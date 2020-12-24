// return how many clock tick interrupts have occurred
// since start.
int sys_uptime(void);
//
// File-system system calls.
// Mostly argument checking, since we don't trust1
// user code, and calls into file.c and fs.c.
//
int sys_dup(void);
int sys_read(void);
int sys_write(void);
int sys_close(void);
int sys_fstat(void);
// Create the path new as a link to the same inode as old.
int sys_link(void);
//PAGEBREAK!
int sys_unlink(void);
int sys_open(void);
int sys_mkdir(void);
int sys_mknod(void);
int sys_chdir(void);
int sys_exec(void);
int sys_pipe(void);
