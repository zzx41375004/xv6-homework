
_test_thread:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
	exit();

}

int main(int argc,char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 18             	sub    $0x18,%esp
	int t=1;
  12:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	open("tmp",O_RDWR | O_CREATE); //复制描述符(3),但不共享
  19:	68 02 02 00 00       	push   $0x202
  1e:	68 a3 0a 00 00       	push   $0xaa3
  23:	e8 9a 03 00 00       	call   3c2 <open>
	int pid=thread_create(worker,&t); //创建一个子线程
  28:	58                   	pop    %eax
  29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  2c:	5a                   	pop    %edx
  2d:	50                   	push   %eax
  2e:	68 f0 00 00 00       	push   $0xf0
  33:	e8 e8 08 00 00       	call   920 <thread_create>
  38:	89 c3                	mov    %eax,%ebx

	thread_join();     //等待回收一个子线程
  3a:	e8 91 09 00 00       	call   9d0 <thread_join>

	printf(1,"thread id=%d\n",pid);
  3f:	83 c4 0c             	add    $0xc,%esp
  42:	53                   	push   %ebx
  43:	68 a7 0a 00 00       	push   $0xaa7
  48:	6a 01                	push   $0x1
  4a:	e8 b1 04 00 00       	call   500 <printf>

	printf(1,"global=%d\n",global);
  4f:	a1 cc 0e 00 00       	mov    0xecc,%eax
  54:	83 c4 0c             	add    $0xc,%esp
  57:	50                   	push   %eax
  58:	68 b5 0a 00 00       	push   $0xab5
  5d:	6a 01                	push   $0x1
  5f:	e8 9c 04 00 00       	call   500 <printf>
	// int c=add(1,2);
	// printf(1,"%d\n",c);
	
	
	exit();
  64:	e8 19 03 00 00       	call   382 <exit>
  69:	66 90                	xchg   %ax,%ax
  6b:	66 90                	xchg   %ax,%ax
  6d:	66 90                	xchg   %ax,%ax
  6f:	90                   	nop

00000070 <F>:
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	57                   	push   %edi
  74:	56                   	push   %esi
  75:	53                   	push   %ebx
  76:	83 ec 0c             	sub    $0xc,%esp
  79:	8b 75 08             	mov    0x8(%ebp),%esi
  if(n<0)
  7c:	85 f6                	test   %esi,%esi
  7e:	78 40                	js     c0 <F+0x50>
  else if(n==1 || n==2)
  80:	8d 5e ff             	lea    -0x1(%esi),%ebx
  83:	83 fb 01             	cmp    $0x1,%ebx
  86:	76 58                	jbe    e0 <F+0x70>
  88:	83 e6 01             	and    $0x1,%esi
  8b:	31 ff                	xor    %edi,%edi
  8d:	83 ee 01             	sub    $0x1,%esi
  	return F(n-1)+F(n-2);
  90:	83 ec 0c             	sub    $0xc,%esp
  93:	53                   	push   %ebx
  94:	e8 d7 ff ff ff       	call   70 <F>
  if(n<0)
  99:	83 c4 10             	add    $0x10,%esp
  9c:	01 c7                	add    %eax,%edi
  9e:	39 f3                	cmp    %esi,%ebx
  a0:	74 20                	je     c2 <F+0x52>
  a2:	83 eb 02             	sub    $0x2,%ebx
  else if(n==1 || n==2)
  a5:	83 fb 01             	cmp    $0x1,%ebx
  a8:	77 e6                	ja     90 <F+0x20>
}
  aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  ad:	83 c7 01             	add    $0x1,%edi
  b0:	89 f8                	mov    %edi,%eax
  b2:	5b                   	pop    %ebx
  b3:	5e                   	pop    %esi
  b4:	5f                   	pop    %edi
  b5:	5d                   	pop    %ebp
  b6:	c3                   	ret    
  b7:	89 f6                	mov    %esi,%esi
  b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  if(n<0)
  c0:	31 ff                	xor    %edi,%edi
  	printf(1,"请输入一个正整数\n");
  c2:	83 ec 08             	sub    $0x8,%esp
  c5:	68 6c 0a 00 00       	push   $0xa6c
  ca:	6a 01                	push   $0x1
  cc:	e8 2f 04 00 00       	call   500 <printf>
  return 0;
  d1:	83 c4 10             	add    $0x10,%esp
}
  d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  d7:	89 f8                	mov    %edi,%eax
  d9:	5b                   	pop    %ebx
  da:	5e                   	pop    %esi
  db:	5f                   	pop    %edi
  dc:	5d                   	pop    %ebp
  dd:	c3                   	ret    
  de:	66 90                	xchg   %ax,%ax
  e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  else if(n==1 || n==2)
  e3:	bf 01 00 00 00       	mov    $0x1,%edi
}
  e8:	89 f8                	mov    %edi,%eax
  ea:	5b                   	pop    %ebx
  eb:	5e                   	pop    %esi
  ec:	5f                   	pop    %edi
  ed:	5d                   	pop    %ebp
  ee:	c3                   	ret    
  ef:	90                   	nop

