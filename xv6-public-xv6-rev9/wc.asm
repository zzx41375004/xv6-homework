
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  printf(1, "%d %d %d %s\n", l, w, c, name);
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
  27:	7e 56                	jle    7f <main+0x7f>
  29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  30:	83 ec 08             	sub    $0x8,%esp
  33:	6a 00                	push   $0x0
  35:	ff 33                	pushl  (%ebx)
  37:	e8 d6 03 00 00       	call   412 <open>
  3c:	83 c4 10             	add    $0x10,%esp
  3f:	85 c0                	test   %eax,%eax
  41:	89 c7                	mov    %eax,%edi
  43:	78 26                	js     6b <main+0x6b>
      printf(1, "wc: cannot open %s\n", argv[i]);
      exit();
    }
    wc(fd, argv[i]);
  45:	83 ec 08             	sub    $0x8,%esp
  48:	ff 33                	pushl  (%ebx)
  for(i = 1; i < argc; i++){
  4a:	83 c6 01             	add    $0x1,%esi
    wc(fd, argv[i]);
  4d:	50                   	push   %eax
  4e:	83 c3 04             	add    $0x4,%ebx
  51:	e8 4a 00 00 00       	call   a0 <wc>
    close(fd);
  56:	89 3c 24             	mov    %edi,(%esp)
  59:	e8 9c 03 00 00       	call   3fa <close>
  for(i = 1; i < argc; i++){
  5e:	83 c4 10             	add    $0x10,%esp
  61:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  64:	75 ca                	jne    30 <main+0x30>
  }
  exit();
  66:	e8 67 03 00 00       	call   3d2 <exit>
      printf(1, "wc: cannot open %s\n", argv[i]);
  6b:	50                   	push   %eax
  6c:	ff 33                	pushl  (%ebx)
  6e:	68 c3 0a 00 00       	push   $0xac3
  73:	6a 01                	push   $0x1
  75:	e8 d6 04 00 00       	call   550 <printf>
      exit();
  7a:	e8 53 03 00 00       	call   3d2 <exit>
    wc(0, "");
  7f:	52                   	push   %edx
  80:	52                   	push   %edx
  81:	68 ff 0a 00 00       	push   $0xaff
  86:	6a 00                	push   $0x0
  88:	e8 13 00 00 00       	call   a0 <wc>
    exit();
  8d:	e8 40 03 00 00       	call   3d2 <exit>
  92:	66 90                	xchg   %ax,%ax
  94:	66 90                	xchg   %ax,%ax
  96:	66 90                	xchg   %ax,%ax
  98:	66 90                	xchg   %ax,%ax
  9a:	66 90                	xchg   %ax,%ax
  9c:	66 90                	xchg   %ax,%ax
  9e:	66 90                	xchg   %ax,%ax

000000a0 <wc>:
{
  a0:	55                   	push   %ebp
  a1:	89 e5                	mov    %esp,%ebp
  a3:	57                   	push   %edi
  a4:	56                   	push   %esi
  a5:	53                   	push   %ebx
  l = w = c = 0;
  a6:	31 db                	xor    %ebx,%ebx
{
  a8:	83 ec 1c             	sub    $0x1c,%esp
  inword = 0;
  ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  l = w = c = 0;
  b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  b9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  c0:	83 ec 04             	sub    $0x4,%esp
  c3:	68 00 02 00 00       	push   $0x200
  c8:	68 60 0f 00 00       	push   $0xf60
  cd:	ff 75 08             	pushl  0x8(%ebp)
  d0:	e8 15 03 00 00       	call   3ea <read>
  d5:	83 c4 10             	add    $0x10,%esp
  d8:	83 f8 00             	cmp    $0x0,%eax
  db:	89 c6                	mov    %eax,%esi
  dd:	7e 61                	jle    140 <wc+0xa0>
    for(i=0; i<n; i++){
  df:	31 ff                	xor    %edi,%edi
  e1:	eb 13                	jmp    f6 <wc+0x56>
  e3:	90                   	nop
  e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        inword = 0;
  e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    for(i=0; i<n; i++){
  ef:	83 c7 01             	add    $0x1,%edi
  f2:	39 fe                	cmp    %edi,%esi
  f4:	74 42                	je     138 <wc+0x98>
      if(buf[i] == '\n')
  f6:	0f be 87 60 0f 00 00 	movsbl 0xf60(%edi),%eax
        l++;
  fd:	31 c9                	xor    %ecx,%ecx
  ff:	3c 0a                	cmp    $0xa,%al
 101:	0f 94 c1             	sete   %cl
      if(strchr(" \r\t\n\v", buf[i]))
 104:	83 ec 08             	sub    $0x8,%esp
 107:	50                   	push   %eax
 108:	68 a0 0a 00 00       	push   $0xaa0
        l++;
 10d:	01 cb                	add    %ecx,%ebx
      if(strchr(" \r\t\n\v", buf[i]))
 10f:	e8 3c 01 00 00       	call   250 <strchr>
 114:	83 c4 10             	add    $0x10,%esp
 117:	85 c0                	test   %eax,%eax
 119:	75 cd                	jne    e8 <wc+0x48>
      else if(!inword){
 11b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 11e:	85 d2                	test   %edx,%edx
 120:	75 cd                	jne    ef <wc+0x4f>
    for(i=0; i<n; i++){
 122:	83 c7 01             	add    $0x1,%edi
        w++;
 125:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
        inword = 1;
 129:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
    for(i=0; i<n; i++){
 130:	39 fe                	cmp    %edi,%esi
 132:	75 c2                	jne    f6 <wc+0x56>
 134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 138:	01 75 e0             	add    %esi,-0x20(%ebp)
 13b:	eb 83                	jmp    c0 <wc+0x20>
 13d:	8d 76 00             	lea    0x0(%esi),%esi
  if(n < 0){
 140:	75 24                	jne    166 <wc+0xc6>
  printf(1, "%d %d %d %s\n", l, w, c, name);
 142:	83 ec 08             	sub    $0x8,%esp
 145:	ff 75 0c             	pushl  0xc(%ebp)
 148:	ff 75 e0             	pushl  -0x20(%ebp)
 14b:	ff 75 dc             	pushl  -0x24(%ebp)
 14e:	53                   	push   %ebx
 14f:	68 b6 0a 00 00       	push   $0xab6
 154:	6a 01                	push   $0x1
 156:	e8 f5 03 00 00       	call   550 <printf>
}
 15b:	83 c4 20             	add    $0x20,%esp
 15e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 161:	5b                   	pop    %ebx
 162:	5e                   	pop    %esi
 163:	5f                   	pop    %edi
 164:	5d                   	pop    %ebp
 165:	c3                   	ret    
    printf(1, "wc: read error\n");
 166:	50                   	push   %eax
 167:	50                   	push   %eax
 168:	68 a6 0a 00 00       	push   $0xaa6
 16d:	6a 01                	push   $0x1
 16f:	e8 dc 03 00 00       	call   550 <printf>
    exit();
 174:	e8 59 02 00 00       	call   3d2 <exit>
 179:	66 90                	xchg   %ax,%ax
 17b:	66 90                	xchg   %ax,%ax
 17d:	66 90                	xchg   %ax,%ax
 17f:	90                   	nop

00000180 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	53                   	push   %ebx
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 18a:	89 c2                	mov    %eax,%edx
 18c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 190:	83 c1 01             	add    $0x1,%ecx
 193:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
 197:	83 c2 01             	add    $0x1,%edx
 19a:	84 db                	test   %bl,%bl
 19c:	88 5a ff             	mov    %bl,-0x1(%edx)
 19f:	75 ef                	jne    190 <strcpy+0x10>
    ;
  return os;
}
 1a1:	5b                   	pop    %ebx
 1a2:	5d                   	pop    %ebp
 1a3:	c3                   	ret    
 1a4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 1aa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

000001b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	53                   	push   %ebx
 1b4:	8b 55 08             	mov    0x8(%ebp),%edx
 1b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
 1ba:	0f b6 02             	movzbl (%edx),%eax
 1bd:	0f b6 19             	movzbl (%ecx),%ebx
 1c0:	84 c0                	test   %al,%al
 1c2:	75 1c                	jne    1e0 <strcmp+0x30>
 1c4:	eb 2a                	jmp    1f0 <strcmp+0x40>
 1c6:	8d 76 00             	lea    0x0(%esi),%esi
 1c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    p++, q++;
 1d0:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 1d3:	0f b6 02             	movzbl (%edx),%eax
    p++, q++;
 1d6:	83 c1 01             	add    $0x1,%ecx
 1d9:	0f b6 19             	movzbl (%ecx),%ebx
  while(*p && *p == *q)
 1dc:	84 c0                	test   %al,%al
 1de:	74 10                	je     1f0 <strcmp+0x40>
 1e0:	38 d8                	cmp    %bl,%al
 1e2:	74 ec                	je     1d0 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
 1e4:	29 d8                	sub    %ebx,%eax
}
 1e6:	5b                   	pop    %ebx
 1e7:	5d                   	pop    %ebp
 1e8:	c3                   	ret    
 1e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 1f0:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
 1f2:	29 d8                	sub    %ebx,%eax
}
 1f4:	5b                   	pop    %ebx
 1f5:	5d                   	pop    %ebp
 1f6:	c3                   	ret    
 1f7:	89 f6                	mov    %esi,%esi
 1f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000200 <strlen>:

uint
strlen(char *s)
{
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
 203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 206:	80 39 00             	cmpb   $0x0,(%ecx)
 209:	74 15                	je     220 <strlen+0x20>
 20b:	31 d2                	xor    %edx,%edx
 20d:	8d 76 00             	lea    0x0(%esi),%esi
 210:	83 c2 01             	add    $0x1,%edx
 213:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 217:	89 d0                	mov    %edx,%eax
 219:	75 f5                	jne    210 <strlen+0x10>
    ;
  return n;
}
 21b:	5d                   	pop    %ebp
 21c:	c3                   	ret    
 21d:	8d 76 00             	lea    0x0(%esi),%esi
  for(n = 0; s[n]; n++)
 220:	31 c0                	xor    %eax,%eax
}
 222:	5d                   	pop    %ebp
 223:	c3                   	ret    
 224:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 22a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000230 <memset>:

void*
memset(void *dst, int c, uint n)
{
 230:	55                   	push   %ebp
 231:	89 e5                	mov    %esp,%ebp
 233:	57                   	push   %edi
 234:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 237:	8b 4d 10             	mov    0x10(%ebp),%ecx
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	89 d7                	mov    %edx,%edi
 23f:	fc                   	cld    
 240:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 242:	89 d0                	mov    %edx,%eax
 244:	5f                   	pop    %edi
 245:	5d                   	pop    %ebp
 246:	c3                   	ret    
 247:	89 f6                	mov    %esi,%esi
 249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000250 <strchr>:

char*
strchr(const char *s, char c)
{
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	53                   	push   %ebx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for(; *s; s++)
 25a:	0f b6 10             	movzbl (%eax),%edx
 25d:	84 d2                	test   %dl,%dl
 25f:	74 1d                	je     27e <strchr+0x2e>
    if(*s == c)
 261:	38 d3                	cmp    %dl,%bl
 263:	89 d9                	mov    %ebx,%ecx
 265:	75 0d                	jne    274 <strchr+0x24>
 267:	eb 17                	jmp    280 <strchr+0x30>
 269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 270:	38 ca                	cmp    %cl,%dl
 272:	74 0c                	je     280 <strchr+0x30>
  for(; *s; s++)
 274:	83 c0 01             	add    $0x1,%eax
 277:	0f b6 10             	movzbl (%eax),%edx
 27a:	84 d2                	test   %dl,%dl
 27c:	75 f2                	jne    270 <strchr+0x20>
      return (char*)s;
  return 0;
 27e:	31 c0                	xor    %eax,%eax
}
 280:	5b                   	pop    %ebx
 281:	5d                   	pop    %ebp
 282:	c3                   	ret    
 283:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000290 <gets>:

char*
gets(char *buf, int max)
{
 290:	55                   	push   %ebp
 291:	89 e5                	mov    %esp,%ebp
 293:	57                   	push   %edi
 294:	56                   	push   %esi
 295:	53                   	push   %ebx
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 296:	31 f6                	xor    %esi,%esi
 298:	89 f3                	mov    %esi,%ebx
{
 29a:	83 ec 1c             	sub    $0x1c,%esp
 29d:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 2a0:	eb 2f                	jmp    2d1 <gets+0x41>
 2a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 2a8:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2ab:	83 ec 04             	sub    $0x4,%esp
 2ae:	6a 01                	push   $0x1
 2b0:	50                   	push   %eax
 2b1:	6a 00                	push   $0x0
 2b3:	e8 32 01 00 00       	call   3ea <read>
    if(cc < 1)
 2b8:	83 c4 10             	add    $0x10,%esp
 2bb:	85 c0                	test   %eax,%eax
 2bd:	7e 1c                	jle    2db <gets+0x4b>
      break;
    buf[i++] = c;
 2bf:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2c3:	83 c7 01             	add    $0x1,%edi
 2c6:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 2c9:	3c 0a                	cmp    $0xa,%al
 2cb:	74 23                	je     2f0 <gets+0x60>
 2cd:	3c 0d                	cmp    $0xd,%al
 2cf:	74 1f                	je     2f0 <gets+0x60>
  for(i=0; i+1 < max; ){
 2d1:	83 c3 01             	add    $0x1,%ebx
 2d4:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 2d7:	89 fe                	mov    %edi,%esi
 2d9:	7c cd                	jl     2a8 <gets+0x18>
 2db:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 2dd:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 2e0:	c6 03 00             	movb   $0x0,(%ebx)
}
 2e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2e6:	5b                   	pop    %ebx
 2e7:	5e                   	pop    %esi
 2e8:	5f                   	pop    %edi
 2e9:	5d                   	pop    %ebp
 2ea:	c3                   	ret    
 2eb:	90                   	nop
 2ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2f0:	8b 75 08             	mov    0x8(%ebp),%esi
 2f3:	8b 45 08             	mov    0x8(%ebp),%eax
 2f6:	01 de                	add    %ebx,%esi
 2f8:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 2fa:	c6 03 00             	movb   $0x0,(%ebx)
}
 2fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
 300:	5b                   	pop    %ebx
 301:	5e                   	pop    %esi
 302:	5f                   	pop    %edi
 303:	5d                   	pop    %ebp
 304:	c3                   	ret    
 305:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000310 <stat>:

int
stat(char *n, struct stat *st)
{
 310:	55                   	push   %ebp
 311:	89 e5                	mov    %esp,%ebp
 313:	56                   	push   %esi
 314:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 315:	83 ec 08             	sub    $0x8,%esp
 318:	6a 00                	push   $0x0
 31a:	ff 75 08             	pushl  0x8(%ebp)
 31d:	e8 f0 00 00 00       	call   412 <open>
  if(fd < 0)
 322:	83 c4 10             	add    $0x10,%esp
 325:	85 c0                	test   %eax,%eax
 327:	78 27                	js     350 <stat+0x40>
    return -1;
  r = fstat(fd, st);
 329:	83 ec 08             	sub    $0x8,%esp
 32c:	ff 75 0c             	pushl  0xc(%ebp)
 32f:	89 c3                	mov    %eax,%ebx
 331:	50                   	push   %eax
 332:	e8 f3 00 00 00       	call   42a <fstat>
  close(fd);
 337:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 33a:	89 c6                	mov    %eax,%esi
  close(fd);
 33c:	e8 b9 00 00 00       	call   3fa <close>
  return r;
 341:	83 c4 10             	add    $0x10,%esp
}
 344:	8d 65 f8             	lea    -0x8(%ebp),%esp
 347:	89 f0                	mov    %esi,%eax
 349:	5b                   	pop    %ebx
 34a:	5e                   	pop    %esi
 34b:	5d                   	pop    %ebp
 34c:	c3                   	ret    
 34d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 350:	be ff ff ff ff       	mov    $0xffffffff,%esi
 355:	eb ed                	jmp    344 <stat+0x34>
 357:	89 f6                	mov    %esi,%esi
 359:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000360 <atoi>:

int
atoi(const char *s)
{
 360:	55                   	push   %ebp
 361:	89 e5                	mov    %esp,%ebp
 363:	53                   	push   %ebx
 364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 367:	0f be 11             	movsbl (%ecx),%edx
 36a:	8d 42 d0             	lea    -0x30(%edx),%eax
 36d:	3c 09                	cmp    $0x9,%al
  n = 0;
 36f:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 374:	77 1f                	ja     395 <atoi+0x35>
 376:	8d 76 00             	lea    0x0(%esi),%esi
 379:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    n = n*10 + *s++ - '0';
 380:	8d 04 80             	lea    (%eax,%eax,4),%eax
 383:	83 c1 01             	add    $0x1,%ecx
 386:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
  while('0' <= *s && *s <= '9')
 38a:	0f be 11             	movsbl (%ecx),%edx
 38d:	8d 5a d0             	lea    -0x30(%edx),%ebx
 390:	80 fb 09             	cmp    $0x9,%bl
 393:	76 eb                	jbe    380 <atoi+0x20>
  return n;
}
 395:	5b                   	pop    %ebx
 396:	5d                   	pop    %ebp
 397:	c3                   	ret    
 398:	90                   	nop
 399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

000003a0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	56                   	push   %esi
 3a4:	53                   	push   %ebx
 3a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3a8:	8b 45 08             	mov    0x8(%ebp),%eax
 3ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3ae:	85 db                	test   %ebx,%ebx
 3b0:	7e 14                	jle    3c6 <memmove+0x26>
 3b2:	31 d2                	xor    %edx,%edx
 3b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *dst++ = *src++;
 3b8:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 3bc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 3bf:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0)
 3c2:	39 d3                	cmp    %edx,%ebx
 3c4:	75 f2                	jne    3b8 <memmove+0x18>
  return vdst;
}
 3c6:	5b                   	pop    %ebx
 3c7:	5e                   	pop    %esi
 3c8:	5d                   	pop    %ebp
 3c9:	c3                   	ret    

000003ca <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3ca:	b8 01 00 00 00       	mov    $0x1,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <exit>:
SYSCALL(exit)
 3d2:	b8 02 00 00 00       	mov    $0x2,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <wait>:
SYSCALL(wait)
 3da:	b8 03 00 00 00       	mov    $0x3,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <pipe>:
SYSCALL(pipe)
 3e2:	b8 04 00 00 00       	mov    $0x4,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <read>:
SYSCALL(read)
 3ea:	b8 05 00 00 00       	mov    $0x5,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <write>:
SYSCALL(write)
 3f2:	b8 10 00 00 00       	mov    $0x10,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <close>:
SYSCALL(close)
 3fa:	b8 15 00 00 00       	mov    $0x15,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <kill>:
SYSCALL(kill)
 402:	b8 06 00 00 00       	mov    $0x6,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <exec>:
SYSCALL(exec)
 40a:	b8 07 00 00 00       	mov    $0x7,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <open>:
SYSCALL(open)
 412:	b8 0f 00 00 00       	mov    $0xf,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <mknod>:
SYSCALL(mknod)
 41a:	b8 11 00 00 00       	mov    $0x11,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <unlink>:
SYSCALL(unlink)
 422:	b8 12 00 00 00       	mov    $0x12,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <fstat>:
SYSCALL(fstat)
 42a:	b8 08 00 00 00       	mov    $0x8,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <link>:
SYSCALL(link)
 432:	b8 13 00 00 00       	mov    $0x13,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <mkdir>:
SYSCALL(mkdir)
 43a:	b8 14 00 00 00       	mov    $0x14,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <chdir>:
SYSCALL(chdir)
 442:	b8 09 00 00 00       	mov    $0x9,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <dup>:
SYSCALL(dup)
 44a:	b8 0a 00 00 00       	mov    $0xa,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <getpid>:
SYSCALL(getpid)
 452:	b8 0b 00 00 00       	mov    $0xb,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <getcpuid>:
SYSCALL(getcpuid)
 45a:	b8 16 00 00 00       	mov    $0x16,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <sbrk>:
SYSCALL(sbrk)
 462:	b8 0c 00 00 00       	mov    $0xc,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <sleep>:
SYSCALL(sleep)
 46a:	b8 0d 00 00 00       	mov    $0xd,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <uptime>:
SYSCALL(uptime)
 472:	b8 0e 00 00 00       	mov    $0xe,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <myalloc>:
SYSCALL(myalloc)
 47a:	b8 17 00 00 00       	mov    $0x17,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <myfree>:
SYSCALL(myfree)
 482:	b8 18 00 00 00       	mov    $0x18,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <clone>:
SYSCALL(clone)
 48a:	b8 19 00 00 00       	mov    $0x19,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <join>:
SYSCALL(join)
 492:	b8 1a 00 00 00       	mov    $0x1a,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <cps>:
SYSCALL(cps)
 49a:	b8 1b 00 00 00       	mov    $0x1b,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <chpri>:
SYSCALL(chpri)
 4a2:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    
 4aa:	66 90                	xchg   %ax,%ax
 4ac:	66 90                	xchg   %ax,%ax
 4ae:	66 90                	xchg   %ax,%ax

000004b0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	57                   	push   %edi
 4b4:	56                   	push   %esi
 4b5:	53                   	push   %ebx
 4b6:	83 ec 3c             	sub    $0x3c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b9:	85 d2                	test   %edx,%edx
{
 4bb:	89 45 c0             	mov    %eax,-0x40(%ebp)
    neg = 1;
    x = -xx;
 4be:	89 d0                	mov    %edx,%eax
  if(sgn && xx < 0){
 4c0:	79 76                	jns    538 <printint+0x88>
 4c2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 4c6:	74 70                	je     538 <printint+0x88>
    x = -xx;
 4c8:	f7 d8                	neg    %eax
    neg = 1;
 4ca:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4d1:	31 f6                	xor    %esi,%esi
 4d3:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 4d6:	eb 0a                	jmp    4e2 <printint+0x32>
 4d8:	90                   	nop
 4d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  do{
    buf[i++] = digits[x % base];
 4e0:	89 fe                	mov    %edi,%esi
 4e2:	31 d2                	xor    %edx,%edx
 4e4:	8d 7e 01             	lea    0x1(%esi),%edi
 4e7:	f7 f1                	div    %ecx
 4e9:	0f b6 92 e0 0a 00 00 	movzbl 0xae0(%edx),%edx
  }while((x /= base) != 0);
 4f0:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
 4f2:	88 14 3b             	mov    %dl,(%ebx,%edi,1)
  }while((x /= base) != 0);
 4f5:	75 e9                	jne    4e0 <printint+0x30>
  if(neg)
 4f7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 4fa:	85 c0                	test   %eax,%eax
 4fc:	74 08                	je     506 <printint+0x56>
    buf[i++] = '-';
 4fe:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
 503:	8d 7e 02             	lea    0x2(%esi),%edi
 506:	8d 74 3d d7          	lea    -0x29(%ebp,%edi,1),%esi
 50a:	8b 7d c0             	mov    -0x40(%ebp),%edi
 50d:	8d 76 00             	lea    0x0(%esi),%esi
 510:	0f b6 06             	movzbl (%esi),%eax
  write(fd, &c, 1);
 513:	83 ec 04             	sub    $0x4,%esp
 516:	83 ee 01             	sub    $0x1,%esi
 519:	6a 01                	push   $0x1
 51b:	53                   	push   %ebx
 51c:	57                   	push   %edi
 51d:	88 45 d7             	mov    %al,-0x29(%ebp)
 520:	e8 cd fe ff ff       	call   3f2 <write>

  while(--i >= 0)
 525:	83 c4 10             	add    $0x10,%esp
 528:	39 de                	cmp    %ebx,%esi
 52a:	75 e4                	jne    510 <printint+0x60>
    putc(fd, buf[i]);
}
 52c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 52f:	5b                   	pop    %ebx
 530:	5e                   	pop    %esi
 531:	5f                   	pop    %edi
 532:	5d                   	pop    %ebp
 533:	c3                   	ret    
 534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 538:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 53f:	eb 90                	jmp    4d1 <printint+0x21>
 541:	eb 0d                	jmp    550 <printf>
 543:	90                   	nop
 544:	90                   	nop
 545:	90                   	nop
 546:	90                   	nop
 547:	90                   	nop
 548:	90                   	nop
 549:	90                   	nop
 54a:	90                   	nop
 54b:	90                   	nop
 54c:	90                   	nop
 54d:	90                   	nop
 54e:	90                   	nop
 54f:	90                   	nop

00000550 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 550:	55                   	push   %ebp
 551:	89 e5                	mov    %esp,%ebp
 553:	57                   	push   %edi
 554:	56                   	push   %esi
 555:	53                   	push   %ebx
 556:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 559:	8b 75 0c             	mov    0xc(%ebp),%esi
 55c:	0f b6 1e             	movzbl (%esi),%ebx
 55f:	84 db                	test   %bl,%bl
 561:	0f 84 b3 00 00 00    	je     61a <printf+0xca>
  ap = (uint*)(void*)&fmt + 1;
 567:	8d 45 10             	lea    0x10(%ebp),%eax
 56a:	83 c6 01             	add    $0x1,%esi
  state = 0;
 56d:	31 ff                	xor    %edi,%edi
  ap = (uint*)(void*)&fmt + 1;
 56f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 572:	eb 2f                	jmp    5a3 <printf+0x53>
 574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 578:	83 f8 25             	cmp    $0x25,%eax
 57b:	0f 84 a7 00 00 00    	je     628 <printf+0xd8>
  write(fd, &c, 1);
 581:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 584:	83 ec 04             	sub    $0x4,%esp
 587:	88 5d e2             	mov    %bl,-0x1e(%ebp)
 58a:	6a 01                	push   $0x1
 58c:	50                   	push   %eax
 58d:	ff 75 08             	pushl  0x8(%ebp)
 590:	e8 5d fe ff ff       	call   3f2 <write>
 595:	83 c4 10             	add    $0x10,%esp
 598:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 59b:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 59f:	84 db                	test   %bl,%bl
 5a1:	74 77                	je     61a <printf+0xca>
    if(state == 0){
 5a3:	85 ff                	test   %edi,%edi
    c = fmt[i] & 0xff;
 5a5:	0f be cb             	movsbl %bl,%ecx
 5a8:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 5ab:	74 cb                	je     578 <printf+0x28>
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ad:	83 ff 25             	cmp    $0x25,%edi
 5b0:	75 e6                	jne    598 <printf+0x48>
      if(c == 'd'){
 5b2:	83 f8 64             	cmp    $0x64,%eax
 5b5:	0f 84 05 01 00 00    	je     6c0 <printf+0x170>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 5bb:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 5c1:	83 f9 70             	cmp    $0x70,%ecx
 5c4:	74 72                	je     638 <printf+0xe8>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 5c6:	83 f8 73             	cmp    $0x73,%eax
 5c9:	0f 84 99 00 00 00    	je     668 <printf+0x118>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5cf:	83 f8 63             	cmp    $0x63,%eax
 5d2:	0f 84 08 01 00 00    	je     6e0 <printf+0x190>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 5d8:	83 f8 25             	cmp    $0x25,%eax
 5db:	0f 84 ef 00 00 00    	je     6d0 <printf+0x180>
  write(fd, &c, 1);
 5e1:	8d 45 e7             	lea    -0x19(%ebp),%eax
 5e4:	83 ec 04             	sub    $0x4,%esp
 5e7:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 5eb:	6a 01                	push   $0x1
 5ed:	50                   	push   %eax
 5ee:	ff 75 08             	pushl  0x8(%ebp)
 5f1:	e8 fc fd ff ff       	call   3f2 <write>
 5f6:	83 c4 0c             	add    $0xc,%esp
 5f9:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 5fc:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 5ff:	6a 01                	push   $0x1
 601:	50                   	push   %eax
 602:	ff 75 08             	pushl  0x8(%ebp)
 605:	83 c6 01             	add    $0x1,%esi
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 608:	31 ff                	xor    %edi,%edi
  write(fd, &c, 1);
 60a:	e8 e3 fd ff ff       	call   3f2 <write>
  for(i = 0; fmt[i]; i++){
 60f:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
  write(fd, &c, 1);
 613:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 616:	84 db                	test   %bl,%bl
 618:	75 89                	jne    5a3 <printf+0x53>
    }
  }
}
 61a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 61d:	5b                   	pop    %ebx
 61e:	5e                   	pop    %esi
 61f:	5f                   	pop    %edi
 620:	5d                   	pop    %ebp
 621:	c3                   	ret    
 622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        state = '%';
 628:	bf 25 00 00 00       	mov    $0x25,%edi
 62d:	e9 66 ff ff ff       	jmp    598 <printf+0x48>
 632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printint(fd, *ap, 16, 0);
 638:	83 ec 0c             	sub    $0xc,%esp
 63b:	b9 10 00 00 00       	mov    $0x10,%ecx
 640:	6a 00                	push   $0x0
 642:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 645:	8b 45 08             	mov    0x8(%ebp),%eax
 648:	8b 17                	mov    (%edi),%edx
 64a:	e8 61 fe ff ff       	call   4b0 <printint>
        ap++;
 64f:	89 f8                	mov    %edi,%eax
 651:	83 c4 10             	add    $0x10,%esp
      state = 0;
 654:	31 ff                	xor    %edi,%edi
        ap++;
 656:	83 c0 04             	add    $0x4,%eax
 659:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 65c:	e9 37 ff ff ff       	jmp    598 <printf+0x48>
 661:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = (char*)*ap;
 668:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 66b:	8b 08                	mov    (%eax),%ecx
        ap++;
 66d:	83 c0 04             	add    $0x4,%eax
 670:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(s == 0)
 673:	85 c9                	test   %ecx,%ecx
 675:	0f 84 8e 00 00 00    	je     709 <printf+0x1b9>
        while(*s != 0){
 67b:	0f b6 01             	movzbl (%ecx),%eax
      state = 0;
 67e:	31 ff                	xor    %edi,%edi
        s = (char*)*ap;
 680:	89 cb                	mov    %ecx,%ebx
        while(*s != 0){
 682:	84 c0                	test   %al,%al
 684:	0f 84 0e ff ff ff    	je     598 <printf+0x48>
 68a:	89 75 d0             	mov    %esi,-0x30(%ebp)
 68d:	89 de                	mov    %ebx,%esi
 68f:	8b 5d 08             	mov    0x8(%ebp),%ebx
 692:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 695:	8d 76 00             	lea    0x0(%esi),%esi
  write(fd, &c, 1);
 698:	83 ec 04             	sub    $0x4,%esp
          s++;
 69b:	83 c6 01             	add    $0x1,%esi
 69e:	88 45 e3             	mov    %al,-0x1d(%ebp)
  write(fd, &c, 1);
 6a1:	6a 01                	push   $0x1
 6a3:	57                   	push   %edi
 6a4:	53                   	push   %ebx
 6a5:	e8 48 fd ff ff       	call   3f2 <write>
        while(*s != 0){
 6aa:	0f b6 06             	movzbl (%esi),%eax
 6ad:	83 c4 10             	add    $0x10,%esp
 6b0:	84 c0                	test   %al,%al
 6b2:	75 e4                	jne    698 <printf+0x148>
 6b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 6b7:	31 ff                	xor    %edi,%edi
 6b9:	e9 da fe ff ff       	jmp    598 <printf+0x48>
 6be:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 10, 1);
 6c0:	83 ec 0c             	sub    $0xc,%esp
 6c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
 6c8:	6a 01                	push   $0x1
 6ca:	e9 73 ff ff ff       	jmp    642 <printf+0xf2>
 6cf:	90                   	nop
  write(fd, &c, 1);
 6d0:	83 ec 04             	sub    $0x4,%esp
 6d3:	88 5d e5             	mov    %bl,-0x1b(%ebp)
 6d6:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 6d9:	6a 01                	push   $0x1
 6db:	e9 21 ff ff ff       	jmp    601 <printf+0xb1>
        putc(fd, *ap);
 6e0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  write(fd, &c, 1);
 6e3:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 6e6:	8b 07                	mov    (%edi),%eax
  write(fd, &c, 1);
 6e8:	6a 01                	push   $0x1
        ap++;
 6ea:	83 c7 04             	add    $0x4,%edi
        putc(fd, *ap);
 6ed:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 6f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 6f3:	50                   	push   %eax
 6f4:	ff 75 08             	pushl  0x8(%ebp)
 6f7:	e8 f6 fc ff ff       	call   3f2 <write>
        ap++;
 6fc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 6ff:	83 c4 10             	add    $0x10,%esp
      state = 0;
 702:	31 ff                	xor    %edi,%edi
 704:	e9 8f fe ff ff       	jmp    598 <printf+0x48>
          s = "(null)";
 709:	bb d7 0a 00 00       	mov    $0xad7,%ebx
        while(*s != 0){
 70e:	b8 28 00 00 00       	mov    $0x28,%eax
 713:	e9 72 ff ff ff       	jmp    68a <printf+0x13a>
 718:	66 90                	xchg   %ax,%ax
 71a:	66 90                	xchg   %ax,%ax
 71c:	66 90                	xchg   %ax,%ax
 71e:	66 90                	xchg   %ax,%ax

00000720 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 720:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 721:	a1 00 0f 00 00       	mov    0xf00,%eax
{
 726:	89 e5                	mov    %esp,%ebp
 728:	57                   	push   %edi
 729:	56                   	push   %esi
 72a:	53                   	push   %ebx
 72b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = (Header*)ap - 1;
 72e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
 731:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 738:	39 c8                	cmp    %ecx,%eax
 73a:	8b 10                	mov    (%eax),%edx
 73c:	73 32                	jae    770 <free+0x50>
 73e:	39 d1                	cmp    %edx,%ecx
 740:	72 04                	jb     746 <free+0x26>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 742:	39 d0                	cmp    %edx,%eax
 744:	72 32                	jb     778 <free+0x58>
      break;
  if(bp + bp->s.size == p->s.ptr){
 746:	8b 73 fc             	mov    -0x4(%ebx),%esi
 749:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 74c:	39 fa                	cmp    %edi,%edx
 74e:	74 30                	je     780 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 750:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 753:	8b 50 04             	mov    0x4(%eax),%edx
 756:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 759:	39 f1                	cmp    %esi,%ecx
 75b:	74 3a                	je     797 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 75d:	89 08                	mov    %ecx,(%eax)
  freep = p;
 75f:	a3 00 0f 00 00       	mov    %eax,0xf00
}
 764:	5b                   	pop    %ebx
 765:	5e                   	pop    %esi
 766:	5f                   	pop    %edi
 767:	5d                   	pop    %ebp
 768:	c3                   	ret    
 769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 770:	39 d0                	cmp    %edx,%eax
 772:	72 04                	jb     778 <free+0x58>
 774:	39 d1                	cmp    %edx,%ecx
 776:	72 ce                	jb     746 <free+0x26>
{
 778:	89 d0                	mov    %edx,%eax
 77a:	eb bc                	jmp    738 <free+0x18>
 77c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp->s.size += p->s.ptr->s.size;
 780:	03 72 04             	add    0x4(%edx),%esi
 783:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 786:	8b 10                	mov    (%eax),%edx
 788:	8b 12                	mov    (%edx),%edx
 78a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 78d:	8b 50 04             	mov    0x4(%eax),%edx
 790:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 793:	39 f1                	cmp    %esi,%ecx
 795:	75 c6                	jne    75d <free+0x3d>
    p->s.size += bp->s.size;
 797:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 79a:	a3 00 0f 00 00       	mov    %eax,0xf00
    p->s.size += bp->s.size;
 79f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7a2:	8b 53 f8             	mov    -0x8(%ebx),%edx
 7a5:	89 10                	mov    %edx,(%eax)
}
 7a7:	5b                   	pop    %ebx
 7a8:	5e                   	pop    %esi
 7a9:	5f                   	pop    %edi
 7aa:	5d                   	pop    %ebp
 7ab:	c3                   	ret    
 7ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000007b0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7b0:	55                   	push   %ebp
 7b1:	89 e5                	mov    %esp,%ebp
 7b3:	57                   	push   %edi
 7b4:	56                   	push   %esi
 7b5:	53                   	push   %ebx
 7b6:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b9:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 7bc:	8b 15 00 0f 00 00    	mov    0xf00,%edx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c2:	8d 78 07             	lea    0x7(%eax),%edi
 7c5:	c1 ef 03             	shr    $0x3,%edi
 7c8:	83 c7 01             	add    $0x1,%edi
  if((prevp = freep) == 0){
 7cb:	85 d2                	test   %edx,%edx
 7cd:	0f 84 9d 00 00 00    	je     870 <malloc+0xc0>
 7d3:	8b 02                	mov    (%edx),%eax
 7d5:	8b 48 04             	mov    0x4(%eax),%ecx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 7d8:	39 cf                	cmp    %ecx,%edi
 7da:	76 6c                	jbe    848 <malloc+0x98>
 7dc:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
 7e2:	bb 00 10 00 00       	mov    $0x1000,%ebx
 7e7:	0f 43 df             	cmovae %edi,%ebx
  p = sbrk(nu * sizeof(Header));
 7ea:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 7f1:	eb 0e                	jmp    801 <malloc+0x51>
 7f3:	90                   	nop
 7f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f8:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 7fa:	8b 48 04             	mov    0x4(%eax),%ecx
 7fd:	39 f9                	cmp    %edi,%ecx
 7ff:	73 47                	jae    848 <malloc+0x98>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 801:	39 05 00 0f 00 00    	cmp    %eax,0xf00
 807:	89 c2                	mov    %eax,%edx
 809:	75 ed                	jne    7f8 <malloc+0x48>
  p = sbrk(nu * sizeof(Header));
 80b:	83 ec 0c             	sub    $0xc,%esp
 80e:	56                   	push   %esi
 80f:	e8 4e fc ff ff       	call   462 <sbrk>
  if(p == (char*)-1)
 814:	83 c4 10             	add    $0x10,%esp
 817:	83 f8 ff             	cmp    $0xffffffff,%eax
 81a:	74 1c                	je     838 <malloc+0x88>
  hp->s.size = nu;
 81c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 81f:	83 ec 0c             	sub    $0xc,%esp
 822:	83 c0 08             	add    $0x8,%eax
 825:	50                   	push   %eax
 826:	e8 f5 fe ff ff       	call   720 <free>
  return freep;
 82b:	8b 15 00 0f 00 00    	mov    0xf00,%edx
      if((p = morecore(nunits)) == 0)
 831:	83 c4 10             	add    $0x10,%esp
 834:	85 d2                	test   %edx,%edx
 836:	75 c0                	jne    7f8 <malloc+0x48>
        return 0;
  }
}
 838:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 83b:	31 c0                	xor    %eax,%eax
}
 83d:	5b                   	pop    %ebx
 83e:	5e                   	pop    %esi
 83f:	5f                   	pop    %edi
 840:	5d                   	pop    %ebp
 841:	c3                   	ret    
 842:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 848:	39 cf                	cmp    %ecx,%edi
 84a:	74 54                	je     8a0 <malloc+0xf0>
        p->s.size -= nunits;
 84c:	29 f9                	sub    %edi,%ecx
 84e:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 851:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 854:	89 78 04             	mov    %edi,0x4(%eax)
      freep = prevp;
 857:	89 15 00 0f 00 00    	mov    %edx,0xf00
}
 85d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 860:	83 c0 08             	add    $0x8,%eax
}
 863:	5b                   	pop    %ebx
 864:	5e                   	pop    %esi
 865:	5f                   	pop    %edi
 866:	5d                   	pop    %ebp
 867:	c3                   	ret    
 868:	90                   	nop
 869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    base.s.ptr = freep = prevp = &base;
 870:	c7 05 00 0f 00 00 04 	movl   $0xf04,0xf00
 877:	0f 00 00 
 87a:	c7 05 04 0f 00 00 04 	movl   $0xf04,0xf04
 881:	0f 00 00 
    base.s.size = 0;
 884:	b8 04 0f 00 00       	mov    $0xf04,%eax
 889:	c7 05 08 0f 00 00 00 	movl   $0x0,0xf08
 890:	00 00 00 
 893:	e9 44 ff ff ff       	jmp    7dc <malloc+0x2c>
 898:	90                   	nop
 899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        prevp->s.ptr = p->s.ptr;
 8a0:	8b 08                	mov    (%eax),%ecx
 8a2:	89 0a                	mov    %ecx,(%edx)
 8a4:	eb b1                	jmp    857 <malloc+0xa7>
 8a6:	66 90                	xchg   %ax,%ax
 8a8:	66 90                	xchg   %ax,%ax
 8aa:	66 90                	xchg   %ax,%ax
 8ac:	66 90                	xchg   %ax,%ax
 8ae:	66 90                	xchg   %ax,%ax

000008b0 <remove_thread>:
    void *ustack;
    int used;
} threads[NTHREAD] = {0};

void remove_thread(int *pid)
{
 8b0:	55                   	push   %ebp
 8b1:	b8 20 0f 00 00       	mov    $0xf20,%eax
    for (int i = 0; i < NTHREAD; ++i)
 8b6:	31 d2                	xor    %edx,%edx
{
 8b8:	89 e5                	mov    %esp,%ebp
 8ba:	56                   	push   %esi
 8bb:	53                   	push   %ebx
 8bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
    {
        if (threads[i].used && threads[i].pid == *pid)
 8bf:	8b 58 08             	mov    0x8(%eax),%ebx
 8c2:	85 db                	test   %ebx,%ebx
 8c4:	74 06                	je     8cc <remove_thread+0x1c>
 8c6:	8b 31                	mov    (%ecx),%esi
 8c8:	39 30                	cmp    %esi,(%eax)
 8ca:	74 14                	je     8e0 <remove_thread+0x30>
    for (int i = 0; i < NTHREAD; ++i)
 8cc:	83 c2 01             	add    $0x1,%edx
 8cf:	83 c0 0c             	add    $0xc,%eax
 8d2:	83 fa 04             	cmp    $0x4,%edx
 8d5:	75 e8                	jne    8bf <remove_thread+0xf>
            threads[i].ustack = 0;
            threads[i].used = 0;
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
            free(threads[i].ustack);
 8e0:	8d 1c 52             	lea    (%edx,%edx,2),%ebx
 8e3:	83 ec 0c             	sub    $0xc,%esp
 8e6:	c1 e3 02             	shl    $0x2,%ebx
 8e9:	ff b3 24 0f 00 00    	pushl  0xf24(%ebx)
 8ef:	e8 2c fe ff ff       	call   720 <free>
            threads[i].pid = 0;
 8f4:	c7 83 20 0f 00 00 00 	movl   $0x0,0xf20(%ebx)
 8fb:	00 00 00 
            threads[i].ustack = 0;
 8fe:	c7 83 24 0f 00 00 00 	movl   $0x0,0xf24(%ebx)
 905:	00 00 00 
            break;
 908:	83 c4 10             	add    $0x10,%esp
            threads[i].used = 0;
 90b:	c7 83 28 0f 00 00 00 	movl   $0x0,0xf28(%ebx)
 912:	00 00 00 
}
 915:	8d 65 f8             	lea    -0x8(%ebp),%esp
 918:	5b                   	pop    %ebx
 919:	5e                   	pop    %esi
 91a:	5d                   	pop    %ebp
 91b:	c3                   	ret    
 91c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000920 <findPos>:

int findPos()
{
 920:	55                   	push   %ebp
 921:	ba 20 0f 00 00       	mov    $0xf20,%edx
    for (int i = 0; i < NTHREAD; ++i)
 926:	31 c0                	xor    %eax,%eax
{
 928:	89 e5                	mov    %esp,%ebp
    {
        if (threads[i].used == 0)
 92a:	8b 4a 08             	mov    0x8(%edx),%ecx
 92d:	85 c9                	test   %ecx,%ecx
 92f:	74 10                	je     941 <findPos+0x21>
    for (int i = 0; i < NTHREAD; ++i)
 931:	83 c0 01             	add    $0x1,%eax
 934:	83 c2 0c             	add    $0xc,%edx
 937:	83 f8 04             	cmp    $0x4,%eax
 93a:	75 ee                	jne    92a <findPos+0xa>
        {
            return i;
        }
    }
    return -1;
 93c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 941:	5d                   	pop    %ebp
 942:	c3                   	ret    
 943:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 949:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000950 <thread_create>:

int thread_create(void (*start_routine)(void *), void *arg)
{
 950:	55                   	push   %ebp
 951:	b8 20 0f 00 00       	mov    $0xf20,%eax
 956:	89 e5                	mov    %esp,%ebp
 958:	56                   	push   %esi
 959:	53                   	push   %ebx
    for (int i = 0; i < NTHREAD; ++i)
 95a:	31 db                	xor    %ebx,%ebx
{
 95c:	83 ec 10             	sub    $0x10,%esp
        if (threads[i].used == 0)
 95f:	8b 50 08             	mov    0x8(%eax),%edx
 962:	85 d2                	test   %edx,%edx
 964:	74 2a                	je     990 <thread_create+0x40>
    for (int i = 0; i < NTHREAD; ++i)
 966:	83 c3 01             	add    $0x1,%ebx
 969:	83 c0 0c             	add    $0xc,%eax
 96c:	83 fb 04             	cmp    $0x4,%ebx
 96f:	75 ee                	jne    95f <thread_create+0xf>
    int pos = findPos();
    if (pos == -1)
    {
        printf(1, "Create thread failed! Perhaps because there are too many threads!\n");
 971:	83 ec 08             	sub    $0x8,%esp
 974:	68 0c 0b 00 00       	push   $0xb0c
 979:	6a 01                	push   $0x1
 97b:	e8 d0 fb ff ff       	call   550 <printf>
        return -1;
 980:	83 c4 10             	add    $0x10,%esp
        threads[pos].pid = pid;
        threads[pos].ustack = stack;
        threads[pos].used = 1;
    }
    return pid;
}
 983:	8d 65 f8             	lea    -0x8(%ebp),%esp
        return -1;
 986:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 98b:	5b                   	pop    %ebx
 98c:	5e                   	pop    %esi
 98d:	5d                   	pop    %ebp
 98e:	c3                   	ret    
 98f:	90                   	nop
    void *stack = malloc(PGSIZE);
 990:	83 ec 0c             	sub    $0xc,%esp
 993:	68 00 10 00 00       	push   $0x1000
 998:	e8 13 fe ff ff       	call   7b0 <malloc>
    int pid = clone(start_routine, arg, stack);
 99d:	83 c4 0c             	add    $0xc,%esp
    void *stack = malloc(PGSIZE);
 9a0:	89 c6                	mov    %eax,%esi
    int pid = clone(start_routine, arg, stack);
 9a2:	50                   	push   %eax
 9a3:	ff 75 0c             	pushl  0xc(%ebp)
 9a6:	ff 75 08             	pushl  0x8(%ebp)
 9a9:	e8 dc fa ff ff       	call   48a <clone>
    if (pid == -1)
 9ae:	83 c4 10             	add    $0x10,%esp
 9b1:	83 f8 ff             	cmp    $0xffffffff,%eax
 9b4:	74 2a                	je     9e0 <thread_create+0x90>
        threads[pos].pid = pid;
 9b6:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
 9b9:	c1 e2 02             	shl    $0x2,%edx
        threads[pos].ustack = stack;
 9bc:	89 b2 24 0f 00 00    	mov    %esi,0xf24(%edx)
        threads[pos].pid = pid;
 9c2:	89 82 20 0f 00 00    	mov    %eax,0xf20(%edx)
        threads[pos].used = 1;
 9c8:	c7 82 28 0f 00 00 01 	movl   $0x1,0xf28(%edx)
 9cf:	00 00 00 
}
 9d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
 9d5:	5b                   	pop    %ebx
 9d6:	5e                   	pop    %esi
 9d7:	5d                   	pop    %ebp
 9d8:	c3                   	ret    
 9d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        printf(1, "clone failed!\n");
 9e0:	83 ec 08             	sub    $0x8,%esp
 9e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9e6:	68 f1 0a 00 00       	push   $0xaf1
 9eb:	6a 01                	push   $0x1
 9ed:	e8 5e fb ff ff       	call   550 <printf>
        free(stack);
 9f2:	89 34 24             	mov    %esi,(%esp)
 9f5:	e8 26 fd ff ff       	call   720 <free>
 9fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fd:	83 c4 10             	add    $0x10,%esp
}
 a00:	8d 65 f8             	lea    -0x8(%ebp),%esp
 a03:	5b                   	pop    %ebx
 a04:	5e                   	pop    %esi
 a05:	5d                   	pop    %ebp
 a06:	c3                   	ret    
 a07:	89 f6                	mov    %esi,%esi
 a09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000a10 <thread_join>:

int thread_join(void)
{
 a10:	55                   	push   %ebp
 a11:	89 e5                	mov    %esp,%ebp
 a13:	53                   	push   %ebx
 a14:	bb 20 0f 00 00       	mov    $0xf20,%ebx
 a19:	83 ec 14             	sub    $0x14,%esp
    for (int i = 0; i < NTHREAD; ++i)
    {
        if (threads[i].used == 1)
 a1c:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
 a20:	74 16                	je     a38 <thread_join+0x28>
 a22:	83 c3 0c             	add    $0xc,%ebx
    for (int i = 0; i < NTHREAD; ++i)
 a25:	81 fb 50 0f 00 00    	cmp    $0xf50,%ebx
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
            int pid = join(&threads[i].ustack);
 a38:	8d 43 04             	lea    0x4(%ebx),%eax
 a3b:	83 ec 0c             	sub    $0xc,%esp
 a3e:	50                   	push   %eax
 a3f:	e8 4e fa ff ff       	call   492 <join>
            if (pid > 0)
 a44:	83 c4 10             	add    $0x10,%esp
 a47:	85 c0                	test   %eax,%eax
            int pid = join(&threads[i].ustack);
 a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (pid > 0)
 a4c:	7e d4                	jle    a22 <thread_join+0x12>
                remove_thread(&pid);
 a4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 a51:	83 ec 0c             	sub    $0xc,%esp
 a54:	50                   	push   %eax
 a55:	e8 56 fe ff ff       	call   8b0 <remove_thread>
                return pid;
 a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5d:	83 c4 10             	add    $0x10,%esp
 a60:	eb cd                	jmp    a2f <thread_join+0x1f>
 a62:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 a69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000a70 <printTCB>:

void printTCB(void)
{
 a70:	55                   	push   %ebp
 a71:	89 e5                	mov    %esp,%ebp
 a73:	53                   	push   %ebx
    for (int i = 0; i < NTHREAD; ++i)
 a74:	31 db                	xor    %ebx,%ebx
{
 a76:	83 ec 04             	sub    $0x4,%esp
    {
        printf(1, "TCB %d:%d\n", i, threads[i].used);
 a79:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
 a7c:	ff 34 85 28 0f 00 00 	pushl  0xf28(,%eax,4)
 a83:	53                   	push   %ebx
    for (int i = 0; i < NTHREAD; ++i)
 a84:	83 c3 01             	add    $0x1,%ebx
        printf(1, "TCB %d:%d\n", i, threads[i].used);
 a87:	68 00 0b 00 00       	push   $0xb00
 a8c:	6a 01                	push   $0x1
 a8e:	e8 bd fa ff ff       	call   550 <printf>
    for (int i = 0; i < NTHREAD; ++i)
 a93:	83 c4 10             	add    $0x10,%esp
 a96:	83 fb 04             	cmp    $0x4,%ebx
 a99:	75 de                	jne    a79 <printTCB+0x9>
    }
}
 a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 a9e:	c9                   	leave  
 a9f:	c3                   	ret    
