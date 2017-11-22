# max number of supported w1 bus masters
CONFIG_W1_MAST_MAX ?= 5

KERN_BLD_DIR:=$(shell if [ "${KERNEL_SRC}x" = "x" ]; then echo "/lib/modules/`uname -r`/build"; else echo "${KERNEL_SRC}"; fi;)
KERN_SRC_DIR:=$(shell if [ "${KERNEL_SRC}x" = "x" ]; then echo "/lib/modules/`uname -r`/source"; else echo "${KERNEL_SRC}"; fi;)

.PHONY: all clean distclean gen-mast w1-headers install uninstall tags

obj-m = w1-gpio-cl.o
ccflags-y = -DCONFIG_W1_MAST_MAX=${CONFIG_W1_MAST_MAX}

all: gen-mast w1-headers
	$(MAKE) -C ${KERN_BLD_DIR} M=$(PWD) modules

clean:
	-$(MAKE) -C ${KERN_BLD_DIR} M=$(PWD) clean
	rm -f gen-mast.h

distclean: clean
	rm -f w1 kernel-source kernel-build tags

gen-mast:
	@for i in `seq 1 ${CONFIG_W1_MAST_MAX}`; \
	do \
	  case $$i in \
	  1) \
	    echo "/* This file was generated.\n   Don't edit or changes will be lost.\n */\n" >$@.h; \
	    pf="st";; \
	  2) \
	    pf="nd";; \
	  3) \
	    pf="rd";; \
	  *) \
	    pf="th";; \
	  esac; \
	  echo "static char *m$$i=NULL;" >>$@.h; \
	  echo "module_param(m$$i, charp, 0444);" >>$@.h; \
	  echo "MODULE_PARM_DESC(m$$i, \"$$i$$pf w1 bus master specification\");\n" >>$@.h; \
	done; \
	echo "static const char *get_mast_arg(int i)\n{\n	switch (i+1)\n	{" >>$@.h; \
	for i in `seq 1 ${CONFIG_W1_MAST_MAX}`; \
	do \
	  echo "	case $$i: return m$$i;" >>$@.h; \
	done; \
	echo "	}\n	return NULL;\n}" >>$@.h; \
	echo "\`$@.h' has been generated."

w1-headers:
	@if [ ! -L w1 ]; then \
	  if [ -d ${KERN_SRC_DIR}/drivers/w1 ]; then \
	    ln -s ${KERN_SRC_DIR}/drivers/w1 w1; \
	  else \
	    if [ "${KERNEL_SRC}x" = "x" ]; then \
	      ln -s w1-internal w1; \
	      echo "\nNOTE: The compiled module needs w1 set of headers, which is a part of the internal"; \
	      echo "(not the public) part of the w1 API. The headers are contained in the full Linux"; \
	      echo "kernel source tree."; \
	      echo "Since the kernel sources has not been detected on this platform, the compilation"; \
	      echo "process will use headers which are part of this source bundle (included in"; \
	      echo "./w1-internal directory). Linux kernel API is not persistent across versions, so"; \
	      echo "it is STRONGLY recommended to set ./w1 symbolic link to \`drivers/w1' subdirectory"; \
	      echo "of the target kernel sources. This way proper w1 headers will be used.\n"; \
	      read -p "Press ENTER to continue..." NULL; \
	    else \
	      echo "\nERROR: w1 sources not found in \`${KERNEL_SRC}'"; \
	      exit 1; \
	    fi; \
	  fi; \
	fi;

install:
	cp $(obj-m:.o=.ko) /lib/modules/`uname -r`/kernel/drivers/w1/masters
	depmod

uninstall:
	rm -f /lib/modules/`uname -r`/kernel/drivers/w1/masters/$(obj-m:.o=.ko)
	depmod

tags:
	@if [ ! -L kernel-source ]; then \
	  ln -s ${KERN_SRC_DIR} kernel-source; \
	fi; \
	if [ ! -L kernel-build -a "${KERNEL_SRC}x" = "x" ]; then \
	  ln -s ${KERN_BLD_DIR} kernel-build; \
	fi; \
	echo "Generating tags..."; \
	ctags -R --c-kinds=+px --c++-kinds=+px .;
