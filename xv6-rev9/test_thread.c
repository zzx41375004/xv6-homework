#include "types.h"
#include "user.h"
#include "fcntl.h"
#include "uthread.h"
#include "stat.h"

volatile int global =1; //测试线程对内存的共享

int F(int n)        //斐波那契数列，测试用户栈
{
  if(n<0)
  	printf(1,"请输入一个正整数\n");
  else if(n==1 || n==2)
  	return 1;
  else{
  	return F(n-1)+F(n-2);
  }
  return 0;
}

void worker(void *arg){
	printf(1,"thread %d is worker.\n",*(int*)arg);//测试参数传递


	global=F(15); //测试全局变量、压栈测试

	//测试文件描述符
	write(3,"hello\n",6);//运行后可以在文件中看到新内容
	exit();

}

int main(int argc,char *argv[])
{
	int t=1;
	open("tmp",O_RDWR | O_CREATE); //复制描述符(3),但不共享
	int pid=thread_create(worker,&t); //创建一个子线程

	thread_join();     //等待回收一个子线程

	printf(1,"thread id=%d\n",pid);

	printf(1,"global=%d\n",global);
	// int c=add(1,2);
	// printf(1,"%d\n",c);
	
	
	exit();
}