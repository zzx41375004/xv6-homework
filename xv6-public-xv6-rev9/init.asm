
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   f:	83 ec 08             	sub    $0x8,%esp
  12:	6a 02                	push   $0x2
  14:	68 20 0a 00 00       	push   $0xa20
  19:	e8 64 03 00 00       	call   382 <open>
  1e:	83 c4 10             	add    $0x10,%esp
  21:	85 c0                	test   %eax,%eax
  23:	0f 88 9f 00 00 00    	js     c8 <main+0xc8>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  29:	83 ec 0c             	sub    $0xc,%esp
  2c:	6a 00                	push   $0x0
  2e:	e8 87 03 00 00       	call   3ba <dup>
  dup(0);  // stderr
  33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  3a:	e8 7b 03 00 00       	call   3ba <dup>
  3f:	83 c4 10             	add    $0x10,%esp
  42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  for(;;){
    printf(1, "init: starting sh\n");
  48:	83 ec 08             	sub    $0x8,%esp
  4b:	68 28 0a 00 00       	push   $0xa28
  50:	6a 01                	push   $0x1
  52:	e8 69 04 00 00       	call   4c0 <printf>
    pid = fork();
  57:	e8 de 02 00 00       	call   33a <fork>
    if(pid < 0){
  5c:	83 c4 10             	add    $0x10,%esp
  5f:	85 c0                	test   %eax,%eax
    pid = fork();
  61:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  63:	78 2c                	js     91 <main+0x91>
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
  65:	74 3d                	je     a4 <main+0xa4>
  67:	89 f6                	mov    %esi,%esi
  69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  70:	e8 d5 02 00 00       	call   34a <wait>
  75:	85 c0                	test   %eax,%eax
  77:	78 cf                	js     48 <main+0x48>
  79:	39 c3                	cmp    %eax,%ebx
  7b:	74 cb                	je     48 <main+0x48>
      printf(1, "zombie!\n");
  7d:	83 ec 08             	sub    $0x8,%esp
  80:	68 67 0a 00 00       	push   $0xa67
  85:	6a 01                	push   $0x1
  87:	e8 34 04 00 00       	call   4c0 <printf>
  8c:	83 c4 10             	add    $0x10,%esp
  8f:	eb df                	jmp    70 <main+0x70>
      printf(1, "init: fork failed\n");
  91:	53                   	push   %ebx
  92:	53                   	push   %ebx
  93:	68 3b 0a 00 00       	push   $0xa3b
  98:	6a 01                	push   $0x1
  9a:	e8 21 04 00 00       	call   4c0 <printf>
      exit();
  9f:	e8 9e 02 00 00       	call   342 <exit>
      exec("sh", argv);
  a4:	50                   	push   %eax
  a5:	50                   	push   %eax
  a6:	68 f4 0d 00 00       	push   $0xdf4
  ab:	68 4e 0a 00 00       	push   $0xa4e
  b0:	e8 c5 02 00 00       	call   37a <exec>
      printf(1, "init: exec sh failed\n");
  b5:	5a                   	pop    %edx
  b6:	59                   	pop    %ecx
  b7:	68 51 0a 00 00       	push   $0xa51
  bc:	6a 01                	push   $0x1
  be:	e8 fd 03 00 00       	call   4c0 <printf>
      exit();
  c3:	e8 7a 02 00 00       	call   342 <exit>
    mknod("console", 1, 1);
  c8:	50                   	push   %eax
  c9:	6a 01                	push   $0x1
  cb:	6a 01                	push   $0x1
  cd:	68 20 0a 00 00       	push   $0xa20
  d2:	e8 b3 02 00 00       	call   38a <mknod>
    open("console", O_RDWR);
  d7:	58                   	pop    %eax
  d8:	5a                   	pop    %edx
  d9:	6a 02                	push   $0x2
  db:	68 20 0a 00 00       	push   $0xa20
  e0:	e8 9d 02 00 00       	call   382 <open>
  e5:	83 c4 10             	add    $0x10,%esp
  e8:	e9 3c ff ff ff       	jmp    29 <main+0x29>
  ed:	66 90                	xchg   %ax,%ax
  ef:	90                   	nop

000000f0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	53                   	push   %ebx
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fa:	89 c2                	mov    %eax,%edx
  fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 100:	83 c1 01             	add    $0x1,%ecx
 103:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
 107:	83 c2 01             	add    $0x1,%edx
 10a:	84 db                	test   %bl,%bl
 10c:	88 5a ff             	mov    %bl,-0x1(%edx)
 10f:	75 ef                	jne    100 <strcpy+0x10>
    ;
  return os;
}
 111:	5b                   	pop    %ebx
 112:	5d                   	pop    %ebp
 113:	c3                   	ret    
 114:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 11a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000120 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	53                   	push   %ebx
 124:	8b 55 08             	mov    0x8(%ebp),%edx
 127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
 12a:	0f b6 02             	movzbl (%edx),%eax
 12d:	0f b6 19             	movzbl (%ecx),%ebx
 130:	84 c0                	test   %al,%al
 132:	75 1c                	jne    150 <strcmp+0x30>
 134:	eb 2a                	jmp    160 <strcmp+0x40>
 136:	8d 76 00             	lea    0x0(%esi),%esi
 139:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    p++, q++;
 140:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 143:	0f b6 02             	movzbl (%edx),%eax
    p++, q++;
 146:	83 c1 01             	add    $0x1,%ecx
 149:	0f b6 19             	movzbl (%ecx),%ebx
  while(*p && *p == *q)
 14c:	84 c0                	test   %al,%al
 14e:	74 10                	je     160 <strcmp+0x40>
 150:	38 d8                	cmp    %bl,%al
 152:	74 ec                	je     140 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
 154:	29 d8                	sub    %ebx,%eax
}
 156:	5b                   	pop    %ebx
 157:	5d                   	pop    %ebp
 158:	c3                   	ret    
 159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 160:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
 162:	29 d8                	sub    %ebx,%eax
}
 164:	5b                   	pop    %ebx
 165:	5d                   	pop    %ebp
 166:	c3                   	ret    
 167:	89 f6                	mov    %esi,%esi
 169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000170 <strlen>:

uint
strlen(char *s)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 176:	80 39 00             	cmpb   $0x0,(%ecx)
 179:	74 15                	je     190 <strlen+0x20>
 17b:	31 d2                	xor    %edx,%edx
 17d:	8d 76 00             	lea    0x0(%esi),%esi
 180:	83 c2 01             	add    $0x1,%edx
 183:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 187:	89 d0                	mov    %edx,%eax
 189:	75 f5                	jne    180 <strlen+0x10>
    ;
  return n;
}
 18b:	5d                   	pop    %ebp
 18c:	c3                   	ret    
 18d:	8d 76 00             	lea    0x0(%esi),%esi
  for(n = 0; s[n]; n++)
 190:	31 c0                	xor    %eax,%eax
}
 192:	5d                   	pop    %ebp
 193:	c3                   	ret    
 194:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 19a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

000001a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	57                   	push   %edi
 1a4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ad:	89 d7                	mov    %edx,%edi
 1af:	fc                   	cld    
 1b0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1b2:	89 d0                	mov    %edx,%eax
 1b4:	5f                   	pop    %edi
 1b5:	5d                   	pop    %ebp
 1b6:	c3                   	ret    
 1b7:	89 f6                	mov    %esi,%esi
 1b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001c0 <strchr>:

char*
strchr(const char *s, char c)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	53                   	push   %ebx
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
 1c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for(; *s; s++)
 1ca:	0f b6 10             	movzbl (%eax),%edx
 1cd:	84 d2                	test   %dl,%dl
 1cf:	74 1d                	je     1ee <strchr+0x2e>
    if(*s == c)
 1d1:	38 d3                	cmp    %dl,%bl
 1d3:	89 d9                	mov    %ebx,%ecx
 1d5:	75 0d                	jne    1e4 <strchr+0x24>
 1d7:	eb 17                	jmp    1f0 <strchr+0x30>
 1d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 1e0:	38 ca                	cmp    %cl,%dl
 1e2:	74 0c                	je     1f0 <strchr+0x30>
  for(; *s; s++)
 1e4:	83 c0 01             	add    $0x1,%eax
 1e7:	0f b6 10             	movzbl (%eax),%edx
 1ea:	84 d2                	test   %dl,%dl
 1ec:	75 f2                	jne    1e0 <strchr+0x20>
      return (char*)s;
  return 0;
 1ee:	31 c0                	xor    %eax,%eax
}
 1f0:	5b                   	pop    %ebx
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    
 1f3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 1f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000200 <gets>:

char*
gets(char *buf, int max)
{
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
 203:	57                   	push   %edi
 204:	56                   	push   %esi
 205:	53                   	push   %ebx
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 206:	31 f6                	xor    %esi,%esi
 208:	89 f3                	mov    %esi,%ebx
{
 20a:	83 ec 1c             	sub    $0x1c,%esp
 20d:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 210:	eb 2f                	jmp    241 <gets+0x41>
 212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 218:	8d 45 e7             	lea    -0x19(%ebp),%eax
 21b:	83 ec 04             	sub    $0x4,%esp
 21e:	6a 01                	push   $0x1
 220:	50                   	push   %eax
 221:	6a 00                	push   $0x0
 223:	e8 32 01 00 00       	call   35a <read>
    if(cc < 1)
 228:	83 c4 10             	add    $0x10,%esp
 22b:	85 c0                	test   %eax,%eax
 22d:	7e 1c                	jle    24b <gets+0x4b>
      break;
    buf[i++] = c;
 22f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 233:	83 c7 01             	add    $0x1,%edi
 236:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 239:	3c 0a                	cmp    $0xa,%al
 23b:	74 23                	je     260 <gets+0x60>
 23d:	3c 0d                	cmp    $0xd,%al
 23f:	74 1f                	je     260 <gets+0x60>
  for(i=0; i+1 < max; ){
 241:	83 c3 01             	add    $0x1,%ebx
 244:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 247:	89 fe                	mov    %edi,%esi
 249:	7c cd                	jl     218 <gets+0x18>
 24b:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 250:	c6 03 00             	movb   $0x0,(%ebx)
}
 253:	8d 65 f4             	lea    -0xc(%ebp),%esp
 256:	5b                   	pop    %ebx
 257:	5e                   	pop    %esi
 258:	5f                   	pop    %edi
 259:	5d                   	pop    %ebp
 25a:	c3                   	ret    
 25b:	90                   	nop
 25c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 260:	8b 75 08             	mov    0x8(%ebp),%esi
 263:	8b 45 08             	mov    0x8(%ebp),%eax
 266:	01 de                	add    %ebx,%esi
 268:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 26a:	c6 03 00             	movb   $0x0,(%ebx)
}
 26d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 270:	5b                   	pop    %ebx
 271:	5e                   	pop    %esi
 272:	5f                   	pop    %edi
 273:	5d                   	pop    %ebp
 274:	c3                   	ret    
 275:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000280 <stat>:

int
stat(char *n, struct stat *st)
{
 280:	55                   	push   %ebp
 281:	89 e5                	mov    %esp,%ebp
 283:	56                   	push   %esi
 284:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 285:	83 ec 08             	sub    $0x8,%esp
 288:	6a 00                	push   $0x0
 28a:	ff 75 08             	pushl  0x8(%ebp)
 28d:	e8 f0 00 00 00       	call   382 <open>
  if(fd < 0)
 292:	83 c4 10             	add    $0x10,%esp
 295:	85 c0                	test   %eax,%eax
 297:	78 27                	js     2c0 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 299:	83 ec 08             	sub    $0x8,%esp
 29c:	ff 75 0c             	pushl  0xc(%ebp)
 29f:	89 c3                	mov    %eax,%ebx
 2a1:	50                   	push   %eax
 2a2:	e8 f3 00 00 00       	call   39a <fstat>
  close(fd);
 2a7:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 2aa:	89 c6                	mov    %eax,%esi
  close(fd);
 2ac:	e8 b9 00 00 00       	call   36a <close>
  return r;
 2b1:	83 c4 10             	add    $0x10,%esp
}
 2b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
 2b7:	89 f0                	mov    %esi,%eax
 2b9:	5b                   	pop    %ebx
 2ba:	5e                   	pop    %esi
 2bb:	5d                   	pop    %ebp
 2bc:	c3                   	ret    
 2bd:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 2c0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 2c5:	eb ed                	jmp    2b4 <stat+0x34>
 2c7:	89 f6                	mov    %esi,%esi
 2c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000002d0 <atoi>:

int
atoi(const char *s)
{
 2d0:	55                   	push   %ebp
 2d1:	89 e5                	mov    %esp,%ebp
 2d3:	53                   	push   %ebx
 2d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d7:	0f be 11             	movsbl (%ecx),%edx
 2da:	8d 42 d0             	lea    -0x30(%edx),%eax
 2dd:	3c 09                	cmp    $0x9,%al
  n = 0;
 2df:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 2e4:	77 1f                	ja     305 <atoi+0x35>
 2e6:	8d 76 00             	lea    0x0(%esi),%esi
 2e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    n = n*10 + *s++ - '0';
 2f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
 2f3:	83 c1 01             	add    $0x1,%ecx
 2f6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
  while('0' <= *s && *s <= '9')
 2fa:	0f be 11             	movsbl (%ecx),%edx
 2fd:	8d 5a d0             	lea    -0x30(%edx),%ebx
 300:	80 fb 09             	cmp    $0x9,%bl
 303:	76 eb                	jbe    2f0 <atoi+0x20>
  return n;
}
 305:	5b                   	pop    %ebx
 306:	5d                   	pop    %ebp
 307:	c3                   	ret    
 308:	90                   	nop
 309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000310 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 310:	55                   	push   %ebp
 311:	89 e5                	mov    %esp,%ebp
 313:	56                   	push   %esi
 314:	53                   	push   %ebx
 315:	8b 5d 10             	mov    0x10(%ebp),%ebx
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 31e:	85 db                	test   %ebx,%ebx
 320:	7e 14                	jle    336 <memmove+0x26>
 322:	31 d2                	xor    %edx,%edx
 324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *dst++ = *src++;
 328:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 32c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 32f:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0)
 332:	39 d3                	cmp    %edx,%ebx
 334:	75 f2                	jne    328 <memmove+0x18>
  return vdst;
}
 336:	5b                   	pop    %ebx
 337:	5e                   	pop    %esi
 338:	5d                   	pop    %ebp
 339:	c3                   	ret    

