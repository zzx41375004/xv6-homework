
_prio_sched:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"
int
main(int argc, char *argv[])
{ 
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 30             	sub    $0x30,%esp
    int pid;
    int data[8];
    printf(1,"This is a demo for prio-schedule!\n");
  14:	68 ac 0a 00 00       	push   $0xaac
  19:	6a 01                	push   $0x1
  1b:	e8 20 05 00 00       	call   540 <printf>
    pid=getpid();
  20:	e8 1d 04 00 00       	call   442 <getpid>
    chpri(pid,19); //如果系统默认优先级不是 19，则需先设置
  25:	5f                   	pop    %edi
  26:	5a                   	pop    %edx
  27:	6a 13                	push   $0x13
  29:	50                   	push   %eax
  2a:	e8 63 04 00 00       	call   492 <chpri>

    pid=fork();
  2f:	e8 86 03 00 00       	call   3ba <fork>
    if(pid!=0){
  34:	83 c4 10             	add    $0x10,%esp
  37:	85 c0                	test   %eax,%eax
  39:	0f 85 83 00 00 00    	jne    c2 <main+0xc2>
                printf(1,"pid%d prio%d\n ",pid,5);
                }
            }
        }
    }
    sleep(20); //该睡眠是为了保证子进程创建完成，不是必须的
  3f:	83 ec 0c             	sub    $0xc,%esp
    pid=getpid();
    printf(1,"pid=%d started\n",pid);
  42:	bf 02 00 00 00       	mov    $0x2,%edi
    sleep(20); //该睡眠是为了保证子进程创建完成，不是必须的
  47:	6a 14                	push   $0x14
  49:	e8 0c 04 00 00       	call   45a <sleep>
    pid=getpid();
  4e:	e8 ef 03 00 00       	call   442 <getpid>
    printf(1,"pid=%d started\n",pid);
  53:	83 c4 0c             	add    $0xc,%esp
    pid=getpid();
  56:	89 c6                	mov    %eax,%esi
    printf(1,"pid=%d started\n",pid);
  58:	50                   	push   %eax
  59:	68 ed 0a 00 00       	push   $0xaed
  5e:	6a 01                	push   $0x1
  60:	e8 db 04 00 00       	call   540 <printf>
  65:	83 c4 10             	add    $0x10,%esp
    int i,j,k;
    for(i=0;i<2;i++)
    { 
        printf(1,"pid=%d runing\n",pid);
  68:	83 ec 04             	sub    $0x4,%esp
  6b:	56                   	push   %esi
  6c:	68 fd 0a 00 00       	push   $0xafd
  71:	6a 01                	push   $0x1
  73:	e8 c8 04 00 00       	call   540 <printf>
  78:	83 c4 10             	add    $0x10,%esp
  7b:	b8 00 90 01 00       	mov    $0x19000,%eax
    printf(1,"pid=%d started\n",pid);
  80:	31 c9                	xor    %ecx,%ecx
        for(j=0;j<1024*100;j++)
        for(k=0;k<1024;k++)
  82:	31 d2                	xor    %edx,%edx
  84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        data[k%8]=pid*k;
  88:	89 d3                	mov    %edx,%ebx
        for(k=0;k<1024;k++)
  8a:	83 c2 01             	add    $0x1,%edx
        data[k%8]=pid*k;
  8d:	83 e3 07             	and    $0x7,%ebx
  90:	89 4c 9d c8          	mov    %ecx,-0x38(%ebp,%ebx,4)
  94:	01 f1                	add    %esi,%ecx
        for(k=0;k<1024;k++)
  96:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  9c:	75 ea                	jne    88 <main+0x88>
        for(j=0;j<1024*100;j++)
  9e:	83 e8 01             	sub    $0x1,%eax
  a1:	75 dd                	jne    80 <main+0x80>
    for(i=0;i<2;i++)
  a3:	83 ff 01             	cmp    $0x1,%edi
  a6:	0f 85 ba 00 00 00    	jne    166 <main+0x166>
    }
    printf(1,"pid=%d finished %d\n",pid,data[pid]);
  ac:	ff 74 b5 c8          	pushl  -0x38(%ebp,%esi,4)
  b0:	56                   	push   %esi
  b1:	68 0c 0b 00 00       	push   $0xb0c
  b6:	6a 01                	push   $0x1
  b8:	e8 83 04 00 00       	call   540 <printf>
    exit();
  bd:	e8 00 03 00 00       	call   3c2 <exit>
        chpri(pid,15); //set 1st child’s prio=15
  c2:	56                   	push   %esi
  c3:	56                   	push   %esi
  c4:	89 c3                	mov    %eax,%ebx
  c6:	6a 0f                	push   $0xf
  c8:	50                   	push   %eax
  c9:	e8 c4 03 00 00       	call   492 <chpri>
        printf(1,"pid%d prio%d\n",pid,15);
  ce:	6a 0f                	push   $0xf
  d0:	53                   	push   %ebx
  d1:	68 d0 0a 00 00       	push   $0xad0
  d6:	6a 01                	push   $0x1
  d8:	e8 63 04 00 00       	call   540 <printf>
        pid=fork();
  dd:	83 c4 20             	add    $0x20,%esp
  e0:	e8 d5 02 00 00       	call   3ba <fork>
        if(pid!=0){
  e5:	85 c0                	test   %eax,%eax
        pid=fork();
  e7:	89 c3                	mov    %eax,%ebx
        if(pid!=0){
  e9:	0f 84 50 ff ff ff    	je     3f <main+0x3f>
        chpri(pid,15); //set 2nd child’s prio=15
  ef:	51                   	push   %ecx
  f0:	51                   	push   %ecx
  f1:	6a 0f                	push   $0xf
  f3:	50                   	push   %eax
  f4:	e8 99 03 00 00       	call   492 <chpri>
        printf(1,"pid%d prio%d\n ",pid,15);
  f9:	6a 0f                	push   $0xf
  fb:	53                   	push   %ebx
  fc:	68 de 0a 00 00       	push   $0xade
 101:	6a 01                	push   $0x1
 103:	e8 38 04 00 00       	call   540 <printf>
        pid=fork();
 108:	83 c4 20             	add    $0x20,%esp
 10b:	e8 aa 02 00 00       	call   3ba <fork>
        if(pid!=0){
 110:	85 c0                	test   %eax,%eax
        pid=fork();
 112:	89 c3                	mov    %eax,%ebx
        if(pid!=0){
 114:	0f 84 25 ff ff ff    	je     3f <main+0x3f>
            chpri(pid,5); //set 3rd child’s prio=5
 11a:	52                   	push   %edx
 11b:	52                   	push   %edx
 11c:	6a 05                	push   $0x5
 11e:	50                   	push   %eax
 11f:	e8 6e 03 00 00       	call   492 <chpri>
            printf(1,"pid%d prio%d\n ",pid,5);
 124:	6a 05                	push   $0x5
 126:	53                   	push   %ebx
 127:	68 de 0a 00 00       	push   $0xade
 12c:	6a 01                	push   $0x1
 12e:	e8 0d 04 00 00       	call   540 <printf>
            pid=fork();
 133:	83 c4 20             	add    $0x20,%esp
 136:	e8 7f 02 00 00       	call   3ba <fork>
            if(pid!=0){
 13b:	85 c0                	test   %eax,%eax
            pid=fork();
 13d:	89 c3                	mov    %eax,%ebx
            if(pid!=0){
 13f:	0f 84 fa fe ff ff    	je     3f <main+0x3f>
                chpri(pid,5); //set 4th child’s prio=5
 145:	50                   	push   %eax
 146:	50                   	push   %eax
 147:	6a 05                	push   $0x5
 149:	53                   	push   %ebx
 14a:	e8 43 03 00 00       	call   492 <chpri>
                printf(1,"pid%d prio%d\n ",pid,5);
 14f:	6a 05                	push   $0x5
 151:	53                   	push   %ebx
 152:	68 de 0a 00 00       	push   $0xade
 157:	6a 01                	push   $0x1
 159:	e8 e2 03 00 00       	call   540 <printf>
 15e:	83 c4 20             	add    $0x20,%esp
 161:	e9 d9 fe ff ff       	jmp    3f <main+0x3f>
 166:	bf 01 00 00 00       	mov    $0x1,%edi
 16b:	e9 f8 fe ff ff       	jmp    68 <main+0x68>

00000170 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	53                   	push   %ebx
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 17a:	89 c2                	mov    %eax,%edx
 17c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 180:	83 c1 01             	add    $0x1,%ecx
 183:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
 187:	83 c2 01             	add    $0x1,%edx
 18a:	84 db                	test   %bl,%bl
 18c:	88 5a ff             	mov    %bl,-0x1(%edx)
 18f:	75 ef                	jne    180 <strcpy+0x10>
    ;
  return os;
}
 191:	5b                   	pop    %ebx
 192:	5d                   	pop    %ebp
 193:	c3                   	ret    
 194:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 19a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

000001a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	53                   	push   %ebx
 1a4:	8b 55 08             	mov    0x8(%ebp),%edx
 1a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
 1aa:	0f b6 02             	movzbl (%edx),%eax
 1ad:	0f b6 19             	movzbl (%ecx),%ebx
 1b0:	84 c0                	test   %al,%al
 1b2:	75 1c                	jne    1d0 <strcmp+0x30>
 1b4:	eb 2a                	jmp    1e0 <strcmp+0x40>
 1b6:	8d 76 00             	lea    0x0(%esi),%esi
 1b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    p++, q++;
 1c0:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 1c3:	0f b6 02             	movzbl (%edx),%eax
    p++, q++;
 1c6:	83 c1 01             	add    $0x1,%ecx
 1c9:	0f b6 19             	movzbl (%ecx),%ebx
  while(*p && *p == *q)
 1cc:	84 c0                	test   %al,%al
 1ce:	74 10                	je     1e0 <strcmp+0x40>
 1d0:	38 d8                	cmp    %bl,%al
 1d2:	74 ec                	je     1c0 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
 1d4:	29 d8                	sub    %ebx,%eax
}
 1d6:	5b                   	pop    %ebx
 1d7:	5d                   	pop    %ebp
 1d8:	c3                   	ret    
 1d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 1e0:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
 1e2:	29 d8                	sub    %ebx,%eax
}
 1e4:	5b                   	pop    %ebx
 1e5:	5d                   	pop    %ebp
 1e6:	c3                   	ret    
 1e7:	89 f6                	mov    %esi,%esi
 1e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001f0 <strlen>:

uint
strlen(char *s)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1f6:	80 39 00             	cmpb   $0x0,(%ecx)
 1f9:	74 15                	je     210 <strlen+0x20>
 1fb:	31 d2                	xor    %edx,%edx
 1fd:	8d 76 00             	lea    0x0(%esi),%esi
 200:	83 c2 01             	add    $0x1,%edx
 203:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 207:	89 d0                	mov    %edx,%eax
 209:	75 f5                	jne    200 <strlen+0x10>
    ;
  return n;
}
 20b:	5d                   	pop    %ebp
 20c:	c3                   	ret    
 20d:	8d 76 00             	lea    0x0(%esi),%esi
  for(n = 0; s[n]; n++)
 210:	31 c0                	xor    %eax,%eax
}
 212:	5d                   	pop    %ebp
 213:	c3                   	ret    
 214:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 21a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000220 <memset>:

void*
memset(void *dst, int c, uint n)
{
 220:	55                   	push   %ebp
 221:	89 e5                	mov    %esp,%ebp
 223:	57                   	push   %edi
 224:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 227:	8b 4d 10             	mov    0x10(%ebp),%ecx
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	89 d7                	mov    %edx,%edi
 22f:	fc                   	cld    
 230:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 232:	89 d0                	mov    %edx,%eax
 234:	5f                   	pop    %edi
 235:	5d                   	pop    %ebp
 236:	c3                   	ret    
 237:	89 f6                	mov    %esi,%esi
 239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000240 <strchr>:

char*
strchr(const char *s, char c)
{
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	53                   	push   %ebx
 244:	8b 45 08             	mov    0x8(%ebp),%eax
 247:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for(; *s; s++)
 24a:	0f b6 10             	movzbl (%eax),%edx
 24d:	84 d2                	test   %dl,%dl
 24f:	74 1d                	je     26e <strchr+0x2e>
    if(*s == c)
 251:	38 d3                	cmp    %dl,%bl
 253:	89 d9                	mov    %ebx,%ecx
 255:	75 0d                	jne    264 <strchr+0x24>
 257:	eb 17                	jmp    270 <strchr+0x30>
 259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 260:	38 ca                	cmp    %cl,%dl
 262:	74 0c                	je     270 <strchr+0x30>
  for(; *s; s++)
 264:	83 c0 01             	add    $0x1,%eax
 267:	0f b6 10             	movzbl (%eax),%edx
 26a:	84 d2                	test   %dl,%dl
 26c:	75 f2                	jne    260 <strchr+0x20>
      return (char*)s;
  return 0;
 26e:	31 c0                	xor    %eax,%eax
}
 270:	5b                   	pop    %ebx
 271:	5d                   	pop    %ebp
 272:	c3                   	ret    
 273:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000280 <gets>:

char*
gets(char *buf, int max)
{
 280:	55                   	push   %ebp
 281:	89 e5                	mov    %esp,%ebp
 283:	57                   	push   %edi
 284:	56                   	push   %esi
 285:	53                   	push   %ebx
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 286:	31 f6                	xor    %esi,%esi
 288:	89 f3                	mov    %esi,%ebx
{
 28a:	83 ec 1c             	sub    $0x1c,%esp
 28d:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 290:	eb 2f                	jmp    2c1 <gets+0x41>
 292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 298:	8d 45 e7             	lea    -0x19(%ebp),%eax
 29b:	83 ec 04             	sub    $0x4,%esp
 29e:	6a 01                	push   $0x1
 2a0:	50                   	push   %eax
 2a1:	6a 00                	push   $0x0
 2a3:	e8 32 01 00 00       	call   3da <read>
    if(cc < 1)
 2a8:	83 c4 10             	add    $0x10,%esp
 2ab:	85 c0                	test   %eax,%eax
 2ad:	7e 1c                	jle    2cb <gets+0x4b>
      break;
    buf[i++] = c;
 2af:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2b3:	83 c7 01             	add    $0x1,%edi
 2b6:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 2b9:	3c 0a                	cmp    $0xa,%al
 2bb:	74 23                	je     2e0 <gets+0x60>
 2bd:	3c 0d                	cmp    $0xd,%al
 2bf:	74 1f                	je     2e0 <gets+0x60>
  for(i=0; i+1 < max; ){
 2c1:	83 c3 01             	add    $0x1,%ebx
 2c4:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 2c7:	89 fe                	mov    %edi,%esi
 2c9:	7c cd                	jl     298 <gets+0x18>
 2cb:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 2cd:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 2d0:	c6 03 00             	movb   $0x0,(%ebx)
}
 2d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2d6:	5b                   	pop    %ebx
 2d7:	5e                   	pop    %esi
 2d8:	5f                   	pop    %edi
 2d9:	5d                   	pop    %ebp
 2da:	c3                   	ret    
 2db:	90                   	nop
 2dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2e0:	8b 75 08             	mov    0x8(%ebp),%esi
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	01 de                	add    %ebx,%esi
 2e8:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 2ea:	c6 03 00             	movb   $0x0,(%ebx)
}
 2ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2f0:	5b                   	pop    %ebx
 2f1:	5e                   	pop    %esi
 2f2:	5f                   	pop    %edi
 2f3:	5d                   	pop    %ebp
 2f4:	c3                   	ret    
 2f5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000300 <stat>:

int
stat(char *n, struct stat *st)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	56                   	push   %esi
 304:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 305:	83 ec 08             	sub    $0x8,%esp
 308:	6a 00                	push   $0x0
 30a:	ff 75 08             	pushl  0x8(%ebp)
 30d:	e8 f0 00 00 00       	call   402 <open>
  if(fd < 0)
 312:	83 c4 10             	add    $0x10,%esp
 315:	85 c0                	test   %eax,%eax
 317:	78 27                	js     340 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 319:	83 ec 08             	sub    $0x8,%esp
 31c:	ff 75 0c             	pushl  0xc(%ebp)
 31f:	89 c3                	mov    %eax,%ebx
 321:	50                   	push   %eax
 322:	e8 f3 00 00 00       	call   41a <fstat>
  close(fd);
 327:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 32a:	89 c6                	mov    %eax,%esi
  close(fd);
 32c:	e8 b9 00 00 00       	call   3ea <close>
  return r;
 331:	83 c4 10             	add    $0x10,%esp
}
 334:	8d 65 f8             	lea    -0x8(%ebp),%esp
 337:	89 f0                	mov    %esi,%eax
 339:	5b                   	pop    %ebx
 33a:	5e                   	pop    %esi
 33b:	5d                   	pop    %ebp
 33c:	c3                   	ret    
 33d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 340:	be ff ff ff ff       	mov    $0xffffffff,%esi
 345:	eb ed                	jmp    334 <stat+0x34>
 347:	89 f6                	mov    %esi,%esi
 349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000350 <atoi>:

int
atoi(const char *s)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	53                   	push   %ebx
 354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 357:	0f be 11             	movsbl (%ecx),%edx
 35a:	8d 42 d0             	lea    -0x30(%edx),%eax
 35d:	3c 09                	cmp    $0x9,%al
  n = 0;
 35f:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 364:	77 1f                	ja     385 <atoi+0x35>
 366:	8d 76 00             	lea    0x0(%esi),%esi
 369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    n = n*10 + *s++ - '0';
 370:	8d 04 80             	lea    (%eax,%eax,4),%eax
 373:	83 c1 01             	add    $0x1,%ecx
 376:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
  while('0' <= *s && *s <= '9')
 37a:	0f be 11             	movsbl (%ecx),%edx
 37d:	8d 5a d0             	lea    -0x30(%edx),%ebx
 380:	80 fb 09             	cmp    $0x9,%bl
 383:	76 eb                	jbe    370 <atoi+0x20>
  return n;
}
 385:	5b                   	pop    %ebx
 386:	5d                   	pop    %ebp
 387:	c3                   	ret    
 388:	90                   	nop
 389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000390 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 390:	55                   	push   %ebp
 391:	89 e5                	mov    %esp,%ebp
 393:	56                   	push   %esi
 394:	53                   	push   %ebx
 395:	8b 5d 10             	mov    0x10(%ebp),%ebx
 398:	8b 45 08             	mov    0x8(%ebp),%eax
 39b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 39e:	85 db                	test   %ebx,%ebx
 3a0:	7e 14                	jle    3b6 <memmove+0x26>
 3a2:	31 d2                	xor    %edx,%edx
 3a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *dst++ = *src++;
 3a8:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 3ac:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 3af:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0)
 3b2:	39 d3                	cmp    %edx,%ebx
 3b4:	75 f2                	jne    3a8 <memmove+0x18>
  return vdst;
}
 3b6:	5b                   	pop    %ebx
 3b7:	5e                   	pop    %esi
 3b8:	5d                   	pop    %ebp
 3b9:	c3                   	ret    

