
_test_free_alloc:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int main()
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
  11:	83 ec 24             	sub    $0x24,%esp
	char* m1=(char*)myalloc(2*4096);
  14:	68 00 20 00 00       	push   $0x2000
  19:	e8 9c 03 00 00       	call   3ba <myalloc>
	char* m2=(char*)myalloc(3*4096);
  1e:	c7 04 24 00 30 00 00 	movl   $0x3000,(%esp)
	char* m1=(char*)myalloc(2*4096);
  25:	89 c3                	mov    %eax,%ebx
	char* m2=(char*)myalloc(3*4096);
  27:	e8 8e 03 00 00       	call   3ba <myalloc>
	char* m3=(char*)myalloc(1*4096);
  2c:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
	char* m2=(char*)myalloc(3*4096);
  33:	89 45 e0             	mov    %eax,-0x20(%ebp)
	char* m3=(char*)myalloc(1*4096);
  36:	e8 7f 03 00 00       	call   3ba <myalloc>
	char* m4=(char*)myalloc(7*4096);
  3b:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
	char* m3=(char*)myalloc(1*4096);
  42:	89 c7                	mov    %eax,%edi
	char* m4=(char*)myalloc(7*4096);
  44:	e8 71 03 00 00       	call   3ba <myalloc>
	char* m5=(char*)myalloc(9*4096);
  49:	c7 04 24 00 90 00 00 	movl   $0x9000,(%esp)
	char* m4=(char*)myalloc(7*4096);
  50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char* m5=(char*)myalloc(9*4096);
  53:	e8 62 03 00 00       	call   3ba <myalloc>

	m1[0]='h';
	m1[1]='\0';
	printf(1,"m1: %s\n",m1);
  58:	83 c4 0c             	add    $0xc,%esp
	char* m5=(char*)myalloc(9*4096);
  5b:	89 c6                	mov    %eax,%esi
	m1[0]='h';
  5d:	b8 68 00 00 00       	mov    $0x68,%eax
  62:	66 89 03             	mov    %ax,(%ebx)
	printf(1,"m1: %s\n",m1);
  65:	53                   	push   %ebx
  66:	68 fc 09 00 00       	push   $0x9fc
  6b:	6a 01                	push   $0x1
  6d:	e8 1e 04 00 00       	call   490 <printf>

	myfree(m2);
  72:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  75:	89 0c 24             	mov    %ecx,(%esp)
  78:	e8 45 03 00 00       	call   3c2 <myfree>
	//尝试往空洞写数据
	// m2[0]='h';
	// m2[1]='\0';
	// printf(1,"m1: %s\n",m2);

	myfree(m4);
  7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80:	89 14 24             	mov    %edx,(%esp)
  83:	e8 3a 03 00 00       	call   3c2 <myfree>

	sleep(1000);
  88:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
  8f:	e8 16 03 00 00       	call   3aa <sleep>

	myfree(m1);
  94:	89 1c 24             	mov    %ebx,(%esp)
  97:	e8 26 03 00 00       	call   3c2 <myfree>
	myfree(m3);
  9c:	89 3c 24             	mov    %edi,(%esp)
  9f:	e8 1e 03 00 00       	call   3c2 <myfree>
	myfree(m5);
  a4:	89 34 24             	mov    %esi,(%esp)
  a7:	e8 16 03 00 00       	call   3c2 <myfree>

	exit();
  ac:	e8 61 02 00 00       	call   312 <exit>
  b1:	66 90                	xchg   %ax,%ax
  b3:	66 90                	xchg   %ax,%ax
  b5:	66 90                	xchg   %ax,%ax
  b7:	66 90                	xchg   %ax,%ax
  b9:	66 90                	xchg   %ax,%ax
  bb:	66 90                	xchg   %ax,%ax
  bd:	66 90                	xchg   %ax,%ax
  bf:	90                   	nop

000000c0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	53                   	push   %ebx
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ca:	89 c2                	mov    %eax,%edx
  cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  d0:	83 c1 01             	add    $0x1,%ecx
  d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  d7:	83 c2 01             	add    $0x1,%edx
  da:	84 db                	test   %bl,%bl
  dc:	88 5a ff             	mov    %bl,-0x1(%edx)
  df:	75 ef                	jne    d0 <strcpy+0x10>
    ;
  return os;
}
  e1:	5b                   	pop    %ebx
  e2:	5d                   	pop    %ebp
  e3:	c3                   	ret    
  e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	53                   	push   %ebx
  f4:	8b 55 08             	mov    0x8(%ebp),%edx
  f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
  fa:	0f b6 02             	movzbl (%edx),%eax
  fd:	0f b6 19             	movzbl (%ecx),%ebx
 100:	84 c0                	test   %al,%al
 102:	75 1c                	jne    120 <strcmp+0x30>
 104:	eb 2a                	jmp    130 <strcmp+0x40>
 106:	8d 76 00             	lea    0x0(%esi),%esi
 109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    p++, q++;
 110:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 113:	0f b6 02             	movzbl (%edx),%eax
    p++, q++;
 116:	83 c1 01             	add    $0x1,%ecx
 119:	0f b6 19             	movzbl (%ecx),%ebx
  while(*p && *p == *q)
 11c:	84 c0                	test   %al,%al
 11e:	74 10                	je     130 <strcmp+0x40>
 120:	38 d8                	cmp    %bl,%al
 122:	74 ec                	je     110 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
 124:	29 d8                	sub    %ebx,%eax
}
 126:	5b                   	pop    %ebx
 127:	5d                   	pop    %ebp
 128:	c3                   	ret    
 129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 130:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
 132:	29 d8                	sub    %ebx,%eax
}
 134:	5b                   	pop    %ebx
 135:	5d                   	pop    %ebp
 136:	c3                   	ret    
 137:	89 f6                	mov    %esi,%esi
 139:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000140 <strlen>:

