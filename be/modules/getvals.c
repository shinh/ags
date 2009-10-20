#include <stdio.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <sys/resource.h>

static int getval(int sys);

int main() {
#define DECLARE_HOOK(syscall)                           \
    printf(#syscall "=%d\n", getval(SYS_ ## syscall));
#include "sandbox.c"
}

static int getval(int sys) {
    return 20 - getpriority(SANDBOX_MAGIC_PRIORITY, sys);
}