0000033a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 33a:	b8 01 00 00 00       	mov    $0x1,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <exit>:
SYSCALL(exit)
 342:	b8 02 00 00 00       	mov    $0x2,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <wait>:
SYSCALL(wait)
 34a:	b8 03 00 00 00       	mov    $0x3,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <pipe>:
SYSCALL(pipe)
 352:	b8 04 00 00 00       	mov    $0x4,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <read>:
SYSCALL(read)
 35a:	b8 05 00 00 00       	mov    $0x5,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <write>:
SYSCALL(write)
 362:	b8 10 00 00 00       	mov    $0x10,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <close>:
SYSCALL(close)
 36a:	b8 15 00 00 00       	mov    $0x15,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <kill>:
SYSCALL(kill)
 372:	b8 06 00 00 00       	mov    $0x6,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <exec>:
SYSCALL(exec)
 37a:	b8 07 00 00 00       	mov    $0x7,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <open>:
SYSCALL(open)
 382:	b8 0f 00 00 00       	mov    $0xf,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <mknod>:
SYSCALL(mknod)
 38a:	b8 11 00 00 00       	mov    $0x11,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <unlink>:
SYSCALL(unlink)
 392:	b8 12 00 00 00       	mov    $0x12,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <fstat>:
SYSCALL(fstat)
 39a:	b8 08 00 00 00       	mov    $0x8,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <link>:
SYSCALL(link)
 3a2:	b8 13 00 00 00       	mov    $0x13,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <mkdir>:
SYSCALL(mkdir)
 3aa:	b8 14 00 00 00       	mov    $0x14,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <chdir>:
SYSCALL(chdir)
 3b2:	b8 09 00 00 00       	mov    $0x9,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <dup>:
SYSCALL(dup)
 3ba:	b8 0a 00 00 00       	mov    $0xa,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <getpid>:
SYSCALL(getpid)
 3c2:	b8 0b 00 00 00       	mov    $0xb,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <getcpuid>:
SYSCALL(getcpuid)
 3ca:	b8 16 00 00 00       	mov    $0x16,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <sbrk>:
SYSCALL(sbrk)
 3d2:	b8 0c 00 00 00       	mov    $0xc,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <sleep>:
SYSCALL(sleep)
 3da:	b8 0d 00 00 00       	mov    $0xd,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <uptime>:
SYSCALL(uptime)
 3e2:	b8 0e 00 00 00       	mov    $0xe,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <myalloc>:
SYSCALL(myalloc)
 3ea:	b8 17 00 00 00       	mov    $0x17,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <myfree>:
SYSCALL(myfree)
 3f2:	b8 18 00 00 00       	mov    $0x18,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <clone>:
SYSCALL(clone)
 3fa:	b8 19 00 00 00       	mov    $0x19,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <join>:
SYSCALL(join)
 402:	b8 1a 00 00 00       	mov    $0x1a,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <cps>:
SYSCALL(cps)
 40a:	b8 1b 00 00 00       	mov    $0x1b,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <chpri>:
SYSCALL(chpri)
 412:	b8 1c 00 00 00       	mov    $0x1c,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    
 41a:	66 90                	xchg   %ax,%ax
 41c:	66 90                	xchg   %ax,%ax
 41e:	66 90                	xchg   %ax,%ax