000003ba <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3ba:	b8 01 00 00 00       	mov    $0x1,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <exit>:
SYSCALL(exit)
 3c2:	b8 02 00 00 00       	mov    $0x2,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <wait>:
SYSCALL(wait)
 3ca:	b8 03 00 00 00       	mov    $0x3,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <pipe>:
SYSCALL(pipe)
 3d2:	b8 04 00 00 00       	mov    $0x4,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <read>:
SYSCALL(read)
 3da:	b8 05 00 00 00       	mov    $0x5,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <write>:
SYSCALL(write)
 3e2:	b8 10 00 00 00       	mov    $0x10,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <close>:
SYSCALL(close)
 3ea:	b8 15 00 00 00       	mov    $0x15,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <kill>:
SYSCALL(kill)
 3f2:	b8 06 00 00 00       	mov    $0x6,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <exec>:
SYSCALL(exec)
 3fa:	b8 07 00 00 00       	mov    $0x7,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <open>:
SYSCALL(open)
 402:	b8 0f 00 00 00       	mov    $0xf,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <mknod>:
SYSCALL(mknod)
 40a:	b8 11 00 00 00       	mov    $0x11,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <unlink>:
SYSCALL(unlink)
 412:	b8 12 00 00 00       	mov    $0x12,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <fstat>:
