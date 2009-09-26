/*
 * libc-based sandbox
 *
 * this approach is fast and easy, but not perfect.
 *
 * override:
 *  exec families (l,le,lp,v,ve,vp)
 *  system
 *  posix_spawn, posix_spawnp
 *  open, fopen, open64, fopen64, freopen, freopen64, openat, openat64,
    _IO_file_fopen, _IO_file_open, _IO_fopen, __open, __open64
 *  _IO_proc_open, popen
 *  syscall
 */

#define _GNU_SOURCE
#include <assert.h>
#include <dlfcn.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

typedef int (*execve_t)(const char *, char *const *, char *const *);
typedef int (*execl_t)(const char *, const char *, ...);
typedef int (*execlp_t)(const char *, const char *, ...);
typedef int (*execle_t)(const char *, const char *, ...);
typedef int (*execv_t)(const char *, char *const *);
typedef int (*execvp_t)(const char *, char *const *);

typedef int (*system_t)(const char *);

typedef int (*posix_spawn_t)(
    pid_t *, char *, void *, void *, char * [], char * []);
typedef int (*posix_spawnp_t)(
    pid_t *, char *, void *, void *, char * [], char * []);

typedef int (*fexecve_t)(int fd, char *const *, char *const *);

typedef FILE *(*popen_t)(const char *, const char *);
typedef FILE *(*_IO_proc_open_t)(const char *, const char *);

typedef int (*open_t)(const char *, int, ...);
typedef int (*open64_t)(const char *, int, ...);
typedef FILE *(*fopen_t)(const char *, const char *);
typedef FILE *(*fopen64_t)(const char *, const char *);
typedef FILE *(*freopen_t)(const char *, const char *, FILE *);
typedef FILE *(*freopen64_t)(const char *, const char *, FILE *);
typedef int (*openat_t)(int, const char *, int);
typedef int (*openat64_t)(int, const char *, int);
typedef FILE *(*_IO_fopen_t)(const char *, const char *);
typedef FILE *(*_IO_file_open_t)(const char *, const char *);
typedef FILE *(*_IO_file_fopen_t)(const char *, const char *);

typedef int (*syscall_t)(int number, ...);

static int inited = 0;
static execve_t libc_execve;
static execl_t libc_execl;
static execlp_t libc_execlp;
static execle_t libc_execle;
static execv_t libc_execv;
static execvp_t libc_execvp;
static fexecve_t libc_fexecve;
static system_t libc_system;
static posix_spawn_t libc_posix_spawn;
static posix_spawnp_t libc_posix_spawnp;
static popen_t libc_popen;
static _IO_proc_open_t libc__IO_proc_open;
static open_t libc_open;
static open64_t libc_open64;
static fopen_t libc_fopen;
static fopen64_t libc_fopen64;
static freopen_t libc_freopen;
static freopen64_t libc_freopen64;
static openat_t libc_openat;
static openat64_t libc_openat64;
static _IO_fopen_t libc__IO_fopen;
static _IO_file_open_t libc__IO_file_open;
static _IO_file_fopen_t libc__IO_file_fopen;
static syscall_t libc_syscall;

