#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

void child_process() {
    printf("I'm child process! pid=%d\n", getpid());
    sleep(1);
    _exit(0);
}
 
int main() {
    int pid;
    int status;
 
    pid = fork();
 
    if (pid == 0) {
        child_process();
    } else {
        while(1);
        waitpid(pid, &status, 0);
    }
}
