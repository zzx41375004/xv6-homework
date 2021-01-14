#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

struct {
  int amount;
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable[CPUNUMBER];

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);



//getcpuid in kernel mode
int getcpuid()
{
  return cpunum();
}
void
pinit(void)
{
  initlock(&ptable[0].lock, "ptable[0]");
}

//choose the suitable ptable
// as well as choose the cpu
static int getPtableIndex(){
  int i, ret;
  int min = NPROC + 1;
  for(i = 0;i < CPUNUMBER; ++i){
    if(ptable[i].amount < min){
      ret = i;
      min = ptable[i].amount;
    }
  }
  return ret;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
// Must hold ptable[0].lock.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;
  int ptableIndex = getPtableIndex();

  for(p = ptable[ptableIndex].proc; p < &ptable[ptableIndex].proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;

  for (int i = 0; i < 10; ++i)
  {
    p->vm[i].next = -1;
    p->vm[i].length = 0;
  }
  p->vm[0].next = 0;

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

  acquire(&ptable[0].lock);

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

  release(&ptable[0].lock);
}

void ptableinit(void){
  int i;
  for(i = 0; i<CPUNUMBER; ++i){
    ptable[i].amount = 0;
  }
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

  acquire(&ptable[0].lock);

  // Allocate process.
  if((np = allocproc()) == 0){
    release(&ptable[0].lock);
    return -1;
  }

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    release(&ptable[0].lock);
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

  release(&ptable[0].lock);

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

  acquire(&ptable[0].lock);

  // Parent might be sleeping in wait().
  if(proc->parent == 0 && proc -> pthread!=0){
    wakeup1(proc->pthread);
  }else{
    wakeup1(proc->parent);
  }

  // Pass abandoned children to init.
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
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

  acquire(&ptable[0].lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
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
        release(&ptable[0].lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable[0].lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable[0].lock);  //DOC: wait-sleep
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
scheduler(int cpuid)
{
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable[cpuid].lock);
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable[cpuid].lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      p->cpuid = cpuid;
      swtch(&cpu->scheduler, p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable[cpuid].lock);

  }
}

// Enter scheduler.  Must hold only ptable[0].lock
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

  if(!holding(&ptable[0].lock))
    panic("sched ptable[0].lock");
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
  acquire(&ptable[0].lock);  //DOC: yieldlock
  proc->state = RUNNABLE;
  sched();
  release(&ptable[0].lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable[0].lock from scheduler.
  release(&ptable[0].lock);

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

  // Must acquire ptable[0].lock in order to
  // change p->state and then call sched.
  // Once we hold ptable[0].lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable[0].lock locked),
  // so it's okay to release lk.
  if(lk != &ptable[0].lock){  //DOC: sleeplock0
    acquire(&ptable[0].lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable[0].lock){  //DOC: sleeplock2
    release(&ptable[0].lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable[0] lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable[0].lock);
  wakeup1(chan);
  release(&ptable[0].lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable[0].lock);
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable[0].lock);
      return 0;
    }
  }
  release(&ptable[0].lock);
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

  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("\npid:%d, state: %s, name: %s\n", p->pid, state, p->name);
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
      cprintf("start: %d, length: %d\n",p->vm[i].start,p->vm[i].length);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}


int mygrowproc(int n){
  struct vma *vm = proc->vm;
  int start = proc->sz;
  int pre=0;
  int i,k;
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
  {
    if (start + n < vm[i].start)
    {
      break;
    }
    start = vm[i].start + vm[i].length;
    pre = i;
  }
  for(k = 1; k < 10; ++k){
    if(vm[k].next == -1){
      vm[k].next = i;
      vm[k].start = start;
      vm[k].length = n;
      vm[pre].next = k;
      myallocuvm(proc->pgdir, start , start + n);
      switchuvm(proc);
      return start;
    }
  }
  switchuvm(proc);
  return 0; 
}

int myreduceproc(int start){
  int prev=0;
  int i;
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
      if(proc->vm[i].start == start){
        mydeallocuvm(proc->pgdir,start,start+proc->vm[i].length);
        proc->vm[prev].next = proc->vm[i].next;
        proc->vm[i].next=-1;
        switchuvm(proc);
        return 0;
      }
      prev=i;
  }
  cprintf("warning: free vma at %x! \n",start);
  return -1;
}

// malloc space for new stack then pass to clone
int clone(void(*fcn)(void*), void* arg, void* stack)
{
  cprintf("in clone, stack start addr = %p\n", stack);
  struct proc *curproc = proc;  // 调用 clone 的进程
  struct proc *np;

  // allocate a PCB
  if((np = allocproc()) == 0)
   return -1; 
  
  // For clone, don't need to copy entire address space like fork
  np->pgdir = curproc->pgdir;  // 线程间公用页表
  np->sz = curproc->sz;
  np->pthread = curproc;       // exit 时唤醒用
  np->parent = 0;
  *np->tf = *curproc->tf;      // 继承 trapframe

  int* sp = stack + 4096 - 8;

  // Clone may need to change other registers than ones seen in fork
  np->tf->eip = (int)fcn;
  np->tf->esp = (int)sp;  // top of stack
  np->tf->ebp = (int)sp;  // 栈帧指针 
  np->tf->eax = 0;    // Clear %eax so that clone returns 0 in the child

  // setup new user stack and some pointers
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
  *sp = 0xffffffff;     // end of stack (fake return PC value)

  for(int i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
  
  int pid = np->pid;
  
  acquire(&ptable[0].lock);
  np->state = RUNNABLE;
  release(&ptable[0].lock);
 
  // return the ID of the new thread
  return pid;
}

int join(void **stack)
{
  cprintf("in join, stack pointer = %p\n",*stack);
  struct proc *curproc = proc;
  struct proc *p;
  int havekids;

  acquire(&ptable[0].lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
      if(p->pthread != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        // *stack = p->ustack;
        int pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->pthread = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable[0].lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable[0].lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable[0].lock);  //DOC: wait-sleep
  }

  return 0;
}