uint
strlen(char *s)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 146:	80 39 00             	cmpb   $0x0,(%ecx)
 149:	74 15                	je     160 <strlen+0x20>
 14b:	31 d2                	xor    %edx,%edx
 14d:	8d 76 00             	lea    0x0(%esi),%esi
 150:	83 c2 01             	add    $0x1,%edx
 153:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 157:	89 d0                	mov    %edx,%eax
 159:	75 f5                	jne    150 <strlen+0x10>
    ;
  return n;
}
 15b:	5d                   	pop    %ebp
 15c:	c3                   	ret    
 15d:	8d 76 00             	lea    0x0(%esi),%esi
  for(n = 0; s[n]; n++)
 160:	31 c0                	xor    %eax,%eax
}
 162:	5d                   	pop    %ebp
 163:	c3                   	ret    
 164:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 16a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000170 <memset>:

void*
memset(void *dst, int c, uint n)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	57                   	push   %edi
 174:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 177:	8b 4d 10             	mov    0x10(%ebp),%ecx
 17a:	8b 45 0c             	mov    0xc(%ebp),%eax
 17d:	89 d7                	mov    %edx,%edi
 17f:	fc                   	cld    
 180:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 182:	89 d0                	mov    %edx,%eax
 184:	5f                   	pop    %edi
 185:	5d                   	pop    %ebp
 186:	c3                   	ret    
 187:	89 f6                	mov    %esi,%esi
 189:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000190 <strchr>:

char*
strchr(const char *s, char c)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	53                   	push   %ebx
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for(; *s; s++)
 19a:	0f b6 10             	movzbl (%eax),%edx
 19d:	84 d2                	test   %dl,%dl
 19f:	74 1d                	je     1be <strchr+0x2e>
    if(*s == c)
 1a1:	38 d3                	cmp    %dl,%bl
 1a3:	89 d9                	mov    %ebx,%ecx
 1a5:	75 0d                	jne    1b4 <strchr+0x24>
 1a7:	eb 17                	jmp    1c0 <strchr+0x30>
 1a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 1b0:	38 ca                	cmp    %cl,%dl
 1b2:	74 0c                	je     1c0 <strchr+0x30>
  for(; *s; s++)
 1b4:	83 c0 01             	add    $0x1,%eax
 1b7:	0f b6 10             	movzbl (%eax),%edx
 1ba:	84 d2                	test   %dl,%dl
 1bc:	75 f2                	jne    1b0 <strchr+0x20>
      return (char*)s;
  return 0;
 1be:	31 c0                	xor    %eax,%eax
}
 1c0:	5b                   	pop    %ebx
 1c1:	5d                   	pop    %ebp
 1c2:	c3                   	ret    
 1c3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 1c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001d0 <gets>:

char*
gets(char *buf, int max)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	57                   	push   %edi
 1d4:	56                   	push   %esi
 1d5:	53                   	push   %ebx
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d6:	31 f6                	xor    %esi,%esi
 1d8:	89 f3                	mov    %esi,%ebx
{
 1da:	83 ec 1c             	sub    $0x1c,%esp
 1dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 1e0:	eb 2f                	jmp    211 <gets+0x41>
 1e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 1e8:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1eb:	83 ec 04             	sub    $0x4,%esp
 1ee:	6a 01                	push   $0x1
 1f0:	50                   	push   %eax
 1f1:	6a 00                	push   $0x0
 1f3:	e8 32 01 00 00       	call   32a <read>
    if(cc < 1)
 1f8:	83 c4 10             	add    $0x10,%esp
 1fb:	85 c0                	test   %eax,%eax
 1fd:	7e 1c                	jle    21b <gets+0x4b>
      break;
    buf[i++] = c;
 1ff:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 203:	83 c7 01             	add    $0x1,%edi
 206:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 209:	3c 0a                	cmp    $0xa,%al
 20b:	74 23                	je     230 <gets+0x60>
 20d:	3c 0d                	cmp    $0xd,%al
 20f:	74 1f                	je     230 <gets+0x60>
  for(i=0; i+1 < max; ){
 211:	83 c3 01             	add    $0x1,%ebx
 214:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 217:	89 fe                	mov    %edi,%esi
 219:	7c cd                	jl     1e8 <gets+0x18>
 21b:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 21d:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 220:	c6 03 00             	movb   $0x0,(%ebx)
}
 223:	8d 65 f4             	lea    -0xc(%ebp),%esp
 226:	5b                   	pop    %ebx
 227:	5e                   	pop    %esi
 228:	5f                   	pop    %edi
 229:	5d                   	pop    %ebp
 22a:	c3                   	ret    
 22b:	90                   	nop
 22c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 230:	8b 75 08             	mov    0x8(%ebp),%esi
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	01 de                	add    %ebx,%esi
 238:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 23a:	c6 03 00             	movb   $0x0,(%ebx)
}
 23d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 240:	5b                   	pop    %ebx
 241:	5e                   	pop    %esi
 242:	5f                   	pop    %edi
 243:	5d                   	pop    %ebp
 244:	c3                   	ret    
 245:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000250 <stat>:

int
stat(char *n, struct stat *st)
{
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	56                   	push   %esi
 254:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 255:	83 ec 08             	sub    $0x8,%esp
 258:	6a 00                	push   $0x0
 25a:	ff 75 08             	pushl  0x8(%ebp)
 25d:	e8 f0 00 00 00       	call   352 <open>
  if(fd < 0)
 262:	83 c4 10             	add    $0x10,%esp
 265:	85 c0                	test   %eax,%eax
 267:	78 27                	js     290 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 269:	83 ec 08             	sub    $0x8,%esp
 26c:	ff 75 0c             	pushl  0xc(%ebp)
 26f:	89 c3                	mov    %eax,%ebx
 271:	50                   	push   %eax
 272:	e8 f3 00 00 00       	call   36a <fstat>
  close(fd);
 277:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 27a:	89 c6                	mov    %eax,%esi
  close(fd);
 27c:	e8 b9 00 00 00       	call   33a <close>
  return r;
 281:	83 c4 10             	add    $0x10,%esp
}
 284:	8d 65 f8             	lea    -0x8(%ebp),%esp
 287:	89 f0                	mov    %esi,%eax
 289:	5b                   	pop    %ebx
 28a:	5e                   	pop    %esi
 28b:	5d                   	pop    %ebp
 28c:	c3                   	ret    
 28d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 290:	be ff ff ff ff       	mov    $0xffffffff,%esi
 295:	eb ed                	jmp    284 <stat+0x34>
 297:	89 f6                	mov    %esi,%esi
 299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000002a0 <atoi>:

int
atoi(const char *s)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	53                   	push   %ebx
 2a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a7:	0f be 11             	movsbl (%ecx),%edx
 2aa:	8d 42 d0             	lea    -0x30(%edx),%eax
 2ad:	3c 09                	cmp    $0x9,%al
  n = 0;
 2af:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 2b4:	77 1f                	ja     2d5 <atoi+0x35>
 2b6:	8d 76 00             	lea    0x0(%esi),%esi
 2b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    n = n*10 + *s++ - '0';
 2c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
 2c3:	83 c1 01             	add    $0x1,%ecx
 2c6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
  while('0' <= *s && *s <= '9')
 2ca:	0f be 11             	movsbl (%ecx),%edx
 2cd:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2d0:	80 fb 09             	cmp    $0x9,%bl
 2d3:	76 eb                	jbe    2c0 <atoi+0x20>
  return n;
}
 2d5:	5b                   	pop    %ebx
 2d6:	5d                   	pop    %ebp
 2d7:	c3                   	ret    
 2d8:	90                   	nop
 2d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

000002e0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	56                   	push   %esi
 2e4:	53                   	push   %ebx
 2e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2ee:	85 db                	test   %ebx,%ebx
 2f0:	7e 14                	jle    306 <memmove+0x26>
 2f2:	31 d2                	xor    %edx,%edx
 2f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *dst++ = *src++;
 2f8:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 2fc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 2ff:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0)
 302:	39 d3                	cmp    %edx,%ebx
 304:	75 f2                	jne    2f8 <memmove+0x18>
  return vdst;
}
 306:	5b                   	pop    %ebx
 307:	5e                   	pop    %esi
 308:	5d                   	pop    %ebp
 309:	c3                   	ret    

0000030a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 30a:	b8 01 00 00 00       	mov    $0x1,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <exit>:
SYSCALL(exit)
 312:	b8 02 00 00 00       	mov    $0x2,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <wait>:
SYSCALL(wait)
 31a:	b8 03 00 00 00       	mov    $0x3,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <pipe>:
SYSCALL(pipe)
 322:	b8 04 00 00 00       	mov    $0x4,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <read>:
SYSCALL(read)
 32a:	b8 05 00 00 00       	mov    $0x5,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <write>:
SYSCALL(write)
 332:	b8 10 00 00 00       	mov    $0x10,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <close>:
SYSCALL(close)
 33a:	b8 15 00 00 00       	mov    $0x15,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <kill>:
SYSCALL(kill)
 342:	b8 06 00 00 00       	mov    $0x6,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <exec>:
SYSCALL(exec)
 34a:	b8 07 00 00 00       	mov    $0x7,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <open>:
SYSCALL(open)
 352:	b8 0f 00 00 00       	mov    $0xf,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <mknod>:
SYSCALL(mknod)
 35a:	b8 11 00 00 00       	mov    $0x11,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <unlink>:
SYSCALL(unlink)
 362:	b8 12 00 00 00       	mov    $0x12,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <fstat>:
SYSCALL(fstat)
 36a:	b8 08 00 00 00       	mov    $0x8,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <link>:
SYSCALL(link)
 372:	b8 13 00 00 00       	mov    $0x13,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <mkdir>:
SYSCALL(mkdir)
 37a:	b8 14 00 00 00       	mov    $0x14,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <chdir>:
SYSCALL(chdir)
 382:	b8 09 00 00 00       	mov    $0x9,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <dup>:
SYSCALL(dup)
 38a:	b8 0a 00 00 00       	mov    $0xa,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <getpid>:
SYSCALL(getpid)
 392:	b8 0b 00 00 00       	mov    $0xb,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <getcpuid>:
SYSCALL(getcpuid)
 39a:	b8 16 00 00 00       	mov    $0x16,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <sbrk>:
SYSCALL(sbrk)
 3a2:	b8 0c 00 00 00       	mov    $0xc,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <sleep>:
SYSCALL(sleep)
 3aa:	b8 0d 00 00 00       	mov    $0xd,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <uptime>:
SYSCALL(uptime)
 3b2:	b8 0e 00 00 00       	mov    $0xe,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <myalloc>:
SYSCALL(myalloc)
 3ba:	b8 17 00 00 00       	mov    $0x17,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <myfree>:
SYSCALL(myfree)
 3c2:	b8 18 00 00 00       	mov    $0x18,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <clone>:
SYSCALL(clone)
 3ca:	b8 19 00 00 00       	mov    $0x19,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <join>:
SYSCALL(join)
 3d2:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <cps>:
SYSCALL(cps);
 3da:	b8 1c 00 00 00       	mov    $0x1c,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <chpri>:
SYSCALL(chpri);
 3e2:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    
 3ea:	66 90                	xchg   %ax,%ax
 3ec:	66 90                	xchg   %ax,%ax
 3ee:	66 90                	xchg   %ax,%ax

