# max number of supported w1 bus masters
CONFIG_W1_MAST_MAX ?= 5

KERN_BLD_DIR:=$(shell if [ "${KERNEL_SRC}x" = "x" ]; then echo "/lib/modules/`uname -r`/build"; else echo "${KERNEL_SRC}"; fi;)
KERN_SRC_DIR:=$(shell if [ "${KERNEL_SRC}x" = "x" ]; then echo "/lib/modules/`uname -r`/source"; else echo "${KERNEL_SRC}"; fi;)

.PHONY: all clean distclean gen-mast w1-headers install uninstall tags

obj-m = w1-gpio-cl.o
ccflags-y = -DCONFIG_W1_MAST_MAX=${CONFIG_W1_MAST_MAX}

all: gen-mast
	$(MAKE) -C ${KERN_BLD_DIR} M=$(PWD) modules

clean:
	-$(MAKE) -C ${KERN_BLD_DIR} M=$(PWD) clean
	rm -f gen-mast.h

distclean: clean
	rm -f w1 kernel-source kernel-build tags

gen-mast: w1-headers
	@for i in `seq 1 ${CONFIG_W1_MAST_MAX}`; \
	do \
	  case $$i in \
	  1) \
	    echo "/*" >$@.h; \
	    echo " * This file was auto-generated." >>$@.h; \
	    echo " * Don't edit it or changes will be lost." >>$@.h; \
	    echo " */" >>$@.h; \
	    if [ -f w1/w1_int.h ]; then \
	      echo "#include \"w1/w1_int.h\"" >>$@.h; \
	    else \
	      echo "#include \"w1/w1.h\"" >>$@.h; \
	    fi; \
	    echo >>$@.h; \
	   if [ `grep -c bitbang_pullup w1/w1.h` -gt 0 ]; then \
	     echo "NOTE: bitbang_pullup() supported as a pullup callback"; \
	     echo "#ifndef CONFIG_W1_BITBANG_PULLUP" >>$@.h; \
	     echo "# define CONFIG_W1_BITBANG_PULLUP 1" >>$@.h; \
	     echo "#endif" >>$@.h; \
	     echo >>$@.h; \
	   fi; \
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
	  echo "MODULE_PARM_DESC(m$$i, \"$$i$$pf w1 bus master specification\");" >>$@.h; \
	  echo >>$@.h; \
	done; \
	echo "static const char *get_mast_arg(int i)" >>$@.h; \
	echo "{" >>$@.h; \
	echo "	switch (i+1)" >>$@.h; \
	echo "	{" >>$@.h; \
	for i in `seq 1 ${CONFIG_W1_MAST_MAX}`; \
	do \
	  echo "	case $$i: return m$$i;" >>$@.h; \
	done; \
	echo "	}" >>$@.h; \
	echo "	return NULL;" >>$@.h; \
	echo "}" >>$@.h; \
	echo "NOTE: $@.h was generated";

w1-headers:
	@if [ ! -L w1 ]; then \
	  if [ -f ${KERN_SRC_DIR}/drivers/w1/w1_int.h ]; then \
	    ln -s ${KERN_SRC_DIR}/drivers/w1 w1; \
	    echo "NOTE: w1 -> ${KERN_SRC_DIR}/drivers/w1"; \
	  elif [ -f ${KERN_SRC_DIR}/include/linux/w1.h ]; then \
	    ln -s ${KERN_SRC_DIR}/include/linux w1; \
	    echo "NOTE: w1 -> ${KERN_SRC_DIR}/include/linux"; \
	  else \
	    if [ "${KERNEL_SRC}x" = "x" ]; then \
	      ln -s w1-internal w1; \
	      echo "NOTE: w1 -> w1-internal"; \
	      echo "WARNING: The compiled module needs w1 set of headers, \
which have not been detected on this platform. The compilation process will \
use headers which are part of this source bundle (located in ./w1-internal \
directory). Linux kernel API is not persistent across versions, so it is \
STRONGLY recommended to set ./w1 symbolic link to a proper w1 header files \
directory of the target kernel sources."; \
	      read -p "Press ENTER to continue..." NULL; \
	    else \
	      echo "ERROR: w1 sources not found in ${KERNEL_SRC}"; \
	      exit 1; \
	    fi; \
	  fi; \
	else \
	  echo "NOTE: ./w1 symlink is already set and will not be updated. \
Remove it and restart the compilation process in case you want to re-run the \
kernel sources examination."; \
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
