
_uthread:     file format elf32-i386


Disassembly of section .text:

00000000 <add_thread>:
	void *ustack;
	int used;
}threads[NTHREAD]; //TCB表

//add a TCB to thread table
void add_thread(int *pid,void *ustack){
   0:	ba e0 0c 00 00       	mov    $0xce0,%edx
	int i;
	for(i=0;i<NTHREAD;i++){
   5:	31 c0                	xor    %eax,%eax
		if(threads[i].used==0){
   7:	8b 4a 08             	mov    0x8(%edx),%ecx
   a:	85 c9                	test   %ecx,%ecx
   c:	74 12                	je     20 <add_thread+0x20>
	for(i=0;i<NTHREAD;i++){
   e:	83 c0 01             	add    $0x1,%eax
  11:	83 c2 0c             	add    $0xc,%edx
  14:	83 f8 04             	cmp    $0x4,%eax
  17:	75 ee                	jne    7 <add_thread+0x7>
  19:	f3 c3                	repz ret 
  1b:	90                   	nop
  1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void add_thread(int *pid,void *ustack){
  20:	55                   	push   %ebp
			threads[i].pid=*pid;
  21:	8d 04 40             	lea    (%eax,%eax,2),%eax
void add_thread(int *pid,void *ustack){
  24:	89 e5                	mov    %esp,%ebp
			threads[i].pid=*pid;
  26:	c1 e0 02             	shl    $0x2,%eax
  29:	8b 55 08             	mov    0x8(%ebp),%edx
  2c:	8b 0a                	mov    (%edx),%ecx
  2e:	8d 90 e0 0c 00 00    	lea    0xce0(%eax),%edx
			threads[i].ustack=ustack;
			threads[i].used=1;
  34:	c7 42 08 01 00 00 00 	movl   $0x1,0x8(%edx)
			threads[i].pid=*pid;
  3b:	89 88 e0 0c 00 00    	mov    %ecx,0xce0(%eax)
			threads[i].ustack=ustack;
  41:	8b 45 0c             	mov    0xc(%ebp),%eax
  44:	89 42 04             	mov    %eax,0x4(%edx)
			break;
		}
	}
}
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    
  49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000050 <remove_thread>:

void remove_thread(int *pid)
{
  50:	55                   	push   %ebp
  51:	b8 e0 0c 00 00       	mov    $0xce0,%eax
    int i;
	for(i=0;i<NTHREAD;i++){
  56:	31 d2                	xor    %edx,%edx
{
  58:	89 e5                	mov    %esp,%ebp
  5a:	56                   	push   %esi
  5b:	53                   	push   %ebx
  5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
    	if(threads[i].used && threads[i].pid==*pid)
  5f:	8b 58 08             	mov    0x8(%eax),%ebx
  62:	85 db                	test   %ebx,%ebx
  64:	74 06                	je     6c <remove_thread+0x1c>
  66:	8b 31                	mov    (%ecx),%esi
  68:	39 30                	cmp    %esi,(%eax)
  6a:	74 14                	je     80 <remove_thread+0x30>
	for(i=0;i<NTHREAD;i++){
  6c:	83 c2 01             	add    $0x1,%edx
  6f:	83 c0 0c             	add    $0xc,%eax
  72:	83 fa 04             	cmp    $0x4,%edx
  75:	75 e8                	jne    5f <remove_thread+0xf>
    		threads[i].ustack=0;
    		threads[i].used=0;
    		break;
    	}
    }
}
  77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  7a:	5b                   	pop    %ebx
  7b:	5e                   	pop    %esi
  7c:	5d                   	pop    %ebp
  7d:	c3                   	ret    
  7e:	66 90                	xchg   %ax,%ax
    		free(threads[i].ustack); //释放用户栈
  80:	8d 1c 52             	lea    (%edx,%edx,2),%ebx
  83:	83 ec 0c             	sub    $0xc,%esp
  86:	c1 e3 02             	shl    $0x2,%ebx
  89:	ff b3 e4 0c 00 00    	pushl  0xce4(%ebx)
  8f:	e8 1c 07 00 00       	call   7b0 <free>
    		threads[i].pid=0;
  94:	c7 83 e0 0c 00 00 00 	movl   $0x0,0xce0(%ebx)
  9b:	00 00 00 
    		threads[i].ustack=0;
  9e:	c7 83 e4 0c 00 00 00 	movl   $0x0,0xce4(%ebx)
  a5:	00 00 00 
    		break;
  a8:	83 c4 10             	add    $0x10,%esp
    		threads[i].used=0;
  ab:	c7 83 e8 0c 00 00 00 	movl   $0x0,0xce8(%ebx)
  b2:	00 00 00 
}
  b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  b8:	5b                   	pop    %ebx
  b9:	5e                   	pop    %esi
  ba:	5d                   	pop    %ebp
  bb:	c3                   	ret    
  bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000000c0 <thread_create>:

int thread_create(void(*start_routine)(void*),void* arg){
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	53                   	push   %ebx
  c4:	83 ec 04             	sub    $0x4,%esp
	//if first time running any threads,initialize thread table with zeros
	static int first=1;
	if(first){
  c7:	a1 b8 0c 00 00       	mov    0xcb8,%eax
  cc:	85 c0                	test   %eax,%eax
  ce:	74 2d                	je     fd <thread_create+0x3d>
		first=0;
  d0:	c7 05 b8 0c 00 00 00 	movl   $0x0,0xcb8
  d7:	00 00 00 
  da:	b8 e0 0c 00 00       	mov    $0xce0,%eax
		int i;
		for(i=0;i<NTHREAD;i++){
			threads[i].pid=0;
  df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			threads[i].ustack=0;
  e5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  ec:	83 c0 0c             	add    $0xc,%eax
			threads[i].used=0;
  ef:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
		for(i=0;i<NTHREAD;i++){
  f6:	3d 10 0d 00 00       	cmp    $0xd10,%eax
  fb:	75 e2                	jne    df <thread_create+0x1f>
		}
	}
	void *stack=malloc(PGSIZE);//allocate one page for user stack
  fd:	83 ec 0c             	sub    $0xc,%esp
 100:	68 00 10 00 00       	push   $0x1000
 105:	e8 36 07 00 00       	call   840 <malloc>
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 10a:	83 c4 0c             	add    $0xc,%esp
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 10d:	89 c3                	mov    %eax,%ebx
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 10f:	50                   	push   %eax
 110:	ff 75 0c             	pushl  0xc(%ebp)
 113:	ff 75 08             	pushl  0x8(%ebp)
 116:	e8 ff 03 00 00       	call   51a <clone>
 11b:	b9 e0 0c 00 00       	mov    $0xce0,%ecx
 120:	83 c4 10             	add    $0x10,%esp
	for(i=0;i<NTHREAD;i++){
 123:	31 d2                	xor    %edx,%edx
		if(threads[i].used==0){
 125:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
 129:	74 15                	je     140 <thread_create+0x80>
	for(i=0;i<NTHREAD;i++){
 12b:	83 c2 01             	add    $0x1,%edx
 12e:	83 c1 0c             	add    $0xc,%ecx
 131:	83 fa 04             	cmp    $0x4,%edx
 134:	75 ef                	jne    125 <thread_create+0x65>
	add_thread(&pid,stack);//save new thread to thread table
	return pid;
}
 136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 139:	c9                   	leave  
 13a:	c3                   	ret    
 13b:	90                   	nop
 13c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			threads[i].pid=*pid;
 140:	8d 14 52             	lea    (%edx,%edx,2),%edx
 143:	c1 e2 02             	shl    $0x2,%edx
			threads[i].ustack=ustack;
 146:	89 9a e4 0c 00 00    	mov    %ebx,0xce4(%edx)
			threads[i].pid=*pid;
 14c:	89 82 e0 0c 00 00    	mov    %eax,0xce0(%edx)
			threads[i].used=1;
 152:	c7 82 e8 0c 00 00 01 	movl   $0x1,0xce8(%edx)
 159:	00 00 00 
}
 15c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 15f:	c9                   	leave  
 160:	c3                   	ret    
 161:	eb 0d                	jmp    170 <thread_join>
 163:	90                   	nop
 164:	90                   	nop
 165:	90                   	nop
 166:	90                   	nop
 167:	90                   	nop
 168:	90                   	nop
 169:	90                   	nop
 16a:	90                   	nop
 16b:	90                   	nop
 16c:	90                   	nop
 16d:	90                   	nop
 16e:	90                   	nop
 16f:	90                   	nop

00000170 <thread_join>:

int thread_join(void){
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	53                   	push   %ebx
 174:	bb e0 0c 00 00       	mov    $0xce0,%ebx
 179:	83 ec 14             	sub    $0x14,%esp
	int i;
	for(i=0;i<NTHREAD;i++){
		if(threads[i].used==1){
 17c:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
 180:	74 16                	je     198 <thread_join+0x28>
 182:	83 c3 0c             	add    $0xc,%ebx
	for(i=0;i<NTHREAD;i++){
 185:	81 fb 10 0d 00 00    	cmp    $0xd10,%ebx
 18b:	75 ef                	jne    17c <thread_join+0xc>
				remove_thread(&pid);
				return pid;
			}
		}
	}
	return 0;
 18d:	31 c0                	xor    %eax,%eax
}
 18f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 192:	c9                   	leave  
 193:	c3                   	ret    
 194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			int pid=join(&threads[i].ustack);  //回收子线程
 198:	8d 43 04             	lea    0x4(%ebx),%eax
 19b:	83 ec 0c             	sub    $0xc,%esp
 19e:	50                   	push   %eax
 19f:	e8 7e 03 00 00       	call   522 <join>
			if(pid>0){
 1a4:	83 c4 10             	add    $0x10,%esp
 1a7:	85 c0                	test   %eax,%eax
			int pid=join(&threads[i].ustack);  //回收子线程
 1a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
			if(pid>0){
 1ac:	7e d4                	jle    182 <thread_join+0x12>
				remove_thread(&pid);
 1ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
 1b1:	83 ec 0c             	sub    $0xc,%esp
 1b4:	50                   	push   %eax
 1b5:	e8 96 fe ff ff       	call   50 <remove_thread>
				return pid;
 1ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bd:	83 c4 10             	add    $0x10,%esp
 1c0:	eb cd                	jmp    18f <thread_join+0x1f>
 1c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 1c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001d0 <printTCB>:

void printTCB(void){
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	53                   	push   %ebx
	int i;
	for(i=0;i<NTHREAD;i++)
 1d4:	31 db                	xor    %ebx,%ebx
void printTCB(void){
 1d6:	83 ec 04             	sub    $0x4,%esp
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 1d9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 1dc:	ff 34 85 e8 0c 00 00 	pushl  0xce8(,%eax,4)
 1e3:	53                   	push   %ebx
	for(i=0;i<NTHREAD;i++)
 1e4:	83 c3 01             	add    $0x1,%ebx
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 1e7:	68 38 09 00 00       	push   $0x938
 1ec:	6a 01                	push   $0x1
 1ee:	e8 ed 03 00 00       	call   5e0 <printf>
	for(i=0;i<NTHREAD;i++)
 1f3:	83 c4 10             	add    $0x10,%esp
 1f6:	83 fb 04             	cmp    $0x4,%ebx
 1f9:	75 de                	jne    1d9 <printTCB+0x9>
}
 1fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 1fe:	c9                   	leave  
 1ff:	c3                   	ret    

00000200 <add>:

int add(int a,int b)
{ 
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
	return a+b;
 203:	8b 45 0c             	mov    0xc(%ebp),%eax
 206:	03 45 08             	add    0x8(%ebp),%eax
 209:	5d                   	pop    %ebp
 20a:	c3                   	ret    
 20b:	66 90                	xchg   %ax,%ax
 20d:	66 90                	xchg   %ax,%ax
 20f:	90                   	nop

00000210 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	53                   	push   %ebx
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 21a:	89 c2                	mov    %eax,%edx
 21c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 220:	83 c1 01             	add    $0x1,%ecx
 223:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
 227:	83 c2 01             	add    $0x1,%edx
 22a:	84 db                	test   %bl,%bl
 22c:	88 5a ff             	mov    %bl,-0x1(%edx)
 22f:	75 ef                	jne    220 <strcpy+0x10>
    ;
  return os;
}
 231:	5b                   	pop    %ebx
 232:	5d                   	pop    %ebp
 233:	c3                   	ret    
 234:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 23a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000240 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	53                   	push   %ebx
 244:	8b 55 08             	mov    0x8(%ebp),%edx
 247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
 24a:	0f b6 02             	movzbl (%edx),%eax
 24d:	0f b6 19             	movzbl (%ecx),%ebx
 250:	84 c0                	test   %al,%al
 252:	75 1c                	jne    270 <strcmp+0x30>
 254:	eb 2a                	jmp    280 <strcmp+0x40>
 256:	8d 76 00             	lea    0x0(%esi),%esi
 259:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    p++, q++;
 260:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 263:	0f b6 02             	movzbl (%edx),%eax
    p++, q++;
 266:	83 c1 01             	add    $0x1,%ecx
 269:	0f b6 19             	movzbl (%ecx),%ebx
  while(*p && *p == *q)
 26c:	84 c0                	test   %al,%al
 26e:	74 10                	je     280 <strcmp+0x40>
 270:	38 d8                	cmp    %bl,%al
 272:	74 ec                	je     260 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
 274:	29 d8                	sub    %ebx,%eax
}
 276:	5b                   	pop    %ebx
 277:	5d                   	pop    %ebp
 278:	c3                   	ret    
 279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 280:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
 282:	29 d8                	sub    %ebx,%eax
}
 284:	5b                   	pop    %ebx
 285:	5d                   	pop    %ebp
 286:	c3                   	ret    
 287:	89 f6                	mov    %esi,%esi
 289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000290 <strlen>:

uint
strlen(char *s)
{
 290:	55                   	push   %ebp
 291:	89 e5                	mov    %esp,%ebp
 293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 296:	80 39 00             	cmpb   $0x0,(%ecx)
 299:	74 15                	je     2b0 <strlen+0x20>
 29b:	31 d2                	xor    %edx,%edx
 29d:	8d 76 00             	lea    0x0(%esi),%esi
 2a0:	83 c2 01             	add    $0x1,%edx
 2a3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 2a7:	89 d0                	mov    %edx,%eax
 2a9:	75 f5                	jne    2a0 <strlen+0x10>
    ;
  return n;
}
 2ab:	5d                   	pop    %ebp
 2ac:	c3                   	ret    
 2ad:	8d 76 00             	lea    0x0(%esi),%esi
  for(n = 0; s[n]; n++)
 2b0:	31 c0                	xor    %eax,%eax
}
 2b2:	5d                   	pop    %ebp
 2b3:	c3                   	ret    
 2b4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 2ba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

000002c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	57                   	push   %edi
 2c4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 2c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cd:	89 d7                	mov    %edx,%edi
 2cf:	fc                   	cld    
 2d0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 2d2:	89 d0                	mov    %edx,%eax
 2d4:	5f                   	pop    %edi
 2d5:	5d                   	pop    %ebp
 2d6:	c3                   	ret    
 2d7:	89 f6                	mov    %esi,%esi
 2d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000002e0 <strchr>:

char*
strchr(const char *s, char c)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	53                   	push   %ebx
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for(; *s; s++)
 2ea:	0f b6 10             	movzbl (%eax),%edx
 2ed:	84 d2                	test   %dl,%dl
 2ef:	74 1d                	je     30e <strchr+0x2e>
    if(*s == c)
 2f1:	38 d3                	cmp    %dl,%bl
 2f3:	89 d9                	mov    %ebx,%ecx
 2f5:	75 0d                	jne    304 <strchr+0x24>
 2f7:	eb 17                	jmp    310 <strchr+0x30>
 2f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 300:	38 ca                	cmp    %cl,%dl
 302:	74 0c                	je     310 <strchr+0x30>
  for(; *s; s++)
 304:	83 c0 01             	add    $0x1,%eax
 307:	0f b6 10             	movzbl (%eax),%edx
 30a:	84 d2                	test   %dl,%dl
 30c:	75 f2                	jne    300 <strchr+0x20>
      return (char*)s;
  return 0;
 30e:	31 c0                	xor    %eax,%eax
}
 310:	5b                   	pop    %ebx
 311:	5d                   	pop    %ebp
 312:	c3                   	ret    
 313:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 319:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000320 <gets>:

char*
gets(char *buf, int max)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	57                   	push   %edi
 324:	56                   	push   %esi
 325:	53                   	push   %ebx
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 326:	31 f6                	xor    %esi,%esi
 328:	89 f3                	mov    %esi,%ebx
{
 32a:	83 ec 1c             	sub    $0x1c,%esp
 32d:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 330:	eb 2f                	jmp    361 <gets+0x41>
 332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 338:	8d 45 e7             	lea    -0x19(%ebp),%eax
 33b:	83 ec 04             	sub    $0x4,%esp
 33e:	6a 01                	push   $0x1
 340:	50                   	push   %eax
 341:	6a 00                	push   $0x0
 343:	e8 32 01 00 00       	call   47a <read>
    if(cc < 1)
 348:	83 c4 10             	add    $0x10,%esp
 34b:	85 c0                	test   %eax,%eax
 34d:	7e 1c                	jle    36b <gets+0x4b>
      break;
    buf[i++] = c;
 34f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 353:	83 c7 01             	add    $0x1,%edi
 356:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 359:	3c 0a                	cmp    $0xa,%al
 35b:	74 23                	je     380 <gets+0x60>
 35d:	3c 0d                	cmp    $0xd,%al
 35f:	74 1f                	je     380 <gets+0x60>
  for(i=0; i+1 < max; ){
 361:	83 c3 01             	add    $0x1,%ebx
 364:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 367:	89 fe                	mov    %edi,%esi
 369:	7c cd                	jl     338 <gets+0x18>
 36b:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 370:	c6 03 00             	movb   $0x0,(%ebx)
}
 373:	8d 65 f4             	lea    -0xc(%ebp),%esp
 376:	5b                   	pop    %ebx
 377:	5e                   	pop    %esi
 378:	5f                   	pop    %edi
 379:	5d                   	pop    %ebp
 37a:	c3                   	ret    
 37b:	90                   	nop
 37c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 380:	8b 75 08             	mov    0x8(%ebp),%esi
 383:	8b 45 08             	mov    0x8(%ebp),%eax
 386:	01 de                	add    %ebx,%esi
 388:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 38a:	c6 03 00             	movb   $0x0,(%ebx)
}
 38d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 390:	5b                   	pop    %ebx
 391:	5e                   	pop    %esi
 392:	5f                   	pop    %edi
 393:	5d                   	pop    %ebp
 394:	c3                   	ret    
 395:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 399:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000003a0 <stat>:

int
stat(char *n, struct stat *st)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	56                   	push   %esi
 3a4:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a5:	83 ec 08             	sub    $0x8,%esp
 3a8:	6a 00                	push   $0x0
 3aa:	ff 75 08             	pushl  0x8(%ebp)
 3ad:	e8 f0 00 00 00       	call   4a2 <open>
  if(fd < 0)
 3b2:	83 c4 10             	add    $0x10,%esp
 3b5:	85 c0                	test   %eax,%eax
 3b7:	78 27                	js     3e0 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 3b9:	83 ec 08             	sub    $0x8,%esp
 3bc:	ff 75 0c             	pushl  0xc(%ebp)
 3bf:	89 c3                	mov    %eax,%ebx
 3c1:	50                   	push   %eax
 3c2:	e8 f3 00 00 00       	call   4ba <fstat>
  close(fd);
 3c7:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 3ca:	89 c6                	mov    %eax,%esi
  close(fd);
 3cc:	e8 b9 00 00 00       	call   48a <close>
  return r;
 3d1:	83 c4 10             	add    $0x10,%esp
}
 3d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
 3d7:	89 f0                	mov    %esi,%eax
 3d9:	5b                   	pop    %ebx
 3da:	5e                   	pop    %esi
 3db:	5d                   	pop    %ebp
 3dc:	c3                   	ret    
 3dd:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 3e0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 3e5:	eb ed                	jmp    3d4 <stat+0x34>
 3e7:	89 f6                	mov    %esi,%esi
 3e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000003f0 <atoi>:

int
atoi(const char *s)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	53                   	push   %ebx
 3f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f7:	0f be 11             	movsbl (%ecx),%edx
 3fa:	8d 42 d0             	lea    -0x30(%edx),%eax
 3fd:	3c 09                	cmp    $0x9,%al
  n = 0;
 3ff:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 404:	77 1f                	ja     425 <atoi+0x35>
 406:	8d 76 00             	lea    0x0(%esi),%esi
 409:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    n = n*10 + *s++ - '0';
 410:	8d 04 80             	lea    (%eax,%eax,4),%eax
 413:	83 c1 01             	add    $0x1,%ecx
 416:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
  while('0' <= *s && *s <= '9')
 41a:	0f be 11             	movsbl (%ecx),%edx
 41d:	8d 5a d0             	lea    -0x30(%edx),%ebx
 420:	80 fb 09             	cmp    $0x9,%bl
 423:	76 eb                	jbe    410 <atoi+0x20>
  return n;
}
 425:	5b                   	pop    %ebx
 426:	5d                   	pop    %ebp
 427:	c3                   	ret    
 428:	90                   	nop
 429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000430 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 430:	55                   	push   %ebp
 431:	89 e5                	mov    %esp,%ebp
 433:	56                   	push   %esi
 434:	53                   	push   %ebx
 435:	8b 5d 10             	mov    0x10(%ebp),%ebx
 438:	8b 45 08             	mov    0x8(%ebp),%eax
 43b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 43e:	85 db                	test   %ebx,%ebx
 440:	7e 14                	jle    456 <memmove+0x26>
 442:	31 d2                	xor    %edx,%edx
 444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *dst++ = *src++;
 448:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 44c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 44f:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0)
 452:	39 d3                	cmp    %edx,%ebx
 454:	75 f2                	jne    448 <memmove+0x18>
  return vdst;
}
 456:	5b                   	pop    %ebx
 457:	5e                   	pop    %esi
 458:	5d                   	pop    %ebp
 459:	c3                   	ret    

0000045a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 45a:	b8 01 00 00 00       	mov    $0x1,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <exit>:
SYSCALL(exit)
 462:	b8 02 00 00 00       	mov    $0x2,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <wait>:
SYSCALL(wait)
 46a:	b8 03 00 00 00       	mov    $0x3,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <pipe>:
SYSCALL(pipe)
 472:	b8 04 00 00 00       	mov    $0x4,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <read>:
SYSCALL(read)
 47a:	b8 05 00 00 00       	mov    $0x5,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <write>:
SYSCALL(write)
 482:	b8 10 00 00 00       	mov    $0x10,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <close>:
SYSCALL(close)
 48a:	b8 15 00 00 00       	mov    $0x15,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <kill>:
SYSCALL(kill)
 492:	b8 06 00 00 00       	mov    $0x6,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <exec>:
SYSCALL(exec)
 49a:	b8 07 00 00 00       	mov    $0x7,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <open>:
SYSCALL(open)
 4a2:	b8 0f 00 00 00       	mov    $0xf,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <mknod>:
SYSCALL(mknod)
 4aa:	b8 11 00 00 00       	mov    $0x11,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret    

000004b2 <unlink>:
SYSCALL(unlink)
 4b2:	b8 12 00 00 00       	mov    $0x12,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret    

000004ba <fstat>:
SYSCALL(fstat)
 4ba:	b8 08 00 00 00       	mov    $0x8,%eax
 4bf:	cd 40                	int    $0x40
 4c1:	c3                   	ret    

000004c2 <link>:
SYSCALL(link)
 4c2:	b8 13 00 00 00       	mov    $0x13,%eax
 4c7:	cd 40                	int    $0x40
 4c9:	c3                   	ret    

000004ca <mkdir>:
SYSCALL(mkdir)
 4ca:	b8 14 00 00 00       	mov    $0x14,%eax
 4cf:	cd 40                	int    $0x40
 4d1:	c3                   	ret    

000004d2 <chdir>:
SYSCALL(chdir)
 4d2:	b8 09 00 00 00       	mov    $0x9,%eax
 4d7:	cd 40                	int    $0x40
 4d9:	c3                   	ret    

000004da <dup>:
SYSCALL(dup)
 4da:	b8 0a 00 00 00       	mov    $0xa,%eax
 4df:	cd 40                	int    $0x40
 4e1:	c3                   	ret    

000004e2 <getpid>:
SYSCALL(getpid)
 4e2:	b8 0b 00 00 00       	mov    $0xb,%eax
 4e7:	cd 40                	int    $0x40
 4e9:	c3                   	ret    

000004ea <getcpuid>:
SYSCALL(getcpuid)
 4ea:	b8 16 00 00 00       	mov    $0x16,%eax
 4ef:	cd 40                	int    $0x40
 4f1:	c3                   	ret    

000004f2 <sbrk>:
SYSCALL(sbrk)
 4f2:	b8 0c 00 00 00       	mov    $0xc,%eax
 4f7:	cd 40                	int    $0x40
 4f9:	c3                   	ret    

000004fa <sleep>:
SYSCALL(sleep)
 4fa:	b8 0d 00 00 00       	mov    $0xd,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret    

00000502 <uptime>:
SYSCALL(uptime)
 502:	b8 0e 00 00 00       	mov    $0xe,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret    

0000050a <myalloc>:
SYSCALL(myalloc)
 50a:	b8 17 00 00 00       	mov    $0x17,%eax
 50f:	cd 40                	int    $0x40
 511:	c3                   	ret    

00000512 <myfree>:
SYSCALL(myfree)
 512:	b8 18 00 00 00       	mov    $0x18,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret    

0000051a <clone>:
SYSCALL(clone)
 51a:	b8 19 00 00 00       	mov    $0x19,%eax
 51f:	cd 40                	int    $0x40
 521:	c3                   	ret    

00000522 <join>:
SYSCALL(join)
 522:	b8 1a 00 00 00       	mov    $0x1a,%eax
 527:	cd 40                	int    $0x40
 529:	c3                   	ret    

0000052a <cps>:
SYSCALL(cps);
 52a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 52f:	cd 40                	int    $0x40
 531:	c3                   	ret    

00000532 <chpri>:
SYSCALL(chpri);
 532:	b8 1b 00 00 00       	mov    $0x1b,%eax
 537:	cd 40                	int    $0x40
 539:	c3                   	ret    
 53a:	66 90                	xchg   %ax,%ax
 53c:	66 90                	xchg   %ax,%ax
 53e:	66 90                	xchg   %ax,%ax

00000540 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 540:	55                   	push   %ebp
 541:	89 e5                	mov    %esp,%ebp
 543:	57                   	push   %edi
 544:	56                   	push   %esi
 545:	53                   	push   %ebx
 546:	83 ec 3c             	sub    $0x3c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 549:	85 d2                	test   %edx,%edx
{
 54b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    neg = 1;
    x = -xx;
 54e:	89 d0                	mov    %edx,%eax
  if(sgn && xx < 0){
 550:	79 76                	jns    5c8 <printint+0x88>
 552:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 556:	74 70                	je     5c8 <printint+0x88>
    x = -xx;
 558:	f7 d8                	neg    %eax
    neg = 1;
 55a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 561:	31 f6                	xor    %esi,%esi
 563:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 566:	eb 0a                	jmp    572 <printint+0x32>
 568:	90                   	nop
 569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  do{
    buf[i++] = digits[x % base];
 570:	89 fe                	mov    %edi,%esi
 572:	31 d2                	xor    %edx,%edx
 574:	8d 7e 01             	lea    0x1(%esi),%edi
 577:	f7 f1                	div    %ecx
 579:	0f b6 92 4c 09 00 00 	movzbl 0x94c(%edx),%edx
  }while((x /= base) != 0);
 580:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
 582:	88 14 3b             	mov    %dl,(%ebx,%edi,1)
  }while((x /= base) != 0);
 585:	75 e9                	jne    570 <printint+0x30>
  if(neg)
 587:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 58a:	85 c0                	test   %eax,%eax
 58c:	74 08                	je     596 <printint+0x56>
    buf[i++] = '-';
 58e:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
 593:	8d 7e 02             	lea    0x2(%esi),%edi
 596:	8d 74 3d d7          	lea    -0x29(%ebp,%edi,1),%esi
 59a:	8b 7d c0             	mov    -0x40(%ebp),%edi
 59d:	8d 76 00             	lea    0x0(%esi),%esi
 5a0:	0f b6 06             	movzbl (%esi),%eax
  write(fd, &c, 1);
 5a3:	83 ec 04             	sub    $0x4,%esp
 5a6:	83 ee 01             	sub    $0x1,%esi
 5a9:	6a 01                	push   $0x1
 5ab:	53                   	push   %ebx
 5ac:	57                   	push   %edi
 5ad:	88 45 d7             	mov    %al,-0x29(%ebp)
 5b0:	e8 cd fe ff ff       	call   482 <write>

  while(--i >= 0)
 5b5:	83 c4 10             	add    $0x10,%esp
 5b8:	39 de                	cmp    %ebx,%esi
 5ba:	75 e4                	jne    5a0 <printint+0x60>
    putc(fd, buf[i]);
}
 5bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5bf:	5b                   	pop    %ebx
 5c0:	5e                   	pop    %esi
 5c1:	5f                   	pop    %edi
 5c2:	5d                   	pop    %ebp
 5c3:	c3                   	ret    
 5c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 5c8:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 5cf:	eb 90                	jmp    561 <printint+0x21>
 5d1:	eb 0d                	jmp    5e0 <printf>
 5d3:	90                   	nop
 5d4:	90                   	nop
 5d5:	90                   	nop
 5d6:	90                   	nop
 5d7:	90                   	nop
 5d8:	90                   	nop
 5d9:	90                   	nop
 5da:	90                   	nop
 5db:	90                   	nop
 5dc:	90                   	nop
 5dd:	90                   	nop
 5de:	90                   	nop
 5df:	90                   	nop

000005e0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	57                   	push   %edi
 5e4:	56                   	push   %esi
 5e5:	53                   	push   %ebx
 5e6:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5e9:	8b 75 0c             	mov    0xc(%ebp),%esi
 5ec:	0f b6 1e             	movzbl (%esi),%ebx
 5ef:	84 db                	test   %bl,%bl
 5f1:	0f 84 b3 00 00 00    	je     6aa <printf+0xca>
  ap = (uint*)(void*)&fmt + 1;
 5f7:	8d 45 10             	lea    0x10(%ebp),%eax
 5fa:	83 c6 01             	add    $0x1,%esi
  state = 0;
 5fd:	31 ff                	xor    %edi,%edi
  ap = (uint*)(void*)&fmt + 1;
 5ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 602:	eb 2f                	jmp    633 <printf+0x53>
 604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 608:	83 f8 25             	cmp    $0x25,%eax
 60b:	0f 84 a7 00 00 00    	je     6b8 <printf+0xd8>
  write(fd, &c, 1);
 611:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 614:	83 ec 04             	sub    $0x4,%esp
 617:	88 5d e2             	mov    %bl,-0x1e(%ebp)
 61a:	6a 01                	push   $0x1
 61c:	50                   	push   %eax
 61d:	ff 75 08             	pushl  0x8(%ebp)
 620:	e8 5d fe ff ff       	call   482 <write>
 625:	83 c4 10             	add    $0x10,%esp
 628:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 62b:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 62f:	84 db                	test   %bl,%bl
 631:	74 77                	je     6aa <printf+0xca>
    if(state == 0){
 633:	85 ff                	test   %edi,%edi
    c = fmt[i] & 0xff;
 635:	0f be cb             	movsbl %bl,%ecx
 638:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 63b:	74 cb                	je     608 <printf+0x28>
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 63d:	83 ff 25             	cmp    $0x25,%edi
 640:	75 e6                	jne    628 <printf+0x48>
      if(c == 'd'){
 642:	83 f8 64             	cmp    $0x64,%eax
 645:	0f 84 05 01 00 00    	je     750 <printf+0x170>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 64b:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 651:	83 f9 70             	cmp    $0x70,%ecx
 654:	74 72                	je     6c8 <printf+0xe8>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 656:	83 f8 73             	cmp    $0x73,%eax
 659:	0f 84 99 00 00 00    	je     6f8 <printf+0x118>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 65f:	83 f8 63             	cmp    $0x63,%eax
 662:	0f 84 08 01 00 00    	je     770 <printf+0x190>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 668:	83 f8 25             	cmp    $0x25,%eax
 66b:	0f 84 ef 00 00 00    	je     760 <printf+0x180>
  write(fd, &c, 1);
 671:	8d 45 e7             	lea    -0x19(%ebp),%eax
 674:	83 ec 04             	sub    $0x4,%esp
 677:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 67b:	6a 01                	push   $0x1
 67d:	50                   	push   %eax
 67e:	ff 75 08             	pushl  0x8(%ebp)
 681:	e8 fc fd ff ff       	call   482 <write>
 686:	83 c4 0c             	add    $0xc,%esp
 689:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 68c:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 68f:	6a 01                	push   $0x1
 691:	50                   	push   %eax
 692:	ff 75 08             	pushl  0x8(%ebp)
 695:	83 c6 01             	add    $0x1,%esi
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 698:	31 ff                	xor    %edi,%edi
  write(fd, &c, 1);
 69a:	e8 e3 fd ff ff       	call   482 <write>
  for(i = 0; fmt[i]; i++){
 69f:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
  write(fd, &c, 1);
 6a3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 6a6:	84 db                	test   %bl,%bl
 6a8:	75 89                	jne    633 <printf+0x53>
    }
  }
}
 6aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
 6ad:	5b                   	pop    %ebx
 6ae:	5e                   	pop    %esi
 6af:	5f                   	pop    %edi
 6b0:	5d                   	pop    %ebp
 6b1:	c3                   	ret    
 6b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        state = '%';
 6b8:	bf 25 00 00 00       	mov    $0x25,%edi
 6bd:	e9 66 ff ff ff       	jmp    628 <printf+0x48>
 6c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printint(fd, *ap, 16, 0);
 6c8:	83 ec 0c             	sub    $0xc,%esp
 6cb:	b9 10 00 00 00       	mov    $0x10,%ecx
 6d0:	6a 00                	push   $0x0
 6d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 6d5:	8b 45 08             	mov    0x8(%ebp),%eax
 6d8:	8b 17                	mov    (%edi),%edx
 6da:	e8 61 fe ff ff       	call   540 <printint>
        ap++;
 6df:	89 f8                	mov    %edi,%eax
 6e1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 6e4:	31 ff                	xor    %edi,%edi
        ap++;
 6e6:	83 c0 04             	add    $0x4,%eax
 6e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 6ec:	e9 37 ff ff ff       	jmp    628 <printf+0x48>
 6f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = (char*)*ap;
 6f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 6fb:	8b 08                	mov    (%eax),%ecx
        ap++;
 6fd:	83 c0 04             	add    $0x4,%eax
 700:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(s == 0)
 703:	85 c9                	test   %ecx,%ecx
 705:	0f 84 8e 00 00 00    	je     799 <printf+0x1b9>
        while(*s != 0){
 70b:	0f b6 01             	movzbl (%ecx),%eax
      state = 0;
 70e:	31 ff                	xor    %edi,%edi
        s = (char*)*ap;
 710:	89 cb                	mov    %ecx,%ebx
        while(*s != 0){
 712:	84 c0                	test   %al,%al
 714:	0f 84 0e ff ff ff    	je     628 <printf+0x48>
 71a:	89 75 d0             	mov    %esi,-0x30(%ebp)
 71d:	89 de                	mov    %ebx,%esi
 71f:	8b 5d 08             	mov    0x8(%ebp),%ebx
 722:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 725:	8d 76 00             	lea    0x0(%esi),%esi
  write(fd, &c, 1);
 728:	83 ec 04             	sub    $0x4,%esp
          s++;
 72b:	83 c6 01             	add    $0x1,%esi
 72e:	88 45 e3             	mov    %al,-0x1d(%ebp)
  write(fd, &c, 1);
 731:	6a 01                	push   $0x1
 733:	57                   	push   %edi
 734:	53                   	push   %ebx
 735:	e8 48 fd ff ff       	call   482 <write>
        while(*s != 0){
 73a:	0f b6 06             	movzbl (%esi),%eax
 73d:	83 c4 10             	add    $0x10,%esp
 740:	84 c0                	test   %al,%al
 742:	75 e4                	jne    728 <printf+0x148>
 744:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 747:	31 ff                	xor    %edi,%edi
 749:	e9 da fe ff ff       	jmp    628 <printf+0x48>
 74e:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 10, 1);
 750:	83 ec 0c             	sub    $0xc,%esp
 753:	b9 0a 00 00 00       	mov    $0xa,%ecx
 758:	6a 01                	push   $0x1
 75a:	e9 73 ff ff ff       	jmp    6d2 <printf+0xf2>
 75f:	90                   	nop
  write(fd, &c, 1);
 760:	83 ec 04             	sub    $0x4,%esp
 763:	88 5d e5             	mov    %bl,-0x1b(%ebp)
 766:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 769:	6a 01                	push   $0x1
 76b:	e9 21 ff ff ff       	jmp    691 <printf+0xb1>
        putc(fd, *ap);
 770:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  write(fd, &c, 1);
 773:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 776:	8b 07                	mov    (%edi),%eax
  write(fd, &c, 1);
 778:	6a 01                	push   $0x1
        ap++;
 77a:	83 c7 04             	add    $0x4,%edi
        putc(fd, *ap);
 77d:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 780:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 783:	50                   	push   %eax
 784:	ff 75 08             	pushl  0x8(%ebp)
 787:	e8 f6 fc ff ff       	call   482 <write>
        ap++;
 78c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 78f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 792:	31 ff                	xor    %edi,%edi
 794:	e9 8f fe ff ff       	jmp    628 <printf+0x48>
          s = "(null)";
 799:	bb 44 09 00 00       	mov    $0x944,%ebx
        while(*s != 0){
 79e:	b8 28 00 00 00       	mov    $0x28,%eax
 7a3:	e9 72 ff ff ff       	jmp    71a <printf+0x13a>
 7a8:	66 90                	xchg   %ax,%ax
 7aa:	66 90                	xchg   %ax,%ax
 7ac:	66 90                	xchg   %ax,%ax
 7ae:	66 90                	xchg   %ax,%ax

000007b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b1:	a1 c0 0c 00 00       	mov    0xcc0,%eax
{
 7b6:	89 e5                	mov    %esp,%ebp
 7b8:	57                   	push   %edi
 7b9:	56                   	push   %esi
 7ba:	53                   	push   %ebx
 7bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 7be:	8d 4b f8             	lea    -0x8(%ebx),%ecx
 7c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c8:	39 c8                	cmp    %ecx,%eax
 7ca:	8b 10                	mov    (%eax),%edx
 7cc:	73 32                	jae    800 <free+0x50>
 7ce:	39 d1                	cmp    %edx,%ecx
 7d0:	72 04                	jb     7d6 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d2:	39 d0                	cmp    %edx,%eax
 7d4:	72 32                	jb     808 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7d6:	8b 73 fc             	mov    -0x4(%ebx),%esi
 7d9:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 7dc:	39 fa                	cmp    %edi,%edx
 7de:	74 30                	je     810 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 7e0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 7e3:	8b 50 04             	mov    0x4(%eax),%edx
 7e6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 7e9:	39 f1                	cmp    %esi,%ecx
 7eb:	74 3a                	je     827 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 7ed:	89 08                	mov    %ecx,(%eax)
  freep = p;
 7ef:	a3 c0 0c 00 00       	mov    %eax,0xcc0
}
 7f4:	5b                   	pop    %ebx
 7f5:	5e                   	pop    %esi
 7f6:	5f                   	pop    %edi
 7f7:	5d                   	pop    %ebp
 7f8:	c3                   	ret    
 7f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 800:	39 d0                	cmp    %edx,%eax
 802:	72 04                	jb     808 <free+0x58>
 804:	39 d1                	cmp    %edx,%ecx
 806:	72 ce                	jb     7d6 <free+0x26>
{
 808:	89 d0                	mov    %edx,%eax
 80a:	eb bc                	jmp    7c8 <free+0x18>
 80c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 810:	03 72 04             	add    0x4(%edx),%esi
 813:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 816:	8b 10                	mov    (%eax),%edx
 818:	8b 12                	mov    (%edx),%edx
 81a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 81d:	8b 50 04             	mov    0x4(%eax),%edx
 820:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 823:	39 f1                	cmp    %esi,%ecx
 825:	75 c6                	jne    7ed <free+0x3d>
    p->s.size += bp->s.size;
 827:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 82a:	a3 c0 0c 00 00       	mov    %eax,0xcc0
    p->s.size += bp->s.size;
 82f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 832:	8b 53 f8             	mov    -0x8(%ebx),%edx
 835:	89 10                	mov    %edx,(%eax)
}
 837:	5b                   	pop    %ebx
 838:	5e                   	pop    %esi
 839:	5f                   	pop    %edi
 83a:	5d                   	pop    %ebp
 83b:	c3                   	ret    
 83c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000840 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 840:	55                   	push   %ebp
 841:	89 e5                	mov    %esp,%ebp
 843:	57                   	push   %edi
 844:	56                   	push   %esi
 845:	53                   	push   %ebx
 846:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 849:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 84c:	8b 15 c0 0c 00 00    	mov    0xcc0,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 852:	8d 78 07             	lea    0x7(%eax),%edi
 855:	c1 ef 03             	shr    $0x3,%edi
 858:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 85b:	85 d2                	test   %edx,%edx
 85d:	0f 84 9d 00 00 00    	je     900 <malloc+0xc0>
 863:	8b 02                	mov    (%edx),%eax
 865:	8b 48 04             	mov    0x4(%eax),%ecx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 868:	39 cf                	cmp    %ecx,%edi
 86a:	76 6c                	jbe    8d8 <malloc+0x98>
 86c:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
 872:	bb 00 10 00 00       	mov    $0x1000,%ebx
 877:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 87a:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 881:	eb 0e                	jmp    891 <malloc+0x51>
 883:	90                   	nop
 884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 888:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 88a:	8b 48 04             	mov    0x4(%eax),%ecx
 88d:	39 f9                	cmp    %edi,%ecx
 88f:	73 47                	jae    8d8 <malloc+0x98>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 891:	39 05 c0 0c 00 00    	cmp    %eax,0xcc0
 897:	89 c2                	mov    %eax,%edx
 899:	75 ed                	jne    888 <malloc+0x48>
  p = sbrk(nu * sizeof(Header));
 89b:	83 ec 0c             	sub    $0xc,%esp
 89e:	56                   	push   %esi
 89f:	e8 4e fc ff ff       	call   4f2 <sbrk>
  if(p == (char*)-1)
 8a4:	83 c4 10             	add    $0x10,%esp
 8a7:	83 f8 ff             	cmp    $0xffffffff,%eax
 8aa:	74 1c                	je     8c8 <malloc+0x88>
  hp->s.size = nu;
 8ac:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 8af:	83 ec 0c             	sub    $0xc,%esp
 8b2:	83 c0 08             	add    $0x8,%eax
 8b5:	50                   	push   %eax
 8b6:	e8 f5 fe ff ff       	call   7b0 <free>
  return freep;
 8bb:	8b 15 c0 0c 00 00    	mov    0xcc0,%edx
      if((p = morecore(nunits)) == 0)
 8c1:	83 c4 10             	add    $0x10,%esp
 8c4:	85 d2                	test   %edx,%edx
 8c6:	75 c0                	jne    888 <malloc+0x48>
        return 0;
  }
}
 8c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 8cb:	31 c0                	xor    %eax,%eax
}
 8cd:	5b                   	pop    %ebx
 8ce:	5e                   	pop    %esi
 8cf:	5f                   	pop    %edi
 8d0:	5d                   	pop    %ebp
 8d1:	c3                   	ret    
 8d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 8d8:	39 cf                	cmp    %ecx,%edi
 8da:	74 54                	je     930 <malloc+0xf0>
        p->s.size -= nunits;
 8dc:	29 f9                	sub    %edi,%ecx
 8de:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 8e1:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 8e4:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 8e7:	89 15 c0 0c 00 00    	mov    %edx,0xcc0
}
 8ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 8f0:	83 c0 08             	add    $0x8,%eax
}
 8f3:	5b                   	pop    %ebx
 8f4:	5e                   	pop    %esi
 8f5:	5f                   	pop    %edi
 8f6:	5d                   	pop    %ebp
 8f7:	c3                   	ret    
 8f8:	90                   	nop
 8f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    base.s.ptr = freep = prevp = &base;
 900:	c7 05 c0 0c 00 00 c4 	movl   $0xcc4,0xcc0
 907:	0c 00 00 
 90a:	c7 05 c4 0c 00 00 c4 	movl   $0xcc4,0xcc4
 911:	0c 00 00 
    base.s.size = 0;
 914:	b8 c4 0c 00 00       	mov    $0xcc4,%eax
 919:	c7 05 c8 0c 00 00 00 	movl   $0x0,0xcc8
 920:	00 00 00 
 923:	e9 44 ff ff ff       	jmp    86c <malloc+0x2c>
 928:	90                   	nop
 929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        prevp->s.ptr = p->s.ptr;
 930:	8b 08                	mov    (%eax),%ecx
 932:	89 0a                	mov    %ecx,(%edx)
 934:	eb b1                	jmp    8e7 <malloc+0xa7>