000003f0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	57                   	push   %edi
 3f4:	56                   	push   %esi
 3f5:	53                   	push   %ebx
 3f6:	83 ec 3c             	sub    $0x3c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f9:	85 d2                	test   %edx,%edx
{
 3fb:	89 45 c0             	mov    %eax,-0x40(%ebp)
    neg = 1;
    x = -xx;
 3fe:	89 d0                	mov    %edx,%eax
  if(sgn && xx < 0){
 400:	79 76                	jns    478 <printint+0x88>
 402:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 406:	74 70                	je     478 <printint+0x88>
    x = -xx;
 408:	f7 d8                	neg    %eax
    neg = 1;
 40a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 411:	31 f6                	xor    %esi,%esi
 413:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 416:	eb 0a                	jmp    422 <printint+0x32>
 418:	90                   	nop
 419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  do{
    buf[i++] = digits[x % base];
 420:	89 fe                	mov    %edi,%esi
 422:	31 d2                	xor    %edx,%edx
 424:	8d 7e 01             	lea    0x1(%esi),%edi
 427:	f7 f1                	div    %ecx
 429:	0f b6 92 0c 0a 00 00 	movzbl 0xa0c(%edx),%edx
  }while((x /= base) != 0);
 430:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
 432:	88 14 3b             	mov    %dl,(%ebx,%edi,1)
  }while((x /= base) != 0);
 435:	75 e9                	jne    420 <printint+0x30>
  if(neg)
 437:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 43a:	85 c0                	test   %eax,%eax
 43c:	74 08                	je     446 <printint+0x56>
    buf[i++] = '-';
 43e:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
 443:	8d 7e 02             	lea    0x2(%esi),%edi
 446:	8d 74 3d d7          	lea    -0x29(%ebp,%edi,1),%esi
 44a:	8b 7d c0             	mov    -0x40(%ebp),%edi
 44d:	8d 76 00             	lea    0x0(%esi),%esi
 450:	0f b6 06             	movzbl (%esi),%eax
  write(fd, &c, 1);
 453:	83 ec 04             	sub    $0x4,%esp
 456:	83 ee 01             	sub    $0x1,%esi
 459:	6a 01                	push   $0x1
 45b:	53                   	push   %ebx
 45c:	57                   	push   %edi
 45d:	88 45 d7             	mov    %al,-0x29(%ebp)
 460:	e8 cd fe ff ff       	call   332 <write>

  while(--i >= 0)
 465:	83 c4 10             	add    $0x10,%esp
 468:	39 de                	cmp    %ebx,%esi
 46a:	75 e4                	jne    450 <printint+0x60>
    putc(fd, buf[i]);
}
 46c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 46f:	5b                   	pop    %ebx
 470:	5e                   	pop    %esi
 471:	5f                   	pop    %edi
 472:	5d                   	pop    %ebp
 473:	c3                   	ret    
 474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 478:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 47f:	eb 90                	jmp    411 <printint+0x21>
 481:	eb 0d                	jmp    490 <printf>
 483:	90                   	nop
 484:	90                   	nop
 485:	90                   	nop
 486:	90                   	nop
 487:	90                   	nop
 488:	90                   	nop
 489:	90                   	nop
 48a:	90                   	nop
 48b:	90                   	nop
 48c:	90                   	nop
 48d:	90                   	nop
 48e:	90                   	nop
 48f:	90                   	nop

