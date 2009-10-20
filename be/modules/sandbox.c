#define SANDBOX_MAGIC_PRIORITY 1764

#ifdef DECLARE_HOOK

DECLARE_HOOK(execve)
DECLARE_HOOK(setpgid)
DECLARE_HOOK(setsid)
DECLARE_HOOK(setuid)
DECLARE_HOOK(setgid)
DECLARE_HOOK(getpriority)
DECLARE_HOOK(setpriority)

#else

#include <asm/unistd_32.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/pid.h>
#include <linux/pid_namespace.h>
#include <linux/sched.h>
#include <linux/syscalls.h>

MODULE_LICENSE("GPL");

// grep sys_call_table /boot/System.map-2.6.26-2-xen-686
#define SYS_CALL_TABLE ((void**)0xc02d355c)

#define PID_MAX ((int*)0xc035df8c)
#define PID_MAX_MIN ((int*)0xc035df90)
#define PID_MAX_MAX ((int*)0xc035df94)

#define DECLARE_HOOK(syscall)                   \
    static int syscall ## _cnt;
#include "sandbox.c"
#undef DECLARE_HOOK

#define DEFINE_HOOK(name, args)                 \
    asmlinkage int (*orig_ ## name) args ;      \
    asmlinkage static int hook_ ## name args

DEFINE_HOOK(execve,
            (const char *filename, char *const argv[], char *const envp[])) {
    if (current->euid != 0) {
        execve_cnt++;
    }
    return orig_execve(filename, argv, envp);
}

DEFINE_HOOK(setpgid, (pid_t pid, pid_t pgid)) {
    if (current->euid != 0) {
        if (pid == 0 || pgid == 0 || pid != pgid) {
            setpgid_cnt++;
            printk(KERN_INFO "setpgid(%d, %d) %d\n",
                   pid, pgid, current->euid);
            return -EPERM;
        }
    }
    return orig_setpgid(pid, pgid);
}

DEFINE_HOOK(setsid, (void)) {
    if (current->euid != 0) {
        setsid_cnt++;
        printk(KERN_INFO "setsid()\n");
        return -EPERM;
    }
    return orig_setsid();
}

DEFINE_HOOK(setuid, (uid_t uid)) {
    if (current->euid != 0) {
        setuid_cnt++;
        printk(KERN_INFO "setuid(%d)\n", uid);
        return -EPERM;
    }
    return orig_setuid(uid);
}

DEFINE_HOOK(setgid, (gid_t gid)) {
    if (current->euid != 0) {
        setgid_cnt++;
        printk(KERN_INFO "setgid(%d)\n", gid);
        return -EPERM;
    }
    return orig_setgid(gid);
}

DEFINE_HOOK(getpriority, (int which, int who)) {
    if (which == SANDBOX_MAGIC_PRIORITY) {
        switch (who) {
#define DECLARE_HOOK(syscall)                   \
            case __NR_ ## syscall:              \
                return syscall ## _cnt;
#include "sandbox.c"
#undef DECLARE_HOOK
        default:
            printk(KERN_INFO "getpriority(%d, %d)\n", which, who);
        }
    }
    return orig_getpriority(which, who);
}

DEFINE_HOOK(setpriority, (int which, int who, int prio)) {
    if (which == SANDBOX_MAGIC_PRIORITY) {
        if (who == __NR_setpriority) {
            printk(KERN_INFO "setpriority for setpriority is not permitted\n");
            return -EPERM;
        } else if (who == __NR_getpid) {
            struct pid_namespace* pid_ns;

            if (prio <= *PID_MAX_MIN ||
                prio >= *PID_MAX ||  prio >= *PID_MAX_MAX) {
                return -EINVAL;
            }

            pid_ns = task_active_pid_ns(current);
            pid_ns->last_pid = prio;
            printk(KERN_INFO "setpid(%d) max_min=%d max_max=%d max=%d\n",
                   prio, *PID_MAX_MIN, *PID_MAX_MAX, *PID_MAX);
            return 0;
        }

        switch (who) {
#define DECLARE_HOOK(syscall)                   \
            case __NR_ ## syscall: {            \
                syscall ## _cnt = prio;         \
                return 0;                       \
            }
#include "sandbox.c"
#undef DECLARE_HOOK
        default:
            printk(KERN_INFO "setpriority(%d, %d, %d)\n", which, who, prio);
        }
    }
    return orig_setpriority(which, who, prio);
}

int sandbox_init(void) {
    printk(KERN_INFO "sandbox_init called !\n");

#define DECLARE_HOOK(syscall)                               \
    syscall ## _cnt = 0;                                    \
    orig_ ## syscall = SYS_CALL_TABLE[__NR_ ## syscall];    \
    SYS_CALL_TABLE[__NR_ ## syscall] = hook_ ## syscall;
#include "sandbox.c"
#undef DECLARE_HOOK

    return 0;
}

void sandbox_exit(void) {
    printk(KERN_INFO "sandbox_exit called !\n");

#define DECLARE_HOOK(syscall)                                    \
        SYS_CALL_TABLE[__NR_ ## syscall] = orig_ ## syscall;
#include "sandbox.c"
#undef DECLARE_HOOK
}

module_init(sandbox_init);
module_exit(sandbox_exit);

#endif
