#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/syscall.h>
 
#define MAX_PTHREAD_NUM  256
void* pthread_func(void *args) {
    printf("create pthread task! pid: %d\n", syscall(__NR_gettid));
    while(1);
}
 
int main(int argc, char **argv) {
    int i, n = 1;
    pthread_t tid[MAX_PTHREAD_NUM];

    if (argc == 2)
        n = atoi(argv[1]);
    for (i = 0; i < n; i++)
        pthread_create(&tid[i], NULL, pthread_func, NULL);

    for (i = 0; i < n; i++)
        pthread_join(tid[i], NULL);
    return 0;
}
