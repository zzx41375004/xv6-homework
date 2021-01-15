
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"


int main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
	if(argc!=1)
  11:	83 39 01             	cmpl   $0x1,(%ecx)
  14:	74 16                	je     2c <main+0x2c>
	printf(1, "Usage: ps\n");
  16:	50                   	push   %eax
  17:	50                   	push   %eax
  18:	68 7c 09 00 00       	push   $0x97c
  1d:	6a 01                	push   $0x1
  1f:	e8 ec 03 00 00       	call   410 <printf>
  24:	83 c4 10             	add    $0x10,%esp
	else
	cps();
	exit();
  27:	e8 66 02 00 00       	call   292 <exit>
	cps();
  2c:	e8 29 03 00 00       	call   35a <cps>
  31:	eb f4                	jmp    27 <main+0x27>
  33:	66 90                	xchg   %ax,%ax
  35:	66 90                	xchg   %ax,%ax
  37:	66 90                	xchg   %ax,%ax
  39:	66 90                	xchg   %ax,%ax
  3b:	66 90                	xchg   %ax,%ax
  3d:	66 90                	xchg   %ax,%ax
  3f:	90                   	nop

00000040 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  40:	55                   	push   %ebp
  41:	89 e5                	mov    %esp,%ebp
  43:	53                   	push   %ebx
  44:	8b 45 08             	mov    0x8(%ebp),%eax
  47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4a:	89 c2                	mov    %eax,%edx
  4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  50:	83 c1 01             	add    $0x1,%ecx
  53:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  57:	83 c2 01             	add    $0x1,%edx
  5a:	84 db                	test   %bl,%bl
  5c:	88 5a ff             	mov    %bl,-0x1(%edx)
  5f:	75 ef                	jne    50 <strcpy+0x10>
    ;
  return os;
}
  61:	5b                   	pop    %ebx
  62:	5d                   	pop    %ebp
  63:	c3                   	ret    
  64:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  6a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000070 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	53                   	push   %ebx
  74:	8b 55 08             	mov    0x8(%ebp),%edx
  77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
  7a:	0f b6 02             	movzbl (%edx),%eax
  7d:	0f b6 19             	movzbl (%ecx),%ebx
  80:	84 c0                	test   %al,%al
  82:	75 1c                	jne    a0 <strcmp+0x30>
  84:	eb 2a                	jmp    b0 <strcmp+0x40>
  86:	8d 76 00             	lea    0x0(%esi),%esi
  89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    p++, q++;
  90:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  93:	0f b6 02             	movzbl (%edx),%eax
    p++, q++;
  96:	83 c1 01             	add    $0x1,%ecx
  99:	0f b6 19             	movzbl (%ecx),%ebx
  while(*p && *p == *q)
  9c:	84 c0                	test   %al,%al
  9e:	74 10                	je     b0 <strcmp+0x40>
  a0:	38 d8                	cmp    %bl,%al
  a2:	74 ec                	je     90 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
  a4:	29 d8                	sub    %ebx,%eax
}
  a6:	5b                   	pop    %ebx
  a7:	5d                   	pop    %ebp
  a8:	c3                   	ret    
  a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  b0:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
  b2:	29 d8                	sub    %ebx,%eax
}
  b4:	5b                   	pop    %ebx
  b5:	5d                   	pop    %ebp
  b6:	c3                   	ret    
  b7:	89 f6                	mov    %esi,%esi
  b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000000c0 <strlen>:

uint
strlen(char *s)
{
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  c6:	80 39 00             	cmpb   $0x0,(%ecx)
  c9:	74 15                	je     e0 <strlen+0x20>
  cb:	31 d2                	xor    %edx,%edx
  cd:	8d 76 00             	lea    0x0(%esi),%esi
  d0:	83 c2 01             	add    $0x1,%edx
  d3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  d7:	89 d0                	mov    %edx,%eax
  d9:	75 f5                	jne    d0 <strlen+0x10>
    ;
  return n;
}
  db:	5d                   	pop    %ebp
  dc:	c3                   	ret    
  dd:	8d 76 00             	lea    0x0(%esi),%esi
  for(n = 0; s[n]; n++)
  e0:	31 c0                	xor    %eax,%eax
}
  e2:	5d                   	pop    %ebp
  e3:	c3                   	ret    
  e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

000000f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	57                   	push   %edi
  f4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  fd:	89 d7                	mov    %edx,%edi
  ff:	fc                   	cld    
 100:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 102:	89 d0                	mov    %edx,%eax
 104:	5f                   	pop    %edi
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    
 107:	89 f6                	mov    %esi,%esi
 109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000110 <strchr>:

char*
strchr(const char *s, char c)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	53                   	push   %ebx
 114:	8b 45 08             	mov    0x8(%ebp),%eax
 117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for(; *s; s++)
 11a:	0f b6 10             	movzbl (%eax),%edx
 11d:	84 d2                	test   %dl,%dl
 11f:	74 1d                	je     13e <strchr+0x2e>
    if(*s == c)
 121:	38 d3                	cmp    %dl,%bl
 123:	89 d9                	mov    %ebx,%ecx
 125:	75 0d                	jne    134 <strchr+0x24>
 127:	eb 17                	jmp    140 <strchr+0x30>
 129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 130:	38 ca                	cmp    %cl,%dl
 132:	74 0c                	je     140 <strchr+0x30>
  for(; *s; s++)
 134:	83 c0 01             	add    $0x1,%eax
 137:	0f b6 10             	movzbl (%eax),%edx
 13a:	84 d2                	test   %dl,%dl
 13c:	75 f2                	jne    130 <strchr+0x20>
      return (char*)s;
  return 0;
 13e:	31 c0                	xor    %eax,%eax
}
 140:	5b                   	pop    %ebx
 141:	5d                   	pop    %ebp
 142:	c3                   	ret    
 143:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 149:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000150 <gets>:

char*
gets(char *buf, int max)
{
 150:	55                   	push   %ebp
 151:	89 e5                	mov    %esp,%ebp
 153:	57                   	push   %edi
 154:	56                   	push   %esi
 155:	53                   	push   %ebx
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 156:	31 f6                	xor    %esi,%esi
 158:	89 f3                	mov    %esi,%ebx
{
 15a:	83 ec 1c             	sub    $0x1c,%esp
 15d:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 160:	eb 2f                	jmp    191 <gets+0x41>
 162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 168:	8d 45 e7             	lea    -0x19(%ebp),%eax
 16b:	83 ec 04             	sub    $0x4,%esp
 16e:	6a 01                	push   $0x1
 170:	50                   	push   %eax
 171:	6a 00                	push   $0x0
 173:	e8 32 01 00 00       	call   2aa <read>
    if(cc < 1)
 178:	83 c4 10             	add    $0x10,%esp
 17b:	85 c0                	test   %eax,%eax
 17d:	7e 1c                	jle    19b <gets+0x4b>
      break;
    buf[i++] = c;
 17f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 183:	83 c7 01             	add    $0x1,%edi
 186:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 189:	3c 0a                	cmp    $0xa,%al
 18b:	74 23                	je     1b0 <gets+0x60>
 18d:	3c 0d                	cmp    $0xd,%al
 18f:	74 1f                	je     1b0 <gets+0x60>
  for(i=0; i+1 < max; ){
 191:	83 c3 01             	add    $0x1,%ebx
 194:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 197:	89 fe                	mov    %edi,%esi
 199:	7c cd                	jl     168 <gets+0x18>
 19b:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 1a0:	c6 03 00             	movb   $0x0,(%ebx)
}
 1a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1a6:	5b                   	pop    %ebx
 1a7:	5e                   	pop    %esi
 1a8:	5f                   	pop    %edi
 1a9:	5d                   	pop    %ebp
 1aa:	c3                   	ret    
 1ab:	90                   	nop
 1ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1b0:	8b 75 08             	mov    0x8(%ebp),%esi
 1b3:	8b 45 08             	mov    0x8(%ebp),%eax
 1b6:	01 de                	add    %ebx,%esi
 1b8:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 1ba:	c6 03 00             	movb   $0x0,(%ebx)
}
 1bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1c0:	5b                   	pop    %ebx
 1c1:	5e                   	pop    %esi
 1c2:	5f                   	pop    %edi
 1c3:	5d                   	pop    %ebp
 1c4:	c3                   	ret    
 1c5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001d0 <stat>:

int
stat(char *n, struct stat *st)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	56                   	push   %esi
 1d4:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d5:	83 ec 08             	sub    $0x8,%esp
 1d8:	6a 00                	push   $0x0
 1da:	ff 75 08             	pushl  0x8(%ebp)
 1dd:	e8 f0 00 00 00       	call   2d2 <open>
  if(fd < 0)
 1e2:	83 c4 10             	add    $0x10,%esp
 1e5:	85 c0                	test   %eax,%eax
 1e7:	78 27                	js     210 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 1e9:	83 ec 08             	sub    $0x8,%esp
 1ec:	ff 75 0c             	pushl  0xc(%ebp)
 1ef:	89 c3                	mov    %eax,%ebx
 1f1:	50                   	push   %eax
 1f2:	e8 f3 00 00 00       	call   2ea <fstat>
  close(fd);
 1f7:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 1fa:	89 c6                	mov    %eax,%esi
  close(fd);
 1fc:	e8 b9 00 00 00       	call   2ba <close>
  return r;
 201:	83 c4 10             	add    $0x10,%esp
}
 204:	8d 65 f8             	lea    -0x8(%ebp),%esp
 207:	89 f0                	mov    %esi,%eax
 209:	5b                   	pop    %ebx
 20a:	5e                   	pop    %esi
 20b:	5d                   	pop    %ebp
 20c:	c3                   	ret    
 20d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 210:	be ff ff ff ff       	mov    $0xffffffff,%esi
 215:	eb ed                	jmp    204 <stat+0x34>
 217:	89 f6                	mov    %esi,%esi
 219:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000220 <atoi>:

int
atoi(const char *s)
{
 220:	55                   	push   %ebp
 221:	89 e5                	mov    %esp,%ebp
 223:	53                   	push   %ebx
 224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 227:	0f be 11             	movsbl (%ecx),%edx
 22a:	8d 42 d0             	lea    -0x30(%edx),%eax
 22d:	3c 09                	cmp    $0x9,%al
  n = 0;
 22f:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 234:	77 1f                	ja     255 <atoi+0x35>
 236:	8d 76 00             	lea    0x0(%esi),%esi
 239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    n = n*10 + *s++ - '0';
 240:	8d 04 80             	lea    (%eax,%eax,4),%eax
 243:	83 c1 01             	add    $0x1,%ecx
 246:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
  while('0' <= *s && *s <= '9')
 24a:	0f be 11             	movsbl (%ecx),%edx
 24d:	8d 5a d0             	lea    -0x30(%edx),%ebx
 250:	80 fb 09             	cmp    $0x9,%bl
 253:	76 eb                	jbe    240 <atoi+0x20>
  return n;
}
 255:	5b                   	pop    %ebx
 256:	5d                   	pop    %ebp
 257:	c3                   	ret    
 258:	90                   	nop
 259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000260 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 260:	55                   	push   %ebp
 261:	89 e5                	mov    %esp,%ebp
 263:	56                   	push   %esi
 264:	53                   	push   %ebx
 265:	8b 5d 10             	mov    0x10(%ebp),%ebx
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 26e:	85 db                	test   %ebx,%ebx
 270:	7e 14                	jle    286 <memmove+0x26>
 272:	31 d2                	xor    %edx,%edx
 274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *dst++ = *src++;
 278:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 27c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 27f:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0)
 282:	39 d3                	cmp    %edx,%ebx
 284:	75 f2                	jne    278 <memmove+0x18>
  return vdst;
}
 286:	5b                   	pop    %ebx
 287:	5e                   	pop    %esi
 288:	5d                   	pop    %ebp
 289:	c3                   	ret    

