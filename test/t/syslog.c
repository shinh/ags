#include <stdio.h>
#include <stdlib.h>
#include <sys/klog.h>

#define SYSLOG_ACTION_READ_ALL 3
#define SYSLOG_ACTION_SIZE_BUFFER 10

int main() {
  char* buf;
  int r;
  r = klogctl(SYSLOG_ACTION_SIZE_BUFFER, 0, 0);
  if (r < 0) {
    perror("SYSLOG_ACTION_SIZE_BUFFER");
    return 1;
  }
  printf("size=%d\n", r);

  buf = malloc(r);
  r = klogctl(SYSLOG_ACTION_READ_ALL, buf, r);
  if (r < 0) {
    perror("SYSLOG_ACTION_SIZE_BUFFER");
    return 1;
  }
  puts(buf);
}
