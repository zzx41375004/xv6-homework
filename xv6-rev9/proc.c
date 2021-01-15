#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "vm.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
// Must hold ptable.lock.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;
  int i;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  p->priority = 10;

for(i=1;i<10;i++){
  p->vm[i].next=-1;
}
   p->vm[0].next=0;
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  acquire(&ptable.lock);

  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;

  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  acquire(&ptable.lock);

  // Allocate process.
  if((np = allocproc()) == 0){
    release(&ptable.lock);
    return -1;
  }

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    release(&ptable.lock);
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));

  pid = np->pid;

  np->state = RUNNABLE;

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  if(proc->parent==0 && proc->pthread!=0)
  	wakeup1(proc->pthread);
  else
  	wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  int proc_num,last_proc_num, prio;
  last_proc_num=0;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for( prio=0;prio<20;prio++){
      for(proc_num=0;proc_num<NPROC;proc_num++){
        p=ptable.proc+((last_proc_num+1+proc_num) % NPROC);
        if(p->state != RUNNABLE)
        continue;
        if(p->priority!=prio)
        continue;
        last_proc_num=(last_proc_num+1+proc_num) % NPROC;
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      }
    }
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  proc->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("\n pid: %d, state: %s, prio=%d name: %s\n", p->pid, state, p->priority, p->name);
    int j;
    for(j=p->vm[0].next;j!=0;j=p->vm[j].next){
      cprintf("start: %d, length: %d\n",p->vm[j].start,p->vm[j].length);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

int 
mygrowproc(int n){                 // 首次适应算法
  // struct proc *proc=myproc();
  struct vma *vm = proc->vm;     
  int start = proc->sz;          
  int pre = 0;
  int i,k; //寻找插入的地方

  for(i = vm[0].next; i != 0; i = vm[i].next){
    if(start + n < vm[i].start)
      break;
    start = vm[i].start + vm[i].length;
    pre = i;
  }
  
  for(k = 1; k < 10; k++) {            // 寻找一块没有用的 vma 记录新的内存块（vm[0]除外)
    if(vm[k].next == -1){
      vm[k].next = i;     
      vm[k].start = start;
      vm[k].length = n;

      vm[pre].next = k;  //将vm[k]挂入链表尾部
      
      myallocuvm(proc->pgdir, start, start + n); //为vm[k]分配内存
      switchuvm(proc);  //使内存映像生效
      return start;   // 返回分配的地址
    }
  }
  switchuvm(proc);
  return 0;
}

int
myreduceproc(int start){  // 释放 start 开头的内存块
  // struct proc *proc=myproc();
  int prev = 0;
  int index;
  for(index = proc->vm[0].next; index != 0; index = proc->vm[index].next) {
    if(proc->vm[index].start == start) { //找到对应内存块
      mydeallocuvm(proc->pgdir, start, start + proc->vm[index].length);   //释放内存  
      proc->vm[prev].next = proc->vm[index].next; //从链上摘除
      proc->vm[index].next = -1;  //标记为未用
     switchuvm(proc); //使内存映像生效
     return 0;
    }
    prev = index;
  }
  cprintf("warning: free vma at %x! \n",start);
  return -1;
}

int getcpuid(void)
{
	return cpunum();
}

int clone(void(*fcn)(void*),void* arg,void* stack)
{
  //cprintf("in clone,stack start addr=%p\n",stack);//打印本线程的堆栈
   // struct proc *curproc=myproc(); //记录发出clone的线程(np->pthread 记录的父线程)
   struct proc *np;

   if((np=allocproc())==0) //为新线程分配PCB/TCB
    return -1;

  //由于共享进程印象，只需使用同一个页表即可，无需拷贝内容
  np->pgdir=proc->pgdir; //线程间共用同一个页表
  np->sz=proc->sz;
  np->pthread=proc; //exit时用于找到父进程并唤醒
  np->ustack=stack; //设置自己的线程栈
  np->parent=0;
  *np->tf=*proc->tf; //继承 trapframe

  int* sp=stack+4096-8; //下面将在线程栈填写8字节内容

  //在内核栈中”伪造“现场，假装成返回地址是fcn、用户堆栈是线程栈
  np->tf->eip=(int)fcn;
  np->tf->esp=(int)sp; //top of stack
  np->tf->ebp=(int)sp; //栈帧指针
  np->tf->eax=0;

  //在用户态栈“伪造”现场，将参赛和返回地址（无用的)保存在里面
  *(sp+1)=(int)arg; //*(np->tf->esp+4)=(int)arg
  *sp=0xffffffff; //返回地址(没有用到)
  
  int i;
  for(i=0;i<NOFILE;i++){
    if(proc->ofile[i])
      np->ofile[i]=filedup(proc->ofile[i]);
  }
  np->cwd=idup(proc->cwd);


    safestrcpy(np->name,proc->name,sizeof(proc->name));
    int pid=np->pid;

    acquire(&ptable.lock);
    np->state=RUNNABLE;
    release(&ptable.lock);
    //返回新线程的pid
    return pid;
}

int join(void **stack)
{
	//cprintf("in join,stack pionter=%p\n",*stack);
	struct proc *curproc=proc;
	struct proc *p;
	int havekids;
	acquire(&ptable.lock);
	for(;;){
		//scan through table looking for zombie children
		havekids=0;
		for(p=ptable.proc;p<&ptable.proc[NPROC];p++){
			if(p->pthread!=curproc)
				continue;

			havekids=1;
			if(p->state==ZOMBIE){
				*stack=p->ustack;
				int pid=p->pid;
				kfree(p->kstack); //释放内核栈
				p->kstack=0;
				p->state=UNUSED;
				p->pid=0;
				p->parent=0;
				p->pthread=0;   //记录父线程的指针 p->ustack=0;//线程用户态栈
				p->name[0]=0;
				p->killed=0;
				release(&ptable.lock);
				return pid;
			}
		}
		//No point waiting if we don't have any children
		if(!havekids||curproc->killed){
			release(&ptable.lock);
			return -1;
		}
		//Wait for children to exit
		sleep(curproc,&ptable.lock);
	}
	return 0;
}

int 
cps(void)
{
  struct proc *p;
  sti();	// Enable interrupts
  acquire(&ptable.lock);
  cprintf("name \t pid \t state \t \t priority \n");
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if(p->state == SLEEPING)
    cprintf("%s \t %d \t SLEEPING \t %d\n", p->name, p->pid, p->priority);
    else if(p->state == RUNNING)
    cprintf("%s \t %d \t RUNNING \t %d\n", p->name, p->pid, p->priority);
    else if(p->state == RUNNABLE)
    cprintf("%s \t %d \t RUNNABLE \t %d\n", p->name, p->pid, p->priority);
  }
  release(&ptable.lock);
  return 28;
}
int
chpri( int pid, int priority ) {
 struct proc *p;
 acquire(&ptable.lock);
 for ( p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if ( p->pid == pid ) {
      p->priority = priority;
      break;
    }
 }
 release(&ptable.lock);
 return pid;
}