0000028a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 28a:	b8 01 00 00 00       	mov    $0x1,%eax
 28f:	cd 40                	int    $0x40
 291:	c3                   	ret    

00000292 <exit>:
SYSCALL(exit)
 292:	b8 02 00 00 00       	mov    $0x2,%eax
 297:	cd 40                	int    $0x40
 299:	c3                   	ret    

0000029a <wait>:
SYSCALL(wait)
 29a:	b8 03 00 00 00       	mov    $0x3,%eax
 29f:	cd 40                	int    $0x40
 2a1:	c3                   	ret    

000002a2 <pipe>:
SYSCALL(pipe)
 2a2:	b8 04 00 00 00       	mov    $0x4,%eax
 2a7:	cd 40                	int    $0x40
 2a9:	c3                   	ret    

000002aa <read>:
SYSCALL(read)
 2aa:	b8 05 00 00 00       	mov    $0x5,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <write>:
SYSCALL(write)
 2b2:	b8 10 00 00 00       	mov    $0x10,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <close>:
SYSCALL(close)
 2ba:	b8 15 00 00 00       	mov    $0x15,%eax
 2bf:	cd 40                	int    $0x40
 2c1:	c3                   	ret    

000002c2 <kill>:
SYSCALL(kill)
 2c2:	b8 06 00 00 00       	mov    $0x6,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <exec>:
SYSCALL(exec)
 2ca:	b8 07 00 00 00       	mov    $0x7,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <open>:
SYSCALL(open)
 2d2:	b8 0f 00 00 00       	mov    $0xf,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <mknod>:
SYSCALL(mknod)
 2da:	b8 11 00 00 00       	mov    $0x11,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <unlink>:
SYSCALL(unlink)
 2e2:	b8 12 00 00 00       	mov    $0x12,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <fstat>:
SYSCALL(fstat)
 2ea:	b8 08 00 00 00       	mov    $0x8,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <link>:
SYSCALL(link)
 2f2:	b8 13 00 00 00       	mov    $0x13,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <mkdir>:
SYSCALL(mkdir)
 2fa:	b8 14 00 00 00       	mov    $0x14,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <chdir>:
SYSCALL(chdir)
 302:	b8 09 00 00 00       	mov    $0x9,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <dup>:
SYSCALL(dup)
 30a:	b8 0a 00 00 00       	mov    $0xa,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <getpid>:
SYSCALL(getpid)
 312:	b8 0b 00 00 00       	mov    $0xb,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <getcpuid>:
SYSCALL(getcpuid)
 31a:	b8 16 00 00 00       	mov    $0x16,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <sbrk>:
SYSCALL(sbrk)
 322:	b8 0c 00 00 00       	mov    $0xc,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <sleep>:
SYSCALL(sleep)
 32a:	b8 0d 00 00 00       	mov    $0xd,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <uptime>:
SYSCALL(uptime)
 332:	b8 0e 00 00 00       	mov    $0xe,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <myalloc>:
SYSCALL(myalloc)
 33a:	b8 17 00 00 00       	mov    $0x17,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <myfree>:
SYSCALL(myfree)
 342:	b8 18 00 00 00       	mov    $0x18,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <clone>:
SYSCALL(clone)
 34a:	b8 19 00 00 00       	mov    $0x19,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <join>:
SYSCALL(join)
 352:	b8 1a 00 00 00       	mov    $0x1a,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <cps>:
SYSCALL(cps);
 35a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <chpri>:
SYSCALL(chpri);
 362:	b8 1b 00 00 00       	mov    $0x1b,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    
 36a:	66 90                	xchg   %ax,%ax
 36c:	66 90                	xchg   %ax,%ax
 36e:	66 90                	xchg   %ax,%ax

00000370 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	57                   	push   %edi
 374:	56                   	push   %esi
 375:	53                   	push   %ebx
 376:	83 ec 3c             	sub    $0x3c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 379:	85 d2                	test   %edx,%edx
{
 37b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    neg = 1;
    x = -xx;
 37e:	89 d0                	mov    %edx,%eax
  if(sgn && xx < 0){
 380:	79 76                	jns    3f8 <printint+0x88>
 382:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 386:	74 70                	je     3f8 <printint+0x88>
    x = -xx;
 388:	f7 d8                	neg    %eax
    neg = 1;
 38a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 391:	31 f6                	xor    %esi,%esi
 393:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 396:	eb 0a                	jmp    3a2 <printint+0x32>
 398:	90                   	nop
 399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  do{
    buf[i++] = digits[x % base];
 3a0:	89 fe                	mov    %edi,%esi
 3a2:	31 d2                	xor    %edx,%edx
 3a4:	8d 7e 01             	lea    0x1(%esi),%edi
 3a7:	f7 f1                	div    %ecx
 3a9:	0f b6 92 90 09 00 00 	movzbl 0x990(%edx),%edx
  }while((x /= base) != 0);
 3b0:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
 3b2:	88 14 3b             	mov    %dl,(%ebx,%edi,1)
  }while((x /= base) != 0);
 3b5:	75 e9                	jne    3a0 <printint+0x30>
  if(neg)
 3b7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 3ba:	85 c0                	test   %eax,%eax
 3bc:	74 08                	je     3c6 <printint+0x56>
    buf[i++] = '-';
 3be:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
 3c3:	8d 7e 02             	lea    0x2(%esi),%edi
 3c6:	8d 74 3d d7          	lea    -0x29(%ebp,%edi,1),%esi
 3ca:	8b 7d c0             	mov    -0x40(%ebp),%edi
 3cd:	8d 76 00             	lea    0x0(%esi),%esi
 3d0:	0f b6 06             	movzbl (%esi),%eax
  write(fd, &c, 1);
 3d3:	83 ec 04             	sub    $0x4,%esp
 3d6:	83 ee 01             	sub    $0x1,%esi
 3d9:	6a 01                	push   $0x1
 3db:	53                   	push   %ebx
 3dc:	57                   	push   %edi
 3dd:	88 45 d7             	mov    %al,-0x29(%ebp)
 3e0:	e8 cd fe ff ff       	call   2b2 <write>

  while(--i >= 0)
 3e5:	83 c4 10             	add    $0x10,%esp
 3e8:	39 de                	cmp    %ebx,%esi
 3ea:	75 e4                	jne    3d0 <printint+0x60>
    putc(fd, buf[i]);
}
 3ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3ef:	5b                   	pop    %ebx
 3f0:	5e                   	pop    %esi
 3f1:	5f                   	pop    %edi
 3f2:	5d                   	pop    %ebp
 3f3:	c3                   	ret    
 3f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 3f8:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 3ff:	eb 90                	jmp    391 <printint+0x21>
 401:	eb 0d                	jmp    410 <printf>
 403:	90                   	nop
 404:	90                   	nop
 405:	90                   	nop
 406:	90                   	nop
 407:	90                   	nop
 408:	90                   	nop
 409:	90                   	nop
 40a:	90                   	nop
 40b:	90                   	nop
 40c:	90                   	nop
 40d:	90                   	nop
 40e:	90                   	nop
 40f:	90                   	nop

