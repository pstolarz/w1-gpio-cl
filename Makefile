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
	@if [ ${CONFIG_W1_MAST_MAX} -lt 1 -o ${CONFIG_W1_MAST_MAX} -gt 100 ]; then \
	  echo "ERROR: Invalid CONFIG_W1_MAST_MAX"; \
	  exit 1; \
	fi
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
	  21|31|41|51|61|71|81|91) \
	    pf="st";; \
	  2|22|32|42|52|62|72|82|92) \
	    pf="nd";; \
	  3|23|33|43|53|63|73|83|93) \
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
	  if [ -f ${KERN_SRC_DIR}/include/linux/w1.h ]; then \
	    ln -s ${KERN_SRC_DIR}/include/linux w1; \
	    echo "NOTE: w1 -> ${KERN_SRC_DIR}/include/linux"; \
	  elif [ -f ${KERN_SRC_DIR}/drivers/w1/w1_int.h ]; then \
	    ln -s ${KERN_SRC_DIR}/drivers/w1 w1; \
	    echo "NOTE: w1 -> ${KERN_SRC_DIR}/drivers/w1"; \
	  elif [ -f ${KERN_BLD_DIR}/include/linux/w1.h ]; then \
	    ln -s ${KERN_BLD_DIR}/include/linux w1; \
	    echo "NOTE: w1 -> ${KERN_BLD_DIR}/include/linux"; \
	  elif [ -f ${KERN_BLD_DIR}/drivers/w1/w1_int.h ]; then \
	    ln -s ${KERN_BLD_DIR}/drivers/w1 w1; \
	    echo "NOTE: w1 -> ${KERN_BLD_DIR}/drivers/w1"; \
	  else \
	    echo "ERROR: w1 headers not found"; \
	    exit 1; \
	  fi; \
	else \
	  echo "NOTE: ./w1 symlink is already set and will not be updated. \
Remove it and restart the compilation process in case you want to re-run the \
kernel sources examination."; \
	fi;

install:
	install -m644 $(obj-m:.o=.ko) /lib/modules/`uname -r`/kernel/drivers/w1/masters
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
