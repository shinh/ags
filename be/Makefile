TARGETS = \
srv/local/watch.so \
srv/local/dmd2/linux/bin/dmd \
srv/local/dmd/linux/bin/dmd \

all: $(TARGETS)

srv/local/watch.so: srv/watch.c
	$(CC) -g -O -shared -o $@ $< -ldl

srv/local/dmd2/linux/bin/dmd:
	fetcher/d2

srv/local/dmd/linux/bin/dmd:
	fetcher/d