__attribute__((constructor)) static void init() {
    if (inited) return;
    inited = 1;
    libc_execve = (execve_t)dlsym(RTLD_NEXT, "execve");
    libc_execl = (execl_t)dlsym(RTLD_NEXT, "execl");
    libc_execlp = (execlp_t)dlsym(RTLD_NEXT, "execlp");
    libc_execle = (execle_t)dlsym(RTLD_NEXT, "execle");
    libc_execv = (execv_t)dlsym(RTLD_NEXT, "execv");
    libc_execvp = (execvp_t)dlsym(RTLD_NEXT, "execvp");
    libc_system = (system_t)dlsym(RTLD_NEXT, "system");
    libc_posix_spawn = (posix_spawn_t)dlsym(RTLD_NEXT, "posix_spawn");
    libc_posix_spawnp = (posix_spawnp_t)dlsym(RTLD_NEXT, "posix_spawnp");
    libc_popen = (popen_t)dlsym(RTLD_NEXT, "popen");
    libc__IO_proc_open = (_IO_proc_open_t)dlsym(RTLD_NEXT, "_IO_proc_open");
    libc_open = (open_t)dlsym(RTLD_NEXT, "open");
    libc_open64 = (open64_t)dlsym(RTLD_NEXT, "open64");
    libc_fopen = (fopen_t)dlsym(RTLD_NEXT, "fopen");
    libc_fopen64 = (fopen64_t)dlsym(RTLD_NEXT, "fopen64");
    libc_freopen = (freopen_t)dlsym(RTLD_NEXT, "freopen");
    libc_freopen64 = (freopen64_t)dlsym(RTLD_NEXT, "freopen64");
    libc_openat = (openat_t)dlsym(RTLD_NEXT, "openat");
    libc_openat64 = (openat64_t)dlsym(RTLD_NEXT, "openat64");
    libc__IO_fopen = (_IO_fopen_t)dlsym(RTLD_NEXT, "_IO_fopen");
    libc__IO_file_open = (_IO_file_open_t)dlsym(RTLD_NEXT, "_IO_file_open");
    libc__IO_file_fopen = (_IO_file_fopen_t)dlsym(RTLD_NEXT, "_IO_file_fopen");
    libc_syscall = (syscall_t)dlsym(RTLD_NEXT, "syscall");

    assert(libc_execve);
    assert(libc_execl);
    assert(libc_execlp);
    assert(libc_execle);
    assert(libc_execv);
    assert(libc_execvp);
    assert(libc_system);
    assert(libc_posix_spawn);
    assert(libc_posix_spawnp);
    assert(libc_popen);
    assert(libc__IO_proc_open);
    assert(libc_open);
    assert(libc_open64);
    assert(libc_fopen);
    assert(libc_fopen64);
    assert(libc_freopen);
    assert(libc_freopen64);
    assert(libc_openat);
    assert(libc_openat64);
    assert(libc__IO_fopen);
    assert(libc__IO_file_open);
    assert(libc__IO_file_fopen);
    assert(libc_syscall);
}

static void watch_log(const char *fmt, ...) {
    va_list ap;
    FILE *fp = libc_fopen("/tmp/watch.log", "a");
    va_start(ap, fmt);
    vfprintf(fp, fmt, ap);
    va_end(ap);
    fclose(fp);
}

int execve(const char *file, char *const *argv, char *const *envp) {
    watch_log("exec %s\n", file);
    return libc_execve(file, argv, envp);
}
#define GET_ARGS \
    int argc = 0; \
    const char **argv = (const char **)malloc(sizeof(char *) * 2); \
    va_list ap; \
    argv[0] = arg; \
    argv[1] = NULL; \
    va_start(ap, arg); \
    while (argv[argc++]) { \
        argv = (const char **)realloc(argv, sizeof(char *) * (argc + 2)); \
        argv[argc] = va_arg(ap, char *); \
    } \
    va_end(ap)

int execl(const char *path, const char *arg, ...) {
    GET_ARGS;
    watch_log("exec %s\n", path);
    return libc_execv(path, (char *const *)argv);
}
int execlp(const char *file, const char *arg, ...) {
    GET_ARGS;
    watch_log("exec %s\n", file);
    return libc_execvp(file, (char *const *)argv);
}
int execle(const char *path, const char *arg, ...) {
    GET_ARGS;
    watch_log("exec %s\n", path);
    return libc_execv(path, (char *const *)argv);
}
int execv(const char *path, char *const *argv) {
    watch_log("exec %s\n", path);
    return libc_execv(path, argv);
}
int execvp(const char *file, char *const *argv) {
    watch_log("exec %s\n", file);
    return libc_execvp(file, argv);
}
int fexecve(int fd, char *const *argv, char *const *envp) {
    watch_log("exec %d\n", fd);
    return libc_fexecve(fd, argv, envp);
}
int system(const char *command) {
    watch_log("exec %s\n", command);
    return libc_system(command);
}