SYSCALL(fstat)
 41a:	b8 08 00 00 00       	mov    $0x8,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <link>:
SYSCALL(link)
 422:	b8 13 00 00 00       	mov    $0x13,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <mkdir>:
SYSCALL(mkdir)
 42a:	b8 14 00 00 00       	mov    $0x14,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <chdir>:
SYSCALL(chdir)
 432:	b8 09 00 00 00       	mov    $0x9,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <dup>:
SYSCALL(dup)
 43a:	b8 0a 00 00 00       	mov    $0xa,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <getpid>:
SYSCALL(getpid)
 442:	b8 0b 00 00 00       	mov    $0xb,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <getcpuid>:
SYSCALL(getcpuid)
 44a:	b8 16 00 00 00       	mov    $0x16,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <sbrk>:
SYSCALL(sbrk)
 452:	b8 0c 00 00 00       	mov    $0xc,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <sleep>:
SYSCALL(sleep)
 45a:	b8 0d 00 00 00       	mov    $0xd,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <uptime>:
SYSCALL(uptime)
 462:	b8 0e 00 00 00       	mov    $0xe,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <myalloc>:
SYSCALL(myalloc)
 46a:	b8 17 00 00 00       	mov    $0x17,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <myfree>:
SYSCALL(myfree)
 472:	b8 18 00 00 00       	mov    $0x18,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <clone>:
SYSCALL(clone)
 47a:	b8 19 00 00 00       	mov    $0x19,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <join>:
SYSCALL(join)
 482:	b8 1a 00 00 00       	mov    $0x1a,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <cps>:
SYSCALL(cps);
 48a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <chpri>:
SYSCALL(chpri);
 492:	b8 1b 00 00 00       	mov    $0x1b,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    
 49a:	66 90                	xchg   %ax,%ax
 49c:	66 90                	xchg   %ax,%ax
 49e:	66 90                	xchg   %ax,%ax

000004a0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4a0:	55                   	push   %ebp
 4a1:	89 e5                	mov    %esp,%ebp
 4a3:	57                   	push   %edi
 4a4:	56                   	push   %esi
 4a5:	53                   	push   %ebx
 4a6:	83 ec 3c             	sub    $0x3c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4a9:	85 d2                	test   %edx,%edx
{
 4ab:	89 45 c0             	mov    %eax,-0x40(%ebp)
    neg = 1;
    x = -xx;
 4ae:	89 d0                	mov    %edx,%eax
  if(sgn && xx < 0){
 4b0:	79 76                	jns    528 <printint+0x88>
 4b2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 4b6:	74 70                	je     528 <printint+0x88>
    x = -xx;
 4b8:	f7 d8                	neg    %eax
    neg = 1;
 4ba:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4c1:	31 f6                	xor    %esi,%esi
 4c3:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 4c6:	eb 0a                	jmp    4d2 <printint+0x32>
 4c8:	90                   	nop
 4c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  do{
    buf[i++] = digits[x % base];
 4d0:	89 fe                	mov    %edi,%esi
 4d2:	31 d2                	xor    %edx,%edx
 4d4:	8d 7e 01             	lea    0x1(%esi),%edi
 4d7:	f7 f1                	div    %ecx
 4d9:	0f b6 92 28 0b 00 00 	movzbl 0xb28(%edx),%edx
  }while((x /= base) != 0);
 4e0:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
 4e2:	88 14 3b             	mov    %dl,(%ebx,%edi,1)
  }while((x /= base) != 0);
 4e5:	75 e9                	jne    4d0 <printint+0x30>
  if(neg)
 4e7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 4ea:	85 c0                	test   %eax,%eax
 4ec:	74 08                	je     4f6 <printint+0x56>
    buf[i++] = '-';
 4ee:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
 4f3:	8d 7e 02             	lea    0x2(%esi),%edi
 4f6:	8d 74 3d d7          	lea    -0x29(%ebp,%edi,1),%esi
 4fa:	8b 7d c0             	mov    -0x40(%ebp),%edi
 4fd:	8d 76 00             	lea    0x0(%esi),%esi
 500:	0f b6 06             	movzbl (%esi),%eax
  write(fd, &c, 1);
 503:	83 ec 04             	sub    $0x4,%esp
 506:	83 ee 01             	sub    $0x1,%esi
 509:	6a 01                	push   $0x1
 50b:	53                   	push   %ebx
 50c:	57                   	push   %edi
 50d:	88 45 d7             	mov    %al,-0x29(%ebp)
 510:	e8 cd fe ff ff       	call   3e2 <write>

  while(--i >= 0)
 515:	83 c4 10             	add    $0x10,%esp
 518:	39 de                	cmp    %ebx,%esi
 51a:	75 e4                	jne    500 <printint+0x60>
    putc(fd, buf[i]);
}
 51c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 51f:	5b                   	pop    %ebx
 520:	5e                   	pop    %esi
 521:	5f                   	pop    %edi
 522:	5d                   	pop    %ebp
 523:	c3                   	ret    
 524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 528:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 52f:	eb 90                	jmp    4c1 <printint+0x21>
 531:	eb 0d                	jmp    540 <printf>
 533:	90                   	nop
 534:	90                   	nop
 535:	90                   	nop
 536:	90                   	nop
 537:	90                   	nop
 538:	90                   	nop
 539:	90                   	nop
 53a:	90                   	nop
 53b:	90                   	nop
 53c:	90                   	nop
 53d:	90                   	nop
 53e:	90                   	nop
 53f:	90                   	nop