000000f0 <worker>:
void worker(void *arg){
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	83 ec 0c             	sub    $0xc,%esp
	printf(1,"thread %d is worker.\n",*(int*)arg);//测试参数传递
  f6:	8b 45 08             	mov    0x8(%ebp),%eax
  f9:	ff 30                	pushl  (%eax)
  fb:	68 86 0a 00 00       	push   $0xa86
 100:	6a 01                	push   $0x1
 102:	e8 f9 03 00 00       	call   500 <printf>
	global=F(15); //测试全局变量、压栈测试
 107:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
 10e:	e8 5d ff ff ff       	call   70 <F>
	write(3,"hello\n",6);//运行后可以在文件中看到新内容
 113:	83 c4 0c             	add    $0xc,%esp
	global=F(15); //测试全局变量、压栈测试
 116:	a3 cc 0e 00 00       	mov    %eax,0xecc
	write(3,"hello\n",6);//运行后可以在文件中看到新内容
 11b:	6a 06                	push   $0x6
 11d:	68 9c 0a 00 00       	push   $0xa9c
 122:	6a 03                	push   $0x3
 124:	e8 79 02 00 00       	call   3a2 <write>
	exit();
 129:	e8 54 02 00 00       	call   382 <exit>
 12e:	66 90                	xchg   %ax,%ax

00000130 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	53                   	push   %ebx
 134:	8b 45 08             	mov    0x8(%ebp),%eax
 137:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13a:	89 c2                	mov    %eax,%edx
 13c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 140:	83 c1 01             	add    $0x1,%ecx
 143:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
 147:	83 c2 01             	add    $0x1,%edx
 14a:	84 db                	test   %bl,%bl
 14c:	88 5a ff             	mov    %bl,-0x1(%edx)
 14f:	75 ef                	jne    140 <strcpy+0x10>
    ;
  return os;
}
 151:	5b                   	pop    %ebx
 152:	5d                   	pop    %ebp
 153:	c3                   	ret    
 154:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 15a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000160 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	53                   	push   %ebx
 164:	8b 55 08             	mov    0x8(%ebp),%edx
 167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
 16a:	0f b6 02             	movzbl (%edx),%eax
 16d:	0f b6 19             	movzbl (%ecx),%ebx
 170:	84 c0                	test   %al,%al
 172:	75 1c                	jne    190 <strcmp+0x30>
 174:	eb 2a                	jmp    1a0 <strcmp+0x40>
 176:	8d 76 00             	lea    0x0(%esi),%esi
 179:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    p++, q++;
 180:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 183:	0f b6 02             	movzbl (%edx),%eax
    p++, q++;
 186:	83 c1 01             	add    $0x1,%ecx
 189:	0f b6 19             	movzbl (%ecx),%ebx
  while(*p && *p == *q)
 18c:	84 c0                	test   %al,%al
 18e:	74 10                	je     1a0 <strcmp+0x40>
 190:	38 d8                	cmp    %bl,%al
 192:	74 ec                	je     180 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
 194:	29 d8                	sub    %ebx,%eax
}
 196:	5b                   	pop    %ebx
 197:	5d                   	pop    %ebp
 198:	c3                   	ret    
 199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 1a0:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
 1a2:	29 d8                	sub    %ebx,%eax
}
 1a4:	5b                   	pop    %ebx
 1a5:	5d                   	pop    %ebp
 1a6:	c3                   	ret    
 1a7:	89 f6                	mov    %esi,%esi
 1a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001b0 <strlen>:

uint
strlen(char *s)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1b6:	80 39 00             	cmpb   $0x0,(%ecx)
 1b9:	74 15                	je     1d0 <strlen+0x20>
 1bb:	31 d2                	xor    %edx,%edx
 1bd:	8d 76 00             	lea    0x0(%esi),%esi
 1c0:	83 c2 01             	add    $0x1,%edx
 1c3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1c7:	89 d0                	mov    %edx,%eax
 1c9:	75 f5                	jne    1c0 <strlen+0x10>
    ;
  return n;
}
 1cb:	5d                   	pop    %ebp
 1cc:	c3                   	ret    
 1cd:	8d 76 00             	lea    0x0(%esi),%esi
  for(n = 0; s[n]; n++)
 1d0:	31 c0                	xor    %eax,%eax
}
 1d2:	5d                   	pop    %ebp
 1d3:	c3                   	ret    
 1d4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 1da:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

000001e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	57                   	push   %edi
 1e4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ed:	89 d7                	mov    %edx,%edi
 1ef:	fc                   	cld    
 1f0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1f2:	89 d0                	mov    %edx,%eax
 1f4:	5f                   	pop    %edi
 1f5:	5d                   	pop    %ebp
 1f6:	c3                   	ret    
 1f7:	89 f6                	mov    %esi,%esi
 1f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
 203:	53                   	push   %ebx
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for(; *s; s++)
 20a:	0f b6 10             	movzbl (%eax),%edx
 20d:	84 d2                	test   %dl,%dl
 20f:	74 1d                	je     22e <strchr+0x2e>
    if(*s == c)
 211:	38 d3                	cmp    %dl,%bl
 213:	89 d9                	mov    %ebx,%ecx
 215:	75 0d                	jne    224 <strchr+0x24>
 217:	eb 17                	jmp    230 <strchr+0x30>
 219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 220:	38 ca                	cmp    %cl,%dl
 222:	74 0c                	je     230 <strchr+0x30>
  for(; *s; s++)
 224:	83 c0 01             	add    $0x1,%eax
 227:	0f b6 10             	movzbl (%eax),%edx
 22a:	84 d2                	test   %dl,%dl
 22c:	75 f2                	jne    220 <strchr+0x20>
      return (char*)s;
  return 0;
 22e:	31 c0                	xor    %eax,%eax
}
 230:	5b                   	pop    %ebx
 231:	5d                   	pop    %ebp
 232:	c3                   	ret    
 233:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000240 <gets>:

char*
gets(char *buf, int max)
{
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	57                   	push   %edi
 244:	56                   	push   %esi
 245:	53                   	push   %ebx
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 246:	31 f6                	xor    %esi,%esi
 248:	89 f3                	mov    %esi,%ebx
{
 24a:	83 ec 1c             	sub    $0x1c,%esp
 24d:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 250:	eb 2f                	jmp    281 <gets+0x41>
 252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 258:	8d 45 e7             	lea    -0x19(%ebp),%eax
 25b:	83 ec 04             	sub    $0x4,%esp
 25e:	6a 01                	push   $0x1
 260:	50                   	push   %eax
 261:	6a 00                	push   $0x0
 263:	e8 32 01 00 00       	call   39a <read>
    if(cc < 1)
 268:	83 c4 10             	add    $0x10,%esp
 26b:	85 c0                	test   %eax,%eax
 26d:	7e 1c                	jle    28b <gets+0x4b>
      break;
    buf[i++] = c;
 26f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 273:	83 c7 01             	add    $0x1,%edi
 276:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 279:	3c 0a                	cmp    $0xa,%al
 27b:	74 23                	je     2a0 <gets+0x60>
 27d:	3c 0d                	cmp    $0xd,%al
 27f:	74 1f                	je     2a0 <gets+0x60>
  for(i=0; i+1 < max; ){
 281:	83 c3 01             	add    $0x1,%ebx
 284:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 287:	89 fe                	mov    %edi,%esi
 289:	7c cd                	jl     258 <gets+0x18>
 28b:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 290:	c6 03 00             	movb   $0x0,(%ebx)
}
 293:	8d 65 f4             	lea    -0xc(%ebp),%esp
 296:	5b                   	pop    %ebx
 297:	5e                   	pop    %esi
 298:	5f                   	pop    %edi
 299:	5d                   	pop    %ebp
 29a:	c3                   	ret    
 29b:	90                   	nop
 29c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2a0:	8b 75 08             	mov    0x8(%ebp),%esi
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	01 de                	add    %ebx,%esi
 2a8:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 2aa:	c6 03 00             	movb   $0x0,(%ebx)
}
 2ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2b0:	5b                   	pop    %ebx
 2b1:	5e                   	pop    %esi
 2b2:	5f                   	pop    %edi
 2b3:	5d                   	pop    %ebp
 2b4:	c3                   	ret    
 2b5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000002c0 <stat>:

int
stat(char *n, struct stat *st)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	56                   	push   %esi
 2c4:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c5:	83 ec 08             	sub    $0x8,%esp
 2c8:	6a 00                	push   $0x0
 2ca:	ff 75 08             	pushl  0x8(%ebp)
 2cd:	e8 f0 00 00 00       	call   3c2 <open>
  if(fd < 0)
 2d2:	83 c4 10             	add    $0x10,%esp
 2d5:	85 c0                	test   %eax,%eax
 2d7:	78 27                	js     300 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 2d9:	83 ec 08             	sub    $0x8,%esp
 2dc:	ff 75 0c             	pushl  0xc(%ebp)
 2df:	89 c3                	mov    %eax,%ebx
 2e1:	50                   	push   %eax
 2e2:	e8 f3 00 00 00       	call   3da <fstat>
  close(fd);
 2e7:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 2ea:	89 c6                	mov    %eax,%esi
  close(fd);
 2ec:	e8 b9 00 00 00       	call   3aa <close>
  return r;
 2f1:	83 c4 10             	add    $0x10,%esp
}
 2f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
 2f7:	89 f0                	mov    %esi,%eax
 2f9:	5b                   	pop    %ebx
 2fa:	5e                   	pop    %esi
 2fb:	5d                   	pop    %ebp
 2fc:	c3                   	ret    
 2fd:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 300:	be ff ff ff ff       	mov    $0xffffffff,%esi
 305:	eb ed                	jmp    2f4 <stat+0x34>
 307:	89 f6                	mov    %esi,%esi
 309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000310 <atoi>:

int
atoi(const char *s)
{
 310:	55                   	push   %ebp
 311:	89 e5                	mov    %esp,%ebp
 313:	53                   	push   %ebx
 314:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 317:	0f be 11             	movsbl (%ecx),%edx
 31a:	8d 42 d0             	lea    -0x30(%edx),%eax
 31d:	3c 09                	cmp    $0x9,%al
  n = 0;
 31f:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 324:	77 1f                	ja     345 <atoi+0x35>
 326:	8d 76 00             	lea    0x0(%esi),%esi
 329:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    n = n*10 + *s++ - '0';
 330:	8d 04 80             	lea    (%eax,%eax,4),%eax
 333:	83 c1 01             	add    $0x1,%ecx
 336:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
  while('0' <= *s && *s <= '9')
 33a:	0f be 11             	movsbl (%ecx),%edx
 33d:	8d 5a d0             	lea    -0x30(%edx),%ebx
 340:	80 fb 09             	cmp    $0x9,%bl
 343:	76 eb                	jbe    330 <atoi+0x20>
  return n;
}
 345:	5b                   	pop    %ebx
 346:	5d                   	pop    %ebp
 347:	c3                   	ret    
 348:	90                   	nop
 349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000350 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	56                   	push   %esi
 354:	53                   	push   %ebx
 355:	8b 5d 10             	mov    0x10(%ebp),%ebx
 358:	8b 45 08             	mov    0x8(%ebp),%eax
 35b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35e:	85 db                	test   %ebx,%ebx
 360:	7e 14                	jle    376 <memmove+0x26>
 362:	31 d2                	xor    %edx,%edx
 364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *dst++ = *src++;
 368:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 36c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 36f:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0)
 372:	39 d3                	cmp    %edx,%ebx
 374:	75 f2                	jne    368 <memmove+0x18>
  return vdst;
}
 376:	5b                   	pop    %ebx
 377:	5e                   	pop    %esi
 378:	5d                   	pop    %ebp
 379:	c3                   	ret    

0000037a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 37a:	b8 01 00 00 00       	mov    $0x1,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <exit>:
SYSCALL(exit)
 382:	b8 02 00 00 00       	mov    $0x2,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <wait>:
SYSCALL(wait)
 38a:	b8 03 00 00 00       	mov    $0x3,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <pipe>:
SYSCALL(pipe)
 392:	b8 04 00 00 00       	mov    $0x4,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <read>:
SYSCALL(read)
 39a:	b8 05 00 00 00       	mov    $0x5,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <write>:
SYSCALL(write)
 3a2:	b8 10 00 00 00       	mov    $0x10,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <close>:
SYSCALL(close)
 3aa:	b8 15 00 00 00       	mov    $0x15,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <kill>:
SYSCALL(kill)
 3b2:	b8 06 00 00 00       	mov    $0x6,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <exec>:
SYSCALL(exec)
 3ba:	b8 07 00 00 00       	mov    $0x7,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <open>:
SYSCALL(open)
 3c2:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <mknod>:
SYSCALL(mknod)
 3ca:	b8 11 00 00 00       	mov    $0x11,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <unlink>:
SYSCALL(unlink)
 3d2:	b8 12 00 00 00       	mov    $0x12,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <fstat>:
SYSCALL(fstat)
 3da:	b8 08 00 00 00       	mov    $0x8,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <link>:
SYSCALL(link)
 3e2:	b8 13 00 00 00       	mov    $0x13,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <mkdir>:
SYSCALL(mkdir)
 3ea:	b8 14 00 00 00       	mov    $0x14,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <chdir>:
SYSCALL(chdir)
 3f2:	b8 09 00 00 00       	mov    $0x9,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <dup>:
SYSCALL(dup)
 3fa:	b8 0a 00 00 00       	mov    $0xa,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <getpid>:
SYSCALL(getpid)
 402:	b8 0b 00 00 00       	mov    $0xb,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <getcpuid>:
SYSCALL(getcpuid)
 40a:	b8 16 00 00 00       	mov    $0x16,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <sbrk>:
SYSCALL(sbrk)
 412:	b8 0c 00 00 00       	mov    $0xc,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <sleep>:
SYSCALL(sleep)
 41a:	b8 0d 00 00 00       	mov    $0xd,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <uptime>:
SYSCALL(uptime)
 422:	b8 0e 00 00 00       	mov    $0xe,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <myalloc>:
SYSCALL(myalloc)
 42a:	b8 17 00 00 00       	mov    $0x17,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <myfree>:
SYSCALL(myfree)
 432:	b8 18 00 00 00       	mov    $0x18,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <clone>:
SYSCALL(clone)
 43a:	b8 19 00 00 00       	mov    $0x19,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <join>:
