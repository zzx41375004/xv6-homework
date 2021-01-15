#ifndef _VM_H_ //如果没有引入头文件file.h
    #define _VM_H_ //那就引入头文件file.h
int myallocuvm(pde_t *pgdir, uint start, uint end);
int mydeallocuvm(pde_t *pgdir, uint start, uint end);
#endif