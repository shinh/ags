#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#define STDIN_MAX 130000
char buf[STDIN_MAX+1];
int main(int argc, char* argv[]) {
  argv++;
  if (!strcmp(argv[0], "-i")) {
    argv++;
    ssize_t l = read(0, buf, STDIN_MAX);
    if (l < 0) {
      perror("read failed");
      return 1;
    }
    if (l < STDIN_MAX) {
      buf[l] = 0;
      setenv("STDIN", buf, 1);
    } else {
      fprintf(stderr, "NOTE: $(STDIN) won't work for this problem\n");
    }
  }
  execv(argv[0], argv);
  perror("exec failed");
}

