w1-gpio-cl
==========

This is a Linux kernel-mode driver, intended as an enhancement/substitution
of the standard Linux `w1-gpio` 1-wire bus master driver. Contrary to
the standard driver, `w1-gpio-cl` is not a platform device driver, therefore
doesn't need any specific device-tree overlay nor preconfigured kernel (except
usual 1-wire support via the `wire` module). Moreover, there is possible
coexistence between `w1-gpio` and `w1-gpio-cl`, provided no GPIOs conflict
exists.

Module Configuration
--------------------

`w1-gpio-cl` is fully configured via its command line parameters while loading
the driver. The configuration allows to launch many 1-wire bus masters
controlling different GPIO pins. For parasite powering support, it is
possible to choose the type of the strong pull-up to be used.

General configuration syntax is:
```
modprobe w1-gpio-cl m1="gdt:num[,od][,bpu|gpu:num[,rev]]" [m2="..." ...]
```

NOTE: `:` and `,` syntax tokens may be replaced by `=` and `;` respectively,
so `m1="gdt:4,od"` is equivalent to `m1="gdt:4;od"`, `m1="gdt=4,od"` or
`m1="gdt=4;od"`.

`m1`, `m2`, ... `mN` - configure up to N (where N=5 for the standard module
compilation) bus masters, each one controlling different 1-wire bus connected
to its GPIO pin (specified in `gdt`). At least one bus master specification
(that is `m1`) must be provided. It's worth to note, the `X` index in `mX`
parameter specifies an order in which bus masters are registered in the 1-wire
subsystem. The index doesn't need to correspond to the bus master id assigned
by the kernel.

Each of bus master configurations consist of set of parameters listed below:

* `gdt` - specifies GPIO number associated with the 1-wire data wire (the
  1-wire bus). This parameter is obligatory for each bus master specification.

* `od` - if specified, the data wire GPIO (`gdt`) is of an open drain type.

* `bpu` - if specified, parasite powering is enabled via the data wire strong
  pull-up bit-banging. This type of strong pull-up is possible only for non
  open-drain type of the data wire GPIO (`gdt`).

* `gpu` - specifies GPIO number used for controlling strong pull-up for
  parasite powering. The GPIO is working in the output mode and is set to the
  low state if the strong pull-up is active, and to the high state otherwise.

  The strong pull-up controlled by the `gpu` GPIO is the only possibility for
  an open-drain type of the data wire GPIO (`gdt`). In this case the `gpu` GPIO
  may be connected to a P-channel MOSFET gate controlling the `Vcc` strong
  pull-up as presented on the following figure.

  ![External GPIO strong pull-up](schema/gpu.png)

  NOTE: In place of the MOSFET it's possible to use a PNP bipolar transistor
  with its emitter connected to `Vcc`, collector to the data wire and base to
  the controlling GPIO (`gpu`). If needed base-collector current reducing resistor
  shall be placed between the transistor's base and `gpu` pin.

* `rev` - if specified and the `gpu` parameter is provided, the `gpu` GPIO
  logic is reversed for the strong pull-up activation: GPIO in the high state
  if the strong pull-up is active, low state - otherwise.

Example of Usage
----------------

![Example](schema/example.png)

In this example, there have been configured three bus masters:

* 1st one on GPIO1 controlling non-parasitically powered thermometers.

* 2nd one on GPIO2 controlling parasitically powered thermometers. Strong
  pull-up is performed via the data wire bit-banging (non open-drain data GPIO).

* 3nd one devoted to handle iButton reader(s) only. Using separate 1-wire bus
  in this case is justified by the performance reason. The iButton bus is empty
  for most of its time, and is scanned/searched much more often than other
  buses for presence of authorized iButtons existence.

NOTE: GPIO1, GPIO2, GPIO3 are numbers specifying actual GPIO pins.

Compilation and Loading
-----------------------