00000420 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 420:	55                   	push   %ebp
 421:	89 e5                	mov    %esp,%ebp
 423:	57                   	push   %edi
 424:	56                   	push   %esi
 425:	53                   	push   %ebx
 426:	83 ec 3c             	sub    $0x3c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 429:	85 d2                	test   %edx,%edx
{
 42b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    neg = 1;
    x = -xx;
 42e:	89 d0                	mov    %edx,%eax
  if(sgn && xx < 0){
 430:	79 76                	jns    4a8 <printint+0x88>
 432:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 436:	74 70                	je     4a8 <printint+0x88>
    x = -xx;
 438:	f7 d8                	neg    %eax
    neg = 1;
 43a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 441:	31 f6                	xor    %esi,%esi
 443:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 446:	eb 0a                	jmp    452 <printint+0x32>
 448:	90                   	nop
 449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  do{
    buf[i++] = digits[x % base];
 450:	89 fe                	mov    %edi,%esi
 452:	31 d2                	xor    %edx,%edx
 454:	8d 7e 01             	lea    0x1(%esi),%edi
 457:	f7 f1                	div    %ecx
 459:	0f b6 92 78 0a 00 00 	movzbl 0xa78(%edx),%edx
  }while((x /= base) != 0);
 460:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
 462:	88 14 3b             	mov    %dl,(%ebx,%edi,1)
  }while((x /= base) != 0);
 465:	75 e9                	jne    450 <printint+0x30>
  if(neg)
 467:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 46a:	85 c0                	test   %eax,%eax
 46c:	74 08                	je     476 <printint+0x56>
    buf[i++] = '-';
 46e:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
 473:	8d 7e 02             	lea    0x2(%esi),%edi
 476:	8d 74 3d d7          	lea    -0x29(%ebp,%edi,1),%esi
 47a:	8b 7d c0             	mov    -0x40(%ebp),%edi
 47d:	8d 76 00             	lea    0x0(%esi),%esi
 480:	0f b6 06             	movzbl (%esi),%eax
  write(fd, &c, 1);
 483:	83 ec 04             	sub    $0x4,%esp
 486:	83 ee 01             	sub    $0x1,%esi
 489:	6a 01                	push   $0x1
 48b:	53                   	push   %ebx
 48c:	57                   	push   %edi
 48d:	88 45 d7             	mov    %al,-0x29(%ebp)
 490:	e8 cd fe ff ff       	call   362 <write>

  while(--i >= 0)
 495:	83 c4 10             	add    $0x10,%esp
 498:	39 de                	cmp    %ebx,%esi
 49a:	75 e4                	jne    480 <printint+0x60>
    putc(fd, buf[i]);
}
 49c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 49f:	5b                   	pop    %ebx
 4a0:	5e                   	pop    %esi
 4a1:	5f                   	pop    %edi
 4a2:	5d                   	pop    %ebp
 4a3:	c3                   	ret    
 4a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 4a8:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 4af:	eb 90                	jmp    441 <printint+0x21>
 4b1:	eb 0d                	jmp    4c0 <printf>
 4b3:	90                   	nop
 4b4:	90                   	nop
 4b5:	90                   	nop
 4b6:	90                   	nop
 4b7:	90                   	nop
 4b8:	90                   	nop
 4b9:	90                   	nop
 4ba:	90                   	nop
 4bb:	90                   	nop
 4bc:	90                   	nop
 4bd:	90                   	nop
 4be:	90                   	nop
 4bf:	90                   	nop