SYSCALL(join)
 442:	b8 1a 00 00 00       	mov    $0x1a,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <cps>:
SYSCALL(cps);
 44a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <chpri>:
SYSCALL(chpri);
 452:	b8 1b 00 00 00       	mov    $0x1b,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    
 45a:	66 90                	xchg   %ax,%ax
 45c:	66 90                	xchg   %ax,%ax
 45e:	66 90                	xchg   %ax,%ax

00000460 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	57                   	push   %edi
 464:	56                   	push   %esi
 465:	53                   	push   %ebx
 466:	83 ec 3c             	sub    $0x3c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 469:	85 d2                	test   %edx,%edx
{
 46b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    neg = 1;
    x = -xx;
 46e:	89 d0                	mov    %edx,%eax
  if(sgn && xx < 0){
 470:	79 76                	jns    4e8 <printint+0x88>
 472:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 476:	74 70                	je     4e8 <printint+0x88>
    x = -xx;
 478:	f7 d8                	neg    %eax
    neg = 1;
 47a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 481:	31 f6                	xor    %esi,%esi
 483:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 486:	eb 0a                	jmp    492 <printint+0x32>
 488:	90                   	nop
 489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  do{
    buf[i++] = digits[x % base];
 490:	89 fe                	mov    %edi,%esi
 492:	31 d2                	xor    %edx,%edx
 494:	8d 7e 01             	lea    0x1(%esi),%edi
 497:	f7 f1                	div    %ecx
 499:	0f b6 92 c8 0a 00 00 	movzbl 0xac8(%edx),%edx
  }while((x /= base) != 0);
 4a0:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
 4a2:	88 14 3b             	mov    %dl,(%ebx,%edi,1)
  }while((x /= base) != 0);
 4a5:	75 e9                	jne    490 <printint+0x30>
  if(neg)
 4a7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 4aa:	85 c0                	test   %eax,%eax
 4ac:	74 08                	je     4b6 <printint+0x56>
    buf[i++] = '-';
 4ae:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
 4b3:	8d 7e 02             	lea    0x2(%esi),%edi
 4b6:	8d 74 3d d7          	lea    -0x29(%ebp,%edi,1),%esi
 4ba:	8b 7d c0             	mov    -0x40(%ebp),%edi
 4bd:	8d 76 00             	lea    0x0(%esi),%esi
 4c0:	0f b6 06             	movzbl (%esi),%eax
  write(fd, &c, 1);
 4c3:	83 ec 04             	sub    $0x4,%esp
 4c6:	83 ee 01             	sub    $0x1,%esi
 4c9:	6a 01                	push   $0x1
 4cb:	53                   	push   %ebx
 4cc:	57                   	push   %edi
 4cd:	88 45 d7             	mov    %al,-0x29(%ebp)
 4d0:	e8 cd fe ff ff       	call   3a2 <write>

  while(--i >= 0)
 4d5:	83 c4 10             	add    $0x10,%esp
 4d8:	39 de                	cmp    %ebx,%esi
 4da:	75 e4                	jne    4c0 <printint+0x60>
    putc(fd, buf[i]);
}
 4dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4df:	5b                   	pop    %ebx
 4e0:	5e                   	pop    %esi
 4e1:	5f                   	pop    %edi
 4e2:	5d                   	pop    %ebp
 4e3:	c3                   	ret    
 4e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 4e8:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 4ef:	eb 90                	jmp    481 <printint+0x21>
 4f1:	eb 0d                	jmp    500 <printf>
 4f3:	90                   	nop
 4f4:	90                   	nop
 4f5:	90                   	nop
 4f6:	90                   	nop
 4f7:	90                   	nop
 4f8:	90                   	nop
 4f9:	90                   	nop
 4fa:	90                   	nop
 4fb:	90                   	nop
 4fc:	90                   	nop
 4fd:	90                   	nop
 4fe:	90                   	nop
 4ff:	90                   	nop