00000410 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	57                   	push   %edi
 414:	56                   	push   %esi
 415:	53                   	push   %ebx
 416:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 419:	8b 75 0c             	mov    0xc(%ebp),%esi
 41c:	0f b6 1e             	movzbl (%esi),%ebx
 41f:	84 db                	test   %bl,%bl
 421:	0f 84 b3 00 00 00    	je     4da <printf+0xca>
  ap = (uint*)(void*)&fmt + 1;
 427:	8d 45 10             	lea    0x10(%ebp),%eax
 42a:	83 c6 01             	add    $0x1,%esi
  state = 0;
 42d:	31 ff                	xor    %edi,%edi
  ap = (uint*)(void*)&fmt + 1;
 42f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 432:	eb 2f                	jmp    463 <printf+0x53>
 434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 438:	83 f8 25             	cmp    $0x25,%eax
 43b:	0f 84 a7 00 00 00    	je     4e8 <printf+0xd8>
  write(fd, &c, 1);
 441:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 444:	83 ec 04             	sub    $0x4,%esp
 447:	88 5d e2             	mov    %bl,-0x1e(%ebp)
 44a:	6a 01                	push   $0x1
 44c:	50                   	push   %eax
 44d:	ff 75 08             	pushl  0x8(%ebp)
 450:	e8 5d fe ff ff       	call   2b2 <write>
 455:	83 c4 10             	add    $0x10,%esp
 458:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 45b:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 45f:	84 db                	test   %bl,%bl
 461:	74 77                	je     4da <printf+0xca>
    if(state == 0){
 463:	85 ff                	test   %edi,%edi
    c = fmt[i] & 0xff;
 465:	0f be cb             	movsbl %bl,%ecx
 468:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 46b:	74 cb                	je     438 <printf+0x28>
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 46d:	83 ff 25             	cmp    $0x25,%edi
 470:	75 e6                	jne    458 <printf+0x48>
      if(c == 'd'){
 472:	83 f8 64             	cmp    $0x64,%eax
 475:	0f 84 05 01 00 00    	je     580 <printf+0x170>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 47b:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 481:	83 f9 70             	cmp    $0x70,%ecx
 484:	74 72                	je     4f8 <printf+0xe8>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 486:	83 f8 73             	cmp    $0x73,%eax
 489:	0f 84 99 00 00 00    	je     528 <printf+0x118>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 48f:	83 f8 63             	cmp    $0x63,%eax
 492:	0f 84 08 01 00 00    	je     5a0 <printf+0x190>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 498:	83 f8 25             	cmp    $0x25,%eax
 49b:	0f 84 ef 00 00 00    	je     590 <printf+0x180>
  write(fd, &c, 1);
 4a1:	8d 45 e7             	lea    -0x19(%ebp),%eax
 4a4:	83 ec 04             	sub    $0x4,%esp
 4a7:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 4ab:	6a 01                	push   $0x1
 4ad:	50                   	push   %eax
 4ae:	ff 75 08             	pushl  0x8(%ebp)
 4b1:	e8 fc fd ff ff       	call   2b2 <write>
 4b6:	83 c4 0c             	add    $0xc,%esp
 4b9:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 4bc:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 4bf:	6a 01                	push   $0x1
 4c1:	50                   	push   %eax
 4c2:	ff 75 08             	pushl  0x8(%ebp)
 4c5:	83 c6 01             	add    $0x1,%esi
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4c8:	31 ff                	xor    %edi,%edi
  write(fd, &c, 1);
 4ca:	e8 e3 fd ff ff       	call   2b2 <write>
  for(i = 0; fmt[i]; i++){
 4cf:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
  write(fd, &c, 1);
 4d3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 4d6:	84 db                	test   %bl,%bl
 4d8:	75 89                	jne    463 <printf+0x53>
    }
  }
}
 4da:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4dd:	5b                   	pop    %ebx
 4de:	5e                   	pop    %esi
 4df:	5f                   	pop    %edi
 4e0:	5d                   	pop    %ebp
 4e1:	c3                   	ret    
 4e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        state = '%';
 4e8:	bf 25 00 00 00       	mov    $0x25,%edi
 4ed:	e9 66 ff ff ff       	jmp    458 <printf+0x48>
 4f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printint(fd, *ap, 16, 0);
 4f8:	83 ec 0c             	sub    $0xc,%esp
 4fb:	b9 10 00 00 00       	mov    $0x10,%ecx
 500:	6a 00                	push   $0x0
 502:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 505:	8b 45 08             	mov    0x8(%ebp),%eax
 508:	8b 17                	mov    (%edi),%edx
 50a:	e8 61 fe ff ff       	call   370 <printint>
        ap++;
 50f:	89 f8                	mov    %edi,%eax
 511:	83 c4 10             	add    $0x10,%esp
      state = 0;
 514:	31 ff                	xor    %edi,%edi
        ap++;
 516:	83 c0 04             	add    $0x4,%eax
 519:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 51c:	e9 37 ff ff ff       	jmp    458 <printf+0x48>
 521:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = (char*)*ap;
 528:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 52b:	8b 08                	mov    (%eax),%ecx
        ap++;
 52d:	83 c0 04             	add    $0x4,%eax
 530:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(s == 0)
 533:	85 c9                	test   %ecx,%ecx
 535:	0f 84 8e 00 00 00    	je     5c9 <printf+0x1b9>
        while(*s != 0){
 53b:	0f b6 01             	movzbl (%ecx),%eax
      state = 0;
 53e:	31 ff                	xor    %edi,%edi
        s = (char*)*ap;
 540:	89 cb                	mov    %ecx,%ebx
        while(*s != 0){
 542:	84 c0                	test   %al,%al
 544:	0f 84 0e ff ff ff    	je     458 <printf+0x48>
 54a:	89 75 d0             	mov    %esi,-0x30(%ebp)
 54d:	89 de                	mov    %ebx,%esi
 54f:	8b 5d 08             	mov    0x8(%ebp),%ebx
 552:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 555:	8d 76 00             	lea    0x0(%esi),%esi
  write(fd, &c, 1);
 558:	83 ec 04             	sub    $0x4,%esp
          s++;
 55b:	83 c6 01             	add    $0x1,%esi
 55e:	88 45 e3             	mov    %al,-0x1d(%ebp)
  write(fd, &c, 1);
 561:	6a 01                	push   $0x1
 563:	57                   	push   %edi
 564:	53                   	push   %ebx
 565:	e8 48 fd ff ff       	call   2b2 <write>
        while(*s != 0){
 56a:	0f b6 06             	movzbl (%esi),%eax
 56d:	83 c4 10             	add    $0x10,%esp
 570:	84 c0                	test   %al,%al
 572:	75 e4                	jne    558 <printf+0x148>
 574:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 577:	31 ff                	xor    %edi,%edi
 579:	e9 da fe ff ff       	jmp    458 <printf+0x48>
 57e:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 10, 1);
 580:	83 ec 0c             	sub    $0xc,%esp
 583:	b9 0a 00 00 00       	mov    $0xa,%ecx
 588:	6a 01                	push   $0x1
 58a:	e9 73 ff ff ff       	jmp    502 <printf+0xf2>
 58f:	90                   	nop
  write(fd, &c, 1);
 590:	83 ec 04             	sub    $0x4,%esp
 593:	88 5d e5             	mov    %bl,-0x1b(%ebp)
 596:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 599:	6a 01                	push   $0x1
 59b:	e9 21 ff ff ff       	jmp    4c1 <printf+0xb1>
        putc(fd, *ap);
 5a0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  write(fd, &c, 1);
 5a3:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 5a6:	8b 07                	mov    (%edi),%eax
  write(fd, &c, 1);
 5a8:	6a 01                	push   $0x1
        ap++;
 5aa:	83 c7 04             	add    $0x4,%edi
        putc(fd, *ap);
 5ad:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 5b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 5b3:	50                   	push   %eax
 5b4:	ff 75 08             	pushl  0x8(%ebp)
 5b7:	e8 f6 fc ff ff       	call   2b2 <write>
        ap++;
 5bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 5bf:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5c2:	31 ff                	xor    %edi,%edi
 5c4:	e9 8f fe ff ff       	jmp    458 <printf+0x48>
          s = "(null)";
 5c9:	bb 87 09 00 00       	mov    $0x987,%ebx
        while(*s != 0){
 5ce:	b8 28 00 00 00       	mov    $0x28,%eax
 5d3:	e9 72 ff ff ff       	jmp    54a <printf+0x13a>
 5d8:	66 90                	xchg   %ax,%ax
 5da:	66 90                	xchg   %ax,%ax
 5dc:	66 90                	xchg   %ax,%ax
 5de:	66 90                	xchg   %ax,%ax

000005e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5e0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e1:	a1 40 0d 00 00       	mov    0xd40,%eax
{
 5e6:	89 e5                	mov    %esp,%ebp
 5e8:	57                   	push   %edi
 5e9:	56                   	push   %esi
 5ea:	53                   	push   %ebx
 5eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 5ee:	8d 4b f8             	lea    -0x8(%ebx),%ecx
 5f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f8:	39 c8                	cmp    %ecx,%eax
 5fa:	8b 10                	mov    (%eax),%edx
 5fc:	73 32                	jae    630 <free+0x50>
 5fe:	39 d1                	cmp    %edx,%ecx
 600:	72 04                	jb     606 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 602:	39 d0                	cmp    %edx,%eax
 604:	72 32                	jb     638 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 606:	8b 73 fc             	mov    -0x4(%ebx),%esi
 609:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 60c:	39 fa                	cmp    %edi,%edx
 60e:	74 30                	je     640 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 610:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 613:	8b 50 04             	mov    0x4(%eax),%edx
 616:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 619:	39 f1                	cmp    %esi,%ecx
 61b:	74 3a                	je     657 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 61d:	89 08                	mov    %ecx,(%eax)
  freep = p;
 61f:	a3 40 0d 00 00       	mov    %eax,0xd40
}
 624:	5b                   	pop    %ebx
 625:	5e                   	pop    %esi
 626:	5f                   	pop    %edi
 627:	5d                   	pop    %ebp
 628:	c3                   	ret    
 629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 630:	39 d0                	cmp    %edx,%eax
 632:	72 04                	jb     638 <free+0x58>
 634:	39 d1                	cmp    %edx,%ecx
 636:	72 ce                	jb     606 <free+0x26>
{
 638:	89 d0                	mov    %edx,%eax
 63a:	eb bc                	jmp    5f8 <free+0x18>
 63c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 640:	03 72 04             	add    0x4(%edx),%esi
 643:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 646:	8b 10                	mov    (%eax),%edx
 648:	8b 12                	mov    (%edx),%edx
 64a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 64d:	8b 50 04             	mov    0x4(%eax),%edx
 650:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 653:	39 f1                	cmp    %esi,%ecx
 655:	75 c6                	jne    61d <free+0x3d>
    p->s.size += bp->s.size;
 657:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 65a:	a3 40 0d 00 00       	mov    %eax,0xd40
    p->s.size += bp->s.size;
 65f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 662:	8b 53 f8             	mov    -0x8(%ebx),%edx
 665:	89 10                	mov    %edx,(%eax)
}
 667:	5b                   	pop    %ebx
 668:	5e                   	pop    %esi
 669:	5f                   	pop    %edi
 66a:	5d                   	pop    %ebp
 66b:	c3                   	ret    
 66c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000670 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 670:	55                   	push   %ebp
 671:	89 e5                	mov    %esp,%ebp
 673:	57                   	push   %edi
 674:	56                   	push   %esi
 675:	53                   	push   %ebx
 676:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 679:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 67c:	8b 15 40 0d 00 00    	mov    0xd40,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 682:	8d 78 07             	lea    0x7(%eax),%edi
 685:	c1 ef 03             	shr    $0x3,%edi
 688:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 68b:	85 d2                	test   %edx,%edx
 68d:	0f 84 9d 00 00 00    	je     730 <malloc+0xc0>
 693:	8b 02                	mov    (%edx),%eax
 695:	8b 48 04             	mov    0x4(%eax),%ecx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 698:	39 cf                	cmp    %ecx,%edi
 69a:	76 6c                	jbe    708 <malloc+0x98>
 69c:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
 6a2:	bb 00 10 00 00       	mov    $0x1000,%ebx
 6a7:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 6aa:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 6b1:	eb 0e                	jmp    6c1 <malloc+0x51>
 6b3:	90                   	nop
 6b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6b8:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 6ba:	8b 48 04             	mov    0x4(%eax),%ecx
 6bd:	39 f9                	cmp    %edi,%ecx
 6bf:	73 47                	jae    708 <malloc+0x98>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6c1:	39 05 40 0d 00 00    	cmp    %eax,0xd40
 6c7:	89 c2                	mov    %eax,%edx
 6c9:	75 ed                	jne    6b8 <malloc+0x48>
  p = sbrk(nu * sizeof(Header));
 6cb:	83 ec 0c             	sub    $0xc,%esp
 6ce:	56                   	push   %esi
 6cf:	e8 4e fc ff ff       	call   322 <sbrk>
  if(p == (char*)-1)
 6d4:	83 c4 10             	add    $0x10,%esp
 6d7:	83 f8 ff             	cmp    $0xffffffff,%eax
 6da:	74 1c                	je     6f8 <malloc+0x88>
  hp->s.size = nu;
 6dc:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 6df:	83 ec 0c             	sub    $0xc,%esp
 6e2:	83 c0 08             	add    $0x8,%eax
 6e5:	50                   	push   %eax
 6e6:	e8 f5 fe ff ff       	call   5e0 <free>
  return freep;
 6eb:	8b 15 40 0d 00 00    	mov    0xd40,%edx
      if((p = morecore(nunits)) == 0)
 6f1:	83 c4 10             	add    $0x10,%esp
 6f4:	85 d2                	test   %edx,%edx
 6f6:	75 c0                	jne    6b8 <malloc+0x48>
        return 0;
  }
}
 6f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 6fb:	31 c0                	xor    %eax,%eax
}
 6fd:	5b                   	pop    %ebx
 6fe:	5e                   	pop    %esi
 6ff:	5f                   	pop    %edi
 700:	5d                   	pop    %ebp
 701:	c3                   	ret    
 702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 708:	39 cf                	cmp    %ecx,%edi
 70a:	74 54                	je     760 <malloc+0xf0>
        p->s.size -= nunits;
 70c:	29 f9                	sub    %edi,%ecx
 70e:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 711:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 714:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 717:	89 15 40 0d 00 00    	mov    %edx,0xd40
}
 71d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 720:	83 c0 08             	add    $0x8,%eax
}
 723:	5b                   	pop    %ebx
 724:	5e                   	pop    %esi
 725:	5f                   	pop    %edi
 726:	5d                   	pop    %ebp
 727:	c3                   	ret    
 728:	90                   	nop
 729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    base.s.ptr = freep = prevp = &base;
 730:	c7 05 40 0d 00 00 44 	movl   $0xd44,0xd40
 737:	0d 00 00 
 73a:	c7 05 44 0d 00 00 44 	movl   $0xd44,0xd44
 741:	0d 00 00 
    base.s.size = 0;
 744:	b8 44 0d 00 00       	mov    $0xd44,%eax
 749:	c7 05 48 0d 00 00 00 	movl   $0x0,0xd48
 750:	00 00 00 
 753:	e9 44 ff ff ff       	jmp    69c <malloc+0x2c>
 758:	90                   	nop
 759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        prevp->s.ptr = p->s.ptr;
 760:	8b 08                	mov    (%eax),%ecx
 762:	89 0a                	mov    %ecx,(%edx)
 764:	eb b1                	jmp    717 <malloc+0xa7>
 766:	66 90                	xchg   %ax,%ax
 768:	66 90                	xchg   %ax,%ax
 76a:	66 90                	xchg   %ax,%ax
 76c:	66 90                	xchg   %ax,%ax
 76e:	66 90                	xchg   %ax,%ax