00000490 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
 493:	57                   	push   %edi
 494:	56                   	push   %esi
 495:	53                   	push   %ebx
 496:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 499:	8b 75 0c             	mov    0xc(%ebp),%esi
 49c:	0f b6 1e             	movzbl (%esi),%ebx
 49f:	84 db                	test   %bl,%bl
 4a1:	0f 84 b3 00 00 00    	je     55a <printf+0xca>
  ap = (uint*)(void*)&fmt + 1;
 4a7:	8d 45 10             	lea    0x10(%ebp),%eax
 4aa:	83 c6 01             	add    $0x1,%esi
  state = 0;
 4ad:	31 ff                	xor    %edi,%edi
  ap = (uint*)(void*)&fmt + 1;
 4af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 4b2:	eb 2f                	jmp    4e3 <printf+0x53>
 4b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 4b8:	83 f8 25             	cmp    $0x25,%eax
 4bb:	0f 84 a7 00 00 00    	je     568 <printf+0xd8>
  write(fd, &c, 1);
 4c1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 4c4:	83 ec 04             	sub    $0x4,%esp
 4c7:	88 5d e2             	mov    %bl,-0x1e(%ebp)
 4ca:	6a 01                	push   $0x1
 4cc:	50                   	push   %eax
 4cd:	ff 75 08             	pushl  0x8(%ebp)
 4d0:	e8 5d fe ff ff       	call   332 <write>
 4d5:	83 c4 10             	add    $0x10,%esp
 4d8:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 4db:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 4df:	84 db                	test   %bl,%bl
 4e1:	74 77                	je     55a <printf+0xca>
    if(state == 0){
 4e3:	85 ff                	test   %edi,%edi
    c = fmt[i] & 0xff;
 4e5:	0f be cb             	movsbl %bl,%ecx
 4e8:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 4eb:	74 cb                	je     4b8 <printf+0x28>
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ed:	83 ff 25             	cmp    $0x25,%edi
 4f0:	75 e6                	jne    4d8 <printf+0x48>
      if(c == 'd'){
 4f2:	83 f8 64             	cmp    $0x64,%eax
 4f5:	0f 84 05 01 00 00    	je     600 <printf+0x170>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 4fb:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 501:	83 f9 70             	cmp    $0x70,%ecx
 504:	74 72                	je     578 <printf+0xe8>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 506:	83 f8 73             	cmp    $0x73,%eax
 509:	0f 84 99 00 00 00    	je     5a8 <printf+0x118>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 50f:	83 f8 63             	cmp    $0x63,%eax
 512:	0f 84 08 01 00 00    	je     620 <printf+0x190>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 518:	83 f8 25             	cmp    $0x25,%eax
 51b:	0f 84 ef 00 00 00    	je     610 <printf+0x180>
  write(fd, &c, 1);
 521:	8d 45 e7             	lea    -0x19(%ebp),%eax
 524:	83 ec 04             	sub    $0x4,%esp
 527:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 52b:	6a 01                	push   $0x1
 52d:	50                   	push   %eax
 52e:	ff 75 08             	pushl  0x8(%ebp)
 531:	e8 fc fd ff ff       	call   332 <write>
 536:	83 c4 0c             	add    $0xc,%esp
 539:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 53c:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 53f:	6a 01                	push   $0x1
 541:	50                   	push   %eax
 542:	ff 75 08             	pushl  0x8(%ebp)
 545:	83 c6 01             	add    $0x1,%esi
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 548:	31 ff                	xor    %edi,%edi
  write(fd, &c, 1);
 54a:	e8 e3 fd ff ff       	call   332 <write>
  for(i = 0; fmt[i]; i++){
 54f:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
  write(fd, &c, 1);
 553:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 556:	84 db                	test   %bl,%bl
 558:	75 89                	jne    4e3 <printf+0x53>
    }
  }
}
 55a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 55d:	5b                   	pop    %ebx
 55e:	5e                   	pop    %esi
 55f:	5f                   	pop    %edi
 560:	5d                   	pop    %ebp
 561:	c3                   	ret    
 562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        state = '%';
 568:	bf 25 00 00 00       	mov    $0x25,%edi
 56d:	e9 66 ff ff ff       	jmp    4d8 <printf+0x48>
 572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printint(fd, *ap, 16, 0);
 578:	83 ec 0c             	sub    $0xc,%esp
 57b:	b9 10 00 00 00       	mov    $0x10,%ecx
 580:	6a 00                	push   $0x0
 582:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 585:	8b 45 08             	mov    0x8(%ebp),%eax
 588:	8b 17                	mov    (%edi),%edx
 58a:	e8 61 fe ff ff       	call   3f0 <printint>
        ap++;
 58f:	89 f8                	mov    %edi,%eax
 591:	83 c4 10             	add    $0x10,%esp
      state = 0;
 594:	31 ff                	xor    %edi,%edi
        ap++;
 596:	83 c0 04             	add    $0x4,%eax
 599:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 59c:	e9 37 ff ff ff       	jmp    4d8 <printf+0x48>
 5a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = (char*)*ap;
 5a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 5ab:	8b 08                	mov    (%eax),%ecx
        ap++;
 5ad:	83 c0 04             	add    $0x4,%eax
 5b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(s == 0)
 5b3:	85 c9                	test   %ecx,%ecx
 5b5:	0f 84 8e 00 00 00    	je     649 <printf+0x1b9>
        while(*s != 0){
 5bb:	0f b6 01             	movzbl (%ecx),%eax
      state = 0;
 5be:	31 ff                	xor    %edi,%edi
        s = (char*)*ap;
 5c0:	89 cb                	mov    %ecx,%ebx
        while(*s != 0){
 5c2:	84 c0                	test   %al,%al
 5c4:	0f 84 0e ff ff ff    	je     4d8 <printf+0x48>
 5ca:	89 75 d0             	mov    %esi,-0x30(%ebp)
 5cd:	89 de                	mov    %ebx,%esi
 5cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5d2:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 5d5:	8d 76 00             	lea    0x0(%esi),%esi
  write(fd, &c, 1);
 5d8:	83 ec 04             	sub    $0x4,%esp
          s++;
 5db:	83 c6 01             	add    $0x1,%esi
 5de:	88 45 e3             	mov    %al,-0x1d(%ebp)
  write(fd, &c, 1);
 5e1:	6a 01                	push   $0x1
 5e3:	57                   	push   %edi
 5e4:	53                   	push   %ebx
 5e5:	e8 48 fd ff ff       	call   332 <write>
        while(*s != 0){
 5ea:	0f b6 06             	movzbl (%esi),%eax
 5ed:	83 c4 10             	add    $0x10,%esp
 5f0:	84 c0                	test   %al,%al
 5f2:	75 e4                	jne    5d8 <printf+0x148>
 5f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 5f7:	31 ff                	xor    %edi,%edi
 5f9:	e9 da fe ff ff       	jmp    4d8 <printf+0x48>
 5fe:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 10, 1);
 600:	83 ec 0c             	sub    $0xc,%esp
 603:	b9 0a 00 00 00       	mov    $0xa,%ecx
 608:	6a 01                	push   $0x1
 60a:	e9 73 ff ff ff       	jmp    582 <printf+0xf2>
 60f:	90                   	nop
  write(fd, &c, 1);
 610:	83 ec 04             	sub    $0x4,%esp
 613:	88 5d e5             	mov    %bl,-0x1b(%ebp)
 616:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 619:	6a 01                	push   $0x1
 61b:	e9 21 ff ff ff       	jmp    541 <printf+0xb1>
        putc(fd, *ap);
 620:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  write(fd, &c, 1);
 623:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 626:	8b 07                	mov    (%edi),%eax
  write(fd, &c, 1);
 628:	6a 01                	push   $0x1
        ap++;
 62a:	83 c7 04             	add    $0x4,%edi
        putc(fd, *ap);
 62d:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 630:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 633:	50                   	push   %eax
 634:	ff 75 08             	pushl  0x8(%ebp)
 637:	e8 f6 fc ff ff       	call   332 <write>
        ap++;
 63c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 63f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 642:	31 ff                	xor    %edi,%edi
 644:	e9 8f fe ff ff       	jmp    4d8 <printf+0x48>
          s = "(null)";
 649:	bb 04 0a 00 00       	mov    $0xa04,%ebx
        while(*s != 0){
 64e:	b8 28 00 00 00       	mov    $0x28,%eax
 653:	e9 72 ff ff ff       	jmp    5ca <printf+0x13a>
 658:	66 90                	xchg   %ax,%ax
 65a:	66 90                	xchg   %ax,%ax
 65c:	66 90                	xchg   %ax,%ax
 65e:	66 90                	xchg   %ax,%ax

00000660 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 660:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 661:	a1 c0 0d 00 00       	mov    0xdc0,%eax
{
 666:	89 e5                	mov    %esp,%ebp
 668:	57                   	push   %edi
 669:	56                   	push   %esi
 66a:	53                   	push   %ebx
 66b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 66e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
 671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 678:	39 c8                	cmp    %ecx,%eax
 67a:	8b 10                	mov    (%eax),%edx
 67c:	73 32                	jae    6b0 <free+0x50>
 67e:	39 d1                	cmp    %edx,%ecx
 680:	72 04                	jb     686 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 682:	39 d0                	cmp    %edx,%eax
 684:	72 32                	jb     6b8 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 686:	8b 73 fc             	mov    -0x4(%ebx),%esi
 689:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 68c:	39 fa                	cmp    %edi,%edx
 68e:	74 30                	je     6c0 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 690:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 693:	8b 50 04             	mov    0x4(%eax),%edx
 696:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 699:	39 f1                	cmp    %esi,%ecx
 69b:	74 3a                	je     6d7 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 69d:	89 08                	mov    %ecx,(%eax)
  freep = p;
 69f:	a3 c0 0d 00 00       	mov    %eax,0xdc0
}
 6a4:	5b                   	pop    %ebx
 6a5:	5e                   	pop    %esi
 6a6:	5f                   	pop    %edi
 6a7:	5d                   	pop    %ebp
 6a8:	c3                   	ret    
 6a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b0:	39 d0                	cmp    %edx,%eax
 6b2:	72 04                	jb     6b8 <free+0x58>
 6b4:	39 d1                	cmp    %edx,%ecx
 6b6:	72 ce                	jb     686 <free+0x26>
{
 6b8:	89 d0                	mov    %edx,%eax
 6ba:	eb bc                	jmp    678 <free+0x18>
 6bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 6c0:	03 72 04             	add    0x4(%edx),%esi
 6c3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c6:	8b 10                	mov    (%eax),%edx
 6c8:	8b 12                	mov    (%edx),%edx
 6ca:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6cd:	8b 50 04             	mov    0x4(%eax),%edx
 6d0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6d3:	39 f1                	cmp    %esi,%ecx
 6d5:	75 c6                	jne    69d <free+0x3d>
    p->s.size += bp->s.size;
 6d7:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 6da:	a3 c0 0d 00 00       	mov    %eax,0xdc0
    p->s.size += bp->s.size;
 6df:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6e2:	8b 53 f8             	mov    -0x8(%ebx),%edx
 6e5:	89 10                	mov    %edx,(%eax)
}
 6e7:	5b                   	pop    %ebx
 6e8:	5e                   	pop    %esi
 6e9:	5f                   	pop    %edi
 6ea:	5d                   	pop    %ebp
 6eb:	c3                   	ret    
 6ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000006f0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6f0:	55                   	push   %ebp
 6f1:	89 e5                	mov    %esp,%ebp
 6f3:	57                   	push   %edi
 6f4:	56                   	push   %esi
 6f5:	53                   	push   %ebx
 6f6:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6f9:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 6fc:	8b 15 c0 0d 00 00    	mov    0xdc0,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 702:	8d 78 07             	lea    0x7(%eax),%edi
 705:	c1 ef 03             	shr    $0x3,%edi
 708:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 70b:	85 d2                	test   %edx,%edx
 70d:	0f 84 9d 00 00 00    	je     7b0 <malloc+0xc0>
 713:	8b 02                	mov    (%edx),%eax
 715:	8b 48 04             	mov    0x4(%eax),%ecx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 718:	39 cf                	cmp    %ecx,%edi
 71a:	76 6c                	jbe    788 <malloc+0x98>
 71c:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
 722:	bb 00 10 00 00       	mov    $0x1000,%ebx
 727:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 72a:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 731:	eb 0e                	jmp    741 <malloc+0x51>
 733:	90                   	nop
 734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 738:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 73a:	8b 48 04             	mov    0x4(%eax),%ecx
 73d:	39 f9                	cmp    %edi,%ecx
 73f:	73 47                	jae    788 <malloc+0x98>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 741:	39 05 c0 0d 00 00    	cmp    %eax,0xdc0
 747:	89 c2                	mov    %eax,%edx
 749:	75 ed                	jne    738 <malloc+0x48>
  p = sbrk(nu * sizeof(Header));
 74b:	83 ec 0c             	sub    $0xc,%esp
 74e:	56                   	push   %esi
 74f:	e8 4e fc ff ff       	call   3a2 <sbrk>
  if(p == (char*)-1)
 754:	83 c4 10             	add    $0x10,%esp
 757:	83 f8 ff             	cmp    $0xffffffff,%eax
 75a:	74 1c                	je     778 <malloc+0x88>
  hp->s.size = nu;
 75c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 75f:	83 ec 0c             	sub    $0xc,%esp
 762:	83 c0 08             	add    $0x8,%eax
 765:	50                   	push   %eax
 766:	e8 f5 fe ff ff       	call   660 <free>
  return freep;
 76b:	8b 15 c0 0d 00 00    	mov    0xdc0,%edx
      if((p = morecore(nunits)) == 0)
 771:	83 c4 10             	add    $0x10,%esp
 774:	85 d2                	test   %edx,%edx
 776:	75 c0                	jne    738 <malloc+0x48>
        return 0;
  }
}
 778:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 77b:	31 c0                	xor    %eax,%eax
}
 77d:	5b                   	pop    %ebx
 77e:	5e                   	pop    %esi
 77f:	5f                   	pop    %edi
 780:	5d                   	pop    %ebp
 781:	c3                   	ret    
 782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 788:	39 cf                	cmp    %ecx,%edi
 78a:	74 54                	je     7e0 <malloc+0xf0>
        p->s.size -= nunits;
 78c:	29 f9                	sub    %edi,%ecx
 78e:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 791:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 794:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 797:	89 15 c0 0d 00 00    	mov    %edx,0xdc0
}
 79d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 7a0:	83 c0 08             	add    $0x8,%eax
}
 7a3:	5b                   	pop    %ebx
 7a4:	5e                   	pop    %esi
 7a5:	5f                   	pop    %edi
 7a6:	5d                   	pop    %ebp
 7a7:	c3                   	ret    
 7a8:	90                   	nop
 7a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    base.s.ptr = freep = prevp = &base;
 7b0:	c7 05 c0 0d 00 00 c4 	movl   $0xdc4,0xdc0
 7b7:	0d 00 00 
 7ba:	c7 05 c4 0d 00 00 c4 	movl   $0xdc4,0xdc4
 7c1:	0d 00 00 
    base.s.size = 0;
 7c4:	b8 c4 0d 00 00       	mov    $0xdc4,%eax
 7c9:	c7 05 c8 0d 00 00 00 	movl   $0x0,0xdc8
 7d0:	00 00 00 
 7d3:	e9 44 ff ff ff       	jmp    71c <malloc+0x2c>
 7d8:	90                   	nop
 7d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        prevp->s.ptr = p->s.ptr;
 7e0:	8b 08                	mov    (%eax),%ecx
 7e2:	89 0a                	mov    %ecx,(%edx)
 7e4:	eb b1                	jmp    797 <malloc+0xa7>
 7e6:	66 90                	xchg   %ax,%ax
 7e8:	66 90                	xchg   %ax,%ax
 7ea:	66 90                	xchg   %ax,%ax
 7ec:	66 90                	xchg   %ax,%ax
 7ee:	66 90                	xchg   %ax,%ax

