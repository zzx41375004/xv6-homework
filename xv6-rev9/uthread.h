#ifndef _UTHREAD_H_ //如果没有引入头文件file.h
    #define _UTHREAD_H_ //那就引入头文件file.h
void add_thread(int pid,void *ustack);
void remove_thread(int pid);
int thread_create(void(*start_routine)(void*),void *arg);
int thread_join(void);
void printTCB(void);
int add(int a,int b);
#endif