00000770 <add_thread>:
	void *ustack;
	int used;
}threads[NTHREAD]; //TCB表

//add a TCB to thread table
void add_thread(int *pid,void *ustack){
 770:	ba 60 0d 00 00       	mov    $0xd60,%edx
	int i;
	for(i=0;i<NTHREAD;i++){
 775:	31 c0                	xor    %eax,%eax
		if(threads[i].used==0){
 777:	8b 4a 08             	mov    0x8(%edx),%ecx
 77a:	85 c9                	test   %ecx,%ecx
 77c:	74 12                	je     790 <add_thread+0x20>
	for(i=0;i<NTHREAD;i++){
 77e:	83 c0 01             	add    $0x1,%eax
 781:	83 c2 0c             	add    $0xc,%edx
 784:	83 f8 04             	cmp    $0x4,%eax
 787:	75 ee                	jne    777 <add_thread+0x7>
 789:	f3 c3                	repz ret 
 78b:	90                   	nop
 78c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void add_thread(int *pid,void *ustack){
 790:	55                   	push   %ebp
			threads[i].pid=*pid;
 791:	8d 04 40             	lea    (%eax,%eax,2),%eax
void add_thread(int *pid,void *ustack){
 794:	89 e5                	mov    %esp,%ebp
			threads[i].pid=*pid;
 796:	c1 e0 02             	shl    $0x2,%eax
 799:	8b 55 08             	mov    0x8(%ebp),%edx
 79c:	8b 0a                	mov    (%edx),%ecx
 79e:	8d 90 60 0d 00 00    	lea    0xd60(%eax),%edx
			threads[i].ustack=ustack;
			threads[i].used=1;
 7a4:	c7 42 08 01 00 00 00 	movl   $0x1,0x8(%edx)
			threads[i].pid=*pid;
 7ab:	89 88 60 0d 00 00    	mov    %ecx,0xd60(%eax)
			threads[i].ustack=ustack;
 7b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 7b4:	89 42 04             	mov    %eax,0x4(%edx)
			break;
		}
	}
}
 7b7:	5d                   	pop    %ebp
 7b8:	c3                   	ret    
 7b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

000007c0 <remove_thread>:

void remove_thread(int *pid)
{
 7c0:	55                   	push   %ebp
 7c1:	b8 60 0d 00 00       	mov    $0xd60,%eax
    int i;
	for(i=0;i<NTHREAD;i++){
 7c6:	31 d2                	xor    %edx,%edx
{
 7c8:	89 e5                	mov    %esp,%ebp
 7ca:	56                   	push   %esi
 7cb:	53                   	push   %ebx
 7cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
    	if(threads[i].used && threads[i].pid==*pid)
 7cf:	8b 58 08             	mov    0x8(%eax),%ebx
 7d2:	85 db                	test   %ebx,%ebx
 7d4:	74 06                	je     7dc <remove_thread+0x1c>
 7d6:	8b 31                	mov    (%ecx),%esi
 7d8:	39 30                	cmp    %esi,(%eax)
 7da:	74 14                	je     7f0 <remove_thread+0x30>
	for(i=0;i<NTHREAD;i++){
 7dc:	83 c2 01             	add    $0x1,%edx
 7df:	83 c0 0c             	add    $0xc,%eax
 7e2:	83 fa 04             	cmp    $0x4,%edx
 7e5:	75 e8                	jne    7cf <remove_thread+0xf>
    		threads[i].ustack=0;
    		threads[i].used=0;
    		break;
    	}
    }
}
 7e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
 7ea:	5b                   	pop    %ebx
 7eb:	5e                   	pop    %esi
 7ec:	5d                   	pop    %ebp
 7ed:	c3                   	ret    
 7ee:	66 90                	xchg   %ax,%ax
    		free(threads[i].ustack); //释放用户栈
 7f0:	8d 1c 52             	lea    (%edx,%edx,2),%ebx
 7f3:	83 ec 0c             	sub    $0xc,%esp
 7f6:	c1 e3 02             	shl    $0x2,%ebx
 7f9:	ff b3 64 0d 00 00    	pushl  0xd64(%ebx)
 7ff:	e8 dc fd ff ff       	call   5e0 <free>
    		threads[i].pid=0;
 804:	c7 83 60 0d 00 00 00 	movl   $0x0,0xd60(%ebx)
 80b:	00 00 00 
    		threads[i].ustack=0;
 80e:	c7 83 64 0d 00 00 00 	movl   $0x0,0xd64(%ebx)
 815:	00 00 00 
    		break;
 818:	83 c4 10             	add    $0x10,%esp
    		threads[i].used=0;
 81b:	c7 83 68 0d 00 00 00 	movl   $0x0,0xd68(%ebx)
 822:	00 00 00 
}
 825:	8d 65 f8             	lea    -0x8(%ebp),%esp
 828:	5b                   	pop    %ebx
 829:	5e                   	pop    %esi
 82a:	5d                   	pop    %ebp
 82b:	c3                   	ret    
 82c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000830 <thread_create>:

int thread_create(void(*start_routine)(void*),void* arg){
 830:	55                   	push   %ebp
 831:	89 e5                	mov    %esp,%ebp
 833:	53                   	push   %ebx
 834:	83 ec 04             	sub    $0x4,%esp
	//if first time running any threads,initialize thread table with zeros
	static int first=1;
	if(first){
 837:	a1 2c 0d 00 00       	mov    0xd2c,%eax
 83c:	85 c0                	test   %eax,%eax
 83e:	74 2d                	je     86d <thread_create+0x3d>
		first=0;
 840:	c7 05 2c 0d 00 00 00 	movl   $0x0,0xd2c
 847:	00 00 00 
 84a:	b8 60 0d 00 00       	mov    $0xd60,%eax
		int i;
		for(i=0;i<NTHREAD;i++){
			threads[i].pid=0;
 84f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			threads[i].ustack=0;
 855:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
 85c:	83 c0 0c             	add    $0xc,%eax
			threads[i].used=0;
 85f:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
		for(i=0;i<NTHREAD;i++){
 866:	3d 90 0d 00 00       	cmp    $0xd90,%eax
 86b:	75 e2                	jne    84f <thread_create+0x1f>
		}
	}
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 86d:	83 ec 0c             	sub    $0xc,%esp
 870:	68 00 10 00 00       	push   $0x1000
 875:	e8 f6 fd ff ff       	call   670 <malloc>
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 87a:	83 c4 0c             	add    $0xc,%esp
	void *stack=malloc(PGSIZE);//allocate one page for user stack
 87d:	89 c3                	mov    %eax,%ebx
	int pid=clone(start_routine,arg,stack); //system call for kernel thread
 87f:	50                   	push   %eax
 880:	ff 75 0c             	pushl  0xc(%ebp)
 883:	ff 75 08             	pushl  0x8(%ebp)
 886:	e8 bf fa ff ff       	call   34a <clone>
 88b:	b9 60 0d 00 00       	mov    $0xd60,%ecx
 890:	83 c4 10             	add    $0x10,%esp
	for(i=0;i<NTHREAD;i++){
 893:	31 d2                	xor    %edx,%edx
		if(threads[i].used==0){
 895:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
 899:	74 15                	je     8b0 <thread_create+0x80>
	for(i=0;i<NTHREAD;i++){
 89b:	83 c2 01             	add    $0x1,%edx
 89e:	83 c1 0c             	add    $0xc,%ecx
 8a1:	83 fa 04             	cmp    $0x4,%edx
 8a4:	75 ef                	jne    895 <thread_create+0x65>
	add_thread(&pid,stack);//save new thread to thread table
	return pid;
}
 8a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 8a9:	c9                   	leave  
 8aa:	c3                   	ret    
 8ab:	90                   	nop
 8ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			threads[i].pid=*pid;
 8b0:	8d 14 52             	lea    (%edx,%edx,2),%edx
 8b3:	c1 e2 02             	shl    $0x2,%edx
			threads[i].ustack=ustack;
 8b6:	89 9a 64 0d 00 00    	mov    %ebx,0xd64(%edx)
			threads[i].pid=*pid;
 8bc:	89 82 60 0d 00 00    	mov    %eax,0xd60(%edx)
			threads[i].used=1;
 8c2:	c7 82 68 0d 00 00 01 	movl   $0x1,0xd68(%edx)
 8c9:	00 00 00 
}
 8cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 8cf:	c9                   	leave  
 8d0:	c3                   	ret    
 8d1:	eb 0d                	jmp    8e0 <thread_join>
 8d3:	90                   	nop
 8d4:	90                   	nop
 8d5:	90                   	nop
 8d6:	90                   	nop
 8d7:	90                   	nop
 8d8:	90                   	nop
 8d9:	90                   	nop
 8da:	90                   	nop
 8db:	90                   	nop
 8dc:	90                   	nop
 8dd:	90                   	nop
 8de:	90                   	nop
 8df:	90                   	nop

000008e0 <thread_join>:

int thread_join(void){
 8e0:	55                   	push   %ebp
 8e1:	89 e5                	mov    %esp,%ebp
 8e3:	53                   	push   %ebx
 8e4:	bb 60 0d 00 00       	mov    $0xd60,%ebx
 8e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for(i=0;i<NTHREAD;i++){
		if(threads[i].used==1){
 8ec:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
 8f0:	74 16                	je     908 <thread_join+0x28>
 8f2:	83 c3 0c             	add    $0xc,%ebx
	for(i=0;i<NTHREAD;i++){
 8f5:	81 fb 90 0d 00 00    	cmp    $0xd90,%ebx
 8fb:	75 ef                	jne    8ec <thread_join+0xc>
				remove_thread(&pid);
				return pid;
			}
		}
	}
	return 0;
 8fd:	31 c0                	xor    %eax,%eax
}
 8ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 902:	c9                   	leave  
 903:	c3                   	ret    
 904:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
			int pid=join(&threads[i].ustack);  //回收子线程
 908:	8d 43 04             	lea    0x4(%ebx),%eax
 90b:	83 ec 0c             	sub    $0xc,%esp
 90e:	50                   	push   %eax
 90f:	e8 3e fa ff ff       	call   352 <join>
			if(pid>0){
 914:	83 c4 10             	add    $0x10,%esp
 917:	85 c0                	test   %eax,%eax
			int pid=join(&threads[i].ustack);  //回收子线程
 919:	89 45 f4             	mov    %eax,-0xc(%ebp)
			if(pid>0){
 91c:	7e d4                	jle    8f2 <thread_join+0x12>
				remove_thread(&pid);
 91e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 921:	83 ec 0c             	sub    $0xc,%esp
 924:	50                   	push   %eax
 925:	e8 96 fe ff ff       	call   7c0 <remove_thread>
				return pid;
 92a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92d:	83 c4 10             	add    $0x10,%esp
 930:	eb cd                	jmp    8ff <thread_join+0x1f>
 932:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 939:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000940 <printTCB>:

void printTCB(void){
 940:	55                   	push   %ebp
 941:	89 e5                	mov    %esp,%ebp
 943:	53                   	push   %ebx
	int i;
	for(i=0;i<NTHREAD;i++)
 944:	31 db                	xor    %ebx,%ebx
void printTCB(void){
 946:	83 ec 04             	sub    $0x4,%esp
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 949:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 94c:	ff 34 85 68 0d 00 00 	pushl  0xd68(,%eax,4)
 953:	53                   	push   %ebx
	for(i=0;i<NTHREAD;i++)
 954:	83 c3 01             	add    $0x1,%ebx
		printf(1,"TCB %d: %d\n",i,threads[i].used);
 957:	68 a1 09 00 00       	push   $0x9a1
 95c:	6a 01                	push   $0x1
 95e:	e8 ad fa ff ff       	call   410 <printf>
	for(i=0;i<NTHREAD;i++)
 963:	83 c4 10             	add    $0x10,%esp
 966:	83 fb 04             	cmp    $0x4,%ebx
 969:	75 de                	jne    949 <printTCB+0x9>
}
 96b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 96e:	c9                   	leave  
 96f:	c3                   	ret    

00000970 <add>:

int add(int a,int b)
{ 
 970:	55                   	push   %ebp
 971:	89 e5                	mov    %esp,%ebp
	return a+b;
 973:	8b 45 0c             	mov    0xc(%ebp),%eax
 976:	03 45 08             	add    0x8(%ebp),%eax
 979:	5d                   	pop    %ebp
 97a:	c3                   	ret    