00000540 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 540:	55                   	push   %ebp
 541:	89 e5                	mov    %esp,%ebp
 543:	57                   	push   %edi
 544:	56                   	push   %esi
 545:	53                   	push   %ebx
 546:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 549:	8b 75 0c             	mov    0xc(%ebp),%esi
 54c:	0f b6 1e             	movzbl (%esi),%ebx
 54f:	84 db                	test   %bl,%bl
 551:	0f 84 b3 00 00 00    	je     60a <printf+0xca>
  ap = (uint*)(void*)&fmt + 1;
 557:	8d 45 10             	lea    0x10(%ebp),%eax
 55a:	83 c6 01             	add    $0x1,%esi
  state = 0;
 55d:	31 ff                	xor    %edi,%edi
  ap = (uint*)(void*)&fmt + 1;
 55f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 562:	eb 2f                	jmp    593 <printf+0x53>
 564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 568:	83 f8 25             	cmp    $0x25,%eax
 56b:	0f 84 a7 00 00 00    	je     618 <printf+0xd8>
  write(fd, &c, 1);
 571:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 574:	83 ec 04             	sub    $0x4,%esp
 577:	88 5d e2             	mov    %bl,-0x1e(%ebp)
 57a:	6a 01                	push   $0x1
 57c:	50                   	push   %eax
 57d:	ff 75 08             	pushl  0x8(%ebp)
 580:	e8 5d fe ff ff       	call   3e2 <write>
 585:	83 c4 10             	add    $0x10,%esp
 588:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 58b:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 58f:	84 db                	test   %bl,%bl
 591:	74 77                	je     60a <printf+0xca>
    if(state == 0){
 593:	85 ff                	test   %edi,%edi
    c = fmt[i] & 0xff;
 595:	0f be cb             	movsbl %bl,%ecx
 598:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 59b:	74 cb                	je     568 <printf+0x28>
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 59d:	83 ff 25             	cmp    $0x25,%edi
 5a0:	75 e6                	jne    588 <printf+0x48>
      if(c == 'd'){
 5a2:	83 f8 64             	cmp    $0x64,%eax
 5a5:	0f 84 05 01 00 00    	je     6b0 <printf+0x170>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 5ab:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 5b1:	83 f9 70             	cmp    $0x70,%ecx
 5b4:	74 72                	je     628 <printf+0xe8>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 5b6:	83 f8 73             	cmp    $0x73,%eax
 5b9:	0f 84 99 00 00 00    	je     658 <printf+0x118>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5bf:	83 f8 63             	cmp    $0x63,%eax
 5c2:	0f 84 08 01 00 00    	je     6d0 <printf+0x190>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 5c8:	83 f8 25             	cmp    $0x25,%eax
 5cb:	0f 84 ef 00 00 00    	je     6c0 <printf+0x180>
  write(fd, &c, 1);
 5d1:	8d 45 e7             	lea    -0x19(%ebp),%eax
 5d4:	83 ec 04             	sub    $0x4,%esp
 5d7:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 5db:	6a 01                	push   $0x1
 5dd:	50                   	push   %eax
 5de:	ff 75 08             	pushl  0x8(%ebp)
 5e1:	e8 fc fd ff ff       	call   3e2 <write>
 5e6:	83 c4 0c             	add    $0xc,%esp
 5e9:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 5ec:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 5ef:	6a 01                	push   $0x1
 5f1:	50                   	push   %eax
 5f2:	ff 75 08             	pushl  0x8(%ebp)
 5f5:	83 c6 01             	add    $0x1,%esi
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5f8:	31 ff                	xor    %edi,%edi
  write(fd, &c, 1);
 5fa:	e8 e3 fd ff ff       	call   3e2 <write>
  for(i = 0; fmt[i]; i++){
 5ff:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
  write(fd, &c, 1);
 603:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 606:	84 db                	test   %bl,%bl
 608:	75 89                	jne    593 <printf+0x53>
    }
  }
}
 60a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 60d:	5b                   	pop    %ebx
 60e:	5e                   	pop    %esi
 60f:	5f                   	pop    %edi
 610:	5d                   	pop    %ebp
 611:	c3                   	ret    
 612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        state = '%';
 618:	bf 25 00 00 00       	mov    $0x25,%edi
 61d:	e9 66 ff ff ff       	jmp    588 <printf+0x48>
 622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printint(fd, *ap, 16, 0);
 628:	83 ec 0c             	sub    $0xc,%esp
 62b:	b9 10 00 00 00       	mov    $0x10,%ecx
 630:	6a 00                	push   $0x0
 632:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 635:	8b 45 08             	mov    0x8(%ebp),%eax
 638:	8b 17                	mov    (%edi),%edx
 63a:	e8 61 fe ff ff       	call   4a0 <printint>
        ap++;
 63f:	89 f8                	mov    %edi,%eax
 641:	83 c4 10             	add    $0x10,%esp
      state = 0;
 644:	31 ff                	xor    %edi,%edi
        ap++;
 646:	83 c0 04             	add    $0x4,%eax
 649:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 64c:	e9 37 ff ff ff       	jmp    588 <printf+0x48>
 651:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = (char*)*ap;
 658:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 65b:	8b 08                	mov    (%eax),%ecx
        ap++;
 65d:	83 c0 04             	add    $0x4,%eax
 660:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(s == 0)
 663:	85 c9                	test   %ecx,%ecx
 665:	0f 84 8e 00 00 00    	je     6f9 <printf+0x1b9>
        while(*s != 0){
 66b:	0f b6 01             	movzbl (%ecx),%eax
      state = 0;
 66e:	31 ff                	xor    %edi,%edi
        s = (char*)*ap;
 670:	89 cb                	mov    %ecx,%ebx
        while(*s != 0){
 672:	84 c0                	test   %al,%al
 674:	0f 84 0e ff ff ff    	je     588 <printf+0x48>
 67a:	89 75 d0             	mov    %esi,-0x30(%ebp)
 67d:	89 de                	mov    %ebx,%esi
 67f:	8b 5d 08             	mov    0x8(%ebp),%ebx
 682:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 685:	8d 76 00             	lea    0x0(%esi),%esi
  write(fd, &c, 1);
 688:	83 ec 04             	sub    $0x4,%esp
          s++;
 68b:	83 c6 01             	add    $0x1,%esi
 68e:	88 45 e3             	mov    %al,-0x1d(%ebp)
  write(fd, &c, 1);
 691:	6a 01                	push   $0x1
 693:	57                   	push   %edi
 694:	53                   	push   %ebx
 695:	e8 48 fd ff ff       	call   3e2 <write>
        while(*s != 0){
 69a:	0f b6 06             	movzbl (%esi),%eax
 69d:	83 c4 10             	add    $0x10,%esp
 6a0:	84 c0                	test   %al,%al
 6a2:	75 e4                	jne    688 <printf+0x148>
 6a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 6a7:	31 ff                	xor    %edi,%edi
 6a9:	e9 da fe ff ff       	jmp    588 <printf+0x48>
 6ae:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 10, 1);
 6b0:	83 ec 0c             	sub    $0xc,%esp
 6b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
 6b8:	6a 01                	push   $0x1
 6ba:	e9 73 ff ff ff       	jmp    632 <printf+0xf2>
 6bf:	90                   	nop
  write(fd, &c, 1);
 6c0:	83 ec 04             	sub    $0x4,%esp
 6c3:	88 5d e5             	mov    %bl,-0x1b(%ebp)
 6c6:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 6c9:	6a 01                	push   $0x1
 6cb:	e9 21 ff ff ff       	jmp    5f1 <printf+0xb1>
        putc(fd, *ap);
 6d0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  write(fd, &c, 1);
 6d3:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 6d6:	8b 07                	mov    (%edi),%eax
  write(fd, &c, 1);
 6d8:	6a 01                	push   $0x1
        ap++;
 6da:	83 c7 04             	add    $0x4,%edi
        putc(fd, *ap);
 6dd:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 6e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 6e3:	50                   	push   %eax
 6e4:	ff 75 08             	pushl  0x8(%ebp)
 6e7:	e8 f6 fc ff ff       	call   3e2 <write>
        ap++;
 6ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 6ef:	83 c4 10             	add    $0x10,%esp
      state = 0;
 6f2:	31 ff                	xor    %edi,%edi
 6f4:	e9 8f fe ff ff       	jmp    588 <printf+0x48>
          s = "(null)";
 6f9:	bb 20 0b 00 00       	mov    $0xb20,%ebx
        while(*s != 0){
 6fe:	b8 28 00 00 00       	mov    $0x28,%eax
 703:	e9 72 ff ff ff       	jmp    67a <printf+0x13a>
 708:	66 90                	xchg   %ax,%ax
 70a:	66 90                	xchg   %ax,%ax
 70c:	66 90                	xchg   %ax,%ax
 70e:	66 90                	xchg   %ax,%ax

00000710 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 710:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 711:	a1 e0 0e 00 00       	mov    0xee0,%eax
{
 716:	89 e5                	mov    %esp,%ebp
 718:	57                   	push   %edi
 719:	56                   	push   %esi
 71a:	53                   	push   %ebx
 71b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 71e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
 721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 728:	39 c8                	cmp    %ecx,%eax
 72a:	8b 10                	mov    (%eax),%edx
 72c:	73 32                	jae    760 <free+0x50>
 72e:	39 d1                	cmp    %edx,%ecx
 730:	72 04                	jb     736 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 732:	39 d0                	cmp    %edx,%eax
 734:	72 32                	jb     768 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 736:	8b 73 fc             	mov    -0x4(%ebx),%esi
 739:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 73c:	39 fa                	cmp    %edi,%edx
 73e:	74 30                	je     770 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 740:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 743:	8b 50 04             	mov    0x4(%eax),%edx
 746:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 749:	39 f1                	cmp    %esi,%ecx
 74b:	74 3a                	je     787 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 74d:	89 08                	mov    %ecx,(%eax)
  freep = p;
 74f:	a3 e0 0e 00 00       	mov    %eax,0xee0
}
 754:	5b                   	pop    %ebx
 755:	5e                   	pop    %esi
 756:	5f                   	pop    %edi
 757:	5d                   	pop    %ebp
 758:	c3                   	ret    
 759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 760:	39 d0                	cmp    %edx,%eax
 762:	72 04                	jb     768 <free+0x58>
 764:	39 d1                	cmp    %edx,%ecx
 766:	72 ce                	jb     736 <free+0x26>
{
 768:	89 d0                	mov    %edx,%eax
 76a:	eb bc                	jmp    728 <free+0x18>
 76c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 770:	03 72 04             	add    0x4(%edx),%esi
 773:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 776:	8b 10                	mov    (%eax),%edx
 778:	8b 12                	mov    (%edx),%edx
 77a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 77d:	8b 50 04             	mov    0x4(%eax),%edx
 780:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 783:	39 f1                	cmp    %esi,%ecx
 785:	75 c6                	jne    74d <free+0x3d>
    p->s.size += bp->s.size;
 787:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 78a:	a3 e0 0e 00 00       	mov    %eax,0xee0
    p->s.size += bp->s.size;
 78f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 792:	8b 53 f8             	mov    -0x8(%ebx),%edx
 795:	89 10                	mov    %edx,(%eax)
}
 797:	5b                   	pop    %ebx
 798:	5e                   	pop    %esi
 799:	5f                   	pop    %edi
 79a:	5d                   	pop    %ebp
 79b:	c3                   	ret    
 79c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000007a0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a0:	55                   	push   %ebp
 7a1:	89 e5                	mov    %esp,%ebp
 7a3:	57                   	push   %edi
 7a4:	56                   	push   %esi
 7a5:	53                   	push   %ebx
 7a6:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a9:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 7ac:	8b 15 e0 0e 00 00    	mov    0xee0,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b2:	8d 78 07             	lea    0x7(%eax),%edi
 7b5:	c1 ef 03             	shr    $0x3,%edi
 7b8:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 7bb:	85 d2                	test   %edx,%edx
 7bd:	0f 84 9d 00 00 00    	je     860 <malloc+0xc0>
 7c3:	8b 02                	mov    (%edx),%eax
 7c5:	8b 48 04             	mov    0x4(%eax),%ecx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 7c8:	39 cf                	cmp    %ecx,%edi
 7ca:	76 6c                	jbe    838 <malloc+0x98>
 7cc:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
 7d2:	bb 00 10 00 00       	mov    $0x1000,%ebx
 7d7:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 7da:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 7e1:	eb 0e                	jmp    7f1 <malloc+0x51>
 7e3:	90                   	nop
 7e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e8:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 7ea:	8b 48 04             	mov    0x4(%eax),%ecx
 7ed:	39 f9                	cmp    %edi,%ecx
 7ef:	73 47                	jae    838 <malloc+0x98>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f1:	39 05 e0 0e 00 00    	cmp    %eax,0xee0
 7f7:	89 c2                	mov    %eax,%edx
 7f9:	75 ed                	jne    7e8 <malloc+0x48>
  p = sbrk(nu * sizeof(Header));
 7fb:	83 ec 0c             	sub    $0xc,%esp
 7fe:	56                   	push   %esi
 7ff:	e8 4e fc ff ff       	call   452 <sbrk>
  if(p == (char*)-1)
 804:	83 c4 10             	add    $0x10,%esp
 807:	83 f8 ff             	cmp    $0xffffffff,%eax
 80a:	74 1c                	je     828 <malloc+0x88>
  hp->s.size = nu;
 80c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 80f:	83 ec 0c             	sub    $0xc,%esp
 812:	83 c0 08             	add    $0x8,%eax
 815:	50                   	push   %eax
 816:	e8 f5 fe ff ff       	call   710 <free>
  return freep;
 81b:	8b 15 e0 0e 00 00    	mov    0xee0,%edx
      if((p = morecore(nunits)) == 0)
 821:	83 c4 10             	add    $0x10,%esp
 824:	85 d2                	test   %edx,%edx
 826:	75 c0                	jne    7e8 <malloc+0x48>
        return 0;
  }
}
 828:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 82b:	31 c0                	xor    %eax,%eax
}
 82d:	5b                   	pop    %ebx
 82e:	5e                   	pop    %esi
 82f:	5f                   	pop    %edi
 830:	5d                   	pop    %ebp
 831:	c3                   	ret    
 832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 838:	39 cf                	cmp    %ecx,%edi
 83a:	74 54                	je     890 <malloc+0xf0>
        p->s.size -= nunits;
 83c:	29 f9                	sub    %edi,%ecx
 83e:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 841:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 844:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 847:	89 15 e0 0e 00 00    	mov    %edx,0xee0
}
 84d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 850:	83 c0 08             	add    $0x8,%eax
}
 853:	5b                   	pop    %ebx
 854:	5e                   	pop    %esi
 855:	5f                   	pop    %edi
 856:	5d                   	pop    %ebp
 857:	c3                   	ret    
 858:	90                   	nop
 859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    base.s.ptr = freep = prevp = &base;
 860:	c7 05 e0 0e 00 00 e4 	movl   $0xee4,0xee0
 867:	0e 00 00 
 86a:	c7 05 e4 0e 00 00 e4 	movl   $0xee4,0xee4
 871:	0e 00 00 
    base.s.size = 0;
 874:	b8 e4 0e 00 00       	mov    $0xee4,%eax
 879:	c7 05 e8 0e 00 00 00 	movl   $0x0,0xee8
 880:	00 00 00 
 883:	e9 44 ff ff ff       	jmp    7cc <malloc+0x2c>
 888:	90                   	nop
 889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        prevp->s.ptr = p->s.ptr;
 890:	8b 08                	mov    (%eax),%ecx
 892:	89 0a                	mov    %ecx,(%edx)
 894:	eb b1                	jmp    847 <malloc+0xa7>
 896:	66 90                	xchg   %ax,%ax
 898:	66 90                	xchg   %ax,%ax
 89a:	66 90                	xchg   %ax,%ax
 89c:	66 90                	xchg   %ax,%ax
 89e:	66 90                	xchg   %ax,%ax

