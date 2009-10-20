#include <stdio.h>
#include <sys/mount.h>
int main() {
    if (umount("/dev/shm") != 0) {
        perror("umount");
        return 1;
    }
    if (mount("devshm", "/dev/shm", "tmpfs", MS_MGC_VAL, NULL) != 0) {
        perror("mount");
        return 1;
    }
    return 0;
}
