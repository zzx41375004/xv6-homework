
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  }
}

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
  11:	be 01 00 00 00       	mov    $0x1,%esi
  16:	83 ec 18             	sub    $0x18,%esp
  19:	8b 01                	mov    (%ecx),%eax
  1b:	8b 59 04             	mov    0x4(%ecx),%ebx
  1e:	83 c3 04             	add    $0x4,%ebx
  int fd, i;

  if(argc <= 1){
  21:	83 f8 01             	cmp    $0x1,%eax
{
  24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(argc <= 1){
  27:	7e 54                	jle    7d <main+0x7d>
  29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  30:	83 ec 08             	sub    $0x8,%esp
  33:	6a 00                	push   $0x0
  35:	ff 33                	pushl  (%ebx)
  37:	e8 46 03 00 00       	call   382 <open>
  3c:	83 c4 10             	add    $0x10,%esp
  3f:	85 c0                	test   %eax,%eax
  41:	89 c7                	mov    %eax,%edi
  43:	78 24                	js     69 <main+0x69>
      printf(1, "cat: cannot open %s\n", argv[i]);
      exit();
    }
    cat(fd);
  45:	83 ec 0c             	sub    $0xc,%esp
  for(i = 1; i < argc; i++){
  48:	83 c6 01             	add    $0x1,%esi
  4b:	83 c3 04             	add    $0x4,%ebx
    cat(fd);
  4e:	50                   	push   %eax
  4f:	e8 3c 00 00 00       	call   90 <cat>
    close(fd);
  54:	89 3c 24             	mov    %edi,(%esp)
  57:	e8 0e 03 00 00       	call   36a <close>
  for(i = 1; i < argc; i++){
  5c:	83 c4 10             	add    $0x10,%esp
  5f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  62:	75 cc                	jne    30 <main+0x30>
  }
  exit();
  64:	e8 d9 02 00 00       	call   342 <exit>
      printf(1, "cat: cannot open %s\n", argv[i]);
  69:	50                   	push   %eax
  6a:	ff 33                	pushl  (%ebx)
  6c:	68 11 0a 00 00       	push   $0xa11
  71:	6a 01                	push   $0x1
  73:	e8 38 04 00 00       	call   4b0 <printf>
      exit();
  78:	e8 c5 02 00 00       	call   342 <exit>
    cat(0);
  7d:	83 ec 0c             	sub    $0xc,%esp
  80:	6a 00                	push   $0x0
  82:	e8 09 00 00 00       	call   90 <cat>
    exit();
  87:	e8 b6 02 00 00       	call   342 <exit>
  8c:	66 90                	xchg   %ax,%ax
  8e:	66 90                	xchg   %ax,%ax

00000090 <cat>:
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	53                   	push   %ebx
  94:	83 ec 04             	sub    $0x4,%esp
  97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  while((n = read(fd, buf, sizeof(buf))) > 0)
  9a:	eb 17                	jmp    b3 <cat+0x23>
  9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    write(1, buf, n);
  a0:	83 ec 04             	sub    $0x4,%esp
  a3:	50                   	push   %eax
  a4:	68 c0 0e 00 00       	push   $0xec0
  a9:	6a 01                	push   $0x1
  ab:	e8 b2 02 00 00       	call   362 <write>
  b0:	83 c4 10             	add    $0x10,%esp
  while((n = read(fd, buf, sizeof(buf))) > 0)
  b3:	83 ec 04             	sub    $0x4,%esp
  b6:	68 00 02 00 00       	push   $0x200
  bb:	68 c0 0e 00 00       	push   $0xec0
  c0:	53                   	push   %ebx
  c1:	e8 94 02 00 00       	call   35a <read>
  c6:	83 c4 10             	add    $0x10,%esp
  c9:	83 f8 00             	cmp    $0x0,%eax
  cc:	7f d2                	jg     a0 <cat+0x10>
  if(n < 0){
  ce:	75 05                	jne    d5 <cat+0x45>
}
  d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  d3:	c9                   	leave  
  d4:	c3                   	ret    
    printf(1, "cat: read error\n");
  d5:	50                   	push   %eax
  d6:	50                   	push   %eax
  d7:	68 00 0a 00 00       	push   $0xa00
  dc:	6a 01                	push   $0x1
  de:	e8 cd 03 00 00       	call   4b0 <printf>
    exit();
  e3:	e8 5a 02 00 00       	call   342 <exit>
  e8:	66 90                	xchg   %ax,%ax
  ea:	66 90                	xchg   %ax,%ax
  ec:	66 90                	xchg   %ax,%ax
  ee:	66 90                	xchg   %ax,%ax

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
 40a:	66 90                	xchg   %ax,%ax
 40c:	66 90                	xchg   %ax,%ax
 40e:	66 90                	xchg   %ax,%ax

00000410 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	57                   	push   %edi
 414:	56                   	push   %esi
 415:	53                   	push   %ebx
 416:	83 ec 3c             	sub    $0x3c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 419:	85 d2                	test   %edx,%edx
{
 41b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    neg = 1;
    x = -xx;
 41e:	89 d0                	mov    %edx,%eax
  if(sgn && xx < 0){
 420:	79 76                	jns    498 <printint+0x88>
 422:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 426:	74 70                	je     498 <printint+0x88>
    x = -xx;
 428:	f7 d8                	neg    %eax
    neg = 1;
 42a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 431:	31 f6                	xor    %esi,%esi
 433:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 436:	eb 0a                	jmp    442 <printint+0x32>
 438:	90                   	nop
 439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  do{
    buf[i++] = digits[x % base];
 440:	89 fe                	mov    %edi,%esi
 442:	31 d2                	xor    %edx,%edx
 444:	8d 7e 01             	lea    0x1(%esi),%edi
 447:	f7 f1                	div    %ecx
 449:	0f b6 92 30 0a 00 00 	movzbl 0xa30(%edx),%edx
  }while((x /= base) != 0);
 450:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
 452:	88 14 3b             	mov    %dl,(%ebx,%edi,1)
  }while((x /= base) != 0);
 455:	75 e9                	jne    440 <printint+0x30>
  if(neg)
 457:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 45a:	85 c0                	test   %eax,%eax
 45c:	74 08                	je     466 <printint+0x56>
    buf[i++] = '-';
 45e:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
 463:	8d 7e 02             	lea    0x2(%esi),%edi
 466:	8d 74 3d d7          	lea    -0x29(%ebp,%edi,1),%esi
 46a:	8b 7d c0             	mov    -0x40(%ebp),%edi
 46d:	8d 76 00             	lea    0x0(%esi),%esi
 470:	0f b6 06             	movzbl (%esi),%eax
  write(fd, &c, 1);
 473:	83 ec 04             	sub    $0x4,%esp
 476:	83 ee 01             	sub    $0x1,%esi
 479:	6a 01                	push   $0x1
 47b:	53                   	push   %ebx
 47c:	57                   	push   %edi
 47d:	88 45 d7             	mov    %al,-0x29(%ebp)
 480:	e8 dd fe ff ff       	call   362 <write>

  while(--i >= 0)
 485:	83 c4 10             	add    $0x10,%esp
 488:	39 de                	cmp    %ebx,%esi
 48a:	75 e4                	jne    470 <printint+0x60>
    putc(fd, buf[i]);
}
 48c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 48f:	5b                   	pop    %ebx
 490:	5e                   	pop    %esi
 491:	5f                   	pop    %edi
 492:	5d                   	pop    %ebp
 493:	c3                   	ret    
 494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 498:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 49f:	eb 90                	jmp    431 <printint+0x21>
 4a1:	eb 0d                	jmp    4b0 <printf>
 4a3:	90                   	nop
 4a4:	90                   	nop
 4a5:	90                   	nop
 4a6:	90                   	nop
 4a7:	90                   	nop
 4a8:	90                   	nop
 4a9:	90                   	nop
 4aa:	90                   	nop
 4ab:	90                   	nop
 4ac:	90                   	nop
 4ad:	90                   	nop
 4ae:	90                   	nop
 4af:	90                   	nop

000004b0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	57                   	push   %edi
 4b4:	56                   	push   %esi
 4b5:	53                   	push   %ebx
 4b6:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4b9:	8b 75 0c             	mov    0xc(%ebp),%esi
 4bc:	0f b6 1e             	movzbl (%esi),%ebx
 4bf:	84 db                	test   %bl,%bl
 4c1:	0f 84 b3 00 00 00    	je     57a <printf+0xca>
  ap = (uint*)(void*)&fmt + 1;
 4c7:	8d 45 10             	lea    0x10(%ebp),%eax
 4ca:	83 c6 01             	add    $0x1,%esi
  state = 0;
 4cd:	31 ff                	xor    %edi,%edi
  ap = (uint*)(void*)&fmt + 1;
 4cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 4d2:	eb 2f                	jmp    503 <printf+0x53>
 4d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 4d8:	83 f8 25             	cmp    $0x25,%eax
 4db:	0f 84 a7 00 00 00    	je     588 <printf+0xd8>
  write(fd, &c, 1);
 4e1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 4e4:	83 ec 04             	sub    $0x4,%esp
 4e7:	88 5d e2             	mov    %bl,-0x1e(%ebp)
 4ea:	6a 01                	push   $0x1
 4ec:	50                   	push   %eax
 4ed:	ff 75 08             	pushl  0x8(%ebp)
 4f0:	e8 6d fe ff ff       	call   362 <write>
 4f5:	83 c4 10             	add    $0x10,%esp
 4f8:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 4fb:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 4ff:	84 db                	test   %bl,%bl
 501:	74 77                	je     57a <printf+0xca>
    if(state == 0){
 503:	85 ff                	test   %edi,%edi
    c = fmt[i] & 0xff;
 505:	0f be cb             	movsbl %bl,%ecx
 508:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 50b:	74 cb                	je     4d8 <printf+0x28>
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 50d:	83 ff 25             	cmp    $0x25,%edi
 510:	75 e6                	jne    4f8 <printf+0x48>
      if(c == 'd'){
 512:	83 f8 64             	cmp    $0x64,%eax
 515:	0f 84 05 01 00 00    	je     620 <printf+0x170>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 51b:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 521:	83 f9 70             	cmp    $0x70,%ecx
 524:	74 72                	je     598 <printf+0xe8>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 526:	83 f8 73             	cmp    $0x73,%eax
 529:	0f 84 99 00 00 00    	je     5c8 <printf+0x118>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 52f:	83 f8 63             	cmp    $0x63,%eax
 532:	0f 84 08 01 00 00    	je     640 <printf+0x190>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 538:	83 f8 25             	cmp    $0x25,%eax
 53b:	0f 84 ef 00 00 00    	je     630 <printf+0x180>
  write(fd, &c, 1);
 541:	8d 45 e7             	lea    -0x19(%ebp),%eax
 544:	83 ec 04             	sub    $0x4,%esp
 547:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 54b:	6a 01                	push   $0x1
 54d:	50                   	push   %eax
 54e:	ff 75 08             	pushl  0x8(%ebp)
 551:	e8 0c fe ff ff       	call   362 <write>
 556:	83 c4 0c             	add    $0xc,%esp
 559:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 55c:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 55f:	6a 01                	push   $0x1
 561:	50                   	push   %eax
 562:	ff 75 08             	pushl  0x8(%ebp)
 565:	83 c6 01             	add    $0x1,%esi
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 568:	31 ff                	xor    %edi,%edi
  write(fd, &c, 1);
 56a:	e8 f3 fd ff ff       	call   362 <write>
  for(i = 0; fmt[i]; i++){
 56f:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
  write(fd, &c, 1);
 573:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 576:	84 db                	test   %bl,%bl
 578:	75 89                	jne    503 <printf+0x53>
    }
  }
}
 57a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 57d:	5b                   	pop    %ebx
 57e:	5e                   	pop    %esi
 57f:	5f                   	pop    %edi
 580:	5d                   	pop    %ebp
 581:	c3                   	ret    
 582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        state = '%';
 588:	bf 25 00 00 00       	mov    $0x25,%edi
 58d:	e9 66 ff ff ff       	jmp    4f8 <printf+0x48>
 592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printint(fd, *ap, 16, 0);
 598:	83 ec 0c             	sub    $0xc,%esp
 59b:	b9 10 00 00 00       	mov    $0x10,%ecx
 5a0:	6a 00                	push   $0x0
 5a2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 5a5:	8b 45 08             	mov    0x8(%ebp),%eax
 5a8:	8b 17                	mov    (%edi),%edx
 5aa:	e8 61 fe ff ff       	call   410 <printint>
        ap++;
 5af:	89 f8                	mov    %edi,%eax
 5b1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5b4:	31 ff                	xor    %edi,%edi
        ap++;
 5b6:	83 c0 04             	add    $0x4,%eax
 5b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 5bc:	e9 37 ff ff ff       	jmp    4f8 <printf+0x48>
 5c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = (char*)*ap;
 5c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 5cb:	8b 08                	mov    (%eax),%ecx
        ap++;
 5cd:	83 c0 04             	add    $0x4,%eax
 5d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(s == 0)
 5d3:	85 c9                	test   %ecx,%ecx
 5d5:	0f 84 8e 00 00 00    	je     669 <printf+0x1b9>
        while(*s != 0){
 5db:	0f b6 01             	movzbl (%ecx),%eax
      state = 0;
 5de:	31 ff                	xor    %edi,%edi
        s = (char*)*ap;
 5e0:	89 cb                	mov    %ecx,%ebx
        while(*s != 0){
 5e2:	84 c0                	test   %al,%al
 5e4:	0f 84 0e ff ff ff    	je     4f8 <printf+0x48>
 5ea:	89 75 d0             	mov    %esi,-0x30(%ebp)
 5ed:	89 de                	mov    %ebx,%esi
 5ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5f2:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 5f5:	8d 76 00             	lea    0x0(%esi),%esi
  write(fd, &c, 1);
 5f8:	83 ec 04             	sub    $0x4,%esp
          s++;
 5fb:	83 c6 01             	add    $0x1,%esi
 5fe:	88 45 e3             	mov    %al,-0x1d(%ebp)
  write(fd, &c, 1);
 601:	6a 01                	push   $0x1
 603:	57                   	push   %edi
 604:	53                   	push   %ebx
 605:	e8 58 fd ff ff       	call   362 <write>
        while(*s != 0){
 60a:	0f b6 06             	movzbl (%esi),%eax
 60d:	83 c4 10             	add    $0x10,%esp
 610:	84 c0                	test   %al,%al
 612:	75 e4                	jne    5f8 <printf+0x148>
 614:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 617:	31 ff                	xor    %edi,%edi
 619:	e9 da fe ff ff       	jmp    4f8 <printf+0x48>
 61e:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 10, 1);
 620:	83 ec 0c             	sub    $0xc,%esp
 623:	b9 0a 00 00 00       	mov    $0xa,%ecx
 628:	6a 01                	push   $0x1
 62a:	e9 73 ff ff ff       	jmp    5a2 <printf+0xf2>
 62f:	90                   	nop
  write(fd, &c, 1);
 630:	83 ec 04             	sub    $0x4,%esp
 633:	88 5d e5             	mov    %bl,-0x1b(%ebp)
 636:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 639:	6a 01                	push   $0x1
 63b:	e9 21 ff ff ff       	jmp    561 <printf+0xb1>
        putc(fd, *ap);
 640:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  write(fd, &c, 1);
 643:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 646:	8b 07                	mov    (%edi),%eax
  write(fd, &c, 1);
 648:	6a 01                	push   $0x1
        ap++;
 64a:	83 c7 04             	add    $0x4,%edi
        putc(fd, *ap);
 64d:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 650:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 653:	50                   	push   %eax
 654:	ff 75 08             	pushl  0x8(%ebp)
 657:	e8 06 fd ff ff       	call   362 <write>
        ap++;
 65c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 65f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 662:	31 ff                	xor    %edi,%edi
 664:	e9 8f fe ff ff       	jmp    4f8 <printf+0x48>
          s = "(null)";
 669:	bb 26 0a 00 00       	mov    $0xa26,%ebx
        while(*s != 0){
 66e:	b8 28 00 00 00       	mov    $0x28,%eax
 673:	e9 72 ff ff ff       	jmp    5ea <printf+0x13a>
 678:	66 90                	xchg   %ax,%ax
 67a:	66 90                	xchg   %ax,%ax
 67c:	66 90                	xchg   %ax,%ax
 67e:	66 90                	xchg   %ax,%ax

00000680 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 680:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 681:	a1 60 0e 00 00       	mov    0xe60,%eax
{
 686:	89 e5                	mov    %esp,%ebp
 688:	57                   	push   %edi
 689:	56                   	push   %esi
 68a:	53                   	push   %ebx
 68b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 68e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
 691:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 698:	39 c8                	cmp    %ecx,%eax
 69a:	8b 10                	mov    (%eax),%edx
 69c:	73 32                	jae    6d0 <free+0x50>
 69e:	39 d1                	cmp    %edx,%ecx
 6a0:	72 04                	jb     6a6 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a2:	39 d0                	cmp    %edx,%eax
 6a4:	72 32                	jb     6d8 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6a6:	8b 73 fc             	mov    -0x4(%ebx),%esi
 6a9:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6ac:	39 fa                	cmp    %edi,%edx
 6ae:	74 30                	je     6e0 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6b0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6b3:	8b 50 04             	mov    0x4(%eax),%edx
 6b6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6b9:	39 f1                	cmp    %esi,%ecx
 6bb:	74 3a                	je     6f7 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6bd:	89 08                	mov    %ecx,(%eax)
  freep = p;
 6bf:	a3 60 0e 00 00       	mov    %eax,0xe60
}
 6c4:	5b                   	pop    %ebx
 6c5:	5e                   	pop    %esi
 6c6:	5f                   	pop    %edi
 6c7:	5d                   	pop    %ebp
 6c8:	c3                   	ret    
 6c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d0:	39 d0                	cmp    %edx,%eax
 6d2:	72 04                	jb     6d8 <free+0x58>
 6d4:	39 d1                	cmp    %edx,%ecx
 6d6:	72 ce                	jb     6a6 <free+0x26>
{
 6d8:	89 d0                	mov    %edx,%eax
 6da:	eb bc                	jmp    698 <free+0x18>
 6dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 6e0:	03 72 04             	add    0x4(%edx),%esi
 6e3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e6:	8b 10                	mov    (%eax),%edx
 6e8:	8b 12                	mov    (%edx),%edx
 6ea:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6ed:	8b 50 04             	mov    0x4(%eax),%edx
 6f0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6f3:	39 f1                	cmp    %esi,%ecx
 6f5:	75 c6                	jne    6bd <free+0x3d>
    p->s.size += bp->s.size;
 6f7:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 6fa:	a3 60 0e 00 00       	mov    %eax,0xe60
    p->s.size += bp->s.size;
 6ff:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 702:	8b 53 f8             	mov    -0x8(%ebx),%edx
 705:	89 10                	mov    %edx,(%eax)
}
 707:	5b                   	pop    %ebx
 708:	5e                   	pop    %esi
 709:	5f                   	pop    %edi
 70a:	5d                   	pop    %ebp
 70b:	c3                   	ret    
 70c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000710 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 710:	55                   	push   %ebp
 711:	89 e5                	mov    %esp,%ebp
 713:	57                   	push   %edi
 714:	56                   	push   %esi
 715:	53                   	push   %ebx
 716:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 719:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 71c:	8b 15 60 0e 00 00    	mov    0xe60,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 722:	8d 78 07             	lea    0x7(%eax),%edi
 725:	c1 ef 03             	shr    $0x3,%edi
 728:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 72b:	85 d2                	test   %edx,%edx
 72d:	0f 84 9d 00 00 00    	je     7d0 <malloc+0xc0>
 733:	8b 02                	mov    (%edx),%eax
 735:	8b 48 04             	mov    0x4(%eax),%ecx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 738:	39 cf                	cmp    %ecx,%edi
 73a:	76 6c                	jbe    7a8 <malloc+0x98>
 73c:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
 742:	bb 00 10 00 00       	mov    $0x1000,%ebx
 747:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 74a:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 751:	eb 0e                	jmp    761 <malloc+0x51>
 753:	90                   	nop
 754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 758:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 75a:	8b 48 04             	mov    0x4(%eax),%ecx
 75d:	39 f9                	cmp    %edi,%ecx
 75f:	73 47                	jae    7a8 <malloc+0x98>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 761:	39 05 60 0e 00 00    	cmp    %eax,0xe60
 767:	89 c2                	mov    %eax,%edx
 769:	75 ed                	jne    758 <malloc+0x48>
  p = sbrk(nu * sizeof(Header));
 76b:	83 ec 0c             	sub    $0xc,%esp
 76e:	56                   	push   %esi
 76f:	e8 5e fc ff ff       	call   3d2 <sbrk>
  if(p == (char*)-1)
 774:	83 c4 10             	add    $0x10,%esp
 777:	83 f8 ff             	cmp    $0xffffffff,%eax
 77a:	74 1c                	je     798 <malloc+0x88>
  hp->s.size = nu;
 77c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 77f:	83 ec 0c             	sub    $0xc,%esp
 782:	83 c0 08             	add    $0x8,%eax
 785:	50                   	push   %eax
 786:	e8 f5 fe ff ff       	call   680 <free>
  return freep;
 78b:	8b 15 60 0e 00 00    	mov    0xe60,%edx
      if((p = morecore(nunits)) == 0)
 791:	83 c4 10             	add    $0x10,%esp
 794:	85 d2                	test   %edx,%edx
 796:	75 c0                	jne    758 <malloc+0x48>
        return 0;
  }
}
 798:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 79b:	31 c0                	xor    %eax,%eax
}
 79d:	5b                   	pop    %ebx
 79e:	5e                   	pop    %esi
 79f:	5f                   	pop    %edi
 7a0:	5d                   	pop    %ebp
 7a1:	c3                   	ret    
 7a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 7a8:	39 cf                	cmp    %ecx,%edi
 7aa:	74 54                	je     800 <malloc+0xf0>
        p->s.size -= nunits;
 7ac:	29 f9                	sub    %edi,%ecx
 7ae:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 7b1:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 7b4:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 7b7:	89 15 60 0e 00 00    	mov    %edx,0xe60
}
 7bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 7c0:	83 c0 08             	add    $0x8,%eax
}
 7c3:	5b                   	pop    %ebx
 7c4:	5e                   	pop    %esi
 7c5:	5f                   	pop    %edi
 7c6:	5d                   	pop    %ebp
 7c7:	c3                   	ret    
 7c8:	90                   	nop
 7c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    base.s.ptr = freep = prevp = &base;
 7d0:	c7 05 60 0e 00 00 64 	movl   $0xe64,0xe60
 7d7:	0e 00 00 
 7da:	c7 05 64 0e 00 00 64 	movl   $0xe64,0xe64
 7e1:	0e 00 00 
    base.s.size = 0;
 7e4:	b8 64 0e 00 00       	mov    $0xe64,%eax
 7e9:	c7 05 68 0e 00 00 00 	movl   $0x0,0xe68
 7f0:	00 00 00 
 7f3:	e9 44 ff ff ff       	jmp    73c <malloc+0x2c>
 7f8:	90                   	nop
 7f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        prevp->s.ptr = p->s.ptr;
 800:	8b 08                	mov    (%eax),%ecx
 802:	89 0a                	mov    %ecx,(%edx)
 804:	eb b1                	jmp    7b7 <malloc+0xa7>
 806:	66 90                	xchg   %ax,%ax
 808:	66 90                	xchg   %ax,%ax
 80a:	66 90                	xchg   %ax,%ax
 80c:	66 90                	xchg   %ax,%ax
 80e:	66 90                	xchg   %ax,%ax

00000810 <remove_thread>:
    int pid;
    void *ustack;
    int used;
}threads[NTHREAD] = {0};