000008a0 <add_thread>:
	void *ustack;
	int used;
}threads[NTHREAD]; //TCB表

//add a TCB to thread table
void add_thread(int *pid,void *ustack){
 8a0:	ba 00 0f 00 00       	mov    $0xf00,%edx
	int i;
	for(i=0;i<NTHREAD;i++){
 8a5:	31 c0                	xor    %eax,%eax
		if(threads[i].used==0){
 8a7:	8b 4a 08             	mov    0x8(%edx),%ecx
 8aa:	85 c9                	test   %ecx,%ecx
 8ac:	74 12                	je     8c0 <add_thread+0x20>
	for(i=0;i<NTHREAD;i++){
 8ae:	83 c0 01             	add    $0x1,%eax
 8b1:	83 c2 0c             	add    $0xc,%edx
 8b4:	83 f8 04             	cmp    $0x4,%eax
 8b7:	75 ee                	jne    8a7 <add_thread+0x7>
 8b9:	f3 c3                	repz ret 
 8bb:	90                   	nop
 8bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void add_thread(int *pid,void *ustack){
 8c0:	55                   	push   %ebp
			threads[i].pid=*pid;
 8c1:	8d 04 40             	lea    (%eax,%eax,2),%eax
void add_thread(int *pid,void *ustack){
 8c4:	89 e5                	mov    %esp,%ebp
			threads[i].pid=*pid;
 8c6:	c1 e0 02             	shl    $0x2,%eax
 8c9:	8b 55 08             	mov    0x8(%ebp),%edx
 8cc:	8b 0a                	mov    (%edx),%ecx
 8ce:	8d 90 00 0f 00 00    	lea    0xf00(%eax),%edx
			threads[i].ustack=ustack;
			threads[i].used=1;
 8d4:	c7 42 08 01 00 00 00 	movl   $0x1,0x8(%edx)
			threads[i].pid=*pid;
 8db:	89 88 00 0f 00 00    	mov    %ecx,0xf00(%eax)
			threads[i].ustack=ustack;
 8e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 8e4:	89 42 04             	mov    %eax,0x4(%edx)
			break;
		}
	}
}
 8e7:	5d                   	pop    %ebp
 8e8:	c3                   	ret    
 8e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

000008f0 <remove_thread>:

void remove_thread(int *pid)
{
 8f0:	55                   	push   %ebp
 8f1:	b8 00 0f 00 00       	mov    $0xf00,%eax
    int i;
	for(i=0;i<NTHREAD;i++){
 8f6:	31 d2                	xor    %edx,%edx
{
 8f8:	89 e5                	mov    %esp,%ebp
 8fa:	56                   	push   %esi
 8fb:	53                   	push   %ebx
 8fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
    	if(threads[i].used && threads[i].pid==*pid)
 8ff:	8b 58 08             	mov    0x8(%eax),%ebx
 902:	85 db                	test   %ebx,%ebx
 904:	74 06                	je     90c <remove_thread+0x1c>
 906:	8b 31                	mov    (%ecx),%esi
 908:	39 30                	cmp    %esi,(%eax)
 90a:	74 14                	je     920 <remove_thread+0x30>
	for(i=0;i<NTHREAD;i++){
 90c:	83 c2 01             	add    $0x1,%edx
 90f:	83 c0 0c             	add    $0xc,%eax
 912:	83 fa 04             	cmp    $0x4,%edx
 915:	75 e8                	jne    8ff <remove_thread+0xf>
    		threads[i].ustack=0;
    		threads[i].used=0;
    		break;
    	}
    }
}
 917:	8d 65 f8             	lea    -0x8(%ebp),%esp
 91a:	5b                   	pop    %ebx
 91b:	5e                   	pop    %esi
 91c:	5d                   	pop    %ebp
 91d:	c3                   	ret    
 91e:	66 90                	xchg   %ax,%ax
    		free(threads[i].ustack); //释放用户栈
 920:	8d 1c 52             	lea    (%edx,%edx,2),%ebx
 923:	83 ec 0c             	sub    $0xc,%esp
 926:	c1 e3 02             	shl    $0x2,%ebx
 929:	ff b3 04 0f 00 00    	pushl  0xf04(%ebx)
 92f:	e8 dc fd ff ff       	call   710 <free>
    		threads[i].pid=0;
 934:	c7 83 00 0f 00 00 00 	movl   $0x0,0xf00(%ebx)
 93b:	00 00 00 
    		threads[i].ustack=0;
 93e:	c7 83 04 0f 00 00 00 	movl   $0x0,0xf04(%ebx)
 945:	00 00 00 
    		break;
 948:	83 c4 10             	add    $0x10,%esp
    		threads[i].used=0;
 94b:	c7 83 08 0f 00 00 00 	movl   $0x0,0xf08(%ebx)
 952:	00 00 00 
}
 955:	8d 65 f8             	lea    -0x8(%ebp),%esp
 958:	5b                   	pop    %ebx
 959:	5e                   	pop    %esi
 95a:	5d                   	pop    %ebp
 95b:	c3                   	ret    
 95c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000960 <thread_create>:

int thread_create(void(*start_routine)(void*),void* arg){
 960:	55                   	push   %ebp
 961:	89 e5                	mov    %esp,%ebp
 963:	53                   	push   %ebx
 964:	83 ec 04             	sub    $0x4,%esp
	//if first time running any threads,initialize thread table with zeros
	static int first=1;
	if(first){
 967:	a1 d0 0e 00 00       	mov    0xed0,%eax
 96c:	85 c0                	test   %eax,%eax
 96e:	74 2d                	je     99d <thread_create+0x3d>
		first=0;
 970:	c7 05 d0 0e 00 00 00 	movl   $0x0,0xed0
 977:	00 00 00 
 97a:	b8 00 0f 00 00       	mov    $0xf00,%eax
		int i;
		for(i=0;i<NTHREAD;i++){
			threads[i].pid=0;
 97f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			threads[i].ustack=0;
 985:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
 98c:	83 c0 0c             	add    $0xc,%eax
			threads[i].used=0;
 98f:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
		for(i=0;i<NTHREAD;i++){
 996:	3d 30 0f 00 00       	cmp    $0xf30,%eax
 99b:	75 e2                	jne    97f <thread_create+0x1f>
		}
	}
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 99d:	83 ec 0c             	sub    $0xc,%esp
 9a0:	68 00 10 00 00       	push   $0x1000
 9a5:	e8 f6 fd ff ff       	call   7a0 <malloc>
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 9aa:	83 c4 0c             	add    $0xc,%esp
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 9ad:	89 c3                	mov    %eax,%ebx
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 9af:	50                   	push   %eax
 9b0:	ff 75 0c             	pushl  0xc(%ebp)
 9b3:	ff 75 08             	pushl  0x8(%ebp)
 9b6:	e8 bf fa ff ff       	call   47a <clone>
 9bb:	b9 00 0f 00 00       	mov    $0xf00,%ecx
 9c0:	83 c4 10             	add    $0x10,%esp
	for(i=0;i<NTHREAD;i++){
 9c3:	31 d2                	xor    %edx,%edx
		if(threads[i].used==0){
 9c5:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
 9c9:	74 15                	je     9e0 <thread_create+0x80>
	for(i=0;i<NTHREAD;i++){
 9cb:	83 c2 01             	add    $0x1,%edx
 9ce:	83 c1 0c             	add    $0xc,%ecx
 9d1:	83 fa 04             	cmp    $0x4,%edx
 9d4:	75 ef                	jne    9c5 <thread_create+0x65>
	add_thread(&pid,stack);//save new thread to thread table
	return pid;
}
 9d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 9d9:	c9                   	leave  
 9da:	c3                   	ret    
 9db:	90                   	nop
 9dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			threads[i].pid=*pid;
 9e0:	8d 14 52             	lea    (%edx,%edx,2),%edx
 9e3:	c1 e2 02             	shl    $0x2,%edx
			threads[i].ustack=ustack;
 9e6:	89 9a 04 0f 00 00    	mov    %ebx,0xf04(%edx)
			threads[i].pid=*pid;
 9ec:	89 82 00 0f 00 00    	mov    %eax,0xf00(%edx)
			threads[i].used=1;
 9f2:	c7 82 08 0f 00 00 01 	movl   $0x1,0xf08(%edx)
 9f9:	00 00 00 
}
 9fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 9ff:	c9                   	leave  
 a00:	c3                   	ret    
 a01:	eb 0d                	jmp    a10 <thread_join>
 a03:	90                   	nop
 a04:	90                   	nop
 a05:	90                   	nop
 a06:	90                   	nop
 a07:	90                   	nop
 a08:	90                   	nop
 a09:	90                   	nop
 a0a:	90                   	nop
 a0b:	90                   	nop
 a0c:	90                   	nop
 a0d:	90                   	nop
 a0e:	90                   	nop
 a0f:	90                   	nop

00000a10 <thread_join>:

int thread_join(void){
 a10:	55                   	push   %ebp
 a11:	89 e5                	mov    %esp,%ebp
 a13:	53                   	push   %ebx
 a14:	bb 00 0f 00 00       	mov    $0xf00,%ebx
 a19:	83 ec 14             	sub    $0x14,%esp
	int i;
	for(i=0;i<NTHREAD;i++){
		if(threads[i].used==1){
 a1c:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
 a20:	74 16                	je     a38 <thread_join+0x28>
 a22:	83 c3 0c             	add    $0xc,%ebx
	for(i=0;i<NTHREAD;i++){
 a25:	81 fb 30 0f 00 00    	cmp    $0xf30,%ebx
 a2b:	75 ef                	jne    a1c <thread_join+0xc>
				remove_thread(&pid);
				return pid;
			}
		}
	}
	return 0;
 a2d:	31 c0                	xor    %eax,%eax
}
 a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 a32:	c9                   	leave  
 a33:	c3                   	ret    
 a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			int pid=join(&threads[i].ustack);  //回收子线程
 a38:	8d 43 04             	lea    0x4(%ebx),%eax
 a3b:	83 ec 0c             	sub    $0xc,%esp
 a3e:	50                   	push   %eax
 a3f:	e8 3e fa ff ff       	call   482 <join>
			if(pid>0){
 a44:	83 c4 10             	add    $0x10,%esp
 a47:	85 c0                	test   %eax,%eax
			int pid=join(&threads[i].ustack);  //回收子线程
 a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
			if(pid>0){
 a4c:	7e d4                	jle    a22 <thread_join+0x12>
				remove_thread(&pid);
 a4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 a51:	83 ec 0c             	sub    $0xc,%esp
 a54:	50                   	push   %eax
 a55:	e8 96 fe ff ff       	call   8f0 <remove_thread>
				return pid;
 a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5d:	83 c4 10             	add    $0x10,%esp
 a60:	eb cd                	jmp    a2f <thread_join+0x1f>
 a62:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 a69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000a70 <printTCB>:

void printTCB(void){
 a70:	55                   	push   %ebp
 a71:	89 e5                	mov    %esp,%ebp
 a73:	53                   	push   %ebx
	int i;
	for(i=0;i<NTHREAD;i++)
 a74:	31 db                	xor    %ebx,%ebx
void printTCB(void){
 a76:	83 ec 04             	sub    $0x4,%esp
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 a79:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 a7c:	ff 34 85 08 0f 00 00 	pushl  0xf08(,%eax,4)
 a83:	53                   	push   %ebx
	for(i=0;i<NTHREAD;i++)
 a84:	83 c3 01             	add    $0x1,%ebx
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 a87:	68 39 0b 00 00       	push   $0xb39
 a8c:	6a 01                	push   $0x1
 a8e:	e8 ad fa ff ff       	call   540 <printf>
	for(i=0;i<NTHREAD;i++)
 a93:	83 c4 10             	add    $0x10,%esp
 a96:	83 fb 04             	cmp    $0x4,%ebx
 a99:	75 de                	jne    a79 <printTCB+0x9>
}
 a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 a9e:	c9                   	leave  
 a9f:	c3                   	ret    

00000aa0 <add>:

int add(int a,int b)
{ 
 aa0:	55                   	push   %ebp
 aa1:	89 e5                	mov    %esp,%ebp
	return a+b;
 aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
 aa6:	03 45 08             	add    0x8(%ebp),%eax
 aa9:	5d                   	pop    %ebp
 aaa:	c3                   	ret    