The driver module may be compiled directly on the target machine or
cross-compiled and the result to be copied into the target machine.
If you are not familiar with the Linux kernel building process please refer to
[this link](https://www.raspberrypi.org/documentation/linux/kernel/building.md)
first. It provides good introduction to the topic of kernel
compilation/cross-compilation for Raspberry Pi boards.

**Prerequisites**

* Building tool-set.

  * For compilation on the target machine Linux kernel building tools may be
    installed by (for Debian based systems):
    ```
    sudo apt-get install build-essential bc bison flex libssl-dev
    ```

  * For cross-compilation appropriate target system tool-chain need to be
    installed on the compiling machine (e.g. package `crossbuild-essential-armhf`
    for 32-bit or `crossbuild-essential-arm64` for 64-bit ARM). Remaining tools
    to be installed on the compiling machine:
    ```
    sudo apt-get install make bc bison flex libssl-dev
    ```

* Kernel headers and `kbuild` scripts corresponding to the target kernel.

  * For compilation on the target machine the required headers may be installed
    by:
    ```
    sudo apt-get install linux-headers-KERNEL_RELEASE
    ```
    where `KERNEL_RELEASE` corresponds to the kernel release version on the
    target (to be checked by `uname -r`). In case the package repository
    contains kernel headers corresponding to the current kernel image the
    following command will install appropriate headers on the target machine:
    ```
    sudo apt-get install linux-headers-`uname -r`
    ```
    In case the target's system package repository doesn't contain kernel
    headers package in a required version (usually the case for Raspberry Pi
    Raspbian OS) there is a need to use kernel sources as described in the
    subsequent point.

  * For cross-compilation it's recommended to use Linux kernel sources
    corresponding to the kernel version installed on the target machine.
    The kernel sources need to be prepared via proper configuration and
    `modules_prepare` as follows (launched from the kernel sources directory
    on the compiling machine):
    ```
    ARCH=... CROSS_COMPILE=... make CONFIG_TARGET modules_prepare
    ```
    where `CONFIG_TARGET` is a specific kernel target configuration (e.g. for
    Raspberry Pi boards the configuration shall be set to `bcmrpi_defconfig`,
    `bcm2709_defconfig`, `bcm2711_defconfig` or `bcmrpi3_defconfig` depending
    on the platform version). `ARCH` and `CROSS_COMPILE` are required to
    indicate target architecture and cross-compiling tool-chain.

    NOTE 1: When using kernel sources while compiling on the target machine,
    there is no need to set `ARCH` and `CROSS_COMPILE`, since the local tool-set
    is used for compilation.

    NOTE 2: When compiling for Raspberry Pi,
    [`search_kernel_commit.sh`](https://github.com/pstolarz/rpi-tools/blob/master/search_kernel_commit.sh)
    script may be used to find commit on the official
    [RPi kernel repository](https://github.com/raspberrypi/linux)
    for target's kernel version.

**Compilation**

General compilation command syntax is as follows (launched from the `w1-gpio-cl`
project directory):
```
[KERNEL_SRC=...] [ARCH=...] [CROSS_COMPILE=...] [CONFIG_W1_MAST_MAX=...] make
```

The result is `w1-gpio-cl.ko` driver module located in the project directory.
All compilation definitions (`KERNEL_SRC`, `ARCH`, ...) are optional, with the
following meaning:

* `KERNEL_SRC`: specifies kernel sources directory in case they are used
  instead of the pre-installed kernel headers (see above).

* `ARCH`, `CROSS_COMPILE`: are used for module cross-compilation exactly as
  for the Linux kernel.

* `CONFIG_W1_MAST_MAX`: by default the module is compiled to support up to 5 bus
  masters. This may be changed by setting this definition.

**Installation**

If the module was compiled on the target machine it's possible to install it
into the destination directory by:
```
sudo make install
```
and uninstall by:
```
sudo make uninstall
```

If the module was cross-compiled, copy `w1-gpio-cl.ko` module into its destination
location on the target machine (`/lib/modules/KERNEL_RELEASE/kernel/drivers/w1/masters`)
and remake the kernel modules dependencies by `sudo depmod`.

**Loading**
```
sudo modprobe w1-gpio-cl MODULE_CONFIG
```
where the `MODULE_CONFIG` specifies 1-wire bus master(s) configuration as
described above.

If you need to load the module automatically create the following files:
* `/etc/modules-load.d/w1-gpio-cl.conf` with content:
```
w1-gpio-cl
```
* `/etc/modprobe.d/w1-gpio-cl.conf` with content:
```
options w1-gpio-cl MODULE_CONFIG
```
where the `MODULE_CONFIG` specifies 1-wire bus master(s) configuration.

**DKMS**

The module may be installed as part of [DKMS](https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support)
system. To install `w1-gpio-cl` as DKMS module launch the following commands
from the module source directory:
```
sudo dkms add .
sudo dkms install w1-gpio-cl/MODULE_VER
```
where `MODULE_VER` denotes module version (e.g. `1.2.1`). From now any kernel
updates on the target machine will precompile `w1-gpio-cl` module accordingly.

License
-------

GNU GENERAL PUBLIC LICENSE v2. See LICENSE file for details.