000004c0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
 4c3:	57                   	push   %edi
 4c4:	56                   	push   %esi
 4c5:	53                   	push   %ebx
 4c6:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4c9:	8b 75 0c             	mov    0xc(%ebp),%esi
 4cc:	0f b6 1e             	movzbl (%esi),%ebx
 4cf:	84 db                	test   %bl,%bl
 4d1:	0f 84 b3 00 00 00    	je     58a <printf+0xca>
  ap = (uint*)(void*)&fmt + 1;
 4d7:	8d 45 10             	lea    0x10(%ebp),%eax
 4da:	83 c6 01             	add    $0x1,%esi
  state = 0;
 4dd:	31 ff                	xor    %edi,%edi
  ap = (uint*)(void*)&fmt + 1;
 4df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 4e2:	eb 2f                	jmp    513 <printf+0x53>
 4e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 4e8:	83 f8 25             	cmp    $0x25,%eax
 4eb:	0f 84 a7 00 00 00    	je     598 <printf+0xd8>
  write(fd, &c, 1);
 4f1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 4f4:	83 ec 04             	sub    $0x4,%esp
 4f7:	88 5d e2             	mov    %bl,-0x1e(%ebp)
 4fa:	6a 01                	push   $0x1
 4fc:	50                   	push   %eax
 4fd:	ff 75 08             	pushl  0x8(%ebp)
 500:	e8 5d fe ff ff       	call   362 <write>
 505:	83 c4 10             	add    $0x10,%esp
 508:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 50b:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 50f:	84 db                	test   %bl,%bl
 511:	74 77                	je     58a <printf+0xca>
    if(state == 0){
 513:	85 ff                	test   %edi,%edi
    c = fmt[i] & 0xff;
 515:	0f be cb             	movsbl %bl,%ecx
 518:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 51b:	74 cb                	je     4e8 <printf+0x28>
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 51d:	83 ff 25             	cmp    $0x25,%edi
 520:	75 e6                	jne    508 <printf+0x48>
      if(c == 'd'){
 522:	83 f8 64             	cmp    $0x64,%eax
 525:	0f 84 05 01 00 00    	je     630 <printf+0x170>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 52b:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 531:	83 f9 70             	cmp    $0x70,%ecx
 534:	74 72                	je     5a8 <printf+0xe8>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 536:	83 f8 73             	cmp    $0x73,%eax
 539:	0f 84 99 00 00 00    	je     5d8 <printf+0x118>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 53f:	83 f8 63             	cmp    $0x63,%eax
 542:	0f 84 08 01 00 00    	je     650 <printf+0x190>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 548:	83 f8 25             	cmp    $0x25,%eax
 54b:	0f 84 ef 00 00 00    	je     640 <printf+0x180>
  write(fd, &c, 1);
 551:	8d 45 e7             	lea    -0x19(%ebp),%eax
 554:	83 ec 04             	sub    $0x4,%esp
 557:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 55b:	6a 01                	push   $0x1
 55d:	50                   	push   %eax
 55e:	ff 75 08             	pushl  0x8(%ebp)
 561:	e8 fc fd ff ff       	call   362 <write>
 566:	83 c4 0c             	add    $0xc,%esp
 569:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 56c:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 56f:	6a 01                	push   $0x1
 571:	50                   	push   %eax
 572:	ff 75 08             	pushl  0x8(%ebp)
 575:	83 c6 01             	add    $0x1,%esi
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 578:	31 ff                	xor    %edi,%edi
  write(fd, &c, 1);
 57a:	e8 e3 fd ff ff       	call   362 <write>
  for(i = 0; fmt[i]; i++){
 57f:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
  write(fd, &c, 1);
 583:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 586:	84 db                	test   %bl,%bl
 588:	75 89                	jne    513 <printf+0x53>
    }
  }
}
 58a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 58d:	5b                   	pop    %ebx
 58e:	5e                   	pop    %esi
 58f:	5f                   	pop    %edi
 590:	5d                   	pop    %ebp
 591:	c3                   	ret    
 592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        state = '%';
 598:	bf 25 00 00 00       	mov    $0x25,%edi
 59d:	e9 66 ff ff ff       	jmp    508 <printf+0x48>
 5a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printint(fd, *ap, 16, 0);
 5a8:	83 ec 0c             	sub    $0xc,%esp
 5ab:	b9 10 00 00 00       	mov    $0x10,%ecx
 5b0:	6a 00                	push   $0x0
 5b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 5b5:	8b 45 08             	mov    0x8(%ebp),%eax
 5b8:	8b 17                	mov    (%edi),%edx
 5ba:	e8 61 fe ff ff       	call   420 <printint>
        ap++;
 5bf:	89 f8                	mov    %edi,%eax
 5c1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5c4:	31 ff                	xor    %edi,%edi
        ap++;
 5c6:	83 c0 04             	add    $0x4,%eax
 5c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 5cc:	e9 37 ff ff ff       	jmp    508 <printf+0x48>
 5d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = (char*)*ap;
 5d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 5db:	8b 08                	mov    (%eax),%ecx
        ap++;
 5dd:	83 c0 04             	add    $0x4,%eax
 5e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(s == 0)
 5e3:	85 c9                	test   %ecx,%ecx
 5e5:	0f 84 8e 00 00 00    	je     679 <printf+0x1b9>
        while(*s != 0){
 5eb:	0f b6 01             	movzbl (%ecx),%eax
      state = 0;
 5ee:	31 ff                	xor    %edi,%edi
        s = (char*)*ap;
 5f0:	89 cb                	mov    %ecx,%ebx
        while(*s != 0){
 5f2:	84 c0                	test   %al,%al
 5f4:	0f 84 0e ff ff ff    	je     508 <printf+0x48>
 5fa:	89 75 d0             	mov    %esi,-0x30(%ebp)
 5fd:	89 de                	mov    %ebx,%esi
 5ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
 602:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 605:	8d 76 00             	lea    0x0(%esi),%esi
  write(fd, &c, 1);
 608:	83 ec 04             	sub    $0x4,%esp
          s++;
 60b:	83 c6 01             	add    $0x1,%esi
 60e:	88 45 e3             	mov    %al,-0x1d(%ebp)
  write(fd, &c, 1);
 611:	6a 01                	push   $0x1
 613:	57                   	push   %edi
 614:	53                   	push   %ebx
 615:	e8 48 fd ff ff       	call   362 <write>
        while(*s != 0){
 61a:	0f b6 06             	movzbl (%esi),%eax
 61d:	83 c4 10             	add    $0x10,%esp
 620:	84 c0                	test   %al,%al
 622:	75 e4                	jne    608 <printf+0x148>
 624:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 627:	31 ff                	xor    %edi,%edi
 629:	e9 da fe ff ff       	jmp    508 <printf+0x48>
 62e:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 10, 1);
 630:	83 ec 0c             	sub    $0xc,%esp
 633:	b9 0a 00 00 00       	mov    $0xa,%ecx
 638:	6a 01                	push   $0x1
 63a:	e9 73 ff ff ff       	jmp    5b2 <printf+0xf2>
 63f:	90                   	nop
  write(fd, &c, 1);
 640:	83 ec 04             	sub    $0x4,%esp
 643:	88 5d e5             	mov    %bl,-0x1b(%ebp)
 646:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 649:	6a 01                	push   $0x1
 64b:	e9 21 ff ff ff       	jmp    571 <printf+0xb1>
        putc(fd, *ap);
 650:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  write(fd, &c, 1);
 653:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 656:	8b 07                	mov    (%edi),%eax
  write(fd, &c, 1);
 658:	6a 01                	push   $0x1
        ap++;
 65a:	83 c7 04             	add    $0x4,%edi
        putc(fd, *ap);
 65d:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 660:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 663:	50                   	push   %eax
 664:	ff 75 08             	pushl  0x8(%ebp)
 667:	e8 f6 fc ff ff       	call   362 <write>
        ap++;
 66c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 66f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 672:	31 ff                	xor    %edi,%edi
 674:	e9 8f fe ff ff       	jmp    508 <printf+0x48>
          s = "(null)";
 679:	bb 70 0a 00 00       	mov    $0xa70,%ebx
        while(*s != 0){
 67e:	b8 28 00 00 00       	mov    $0x28,%eax
 683:	e9 72 ff ff ff       	jmp    5fa <printf+0x13a>
 688:	66 90                	xchg   %ax,%ax
 68a:	66 90                	xchg   %ax,%ax
 68c:	66 90                	xchg   %ax,%ax
 68e:	66 90                	xchg   %ax,%ax

00000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 691:	a1 00 0e 00 00       	mov    0xe00,%eax
{
 696:	89 e5                	mov    %esp,%ebp
 698:	57                   	push   %edi
 699:	56                   	push   %esi
 69a:	53                   	push   %ebx
 69b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 69e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
 6a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a8:	39 c8                	cmp    %ecx,%eax
 6aa:	8b 10                	mov    (%eax),%edx
 6ac:	73 32                	jae    6e0 <free+0x50>
 6ae:	39 d1                	cmp    %edx,%ecx
 6b0:	72 04                	jb     6b6 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b2:	39 d0                	cmp    %edx,%eax
 6b4:	72 32                	jb     6e8 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6b6:	8b 73 fc             	mov    -0x4(%ebx),%esi
 6b9:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6bc:	39 fa                	cmp    %edi,%edx
 6be:	74 30                	je     6f0 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6c0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6c3:	8b 50 04             	mov    0x4(%eax),%edx
 6c6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6c9:	39 f1                	cmp    %esi,%ecx
 6cb:	74 3a                	je     707 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6cd:	89 08                	mov    %ecx,(%eax)
  freep = p;
 6cf:	a3 00 0e 00 00       	mov    %eax,0xe00
}
 6d4:	5b                   	pop    %ebx
 6d5:	5e                   	pop    %esi
 6d6:	5f                   	pop    %edi
 6d7:	5d                   	pop    %ebp
 6d8:	c3                   	ret    
 6d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e0:	39 d0                	cmp    %edx,%eax
 6e2:	72 04                	jb     6e8 <free+0x58>
 6e4:	39 d1                	cmp    %edx,%ecx
 6e6:	72 ce                	jb     6b6 <free+0x26>
{
 6e8:	89 d0                	mov    %edx,%eax
 6ea:	eb bc                	jmp    6a8 <free+0x18>
 6ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 6f0:	03 72 04             	add    0x4(%edx),%esi
 6f3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f6:	8b 10                	mov    (%eax),%edx
 6f8:	8b 12                	mov    (%edx),%edx
 6fa:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6fd:	8b 50 04             	mov    0x4(%eax),%edx
 700:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 703:	39 f1                	cmp    %esi,%ecx
 705:	75 c6                	jne    6cd <free+0x3d>
    p->s.size += bp->s.size;
 707:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 70a:	a3 00 0e 00 00       	mov    %eax,0xe00
    p->s.size += bp->s.size;
 70f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 712:	8b 53 f8             	mov    -0x8(%ebx),%edx
 715:	89 10                	mov    %edx,(%eax)
}
 717:	5b                   	pop    %ebx
 718:	5e                   	pop    %esi
 719:	5f                   	pop    %edi
 71a:	5d                   	pop    %ebp
 71b:	c3                   	ret    
 71c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000720 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 720:	55                   	push   %ebp
 721:	89 e5                	mov    %esp,%ebp
 723:	57                   	push   %edi
 724:	56                   	push   %esi
 725:	53                   	push   %ebx
 726:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 729:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 72c:	8b 15 00 0e 00 00    	mov    0xe00,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 732:	8d 78 07             	lea    0x7(%eax),%edi
 735:	c1 ef 03             	shr    $0x3,%edi
 738:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 73b:	85 d2                	test   %edx,%edx
 73d:	0f 84 9d 00 00 00    	je     7e0 <malloc+0xc0>
 743:	8b 02                	mov    (%edx),%eax
 745:	8b 48 04             	mov    0x4(%eax),%ecx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 748:	39 cf                	cmp    %ecx,%edi
 74a:	76 6c                	jbe    7b8 <malloc+0x98>
 74c:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
 752:	bb 00 10 00 00       	mov    $0x1000,%ebx
 757:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 75a:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 761:	eb 0e                	jmp    771 <malloc+0x51>
 763:	90                   	nop
 764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 768:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 76a:	8b 48 04             	mov    0x4(%eax),%ecx
 76d:	39 f9                	cmp    %edi,%ecx
 76f:	73 47                	jae    7b8 <malloc+0x98>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 771:	39 05 00 0e 00 00    	cmp    %eax,0xe00
 777:	89 c2                	mov    %eax,%edx
 779:	75 ed                	jne    768 <malloc+0x48>
  p = sbrk(nu * sizeof(Header));
 77b:	83 ec 0c             	sub    $0xc,%esp
 77e:	56                   	push   %esi
 77f:	e8 4e fc ff ff       	call   3d2 <sbrk>
  if(p == (char*)-1)
 784:	83 c4 10             	add    $0x10,%esp
 787:	83 f8 ff             	cmp    $0xffffffff,%eax
 78a:	74 1c                	je     7a8 <malloc+0x88>
  hp->s.size = nu;
 78c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 78f:	83 ec 0c             	sub    $0xc,%esp
 792:	83 c0 08             	add    $0x8,%eax
 795:	50                   	push   %eax
 796:	e8 f5 fe ff ff       	call   690 <free>
  return freep;
 79b:	8b 15 00 0e 00 00    	mov    0xe00,%edx
      if((p = morecore(nunits)) == 0)
 7a1:	83 c4 10             	add    $0x10,%esp
 7a4:	85 d2                	test   %edx,%edx
 7a6:	75 c0                	jne    768 <malloc+0x48>
        return 0;
  }
}
 7a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 7ab:	31 c0                	xor    %eax,%eax
}
 7ad:	5b                   	pop    %ebx
 7ae:	5e                   	pop    %esi
 7af:	5f                   	pop    %edi
 7b0:	5d                   	pop    %ebp
 7b1:	c3                   	ret    
 7b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 7b8:	39 cf                	cmp    %ecx,%edi
 7ba:	74 54                	je     810 <malloc+0xf0>
        p->s.size -= nunits;
 7bc:	29 f9                	sub    %edi,%ecx
 7be:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 7c1:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 7c4:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 7c7:	89 15 00 0e 00 00    	mov    %edx,0xe00
}
 7cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 7d0:	83 c0 08             	add    $0x8,%eax
}
 7d3:	5b                   	pop    %ebx
 7d4:	5e                   	pop    %esi
 7d5:	5f                   	pop    %edi
 7d6:	5d                   	pop    %ebp
 7d7:	c3                   	ret    
 7d8:	90                   	nop
 7d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    base.s.ptr = freep = prevp = &base;
 7e0:	c7 05 00 0e 00 00 04 	movl   $0xe04,0xe00
 7e7:	0e 00 00 
 7ea:	c7 05 04 0e 00 00 04 	movl   $0xe04,0xe04
 7f1:	0e 00 00 
    base.s.size = 0;
 7f4:	b8 04 0e 00 00       	mov    $0xe04,%eax
 7f9:	c7 05 08 0e 00 00 00 	movl   $0x0,0xe08
 800:	00 00 00 
 803:	e9 44 ff ff ff       	jmp    74c <malloc+0x2c>
 808:	90                   	nop
 809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        prevp->s.ptr = p->s.ptr;
 810:	8b 08                	mov    (%eax),%ecx
 812:	89 0a                	mov    %ecx,(%edx)
 814:	eb b1                	jmp    7c7 <malloc+0xa7>
 816:	66 90                	xchg   %ax,%ax
 818:	66 90                	xchg   %ax,%ax
 81a:	66 90                	xchg   %ax,%ax
 81c:	66 90                	xchg   %ax,%ax
 81e:	66 90                	xchg   %ax,%ax

