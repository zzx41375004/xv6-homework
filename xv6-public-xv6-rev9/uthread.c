#include "types.h"
#include "user.h"

#define NTHREAD 4
#define PGSIZE 4096
struct
{
    int pid;
    void *ustack;
    int used;
}threads[NTHREAD] = {0};

void remove_thread(int* pid){
    for (int i = 0; i < NTHREAD; ++i)
    {
        if(threads[i].used && threads[i].pid == *pid){
            free(threads[i].ustack);
            threads[i].pid = 0;
            threads[i].ustack = 0;
            threads[i].used = 0;
            break;
        }
    }
}

int findPos(){
    for (int i = 0; i < NTHREAD; ++i)
    {
        if(threads[i].used == 0){
            return i;
        }
    }
    return -1;
}

int thread_create(void(*start_routine)(void*), void *arg){
    int pos = findPos();
    if(pos == -1){
        printf(1,"Create thread failed! Perhaps because there are too many threads!\n");
        return -1;
    }
    void *stack = malloc(PGSIZE);
    int pid = clone(start_routine, arg, stack);
    if(pid == -1){
        printf(1,"clone failed!\n");
        free(stack);
    }else{
        threads[pos].pid = pid;
        threads[pos].ustack = stack;
        threads[pos].used = 1; 
    }
    return pid;
}

int thread_join(void){
    for(int i = 0; i < NTHREAD; ++i){
        if(threads[i].used == 1){
            int pid = join(&threads[i].ustack);
            if(pid > 0){
                remove_thread(&pid);
                return pid;
            }
        }
    }
    return 0;
}

void printTCB(void){
    for (int i = 0; i < NTHREAD; ++i)
    {
        printf(1,"TCB %d:%d\n",i,threads[i].used);
    }
    
}

