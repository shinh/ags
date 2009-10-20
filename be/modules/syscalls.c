#include <stdio.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <sys/resource.h>

int main() {
    puts("SYSCALLS = {");
#define DECLARE_HOOK(syscall)                           \
    printf("  :" #syscall " => %d,\n", SYS_ ## syscall);
#include "sandbox.c"
    puts("}");

    printf("SANDBOX_MAGIC_PRIORITY = %d\n", SANDBOX_MAGIC_PRIORITY);
}