00000820 <add_thread>:
    int pid;
    void *ustack;
    int used;
}threads[NTHREAD];

void add_thread(int* pid, void* ustack){
 820:	ba 20 0e 00 00       	mov    $0xe20,%edx
    for (int i = 0; i < NTHREAD; ++i)
 825:	31 c0                	xor    %eax,%eax
    {
        if(threads[i].used == 0){
 827:	8b 4a 08             	mov    0x8(%edx),%ecx
 82a:	85 c9                	test   %ecx,%ecx
 82c:	74 12                	je     840 <add_thread+0x20>
    for (int i = 0; i < NTHREAD; ++i)
 82e:	83 c0 01             	add    $0x1,%eax
 831:	83 c2 0c             	add    $0xc,%edx
 834:	83 f8 04             	cmp    $0x4,%eax
 837:	75 ee                	jne    827 <add_thread+0x7>
 839:	f3 c3                	repz ret 
 83b:	90                   	nop
 83c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void add_thread(int* pid, void* ustack){
 840:	55                   	push   %ebp
            threads[i].pid = *pid;
 841:	8d 04 40             	lea    (%eax,%eax,2),%eax
void add_thread(int* pid, void* ustack){
 844:	89 e5                	mov    %esp,%ebp
            threads[i].pid = *pid;
 846:	c1 e0 02             	shl    $0x2,%eax
 849:	8b 55 08             	mov    0x8(%ebp),%edx
 84c:	8b 0a                	mov    (%edx),%ecx
 84e:	8d 90 20 0e 00 00    	lea    0xe20(%eax),%edx
            threads[i].ustack = ustack;
            threads[i].used = 1;
 854:	c7 42 08 01 00 00 00 	movl   $0x1,0x8(%edx)
            threads[i].pid = *pid;
 85b:	89 88 20 0e 00 00    	mov    %ecx,0xe20(%eax)
            threads[i].ustack = ustack;
 861:	8b 45 0c             	mov    0xc(%ebp),%eax
 864:	89 42 04             	mov    %eax,0x4(%edx)
            break;
        }
    }
}
 867:	5d                   	pop    %ebp
 868:	c3                   	ret    
 869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000870 <remove_thread>:

void remove_thread(int* pid){
 870:	55                   	push   %ebp
 871:	b8 20 0e 00 00       	mov    $0xe20,%eax
    for (int i = 0; i < NTHREAD; ++i)
 876:	31 d2                	xor    %edx,%edx
void remove_thread(int* pid){
 878:	89 e5                	mov    %esp,%ebp
 87a:	56                   	push   %esi
 87b:	53                   	push   %ebx
 87c:	8b 4d 08             	mov    0x8(%ebp),%ecx
    {
        if(threads[i].used && threads[i].pid == *pid){
 87f:	8b 58 08             	mov    0x8(%eax),%ebx
 882:	85 db                	test   %ebx,%ebx
 884:	74 06                	je     88c <remove_thread+0x1c>
 886:	8b 31                	mov    (%ecx),%esi
 888:	39 30                	cmp    %esi,(%eax)
 88a:	74 14                	je     8a0 <remove_thread+0x30>
    for (int i = 0; i < NTHREAD; ++i)
 88c:	83 c2 01             	add    $0x1,%edx
 88f:	83 c0 0c             	add    $0xc,%eax
 892:	83 fa 04             	cmp    $0x4,%edx
 895:	75 e8                	jne    87f <remove_thread+0xf>
            threads[i].ustack = 0;
            threads[i].used = 0;
            break;
        }
    }
}
 897:	8d 65 f8             	lea    -0x8(%ebp),%esp
 89a:	5b                   	pop    %ebx
 89b:	5e                   	pop    %esi
 89c:	5d                   	pop    %ebp
 89d:	c3                   	ret    
 89e:	66 90                	xchg   %ax,%ax
            free(threads[i].ustack);
 8a0:	8d 1c 52             	lea    (%edx,%edx,2),%ebx
 8a3:	83 ec 0c             	sub    $0xc,%esp
 8a6:	c1 e3 02             	shl    $0x2,%ebx
 8a9:	ff b3 24 0e 00 00    	pushl  0xe24(%ebx)
 8af:	e8 dc fd ff ff       	call   690 <free>
            threads[i].pid = 0;
 8b4:	c7 83 20 0e 00 00 00 	movl   $0x0,0xe20(%ebx)
 8bb:	00 00 00 
            threads[i].ustack = 0;
 8be:	c7 83 24 0e 00 00 00 	movl   $0x0,0xe24(%ebx)
 8c5:	00 00 00 
            break;
 8c8:	83 c4 10             	add    $0x10,%esp
            threads[i].used = 0;
 8cb:	c7 83 28 0e 00 00 00 	movl   $0x0,0xe28(%ebx)
 8d2:	00 00 00 
}
 8d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
 8d8:	5b                   	pop    %ebx
 8d9:	5e                   	pop    %esi
 8da:	5d                   	pop    %ebp
 8db:	c3                   	ret    
 8dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000008e0 <thread_create>:

int thread_create(void(*start_routine)(void*), void *arg){
 8e0:	55                   	push   %ebp
 8e1:	89 e5                	mov    %esp,%ebp
 8e3:	53                   	push   %ebx
 8e4:	83 ec 04             	sub    $0x4,%esp
    static int first = 1;
    if(first){
 8e7:	a1 fc 0d 00 00       	mov    0xdfc,%eax
 8ec:	85 c0                	test   %eax,%eax
 8ee:	74 2d                	je     91d <thread_create+0x3d>
        first = 0;
 8f0:	c7 05 fc 0d 00 00 00 	movl   $0x0,0xdfc
 8f7:	00 00 00 
 8fa:	b8 20 0e 00 00       	mov    $0xe20,%eax
        for (int i = 0; i < NTHREAD; ++i)
        {
            threads[i].pid = 0;
 8ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            threads[i].ustack = 0;
 905:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
 90c:	83 c0 0c             	add    $0xc,%eax
            threads[i].used = 0;
 90f:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)
        for (int i = 0; i < NTHREAD; ++i)
 916:	3d 50 0e 00 00       	cmp    $0xe50,%eax
 91b:	75 e2                	jne    8ff <thread_create+0x1f>
        }
    }
    void *stack = malloc(PGSIZE);
 91d:	83 ec 0c             	sub    $0xc,%esp
 920:	68 00 10 00 00       	push   $0x1000
 925:	e8 f6 fd ff ff       	call   720 <malloc>
    int pid = clone(start_routine, arg, stack);
 92a:	83 c4 0c             	add    $0xc,%esp
    void *stack = malloc(PGSIZE);
 92d:	89 c3                	mov    %eax,%ebx
    int pid = clone(start_routine, arg, stack);
 92f:	50                   	push   %eax
 930:	ff 75 0c             	pushl  0xc(%ebp)
 933:	ff 75 08             	pushl  0x8(%ebp)
 936:	e8 bf fa ff ff       	call   3fa <clone>
 93b:	b9 20 0e 00 00       	mov    $0xe20,%ecx
 940:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < NTHREAD; ++i)
 943:	31 d2                	xor    %edx,%edx
        if(threads[i].used == 0){
 945:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
 949:	74 15                	je     960 <thread_create+0x80>
    for (int i = 0; i < NTHREAD; ++i)
 94b:	83 c2 01             	add    $0x1,%edx
 94e:	83 c1 0c             	add    $0xc,%ecx
 951:	83 fa 04             	cmp    $0x4,%edx
 954:	75 ef                	jne    945 <thread_create+0x65>
    add_thread(&pid,stack);
    return pid;
}
 956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 959:	c9                   	leave  
 95a:	c3                   	ret    
 95b:	90                   	nop
 95c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
            threads[i].pid = *pid;
 960:	8d 14 52             	lea    (%edx,%edx,2),%edx
 963:	c1 e2 02             	shl    $0x2,%edx
            threads[i].ustack = ustack;
 966:	89 9a 24 0e 00 00    	mov    %ebx,0xe24(%edx)
            threads[i].pid = *pid;
 96c:	89 82 20 0e 00 00    	mov    %eax,0xe20(%edx)
            threads[i].used = 1;
 972:	c7 82 28 0e 00 00 01 	movl   $0x1,0xe28(%edx)
 979:	00 00 00 
}
 97c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 97f:	c9                   	leave  
 980:	c3                   	ret    
 981:	eb 0d                	jmp    990 <thread_join>
 983:	90                   	nop
 984:	90                   	nop
 985:	90                   	nop
 986:	90                   	nop
 987:	90                   	nop
 988:	90                   	nop
 989:	90                   	nop
 98a:	90                   	nop
 98b:	90                   	nop
 98c:	90                   	nop
 98d:	90                   	nop
 98e:	90                   	nop
 98f:	90                   	nop

