TARGETS = srv/local/watch.so

all: $(TARGETS)

srv/local/watch.so: srv/watch.c
	$(CC) -g -O -shared -o $@ $< -ldl