00000500 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 500:	55                   	push   %ebp
 501:	89 e5                	mov    %esp,%ebp
 503:	57                   	push   %edi
 504:	56                   	push   %esi
 505:	53                   	push   %ebx
 506:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 509:	8b 75 0c             	mov    0xc(%ebp),%esi
 50c:	0f b6 1e             	movzbl (%esi),%ebx
 50f:	84 db                	test   %bl,%bl
 511:	0f 84 b3 00 00 00    	je     5ca <printf+0xca>
  ap = (uint*)(void*)&fmt + 1;
 517:	8d 45 10             	lea    0x10(%ebp),%eax
 51a:	83 c6 01             	add    $0x1,%esi
  state = 0;
 51d:	31 ff                	xor    %edi,%edi
  ap = (uint*)(void*)&fmt + 1;
 51f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 522:	eb 2f                	jmp    553 <printf+0x53>
 524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 528:	83 f8 25             	cmp    $0x25,%eax
 52b:	0f 84 a7 00 00 00    	je     5d8 <printf+0xd8>
  write(fd, &c, 1);
 531:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 534:	83 ec 04             	sub    $0x4,%esp
 537:	88 5d e2             	mov    %bl,-0x1e(%ebp)
 53a:	6a 01                	push   $0x1
 53c:	50                   	push   %eax
 53d:	ff 75 08             	pushl  0x8(%ebp)
 540:	e8 5d fe ff ff       	call   3a2 <write>
 545:	83 c4 10             	add    $0x10,%esp
 548:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 54b:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 54f:	84 db                	test   %bl,%bl
 551:	74 77                	je     5ca <printf+0xca>
    if(state == 0){
 553:	85 ff                	test   %edi,%edi
    c = fmt[i] & 0xff;
 555:	0f be cb             	movsbl %bl,%ecx
 558:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 55b:	74 cb                	je     528 <printf+0x28>
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 55d:	83 ff 25             	cmp    $0x25,%edi
 560:	75 e6                	jne    548 <printf+0x48>
      if(c == 'd'){
 562:	83 f8 64             	cmp    $0x64,%eax
 565:	0f 84 05 01 00 00    	je     670 <printf+0x170>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 56b:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 571:	83 f9 70             	cmp    $0x70,%ecx
 574:	74 72                	je     5e8 <printf+0xe8>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 576:	83 f8 73             	cmp    $0x73,%eax
 579:	0f 84 99 00 00 00    	je     618 <printf+0x118>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 57f:	83 f8 63             	cmp    $0x63,%eax
 582:	0f 84 08 01 00 00    	je     690 <printf+0x190>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 588:	83 f8 25             	cmp    $0x25,%eax
 58b:	0f 84 ef 00 00 00    	je     680 <printf+0x180>
  write(fd, &c, 1);
 591:	8d 45 e7             	lea    -0x19(%ebp),%eax
 594:	83 ec 04             	sub    $0x4,%esp
 597:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 59b:	6a 01                	push   $0x1
 59d:	50                   	push   %eax
 59e:	ff 75 08             	pushl  0x8(%ebp)
 5a1:	e8 fc fd ff ff       	call   3a2 <write>
 5a6:	83 c4 0c             	add    $0xc,%esp
 5a9:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 5ac:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 5af:	6a 01                	push   $0x1
 5b1:	50                   	push   %eax
 5b2:	ff 75 08             	pushl  0x8(%ebp)
 5b5:	83 c6 01             	add    $0x1,%esi
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b8:	31 ff                	xor    %edi,%edi
  write(fd, &c, 1);
 5ba:	e8 e3 fd ff ff       	call   3a2 <write>
  for(i = 0; fmt[i]; i++){
 5bf:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
  write(fd, &c, 1);
 5c3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 5c6:	84 db                	test   %bl,%bl
 5c8:	75 89                	jne    553 <printf+0x53>
    }
  }
}
 5ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5cd:	5b                   	pop    %ebx
 5ce:	5e                   	pop    %esi
 5cf:	5f                   	pop    %edi
 5d0:	5d                   	pop    %ebp
 5d1:	c3                   	ret    
 5d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        state = '%';
 5d8:	bf 25 00 00 00       	mov    $0x25,%edi
 5dd:	e9 66 ff ff ff       	jmp    548 <printf+0x48>
 5e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printint(fd, *ap, 16, 0);
 5e8:	83 ec 0c             	sub    $0xc,%esp
 5eb:	b9 10 00 00 00       	mov    $0x10,%ecx
 5f0:	6a 00                	push   $0x0
 5f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 5f5:	8b 45 08             	mov    0x8(%ebp),%eax
 5f8:	8b 17                	mov    (%edi),%edx
 5fa:	e8 61 fe ff ff       	call   460 <printint>
        ap++;
 5ff:	89 f8                	mov    %edi,%eax
 601:	83 c4 10             	add    $0x10,%esp
      state = 0;
 604:	31 ff                	xor    %edi,%edi
        ap++;
 606:	83 c0 04             	add    $0x4,%eax
 609:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 60c:	e9 37 ff ff ff       	jmp    548 <printf+0x48>
 611:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = (char*)*ap;
 618:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 61b:	8b 08                	mov    (%eax),%ecx
        ap++;
 61d:	83 c0 04             	add    $0x4,%eax
 620:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(s == 0)
 623:	85 c9                	test   %ecx,%ecx
 625:	0f 84 8e 00 00 00    	je     6b9 <printf+0x1b9>
        while(*s != 0){
 62b:	0f b6 01             	movzbl (%ecx),%eax
      state = 0;
 62e:	31 ff                	xor    %edi,%edi
        s = (char*)*ap;
 630:	89 cb                	mov    %ecx,%ebx
        while(*s != 0){
 632:	84 c0                	test   %al,%al
 634:	0f 84 0e ff ff ff    	je     548 <printf+0x48>
 63a:	89 75 d0             	mov    %esi,-0x30(%ebp)
 63d:	89 de                	mov    %ebx,%esi
 63f:	8b 5d 08             	mov    0x8(%ebp),%ebx
 642:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 645:	8d 76 00             	lea    0x0(%esi),%esi
  write(fd, &c, 1);
 648:	83 ec 04             	sub    $0x4,%esp
          s++;
 64b:	83 c6 01             	add    $0x1,%esi
 64e:	88 45 e3             	mov    %al,-0x1d(%ebp)
  write(fd, &c, 1);
 651:	6a 01                	push   $0x1
 653:	57                   	push   %edi
 654:	53                   	push   %ebx
 655:	e8 48 fd ff ff       	call   3a2 <write>
        while(*s != 0){
 65a:	0f b6 06             	movzbl (%esi),%eax
 65d:	83 c4 10             	add    $0x10,%esp
 660:	84 c0                	test   %al,%al
 662:	75 e4                	jne    648 <printf+0x148>
 664:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 667:	31 ff                	xor    %edi,%edi
 669:	e9 da fe ff ff       	jmp    548 <printf+0x48>
 66e:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 10, 1);
 670:	83 ec 0c             	sub    $0xc,%esp
 673:	b9 0a 00 00 00       	mov    $0xa,%ecx
 678:	6a 01                	push   $0x1
 67a:	e9 73 ff ff ff       	jmp    5f2 <printf+0xf2>
 67f:	90                   	nop
  write(fd, &c, 1);
 680:	83 ec 04             	sub    $0x4,%esp
 683:	88 5d e5             	mov    %bl,-0x1b(%ebp)
 686:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 689:	6a 01                	push   $0x1
 68b:	e9 21 ff ff ff       	jmp    5b1 <printf+0xb1>
        putc(fd, *ap);
 690:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  write(fd, &c, 1);
 693:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 696:	8b 07                	mov    (%edi),%eax
  write(fd, &c, 1);
 698:	6a 01                	push   $0x1
        ap++;
 69a:	83 c7 04             	add    $0x4,%edi
        putc(fd, *ap);
 69d:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 6a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 6a3:	50                   	push   %eax
 6a4:	ff 75 08             	pushl  0x8(%ebp)
 6a7:	e8 f6 fc ff ff       	call   3a2 <write>
        ap++;
 6ac:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 6af:	83 c4 10             	add    $0x10,%esp
      state = 0;
 6b2:	31 ff                	xor    %edi,%edi
 6b4:	e9 8f fe ff ff       	jmp    548 <printf+0x48>
          s = "(null)";
 6b9:	bb c0 0a 00 00       	mov    $0xac0,%ebx
        while(*s != 0){
 6be:	b8 28 00 00 00       	mov    $0x28,%eax
 6c3:	e9 72 ff ff ff       	jmp    63a <printf+0x13a>
 6c8:	66 90                	xchg   %ax,%ax
 6ca:	66 90                	xchg   %ax,%ax
 6cc:	66 90                	xchg   %ax,%ax
 6ce:	66 90                	xchg   %ax,%ax

000006d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d1:	a1 e0 0e 00 00       	mov    0xee0,%eax
{
 6d6:	89 e5                	mov    %esp,%ebp
 6d8:	57                   	push   %edi
 6d9:	56                   	push   %esi
 6da:	53                   	push   %ebx
 6db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 6de:	8d 4b f8             	lea    -0x8(%ebx),%ecx
 6e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e8:	39 c8                	cmp    %ecx,%eax
 6ea:	8b 10                	mov    (%eax),%edx
 6ec:	73 32                	jae    720 <free+0x50>
 6ee:	39 d1                	cmp    %edx,%ecx
 6f0:	72 04                	jb     6f6 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f2:	39 d0                	cmp    %edx,%eax
 6f4:	72 32                	jb     728 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f6:	8b 73 fc             	mov    -0x4(%ebx),%esi
 6f9:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6fc:	39 fa                	cmp    %edi,%edx
 6fe:	74 30                	je     730 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 700:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 703:	8b 50 04             	mov    0x4(%eax),%edx
 706:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 709:	39 f1                	cmp    %esi,%ecx
 70b:	74 3a                	je     747 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 70d:	89 08                	mov    %ecx,(%eax)
  freep = p;
 70f:	a3 e0 0e 00 00       	mov    %eax,0xee0
}
 714:	5b                   	pop    %ebx
 715:	5e                   	pop    %esi
 716:	5f                   	pop    %edi
 717:	5d                   	pop    %ebp
 718:	c3                   	ret    
 719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 720:	39 d0                	cmp    %edx,%eax
 722:	72 04                	jb     728 <free+0x58>
 724:	39 d1                	cmp    %edx,%ecx
 726:	72 ce                	jb     6f6 <free+0x26>
{
 728:	89 d0                	mov    %edx,%eax
 72a:	eb bc                	jmp    6e8 <free+0x18>
 72c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 730:	03 72 04             	add    0x4(%edx),%esi
 733:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 736:	8b 10                	mov    (%eax),%edx
 738:	8b 12                	mov    (%edx),%edx
 73a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 73d:	8b 50 04             	mov    0x4(%eax),%edx
 740:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 743:	39 f1                	cmp    %esi,%ecx
 745:	75 c6                	jne    70d <free+0x3d>
    p->s.size += bp->s.size;
 747:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 74a:	a3 e0 0e 00 00       	mov    %eax,0xee0
    p->s.size += bp->s.size;
 74f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 752:	8b 53 f8             	mov    -0x8(%ebx),%edx
 755:	89 10                	mov    %edx,(%eax)
}
 757:	5b                   	pop    %ebx
 758:	5e                   	pop    %esi
 759:	5f                   	pop    %edi
 75a:	5d                   	pop    %ebp
 75b:	c3                   	ret    
 75c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000760 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 760:	55                   	push   %ebp
 761:	89 e5                	mov    %esp,%ebp
 763:	57                   	push   %edi
 764:	56                   	push   %esi
 765:	53                   	push   %ebx
 766:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 769:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 76c:	8b 15 e0 0e 00 00    	mov    0xee0,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 772:	8d 78 07             	lea    0x7(%eax),%edi
 775:	c1 ef 03             	shr    $0x3,%edi
 778:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 77b:	85 d2                	test   %edx,%edx
 77d:	0f 84 9d 00 00 00    	je     820 <malloc+0xc0>
 783:	8b 02                	mov    (%edx),%eax
 785:	8b 48 04             	mov    0x4(%eax),%ecx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 788:	39 cf                	cmp    %ecx,%edi
 78a:	76 6c                	jbe    7f8 <malloc+0x98>
 78c:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
 792:	bb 00 10 00 00       	mov    $0x1000,%ebx
 797:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 79a:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 7a1:	eb 0e                	jmp    7b1 <malloc+0x51>
 7a3:	90                   	nop
 7a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a8:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 7aa:	8b 48 04             	mov    0x4(%eax),%ecx
 7ad:	39 f9                	cmp    %edi,%ecx
 7af:	73 47                	jae    7f8 <malloc+0x98>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7b1:	39 05 e0 0e 00 00    	cmp    %eax,0xee0
 7b7:	89 c2                	mov    %eax,%edx
 7b9:	75 ed                	jne    7a8 <malloc+0x48>
  p = sbrk(nu * sizeof(Header));
 7bb:	83 ec 0c             	sub    $0xc,%esp
 7be:	56                   	push   %esi
 7bf:	e8 4e fc ff ff       	call   412 <sbrk>
  if(p == (char*)-1)
 7c4:	83 c4 10             	add    $0x10,%esp
 7c7:	83 f8 ff             	cmp    $0xffffffff,%eax
 7ca:	74 1c                	je     7e8 <malloc+0x88>
  hp->s.size = nu;
 7cc:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 7cf:	83 ec 0c             	sub    $0xc,%esp
 7d2:	83 c0 08             	add    $0x8,%eax
 7d5:	50                   	push   %eax
 7d6:	e8 f5 fe ff ff       	call   6d0 <free>
  return freep;
 7db:	8b 15 e0 0e 00 00    	mov    0xee0,%edx
      if((p = morecore(nunits)) == 0)
 7e1:	83 c4 10             	add    $0x10,%esp
 7e4:	85 d2                	test   %edx,%edx
 7e6:	75 c0                	jne    7a8 <malloc+0x48>
        return 0;
  }
}
 7e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 7eb:	31 c0                	xor    %eax,%eax
}
 7ed:	5b                   	pop    %ebx
 7ee:	5e                   	pop    %esi
 7ef:	5f                   	pop    %edi
 7f0:	5d                   	pop    %ebp
 7f1:	c3                   	ret    
 7f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 7f8:	39 cf                	cmp    %ecx,%edi
 7fa:	74 54                	je     850 <malloc+0xf0>
        p->s.size -= nunits;
 7fc:	29 f9                	sub    %edi,%ecx
 7fe:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 801:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 804:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 807:	89 15 e0 0e 00 00    	mov    %edx,0xee0
}
 80d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 810:	83 c0 08             	add    $0x8,%eax
}
 813:	5b                   	pop    %ebx
 814:	5e                   	pop    %esi
 815:	5f                   	pop    %edi
 816:	5d                   	pop    %ebp
 817:	c3                   	ret    
 818:	90                   	nop
 819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    base.s.ptr = freep = prevp = &base;
 820:	c7 05 e0 0e 00 00 e4 	movl   $0xee4,0xee0
 827:	0e 00 00 
 82a:	c7 05 e4 0e 00 00 e4 	movl   $0xee4,0xee4
 831:	0e 00 00 
    base.s.size = 0;
 834:	b8 e4 0e 00 00       	mov    $0xee4,%eax
 839:	c7 05 e8 0e 00 00 00 	movl   $0x0,0xee8
 840:	00 00 00 
 843:	e9 44 ff ff ff       	jmp    78c <malloc+0x2c>
 848:	90                   	nop
 849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        prevp->s.ptr = p->s.ptr;
 850:	8b 08                	mov    (%eax),%ecx
 852:	89 0a                	mov    %ecx,(%edx)
 854:	eb b1                	jmp    807 <malloc+0xa7>
 856:	66 90                	xchg   %ax,%ax
 858:	66 90                	xchg   %ax,%ax
 85a:	66 90                	xchg   %ax,%ax
 85c:	66 90                	xchg   %ax,%ax
 85e:	66 90                	xchg   %ax,%ax

