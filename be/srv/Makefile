all: remount

remount: remount.c
	$(CC) $< -o $@.tmp
	chmod 4755 $@.tmp
	mv $@.tmp $@