int posix_spawn(pid_t *a, char *b, void *c, void *d, char *e[], char *f[]) {
    watch_log("exec\n");
    return libc_posix_spawn(a, b, c, d, e, f);
}
int posix_spawnp(pid_t *a, char *b, void *c, void *d, char *e[], char *f[]) {
    watch_log("exec\n");
    return libc_posix_spawnp(a, b, c, d, e, f);
}
FILE *popen(const char *command, const char *type) {
    watch_log("exec %s\n", command);
    return libc_popen(command, type);
}
FILE *_IO_proc_open(const char *command, const char *type) {
    watch_log("exec %s\n", command);
    return libc__IO_proc_open(command, type);
}
FILE *_IO_popen(const char *command, const char *type) {
    watch_log("exec %s\n", command);
    return libc__IO_proc_open(command, type);
}

int open(const char *path, int flags, ...) {
    if ((flags & O_WRONLY) || (flags & O_RDWR)) {
        watch_log("open %s w\n", path);
    }
    return libc_open(path, flags);
}
int open64(const char *path, int flags, ...) {
    if ((flags & O_WRONLY) || (flags & O_RDWR)) {
        watch_log("open %s w\n", path);
    }
    return libc_open64(path, flags);
}
int __open(const char *path, int flags, ...) {
    if ((flags & O_WRONLY) || (flags & O_RDWR)) {
        watch_log("open %s w\n", path);
    }
    return libc_open(path, flags);
}
int __open64(const char *path, int flags, ...) {
    if ((flags & O_WRONLY) || (flags & O_RDWR)) {
        watch_log("open %s w\n", path);
    }
    return libc_open64(path, flags);
}

FILE *fopen(const char *path, const char *mode) {
    if (strchr(mode, 'w') || strchr(mode, 'a')) {
        watch_log("open %s w\n", path);
    }
    return libc_fopen(path, mode);
}
FILE *fopen64(const char *path, const char *mode) {
    init();
    if (strchr(mode, 'w') || strchr(mode, 'a')) {
        watch_log("open %s w\n", path);
    }
    return libc_fopen64(path, mode);
}
FILE *freopen(const char *path, const char *mode, FILE *stream) {
    if (strchr(mode, 'w') || strchr(mode, 'a')) {
        watch_log("open %s w\n", path);
    }
    return libc_freopen(path, mode, stream);
}
FILE *freopen64(const char *path, const char *mode, FILE *stream) {
    if (strchr(mode, 'w') || strchr(mode, 'a')) {
        watch_log("open %s w\n", path);
    }
    return libc_freopen64(path, mode, stream);
}

int openat(int dirfd, const char *path, int flags, ...) {
    if ((flags & O_WRONLY) || (flags & O_RDWR)) {
        watch_log("openat %s w\n");
        // We don't allow to use openat for writing
        return 0;
    }
    return libc_openat(dirfd, path, flags);
}
int openat64(int dirfd, const char *path, int flags, ...) {
    if ((flags & O_WRONLY) || (flags & O_RDWR)) {
        watch_log("openat %s w\n");
        // We don't allow to use openat for writing
        return 0;
    }
    return libc_openat64(dirfd, path, flags);
}

// We don't allow to use these functions directly
FILE *_IO_fopen(const char *path, const char *mode) {
    watch_log("io_open\n");
    return NULL;
}
FILE *_IO_file_open(const char *path, const char *mode) {
    watch_log("io_open\n");
    return NULL;
}
FILE *_IO_file_fopen(const char *path, const char *mode) {
    watch_log("io_open\n");
    return NULL;
}

long int syscall(long int number, ...) {
    // Don't call syscall
    watch_log("syscall\n");
    return 0;
}
