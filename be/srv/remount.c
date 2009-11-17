#include <stdio.h>
#include <sys/mount.h>
#include <unistd.h>
int main() {
    sync();
    if (umount("/dev/shm") != 0) {
        perror("umount");
        // It's not so serious.
        //return 1;
    }
    if (mount("devshm", "/dev/shm", "tmpfs", MS_MGC_VAL, NULL) != 0) {
        perror("mount");
        return 1;
    }
    return 0;
}