00000860 <add_thread>:
	void *ustack;
	int used;
}threads[NTHREAD]; //TCB表

//add a TCB to thread table
void add_thread(int *pid,void *ustack){
 860:	ba 00 0f 00 00       	mov    $0xf00,%edx
	int i;
	for(i=0;i<NTHREAD;i++){
 865:	31 c0                	xor    %eax,%eax
		if(threads[i].used==0){
 867:	8b 4a 08             	mov    0x8(%edx),%ecx
 86a:	85 c9                	test   %ecx,%ecx
 86c:	74 12                	je     880 <add_thread+0x20>
	for(i=0;i<NTHREAD;i++){
 86e:	83 c0 01             	add    $0x1,%eax
 871:	83 c2 0c             	add    $0xc,%edx
 874:	83 f8 04             	cmp    $0x4,%eax
 877:	75 ee                	jne    867 <add_thread+0x7>
 879:	f3 c3                	repz ret 
 87b:	90                   	nop
 87c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void add_thread(int *pid,void *ustack){
 880:	55                   	push   %ebp
			threads[i].pid=*pid;
 881:	8d 04 40             	lea    (%eax,%eax,2),%eax
void add_thread(int *pid,void *ustack){
 884:	89 e5                	mov    %esp,%ebp
			threads[i].pid=*pid;
 886:	c1 e0 02             	shl    $0x2,%eax
 889:	8b 55 08             	mov    0x8(%ebp),%edx
 88c:	8b 0a                	mov    (%edx),%ecx
 88e:	8d 90 00 0f 00 00    	lea    0xf00(%eax),%edx
			threads[i].ustack=ustack;
			threads[i].used=1;
 894:	c7 42 08 01 00 00 00 	movl   $0x1,0x8(%edx)
			threads[i].pid=*pid;
 89b:	89 88 00 0f 00 00    	mov    %ecx,0xf00(%eax)
			threads[i].ustack=ustack;
 8a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 8a4:	89 42 04             	mov    %eax,0x4(%edx)
			break;
		}
	}
}
 8a7:	5d                   	pop    %ebp
 8a8:	c3                   	ret    
 8a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

000008b0 <remove_thread>:

void remove_thread(int *pid)
{
 8b0:	55                   	push   %ebp
 8b1:	b8 00 0f 00 00       	mov    $0xf00,%eax
    int i;
	for(i=0;i<NTHREAD;i++){
 8b6:	31 d2                	xor    %edx,%edx
{
 8b8:	89 e5                	mov    %esp,%ebp
 8ba:	56                   	push   %esi
 8bb:	53                   	push   %ebx
 8bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
    	if(threads[i].used && threads[i].pid==*pid)
 8bf:	8b 58 08             	mov    0x8(%eax),%ebx
 8c2:	85 db                	test   %ebx,%ebx
 8c4:	74 06                	je     8cc <remove_thread+0x1c>
 8c6:	8b 31                	mov    (%ecx),%esi
 8c8:	39 30                	cmp    %esi,(%eax)
 8ca:	74 14                	je     8e0 <remove_thread+0x30>
	for(i=0;i<NTHREAD;i++){
 8cc:	83 c2 01             	add    $0x1,%edx
 8cf:	83 c0 0c             	add    $0xc,%eax
 8d2:	83 fa 04             	cmp    $0x4,%edx
 8d5:	75 e8                	jne    8bf <remove_thread+0xf>
    		threads[i].ustack=0;
    		threads[i].used=0;
    		break;
    	}
    }
}
 8d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
 8da:	5b                   	pop    %ebx
 8db:	5e                   	pop    %esi
 8dc:	5d                   	pop    %ebp
 8dd:	c3                   	ret    
 8de:	66 90                	xchg   %ax,%ax
    		free(threads[i].ustack); //释放用户栈
 8e0:	8d 1c 52             	lea    (%edx,%edx,2),%ebx
 8e3:	83 ec 0c             	sub    $0xc,%esp
 8e6:	c1 e3 02             	shl    $0x2,%ebx
 8e9:	ff b3 04 0f 00 00    	pushl  0xf04(%ebx)
 8ef:	e8 dc fd ff ff       	call   6d0 <free>
    		threads[i].pid=0;
 8f4:	c7 83 00 0f 00 00 00 	movl   $0x0,0xf00(%ebx)
 8fb:	00 00 00 
    		threads[i].ustack=0;
 8fe:	c7 83 04 0f 00 00 00 	movl   $0x0,0xf04(%ebx)
 905:	00 00 00 
    		break;
 908:	83 c4 10             	add    $0x10,%esp
    		threads[i].used=0;
 90b:	c7 83 08 0f 00 00 00 	movl   $0x0,0xf08(%ebx)
 912:	00 00 00 
}
 915:	8d 65 f8             	lea    -0x8(%ebp),%esp
 918:	5b                   	pop    %ebx
 919:	5e                   	pop    %esi
 91a:	5d                   	pop    %ebp
 91b:	c3                   	ret    
 91c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000920 <thread_create>:

int thread_create(void(*start_routine)(void*),void* arg){
 920:	55                   	push   %ebp
 921:	89 e5                	mov    %esp,%ebp
 923:	53                   	push   %ebx
 924:	83 ec 04             	sub    $0x4,%esp
	//if first time running any threads,initialize thread table with zeros
	static int first=1;
	if(first){
 927:	a1 d0 0e 00 00       	mov    0xed0,%eax
 92c:	85 c0                	test   %eax,%eax
 92e:	74 2d                	je     95d <thread_create+0x3d>
		first=0;
 930:	c7 05 d0 0e 00 00 00 	movl   $0x0,0xed0
 937:	00 00 00 
 93a:	b8 00 0f 00 00       	mov    $0xf00,%eax
		int i;
		for(i=0;i<NTHREAD;i++){
			threads[i].pid=0;
 93f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			threads[i].ustack=0;
 945:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
 94c:	83 c0 0c             	add    $0xc,%eax
			threads[i].used=0;
 94f:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
		for(i=0;i<NTHREAD;i++){
 956:	3d 30 0f 00 00       	cmp    $0xf30,%eax
 95b:	75 e2                	jne    93f <thread_create+0x1f>
		}
	}
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 95d:	83 ec 0c             	sub    $0xc,%esp
 960:	68 00 10 00 00       	push   $0x1000
 965:	e8 f6 fd ff ff       	call   760 <malloc>
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 96a:	83 c4 0c             	add    $0xc,%esp
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 96d:	89 c3                	mov    %eax,%ebx
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 96f:	50                   	push   %eax
 970:	ff 75 0c             	pushl  0xc(%ebp)
 973:	ff 75 08             	pushl  0x8(%ebp)
 976:	e8 bf fa ff ff       	call   43a <clone>
 97b:	b9 00 0f 00 00       	mov    $0xf00,%ecx
 980:	83 c4 10             	add    $0x10,%esp
	for(i=0;i<NTHREAD;i++){
 983:	31 d2                	xor    %edx,%edx
		if(threads[i].used==0){
 985:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
 989:	74 15                	je     9a0 <thread_create+0x80>
	for(i=0;i<NTHREAD;i++){
 98b:	83 c2 01             	add    $0x1,%edx
 98e:	83 c1 0c             	add    $0xc,%ecx
 991:	83 fa 04             	cmp    $0x4,%edx
 994:	75 ef                	jne    985 <thread_create+0x65>
	add_thread(&pid,stack);//save new thread to thread table
	return pid;
}
 996:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 999:	c9                   	leave  
 99a:	c3                   	ret    
 99b:	90                   	nop
 99c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			threads[i].pid=*pid;
 9a0:	8d 14 52             	lea    (%edx,%edx,2),%edx
 9a3:	c1 e2 02             	shl    $0x2,%edx
			threads[i].ustack=ustack;
 9a6:	89 9a 04 0f 00 00    	mov    %ebx,0xf04(%edx)
			threads[i].pid=*pid;
 9ac:	89 82 00 0f 00 00    	mov    %eax,0xf00(%edx)
			threads[i].used=1;
 9b2:	c7 82 08 0f 00 00 01 	movl   $0x1,0xf08(%edx)
 9b9:	00 00 00 
}
 9bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 9bf:	c9                   	leave  
 9c0:	c3                   	ret    
 9c1:	eb 0d                	jmp    9d0 <thread_join>
 9c3:	90                   	nop
 9c4:	90                   	nop
 9c5:	90                   	nop
 9c6:	90                   	nop
 9c7:	90                   	nop
 9c8:	90                   	nop
 9c9:	90                   	nop
 9ca:	90                   	nop
 9cb:	90                   	nop
 9cc:	90                   	nop
 9cd:	90                   	nop
 9ce:	90                   	nop
 9cf:	90                   	nop

000009d0 <thread_join>:

int thread_join(void){
 9d0:	55                   	push   %ebp
 9d1:	89 e5                	mov    %esp,%ebp
 9d3:	53                   	push   %ebx
 9d4:	bb 00 0f 00 00       	mov    $0xf00,%ebx
 9d9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for(i=0;i<NTHREAD;i++){
		if(threads[i].used==1){
 9dc:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
 9e0:	74 16                	je     9f8 <thread_join+0x28>
 9e2:	83 c3 0c             	add    $0xc,%ebx
	for(i=0;i<NTHREAD;i++){
 9e5:	81 fb 30 0f 00 00    	cmp    $0xf30,%ebx
 9eb:	75 ef                	jne    9dc <thread_join+0xc>
				remove_thread(&pid);
				return pid;
			}
		}
	}
	return 0;
 9ed:	31 c0                	xor    %eax,%eax
}
 9ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 9f2:	c9                   	leave  
 9f3:	c3                   	ret    
 9f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			int pid=join(&threads[i].ustack);  //回收子线程
 9f8:	8d 43 04             	lea    0x4(%ebx),%eax
 9fb:	83 ec 0c             	sub    $0xc,%esp
 9fe:	50                   	push   %eax
 9ff:	e8 3e fa ff ff       	call   442 <join>
			if(pid>0){
 a04:	83 c4 10             	add    $0x10,%esp
 a07:	85 c0                	test   %eax,%eax
			int pid=join(&threads[i].ustack);  //回收子线程
 a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
			if(pid>0){
 a0c:	7e d4                	jle    9e2 <thread_join+0x12>
				remove_thread(&pid);
 a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 a11:	83 ec 0c             	sub    $0xc,%esp
 a14:	50                   	push   %eax
 a15:	e8 96 fe ff ff       	call   8b0 <remove_thread>
				return pid;
 a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1d:	83 c4 10             	add    $0x10,%esp
 a20:	eb cd                	jmp    9ef <thread_join+0x1f>
 a22:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 a29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000a30 <printTCB>:

void printTCB(void){
 a30:	55                   	push   %ebp
 a31:	89 e5                	mov    %esp,%ebp
 a33:	53                   	push   %ebx
	int i;
	for(i=0;i<NTHREAD;i++)
 a34:	31 db                	xor    %ebx,%ebx
void printTCB(void){
 a36:	83 ec 04             	sub    $0x4,%esp
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 a39:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 a3c:	ff 34 85 08 0f 00 00 	pushl  0xf08(,%eax,4)
 a43:	53                   	push   %ebx
	for(i=0;i<NTHREAD;i++)
 a44:	83 c3 01             	add    $0x1,%ebx
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 a47:	68 d9 0a 00 00       	push   $0xad9
 a4c:	6a 01                	push   $0x1
 a4e:	e8 ad fa ff ff       	call   500 <printf>
	for(i=0;i<NTHREAD;i++)
 a53:	83 c4 10             	add    $0x10,%esp
 a56:	83 fb 04             	cmp    $0x4,%ebx
 a59:	75 de                	jne    a39 <printTCB+0x9>
}
 a5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 a5e:	c9                   	leave  
 a5f:	c3                   	ret    

00000a60 <add>:

int add(int a,int b)
{ 
 a60:	55                   	push   %ebp
 a61:	89 e5                	mov    %esp,%ebp
	return a+b;
 a63:	8b 45 0c             	mov    0xc(%ebp),%eax
 a66:	03 45 08             	add    0x8(%ebp),%eax
 a69:	5d                   	pop    %ebp
 a6a:	c3                   	ret    