void remove_thread(int* pid){
 810:	55                   	push   %ebp
 811:	b8 80 0e 00 00       	mov    $0xe80,%eax
    for (int i = 0; i < NTHREAD; ++i)
 816:	31 d2                	xor    %edx,%edx
void remove_thread(int* pid){
 818:	89 e5                	mov    %esp,%ebp
 81a:	56                   	push   %esi
 81b:	53                   	push   %ebx
 81c:	8b 4d 08             	mov    0x8(%ebp),%ecx
    {
        if(threads[i].used && threads[i].pid == *pid){
 81f:	8b 58 08             	mov    0x8(%eax),%ebx
 822:	85 db                	test   %ebx,%ebx
 824:	74 06                	je     82c <remove_thread+0x1c>
 826:	8b 31                	mov    (%ecx),%esi
 828:	39 30                	cmp    %esi,(%eax)
 82a:	74 14                	je     840 <remove_thread+0x30>
    for (int i = 0; i < NTHREAD; ++i)
 82c:	83 c2 01             	add    $0x1,%edx
 82f:	83 c0 0c             	add    $0xc,%eax
 832:	83 fa 04             	cmp    $0x4,%edx
 835:	75 e8                	jne    81f <remove_thread+0xf>
            threads[i].ustack = 0;
            threads[i].used = 0;
            break;
        }
    }
}
 837:	8d 65 f8             	lea    -0x8(%ebp),%esp
 83a:	5b                   	pop    %ebx
 83b:	5e                   	pop    %esi
 83c:	5d                   	pop    %ebp
 83d:	c3                   	ret    
 83e:	66 90                	xchg   %ax,%ax
            free(threads[i].ustack);
 840:	8d 1c 52             	lea    (%edx,%edx,2),%ebx
 843:	83 ec 0c             	sub    $0xc,%esp
 846:	c1 e3 02             	shl    $0x2,%ebx
 849:	ff b3 84 0e 00 00    	pushl  0xe84(%ebx)
 84f:	e8 2c fe ff ff       	call   680 <free>
            threads[i].pid = 0;
 854:	c7 83 80 0e 00 00 00 	movl   $0x0,0xe80(%ebx)
 85b:	00 00 00 
            threads[i].ustack = 0;
 85e:	c7 83 84 0e 00 00 00 	movl   $0x0,0xe84(%ebx)
 865:	00 00 00 
            break;
 868:	83 c4 10             	add    $0x10,%esp
            threads[i].used = 0;
 86b:	c7 83 88 0e 00 00 00 	movl   $0x0,0xe88(%ebx)
 872:	00 00 00 
}
 875:	8d 65 f8             	lea    -0x8(%ebp),%esp
 878:	5b                   	pop    %ebx
 879:	5e                   	pop    %esi
 87a:	5d                   	pop    %ebp
 87b:	c3                   	ret    
 87c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000880 <findPos>:

int findPos(){
 880:	55                   	push   %ebp
 881:	ba 80 0e 00 00       	mov    $0xe80,%edx
    for (int i = 0; i < NTHREAD; ++i)
 886:	31 c0                	xor    %eax,%eax
int findPos(){
 888:	89 e5                	mov    %esp,%ebp
    {
        if(threads[i].used == 0){
 88a:	8b 4a 08             	mov    0x8(%edx),%ecx
 88d:	85 c9                	test   %ecx,%ecx
 88f:	74 10                	je     8a1 <findPos+0x21>
    for (int i = 0; i < NTHREAD; ++i)
 891:	83 c0 01             	add    $0x1,%eax
 894:	83 c2 0c             	add    $0xc,%edx
 897:	83 f8 04             	cmp    $0x4,%eax
 89a:	75 ee                	jne    88a <findPos+0xa>
            return i;
        }
    }
    return -1;
 89c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 8a1:	5d                   	pop    %ebp
 8a2:	c3                   	ret    
 8a3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 8a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000008b0 <thread_create>:

int thread_create(void(*start_routine)(void*), void *arg){
 8b0:	55                   	push   %ebp
 8b1:	b8 80 0e 00 00       	mov    $0xe80,%eax
 8b6:	89 e5                	mov    %esp,%ebp
 8b8:	56                   	push   %esi
 8b9:	53                   	push   %ebx
    for (int i = 0; i < NTHREAD; ++i)
 8ba:	31 db                	xor    %ebx,%ebx
int thread_create(void(*start_routine)(void*), void *arg){
 8bc:	83 ec 10             	sub    $0x10,%esp
        if(threads[i].used == 0){
 8bf:	8b 50 08             	mov    0x8(%eax),%edx
 8c2:	85 d2                	test   %edx,%edx
 8c4:	74 2a                	je     8f0 <thread_create+0x40>
    for (int i = 0; i < NTHREAD; ++i)
 8c6:	83 c3 01             	add    $0x1,%ebx
 8c9:	83 c0 0c             	add    $0xc,%eax
 8cc:	83 fb 04             	cmp    $0x4,%ebx
 8cf:	75 ee                	jne    8bf <thread_create+0xf>
    int pos = findPos();
    if(pos == -1){
        printf(1,"Create thread failed! Perhaps because there are too many threads!\n");
 8d1:	83 ec 08             	sub    $0x8,%esp
 8d4:	68 5c 0a 00 00       	push   $0xa5c
 8d9:	6a 01                	push   $0x1
 8db:	e8 d0 fb ff ff       	call   4b0 <printf>
        return -1;
 8e0:	83 c4 10             	add    $0x10,%esp
        threads[pos].pid = pid;
        threads[pos].ustack = stack;
        threads[pos].used = 1; 
    }
    return pid;
}
 8e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
        return -1;
 8e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 8eb:	5b                   	pop    %ebx
 8ec:	5e                   	pop    %esi
 8ed:	5d                   	pop    %ebp
 8ee:	c3                   	ret    
 8ef:	90                   	nop
    void *stack = malloc(PGSIZE);
 8f0:	83 ec 0c             	sub    $0xc,%esp
 8f3:	68 00 10 00 00       	push   $0x1000
 8f8:	e8 13 fe ff ff       	call   710 <malloc>
    int pid = clone(start_routine, arg, stack);
 8fd:	83 c4 0c             	add    $0xc,%esp
    void *stack = malloc(PGSIZE);
 900:	89 c6                	mov    %eax,%esi
    int pid = clone(start_routine, arg, stack);
 902:	50                   	push   %eax
 903:	ff 75 0c             	pushl  0xc(%ebp)
 906:	ff 75 08             	pushl  0x8(%ebp)
 909:	e8 ec fa ff ff       	call   3fa <clone>
    if(pid == -1){
 90e:	83 c4 10             	add    $0x10,%esp
 911:	83 f8 ff             	cmp    $0xffffffff,%eax
 914:	74 2a                	je     940 <thread_create+0x90>
        threads[pos].pid = pid;
 916:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
 919:	c1 e2 02             	shl    $0x2,%edx
        threads[pos].ustack = stack;
 91c:	89 b2 84 0e 00 00    	mov    %esi,0xe84(%edx)
        threads[pos].pid = pid;
 922:	89 82 80 0e 00 00    	mov    %eax,0xe80(%edx)
        threads[pos].used = 1; 
 928:	c7 82 88 0e 00 00 01 	movl   $0x1,0xe88(%edx)
 92f:	00 00 00 
}
 932:	8d 65 f8             	lea    -0x8(%ebp),%esp
 935:	5b                   	pop    %ebx
 936:	5e                   	pop    %esi
 937:	5d                   	pop    %ebp
 938:	c3                   	ret    
 939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        printf(1,"clone failed!\n");
 940:	83 ec 08             	sub    $0x8,%esp
 943:	89 45 f4             	mov    %eax,-0xc(%ebp)
 946:	68 41 0a 00 00       	push   $0xa41
 94b:	6a 01                	push   $0x1
 94d:	e8 5e fb ff ff       	call   4b0 <printf>
        free(stack);
 952:	89 34 24             	mov    %esi,(%esp)
 955:	e8 26 fd ff ff       	call   680 <free>
 95a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95d:	83 c4 10             	add    $0x10,%esp
}
 960:	8d 65 f8             	lea    -0x8(%ebp),%esp
 963:	5b                   	pop    %ebx
 964:	5e                   	pop    %esi
 965:	5d                   	pop    %ebp
 966:	c3                   	ret    
 967:	89 f6                	mov    %esi,%esi
 969:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000970 <thread_join>:

int thread_join(void){
 970:	55                   	push   %ebp
 971:	89 e5                	mov    %esp,%ebp
 973:	53                   	push   %ebx
 974:	bb 80 0e 00 00       	mov    $0xe80,%ebx
 979:	83 ec 14             	sub    $0x14,%esp
    for(int i = 0; i < NTHREAD; ++i){
        if(threads[i].used == 1){
 97c:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
 980:	74 16                	je     998 <thread_join+0x28>
 982:	83 c3 0c             	add    $0xc,%ebx
    for(int i = 0; i < NTHREAD; ++i){
 985:	81 fb b0 0e 00 00    	cmp    $0xeb0,%ebx
 98b:	75 ef                	jne    97c <thread_join+0xc>
                remove_thread(&pid);
                return pid;
            }
        }
    }
    return 0;
 98d:	31 c0                	xor    %eax,%eax
}
 98f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 992:	c9                   	leave  
 993:	c3                   	ret    
 994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
            int pid = join(&threads[i].ustack);
 998:	8d 43 04             	lea    0x4(%ebx),%eax
 99b:	83 ec 0c             	sub    $0xc,%esp
 99e:	50                   	push   %eax
 99f:	e8 5e fa ff ff       	call   402 <join>
            if(pid > 0){
 9a4:	83 c4 10             	add    $0x10,%esp
 9a7:	85 c0                	test   %eax,%eax
            int pid = join(&threads[i].ustack);
 9a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if(pid > 0){
 9ac:	7e d4                	jle    982 <thread_join+0x12>
                remove_thread(&pid);
 9ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
 9b1:	83 ec 0c             	sub    $0xc,%esp
 9b4:	50                   	push   %eax
 9b5:	e8 56 fe ff ff       	call   810 <remove_thread>
                return pid;
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	83 c4 10             	add    $0x10,%esp
 9c0:	eb cd                	jmp    98f <thread_join+0x1f>
 9c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 9c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000009d0 <printTCB>:

void printTCB(void){
 9d0:	55                   	push   %ebp
 9d1:	89 e5                	mov    %esp,%ebp
 9d3:	53                   	push   %ebx
    for (int i = 0; i < NTHREAD; ++i)
 9d4:	31 db                	xor    %ebx,%ebx
void printTCB(void){
 9d6:	83 ec 04             	sub    $0x4,%esp
    {
        printf(1,"TCB %d:%d\n",i,threads[i].used);
 9d9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 9dc:	ff 34 85 88 0e 00 00 	pushl  0xe88(,%eax,4)
 9e3:	53                   	push   %ebx
    for (int i = 0; i < NTHREAD; ++i)
 9e4:	83 c3 01             	add    $0x1,%ebx
        printf(1,"TCB %d:%d\n",i,threads[i].used);
 9e7:	68 50 0a 00 00       	push   $0xa50
 9ec:	6a 01                	push   $0x1
 9ee:	e8 bd fa ff ff       	call   4b0 <printf>
    for (int i = 0; i < NTHREAD; ++i)
 9f3:	83 c4 10             	add    $0x10,%esp
 9f6:	83 fb 04             	cmp    $0x4,%ebx
 9f9:	75 de                	jne    9d9 <printTCB+0x9>
    }
    
}
 9fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 9fe:	c9                   	leave  
 9ff:	c3                   	ret    