000007f0 <add_thread>:
	void *ustack;
	int used;
}threads[NTHREAD]; //TCB表

//add a TCB to thread table
void add_thread(int *pid,void *ustack){
 7f0:	ba e0 0d 00 00       	mov    $0xde0,%edx
	int i;
	for(i=0;i<NTHREAD;i++){
 7f5:	31 c0                	xor    %eax,%eax
		if(threads[i].used==0){
 7f7:	8b 4a 08             	mov    0x8(%edx),%ecx
 7fa:	85 c9                	test   %ecx,%ecx
 7fc:	74 12                	je     810 <add_thread+0x20>
	for(i=0;i<NTHREAD;i++){
 7fe:	83 c0 01             	add    $0x1,%eax
 801:	83 c2 0c             	add    $0xc,%edx
 804:	83 f8 04             	cmp    $0x4,%eax
 807:	75 ee                	jne    7f7 <add_thread+0x7>
 809:	f3 c3                	repz ret 
 80b:	90                   	nop
 80c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void add_thread(int *pid,void *ustack){
 810:	55                   	push   %ebp
			threads[i].pid=*pid;
 811:	8d 04 40             	lea    (%eax,%eax,2),%eax
void add_thread(int *pid,void *ustack){
 814:	89 e5                	mov    %esp,%ebp
			threads[i].pid=*pid;
 816:	c1 e0 02             	shl    $0x2,%eax
 819:	8b 55 08             	mov    0x8(%ebp),%edx
 81c:	8b 0a                	mov    (%edx),%ecx
 81e:	8d 90 e0 0d 00 00    	lea    0xde0(%eax),%edx
			threads[i].ustack=ustack;
			threads[i].used=1;
 824:	c7 42 08 01 00 00 00 	movl   $0x1,0x8(%edx)
			threads[i].pid=*pid;
 82b:	89 88 e0 0d 00 00    	mov    %ecx,0xde0(%eax)
			threads[i].ustack=ustack;
 831:	8b 45 0c             	mov    0xc(%ebp),%eax
 834:	89 42 04             	mov    %eax,0x4(%edx)
			break;
		}
	}
}
 837:	5d                   	pop    %ebp
 838:	c3                   	ret    
 839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000840 <remove_thread>:

void remove_thread(int *pid)
{
 840:	55                   	push   %ebp
 841:	b8 e0 0d 00 00       	mov    $0xde0,%eax
    int i;
	for(i=0;i<NTHREAD;i++){
 846:	31 d2                	xor    %edx,%edx
{
 848:	89 e5                	mov    %esp,%ebp
 84a:	56                   	push   %esi
 84b:	53                   	push   %ebx
 84c:	8b 4d 08             	mov    0x8(%ebp),%ecx
    	if(threads[i].used && threads[i].pid==*pid)
 84f:	8b 58 08             	mov    0x8(%eax),%ebx
 852:	85 db                	test   %ebx,%ebx
 854:	74 06                	je     85c <remove_thread+0x1c>
 856:	8b 31                	mov    (%ecx),%esi
 858:	39 30                	cmp    %esi,(%eax)
 85a:	74 14                	je     870 <remove_thread+0x30>
	for(i=0;i<NTHREAD;i++){
 85c:	83 c2 01             	add    $0x1,%edx
 85f:	83 c0 0c             	add    $0xc,%eax
 862:	83 fa 04             	cmp    $0x4,%edx
 865:	75 e8                	jne    84f <remove_thread+0xf>
    		threads[i].ustack=0;
    		threads[i].used=0;
    		break;
    	}
    }
}
 867:	8d 65 f8             	lea    -0x8(%ebp),%esp
 86a:	5b                   	pop    %ebx
 86b:	5e                   	pop    %esi
 86c:	5d                   	pop    %ebp
 86d:	c3                   	ret    
 86e:	66 90                	xchg   %ax,%ax
    		free(threads[i].ustack); //释放用户栈
 870:	8d 1c 52             	lea    (%edx,%edx,2),%ebx
 873:	83 ec 0c             	sub    $0xc,%esp
 876:	c1 e3 02             	shl    $0x2,%ebx
 879:	ff b3 e4 0d 00 00    	pushl  0xde4(%ebx)
 87f:	e8 dc fd ff ff       	call   660 <free>
    		threads[i].pid=0;
 884:	c7 83 e0 0d 00 00 00 	movl   $0x0,0xde0(%ebx)
 88b:	00 00 00 
    		threads[i].ustack=0;
 88e:	c7 83 e4 0d 00 00 00 	movl   $0x0,0xde4(%ebx)
 895:	00 00 00 
    		break;
 898:	83 c4 10             	add    $0x10,%esp
    		threads[i].used=0;
 89b:	c7 83 e8 0d 00 00 00 	movl   $0x0,0xde8(%ebx)
 8a2:	00 00 00 
}
 8a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
 8a8:	5b                   	pop    %ebx
 8a9:	5e                   	pop    %esi
 8aa:	5d                   	pop    %ebp
 8ab:	c3                   	ret    
 8ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000008b0 <thread_create>:

int thread_create(void(*start_routine)(void*),void* arg){
 8b0:	55                   	push   %ebp
 8b1:	89 e5                	mov    %esp,%ebp
 8b3:	53                   	push   %ebx
 8b4:	83 ec 04             	sub    $0x4,%esp
	//if first time running any threads,initialize thread table with zeros
	static int first=1;
	if(first){
 8b7:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 8bc:	85 c0                	test   %eax,%eax
 8be:	74 2d                	je     8ed <thread_create+0x3d>
		first=0;
 8c0:	c7 05 b4 0d 00 00 00 	movl   $0x0,0xdb4
 8c7:	00 00 00 
 8ca:	b8 e0 0d 00 00       	mov    $0xde0,%eax
		int i;
		for(i=0;i<NTHREAD;i++){
			threads[i].pid=0;
 8cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			threads[i].ustack=0;
 8d5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
 8dc:	83 c0 0c             	add    $0xc,%eax
			threads[i].used=0;
 8df:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
		for(i=0;i<NTHREAD;i++){
 8e6:	3d 10 0e 00 00       	cmp    $0xe10,%eax
 8eb:	75 e2                	jne    8cf <thread_create+0x1f>
		}
	}
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 8ed:	83 ec 0c             	sub    $0xc,%esp
 8f0:	68 00 10 00 00       	push   $0x1000
 8f5:	e8 f6 fd ff ff       	call   6f0 <malloc>
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 8fa:	83 c4 0c             	add    $0xc,%esp
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 8fd:	89 c3                	mov    %eax,%ebx
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 8ff:	50                   	push   %eax
 900:	ff 75 0c             	pushl  0xc(%ebp)
 903:	ff 75 08             	pushl  0x8(%ebp)
 906:	e8 bf fa ff ff       	call   3ca <clone>
 90b:	b9 e0 0d 00 00       	mov    $0xde0,%ecx
 910:	83 c4 10             	add    $0x10,%esp
	for(i=0;i<NTHREAD;i++){
 913:	31 d2                	xor    %edx,%edx
		if(threads[i].used==0){
 915:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
 919:	74 15                	je     930 <thread_create+0x80>
	for(i=0;i<NTHREAD;i++){
 91b:	83 c2 01             	add    $0x1,%edx
 91e:	83 c1 0c             	add    $0xc,%ecx
 921:	83 fa 04             	cmp    $0x4,%edx
 924:	75 ef                	jne    915 <thread_create+0x65>
	add_thread(&pid,stack);//save new thread to thread table
	return pid;
}
 926:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 929:	c9                   	leave  
 92a:	c3                   	ret    
 92b:	90                   	nop
 92c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			threads[i].pid=*pid;
 930:	8d 14 52             	lea    (%edx,%edx,2),%edx
 933:	c1 e2 02             	shl    $0x2,%edx
			threads[i].ustack=ustack;
 936:	89 9a e4 0d 00 00    	mov    %ebx,0xde4(%edx)
			threads[i].pid=*pid;
 93c:	89 82 e0 0d 00 00    	mov    %eax,0xde0(%edx)
			threads[i].used=1;
 942:	c7 82 e8 0d 00 00 01 	movl   $0x1,0xde8(%edx)
 949:	00 00 00 
}
 94c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 94f:	c9                   	leave  
 950:	c3                   	ret    
 951:	eb 0d                	jmp    960 <thread_join>
 953:	90                   	nop
 954:	90                   	nop
 955:	90                   	nop
 956:	90                   	nop
 957:	90                   	nop
 958:	90                   	nop
 959:	90                   	nop
 95a:	90                   	nop
 95b:	90                   	nop
 95c:	90                   	nop
 95d:	90                   	nop
 95e:	90                   	nop
 95f:	90                   	nop

00000960 <thread_join>:

int thread_join(void){
 960:	55                   	push   %ebp
 961:	89 e5                	mov    %esp,%ebp
 963:	53                   	push   %ebx
 964:	bb e0 0d 00 00       	mov    $0xde0,%ebx
 969:	83 ec 14             	sub    $0x14,%esp
	int i;
	for(i=0;i<NTHREAD;i++){
		if(threads[i].used==1){
 96c:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
 970:	74 16                	je     988 <thread_join+0x28>
 972:	83 c3 0c             	add    $0xc,%ebx
	for(i=0;i<NTHREAD;i++){
 975:	81 fb 10 0e 00 00    	cmp    $0xe10,%ebx
 97b:	75 ef                	jne    96c <thread_join+0xc>
				remove_thread(&pid);
				return pid;
			}
		}
	}
	return 0;
 97d:	31 c0                	xor    %eax,%eax
}
 97f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 982:	c9                   	leave  
 983:	c3                   	ret    
 984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			int pid=join(&threads[i].ustack);  //回收子线程
 988:	8d 43 04             	lea    0x4(%ebx),%eax
 98b:	83 ec 0c             	sub    $0xc,%esp
 98e:	50                   	push   %eax
 98f:	e8 3e fa ff ff       	call   3d2 <join>
			if(pid>0){
 994:	83 c4 10             	add    $0x10,%esp
 997:	85 c0                	test   %eax,%eax
			int pid=join(&threads[i].ustack);  //回收子线程
 999:	89 45 f4             	mov    %eax,-0xc(%ebp)
			if(pid>0){
 99c:	7e d4                	jle    972 <thread_join+0x12>
				remove_thread(&pid);
 99e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 9a1:	83 ec 0c             	sub    $0xc,%esp
 9a4:	50                   	push   %eax
 9a5:	e8 96 fe ff ff       	call   840 <remove_thread>
				return pid;
 9aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ad:	83 c4 10             	add    $0x10,%esp
 9b0:	eb cd                	jmp    97f <thread_join+0x1f>
 9b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 9b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000009c0 <printTCB>:

void printTCB(void){
 9c0:	55                   	push   %ebp
 9c1:	89 e5                	mov    %esp,%ebp
 9c3:	53                   	push   %ebx
	int i;
	for(i=0;i<NTHREAD;i++)
 9c4:	31 db                	xor    %ebx,%ebx
void printTCB(void){
 9c6:	83 ec 04             	sub    $0x4,%esp
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 9c9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 9cc:	ff 34 85 e8 0d 00 00 	pushl  0xde8(,%eax,4)
 9d3:	53                   	push   %ebx
	for(i=0;i<NTHREAD;i++)
 9d4:	83 c3 01             	add    $0x1,%ebx
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 9d7:	68 1d 0a 00 00       	push   $0xa1d
 9dc:	6a 01                	push   $0x1
 9de:	e8 ad fa ff ff       	call   490 <printf>
	for(i=0;i<NTHREAD;i++)
 9e3:	83 c4 10             	add    $0x10,%esp
 9e6:	83 fb 04             	cmp    $0x4,%ebx
 9e9:	75 de                	jne    9c9 <printTCB+0x9>
}
 9eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 9ee:	c9                   	leave  
 9ef:	c3                   	ret    

000009f0 <add>:

int add(int a,int b)
{ 
 9f0:	55                   	push   %ebp
 9f1:	89 e5                	mov    %esp,%ebp
	return a+b;
 9f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 9f6:	03 45 08             	add    0x8(%ebp),%eax
 9f9:	5d                   	pop    %ebp
 9fa:	c3                   	ret    
