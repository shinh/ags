TARGETS = sandbox.ko getvals reset syscalls
obj-m := sandbox.o

all: $(TARGETS)

sandbox.ko: sandbox.c
	$(MAKE) -C /lib/modules/`uname -r`/build SUBDIRS=`pwd` modules

clean:
	rm -f $(TARGETS)
