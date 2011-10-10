#include <stdio.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <sys/resource.h>

static void setval(int sys, int val);

int main() {
#define DECLARE_HOOK(syscall)                           \
    puts("reseting " #syscall);                         \
    setval(SYS_ ## syscall, 0);
#include "sandbox.c"
}

static void setval(int sys, int val) {
    if (setpriority(SANDBOX_MAGIC_PRIORITY, sys, val)) {
        perror("");
    }
}
