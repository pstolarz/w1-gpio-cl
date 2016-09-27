# max number of supported masters
CONFIG_W1_MAST_MAX=5

.PHONY: all clean gen-mast w1-headers ctags

obj-m = w1-gpio-cl.o
ccflags-y = -DCONFIG_W1_MAST_MAX=${CONFIG_W1_MAST_MAX}

all: gen-mast w1-headers
	$(MAKE) -C /lib/modules/`uname -r`/build M=$(PWD) modules

clean:
	rm -f gen-mast.h
	$(MAKE) -C /lib/modules/`uname -r`/build M=$(PWD) clean

gen-mast:
	@for i in `seq 1 ${CONFIG_W1_MAST_MAX}`; \
	do \
	  case $$i in \
	  1) \
	    echo "/* This file was generated.\n   Don't edit or changes will be lost.\n */\n" >$@.h; \
	    pf="st";; \
	  2) \
	    pf="nd";; \
	  *) \
	    pf="th";; \
	  esac; \
	  echo "static char *m$$i=NULL;" >>$@.h; \
	  echo "module_param(m$$i, charp, 0444);" >>$@.h; \
	  echo "MODULE_PARM_DESC(m$$i, \"$$i$$pf w1 master specification\");\n" >>$@.h; \
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
	  if [ -d /lib/modules/`uname -r`/drivers/w1 ]; then \
	    ln -s /lib/modules/`uname -r`/drivers/w1 w1; \
	  else \
	    ln -s w1-internal w1; \
	    echo "\nNOTE: The compiled module needs w1 set of headers, which is part of the internal"; \
	    echo "(not the public) part of the w1 subsystem. The headers are contained in the full"; \
	    echo "Linux kernel source tree."; \
	    echo "Since the kernel sources has not been detected on this platform, the compilation"; \
	    echo "process will use headers which are part of this source bundle (included in"; \
	    echo "./w1-internal directory). It's ALWAYS BETTER to use headers which are aligned"; \
	    echo "with the target kernel, therefore it's STRONGLY recommended to set ./w1 symbolic"; \
	    echo "link to \`drivers/w1' subdirectory of the target kernel sources.\n"; \
	    read -p "Press ENTER to continue..." stdin; \
	  fi; \
	fi;

ctags:
	@if [ ! -L kernel-source ]; then \
	  ln -s /lib/modules/`uname -r`/source kernel-source; \
	fi; \
	if [ ! -L kernel-build ]; then \
	  ln -s /lib/modules/`uname -r`/build kernel-build; \
	fi; \
	echo "Generating C tags..."; \
	ctags -R --c-kinds=+px --c++-kinds=+px .;
