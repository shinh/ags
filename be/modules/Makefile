obj-m := sandbox.o

all: sandbox.ko getvals

sandbox.ko: sandbox.c
	$(MAKE) -C /lib/modules/`uname -r`/build SUBDIRS=`pwd` modules