00000990 <thread_join>:

int thread_join(void){
 990:	55                   	push   %ebp
 991:	89 e5                	mov    %esp,%ebp
 993:	53                   	push   %ebx
 994:	bb 20 0e 00 00       	mov    $0xe20,%ebx
 999:	83 ec 14             	sub    $0x14,%esp
    for(int i = 0; i < NTHREAD; ++i){
        if(threads[i].used == 1){
 99c:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
 9a0:	74 16                	je     9b8 <thread_join+0x28>
 9a2:	83 c3 0c             	add    $0xc,%ebx
    for(int i = 0; i < NTHREAD; ++i){
 9a5:	81 fb 50 0e 00 00    	cmp    $0xe50,%ebx
 9ab:	75 ef                	jne    99c <thread_join+0xc>
                remove_thread(&pid);
                return pid;
            }
        }
    }
    return 0;
 9ad:	31 c0                	xor    %eax,%eax
}
 9af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 9b2:	c9                   	leave  
 9b3:	c3                   	ret    
 9b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
            int pid = join(&threads[i].ustack);
 9b8:	8d 43 04             	lea    0x4(%ebx),%eax
 9bb:	83 ec 0c             	sub    $0xc,%esp
 9be:	50                   	push   %eax
 9bf:	e8 3e fa ff ff       	call   402 <join>
            if(pid > 0){
 9c4:	83 c4 10             	add    $0x10,%esp
 9c7:	85 c0                	test   %eax,%eax
            int pid = join(&threads[i].ustack);
 9c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if(pid > 0){
 9cc:	7e d4                	jle    9a2 <thread_join+0x12>
                remove_thread(&pid);
 9ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
 9d1:	83 ec 0c             	sub    $0xc,%esp
 9d4:	50                   	push   %eax
 9d5:	e8 96 fe ff ff       	call   870 <remove_thread>
                return pid;
 9da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dd:	83 c4 10             	add    $0x10,%esp
 9e0:	eb cd                	jmp    9af <thread_join+0x1f>
 9e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 9e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000009f0 <printTCB>:

void printTCB(void){
 9f0:	55                   	push   %ebp
 9f1:	89 e5                	mov    %esp,%ebp
 9f3:	53                   	push   %ebx
    for (int i = 0; i < NTHREAD; ++i)
 9f4:	31 db                	xor    %ebx,%ebx
void printTCB(void){
 9f6:	83 ec 04             	sub    $0x4,%esp
    {
        printf(1,"TCB %d:%d\n",i,threads[i].used);
 9f9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 9fc:	ff 34 85 28 0e 00 00 	pushl  0xe28(,%eax,4)
 a03:	53                   	push   %ebx
    for (int i = 0; i < NTHREAD; ++i)
 a04:	83 c3 01             	add    $0x1,%ebx
        printf(1,"TCB %d:%d\n",i,threads[i].used);
 a07:	68 89 0a 00 00       	push   $0xa89
 a0c:	6a 01                	push   $0x1
 a0e:	e8 ad fa ff ff       	call   4c0 <printf>
    for (int i = 0; i < NTHREAD; ++i)
 a13:	83 c4 10             	add    $0x10,%esp
 a16:	83 fb 04             	cmp    $0x4,%ebx
 a19:	75 de                	jne    9f9 <printTCB+0x9>
    }
    
}
 a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 a1e:	c9                   	leave  
 a1f:	c3                   	ret    
