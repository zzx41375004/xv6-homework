
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc d0 c5 10 80       	mov    $0x8010c5d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 30 2f 10 80       	mov    $0x80102f30,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
80100046:	68 a0 78 10 80       	push   $0x801078a0
8010004b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100050:	e8 4b 49 00 00       	call   801049a0 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100055:	c7 05 f0 04 11 80 e4 	movl   $0x801104e4,0x801104f0
8010005c:	04 11 80 
  bcache.head.next = &bcache.head;
8010005f:	c7 05 f4 04 11 80 e4 	movl   $0x801104e4,0x801104f4
80100066:	04 11 80 
80100069:	83 c4 10             	add    $0x10,%esp
8010006c:	b9 e4 04 11 80       	mov    $0x801104e4,%ecx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100071:	b8 14 c6 10 80       	mov    $0x8010c614,%eax
80100076:	eb 0a                	jmp    80100082 <binit+0x42>
80100078:	90                   	nop
80100079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 d0                	mov    %edx,%eax
    b->next = bcache.head.next;
80100082:	89 48 10             	mov    %ecx,0x10(%eax)
    b->prev = &bcache.head;
80100085:	c7 40 0c e4 04 11 80 	movl   $0x801104e4,0xc(%eax)
8010008c:	89 c1                	mov    %eax,%ecx
    b->dev = -1;
8010008e:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
80100095:	8b 15 f4 04 11 80    	mov    0x801104f4,%edx
8010009b:	89 42 0c             	mov    %eax,0xc(%edx)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	8d 90 18 02 00 00    	lea    0x218(%eax),%edx
    bcache.head.next = b;
801000a4:	a3 f4 04 11 80       	mov    %eax,0x801104f4
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a9:	81 fa e4 04 11 80    	cmp    $0x801104e4,%edx
801000af:	72 cf                	jb     80100080 <binit+0x40>
  }
}
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    
801000b3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801000b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801000c0 <bread>:
}

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000c0:	55                   	push   %ebp
801000c1:	89 e5                	mov    %esp,%ebp
801000c3:	57                   	push   %edi
801000c4:	56                   	push   %esi
801000c5:	53                   	push   %ebx
801000c6:	83 ec 18             	sub    $0x18,%esp
801000c9:	8b 75 08             	mov    0x8(%ebp),%esi
801000cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  acquire(&bcache.lock);
801000cf:	68 e0 c5 10 80       	push   $0x8010c5e0
801000d4:	e8 e7 48 00 00       	call   801049c0 <acquire>
801000d9:	83 c4 10             	add    $0x10,%esp
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000dc:	8b 1d f4 04 11 80    	mov    0x801104f4,%ebx
801000e2:	81 fb e4 04 11 80    	cmp    $0x801104e4,%ebx
801000e8:	75 11                	jne    801000fb <bread+0x3b>
801000ea:	eb 34                	jmp    80100120 <bread+0x60>
801000ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801000f0:	8b 5b 10             	mov    0x10(%ebx),%ebx
801000f3:	81 fb e4 04 11 80    	cmp    $0x801104e4,%ebx
801000f9:	74 25                	je     80100120 <bread+0x60>
    if(b->dev == dev && b->blockno == blockno){
801000fb:	3b 73 04             	cmp    0x4(%ebx),%esi
801000fe:	75 f0                	jne    801000f0 <bread+0x30>
80100100:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100103:	75 eb                	jne    801000f0 <bread+0x30>
      if(!(b->flags & B_BUSY)){
80100105:	8b 03                	mov    (%ebx),%eax
80100107:	a8 01                	test   $0x1,%al
80100109:	74 6c                	je     80100177 <bread+0xb7>
      sleep(b, &bcache.lock);
8010010b:	83 ec 08             	sub    $0x8,%esp
8010010e:	68 e0 c5 10 80       	push   $0x8010c5e0
80100113:	53                   	push   %ebx
80100114:	e8 47 3f 00 00       	call   80104060 <sleep>
80100119:	83 c4 10             	add    $0x10,%esp
8010011c:	eb be                	jmp    801000dc <bread+0x1c>
8010011e:	66 90                	xchg   %ax,%ax
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d f0 04 11 80    	mov    0x801104f0,%ebx
80100126:	81 fb e4 04 11 80    	cmp    $0x801104e4,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x7b>
8010012e:	eb 5e                	jmp    8010018e <bread+0xce>
80100130:	8b 5b 0c             	mov    0xc(%ebx),%ebx
80100133:	81 fb e4 04 11 80    	cmp    $0x801104e4,%ebx
80100139:	74 53                	je     8010018e <bread+0xce>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010013b:	f6 03 05             	testb  $0x5,(%ebx)
8010013e:	75 f0                	jne    80100130 <bread+0x70>
      release(&bcache.lock);
80100140:	83 ec 0c             	sub    $0xc,%esp
      b->dev = dev;
80100143:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
80100146:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = B_BUSY;
80100149:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
      release(&bcache.lock);
8010014f:	68 e0 c5 10 80       	push   $0x8010c5e0
80100154:	e8 27 4a 00 00       	call   80104b80 <release>
80100159:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if(!(b->flags & B_VALID)) {
8010015c:	f6 03 02             	testb  $0x2,(%ebx)
8010015f:	75 0c                	jne    8010016d <bread+0xad>
    iderw(b);
80100161:	83 ec 0c             	sub    $0xc,%esp
80100164:	53                   	push   %ebx
80100165:	e8 a6 1f 00 00       	call   80102110 <iderw>
8010016a:	83 c4 10             	add    $0x10,%esp
  }
  return b;
}
8010016d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100170:	89 d8                	mov    %ebx,%eax
80100172:	5b                   	pop    %ebx
80100173:	5e                   	pop    %esi
80100174:	5f                   	pop    %edi
80100175:	5d                   	pop    %ebp
80100176:	c3                   	ret    
        release(&bcache.lock);
80100177:	83 ec 0c             	sub    $0xc,%esp
        b->flags |= B_BUSY;
8010017a:	83 c8 01             	or     $0x1,%eax
8010017d:	89 03                	mov    %eax,(%ebx)
        release(&bcache.lock);
8010017f:	68 e0 c5 10 80       	push   $0x8010c5e0
80100184:	e8 f7 49 00 00       	call   80104b80 <release>
80100189:	83 c4 10             	add    $0x10,%esp
8010018c:	eb ce                	jmp    8010015c <bread+0x9c>
  panic("bget: no buffers");
8010018e:	83 ec 0c             	sub    $0xc,%esp
80100191:	68 a7 78 10 80       	push   $0x801078a7
80100196:	e8 d5 01 00 00       	call   80100370 <panic>
8010019b:	90                   	nop
8010019c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801001a0 <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001a0:	55                   	push   %ebp
801001a1:	89 e5                	mov    %esp,%ebp
801001a3:	83 ec 08             	sub    $0x8,%esp
801001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  if((b->flags & B_BUSY) == 0)
801001a9:	8b 02                	mov    (%edx),%eax
801001ab:	a8 01                	test   $0x1,%al
801001ad:	74 0b                	je     801001ba <bwrite+0x1a>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001af:	83 c8 04             	or     $0x4,%eax
801001b2:	89 02                	mov    %eax,(%edx)
  iderw(b);
}
801001b4:	c9                   	leave  
  iderw(b);
801001b5:	e9 56 1f 00 00       	jmp    80102110 <iderw>
    panic("bwrite");
801001ba:	83 ec 0c             	sub    $0xc,%esp
801001bd:	68 b8 78 10 80       	push   $0x801078b8
801001c2:	e8 a9 01 00 00       	call   80100370 <panic>
801001c7:	89 f6                	mov    %esi,%esi
801001c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801001d0 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d0:	55                   	push   %ebp
801001d1:	89 e5                	mov    %esp,%ebp
801001d3:	53                   	push   %ebx
801001d4:	83 ec 04             	sub    $0x4,%esp
801001d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((b->flags & B_BUSY) == 0)
801001da:	f6 03 01             	testb  $0x1,(%ebx)
801001dd:	74 5a                	je     80100239 <brelse+0x69>
    panic("brelse");

  acquire(&bcache.lock);
801001df:	83 ec 0c             	sub    $0xc,%esp
801001e2:	68 e0 c5 10 80       	push   $0x8010c5e0
801001e7:	e8 d4 47 00 00       	call   801049c0 <acquire>

  b->next->prev = b->prev;
801001ec:	8b 43 10             	mov    0x10(%ebx),%eax
801001ef:	8b 53 0c             	mov    0xc(%ebx),%edx
801001f2:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
801001f5:	8b 43 0c             	mov    0xc(%ebx),%eax
801001f8:	8b 53 10             	mov    0x10(%ebx),%edx
801001fb:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
801001fe:	a1 f4 04 11 80       	mov    0x801104f4,%eax
  b->prev = &bcache.head;
80100203:	c7 43 0c e4 04 11 80 	movl   $0x801104e4,0xc(%ebx)
  b->next = bcache.head.next;
8010020a:	89 43 10             	mov    %eax,0x10(%ebx)
  bcache.head.next->prev = b;
8010020d:	a1 f4 04 11 80       	mov    0x801104f4,%eax
80100212:	89 58 0c             	mov    %ebx,0xc(%eax)
  bcache.head.next = b;
80100215:	89 1d f4 04 11 80    	mov    %ebx,0x801104f4

  b->flags &= ~B_BUSY;
8010021b:	83 23 fe             	andl   $0xfffffffe,(%ebx)
  wakeup(b);
8010021e:	89 1c 24             	mov    %ebx,(%esp)
80100221:	e8 2a 40 00 00       	call   80104250 <wakeup>

  release(&bcache.lock);
80100226:	83 c4 10             	add    $0x10,%esp
80100229:	c7 45 08 e0 c5 10 80 	movl   $0x8010c5e0,0x8(%ebp)
}
80100230:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100233:	c9                   	leave  
  release(&bcache.lock);
80100234:	e9 47 49 00 00       	jmp    80104b80 <release>
    panic("brelse");
80100239:	83 ec 0c             	sub    $0xc,%esp
8010023c:	68 bf 78 10 80       	push   $0x801078bf
80100241:	e8 2a 01 00 00       	call   80100370 <panic>
80100246:	66 90                	xchg   %ax,%ax
80100248:	66 90                	xchg   %ax,%ax
8010024a:	66 90                	xchg   %ax,%ax
8010024c:	66 90                	xchg   %ax,%ax
8010024e:	66 90                	xchg   %ax,%ax

80100250 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100250:	55                   	push   %ebp
80100251:	89 e5                	mov    %esp,%ebp
80100253:	57                   	push   %edi
80100254:	56                   	push   %esi
80100255:	53                   	push   %ebx
80100256:	83 ec 28             	sub    $0x28,%esp
80100259:	8b 7d 08             	mov    0x8(%ebp),%edi
8010025c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010025f:	57                   	push   %edi
80100260:	e8 bb 14 00 00       	call   80101720 <iunlock>
  target = n;
  acquire(&cons.lock);
80100265:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010026c:	e8 4f 47 00 00       	call   801049c0 <acquire>
  while(n > 0){
80100271:	8b 5d 10             	mov    0x10(%ebp),%ebx
80100274:	83 c4 10             	add    $0x10,%esp
80100277:	31 c0                	xor    %eax,%eax
80100279:	85 db                	test   %ebx,%ebx
8010027b:	0f 8e a1 00 00 00    	jle    80100322 <consoleread+0xd2>
    while(input.r == input.w){
80100281:	8b 15 80 07 11 80    	mov    0x80110780,%edx
80100287:	39 15 84 07 11 80    	cmp    %edx,0x80110784
8010028d:	74 2c                	je     801002bb <consoleread+0x6b>
8010028f:	eb 5f                	jmp    801002f0 <consoleread+0xa0>
80100291:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(proc->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
80100298:	83 ec 08             	sub    $0x8,%esp
8010029b:	68 20 b5 10 80       	push   $0x8010b520
801002a0:	68 80 07 11 80       	push   $0x80110780
801002a5:	e8 b6 3d 00 00       	call   80104060 <sleep>
    while(input.r == input.w){
801002aa:	8b 15 80 07 11 80    	mov    0x80110780,%edx
801002b0:	83 c4 10             	add    $0x10,%esp
801002b3:	3b 15 84 07 11 80    	cmp    0x80110784,%edx
801002b9:	75 35                	jne    801002f0 <consoleread+0xa0>
      if(proc->killed){
801002bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801002c1:	8b 40 48             	mov    0x48(%eax),%eax
801002c4:	85 c0                	test   %eax,%eax
801002c6:	74 d0                	je     80100298 <consoleread+0x48>
        release(&cons.lock);
801002c8:	83 ec 0c             	sub    $0xc,%esp
801002cb:	68 20 b5 10 80       	push   $0x8010b520
801002d0:	e8 ab 48 00 00       	call   80104b80 <release>
        ilock(ip);
801002d5:	89 3c 24             	mov    %edi,(%esp)
801002d8:	e8 33 13 00 00       	call   80101610 <ilock>
        return -1;
801002dd:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
801002e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801002e8:	5b                   	pop    %ebx
801002e9:	5e                   	pop    %esi
801002ea:	5f                   	pop    %edi
801002eb:	5d                   	pop    %ebp
801002ec:	c3                   	ret    
801002ed:	8d 76 00             	lea    0x0(%esi),%esi
    c = input.buf[input.r++ % INPUT_BUF];
801002f0:	8d 42 01             	lea    0x1(%edx),%eax
801002f3:	a3 80 07 11 80       	mov    %eax,0x80110780
801002f8:	89 d0                	mov    %edx,%eax
801002fa:	83 e0 7f             	and    $0x7f,%eax
801002fd:	0f be 80 00 07 11 80 	movsbl -0x7feef900(%eax),%eax
    if(c == C('D')){  // EOF
80100304:	83 f8 04             	cmp    $0x4,%eax
80100307:	74 3f                	je     80100348 <consoleread+0xf8>
    *dst++ = c;
80100309:	83 c6 01             	add    $0x1,%esi
    --n;
8010030c:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
8010030f:	83 f8 0a             	cmp    $0xa,%eax
    *dst++ = c;
80100312:	88 46 ff             	mov    %al,-0x1(%esi)
    if(c == '\n')
80100315:	74 43                	je     8010035a <consoleread+0x10a>
  while(n > 0){
80100317:	85 db                	test   %ebx,%ebx
80100319:	0f 85 62 ff ff ff    	jne    80100281 <consoleread+0x31>
8010031f:	8b 45 10             	mov    0x10(%ebp),%eax
  release(&cons.lock);
80100322:	83 ec 0c             	sub    $0xc,%esp
80100325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100328:	68 20 b5 10 80       	push   $0x8010b520
8010032d:	e8 4e 48 00 00       	call   80104b80 <release>
  ilock(ip);
80100332:	89 3c 24             	mov    %edi,(%esp)
80100335:	e8 d6 12 00 00       	call   80101610 <ilock>
  return target - n;
8010033a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010033d:	83 c4 10             	add    $0x10,%esp
}
80100340:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100343:	5b                   	pop    %ebx
80100344:	5e                   	pop    %esi
80100345:	5f                   	pop    %edi
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    
80100348:	8b 45 10             	mov    0x10(%ebp),%eax
8010034b:	29 d8                	sub    %ebx,%eax
      if(n < target){
8010034d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
80100350:	73 d0                	jae    80100322 <consoleread+0xd2>
        input.r--;
80100352:	89 15 80 07 11 80    	mov    %edx,0x80110780
80100358:	eb c8                	jmp    80100322 <consoleread+0xd2>
8010035a:	8b 45 10             	mov    0x10(%ebp),%eax
8010035d:	29 d8                	sub    %ebx,%eax
8010035f:	eb c1                	jmp    80100322 <consoleread+0xd2>
80100361:	eb 0d                	jmp    80100370 <panic>
80100363:	90                   	nop
80100364:	90                   	nop
80100365:	90                   	nop
80100366:	90                   	nop
80100367:	90                   	nop
80100368:	90                   	nop
80100369:	90                   	nop
8010036a:	90                   	nop
8010036b:	90                   	nop
8010036c:	90                   	nop
8010036d:	90                   	nop
8010036e:	90                   	nop
8010036f:	90                   	nop

80100370 <panic>:
{
80100370:	55                   	push   %ebp
80100371:	89 e5                	mov    %esp,%ebp
80100373:	56                   	push   %esi
80100374:	53                   	push   %ebx
80100375:	83 ec 38             	sub    $0x38,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100378:	fa                   	cli    
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
80100379:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  cons.locking = 0;
8010037f:	c7 05 54 b5 10 80 00 	movl   $0x0,0x8010b554
80100386:	00 00 00 
  getcallerpcs(&s, pcs);
80100389:	8d 5d d0             	lea    -0x30(%ebp),%ebx
8010038c:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
8010038f:	0f b6 00             	movzbl (%eax),%eax
80100392:	50                   	push   %eax
80100393:	68 c6 78 10 80       	push   $0x801078c6
80100398:	e8 a3 02 00 00       	call   80100640 <cprintf>
  cprintf(s);
8010039d:	58                   	pop    %eax
8010039e:	ff 75 08             	pushl  0x8(%ebp)
801003a1:	e8 9a 02 00 00       	call   80100640 <cprintf>
  cprintf("\n");
801003a6:	c7 04 24 43 7f 10 80 	movl   $0x80107f43,(%esp)
801003ad:	e8 8e 02 00 00       	call   80100640 <cprintf>
  getcallerpcs(&s, pcs);
801003b2:	5a                   	pop    %edx
801003b3:	8d 45 08             	lea    0x8(%ebp),%eax
801003b6:	59                   	pop    %ecx
801003b7:	53                   	push   %ebx
801003b8:	50                   	push   %eax
801003b9:	e8 c2 46 00 00       	call   80104a80 <getcallerpcs>
801003be:	83 c4 10             	add    $0x10,%esp
801003c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf(" %p", pcs[i]);
801003c8:	83 ec 08             	sub    $0x8,%esp
801003cb:	ff 33                	pushl  (%ebx)
801003cd:	83 c3 04             	add    $0x4,%ebx
801003d0:	68 e2 78 10 80       	push   $0x801078e2
801003d5:	e8 66 02 00 00       	call   80100640 <cprintf>
  for(i=0; i<10; i++)
801003da:	83 c4 10             	add    $0x10,%esp
801003dd:	39 f3                	cmp    %esi,%ebx
801003df:	75 e7                	jne    801003c8 <panic+0x58>
  panicked = 1; // freeze other CPU
801003e1:	c7 05 58 b5 10 80 01 	movl   $0x1,0x8010b558
801003e8:	00 00 00 
801003eb:	eb fe                	jmp    801003eb <panic+0x7b>
801003ed:	8d 76 00             	lea    0x0(%esi),%esi

801003f0 <consputc>:
  if(panicked){
801003f0:	8b 0d 58 b5 10 80    	mov    0x8010b558,%ecx
801003f6:	85 c9                	test   %ecx,%ecx
801003f8:	74 06                	je     80100400 <consputc+0x10>
801003fa:	fa                   	cli    
801003fb:	eb fe                	jmp    801003fb <consputc+0xb>
801003fd:	8d 76 00             	lea    0x0(%esi),%esi
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	57                   	push   %edi
80100404:	56                   	push   %esi
80100405:	53                   	push   %ebx
80100406:	89 c6                	mov    %eax,%esi
80100408:	83 ec 0c             	sub    $0xc,%esp
  if(c == BACKSPACE){
8010040b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100410:	0f 84 b1 00 00 00    	je     801004c7 <consputc+0xd7>
    uartputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	50                   	push   %eax
8010041a:	e8 c1 5f 00 00       	call   801063e0 <uartputc>
8010041f:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100422:	bb d4 03 00 00       	mov    $0x3d4,%ebx
80100427:	b8 0e 00 00 00       	mov    $0xe,%eax
8010042c:	89 da                	mov    %ebx,%edx
8010042e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010042f:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100434:	89 ca                	mov    %ecx,%edx
80100436:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100437:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010043a:	89 da                	mov    %ebx,%edx
8010043c:	c1 e0 08             	shl    $0x8,%eax
8010043f:	89 c7                	mov    %eax,%edi
80100441:	b8 0f 00 00 00       	mov    $0xf,%eax
80100446:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100447:	89 ca                	mov    %ecx,%edx
80100449:	ec                   	in     (%dx),%al
8010044a:	0f b6 d8             	movzbl %al,%ebx
  pos |= inb(CRTPORT+1);
8010044d:	09 fb                	or     %edi,%ebx
  if(c == '\n')
8010044f:	83 fe 0a             	cmp    $0xa,%esi
80100452:	0f 84 f3 00 00 00    	je     8010054b <consputc+0x15b>
  else if(c == BACKSPACE){
80100458:	81 fe 00 01 00 00    	cmp    $0x100,%esi
8010045e:	0f 84 d7 00 00 00    	je     8010053b <consputc+0x14b>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100464:	89 f0                	mov    %esi,%eax
80100466:	0f b6 c0             	movzbl %al,%eax
80100469:	80 cc 07             	or     $0x7,%ah
8010046c:	66 89 84 1b 00 80 0b 	mov    %ax,-0x7ff48000(%ebx,%ebx,1)
80100473:	80 
80100474:	83 c3 01             	add    $0x1,%ebx
  if(pos < 0 || pos > 25*80)
80100477:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
8010047d:	0f 8f ab 00 00 00    	jg     8010052e <consputc+0x13e>
  if((pos/80) >= 24){  // Scroll up.
80100483:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100489:	7f 66                	jg     801004f1 <consputc+0x101>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010048b:	be d4 03 00 00       	mov    $0x3d4,%esi
80100490:	b8 0e 00 00 00       	mov    $0xe,%eax
80100495:	89 f2                	mov    %esi,%edx
80100497:	ee                   	out    %al,(%dx)
80100498:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
  outb(CRTPORT+1, pos>>8);
8010049d:	89 d8                	mov    %ebx,%eax
8010049f:	c1 f8 08             	sar    $0x8,%eax
801004a2:	89 ca                	mov    %ecx,%edx
801004a4:	ee                   	out    %al,(%dx)
801004a5:	b8 0f 00 00 00       	mov    $0xf,%eax
801004aa:	89 f2                	mov    %esi,%edx
801004ac:	ee                   	out    %al,(%dx)
801004ad:	89 d8                	mov    %ebx,%eax
801004af:	89 ca                	mov    %ecx,%edx
801004b1:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801004b2:	b8 20 07 00 00       	mov    $0x720,%eax
801004b7:	66 89 84 1b 00 80 0b 	mov    %ax,-0x7ff48000(%ebx,%ebx,1)
801004be:	80 
}
801004bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004c2:	5b                   	pop    %ebx
801004c3:	5e                   	pop    %esi
801004c4:	5f                   	pop    %edi
801004c5:	5d                   	pop    %ebp
801004c6:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
801004c7:	83 ec 0c             	sub    $0xc,%esp
801004ca:	6a 08                	push   $0x8
801004cc:	e8 0f 5f 00 00       	call   801063e0 <uartputc>
801004d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004d8:	e8 03 5f 00 00       	call   801063e0 <uartputc>
801004dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004e4:	e8 f7 5e 00 00       	call   801063e0 <uartputc>
801004e9:	83 c4 10             	add    $0x10,%esp
801004ec:	e9 31 ff ff ff       	jmp    80100422 <consputc+0x32>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004f1:	52                   	push   %edx
801004f2:	68 60 0e 00 00       	push   $0xe60
    pos -= 80;
801004f7:	83 eb 50             	sub    $0x50,%ebx
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004fa:	68 a0 80 0b 80       	push   $0x800b80a0
801004ff:	68 00 80 0b 80       	push   $0x800b8000
80100504:	e8 77 47 00 00       	call   80104c80 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100509:	b8 80 07 00 00       	mov    $0x780,%eax
8010050e:	83 c4 0c             	add    $0xc,%esp
80100511:	29 d8                	sub    %ebx,%eax
80100513:	01 c0                	add    %eax,%eax
80100515:	50                   	push   %eax
80100516:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
80100519:	6a 00                	push   $0x0
8010051b:	2d 00 80 f4 7f       	sub    $0x7ff48000,%eax
80100520:	50                   	push   %eax
80100521:	e8 aa 46 00 00       	call   80104bd0 <memset>
80100526:	83 c4 10             	add    $0x10,%esp
80100529:	e9 5d ff ff ff       	jmp    8010048b <consputc+0x9b>
    panic("pos under/overflow");
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	68 e6 78 10 80       	push   $0x801078e6
80100536:	e8 35 fe ff ff       	call   80100370 <panic>
    if(pos > 0) --pos;
8010053b:	85 db                	test   %ebx,%ebx
8010053d:	0f 84 48 ff ff ff    	je     8010048b <consputc+0x9b>
80100543:	83 eb 01             	sub    $0x1,%ebx
80100546:	e9 2c ff ff ff       	jmp    80100477 <consputc+0x87>
    pos += 80 - pos%80;
8010054b:	89 d8                	mov    %ebx,%eax
8010054d:	b9 50 00 00 00       	mov    $0x50,%ecx
80100552:	99                   	cltd   
80100553:	f7 f9                	idiv   %ecx
80100555:	29 d1                	sub    %edx,%ecx
80100557:	01 cb                	add    %ecx,%ebx
80100559:	e9 19 ff ff ff       	jmp    80100477 <consputc+0x87>
8010055e:	66 90                	xchg   %ax,%ax

80100560 <printint>:
{
80100560:	55                   	push   %ebp
80100561:	89 e5                	mov    %esp,%ebp
80100563:	57                   	push   %edi
80100564:	56                   	push   %esi
80100565:	53                   	push   %ebx
80100566:	89 d3                	mov    %edx,%ebx
80100568:	83 ec 2c             	sub    $0x2c,%esp
  if(sign && (sign = xx < 0))
8010056b:	85 c9                	test   %ecx,%ecx
{
8010056d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
80100570:	74 04                	je     80100576 <printint+0x16>
80100572:	85 c0                	test   %eax,%eax
80100574:	78 5a                	js     801005d0 <printint+0x70>
    x = xx;
80100576:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  i = 0;
8010057d:	31 c9                	xor    %ecx,%ecx
8010057f:	8d 75 d7             	lea    -0x29(%ebp),%esi
80100582:	eb 06                	jmp    8010058a <printint+0x2a>
80100584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    buf[i++] = digits[x % base];
80100588:	89 f9                	mov    %edi,%ecx
8010058a:	31 d2                	xor    %edx,%edx
8010058c:	8d 79 01             	lea    0x1(%ecx),%edi
8010058f:	f7 f3                	div    %ebx
80100591:	0f b6 92 14 79 10 80 	movzbl -0x7fef86ec(%edx),%edx
  }while((x /= base) != 0);
80100598:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
8010059a:	88 14 3e             	mov    %dl,(%esi,%edi,1)
  }while((x /= base) != 0);
8010059d:	75 e9                	jne    80100588 <printint+0x28>
  if(sign)
8010059f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801005a2:	85 c0                	test   %eax,%eax
801005a4:	74 08                	je     801005ae <printint+0x4e>
    buf[i++] = '-';
801005a6:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
801005ab:	8d 79 02             	lea    0x2(%ecx),%edi
801005ae:	8d 5c 3d d7          	lea    -0x29(%ebp,%edi,1),%ebx
801005b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    consputc(buf[i]);
801005b8:	0f be 03             	movsbl (%ebx),%eax
801005bb:	83 eb 01             	sub    $0x1,%ebx
801005be:	e8 2d fe ff ff       	call   801003f0 <consputc>
  while(--i >= 0)
801005c3:	39 f3                	cmp    %esi,%ebx
801005c5:	75 f1                	jne    801005b8 <printint+0x58>
}
801005c7:	83 c4 2c             	add    $0x2c,%esp
801005ca:	5b                   	pop    %ebx
801005cb:	5e                   	pop    %esi
801005cc:	5f                   	pop    %edi
801005cd:	5d                   	pop    %ebp
801005ce:	c3                   	ret    
801005cf:	90                   	nop
    x = -xx;
801005d0:	f7 d8                	neg    %eax
801005d2:	eb a9                	jmp    8010057d <printint+0x1d>
801005d4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801005da:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801005e0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005e0:	55                   	push   %ebp
801005e1:	89 e5                	mov    %esp,%ebp
801005e3:	57                   	push   %edi
801005e4:	56                   	push   %esi
801005e5:	53                   	push   %ebx
801005e6:	83 ec 18             	sub    $0x18,%esp
801005e9:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005ec:	ff 75 08             	pushl  0x8(%ebp)
801005ef:	e8 2c 11 00 00       	call   80101720 <iunlock>
  acquire(&cons.lock);
801005f4:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
801005fb:	e8 c0 43 00 00       	call   801049c0 <acquire>
  for(i = 0; i < n; i++)
80100600:	83 c4 10             	add    $0x10,%esp
80100603:	85 f6                	test   %esi,%esi
80100605:	7e 18                	jle    8010061f <consolewrite+0x3f>
80100607:	8b 7d 0c             	mov    0xc(%ebp),%edi
8010060a:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
8010060d:	8d 76 00             	lea    0x0(%esi),%esi
    consputc(buf[i] & 0xff);
80100610:	0f b6 07             	movzbl (%edi),%eax
80100613:	83 c7 01             	add    $0x1,%edi
80100616:	e8 d5 fd ff ff       	call   801003f0 <consputc>
  for(i = 0; i < n; i++)
8010061b:	39 fb                	cmp    %edi,%ebx
8010061d:	75 f1                	jne    80100610 <consolewrite+0x30>
  release(&cons.lock);
8010061f:	83 ec 0c             	sub    $0xc,%esp
80100622:	68 20 b5 10 80       	push   $0x8010b520
80100627:	e8 54 45 00 00       	call   80104b80 <release>
  ilock(ip);
8010062c:	58                   	pop    %eax
8010062d:	ff 75 08             	pushl  0x8(%ebp)
80100630:	e8 db 0f 00 00       	call   80101610 <ilock>

  return n;
}
80100635:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100638:	89 f0                	mov    %esi,%eax
8010063a:	5b                   	pop    %ebx
8010063b:	5e                   	pop    %esi
8010063c:	5f                   	pop    %edi
8010063d:	5d                   	pop    %ebp
8010063e:	c3                   	ret    
8010063f:	90                   	nop

80100640 <cprintf>:
{
80100640:	55                   	push   %ebp
80100641:	89 e5                	mov    %esp,%ebp
80100643:	57                   	push   %edi
80100644:	56                   	push   %esi
80100645:	53                   	push   %ebx
80100646:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100649:	a1 54 b5 10 80       	mov    0x8010b554,%eax
  if(locking)
8010064e:	85 c0                	test   %eax,%eax
  locking = cons.locking;
80100650:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if(locking)
80100653:	0f 85 6f 01 00 00    	jne    801007c8 <cprintf+0x188>
  if (fmt == 0)
80100659:	8b 45 08             	mov    0x8(%ebp),%eax
8010065c:	85 c0                	test   %eax,%eax
8010065e:	89 c7                	mov    %eax,%edi
80100660:	0f 84 77 01 00 00    	je     801007dd <cprintf+0x19d>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100666:	0f b6 00             	movzbl (%eax),%eax
  argp = (uint*)(void*)(&fmt + 1);
80100669:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010066c:	31 db                	xor    %ebx,%ebx
  argp = (uint*)(void*)(&fmt + 1);
8010066e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100671:	85 c0                	test   %eax,%eax
80100673:	75 56                	jne    801006cb <cprintf+0x8b>
80100675:	eb 79                	jmp    801006f0 <cprintf+0xb0>
80100677:	89 f6                	mov    %esi,%esi
80100679:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    c = fmt[++i] & 0xff;
80100680:	0f b6 16             	movzbl (%esi),%edx
    if(c == 0)
80100683:	85 d2                	test   %edx,%edx
80100685:	74 69                	je     801006f0 <cprintf+0xb0>
80100687:	83 c3 02             	add    $0x2,%ebx
    switch(c){
8010068a:	83 fa 70             	cmp    $0x70,%edx
8010068d:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
80100690:	0f 84 84 00 00 00    	je     8010071a <cprintf+0xda>
80100696:	7f 78                	jg     80100710 <cprintf+0xd0>
80100698:	83 fa 25             	cmp    $0x25,%edx
8010069b:	0f 84 ff 00 00 00    	je     801007a0 <cprintf+0x160>
801006a1:	83 fa 64             	cmp    $0x64,%edx
801006a4:	0f 85 8e 00 00 00    	jne    80100738 <cprintf+0xf8>
      printint(*argp++, 10, 1);
801006aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801006ad:	ba 0a 00 00 00       	mov    $0xa,%edx
801006b2:	8d 48 04             	lea    0x4(%eax),%ecx
801006b5:	8b 00                	mov    (%eax),%eax
801006b7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801006ba:	b9 01 00 00 00       	mov    $0x1,%ecx
801006bf:	e8 9c fe ff ff       	call   80100560 <printint>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006c4:	0f b6 06             	movzbl (%esi),%eax
801006c7:	85 c0                	test   %eax,%eax
801006c9:	74 25                	je     801006f0 <cprintf+0xb0>
801006cb:	8d 53 01             	lea    0x1(%ebx),%edx
    if(c != '%'){
801006ce:	83 f8 25             	cmp    $0x25,%eax
801006d1:	8d 34 17             	lea    (%edi,%edx,1),%esi
801006d4:	74 aa                	je     80100680 <cprintf+0x40>
801006d6:	89 55 e0             	mov    %edx,-0x20(%ebp)
      consputc(c);
801006d9:	e8 12 fd ff ff       	call   801003f0 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006de:	0f b6 06             	movzbl (%esi),%eax
      continue;
801006e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801006e4:	89 d3                	mov    %edx,%ebx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006e6:	85 c0                	test   %eax,%eax
801006e8:	75 e1                	jne    801006cb <cprintf+0x8b>
801006ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if(locking)
801006f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801006f3:	85 c0                	test   %eax,%eax
801006f5:	74 10                	je     80100707 <cprintf+0xc7>
    release(&cons.lock);
801006f7:	83 ec 0c             	sub    $0xc,%esp
801006fa:	68 20 b5 10 80       	push   $0x8010b520
801006ff:	e8 7c 44 00 00       	call   80104b80 <release>
80100704:	83 c4 10             	add    $0x10,%esp
}
80100707:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010070a:	5b                   	pop    %ebx
8010070b:	5e                   	pop    %esi
8010070c:	5f                   	pop    %edi
8010070d:	5d                   	pop    %ebp
8010070e:	c3                   	ret    
8010070f:	90                   	nop
    switch(c){
80100710:	83 fa 73             	cmp    $0x73,%edx
80100713:	74 43                	je     80100758 <cprintf+0x118>
80100715:	83 fa 78             	cmp    $0x78,%edx
80100718:	75 1e                	jne    80100738 <cprintf+0xf8>
      printint(*argp++, 16, 0);
8010071a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010071d:	ba 10 00 00 00       	mov    $0x10,%edx
80100722:	8d 48 04             	lea    0x4(%eax),%ecx
80100725:	8b 00                	mov    (%eax),%eax
80100727:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010072a:	31 c9                	xor    %ecx,%ecx
8010072c:	e8 2f fe ff ff       	call   80100560 <printint>
      break;
80100731:	eb 91                	jmp    801006c4 <cprintf+0x84>
80100733:	90                   	nop
80100734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      consputc('%');
80100738:	b8 25 00 00 00       	mov    $0x25,%eax
8010073d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80100740:	e8 ab fc ff ff       	call   801003f0 <consputc>
      consputc(c);
80100745:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100748:	89 d0                	mov    %edx,%eax
8010074a:	e8 a1 fc ff ff       	call   801003f0 <consputc>
      break;
8010074f:	e9 70 ff ff ff       	jmp    801006c4 <cprintf+0x84>
80100754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if((s = (char*)*argp++) == 0)
80100758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010075b:	8b 10                	mov    (%eax),%edx
8010075d:	8d 48 04             	lea    0x4(%eax),%ecx
80100760:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80100763:	85 d2                	test   %edx,%edx
80100765:	74 49                	je     801007b0 <cprintf+0x170>
      for(; *s; s++)
80100767:	0f be 02             	movsbl (%edx),%eax
      if((s = (char*)*argp++) == 0)
8010076a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
      for(; *s; s++)
8010076d:	84 c0                	test   %al,%al
8010076f:	0f 84 4f ff ff ff    	je     801006c4 <cprintf+0x84>
80100775:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80100778:	89 d3                	mov    %edx,%ebx
8010077a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100780:	83 c3 01             	add    $0x1,%ebx
        consputc(*s);
80100783:	e8 68 fc ff ff       	call   801003f0 <consputc>
      for(; *s; s++)
80100788:	0f be 03             	movsbl (%ebx),%eax
8010078b:	84 c0                	test   %al,%al
8010078d:	75 f1                	jne    80100780 <cprintf+0x140>
      if((s = (char*)*argp++) == 0)
8010078f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100792:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80100795:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100798:	e9 27 ff ff ff       	jmp    801006c4 <cprintf+0x84>
8010079d:	8d 76 00             	lea    0x0(%esi),%esi
      consputc('%');
801007a0:	b8 25 00 00 00       	mov    $0x25,%eax
801007a5:	e8 46 fc ff ff       	call   801003f0 <consputc>
      break;
801007aa:	e9 15 ff ff ff       	jmp    801006c4 <cprintf+0x84>
801007af:	90                   	nop
        s = "(null)";
801007b0:	ba f9 78 10 80       	mov    $0x801078f9,%edx
      for(; *s; s++)
801007b5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801007b8:	b8 28 00 00 00       	mov    $0x28,%eax
801007bd:	89 d3                	mov    %edx,%ebx
801007bf:	eb bf                	jmp    80100780 <cprintf+0x140>
801007c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    acquire(&cons.lock);
801007c8:	83 ec 0c             	sub    $0xc,%esp
801007cb:	68 20 b5 10 80       	push   $0x8010b520
801007d0:	e8 eb 41 00 00       	call   801049c0 <acquire>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	e9 7c fe ff ff       	jmp    80100659 <cprintf+0x19>
    panic("null fmt");
801007dd:	83 ec 0c             	sub    $0xc,%esp
801007e0:	68 00 79 10 80       	push   $0x80107900
801007e5:	e8 86 fb ff ff       	call   80100370 <panic>
801007ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801007f0 <consoleintr>:
{
801007f0:	55                   	push   %ebp
801007f1:	89 e5                	mov    %esp,%ebp
801007f3:	57                   	push   %edi
801007f4:	56                   	push   %esi
801007f5:	53                   	push   %ebx
  int c, doprocdump = 0;
801007f6:	31 f6                	xor    %esi,%esi
{
801007f8:	83 ec 18             	sub    $0x18,%esp
801007fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
801007fe:	68 20 b5 10 80       	push   $0x8010b520
80100803:	e8 b8 41 00 00       	call   801049c0 <acquire>
  while((c = getc()) >= 0){
80100808:	83 c4 10             	add    $0x10,%esp
8010080b:	90                   	nop
8010080c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100810:	ff d3                	call   *%ebx
80100812:	85 c0                	test   %eax,%eax
80100814:	89 c7                	mov    %eax,%edi
80100816:	78 48                	js     80100860 <consoleintr+0x70>
    switch(c){
80100818:	83 ff 10             	cmp    $0x10,%edi
8010081b:	0f 84 e7 00 00 00    	je     80100908 <consoleintr+0x118>
80100821:	7e 5d                	jle    80100880 <consoleintr+0x90>
80100823:	83 ff 15             	cmp    $0x15,%edi
80100826:	0f 84 ec 00 00 00    	je     80100918 <consoleintr+0x128>
8010082c:	83 ff 7f             	cmp    $0x7f,%edi
8010082f:	75 54                	jne    80100885 <consoleintr+0x95>
      if(input.e != input.w){
80100831:	a1 88 07 11 80       	mov    0x80110788,%eax
80100836:	3b 05 84 07 11 80    	cmp    0x80110784,%eax
8010083c:	74 d2                	je     80100810 <consoleintr+0x20>
        input.e--;
8010083e:	83 e8 01             	sub    $0x1,%eax
80100841:	a3 88 07 11 80       	mov    %eax,0x80110788
        consputc(BACKSPACE);
80100846:	b8 00 01 00 00       	mov    $0x100,%eax
8010084b:	e8 a0 fb ff ff       	call   801003f0 <consputc>
  while((c = getc()) >= 0){
80100850:	ff d3                	call   *%ebx
80100852:	85 c0                	test   %eax,%eax
80100854:	89 c7                	mov    %eax,%edi
80100856:	79 c0                	jns    80100818 <consoleintr+0x28>
80100858:	90                   	nop
80100859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  release(&cons.lock);
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	68 20 b5 10 80       	push   $0x8010b520
80100868:	e8 13 43 00 00       	call   80104b80 <release>
  if(doprocdump) {
8010086d:	83 c4 10             	add    $0x10,%esp
80100870:	85 f6                	test   %esi,%esi
80100872:	0f 85 f8 00 00 00    	jne    80100970 <consoleintr+0x180>
}
80100878:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010087b:	5b                   	pop    %ebx
8010087c:	5e                   	pop    %esi
8010087d:	5f                   	pop    %edi
8010087e:	5d                   	pop    %ebp
8010087f:	c3                   	ret    
    switch(c){
80100880:	83 ff 08             	cmp    $0x8,%edi
80100883:	74 ac                	je     80100831 <consoleintr+0x41>
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100885:	85 ff                	test   %edi,%edi
80100887:	74 87                	je     80100810 <consoleintr+0x20>
80100889:	a1 88 07 11 80       	mov    0x80110788,%eax
8010088e:	89 c2                	mov    %eax,%edx
80100890:	2b 15 80 07 11 80    	sub    0x80110780,%edx
80100896:	83 fa 7f             	cmp    $0x7f,%edx
80100899:	0f 87 71 ff ff ff    	ja     80100810 <consoleintr+0x20>
8010089f:	8d 50 01             	lea    0x1(%eax),%edx
801008a2:	83 e0 7f             	and    $0x7f,%eax
        c = (c == '\r') ? '\n' : c;
801008a5:	83 ff 0d             	cmp    $0xd,%edi
        input.buf[input.e++ % INPUT_BUF] = c;
801008a8:	89 15 88 07 11 80    	mov    %edx,0x80110788
        c = (c == '\r') ? '\n' : c;
801008ae:	0f 84 cc 00 00 00    	je     80100980 <consoleintr+0x190>
        input.buf[input.e++ % INPUT_BUF] = c;
801008b4:	89 f9                	mov    %edi,%ecx
801008b6:	88 88 00 07 11 80    	mov    %cl,-0x7feef900(%eax)
        consputc(c);
801008bc:	89 f8                	mov    %edi,%eax
801008be:	e8 2d fb ff ff       	call   801003f0 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c3:	83 ff 0a             	cmp    $0xa,%edi
801008c6:	0f 84 c5 00 00 00    	je     80100991 <consoleintr+0x1a1>
801008cc:	83 ff 04             	cmp    $0x4,%edi
801008cf:	0f 84 bc 00 00 00    	je     80100991 <consoleintr+0x1a1>
801008d5:	a1 80 07 11 80       	mov    0x80110780,%eax
801008da:	83 e8 80             	sub    $0xffffff80,%eax
801008dd:	39 05 88 07 11 80    	cmp    %eax,0x80110788
801008e3:	0f 85 27 ff ff ff    	jne    80100810 <consoleintr+0x20>
          wakeup(&input.r);
801008e9:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
801008ec:	a3 84 07 11 80       	mov    %eax,0x80110784
          wakeup(&input.r);
801008f1:	68 80 07 11 80       	push   $0x80110780
801008f6:	e8 55 39 00 00       	call   80104250 <wakeup>
801008fb:	83 c4 10             	add    $0x10,%esp
801008fe:	e9 0d ff ff ff       	jmp    80100810 <consoleintr+0x20>
80100903:	90                   	nop
80100904:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      doprocdump = 1;
80100908:	be 01 00 00 00       	mov    $0x1,%esi
8010090d:	e9 fe fe ff ff       	jmp    80100810 <consoleintr+0x20>
80100912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      while(input.e != input.w &&
80100918:	a1 88 07 11 80       	mov    0x80110788,%eax
8010091d:	39 05 84 07 11 80    	cmp    %eax,0x80110784
80100923:	75 2b                	jne    80100950 <consoleintr+0x160>
80100925:	e9 e6 fe ff ff       	jmp    80100810 <consoleintr+0x20>
8010092a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        input.e--;
80100930:	a3 88 07 11 80       	mov    %eax,0x80110788
        consputc(BACKSPACE);
80100935:	b8 00 01 00 00       	mov    $0x100,%eax
8010093a:	e8 b1 fa ff ff       	call   801003f0 <consputc>
      while(input.e != input.w &&
8010093f:	a1 88 07 11 80       	mov    0x80110788,%eax
80100944:	3b 05 84 07 11 80    	cmp    0x80110784,%eax
8010094a:	0f 84 c0 fe ff ff    	je     80100810 <consoleintr+0x20>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100950:	83 e8 01             	sub    $0x1,%eax
80100953:	89 c2                	mov    %eax,%edx
80100955:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100958:	80 ba 00 07 11 80 0a 	cmpb   $0xa,-0x7feef900(%edx)
8010095f:	75 cf                	jne    80100930 <consoleintr+0x140>
80100961:	e9 aa fe ff ff       	jmp    80100810 <consoleintr+0x20>
80100966:	8d 76 00             	lea    0x0(%esi),%esi
80100969:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
}
80100970:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100973:	5b                   	pop    %ebx
80100974:	5e                   	pop    %esi
80100975:	5f                   	pop    %edi
80100976:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100977:	e9 b4 39 00 00       	jmp    80104330 <procdump>
8010097c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        input.buf[input.e++ % INPUT_BUF] = c;
80100980:	c6 80 00 07 11 80 0a 	movb   $0xa,-0x7feef900(%eax)
        consputc(c);
80100987:	b8 0a 00 00 00       	mov    $0xa,%eax
8010098c:	e8 5f fa ff ff       	call   801003f0 <consputc>
80100991:	a1 88 07 11 80       	mov    0x80110788,%eax
80100996:	e9 4e ff ff ff       	jmp    801008e9 <consoleintr+0xf9>
8010099b:	90                   	nop
8010099c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801009a0 <consoleinit>:

void
consoleinit(void)
{
801009a0:	55                   	push   %ebp
801009a1:	89 e5                	mov    %esp,%ebp
801009a3:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
801009a6:	68 09 79 10 80       	push   $0x80107909
801009ab:	68 20 b5 10 80       	push   $0x8010b520
801009b0:	e8 eb 3f 00 00       	call   801049a0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  picenable(IRQ_KBD);
801009b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  devsw[CONSOLE].write = consolewrite;
801009bc:	c7 05 4c 11 11 80 e0 	movl   $0x801005e0,0x8011114c
801009c3:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801009c6:	c7 05 48 11 11 80 50 	movl   $0x80100250,0x80111148
801009cd:	02 10 80 
  cons.locking = 1;
801009d0:	c7 05 54 b5 10 80 01 	movl   $0x1,0x8010b554
801009d7:	00 00 00 
  picenable(IRQ_KBD);
801009da:	e8 21 29 00 00       	call   80103300 <picenable>
  ioapicenable(IRQ_KBD, 0);
801009df:	58                   	pop    %eax
801009e0:	5a                   	pop    %edx
801009e1:	6a 00                	push   $0x0
801009e3:	6a 01                	push   $0x1
801009e5:	e8 e6 18 00 00       	call   801022d0 <ioapicenable>
}
801009ea:	83 c4 10             	add    $0x10,%esp
801009ed:	c9                   	leave  
801009ee:	c3                   	ret    
801009ef:	90                   	nop

801009f0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801009f0:	55                   	push   %ebp
801009f1:	89 e5                	mov    %esp,%ebp
801009f3:	57                   	push   %edi
801009f4:	56                   	push   %esi
801009f5:	53                   	push   %ebx
801009f6:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
801009fc:	e8 2f 22 00 00       	call   80102c30 <begin_op>
  if((ip = namei(path)) == 0){
80100a01:	83 ec 0c             	sub    $0xc,%esp
80100a04:	ff 75 08             	pushl  0x8(%ebp)
80100a07:	e8 b4 14 00 00       	call   80101ec0 <namei>
80100a0c:	83 c4 10             	add    $0x10,%esp
80100a0f:	85 c0                	test   %eax,%eax
80100a11:	0f 84 9d 01 00 00    	je     80100bb4 <exec+0x1c4>
    end_op();
    return -1;
  }
  ilock(ip);
80100a17:	83 ec 0c             	sub    $0xc,%esp
80100a1a:	89 c3                	mov    %eax,%ebx
80100a1c:	50                   	push   %eax
80100a1d:	e8 ee 0b 00 00       	call   80101610 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100a22:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100a28:	6a 34                	push   $0x34
80100a2a:	6a 00                	push   $0x0
80100a2c:	50                   	push   %eax
80100a2d:	53                   	push   %ebx
80100a2e:	e8 fd 0e 00 00       	call   80101930 <readi>
80100a33:	83 c4 20             	add    $0x20,%esp
80100a36:	83 f8 33             	cmp    $0x33,%eax
80100a39:	77 25                	ja     80100a60 <exec+0x70>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100a3b:	83 ec 0c             	sub    $0xc,%esp
80100a3e:	53                   	push   %ebx
80100a3f:	e8 9c 0e 00 00       	call   801018e0 <iunlockput>
    end_op();
80100a44:	e8 57 22 00 00       	call   80102ca0 <end_op>
80100a49:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100a4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100a51:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a54:	5b                   	pop    %ebx
80100a55:	5e                   	pop    %esi
80100a56:	5f                   	pop    %edi
80100a57:	5d                   	pop    %ebp
80100a58:	c3                   	ret    
80100a59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(elf.magic != ELF_MAGIC)
80100a60:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100a67:	45 4c 46 
80100a6a:	75 cf                	jne    80100a3b <exec+0x4b>
  if((pgdir = setupkvm()) == 0)
80100a6c:	e8 bf 66 00 00       	call   80107130 <setupkvm>
80100a71:	85 c0                	test   %eax,%eax
80100a73:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100a79:	74 c0                	je     80100a3b <exec+0x4b>
  sz = 0;
80100a7b:	31 ff                	xor    %edi,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100a7d:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100a84:	00 
80100a85:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
80100a8b:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a91:	0f 84 8b 02 00 00    	je     80100d22 <exec+0x332>
80100a97:	31 f6                	xor    %esi,%esi
80100a99:	eb 7f                	jmp    80100b1a <exec+0x12a>
80100a9b:	90                   	nop
80100a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ph.type != ELF_PROG_LOAD)
80100aa0:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100aa7:	75 63                	jne    80100b0c <exec+0x11c>
    if(ph.memsz < ph.filesz)
80100aa9:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100aaf:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100ab5:	0f 82 86 00 00 00    	jb     80100b41 <exec+0x151>
80100abb:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100ac1:	72 7e                	jb     80100b41 <exec+0x151>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ac3:	83 ec 04             	sub    $0x4,%esp
80100ac6:	50                   	push   %eax
80100ac7:	57                   	push   %edi
80100ac8:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100ace:	e8 ed 68 00 00       	call   801073c0 <allocuvm>
80100ad3:	83 c4 10             	add    $0x10,%esp
80100ad6:	85 c0                	test   %eax,%eax
80100ad8:	89 c7                	mov    %eax,%edi
80100ada:	74 65                	je     80100b41 <exec+0x151>
    if(ph.vaddr % PGSIZE != 0)
80100adc:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ae2:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100ae7:	75 58                	jne    80100b41 <exec+0x151>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ae9:	83 ec 0c             	sub    $0xc,%esp
80100aec:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100af2:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100af8:	53                   	push   %ebx
80100af9:	50                   	push   %eax
80100afa:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100b00:	e8 fb 67 00 00       	call   80107300 <loaduvm>
80100b05:	83 c4 20             	add    $0x20,%esp
80100b08:	85 c0                	test   %eax,%eax
80100b0a:	78 35                	js     80100b41 <exec+0x151>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b0c:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100b13:	83 c6 01             	add    $0x1,%esi
80100b16:	39 f0                	cmp    %esi,%eax
80100b18:	7e 46                	jle    80100b60 <exec+0x170>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100b1a:	89 f0                	mov    %esi,%eax
80100b1c:	6a 20                	push   $0x20
80100b1e:	c1 e0 05             	shl    $0x5,%eax
80100b21:	03 85 f0 fe ff ff    	add    -0x110(%ebp),%eax
80100b27:	50                   	push   %eax
80100b28:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100b2e:	50                   	push   %eax
80100b2f:	53                   	push   %ebx
80100b30:	e8 fb 0d 00 00       	call   80101930 <readi>
80100b35:	83 c4 10             	add    $0x10,%esp
80100b38:	83 f8 20             	cmp    $0x20,%eax
80100b3b:	0f 84 5f ff ff ff    	je     80100aa0 <exec+0xb0>
    freevm(pgdir);
80100b41:	83 ec 0c             	sub    $0xc,%esp
80100b44:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100b4a:	e8 e1 6a 00 00       	call   80107630 <freevm>
80100b4f:	83 c4 10             	add    $0x10,%esp
80100b52:	e9 e4 fe ff ff       	jmp    80100a3b <exec+0x4b>
80100b57:	89 f6                	mov    %esi,%esi
80100b59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80100b60:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100b66:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
80100b6c:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100b72:	83 ec 0c             	sub    $0xc,%esp
80100b75:	53                   	push   %ebx
80100b76:	e8 65 0d 00 00       	call   801018e0 <iunlockput>
  end_op();
80100b7b:	e8 20 21 00 00       	call   80102ca0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100b80:	83 c4 0c             	add    $0xc,%esp
80100b83:	56                   	push   %esi
80100b84:	57                   	push   %edi
80100b85:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100b8b:	e8 30 68 00 00       	call   801073c0 <allocuvm>
80100b90:	83 c4 10             	add    $0x10,%esp
80100b93:	85 c0                	test   %eax,%eax
80100b95:	89 c6                	mov    %eax,%esi
80100b97:	75 2a                	jne    80100bc3 <exec+0x1d3>
    freevm(pgdir);
80100b99:	83 ec 0c             	sub    $0xc,%esp
80100b9c:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100ba2:	e8 89 6a 00 00       	call   80107630 <freevm>
80100ba7:	83 c4 10             	add    $0x10,%esp
  return -1;
80100baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100baf:	e9 9d fe ff ff       	jmp    80100a51 <exec+0x61>
    end_op();
80100bb4:	e8 e7 20 00 00       	call   80102ca0 <end_op>
    return -1;
80100bb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bbe:	e9 8e fe ff ff       	jmp    80100a51 <exec+0x61>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100bc3:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100bc9:	83 ec 08             	sub    $0x8,%esp
  for(argc = 0; argv[argc]; argc++) {
80100bcc:	31 ff                	xor    %edi,%edi
80100bce:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100bd0:	50                   	push   %eax
80100bd1:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100bd7:	e8 d4 6a 00 00       	call   801076b0 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bdf:	83 c4 10             	add    $0x10,%esp
80100be2:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100be8:	8b 00                	mov    (%eax),%eax
80100bea:	85 c0                	test   %eax,%eax
80100bec:	74 6f                	je     80100c5d <exec+0x26d>
80100bee:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100bf4:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100bfa:	eb 09                	jmp    80100c05 <exec+0x215>
80100bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(argc >= MAXARG)
80100c00:	83 ff 20             	cmp    $0x20,%edi
80100c03:	74 94                	je     80100b99 <exec+0x1a9>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100c05:	83 ec 0c             	sub    $0xc,%esp
80100c08:	50                   	push   %eax
80100c09:	e8 e2 41 00 00       	call   80104df0 <strlen>
80100c0e:	f7 d0                	not    %eax
80100c10:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c12:	58                   	pop    %eax
80100c13:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100c16:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c19:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c1c:	e8 cf 41 00 00       	call   80104df0 <strlen>
80100c21:	83 c0 01             	add    $0x1,%eax
80100c24:	50                   	push   %eax
80100c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c28:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c2b:	53                   	push   %ebx
80100c2c:	56                   	push   %esi
80100c2d:	e8 ce 6b 00 00       	call   80107800 <copyout>
80100c32:	83 c4 20             	add    $0x20,%esp
80100c35:	85 c0                	test   %eax,%eax
80100c37:	0f 88 5c ff ff ff    	js     80100b99 <exec+0x1a9>
  for(argc = 0; argv[argc]; argc++) {
80100c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100c40:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100c47:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100c4a:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100c50:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100c53:	85 c0                	test   %eax,%eax
80100c55:	75 a9                	jne    80100c00 <exec+0x210>
80100c57:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100c5d:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100c64:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80100c66:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100c6d:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100c71:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100c78:	ff ff ff 
  ustack[1] = argc;
80100c7b:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100c81:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80100c83:	83 c0 0c             	add    $0xc,%eax
80100c86:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100c88:	50                   	push   %eax
80100c89:	52                   	push   %edx
80100c8a:	53                   	push   %ebx
80100c8b:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100c91:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100c97:	e8 64 6b 00 00       	call   80107800 <copyout>
80100c9c:	83 c4 10             	add    $0x10,%esp
80100c9f:	85 c0                	test   %eax,%eax
80100ca1:	0f 88 f2 fe ff ff    	js     80100b99 <exec+0x1a9>
  for(last=s=path; *s; s++)
80100ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80100caa:	8b 55 08             	mov    0x8(%ebp),%edx
80100cad:	0f b6 00             	movzbl (%eax),%eax
80100cb0:	84 c0                	test   %al,%al
80100cb2:	74 11                	je     80100cc5 <exec+0x2d5>
80100cb4:	89 d1                	mov    %edx,%ecx
80100cb6:	83 c1 01             	add    $0x1,%ecx
80100cb9:	3c 2f                	cmp    $0x2f,%al
80100cbb:	0f b6 01             	movzbl (%ecx),%eax
80100cbe:	0f 44 d1             	cmove  %ecx,%edx
80100cc1:	84 c0                	test   %al,%al
80100cc3:	75 f1                	jne    80100cb6 <exec+0x2c6>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100cc5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ccb:	83 ec 04             	sub    $0x4,%esp
80100cce:	6a 10                	push   $0x10
80100cd0:	52                   	push   %edx
80100cd1:	05 90 00 00 00       	add    $0x90,%eax
80100cd6:	50                   	push   %eax
80100cd7:	e8 d4 40 00 00       	call   80104db0 <safestrcpy>
  oldpgdir = proc->pgdir;
80100cdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  proc->pgdir = pgdir;
80100ce2:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
  oldpgdir = proc->pgdir;
80100ce8:	8b 78 04             	mov    0x4(%eax),%edi
  proc->sz = sz;
80100ceb:	89 30                	mov    %esi,(%eax)
  proc->pgdir = pgdir;
80100ced:	89 50 04             	mov    %edx,0x4(%eax)
  proc->tf->eip = elf.entry;  // main
80100cf0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cf6:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
80100cfc:	8b 50 3c             	mov    0x3c(%eax),%edx
80100cff:	89 4a 38             	mov    %ecx,0x38(%edx)
  proc->tf->esp = sp;
80100d02:	8b 50 3c             	mov    0x3c(%eax),%edx
80100d05:	89 5a 44             	mov    %ebx,0x44(%edx)
  switchuvm(proc);
80100d08:	89 04 24             	mov    %eax,(%esp)
80100d0b:	e8 d0 64 00 00       	call   801071e0 <switchuvm>
  freevm(oldpgdir);
80100d10:	89 3c 24             	mov    %edi,(%esp)
80100d13:	e8 18 69 00 00       	call   80107630 <freevm>
  return 0;
80100d18:	83 c4 10             	add    $0x10,%esp
80100d1b:	31 c0                	xor    %eax,%eax
80100d1d:	e9 2f fd ff ff       	jmp    80100a51 <exec+0x61>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d22:	be 00 20 00 00       	mov    $0x2000,%esi
80100d27:	e9 46 fe ff ff       	jmp    80100b72 <exec+0x182>
80100d2c:	66 90                	xchg   %ax,%ax
80100d2e:	66 90                	xchg   %ax,%ax

80100d30 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100d30:	55                   	push   %ebp
80100d31:	89 e5                	mov    %esp,%ebp
80100d33:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100d36:	68 25 79 10 80       	push   $0x80107925
80100d3b:	68 a0 07 11 80       	push   $0x801107a0
80100d40:	e8 5b 3c 00 00       	call   801049a0 <initlock>
}
80100d45:	83 c4 10             	add    $0x10,%esp
80100d48:	c9                   	leave  
80100d49:	c3                   	ret    
80100d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100d50 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100d50:	55                   	push   %ebp
80100d51:	89 e5                	mov    %esp,%ebp
80100d53:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100d54:	bb d4 07 11 80       	mov    $0x801107d4,%ebx
{
80100d59:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100d5c:	68 a0 07 11 80       	push   $0x801107a0
80100d61:	e8 5a 3c 00 00       	call   801049c0 <acquire>
80100d66:	83 c4 10             	add    $0x10,%esp
80100d69:	eb 10                	jmp    80100d7b <filealloc+0x2b>
80100d6b:	90                   	nop
80100d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100d70:	83 c3 18             	add    $0x18,%ebx
80100d73:	81 fb 34 11 11 80    	cmp    $0x80111134,%ebx
80100d79:	73 25                	jae    80100da0 <filealloc+0x50>
    if(f->ref == 0){
80100d7b:	8b 43 04             	mov    0x4(%ebx),%eax
80100d7e:	85 c0                	test   %eax,%eax
80100d80:	75 ee                	jne    80100d70 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100d82:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100d85:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100d8c:	68 a0 07 11 80       	push   $0x801107a0
80100d91:	e8 ea 3d 00 00       	call   80104b80 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100d96:	89 d8                	mov    %ebx,%eax
      return f;
80100d98:	83 c4 10             	add    $0x10,%esp
}
80100d9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d9e:	c9                   	leave  
80100d9f:	c3                   	ret    
  release(&ftable.lock);
80100da0:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100da3:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100da5:	68 a0 07 11 80       	push   $0x801107a0
80100daa:	e8 d1 3d 00 00       	call   80104b80 <release>
}
80100daf:	89 d8                	mov    %ebx,%eax
  return 0;
80100db1:	83 c4 10             	add    $0x10,%esp
}
80100db4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100db7:	c9                   	leave  
80100db8:	c3                   	ret    
80100db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100dc0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100dc0:	55                   	push   %ebp
80100dc1:	89 e5                	mov    %esp,%ebp
80100dc3:	53                   	push   %ebx
80100dc4:	83 ec 10             	sub    $0x10,%esp
80100dc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100dca:	68 a0 07 11 80       	push   $0x801107a0
80100dcf:	e8 ec 3b 00 00       	call   801049c0 <acquire>
  if(f->ref < 1)
80100dd4:	8b 43 04             	mov    0x4(%ebx),%eax
80100dd7:	83 c4 10             	add    $0x10,%esp
80100dda:	85 c0                	test   %eax,%eax
80100ddc:	7e 1a                	jle    80100df8 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100dde:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100de1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100de4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100de7:	68 a0 07 11 80       	push   $0x801107a0
80100dec:	e8 8f 3d 00 00       	call   80104b80 <release>
  return f;
}
80100df1:	89 d8                	mov    %ebx,%eax
80100df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100df6:	c9                   	leave  
80100df7:	c3                   	ret    
    panic("filedup");
80100df8:	83 ec 0c             	sub    $0xc,%esp
80100dfb:	68 2c 79 10 80       	push   $0x8010792c
80100e00:	e8 6b f5 ff ff       	call   80100370 <panic>
80100e05:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100e09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100e10 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100e10:	55                   	push   %ebp
80100e11:	89 e5                	mov    %esp,%ebp
80100e13:	57                   	push   %edi
80100e14:	56                   	push   %esi
80100e15:	53                   	push   %ebx
80100e16:	83 ec 28             	sub    $0x28,%esp
80100e19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100e1c:	68 a0 07 11 80       	push   $0x801107a0
80100e21:	e8 9a 3b 00 00       	call   801049c0 <acquire>
  if(f->ref < 1)
80100e26:	8b 43 04             	mov    0x4(%ebx),%eax
80100e29:	83 c4 10             	add    $0x10,%esp
80100e2c:	85 c0                	test   %eax,%eax
80100e2e:	0f 8e 9b 00 00 00    	jle    80100ecf <fileclose+0xbf>
    panic("fileclose");
  if(--f->ref > 0){
80100e34:	83 e8 01             	sub    $0x1,%eax
80100e37:	85 c0                	test   %eax,%eax
80100e39:	89 43 04             	mov    %eax,0x4(%ebx)
80100e3c:	74 1a                	je     80100e58 <fileclose+0x48>
    release(&ftable.lock);
80100e3e:	c7 45 08 a0 07 11 80 	movl   $0x801107a0,0x8(%ebp)
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100e48:	5b                   	pop    %ebx
80100e49:	5e                   	pop    %esi
80100e4a:	5f                   	pop    %edi
80100e4b:	5d                   	pop    %ebp
    release(&ftable.lock);
80100e4c:	e9 2f 3d 00 00       	jmp    80104b80 <release>
80100e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  ff = *f;
80100e58:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
80100e5c:	8b 3b                	mov    (%ebx),%edi
  release(&ftable.lock);
80100e5e:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80100e61:	8b 73 0c             	mov    0xc(%ebx),%esi
  f->type = FD_NONE;
80100e64:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
80100e6a:	88 45 e7             	mov    %al,-0x19(%ebp)
80100e6d:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80100e70:	68 a0 07 11 80       	push   $0x801107a0
  ff = *f;
80100e75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80100e78:	e8 03 3d 00 00       	call   80104b80 <release>
  if(ff.type == FD_PIPE)
80100e7d:	83 c4 10             	add    $0x10,%esp
80100e80:	83 ff 01             	cmp    $0x1,%edi
80100e83:	74 13                	je     80100e98 <fileclose+0x88>
  else if(ff.type == FD_INODE){
80100e85:	83 ff 02             	cmp    $0x2,%edi
80100e88:	74 26                	je     80100eb0 <fileclose+0xa0>
}
80100e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100e8d:	5b                   	pop    %ebx
80100e8e:	5e                   	pop    %esi
80100e8f:	5f                   	pop    %edi
80100e90:	5d                   	pop    %ebp
80100e91:	c3                   	ret    
80100e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pipeclose(ff.pipe, ff.writable);
80100e98:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80100e9c:	83 ec 08             	sub    $0x8,%esp
80100e9f:	53                   	push   %ebx
80100ea0:	56                   	push   %esi
80100ea1:	e8 3a 26 00 00       	call   801034e0 <pipeclose>
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	eb df                	jmp    80100e8a <fileclose+0x7a>
80100eab:	90                   	nop
80100eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    begin_op();
80100eb0:	e8 7b 1d 00 00       	call   80102c30 <begin_op>
    iput(ff.ip);
80100eb5:	83 ec 0c             	sub    $0xc,%esp
80100eb8:	ff 75 e0             	pushl  -0x20(%ebp)
80100ebb:	e8 c0 08 00 00       	call   80101780 <iput>
    end_op();
80100ec0:	83 c4 10             	add    $0x10,%esp
}
80100ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100ec6:	5b                   	pop    %ebx
80100ec7:	5e                   	pop    %esi
80100ec8:	5f                   	pop    %edi
80100ec9:	5d                   	pop    %ebp
    end_op();
80100eca:	e9 d1 1d 00 00       	jmp    80102ca0 <end_op>
    panic("fileclose");
80100ecf:	83 ec 0c             	sub    $0xc,%esp
80100ed2:	68 34 79 10 80       	push   $0x80107934
80100ed7:	e8 94 f4 ff ff       	call   80100370 <panic>
80100edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100ee0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100ee0:	55                   	push   %ebp
80100ee1:	89 e5                	mov    %esp,%ebp
80100ee3:	53                   	push   %ebx
80100ee4:	83 ec 04             	sub    $0x4,%esp
80100ee7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100eea:	83 3b 02             	cmpl   $0x2,(%ebx)
80100eed:	75 31                	jne    80100f20 <filestat+0x40>
    ilock(f->ip);
80100eef:	83 ec 0c             	sub    $0xc,%esp
80100ef2:	ff 73 10             	pushl  0x10(%ebx)
80100ef5:	e8 16 07 00 00       	call   80101610 <ilock>
    stati(f->ip, st);
80100efa:	58                   	pop    %eax
80100efb:	5a                   	pop    %edx
80100efc:	ff 75 0c             	pushl  0xc(%ebp)
80100eff:	ff 73 10             	pushl  0x10(%ebx)
80100f02:	e8 f9 09 00 00       	call   80101900 <stati>
    iunlock(f->ip);
80100f07:	59                   	pop    %ecx
80100f08:	ff 73 10             	pushl  0x10(%ebx)
80100f0b:	e8 10 08 00 00       	call   80101720 <iunlock>
    return 0;
80100f10:	83 c4 10             	add    $0x10,%esp
80100f13:	31 c0                	xor    %eax,%eax
  }
  return -1;
}
80100f15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f18:	c9                   	leave  
80100f19:	c3                   	ret    
80100f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return -1;
80100f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f25:	eb ee                	jmp    80100f15 <filestat+0x35>
80100f27:	89 f6                	mov    %esi,%esi
80100f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100f30 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100f30:	55                   	push   %ebp
80100f31:	89 e5                	mov    %esp,%ebp
80100f33:	57                   	push   %edi
80100f34:	56                   	push   %esi
80100f35:	53                   	push   %ebx
80100f36:	83 ec 0c             	sub    $0xc,%esp
80100f39:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100f3c:	8b 75 0c             	mov    0xc(%ebp),%esi
80100f3f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80100f42:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100f46:	74 60                	je     80100fa8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80100f48:	8b 03                	mov    (%ebx),%eax
80100f4a:	83 f8 01             	cmp    $0x1,%eax
80100f4d:	74 41                	je     80100f90 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100f4f:	83 f8 02             	cmp    $0x2,%eax
80100f52:	75 5b                	jne    80100faf <fileread+0x7f>
    ilock(f->ip);
80100f54:	83 ec 0c             	sub    $0xc,%esp
80100f57:	ff 73 10             	pushl  0x10(%ebx)
80100f5a:	e8 b1 06 00 00       	call   80101610 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100f5f:	57                   	push   %edi
80100f60:	ff 73 14             	pushl  0x14(%ebx)
80100f63:	56                   	push   %esi
80100f64:	ff 73 10             	pushl  0x10(%ebx)
80100f67:	e8 c4 09 00 00       	call   80101930 <readi>
80100f6c:	83 c4 20             	add    $0x20,%esp
80100f6f:	85 c0                	test   %eax,%eax
80100f71:	89 c6                	mov    %eax,%esi
80100f73:	7e 03                	jle    80100f78 <fileread+0x48>
      f->off += r;
80100f75:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100f78:	83 ec 0c             	sub    $0xc,%esp
80100f7b:	ff 73 10             	pushl  0x10(%ebx)
80100f7e:	e8 9d 07 00 00       	call   80101720 <iunlock>
    return r;
80100f83:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f89:	89 f0                	mov    %esi,%eax
80100f8b:	5b                   	pop    %ebx
80100f8c:	5e                   	pop    %esi
80100f8d:	5f                   	pop    %edi
80100f8e:	5d                   	pop    %ebp
80100f8f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100f90:	8b 43 0c             	mov    0xc(%ebx),%eax
80100f93:	89 45 08             	mov    %eax,0x8(%ebp)
}
80100f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f99:	5b                   	pop    %ebx
80100f9a:	5e                   	pop    %esi
80100f9b:	5f                   	pop    %edi
80100f9c:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
80100f9d:	e9 0e 27 00 00       	jmp    801036b0 <piperead>
80100fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80100fa8:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100fad:	eb d7                	jmp    80100f86 <fileread+0x56>
  panic("fileread");
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	68 3e 79 10 80       	push   $0x8010793e
80100fb7:	e8 b4 f3 ff ff       	call   80100370 <panic>
80100fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100fc0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100fc0:	55                   	push   %ebp
80100fc1:	89 e5                	mov    %esp,%ebp
80100fc3:	57                   	push   %edi
80100fc4:	56                   	push   %esi
80100fc5:	53                   	push   %ebx
80100fc6:	83 ec 1c             	sub    $0x1c,%esp
80100fc9:	8b 75 08             	mov    0x8(%ebp),%esi
80100fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  int r;

  if(f->writable == 0)
80100fcf:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
{
80100fd3:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100fd6:	8b 45 10             	mov    0x10(%ebp),%eax
80100fd9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
80100fdc:	0f 84 aa 00 00 00    	je     8010108c <filewrite+0xcc>
    return -1;
  if(f->type == FD_PIPE)
80100fe2:	8b 06                	mov    (%esi),%eax
80100fe4:	83 f8 01             	cmp    $0x1,%eax
80100fe7:	0f 84 c3 00 00 00    	je     801010b0 <filewrite+0xf0>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100fed:	83 f8 02             	cmp    $0x2,%eax
80100ff0:	0f 85 d9 00 00 00    	jne    801010cf <filewrite+0x10f>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
80100ff9:	31 ff                	xor    %edi,%edi
    while(i < n){
80100ffb:	85 c0                	test   %eax,%eax
80100ffd:	7f 34                	jg     80101033 <filewrite+0x73>
80100fff:	e9 9c 00 00 00       	jmp    801010a0 <filewrite+0xe0>
80101004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101008:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
8010100b:	83 ec 0c             	sub    $0xc,%esp
8010100e:	ff 76 10             	pushl  0x10(%esi)
        f->off += r;
80101011:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101014:	e8 07 07 00 00       	call   80101720 <iunlock>
      end_op();
80101019:	e8 82 1c 00 00       	call   80102ca0 <end_op>
8010101e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101021:	83 c4 10             	add    $0x10,%esp

      if(r < 0)
        break;
      if(r != n1)
80101024:	39 c3                	cmp    %eax,%ebx
80101026:	0f 85 96 00 00 00    	jne    801010c2 <filewrite+0x102>
        panic("short filewrite");
      i += r;
8010102c:	01 df                	add    %ebx,%edi
    while(i < n){
8010102e:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101031:	7e 6d                	jle    801010a0 <filewrite+0xe0>
      int n1 = n - i;
80101033:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101036:	b8 00 1a 00 00       	mov    $0x1a00,%eax
8010103b:	29 fb                	sub    %edi,%ebx
8010103d:	81 fb 00 1a 00 00    	cmp    $0x1a00,%ebx
80101043:	0f 4f d8             	cmovg  %eax,%ebx
      begin_op();
80101046:	e8 e5 1b 00 00       	call   80102c30 <begin_op>
      ilock(f->ip);
8010104b:	83 ec 0c             	sub    $0xc,%esp
8010104e:	ff 76 10             	pushl  0x10(%esi)
80101051:	e8 ba 05 00 00       	call   80101610 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101056:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101059:	53                   	push   %ebx
8010105a:	ff 76 14             	pushl  0x14(%esi)
8010105d:	01 f8                	add    %edi,%eax
8010105f:	50                   	push   %eax
80101060:	ff 76 10             	pushl  0x10(%esi)
80101063:	e8 c8 09 00 00       	call   80101a30 <writei>
80101068:	83 c4 20             	add    $0x20,%esp
8010106b:	85 c0                	test   %eax,%eax
8010106d:	7f 99                	jg     80101008 <filewrite+0x48>
      iunlock(f->ip);
8010106f:	83 ec 0c             	sub    $0xc,%esp
80101072:	ff 76 10             	pushl  0x10(%esi)
80101075:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101078:	e8 a3 06 00 00       	call   80101720 <iunlock>
      end_op();
8010107d:	e8 1e 1c 00 00       	call   80102ca0 <end_op>
      if(r < 0)
80101082:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101085:	83 c4 10             	add    $0x10,%esp
80101088:	85 c0                	test   %eax,%eax
8010108a:	74 98                	je     80101024 <filewrite+0x64>
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
8010108c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010108f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
}
80101094:	89 f8                	mov    %edi,%eax
80101096:	5b                   	pop    %ebx
80101097:	5e                   	pop    %esi
80101098:	5f                   	pop    %edi
80101099:	5d                   	pop    %ebp
8010109a:	c3                   	ret    
8010109b:	90                   	nop
8010109c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return i == n ? n : -1;
801010a0:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
801010a3:	75 e7                	jne    8010108c <filewrite+0xcc>
}
801010a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010a8:	89 f8                	mov    %edi,%eax
801010aa:	5b                   	pop    %ebx
801010ab:	5e                   	pop    %esi
801010ac:	5f                   	pop    %edi
801010ad:	5d                   	pop    %ebp
801010ae:	c3                   	ret    
801010af:	90                   	nop
    return pipewrite(f->pipe, addr, n);
801010b0:	8b 46 0c             	mov    0xc(%esi),%eax
801010b3:	89 45 08             	mov    %eax,0x8(%ebp)
}
801010b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010b9:	5b                   	pop    %ebx
801010ba:	5e                   	pop    %esi
801010bb:	5f                   	pop    %edi
801010bc:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801010bd:	e9 be 24 00 00       	jmp    80103580 <pipewrite>
        panic("short filewrite");
801010c2:	83 ec 0c             	sub    $0xc,%esp
801010c5:	68 47 79 10 80       	push   $0x80107947
801010ca:	e8 a1 f2 ff ff       	call   80100370 <panic>
  panic("filewrite");
801010cf:	83 ec 0c             	sub    $0xc,%esp
801010d2:	68 4d 79 10 80       	push   $0x8010794d
801010d7:	e8 94 f2 ff ff       	call   80100370 <panic>
801010dc:	66 90                	xchg   %ax,%ax
801010de:	66 90                	xchg   %ax,%ax

801010e0 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801010e0:	55                   	push   %ebp
801010e1:	89 e5                	mov    %esp,%ebp
801010e3:	57                   	push   %edi
801010e4:	56                   	push   %esi
801010e5:	53                   	push   %ebx
801010e6:	83 ec 1c             	sub    $0x1c,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801010e9:	8b 0d a0 11 11 80    	mov    0x801111a0,%ecx
{
801010ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801010f2:	85 c9                	test   %ecx,%ecx
801010f4:	0f 84 87 00 00 00    	je     80101181 <balloc+0xa1>
801010fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101101:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101104:	83 ec 08             	sub    $0x8,%esp
80101107:	89 f0                	mov    %esi,%eax
80101109:	c1 f8 0c             	sar    $0xc,%eax
8010110c:	03 05 b8 11 11 80    	add    0x801111b8,%eax
80101112:	50                   	push   %eax
80101113:	ff 75 d8             	pushl  -0x28(%ebp)
80101116:	e8 a5 ef ff ff       	call   801000c0 <bread>
8010111b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010111e:	a1 a0 11 11 80       	mov    0x801111a0,%eax
80101123:	83 c4 10             	add    $0x10,%esp
80101126:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101129:	31 c0                	xor    %eax,%eax
8010112b:	eb 2f                	jmp    8010115c <balloc+0x7c>
8010112d:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
80101130:	89 c1                	mov    %eax,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101132:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
80101135:	bb 01 00 00 00       	mov    $0x1,%ebx
8010113a:	83 e1 07             	and    $0x7,%ecx
8010113d:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010113f:	89 c1                	mov    %eax,%ecx
80101141:	c1 f9 03             	sar    $0x3,%ecx
80101144:	0f b6 7c 0a 18       	movzbl 0x18(%edx,%ecx,1),%edi
80101149:	85 df                	test   %ebx,%edi
8010114b:	89 fa                	mov    %edi,%edx
8010114d:	74 41                	je     80101190 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010114f:	83 c0 01             	add    $0x1,%eax
80101152:	83 c6 01             	add    $0x1,%esi
80101155:	3d 00 10 00 00       	cmp    $0x1000,%eax
8010115a:	74 05                	je     80101161 <balloc+0x81>
8010115c:	39 75 e0             	cmp    %esi,-0x20(%ebp)
8010115f:	77 cf                	ja     80101130 <balloc+0x50>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101161:	83 ec 0c             	sub    $0xc,%esp
80101164:	ff 75 e4             	pushl  -0x1c(%ebp)
80101167:	e8 64 f0 ff ff       	call   801001d0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010116c:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
80101173:	83 c4 10             	add    $0x10,%esp
80101176:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101179:	39 05 a0 11 11 80    	cmp    %eax,0x801111a0
8010117f:	77 80                	ja     80101101 <balloc+0x21>
  }
  panic("balloc: out of blocks");
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 57 79 10 80       	push   $0x80107957
80101189:	e8 e2 f1 ff ff       	call   80100370 <panic>
8010118e:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
80101190:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
80101193:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
80101196:	09 da                	or     %ebx,%edx
80101198:	88 54 0f 18          	mov    %dl,0x18(%edi,%ecx,1)
        log_write(bp);
8010119c:	57                   	push   %edi
8010119d:	e8 5e 1c 00 00       	call   80102e00 <log_write>
        brelse(bp);
801011a2:	89 3c 24             	mov    %edi,(%esp)
801011a5:	e8 26 f0 ff ff       	call   801001d0 <brelse>
  bp = bread(dev, bno);
801011aa:	58                   	pop    %eax
801011ab:	5a                   	pop    %edx
801011ac:	56                   	push   %esi
801011ad:	ff 75 d8             	pushl  -0x28(%ebp)
801011b0:	e8 0b ef ff ff       	call   801000c0 <bread>
801011b5:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
801011b7:	8d 40 18             	lea    0x18(%eax),%eax
801011ba:	83 c4 0c             	add    $0xc,%esp
801011bd:	68 00 02 00 00       	push   $0x200
801011c2:	6a 00                	push   $0x0
801011c4:	50                   	push   %eax
801011c5:	e8 06 3a 00 00       	call   80104bd0 <memset>
  log_write(bp);
801011ca:	89 1c 24             	mov    %ebx,(%esp)
801011cd:	e8 2e 1c 00 00       	call   80102e00 <log_write>
  brelse(bp);
801011d2:	89 1c 24             	mov    %ebx,(%esp)
801011d5:	e8 f6 ef ff ff       	call   801001d0 <brelse>
}
801011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011dd:	89 f0                	mov    %esi,%eax
801011df:	5b                   	pop    %ebx
801011e0:	5e                   	pop    %esi
801011e1:	5f                   	pop    %edi
801011e2:	5d                   	pop    %ebp
801011e3:	c3                   	ret    
801011e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801011ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801011f0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801011f0:	55                   	push   %ebp
801011f1:	89 e5                	mov    %esp,%ebp
801011f3:	57                   	push   %edi
801011f4:	56                   	push   %esi
801011f5:	53                   	push   %ebx
801011f6:	89 c7                	mov    %eax,%edi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
801011f8:	31 f6                	xor    %esi,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011fa:	bb f4 11 11 80       	mov    $0x801111f4,%ebx
{
801011ff:	83 ec 28             	sub    $0x28,%esp
80101202:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101205:	68 c0 11 11 80       	push   $0x801111c0
8010120a:	e8 b1 37 00 00       	call   801049c0 <acquire>
8010120f:	83 c4 10             	add    $0x10,%esp
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101212:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101215:	eb 14                	jmp    8010122b <iget+0x3b>
80101217:	89 f6                	mov    %esi,%esi
80101219:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80101220:	83 c3 50             	add    $0x50,%ebx
80101223:	81 fb 94 21 11 80    	cmp    $0x80112194,%ebx
80101229:	73 1f                	jae    8010124a <iget+0x5a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010122b:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010122e:	85 c9                	test   %ecx,%ecx
80101230:	7e 04                	jle    80101236 <iget+0x46>
80101232:	39 3b                	cmp    %edi,(%ebx)
80101234:	74 4a                	je     80101280 <iget+0x90>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101236:	85 f6                	test   %esi,%esi
80101238:	75 e6                	jne    80101220 <iget+0x30>
8010123a:	85 c9                	test   %ecx,%ecx
8010123c:	0f 44 f3             	cmove  %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010123f:	83 c3 50             	add    $0x50,%ebx
80101242:	81 fb 94 21 11 80    	cmp    $0x80112194,%ebx
80101248:	72 e1                	jb     8010122b <iget+0x3b>
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010124a:	85 f6                	test   %esi,%esi
8010124c:	74 59                	je     801012a7 <iget+0xb7>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);
8010124e:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
80101251:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101253:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
80101256:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->flags = 0;
8010125d:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
  release(&icache.lock);
80101264:	68 c0 11 11 80       	push   $0x801111c0
80101269:	e8 12 39 00 00       	call   80104b80 <release>

  return ip;
8010126e:	83 c4 10             	add    $0x10,%esp
}
80101271:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101274:	89 f0                	mov    %esi,%eax
80101276:	5b                   	pop    %ebx
80101277:	5e                   	pop    %esi
80101278:	5f                   	pop    %edi
80101279:	5d                   	pop    %ebp
8010127a:	c3                   	ret    
8010127b:	90                   	nop
8010127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101280:	39 53 04             	cmp    %edx,0x4(%ebx)
80101283:	75 b1                	jne    80101236 <iget+0x46>
      release(&icache.lock);
80101285:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101288:	83 c1 01             	add    $0x1,%ecx
      return ip;
8010128b:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
8010128d:	68 c0 11 11 80       	push   $0x801111c0
      ip->ref++;
80101292:	89 4b 08             	mov    %ecx,0x8(%ebx)
      release(&icache.lock);
80101295:	e8 e6 38 00 00       	call   80104b80 <release>
      return ip;
8010129a:	83 c4 10             	add    $0x10,%esp
}
8010129d:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012a0:	89 f0                	mov    %esi,%eax
801012a2:	5b                   	pop    %ebx
801012a3:	5e                   	pop    %esi
801012a4:	5f                   	pop    %edi
801012a5:	5d                   	pop    %ebp
801012a6:	c3                   	ret    
    panic("iget: no inodes");
801012a7:	83 ec 0c             	sub    $0xc,%esp
801012aa:	68 6d 79 10 80       	push   $0x8010796d
801012af:	e8 bc f0 ff ff       	call   80100370 <panic>
801012b4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801012ba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801012c0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
801012c0:	55                   	push   %ebp
801012c1:	89 e5                	mov    %esp,%ebp
801012c3:	57                   	push   %edi
801012c4:	56                   	push   %esi
801012c5:	53                   	push   %ebx
801012c6:	89 c6                	mov    %eax,%esi
801012c8:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
801012cb:	83 fa 0b             	cmp    $0xb,%edx
801012ce:	77 18                	ja     801012e8 <bmap+0x28>
801012d0:	8d 3c 90             	lea    (%eax,%edx,4),%edi
    if((addr = ip->addrs[bn]) == 0)
801012d3:	8b 5f 1c             	mov    0x1c(%edi),%ebx
801012d6:	85 db                	test   %ebx,%ebx
801012d8:	74 6e                	je     80101348 <bmap+0x88>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
801012da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012dd:	89 d8                	mov    %ebx,%eax
801012df:	5b                   	pop    %ebx
801012e0:	5e                   	pop    %esi
801012e1:	5f                   	pop    %edi
801012e2:	5d                   	pop    %ebp
801012e3:	c3                   	ret    
801012e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  bn -= NDIRECT;
801012e8:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
801012eb:	83 fb 7f             	cmp    $0x7f,%ebx
801012ee:	77 7e                	ja     8010136e <bmap+0xae>
    if((addr = ip->addrs[NDIRECT]) == 0)
801012f0:	8b 50 4c             	mov    0x4c(%eax),%edx
801012f3:	8b 00                	mov    (%eax),%eax
801012f5:	85 d2                	test   %edx,%edx
801012f7:	74 67                	je     80101360 <bmap+0xa0>
    bp = bread(ip->dev, addr);
801012f9:	83 ec 08             	sub    $0x8,%esp
801012fc:	52                   	push   %edx
801012fd:	50                   	push   %eax
801012fe:	e8 bd ed ff ff       	call   801000c0 <bread>
    if((addr = a[bn]) == 0){
80101303:	8d 54 98 18          	lea    0x18(%eax,%ebx,4),%edx
80101307:	83 c4 10             	add    $0x10,%esp
    bp = bread(ip->dev, addr);
8010130a:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
8010130c:	8b 1a                	mov    (%edx),%ebx
8010130e:	85 db                	test   %ebx,%ebx
80101310:	75 1d                	jne    8010132f <bmap+0x6f>
      a[bn] = addr = balloc(ip->dev);
80101312:	8b 06                	mov    (%esi),%eax
80101314:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101317:	e8 c4 fd ff ff       	call   801010e0 <balloc>
8010131c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      log_write(bp);
8010131f:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
80101322:	89 c3                	mov    %eax,%ebx
80101324:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101326:	57                   	push   %edi
80101327:	e8 d4 1a 00 00       	call   80102e00 <log_write>
8010132c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010132f:	83 ec 0c             	sub    $0xc,%esp
80101332:	57                   	push   %edi
80101333:	e8 98 ee ff ff       	call   801001d0 <brelse>
80101338:	83 c4 10             	add    $0x10,%esp
}
8010133b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010133e:	89 d8                	mov    %ebx,%eax
80101340:	5b                   	pop    %ebx
80101341:	5e                   	pop    %esi
80101342:	5f                   	pop    %edi
80101343:	5d                   	pop    %ebp
80101344:	c3                   	ret    
80101345:	8d 76 00             	lea    0x0(%esi),%esi
      ip->addrs[bn] = addr = balloc(ip->dev);
80101348:	8b 00                	mov    (%eax),%eax
8010134a:	e8 91 fd ff ff       	call   801010e0 <balloc>
8010134f:	89 47 1c             	mov    %eax,0x1c(%edi)
}
80101352:	8d 65 f4             	lea    -0xc(%ebp),%esp
      ip->addrs[bn] = addr = balloc(ip->dev);
80101355:	89 c3                	mov    %eax,%ebx
}
80101357:	89 d8                	mov    %ebx,%eax
80101359:	5b                   	pop    %ebx
8010135a:	5e                   	pop    %esi
8010135b:	5f                   	pop    %edi
8010135c:	5d                   	pop    %ebp
8010135d:	c3                   	ret    
8010135e:	66 90                	xchg   %ax,%ax
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101360:	e8 7b fd ff ff       	call   801010e0 <balloc>
80101365:	89 c2                	mov    %eax,%edx
80101367:	89 46 4c             	mov    %eax,0x4c(%esi)
8010136a:	8b 06                	mov    (%esi),%eax
8010136c:	eb 8b                	jmp    801012f9 <bmap+0x39>
  panic("bmap: out of range");
8010136e:	83 ec 0c             	sub    $0xc,%esp
80101371:	68 7d 79 10 80       	push   $0x8010797d
80101376:	e8 f5 ef ff ff       	call   80100370 <panic>
8010137b:	90                   	nop
8010137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101380 <readsb>:
{
80101380:	55                   	push   %ebp
80101381:	89 e5                	mov    %esp,%ebp
80101383:	56                   	push   %esi
80101384:	53                   	push   %ebx
80101385:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101388:	83 ec 08             	sub    $0x8,%esp
8010138b:	6a 01                	push   $0x1
8010138d:	ff 75 08             	pushl  0x8(%ebp)
80101390:	e8 2b ed ff ff       	call   801000c0 <bread>
80101395:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101397:	8d 40 18             	lea    0x18(%eax),%eax
8010139a:	83 c4 0c             	add    $0xc,%esp
8010139d:	6a 1c                	push   $0x1c
8010139f:	50                   	push   %eax
801013a0:	56                   	push   %esi
801013a1:	e8 da 38 00 00       	call   80104c80 <memmove>
  brelse(bp);
801013a6:	89 5d 08             	mov    %ebx,0x8(%ebp)
801013a9:	83 c4 10             	add    $0x10,%esp
}
801013ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
801013af:	5b                   	pop    %ebx
801013b0:	5e                   	pop    %esi
801013b1:	5d                   	pop    %ebp
  brelse(bp);
801013b2:	e9 19 ee ff ff       	jmp    801001d0 <brelse>
801013b7:	89 f6                	mov    %esi,%esi
801013b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801013c0 <bfree>:
{
801013c0:	55                   	push   %ebp
801013c1:	89 e5                	mov    %esp,%ebp
801013c3:	56                   	push   %esi
801013c4:	53                   	push   %ebx
801013c5:	89 d3                	mov    %edx,%ebx
801013c7:	89 c6                	mov    %eax,%esi
  readsb(dev, &sb);
801013c9:	83 ec 08             	sub    $0x8,%esp
801013cc:	68 a0 11 11 80       	push   $0x801111a0
801013d1:	50                   	push   %eax
801013d2:	e8 a9 ff ff ff       	call   80101380 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801013d7:	58                   	pop    %eax
801013d8:	5a                   	pop    %edx
801013d9:	89 da                	mov    %ebx,%edx
801013db:	c1 ea 0c             	shr    $0xc,%edx
801013de:	03 15 b8 11 11 80    	add    0x801111b8,%edx
801013e4:	52                   	push   %edx
801013e5:	56                   	push   %esi
801013e6:	e8 d5 ec ff ff       	call   801000c0 <bread>
  m = 1 << (bi % 8);
801013eb:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801013ed:	c1 fb 03             	sar    $0x3,%ebx
  m = 1 << (bi % 8);
801013f0:	ba 01 00 00 00       	mov    $0x1,%edx
801013f5:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
801013f8:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801013fe:	83 c4 10             	add    $0x10,%esp
  m = 1 << (bi % 8);
80101401:	d3 e2                	shl    %cl,%edx
  if((bp->data[bi/8] & m) == 0)
80101403:	0f b6 4c 18 18       	movzbl 0x18(%eax,%ebx,1),%ecx
80101408:	85 d1                	test   %edx,%ecx
8010140a:	74 25                	je     80101431 <bfree+0x71>
  bp->data[bi/8] &= ~m;
8010140c:	f7 d2                	not    %edx
8010140e:	89 c6                	mov    %eax,%esi
  log_write(bp);
80101410:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101413:	21 ca                	and    %ecx,%edx
80101415:	88 54 1e 18          	mov    %dl,0x18(%esi,%ebx,1)
  log_write(bp);
80101419:	56                   	push   %esi
8010141a:	e8 e1 19 00 00       	call   80102e00 <log_write>
  brelse(bp);
8010141f:	89 34 24             	mov    %esi,(%esp)
80101422:	e8 a9 ed ff ff       	call   801001d0 <brelse>
}
80101427:	83 c4 10             	add    $0x10,%esp
8010142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010142d:	5b                   	pop    %ebx
8010142e:	5e                   	pop    %esi
8010142f:	5d                   	pop    %ebp
80101430:	c3                   	ret    
    panic("freeing free block");
80101431:	83 ec 0c             	sub    $0xc,%esp
80101434:	68 90 79 10 80       	push   $0x80107990
80101439:	e8 32 ef ff ff       	call   80100370 <panic>
8010143e:	66 90                	xchg   %ax,%ax

80101440 <iinit>:
{
80101440:	55                   	push   %ebp
80101441:	89 e5                	mov    %esp,%ebp
80101443:	83 ec 10             	sub    $0x10,%esp
  initlock(&icache.lock, "icache");
80101446:	68 a3 79 10 80       	push   $0x801079a3
8010144b:	68 c0 11 11 80       	push   $0x801111c0
80101450:	e8 4b 35 00 00       	call   801049a0 <initlock>
  readsb(dev, &sb);
80101455:	58                   	pop    %eax
80101456:	5a                   	pop    %edx
80101457:	68 a0 11 11 80       	push   $0x801111a0
8010145c:	ff 75 08             	pushl  0x8(%ebp)
8010145f:	e8 1c ff ff ff       	call   80101380 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101464:	ff 35 b8 11 11 80    	pushl  0x801111b8
8010146a:	ff 35 b4 11 11 80    	pushl  0x801111b4
80101470:	ff 35 b0 11 11 80    	pushl  0x801111b0
80101476:	ff 35 ac 11 11 80    	pushl  0x801111ac
8010147c:	ff 35 a8 11 11 80    	pushl  0x801111a8
80101482:	ff 35 a4 11 11 80    	pushl  0x801111a4
80101488:	ff 35 a0 11 11 80    	pushl  0x801111a0
8010148e:	68 04 7a 10 80       	push   $0x80107a04
80101493:	e8 a8 f1 ff ff       	call   80100640 <cprintf>
}
80101498:	83 c4 30             	add    $0x30,%esp
8010149b:	c9                   	leave  
8010149c:	c3                   	ret    
8010149d:	8d 76 00             	lea    0x0(%esi),%esi

801014a0 <ialloc>:
{
801014a0:	55                   	push   %ebp
801014a1:	89 e5                	mov    %esp,%ebp
801014a3:	57                   	push   %edi
801014a4:	56                   	push   %esi
801014a5:	53                   	push   %ebx
801014a6:	83 ec 1c             	sub    $0x1c,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801014a9:	83 3d a8 11 11 80 01 	cmpl   $0x1,0x801111a8
{
801014b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801014b3:	8b 75 08             	mov    0x8(%ebp),%esi
801014b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
801014b9:	0f 86 91 00 00 00    	jbe    80101550 <ialloc+0xb0>
801014bf:	bb 01 00 00 00       	mov    $0x1,%ebx
801014c4:	eb 21                	jmp    801014e7 <ialloc+0x47>
801014c6:	8d 76 00             	lea    0x0(%esi),%esi
801014c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    brelse(bp);
801014d0:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801014d3:	83 c3 01             	add    $0x1,%ebx
    brelse(bp);
801014d6:	57                   	push   %edi
801014d7:	e8 f4 ec ff ff       	call   801001d0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801014dc:	83 c4 10             	add    $0x10,%esp
801014df:	39 1d a8 11 11 80    	cmp    %ebx,0x801111a8
801014e5:	76 69                	jbe    80101550 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
801014e7:	89 d8                	mov    %ebx,%eax
801014e9:	83 ec 08             	sub    $0x8,%esp
801014ec:	c1 e8 03             	shr    $0x3,%eax
801014ef:	03 05 b4 11 11 80    	add    0x801111b4,%eax
801014f5:	50                   	push   %eax
801014f6:	56                   	push   %esi
801014f7:	e8 c4 eb ff ff       	call   801000c0 <bread>
801014fc:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
801014fe:	89 d8                	mov    %ebx,%eax
    if(dip->type == 0){  // a free inode
80101500:	83 c4 10             	add    $0x10,%esp
    dip = (struct dinode*)bp->data + inum%IPB;
80101503:	83 e0 07             	and    $0x7,%eax
80101506:	c1 e0 06             	shl    $0x6,%eax
80101509:	8d 4c 07 18          	lea    0x18(%edi,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010150d:	66 83 39 00          	cmpw   $0x0,(%ecx)
80101511:	75 bd                	jne    801014d0 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101513:	83 ec 04             	sub    $0x4,%esp
80101516:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101519:	6a 40                	push   $0x40
8010151b:	6a 00                	push   $0x0
8010151d:	51                   	push   %ecx
8010151e:	e8 ad 36 00 00       	call   80104bd0 <memset>
      dip->type = type;
80101523:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80101527:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010152a:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
8010152d:	89 3c 24             	mov    %edi,(%esp)
80101530:	e8 cb 18 00 00       	call   80102e00 <log_write>
      brelse(bp);
80101535:	89 3c 24             	mov    %edi,(%esp)
80101538:	e8 93 ec ff ff       	call   801001d0 <brelse>
      return iget(dev, inum);
8010153d:	83 c4 10             	add    $0x10,%esp
}
80101540:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
80101543:	89 da                	mov    %ebx,%edx
80101545:	89 f0                	mov    %esi,%eax
}
80101547:	5b                   	pop    %ebx
80101548:	5e                   	pop    %esi
80101549:	5f                   	pop    %edi
8010154a:	5d                   	pop    %ebp
      return iget(dev, inum);
8010154b:	e9 a0 fc ff ff       	jmp    801011f0 <iget>
  panic("ialloc: no inodes");
80101550:	83 ec 0c             	sub    $0xc,%esp
80101553:	68 aa 79 10 80       	push   $0x801079aa
80101558:	e8 13 ee ff ff       	call   80100370 <panic>
8010155d:	8d 76 00             	lea    0x0(%esi),%esi

80101560 <iupdate>:
{
80101560:	55                   	push   %ebp
80101561:	89 e5                	mov    %esp,%ebp
80101563:	56                   	push   %esi
80101564:	53                   	push   %ebx
80101565:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101568:	83 ec 08             	sub    $0x8,%esp
8010156b:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010156e:	83 c3 1c             	add    $0x1c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101571:	c1 e8 03             	shr    $0x3,%eax
80101574:	03 05 b4 11 11 80    	add    0x801111b4,%eax
8010157a:	50                   	push   %eax
8010157b:	ff 73 e4             	pushl  -0x1c(%ebx)
8010157e:	e8 3d eb ff ff       	call   801000c0 <bread>
80101583:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101585:	8b 43 e8             	mov    -0x18(%ebx),%eax
  dip->type = ip->type;
80101588:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010158c:	83 c4 0c             	add    $0xc,%esp
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010158f:	83 e0 07             	and    $0x7,%eax
80101592:	c1 e0 06             	shl    $0x6,%eax
80101595:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
  dip->type = ip->type;
80101599:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010159c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801015a0:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
801015a3:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
801015a7:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
801015ab:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
801015af:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
801015b3:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
801015b7:	8b 53 fc             	mov    -0x4(%ebx),%edx
801015ba:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801015bd:	6a 34                	push   $0x34
801015bf:	53                   	push   %ebx
801015c0:	50                   	push   %eax
801015c1:	e8 ba 36 00 00       	call   80104c80 <memmove>
  log_write(bp);
801015c6:	89 34 24             	mov    %esi,(%esp)
801015c9:	e8 32 18 00 00       	call   80102e00 <log_write>
  brelse(bp);
801015ce:	89 75 08             	mov    %esi,0x8(%ebp)
801015d1:	83 c4 10             	add    $0x10,%esp
}
801015d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015d7:	5b                   	pop    %ebx
801015d8:	5e                   	pop    %esi
801015d9:	5d                   	pop    %ebp
  brelse(bp);
801015da:	e9 f1 eb ff ff       	jmp    801001d0 <brelse>
801015df:	90                   	nop

801015e0 <idup>:
{
801015e0:	55                   	push   %ebp
801015e1:	89 e5                	mov    %esp,%ebp
801015e3:	53                   	push   %ebx
801015e4:	83 ec 10             	sub    $0x10,%esp
801015e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801015ea:	68 c0 11 11 80       	push   $0x801111c0
801015ef:	e8 cc 33 00 00       	call   801049c0 <acquire>
  ip->ref++;
801015f4:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801015f8:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
801015ff:	e8 7c 35 00 00       	call   80104b80 <release>
}
80101604:	89 d8                	mov    %ebx,%eax
80101606:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101609:	c9                   	leave  
8010160a:	c3                   	ret    
8010160b:	90                   	nop
8010160c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101610 <ilock>:
{
80101610:	55                   	push   %ebp
80101611:	89 e5                	mov    %esp,%ebp
80101613:	56                   	push   %esi
80101614:	53                   	push   %ebx
80101615:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101618:	85 db                	test   %ebx,%ebx
8010161a:	0f 84 e8 00 00 00    	je     80101708 <ilock+0xf8>
80101620:	8b 43 08             	mov    0x8(%ebx),%eax
80101623:	85 c0                	test   %eax,%eax
80101625:	0f 8e dd 00 00 00    	jle    80101708 <ilock+0xf8>
  acquire(&icache.lock);
8010162b:	83 ec 0c             	sub    $0xc,%esp
8010162e:	68 c0 11 11 80       	push   $0x801111c0
80101633:	e8 88 33 00 00       	call   801049c0 <acquire>
  while(ip->flags & I_BUSY)
80101638:	8b 43 0c             	mov    0xc(%ebx),%eax
8010163b:	83 c4 10             	add    $0x10,%esp
8010163e:	a8 01                	test   $0x1,%al
80101640:	74 1e                	je     80101660 <ilock+0x50>
80101642:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sleep(ip, &icache.lock);
80101648:	83 ec 08             	sub    $0x8,%esp
8010164b:	68 c0 11 11 80       	push   $0x801111c0
80101650:	53                   	push   %ebx
80101651:	e8 0a 2a 00 00       	call   80104060 <sleep>
  while(ip->flags & I_BUSY)
80101656:	8b 43 0c             	mov    0xc(%ebx),%eax
80101659:	83 c4 10             	add    $0x10,%esp
8010165c:	a8 01                	test   $0x1,%al
8010165e:	75 e8                	jne    80101648 <ilock+0x38>
  release(&icache.lock);
80101660:	83 ec 0c             	sub    $0xc,%esp
  ip->flags |= I_BUSY;
80101663:	83 c8 01             	or     $0x1,%eax
80101666:	89 43 0c             	mov    %eax,0xc(%ebx)
  release(&icache.lock);
80101669:	68 c0 11 11 80       	push   $0x801111c0
8010166e:	e8 0d 35 00 00       	call   80104b80 <release>
  if(!(ip->flags & I_VALID)){
80101673:	83 c4 10             	add    $0x10,%esp
80101676:	f6 43 0c 02          	testb  $0x2,0xc(%ebx)
8010167a:	74 0c                	je     80101688 <ilock+0x78>
}
8010167c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010167f:	5b                   	pop    %ebx
80101680:	5e                   	pop    %esi
80101681:	5d                   	pop    %ebp
80101682:	c3                   	ret    
80101683:	90                   	nop
80101684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101688:	8b 43 04             	mov    0x4(%ebx),%eax
8010168b:	83 ec 08             	sub    $0x8,%esp
8010168e:	c1 e8 03             	shr    $0x3,%eax
80101691:	03 05 b4 11 11 80    	add    0x801111b4,%eax
80101697:	50                   	push   %eax
80101698:	ff 33                	pushl  (%ebx)
8010169a:	e8 21 ea ff ff       	call   801000c0 <bread>
8010169f:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801016a1:	8b 43 04             	mov    0x4(%ebx),%eax
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801016a4:	83 c4 0c             	add    $0xc,%esp
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801016a7:	83 e0 07             	and    $0x7,%eax
801016aa:	c1 e0 06             	shl    $0x6,%eax
801016ad:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
    ip->type = dip->type;
801016b1:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801016b4:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
801016b7:	66 89 53 10          	mov    %dx,0x10(%ebx)
    ip->major = dip->major;
801016bb:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
801016bf:	66 89 53 12          	mov    %dx,0x12(%ebx)
    ip->minor = dip->minor;
801016c3:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
801016c7:	66 89 53 14          	mov    %dx,0x14(%ebx)
    ip->nlink = dip->nlink;
801016cb:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
801016cf:	66 89 53 16          	mov    %dx,0x16(%ebx)
    ip->size = dip->size;
801016d3:	8b 50 fc             	mov    -0x4(%eax),%edx
801016d6:	89 53 18             	mov    %edx,0x18(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801016d9:	6a 34                	push   $0x34
801016db:	50                   	push   %eax
801016dc:	8d 43 1c             	lea    0x1c(%ebx),%eax
801016df:	50                   	push   %eax
801016e0:	e8 9b 35 00 00       	call   80104c80 <memmove>
    brelse(bp);
801016e5:	89 34 24             	mov    %esi,(%esp)
801016e8:	e8 e3 ea ff ff       	call   801001d0 <brelse>
    ip->flags |= I_VALID;
801016ed:	83 4b 0c 02          	orl    $0x2,0xc(%ebx)
    if(ip->type == 0)
801016f1:	83 c4 10             	add    $0x10,%esp
801016f4:	66 83 7b 10 00       	cmpw   $0x0,0x10(%ebx)
801016f9:	75 81                	jne    8010167c <ilock+0x6c>
      panic("ilock: no type");
801016fb:	83 ec 0c             	sub    $0xc,%esp
801016fe:	68 c2 79 10 80       	push   $0x801079c2
80101703:	e8 68 ec ff ff       	call   80100370 <panic>
    panic("ilock");
80101708:	83 ec 0c             	sub    $0xc,%esp
8010170b:	68 bc 79 10 80       	push   $0x801079bc
80101710:	e8 5b ec ff ff       	call   80100370 <panic>
80101715:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101719:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101720 <iunlock>:
{
80101720:	55                   	push   %ebp
80101721:	89 e5                	mov    %esp,%ebp
80101723:	53                   	push   %ebx
80101724:	83 ec 04             	sub    $0x4,%esp
80101727:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
8010172a:	85 db                	test   %ebx,%ebx
8010172c:	74 39                	je     80101767 <iunlock+0x47>
8010172e:	f6 43 0c 01          	testb  $0x1,0xc(%ebx)
80101732:	74 33                	je     80101767 <iunlock+0x47>
80101734:	8b 43 08             	mov    0x8(%ebx),%eax
80101737:	85 c0                	test   %eax,%eax
80101739:	7e 2c                	jle    80101767 <iunlock+0x47>
  acquire(&icache.lock);
8010173b:	83 ec 0c             	sub    $0xc,%esp
8010173e:	68 c0 11 11 80       	push   $0x801111c0
80101743:	e8 78 32 00 00       	call   801049c0 <acquire>
  ip->flags &= ~I_BUSY;
80101748:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
8010174c:	89 1c 24             	mov    %ebx,(%esp)
8010174f:	e8 fc 2a 00 00       	call   80104250 <wakeup>
  release(&icache.lock);
80101754:	83 c4 10             	add    $0x10,%esp
80101757:	c7 45 08 c0 11 11 80 	movl   $0x801111c0,0x8(%ebp)
}
8010175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101761:	c9                   	leave  
  release(&icache.lock);
80101762:	e9 19 34 00 00       	jmp    80104b80 <release>
    panic("iunlock");
80101767:	83 ec 0c             	sub    $0xc,%esp
8010176a:	68 d1 79 10 80       	push   $0x801079d1
8010176f:	e8 fc eb ff ff       	call   80100370 <panic>
80101774:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010177a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80101780 <iput>:
{
80101780:	55                   	push   %ebp
80101781:	89 e5                	mov    %esp,%ebp
80101783:	57                   	push   %edi
80101784:	56                   	push   %esi
80101785:	53                   	push   %ebx
80101786:	83 ec 28             	sub    $0x28,%esp
80101789:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&icache.lock);
8010178c:	68 c0 11 11 80       	push   $0x801111c0
80101791:	e8 2a 32 00 00       	call   801049c0 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101796:	8b 46 08             	mov    0x8(%esi),%eax
80101799:	83 c4 10             	add    $0x10,%esp
8010179c:	83 f8 01             	cmp    $0x1,%eax
8010179f:	0f 85 ab 00 00 00    	jne    80101850 <iput+0xd0>
801017a5:	8b 56 0c             	mov    0xc(%esi),%edx
801017a8:	f6 c2 02             	test   $0x2,%dl
801017ab:	0f 84 9f 00 00 00    	je     80101850 <iput+0xd0>
801017b1:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
801017b6:	0f 85 94 00 00 00    	jne    80101850 <iput+0xd0>
    if(ip->flags & I_BUSY)
801017bc:	f6 c2 01             	test   $0x1,%dl
801017bf:	0f 85 05 01 00 00    	jne    801018ca <iput+0x14a>
    release(&icache.lock);
801017c5:	83 ec 0c             	sub    $0xc,%esp
    ip->flags |= I_BUSY;
801017c8:	83 ca 01             	or     $0x1,%edx
801017cb:	8d 5e 1c             	lea    0x1c(%esi),%ebx
801017ce:	89 56 0c             	mov    %edx,0xc(%esi)
    release(&icache.lock);
801017d1:	68 c0 11 11 80       	push   $0x801111c0
801017d6:	8d 7e 4c             	lea    0x4c(%esi),%edi
801017d9:	e8 a2 33 00 00       	call   80104b80 <release>
801017de:	83 c4 10             	add    $0x10,%esp
801017e1:	eb 0c                	jmp    801017ef <iput+0x6f>
801017e3:	90                   	nop
801017e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801017e8:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801017eb:	39 fb                	cmp    %edi,%ebx
801017ed:	74 1b                	je     8010180a <iput+0x8a>
    if(ip->addrs[i]){
801017ef:	8b 13                	mov    (%ebx),%edx
801017f1:	85 d2                	test   %edx,%edx
801017f3:	74 f3                	je     801017e8 <iput+0x68>
      bfree(ip->dev, ip->addrs[i]);
801017f5:	8b 06                	mov    (%esi),%eax
801017f7:	83 c3 04             	add    $0x4,%ebx
801017fa:	e8 c1 fb ff ff       	call   801013c0 <bfree>
      ip->addrs[i] = 0;
801017ff:	c7 43 fc 00 00 00 00 	movl   $0x0,-0x4(%ebx)
  for(i = 0; i < NDIRECT; i++){
80101806:	39 fb                	cmp    %edi,%ebx
80101808:	75 e5                	jne    801017ef <iput+0x6f>
    }
  }

  if(ip->addrs[NDIRECT]){
8010180a:	8b 46 4c             	mov    0x4c(%esi),%eax
8010180d:	85 c0                	test   %eax,%eax
8010180f:	75 5f                	jne    80101870 <iput+0xf0>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101811:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101814:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
  iupdate(ip);
8010181b:	56                   	push   %esi
8010181c:	e8 3f fd ff ff       	call   80101560 <iupdate>
    ip->type = 0;
80101821:	31 c0                	xor    %eax,%eax
80101823:	66 89 46 10          	mov    %ax,0x10(%esi)
    iupdate(ip);
80101827:	89 34 24             	mov    %esi,(%esp)
8010182a:	e8 31 fd ff ff       	call   80101560 <iupdate>
    acquire(&icache.lock);
8010182f:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
80101836:	e8 85 31 00 00       	call   801049c0 <acquire>
    ip->flags = 0;
8010183b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
80101842:	89 34 24             	mov    %esi,(%esp)
80101845:	e8 06 2a 00 00       	call   80104250 <wakeup>
8010184a:	8b 46 08             	mov    0x8(%esi),%eax
8010184d:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101850:	83 e8 01             	sub    $0x1,%eax
80101853:	89 46 08             	mov    %eax,0x8(%esi)
  release(&icache.lock);
80101856:	c7 45 08 c0 11 11 80 	movl   $0x801111c0,0x8(%ebp)
}
8010185d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101860:	5b                   	pop    %ebx
80101861:	5e                   	pop    %esi
80101862:	5f                   	pop    %edi
80101863:	5d                   	pop    %ebp
  release(&icache.lock);
80101864:	e9 17 33 00 00       	jmp    80104b80 <release>
80101869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101870:	83 ec 08             	sub    $0x8,%esp
80101873:	50                   	push   %eax
80101874:	ff 36                	pushl  (%esi)
80101876:	e8 45 e8 ff ff       	call   801000c0 <bread>
8010187b:	83 c4 10             	add    $0x10,%esp
8010187e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101881:	8d 58 18             	lea    0x18(%eax),%ebx
80101884:	8d b8 18 02 00 00    	lea    0x218(%eax),%edi
8010188a:	eb 0b                	jmp    80101897 <iput+0x117>
8010188c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101890:	83 c3 04             	add    $0x4,%ebx
    for(j = 0; j < NINDIRECT; j++){
80101893:	39 df                	cmp    %ebx,%edi
80101895:	74 0f                	je     801018a6 <iput+0x126>
      if(a[j])
80101897:	8b 13                	mov    (%ebx),%edx
80101899:	85 d2                	test   %edx,%edx
8010189b:	74 f3                	je     80101890 <iput+0x110>
        bfree(ip->dev, a[j]);
8010189d:	8b 06                	mov    (%esi),%eax
8010189f:	e8 1c fb ff ff       	call   801013c0 <bfree>
801018a4:	eb ea                	jmp    80101890 <iput+0x110>
    brelse(bp);
801018a6:	83 ec 0c             	sub    $0xc,%esp
801018a9:	ff 75 e4             	pushl  -0x1c(%ebp)
801018ac:	e8 1f e9 ff ff       	call   801001d0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801018b1:	8b 56 4c             	mov    0x4c(%esi),%edx
801018b4:	8b 06                	mov    (%esi),%eax
801018b6:	e8 05 fb ff ff       	call   801013c0 <bfree>
    ip->addrs[NDIRECT] = 0;
801018bb:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
801018c2:	83 c4 10             	add    $0x10,%esp
801018c5:	e9 47 ff ff ff       	jmp    80101811 <iput+0x91>
      panic("iput busy");
801018ca:	83 ec 0c             	sub    $0xc,%esp
801018cd:	68 d9 79 10 80       	push   $0x801079d9
801018d2:	e8 99 ea ff ff       	call   80100370 <panic>
801018d7:	89 f6                	mov    %esi,%esi
801018d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801018e0 <iunlockput>:
{
801018e0:	55                   	push   %ebp
801018e1:	89 e5                	mov    %esp,%ebp
801018e3:	53                   	push   %ebx
801018e4:	83 ec 10             	sub    $0x10,%esp
801018e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801018ea:	53                   	push   %ebx
801018eb:	e8 30 fe ff ff       	call   80101720 <iunlock>
  iput(ip);
801018f0:	89 5d 08             	mov    %ebx,0x8(%ebp)
801018f3:	83 c4 10             	add    $0x10,%esp
}
801018f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801018f9:	c9                   	leave  
  iput(ip);
801018fa:	e9 81 fe ff ff       	jmp    80101780 <iput>
801018ff:	90                   	nop

80101900 <stati>:
}

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101900:	55                   	push   %ebp
80101901:	89 e5                	mov    %esp,%ebp
80101903:	8b 55 08             	mov    0x8(%ebp),%edx
80101906:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101909:	8b 0a                	mov    (%edx),%ecx
8010190b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
8010190e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101911:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101914:	0f b7 4a 10          	movzwl 0x10(%edx),%ecx
80101918:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
8010191b:	0f b7 4a 16          	movzwl 0x16(%edx),%ecx
8010191f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101923:	8b 52 18             	mov    0x18(%edx),%edx
80101926:	89 50 10             	mov    %edx,0x10(%eax)
}
80101929:	5d                   	pop    %ebp
8010192a:	c3                   	ret    
8010192b:	90                   	nop
8010192c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101930 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101930:	55                   	push   %ebp
80101931:	89 e5                	mov    %esp,%ebp
80101933:	57                   	push   %edi
80101934:	56                   	push   %esi
80101935:	53                   	push   %ebx
80101936:	83 ec 1c             	sub    $0x1c,%esp
80101939:	8b 45 08             	mov    0x8(%ebp),%eax
8010193c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010193f:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101942:	66 83 78 10 03       	cmpw   $0x3,0x10(%eax)
{
80101947:	89 75 e0             	mov    %esi,-0x20(%ebp)
8010194a:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010194d:	8b 75 10             	mov    0x10(%ebp),%esi
80101950:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101953:	0f 84 a7 00 00 00    	je     80101a00 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101959:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010195c:	8b 40 18             	mov    0x18(%eax),%eax
8010195f:	39 c6                	cmp    %eax,%esi
80101961:	0f 87 ba 00 00 00    	ja     80101a21 <readi+0xf1>
80101967:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010196a:	89 f9                	mov    %edi,%ecx
8010196c:	01 f1                	add    %esi,%ecx
8010196e:	0f 82 ad 00 00 00    	jb     80101a21 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101974:	89 c2                	mov    %eax,%edx
80101976:	29 f2                	sub    %esi,%edx
80101978:	39 c8                	cmp    %ecx,%eax
8010197a:	0f 43 d7             	cmovae %edi,%edx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010197d:	31 ff                	xor    %edi,%edi
8010197f:	85 d2                	test   %edx,%edx
    n = ip->size - off;
80101981:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101984:	74 6c                	je     801019f2 <readi+0xc2>
80101986:	8d 76 00             	lea    0x0(%esi),%esi
80101989:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101990:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101993:	89 f2                	mov    %esi,%edx
80101995:	c1 ea 09             	shr    $0x9,%edx
80101998:	89 d8                	mov    %ebx,%eax
8010199a:	e8 21 f9 ff ff       	call   801012c0 <bmap>
8010199f:	83 ec 08             	sub    $0x8,%esp
801019a2:	50                   	push   %eax
801019a3:	ff 33                	pushl  (%ebx)
801019a5:	e8 16 e7 ff ff       	call   801000c0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
801019aa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801019ad:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
801019af:	89 f0                	mov    %esi,%eax
801019b1:	25 ff 01 00 00       	and    $0x1ff,%eax
801019b6:	b9 00 02 00 00       	mov    $0x200,%ecx
801019bb:	83 c4 0c             	add    $0xc,%esp
801019be:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
801019c0:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
801019c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801019c7:	29 fb                	sub    %edi,%ebx
801019c9:	39 d9                	cmp    %ebx,%ecx
801019cb:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
801019ce:	53                   	push   %ebx
801019cf:	50                   	push   %eax
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801019d0:	01 df                	add    %ebx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
801019d2:	ff 75 e0             	pushl  -0x20(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801019d5:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
801019d7:	e8 a4 32 00 00       	call   80104c80 <memmove>
    brelse(bp);
801019dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801019df:	89 14 24             	mov    %edx,(%esp)
801019e2:	e8 e9 e7 ff ff       	call   801001d0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801019e7:	01 5d e0             	add    %ebx,-0x20(%ebp)
801019ea:	83 c4 10             	add    $0x10,%esp
801019ed:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
801019f0:	77 9e                	ja     80101990 <readi+0x60>
  }
  return n;
801019f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
801019f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019f8:	5b                   	pop    %ebx
801019f9:	5e                   	pop    %esi
801019fa:	5f                   	pop    %edi
801019fb:	5d                   	pop    %ebp
801019fc:	c3                   	ret    
801019fd:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101a00:	0f bf 40 12          	movswl 0x12(%eax),%eax
80101a04:	66 83 f8 09          	cmp    $0x9,%ax
80101a08:	77 17                	ja     80101a21 <readi+0xf1>
80101a0a:	8b 04 c5 40 11 11 80 	mov    -0x7feeeec0(,%eax,8),%eax
80101a11:	85 c0                	test   %eax,%eax
80101a13:	74 0c                	je     80101a21 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101a15:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101a18:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a1b:	5b                   	pop    %ebx
80101a1c:	5e                   	pop    %esi
80101a1d:	5f                   	pop    %edi
80101a1e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101a1f:	ff e0                	jmp    *%eax
      return -1;
80101a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a26:	eb cd                	jmp    801019f5 <readi+0xc5>
80101a28:	90                   	nop
80101a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101a30 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101a30:	55                   	push   %ebp
80101a31:	89 e5                	mov    %esp,%ebp
80101a33:	57                   	push   %edi
80101a34:	56                   	push   %esi
80101a35:	53                   	push   %ebx
80101a36:	83 ec 1c             	sub    $0x1c,%esp
80101a39:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
80101a3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101a42:	66 83 78 10 03       	cmpw   $0x3,0x10(%eax)
{
80101a47:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101a4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101a4d:	8b 75 10             	mov    0x10(%ebp),%esi
80101a50:	89 7d e0             	mov    %edi,-0x20(%ebp)
  if(ip->type == T_DEV){
80101a53:	0f 84 b7 00 00 00    	je     80101b10 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101a59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101a5c:	39 70 18             	cmp    %esi,0x18(%eax)
80101a5f:	0f 82 eb 00 00 00    	jb     80101b50 <writei+0x120>
80101a65:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101a68:	31 d2                	xor    %edx,%edx
80101a6a:	89 f8                	mov    %edi,%eax
80101a6c:	01 f0                	add    %esi,%eax
80101a6e:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101a71:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101a76:	0f 87 d4 00 00 00    	ja     80101b50 <writei+0x120>
80101a7c:	85 d2                	test   %edx,%edx
80101a7e:	0f 85 cc 00 00 00    	jne    80101b50 <writei+0x120>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101a84:	85 ff                	test   %edi,%edi
80101a86:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101a8d:	74 72                	je     80101b01 <writei+0xd1>
80101a8f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101a90:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101a93:	89 f2                	mov    %esi,%edx
80101a95:	c1 ea 09             	shr    $0x9,%edx
80101a98:	89 f8                	mov    %edi,%eax
80101a9a:	e8 21 f8 ff ff       	call   801012c0 <bmap>
80101a9f:	83 ec 08             	sub    $0x8,%esp
80101aa2:	50                   	push   %eax
80101aa3:	ff 37                	pushl  (%edi)
80101aa5:	e8 16 e6 ff ff       	call   801000c0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101aaa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101aad:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ab0:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101ab2:	89 f0                	mov    %esi,%eax
80101ab4:	b9 00 02 00 00       	mov    $0x200,%ecx
80101ab9:	83 c4 0c             	add    $0xc,%esp
80101abc:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ac1:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101ac3:	8d 44 07 18          	lea    0x18(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101ac7:	39 d9                	cmp    %ebx,%ecx
80101ac9:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101acc:	53                   	push   %ebx
80101acd:	ff 75 dc             	pushl  -0x24(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ad0:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101ad2:	50                   	push   %eax
80101ad3:	e8 a8 31 00 00       	call   80104c80 <memmove>
    log_write(bp);
80101ad8:	89 3c 24             	mov    %edi,(%esp)
80101adb:	e8 20 13 00 00       	call   80102e00 <log_write>
    brelse(bp);
80101ae0:	89 3c 24             	mov    %edi,(%esp)
80101ae3:	e8 e8 e6 ff ff       	call   801001d0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ae8:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101aeb:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101aee:	83 c4 10             	add    $0x10,%esp
80101af1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101af4:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101af7:	77 97                	ja     80101a90 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101af9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101afc:	3b 70 18             	cmp    0x18(%eax),%esi
80101aff:	77 37                	ja     80101b38 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101b01:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b07:	5b                   	pop    %ebx
80101b08:	5e                   	pop    %esi
80101b09:	5f                   	pop    %edi
80101b0a:	5d                   	pop    %ebp
80101b0b:	c3                   	ret    
80101b0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101b10:	0f bf 40 12          	movswl 0x12(%eax),%eax
80101b14:	66 83 f8 09          	cmp    $0x9,%ax
80101b18:	77 36                	ja     80101b50 <writei+0x120>
80101b1a:	8b 04 c5 44 11 11 80 	mov    -0x7feeeebc(,%eax,8),%eax
80101b21:	85 c0                	test   %eax,%eax
80101b23:	74 2b                	je     80101b50 <writei+0x120>
    return devsw[ip->major].write(ip, src, n);
80101b25:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b2b:	5b                   	pop    %ebx
80101b2c:	5e                   	pop    %esi
80101b2d:	5f                   	pop    %edi
80101b2e:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101b2f:	ff e0                	jmp    *%eax
80101b31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101b38:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101b3b:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101b3e:	89 70 18             	mov    %esi,0x18(%eax)
    iupdate(ip);
80101b41:	50                   	push   %eax
80101b42:	e8 19 fa ff ff       	call   80101560 <iupdate>
80101b47:	83 c4 10             	add    $0x10,%esp
80101b4a:	eb b5                	jmp    80101b01 <writei+0xd1>
80101b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
80101b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b55:	eb ad                	jmp    80101b04 <writei+0xd4>
80101b57:	89 f6                	mov    %esi,%esi
80101b59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101b60 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101b60:	55                   	push   %ebp
80101b61:	89 e5                	mov    %esp,%ebp
80101b63:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101b66:	6a 0e                	push   $0xe
80101b68:	ff 75 0c             	pushl  0xc(%ebp)
80101b6b:	ff 75 08             	pushl  0x8(%ebp)
80101b6e:	e8 7d 31 00 00       	call   80104cf0 <strncmp>
}
80101b73:	c9                   	leave  
80101b74:	c3                   	ret    
80101b75:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101b79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101b80 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101b80:	55                   	push   %ebp
80101b81:	89 e5                	mov    %esp,%ebp
80101b83:	57                   	push   %edi
80101b84:	56                   	push   %esi
80101b85:	53                   	push   %ebx
80101b86:	83 ec 1c             	sub    $0x1c,%esp
80101b89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101b8c:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80101b91:	0f 85 85 00 00 00    	jne    80101c1c <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101b97:	8b 53 18             	mov    0x18(%ebx),%edx
80101b9a:	31 ff                	xor    %edi,%edi
80101b9c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101b9f:	85 d2                	test   %edx,%edx
80101ba1:	74 3e                	je     80101be1 <dirlookup+0x61>
80101ba3:	90                   	nop
80101ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101ba8:	6a 10                	push   $0x10
80101baa:	57                   	push   %edi
80101bab:	56                   	push   %esi
80101bac:	53                   	push   %ebx
80101bad:	e8 7e fd ff ff       	call   80101930 <readi>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	83 f8 10             	cmp    $0x10,%eax
80101bb8:	75 55                	jne    80101c0f <dirlookup+0x8f>
      panic("dirlink read");
    if(de.inum == 0)
80101bba:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101bbf:	74 18                	je     80101bd9 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101bc1:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bc4:	83 ec 04             	sub    $0x4,%esp
80101bc7:	6a 0e                	push   $0xe
80101bc9:	50                   	push   %eax
80101bca:	ff 75 0c             	pushl  0xc(%ebp)
80101bcd:	e8 1e 31 00 00       	call   80104cf0 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101bd2:	83 c4 10             	add    $0x10,%esp
80101bd5:	85 c0                	test   %eax,%eax
80101bd7:	74 17                	je     80101bf0 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101bd9:	83 c7 10             	add    $0x10,%edi
80101bdc:	3b 7b 18             	cmp    0x18(%ebx),%edi
80101bdf:	72 c7                	jb     80101ba8 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101be4:	31 c0                	xor    %eax,%eax
}
80101be6:	5b                   	pop    %ebx
80101be7:	5e                   	pop    %esi
80101be8:	5f                   	pop    %edi
80101be9:	5d                   	pop    %ebp
80101bea:	c3                   	ret    
80101beb:	90                   	nop
80101bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(poff)
80101bf0:	8b 45 10             	mov    0x10(%ebp),%eax
80101bf3:	85 c0                	test   %eax,%eax
80101bf5:	74 05                	je     80101bfc <dirlookup+0x7c>
        *poff = off;
80101bf7:	8b 45 10             	mov    0x10(%ebp),%eax
80101bfa:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101bfc:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101c00:	8b 03                	mov    (%ebx),%eax
80101c02:	e8 e9 f5 ff ff       	call   801011f0 <iget>
}
80101c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c0a:	5b                   	pop    %ebx
80101c0b:	5e                   	pop    %esi
80101c0c:	5f                   	pop    %edi
80101c0d:	5d                   	pop    %ebp
80101c0e:	c3                   	ret    
      panic("dirlink read");
80101c0f:	83 ec 0c             	sub    $0xc,%esp
80101c12:	68 f5 79 10 80       	push   $0x801079f5
80101c17:	e8 54 e7 ff ff       	call   80100370 <panic>
    panic("dirlookup not DIR");
80101c1c:	83 ec 0c             	sub    $0xc,%esp
80101c1f:	68 e3 79 10 80       	push   $0x801079e3
80101c24:	e8 47 e7 ff ff       	call   80100370 <panic>
80101c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101c30 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101c30:	55                   	push   %ebp
80101c31:	89 e5                	mov    %esp,%ebp
80101c33:	57                   	push   %edi
80101c34:	56                   	push   %esi
80101c35:	53                   	push   %ebx
80101c36:	89 cf                	mov    %ecx,%edi
80101c38:	89 c3                	mov    %eax,%ebx
80101c3a:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101c3d:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101c40:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(*path == '/')
80101c43:	0f 84 77 01 00 00    	je     80101dc0 <namex+0x190>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80101c49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  acquire(&icache.lock);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(proc->cwd);
80101c52:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
  acquire(&icache.lock);
80101c58:	68 c0 11 11 80       	push   $0x801111c0
80101c5d:	e8 5e 2d 00 00       	call   801049c0 <acquire>
  ip->ref++;
80101c62:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101c66:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
80101c6d:	e8 0e 2f 00 00       	call   80104b80 <release>
80101c72:	83 c4 10             	add    $0x10,%esp
80101c75:	eb 0c                	jmp    80101c83 <namex+0x53>
80101c77:	89 f6                	mov    %esi,%esi
80101c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    path++;
80101c80:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101c83:	0f b6 03             	movzbl (%ebx),%eax
80101c86:	3c 2f                	cmp    $0x2f,%al
80101c88:	74 f6                	je     80101c80 <namex+0x50>
  if(*path == 0)
80101c8a:	84 c0                	test   %al,%al
80101c8c:	0f 84 f6 00 00 00    	je     80101d88 <namex+0x158>
  while(*path != '/' && *path != 0)
80101c92:	0f b6 03             	movzbl (%ebx),%eax
80101c95:	3c 2f                	cmp    $0x2f,%al
80101c97:	0f 84 bb 00 00 00    	je     80101d58 <namex+0x128>
80101c9d:	84 c0                	test   %al,%al
80101c9f:	89 da                	mov    %ebx,%edx
80101ca1:	75 11                	jne    80101cb4 <namex+0x84>
80101ca3:	e9 b0 00 00 00       	jmp    80101d58 <namex+0x128>
80101ca8:	90                   	nop
80101ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cb0:	84 c0                	test   %al,%al
80101cb2:	74 0a                	je     80101cbe <namex+0x8e>
    path++;
80101cb4:	83 c2 01             	add    $0x1,%edx
  while(*path != '/' && *path != 0)
80101cb7:	0f b6 02             	movzbl (%edx),%eax
80101cba:	3c 2f                	cmp    $0x2f,%al
80101cbc:	75 f2                	jne    80101cb0 <namex+0x80>
80101cbe:	89 d1                	mov    %edx,%ecx
80101cc0:	29 d9                	sub    %ebx,%ecx
  if(len >= DIRSIZ)
80101cc2:	83 f9 0d             	cmp    $0xd,%ecx
80101cc5:	0f 8e 91 00 00 00    	jle    80101d5c <namex+0x12c>
    memmove(name, s, DIRSIZ);
80101ccb:	83 ec 04             	sub    $0x4,%esp
80101cce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101cd1:	6a 0e                	push   $0xe
80101cd3:	53                   	push   %ebx
80101cd4:	57                   	push   %edi
80101cd5:	e8 a6 2f 00 00       	call   80104c80 <memmove>
    path++;
80101cda:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    memmove(name, s, DIRSIZ);
80101cdd:	83 c4 10             	add    $0x10,%esp
    path++;
80101ce0:	89 d3                	mov    %edx,%ebx
  while(*path == '/')
80101ce2:	80 3a 2f             	cmpb   $0x2f,(%edx)
80101ce5:	75 11                	jne    80101cf8 <namex+0xc8>
80101ce7:	89 f6                	mov    %esi,%esi
80101ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    path++;
80101cf0:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101cf3:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101cf6:	74 f8                	je     80101cf0 <namex+0xc0>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101cf8:	83 ec 0c             	sub    $0xc,%esp
80101cfb:	56                   	push   %esi
80101cfc:	e8 0f f9 ff ff       	call   80101610 <ilock>
    if(ip->type != T_DIR){
80101d01:	83 c4 10             	add    $0x10,%esp
80101d04:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
80101d09:	0f 85 91 00 00 00    	jne    80101da0 <namex+0x170>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101d0f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101d12:	85 d2                	test   %edx,%edx
80101d14:	74 09                	je     80101d1f <namex+0xef>
80101d16:	80 3b 00             	cmpb   $0x0,(%ebx)
80101d19:	0f 84 b7 00 00 00    	je     80101dd6 <namex+0x1a6>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101d1f:	83 ec 04             	sub    $0x4,%esp
80101d22:	6a 00                	push   $0x0
80101d24:	57                   	push   %edi
80101d25:	56                   	push   %esi
80101d26:	e8 55 fe ff ff       	call   80101b80 <dirlookup>
80101d2b:	83 c4 10             	add    $0x10,%esp
80101d2e:	85 c0                	test   %eax,%eax
80101d30:	74 6e                	je     80101da0 <namex+0x170>
  iunlock(ip);
80101d32:	83 ec 0c             	sub    $0xc,%esp
80101d35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101d38:	56                   	push   %esi
80101d39:	e8 e2 f9 ff ff       	call   80101720 <iunlock>
  iput(ip);
80101d3e:	89 34 24             	mov    %esi,(%esp)
80101d41:	e8 3a fa ff ff       	call   80101780 <iput>
80101d46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d49:	83 c4 10             	add    $0x10,%esp
80101d4c:	89 c6                	mov    %eax,%esi
80101d4e:	e9 30 ff ff ff       	jmp    80101c83 <namex+0x53>
80101d53:	90                   	nop
80101d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path != '/' && *path != 0)
80101d58:	89 da                	mov    %ebx,%edx
80101d5a:	31 c9                	xor    %ecx,%ecx
    memmove(name, s, len);
80101d5c:	83 ec 04             	sub    $0x4,%esp
80101d5f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101d62:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101d65:	51                   	push   %ecx
80101d66:	53                   	push   %ebx
80101d67:	57                   	push   %edi
80101d68:	e8 13 2f 00 00       	call   80104c80 <memmove>
    name[len] = 0;
80101d6d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101d70:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101d73:	83 c4 10             	add    $0x10,%esp
80101d76:	c6 04 0f 00          	movb   $0x0,(%edi,%ecx,1)
80101d7a:	89 d3                	mov    %edx,%ebx
80101d7c:	e9 61 ff ff ff       	jmp    80101ce2 <namex+0xb2>
80101d81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101d88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101d8b:	85 c0                	test   %eax,%eax
80101d8d:	75 5d                	jne    80101dec <namex+0x1bc>
    iput(ip);
    return 0;
  }
  return ip;
}
80101d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d92:	89 f0                	mov    %esi,%eax
80101d94:	5b                   	pop    %ebx
80101d95:	5e                   	pop    %esi
80101d96:	5f                   	pop    %edi
80101d97:	5d                   	pop    %ebp
80101d98:	c3                   	ret    
80101d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  iunlock(ip);
80101da0:	83 ec 0c             	sub    $0xc,%esp
80101da3:	56                   	push   %esi
80101da4:	e8 77 f9 ff ff       	call   80101720 <iunlock>
  iput(ip);
80101da9:	89 34 24             	mov    %esi,(%esp)
      return 0;
80101dac:	31 f6                	xor    %esi,%esi
  iput(ip);
80101dae:	e8 cd f9 ff ff       	call   80101780 <iput>
      return 0;
80101db3:	83 c4 10             	add    $0x10,%esp
}
80101db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101db9:	89 f0                	mov    %esi,%eax
80101dbb:	5b                   	pop    %ebx
80101dbc:	5e                   	pop    %esi
80101dbd:	5f                   	pop    %edi
80101dbe:	5d                   	pop    %ebp
80101dbf:	c3                   	ret    
    ip = iget(ROOTDEV, ROOTINO);
80101dc0:	ba 01 00 00 00       	mov    $0x1,%edx
80101dc5:	b8 01 00 00 00       	mov    $0x1,%eax
80101dca:	e8 21 f4 ff ff       	call   801011f0 <iget>
80101dcf:	89 c6                	mov    %eax,%esi
80101dd1:	e9 ad fe ff ff       	jmp    80101c83 <namex+0x53>
      iunlock(ip);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	56                   	push   %esi
80101dda:	e8 41 f9 ff ff       	call   80101720 <iunlock>
      return ip;
80101ddf:	83 c4 10             	add    $0x10,%esp
}
80101de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101de5:	89 f0                	mov    %esi,%eax
80101de7:	5b                   	pop    %ebx
80101de8:	5e                   	pop    %esi
80101de9:	5f                   	pop    %edi
80101dea:	5d                   	pop    %ebp
80101deb:	c3                   	ret    
    iput(ip);
80101dec:	83 ec 0c             	sub    $0xc,%esp
80101def:	56                   	push   %esi
    return 0;
80101df0:	31 f6                	xor    %esi,%esi
    iput(ip);
80101df2:	e8 89 f9 ff ff       	call   80101780 <iput>
    return 0;
80101df7:	83 c4 10             	add    $0x10,%esp
80101dfa:	eb 93                	jmp    80101d8f <namex+0x15f>
80101dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101e00 <dirlink>:
{
80101e00:	55                   	push   %ebp
80101e01:	89 e5                	mov    %esp,%ebp
80101e03:	57                   	push   %edi
80101e04:	56                   	push   %esi
80101e05:	53                   	push   %ebx
80101e06:	83 ec 20             	sub    $0x20,%esp
80101e09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101e0c:	6a 00                	push   $0x0
80101e0e:	ff 75 0c             	pushl  0xc(%ebp)
80101e11:	53                   	push   %ebx
80101e12:	e8 69 fd ff ff       	call   80101b80 <dirlookup>
80101e17:	83 c4 10             	add    $0x10,%esp
80101e1a:	85 c0                	test   %eax,%eax
80101e1c:	75 67                	jne    80101e85 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101e1e:	8b 7b 18             	mov    0x18(%ebx),%edi
80101e21:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e24:	85 ff                	test   %edi,%edi
80101e26:	74 29                	je     80101e51 <dirlink+0x51>
80101e28:	31 ff                	xor    %edi,%edi
80101e2a:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e2d:	eb 09                	jmp    80101e38 <dirlink+0x38>
80101e2f:	90                   	nop
80101e30:	83 c7 10             	add    $0x10,%edi
80101e33:	3b 7b 18             	cmp    0x18(%ebx),%edi
80101e36:	73 19                	jae    80101e51 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e38:	6a 10                	push   $0x10
80101e3a:	57                   	push   %edi
80101e3b:	56                   	push   %esi
80101e3c:	53                   	push   %ebx
80101e3d:	e8 ee fa ff ff       	call   80101930 <readi>
80101e42:	83 c4 10             	add    $0x10,%esp
80101e45:	83 f8 10             	cmp    $0x10,%eax
80101e48:	75 4e                	jne    80101e98 <dirlink+0x98>
    if(de.inum == 0)
80101e4a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101e4f:	75 df                	jne    80101e30 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80101e51:	8d 45 da             	lea    -0x26(%ebp),%eax
80101e54:	83 ec 04             	sub    $0x4,%esp
80101e57:	6a 0e                	push   $0xe
80101e59:	ff 75 0c             	pushl  0xc(%ebp)
80101e5c:	50                   	push   %eax
80101e5d:	e8 ee 2e 00 00       	call   80104d50 <strncpy>
  de.inum = inum;
80101e62:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e65:	6a 10                	push   $0x10
80101e67:	57                   	push   %edi
80101e68:	56                   	push   %esi
80101e69:	53                   	push   %ebx
  de.inum = inum;
80101e6a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e6e:	e8 bd fb ff ff       	call   80101a30 <writei>
80101e73:	83 c4 20             	add    $0x20,%esp
80101e76:	83 f8 10             	cmp    $0x10,%eax
80101e79:	75 2a                	jne    80101ea5 <dirlink+0xa5>
  return 0;
80101e7b:	31 c0                	xor    %eax,%eax
}
80101e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e80:	5b                   	pop    %ebx
80101e81:	5e                   	pop    %esi
80101e82:	5f                   	pop    %edi
80101e83:	5d                   	pop    %ebp
80101e84:	c3                   	ret    
    iput(ip);
80101e85:	83 ec 0c             	sub    $0xc,%esp
80101e88:	50                   	push   %eax
80101e89:	e8 f2 f8 ff ff       	call   80101780 <iput>
    return -1;
80101e8e:	83 c4 10             	add    $0x10,%esp
80101e91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e96:	eb e5                	jmp    80101e7d <dirlink+0x7d>
      panic("dirlink read");
80101e98:	83 ec 0c             	sub    $0xc,%esp
80101e9b:	68 f5 79 10 80       	push   $0x801079f5
80101ea0:	e8 cb e4 ff ff       	call   80100370 <panic>
    panic("dirlink");
80101ea5:	83 ec 0c             	sub    $0xc,%esp
80101ea8:	68 9a 81 10 80       	push   $0x8010819a
80101ead:	e8 be e4 ff ff       	call   80100370 <panic>
80101eb2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ec0 <namei>:

struct inode*
namei(char *path)
{
80101ec0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101ec1:	31 d2                	xor    %edx,%edx
{
80101ec3:	89 e5                	mov    %esp,%ebp
80101ec5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101ece:	e8 5d fd ff ff       	call   80101c30 <namex>
}
80101ed3:	c9                   	leave  
80101ed4:	c3                   	ret    
80101ed5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ee0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101ee0:	55                   	push   %ebp
  return namex(path, 1, name);
80101ee1:	ba 01 00 00 00       	mov    $0x1,%edx
{
80101ee6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80101ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101eee:	5d                   	pop    %ebp
  return namex(path, 1, name);
80101eef:	e9 3c fd ff ff       	jmp    80101c30 <namex>
80101ef4:	66 90                	xchg   %ax,%ax
80101ef6:	66 90                	xchg   %ax,%ax
80101ef8:	66 90                	xchg   %ax,%ax
80101efa:	66 90                	xchg   %ax,%ax
80101efc:	66 90                	xchg   %ax,%ax
80101efe:	66 90                	xchg   %ax,%ax

80101f00 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101f00:	55                   	push   %ebp
80101f01:	89 e5                	mov    %esp,%ebp
80101f03:	57                   	push   %edi
80101f04:	56                   	push   %esi
80101f05:	53                   	push   %ebx
80101f06:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80101f09:	85 c0                	test   %eax,%eax
80101f0b:	0f 84 b4 00 00 00    	je     80101fc5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101f11:	8b 58 08             	mov    0x8(%eax),%ebx
80101f14:	89 c6                	mov    %eax,%esi
80101f16:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101f1c:	0f 87 96 00 00 00    	ja     80101fb8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101f22:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80101f27:	89 f6                	mov    %esi,%esi
80101f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80101f30:	89 ca                	mov    %ecx,%edx
80101f32:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101f33:	83 e0 c0             	and    $0xffffffc0,%eax
80101f36:	3c 40                	cmp    $0x40,%al
80101f38:	75 f6                	jne    80101f30 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101f3a:	31 ff                	xor    %edi,%edi
80101f3c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101f41:	89 f8                	mov    %edi,%eax
80101f43:	ee                   	out    %al,(%dx)
80101f44:	b8 01 00 00 00       	mov    $0x1,%eax
80101f49:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101f4e:	ee                   	out    %al,(%dx)
80101f4f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101f54:	89 d8                	mov    %ebx,%eax
80101f56:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101f57:	89 d8                	mov    %ebx,%eax
80101f59:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101f5e:	c1 f8 08             	sar    $0x8,%eax
80101f61:	ee                   	out    %al,(%dx)
80101f62:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101f67:	89 f8                	mov    %edi,%eax
80101f69:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101f6a:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101f6e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101f73:	c1 e0 04             	shl    $0x4,%eax
80101f76:	83 e0 10             	and    $0x10,%eax
80101f79:	83 c8 e0             	or     $0xffffffe0,%eax
80101f7c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101f7d:	f6 06 04             	testb  $0x4,(%esi)
80101f80:	75 16                	jne    80101f98 <idestart+0x98>
80101f82:	b8 20 00 00 00       	mov    $0x20,%eax
80101f87:	89 ca                	mov    %ecx,%edx
80101f89:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f8d:	5b                   	pop    %ebx
80101f8e:	5e                   	pop    %esi
80101f8f:	5f                   	pop    %edi
80101f90:	5d                   	pop    %ebp
80101f91:	c3                   	ret    
80101f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101f98:	b8 30 00 00 00       	mov    $0x30,%eax
80101f9d:	89 ca                	mov    %ecx,%edx
80101f9f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80101fa0:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80101fa5:	83 c6 18             	add    $0x18,%esi
80101fa8:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101fad:	fc                   	cld    
80101fae:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
80101fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fb3:	5b                   	pop    %ebx
80101fb4:	5e                   	pop    %esi
80101fb5:	5f                   	pop    %edi
80101fb6:	5d                   	pop    %ebp
80101fb7:	c3                   	ret    
    panic("incorrect blockno");
80101fb8:	83 ec 0c             	sub    $0xc,%esp
80101fbb:	68 69 7a 10 80       	push   $0x80107a69
80101fc0:	e8 ab e3 ff ff       	call   80100370 <panic>
    panic("idestart");
80101fc5:	83 ec 0c             	sub    $0xc,%esp
80101fc8:	68 60 7a 10 80       	push   $0x80107a60
80101fcd:	e8 9e e3 ff ff       	call   80100370 <panic>
80101fd2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101fd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101fe0 <ideinit>:
{
80101fe0:	55                   	push   %ebp
80101fe1:	89 e5                	mov    %esp,%ebp
80101fe3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101fe6:	68 7b 7a 10 80       	push   $0x80107a7b
80101feb:	68 80 b5 10 80       	push   $0x8010b580
80101ff0:	e8 ab 29 00 00       	call   801049a0 <initlock>
  picenable(IRQ_IDE);
80101ff5:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80101ffc:	e8 ff 12 00 00       	call   80103300 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102001:	58                   	pop    %eax
80102002:	a1 c0 28 11 80       	mov    0x801128c0,%eax
80102007:	5a                   	pop    %edx
80102008:	83 e8 01             	sub    $0x1,%eax
8010200b:	50                   	push   %eax
8010200c:	6a 0e                	push   $0xe
8010200e:	e8 bd 02 00 00       	call   801022d0 <ioapicenable>
80102013:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102016:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010201b:	90                   	nop
8010201c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102020:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102021:	83 e0 c0             	and    $0xffffffc0,%eax
80102024:	3c 40                	cmp    $0x40,%al
80102026:	75 f8                	jne    80102020 <ideinit+0x40>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102028:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010202d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102032:	ee                   	out    %al,(%dx)
80102033:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102038:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010203d:	eb 06                	jmp    80102045 <ideinit+0x65>
8010203f:	90                   	nop
  for(i=0; i<1000; i++){
80102040:	83 e9 01             	sub    $0x1,%ecx
80102043:	74 0f                	je     80102054 <ideinit+0x74>
80102045:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102046:	84 c0                	test   %al,%al
80102048:	74 f6                	je     80102040 <ideinit+0x60>
      havedisk1 = 1;
8010204a:	c7 05 60 b5 10 80 01 	movl   $0x1,0x8010b560
80102051:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102054:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102059:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010205e:	ee                   	out    %al,(%dx)
}
8010205f:	c9                   	leave  
80102060:	c3                   	ret    
80102061:	eb 0d                	jmp    80102070 <ideintr>
80102063:	90                   	nop
80102064:	90                   	nop
80102065:	90                   	nop
80102066:	90                   	nop
80102067:	90                   	nop
80102068:	90                   	nop
80102069:	90                   	nop
8010206a:	90                   	nop
8010206b:	90                   	nop
8010206c:	90                   	nop
8010206d:	90                   	nop
8010206e:	90                   	nop
8010206f:	90                   	nop

80102070 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102070:	55                   	push   %ebp
80102071:	89 e5                	mov    %esp,%ebp
80102073:	57                   	push   %edi
80102074:	56                   	push   %esi
80102075:	53                   	push   %ebx
80102076:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102079:	68 80 b5 10 80       	push   $0x8010b580
8010207e:	e8 3d 29 00 00       	call   801049c0 <acquire>
  if((b = idequeue) == 0){
80102083:	8b 1d 64 b5 10 80    	mov    0x8010b564,%ebx
80102089:	83 c4 10             	add    $0x10,%esp
8010208c:	85 db                	test   %ebx,%ebx
8010208e:	74 67                	je     801020f7 <ideintr+0x87>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
80102090:	8b 43 14             	mov    0x14(%ebx),%eax
80102093:	a3 64 b5 10 80       	mov    %eax,0x8010b564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102098:	8b 3b                	mov    (%ebx),%edi
8010209a:	f7 c7 04 00 00 00    	test   $0x4,%edi
801020a0:	75 31                	jne    801020d3 <ideintr+0x63>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801020a2:	ba f7 01 00 00       	mov    $0x1f7,%edx
801020a7:	89 f6                	mov    %esi,%esi
801020a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801020b0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801020b1:	89 c6                	mov    %eax,%esi
801020b3:	83 e6 c0             	and    $0xffffffc0,%esi
801020b6:	89 f1                	mov    %esi,%ecx
801020b8:	80 f9 40             	cmp    $0x40,%cl
801020bb:	75 f3                	jne    801020b0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801020bd:	a8 21                	test   $0x21,%al
801020bf:	75 12                	jne    801020d3 <ideintr+0x63>
    insl(0x1f0, b->data, BSIZE/4);
801020c1:	8d 7b 18             	lea    0x18(%ebx),%edi
  asm volatile("cld; rep insl" :
801020c4:	b9 80 00 00 00       	mov    $0x80,%ecx
801020c9:	ba f0 01 00 00       	mov    $0x1f0,%edx
801020ce:	fc                   	cld    
801020cf:	f3 6d                	rep insl (%dx),%es:(%edi)
801020d1:	8b 3b                	mov    (%ebx),%edi

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
801020d3:	83 e7 fb             	and    $0xfffffffb,%edi
  wakeup(b);
801020d6:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801020d9:	89 f9                	mov    %edi,%ecx
801020db:	83 c9 02             	or     $0x2,%ecx
801020de:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
801020e0:	53                   	push   %ebx
801020e1:	e8 6a 21 00 00       	call   80104250 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801020e6:	a1 64 b5 10 80       	mov    0x8010b564,%eax
801020eb:	83 c4 10             	add    $0x10,%esp
801020ee:	85 c0                	test   %eax,%eax
801020f0:	74 05                	je     801020f7 <ideintr+0x87>
    idestart(idequeue);
801020f2:	e8 09 fe ff ff       	call   80101f00 <idestart>
    release(&idelock);
801020f7:	83 ec 0c             	sub    $0xc,%esp
801020fa:	68 80 b5 10 80       	push   $0x8010b580
801020ff:	e8 7c 2a 00 00       	call   80104b80 <release>

  release(&idelock);
}
80102104:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102107:	5b                   	pop    %ebx
80102108:	5e                   	pop    %esi
80102109:	5f                   	pop    %edi
8010210a:	5d                   	pop    %ebp
8010210b:	c3                   	ret    
8010210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102110 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102110:	55                   	push   %ebp
80102111:	89 e5                	mov    %esp,%ebp
80102113:	53                   	push   %ebx
80102114:	83 ec 04             	sub    $0x4,%esp
80102117:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010211a:	8b 03                	mov    (%ebx),%eax
8010211c:	a8 01                	test   $0x1,%al
8010211e:	0f 84 c0 00 00 00    	je     801021e4 <iderw+0xd4>
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102124:	83 e0 06             	and    $0x6,%eax
80102127:	83 f8 02             	cmp    $0x2,%eax
8010212a:	0f 84 a7 00 00 00    	je     801021d7 <iderw+0xc7>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80102130:	8b 53 04             	mov    0x4(%ebx),%edx
80102133:	85 d2                	test   %edx,%edx
80102135:	74 0d                	je     80102144 <iderw+0x34>
80102137:	a1 60 b5 10 80       	mov    0x8010b560,%eax
8010213c:	85 c0                	test   %eax,%eax
8010213e:	0f 84 ad 00 00 00    	je     801021f1 <iderw+0xe1>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102144:	83 ec 0c             	sub    $0xc,%esp
80102147:	68 80 b5 10 80       	push   $0x8010b580
8010214c:	e8 6f 28 00 00       	call   801049c0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102151:	8b 15 64 b5 10 80    	mov    0x8010b564,%edx
80102157:	83 c4 10             	add    $0x10,%esp
  b->qnext = 0;
8010215a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102161:	85 d2                	test   %edx,%edx
80102163:	75 0d                	jne    80102172 <iderw+0x62>
80102165:	eb 69                	jmp    801021d0 <iderw+0xc0>
80102167:	89 f6                	mov    %esi,%esi
80102169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80102170:	89 c2                	mov    %eax,%edx
80102172:	8b 42 14             	mov    0x14(%edx),%eax
80102175:	85 c0                	test   %eax,%eax
80102177:	75 f7                	jne    80102170 <iderw+0x60>
80102179:	83 c2 14             	add    $0x14,%edx
    ;
  *pp = b;
8010217c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010217e:	39 1d 64 b5 10 80    	cmp    %ebx,0x8010b564
80102184:	74 3a                	je     801021c0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102186:	8b 03                	mov    (%ebx),%eax
80102188:	83 e0 06             	and    $0x6,%eax
8010218b:	83 f8 02             	cmp    $0x2,%eax
8010218e:	74 1b                	je     801021ab <iderw+0x9b>
    sleep(b, &idelock);
80102190:	83 ec 08             	sub    $0x8,%esp
80102193:	68 80 b5 10 80       	push   $0x8010b580
80102198:	53                   	push   %ebx
80102199:	e8 c2 1e 00 00       	call   80104060 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010219e:	8b 03                	mov    (%ebx),%eax
801021a0:	83 c4 10             	add    $0x10,%esp
801021a3:	83 e0 06             	and    $0x6,%eax
801021a6:	83 f8 02             	cmp    $0x2,%eax
801021a9:	75 e5                	jne    80102190 <iderw+0x80>
  }

  release(&idelock);
801021ab:	c7 45 08 80 b5 10 80 	movl   $0x8010b580,0x8(%ebp)
}
801021b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801021b5:	c9                   	leave  
  release(&idelock);
801021b6:	e9 c5 29 00 00       	jmp    80104b80 <release>
801021bb:	90                   	nop
801021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    idestart(b);
801021c0:	89 d8                	mov    %ebx,%eax
801021c2:	e8 39 fd ff ff       	call   80101f00 <idestart>
801021c7:	eb bd                	jmp    80102186 <iderw+0x76>
801021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801021d0:	ba 64 b5 10 80       	mov    $0x8010b564,%edx
801021d5:	eb a5                	jmp    8010217c <iderw+0x6c>
    panic("iderw: nothing to do");
801021d7:	83 ec 0c             	sub    $0xc,%esp
801021da:	68 93 7a 10 80       	push   $0x80107a93
801021df:	e8 8c e1 ff ff       	call   80100370 <panic>
    panic("iderw: buf not busy");
801021e4:	83 ec 0c             	sub    $0xc,%esp
801021e7:	68 7f 7a 10 80       	push   $0x80107a7f
801021ec:	e8 7f e1 ff ff       	call   80100370 <panic>
    panic("iderw: ide disk 1 not present");
801021f1:	83 ec 0c             	sub    $0xc,%esp
801021f4:	68 a8 7a 10 80       	push   $0x80107aa8
801021f9:	e8 72 e1 ff ff       	call   80100370 <panic>
801021fe:	66 90                	xchg   %ax,%ax

80102200 <ioapicinit>:
void
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
80102200:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80102205:	85 c0                	test   %eax,%eax
80102207:	0f 84 b3 00 00 00    	je     801022c0 <ioapicinit+0xc0>
{
8010220d:	55                   	push   %ebp
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010220e:	c7 05 94 21 11 80 00 	movl   $0xfec00000,0x80112194
80102215:	00 c0 fe 
{
80102218:	89 e5                	mov    %esp,%ebp
8010221a:	56                   	push   %esi
8010221b:	53                   	push   %ebx
  ioapic->reg = reg;
8010221c:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102223:	00 00 00 
  return ioapic->data;
80102226:	a1 94 21 11 80       	mov    0x80112194,%eax
8010222b:	8b 58 10             	mov    0x10(%eax),%ebx
  ioapic->reg = reg;
8010222e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return ioapic->data;
80102234:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010223a:	0f b6 15 c0 22 11 80 	movzbl 0x801122c0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102241:	c1 eb 10             	shr    $0x10,%ebx
  return ioapic->data;
80102244:	8b 41 10             	mov    0x10(%ecx),%eax
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102247:	0f b6 db             	movzbl %bl,%ebx
  id = ioapicread(REG_ID) >> 24;
8010224a:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
8010224d:	39 c2                	cmp    %eax,%edx
8010224f:	75 4f                	jne    801022a0 <ioapicinit+0xa0>
80102251:	83 c3 21             	add    $0x21,%ebx
{
80102254:	ba 10 00 00 00       	mov    $0x10,%edx
80102259:	b8 20 00 00 00       	mov    $0x20,%eax
8010225e:	66 90                	xchg   %ax,%ax
  ioapic->reg = reg;
80102260:	89 11                	mov    %edx,(%ecx)
  ioapic->data = data;
80102262:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102268:	89 c6                	mov    %eax,%esi
8010226a:	81 ce 00 00 01 00    	or     $0x10000,%esi
80102270:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
80102273:	89 71 10             	mov    %esi,0x10(%ecx)
80102276:	8d 72 01             	lea    0x1(%edx),%esi
80102279:	83 c2 02             	add    $0x2,%edx
  for(i = 0; i <= maxintr; i++){
8010227c:	39 d8                	cmp    %ebx,%eax
  ioapic->reg = reg;
8010227e:	89 31                	mov    %esi,(%ecx)
  ioapic->data = data;
80102280:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
80102286:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010228d:	75 d1                	jne    80102260 <ioapicinit+0x60>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010228f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102292:	5b                   	pop    %ebx
80102293:	5e                   	pop    %esi
80102294:	5d                   	pop    %ebp
80102295:	c3                   	ret    
80102296:	8d 76 00             	lea    0x0(%esi),%esi
80102299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801022a0:	83 ec 0c             	sub    $0xc,%esp
801022a3:	68 c8 7a 10 80       	push   $0x80107ac8
801022a8:	e8 93 e3 ff ff       	call   80100640 <cprintf>
801022ad:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
801022b3:	83 c4 10             	add    $0x10,%esp
801022b6:	eb 99                	jmp    80102251 <ioapicinit+0x51>
801022b8:	90                   	nop
801022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022c0:	f3 c3                	repz ret 
801022c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801022d0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
801022d0:	8b 15 c4 22 11 80    	mov    0x801122c4,%edx
{
801022d6:	55                   	push   %ebp
801022d7:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801022d9:	85 d2                	test   %edx,%edx
{
801022db:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
801022de:	74 2b                	je     8010230b <ioapicenable+0x3b>
  ioapic->reg = reg;
801022e0:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801022e6:	8d 50 20             	lea    0x20(%eax),%edx
801022e9:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801022ed:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801022ef:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801022f5:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801022f8:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801022fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801022fe:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102300:	a1 94 21 11 80       	mov    0x80112194,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102305:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
80102308:	89 50 10             	mov    %edx,0x10(%eax)
}
8010230b:	5d                   	pop    %ebp
8010230c:	c3                   	ret    
8010230d:	66 90                	xchg   %ax,%ax
8010230f:	90                   	nop

80102310 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102310:	55                   	push   %ebp
80102311:	89 e5                	mov    %esp,%ebp
80102313:	53                   	push   %ebx
80102314:	83 ec 04             	sub    $0x4,%esp
80102317:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010231a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102320:	75 70                	jne    80102392 <kfree+0x82>
80102322:	81 fb 68 7b 11 80    	cmp    $0x80117b68,%ebx
80102328:	72 68                	jb     80102392 <kfree+0x82>
8010232a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102330:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102335:	77 5b                	ja     80102392 <kfree+0x82>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102337:	83 ec 04             	sub    $0x4,%esp
8010233a:	68 00 10 00 00       	push   $0x1000
8010233f:	6a 01                	push   $0x1
80102341:	53                   	push   %ebx
80102342:	e8 89 28 00 00       	call   80104bd0 <memset>

  if(kmem.use_lock)
80102347:	8b 15 d4 21 11 80    	mov    0x801121d4,%edx
8010234d:	83 c4 10             	add    $0x10,%esp
80102350:	85 d2                	test   %edx,%edx
80102352:	75 2c                	jne    80102380 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102354:	a1 d8 21 11 80       	mov    0x801121d8,%eax
80102359:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010235b:	a1 d4 21 11 80       	mov    0x801121d4,%eax
  kmem.freelist = r;
80102360:	89 1d d8 21 11 80    	mov    %ebx,0x801121d8
  if(kmem.use_lock)
80102366:	85 c0                	test   %eax,%eax
80102368:	75 06                	jne    80102370 <kfree+0x60>
    release(&kmem.lock);
}
8010236a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010236d:	c9                   	leave  
8010236e:	c3                   	ret    
8010236f:	90                   	nop
    release(&kmem.lock);
80102370:	c7 45 08 a0 21 11 80 	movl   $0x801121a0,0x8(%ebp)
}
80102377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010237a:	c9                   	leave  
    release(&kmem.lock);
8010237b:	e9 00 28 00 00       	jmp    80104b80 <release>
    acquire(&kmem.lock);
80102380:	83 ec 0c             	sub    $0xc,%esp
80102383:	68 a0 21 11 80       	push   $0x801121a0
80102388:	e8 33 26 00 00       	call   801049c0 <acquire>
8010238d:	83 c4 10             	add    $0x10,%esp
80102390:	eb c2                	jmp    80102354 <kfree+0x44>
    panic("kfree");
80102392:	83 ec 0c             	sub    $0xc,%esp
80102395:	68 fa 7a 10 80       	push   $0x80107afa
8010239a:	e8 d1 df ff ff       	call   80100370 <panic>
8010239f:	90                   	nop

801023a0 <freerange>:
{
801023a0:	55                   	push   %ebp
801023a1:	89 e5                	mov    %esp,%ebp
801023a3:	56                   	push   %esi
801023a4:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
{
801023a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
801023ab:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801023b1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023b7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801023bd:	39 de                	cmp    %ebx,%esi
801023bf:	72 23                	jb     801023e4 <freerange+0x44>
801023c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801023c8:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
801023ce:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801023d7:	50                   	push   %eax
801023d8:	e8 33 ff ff ff       	call   80102310 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023dd:	83 c4 10             	add    $0x10,%esp
801023e0:	39 f3                	cmp    %esi,%ebx
801023e2:	76 e4                	jbe    801023c8 <freerange+0x28>
}
801023e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801023e7:	5b                   	pop    %ebx
801023e8:	5e                   	pop    %esi
801023e9:	5d                   	pop    %ebp
801023ea:	c3                   	ret    
801023eb:	90                   	nop
801023ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801023f0 <kinit1>:
{
801023f0:	55                   	push   %ebp
801023f1:	89 e5                	mov    %esp,%ebp
801023f3:	56                   	push   %esi
801023f4:	53                   	push   %ebx
801023f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
801023f8:	83 ec 08             	sub    $0x8,%esp
801023fb:	68 00 7b 10 80       	push   $0x80107b00
80102400:	68 a0 21 11 80       	push   $0x801121a0
80102405:	e8 96 25 00 00       	call   801049a0 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010240a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010240d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102410:	c7 05 d4 21 11 80 00 	movl   $0x0,0x801121d4
80102417:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010241a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102420:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102426:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010242c:	39 de                	cmp    %ebx,%esi
8010242e:	72 1c                	jb     8010244c <kinit1+0x5c>
    kfree(p);
80102430:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
80102436:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102439:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010243f:	50                   	push   %eax
80102440:	e8 cb fe ff ff       	call   80102310 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102445:	83 c4 10             	add    $0x10,%esp
80102448:	39 de                	cmp    %ebx,%esi
8010244a:	73 e4                	jae    80102430 <kinit1+0x40>
}
8010244c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010244f:	5b                   	pop    %ebx
80102450:	5e                   	pop    %esi
80102451:	5d                   	pop    %ebp
80102452:	c3                   	ret    
80102453:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102459:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102460 <kinit2>:
{
80102460:	55                   	push   %ebp
80102461:	89 e5                	mov    %esp,%ebp
80102463:	56                   	push   %esi
80102464:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102465:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102468:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010246b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102471:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102477:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010247d:	39 de                	cmp    %ebx,%esi
8010247f:	72 23                	jb     801024a4 <kinit2+0x44>
80102481:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102488:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
8010248e:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102491:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102497:	50                   	push   %eax
80102498:	e8 73 fe ff ff       	call   80102310 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010249d:	83 c4 10             	add    $0x10,%esp
801024a0:	39 de                	cmp    %ebx,%esi
801024a2:	73 e4                	jae    80102488 <kinit2+0x28>
  kmem.use_lock = 1;
801024a4:	c7 05 d4 21 11 80 01 	movl   $0x1,0x801121d4
801024ab:	00 00 00 
}
801024ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
801024b1:	5b                   	pop    %ebx
801024b2:	5e                   	pop    %esi
801024b3:	5d                   	pop    %ebp
801024b4:	c3                   	ret    
801024b5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801024b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801024c0 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
801024c0:	a1 d4 21 11 80       	mov    0x801121d4,%eax
801024c5:	85 c0                	test   %eax,%eax
801024c7:	75 1f                	jne    801024e8 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
801024c9:	a1 d8 21 11 80       	mov    0x801121d8,%eax
  if(r)
801024ce:	85 c0                	test   %eax,%eax
801024d0:	74 0e                	je     801024e0 <kalloc+0x20>
    kmem.freelist = r->next;
801024d2:	8b 10                	mov    (%eax),%edx
801024d4:	89 15 d8 21 11 80    	mov    %edx,0x801121d8
801024da:	c3                   	ret    
801024db:	90                   	nop
801024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}
801024e0:	f3 c3                	repz ret 
801024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
801024e8:	55                   	push   %ebp
801024e9:	89 e5                	mov    %esp,%ebp
801024eb:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
801024ee:	68 a0 21 11 80       	push   $0x801121a0
801024f3:	e8 c8 24 00 00       	call   801049c0 <acquire>
  r = kmem.freelist;
801024f8:	a1 d8 21 11 80       	mov    0x801121d8,%eax
  if(r)
801024fd:	83 c4 10             	add    $0x10,%esp
80102500:	8b 15 d4 21 11 80    	mov    0x801121d4,%edx
80102506:	85 c0                	test   %eax,%eax
80102508:	74 08                	je     80102512 <kalloc+0x52>
    kmem.freelist = r->next;
8010250a:	8b 08                	mov    (%eax),%ecx
8010250c:	89 0d d8 21 11 80    	mov    %ecx,0x801121d8
  if(kmem.use_lock)
80102512:	85 d2                	test   %edx,%edx
80102514:	74 16                	je     8010252c <kalloc+0x6c>
    release(&kmem.lock);
80102516:	83 ec 0c             	sub    $0xc,%esp
80102519:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010251c:	68 a0 21 11 80       	push   $0x801121a0
80102521:	e8 5a 26 00 00       	call   80104b80 <release>
  return (char*)r;
80102526:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
80102529:	83 c4 10             	add    $0x10,%esp
}
8010252c:	c9                   	leave  
8010252d:	c3                   	ret    
8010252e:	66 90                	xchg   %ax,%ax

80102530 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102530:	ba 64 00 00 00       	mov    $0x64,%edx
80102535:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102536:	a8 01                	test   $0x1,%al
80102538:	0f 84 c2 00 00 00    	je     80102600 <kbdgetc+0xd0>
8010253e:	ba 60 00 00 00       	mov    $0x60,%edx
80102543:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102544:	0f b6 d0             	movzbl %al,%edx
80102547:	8b 0d b4 b5 10 80    	mov    0x8010b5b4,%ecx

  if(data == 0xE0){
8010254d:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102553:	0f 84 7f 00 00 00    	je     801025d8 <kbdgetc+0xa8>
{
80102559:	55                   	push   %ebp
8010255a:	89 e5                	mov    %esp,%ebp
8010255c:	53                   	push   %ebx
8010255d:	89 cb                	mov    %ecx,%ebx
8010255f:	83 e3 40             	and    $0x40,%ebx
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102562:	84 c0                	test   %al,%al
80102564:	78 4a                	js     801025b0 <kbdgetc+0x80>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102566:	85 db                	test   %ebx,%ebx
80102568:	74 09                	je     80102573 <kbdgetc+0x43>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010256a:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
8010256d:	83 e1 bf             	and    $0xffffffbf,%ecx
    data |= 0x80;
80102570:	0f b6 d0             	movzbl %al,%edx
  }

  shift |= shiftcode[data];
80102573:	0f b6 82 40 7c 10 80 	movzbl -0x7fef83c0(%edx),%eax
8010257a:	09 c1                	or     %eax,%ecx
  shift ^= togglecode[data];
8010257c:	0f b6 82 40 7b 10 80 	movzbl -0x7fef84c0(%edx),%eax
80102583:	31 c1                	xor    %eax,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
80102585:	89 c8                	mov    %ecx,%eax
  shift ^= togglecode[data];
80102587:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010258d:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102590:	83 e1 08             	and    $0x8,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
80102593:	8b 04 85 20 7b 10 80 	mov    -0x7fef84e0(,%eax,4),%eax
8010259a:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010259e:	74 31                	je     801025d1 <kbdgetc+0xa1>
    if('a' <= c && c <= 'z')
801025a0:	8d 50 9f             	lea    -0x61(%eax),%edx
801025a3:	83 fa 19             	cmp    $0x19,%edx
801025a6:	77 40                	ja     801025e8 <kbdgetc+0xb8>
      c += 'A' - 'a';
801025a8:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801025ab:	5b                   	pop    %ebx
801025ac:	5d                   	pop    %ebp
801025ad:	c3                   	ret    
801025ae:	66 90                	xchg   %ax,%ax
    data = (shift & E0ESC ? data : data & 0x7F);
801025b0:	83 e0 7f             	and    $0x7f,%eax
801025b3:	85 db                	test   %ebx,%ebx
801025b5:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801025b8:	0f b6 82 40 7c 10 80 	movzbl -0x7fef83c0(%edx),%eax
801025bf:	83 c8 40             	or     $0x40,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	f7 d0                	not    %eax
801025c7:	21 c1                	and    %eax,%ecx
    return 0;
801025c9:	31 c0                	xor    %eax,%eax
    shift &= ~(shiftcode[data] | E0ESC);
801025cb:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
}
801025d1:	5b                   	pop    %ebx
801025d2:	5d                   	pop    %ebp
801025d3:	c3                   	ret    
801025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    shift |= E0ESC;
801025d8:	83 c9 40             	or     $0x40,%ecx
    return 0;
801025db:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
801025dd:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
    return 0;
801025e3:	c3                   	ret    
801025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else if('A' <= c && c <= 'Z')
801025e8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
801025eb:	8d 50 20             	lea    0x20(%eax),%edx
}
801025ee:	5b                   	pop    %ebx
      c += 'a' - 'A';
801025ef:	83 f9 1a             	cmp    $0x1a,%ecx
801025f2:	0f 42 c2             	cmovb  %edx,%eax
}
801025f5:	5d                   	pop    %ebp
801025f6:	c3                   	ret    
801025f7:	89 f6                	mov    %esi,%esi
801025f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80102600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102605:	c3                   	ret    
80102606:	8d 76 00             	lea    0x0(%esi),%esi
80102609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102610 <kbdintr>:

void
kbdintr(void)
{
80102610:	55                   	push   %ebp
80102611:	89 e5                	mov    %esp,%ebp
80102613:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102616:	68 30 25 10 80       	push   $0x80102530
8010261b:	e8 d0 e1 ff ff       	call   801007f0 <consoleintr>
}
80102620:	83 c4 10             	add    $0x10,%esp
80102623:	c9                   	leave  
80102624:	c3                   	ret    
80102625:	66 90                	xchg   %ax,%ax
80102627:	66 90                	xchg   %ax,%ax
80102629:	66 90                	xchg   %ax,%ax
8010262b:	66 90                	xchg   %ax,%ax
8010262d:	66 90                	xchg   %ax,%ax
8010262f:	90                   	nop

80102630 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
  if(!lapic)
80102630:	a1 dc 21 11 80       	mov    0x801121dc,%eax
{
80102635:	55                   	push   %ebp
80102636:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102638:	85 c0                	test   %eax,%eax
8010263a:	0f 84 c8 00 00 00    	je     80102708 <lapicinit+0xd8>
  lapic[index] = value;
80102640:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102647:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010264a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010264d:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102654:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102657:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010265a:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102661:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102664:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102667:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010266e:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102671:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102674:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
8010267b:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010267e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102681:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102688:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010268b:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010268e:	8b 50 30             	mov    0x30(%eax),%edx
80102691:	c1 ea 10             	shr    $0x10,%edx
80102694:	80 fa 03             	cmp    $0x3,%dl
80102697:	77 77                	ja     80102710 <lapicinit+0xe0>
  lapic[index] = value;
80102699:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
801026a0:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026a3:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026a6:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801026ad:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026b0:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026b3:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801026ba:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026bd:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026c0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801026c7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026ca:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026cd:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
801026d4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026d7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026da:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801026e1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801026e4:	8b 50 20             	mov    0x20(%eax),%edx
801026e7:	89 f6                	mov    %esi,%esi
801026e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801026f0:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801026f6:	80 e6 10             	and    $0x10,%dh
801026f9:	75 f5                	jne    801026f0 <lapicinit+0xc0>
  lapic[index] = value;
801026fb:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102702:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102705:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102708:	5d                   	pop    %ebp
80102709:	c3                   	ret    
8010270a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  lapic[index] = value;
80102710:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102717:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010271a:	8b 50 20             	mov    0x20(%eax),%edx
8010271d:	e9 77 ff ff ff       	jmp    80102699 <lapicinit+0x69>
80102722:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102729:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102730 <cpunum>:

int
  cpunum(void)
{
80102730:	55                   	push   %ebp
80102731:	89 e5                	mov    %esp,%ebp
80102733:	56                   	push   %esi
80102734:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102735:	9c                   	pushf  
80102736:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102737:	f6 c4 02             	test   $0x2,%ah
8010273a:	74 12                	je     8010274e <cpunum+0x1e>
    static int n;
    if(n++ == 0)
8010273c:	a1 b8 b5 10 80       	mov    0x8010b5b8,%eax
80102741:	8d 50 01             	lea    0x1(%eax),%edx
80102744:	85 c0                	test   %eax,%eax
80102746:	89 15 b8 b5 10 80    	mov    %edx,0x8010b5b8
8010274c:	74 62                	je     801027b0 <cpunum+0x80>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if (!lapic)
8010274e:	a1 dc 21 11 80       	mov    0x801121dc,%eax
80102753:	85 c0                	test   %eax,%eax
80102755:	74 49                	je     801027a0 <cpunum+0x70>
    return 0;

  apicid = lapic[ID] >> 24;
80102757:	8b 58 20             	mov    0x20(%eax),%ebx
  for (i = 0; i < ncpu; ++i) {
8010275a:	8b 35 c0 28 11 80    	mov    0x801128c0,%esi
  apicid = lapic[ID] >> 24;
80102760:	c1 eb 18             	shr    $0x18,%ebx
  for (i = 0; i < ncpu; ++i) {
80102763:	85 f6                	test   %esi,%esi
80102765:	7e 5e                	jle    801027c5 <cpunum+0x95>
    if (cpus[i].apicid == apicid)
80102767:	0f b6 05 e0 22 11 80 	movzbl 0x801122e0,%eax
8010276e:	39 c3                	cmp    %eax,%ebx
80102770:	74 2e                	je     801027a0 <cpunum+0x70>
80102772:	ba 9c 23 11 80       	mov    $0x8011239c,%edx
  for (i = 0; i < ncpu; ++i) {
80102777:	31 c0                	xor    %eax,%eax
80102779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102780:	83 c0 01             	add    $0x1,%eax
80102783:	39 f0                	cmp    %esi,%eax
80102785:	74 3e                	je     801027c5 <cpunum+0x95>
    if (cpus[i].apicid == apicid)
80102787:	0f b6 0a             	movzbl (%edx),%ecx
8010278a:	81 c2 bc 00 00 00    	add    $0xbc,%edx
80102790:	39 d9                	cmp    %ebx,%ecx
80102792:	75 ec                	jne    80102780 <cpunum+0x50>
      return i;
  }
  panic("unknown apicid\n");
}
80102794:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102797:	5b                   	pop    %ebx
80102798:	5e                   	pop    %esi
80102799:	5d                   	pop    %ebp
8010279a:	c3                   	ret    
8010279b:	90                   	nop
8010279c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801027a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
801027a3:	31 c0                	xor    %eax,%eax
}
801027a5:	5b                   	pop    %ebx
801027a6:	5e                   	pop    %esi
801027a7:	5d                   	pop    %ebp
801027a8:	c3                   	ret    
801027a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      cprintf("cpu called from %x with interrupts enabled\n",
801027b0:	83 ec 08             	sub    $0x8,%esp
801027b3:	ff 75 04             	pushl  0x4(%ebp)
801027b6:	68 40 7d 10 80       	push   $0x80107d40
801027bb:	e8 80 de ff ff       	call   80100640 <cprintf>
801027c0:	83 c4 10             	add    $0x10,%esp
801027c3:	eb 89                	jmp    8010274e <cpunum+0x1e>
  panic("unknown apicid\n");
801027c5:	83 ec 0c             	sub    $0xc,%esp
801027c8:	68 6c 7d 10 80       	push   $0x80107d6c
801027cd:	e8 9e db ff ff       	call   80100370 <panic>
801027d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801027e0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
801027e0:	a1 dc 21 11 80       	mov    0x801121dc,%eax
{
801027e5:	55                   	push   %ebp
801027e6:	89 e5                	mov    %esp,%ebp
  if(lapic)
801027e8:	85 c0                	test   %eax,%eax
801027ea:	74 0d                	je     801027f9 <lapiceoi+0x19>
  lapic[index] = value;
801027ec:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801027f3:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801027f6:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
801027f9:	5d                   	pop    %ebp
801027fa:	c3                   	ret    
801027fb:	90                   	nop
801027fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102800 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102800:	55                   	push   %ebp
80102801:	89 e5                	mov    %esp,%ebp
}
80102803:	5d                   	pop    %ebp
80102804:	c3                   	ret    
80102805:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102809:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102810 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102810:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102811:	b8 0f 00 00 00       	mov    $0xf,%eax
80102816:	ba 70 00 00 00       	mov    $0x70,%edx
8010281b:	89 e5                	mov    %esp,%ebp
8010281d:	53                   	push   %ebx
8010281e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102821:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102824:	ee                   	out    %al,(%dx)
80102825:	b8 0a 00 00 00       	mov    $0xa,%eax
8010282a:	ba 71 00 00 00       	mov    $0x71,%edx
8010282f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102830:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102832:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102835:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
8010283b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
8010283d:	c1 e9 0c             	shr    $0xc,%ecx
  wrv[1] = addr >> 4;
80102840:	c1 e8 04             	shr    $0x4,%eax
  lapicw(ICRHI, apicid<<24);
80102843:	89 da                	mov    %ebx,%edx
    lapicw(ICRLO, STARTUP | (addr>>12));
80102845:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102848:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
8010284e:	a1 dc 21 11 80       	mov    0x801121dc,%eax
80102853:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102859:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010285c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102863:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102866:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102869:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102870:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102873:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102876:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010287c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010287f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102885:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102888:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010288e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102891:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102897:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
8010289a:	5b                   	pop    %ebx
8010289b:	5d                   	pop    %ebp
8010289c:	c3                   	ret    
8010289d:	8d 76 00             	lea    0x0(%esi),%esi

801028a0 <cmostime>:
  r->year   = cmos_read(YEAR);
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801028a0:	55                   	push   %ebp
801028a1:	b8 0b 00 00 00       	mov    $0xb,%eax
801028a6:	ba 70 00 00 00       	mov    $0x70,%edx
801028ab:	89 e5                	mov    %esp,%ebp
801028ad:	57                   	push   %edi
801028ae:	56                   	push   %esi
801028af:	53                   	push   %ebx
801028b0:	83 ec 4c             	sub    $0x4c,%esp
801028b3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028b4:	ba 71 00 00 00       	mov    $0x71,%edx
801028b9:	ec                   	in     (%dx),%al
801028ba:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028bd:	bb 70 00 00 00       	mov    $0x70,%ebx
801028c2:	88 45 b3             	mov    %al,-0x4d(%ebp)
801028c5:	8d 76 00             	lea    0x0(%esi),%esi
801028c8:	31 c0                	xor    %eax,%eax
801028ca:	89 da                	mov    %ebx,%edx
801028cc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028cd:	b9 71 00 00 00       	mov    $0x71,%ecx
801028d2:	89 ca                	mov    %ecx,%edx
801028d4:	ec                   	in     (%dx),%al
801028d5:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028d8:	89 da                	mov    %ebx,%edx
801028da:	b8 02 00 00 00       	mov    $0x2,%eax
801028df:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028e0:	89 ca                	mov    %ecx,%edx
801028e2:	ec                   	in     (%dx),%al
801028e3:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028e6:	89 da                	mov    %ebx,%edx
801028e8:	b8 04 00 00 00       	mov    $0x4,%eax
801028ed:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028ee:	89 ca                	mov    %ecx,%edx
801028f0:	ec                   	in     (%dx),%al
801028f1:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028f4:	89 da                	mov    %ebx,%edx
801028f6:	b8 07 00 00 00       	mov    $0x7,%eax
801028fb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028fc:	89 ca                	mov    %ecx,%edx
801028fe:	ec                   	in     (%dx),%al
801028ff:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102902:	89 da                	mov    %ebx,%edx
80102904:	b8 08 00 00 00       	mov    $0x8,%eax
80102909:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010290a:	89 ca                	mov    %ecx,%edx
8010290c:	ec                   	in     (%dx),%al
8010290d:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010290f:	89 da                	mov    %ebx,%edx
80102911:	b8 09 00 00 00       	mov    $0x9,%eax
80102916:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102917:	89 ca                	mov    %ecx,%edx
80102919:	ec                   	in     (%dx),%al
8010291a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010291c:	89 da                	mov    %ebx,%edx
8010291e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102923:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102924:	89 ca                	mov    %ecx,%edx
80102926:	ec                   	in     (%dx),%al
  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102927:	84 c0                	test   %al,%al
80102929:	78 9d                	js     801028c8 <cmostime+0x28>
  return inb(CMOS_RETURN);
8010292b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
8010292f:	89 fa                	mov    %edi,%edx
80102931:	0f b6 fa             	movzbl %dl,%edi
80102934:	89 f2                	mov    %esi,%edx
80102936:	0f b6 f2             	movzbl %dl,%esi
80102939:	89 7d c8             	mov    %edi,-0x38(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010293c:	89 da                	mov    %ebx,%edx
8010293e:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102941:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102944:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102948:	89 45 bc             	mov    %eax,-0x44(%ebp)
8010294b:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
8010294f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102952:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102956:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102959:	31 c0                	xor    %eax,%eax
8010295b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010295c:	89 ca                	mov    %ecx,%edx
8010295e:	ec                   	in     (%dx),%al
8010295f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102962:	89 da                	mov    %ebx,%edx
80102964:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102967:	b8 02 00 00 00       	mov    $0x2,%eax
8010296c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010296d:	89 ca                	mov    %ecx,%edx
8010296f:	ec                   	in     (%dx),%al
80102970:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102973:	89 da                	mov    %ebx,%edx
80102975:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102978:	b8 04 00 00 00       	mov    $0x4,%eax
8010297d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010297e:	89 ca                	mov    %ecx,%edx
80102980:	ec                   	in     (%dx),%al
80102981:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102984:	89 da                	mov    %ebx,%edx
80102986:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102989:	b8 07 00 00 00       	mov    $0x7,%eax
8010298e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010298f:	89 ca                	mov    %ecx,%edx
80102991:	ec                   	in     (%dx),%al
80102992:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102995:	89 da                	mov    %ebx,%edx
80102997:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010299a:	b8 08 00 00 00       	mov    $0x8,%eax
8010299f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029a0:	89 ca                	mov    %ecx,%edx
801029a2:	ec                   	in     (%dx),%al
801029a3:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029a6:	89 da                	mov    %ebx,%edx
801029a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801029ab:	b8 09 00 00 00       	mov    $0x9,%eax
801029b0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029b1:	89 ca                	mov    %ecx,%edx
801029b3:	ec                   	in     (%dx),%al
801029b4:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801029b7:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
801029ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801029bd:	8d 45 d0             	lea    -0x30(%ebp),%eax
801029c0:	6a 18                	push   $0x18
801029c2:	50                   	push   %eax
801029c3:	8d 45 b8             	lea    -0x48(%ebp),%eax
801029c6:	50                   	push   %eax
801029c7:	e8 54 22 00 00       	call   80104c20 <memcmp>
801029cc:	83 c4 10             	add    $0x10,%esp
801029cf:	85 c0                	test   %eax,%eax
801029d1:	0f 85 f1 fe ff ff    	jne    801028c8 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
801029d7:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
801029db:	75 78                	jne    80102a55 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801029dd:	8b 45 b8             	mov    -0x48(%ebp),%eax
801029e0:	89 c2                	mov    %eax,%edx
801029e2:	83 e0 0f             	and    $0xf,%eax
801029e5:	c1 ea 04             	shr    $0x4,%edx
801029e8:	8d 14 92             	lea    (%edx,%edx,4),%edx
801029eb:	8d 04 50             	lea    (%eax,%edx,2),%eax
801029ee:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
801029f1:	8b 45 bc             	mov    -0x44(%ebp),%eax
801029f4:	89 c2                	mov    %eax,%edx
801029f6:	83 e0 0f             	and    $0xf,%eax
801029f9:	c1 ea 04             	shr    $0x4,%edx
801029fc:	8d 14 92             	lea    (%edx,%edx,4),%edx
801029ff:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a02:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102a05:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102a08:	89 c2                	mov    %eax,%edx
80102a0a:	83 e0 0f             	and    $0xf,%eax
80102a0d:	c1 ea 04             	shr    $0x4,%edx
80102a10:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a13:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a16:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102a19:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102a1c:	89 c2                	mov    %eax,%edx
80102a1e:	83 e0 0f             	and    $0xf,%eax
80102a21:	c1 ea 04             	shr    $0x4,%edx
80102a24:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a27:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a2a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102a2d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102a30:	89 c2                	mov    %eax,%edx
80102a32:	83 e0 0f             	and    $0xf,%eax
80102a35:	c1 ea 04             	shr    $0x4,%edx
80102a38:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a3b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a3e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102a41:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102a44:	89 c2                	mov    %eax,%edx
80102a46:	83 e0 0f             	and    $0xf,%eax
80102a49:	c1 ea 04             	shr    $0x4,%edx
80102a4c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a4f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a52:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102a55:	8b 75 08             	mov    0x8(%ebp),%esi
80102a58:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102a5b:	89 06                	mov    %eax,(%esi)
80102a5d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102a60:	89 46 04             	mov    %eax,0x4(%esi)
80102a63:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102a66:	89 46 08             	mov    %eax,0x8(%esi)
80102a69:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102a6c:	89 46 0c             	mov    %eax,0xc(%esi)
80102a6f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102a72:	89 46 10             	mov    %eax,0x10(%esi)
80102a75:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102a78:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102a7b:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102a85:	5b                   	pop    %ebx
80102a86:	5e                   	pop    %esi
80102a87:	5f                   	pop    %edi
80102a88:	5d                   	pop    %ebp
80102a89:	c3                   	ret    
80102a8a:	66 90                	xchg   %ax,%ax
80102a8c:	66 90                	xchg   %ax,%ax
80102a8e:	66 90                	xchg   %ax,%ax

80102a90 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102a90:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102a96:	85 c9                	test   %ecx,%ecx
80102a98:	0f 8e 8a 00 00 00    	jle    80102b28 <install_trans+0x98>
{
80102a9e:	55                   	push   %ebp
80102a9f:	89 e5                	mov    %esp,%ebp
80102aa1:	57                   	push   %edi
80102aa2:	56                   	push   %esi
80102aa3:	53                   	push   %ebx
  for (tail = 0; tail < log.lh.n; tail++) {
80102aa4:	31 db                	xor    %ebx,%ebx
{
80102aa6:	83 ec 0c             	sub    $0xc,%esp
80102aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102ab0:	a1 14 22 11 80       	mov    0x80112214,%eax
80102ab5:	83 ec 08             	sub    $0x8,%esp
80102ab8:	01 d8                	add    %ebx,%eax
80102aba:	83 c0 01             	add    $0x1,%eax
80102abd:	50                   	push   %eax
80102abe:	ff 35 24 22 11 80    	pushl  0x80112224
80102ac4:	e8 f7 d5 ff ff       	call   801000c0 <bread>
80102ac9:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102acb:	58                   	pop    %eax
80102acc:	5a                   	pop    %edx
80102acd:	ff 34 9d 2c 22 11 80 	pushl  -0x7feeddd4(,%ebx,4)
80102ad4:	ff 35 24 22 11 80    	pushl  0x80112224
  for (tail = 0; tail < log.lh.n; tail++) {
80102ada:	83 c3 01             	add    $0x1,%ebx
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102add:	e8 de d5 ff ff       	call   801000c0 <bread>
80102ae2:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ae4:	8d 47 18             	lea    0x18(%edi),%eax
80102ae7:	83 c4 0c             	add    $0xc,%esp
80102aea:	68 00 02 00 00       	push   $0x200
80102aef:	50                   	push   %eax
80102af0:	8d 46 18             	lea    0x18(%esi),%eax
80102af3:	50                   	push   %eax
80102af4:	e8 87 21 00 00       	call   80104c80 <memmove>
    bwrite(dbuf);  // write dst to disk
80102af9:	89 34 24             	mov    %esi,(%esp)
80102afc:	e8 9f d6 ff ff       	call   801001a0 <bwrite>
    brelse(lbuf);
80102b01:	89 3c 24             	mov    %edi,(%esp)
80102b04:	e8 c7 d6 ff ff       	call   801001d0 <brelse>
    brelse(dbuf);
80102b09:	89 34 24             	mov    %esi,(%esp)
80102b0c:	e8 bf d6 ff ff       	call   801001d0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102b11:	83 c4 10             	add    $0x10,%esp
80102b14:	39 1d 28 22 11 80    	cmp    %ebx,0x80112228
80102b1a:	7f 94                	jg     80102ab0 <install_trans+0x20>
  }
}
80102b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102b1f:	5b                   	pop    %ebx
80102b20:	5e                   	pop    %esi
80102b21:	5f                   	pop    %edi
80102b22:	5d                   	pop    %ebp
80102b23:	c3                   	ret    
80102b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102b28:	f3 c3                	repz ret 
80102b2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102b30 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102b30:	55                   	push   %ebp
80102b31:	89 e5                	mov    %esp,%ebp
80102b33:	53                   	push   %ebx
80102b34:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102b37:	ff 35 14 22 11 80    	pushl  0x80112214
80102b3d:	ff 35 24 22 11 80    	pushl  0x80112224
80102b43:	e8 78 d5 ff ff       	call   801000c0 <bread>
80102b48:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102b4a:	a1 28 22 11 80       	mov    0x80112228,%eax
  for (i = 0; i < log.lh.n; i++) {
80102b4f:	83 c4 10             	add    $0x10,%esp
  hb->n = log.lh.n;
80102b52:	89 43 18             	mov    %eax,0x18(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102b55:	a1 28 22 11 80       	mov    0x80112228,%eax
80102b5a:	85 c0                	test   %eax,%eax
80102b5c:	7e 18                	jle    80102b76 <write_head+0x46>
80102b5e:	31 d2                	xor    %edx,%edx
    hb->block[i] = log.lh.block[i];
80102b60:	8b 0c 95 2c 22 11 80 	mov    -0x7feeddd4(,%edx,4),%ecx
80102b67:	89 4c 93 1c          	mov    %ecx,0x1c(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102b6b:	83 c2 01             	add    $0x1,%edx
80102b6e:	39 15 28 22 11 80    	cmp    %edx,0x80112228
80102b74:	7f ea                	jg     80102b60 <write_head+0x30>
  }
  bwrite(buf);
80102b76:	83 ec 0c             	sub    $0xc,%esp
80102b79:	53                   	push   %ebx
80102b7a:	e8 21 d6 ff ff       	call   801001a0 <bwrite>
  brelse(buf);
80102b7f:	89 1c 24             	mov    %ebx,(%esp)
80102b82:	e8 49 d6 ff ff       	call   801001d0 <brelse>
}
80102b87:	83 c4 10             	add    $0x10,%esp
80102b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b8d:	c9                   	leave  
80102b8e:	c3                   	ret    
80102b8f:	90                   	nop

80102b90 <initlog>:
{
80102b90:	55                   	push   %ebp
80102b91:	89 e5                	mov    %esp,%ebp
80102b93:	53                   	push   %ebx
80102b94:	83 ec 2c             	sub    $0x2c,%esp
80102b97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102b9a:	68 7c 7d 10 80       	push   $0x80107d7c
80102b9f:	68 e0 21 11 80       	push   $0x801121e0
80102ba4:	e8 f7 1d 00 00       	call   801049a0 <initlock>
  readsb(dev, &sb);
80102ba9:	58                   	pop    %eax
80102baa:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102bad:	5a                   	pop    %edx
80102bae:	50                   	push   %eax
80102baf:	53                   	push   %ebx
80102bb0:	e8 cb e7 ff ff       	call   80101380 <readsb>
  log.size = sb.nlog;
80102bb5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102bbb:	59                   	pop    %ecx
  log.dev = dev;
80102bbc:	89 1d 24 22 11 80    	mov    %ebx,0x80112224
  log.size = sb.nlog;
80102bc2:	89 15 18 22 11 80    	mov    %edx,0x80112218
  log.start = sb.logstart;
80102bc8:	a3 14 22 11 80       	mov    %eax,0x80112214
  struct buf *buf = bread(log.dev, log.start);
80102bcd:	5a                   	pop    %edx
80102bce:	50                   	push   %eax
80102bcf:	53                   	push   %ebx
80102bd0:	e8 eb d4 ff ff       	call   801000c0 <bread>
  log.lh.n = lh->n;
80102bd5:	8b 58 18             	mov    0x18(%eax),%ebx
  for (i = 0; i < log.lh.n; i++) {
80102bd8:	83 c4 10             	add    $0x10,%esp
80102bdb:	85 db                	test   %ebx,%ebx
  log.lh.n = lh->n;
80102bdd:	89 1d 28 22 11 80    	mov    %ebx,0x80112228
  for (i = 0; i < log.lh.n; i++) {
80102be3:	7e 1c                	jle    80102c01 <initlog+0x71>
80102be5:	c1 e3 02             	shl    $0x2,%ebx
80102be8:	31 d2                	xor    %edx,%edx
80102bea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    log.lh.block[i] = lh->block[i];
80102bf0:	8b 4c 10 1c          	mov    0x1c(%eax,%edx,1),%ecx
80102bf4:	83 c2 04             	add    $0x4,%edx
80102bf7:	89 8a 28 22 11 80    	mov    %ecx,-0x7feeddd8(%edx)
  for (i = 0; i < log.lh.n; i++) {
80102bfd:	39 d3                	cmp    %edx,%ebx
80102bff:	75 ef                	jne    80102bf0 <initlog+0x60>
  brelse(buf);
80102c01:	83 ec 0c             	sub    $0xc,%esp
80102c04:	50                   	push   %eax
80102c05:	e8 c6 d5 ff ff       	call   801001d0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102c0a:	e8 81 fe ff ff       	call   80102a90 <install_trans>
  log.lh.n = 0;
80102c0f:	c7 05 28 22 11 80 00 	movl   $0x0,0x80112228
80102c16:	00 00 00 
  write_head(); // clear the log
80102c19:	e8 12 ff ff ff       	call   80102b30 <write_head>
}
80102c1e:	83 c4 10             	add    $0x10,%esp
80102c21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c24:	c9                   	leave  
80102c25:	c3                   	ret    
80102c26:	8d 76 00             	lea    0x0(%esi),%esi
80102c29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c30 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102c30:	55                   	push   %ebp
80102c31:	89 e5                	mov    %esp,%ebp
80102c33:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102c36:	68 e0 21 11 80       	push   $0x801121e0
80102c3b:	e8 80 1d 00 00       	call   801049c0 <acquire>
80102c40:	83 c4 10             	add    $0x10,%esp
80102c43:	eb 18                	jmp    80102c5d <begin_op+0x2d>
80102c45:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102c48:	83 ec 08             	sub    $0x8,%esp
80102c4b:	68 e0 21 11 80       	push   $0x801121e0
80102c50:	68 e0 21 11 80       	push   $0x801121e0
80102c55:	e8 06 14 00 00       	call   80104060 <sleep>
80102c5a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102c5d:	a1 20 22 11 80       	mov    0x80112220,%eax
80102c62:	85 c0                	test   %eax,%eax
80102c64:	75 e2                	jne    80102c48 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102c66:	a1 1c 22 11 80       	mov    0x8011221c,%eax
80102c6b:	8b 15 28 22 11 80    	mov    0x80112228,%edx
80102c71:	83 c0 01             	add    $0x1,%eax
80102c74:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102c77:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102c7a:	83 fa 1e             	cmp    $0x1e,%edx
80102c7d:	7f c9                	jg     80102c48 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102c7f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102c82:	a3 1c 22 11 80       	mov    %eax,0x8011221c
      release(&log.lock);
80102c87:	68 e0 21 11 80       	push   $0x801121e0
80102c8c:	e8 ef 1e 00 00       	call   80104b80 <release>
      break;
    }
  }
}
80102c91:	83 c4 10             	add    $0x10,%esp
80102c94:	c9                   	leave  
80102c95:	c3                   	ret    
80102c96:	8d 76 00             	lea    0x0(%esi),%esi
80102c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102ca0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
80102ca3:	57                   	push   %edi
80102ca4:	56                   	push   %esi
80102ca5:	53                   	push   %ebx
80102ca6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102ca9:	68 e0 21 11 80       	push   $0x801121e0
80102cae:	e8 0d 1d 00 00       	call   801049c0 <acquire>
  log.outstanding -= 1;
80102cb3:	a1 1c 22 11 80       	mov    0x8011221c,%eax
  if(log.committing)
80102cb8:	8b 35 20 22 11 80    	mov    0x80112220,%esi
80102cbe:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102cc1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  if(log.committing)
80102cc4:	85 f6                	test   %esi,%esi
  log.outstanding -= 1;
80102cc6:	89 1d 1c 22 11 80    	mov    %ebx,0x8011221c
  if(log.committing)
80102ccc:	0f 85 1a 01 00 00    	jne    80102dec <end_op+0x14c>
    panic("log.committing");
  if(log.outstanding == 0){
80102cd2:	85 db                	test   %ebx,%ebx
80102cd4:	0f 85 ee 00 00 00    	jne    80102dc8 <end_op+0x128>
    log.committing = 1;
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
  }
  release(&log.lock);
80102cda:	83 ec 0c             	sub    $0xc,%esp
    log.committing = 1;
80102cdd:	c7 05 20 22 11 80 01 	movl   $0x1,0x80112220
80102ce4:	00 00 00 
  release(&log.lock);
80102ce7:	68 e0 21 11 80       	push   $0x801121e0
80102cec:	e8 8f 1e 00 00       	call   80104b80 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102cf1:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102cf7:	83 c4 10             	add    $0x10,%esp
80102cfa:	85 c9                	test   %ecx,%ecx
80102cfc:	0f 8e 85 00 00 00    	jle    80102d87 <end_op+0xe7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102d02:	a1 14 22 11 80       	mov    0x80112214,%eax
80102d07:	83 ec 08             	sub    $0x8,%esp
80102d0a:	01 d8                	add    %ebx,%eax
80102d0c:	83 c0 01             	add    $0x1,%eax
80102d0f:	50                   	push   %eax
80102d10:	ff 35 24 22 11 80    	pushl  0x80112224
80102d16:	e8 a5 d3 ff ff       	call   801000c0 <bread>
80102d1b:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d1d:	58                   	pop    %eax
80102d1e:	5a                   	pop    %edx
80102d1f:	ff 34 9d 2c 22 11 80 	pushl  -0x7feeddd4(,%ebx,4)
80102d26:	ff 35 24 22 11 80    	pushl  0x80112224
  for (tail = 0; tail < log.lh.n; tail++) {
80102d2c:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d2f:	e8 8c d3 ff ff       	call   801000c0 <bread>
80102d34:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102d36:	8d 40 18             	lea    0x18(%eax),%eax
80102d39:	83 c4 0c             	add    $0xc,%esp
80102d3c:	68 00 02 00 00       	push   $0x200
80102d41:	50                   	push   %eax
80102d42:	8d 46 18             	lea    0x18(%esi),%eax
80102d45:	50                   	push   %eax
80102d46:	e8 35 1f 00 00       	call   80104c80 <memmove>
    bwrite(to);  // write the log
80102d4b:	89 34 24             	mov    %esi,(%esp)
80102d4e:	e8 4d d4 ff ff       	call   801001a0 <bwrite>
    brelse(from);
80102d53:	89 3c 24             	mov    %edi,(%esp)
80102d56:	e8 75 d4 ff ff       	call   801001d0 <brelse>
    brelse(to);
80102d5b:	89 34 24             	mov    %esi,(%esp)
80102d5e:	e8 6d d4 ff ff       	call   801001d0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102d63:	83 c4 10             	add    $0x10,%esp
80102d66:	3b 1d 28 22 11 80    	cmp    0x80112228,%ebx
80102d6c:	7c 94                	jl     80102d02 <end_op+0x62>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102d6e:	e8 bd fd ff ff       	call   80102b30 <write_head>
    install_trans(); // Now install writes to home locations
80102d73:	e8 18 fd ff ff       	call   80102a90 <install_trans>
    log.lh.n = 0;
80102d78:	c7 05 28 22 11 80 00 	movl   $0x0,0x80112228
80102d7f:	00 00 00 
    write_head();    // Erase the transaction from the log
80102d82:	e8 a9 fd ff ff       	call   80102b30 <write_head>
    acquire(&log.lock);
80102d87:	83 ec 0c             	sub    $0xc,%esp
80102d8a:	68 e0 21 11 80       	push   $0x801121e0
80102d8f:	e8 2c 1c 00 00       	call   801049c0 <acquire>
    wakeup(&log);
80102d94:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
    log.committing = 0;
80102d9b:	c7 05 20 22 11 80 00 	movl   $0x0,0x80112220
80102da2:	00 00 00 
    wakeup(&log);
80102da5:	e8 a6 14 00 00       	call   80104250 <wakeup>
    release(&log.lock);
80102daa:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102db1:	e8 ca 1d 00 00       	call   80104b80 <release>
80102db6:	83 c4 10             	add    $0x10,%esp
}
80102db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dbc:	5b                   	pop    %ebx
80102dbd:	5e                   	pop    %esi
80102dbe:	5f                   	pop    %edi
80102dbf:	5d                   	pop    %ebp
80102dc0:	c3                   	ret    
80102dc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&log);
80102dc8:	83 ec 0c             	sub    $0xc,%esp
80102dcb:	68 e0 21 11 80       	push   $0x801121e0
80102dd0:	e8 7b 14 00 00       	call   80104250 <wakeup>
  release(&log.lock);
80102dd5:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102ddc:	e8 9f 1d 00 00       	call   80104b80 <release>
80102de1:	83 c4 10             	add    $0x10,%esp
}
80102de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102de7:	5b                   	pop    %ebx
80102de8:	5e                   	pop    %esi
80102de9:	5f                   	pop    %edi
80102dea:	5d                   	pop    %ebp
80102deb:	c3                   	ret    
    panic("log.committing");
80102dec:	83 ec 0c             	sub    $0xc,%esp
80102def:	68 80 7d 10 80       	push   $0x80107d80
80102df4:	e8 77 d5 ff ff       	call   80100370 <panic>
80102df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102e00 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102e00:	55                   	push   %ebp
80102e01:	89 e5                	mov    %esp,%ebp
80102e03:	53                   	push   %ebx
80102e04:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102e07:	8b 15 28 22 11 80    	mov    0x80112228,%edx
{
80102e0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102e10:	83 fa 1d             	cmp    $0x1d,%edx
80102e13:	0f 8f 9d 00 00 00    	jg     80102eb6 <log_write+0xb6>
80102e19:	a1 18 22 11 80       	mov    0x80112218,%eax
80102e1e:	83 e8 01             	sub    $0x1,%eax
80102e21:	39 c2                	cmp    %eax,%edx
80102e23:	0f 8d 8d 00 00 00    	jge    80102eb6 <log_write+0xb6>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102e29:	a1 1c 22 11 80       	mov    0x8011221c,%eax
80102e2e:	85 c0                	test   %eax,%eax
80102e30:	0f 8e 8d 00 00 00    	jle    80102ec3 <log_write+0xc3>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102e36:	83 ec 0c             	sub    $0xc,%esp
80102e39:	68 e0 21 11 80       	push   $0x801121e0
80102e3e:	e8 7d 1b 00 00       	call   801049c0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102e43:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102e49:	83 c4 10             	add    $0x10,%esp
80102e4c:	83 f9 00             	cmp    $0x0,%ecx
80102e4f:	7e 57                	jle    80102ea8 <log_write+0xa8>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102e51:	8b 53 08             	mov    0x8(%ebx),%edx
  for (i = 0; i < log.lh.n; i++) {
80102e54:	31 c0                	xor    %eax,%eax
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102e56:	3b 15 2c 22 11 80    	cmp    0x8011222c,%edx
80102e5c:	75 0b                	jne    80102e69 <log_write+0x69>
80102e5e:	eb 38                	jmp    80102e98 <log_write+0x98>
80102e60:	39 14 85 2c 22 11 80 	cmp    %edx,-0x7feeddd4(,%eax,4)
80102e67:	74 2f                	je     80102e98 <log_write+0x98>
  for (i = 0; i < log.lh.n; i++) {
80102e69:	83 c0 01             	add    $0x1,%eax
80102e6c:	39 c1                	cmp    %eax,%ecx
80102e6e:	75 f0                	jne    80102e60 <log_write+0x60>
      break;
  }
  log.lh.block[i] = b->blockno;
80102e70:	89 14 85 2c 22 11 80 	mov    %edx,-0x7feeddd4(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
80102e77:	83 c0 01             	add    $0x1,%eax
80102e7a:	a3 28 22 11 80       	mov    %eax,0x80112228
  b->flags |= B_DIRTY; // prevent eviction
80102e7f:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102e82:	c7 45 08 e0 21 11 80 	movl   $0x801121e0,0x8(%ebp)
}
80102e89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e8c:	c9                   	leave  
  release(&log.lock);
80102e8d:	e9 ee 1c 00 00       	jmp    80104b80 <release>
80102e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80102e98:	89 14 85 2c 22 11 80 	mov    %edx,-0x7feeddd4(,%eax,4)
80102e9f:	eb de                	jmp    80102e7f <log_write+0x7f>
80102ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102ea8:	8b 43 08             	mov    0x8(%ebx),%eax
80102eab:	a3 2c 22 11 80       	mov    %eax,0x8011222c
  if (i == log.lh.n)
80102eb0:	75 cd                	jne    80102e7f <log_write+0x7f>
80102eb2:	31 c0                	xor    %eax,%eax
80102eb4:	eb c1                	jmp    80102e77 <log_write+0x77>
    panic("too big a transaction");
80102eb6:	83 ec 0c             	sub    $0xc,%esp
80102eb9:	68 8f 7d 10 80       	push   $0x80107d8f
80102ebe:	e8 ad d4 ff ff       	call   80100370 <panic>
    panic("log_write outside of trans");
80102ec3:	83 ec 0c             	sub    $0xc,%esp
80102ec6:	68 a5 7d 10 80       	push   $0x80107da5
80102ecb:	e8 a0 d4 ff ff       	call   80100370 <panic>

80102ed0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102ed0:	55                   	push   %ebp
80102ed1:	89 e5                	mov    %esp,%ebp
80102ed3:	53                   	push   %ebx
80102ed4:	83 ec 04             	sub    $0x4,%esp
  int cpuID = cpunum();
80102ed7:	e8 54 f8 ff ff       	call   80102730 <cpunum>
  cprintf("cpu%d: starting\n", cpuID);
80102edc:	83 ec 08             	sub    $0x8,%esp
  int cpuID = cpunum();
80102edf:	89 c3                	mov    %eax,%ebx
  cprintf("cpu%d: starting\n", cpuID);
80102ee1:	50                   	push   %eax
80102ee2:	68 c0 7d 10 80       	push   $0x80107dc0
80102ee7:	e8 54 d7 ff ff       	call   80100640 <cprintf>
  idtinit();       // load idt register
80102eec:	e8 3f 31 00 00       	call   80106030 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80102ef1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102ef8:	b8 01 00 00 00       	mov    $0x1,%eax
80102efd:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler(cpuID);     // start running processes
80102f04:	89 1c 24             	mov    %ebx,(%esp)
80102f07:	e8 94 0d 00 00       	call   80103ca0 <scheduler>
80102f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102f10 <mpenter>:
{
80102f10:	55                   	push   %ebp
80102f11:	89 e5                	mov    %esp,%ebp
80102f13:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102f16:	e8 a5 42 00 00       	call   801071c0 <switchkvm>
  seginit();
80102f1b:	e8 30 41 00 00       	call   80107050 <seginit>
  lapicinit();
80102f20:	e8 0b f7 ff ff       	call   80102630 <lapicinit>
  mpmain();
80102f25:	e8 a6 ff ff ff       	call   80102ed0 <mpmain>
80102f2a:	66 90                	xchg   %ax,%ax
80102f2c:	66 90                	xchg   %ax,%ax
80102f2e:	66 90                	xchg   %ax,%ax

80102f30 <main>:
{
80102f30:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102f34:	83 e4 f0             	and    $0xfffffff0,%esp
80102f37:	ff 71 fc             	pushl  -0x4(%ecx)
80102f3a:	55                   	push   %ebp
80102f3b:	89 e5                	mov    %esp,%ebp
80102f3d:	53                   	push   %ebx
80102f3e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102f3f:	83 ec 08             	sub    $0x8,%esp
80102f42:	68 00 00 40 80       	push   $0x80400000
80102f47:	68 68 7b 11 80       	push   $0x80117b68
80102f4c:	e8 9f f4 ff ff       	call   801023f0 <kinit1>
  kvmalloc();      // kernel page table
80102f51:	e8 4a 42 00 00       	call   801071a0 <kvmalloc>
  mpinit();        // detect other processors
80102f56:	e8 b5 01 00 00       	call   80103110 <mpinit>
  lapicinit();     // interrupt controller
80102f5b:	e8 d0 f6 ff ff       	call   80102630 <lapicinit>
  seginit();       // segment descriptors
80102f60:	e8 eb 40 00 00       	call   80107050 <seginit>
  cprintf("\ncpu%d: starting xv6\n----------------------------\nzzx is programming xv6\n----------------------------\n", cpunum());
80102f65:	e8 c6 f7 ff ff       	call   80102730 <cpunum>
80102f6a:	5a                   	pop    %edx
80102f6b:	59                   	pop    %ecx
80102f6c:	50                   	push   %eax
80102f6d:	68 d4 7d 10 80       	push   $0x80107dd4
80102f72:	e8 c9 d6 ff ff       	call   80100640 <cprintf>
  picinit();       // another interrupt controller
80102f77:	e8 b4 03 00 00       	call   80103330 <picinit>
  ioapicinit();    // another interrupt controller
80102f7c:	e8 7f f2 ff ff       	call   80102200 <ioapicinit>
  consoleinit();   // console hardware
80102f81:	e8 1a da ff ff       	call   801009a0 <consoleinit>
  uartinit();      // serial port
80102f86:	e8 95 33 00 00       	call   80106320 <uartinit>
  pinit();         // process table
80102f8b:	e8 c0 09 00 00       	call   80103950 <pinit>
  tvinit();        // trap vectors
80102f90:	e8 1b 30 00 00       	call   80105fb0 <tvinit>
  binit();         // buffer cache
80102f95:	e8 a6 d0 ff ff       	call   80100040 <binit>
  fileinit();      // file table
80102f9a:	e8 91 dd ff ff       	call   80100d30 <fileinit>
  ideinit();       // disk
80102f9f:	e8 3c f0 ff ff       	call   80101fe0 <ideinit>
  if(!ismp)
80102fa4:	8b 1d c4 22 11 80    	mov    0x801122c4,%ebx
80102faa:	83 c4 10             	add    $0x10,%esp
80102fad:	85 db                	test   %ebx,%ebx
80102faf:	0f 84 ca 00 00 00    	je     8010307f <main+0x14f>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102fb5:	83 ec 04             	sub    $0x4,%esp
80102fb8:	68 8a 00 00 00       	push   $0x8a
80102fbd:	68 8c b4 10 80       	push   $0x8010b48c
80102fc2:	68 00 70 00 80       	push   $0x80007000
80102fc7:	e8 b4 1c 00 00       	call   80104c80 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102fcc:	69 05 c0 28 11 80 bc 	imul   $0xbc,0x801128c0,%eax
80102fd3:	00 00 00 
80102fd6:	83 c4 10             	add    $0x10,%esp
80102fd9:	05 e0 22 11 80       	add    $0x801122e0,%eax
80102fde:	3d e0 22 11 80       	cmp    $0x801122e0,%eax
80102fe3:	76 7e                	jbe    80103063 <main+0x133>
80102fe5:	bb e0 22 11 80       	mov    $0x801122e0,%ebx
80102fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(c == cpus+cpunum())  // We've started already.
80102ff0:	e8 3b f7 ff ff       	call   80102730 <cpunum>
80102ff5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80102ffb:	05 e0 22 11 80       	add    $0x801122e0,%eax
80103000:	39 c3                	cmp    %eax,%ebx
80103002:	74 46                	je     8010304a <main+0x11a>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103004:	e8 b7 f4 ff ff       	call   801024c0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80103009:	83 ec 08             	sub    $0x8,%esp
    *(void**)(code-4) = stack + KSTACKSIZE;
8010300c:	05 00 10 00 00       	add    $0x1000,%eax
    *(void**)(code-8) = mpenter;
80103011:	c7 05 f8 6f 00 80 10 	movl   $0x80102f10,0x80006ff8
80103018:	2f 10 80 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010301b:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103020:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
80103027:	a0 10 00 
    lapicstartap(c->apicid, V2P(code));
8010302a:	68 00 70 00 00       	push   $0x7000
8010302f:	0f b6 03             	movzbl (%ebx),%eax
80103032:	50                   	push   %eax
80103033:	e8 d8 f7 ff ff       	call   80102810 <lapicstartap>
80103038:	83 c4 10             	add    $0x10,%esp
8010303b:	90                   	nop
8010303c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103040:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
80103046:	85 c0                	test   %eax,%eax
80103048:	74 f6                	je     80103040 <main+0x110>
  for(c = cpus; c < cpus+ncpu; c++){
8010304a:	69 05 c0 28 11 80 bc 	imul   $0xbc,0x801128c0,%eax
80103051:	00 00 00 
80103054:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
8010305a:	05 e0 22 11 80       	add    $0x801122e0,%eax
8010305f:	39 c3                	cmp    %eax,%ebx
80103061:	72 8d                	jb     80102ff0 <main+0xc0>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103063:	83 ec 08             	sub    $0x8,%esp
80103066:	68 00 00 00 8e       	push   $0x8e000000
8010306b:	68 00 00 40 80       	push   $0x80400000
80103070:	e8 eb f3 ff ff       	call   80102460 <kinit2>
  userinit();      // first user process
80103075:	e8 f6 08 00 00       	call   80103970 <userinit>
  mpmain();        // finish this processor's setup
8010307a:	e8 51 fe ff ff       	call   80102ed0 <mpmain>
    timerinit();   // uniprocessor timer
8010307f:	e8 cc 2e 00 00       	call   80105f50 <timerinit>
80103084:	e9 2c ff ff ff       	jmp    80102fb5 <main+0x85>
80103089:	66 90                	xchg   %ax,%ax
8010308b:	66 90                	xchg   %ax,%ax
8010308d:	66 90                	xchg   %ax,%ax
8010308f:	90                   	nop

80103090 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103090:	55                   	push   %ebp
80103091:	89 e5                	mov    %esp,%ebp
80103093:	57                   	push   %edi
80103094:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103095:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010309b:	53                   	push   %ebx
  e = addr+len;
8010309c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010309f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
801030a2:	39 de                	cmp    %ebx,%esi
801030a4:	72 10                	jb     801030b6 <mpsearch1+0x26>
801030a6:	eb 50                	jmp    801030f8 <mpsearch1+0x68>
801030a8:	90                   	nop
801030a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030b0:	39 fb                	cmp    %edi,%ebx
801030b2:	89 fe                	mov    %edi,%esi
801030b4:	76 42                	jbe    801030f8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801030b6:	83 ec 04             	sub    $0x4,%esp
801030b9:	8d 7e 10             	lea    0x10(%esi),%edi
801030bc:	6a 04                	push   $0x4
801030be:	68 3b 7e 10 80       	push   $0x80107e3b
801030c3:	56                   	push   %esi
801030c4:	e8 57 1b 00 00       	call   80104c20 <memcmp>
801030c9:	83 c4 10             	add    $0x10,%esp
801030cc:	85 c0                	test   %eax,%eax
801030ce:	75 e0                	jne    801030b0 <mpsearch1+0x20>
801030d0:	89 f1                	mov    %esi,%ecx
801030d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801030d8:	0f b6 11             	movzbl (%ecx),%edx
801030db:	83 c1 01             	add    $0x1,%ecx
801030de:	01 d0                	add    %edx,%eax
  for(i=0; i<len; i++)
801030e0:	39 f9                	cmp    %edi,%ecx
801030e2:	75 f4                	jne    801030d8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801030e4:	84 c0                	test   %al,%al
801030e6:	75 c8                	jne    801030b0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801030e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030eb:	89 f0                	mov    %esi,%eax
801030ed:	5b                   	pop    %ebx
801030ee:	5e                   	pop    %esi
801030ef:	5f                   	pop    %edi
801030f0:	5d                   	pop    %ebp
801030f1:	c3                   	ret    
801030f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801030f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801030fb:	31 f6                	xor    %esi,%esi
}
801030fd:	89 f0                	mov    %esi,%eax
801030ff:	5b                   	pop    %ebx
80103100:	5e                   	pop    %esi
80103101:	5f                   	pop    %edi
80103102:	5d                   	pop    %ebp
80103103:	c3                   	ret    
80103104:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010310a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103110 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103110:	55                   	push   %ebp
80103111:	89 e5                	mov    %esp,%ebp
80103113:	57                   	push   %edi
80103114:	56                   	push   %esi
80103115:	53                   	push   %ebx
80103116:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103119:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103120:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103127:	c1 e0 08             	shl    $0x8,%eax
8010312a:	09 d0                	or     %edx,%eax
8010312c:	c1 e0 04             	shl    $0x4,%eax
8010312f:	85 c0                	test   %eax,%eax
80103131:	75 1b                	jne    8010314e <mpinit+0x3e>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103133:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
8010313a:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80103141:	c1 e0 08             	shl    $0x8,%eax
80103144:	09 d0                	or     %edx,%eax
80103146:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103149:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010314e:	ba 00 04 00 00       	mov    $0x400,%edx
80103153:	e8 38 ff ff ff       	call   80103090 <mpsearch1>
80103158:	85 c0                	test   %eax,%eax
8010315a:	89 c7                	mov    %eax,%edi
8010315c:	0f 84 76 01 00 00    	je     801032d8 <mpinit+0x1c8>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103162:	8b 5f 04             	mov    0x4(%edi),%ebx
80103165:	85 db                	test   %ebx,%ebx
80103167:	0f 84 e6 00 00 00    	je     80103253 <mpinit+0x143>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010316d:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80103173:	83 ec 04             	sub    $0x4,%esp
80103176:	6a 04                	push   $0x4
80103178:	68 40 7e 10 80       	push   $0x80107e40
8010317d:	56                   	push   %esi
8010317e:	e8 9d 1a 00 00       	call   80104c20 <memcmp>
80103183:	83 c4 10             	add    $0x10,%esp
80103186:	85 c0                	test   %eax,%eax
80103188:	0f 85 c5 00 00 00    	jne    80103253 <mpinit+0x143>
  if(conf->version != 1 && conf->version != 4)
8010318e:	0f b6 93 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%edx
80103195:	80 fa 01             	cmp    $0x1,%dl
80103198:	0f 95 c1             	setne  %cl
8010319b:	80 fa 04             	cmp    $0x4,%dl
8010319e:	0f 95 c2             	setne  %dl
801031a1:	20 ca                	and    %cl,%dl
801031a3:	0f 85 aa 00 00 00    	jne    80103253 <mpinit+0x143>
  if(sum((uchar*)conf, conf->length) != 0)
801031a9:	0f b7 8b 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%ecx
  for(i=0; i<len; i++)
801031b0:	66 85 c9             	test   %cx,%cx
801031b3:	74 1f                	je     801031d4 <mpinit+0xc4>
801031b5:	01 f1                	add    %esi,%ecx
801031b7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801031ba:	89 f2                	mov    %esi,%edx
801031bc:	89 cb                	mov    %ecx,%ebx
801031be:	66 90                	xchg   %ax,%ax
    sum += addr[i];
801031c0:	0f b6 0a             	movzbl (%edx),%ecx
801031c3:	83 c2 01             	add    $0x1,%edx
801031c6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801031c8:	39 da                	cmp    %ebx,%edx
801031ca:	75 f4                	jne    801031c0 <mpinit+0xb0>
801031cc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801031cf:	84 c0                	test   %al,%al
801031d1:	0f 95 c2             	setne  %dl
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
801031d4:	85 f6                	test   %esi,%esi
801031d6:	74 7b                	je     80103253 <mpinit+0x143>
801031d8:	84 d2                	test   %dl,%dl
801031da:	75 77                	jne    80103253 <mpinit+0x143>
    return;
  ismp = 1;
801031dc:	c7 05 c4 22 11 80 01 	movl   $0x1,0x801122c4
801031e3:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801031e6:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
801031ec:	a3 dc 21 11 80       	mov    %eax,0x801121dc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801031f1:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
801031f8:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
801031fe:	01 d6                	add    %edx,%esi
80103200:	39 f0                	cmp    %esi,%eax
80103202:	0f 83 a8 00 00 00    	jae    801032b0 <mpinit+0x1a0>
80103208:	90                   	nop
80103209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(*p){
80103210:	80 38 04             	cmpb   $0x4,(%eax)
80103213:	0f 87 87 00 00 00    	ja     801032a0 <mpinit+0x190>
80103219:	0f b6 10             	movzbl (%eax),%edx
8010321c:	ff 24 95 48 7e 10 80 	jmp    *-0x7fef81b8(,%edx,4)
80103223:	90                   	nop
80103224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103228:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010322b:	39 c6                	cmp    %eax,%esi
8010322d:	77 e1                	ja     80103210 <mpinit+0x100>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp){
8010322f:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	75 78                	jne    801032b0 <mpinit+0x1a0>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103238:	c7 05 c0 28 11 80 01 	movl   $0x1,0x801128c0
8010323f:	00 00 00 
    lapic = 0;
80103242:	c7 05 dc 21 11 80 00 	movl   $0x0,0x801121dc
80103249:	00 00 00 
    ioapicid = 0;
8010324c:	c6 05 c0 22 11 80 00 	movb   $0x0,0x801122c0
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103253:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103256:	5b                   	pop    %ebx
80103257:	5e                   	pop    %esi
80103258:	5f                   	pop    %edi
80103259:	5d                   	pop    %ebp
8010325a:	c3                   	ret    
8010325b:	90                   	nop
8010325c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(ncpu < NCPU) {
80103260:	8b 15 c0 28 11 80    	mov    0x801128c0,%edx
80103266:	83 fa 07             	cmp    $0x7,%edx
80103269:	7f 19                	jg     80103284 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010326b:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
8010326f:	69 da bc 00 00 00    	imul   $0xbc,%edx,%ebx
        ncpu++;
80103275:	83 c2 01             	add    $0x1,%edx
80103278:	89 15 c0 28 11 80    	mov    %edx,0x801128c0
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010327e:	88 8b e0 22 11 80    	mov    %cl,-0x7feedd20(%ebx)
      p += sizeof(struct mpproc);
80103284:	83 c0 14             	add    $0x14,%eax
      continue;
80103287:	eb a2                	jmp    8010322b <mpinit+0x11b>
80103289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103290:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      p += sizeof(struct mpioapic);
80103294:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103297:	88 15 c0 22 11 80    	mov    %dl,0x801122c0
      continue;
8010329d:	eb 8c                	jmp    8010322b <mpinit+0x11b>
8010329f:	90                   	nop
      ismp = 0;
801032a0:	c7 05 c4 22 11 80 00 	movl   $0x0,0x801122c4
801032a7:	00 00 00 
      break;
801032aa:	e9 7c ff ff ff       	jmp    8010322b <mpinit+0x11b>
801032af:	90                   	nop
  if(mp->imcrp){
801032b0:	80 7f 0c 00          	cmpb   $0x0,0xc(%edi)
801032b4:	74 9d                	je     80103253 <mpinit+0x143>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801032b6:	b8 70 00 00 00       	mov    $0x70,%eax
801032bb:	ba 22 00 00 00       	mov    $0x22,%edx
801032c0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801032c1:	ba 23 00 00 00       	mov    $0x23,%edx
801032c6:	ec                   	in     (%dx),%al
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801032c7:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801032ca:	ee                   	out    %al,(%dx)
}
801032cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801032ce:	5b                   	pop    %ebx
801032cf:	5e                   	pop    %esi
801032d0:	5f                   	pop    %edi
801032d1:	5d                   	pop    %ebp
801032d2:	c3                   	ret    
801032d3:	90                   	nop
801032d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return mpsearch1(0xF0000, 0x10000);
801032d8:	ba 00 00 01 00       	mov    $0x10000,%edx
801032dd:	b8 00 00 0f 00       	mov    $0xf0000,%eax
801032e2:	e8 a9 fd ff ff       	call   80103090 <mpsearch1>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801032e7:	85 c0                	test   %eax,%eax
  return mpsearch1(0xF0000, 0x10000);
801032e9:	89 c7                	mov    %eax,%edi
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801032eb:	0f 85 71 fe ff ff    	jne    80103162 <mpinit+0x52>
801032f1:	e9 5d ff ff ff       	jmp    80103253 <mpinit+0x143>
801032f6:	66 90                	xchg   %ax,%ax
801032f8:	66 90                	xchg   %ax,%ax
801032fa:	66 90                	xchg   %ax,%ax
801032fc:	66 90                	xchg   %ax,%ax
801032fe:	66 90                	xchg   %ax,%ax

80103300 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
80103300:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
80103301:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
80103306:	ba 21 00 00 00       	mov    $0x21,%edx
{
8010330b:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
8010330d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103310:	d3 c0                	rol    %cl,%eax
80103312:	66 23 05 00 b0 10 80 	and    0x8010b000,%ax
  irqmask = mask;
80103319:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
8010331f:	ee                   	out    %al,(%dx)
80103320:	ba a1 00 00 00       	mov    $0xa1,%edx
  outb(IO_PIC2+1, mask >> 8);
80103325:	66 c1 e8 08          	shr    $0x8,%ax
80103329:	ee                   	out    %al,(%dx)
}
8010332a:	5d                   	pop    %ebp
8010332b:	c3                   	ret    
8010332c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103330 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103330:	55                   	push   %ebp
80103331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103336:	89 e5                	mov    %esp,%ebp
80103338:	57                   	push   %edi
80103339:	56                   	push   %esi
8010333a:	53                   	push   %ebx
8010333b:	bb 21 00 00 00       	mov    $0x21,%ebx
80103340:	89 da                	mov    %ebx,%edx
80103342:	ee                   	out    %al,(%dx)
80103343:	b9 a1 00 00 00       	mov    $0xa1,%ecx
80103348:	89 ca                	mov    %ecx,%edx
8010334a:	ee                   	out    %al,(%dx)
8010334b:	be 11 00 00 00       	mov    $0x11,%esi
80103350:	ba 20 00 00 00       	mov    $0x20,%edx
80103355:	89 f0                	mov    %esi,%eax
80103357:	ee                   	out    %al,(%dx)
80103358:	b8 20 00 00 00       	mov    $0x20,%eax
8010335d:	89 da                	mov    %ebx,%edx
8010335f:	ee                   	out    %al,(%dx)
80103360:	b8 04 00 00 00       	mov    $0x4,%eax
80103365:	ee                   	out    %al,(%dx)
80103366:	bf 03 00 00 00       	mov    $0x3,%edi
8010336b:	89 f8                	mov    %edi,%eax
8010336d:	ee                   	out    %al,(%dx)
8010336e:	ba a0 00 00 00       	mov    $0xa0,%edx
80103373:	89 f0                	mov    %esi,%eax
80103375:	ee                   	out    %al,(%dx)
80103376:	b8 28 00 00 00       	mov    $0x28,%eax
8010337b:	89 ca                	mov    %ecx,%edx
8010337d:	ee                   	out    %al,(%dx)
8010337e:	b8 02 00 00 00       	mov    $0x2,%eax
80103383:	ee                   	out    %al,(%dx)
80103384:	89 f8                	mov    %edi,%eax
80103386:	ee                   	out    %al,(%dx)
80103387:	bf 68 00 00 00       	mov    $0x68,%edi
8010338c:	ba 20 00 00 00       	mov    $0x20,%edx
80103391:	89 f8                	mov    %edi,%eax
80103393:	ee                   	out    %al,(%dx)
80103394:	be 0a 00 00 00       	mov    $0xa,%esi
80103399:	89 f0                	mov    %esi,%eax
8010339b:	ee                   	out    %al,(%dx)
8010339c:	ba a0 00 00 00       	mov    $0xa0,%edx
801033a1:	89 f8                	mov    %edi,%eax
801033a3:	ee                   	out    %al,(%dx)
801033a4:	89 f0                	mov    %esi,%eax
801033a6:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
801033a7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
801033ae:	66 83 f8 ff          	cmp    $0xffff,%ax
801033b2:	74 0a                	je     801033be <picinit+0x8e>
801033b4:	89 da                	mov    %ebx,%edx
801033b6:	ee                   	out    %al,(%dx)
  outb(IO_PIC2+1, mask >> 8);
801033b7:	66 c1 e8 08          	shr    $0x8,%ax
801033bb:	89 ca                	mov    %ecx,%edx
801033bd:	ee                   	out    %al,(%dx)
    picsetmask(irqmask);
}
801033be:	5b                   	pop    %ebx
801033bf:	5e                   	pop    %esi
801033c0:	5f                   	pop    %edi
801033c1:	5d                   	pop    %ebp
801033c2:	c3                   	ret    
801033c3:	66 90                	xchg   %ax,%ax
801033c5:	66 90                	xchg   %ax,%ax
801033c7:	66 90                	xchg   %ax,%ax
801033c9:	66 90                	xchg   %ax,%ax
801033cb:	66 90                	xchg   %ax,%ax
801033cd:	66 90                	xchg   %ax,%ax
801033cf:	90                   	nop

801033d0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801033d0:	55                   	push   %ebp
801033d1:	89 e5                	mov    %esp,%ebp
801033d3:	57                   	push   %edi
801033d4:	56                   	push   %esi
801033d5:	53                   	push   %ebx
801033d6:	83 ec 0c             	sub    $0xc,%esp
801033d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801033dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
801033df:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801033e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801033eb:	e8 60 d9 ff ff       	call   80100d50 <filealloc>
801033f0:	85 c0                	test   %eax,%eax
801033f2:	89 03                	mov    %eax,(%ebx)
801033f4:	74 22                	je     80103418 <pipealloc+0x48>
801033f6:	e8 55 d9 ff ff       	call   80100d50 <filealloc>
801033fb:	85 c0                	test   %eax,%eax
801033fd:	89 06                	mov    %eax,(%esi)
801033ff:	74 3f                	je     80103440 <pipealloc+0x70>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103401:	e8 ba f0 ff ff       	call   801024c0 <kalloc>
80103406:	85 c0                	test   %eax,%eax
80103408:	89 c7                	mov    %eax,%edi
8010340a:	75 54                	jne    80103460 <pipealloc+0x90>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
8010340c:	8b 03                	mov    (%ebx),%eax
8010340e:	85 c0                	test   %eax,%eax
80103410:	75 34                	jne    80103446 <pipealloc+0x76>
80103412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    fileclose(*f0);
  if(*f1)
80103418:	8b 06                	mov    (%esi),%eax
8010341a:	85 c0                	test   %eax,%eax
8010341c:	74 0c                	je     8010342a <pipealloc+0x5a>
    fileclose(*f1);
8010341e:	83 ec 0c             	sub    $0xc,%esp
80103421:	50                   	push   %eax
80103422:	e8 e9 d9 ff ff       	call   80100e10 <fileclose>
80103427:	83 c4 10             	add    $0x10,%esp
  return -1;
}
8010342a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010342d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103432:	5b                   	pop    %ebx
80103433:	5e                   	pop    %esi
80103434:	5f                   	pop    %edi
80103435:	5d                   	pop    %ebp
80103436:	c3                   	ret    
80103437:	89 f6                	mov    %esi,%esi
80103439:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  if(*f0)
80103440:	8b 03                	mov    (%ebx),%eax
80103442:	85 c0                	test   %eax,%eax
80103444:	74 e4                	je     8010342a <pipealloc+0x5a>
    fileclose(*f0);
80103446:	83 ec 0c             	sub    $0xc,%esp
80103449:	50                   	push   %eax
8010344a:	e8 c1 d9 ff ff       	call   80100e10 <fileclose>
  if(*f1)
8010344f:	8b 06                	mov    (%esi),%eax
    fileclose(*f0);
80103451:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103454:	85 c0                	test   %eax,%eax
80103456:	75 c6                	jne    8010341e <pipealloc+0x4e>
80103458:	eb d0                	jmp    8010342a <pipealloc+0x5a>
8010345a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  initlock(&p->lock, "pipe");
80103460:	83 ec 08             	sub    $0x8,%esp
  p->readopen = 1;
80103463:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010346a:	00 00 00 
  p->writeopen = 1;
8010346d:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103474:	00 00 00 
  p->nwrite = 0;
80103477:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010347e:	00 00 00 
  p->nread = 0;
80103481:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103488:	00 00 00 
  initlock(&p->lock, "pipe");
8010348b:	68 5c 7e 10 80       	push   $0x80107e5c
80103490:	50                   	push   %eax
80103491:	e8 0a 15 00 00       	call   801049a0 <initlock>
  (*f0)->type = FD_PIPE;
80103496:	8b 03                	mov    (%ebx),%eax
  return 0;
80103498:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010349b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801034a1:	8b 03                	mov    (%ebx),%eax
801034a3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801034a7:	8b 03                	mov    (%ebx),%eax
801034a9:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801034ad:	8b 03                	mov    (%ebx),%eax
801034af:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801034b2:	8b 06                	mov    (%esi),%eax
801034b4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801034ba:	8b 06                	mov    (%esi),%eax
801034bc:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801034c0:	8b 06                	mov    (%esi),%eax
801034c2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801034c6:	8b 06                	mov    (%esi),%eax
801034c8:	89 78 0c             	mov    %edi,0xc(%eax)
}
801034cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801034ce:	31 c0                	xor    %eax,%eax
}
801034d0:	5b                   	pop    %ebx
801034d1:	5e                   	pop    %esi
801034d2:	5f                   	pop    %edi
801034d3:	5d                   	pop    %ebp
801034d4:	c3                   	ret    
801034d5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801034d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801034e0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801034e0:	55                   	push   %ebp
801034e1:	89 e5                	mov    %esp,%ebp
801034e3:	56                   	push   %esi
801034e4:	53                   	push   %ebx
801034e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801034e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801034eb:	83 ec 0c             	sub    $0xc,%esp
801034ee:	53                   	push   %ebx
801034ef:	e8 cc 14 00 00       	call   801049c0 <acquire>
  if(writable){
801034f4:	83 c4 10             	add    $0x10,%esp
801034f7:	85 f6                	test   %esi,%esi
801034f9:	74 45                	je     80103540 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
801034fb:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103501:	83 ec 0c             	sub    $0xc,%esp
    p->writeopen = 0;
80103504:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010350b:	00 00 00 
    wakeup(&p->nread);
8010350e:	50                   	push   %eax
8010350f:	e8 3c 0d 00 00       	call   80104250 <wakeup>
80103514:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103517:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010351d:	85 d2                	test   %edx,%edx
8010351f:	75 0a                	jne    8010352b <pipeclose+0x4b>
80103521:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103527:	85 c0                	test   %eax,%eax
80103529:	74 35                	je     80103560 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010352b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010352e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103531:	5b                   	pop    %ebx
80103532:	5e                   	pop    %esi
80103533:	5d                   	pop    %ebp
    release(&p->lock);
80103534:	e9 47 16 00 00       	jmp    80104b80 <release>
80103539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&p->nwrite);
80103540:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103546:	83 ec 0c             	sub    $0xc,%esp
    p->readopen = 0;
80103549:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103550:	00 00 00 
    wakeup(&p->nwrite);
80103553:	50                   	push   %eax
80103554:	e8 f7 0c 00 00       	call   80104250 <wakeup>
80103559:	83 c4 10             	add    $0x10,%esp
8010355c:	eb b9                	jmp    80103517 <pipeclose+0x37>
8010355e:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80103560:	83 ec 0c             	sub    $0xc,%esp
80103563:	53                   	push   %ebx
80103564:	e8 17 16 00 00       	call   80104b80 <release>
    kfree((char*)p);
80103569:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010356c:	83 c4 10             	add    $0x10,%esp
}
8010356f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103572:	5b                   	pop    %ebx
80103573:	5e                   	pop    %esi
80103574:	5d                   	pop    %ebp
    kfree((char*)p);
80103575:	e9 96 ed ff ff       	jmp    80102310 <kfree>
8010357a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103580 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103580:	55                   	push   %ebp
80103581:	89 e5                	mov    %esp,%ebp
80103583:	57                   	push   %edi
80103584:	56                   	push   %esi
80103585:	53                   	push   %ebx
80103586:	83 ec 28             	sub    $0x28,%esp
80103589:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i;

  acquire(&p->lock);
8010358c:	57                   	push   %edi
8010358d:	e8 2e 14 00 00       	call   801049c0 <acquire>
  for(i = 0; i < n; i++){
80103592:	8b 45 10             	mov    0x10(%ebp),%eax
80103595:	83 c4 10             	add    $0x10,%esp
80103598:	85 c0                	test   %eax,%eax
8010359a:	0f 8e c6 00 00 00    	jle    80103666 <pipewrite+0xe6>
801035a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801035a3:	8b 8f 38 02 00 00    	mov    0x238(%edi),%ecx
801035a9:	8d b7 34 02 00 00    	lea    0x234(%edi),%esi
801035af:	8d 9f 38 02 00 00    	lea    0x238(%edi),%ebx
801035b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801035b8:	03 45 10             	add    0x10(%ebp),%eax
801035bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801035be:	8b 87 34 02 00 00    	mov    0x234(%edi),%eax
801035c4:	8d 90 00 02 00 00    	lea    0x200(%eax),%edx
801035ca:	39 d1                	cmp    %edx,%ecx
801035cc:	0f 85 cf 00 00 00    	jne    801036a1 <pipewrite+0x121>
      if(p->readopen == 0 || proc->killed){
801035d2:	8b 97 3c 02 00 00    	mov    0x23c(%edi),%edx
801035d8:	85 d2                	test   %edx,%edx
801035da:	0f 84 a8 00 00 00    	je     80103688 <pipewrite+0x108>
801035e0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801035e7:	8b 42 48             	mov    0x48(%edx),%eax
801035ea:	85 c0                	test   %eax,%eax
801035ec:	74 25                	je     80103613 <pipewrite+0x93>
801035ee:	e9 95 00 00 00       	jmp    80103688 <pipewrite+0x108>
801035f3:	90                   	nop
801035f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801035f8:	8b 87 3c 02 00 00    	mov    0x23c(%edi),%eax
801035fe:	85 c0                	test   %eax,%eax
80103600:	0f 84 82 00 00 00    	je     80103688 <pipewrite+0x108>
80103606:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010360c:	8b 40 48             	mov    0x48(%eax),%eax
8010360f:	85 c0                	test   %eax,%eax
80103611:	75 75                	jne    80103688 <pipewrite+0x108>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103613:	83 ec 0c             	sub    $0xc,%esp
80103616:	56                   	push   %esi
80103617:	e8 34 0c 00 00       	call   80104250 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010361c:	59                   	pop    %ecx
8010361d:	58                   	pop    %eax
8010361e:	57                   	push   %edi
8010361f:	53                   	push   %ebx
80103620:	e8 3b 0a 00 00       	call   80104060 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103625:	8b 87 34 02 00 00    	mov    0x234(%edi),%eax
8010362b:	8b 97 38 02 00 00    	mov    0x238(%edi),%edx
80103631:	83 c4 10             	add    $0x10,%esp
80103634:	05 00 02 00 00       	add    $0x200,%eax
80103639:	39 c2                	cmp    %eax,%edx
8010363b:	74 bb                	je     801035f8 <pipewrite+0x78>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010363d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103640:	8d 4a 01             	lea    0x1(%edx),%ecx
80103643:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103647:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010364d:	89 8f 38 02 00 00    	mov    %ecx,0x238(%edi)
80103653:	0f b6 00             	movzbl (%eax),%eax
80103656:	88 44 17 34          	mov    %al,0x34(%edi,%edx,1)
8010365a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  for(i = 0; i < n; i++){
8010365d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80103660:	0f 85 58 ff ff ff    	jne    801035be <pipewrite+0x3e>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103666:	8d 97 34 02 00 00    	lea    0x234(%edi),%edx
8010366c:	83 ec 0c             	sub    $0xc,%esp
8010366f:	52                   	push   %edx
80103670:	e8 db 0b 00 00       	call   80104250 <wakeup>
  release(&p->lock);
80103675:	89 3c 24             	mov    %edi,(%esp)
80103678:	e8 03 15 00 00       	call   80104b80 <release>
  return n;
8010367d:	83 c4 10             	add    $0x10,%esp
80103680:	8b 45 10             	mov    0x10(%ebp),%eax
80103683:	eb 14                	jmp    80103699 <pipewrite+0x119>
80103685:	8d 76 00             	lea    0x0(%esi),%esi
        release(&p->lock);
80103688:	83 ec 0c             	sub    $0xc,%esp
8010368b:	57                   	push   %edi
8010368c:	e8 ef 14 00 00       	call   80104b80 <release>
        return -1;
80103691:	83 c4 10             	add    $0x10,%esp
80103694:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103699:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010369c:	5b                   	pop    %ebx
8010369d:	5e                   	pop    %esi
8010369e:	5f                   	pop    %edi
8010369f:	5d                   	pop    %ebp
801036a0:	c3                   	ret    
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801036a1:	89 ca                	mov    %ecx,%edx
801036a3:	eb 98                	jmp    8010363d <pipewrite+0xbd>
801036a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801036a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801036b0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801036b0:	55                   	push   %ebp
801036b1:	89 e5                	mov    %esp,%ebp
801036b3:	57                   	push   %edi
801036b4:	56                   	push   %esi
801036b5:	53                   	push   %ebx
801036b6:	83 ec 18             	sub    $0x18,%esp
801036b9:	8b 75 08             	mov    0x8(%ebp),%esi
801036bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801036bf:	56                   	push   %esi
801036c0:	e8 fb 12 00 00       	call   801049c0 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
801036ce:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
801036d4:	75 64                	jne    8010373a <piperead+0x8a>
801036d6:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
801036dc:	85 c0                	test   %eax,%eax
801036de:	0f 84 bc 00 00 00    	je     801037a0 <piperead+0xf0>
    if(proc->killed){
801036e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801036ea:	8b 58 48             	mov    0x48(%eax),%ebx
801036ed:	85 db                	test   %ebx,%ebx
801036ef:	0f 85 b3 00 00 00    	jne    801037a8 <piperead+0xf8>
801036f5:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801036fb:	eb 22                	jmp    8010371f <piperead+0x6f>
801036fd:	8d 76 00             	lea    0x0(%esi),%esi
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103700:	8b 96 40 02 00 00    	mov    0x240(%esi),%edx
80103706:	85 d2                	test   %edx,%edx
80103708:	0f 84 92 00 00 00    	je     801037a0 <piperead+0xf0>
    if(proc->killed){
8010370e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103714:	8b 48 48             	mov    0x48(%eax),%ecx
80103717:	85 c9                	test   %ecx,%ecx
80103719:	0f 85 89 00 00 00    	jne    801037a8 <piperead+0xf8>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010371f:	83 ec 08             	sub    $0x8,%esp
80103722:	56                   	push   %esi
80103723:	53                   	push   %ebx
80103724:	e8 37 09 00 00       	call   80104060 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103729:	83 c4 10             	add    $0x10,%esp
8010372c:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
80103732:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
80103738:	74 c6                	je     80103700 <piperead+0x50>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010373a:	8b 45 10             	mov    0x10(%ebp),%eax
8010373d:	85 c0                	test   %eax,%eax
8010373f:	7e 5f                	jle    801037a0 <piperead+0xf0>
    if(p->nread == p->nwrite)
80103741:	31 db                	xor    %ebx,%ebx
80103743:	eb 11                	jmp    80103756 <piperead+0xa6>
80103745:	8d 76 00             	lea    0x0(%esi),%esi
80103748:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
8010374e:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
80103754:	74 1f                	je     80103775 <piperead+0xc5>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103756:	8d 41 01             	lea    0x1(%ecx),%eax
80103759:	81 e1 ff 01 00 00    	and    $0x1ff,%ecx
8010375f:	89 86 34 02 00 00    	mov    %eax,0x234(%esi)
80103765:	0f b6 44 0e 34       	movzbl 0x34(%esi,%ecx,1),%eax
8010376a:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010376d:	83 c3 01             	add    $0x1,%ebx
80103770:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80103773:	75 d3                	jne    80103748 <piperead+0x98>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103775:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	50                   	push   %eax
8010377f:	e8 cc 0a 00 00       	call   80104250 <wakeup>
  release(&p->lock);
80103784:	89 34 24             	mov    %esi,(%esp)
80103787:	e8 f4 13 00 00       	call   80104b80 <release>
  return i;
8010378c:	83 c4 10             	add    $0x10,%esp
}
8010378f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103792:	89 d8                	mov    %ebx,%eax
80103794:	5b                   	pop    %ebx
80103795:	5e                   	pop    %esi
80103796:	5f                   	pop    %edi
80103797:	5d                   	pop    %ebp
80103798:	c3                   	ret    
80103799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p->nread == p->nwrite)
801037a0:	31 db                	xor    %ebx,%ebx
801037a2:	eb d1                	jmp    80103775 <piperead+0xc5>
801037a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&p->lock);
801037a8:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801037ab:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
801037b0:	56                   	push   %esi
801037b1:	e8 ca 13 00 00       	call   80104b80 <release>
      return -1;
801037b6:	83 c4 10             	add    $0x10,%esp
}
801037b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801037bc:	89 d8                	mov    %ebx,%eax
801037be:	5b                   	pop    %ebx
801037bf:	5e                   	pop    %esi
801037c0:	5f                   	pop    %edi
801037c1:	5d                   	pop    %ebp
801037c2:	c3                   	ret    
801037c3:	66 90                	xchg   %ax,%ax
801037c5:	66 90                	xchg   %ax,%ax
801037c7:	66 90                	xchg   %ax,%ax
801037c9:	66 90                	xchg   %ax,%ax
801037cb:	66 90                	xchg   %ax,%ax
801037cd:	66 90                	xchg   %ax,%ax
801037cf:	90                   	nop

801037d0 <allocproc>:
// state required to run in the kernel.
// Otherwise return 0.
// Must hold ptable.lock.
static struct proc*
allocproc(void)
{
801037d0:	55                   	push   %ebp
801037d1:	89 e5                	mov    %esp,%ebp
801037d3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037d4:	bb 14 29 11 80       	mov    $0x80112914,%ebx
{
801037d9:	83 ec 04             	sub    $0x4,%esp
801037dc:	eb 14                	jmp    801037f2 <allocproc+0x22>
801037de:	66 90                	xchg   %ax,%ax
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037e0:	81 c3 28 01 00 00    	add    $0x128,%ebx
801037e6:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
801037ec:	0f 83 e8 00 00 00    	jae    801038da <allocproc+0x10a>
    if(p->state == UNUSED)
801037f2:	8b 43 0c             	mov    0xc(%ebx),%eax
801037f5:	85 c0                	test   %eax,%eax
801037f7:	75 e7                	jne    801037e0 <allocproc+0x10>
      goto found;
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
801037f9:	a1 08 b0 10 80       	mov    0x8010b008,%eax
  p->state = EMBRYO;
801037fe:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->priority = 10;
80103805:	c7 83 20 01 00 00 0a 	movl   $0xa,0x120(%ebx)
8010380c:	00 00 00 
  p->numberOfSon = 0;
8010380f:	c7 43 38 00 00 00 00 	movl   $0x0,0x38(%ebx)
  for(int i = 0; i < MAXSON; ++i){
    p->son[i] = 0;
80103816:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
8010381d:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
  p->pid = nextpid++;
80103824:	8d 50 01             	lea    0x1(%eax),%edx
80103827:	89 43 10             	mov    %eax,0x10(%ebx)
8010382a:	8d 83 a4 00 00 00    	lea    0xa4(%ebx),%eax
    p->son[i] = 0;
80103830:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
80103837:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
  p->pid = nextpid++;
8010383e:	89 15 08 b0 10 80    	mov    %edx,0x8010b008
80103844:	8d 93 1c 01 00 00    	lea    0x11c(%ebx),%edx
    p->son[i] = 0;
8010384a:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
80103851:	c7 43 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
80103858:	c7 43 30 00 00 00 00 	movl   $0x0,0x30(%ebx)
8010385f:	c7 43 34 00 00 00 00 	movl   $0x0,0x34(%ebx)
80103866:	8d 76 00             	lea    0x0(%esi),%esi
80103869:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  }

  for (int i = 0; i < 10; ++i)
  {
    p->vm[i].next = -1;
80103870:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    p->vm[i].length = 0;
80103877:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010387d:	83 c0 0c             	add    $0xc,%eax
  for (int i = 0; i < 10; ++i)
80103880:	39 d0                	cmp    %edx,%eax
80103882:	75 ec                	jne    80103870 <allocproc+0xa0>
  }
  p->vm[0].next = 0;
80103884:	c7 83 a8 00 00 00 00 	movl   $0x0,0xa8(%ebx)
8010388b:	00 00 00 

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010388e:	e8 2d ec ff ff       	call   801024c0 <kalloc>
80103893:	85 c0                	test   %eax,%eax
80103895:	89 43 08             	mov    %eax,0x8(%ebx)
80103898:	74 39                	je     801038d3 <allocproc+0x103>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010389a:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
801038a0:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
801038a3:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
801038a8:	89 53 3c             	mov    %edx,0x3c(%ebx)
  *(uint*)sp = (uint)trapret;
801038ab:	c7 40 14 9e 5f 10 80 	movl   $0x80105f9e,0x14(%eax)
  p->context = (struct context*)sp;
801038b2:	89 43 40             	mov    %eax,0x40(%ebx)
  memset(p->context, 0, sizeof *p->context);
801038b5:	6a 14                	push   $0x14
801038b7:	6a 00                	push   $0x0
801038b9:	50                   	push   %eax
801038ba:	e8 11 13 00 00       	call   80104bd0 <memset>
  p->context->eip = (uint)forkret;
801038bf:	8b 43 40             	mov    0x40(%ebx),%eax

  return p;
801038c2:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801038c5:	c7 40 10 f0 38 10 80 	movl   $0x801038f0,0x10(%eax)
}
801038cc:	89 d8                	mov    %ebx,%eax
801038ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038d1:	c9                   	leave  
801038d2:	c3                   	ret    
    p->state = UNUSED;
801038d3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801038da:	31 db                	xor    %ebx,%ebx
}
801038dc:	89 d8                	mov    %ebx,%eax
801038de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038e1:	c9                   	leave  
801038e2:	c3                   	ret    
801038e3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801038e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801038f0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801038f0:	55                   	push   %ebp
801038f1:	89 e5                	mov    %esp,%ebp
801038f3:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801038f6:	68 e0 28 11 80       	push   $0x801128e0
801038fb:	e8 80 12 00 00       	call   80104b80 <release>

  if (first) {
80103900:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80103905:	83 c4 10             	add    $0x10,%esp
80103908:	85 c0                	test   %eax,%eax
8010390a:	75 04                	jne    80103910 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010390c:	c9                   	leave  
8010390d:	c3                   	ret    
8010390e:	66 90                	xchg   %ax,%ax
    iinit(ROOTDEV);
80103910:	83 ec 0c             	sub    $0xc,%esp
    first = 0;
80103913:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
8010391a:	00 00 00 
    iinit(ROOTDEV);
8010391d:	6a 01                	push   $0x1
8010391f:	e8 1c db ff ff       	call   80101440 <iinit>
    initlog(ROOTDEV);
80103924:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010392b:	e8 60 f2 ff ff       	call   80102b90 <initlog>
80103930:	83 c4 10             	add    $0x10,%esp
}
80103933:	c9                   	leave  
80103934:	c3                   	ret    
80103935:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103939:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103940 <getcpuid>:
{
80103940:	55                   	push   %ebp
80103941:	89 e5                	mov    %esp,%ebp
}
80103943:	5d                   	pop    %ebp
  return cpunum();
80103944:	e9 e7 ed ff ff       	jmp    80102730 <cpunum>
80103949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103950 <pinit>:
{
80103950:	55                   	push   %ebp
80103951:	89 e5                	mov    %esp,%ebp
80103953:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103956:	68 61 7e 10 80       	push   $0x80107e61
8010395b:	68 e0 28 11 80       	push   $0x801128e0
80103960:	e8 3b 10 00 00       	call   801049a0 <initlock>
}
80103965:	83 c4 10             	add    $0x10,%esp
80103968:	c9                   	leave  
80103969:	c3                   	ret    
8010396a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103970 <userinit>:
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	53                   	push   %ebx
80103974:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103977:	68 e0 28 11 80       	push   $0x801128e0
8010397c:	e8 3f 10 00 00       	call   801049c0 <acquire>
  p = allocproc();
80103981:	e8 4a fe ff ff       	call   801037d0 <allocproc>
80103986:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103988:	a3 bc b5 10 80       	mov    %eax,0x8010b5bc
  if((p->pgdir = setupkvm()) == 0)
8010398d:	e8 9e 37 00 00       	call   80107130 <setupkvm>
80103992:	83 c4 10             	add    $0x10,%esp
80103995:	85 c0                	test   %eax,%eax
80103997:	89 43 04             	mov    %eax,0x4(%ebx)
8010399a:	0f 84 c1 00 00 00    	je     80103a61 <userinit+0xf1>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801039a0:	83 ec 04             	sub    $0x4,%esp
801039a3:	68 2c 00 00 00       	push   $0x2c
801039a8:	68 60 b4 10 80       	push   $0x8010b460
801039ad:	50                   	push   %eax
801039ae:	e8 cd 38 00 00       	call   80107280 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
801039b3:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
801039b6:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801039bc:	6a 4c                	push   $0x4c
801039be:	6a 00                	push   $0x0
801039c0:	ff 73 3c             	pushl  0x3c(%ebx)
801039c3:	e8 08 12 00 00       	call   80104bd0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801039c8:	8b 43 3c             	mov    0x3c(%ebx),%eax
801039cb:	ba 23 00 00 00       	mov    $0x23,%edx
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801039d0:	b9 2b 00 00 00       	mov    $0x2b,%ecx
  safestrcpy(p->name, "initcode", sizeof(p->name));
801039d5:	83 c4 0c             	add    $0xc,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801039d8:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801039dc:	8b 43 3c             	mov    0x3c(%ebx),%eax
801039df:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
801039e3:	8b 43 3c             	mov    0x3c(%ebx),%eax
801039e6:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801039ea:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801039ee:	8b 43 3c             	mov    0x3c(%ebx),%eax
801039f1:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801039f5:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801039f9:	8b 43 3c             	mov    0x3c(%ebx),%eax
801039fc:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103a03:	8b 43 3c             	mov    0x3c(%ebx),%eax
80103a06:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103a0d:	8b 43 3c             	mov    0x3c(%ebx),%eax
80103a10:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a17:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80103a1d:	6a 10                	push   $0x10
80103a1f:	68 81 7e 10 80       	push   $0x80107e81
80103a24:	50                   	push   %eax
80103a25:	e8 86 13 00 00       	call   80104db0 <safestrcpy>
  p->cwd = namei("/");
80103a2a:	c7 04 24 8a 7e 10 80 	movl   $0x80107e8a,(%esp)
80103a31:	e8 8a e4 ff ff       	call   80101ec0 <namei>
  p->cpuID = 0;   //init进程在0号cpu上运行
80103a36:	c7 83 24 01 00 00 00 	movl   $0x0,0x124(%ebx)
80103a3d:	00 00 00 
  p->cwd = namei("/");
80103a40:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
  p->state = RUNNABLE;
80103a46:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103a4d:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103a54:	e8 27 11 00 00       	call   80104b80 <release>
}
80103a59:	83 c4 10             	add    $0x10,%esp
80103a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a5f:	c9                   	leave  
80103a60:	c3                   	ret    
    panic("userinit: out of memory?");
80103a61:	83 ec 0c             	sub    $0xc,%esp
80103a64:	68 68 7e 10 80       	push   $0x80107e68
80103a69:	e8 02 c9 ff ff       	call   80100370 <panic>
80103a6e:	66 90                	xchg   %ax,%ax

80103a70 <growproc>:
{
80103a70:	55                   	push   %ebp
80103a71:	89 e5                	mov    %esp,%ebp
80103a73:	83 ec 08             	sub    $0x8,%esp
  sz = proc->sz;
80103a76:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80103a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  sz = proc->sz;
80103a80:	8b 02                	mov    (%edx),%eax
  if(n > 0){
80103a82:	83 f9 00             	cmp    $0x0,%ecx
80103a85:	7f 21                	jg     80103aa8 <growproc+0x38>
  } else if(n < 0){
80103a87:	75 47                	jne    80103ad0 <growproc+0x60>
  proc->sz = sz;
80103a89:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
80103a8b:	83 ec 0c             	sub    $0xc,%esp
80103a8e:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
80103a95:	e8 46 37 00 00       	call   801071e0 <switchuvm>
  return 0;
80103a9a:	83 c4 10             	add    $0x10,%esp
80103a9d:	31 c0                	xor    %eax,%eax
}
80103a9f:	c9                   	leave  
80103aa0:	c3                   	ret    
80103aa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80103aa8:	83 ec 04             	sub    $0x4,%esp
80103aab:	01 c1                	add    %eax,%ecx
80103aad:	51                   	push   %ecx
80103aae:	50                   	push   %eax
80103aaf:	ff 72 04             	pushl  0x4(%edx)
80103ab2:	e8 09 39 00 00       	call   801073c0 <allocuvm>
80103ab7:	83 c4 10             	add    $0x10,%esp
80103aba:	85 c0                	test   %eax,%eax
80103abc:	74 28                	je     80103ae6 <growproc+0x76>
80103abe:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103ac5:	eb c2                	jmp    80103a89 <growproc+0x19>
80103ac7:	89 f6                	mov    %esi,%esi
80103ac9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80103ad0:	83 ec 04             	sub    $0x4,%esp
80103ad3:	01 c1                	add    %eax,%ecx
80103ad5:	51                   	push   %ecx
80103ad6:	50                   	push   %eax
80103ad7:	ff 72 04             	pushl  0x4(%edx)
80103ada:	e8 81 3a 00 00       	call   80107560 <deallocuvm>
80103adf:	83 c4 10             	add    $0x10,%esp
80103ae2:	85 c0                	test   %eax,%eax
80103ae4:	75 d8                	jne    80103abe <growproc+0x4e>
      return -1;
80103ae6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103aeb:	c9                   	leave  
80103aec:	c3                   	ret    
80103aed:	8d 76 00             	lea    0x0(%esi),%esi

80103af0 <fork>:
{
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	57                   	push   %edi
80103af4:	56                   	push   %esi
80103af5:	53                   	push   %ebx
80103af6:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80103af9:	68 e0 28 11 80       	push   $0x801128e0
80103afe:	e8 bd 0e 00 00       	call   801049c0 <acquire>
  if((np = allocproc()) == 0){
80103b03:	e8 c8 fc ff ff       	call   801037d0 <allocproc>
80103b08:	83 c4 10             	add    $0x10,%esp
80103b0b:	85 c0                	test   %eax,%eax
80103b0d:	0f 84 37 01 00 00    	je     80103c4a <fork+0x15a>
80103b13:	89 c3                	mov    %eax,%ebx
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80103b15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b1b:	83 ec 08             	sub    $0x8,%esp
80103b1e:	ff 30                	pushl  (%eax)
80103b20:	ff 70 04             	pushl  0x4(%eax)
80103b23:	e8 b8 3b 00 00       	call   801076e0 <copyuvm>
80103b28:	83 c4 10             	add    $0x10,%esp
80103b2b:	85 c0                	test   %eax,%eax
80103b2d:	89 43 04             	mov    %eax,0x4(%ebx)
80103b30:	0f 84 2b 01 00 00    	je     80103c61 <fork+0x171>
  np->sz = proc->sz;
80103b36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b3c:	8b 00                	mov    (%eax),%eax
80103b3e:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
80103b40:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b47:	89 53 14             	mov    %edx,0x14(%ebx)
  if(parent->numberOfSon >= MAXSON){
80103b4a:	8b 4a 38             	mov    0x38(%edx),%ecx
80103b4d:	83 f9 07             	cmp    $0x7,%ecx
80103b50:	0f 8f d1 00 00 00    	jg     80103c27 <fork+0x137>
  for (int i = 0; i < MAXSON; ++i){
80103b56:	31 c0                	xor    %eax,%eax
80103b58:	90                   	nop
80103b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if (parent->son[i] == 0){
80103b60:	8b 74 82 18          	mov    0x18(%edx,%eax,4),%esi
80103b64:	85 f6                	test   %esi,%esi
80103b66:	0f 84 ac 00 00 00    	je     80103c18 <fork+0x128>
  for (int i = 0; i < MAXSON; ++i){
80103b6c:	83 c0 01             	add    $0x1,%eax
80103b6f:	83 f8 08             	cmp    $0x8,%eax
80103b72:	75 ec                	jne    80103b60 <fork+0x70>
  *np->tf = *proc->tf;
80103b74:	8b 72 3c             	mov    0x3c(%edx),%esi
80103b77:	8b 7b 3c             	mov    0x3c(%ebx),%edi
80103b7a:	b9 13 00 00 00       	mov    $0x13,%ecx
80103b7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103b81:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103b83:	8b 43 3c             	mov    0x3c(%ebx),%eax
80103b86:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b8d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
80103b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->ofile[i])
80103b98:	8b 44 b2 4c          	mov    0x4c(%edx,%esi,4),%eax
80103b9c:	85 c0                	test   %eax,%eax
80103b9e:	74 17                	je     80103bb7 <fork+0xc7>
      np->ofile[i] = filedup(proc->ofile[i]);
80103ba0:	83 ec 0c             	sub    $0xc,%esp
80103ba3:	50                   	push   %eax
80103ba4:	e8 17 d2 ff ff       	call   80100dc0 <filedup>
80103ba9:	89 44 b3 4c          	mov    %eax,0x4c(%ebx,%esi,4)
80103bad:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103bb4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
80103bb7:	83 c6 01             	add    $0x1,%esi
80103bba:	83 fe 10             	cmp    $0x10,%esi
80103bbd:	75 d9                	jne    80103b98 <fork+0xa8>
  np->cwd = idup(proc->cwd);
80103bbf:	83 ec 0c             	sub    $0xc,%esp
80103bc2:	ff b2 8c 00 00 00    	pushl  0x8c(%edx)
80103bc8:	e8 13 da ff ff       	call   801015e0 <idup>
80103bcd:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80103bd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103bd9:	83 c4 0c             	add    $0xc,%esp
80103bdc:	6a 10                	push   $0x10
80103bde:	05 90 00 00 00       	add    $0x90,%eax
80103be3:	50                   	push   %eax
80103be4:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80103bea:	50                   	push   %eax
80103beb:	e8 c0 11 00 00       	call   80104db0 <safestrcpy>
  np->state = RUNNABLE;
80103bf0:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  pid = np->pid;
80103bf7:	8b 73 10             	mov    0x10(%ebx),%esi
  release(&ptable.lock);
80103bfa:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103c01:	e8 7a 0f 00 00       	call   80104b80 <release>
  return pid;
80103c06:	83 c4 10             	add    $0x10,%esp
}
80103c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c0c:	89 f0                	mov    %esi,%eax
80103c0e:	5b                   	pop    %ebx
80103c0f:	5e                   	pop    %esi
80103c10:	5f                   	pop    %edi
80103c11:	5d                   	pop    %ebp
80103c12:	c3                   	ret    
80103c13:	90                   	nop
80103c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      parent->numberOfSon++;
80103c18:	83 c1 01             	add    $0x1,%ecx
      parent->son[i] = son;
80103c1b:	89 5c 82 18          	mov    %ebx,0x18(%edx,%eax,4)
      parent->numberOfSon++;
80103c1f:	89 4a 38             	mov    %ecx,0x38(%edx)
80103c22:	e9 4d ff ff ff       	jmp    80103b74 <fork+0x84>
    cprintf("fork: the number of sons is too much\n");
80103c27:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80103c2a:	be ff ff ff ff       	mov    $0xffffffff,%esi
    cprintf("fork: the number of sons is too much\n");
80103c2f:	68 e0 7f 10 80       	push   $0x80107fe0
80103c34:	e8 07 ca ff ff       	call   80100640 <cprintf>
    release(&ptable.lock);
80103c39:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103c40:	e8 3b 0f 00 00       	call   80104b80 <release>
    return -1;
80103c45:	83 c4 10             	add    $0x10,%esp
80103c48:	eb bf                	jmp    80103c09 <fork+0x119>
    release(&ptable.lock);
80103c4a:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80103c4d:	be ff ff ff ff       	mov    $0xffffffff,%esi
    release(&ptable.lock);
80103c52:	68 e0 28 11 80       	push   $0x801128e0
80103c57:	e8 24 0f 00 00       	call   80104b80 <release>
    return -1;
80103c5c:	83 c4 10             	add    $0x10,%esp
80103c5f:	eb a8                	jmp    80103c09 <fork+0x119>
    kfree(np->kstack);
80103c61:	83 ec 0c             	sub    $0xc,%esp
80103c64:	ff 73 08             	pushl  0x8(%ebx)
    return -1;
80103c67:	be ff ff ff ff       	mov    $0xffffffff,%esi
    kfree(np->kstack);
80103c6c:	e8 9f e6 ff ff       	call   80102310 <kfree>
    np->kstack = 0;
80103c71:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103c78:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    release(&ptable.lock);
80103c7f:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103c86:	e8 f5 0e 00 00       	call   80104b80 <release>
    return -1;
80103c8b:	83 c4 10             	add    $0x10,%esp
80103c8e:	e9 76 ff ff ff       	jmp    80103c09 <fork+0x119>
80103c93:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103ca0 <scheduler>:
{
80103ca0:	55                   	push   %ebp
80103ca1:	89 e5                	mov    %esp,%ebp
80103ca3:	56                   	push   %esi
80103ca4:	53                   	push   %ebx
80103ca5:	8b 75 08             	mov    0x8(%ebp),%esi
80103ca8:	90                   	nop
80103ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("sti");
80103cb0:	fb                   	sti    
    acquire(&ptable.lock);
80103cb1:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103cb4:	bb 14 29 11 80       	mov    $0x80112914,%ebx
    acquire(&ptable.lock);
80103cb9:	68 e0 28 11 80       	push   $0x801128e0
80103cbe:	e8 fd 0c 00 00       	call   801049c0 <acquire>
80103cc3:	83 c4 10             	add    $0x10,%esp
80103cc6:	8d 76 00             	lea    0x0(%esi),%esi
80103cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      if(p->state != RUNNABLE)
80103cd0:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103cd4:	75 51                	jne    80103d27 <scheduler+0x87>
      switchuvm(p);
80103cd6:	83 ec 0c             	sub    $0xc,%esp
      proc = p;
80103cd9:	65 89 1d 04 00 00 00 	mov    %ebx,%gs:0x4
      switchuvm(p);
80103ce0:	53                   	push   %ebx
80103ce1:	e8 fa 34 00 00       	call   801071e0 <switchuvm>
      cprintf("acquire: cpuID = \n",cpuID);
80103ce6:	58                   	pop    %eax
80103ce7:	5a                   	pop    %edx
80103ce8:	56                   	push   %esi
80103ce9:	68 8c 7e 10 80       	push   $0x80107e8c
      p->state = RUNNING;
80103cee:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      cprintf("acquire: cpuID = \n",cpuID);
80103cf5:	e8 46 c9 ff ff       	call   80100640 <cprintf>
      swtch(&cpu->scheduler, p->context);
80103cfa:	59                   	pop    %ecx
80103cfb:	58                   	pop    %eax
80103cfc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d02:	ff 73 40             	pushl  0x40(%ebx)
      p->cpuID = cpuID;
80103d05:	89 b3 24 01 00 00    	mov    %esi,0x124(%ebx)
      swtch(&cpu->scheduler, p->context);
80103d0b:	83 c0 04             	add    $0x4,%eax
80103d0e:	50                   	push   %eax
80103d0f:	e8 f7 10 00 00       	call   80104e0b <swtch>
      switchkvm();
80103d14:	e8 a7 34 00 00       	call   801071c0 <switchkvm>
      proc = 0;
80103d19:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80103d20:	00 00 00 00 
80103d24:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d27:	81 c3 28 01 00 00    	add    $0x128,%ebx
80103d2d:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
80103d33:	72 9b                	jb     80103cd0 <scheduler+0x30>
    release(&ptable.lock);
80103d35:	83 ec 0c             	sub    $0xc,%esp
80103d38:	68 e0 28 11 80       	push   $0x801128e0
80103d3d:	e8 3e 0e 00 00       	call   80104b80 <release>
    sti();
80103d42:	83 c4 10             	add    $0x10,%esp
80103d45:	e9 66 ff ff ff       	jmp    80103cb0 <scheduler+0x10>
80103d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103d50 <sched>:
{
80103d50:	55                   	push   %ebp
80103d51:	89 e5                	mov    %esp,%ebp
80103d53:	53                   	push   %ebx
80103d54:	83 ec 10             	sub    $0x10,%esp
  if(!holding(&ptable.lock))
80103d57:	68 e0 28 11 80       	push   $0x801128e0
80103d5c:	e8 6f 0d 00 00       	call   80104ad0 <holding>
80103d61:	83 c4 10             	add    $0x10,%esp
80103d64:	85 c0                	test   %eax,%eax
80103d66:	74 4c                	je     80103db4 <sched+0x64>
  if(cpu->ncli != 1)
80103d68:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80103d6f:	83 ba ac 00 00 00 01 	cmpl   $0x1,0xac(%edx)
80103d76:	75 63                	jne    80103ddb <sched+0x8b>
  if(proc->state == RUNNING)
80103d78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103d7e:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80103d82:	74 4a                	je     80103dce <sched+0x7e>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d84:	9c                   	pushf  
80103d85:	59                   	pop    %ecx
  if(readeflags()&FL_IF)
80103d86:	80 e5 02             	and    $0x2,%ch
80103d89:	75 36                	jne    80103dc1 <sched+0x71>
  swtch(&proc->context, cpu->scheduler);
80103d8b:	83 ec 08             	sub    $0x8,%esp
80103d8e:	83 c0 40             	add    $0x40,%eax
  intena = cpu->intena;
80103d91:	8b 9a b0 00 00 00    	mov    0xb0(%edx),%ebx
  swtch(&proc->context, cpu->scheduler);
80103d97:	ff 72 04             	pushl  0x4(%edx)
80103d9a:	50                   	push   %eax
80103d9b:	e8 6b 10 00 00       	call   80104e0b <swtch>
  cpu->intena = intena;
80103da0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
}
80103da6:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80103da9:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
80103daf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103db2:	c9                   	leave  
80103db3:	c3                   	ret    
    panic("sched ptable.lock");
80103db4:	83 ec 0c             	sub    $0xc,%esp
80103db7:	68 9f 7e 10 80       	push   $0x80107e9f
80103dbc:	e8 af c5 ff ff       	call   80100370 <panic>
    panic("sched interruptible");
80103dc1:	83 ec 0c             	sub    $0xc,%esp
80103dc4:	68 cb 7e 10 80       	push   $0x80107ecb
80103dc9:	e8 a2 c5 ff ff       	call   80100370 <panic>
    panic("sched running");
80103dce:	83 ec 0c             	sub    $0xc,%esp
80103dd1:	68 bd 7e 10 80       	push   $0x80107ebd
80103dd6:	e8 95 c5 ff ff       	call   80100370 <panic>
    panic("sched locks");
80103ddb:	83 ec 0c             	sub    $0xc,%esp
80103dde:	68 b1 7e 10 80       	push   $0x80107eb1
80103de3:	e8 88 c5 ff ff       	call   80100370 <panic>
80103de8:	90                   	nop
80103de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103df0 <exit>:
{
80103df0:	55                   	push   %ebp
  if(proc == initproc)
80103df1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80103df8:	89 e5                	mov    %esp,%ebp
80103dfa:	56                   	push   %esi
80103dfb:	53                   	push   %ebx
80103dfc:	31 db                	xor    %ebx,%ebx
  if(proc == initproc)
80103dfe:	3b 15 bc b5 10 80    	cmp    0x8010b5bc,%edx
80103e04:	0f 84 fa 01 00 00    	je     80104004 <exit+0x214>
80103e0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(proc->ofile[fd]){
80103e10:	8d 73 10             	lea    0x10(%ebx),%esi
80103e13:	8b 44 b2 0c          	mov    0xc(%edx,%esi,4),%eax
80103e17:	85 c0                	test   %eax,%eax
80103e19:	74 1b                	je     80103e36 <exit+0x46>
      fileclose(proc->ofile[fd]);
80103e1b:	83 ec 0c             	sub    $0xc,%esp
80103e1e:	50                   	push   %eax
80103e1f:	e8 ec cf ff ff       	call   80100e10 <fileclose>
      proc->ofile[fd] = 0;
80103e24:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103e2b:	83 c4 10             	add    $0x10,%esp
80103e2e:	c7 44 b2 0c 00 00 00 	movl   $0x0,0xc(%edx,%esi,4)
80103e35:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103e36:	83 c3 01             	add    $0x1,%ebx
80103e39:	83 fb 10             	cmp    $0x10,%ebx
80103e3c:	75 d2                	jne    80103e10 <exit+0x20>
  begin_op();
80103e3e:	e8 ed ed ff ff       	call   80102c30 <begin_op>
  iput(proc->cwd);
80103e43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e49:	83 ec 0c             	sub    $0xc,%esp
80103e4c:	ff b0 8c 00 00 00    	pushl  0x8c(%eax)
80103e52:	e8 29 d9 ff ff       	call   80101780 <iput>
  end_op();
80103e57:	e8 44 ee ff ff       	call   80102ca0 <end_op>
  proc->cwd = 0;
80103e5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e62:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80103e69:	00 00 00 
  acquire(&ptable.lock);
80103e6c:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103e73:	e8 48 0b 00 00       	call   801049c0 <acquire>
  if(proc->parent == 0 && proc -> pthread!=0){
80103e78:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103e7f:	83 c4 10             	add    $0x10,%esp
80103e82:	31 c0                	xor    %eax,%eax
80103e84:	8b 4a 14             	mov    0x14(%edx),%ecx
80103e87:	85 c9                	test   %ecx,%ecx
80103e89:	0f 84 36 01 00 00    	je     80103fc5 <exit+0x1d5>
80103e8f:	90                   	nop
    if(parent->son[i] == son){
80103e90:	3b 54 81 18          	cmp    0x18(%ecx,%eax,4),%edx
80103e94:	0f 84 1a 01 00 00    	je     80103fb4 <exit+0x1c4>
  for(int i=0;i<MAXSON;++i){
80103e9a:	83 c0 01             	add    $0x1,%eax
80103e9d:	83 f8 08             	cmp    $0x8,%eax
80103ea0:	75 ee                	jne    80103e90 <exit+0xa0>
      cprintf("exit: son(%s) doesn't exist in parent(%s)\n", proc->name, proc->parent->name);
80103ea2:	81 c2 90 00 00 00    	add    $0x90,%edx
80103ea8:	81 c1 90 00 00 00    	add    $0x90,%ecx
80103eae:	50                   	push   %eax
80103eaf:	51                   	push   %ecx
80103eb0:	52                   	push   %edx
80103eb1:	68 08 80 10 80       	push   $0x80108008
80103eb6:	e8 85 c7 ff ff       	call   80100640 <cprintf>
80103ebb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103ec2:	83 c4 10             	add    $0x10,%esp
    wakeup1(proc->parent);
80103ec5:	8b 4a 14             	mov    0x14(%edx),%ecx
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ec8:	b8 14 29 11 80       	mov    $0x80112914,%eax
80103ecd:	eb 0d                	jmp    80103edc <exit+0xec>
80103ecf:	90                   	nop
80103ed0:	05 28 01 00 00       	add    $0x128,%eax
80103ed5:	3d 14 73 11 80       	cmp    $0x80117314,%eax
80103eda:	73 1e                	jae    80103efa <exit+0x10a>
    if(p->state == SLEEPING && p->chan == chan)
80103edc:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103ee0:	75 ee                	jne    80103ed0 <exit+0xe0>
80103ee2:	3b 48 44             	cmp    0x44(%eax),%ecx
80103ee5:	75 e9                	jne    80103ed0 <exit+0xe0>
      p->state = RUNNABLE;
80103ee7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103eee:	05 28 01 00 00       	add    $0x128,%eax
80103ef3:	3d 14 73 11 80       	cmp    $0x80117314,%eax
80103ef8:	72 e2                	jb     80103edc <exit+0xec>
80103efa:	bb 14 29 11 80       	mov    $0x80112914,%ebx
80103eff:	eb 19                	jmp    80103f1a <exit+0x12a>
80103f01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f08:	81 c3 28 01 00 00    	add    $0x128,%ebx
80103f0e:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
80103f14:	0f 83 81 00 00 00    	jae    80103f9b <exit+0x1ab>
    if(p->parent == proc){
80103f1a:	39 53 14             	cmp    %edx,0x14(%ebx)
80103f1d:	75 e9                	jne    80103f08 <exit+0x118>
      p->parent = initproc;
80103f1f:	8b 0d bc b5 10 80    	mov    0x8010b5bc,%ecx
  for (int i = 0; i < MAXSON; ++i){
80103f25:	31 c0                	xor    %eax,%eax
      p->parent = initproc;
80103f27:	89 4b 14             	mov    %ecx,0x14(%ebx)
  if(parent->numberOfSon >= MAXSON){
80103f2a:	8b 71 38             	mov    0x38(%ecx),%esi
80103f2d:	83 fe 07             	cmp    $0x7,%esi
80103f30:	7e 56                	jle    80103f88 <exit+0x198>
        cprintf("fork: the number of sons is too much\n");
80103f32:	83 ec 0c             	sub    $0xc,%esp
80103f35:	68 e0 7f 10 80       	push   $0x80107fe0
80103f3a:	e8 01 c7 ff ff       	call   80100640 <cprintf>
80103f3f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103f46:	83 c4 10             	add    $0x10,%esp
      if(p->state == ZOMBIE)
80103f49:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103f4d:	75 b9                	jne    80103f08 <exit+0x118>
        wakeup1(initproc);
80103f4f:	8b 0d bc b5 10 80    	mov    0x8010b5bc,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f55:	b8 14 29 11 80       	mov    $0x80112914,%eax
80103f5a:	eb 10                	jmp    80103f6c <exit+0x17c>
80103f5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103f60:	05 28 01 00 00       	add    $0x128,%eax
80103f65:	3d 14 73 11 80       	cmp    $0x80117314,%eax
80103f6a:	73 9c                	jae    80103f08 <exit+0x118>
    if(p->state == SLEEPING && p->chan == chan)
80103f6c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103f70:	75 ee                	jne    80103f60 <exit+0x170>
80103f72:	3b 48 44             	cmp    0x44(%eax),%ecx
80103f75:	75 e9                	jne    80103f60 <exit+0x170>
      p->state = RUNNABLE;
80103f77:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103f7e:	eb e0                	jmp    80103f60 <exit+0x170>
  for (int i = 0; i < MAXSON; ++i){
80103f80:	83 c0 01             	add    $0x1,%eax
80103f83:	83 f8 08             	cmp    $0x8,%eax
80103f86:	74 c1                	je     80103f49 <exit+0x159>
    if (parent->son[i] == 0){
80103f88:	83 7c 81 18 00       	cmpl   $0x0,0x18(%ecx,%eax,4)
80103f8d:	75 f1                	jne    80103f80 <exit+0x190>
      parent->numberOfSon++;
80103f8f:	83 c6 01             	add    $0x1,%esi
      parent->son[i] = son;
80103f92:	89 5c 81 18          	mov    %ebx,0x18(%ecx,%eax,4)
      parent->numberOfSon++;
80103f96:	89 71 38             	mov    %esi,0x38(%ecx)
80103f99:	eb ae                	jmp    80103f49 <exit+0x159>
  proc->state = ZOMBIE;
80103f9b:	c7 42 0c 05 00 00 00 	movl   $0x5,0xc(%edx)
  sched();
80103fa2:	e8 a9 fd ff ff       	call   80103d50 <sched>
  panic("zombie exit");
80103fa7:	83 ec 0c             	sub    $0xc,%esp
80103faa:	68 ec 7e 10 80       	push   $0x80107eec
80103faf:	e8 bc c3 ff ff       	call   80100370 <panic>
      parent->son[i] = 0;
80103fb4:	c7 44 81 18 00 00 00 	movl   $0x0,0x18(%ecx,%eax,4)
80103fbb:	00 
      parent->numberOfSon--;
80103fbc:	83 69 38 01          	subl   $0x1,0x38(%ecx)
80103fc0:	e9 00 ff ff ff       	jmp    80103ec5 <exit+0xd5>
  if(proc->parent == 0 && proc -> pthread!=0){
80103fc5:	8b 9a 18 01 00 00    	mov    0x118(%edx),%ebx
80103fcb:	85 db                	test   %ebx,%ebx
80103fcd:	0f 84 bd fe ff ff    	je     80103e90 <exit+0xa0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fd3:	b8 14 29 11 80       	mov    $0x80112914,%eax
80103fd8:	eb 16                	jmp    80103ff0 <exit+0x200>
80103fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103fe0:	05 28 01 00 00       	add    $0x128,%eax
80103fe5:	3d 14 73 11 80       	cmp    $0x80117314,%eax
80103fea:	0f 83 0a ff ff ff    	jae    80103efa <exit+0x10a>
    if(p->state == SLEEPING && p->chan == chan)
80103ff0:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103ff4:	75 ea                	jne    80103fe0 <exit+0x1f0>
80103ff6:	3b 58 44             	cmp    0x44(%eax),%ebx
80103ff9:	75 e5                	jne    80103fe0 <exit+0x1f0>
      p->state = RUNNABLE;
80103ffb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80104002:	eb dc                	jmp    80103fe0 <exit+0x1f0>
    panic("init exiting");
80104004:	83 ec 0c             	sub    $0xc,%esp
80104007:	68 df 7e 10 80       	push   $0x80107edf
8010400c:	e8 5f c3 ff ff       	call   80100370 <panic>
80104011:	eb 0d                	jmp    80104020 <yield>
80104013:	90                   	nop
80104014:	90                   	nop
80104015:	90                   	nop
80104016:	90                   	nop
80104017:	90                   	nop
80104018:	90                   	nop
80104019:	90                   	nop
8010401a:	90                   	nop
8010401b:	90                   	nop
8010401c:	90                   	nop
8010401d:	90                   	nop
8010401e:	90                   	nop
8010401f:	90                   	nop

80104020 <yield>:
{
80104020:	55                   	push   %ebp
80104021:	89 e5                	mov    %esp,%ebp
80104023:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104026:	68 e0 28 11 80       	push   $0x801128e0
8010402b:	e8 90 09 00 00       	call   801049c0 <acquire>
  proc->state = RUNNABLE;
80104030:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104036:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010403d:	e8 0e fd ff ff       	call   80103d50 <sched>
  release(&ptable.lock);
80104042:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80104049:	e8 32 0b 00 00       	call   80104b80 <release>
}
8010404e:	83 c4 10             	add    $0x10,%esp
80104051:	c9                   	leave  
80104052:	c3                   	ret    
80104053:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104059:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104060 <sleep>:
  if(proc == 0)
80104060:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80104066:	55                   	push   %ebp
80104067:	89 e5                	mov    %esp,%ebp
80104069:	56                   	push   %esi
8010406a:	53                   	push   %ebx
  if(proc == 0)
8010406b:	85 c0                	test   %eax,%eax
{
8010406d:	8b 75 08             	mov    0x8(%ebp),%esi
80104070:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
80104073:	0f 84 97 00 00 00    	je     80104110 <sleep+0xb0>
  if(lk == 0)
80104079:	85 db                	test   %ebx,%ebx
8010407b:	0f 84 82 00 00 00    	je     80104103 <sleep+0xa3>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104081:	81 fb e0 28 11 80    	cmp    $0x801128e0,%ebx
80104087:	74 57                	je     801040e0 <sleep+0x80>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104089:	83 ec 0c             	sub    $0xc,%esp
8010408c:	68 e0 28 11 80       	push   $0x801128e0
80104091:	e8 2a 09 00 00       	call   801049c0 <acquire>
    release(lk);
80104096:	89 1c 24             	mov    %ebx,(%esp)
80104099:	e8 e2 0a 00 00       	call   80104b80 <release>
  proc->chan = chan;
8010409e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040a4:	89 70 44             	mov    %esi,0x44(%eax)
  proc->state = SLEEPING;
801040a7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801040ae:	e8 9d fc ff ff       	call   80103d50 <sched>
  proc->chan = 0;
801040b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040b9:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
    release(&ptable.lock);
801040c0:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
801040c7:	e8 b4 0a 00 00       	call   80104b80 <release>
    acquire(lk);
801040cc:	89 5d 08             	mov    %ebx,0x8(%ebp)
801040cf:	83 c4 10             	add    $0x10,%esp
}
801040d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040d5:	5b                   	pop    %ebx
801040d6:	5e                   	pop    %esi
801040d7:	5d                   	pop    %ebp
    acquire(lk);
801040d8:	e9 e3 08 00 00       	jmp    801049c0 <acquire>
801040dd:	8d 76 00             	lea    0x0(%esi),%esi
  proc->chan = chan;
801040e0:	89 70 44             	mov    %esi,0x44(%eax)
  proc->state = SLEEPING;
801040e3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801040ea:	e8 61 fc ff ff       	call   80103d50 <sched>
  proc->chan = 0;
801040ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040f5:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
}
801040fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040ff:	5b                   	pop    %ebx
80104100:	5e                   	pop    %esi
80104101:	5d                   	pop    %ebp
80104102:	c3                   	ret    
    panic("sleep without lk");
80104103:	83 ec 0c             	sub    $0xc,%esp
80104106:	68 fe 7e 10 80       	push   $0x80107efe
8010410b:	e8 60 c2 ff ff       	call   80100370 <panic>
    panic("sleep");
80104110:	83 ec 0c             	sub    $0xc,%esp
80104113:	68 f8 7e 10 80       	push   $0x80107ef8
80104118:	e8 53 c2 ff ff       	call   80100370 <panic>
8010411d:	8d 76 00             	lea    0x0(%esi),%esi

80104120 <wait>:
{
80104120:	55                   	push   %ebp
80104121:	89 e5                	mov    %esp,%ebp
80104123:	56                   	push   %esi
80104124:	53                   	push   %ebx
  acquire(&ptable.lock);
80104125:	83 ec 0c             	sub    $0xc,%esp
80104128:	68 e0 28 11 80       	push   $0x801128e0
8010412d:	e8 8e 08 00 00       	call   801049c0 <acquire>
80104132:	83 c4 10             	add    $0x10,%esp
      if(p->parent != proc)
80104135:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    havekids = 0;
8010413b:	31 d2                	xor    %edx,%edx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010413d:	bb 14 29 11 80       	mov    $0x80112914,%ebx
80104142:	eb 12                	jmp    80104156 <wait+0x36>
80104144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104148:	81 c3 28 01 00 00    	add    $0x128,%ebx
8010414e:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
80104154:	73 1e                	jae    80104174 <wait+0x54>
      if(p->parent != proc)
80104156:	39 43 14             	cmp    %eax,0x14(%ebx)
80104159:	75 ed                	jne    80104148 <wait+0x28>
      if(p->state == ZOMBIE){
8010415b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010415f:	74 3f                	je     801041a0 <wait+0x80>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104161:	81 c3 28 01 00 00    	add    $0x128,%ebx
      havekids = 1;
80104167:	ba 01 00 00 00       	mov    $0x1,%edx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010416c:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
80104172:	72 e2                	jb     80104156 <wait+0x36>
    if(!havekids || proc->killed){
80104174:	85 d2                	test   %edx,%edx
80104176:	0f 84 bc 00 00 00    	je     80104238 <wait+0x118>
8010417c:	8b 50 48             	mov    0x48(%eax),%edx
8010417f:	85 d2                	test   %edx,%edx
80104181:	0f 85 b1 00 00 00    	jne    80104238 <wait+0x118>
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104187:	83 ec 08             	sub    $0x8,%esp
8010418a:	68 e0 28 11 80       	push   $0x801128e0
8010418f:	50                   	push   %eax
80104190:	e8 cb fe ff ff       	call   80104060 <sleep>
    havekids = 0;
80104195:	83 c4 10             	add    $0x10,%esp
80104198:	eb 9b                	jmp    80104135 <wait+0x15>
8010419a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        kfree(p->kstack);
801041a0:	83 ec 0c             	sub    $0xc,%esp
801041a3:	ff 73 08             	pushl  0x8(%ebx)
        pid = p->pid;
801041a6:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801041a9:	e8 62 e1 ff ff       	call   80102310 <kfree>
        freevm(p->pgdir);
801041ae:	59                   	pop    %ecx
801041af:	ff 73 04             	pushl  0x4(%ebx)
        p->kstack = 0;
801041b2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801041b9:	e8 72 34 00 00       	call   80107630 <freevm>
        release(&ptable.lock);
801041be:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
        p->pid = 0;
801041c5:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801041cc:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801041d3:	c6 83 90 00 00 00 00 	movb   $0x0,0x90(%ebx)
        p->killed = 0;
801041da:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        p->state = UNUSED;
801041e1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->numberOfSon = 0;
801041e8:	c7 43 38 00 00 00 00 	movl   $0x0,0x38(%ebx)
          p->son[i] = 0;
801041ef:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
801041f6:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
801041fd:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
80104204:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
8010420b:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
80104212:	c7 43 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
80104219:	c7 43 30 00 00 00 00 	movl   $0x0,0x30(%ebx)
80104220:	c7 43 34 00 00 00 00 	movl   $0x0,0x34(%ebx)
        release(&ptable.lock);
80104227:	e8 54 09 00 00       	call   80104b80 <release>
        return pid;
8010422c:	83 c4 10             	add    $0x10,%esp
}
8010422f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104232:	89 f0                	mov    %esi,%eax
80104234:	5b                   	pop    %ebx
80104235:	5e                   	pop    %esi
80104236:	5d                   	pop    %ebp
80104237:	c3                   	ret    
      release(&ptable.lock);
80104238:	83 ec 0c             	sub    $0xc,%esp
      return -1;
8010423b:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104240:	68 e0 28 11 80       	push   $0x801128e0
80104245:	e8 36 09 00 00       	call   80104b80 <release>
      return -1;
8010424a:	83 c4 10             	add    $0x10,%esp
8010424d:	eb e0                	jmp    8010422f <wait+0x10f>
8010424f:	90                   	nop

80104250 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104250:	55                   	push   %ebp
80104251:	89 e5                	mov    %esp,%ebp
80104253:	53                   	push   %ebx
80104254:	83 ec 10             	sub    $0x10,%esp
80104257:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010425a:	68 e0 28 11 80       	push   $0x801128e0
8010425f:	e8 5c 07 00 00       	call   801049c0 <acquire>
80104264:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104267:	b8 14 29 11 80       	mov    $0x80112914,%eax
8010426c:	eb 0e                	jmp    8010427c <wakeup+0x2c>
8010426e:	66 90                	xchg   %ax,%ax
80104270:	05 28 01 00 00       	add    $0x128,%eax
80104275:	3d 14 73 11 80       	cmp    $0x80117314,%eax
8010427a:	73 1e                	jae    8010429a <wakeup+0x4a>
    if(p->state == SLEEPING && p->chan == chan)
8010427c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104280:	75 ee                	jne    80104270 <wakeup+0x20>
80104282:	3b 58 44             	cmp    0x44(%eax),%ebx
80104285:	75 e9                	jne    80104270 <wakeup+0x20>
      p->state = RUNNABLE;
80104287:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010428e:	05 28 01 00 00       	add    $0x128,%eax
80104293:	3d 14 73 11 80       	cmp    $0x80117314,%eax
80104298:	72 e2                	jb     8010427c <wakeup+0x2c>
  wakeup1(chan);
  release(&ptable.lock);
8010429a:	c7 45 08 e0 28 11 80 	movl   $0x801128e0,0x8(%ebp)
}
801042a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042a4:	c9                   	leave  
  release(&ptable.lock);
801042a5:	e9 d6 08 00 00       	jmp    80104b80 <release>
801042aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801042b0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801042b0:	55                   	push   %ebp
801042b1:	89 e5                	mov    %esp,%ebp
801042b3:	53                   	push   %ebx
801042b4:	83 ec 10             	sub    $0x10,%esp
801042b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801042ba:	68 e0 28 11 80       	push   $0x801128e0
801042bf:	e8 fc 06 00 00       	call   801049c0 <acquire>
801042c4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042c7:	b8 14 29 11 80       	mov    $0x80112914,%eax
801042cc:	eb 0e                	jmp    801042dc <kill+0x2c>
801042ce:	66 90                	xchg   %ax,%ax
801042d0:	05 28 01 00 00       	add    $0x128,%eax
801042d5:	3d 14 73 11 80       	cmp    $0x80117314,%eax
801042da:	73 34                	jae    80104310 <kill+0x60>
    if(p->pid == pid){
801042dc:	39 58 10             	cmp    %ebx,0x10(%eax)
801042df:	75 ef                	jne    801042d0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801042e1:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
801042e5:	c7 40 48 01 00 00 00 	movl   $0x1,0x48(%eax)
      if(p->state == SLEEPING)
801042ec:	75 07                	jne    801042f5 <kill+0x45>
        p->state = RUNNABLE;
801042ee:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801042f5:	83 ec 0c             	sub    $0xc,%esp
801042f8:	68 e0 28 11 80       	push   $0x801128e0
801042fd:	e8 7e 08 00 00       	call   80104b80 <release>
      return 0;
80104302:	83 c4 10             	add    $0x10,%esp
80104305:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80104307:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010430a:	c9                   	leave  
8010430b:	c3                   	ret    
8010430c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable.lock);
80104310:	83 ec 0c             	sub    $0xc,%esp
80104313:	68 e0 28 11 80       	push   $0x801128e0
80104318:	e8 63 08 00 00       	call   80104b80 <release>
  return -1;
8010431d:	83 c4 10             	add    $0x10,%esp
80104320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104328:	c9                   	leave  
80104329:	c3                   	ret    
8010432a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104330 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104330:	55                   	push   %ebp
80104331:	89 e5                	mov    %esp,%ebp
80104333:	57                   	push   %edi
80104334:	56                   	push   %esi
80104335:	53                   	push   %ebx
80104336:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104339:	be 14 29 11 80       	mov    $0x80112914,%esi
{
8010433e:	83 ec 3c             	sub    $0x3c,%esp
80104341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p->state == UNUSED)
80104348:	8b 46 0c             	mov    0xc(%esi),%eax
8010434b:	85 c0                	test   %eax,%eax
8010434d:	0f 84 97 00 00 00    	je     801043ea <procdump+0xba>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104353:	83 f8 05             	cmp    $0x5,%eax
      state = states[p->state];
    else
      state = "???";
80104356:	b9 0f 7f 10 80       	mov    $0x80107f0f,%ecx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010435b:	77 11                	ja     8010436e <procdump+0x3e>
8010435d:	8b 0c 85 80 80 10 80 	mov    -0x7fef7f80(,%eax,4),%ecx
      state = "???";
80104364:	b8 0f 7f 10 80       	mov    $0x80107f0f,%eax
80104369:	85 c9                	test   %ecx,%ecx
8010436b:	0f 44 c8             	cmove  %eax,%ecx
    cprintf("\npid:%d, state: %s, name: %s, priority = %d, numOfSon is %d, cpuID = %d\n", p->pid, state, p->name, p->priority,p->numberOfSon,p->cpuID);
8010436e:	8d 86 90 00 00 00    	lea    0x90(%esi),%eax
80104374:	83 ec 04             	sub    $0x4,%esp
80104377:	ff b6 24 01 00 00    	pushl  0x124(%esi)
8010437d:	ff 76 38             	pushl  0x38(%esi)
80104380:	ff b6 20 01 00 00    	pushl  0x120(%esi)
80104386:	50                   	push   %eax
80104387:	51                   	push   %ecx
80104388:	ff 76 10             	pushl  0x10(%esi)
8010438b:	68 34 80 10 80       	push   $0x80108034
80104390:	e8 ab c2 ff ff       	call   80100640 <cprintf>
    //     }
    //   }
    //   cprintf("\n");
    // }
    
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
80104395:	8b 86 a8 00 00 00    	mov    0xa8(%esi),%eax
8010439b:	83 c4 20             	add    $0x20,%esp
8010439e:	85 c0                	test   %eax,%eax
801043a0:	74 32                	je     801043d4 <procdump+0xa4>
801043a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("start: %d, length: %d\n",p->vm[i].start,p->vm[i].length);
801043a8:	8d 04 40             	lea    (%eax,%eax,2),%eax
801043ab:	83 ec 04             	sub    $0x4,%esp
801043ae:	8d 3c 86             	lea    (%esi,%eax,4),%edi
801043b1:	ff b7 a4 00 00 00    	pushl  0xa4(%edi)
801043b7:	ff b7 a0 00 00 00    	pushl  0xa0(%edi)
801043bd:	68 13 7f 10 80       	push   $0x80107f13
801043c2:	e8 79 c2 ff ff       	call   80100640 <cprintf>
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
801043c7:	8b 87 a8 00 00 00    	mov    0xa8(%edi),%eax
801043cd:	83 c4 10             	add    $0x10,%esp
801043d0:	85 c0                	test   %eax,%eax
801043d2:	75 d4                	jne    801043a8 <procdump+0x78>
    }
    if(p->state == SLEEPING){
801043d4:	83 7e 0c 02          	cmpl   $0x2,0xc(%esi)
801043d8:	74 2e                	je     80104408 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801043da:	83 ec 0c             	sub    $0xc,%esp
801043dd:	68 43 7f 10 80       	push   $0x80107f43
801043e2:	e8 59 c2 ff ff       	call   80100640 <cprintf>
801043e7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043ea:	81 c6 28 01 00 00    	add    $0x128,%esi
801043f0:	81 fe 14 73 11 80    	cmp    $0x80117314,%esi
801043f6:	0f 82 4c ff ff ff    	jb     80104348 <procdump+0x18>
  }
}
801043fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043ff:	5b                   	pop    %ebx
80104400:	5e                   	pop    %esi
80104401:	5f                   	pop    %edi
80104402:	5d                   	pop    %ebp
80104403:	c3                   	ret    
80104404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104408:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010440b:	83 ec 08             	sub    $0x8,%esp
8010440e:	8d 7d c0             	lea    -0x40(%ebp),%edi
80104411:	50                   	push   %eax
80104412:	8b 46 40             	mov    0x40(%esi),%eax
80104415:	8b 40 0c             	mov    0xc(%eax),%eax
80104418:	83 c0 08             	add    $0x8,%eax
8010441b:	50                   	push   %eax
8010441c:	e8 5f 06 00 00       	call   80104a80 <getcallerpcs>
80104421:	83 c4 10             	add    $0x10,%esp
80104424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      for(i=0; i<10 && pc[i] != 0; i++)
80104428:	8b 07                	mov    (%edi),%eax
8010442a:	85 c0                	test   %eax,%eax
8010442c:	74 ac                	je     801043da <procdump+0xaa>
        cprintf(" %p", pc[i]);
8010442e:	83 ec 08             	sub    $0x8,%esp
80104431:	83 c7 04             	add    $0x4,%edi
80104434:	50                   	push   %eax
80104435:	68 e2 78 10 80       	push   $0x801078e2
8010443a:	e8 01 c2 ff ff       	call   80100640 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
8010443f:	83 c4 10             	add    $0x10,%esp
80104442:	39 df                	cmp    %ebx,%edi
80104444:	75 e2                	jne    80104428 <procdump+0xf8>
80104446:	eb 92                	jmp    801043da <procdump+0xaa>
80104448:	90                   	nop
80104449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104450 <mygrowproc>:


int mygrowproc(int n){
80104450:	55                   	push   %ebp
80104451:	89 e5                	mov    %esp,%ebp
80104453:	57                   	push   %edi
80104454:	56                   	push   %esi
80104455:	53                   	push   %ebx
80104456:	83 ec 1c             	sub    $0x1c,%esp
  struct vma *vm = proc->vm;
80104459:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  int start = proc->sz;
  int pre=0;
  int i,k;
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
8010445f:	8b b8 a8 00 00 00    	mov    0xa8(%eax),%edi
  struct vma *vm = proc->vm;
80104465:	8d 88 a0 00 00 00    	lea    0xa0(%eax),%ecx
8010446b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  int start = proc->sz;
8010446e:	8b 18                	mov    (%eax),%ebx
  struct vma *vm = proc->vm;
80104470:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104473:	85 ff                	test   %edi,%edi
80104475:	0f 84 d5 00 00 00    	je     80104550 <mygrowproc+0x100>
  {
    if (start + n < vm[i].start)
8010447b:	8d 04 7f             	lea    (%edi,%edi,2),%eax
8010447e:	8d 14 81             	lea    (%ecx,%eax,4),%edx
80104481:	8b 45 08             	mov    0x8(%ebp),%eax
80104484:	8b 0a                	mov    (%edx),%ecx
80104486:	01 d8                	add    %ebx,%eax
80104488:	39 c8                	cmp    %ecx,%eax
8010448a:	7d 22                	jge    801044ae <mygrowproc+0x5e>
8010448c:	e9 cf 00 00 00       	jmp    80104560 <mygrowproc+0x110>
80104491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104498:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010449b:	8d 14 40             	lea    (%eax,%eax,2),%edx
8010449e:	8d 14 96             	lea    (%esi,%edx,4),%edx
801044a1:	8b 75 08             	mov    0x8(%ebp),%esi
801044a4:	8b 0a                	mov    (%edx),%ecx
801044a6:	01 de                	add    %ebx,%esi
801044a8:	39 ce                	cmp    %ecx,%esi
801044aa:	7c 0e                	jl     801044ba <mygrowproc+0x6a>
801044ac:	89 c7                	mov    %eax,%edi
    {
      break;
    }
    start = vm[i].start + vm[i].length;
801044ae:	8b 5a 04             	mov    0x4(%edx),%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801044b1:	8b 42 08             	mov    0x8(%edx),%eax
    start = vm[i].start + vm[i].length;
801044b4:	01 cb                	add    %ecx,%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801044b6:	85 c0                	test   %eax,%eax
801044b8:	75 de                	jne    80104498 <mygrowproc+0x48>
801044ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
801044bd:	b9 01 00 00 00       	mov    $0x1,%ecx
801044c2:	8d 96 ac 00 00 00    	lea    0xac(%esi),%edx
801044c8:	90                   	nop
801044c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pre = i;
  }
  for(k = 1; k < 10; ++k){
    if(vm[k].next == -1){
801044d0:	83 7a 08 ff          	cmpl   $0xffffffff,0x8(%edx)
801044d4:	74 2a                	je     80104500 <mygrowproc+0xb0>
  for(k = 1; k < 10; ++k){
801044d6:	83 c1 01             	add    $0x1,%ecx
801044d9:	83 c2 0c             	add    $0xc,%edx
801044dc:	83 f9 0a             	cmp    $0xa,%ecx
801044df:	75 ef                	jne    801044d0 <mygrowproc+0x80>
      myallocuvm(proc->pgdir, start , start + n);
      switchuvm(proc);
      return start;
    }
  }
  switchuvm(proc);
801044e1:	83 ec 0c             	sub    $0xc,%esp
801044e4:	ff 75 e0             	pushl  -0x20(%ebp)
  return 0; 
801044e7:	31 db                	xor    %ebx,%ebx
  switchuvm(proc);
801044e9:	e8 f2 2c 00 00       	call   801071e0 <switchuvm>
  return 0; 
801044ee:	83 c4 10             	add    $0x10,%esp
}
801044f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044f4:	89 d8                	mov    %ebx,%eax
801044f6:	5b                   	pop    %ebx
801044f7:	5e                   	pop    %esi
801044f8:	5f                   	pop    %edi
801044f9:	5d                   	pop    %ebp
801044fa:	c3                   	ret    
801044fb:	90                   	nop
801044fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      vm[k].next = i;
80104500:	89 42 08             	mov    %eax,0x8(%edx)
      vm[k].length = n;
80104503:	8b 45 08             	mov    0x8(%ebp),%eax
      myallocuvm(proc->pgdir, start , start + n);
80104506:	83 ec 04             	sub    $0x4,%esp
      vm[k].start = start;
80104509:	89 1a                	mov    %ebx,(%edx)
      vm[k].length = n;
8010450b:	89 42 04             	mov    %eax,0x4(%edx)
      vm[pre].next = k;
8010450e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
80104511:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80104514:	89 4c 87 08          	mov    %ecx,0x8(%edi,%eax,4)
      myallocuvm(proc->pgdir, start , start + n);
80104518:	8b 45 08             	mov    0x8(%ebp),%eax
8010451b:	01 d8                	add    %ebx,%eax
8010451d:	50                   	push   %eax
8010451e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104524:	53                   	push   %ebx
80104525:	ff 70 04             	pushl  0x4(%eax)
80104528:	e8 c3 2f 00 00       	call   801074f0 <myallocuvm>
      switchuvm(proc);
8010452d:	58                   	pop    %eax
8010452e:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
80104535:	e8 a6 2c 00 00       	call   801071e0 <switchuvm>
      return start;
8010453a:	83 c4 10             	add    $0x10,%esp
}
8010453d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104540:	89 d8                	mov    %ebx,%eax
80104542:	5b                   	pop    %ebx
80104543:	5e                   	pop    %esi
80104544:	5f                   	pop    %edi
80104545:	5d                   	pop    %ebp
80104546:	c3                   	ret    
80104547:	89 f6                	mov    %esi,%esi
80104549:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104550:	31 c0                	xor    %eax,%eax
80104552:	e9 63 ff ff ff       	jmp    801044ba <mygrowproc+0x6a>
80104557:	89 f6                	mov    %esi,%esi
80104559:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if (start + n < vm[i].start)
80104560:	89 f8                	mov    %edi,%eax
  int pre=0;
80104562:	31 ff                	xor    %edi,%edi
80104564:	e9 51 ff ff ff       	jmp    801044ba <mygrowproc+0x6a>
80104569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104570 <myreduceproc>:

int myreduceproc(int start){
80104570:	55                   	push   %ebp
80104571:	89 e5                	mov    %esp,%ebp
80104573:	57                   	push   %edi
80104574:	56                   	push   %esi
80104575:	53                   	push   %ebx
80104576:	83 ec 0c             	sub    $0xc,%esp
  int prev=0;
  int i;
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
80104579:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
int myreduceproc(int start){
80104580:	8b 75 08             	mov    0x8(%ebp),%esi
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
80104583:	8b 9a a8 00 00 00    	mov    0xa8(%edx),%ebx
80104589:	85 db                	test   %ebx,%ebx
8010458b:	74 2f                	je     801045bc <myreduceproc+0x4c>
      if(proc->vm[i].start == start){
8010458d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
80104590:	3b b4 82 a0 00 00 00 	cmp    0xa0(%edx,%eax,4),%esi
80104597:	75 15                	jne    801045ae <myreduceproc+0x3e>
80104599:	eb 45                	jmp    801045e0 <myreduceproc+0x70>
8010459b:	90                   	nop
8010459c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801045a0:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
801045a3:	39 b4 8a a0 00 00 00 	cmp    %esi,0xa0(%edx,%ecx,4)
801045aa:	74 38                	je     801045e4 <myreduceproc+0x74>
801045ac:	89 c3                	mov    %eax,%ebx
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
801045ae:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
801045b1:	8b 84 82 a8 00 00 00 	mov    0xa8(%edx,%eax,4),%eax
801045b8:	85 c0                	test   %eax,%eax
801045ba:	75 e4                	jne    801045a0 <myreduceproc+0x30>
        switchuvm(proc);
        return 0;
      }
      prev=i;
  }
  cprintf("warning: free vma at %x! \n",start);
801045bc:	83 ec 08             	sub    $0x8,%esp
801045bf:	56                   	push   %esi
801045c0:	68 2a 7f 10 80       	push   $0x80107f2a
801045c5:	e8 76 c0 ff ff       	call   80100640 <cprintf>
  return -1;
801045ca:	83 c4 10             	add    $0x10,%esp
}
801045cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
801045d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801045d5:	5b                   	pop    %ebx
801045d6:	5e                   	pop    %esi
801045d7:	5f                   	pop    %edi
801045d8:	5d                   	pop    %ebp
801045d9:	c3                   	ret    
801045da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(proc->vm[i].start == start){
801045e0:	89 d8                	mov    %ebx,%eax
  int prev=0;
801045e2:	31 db                	xor    %ebx,%ebx
        mydeallocuvm(proc->pgdir,start,start+proc->vm[i].length);
801045e4:	8d 3c 40             	lea    (%eax,%eax,2),%edi
801045e7:	83 ec 04             	sub    $0x4,%esp
801045ea:	c1 e7 02             	shl    $0x2,%edi
801045ed:	8b 84 3a a4 00 00 00 	mov    0xa4(%edx,%edi,1),%eax
801045f4:	01 f0                	add    %esi,%eax
801045f6:	50                   	push   %eax
801045f7:	56                   	push   %esi
801045f8:	ff 72 04             	pushl  0x4(%edx)
801045fb:	e8 90 2f 00 00       	call   80107590 <mydeallocuvm>
        proc->vm[prev].next = proc->vm[i].next;
80104600:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104606:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
80104609:	01 c7                	add    %eax,%edi
8010460b:	8b 8f a8 00 00 00    	mov    0xa8(%edi),%ecx
80104611:	89 8c 90 a8 00 00 00 	mov    %ecx,0xa8(%eax,%edx,4)
        proc->vm[i].next=-1;
80104618:	c7 87 a8 00 00 00 ff 	movl   $0xffffffff,0xa8(%edi)
8010461f:	ff ff ff 
        switchuvm(proc);
80104622:	89 04 24             	mov    %eax,(%esp)
80104625:	e8 b6 2b 00 00       	call   801071e0 <switchuvm>
        return 0;
8010462a:	83 c4 10             	add    $0x10,%esp
}
8010462d:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
80104630:	31 c0                	xor    %eax,%eax
}
80104632:	5b                   	pop    %ebx
80104633:	5e                   	pop    %esi
80104634:	5f                   	pop    %edi
80104635:	5d                   	pop    %ebp
80104636:	c3                   	ret    
80104637:	89 f6                	mov    %esi,%esi
80104639:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104640 <clone>:

// malloc space for new stack then pass to clone
int clone(void(*fcn)(void*), void* arg, void* stack)
{
80104640:	55                   	push   %ebp
80104641:	89 e5                	mov    %esp,%ebp
80104643:	57                   	push   %edi
80104644:	56                   	push   %esi
80104645:	53                   	push   %ebx
80104646:	83 ec 1c             	sub    $0x1c,%esp
//  cprintf("in clone, stack start addr = %p\n", stack);
  struct proc *curproc = proc;  // 调用 clone 的进程
80104649:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104650:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  struct proc *np;

  // allocate a PCB
  if((np = allocproc()) == 0)
80104653:	e8 78 f1 ff ff       	call   801037d0 <allocproc>
80104658:	85 c0                	test   %eax,%eax
8010465a:	0f 84 f1 00 00 00    	je     80104751 <clone+0x111>
   return -1; 
  
  // For clone, don't need to copy entire address space like fork
  np->pgdir = curproc->pgdir;  // 线程间公用页表
80104660:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104663:	89 c3                	mov    %eax,%ebx
  np->sz = curproc->sz;
  np->pthread = curproc;       // exit 时唤醒用
  np->parent = 0;
  *np->tf = *curproc->tf;      // 继承 trapframe
80104665:	b9 13 00 00 00       	mov    $0x13,%ecx
8010466a:	8b 7b 3c             	mov    0x3c(%ebx),%edi
  np->pgdir = curproc->pgdir;  // 线程间公用页表
8010466d:	8b 42 04             	mov    0x4(%edx),%eax
80104670:	89 43 04             	mov    %eax,0x4(%ebx)
  np->sz = curproc->sz;
80104673:	8b 02                	mov    (%edx),%eax
  np->pthread = curproc;       // exit 时唤醒用
80104675:	89 93 18 01 00 00    	mov    %edx,0x118(%ebx)
  np->parent = 0;
8010467b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  np->sz = curproc->sz;
80104682:	89 03                	mov    %eax,(%ebx)
  *np->tf = *curproc->tf;      // 继承 trapframe
80104684:	8b 72 3c             	mov    0x3c(%edx),%esi
80104687:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  int* sp = stack + 4096 - 8;

  // Clone may need to change other registers than ones seen in fork
  np->tf->eip = (int)fcn;
80104689:	8b 4d 08             	mov    0x8(%ebp),%ecx

  // setup new user stack and some pointers
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
  *sp = 0xffffffff;     // end of stack (fake return PC value)

  for(int i = 0; i < NOFILE; i++)
8010468c:	31 f6                	xor    %esi,%esi
8010468e:	89 d7                	mov    %edx,%edi
  np->tf->eip = (int)fcn;
80104690:	8b 43 3c             	mov    0x3c(%ebx),%eax
80104693:	89 48 38             	mov    %ecx,0x38(%eax)
  int* sp = stack + 4096 - 8;
80104696:	8b 45 10             	mov    0x10(%ebp),%eax
  np->tf->esp = (int)sp;  // top of stack
80104699:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
  int* sp = stack + 4096 - 8;
8010469c:	05 f8 0f 00 00       	add    $0xff8,%eax
  np->tf->esp = (int)sp;  // top of stack
801046a1:	89 41 44             	mov    %eax,0x44(%ecx)
  np->tf->ebp = (int)sp;  // 栈帧指针 
801046a4:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
801046a7:	89 41 08             	mov    %eax,0x8(%ecx)
  np->tf->eax = 0;    // Clear %eax so that clone returns 0 in the child
801046aa:	8b 43 3c             	mov    0x3c(%ebx),%eax
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
801046ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
  np->tf->eax = 0;    // Clear %eax so that clone returns 0 in the child
801046b0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
801046b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  *sp = 0xffffffff;     // end of stack (fake return PC value)
801046ba:	c7 81 f8 0f 00 00 ff 	movl   $0xffffffff,0xff8(%ecx)
801046c1:	ff ff ff 
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
801046c4:	89 81 fc 0f 00 00    	mov    %eax,0xffc(%ecx)
801046ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[i])
801046d0:	8b 44 b7 4c          	mov    0x4c(%edi,%esi,4),%eax
801046d4:	85 c0                	test   %eax,%eax
801046d6:	74 10                	je     801046e8 <clone+0xa8>
      np->ofile[i] = filedup(curproc->ofile[i]);
801046d8:	83 ec 0c             	sub    $0xc,%esp
801046db:	50                   	push   %eax
801046dc:	e8 df c6 ff ff       	call   80100dc0 <filedup>
801046e1:	83 c4 10             	add    $0x10,%esp
801046e4:	89 44 b3 4c          	mov    %eax,0x4c(%ebx,%esi,4)
  for(int i = 0; i < NOFILE; i++)
801046e8:	83 c6 01             	add    $0x1,%esi
801046eb:	83 fe 10             	cmp    $0x10,%esi
801046ee:	75 e0                	jne    801046d0 <clone+0x90>
  np->cwd = idup(curproc->cwd);
801046f0:	83 ec 0c             	sub    $0xc,%esp
801046f3:	ff b7 8c 00 00 00    	pushl  0x8c(%edi)
801046f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801046fc:	e8 df ce ff ff       	call   801015e0 <idup>

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104701:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  np->cwd = idup(curproc->cwd);
80104704:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010470a:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80104710:	83 c4 0c             	add    $0xc,%esp
80104713:	6a 10                	push   $0x10
80104715:	81 c2 90 00 00 00    	add    $0x90,%edx
8010471b:	52                   	push   %edx
8010471c:	50                   	push   %eax
8010471d:	e8 8e 06 00 00       	call   80104db0 <safestrcpy>
  
  int pid = np->pid;
80104722:	8b 73 10             	mov    0x10(%ebx),%esi
  
  acquire(&ptable.lock);
80104725:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
8010472c:	e8 8f 02 00 00       	call   801049c0 <acquire>
  np->state = RUNNABLE;
80104731:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80104738:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
8010473f:	e8 3c 04 00 00       	call   80104b80 <release>
 
  // return the ID of the new thread
  return pid;
80104744:	83 c4 10             	add    $0x10,%esp
}
80104747:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010474a:	89 f0                	mov    %esi,%eax
8010474c:	5b                   	pop    %ebx
8010474d:	5e                   	pop    %esi
8010474e:	5f                   	pop    %edi
8010474f:	5d                   	pop    %ebp
80104750:	c3                   	ret    
   return -1; 
80104751:	be ff ff ff ff       	mov    $0xffffffff,%esi
80104756:	eb ef                	jmp    80104747 <clone+0x107>
80104758:	90                   	nop
80104759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104760 <join>:

int
join(void **stack)
{
80104760:	55                   	push   %ebp
80104761:	89 e5                	mov    %esp,%ebp
80104763:	56                   	push   %esi
80104764:	53                   	push   %ebx
  cprintf("in join, stack pointer = %p\n",*stack);
80104765:	8b 45 08             	mov    0x8(%ebp),%eax
80104768:	83 ec 08             	sub    $0x8,%esp
8010476b:	ff 30                	pushl  (%eax)
8010476d:	68 45 7f 10 80       	push   $0x80107f45
80104772:	e8 c9 be ff ff       	call   80100640 <cprintf>
  struct proc *curproc = proc;
  struct proc *p;
  int havekids;

  acquire(&ptable.lock);
80104777:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
  struct proc *curproc = proc;
8010477e:	65 8b 35 04 00 00 00 	mov    %gs:0x4,%esi
  acquire(&ptable.lock);
80104785:	e8 36 02 00 00       	call   801049c0 <acquire>
8010478a:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010478d:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010478f:	bb 14 29 11 80       	mov    $0x80112914,%ebx
80104794:	eb 18                	jmp    801047ae <join+0x4e>
80104796:	8d 76 00             	lea    0x0(%esi),%esi
80104799:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801047a0:	81 c3 28 01 00 00    	add    $0x128,%ebx
801047a6:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
801047ac:	73 21                	jae    801047cf <join+0x6f>
      if(p->pthread != curproc)
801047ae:	39 b3 18 01 00 00    	cmp    %esi,0x118(%ebx)
801047b4:	75 ea                	jne    801047a0 <join+0x40>
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
801047b6:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801047ba:	74 34                	je     801047f0 <join+0x90>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047bc:	81 c3 28 01 00 00    	add    $0x128,%ebx
      havekids = 1;
801047c2:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047c7:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
801047cd:	72 df                	jb     801047ae <join+0x4e>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801047cf:	85 c0                	test   %eax,%eax
801047d1:	74 77                	je     8010484a <join+0xea>
801047d3:	8b 46 48             	mov    0x48(%esi),%eax
801047d6:	85 c0                	test   %eax,%eax
801047d8:	75 70                	jne    8010484a <join+0xea>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801047da:	83 ec 08             	sub    $0x8,%esp
801047dd:	68 e0 28 11 80       	push   $0x801128e0
801047e2:	56                   	push   %esi
801047e3:	e8 78 f8 ff ff       	call   80104060 <sleep>
    havekids = 0;
801047e8:	83 c4 10             	add    $0x10,%esp
801047eb:	eb a0                	jmp    8010478d <join+0x2d>
801047ed:	8d 76 00             	lea    0x0(%esi),%esi
        kfree(p->kstack);
801047f0:	83 ec 0c             	sub    $0xc,%esp
801047f3:	ff 73 08             	pushl  0x8(%ebx)
        int pid = p->pid;
801047f6:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801047f9:	e8 12 db ff ff       	call   80102310 <kfree>
        release(&ptable.lock);
801047fe:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
        p->kstack = 0;
80104805:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        p->state = UNUSED;
8010480c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
80104813:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010481a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->pthread = 0;
80104821:	c7 83 18 01 00 00 00 	movl   $0x0,0x118(%ebx)
80104828:	00 00 00 
        p->name[0] = 0;
8010482b:	c6 83 90 00 00 00 00 	movb   $0x0,0x90(%ebx)
        p->killed = 0;
80104832:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        release(&ptable.lock);
80104839:	e8 42 03 00 00       	call   80104b80 <release>
        return pid;
8010483e:	83 c4 10             	add    $0x10,%esp
  }

  return 0;
}
80104841:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104844:	89 f0                	mov    %esi,%eax
80104846:	5b                   	pop    %ebx
80104847:	5e                   	pop    %esi
80104848:	5d                   	pop    %ebp
80104849:	c3                   	ret    
      release(&ptable.lock);
8010484a:	83 ec 0c             	sub    $0xc,%esp
      return -1;
8010484d:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104852:	68 e0 28 11 80       	push   $0x801128e0
80104857:	e8 24 03 00 00       	call   80104b80 <release>
      return -1;
8010485c:	83 c4 10             	add    $0x10,%esp
8010485f:	eb e0                	jmp    80104841 <join+0xe1>
80104861:	eb 0d                	jmp    80104870 <cps>
80104863:	90                   	nop
80104864:	90                   	nop
80104865:	90                   	nop
80104866:	90                   	nop
80104867:	90                   	nop
80104868:	90                   	nop
80104869:	90                   	nop
8010486a:	90                   	nop
8010486b:	90                   	nop
8010486c:	90                   	nop
8010486d:	90                   	nop
8010486e:	90                   	nop
8010486f:	90                   	nop

80104870 <cps>:

int cps(void)
{
80104870:	55                   	push   %ebp
80104871:	89 e5                	mov    %esp,%ebp
80104873:	53                   	push   %ebx
80104874:	83 ec 10             	sub    $0x10,%esp
  asm volatile("sti");
80104877:	fb                   	sti    
  struct proc *p;
  sti(); // Enable interrupts
  acquire(&ptable.lock);
80104878:	68 e0 28 11 80       	push   $0x801128e0
  cprintf("name\tpid\tstate\t\tpriority\n");
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010487d:	bb 14 29 11 80       	mov    $0x80112914,%ebx
  acquire(&ptable.lock);
80104882:	e8 39 01 00 00       	call   801049c0 <acquire>
  cprintf("name\tpid\tstate\t\tpriority\n");
80104887:	c7 04 24 62 7f 10 80 	movl   $0x80107f62,(%esp)
8010488e:	e8 ad bd ff ff       	call   80100640 <cprintf>
80104893:	83 c4 10             	add    $0x10,%esp
80104896:	eb 20                	jmp    801048b8 <cps+0x48>
80104898:	90                   	nop
80104899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  {
    if (p->state == SLEEPING)
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
    else if (p->state == RUNNING)
801048a0:	83 f8 04             	cmp    $0x4,%eax
801048a3:	74 5b                	je     80104900 <cps+0x90>
      cprintf("%s\t%d\tRUNNING\t\t%d\n", p->name, p->pid, p->priority);
    else if (p->state == RUNNABLE)
801048a5:	83 f8 03             	cmp    $0x3,%eax
801048a8:	74 76                	je     80104920 <cps+0xb0>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048aa:	81 c3 28 01 00 00    	add    $0x128,%ebx
801048b0:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
801048b6:	73 33                	jae    801048eb <cps+0x7b>
    if (p->state == SLEEPING)
801048b8:	8b 43 0c             	mov    0xc(%ebx),%eax
801048bb:	83 f8 02             	cmp    $0x2,%eax
801048be:	75 e0                	jne    801048a0 <cps+0x30>
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
801048c0:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
801048c6:	ff b3 20 01 00 00    	pushl  0x120(%ebx)
801048cc:	ff 73 10             	pushl  0x10(%ebx)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048cf:	81 c3 28 01 00 00    	add    $0x128,%ebx
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
801048d5:	50                   	push   %eax
801048d6:	68 7c 7f 10 80       	push   $0x80107f7c
801048db:	e8 60 bd ff ff       	call   80100640 <cprintf>
801048e0:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048e3:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
801048e9:	72 cd                	jb     801048b8 <cps+0x48>
      cprintf("%s\t%d\tRUNNABLE\t%d\n", p->name, p->pid, p->priority);
  }
  release(&ptable.lock);
801048eb:	83 ec 0c             	sub    $0xc,%esp
801048ee:	68 e0 28 11 80       	push   $0x801128e0
801048f3:	e8 88 02 00 00       	call   80104b80 <release>
  return 0;
}
801048f8:	31 c0                	xor    %eax,%eax
801048fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048fd:	c9                   	leave  
801048fe:	c3                   	ret    
801048ff:	90                   	nop
      cprintf("%s\t%d\tRUNNING\t\t%d\n", p->name, p->pid, p->priority);
80104900:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80104906:	ff b3 20 01 00 00    	pushl  0x120(%ebx)
8010490c:	ff 73 10             	pushl  0x10(%ebx)
8010490f:	50                   	push   %eax
80104910:	68 8f 7f 10 80       	push   $0x80107f8f
80104915:	e8 26 bd ff ff       	call   80100640 <cprintf>
8010491a:	83 c4 10             	add    $0x10,%esp
8010491d:	eb 8b                	jmp    801048aa <cps+0x3a>
8010491f:	90                   	nop
      cprintf("%s\t%d\tRUNNABLE\t%d\n", p->name, p->pid, p->priority);
80104920:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80104926:	ff b3 20 01 00 00    	pushl  0x120(%ebx)
8010492c:	ff 73 10             	pushl  0x10(%ebx)
8010492f:	50                   	push   %eax
80104930:	68 a2 7f 10 80       	push   $0x80107fa2
80104935:	e8 06 bd ff ff       	call   80100640 <cprintf>
8010493a:	83 c4 10             	add    $0x10,%esp
8010493d:	e9 68 ff ff ff       	jmp    801048aa <cps+0x3a>
80104942:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104949:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104950 <chpri>:

int chpri(int pid, int priority)
{
80104950:	55                   	push   %ebp
80104951:	89 e5                	mov    %esp,%ebp
80104953:	53                   	push   %ebx
80104954:	83 ec 10             	sub    $0x10,%esp
80104957:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;
  acquire(&ptable.lock);
8010495a:	68 e0 28 11 80       	push   $0x801128e0
8010495f:	e8 5c 00 00 00       	call   801049c0 <acquire>
80104964:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104967:	ba 14 29 11 80       	mov    $0x80112914,%edx
8010496c:	eb 10                	jmp    8010497e <chpri+0x2e>
8010496e:	66 90                	xchg   %ax,%ax
80104970:	81 c2 28 01 00 00    	add    $0x128,%edx
80104976:	81 fa 14 73 11 80    	cmp    $0x80117314,%edx
8010497c:	73 0e                	jae    8010498c <chpri+0x3c>
  {
    if (p->pid == pid)
8010497e:	39 5a 10             	cmp    %ebx,0x10(%edx)
80104981:	75 ed                	jne    80104970 <chpri+0x20>
    {
      p->priority = priority;
80104983:	8b 45 0c             	mov    0xc(%ebp),%eax
80104986:	89 82 20 01 00 00    	mov    %eax,0x120(%edx)
      break;
    }
  }
  release(&ptable.lock);
8010498c:	83 ec 0c             	sub    $0xc,%esp
8010498f:	68 e0 28 11 80       	push   $0x801128e0
80104994:	e8 e7 01 00 00       	call   80104b80 <release>
  return pid;
}
80104999:	89 d8                	mov    %ebx,%eax
8010499b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010499e:	c9                   	leave  
8010499f:	c3                   	ret    

801049a0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801049a0:	55                   	push   %ebp
801049a1:	89 e5                	mov    %esp,%ebp
801049a3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801049a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
801049a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
801049af:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
801049b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801049b9:	5d                   	pop    %ebp
801049ba:	c3                   	ret    
801049bb:	90                   	nop
801049bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801049c0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801049c0:	55                   	push   %ebp
801049c1:	89 e5                	mov    %esp,%ebp
801049c3:	53                   	push   %ebx
801049c4:	83 ec 04             	sub    $0x4,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801049c7:	9c                   	pushf  
801049c8:	5a                   	pop    %edx
  asm volatile("cli");
801049c9:	fa                   	cli    
{
  int eflags;

  eflags = readeflags();
  cli();
  if(cpu->ncli == 0)
801049ca:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
801049d1:	8b 81 ac 00 00 00    	mov    0xac(%ecx),%eax
801049d7:	85 c0                	test   %eax,%eax
801049d9:	75 0c                	jne    801049e7 <acquire+0x27>
    cpu->intena = eflags & FL_IF;
801049db:	81 e2 00 02 00 00    	and    $0x200,%edx
801049e1:	89 91 b0 00 00 00    	mov    %edx,0xb0(%ecx)
  if(holding(lk))
801049e7:	8b 55 08             	mov    0x8(%ebp),%edx
  cpu->ncli += 1;
801049ea:	83 c0 01             	add    $0x1,%eax
801049ed:	89 81 ac 00 00 00    	mov    %eax,0xac(%ecx)
  return lock->locked && lock->cpu == cpu;
801049f3:	8b 02                	mov    (%edx),%eax
801049f5:	85 c0                	test   %eax,%eax
801049f7:	74 05                	je     801049fe <acquire+0x3e>
801049f9:	39 4a 08             	cmp    %ecx,0x8(%edx)
801049fc:	74 74                	je     80104a72 <acquire+0xb2>
  asm volatile("lock; xchgl %0, %1" :
801049fe:	b9 01 00 00 00       	mov    $0x1,%ecx
80104a03:	90                   	nop
80104a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a08:	89 c8                	mov    %ecx,%eax
80104a0a:	f0 87 02             	lock xchg %eax,(%edx)
  while(xchg(&lk->locked, 1) != 0)
80104a0d:	85 c0                	test   %eax,%eax
80104a0f:	75 f7                	jne    80104a08 <acquire+0x48>
  __sync_synchronize();
80104a11:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = cpu;
80104a16:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a19:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  for(i = 0; i < 10; i++){
80104a1f:	31 d2                	xor    %edx,%edx
  lk->cpu = cpu;
80104a21:	89 41 08             	mov    %eax,0x8(%ecx)
  getcallerpcs(&lk, lk->pcs);
80104a24:	83 c1 0c             	add    $0xc,%ecx
  ebp = (uint*)v - 2;
80104a27:	89 e8                	mov    %ebp,%eax
80104a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104a30:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104a36:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104a3c:	77 1a                	ja     80104a58 <acquire+0x98>
    pcs[i] = ebp[1];     // saved %eip
80104a3e:	8b 58 04             	mov    0x4(%eax),%ebx
80104a41:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104a44:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104a47:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104a49:	83 fa 0a             	cmp    $0xa,%edx
80104a4c:	75 e2                	jne    80104a30 <acquire+0x70>
}
80104a4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a51:	c9                   	leave  
80104a52:	c3                   	ret    
80104a53:	90                   	nop
80104a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a58:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104a5b:	83 c1 28             	add    $0x28,%ecx
80104a5e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104a60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104a66:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104a69:	39 c8                	cmp    %ecx,%eax
80104a6b:	75 f3                	jne    80104a60 <acquire+0xa0>
}
80104a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a70:	c9                   	leave  
80104a71:	c3                   	ret    
    panic("acquire");
80104a72:	83 ec 0c             	sub    $0xc,%esp
80104a75:	68 98 80 10 80       	push   $0x80108098
80104a7a:	e8 f1 b8 ff ff       	call   80100370 <panic>
80104a7f:	90                   	nop

80104a80 <getcallerpcs>:
{
80104a80:	55                   	push   %ebp
  for(i = 0; i < 10; i++){
80104a81:	31 d2                	xor    %edx,%edx
{
80104a83:	89 e5                	mov    %esp,%ebp
80104a85:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104a86:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104a89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
80104a8c:	83 e8 08             	sub    $0x8,%eax
80104a8f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104a90:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104a96:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104a9c:	77 1a                	ja     80104ab8 <getcallerpcs+0x38>
    pcs[i] = ebp[1];     // saved %eip
80104a9e:	8b 58 04             	mov    0x4(%eax),%ebx
80104aa1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104aa4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104aa7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104aa9:	83 fa 0a             	cmp    $0xa,%edx
80104aac:	75 e2                	jne    80104a90 <getcallerpcs+0x10>
}
80104aae:	5b                   	pop    %ebx
80104aaf:	5d                   	pop    %ebp
80104ab0:	c3                   	ret    
80104ab1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ab8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104abb:	83 c1 28             	add    $0x28,%ecx
80104abe:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104ac0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104ac6:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104ac9:	39 c1                	cmp    %eax,%ecx
80104acb:	75 f3                	jne    80104ac0 <getcallerpcs+0x40>
}
80104acd:	5b                   	pop    %ebx
80104ace:	5d                   	pop    %ebp
80104acf:	c3                   	ret    

80104ad0 <holding>:
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
80104ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
80104ad6:	8b 02                	mov    (%edx),%eax
80104ad8:	85 c0                	test   %eax,%eax
80104ada:	74 14                	je     80104af0 <holding+0x20>
80104adc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ae2:	39 42 08             	cmp    %eax,0x8(%edx)
}
80104ae5:	5d                   	pop    %ebp
  return lock->locked && lock->cpu == cpu;
80104ae6:	0f 94 c0             	sete   %al
80104ae9:	0f b6 c0             	movzbl %al,%eax
}
80104aec:	c3                   	ret    
80104aed:	8d 76 00             	lea    0x0(%esi),%esi
80104af0:	31 c0                	xor    %eax,%eax
80104af2:	5d                   	pop    %ebp
80104af3:	c3                   	ret    
80104af4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104afa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104b00 <pushcli>:
{
80104b00:	55                   	push   %ebp
80104b01:	89 e5                	mov    %esp,%ebp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b03:	9c                   	pushf  
80104b04:	59                   	pop    %ecx
  asm volatile("cli");
80104b05:	fa                   	cli    
  if(cpu->ncli == 0)
80104b06:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b0d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104b13:	85 c0                	test   %eax,%eax
80104b15:	75 0c                	jne    80104b23 <pushcli+0x23>
    cpu->intena = eflags & FL_IF;
80104b17:	81 e1 00 02 00 00    	and    $0x200,%ecx
80104b1d:	89 8a b0 00 00 00    	mov    %ecx,0xb0(%edx)
  cpu->ncli += 1;
80104b23:	83 c0 01             	add    $0x1,%eax
80104b26:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
}
80104b2c:	5d                   	pop    %ebp
80104b2d:	c3                   	ret    
80104b2e:	66 90                	xchg   %ax,%ax

80104b30 <popcli>:

void
popcli(void)
{
80104b30:	55                   	push   %ebp
80104b31:	89 e5                	mov    %esp,%ebp
80104b33:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b36:	9c                   	pushf  
80104b37:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104b38:	f6 c4 02             	test   $0x2,%ah
80104b3b:	75 2c                	jne    80104b69 <popcli+0x39>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
80104b3d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b44:	83 aa ac 00 00 00 01 	subl   $0x1,0xac(%edx)
80104b4b:	78 0f                	js     80104b5c <popcli+0x2c>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
80104b4d:	75 0b                	jne    80104b5a <popcli+0x2a>
80104b4f:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
80104b55:	85 c0                	test   %eax,%eax
80104b57:	74 01                	je     80104b5a <popcli+0x2a>
  asm volatile("sti");
80104b59:	fb                   	sti    
    sti();
}
80104b5a:	c9                   	leave  
80104b5b:	c3                   	ret    
    panic("popcli");
80104b5c:	83 ec 0c             	sub    $0xc,%esp
80104b5f:	68 b7 80 10 80       	push   $0x801080b7
80104b64:	e8 07 b8 ff ff       	call   80100370 <panic>
    panic("popcli - interruptible");
80104b69:	83 ec 0c             	sub    $0xc,%esp
80104b6c:	68 a0 80 10 80       	push   $0x801080a0
80104b71:	e8 fa b7 ff ff       	call   80100370 <panic>
80104b76:	8d 76 00             	lea    0x0(%esi),%esi
80104b79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104b80 <release>:
{
80104b80:	55                   	push   %ebp
80104b81:	89 e5                	mov    %esp,%ebp
80104b83:	83 ec 08             	sub    $0x8,%esp
80104b86:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked && lock->cpu == cpu;
80104b89:	8b 10                	mov    (%eax),%edx
80104b8b:	85 d2                	test   %edx,%edx
80104b8d:	74 2b                	je     80104bba <release+0x3a>
80104b8f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b96:	39 50 08             	cmp    %edx,0x8(%eax)
80104b99:	75 1f                	jne    80104bba <release+0x3a>
  lk->pcs[0] = 0;
80104b9b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104ba2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  __sync_synchronize();
80104ba9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->locked = 0;
80104bae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80104bb4:	c9                   	leave  
  popcli();
80104bb5:	e9 76 ff ff ff       	jmp    80104b30 <popcli>
    panic("release");
80104bba:	83 ec 0c             	sub    $0xc,%esp
80104bbd:	68 be 80 10 80       	push   $0x801080be
80104bc2:	e8 a9 b7 ff ff       	call   80100370 <panic>
80104bc7:	66 90                	xchg   %ax,%ax
80104bc9:	66 90                	xchg   %ax,%ax
80104bcb:	66 90                	xchg   %ax,%ax
80104bcd:	66 90                	xchg   %ax,%ax
80104bcf:	90                   	nop

80104bd0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104bd0:	55                   	push   %ebp
80104bd1:	89 e5                	mov    %esp,%ebp
80104bd3:	57                   	push   %edi
80104bd4:	53                   	push   %ebx
80104bd5:	8b 55 08             	mov    0x8(%ebp),%edx
80104bd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104bdb:	f6 c2 03             	test   $0x3,%dl
80104bde:	75 05                	jne    80104be5 <memset+0x15>
80104be0:	f6 c1 03             	test   $0x3,%cl
80104be3:	74 13                	je     80104bf8 <memset+0x28>
  asm volatile("cld; rep stosb" :
80104be5:	89 d7                	mov    %edx,%edi
80104be7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bea:	fc                   	cld    
80104beb:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104bed:	5b                   	pop    %ebx
80104bee:	89 d0                	mov    %edx,%eax
80104bf0:	5f                   	pop    %edi
80104bf1:	5d                   	pop    %ebp
80104bf2:	c3                   	ret    
80104bf3:	90                   	nop
80104bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c &= 0xFF;
80104bf8:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104bfc:	c1 e9 02             	shr    $0x2,%ecx
80104bff:	89 f8                	mov    %edi,%eax
80104c01:	89 fb                	mov    %edi,%ebx
80104c03:	c1 e0 18             	shl    $0x18,%eax
80104c06:	c1 e3 10             	shl    $0x10,%ebx
80104c09:	09 d8                	or     %ebx,%eax
80104c0b:	09 f8                	or     %edi,%eax
80104c0d:	c1 e7 08             	shl    $0x8,%edi
80104c10:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104c12:	89 d7                	mov    %edx,%edi
80104c14:	fc                   	cld    
80104c15:	f3 ab                	rep stos %eax,%es:(%edi)
}
80104c17:	5b                   	pop    %ebx
80104c18:	89 d0                	mov    %edx,%eax
80104c1a:	5f                   	pop    %edi
80104c1b:	5d                   	pop    %ebp
80104c1c:	c3                   	ret    
80104c1d:	8d 76 00             	lea    0x0(%esi),%esi

80104c20 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104c20:	55                   	push   %ebp
80104c21:	89 e5                	mov    %esp,%ebp
80104c23:	57                   	push   %edi
80104c24:	56                   	push   %esi
80104c25:	53                   	push   %ebx
80104c26:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104c29:	8b 75 08             	mov    0x8(%ebp),%esi
80104c2c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104c2f:	85 db                	test   %ebx,%ebx
80104c31:	74 29                	je     80104c5c <memcmp+0x3c>
    if(*s1 != *s2)
80104c33:	0f b6 16             	movzbl (%esi),%edx
80104c36:	0f b6 0f             	movzbl (%edi),%ecx
80104c39:	38 d1                	cmp    %dl,%cl
80104c3b:	75 2b                	jne    80104c68 <memcmp+0x48>
80104c3d:	b8 01 00 00 00       	mov    $0x1,%eax
80104c42:	eb 14                	jmp    80104c58 <memcmp+0x38>
80104c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104c48:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
80104c4c:	83 c0 01             	add    $0x1,%eax
80104c4f:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
80104c54:	38 ca                	cmp    %cl,%dl
80104c56:	75 10                	jne    80104c68 <memcmp+0x48>
  while(n-- > 0){
80104c58:	39 d8                	cmp    %ebx,%eax
80104c5a:	75 ec                	jne    80104c48 <memcmp+0x28>
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
80104c5c:	5b                   	pop    %ebx
  return 0;
80104c5d:	31 c0                	xor    %eax,%eax
}
80104c5f:	5e                   	pop    %esi
80104c60:	5f                   	pop    %edi
80104c61:	5d                   	pop    %ebp
80104c62:	c3                   	ret    
80104c63:	90                   	nop
80104c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return *s1 - *s2;
80104c68:	0f b6 c2             	movzbl %dl,%eax
}
80104c6b:	5b                   	pop    %ebx
      return *s1 - *s2;
80104c6c:	29 c8                	sub    %ecx,%eax
}
80104c6e:	5e                   	pop    %esi
80104c6f:	5f                   	pop    %edi
80104c70:	5d                   	pop    %ebp
80104c71:	c3                   	ret    
80104c72:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104c80 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104c80:	55                   	push   %ebp
80104c81:	89 e5                	mov    %esp,%ebp
80104c83:	56                   	push   %esi
80104c84:	53                   	push   %ebx
80104c85:	8b 45 08             	mov    0x8(%ebp),%eax
80104c88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104c8b:	8b 75 10             	mov    0x10(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104c8e:	39 c3                	cmp    %eax,%ebx
80104c90:	73 26                	jae    80104cb8 <memmove+0x38>
80104c92:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
80104c95:	39 c8                	cmp    %ecx,%eax
80104c97:	73 1f                	jae    80104cb8 <memmove+0x38>
    s += n;
    d += n;
    while(n-- > 0)
80104c99:	85 f6                	test   %esi,%esi
80104c9b:	8d 56 ff             	lea    -0x1(%esi),%edx
80104c9e:	74 0f                	je     80104caf <memmove+0x2f>
      *--d = *--s;
80104ca0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104ca4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    while(n-- > 0)
80104ca7:	83 ea 01             	sub    $0x1,%edx
80104caa:	83 fa ff             	cmp    $0xffffffff,%edx
80104cad:	75 f1                	jne    80104ca0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104caf:	5b                   	pop    %ebx
80104cb0:	5e                   	pop    %esi
80104cb1:	5d                   	pop    %ebp
80104cb2:	c3                   	ret    
80104cb3:	90                   	nop
80104cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
80104cb8:	31 d2                	xor    %edx,%edx
80104cba:	85 f6                	test   %esi,%esi
80104cbc:	74 f1                	je     80104caf <memmove+0x2f>
80104cbe:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80104cc0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104cc4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80104cc7:	83 c2 01             	add    $0x1,%edx
    while(n-- > 0)
80104cca:	39 d6                	cmp    %edx,%esi
80104ccc:	75 f2                	jne    80104cc0 <memmove+0x40>
}
80104cce:	5b                   	pop    %ebx
80104ccf:	5e                   	pop    %esi
80104cd0:	5d                   	pop    %ebp
80104cd1:	c3                   	ret    
80104cd2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ce0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ce0:	55                   	push   %ebp
80104ce1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80104ce3:	5d                   	pop    %ebp
  return memmove(dst, src, n);
80104ce4:	eb 9a                	jmp    80104c80 <memmove>
80104ce6:	8d 76 00             	lea    0x0(%esi),%esi
80104ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104cf0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104cf0:	55                   	push   %ebp
80104cf1:	89 e5                	mov    %esp,%ebp
80104cf3:	57                   	push   %edi
80104cf4:	56                   	push   %esi
80104cf5:	8b 7d 10             	mov    0x10(%ebp),%edi
80104cf8:	53                   	push   %ebx
80104cf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  while(n > 0 && *p && *p == *q)
80104cff:	85 ff                	test   %edi,%edi
80104d01:	74 2f                	je     80104d32 <strncmp+0x42>
80104d03:	0f b6 01             	movzbl (%ecx),%eax
80104d06:	0f b6 1e             	movzbl (%esi),%ebx
80104d09:	84 c0                	test   %al,%al
80104d0b:	74 37                	je     80104d44 <strncmp+0x54>
80104d0d:	38 c3                	cmp    %al,%bl
80104d0f:	75 33                	jne    80104d44 <strncmp+0x54>
80104d11:	01 f7                	add    %esi,%edi
80104d13:	eb 13                	jmp    80104d28 <strncmp+0x38>
80104d15:	8d 76 00             	lea    0x0(%esi),%esi
80104d18:	0f b6 01             	movzbl (%ecx),%eax
80104d1b:	84 c0                	test   %al,%al
80104d1d:	74 21                	je     80104d40 <strncmp+0x50>
80104d1f:	0f b6 1a             	movzbl (%edx),%ebx
80104d22:	89 d6                	mov    %edx,%esi
80104d24:	38 d8                	cmp    %bl,%al
80104d26:	75 1c                	jne    80104d44 <strncmp+0x54>
    n--, p++, q++;
80104d28:	8d 56 01             	lea    0x1(%esi),%edx
80104d2b:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104d2e:	39 fa                	cmp    %edi,%edx
80104d30:	75 e6                	jne    80104d18 <strncmp+0x28>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
80104d32:	5b                   	pop    %ebx
    return 0;
80104d33:	31 c0                	xor    %eax,%eax
}
80104d35:	5e                   	pop    %esi
80104d36:	5f                   	pop    %edi
80104d37:	5d                   	pop    %ebp
80104d38:	c3                   	ret    
80104d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d40:	0f b6 5e 01          	movzbl 0x1(%esi),%ebx
  return (uchar)*p - (uchar)*q;
80104d44:	29 d8                	sub    %ebx,%eax
}
80104d46:	5b                   	pop    %ebx
80104d47:	5e                   	pop    %esi
80104d48:	5f                   	pop    %edi
80104d49:	5d                   	pop    %ebp
80104d4a:	c3                   	ret    
80104d4b:	90                   	nop
80104d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104d50 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104d50:	55                   	push   %ebp
80104d51:	89 e5                	mov    %esp,%ebp
80104d53:	56                   	push   %esi
80104d54:	53                   	push   %ebx
80104d55:	8b 45 08             	mov    0x8(%ebp),%eax
80104d58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104d5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104d5e:	89 c2                	mov    %eax,%edx
80104d60:	eb 19                	jmp    80104d7b <strncpy+0x2b>
80104d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104d68:	83 c3 01             	add    $0x1,%ebx
80104d6b:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
80104d6f:	83 c2 01             	add    $0x1,%edx
80104d72:	84 c9                	test   %cl,%cl
80104d74:	88 4a ff             	mov    %cl,-0x1(%edx)
80104d77:	74 09                	je     80104d82 <strncpy+0x32>
80104d79:	89 f1                	mov    %esi,%ecx
80104d7b:	85 c9                	test   %ecx,%ecx
80104d7d:	8d 71 ff             	lea    -0x1(%ecx),%esi
80104d80:	7f e6                	jg     80104d68 <strncpy+0x18>
    ;
  while(n-- > 0)
80104d82:	31 c9                	xor    %ecx,%ecx
80104d84:	85 f6                	test   %esi,%esi
80104d86:	7e 17                	jle    80104d9f <strncpy+0x4f>
80104d88:	90                   	nop
80104d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104d90:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
80104d94:	89 f3                	mov    %esi,%ebx
80104d96:	83 c1 01             	add    $0x1,%ecx
80104d99:	29 cb                	sub    %ecx,%ebx
  while(n-- > 0)
80104d9b:	85 db                	test   %ebx,%ebx
80104d9d:	7f f1                	jg     80104d90 <strncpy+0x40>
  return os;
}
80104d9f:	5b                   	pop    %ebx
80104da0:	5e                   	pop    %esi
80104da1:	5d                   	pop    %ebp
80104da2:	c3                   	ret    
80104da3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104da9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104db0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104db0:	55                   	push   %ebp
80104db1:	89 e5                	mov    %esp,%ebp
80104db3:	56                   	push   %esi
80104db4:	53                   	push   %ebx
80104db5:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104db8:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104dbe:	85 c9                	test   %ecx,%ecx
80104dc0:	7e 26                	jle    80104de8 <safestrcpy+0x38>
80104dc2:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
80104dc6:	89 c1                	mov    %eax,%ecx
80104dc8:	eb 17                	jmp    80104de1 <safestrcpy+0x31>
80104dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104dd0:	83 c2 01             	add    $0x1,%edx
80104dd3:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
80104dd7:	83 c1 01             	add    $0x1,%ecx
80104dda:	84 db                	test   %bl,%bl
80104ddc:	88 59 ff             	mov    %bl,-0x1(%ecx)
80104ddf:	74 04                	je     80104de5 <safestrcpy+0x35>
80104de1:	39 f2                	cmp    %esi,%edx
80104de3:	75 eb                	jne    80104dd0 <safestrcpy+0x20>
    ;
  *s = 0;
80104de5:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104de8:	5b                   	pop    %ebx
80104de9:	5e                   	pop    %esi
80104dea:	5d                   	pop    %ebp
80104deb:	c3                   	ret    
80104dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104df0 <strlen>:

int
strlen(const char *s)
{
80104df0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104df1:	31 c0                	xor    %eax,%eax
{
80104df3:	89 e5                	mov    %esp,%ebp
80104df5:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104df8:	80 3a 00             	cmpb   $0x0,(%edx)
80104dfb:	74 0c                	je     80104e09 <strlen+0x19>
80104dfd:	8d 76 00             	lea    0x0(%esi),%esi
80104e00:	83 c0 01             	add    $0x1,%eax
80104e03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104e07:	75 f7                	jne    80104e00 <strlen+0x10>
    ;
  return n;
}
80104e09:	5d                   	pop    %ebp
80104e0a:	c3                   	ret    

80104e0b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104e0b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104e0f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104e13:	55                   	push   %ebp
  pushl %ebx
80104e14:	53                   	push   %ebx
  pushl %esi
80104e15:	56                   	push   %esi
  pushl %edi
80104e16:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104e17:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e19:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104e1b:	5f                   	pop    %edi
  popl %esi
80104e1c:	5e                   	pop    %esi
  popl %ebx
80104e1d:	5b                   	pop    %ebx
  popl %ebp
80104e1e:	5d                   	pop    %ebp
  ret
80104e1f:	c3                   	ret    

80104e20 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e20:	55                   	push   %ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80104e21:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80104e28:	89 e5                	mov    %esp,%ebp
80104e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  if(addr >= proc->sz || addr+4 > proc->sz)
80104e2d:	8b 12                	mov    (%edx),%edx
80104e2f:	39 c2                	cmp    %eax,%edx
80104e31:	76 15                	jbe    80104e48 <fetchint+0x28>
80104e33:	8d 48 04             	lea    0x4(%eax),%ecx
80104e36:	39 ca                	cmp    %ecx,%edx
80104e38:	72 0e                	jb     80104e48 <fetchint+0x28>
    return -1;
  *ip = *(int*)(addr);
80104e3a:	8b 10                	mov    (%eax),%edx
80104e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e3f:	89 10                	mov    %edx,(%eax)
  return 0;
80104e41:	31 c0                	xor    %eax,%eax
}
80104e43:	5d                   	pop    %ebp
80104e44:	c3                   	ret    
80104e45:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e4d:	5d                   	pop    %ebp
80104e4e:	c3                   	ret    
80104e4f:	90                   	nop

80104e50 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104e50:	55                   	push   %ebp
  char *s, *ep;

  if(addr >= proc->sz)
80104e51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80104e57:	89 e5                	mov    %esp,%ebp
80104e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz)
80104e5c:	39 08                	cmp    %ecx,(%eax)
80104e5e:	76 2c                	jbe    80104e8c <fetchstr+0x3c>
    return -1;
  *pp = (char*)addr;
80104e60:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e63:	89 c8                	mov    %ecx,%eax
80104e65:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
80104e67:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e6e:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
80104e70:	39 d1                	cmp    %edx,%ecx
80104e72:	73 18                	jae    80104e8c <fetchstr+0x3c>
    if(*s == 0)
80104e74:	80 39 00             	cmpb   $0x0,(%ecx)
80104e77:	75 0c                	jne    80104e85 <fetchstr+0x35>
80104e79:	eb 25                	jmp    80104ea0 <fetchstr+0x50>
80104e7b:	90                   	nop
80104e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104e80:	80 38 00             	cmpb   $0x0,(%eax)
80104e83:	74 13                	je     80104e98 <fetchstr+0x48>
  for(s = *pp; s < ep; s++)
80104e85:	83 c0 01             	add    $0x1,%eax
80104e88:	39 c2                	cmp    %eax,%edx
80104e8a:	77 f4                	ja     80104e80 <fetchstr+0x30>
    return -1;
80104e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return s - *pp;
  return -1;
}
80104e91:	5d                   	pop    %ebp
80104e92:	c3                   	ret    
80104e93:	90                   	nop
80104e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104e98:	29 c8                	sub    %ecx,%eax
80104e9a:	5d                   	pop    %ebp
80104e9b:	c3                   	ret    
80104e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
80104ea0:	31 c0                	xor    %eax,%eax
}
80104ea2:	5d                   	pop    %ebp
80104ea3:	c3                   	ret    
80104ea4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104eaa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104eb0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104eb0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80104eb7:	55                   	push   %ebp
80104eb8:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104eba:	8b 42 3c             	mov    0x3c(%edx),%eax
80104ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104ec0:	8b 12                	mov    (%edx),%edx
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104ec2:	8b 40 44             	mov    0x44(%eax),%eax
80104ec5:	8d 04 88             	lea    (%eax,%ecx,4),%eax
80104ec8:	8d 48 04             	lea    0x4(%eax),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104ecb:	39 d1                	cmp    %edx,%ecx
80104ecd:	73 19                	jae    80104ee8 <argint+0x38>
80104ecf:	8d 48 08             	lea    0x8(%eax),%ecx
80104ed2:	39 ca                	cmp    %ecx,%edx
80104ed4:	72 12                	jb     80104ee8 <argint+0x38>
  *ip = *(int*)(addr);
80104ed6:	8b 50 04             	mov    0x4(%eax),%edx
80104ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104edc:	89 10                	mov    %edx,(%eax)
  return 0;
80104ede:	31 c0                	xor    %eax,%eax
}
80104ee0:	5d                   	pop    %ebp
80104ee1:	c3                   	ret    
80104ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104ee8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eed:	5d                   	pop    %ebp
80104eee:	c3                   	ret    
80104eef:	90                   	nop

80104ef0 <argptr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104ef0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104ef6:	55                   	push   %ebp
80104ef7:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104ef9:	8b 50 3c             	mov    0x3c(%eax),%edx
80104efc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104eff:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f01:	8b 52 44             	mov    0x44(%edx),%edx
80104f04:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
80104f07:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f0a:	39 c1                	cmp    %eax,%ecx
80104f0c:	73 22                	jae    80104f30 <argptr+0x40>
80104f0e:	8d 4a 08             	lea    0x8(%edx),%ecx
80104f11:	39 c8                	cmp    %ecx,%eax
80104f13:	72 1b                	jb     80104f30 <argptr+0x40>
  *ip = *(int*)(addr);
80104f15:	8b 52 04             	mov    0x4(%edx),%edx
  int i;

  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80104f18:	39 c2                	cmp    %eax,%edx
80104f1a:	73 14                	jae    80104f30 <argptr+0x40>
80104f1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104f1f:	01 d1                	add    %edx,%ecx
80104f21:	39 c1                	cmp    %eax,%ecx
80104f23:	77 0b                	ja     80104f30 <argptr+0x40>
    return -1;
  *pp = (char*)i;
80104f25:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f28:	89 10                	mov    %edx,(%eax)
  return 0;
80104f2a:	31 c0                	xor    %eax,%eax
}
80104f2c:	5d                   	pop    %ebp
80104f2d:	c3                   	ret    
80104f2e:	66 90                	xchg   %ax,%ax
    return -1;
80104f30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f35:	5d                   	pop    %ebp
80104f36:	c3                   	ret    
80104f37:	89 f6                	mov    %esi,%esi
80104f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104f40 <argstr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104f46:	55                   	push   %ebp
80104f47:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f49:	8b 50 3c             	mov    0x3c(%eax),%edx
80104f4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f4f:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f51:	8b 52 44             	mov    0x44(%edx),%edx
80104f54:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
80104f57:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f5a:	39 c1                	cmp    %eax,%ecx
80104f5c:	73 3e                	jae    80104f9c <argstr+0x5c>
80104f5e:	8d 4a 08             	lea    0x8(%edx),%ecx
80104f61:	39 c8                	cmp    %ecx,%eax
80104f63:	72 37                	jb     80104f9c <argstr+0x5c>
  *ip = *(int*)(addr);
80104f65:	8b 4a 04             	mov    0x4(%edx),%ecx
  if(addr >= proc->sz)
80104f68:	39 c1                	cmp    %eax,%ecx
80104f6a:	73 30                	jae    80104f9c <argstr+0x5c>
  *pp = (char*)addr;
80104f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f6f:	89 c8                	mov    %ecx,%eax
80104f71:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
80104f73:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f7a:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
80104f7c:	39 d1                	cmp    %edx,%ecx
80104f7e:	73 1c                	jae    80104f9c <argstr+0x5c>
    if(*s == 0)
80104f80:	80 39 00             	cmpb   $0x0,(%ecx)
80104f83:	75 10                	jne    80104f95 <argstr+0x55>
80104f85:	eb 29                	jmp    80104fb0 <argstr+0x70>
80104f87:	89 f6                	mov    %esi,%esi
80104f89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80104f90:	80 38 00             	cmpb   $0x0,(%eax)
80104f93:	74 13                	je     80104fa8 <argstr+0x68>
  for(s = *pp; s < ep; s++)
80104f95:	83 c0 01             	add    $0x1,%eax
80104f98:	39 c2                	cmp    %eax,%edx
80104f9a:	77 f4                	ja     80104f90 <argstr+0x50>
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
80104f9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchstr(addr, pp);
}
80104fa1:	5d                   	pop    %ebp
80104fa2:	c3                   	ret    
80104fa3:	90                   	nop
80104fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104fa8:	29 c8                	sub    %ecx,%eax
80104faa:	5d                   	pop    %ebp
80104fab:	c3                   	ret    
80104fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
80104fb0:	31 c0                	xor    %eax,%eax
}
80104fb2:	5d                   	pop    %ebp
80104fb3:	c3                   	ret    
80104fb4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104fba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104fc0 <syscall>:
[SYS_chpri]     sys_chpri,
};

void
syscall(void)
{
80104fc0:	55                   	push   %ebp
80104fc1:	89 e5                	mov    %esp,%ebp
80104fc3:	83 ec 08             	sub    $0x8,%esp
  int num;

  num = proc->tf->eax;
80104fc6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fcd:	8b 42 3c             	mov    0x3c(%edx),%eax
80104fd0:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104fd3:	8d 48 ff             	lea    -0x1(%eax),%ecx
80104fd6:	83 f9 1b             	cmp    $0x1b,%ecx
80104fd9:	77 25                	ja     80105000 <syscall+0x40>
80104fdb:	8b 0c 85 00 81 10 80 	mov    -0x7fef7f00(,%eax,4),%ecx
80104fe2:	85 c9                	test   %ecx,%ecx
80104fe4:	74 1a                	je     80105000 <syscall+0x40>
    proc->tf->eax = syscalls[num]();
80104fe6:	ff d1                	call   *%ecx
80104fe8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fef:	8b 52 3c             	mov    0x3c(%edx),%edx
80104ff2:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
80104ff5:	c9                   	leave  
80104ff6:	c3                   	ret    
80104ff7:	89 f6                	mov    %esi,%esi
80104ff9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    cprintf("%d %s: unknown sys call %d\n",
80105000:	50                   	push   %eax
            proc->pid, proc->name, num);
80105001:	8d 82 90 00 00 00    	lea    0x90(%edx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80105007:	50                   	push   %eax
80105008:	ff 72 10             	pushl  0x10(%edx)
8010500b:	68 c6 80 10 80       	push   $0x801080c6
80105010:	e8 2b b6 ff ff       	call   80100640 <cprintf>
    proc->tf->eax = -1;
80105015:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010501b:	83 c4 10             	add    $0x10,%esp
8010501e:	8b 40 3c             	mov    0x3c(%eax),%eax
80105021:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80105028:	c9                   	leave  
80105029:	c3                   	ret    
8010502a:	66 90                	xchg   %ax,%ax
8010502c:	66 90                	xchg   %ax,%ax
8010502e:	66 90                	xchg   %ax,%ax

80105030 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80105030:	55                   	push   %ebp
80105031:	89 e5                	mov    %esp,%ebp
80105033:	57                   	push   %edi
80105034:	56                   	push   %esi
80105035:	53                   	push   %ebx
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105036:	8d 75 da             	lea    -0x26(%ebp),%esi
{
80105039:	83 ec 44             	sub    $0x44,%esp
8010503c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
8010503f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80105042:	56                   	push   %esi
80105043:	50                   	push   %eax
{
80105044:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80105047:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  if((dp = nameiparent(path, name)) == 0)
8010504a:	e8 91 ce ff ff       	call   80101ee0 <nameiparent>
8010504f:	83 c4 10             	add    $0x10,%esp
80105052:	85 c0                	test   %eax,%eax
80105054:	0f 84 46 01 00 00    	je     801051a0 <create+0x170>
    return 0;
  ilock(dp);
8010505a:	83 ec 0c             	sub    $0xc,%esp
8010505d:	89 c3                	mov    %eax,%ebx
8010505f:	50                   	push   %eax
80105060:	e8 ab c5 ff ff       	call   80101610 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105065:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80105068:	83 c4 0c             	add    $0xc,%esp
8010506b:	50                   	push   %eax
8010506c:	56                   	push   %esi
8010506d:	53                   	push   %ebx
8010506e:	e8 0d cb ff ff       	call   80101b80 <dirlookup>
80105073:	83 c4 10             	add    $0x10,%esp
80105076:	85 c0                	test   %eax,%eax
80105078:	89 c7                	mov    %eax,%edi
8010507a:	74 34                	je     801050b0 <create+0x80>
    iunlockput(dp);
8010507c:	83 ec 0c             	sub    $0xc,%esp
8010507f:	53                   	push   %ebx
80105080:	e8 5b c8 ff ff       	call   801018e0 <iunlockput>
    ilock(ip);
80105085:	89 3c 24             	mov    %edi,(%esp)
80105088:	e8 83 c5 ff ff       	call   80101610 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010508d:	83 c4 10             	add    $0x10,%esp
80105090:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80105095:	0f 85 95 00 00 00    	jne    80105130 <create+0x100>
8010509b:	66 83 7f 10 02       	cmpw   $0x2,0x10(%edi)
801050a0:	0f 85 8a 00 00 00    	jne    80105130 <create+0x100>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801050a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050a9:	89 f8                	mov    %edi,%eax
801050ab:	5b                   	pop    %ebx
801050ac:	5e                   	pop    %esi
801050ad:	5f                   	pop    %edi
801050ae:	5d                   	pop    %ebp
801050af:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
801050b0:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801050b4:	83 ec 08             	sub    $0x8,%esp
801050b7:	50                   	push   %eax
801050b8:	ff 33                	pushl  (%ebx)
801050ba:	e8 e1 c3 ff ff       	call   801014a0 <ialloc>
801050bf:	83 c4 10             	add    $0x10,%esp
801050c2:	85 c0                	test   %eax,%eax
801050c4:	89 c7                	mov    %eax,%edi
801050c6:	0f 84 e8 00 00 00    	je     801051b4 <create+0x184>
  ilock(ip);
801050cc:	83 ec 0c             	sub    $0xc,%esp
801050cf:	50                   	push   %eax
801050d0:	e8 3b c5 ff ff       	call   80101610 <ilock>
  ip->major = major;
801050d5:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801050d9:	66 89 47 12          	mov    %ax,0x12(%edi)
  ip->minor = minor;
801050dd:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
801050e1:	66 89 47 14          	mov    %ax,0x14(%edi)
  ip->nlink = 1;
801050e5:	b8 01 00 00 00       	mov    $0x1,%eax
801050ea:	66 89 47 16          	mov    %ax,0x16(%edi)
  iupdate(ip);
801050ee:	89 3c 24             	mov    %edi,(%esp)
801050f1:	e8 6a c4 ff ff       	call   80101560 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801050f6:	83 c4 10             	add    $0x10,%esp
801050f9:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
801050fe:	74 50                	je     80105150 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80105100:	83 ec 04             	sub    $0x4,%esp
80105103:	ff 77 04             	pushl  0x4(%edi)
80105106:	56                   	push   %esi
80105107:	53                   	push   %ebx
80105108:	e8 f3 cc ff ff       	call   80101e00 <dirlink>
8010510d:	83 c4 10             	add    $0x10,%esp
80105110:	85 c0                	test   %eax,%eax
80105112:	0f 88 8f 00 00 00    	js     801051a7 <create+0x177>
  iunlockput(dp);
80105118:	83 ec 0c             	sub    $0xc,%esp
8010511b:	53                   	push   %ebx
8010511c:	e8 bf c7 ff ff       	call   801018e0 <iunlockput>
  return ip;
80105121:	83 c4 10             	add    $0x10,%esp
}
80105124:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105127:	89 f8                	mov    %edi,%eax
80105129:	5b                   	pop    %ebx
8010512a:	5e                   	pop    %esi
8010512b:	5f                   	pop    %edi
8010512c:	5d                   	pop    %ebp
8010512d:	c3                   	ret    
8010512e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80105130:	83 ec 0c             	sub    $0xc,%esp
80105133:	57                   	push   %edi
    return 0;
80105134:	31 ff                	xor    %edi,%edi
    iunlockput(ip);
80105136:	e8 a5 c7 ff ff       	call   801018e0 <iunlockput>
    return 0;
8010513b:	83 c4 10             	add    $0x10,%esp
}
8010513e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105141:	89 f8                	mov    %edi,%eax
80105143:	5b                   	pop    %ebx
80105144:	5e                   	pop    %esi
80105145:	5f                   	pop    %edi
80105146:	5d                   	pop    %ebp
80105147:	c3                   	ret    
80105148:	90                   	nop
80105149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink++;  // for ".."
80105150:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
    iupdate(dp);
80105155:	83 ec 0c             	sub    $0xc,%esp
80105158:	53                   	push   %ebx
80105159:	e8 02 c4 ff ff       	call   80101560 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010515e:	83 c4 0c             	add    $0xc,%esp
80105161:	ff 77 04             	pushl  0x4(%edi)
80105164:	68 90 81 10 80       	push   $0x80108190
80105169:	57                   	push   %edi
8010516a:	e8 91 cc ff ff       	call   80101e00 <dirlink>
8010516f:	83 c4 10             	add    $0x10,%esp
80105172:	85 c0                	test   %eax,%eax
80105174:	78 1c                	js     80105192 <create+0x162>
80105176:	83 ec 04             	sub    $0x4,%esp
80105179:	ff 73 04             	pushl  0x4(%ebx)
8010517c:	68 8f 81 10 80       	push   $0x8010818f
80105181:	57                   	push   %edi
80105182:	e8 79 cc ff ff       	call   80101e00 <dirlink>
80105187:	83 c4 10             	add    $0x10,%esp
8010518a:	85 c0                	test   %eax,%eax
8010518c:	0f 89 6e ff ff ff    	jns    80105100 <create+0xd0>
      panic("create dots");
80105192:	83 ec 0c             	sub    $0xc,%esp
80105195:	68 83 81 10 80       	push   $0x80108183
8010519a:	e8 d1 b1 ff ff       	call   80100370 <panic>
8010519f:	90                   	nop
    return 0;
801051a0:	31 ff                	xor    %edi,%edi
801051a2:	e9 ff fe ff ff       	jmp    801050a6 <create+0x76>
    panic("create: dirlink");
801051a7:	83 ec 0c             	sub    $0xc,%esp
801051aa:	68 92 81 10 80       	push   $0x80108192
801051af:	e8 bc b1 ff ff       	call   80100370 <panic>
    panic("create: ialloc");
801051b4:	83 ec 0c             	sub    $0xc,%esp
801051b7:	68 74 81 10 80       	push   $0x80108174
801051bc:	e8 af b1 ff ff       	call   80100370 <panic>
801051c1:	eb 0d                	jmp    801051d0 <argfd.constprop.0>
801051c3:	90                   	nop
801051c4:	90                   	nop
801051c5:	90                   	nop
801051c6:	90                   	nop
801051c7:	90                   	nop
801051c8:	90                   	nop
801051c9:	90                   	nop
801051ca:	90                   	nop
801051cb:	90                   	nop
801051cc:	90                   	nop
801051cd:	90                   	nop
801051ce:	90                   	nop
801051cf:	90                   	nop

801051d0 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
801051d0:	55                   	push   %ebp
801051d1:	89 e5                	mov    %esp,%ebp
801051d3:	56                   	push   %esi
801051d4:	53                   	push   %ebx
801051d5:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
801051d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
801051da:	89 d6                	mov    %edx,%esi
801051dc:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801051df:	50                   	push   %eax
801051e0:	6a 00                	push   $0x0
801051e2:	e8 c9 fc ff ff       	call   80104eb0 <argint>
801051e7:	83 c4 10             	add    $0x10,%esp
801051ea:	85 c0                	test   %eax,%eax
801051ec:	78 32                	js     80105220 <argfd.constprop.0+0x50>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801051ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f1:	83 f8 0f             	cmp    $0xf,%eax
801051f4:	77 2a                	ja     80105220 <argfd.constprop.0+0x50>
801051f6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801051fd:	8b 4c 82 4c          	mov    0x4c(%edx,%eax,4),%ecx
80105201:	85 c9                	test   %ecx,%ecx
80105203:	74 1b                	je     80105220 <argfd.constprop.0+0x50>
  if(pfd)
80105205:	85 db                	test   %ebx,%ebx
80105207:	74 02                	je     8010520b <argfd.constprop.0+0x3b>
    *pfd = fd;
80105209:	89 03                	mov    %eax,(%ebx)
    *pf = f;
8010520b:	89 0e                	mov    %ecx,(%esi)
  return 0;
8010520d:	31 c0                	xor    %eax,%eax
}
8010520f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105212:	5b                   	pop    %ebx
80105213:	5e                   	pop    %esi
80105214:	5d                   	pop    %ebp
80105215:	c3                   	ret    
80105216:	8d 76 00             	lea    0x0(%esi),%esi
80105219:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105225:	eb e8                	jmp    8010520f <argfd.constprop.0+0x3f>
80105227:	89 f6                	mov    %esi,%esi
80105229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105230 <sys_dup>:
{
80105230:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
80105231:	31 c0                	xor    %eax,%eax
{
80105233:	89 e5                	mov    %esp,%ebp
80105235:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
80105236:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
80105239:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010523c:	e8 8f ff ff ff       	call   801051d0 <argfd.constprop.0>
80105241:	85 c0                	test   %eax,%eax
80105243:	78 3b                	js     80105280 <sys_dup+0x50>
  if((fd=fdalloc(f)) < 0)
80105245:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if(proc->ofile[fd] == 0){
80105248:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  for(fd = 0; fd < NOFILE; fd++){
8010524e:	31 db                	xor    %ebx,%ebx
80105250:	eb 0e                	jmp    80105260 <sys_dup+0x30>
80105252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105258:	83 c3 01             	add    $0x1,%ebx
8010525b:	83 fb 10             	cmp    $0x10,%ebx
8010525e:	74 20                	je     80105280 <sys_dup+0x50>
    if(proc->ofile[fd] == 0){
80105260:	8b 4c 98 4c          	mov    0x4c(%eax,%ebx,4),%ecx
80105264:	85 c9                	test   %ecx,%ecx
80105266:	75 f0                	jne    80105258 <sys_dup+0x28>
  filedup(f);
80105268:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
8010526b:	89 54 98 4c          	mov    %edx,0x4c(%eax,%ebx,4)
  filedup(f);
8010526f:	52                   	push   %edx
80105270:	e8 4b bb ff ff       	call   80100dc0 <filedup>
}
80105275:	89 d8                	mov    %ebx,%eax
  return fd;
80105277:	83 c4 10             	add    $0x10,%esp
}
8010527a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010527d:	c9                   	leave  
8010527e:	c3                   	ret    
8010527f:	90                   	nop
    return -1;
80105280:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80105285:	89 d8                	mov    %ebx,%eax
80105287:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010528a:	c9                   	leave  
8010528b:	c3                   	ret    
8010528c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105290 <sys_read>:
{
80105290:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105291:	31 c0                	xor    %eax,%eax
{
80105293:	89 e5                	mov    %esp,%ebp
80105295:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105298:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010529b:	e8 30 ff ff ff       	call   801051d0 <argfd.constprop.0>
801052a0:	85 c0                	test   %eax,%eax
801052a2:	78 4c                	js     801052f0 <sys_read+0x60>
801052a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052a7:	83 ec 08             	sub    $0x8,%esp
801052aa:	50                   	push   %eax
801052ab:	6a 02                	push   $0x2
801052ad:	e8 fe fb ff ff       	call   80104eb0 <argint>
801052b2:	83 c4 10             	add    $0x10,%esp
801052b5:	85 c0                	test   %eax,%eax
801052b7:	78 37                	js     801052f0 <sys_read+0x60>
801052b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052bc:	83 ec 04             	sub    $0x4,%esp
801052bf:	ff 75 f0             	pushl  -0x10(%ebp)
801052c2:	50                   	push   %eax
801052c3:	6a 01                	push   $0x1
801052c5:	e8 26 fc ff ff       	call   80104ef0 <argptr>
801052ca:	83 c4 10             	add    $0x10,%esp
801052cd:	85 c0                	test   %eax,%eax
801052cf:	78 1f                	js     801052f0 <sys_read+0x60>
  return fileread(f, p, n);
801052d1:	83 ec 04             	sub    $0x4,%esp
801052d4:	ff 75 f0             	pushl  -0x10(%ebp)
801052d7:	ff 75 f4             	pushl  -0xc(%ebp)
801052da:	ff 75 ec             	pushl  -0x14(%ebp)
801052dd:	e8 4e bc ff ff       	call   80100f30 <fileread>
801052e2:	83 c4 10             	add    $0x10,%esp
}
801052e5:	c9                   	leave  
801052e6:	c3                   	ret    
801052e7:	89 f6                	mov    %esi,%esi
801052e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
801052f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052f5:	c9                   	leave  
801052f6:	c3                   	ret    
801052f7:	89 f6                	mov    %esi,%esi
801052f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105300 <sys_write>:
{
80105300:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105301:	31 c0                	xor    %eax,%eax
{
80105303:	89 e5                	mov    %esp,%ebp
80105305:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105308:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010530b:	e8 c0 fe ff ff       	call   801051d0 <argfd.constprop.0>
80105310:	85 c0                	test   %eax,%eax
80105312:	78 4c                	js     80105360 <sys_write+0x60>
80105314:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105317:	83 ec 08             	sub    $0x8,%esp
8010531a:	50                   	push   %eax
8010531b:	6a 02                	push   $0x2
8010531d:	e8 8e fb ff ff       	call   80104eb0 <argint>
80105322:	83 c4 10             	add    $0x10,%esp
80105325:	85 c0                	test   %eax,%eax
80105327:	78 37                	js     80105360 <sys_write+0x60>
80105329:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010532c:	83 ec 04             	sub    $0x4,%esp
8010532f:	ff 75 f0             	pushl  -0x10(%ebp)
80105332:	50                   	push   %eax
80105333:	6a 01                	push   $0x1
80105335:	e8 b6 fb ff ff       	call   80104ef0 <argptr>
8010533a:	83 c4 10             	add    $0x10,%esp
8010533d:	85 c0                	test   %eax,%eax
8010533f:	78 1f                	js     80105360 <sys_write+0x60>
  return filewrite(f, p, n);
80105341:	83 ec 04             	sub    $0x4,%esp
80105344:	ff 75 f0             	pushl  -0x10(%ebp)
80105347:	ff 75 f4             	pushl  -0xc(%ebp)
8010534a:	ff 75 ec             	pushl  -0x14(%ebp)
8010534d:	e8 6e bc ff ff       	call   80100fc0 <filewrite>
80105352:	83 c4 10             	add    $0x10,%esp
}
80105355:	c9                   	leave  
80105356:	c3                   	ret    
80105357:	89 f6                	mov    %esi,%esi
80105359:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105360:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105365:	c9                   	leave  
80105366:	c3                   	ret    
80105367:	89 f6                	mov    %esi,%esi
80105369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105370 <sys_close>:
{
80105370:	55                   	push   %ebp
80105371:	89 e5                	mov    %esp,%ebp
80105373:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80105376:	8d 55 f4             	lea    -0xc(%ebp),%edx
80105379:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010537c:	e8 4f fe ff ff       	call   801051d0 <argfd.constprop.0>
80105381:	85 c0                	test   %eax,%eax
80105383:	78 2b                	js     801053b0 <sys_close+0x40>
  proc->ofile[fd] = 0;
80105385:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010538b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
8010538e:	83 ec 0c             	sub    $0xc,%esp
  proc->ofile[fd] = 0;
80105391:	c7 44 90 4c 00 00 00 	movl   $0x0,0x4c(%eax,%edx,4)
80105398:	00 
  fileclose(f);
80105399:	ff 75 f4             	pushl  -0xc(%ebp)
8010539c:	e8 6f ba ff ff       	call   80100e10 <fileclose>
  return 0;
801053a1:	83 c4 10             	add    $0x10,%esp
801053a4:	31 c0                	xor    %eax,%eax
}
801053a6:	c9                   	leave  
801053a7:	c3                   	ret    
801053a8:	90                   	nop
801053a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801053b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053b5:	c9                   	leave  
801053b6:	c3                   	ret    
801053b7:	89 f6                	mov    %esi,%esi
801053b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801053c0 <sys_fstat>:
{
801053c0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801053c1:	31 c0                	xor    %eax,%eax
{
801053c3:	89 e5                	mov    %esp,%ebp
801053c5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801053c8:	8d 55 f0             	lea    -0x10(%ebp),%edx
801053cb:	e8 00 fe ff ff       	call   801051d0 <argfd.constprop.0>
801053d0:	85 c0                	test   %eax,%eax
801053d2:	78 2c                	js     80105400 <sys_fstat+0x40>
801053d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053d7:	83 ec 04             	sub    $0x4,%esp
801053da:	6a 14                	push   $0x14
801053dc:	50                   	push   %eax
801053dd:	6a 01                	push   $0x1
801053df:	e8 0c fb ff ff       	call   80104ef0 <argptr>
801053e4:	83 c4 10             	add    $0x10,%esp
801053e7:	85 c0                	test   %eax,%eax
801053e9:	78 15                	js     80105400 <sys_fstat+0x40>
  return filestat(f, st);
801053eb:	83 ec 08             	sub    $0x8,%esp
801053ee:	ff 75 f4             	pushl  -0xc(%ebp)
801053f1:	ff 75 f0             	pushl  -0x10(%ebp)
801053f4:	e8 e7 ba ff ff       	call   80100ee0 <filestat>
801053f9:	83 c4 10             	add    $0x10,%esp
}
801053fc:	c9                   	leave  
801053fd:	c3                   	ret    
801053fe:	66 90                	xchg   %ax,%ax
    return -1;
80105400:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105405:	c9                   	leave  
80105406:	c3                   	ret    
80105407:	89 f6                	mov    %esi,%esi
80105409:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105410 <sys_link>:
{
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	57                   	push   %edi
80105414:	56                   	push   %esi
80105415:	53                   	push   %ebx
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105416:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105419:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010541c:	50                   	push   %eax
8010541d:	6a 00                	push   $0x0
8010541f:	e8 1c fb ff ff       	call   80104f40 <argstr>
80105424:	83 c4 10             	add    $0x10,%esp
80105427:	85 c0                	test   %eax,%eax
80105429:	0f 88 fb 00 00 00    	js     8010552a <sys_link+0x11a>
8010542f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105432:	83 ec 08             	sub    $0x8,%esp
80105435:	50                   	push   %eax
80105436:	6a 01                	push   $0x1
80105438:	e8 03 fb ff ff       	call   80104f40 <argstr>
8010543d:	83 c4 10             	add    $0x10,%esp
80105440:	85 c0                	test   %eax,%eax
80105442:	0f 88 e2 00 00 00    	js     8010552a <sys_link+0x11a>
  begin_op();
80105448:	e8 e3 d7 ff ff       	call   80102c30 <begin_op>
  if((ip = namei(old)) == 0){
8010544d:	83 ec 0c             	sub    $0xc,%esp
80105450:	ff 75 d4             	pushl  -0x2c(%ebp)
80105453:	e8 68 ca ff ff       	call   80101ec0 <namei>
80105458:	83 c4 10             	add    $0x10,%esp
8010545b:	85 c0                	test   %eax,%eax
8010545d:	89 c3                	mov    %eax,%ebx
8010545f:	0f 84 ea 00 00 00    	je     8010554f <sys_link+0x13f>
  ilock(ip);
80105465:	83 ec 0c             	sub    $0xc,%esp
80105468:	50                   	push   %eax
80105469:	e8 a2 c1 ff ff       	call   80101610 <ilock>
  if(ip->type == T_DIR){
8010546e:	83 c4 10             	add    $0x10,%esp
80105471:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105476:	0f 84 bb 00 00 00    	je     80105537 <sys_link+0x127>
  ip->nlink++;
8010547c:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
80105481:	83 ec 0c             	sub    $0xc,%esp
  if((dp = nameiparent(new, name)) == 0)
80105484:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
80105487:	53                   	push   %ebx
80105488:	e8 d3 c0 ff ff       	call   80101560 <iupdate>
  iunlock(ip);
8010548d:	89 1c 24             	mov    %ebx,(%esp)
80105490:	e8 8b c2 ff ff       	call   80101720 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80105495:	58                   	pop    %eax
80105496:	5a                   	pop    %edx
80105497:	57                   	push   %edi
80105498:	ff 75 d0             	pushl  -0x30(%ebp)
8010549b:	e8 40 ca ff ff       	call   80101ee0 <nameiparent>
801054a0:	83 c4 10             	add    $0x10,%esp
801054a3:	85 c0                	test   %eax,%eax
801054a5:	89 c6                	mov    %eax,%esi
801054a7:	74 5b                	je     80105504 <sys_link+0xf4>
  ilock(dp);
801054a9:	83 ec 0c             	sub    $0xc,%esp
801054ac:	50                   	push   %eax
801054ad:	e8 5e c1 ff ff       	call   80101610 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801054b2:	83 c4 10             	add    $0x10,%esp
801054b5:	8b 03                	mov    (%ebx),%eax
801054b7:	39 06                	cmp    %eax,(%esi)
801054b9:	75 3d                	jne    801054f8 <sys_link+0xe8>
801054bb:	83 ec 04             	sub    $0x4,%esp
801054be:	ff 73 04             	pushl  0x4(%ebx)
801054c1:	57                   	push   %edi
801054c2:	56                   	push   %esi
801054c3:	e8 38 c9 ff ff       	call   80101e00 <dirlink>
801054c8:	83 c4 10             	add    $0x10,%esp
801054cb:	85 c0                	test   %eax,%eax
801054cd:	78 29                	js     801054f8 <sys_link+0xe8>
  iunlockput(dp);
801054cf:	83 ec 0c             	sub    $0xc,%esp
801054d2:	56                   	push   %esi
801054d3:	e8 08 c4 ff ff       	call   801018e0 <iunlockput>
  iput(ip);
801054d8:	89 1c 24             	mov    %ebx,(%esp)
801054db:	e8 a0 c2 ff ff       	call   80101780 <iput>
  end_op();
801054e0:	e8 bb d7 ff ff       	call   80102ca0 <end_op>
  return 0;
801054e5:	83 c4 10             	add    $0x10,%esp
801054e8:	31 c0                	xor    %eax,%eax
}
801054ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801054ed:	5b                   	pop    %ebx
801054ee:	5e                   	pop    %esi
801054ef:	5f                   	pop    %edi
801054f0:	5d                   	pop    %ebp
801054f1:	c3                   	ret    
801054f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
801054f8:	83 ec 0c             	sub    $0xc,%esp
801054fb:	56                   	push   %esi
801054fc:	e8 df c3 ff ff       	call   801018e0 <iunlockput>
    goto bad;
80105501:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105504:	83 ec 0c             	sub    $0xc,%esp
80105507:	53                   	push   %ebx
80105508:	e8 03 c1 ff ff       	call   80101610 <ilock>
  ip->nlink--;
8010550d:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
80105512:	89 1c 24             	mov    %ebx,(%esp)
80105515:	e8 46 c0 ff ff       	call   80101560 <iupdate>
  iunlockput(ip);
8010551a:	89 1c 24             	mov    %ebx,(%esp)
8010551d:	e8 be c3 ff ff       	call   801018e0 <iunlockput>
  end_op();
80105522:	e8 79 d7 ff ff       	call   80102ca0 <end_op>
  return -1;
80105527:	83 c4 10             	add    $0x10,%esp
}
8010552a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010552d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105532:	5b                   	pop    %ebx
80105533:	5e                   	pop    %esi
80105534:	5f                   	pop    %edi
80105535:	5d                   	pop    %ebp
80105536:	c3                   	ret    
    iunlockput(ip);
80105537:	83 ec 0c             	sub    $0xc,%esp
8010553a:	53                   	push   %ebx
8010553b:	e8 a0 c3 ff ff       	call   801018e0 <iunlockput>
    end_op();
80105540:	e8 5b d7 ff ff       	call   80102ca0 <end_op>
    return -1;
80105545:	83 c4 10             	add    $0x10,%esp
80105548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554d:	eb 9b                	jmp    801054ea <sys_link+0xda>
    end_op();
8010554f:	e8 4c d7 ff ff       	call   80102ca0 <end_op>
    return -1;
80105554:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105559:	eb 8f                	jmp    801054ea <sys_link+0xda>
8010555b:	90                   	nop
8010555c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105560 <sys_unlink>:
{
80105560:	55                   	push   %ebp
80105561:	89 e5                	mov    %esp,%ebp
80105563:	57                   	push   %edi
80105564:	56                   	push   %esi
80105565:	53                   	push   %ebx
  if(argstr(0, &path) < 0)
80105566:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80105569:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
8010556c:	50                   	push   %eax
8010556d:	6a 00                	push   $0x0
8010556f:	e8 cc f9 ff ff       	call   80104f40 <argstr>
80105574:	83 c4 10             	add    $0x10,%esp
80105577:	85 c0                	test   %eax,%eax
80105579:	0f 88 77 01 00 00    	js     801056f6 <sys_unlink+0x196>
  if((dp = nameiparent(path, name)) == 0){
8010557f:	8d 5d ca             	lea    -0x36(%ebp),%ebx
  begin_op();
80105582:	e8 a9 d6 ff ff       	call   80102c30 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105587:	83 ec 08             	sub    $0x8,%esp
8010558a:	53                   	push   %ebx
8010558b:	ff 75 c0             	pushl  -0x40(%ebp)
8010558e:	e8 4d c9 ff ff       	call   80101ee0 <nameiparent>
80105593:	83 c4 10             	add    $0x10,%esp
80105596:	85 c0                	test   %eax,%eax
80105598:	89 c6                	mov    %eax,%esi
8010559a:	0f 84 60 01 00 00    	je     80105700 <sys_unlink+0x1a0>
  ilock(dp);
801055a0:	83 ec 0c             	sub    $0xc,%esp
801055a3:	50                   	push   %eax
801055a4:	e8 67 c0 ff ff       	call   80101610 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801055a9:	58                   	pop    %eax
801055aa:	5a                   	pop    %edx
801055ab:	68 90 81 10 80       	push   $0x80108190
801055b0:	53                   	push   %ebx
801055b1:	e8 aa c5 ff ff       	call   80101b60 <namecmp>
801055b6:	83 c4 10             	add    $0x10,%esp
801055b9:	85 c0                	test   %eax,%eax
801055bb:	0f 84 03 01 00 00    	je     801056c4 <sys_unlink+0x164>
801055c1:	83 ec 08             	sub    $0x8,%esp
801055c4:	68 8f 81 10 80       	push   $0x8010818f
801055c9:	53                   	push   %ebx
801055ca:	e8 91 c5 ff ff       	call   80101b60 <namecmp>
801055cf:	83 c4 10             	add    $0x10,%esp
801055d2:	85 c0                	test   %eax,%eax
801055d4:	0f 84 ea 00 00 00    	je     801056c4 <sys_unlink+0x164>
  if((ip = dirlookup(dp, name, &off)) == 0)
801055da:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801055dd:	83 ec 04             	sub    $0x4,%esp
801055e0:	50                   	push   %eax
801055e1:	53                   	push   %ebx
801055e2:	56                   	push   %esi
801055e3:	e8 98 c5 ff ff       	call   80101b80 <dirlookup>
801055e8:	83 c4 10             	add    $0x10,%esp
801055eb:	85 c0                	test   %eax,%eax
801055ed:	89 c3                	mov    %eax,%ebx
801055ef:	0f 84 cf 00 00 00    	je     801056c4 <sys_unlink+0x164>
  ilock(ip);
801055f5:	83 ec 0c             	sub    $0xc,%esp
801055f8:	50                   	push   %eax
801055f9:	e8 12 c0 ff ff       	call   80101610 <ilock>
  if(ip->nlink < 1)
801055fe:	83 c4 10             	add    $0x10,%esp
80105601:	66 83 7b 16 00       	cmpw   $0x0,0x16(%ebx)
80105606:	0f 8e 10 01 00 00    	jle    8010571c <sys_unlink+0x1bc>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010560c:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105611:	74 6d                	je     80105680 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
80105613:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105616:	83 ec 04             	sub    $0x4,%esp
80105619:	6a 10                	push   $0x10
8010561b:	6a 00                	push   $0x0
8010561d:	50                   	push   %eax
8010561e:	e8 ad f5 ff ff       	call   80104bd0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105623:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105626:	6a 10                	push   $0x10
80105628:	ff 75 c4             	pushl  -0x3c(%ebp)
8010562b:	50                   	push   %eax
8010562c:	56                   	push   %esi
8010562d:	e8 fe c3 ff ff       	call   80101a30 <writei>
80105632:	83 c4 20             	add    $0x20,%esp
80105635:	83 f8 10             	cmp    $0x10,%eax
80105638:	0f 85 eb 00 00 00    	jne    80105729 <sys_unlink+0x1c9>
  if(ip->type == T_DIR){
8010563e:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105643:	0f 84 97 00 00 00    	je     801056e0 <sys_unlink+0x180>
  iunlockput(dp);
80105649:	83 ec 0c             	sub    $0xc,%esp
8010564c:	56                   	push   %esi
8010564d:	e8 8e c2 ff ff       	call   801018e0 <iunlockput>
  ip->nlink--;
80105652:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
80105657:	89 1c 24             	mov    %ebx,(%esp)
8010565a:	e8 01 bf ff ff       	call   80101560 <iupdate>
  iunlockput(ip);
8010565f:	89 1c 24             	mov    %ebx,(%esp)
80105662:	e8 79 c2 ff ff       	call   801018e0 <iunlockput>
  end_op();
80105667:	e8 34 d6 ff ff       	call   80102ca0 <end_op>
  return 0;
8010566c:	83 c4 10             	add    $0x10,%esp
8010566f:	31 c0                	xor    %eax,%eax
}
80105671:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105674:	5b                   	pop    %ebx
80105675:	5e                   	pop    %esi
80105676:	5f                   	pop    %edi
80105677:	5d                   	pop    %ebp
80105678:	c3                   	ret    
80105679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105680:	83 7b 18 20          	cmpl   $0x20,0x18(%ebx)
80105684:	76 8d                	jbe    80105613 <sys_unlink+0xb3>
80105686:	bf 20 00 00 00       	mov    $0x20,%edi
8010568b:	eb 0f                	jmp    8010569c <sys_unlink+0x13c>
8010568d:	8d 76 00             	lea    0x0(%esi),%esi
80105690:	83 c7 10             	add    $0x10,%edi
80105693:	3b 7b 18             	cmp    0x18(%ebx),%edi
80105696:	0f 83 77 ff ff ff    	jae    80105613 <sys_unlink+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010569c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010569f:	6a 10                	push   $0x10
801056a1:	57                   	push   %edi
801056a2:	50                   	push   %eax
801056a3:	53                   	push   %ebx
801056a4:	e8 87 c2 ff ff       	call   80101930 <readi>
801056a9:	83 c4 10             	add    $0x10,%esp
801056ac:	83 f8 10             	cmp    $0x10,%eax
801056af:	75 5e                	jne    8010570f <sys_unlink+0x1af>
    if(de.inum != 0)
801056b1:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801056b6:	74 d8                	je     80105690 <sys_unlink+0x130>
    iunlockput(ip);
801056b8:	83 ec 0c             	sub    $0xc,%esp
801056bb:	53                   	push   %ebx
801056bc:	e8 1f c2 ff ff       	call   801018e0 <iunlockput>
    goto bad;
801056c1:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801056c4:	83 ec 0c             	sub    $0xc,%esp
801056c7:	56                   	push   %esi
801056c8:	e8 13 c2 ff ff       	call   801018e0 <iunlockput>
  end_op();
801056cd:	e8 ce d5 ff ff       	call   80102ca0 <end_op>
  return -1;
801056d2:	83 c4 10             	add    $0x10,%esp
801056d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056da:	eb 95                	jmp    80105671 <sys_unlink+0x111>
801056dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink--;
801056e0:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
    iupdate(dp);
801056e5:	83 ec 0c             	sub    $0xc,%esp
801056e8:	56                   	push   %esi
801056e9:	e8 72 be ff ff       	call   80101560 <iupdate>
801056ee:	83 c4 10             	add    $0x10,%esp
801056f1:	e9 53 ff ff ff       	jmp    80105649 <sys_unlink+0xe9>
    return -1;
801056f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fb:	e9 71 ff ff ff       	jmp    80105671 <sys_unlink+0x111>
    end_op();
80105700:	e8 9b d5 ff ff       	call   80102ca0 <end_op>
    return -1;
80105705:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010570a:	e9 62 ff ff ff       	jmp    80105671 <sys_unlink+0x111>
      panic("isdirempty: readi");
8010570f:	83 ec 0c             	sub    $0xc,%esp
80105712:	68 b4 81 10 80       	push   $0x801081b4
80105717:	e8 54 ac ff ff       	call   80100370 <panic>
    panic("unlink: nlink < 1");
8010571c:	83 ec 0c             	sub    $0xc,%esp
8010571f:	68 a2 81 10 80       	push   $0x801081a2
80105724:	e8 47 ac ff ff       	call   80100370 <panic>
    panic("unlink: writei");
80105729:	83 ec 0c             	sub    $0xc,%esp
8010572c:	68 c6 81 10 80       	push   $0x801081c6
80105731:	e8 3a ac ff ff       	call   80100370 <panic>
80105736:	8d 76 00             	lea    0x0(%esi),%esi
80105739:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105740 <sys_open>:

int
sys_open(void)
{
80105740:	55                   	push   %ebp
80105741:	89 e5                	mov    %esp,%ebp
80105743:	57                   	push   %edi
80105744:	56                   	push   %esi
80105745:	53                   	push   %ebx
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105746:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105749:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010574c:	50                   	push   %eax
8010574d:	6a 00                	push   $0x0
8010574f:	e8 ec f7 ff ff       	call   80104f40 <argstr>
80105754:	83 c4 10             	add    $0x10,%esp
80105757:	85 c0                	test   %eax,%eax
80105759:	0f 88 1d 01 00 00    	js     8010587c <sys_open+0x13c>
8010575f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105762:	83 ec 08             	sub    $0x8,%esp
80105765:	50                   	push   %eax
80105766:	6a 01                	push   $0x1
80105768:	e8 43 f7 ff ff       	call   80104eb0 <argint>
8010576d:	83 c4 10             	add    $0x10,%esp
80105770:	85 c0                	test   %eax,%eax
80105772:	0f 88 04 01 00 00    	js     8010587c <sys_open+0x13c>
    return -1;

  begin_op();
80105778:	e8 b3 d4 ff ff       	call   80102c30 <begin_op>

  if(omode & O_CREATE){
8010577d:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
80105781:	0f 85 a9 00 00 00    	jne    80105830 <sys_open+0xf0>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
80105787:	83 ec 0c             	sub    $0xc,%esp
8010578a:	ff 75 e0             	pushl  -0x20(%ebp)
8010578d:	e8 2e c7 ff ff       	call   80101ec0 <namei>
80105792:	83 c4 10             	add    $0x10,%esp
80105795:	85 c0                	test   %eax,%eax
80105797:	89 c6                	mov    %eax,%esi
80105799:	0f 84 b2 00 00 00    	je     80105851 <sys_open+0x111>
      end_op();
      return -1;
    }
    ilock(ip);
8010579f:	83 ec 0c             	sub    $0xc,%esp
801057a2:	50                   	push   %eax
801057a3:	e8 68 be ff ff       	call   80101610 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801057a8:	83 c4 10             	add    $0x10,%esp
801057ab:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
801057b0:	0f 84 aa 00 00 00    	je     80105860 <sys_open+0x120>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801057b6:	e8 95 b5 ff ff       	call   80100d50 <filealloc>
801057bb:	85 c0                	test   %eax,%eax
801057bd:	89 c7                	mov    %eax,%edi
801057bf:	0f 84 a6 00 00 00    	je     8010586b <sys_open+0x12b>
    if(proc->ofile[fd] == 0){
801057c5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  for(fd = 0; fd < NOFILE; fd++){
801057cc:	31 db                	xor    %ebx,%ebx
801057ce:	eb 0c                	jmp    801057dc <sys_open+0x9c>
801057d0:	83 c3 01             	add    $0x1,%ebx
801057d3:	83 fb 10             	cmp    $0x10,%ebx
801057d6:	0f 84 ac 00 00 00    	je     80105888 <sys_open+0x148>
    if(proc->ofile[fd] == 0){
801057dc:	8b 44 9a 4c          	mov    0x4c(%edx,%ebx,4),%eax
801057e0:	85 c0                	test   %eax,%eax
801057e2:	75 ec                	jne    801057d0 <sys_open+0x90>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801057e4:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
801057e7:	89 7c 9a 4c          	mov    %edi,0x4c(%edx,%ebx,4)
  iunlock(ip);
801057eb:	56                   	push   %esi
801057ec:	e8 2f bf ff ff       	call   80101720 <iunlock>
  end_op();
801057f1:	e8 aa d4 ff ff       	call   80102ca0 <end_op>

  f->type = FD_INODE;
801057f6:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
801057fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801057ff:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105802:	89 77 10             	mov    %esi,0x10(%edi)
  f->off = 0;
80105805:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
8010580c:	89 d0                	mov    %edx,%eax
8010580e:	f7 d0                	not    %eax
80105810:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105813:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
80105816:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105819:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
8010581d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105820:	89 d8                	mov    %ebx,%eax
80105822:	5b                   	pop    %ebx
80105823:	5e                   	pop    %esi
80105824:	5f                   	pop    %edi
80105825:	5d                   	pop    %ebp
80105826:	c3                   	ret    
80105827:	89 f6                	mov    %esi,%esi
80105829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ip = create(path, T_FILE, 0, 0);
80105830:	83 ec 0c             	sub    $0xc,%esp
80105833:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105836:	31 c9                	xor    %ecx,%ecx
80105838:	6a 00                	push   $0x0
8010583a:	ba 02 00 00 00       	mov    $0x2,%edx
8010583f:	e8 ec f7 ff ff       	call   80105030 <create>
    if(ip == 0){
80105844:	83 c4 10             	add    $0x10,%esp
80105847:	85 c0                	test   %eax,%eax
    ip = create(path, T_FILE, 0, 0);
80105849:	89 c6                	mov    %eax,%esi
    if(ip == 0){
8010584b:	0f 85 65 ff ff ff    	jne    801057b6 <sys_open+0x76>
      end_op();
80105851:	e8 4a d4 ff ff       	call   80102ca0 <end_op>
      return -1;
80105856:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010585b:	eb c0                	jmp    8010581d <sys_open+0xdd>
8010585d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->type == T_DIR && omode != O_RDONLY){
80105860:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105863:	85 d2                	test   %edx,%edx
80105865:	0f 84 4b ff ff ff    	je     801057b6 <sys_open+0x76>
    iunlockput(ip);
8010586b:	83 ec 0c             	sub    $0xc,%esp
8010586e:	56                   	push   %esi
8010586f:	e8 6c c0 ff ff       	call   801018e0 <iunlockput>
    end_op();
80105874:	e8 27 d4 ff ff       	call   80102ca0 <end_op>
    return -1;
80105879:	83 c4 10             	add    $0x10,%esp
8010587c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105881:	eb 9a                	jmp    8010581d <sys_open+0xdd>
80105883:	90                   	nop
80105884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      fileclose(f);
80105888:	83 ec 0c             	sub    $0xc,%esp
8010588b:	57                   	push   %edi
8010588c:	e8 7f b5 ff ff       	call   80100e10 <fileclose>
80105891:	83 c4 10             	add    $0x10,%esp
80105894:	eb d5                	jmp    8010586b <sys_open+0x12b>
80105896:	8d 76 00             	lea    0x0(%esi),%esi
80105899:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801058a0 <sys_mkdir>:

int
sys_mkdir(void)
{
801058a0:	55                   	push   %ebp
801058a1:	89 e5                	mov    %esp,%ebp
801058a3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801058a6:	e8 85 d3 ff ff       	call   80102c30 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801058ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058ae:	83 ec 08             	sub    $0x8,%esp
801058b1:	50                   	push   %eax
801058b2:	6a 00                	push   $0x0
801058b4:	e8 87 f6 ff ff       	call   80104f40 <argstr>
801058b9:	83 c4 10             	add    $0x10,%esp
801058bc:	85 c0                	test   %eax,%eax
801058be:	78 30                	js     801058f0 <sys_mkdir+0x50>
801058c0:	83 ec 0c             	sub    $0xc,%esp
801058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c6:	31 c9                	xor    %ecx,%ecx
801058c8:	6a 00                	push   $0x0
801058ca:	ba 01 00 00 00       	mov    $0x1,%edx
801058cf:	e8 5c f7 ff ff       	call   80105030 <create>
801058d4:	83 c4 10             	add    $0x10,%esp
801058d7:	85 c0                	test   %eax,%eax
801058d9:	74 15                	je     801058f0 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
801058db:	83 ec 0c             	sub    $0xc,%esp
801058de:	50                   	push   %eax
801058df:	e8 fc bf ff ff       	call   801018e0 <iunlockput>
  end_op();
801058e4:	e8 b7 d3 ff ff       	call   80102ca0 <end_op>
  return 0;
801058e9:	83 c4 10             	add    $0x10,%esp
801058ec:	31 c0                	xor    %eax,%eax
}
801058ee:	c9                   	leave  
801058ef:	c3                   	ret    
    end_op();
801058f0:	e8 ab d3 ff ff       	call   80102ca0 <end_op>
    return -1;
801058f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058fa:	c9                   	leave  
801058fb:	c3                   	ret    
801058fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105900 <sys_mknod>:

int
sys_mknod(void)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
80105903:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105906:	e8 25 d3 ff ff       	call   80102c30 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010590b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010590e:	83 ec 08             	sub    $0x8,%esp
80105911:	50                   	push   %eax
80105912:	6a 00                	push   $0x0
80105914:	e8 27 f6 ff ff       	call   80104f40 <argstr>
80105919:	83 c4 10             	add    $0x10,%esp
8010591c:	85 c0                	test   %eax,%eax
8010591e:	78 60                	js     80105980 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105920:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105923:	83 ec 08             	sub    $0x8,%esp
80105926:	50                   	push   %eax
80105927:	6a 01                	push   $0x1
80105929:	e8 82 f5 ff ff       	call   80104eb0 <argint>
  if((argstr(0, &path)) < 0 ||
8010592e:	83 c4 10             	add    $0x10,%esp
80105931:	85 c0                	test   %eax,%eax
80105933:	78 4b                	js     80105980 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105935:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105938:	83 ec 08             	sub    $0x8,%esp
8010593b:	50                   	push   %eax
8010593c:	6a 02                	push   $0x2
8010593e:	e8 6d f5 ff ff       	call   80104eb0 <argint>
     argint(1, &major) < 0 ||
80105943:	83 c4 10             	add    $0x10,%esp
80105946:	85 c0                	test   %eax,%eax
80105948:	78 36                	js     80105980 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010594a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
     argint(2, &minor) < 0 ||
8010594e:	83 ec 0c             	sub    $0xc,%esp
     (ip = create(path, T_DEV, major, minor)) == 0){
80105951:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80105955:	ba 03 00 00 00       	mov    $0x3,%edx
8010595a:	50                   	push   %eax
8010595b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010595e:	e8 cd f6 ff ff       	call   80105030 <create>
80105963:	83 c4 10             	add    $0x10,%esp
80105966:	85 c0                	test   %eax,%eax
80105968:	74 16                	je     80105980 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010596a:	83 ec 0c             	sub    $0xc,%esp
8010596d:	50                   	push   %eax
8010596e:	e8 6d bf ff ff       	call   801018e0 <iunlockput>
  end_op();
80105973:	e8 28 d3 ff ff       	call   80102ca0 <end_op>
  return 0;
80105978:	83 c4 10             	add    $0x10,%esp
8010597b:	31 c0                	xor    %eax,%eax
}
8010597d:	c9                   	leave  
8010597e:	c3                   	ret    
8010597f:	90                   	nop
    end_op();
80105980:	e8 1b d3 ff ff       	call   80102ca0 <end_op>
    return -1;
80105985:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010598a:	c9                   	leave  
8010598b:	c3                   	ret    
8010598c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105990 <sys_chdir>:

int
sys_chdir(void)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	53                   	push   %ebx
80105994:	83 ec 14             	sub    $0x14,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105997:	e8 94 d2 ff ff       	call   80102c30 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010599c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010599f:	83 ec 08             	sub    $0x8,%esp
801059a2:	50                   	push   %eax
801059a3:	6a 00                	push   $0x0
801059a5:	e8 96 f5 ff ff       	call   80104f40 <argstr>
801059aa:	83 c4 10             	add    $0x10,%esp
801059ad:	85 c0                	test   %eax,%eax
801059af:	78 7f                	js     80105a30 <sys_chdir+0xa0>
801059b1:	83 ec 0c             	sub    $0xc,%esp
801059b4:	ff 75 f4             	pushl  -0xc(%ebp)
801059b7:	e8 04 c5 ff ff       	call   80101ec0 <namei>
801059bc:	83 c4 10             	add    $0x10,%esp
801059bf:	85 c0                	test   %eax,%eax
801059c1:	89 c3                	mov    %eax,%ebx
801059c3:	74 6b                	je     80105a30 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
801059c5:	83 ec 0c             	sub    $0xc,%esp
801059c8:	50                   	push   %eax
801059c9:	e8 42 bc ff ff       	call   80101610 <ilock>
  if(ip->type != T_DIR){
801059ce:	83 c4 10             	add    $0x10,%esp
801059d1:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
801059d6:	75 38                	jne    80105a10 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801059d8:	83 ec 0c             	sub    $0xc,%esp
801059db:	53                   	push   %ebx
801059dc:	e8 3f bd ff ff       	call   80101720 <iunlock>
  iput(proc->cwd);
801059e1:	58                   	pop    %eax
801059e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059e8:	ff b0 8c 00 00 00    	pushl  0x8c(%eax)
801059ee:	e8 8d bd ff ff       	call   80101780 <iput>
  end_op();
801059f3:	e8 a8 d2 ff ff       	call   80102ca0 <end_op>
  proc->cwd = ip;
801059f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return 0;
801059fe:	83 c4 10             	add    $0x10,%esp
  proc->cwd = ip;
80105a01:	89 98 8c 00 00 00    	mov    %ebx,0x8c(%eax)
  return 0;
80105a07:	31 c0                	xor    %eax,%eax
}
80105a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105a0c:	c9                   	leave  
80105a0d:	c3                   	ret    
80105a0e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80105a10:	83 ec 0c             	sub    $0xc,%esp
80105a13:	53                   	push   %ebx
80105a14:	e8 c7 be ff ff       	call   801018e0 <iunlockput>
    end_op();
80105a19:	e8 82 d2 ff ff       	call   80102ca0 <end_op>
    return -1;
80105a1e:	83 c4 10             	add    $0x10,%esp
80105a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a26:	eb e1                	jmp    80105a09 <sys_chdir+0x79>
80105a28:	90                   	nop
80105a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    end_op();
80105a30:	e8 6b d2 ff ff       	call   80102ca0 <end_op>
    return -1;
80105a35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a3a:	eb cd                	jmp    80105a09 <sys_chdir+0x79>
80105a3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a40 <sys_exec>:

int
sys_exec(void)
{
80105a40:	55                   	push   %ebp
80105a41:	89 e5                	mov    %esp,%ebp
80105a43:	57                   	push   %edi
80105a44:	56                   	push   %esi
80105a45:	53                   	push   %ebx
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105a46:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
80105a4c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105a52:	50                   	push   %eax
80105a53:	6a 00                	push   $0x0
80105a55:	e8 e6 f4 ff ff       	call   80104f40 <argstr>
80105a5a:	83 c4 10             	add    $0x10,%esp
80105a5d:	85 c0                	test   %eax,%eax
80105a5f:	0f 88 87 00 00 00    	js     80105aec <sys_exec+0xac>
80105a65:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105a6b:	83 ec 08             	sub    $0x8,%esp
80105a6e:	50                   	push   %eax
80105a6f:	6a 01                	push   $0x1
80105a71:	e8 3a f4 ff ff       	call   80104eb0 <argint>
80105a76:	83 c4 10             	add    $0x10,%esp
80105a79:	85 c0                	test   %eax,%eax
80105a7b:	78 6f                	js     80105aec <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105a7d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a83:	83 ec 04             	sub    $0x4,%esp
  for(i=0;; i++){
80105a86:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105a88:	68 80 00 00 00       	push   $0x80
80105a8d:	6a 00                	push   $0x0
80105a8f:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
80105a95:	50                   	push   %eax
80105a96:	e8 35 f1 ff ff       	call   80104bd0 <memset>
80105a9b:	83 c4 10             	add    $0x10,%esp
80105a9e:	eb 2c                	jmp    80105acc <sys_exec+0x8c>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
80105aa0:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105aa6:	85 c0                	test   %eax,%eax
80105aa8:	74 56                	je     80105b00 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105aaa:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
80105ab0:	83 ec 08             	sub    $0x8,%esp
80105ab3:	8d 14 31             	lea    (%ecx,%esi,1),%edx
80105ab6:	52                   	push   %edx
80105ab7:	50                   	push   %eax
80105ab8:	e8 93 f3 ff ff       	call   80104e50 <fetchstr>
80105abd:	83 c4 10             	add    $0x10,%esp
80105ac0:	85 c0                	test   %eax,%eax
80105ac2:	78 28                	js     80105aec <sys_exec+0xac>
  for(i=0;; i++){
80105ac4:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105ac7:	83 fb 20             	cmp    $0x20,%ebx
80105aca:	74 20                	je     80105aec <sys_exec+0xac>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105acc:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105ad2:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
80105ad9:	83 ec 08             	sub    $0x8,%esp
80105adc:	57                   	push   %edi
80105add:	01 f0                	add    %esi,%eax
80105adf:	50                   	push   %eax
80105ae0:	e8 3b f3 ff ff       	call   80104e20 <fetchint>
80105ae5:	83 c4 10             	add    $0x10,%esp
80105ae8:	85 c0                	test   %eax,%eax
80105aea:	79 b4                	jns    80105aa0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
80105aec:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105aef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105af4:	5b                   	pop    %ebx
80105af5:	5e                   	pop    %esi
80105af6:	5f                   	pop    %edi
80105af7:	5d                   	pop    %ebp
80105af8:	c3                   	ret    
80105af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105b00:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b06:	83 ec 08             	sub    $0x8,%esp
      argv[i] = 0;
80105b09:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105b10:	00 00 00 00 
  return exec(path, argv);
80105b14:	50                   	push   %eax
80105b15:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
80105b1b:	e8 d0 ae ff ff       	call   801009f0 <exec>
80105b20:	83 c4 10             	add    $0x10,%esp
}
80105b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105b26:	5b                   	pop    %ebx
80105b27:	5e                   	pop    %esi
80105b28:	5f                   	pop    %edi
80105b29:	5d                   	pop    %ebp
80105b2a:	c3                   	ret    
80105b2b:	90                   	nop
80105b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105b30 <sys_pipe>:

int
sys_pipe(void)
{
80105b30:	55                   	push   %ebp
80105b31:	89 e5                	mov    %esp,%ebp
80105b33:	57                   	push   %edi
80105b34:	56                   	push   %esi
80105b35:	53                   	push   %ebx
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105b36:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105b39:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105b3c:	6a 08                	push   $0x8
80105b3e:	50                   	push   %eax
80105b3f:	6a 00                	push   $0x0
80105b41:	e8 aa f3 ff ff       	call   80104ef0 <argptr>
80105b46:	83 c4 10             	add    $0x10,%esp
80105b49:	85 c0                	test   %eax,%eax
80105b4b:	0f 88 a4 00 00 00    	js     80105bf5 <sys_pipe+0xc5>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105b51:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b54:	83 ec 08             	sub    $0x8,%esp
80105b57:	50                   	push   %eax
80105b58:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b5b:	50                   	push   %eax
80105b5c:	e8 6f d8 ff ff       	call   801033d0 <pipealloc>
80105b61:	83 c4 10             	add    $0x10,%esp
80105b64:	85 c0                	test   %eax,%eax
80105b66:	0f 88 89 00 00 00    	js     80105bf5 <sys_pipe+0xc5>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105b6c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
    if(proc->ofile[fd] == 0){
80105b6f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  for(fd = 0; fd < NOFILE; fd++){
80105b76:	31 c0                	xor    %eax,%eax
80105b78:	eb 0e                	jmp    80105b88 <sys_pipe+0x58>
80105b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105b80:	83 c0 01             	add    $0x1,%eax
80105b83:	83 f8 10             	cmp    $0x10,%eax
80105b86:	74 58                	je     80105be0 <sys_pipe+0xb0>
    if(proc->ofile[fd] == 0){
80105b88:	8b 54 81 4c          	mov    0x4c(%ecx,%eax,4),%edx
80105b8c:	85 d2                	test   %edx,%edx
80105b8e:	75 f0                	jne    80105b80 <sys_pipe+0x50>
80105b90:	8d 34 81             	lea    (%ecx,%eax,4),%esi
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105b93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105b96:	31 d2                	xor    %edx,%edx
      proc->ofile[fd] = f;
80105b98:	89 5e 4c             	mov    %ebx,0x4c(%esi)
80105b9b:	eb 0b                	jmp    80105ba8 <sys_pipe+0x78>
80105b9d:	8d 76 00             	lea    0x0(%esi),%esi
  for(fd = 0; fd < NOFILE; fd++){
80105ba0:	83 c2 01             	add    $0x1,%edx
80105ba3:	83 fa 10             	cmp    $0x10,%edx
80105ba6:	74 28                	je     80105bd0 <sys_pipe+0xa0>
    if(proc->ofile[fd] == 0){
80105ba8:	83 7c 91 4c 00       	cmpl   $0x0,0x4c(%ecx,%edx,4)
80105bad:	75 f1                	jne    80105ba0 <sys_pipe+0x70>
      proc->ofile[fd] = f;
80105baf:	89 7c 91 4c          	mov    %edi,0x4c(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105bb3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80105bb6:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
80105bb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105bbb:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105bbe:	31 c0                	xor    %eax,%eax
}
80105bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105bc3:	5b                   	pop    %ebx
80105bc4:	5e                   	pop    %esi
80105bc5:	5f                   	pop    %edi
80105bc6:	5d                   	pop    %ebp
80105bc7:	c3                   	ret    
80105bc8:	90                   	nop
80105bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      proc->ofile[fd0] = 0;
80105bd0:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
80105bd7:	89 f6                	mov    %esi,%esi
80105bd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    fileclose(rf);
80105be0:	83 ec 0c             	sub    $0xc,%esp
80105be3:	53                   	push   %ebx
80105be4:	e8 27 b2 ff ff       	call   80100e10 <fileclose>
    fileclose(wf);
80105be9:	58                   	pop    %eax
80105bea:	ff 75 e4             	pushl  -0x1c(%ebp)
80105bed:	e8 1e b2 ff ff       	call   80100e10 <fileclose>
    return -1;
80105bf2:	83 c4 10             	add    $0x10,%esp
80105bf5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfa:	eb c4                	jmp    80105bc0 <sys_pipe+0x90>
80105bfc:	66 90                	xchg   %ax,%ax
80105bfe:	66 90                	xchg   %ax,%ax

80105c00 <sys_clone>:
#include "mmu.h"
#include "proc.h"

int 
sys_clone(void)
{
80105c00:	55                   	push   %ebp
80105c01:	89 e5                	mov    %esp,%ebp
80105c03:	83 ec 20             	sub    $0x20,%esp
  int func_add;
  int arg;
  int stack_add;

  if (argint(0, &func_add) < 0)
80105c06:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c09:	50                   	push   %eax
80105c0a:	6a 00                	push   $0x0
80105c0c:	e8 9f f2 ff ff       	call   80104eb0 <argint>
80105c11:	83 c4 10             	add    $0x10,%esp
80105c14:	85 c0                	test   %eax,%eax
80105c16:	78 48                	js     80105c60 <sys_clone+0x60>
     return -1;
  if (argint(1, &arg) < 0)
80105c18:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c1b:	83 ec 08             	sub    $0x8,%esp
80105c1e:	50                   	push   %eax
80105c1f:	6a 01                	push   $0x1
80105c21:	e8 8a f2 ff ff       	call   80104eb0 <argint>
80105c26:	83 c4 10             	add    $0x10,%esp
80105c29:	85 c0                	test   %eax,%eax
80105c2b:	78 33                	js     80105c60 <sys_clone+0x60>
     return -1;
  if (argint(2, &stack_add) < 0)
80105c2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c30:	83 ec 08             	sub    $0x8,%esp
80105c33:	50                   	push   %eax
80105c34:	6a 02                	push   $0x2
80105c36:	e8 75 f2 ff ff       	call   80104eb0 <argint>
80105c3b:	83 c4 10             	add    $0x10,%esp
80105c3e:	85 c0                	test   %eax,%eax
80105c40:	78 1e                	js     80105c60 <sys_clone+0x60>
     return -1;
 
  return clone((void *)func_add, (void *)arg, (void *)stack_add);
80105c42:	83 ec 04             	sub    $0x4,%esp
80105c45:	ff 75 f4             	pushl  -0xc(%ebp)
80105c48:	ff 75 f0             	pushl  -0x10(%ebp)
80105c4b:	ff 75 ec             	pushl  -0x14(%ebp)
80105c4e:	e8 ed e9 ff ff       	call   80104640 <clone>
80105c53:	83 c4 10             	add    $0x10,%esp
  
}
80105c56:	c9                   	leave  
80105c57:	c3                   	ret    
80105c58:	90                   	nop
80105c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
80105c60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c65:	c9                   	leave  
80105c66:	c3                   	ret    
80105c67:	89 f6                	mov    %esi,%esi
80105c69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105c70 <sys_join>:

int 
sys_join(void)
{
80105c70:	55                   	push   %ebp
80105c71:	89 e5                	mov    %esp,%ebp
80105c73:	83 ec 20             	sub    $0x20,%esp
  int stack_add;

  if (argint(0, &stack_add) < 0)
80105c76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c79:	50                   	push   %eax
80105c7a:	6a 00                	push   $0x0
80105c7c:	e8 2f f2 ff ff       	call   80104eb0 <argint>
80105c81:	83 c4 10             	add    $0x10,%esp
80105c84:	85 c0                	test   %eax,%eax
80105c86:	78 18                	js     80105ca0 <sys_join+0x30>
     return -1;

  return join((void **)stack_add);
80105c88:	83 ec 0c             	sub    $0xc,%esp
80105c8b:	ff 75 f4             	pushl  -0xc(%ebp)
80105c8e:	e8 cd ea ff ff       	call   80104760 <join>
80105c93:	83 c4 10             	add    $0x10,%esp
}
80105c96:	c9                   	leave  
80105c97:	c3                   	ret    
80105c98:	90                   	nop
80105c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
80105ca0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ca5:	c9                   	leave  
80105ca6:	c3                   	ret    
80105ca7:	89 f6                	mov    %esi,%esi
80105ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105cb0 <sys_myalloc>:

int 
sys_myalloc(void)
{
80105cb0:	55                   	push   %ebp
80105cb1:	89 e5                	mov    %esp,%ebp
80105cb3:	83 ec 20             	sub    $0x20,%esp
  int n;   // 分配 n 个字节
  if(argint(0, &n) < 0)
80105cb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cb9:	50                   	push   %eax
80105cba:	6a 00                	push   $0x0
80105cbc:	e8 ef f1 ff ff       	call   80104eb0 <argint>
80105cc1:	83 c4 10             	add    $0x10,%esp
    return 0;
80105cc4:	31 d2                	xor    %edx,%edx
  if(argint(0, &n) < 0)
80105cc6:	85 c0                	test   %eax,%eax
80105cc8:	78 15                	js     80105cdf <sys_myalloc+0x2f>
  if(n <= 0)
80105cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccd:	85 c0                	test   %eax,%eax
80105ccf:	7e 0e                	jle    80105cdf <sys_myalloc+0x2f>
    return 0;
  return mygrowproc(n);
80105cd1:	83 ec 0c             	sub    $0xc,%esp
80105cd4:	50                   	push   %eax
80105cd5:	e8 76 e7 ff ff       	call   80104450 <mygrowproc>
80105cda:	83 c4 10             	add    $0x10,%esp
80105cdd:	89 c2                	mov    %eax,%edx
}
80105cdf:	89 d0                	mov    %edx,%eax
80105ce1:	c9                   	leave  
80105ce2:	c3                   	ret    
80105ce3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105cf0 <sys_myfree>:

int 
sys_myfree(void) {
80105cf0:	55                   	push   %ebp
80105cf1:	89 e5                	mov    %esp,%ebp
80105cf3:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(0, &addr) < 0)
80105cf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cf9:	50                   	push   %eax
80105cfa:	6a 00                	push   $0x0
80105cfc:	e8 af f1 ff ff       	call   80104eb0 <argint>
80105d01:	83 c4 10             	add    $0x10,%esp
80105d04:	85 c0                	test   %eax,%eax
80105d06:	78 18                	js     80105d20 <sys_myfree+0x30>
    return -1;
  return myreduceproc(addr);
80105d08:	83 ec 0c             	sub    $0xc,%esp
80105d0b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d0e:	e8 5d e8 ff ff       	call   80104570 <myreduceproc>
80105d13:	83 c4 10             	add    $0x10,%esp
}
80105d16:	c9                   	leave  
80105d17:	c3                   	ret    
80105d18:	90                   	nop
80105d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105d20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d25:	c9                   	leave  
80105d26:	c3                   	ret    
80105d27:	89 f6                	mov    %esi,%esi
80105d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105d30 <sys_getcpuid>:

//achieve sys_getcpuid, just my homework
int
sys_getcpuid()
{
80105d30:	55                   	push   %ebp
80105d31:	89 e5                	mov    %esp,%ebp
  return getcpuid();
}
80105d33:	5d                   	pop    %ebp
  return getcpuid();
80105d34:	e9 07 dc ff ff       	jmp    80103940 <getcpuid>
80105d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105d40 <sys_fork>:

int
sys_fork(void)
{
80105d40:	55                   	push   %ebp
80105d41:	89 e5                	mov    %esp,%ebp
  return fork();
}
80105d43:	5d                   	pop    %ebp
  return fork();
80105d44:	e9 a7 dd ff ff       	jmp    80103af0 <fork>
80105d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105d50 <sys_exit>:

int
sys_exit(void)
{
80105d50:	55                   	push   %ebp
80105d51:	89 e5                	mov    %esp,%ebp
80105d53:	83 ec 08             	sub    $0x8,%esp
  exit();
80105d56:	e8 95 e0 ff ff       	call   80103df0 <exit>
  return 0;  // not reached
}
80105d5b:	31 c0                	xor    %eax,%eax
80105d5d:	c9                   	leave  
80105d5e:	c3                   	ret    
80105d5f:	90                   	nop

80105d60 <sys_wait>:

int
sys_wait(void)
{
80105d60:	55                   	push   %ebp
80105d61:	89 e5                	mov    %esp,%ebp
  return wait();
}
80105d63:	5d                   	pop    %ebp
  return wait();
80105d64:	e9 b7 e3 ff ff       	jmp    80104120 <wait>
80105d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105d70 <sys_kill>:

int
sys_kill(void)
{
80105d70:	55                   	push   %ebp
80105d71:	89 e5                	mov    %esp,%ebp
80105d73:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105d76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d79:	50                   	push   %eax
80105d7a:	6a 00                	push   $0x0
80105d7c:	e8 2f f1 ff ff       	call   80104eb0 <argint>
80105d81:	83 c4 10             	add    $0x10,%esp
80105d84:	85 c0                	test   %eax,%eax
80105d86:	78 18                	js     80105da0 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105d88:	83 ec 0c             	sub    $0xc,%esp
80105d8b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d8e:	e8 1d e5 ff ff       	call   801042b0 <kill>
80105d93:	83 c4 10             	add    $0x10,%esp
}
80105d96:	c9                   	leave  
80105d97:	c3                   	ret    
80105d98:	90                   	nop
80105d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105da5:	c9                   	leave  
80105da6:	c3                   	ret    
80105da7:	89 f6                	mov    %esi,%esi
80105da9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105db0 <sys_getpid>:

int
sys_getpid(void)
{
  return proc->pid;
80105db0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80105db6:	55                   	push   %ebp
80105db7:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80105db9:	8b 40 10             	mov    0x10(%eax),%eax
}
80105dbc:	5d                   	pop    %ebp
80105dbd:	c3                   	ret    
80105dbe:	66 90                	xchg   %ax,%ax

80105dc0 <sys_sbrk>:

int
sys_sbrk(void)
{
80105dc0:	55                   	push   %ebp
80105dc1:	89 e5                	mov    %esp,%ebp
80105dc3:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105dc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105dc7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105dca:	50                   	push   %eax
80105dcb:	6a 00                	push   $0x0
80105dcd:	e8 de f0 ff ff       	call   80104eb0 <argint>
80105dd2:	83 c4 10             	add    $0x10,%esp
80105dd5:	85 c0                	test   %eax,%eax
80105dd7:	78 27                	js     80105e00 <sys_sbrk+0x40>
    return -1;
  addr = proc->sz;
80105dd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(growproc(n) < 0)
80105ddf:	83 ec 0c             	sub    $0xc,%esp
  addr = proc->sz;
80105de2:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105de4:	ff 75 f4             	pushl  -0xc(%ebp)
80105de7:	e8 84 dc ff ff       	call   80103a70 <growproc>
80105dec:	83 c4 10             	add    $0x10,%esp
80105def:	85 c0                	test   %eax,%eax
80105df1:	78 0d                	js     80105e00 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105df3:	89 d8                	mov    %ebx,%eax
80105df5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105df8:	c9                   	leave  
80105df9:	c3                   	ret    
80105dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105e00:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105e05:	eb ec                	jmp    80105df3 <sys_sbrk+0x33>
80105e07:	89 f6                	mov    %esi,%esi
80105e09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105e10 <sys_sleep>:

int
sys_sleep(void)
{
80105e10:	55                   	push   %ebp
80105e11:	89 e5                	mov    %esp,%ebp
80105e13:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105e14:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105e17:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105e1a:	50                   	push   %eax
80105e1b:	6a 00                	push   $0x0
80105e1d:	e8 8e f0 ff ff       	call   80104eb0 <argint>
80105e22:	83 c4 10             	add    $0x10,%esp
80105e25:	85 c0                	test   %eax,%eax
80105e27:	0f 88 8a 00 00 00    	js     80105eb7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105e2d:	83 ec 0c             	sub    $0xc,%esp
80105e30:	68 20 73 11 80       	push   $0x80117320
80105e35:	e8 86 eb ff ff       	call   801049c0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105e3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e3d:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105e40:	8b 1d 60 7b 11 80    	mov    0x80117b60,%ebx
  while(ticks - ticks0 < n){
80105e46:	85 d2                	test   %edx,%edx
80105e48:	75 27                	jne    80105e71 <sys_sleep+0x61>
80105e4a:	eb 54                	jmp    80105ea0 <sys_sleep+0x90>
80105e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105e50:	83 ec 08             	sub    $0x8,%esp
80105e53:	68 20 73 11 80       	push   $0x80117320
80105e58:	68 60 7b 11 80       	push   $0x80117b60
80105e5d:	e8 fe e1 ff ff       	call   80104060 <sleep>
  while(ticks - ticks0 < n){
80105e62:	a1 60 7b 11 80       	mov    0x80117b60,%eax
80105e67:	83 c4 10             	add    $0x10,%esp
80105e6a:	29 d8                	sub    %ebx,%eax
80105e6c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105e6f:	73 2f                	jae    80105ea0 <sys_sleep+0x90>
    if(proc->killed){
80105e71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e77:	8b 40 48             	mov    0x48(%eax),%eax
80105e7a:	85 c0                	test   %eax,%eax
80105e7c:	74 d2                	je     80105e50 <sys_sleep+0x40>
      release(&tickslock);
80105e7e:	83 ec 0c             	sub    $0xc,%esp
80105e81:	68 20 73 11 80       	push   $0x80117320
80105e86:	e8 f5 ec ff ff       	call   80104b80 <release>
      return -1;
80105e8b:	83 c4 10             	add    $0x10,%esp
80105e8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&tickslock);
  return 0;
}
80105e93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e96:	c9                   	leave  
80105e97:	c3                   	ret    
80105e98:	90                   	nop
80105e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  release(&tickslock);
80105ea0:	83 ec 0c             	sub    $0xc,%esp
80105ea3:	68 20 73 11 80       	push   $0x80117320
80105ea8:	e8 d3 ec ff ff       	call   80104b80 <release>
  return 0;
80105ead:	83 c4 10             	add    $0x10,%esp
80105eb0:	31 c0                	xor    %eax,%eax
}
80105eb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105eb5:	c9                   	leave  
80105eb6:	c3                   	ret    
    return -1;
80105eb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebc:	eb f4                	jmp    80105eb2 <sys_sleep+0xa2>
80105ebe:	66 90                	xchg   %ax,%ax

80105ec0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105ec0:	55                   	push   %ebp
80105ec1:	89 e5                	mov    %esp,%ebp
80105ec3:	53                   	push   %ebx
80105ec4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105ec7:	68 20 73 11 80       	push   $0x80117320
80105ecc:	e8 ef ea ff ff       	call   801049c0 <acquire>
  xticks = ticks;
80105ed1:	8b 1d 60 7b 11 80    	mov    0x80117b60,%ebx
  release(&tickslock);
80105ed7:	c7 04 24 20 73 11 80 	movl   $0x80117320,(%esp)
80105ede:	e8 9d ec ff ff       	call   80104b80 <release>
  return xticks;
}
80105ee3:	89 d8                	mov    %ebx,%eax
80105ee5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105ee8:	c9                   	leave  
80105ee9:	c3                   	ret    
80105eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105ef0 <sys_cps>:

int sys_cps(void){
80105ef0:	55                   	push   %ebp
80105ef1:	89 e5                	mov    %esp,%ebp
  return cps();
}
80105ef3:	5d                   	pop    %ebp
  return cps();
80105ef4:	e9 77 e9 ff ff       	jmp    80104870 <cps>
80105ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105f00 <sys_chpri>:

int sys_chpri(void)
{
80105f00:	55                   	push   %ebp
80105f01:	89 e5                	mov    %esp,%ebp
80105f03:	83 ec 20             	sub    $0x20,%esp
  int pid, pr;
  if (argint(0, &pid) < 0)
80105f06:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f09:	50                   	push   %eax
80105f0a:	6a 00                	push   $0x0
80105f0c:	e8 9f ef ff ff       	call   80104eb0 <argint>
80105f11:	83 c4 10             	add    $0x10,%esp
80105f14:	85 c0                	test   %eax,%eax
80105f16:	78 28                	js     80105f40 <sys_chpri+0x40>
    return -1;
  if (argint(1, &pr) < 0)
80105f18:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f1b:	83 ec 08             	sub    $0x8,%esp
80105f1e:	50                   	push   %eax
80105f1f:	6a 01                	push   $0x1
80105f21:	e8 8a ef ff ff       	call   80104eb0 <argint>
80105f26:	83 c4 10             	add    $0x10,%esp
80105f29:	85 c0                	test   %eax,%eax
80105f2b:	78 13                	js     80105f40 <sys_chpri+0x40>
    return -1;
  return chpri(pid, pr);
80105f2d:	83 ec 08             	sub    $0x8,%esp
80105f30:	ff 75 f4             	pushl  -0xc(%ebp)
80105f33:	ff 75 f0             	pushl  -0x10(%ebp)
80105f36:	e8 15 ea ff ff       	call   80104950 <chpri>
80105f3b:	83 c4 10             	add    $0x10,%esp
}
80105f3e:	c9                   	leave  
80105f3f:	c3                   	ret    
    return -1;
80105f40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f45:	c9                   	leave  
80105f46:	c3                   	ret    
80105f47:	66 90                	xchg   %ax,%ax
80105f49:	66 90                	xchg   %ax,%ax
80105f4b:	66 90                	xchg   %ax,%ax
80105f4d:	66 90                	xchg   %ax,%ax
80105f4f:	90                   	nop

80105f50 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80105f50:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105f51:	b8 34 00 00 00       	mov    $0x34,%eax
80105f56:	ba 43 00 00 00       	mov    $0x43,%edx
80105f5b:	89 e5                	mov    %esp,%ebp
80105f5d:	83 ec 14             	sub    $0x14,%esp
80105f60:	ee                   	out    %al,(%dx)
80105f61:	ba 40 00 00 00       	mov    $0x40,%edx
80105f66:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
80105f6b:	ee                   	out    %al,(%dx)
80105f6c:	b8 2e 00 00 00       	mov    $0x2e,%eax
80105f71:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
80105f72:	6a 00                	push   $0x0
80105f74:	e8 87 d3 ff ff       	call   80103300 <picenable>
}
80105f79:	83 c4 10             	add    $0x10,%esp
80105f7c:	c9                   	leave  
80105f7d:	c3                   	ret    

80105f7e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105f7e:	1e                   	push   %ds
  pushl %es
80105f7f:	06                   	push   %es
  pushl %fs
80105f80:	0f a0                	push   %fs
  pushl %gs
80105f82:	0f a8                	push   %gs
  pushal
80105f84:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80105f85:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105f89:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105f8b:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80105f8d:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80105f91:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80105f93:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80105f95:	54                   	push   %esp
  call trap
80105f96:	e8 c5 00 00 00       	call   80106060 <trap>
  addl $4, %esp
80105f9b:	83 c4 04             	add    $0x4,%esp

80105f9e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105f9e:	61                   	popa   
  popl %gs
80105f9f:	0f a9                	pop    %gs
  popl %fs
80105fa1:	0f a1                	pop    %fs
  popl %es
80105fa3:	07                   	pop    %es
  popl %ds
80105fa4:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105fa5:	83 c4 08             	add    $0x8,%esp
  iret
80105fa8:	cf                   	iret   
80105fa9:	66 90                	xchg   %ax,%ax
80105fab:	66 90                	xchg   %ax,%ax
80105fad:	66 90                	xchg   %ax,%ax
80105faf:	90                   	nop

80105fb0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105fb0:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105fb1:	31 c0                	xor    %eax,%eax
{
80105fb3:	89 e5                	mov    %esp,%ebp
80105fb5:	83 ec 08             	sub    $0x8,%esp
80105fb8:	90                   	nop
80105fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105fc0:	8b 14 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%edx
80105fc7:	c7 04 c5 62 73 11 80 	movl   $0x8e000008,-0x7fee8c9e(,%eax,8)
80105fce:	08 00 00 8e 
80105fd2:	66 89 14 c5 60 73 11 	mov    %dx,-0x7fee8ca0(,%eax,8)
80105fd9:	80 
80105fda:	c1 ea 10             	shr    $0x10,%edx
80105fdd:	66 89 14 c5 66 73 11 	mov    %dx,-0x7fee8c9a(,%eax,8)
80105fe4:	80 
  for(i = 0; i < 256; i++)
80105fe5:	83 c0 01             	add    $0x1,%eax
80105fe8:	3d 00 01 00 00       	cmp    $0x100,%eax
80105fed:	75 d1                	jne    80105fc0 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105fef:	a1 0c b1 10 80       	mov    0x8010b10c,%eax

  initlock(&tickslock, "time");
80105ff4:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105ff7:	c7 05 62 75 11 80 08 	movl   $0xef000008,0x80117562
80105ffe:	00 00 ef 
  initlock(&tickslock, "time");
80106001:	68 d5 81 10 80       	push   $0x801081d5
80106006:	68 20 73 11 80       	push   $0x80117320
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010600b:	66 a3 60 75 11 80    	mov    %ax,0x80117560
80106011:	c1 e8 10             	shr    $0x10,%eax
80106014:	66 a3 66 75 11 80    	mov    %ax,0x80117566
  initlock(&tickslock, "time");
8010601a:	e8 81 e9 ff ff       	call   801049a0 <initlock>
}
8010601f:	83 c4 10             	add    $0x10,%esp
80106022:	c9                   	leave  
80106023:	c3                   	ret    
80106024:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010602a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80106030 <idtinit>:

void
idtinit(void)
{
80106030:	55                   	push   %ebp
  pd[0] = size-1;
80106031:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80106036:	89 e5                	mov    %esp,%ebp
80106038:	83 ec 10             	sub    $0x10,%esp
8010603b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010603f:	b8 60 73 11 80       	mov    $0x80117360,%eax
80106044:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106048:	c1 e8 10             	shr    $0x10,%eax
8010604b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010604f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106052:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80106055:	c9                   	leave  
80106056:	c3                   	ret    
80106057:	89 f6                	mov    %esi,%esi
80106059:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106060 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106060:	55                   	push   %ebp
80106061:	89 e5                	mov    %esp,%ebp
80106063:	57                   	push   %edi
80106064:	56                   	push   %esi
80106065:	53                   	push   %ebx
80106066:	83 ec 0c             	sub    $0xc,%esp
80106069:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010606c:	8b 43 30             	mov    0x30(%ebx),%eax
8010606f:	83 f8 40             	cmp    $0x40,%eax
80106072:	74 6c                	je     801060e0 <trap+0x80>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80106074:	83 e8 20             	sub    $0x20,%eax
80106077:	83 f8 1f             	cmp    $0x1f,%eax
8010607a:	0f 87 98 00 00 00    	ja     80106118 <trap+0xb8>
80106080:	ff 24 85 7c 82 10 80 	jmp    *-0x7fef7d84(,%eax,4)
80106087:	89 f6                	mov    %esi,%esi
80106089:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  case T_IRQ0 + IRQ_TIMER:
    if(cpunum() == 0){
80106090:	e8 9b c6 ff ff       	call   80102730 <cpunum>
80106095:	85 c0                	test   %eax,%eax
80106097:	0f 84 a3 01 00 00    	je     80106240 <trap+0x1e0>
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
8010609d:	e8 3e c7 ff ff       	call   801027e0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801060a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060a8:	85 c0                	test   %eax,%eax
801060aa:	74 29                	je     801060d5 <trap+0x75>
801060ac:	8b 50 48             	mov    0x48(%eax),%edx
801060af:	85 d2                	test   %edx,%edx
801060b1:	0f 85 b9 00 00 00    	jne    80106170 <trap+0x110>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801060b7:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801060bb:	0f 84 3f 01 00 00    	je     80106200 <trap+0x1a0>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801060c1:	8b 40 48             	mov    0x48(%eax),%eax
801060c4:	85 c0                	test   %eax,%eax
801060c6:	74 0d                	je     801060d5 <trap+0x75>
801060c8:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801060cc:	83 e0 03             	and    $0x3,%eax
801060cf:	66 83 f8 03          	cmp    $0x3,%ax
801060d3:	74 31                	je     80106106 <trap+0xa6>
    exit();
}
801060d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060d8:	5b                   	pop    %ebx
801060d9:	5e                   	pop    %esi
801060da:	5f                   	pop    %edi
801060db:	5d                   	pop    %ebp
801060dc:	c3                   	ret    
801060dd:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
801060e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060e6:	8b 70 48             	mov    0x48(%eax),%esi
801060e9:	85 f6                	test   %esi,%esi
801060eb:	0f 85 37 01 00 00    	jne    80106228 <trap+0x1c8>
    proc->tf = tf;
801060f1:	89 58 3c             	mov    %ebx,0x3c(%eax)
    syscall();
801060f4:	e8 c7 ee ff ff       	call   80104fc0 <syscall>
    if(proc->killed)
801060f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060ff:	8b 58 48             	mov    0x48(%eax),%ebx
80106102:	85 db                	test   %ebx,%ebx
80106104:	74 cf                	je     801060d5 <trap+0x75>
}
80106106:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106109:	5b                   	pop    %ebx
8010610a:	5e                   	pop    %esi
8010610b:	5f                   	pop    %edi
8010610c:	5d                   	pop    %ebp
      exit();
8010610d:	e9 de dc ff ff       	jmp    80103df0 <exit>
80106112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(proc == 0 || (tf->cs&3) == 0){
80106118:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010611f:	8b 73 38             	mov    0x38(%ebx),%esi
80106122:	85 c9                	test   %ecx,%ecx
80106124:	0f 84 4a 01 00 00    	je     80106274 <trap+0x214>
8010612a:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010612e:	0f 84 40 01 00 00    	je     80106274 <trap+0x214>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106134:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106137:	e8 f4 c5 ff ff       	call   80102730 <cpunum>
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
8010613c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106143:	57                   	push   %edi
80106144:	56                   	push   %esi
80106145:	50                   	push   %eax
80106146:	ff 73 34             	pushl  0x34(%ebx)
80106149:	ff 73 30             	pushl  0x30(%ebx)
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
8010614c:	8d 82 90 00 00 00    	lea    0x90(%edx),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106152:	50                   	push   %eax
80106153:	ff 72 10             	pushl  0x10(%edx)
80106156:	68 38 82 10 80       	push   $0x80108238
8010615b:	e8 e0 a4 ff ff       	call   80100640 <cprintf>
    proc->killed = 1;
80106160:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106166:	83 c4 20             	add    $0x20,%esp
80106169:	c7 40 48 01 00 00 00 	movl   $0x1,0x48(%eax)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106170:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
80106174:	83 e2 03             	and    $0x3,%edx
80106177:	66 83 fa 03          	cmp    $0x3,%dx
8010617b:	0f 85 36 ff ff ff    	jne    801060b7 <trap+0x57>
    exit();
80106181:	e8 6a dc ff ff       	call   80103df0 <exit>
80106186:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010618c:	85 c0                	test   %eax,%eax
8010618e:	0f 85 23 ff ff ff    	jne    801060b7 <trap+0x57>
80106194:	e9 3c ff ff ff       	jmp    801060d5 <trap+0x75>
80106199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kbdintr();
801061a0:	e8 6b c4 ff ff       	call   80102610 <kbdintr>
    lapiceoi();
801061a5:	e8 36 c6 ff ff       	call   801027e0 <lapiceoi>
    break;
801061aa:	e9 f3 fe ff ff       	jmp    801060a2 <trap+0x42>
801061af:	90                   	nop
    uartintr();
801061b0:	e8 5b 02 00 00       	call   80106410 <uartintr>
801061b5:	e9 e3 fe ff ff       	jmp    8010609d <trap+0x3d>
801061ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801061c0:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
801061c4:	8b 7b 38             	mov    0x38(%ebx),%edi
801061c7:	e8 64 c5 ff ff       	call   80102730 <cpunum>
801061cc:	57                   	push   %edi
801061cd:	56                   	push   %esi
801061ce:	50                   	push   %eax
801061cf:	68 e0 81 10 80       	push   $0x801081e0
801061d4:	e8 67 a4 ff ff       	call   80100640 <cprintf>
    lapiceoi();
801061d9:	e8 02 c6 ff ff       	call   801027e0 <lapiceoi>
    break;
801061de:	83 c4 10             	add    $0x10,%esp
801061e1:	e9 bc fe ff ff       	jmp    801060a2 <trap+0x42>
801061e6:	8d 76 00             	lea    0x0(%esi),%esi
801061e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ideintr();
801061f0:	e8 7b be ff ff       	call   80102070 <ideintr>
    lapiceoi();
801061f5:	e8 e6 c5 ff ff       	call   801027e0 <lapiceoi>
    break;
801061fa:	e9 a3 fe ff ff       	jmp    801060a2 <trap+0x42>
801061ff:	90                   	nop
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106200:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80106204:	0f 85 b7 fe ff ff    	jne    801060c1 <trap+0x61>
    yield();
8010620a:	e8 11 de ff ff       	call   80104020 <yield>
8010620f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106215:	85 c0                	test   %eax,%eax
80106217:	0f 85 a4 fe ff ff    	jne    801060c1 <trap+0x61>
8010621d:	e9 b3 fe ff ff       	jmp    801060d5 <trap+0x75>
80106222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80106228:	e8 c3 db ff ff       	call   80103df0 <exit>
8010622d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106233:	e9 b9 fe ff ff       	jmp    801060f1 <trap+0x91>
80106238:	90                   	nop
80106239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      acquire(&tickslock);
80106240:	83 ec 0c             	sub    $0xc,%esp
80106243:	68 20 73 11 80       	push   $0x80117320
80106248:	e8 73 e7 ff ff       	call   801049c0 <acquire>
      wakeup(&ticks);
8010624d:	c7 04 24 60 7b 11 80 	movl   $0x80117b60,(%esp)
      ticks++;
80106254:	83 05 60 7b 11 80 01 	addl   $0x1,0x80117b60
      wakeup(&ticks);
8010625b:	e8 f0 df ff ff       	call   80104250 <wakeup>
      release(&tickslock);
80106260:	c7 04 24 20 73 11 80 	movl   $0x80117320,(%esp)
80106267:	e8 14 e9 ff ff       	call   80104b80 <release>
8010626c:	83 c4 10             	add    $0x10,%esp
8010626f:	e9 29 fe ff ff       	jmp    8010609d <trap+0x3d>
80106274:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106277:	e8 b4 c4 ff ff       	call   80102730 <cpunum>
8010627c:	83 ec 0c             	sub    $0xc,%esp
8010627f:	57                   	push   %edi
80106280:	56                   	push   %esi
80106281:	50                   	push   %eax
80106282:	ff 73 30             	pushl  0x30(%ebx)
80106285:	68 04 82 10 80       	push   $0x80108204
8010628a:	e8 b1 a3 ff ff       	call   80100640 <cprintf>
      panic("trap");
8010628f:	83 c4 14             	add    $0x14,%esp
80106292:	68 da 81 10 80       	push   $0x801081da
80106297:	e8 d4 a0 ff ff       	call   80100370 <panic>
8010629c:	66 90                	xchg   %ax,%ax
8010629e:	66 90                	xchg   %ax,%ax

801062a0 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
801062a0:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
{
801062a5:	55                   	push   %ebp
801062a6:	89 e5                	mov    %esp,%ebp
  if(!uart)
801062a8:	85 c0                	test   %eax,%eax
801062aa:	74 1c                	je     801062c8 <uartgetc+0x28>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801062ac:	ba fd 03 00 00       	mov    $0x3fd,%edx
801062b1:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801062b2:	a8 01                	test   $0x1,%al
801062b4:	74 12                	je     801062c8 <uartgetc+0x28>
801062b6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801062bb:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801062bc:	0f b6 c0             	movzbl %al,%eax
}
801062bf:	5d                   	pop    %ebp
801062c0:	c3                   	ret    
801062c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801062c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062cd:	5d                   	pop    %ebp
801062ce:	c3                   	ret    
801062cf:	90                   	nop

801062d0 <uartputc.part.0>:
uartputc(int c)
801062d0:	55                   	push   %ebp
801062d1:	89 e5                	mov    %esp,%ebp
801062d3:	57                   	push   %edi
801062d4:	56                   	push   %esi
801062d5:	53                   	push   %ebx
801062d6:	89 c7                	mov    %eax,%edi
801062d8:	bb 80 00 00 00       	mov    $0x80,%ebx
801062dd:	be fd 03 00 00       	mov    $0x3fd,%esi
801062e2:	83 ec 0c             	sub    $0xc,%esp
801062e5:	eb 1b                	jmp    80106302 <uartputc.part.0+0x32>
801062e7:	89 f6                	mov    %esi,%esi
801062e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    microdelay(10);
801062f0:	83 ec 0c             	sub    $0xc,%esp
801062f3:	6a 0a                	push   $0xa
801062f5:	e8 06 c5 ff ff       	call   80102800 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801062fa:	83 c4 10             	add    $0x10,%esp
801062fd:	83 eb 01             	sub    $0x1,%ebx
80106300:	74 07                	je     80106309 <uartputc.part.0+0x39>
80106302:	89 f2                	mov    %esi,%edx
80106304:	ec                   	in     (%dx),%al
80106305:	a8 20                	test   $0x20,%al
80106307:	74 e7                	je     801062f0 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106309:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010630e:	89 f8                	mov    %edi,%eax
80106310:	ee                   	out    %al,(%dx)
}
80106311:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106314:	5b                   	pop    %ebx
80106315:	5e                   	pop    %esi
80106316:	5f                   	pop    %edi
80106317:	5d                   	pop    %ebp
80106318:	c3                   	ret    
80106319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106320 <uartinit>:
{
80106320:	55                   	push   %ebp
80106321:	31 c9                	xor    %ecx,%ecx
80106323:	89 c8                	mov    %ecx,%eax
80106325:	89 e5                	mov    %esp,%ebp
80106327:	57                   	push   %edi
80106328:	56                   	push   %esi
80106329:	53                   	push   %ebx
8010632a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
8010632f:	89 da                	mov    %ebx,%edx
80106331:	83 ec 0c             	sub    $0xc,%esp
80106334:	ee                   	out    %al,(%dx)
80106335:	bf fb 03 00 00       	mov    $0x3fb,%edi
8010633a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010633f:	89 fa                	mov    %edi,%edx
80106341:	ee                   	out    %al,(%dx)
80106342:	b8 0c 00 00 00       	mov    $0xc,%eax
80106347:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010634c:	ee                   	out    %al,(%dx)
8010634d:	be f9 03 00 00       	mov    $0x3f9,%esi
80106352:	89 c8                	mov    %ecx,%eax
80106354:	89 f2                	mov    %esi,%edx
80106356:	ee                   	out    %al,(%dx)
80106357:	b8 03 00 00 00       	mov    $0x3,%eax
8010635c:	89 fa                	mov    %edi,%edx
8010635e:	ee                   	out    %al,(%dx)
8010635f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106364:	89 c8                	mov    %ecx,%eax
80106366:	ee                   	out    %al,(%dx)
80106367:	b8 01 00 00 00       	mov    $0x1,%eax
8010636c:	89 f2                	mov    %esi,%edx
8010636e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010636f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106374:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80106375:	3c ff                	cmp    $0xff,%al
80106377:	74 5a                	je     801063d3 <uartinit+0xb3>
  uart = 1;
80106379:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
80106380:	00 00 00 
80106383:	89 da                	mov    %ebx,%edx
80106385:	ec                   	in     (%dx),%al
80106386:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010638b:	ec                   	in     (%dx),%al
  picenable(IRQ_COM1);
8010638c:	83 ec 0c             	sub    $0xc,%esp
8010638f:	6a 04                	push   $0x4
80106391:	e8 6a cf ff ff       	call   80103300 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106396:	59                   	pop    %ecx
80106397:	5b                   	pop    %ebx
80106398:	6a 00                	push   $0x0
8010639a:	6a 04                	push   $0x4
  for(p="xv6...\n"; *p; p++)
8010639c:	bb fc 82 10 80       	mov    $0x801082fc,%ebx
  ioapicenable(IRQ_COM1, 0);
801063a1:	e8 2a bf ff ff       	call   801022d0 <ioapicenable>
801063a6:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801063a9:	b8 78 00 00 00       	mov    $0x78,%eax
801063ae:	eb 0a                	jmp    801063ba <uartinit+0x9a>
801063b0:	83 c3 01             	add    $0x1,%ebx
801063b3:	0f be 03             	movsbl (%ebx),%eax
801063b6:	84 c0                	test   %al,%al
801063b8:	74 19                	je     801063d3 <uartinit+0xb3>
  if(!uart)
801063ba:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
801063c0:	85 d2                	test   %edx,%edx
801063c2:	74 ec                	je     801063b0 <uartinit+0x90>
  for(p="xv6...\n"; *p; p++)
801063c4:	83 c3 01             	add    $0x1,%ebx
801063c7:	e8 04 ff ff ff       	call   801062d0 <uartputc.part.0>
801063cc:	0f be 03             	movsbl (%ebx),%eax
801063cf:	84 c0                	test   %al,%al
801063d1:	75 e7                	jne    801063ba <uartinit+0x9a>
}
801063d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063d6:	5b                   	pop    %ebx
801063d7:	5e                   	pop    %esi
801063d8:	5f                   	pop    %edi
801063d9:	5d                   	pop    %ebp
801063da:	c3                   	ret    
801063db:	90                   	nop
801063dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801063e0 <uartputc>:
  if(!uart)
801063e0:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
{
801063e6:	55                   	push   %ebp
801063e7:	89 e5                	mov    %esp,%ebp
  if(!uart)
801063e9:	85 d2                	test   %edx,%edx
{
801063eb:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
801063ee:	74 10                	je     80106400 <uartputc+0x20>
}
801063f0:	5d                   	pop    %ebp
801063f1:	e9 da fe ff ff       	jmp    801062d0 <uartputc.part.0>
801063f6:	8d 76 00             	lea    0x0(%esi),%esi
801063f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80106400:	5d                   	pop    %ebp
80106401:	c3                   	ret    
80106402:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106409:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106410 <uartintr>:

void
uartintr(void)
{
80106410:	55                   	push   %ebp
80106411:	89 e5                	mov    %esp,%ebp
80106413:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106416:	68 a0 62 10 80       	push   $0x801062a0
8010641b:	e8 d0 a3 ff ff       	call   801007f0 <consoleintr>
}
80106420:	83 c4 10             	add    $0x10,%esp
80106423:	c9                   	leave  
80106424:	c3                   	ret    

80106425 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106425:	6a 00                	push   $0x0
  pushl $0
80106427:	6a 00                	push   $0x0
  jmp alltraps
80106429:	e9 50 fb ff ff       	jmp    80105f7e <alltraps>

8010642e <vector1>:
.globl vector1
vector1:
  pushl $0
8010642e:	6a 00                	push   $0x0
  pushl $1
80106430:	6a 01                	push   $0x1
  jmp alltraps
80106432:	e9 47 fb ff ff       	jmp    80105f7e <alltraps>

80106437 <vector2>:
.globl vector2
vector2:
  pushl $0
80106437:	6a 00                	push   $0x0
  pushl $2
80106439:	6a 02                	push   $0x2
  jmp alltraps
8010643b:	e9 3e fb ff ff       	jmp    80105f7e <alltraps>

80106440 <vector3>:
.globl vector3
vector3:
  pushl $0
80106440:	6a 00                	push   $0x0
  pushl $3
80106442:	6a 03                	push   $0x3
  jmp alltraps
80106444:	e9 35 fb ff ff       	jmp    80105f7e <alltraps>

80106449 <vector4>:
.globl vector4
vector4:
  pushl $0
80106449:	6a 00                	push   $0x0
  pushl $4
8010644b:	6a 04                	push   $0x4
  jmp alltraps
8010644d:	e9 2c fb ff ff       	jmp    80105f7e <alltraps>

80106452 <vector5>:
.globl vector5
vector5:
  pushl $0
80106452:	6a 00                	push   $0x0
  pushl $5
80106454:	6a 05                	push   $0x5
  jmp alltraps
80106456:	e9 23 fb ff ff       	jmp    80105f7e <alltraps>

8010645b <vector6>:
.globl vector6
vector6:
  pushl $0
8010645b:	6a 00                	push   $0x0
  pushl $6
8010645d:	6a 06                	push   $0x6
  jmp alltraps
8010645f:	e9 1a fb ff ff       	jmp    80105f7e <alltraps>

80106464 <vector7>:
.globl vector7
vector7:
  pushl $0
80106464:	6a 00                	push   $0x0
  pushl $7
80106466:	6a 07                	push   $0x7
  jmp alltraps
80106468:	e9 11 fb ff ff       	jmp    80105f7e <alltraps>

8010646d <vector8>:
.globl vector8
vector8:
  pushl $8
8010646d:	6a 08                	push   $0x8
  jmp alltraps
8010646f:	e9 0a fb ff ff       	jmp    80105f7e <alltraps>

80106474 <vector9>:
.globl vector9
vector9:
  pushl $0
80106474:	6a 00                	push   $0x0
  pushl $9
80106476:	6a 09                	push   $0x9
  jmp alltraps
80106478:	e9 01 fb ff ff       	jmp    80105f7e <alltraps>

8010647d <vector10>:
.globl vector10
vector10:
  pushl $10
8010647d:	6a 0a                	push   $0xa
  jmp alltraps
8010647f:	e9 fa fa ff ff       	jmp    80105f7e <alltraps>

80106484 <vector11>:
.globl vector11
vector11:
  pushl $11
80106484:	6a 0b                	push   $0xb
  jmp alltraps
80106486:	e9 f3 fa ff ff       	jmp    80105f7e <alltraps>

8010648b <vector12>:
.globl vector12
vector12:
  pushl $12
8010648b:	6a 0c                	push   $0xc
  jmp alltraps
8010648d:	e9 ec fa ff ff       	jmp    80105f7e <alltraps>

80106492 <vector13>:
.globl vector13
vector13:
  pushl $13
80106492:	6a 0d                	push   $0xd
  jmp alltraps
80106494:	e9 e5 fa ff ff       	jmp    80105f7e <alltraps>

80106499 <vector14>:
.globl vector14
vector14:
  pushl $14
80106499:	6a 0e                	push   $0xe
  jmp alltraps
8010649b:	e9 de fa ff ff       	jmp    80105f7e <alltraps>

801064a0 <vector15>:
.globl vector15
vector15:
  pushl $0
801064a0:	6a 00                	push   $0x0
  pushl $15
801064a2:	6a 0f                	push   $0xf
  jmp alltraps
801064a4:	e9 d5 fa ff ff       	jmp    80105f7e <alltraps>

801064a9 <vector16>:
.globl vector16
vector16:
  pushl $0
801064a9:	6a 00                	push   $0x0
  pushl $16
801064ab:	6a 10                	push   $0x10
  jmp alltraps
801064ad:	e9 cc fa ff ff       	jmp    80105f7e <alltraps>

801064b2 <vector17>:
.globl vector17
vector17:
  pushl $17
801064b2:	6a 11                	push   $0x11
  jmp alltraps
801064b4:	e9 c5 fa ff ff       	jmp    80105f7e <alltraps>

801064b9 <vector18>:
.globl vector18
vector18:
  pushl $0
801064b9:	6a 00                	push   $0x0
  pushl $18
801064bb:	6a 12                	push   $0x12
  jmp alltraps
801064bd:	e9 bc fa ff ff       	jmp    80105f7e <alltraps>

801064c2 <vector19>:
.globl vector19
vector19:
  pushl $0
801064c2:	6a 00                	push   $0x0
  pushl $19
801064c4:	6a 13                	push   $0x13
  jmp alltraps
801064c6:	e9 b3 fa ff ff       	jmp    80105f7e <alltraps>

801064cb <vector20>:
.globl vector20
vector20:
  pushl $0
801064cb:	6a 00                	push   $0x0
  pushl $20
801064cd:	6a 14                	push   $0x14
  jmp alltraps
801064cf:	e9 aa fa ff ff       	jmp    80105f7e <alltraps>

801064d4 <vector21>:
.globl vector21
vector21:
  pushl $0
801064d4:	6a 00                	push   $0x0
  pushl $21
801064d6:	6a 15                	push   $0x15
  jmp alltraps
801064d8:	e9 a1 fa ff ff       	jmp    80105f7e <alltraps>

801064dd <vector22>:
.globl vector22
vector22:
  pushl $0
801064dd:	6a 00                	push   $0x0
  pushl $22
801064df:	6a 16                	push   $0x16
  jmp alltraps
801064e1:	e9 98 fa ff ff       	jmp    80105f7e <alltraps>

801064e6 <vector23>:
.globl vector23
vector23:
  pushl $0
801064e6:	6a 00                	push   $0x0
  pushl $23
801064e8:	6a 17                	push   $0x17
  jmp alltraps
801064ea:	e9 8f fa ff ff       	jmp    80105f7e <alltraps>

801064ef <vector24>:
.globl vector24
vector24:
  pushl $0
801064ef:	6a 00                	push   $0x0
  pushl $24
801064f1:	6a 18                	push   $0x18
  jmp alltraps
801064f3:	e9 86 fa ff ff       	jmp    80105f7e <alltraps>

801064f8 <vector25>:
.globl vector25
vector25:
  pushl $0
801064f8:	6a 00                	push   $0x0
  pushl $25
801064fa:	6a 19                	push   $0x19
  jmp alltraps
801064fc:	e9 7d fa ff ff       	jmp    80105f7e <alltraps>

80106501 <vector26>:
.globl vector26
vector26:
  pushl $0
80106501:	6a 00                	push   $0x0
  pushl $26
80106503:	6a 1a                	push   $0x1a
  jmp alltraps
80106505:	e9 74 fa ff ff       	jmp    80105f7e <alltraps>

8010650a <vector27>:
.globl vector27
vector27:
  pushl $0
8010650a:	6a 00                	push   $0x0
  pushl $27
8010650c:	6a 1b                	push   $0x1b
  jmp alltraps
8010650e:	e9 6b fa ff ff       	jmp    80105f7e <alltraps>

80106513 <vector28>:
.globl vector28
vector28:
  pushl $0
80106513:	6a 00                	push   $0x0
  pushl $28
80106515:	6a 1c                	push   $0x1c
  jmp alltraps
80106517:	e9 62 fa ff ff       	jmp    80105f7e <alltraps>

8010651c <vector29>:
.globl vector29
vector29:
  pushl $0
8010651c:	6a 00                	push   $0x0
  pushl $29
8010651e:	6a 1d                	push   $0x1d
  jmp alltraps
80106520:	e9 59 fa ff ff       	jmp    80105f7e <alltraps>

80106525 <vector30>:
.globl vector30
vector30:
  pushl $0
80106525:	6a 00                	push   $0x0
  pushl $30
80106527:	6a 1e                	push   $0x1e
  jmp alltraps
80106529:	e9 50 fa ff ff       	jmp    80105f7e <alltraps>

8010652e <vector31>:
.globl vector31
vector31:
  pushl $0
8010652e:	6a 00                	push   $0x0
  pushl $31
80106530:	6a 1f                	push   $0x1f
  jmp alltraps
80106532:	e9 47 fa ff ff       	jmp    80105f7e <alltraps>

80106537 <vector32>:
.globl vector32
vector32:
  pushl $0
80106537:	6a 00                	push   $0x0
  pushl $32
80106539:	6a 20                	push   $0x20
  jmp alltraps
8010653b:	e9 3e fa ff ff       	jmp    80105f7e <alltraps>

80106540 <vector33>:
.globl vector33
vector33:
  pushl $0
80106540:	6a 00                	push   $0x0
  pushl $33
80106542:	6a 21                	push   $0x21
  jmp alltraps
80106544:	e9 35 fa ff ff       	jmp    80105f7e <alltraps>

80106549 <vector34>:
.globl vector34
vector34:
  pushl $0
80106549:	6a 00                	push   $0x0
  pushl $34
8010654b:	6a 22                	push   $0x22
  jmp alltraps
8010654d:	e9 2c fa ff ff       	jmp    80105f7e <alltraps>

80106552 <vector35>:
.globl vector35
vector35:
  pushl $0
80106552:	6a 00                	push   $0x0
  pushl $35
80106554:	6a 23                	push   $0x23
  jmp alltraps
80106556:	e9 23 fa ff ff       	jmp    80105f7e <alltraps>

8010655b <vector36>:
.globl vector36
vector36:
  pushl $0
8010655b:	6a 00                	push   $0x0
  pushl $36
8010655d:	6a 24                	push   $0x24
  jmp alltraps
8010655f:	e9 1a fa ff ff       	jmp    80105f7e <alltraps>

80106564 <vector37>:
.globl vector37
vector37:
  pushl $0
80106564:	6a 00                	push   $0x0
  pushl $37
80106566:	6a 25                	push   $0x25
  jmp alltraps
80106568:	e9 11 fa ff ff       	jmp    80105f7e <alltraps>

8010656d <vector38>:
.globl vector38
vector38:
  pushl $0
8010656d:	6a 00                	push   $0x0
  pushl $38
8010656f:	6a 26                	push   $0x26
  jmp alltraps
80106571:	e9 08 fa ff ff       	jmp    80105f7e <alltraps>

80106576 <vector39>:
.globl vector39
vector39:
  pushl $0
80106576:	6a 00                	push   $0x0
  pushl $39
80106578:	6a 27                	push   $0x27
  jmp alltraps
8010657a:	e9 ff f9 ff ff       	jmp    80105f7e <alltraps>

8010657f <vector40>:
.globl vector40
vector40:
  pushl $0
8010657f:	6a 00                	push   $0x0
  pushl $40
80106581:	6a 28                	push   $0x28
  jmp alltraps
80106583:	e9 f6 f9 ff ff       	jmp    80105f7e <alltraps>

80106588 <vector41>:
.globl vector41
vector41:
  pushl $0
80106588:	6a 00                	push   $0x0
  pushl $41
8010658a:	6a 29                	push   $0x29
  jmp alltraps
8010658c:	e9 ed f9 ff ff       	jmp    80105f7e <alltraps>

80106591 <vector42>:
.globl vector42
vector42:
  pushl $0
80106591:	6a 00                	push   $0x0
  pushl $42
80106593:	6a 2a                	push   $0x2a
  jmp alltraps
80106595:	e9 e4 f9 ff ff       	jmp    80105f7e <alltraps>

8010659a <vector43>:
.globl vector43
vector43:
  pushl $0
8010659a:	6a 00                	push   $0x0
  pushl $43
8010659c:	6a 2b                	push   $0x2b
  jmp alltraps
8010659e:	e9 db f9 ff ff       	jmp    80105f7e <alltraps>

801065a3 <vector44>:
.globl vector44
vector44:
  pushl $0
801065a3:	6a 00                	push   $0x0
  pushl $44
801065a5:	6a 2c                	push   $0x2c
  jmp alltraps
801065a7:	e9 d2 f9 ff ff       	jmp    80105f7e <alltraps>

801065ac <vector45>:
.globl vector45
vector45:
  pushl $0
801065ac:	6a 00                	push   $0x0
  pushl $45
801065ae:	6a 2d                	push   $0x2d
  jmp alltraps
801065b0:	e9 c9 f9 ff ff       	jmp    80105f7e <alltraps>

801065b5 <vector46>:
.globl vector46
vector46:
  pushl $0
801065b5:	6a 00                	push   $0x0
  pushl $46
801065b7:	6a 2e                	push   $0x2e
  jmp alltraps
801065b9:	e9 c0 f9 ff ff       	jmp    80105f7e <alltraps>

801065be <vector47>:
.globl vector47
vector47:
  pushl $0
801065be:	6a 00                	push   $0x0
  pushl $47
801065c0:	6a 2f                	push   $0x2f
  jmp alltraps
801065c2:	e9 b7 f9 ff ff       	jmp    80105f7e <alltraps>

801065c7 <vector48>:
.globl vector48
vector48:
  pushl $0
801065c7:	6a 00                	push   $0x0
  pushl $48
801065c9:	6a 30                	push   $0x30
  jmp alltraps
801065cb:	e9 ae f9 ff ff       	jmp    80105f7e <alltraps>

801065d0 <vector49>:
.globl vector49
vector49:
  pushl $0
801065d0:	6a 00                	push   $0x0
  pushl $49
801065d2:	6a 31                	push   $0x31
  jmp alltraps
801065d4:	e9 a5 f9 ff ff       	jmp    80105f7e <alltraps>

801065d9 <vector50>:
.globl vector50
vector50:
  pushl $0
801065d9:	6a 00                	push   $0x0
  pushl $50
801065db:	6a 32                	push   $0x32
  jmp alltraps
801065dd:	e9 9c f9 ff ff       	jmp    80105f7e <alltraps>

801065e2 <vector51>:
.globl vector51
vector51:
  pushl $0
801065e2:	6a 00                	push   $0x0
  pushl $51
801065e4:	6a 33                	push   $0x33
  jmp alltraps
801065e6:	e9 93 f9 ff ff       	jmp    80105f7e <alltraps>

801065eb <vector52>:
.globl vector52
vector52:
  pushl $0
801065eb:	6a 00                	push   $0x0
  pushl $52
801065ed:	6a 34                	push   $0x34
  jmp alltraps
801065ef:	e9 8a f9 ff ff       	jmp    80105f7e <alltraps>

801065f4 <vector53>:
.globl vector53
vector53:
  pushl $0
801065f4:	6a 00                	push   $0x0
  pushl $53
801065f6:	6a 35                	push   $0x35
  jmp alltraps
801065f8:	e9 81 f9 ff ff       	jmp    80105f7e <alltraps>

801065fd <vector54>:
.globl vector54
vector54:
  pushl $0
801065fd:	6a 00                	push   $0x0
  pushl $54
801065ff:	6a 36                	push   $0x36
  jmp alltraps
80106601:	e9 78 f9 ff ff       	jmp    80105f7e <alltraps>

80106606 <vector55>:
.globl vector55
vector55:
  pushl $0
80106606:	6a 00                	push   $0x0
  pushl $55
80106608:	6a 37                	push   $0x37
  jmp alltraps
8010660a:	e9 6f f9 ff ff       	jmp    80105f7e <alltraps>

8010660f <vector56>:
.globl vector56
vector56:
  pushl $0
8010660f:	6a 00                	push   $0x0
  pushl $56
80106611:	6a 38                	push   $0x38
  jmp alltraps
80106613:	e9 66 f9 ff ff       	jmp    80105f7e <alltraps>

80106618 <vector57>:
.globl vector57
vector57:
  pushl $0
80106618:	6a 00                	push   $0x0
  pushl $57
8010661a:	6a 39                	push   $0x39
  jmp alltraps
8010661c:	e9 5d f9 ff ff       	jmp    80105f7e <alltraps>

80106621 <vector58>:
.globl vector58
vector58:
  pushl $0
80106621:	6a 00                	push   $0x0
  pushl $58
80106623:	6a 3a                	push   $0x3a
  jmp alltraps
80106625:	e9 54 f9 ff ff       	jmp    80105f7e <alltraps>

8010662a <vector59>:
.globl vector59
vector59:
  pushl $0
8010662a:	6a 00                	push   $0x0
  pushl $59
8010662c:	6a 3b                	push   $0x3b
  jmp alltraps
8010662e:	e9 4b f9 ff ff       	jmp    80105f7e <alltraps>

80106633 <vector60>:
.globl vector60
vector60:
  pushl $0
80106633:	6a 00                	push   $0x0
  pushl $60
80106635:	6a 3c                	push   $0x3c
  jmp alltraps
80106637:	e9 42 f9 ff ff       	jmp    80105f7e <alltraps>

8010663c <vector61>:
.globl vector61
vector61:
  pushl $0
8010663c:	6a 00                	push   $0x0
  pushl $61
8010663e:	6a 3d                	push   $0x3d
  jmp alltraps
80106640:	e9 39 f9 ff ff       	jmp    80105f7e <alltraps>

80106645 <vector62>:
.globl vector62
vector62:
  pushl $0
80106645:	6a 00                	push   $0x0
  pushl $62
80106647:	6a 3e                	push   $0x3e
  jmp alltraps
80106649:	e9 30 f9 ff ff       	jmp    80105f7e <alltraps>

8010664e <vector63>:
.globl vector63
vector63:
  pushl $0
8010664e:	6a 00                	push   $0x0
  pushl $63
80106650:	6a 3f                	push   $0x3f
  jmp alltraps
80106652:	e9 27 f9 ff ff       	jmp    80105f7e <alltraps>

80106657 <vector64>:
.globl vector64
vector64:
  pushl $0
80106657:	6a 00                	push   $0x0
  pushl $64
80106659:	6a 40                	push   $0x40
  jmp alltraps
8010665b:	e9 1e f9 ff ff       	jmp    80105f7e <alltraps>

80106660 <vector65>:
.globl vector65
vector65:
  pushl $0
80106660:	6a 00                	push   $0x0
  pushl $65
80106662:	6a 41                	push   $0x41
  jmp alltraps
80106664:	e9 15 f9 ff ff       	jmp    80105f7e <alltraps>

80106669 <vector66>:
.globl vector66
vector66:
  pushl $0
80106669:	6a 00                	push   $0x0
  pushl $66
8010666b:	6a 42                	push   $0x42
  jmp alltraps
8010666d:	e9 0c f9 ff ff       	jmp    80105f7e <alltraps>

80106672 <vector67>:
.globl vector67
vector67:
  pushl $0
80106672:	6a 00                	push   $0x0
  pushl $67
80106674:	6a 43                	push   $0x43
  jmp alltraps
80106676:	e9 03 f9 ff ff       	jmp    80105f7e <alltraps>

8010667b <vector68>:
.globl vector68
vector68:
  pushl $0
8010667b:	6a 00                	push   $0x0
  pushl $68
8010667d:	6a 44                	push   $0x44
  jmp alltraps
8010667f:	e9 fa f8 ff ff       	jmp    80105f7e <alltraps>

80106684 <vector69>:
.globl vector69
vector69:
  pushl $0
80106684:	6a 00                	push   $0x0
  pushl $69
80106686:	6a 45                	push   $0x45
  jmp alltraps
80106688:	e9 f1 f8 ff ff       	jmp    80105f7e <alltraps>

8010668d <vector70>:
.globl vector70
vector70:
  pushl $0
8010668d:	6a 00                	push   $0x0
  pushl $70
8010668f:	6a 46                	push   $0x46
  jmp alltraps
80106691:	e9 e8 f8 ff ff       	jmp    80105f7e <alltraps>

80106696 <vector71>:
.globl vector71
vector71:
  pushl $0
80106696:	6a 00                	push   $0x0
  pushl $71
80106698:	6a 47                	push   $0x47
  jmp alltraps
8010669a:	e9 df f8 ff ff       	jmp    80105f7e <alltraps>

8010669f <vector72>:
.globl vector72
vector72:
  pushl $0
8010669f:	6a 00                	push   $0x0
  pushl $72
801066a1:	6a 48                	push   $0x48
  jmp alltraps
801066a3:	e9 d6 f8 ff ff       	jmp    80105f7e <alltraps>

801066a8 <vector73>:
.globl vector73
vector73:
  pushl $0
801066a8:	6a 00                	push   $0x0
  pushl $73
801066aa:	6a 49                	push   $0x49
  jmp alltraps
801066ac:	e9 cd f8 ff ff       	jmp    80105f7e <alltraps>

801066b1 <vector74>:
.globl vector74
vector74:
  pushl $0
801066b1:	6a 00                	push   $0x0
  pushl $74
801066b3:	6a 4a                	push   $0x4a
  jmp alltraps
801066b5:	e9 c4 f8 ff ff       	jmp    80105f7e <alltraps>

801066ba <vector75>:
.globl vector75
vector75:
  pushl $0
801066ba:	6a 00                	push   $0x0
  pushl $75
801066bc:	6a 4b                	push   $0x4b
  jmp alltraps
801066be:	e9 bb f8 ff ff       	jmp    80105f7e <alltraps>

801066c3 <vector76>:
.globl vector76
vector76:
  pushl $0
801066c3:	6a 00                	push   $0x0
  pushl $76
801066c5:	6a 4c                	push   $0x4c
  jmp alltraps
801066c7:	e9 b2 f8 ff ff       	jmp    80105f7e <alltraps>

801066cc <vector77>:
.globl vector77
vector77:
  pushl $0
801066cc:	6a 00                	push   $0x0
  pushl $77
801066ce:	6a 4d                	push   $0x4d
  jmp alltraps
801066d0:	e9 a9 f8 ff ff       	jmp    80105f7e <alltraps>

801066d5 <vector78>:
.globl vector78
vector78:
  pushl $0
801066d5:	6a 00                	push   $0x0
  pushl $78
801066d7:	6a 4e                	push   $0x4e
  jmp alltraps
801066d9:	e9 a0 f8 ff ff       	jmp    80105f7e <alltraps>

801066de <vector79>:
.globl vector79
vector79:
  pushl $0
801066de:	6a 00                	push   $0x0
  pushl $79
801066e0:	6a 4f                	push   $0x4f
  jmp alltraps
801066e2:	e9 97 f8 ff ff       	jmp    80105f7e <alltraps>

801066e7 <vector80>:
.globl vector80
vector80:
  pushl $0
801066e7:	6a 00                	push   $0x0
  pushl $80
801066e9:	6a 50                	push   $0x50
  jmp alltraps
801066eb:	e9 8e f8 ff ff       	jmp    80105f7e <alltraps>

801066f0 <vector81>:
.globl vector81
vector81:
  pushl $0
801066f0:	6a 00                	push   $0x0
  pushl $81
801066f2:	6a 51                	push   $0x51
  jmp alltraps
801066f4:	e9 85 f8 ff ff       	jmp    80105f7e <alltraps>

801066f9 <vector82>:
.globl vector82
vector82:
  pushl $0
801066f9:	6a 00                	push   $0x0
  pushl $82
801066fb:	6a 52                	push   $0x52
  jmp alltraps
801066fd:	e9 7c f8 ff ff       	jmp    80105f7e <alltraps>

80106702 <vector83>:
.globl vector83
vector83:
  pushl $0
80106702:	6a 00                	push   $0x0
  pushl $83
80106704:	6a 53                	push   $0x53
  jmp alltraps
80106706:	e9 73 f8 ff ff       	jmp    80105f7e <alltraps>

8010670b <vector84>:
.globl vector84
vector84:
  pushl $0
8010670b:	6a 00                	push   $0x0
  pushl $84
8010670d:	6a 54                	push   $0x54
  jmp alltraps
8010670f:	e9 6a f8 ff ff       	jmp    80105f7e <alltraps>

80106714 <vector85>:
.globl vector85
vector85:
  pushl $0
80106714:	6a 00                	push   $0x0
  pushl $85
80106716:	6a 55                	push   $0x55
  jmp alltraps
80106718:	e9 61 f8 ff ff       	jmp    80105f7e <alltraps>

8010671d <vector86>:
.globl vector86
vector86:
  pushl $0
8010671d:	6a 00                	push   $0x0
  pushl $86
8010671f:	6a 56                	push   $0x56
  jmp alltraps
80106721:	e9 58 f8 ff ff       	jmp    80105f7e <alltraps>

80106726 <vector87>:
.globl vector87
vector87:
  pushl $0
80106726:	6a 00                	push   $0x0
  pushl $87
80106728:	6a 57                	push   $0x57
  jmp alltraps
8010672a:	e9 4f f8 ff ff       	jmp    80105f7e <alltraps>

8010672f <vector88>:
.globl vector88
vector88:
  pushl $0
8010672f:	6a 00                	push   $0x0
  pushl $88
80106731:	6a 58                	push   $0x58
  jmp alltraps
80106733:	e9 46 f8 ff ff       	jmp    80105f7e <alltraps>

80106738 <vector89>:
.globl vector89
vector89:
  pushl $0
80106738:	6a 00                	push   $0x0
  pushl $89
8010673a:	6a 59                	push   $0x59
  jmp alltraps
8010673c:	e9 3d f8 ff ff       	jmp    80105f7e <alltraps>

80106741 <vector90>:
.globl vector90
vector90:
  pushl $0
80106741:	6a 00                	push   $0x0
  pushl $90
80106743:	6a 5a                	push   $0x5a
  jmp alltraps
80106745:	e9 34 f8 ff ff       	jmp    80105f7e <alltraps>

8010674a <vector91>:
.globl vector91
vector91:
  pushl $0
8010674a:	6a 00                	push   $0x0
  pushl $91
8010674c:	6a 5b                	push   $0x5b
  jmp alltraps
8010674e:	e9 2b f8 ff ff       	jmp    80105f7e <alltraps>

80106753 <vector92>:
.globl vector92
vector92:
  pushl $0
80106753:	6a 00                	push   $0x0
  pushl $92
80106755:	6a 5c                	push   $0x5c
  jmp alltraps
80106757:	e9 22 f8 ff ff       	jmp    80105f7e <alltraps>

8010675c <vector93>:
.globl vector93
vector93:
  pushl $0
8010675c:	6a 00                	push   $0x0
  pushl $93
8010675e:	6a 5d                	push   $0x5d
  jmp alltraps
80106760:	e9 19 f8 ff ff       	jmp    80105f7e <alltraps>

80106765 <vector94>:
.globl vector94
vector94:
  pushl $0
80106765:	6a 00                	push   $0x0
  pushl $94
80106767:	6a 5e                	push   $0x5e
  jmp alltraps
80106769:	e9 10 f8 ff ff       	jmp    80105f7e <alltraps>

8010676e <vector95>:
.globl vector95
vector95:
  pushl $0
8010676e:	6a 00                	push   $0x0
  pushl $95
80106770:	6a 5f                	push   $0x5f
  jmp alltraps
80106772:	e9 07 f8 ff ff       	jmp    80105f7e <alltraps>

80106777 <vector96>:
.globl vector96
vector96:
  pushl $0
80106777:	6a 00                	push   $0x0
  pushl $96
80106779:	6a 60                	push   $0x60
  jmp alltraps
8010677b:	e9 fe f7 ff ff       	jmp    80105f7e <alltraps>

80106780 <vector97>:
.globl vector97
vector97:
  pushl $0
80106780:	6a 00                	push   $0x0
  pushl $97
80106782:	6a 61                	push   $0x61
  jmp alltraps
80106784:	e9 f5 f7 ff ff       	jmp    80105f7e <alltraps>

80106789 <vector98>:
.globl vector98
vector98:
  pushl $0
80106789:	6a 00                	push   $0x0
  pushl $98
8010678b:	6a 62                	push   $0x62
  jmp alltraps
8010678d:	e9 ec f7 ff ff       	jmp    80105f7e <alltraps>

80106792 <vector99>:
.globl vector99
vector99:
  pushl $0
80106792:	6a 00                	push   $0x0
  pushl $99
80106794:	6a 63                	push   $0x63
  jmp alltraps
80106796:	e9 e3 f7 ff ff       	jmp    80105f7e <alltraps>

8010679b <vector100>:
.globl vector100
vector100:
  pushl $0
8010679b:	6a 00                	push   $0x0
  pushl $100
8010679d:	6a 64                	push   $0x64
  jmp alltraps
8010679f:	e9 da f7 ff ff       	jmp    80105f7e <alltraps>

801067a4 <vector101>:
.globl vector101
vector101:
  pushl $0
801067a4:	6a 00                	push   $0x0
  pushl $101
801067a6:	6a 65                	push   $0x65
  jmp alltraps
801067a8:	e9 d1 f7 ff ff       	jmp    80105f7e <alltraps>

801067ad <vector102>:
.globl vector102
vector102:
  pushl $0
801067ad:	6a 00                	push   $0x0
  pushl $102
801067af:	6a 66                	push   $0x66
  jmp alltraps
801067b1:	e9 c8 f7 ff ff       	jmp    80105f7e <alltraps>

801067b6 <vector103>:
.globl vector103
vector103:
  pushl $0
801067b6:	6a 00                	push   $0x0
  pushl $103
801067b8:	6a 67                	push   $0x67
  jmp alltraps
801067ba:	e9 bf f7 ff ff       	jmp    80105f7e <alltraps>

801067bf <vector104>:
.globl vector104
vector104:
  pushl $0
801067bf:	6a 00                	push   $0x0
  pushl $104
801067c1:	6a 68                	push   $0x68
  jmp alltraps
801067c3:	e9 b6 f7 ff ff       	jmp    80105f7e <alltraps>

801067c8 <vector105>:
.globl vector105
vector105:
  pushl $0
801067c8:	6a 00                	push   $0x0
  pushl $105
801067ca:	6a 69                	push   $0x69
  jmp alltraps
801067cc:	e9 ad f7 ff ff       	jmp    80105f7e <alltraps>

801067d1 <vector106>:
.globl vector106
vector106:
  pushl $0
801067d1:	6a 00                	push   $0x0
  pushl $106
801067d3:	6a 6a                	push   $0x6a
  jmp alltraps
801067d5:	e9 a4 f7 ff ff       	jmp    80105f7e <alltraps>

801067da <vector107>:
.globl vector107
vector107:
  pushl $0
801067da:	6a 00                	push   $0x0
  pushl $107
801067dc:	6a 6b                	push   $0x6b
  jmp alltraps
801067de:	e9 9b f7 ff ff       	jmp    80105f7e <alltraps>

801067e3 <vector108>:
.globl vector108
vector108:
  pushl $0
801067e3:	6a 00                	push   $0x0
  pushl $108
801067e5:	6a 6c                	push   $0x6c
  jmp alltraps
801067e7:	e9 92 f7 ff ff       	jmp    80105f7e <alltraps>

801067ec <vector109>:
.globl vector109
vector109:
  pushl $0
801067ec:	6a 00                	push   $0x0
  pushl $109
801067ee:	6a 6d                	push   $0x6d
  jmp alltraps
801067f0:	e9 89 f7 ff ff       	jmp    80105f7e <alltraps>

801067f5 <vector110>:
.globl vector110
vector110:
  pushl $0
801067f5:	6a 00                	push   $0x0
  pushl $110
801067f7:	6a 6e                	push   $0x6e
  jmp alltraps
801067f9:	e9 80 f7 ff ff       	jmp    80105f7e <alltraps>

801067fe <vector111>:
.globl vector111
vector111:
  pushl $0
801067fe:	6a 00                	push   $0x0
  pushl $111
80106800:	6a 6f                	push   $0x6f
  jmp alltraps
80106802:	e9 77 f7 ff ff       	jmp    80105f7e <alltraps>

80106807 <vector112>:
.globl vector112
vector112:
  pushl $0
80106807:	6a 00                	push   $0x0
  pushl $112
80106809:	6a 70                	push   $0x70
  jmp alltraps
8010680b:	e9 6e f7 ff ff       	jmp    80105f7e <alltraps>

80106810 <vector113>:
.globl vector113
vector113:
  pushl $0
80106810:	6a 00                	push   $0x0
  pushl $113
80106812:	6a 71                	push   $0x71
  jmp alltraps
80106814:	e9 65 f7 ff ff       	jmp    80105f7e <alltraps>

80106819 <vector114>:
.globl vector114
vector114:
  pushl $0
80106819:	6a 00                	push   $0x0
  pushl $114
8010681b:	6a 72                	push   $0x72
  jmp alltraps
8010681d:	e9 5c f7 ff ff       	jmp    80105f7e <alltraps>

80106822 <vector115>:
.globl vector115
vector115:
  pushl $0
80106822:	6a 00                	push   $0x0
  pushl $115
80106824:	6a 73                	push   $0x73
  jmp alltraps
80106826:	e9 53 f7 ff ff       	jmp    80105f7e <alltraps>

8010682b <vector116>:
.globl vector116
vector116:
  pushl $0
8010682b:	6a 00                	push   $0x0
  pushl $116
8010682d:	6a 74                	push   $0x74
  jmp alltraps
8010682f:	e9 4a f7 ff ff       	jmp    80105f7e <alltraps>

80106834 <vector117>:
.globl vector117
vector117:
  pushl $0
80106834:	6a 00                	push   $0x0
  pushl $117
80106836:	6a 75                	push   $0x75
  jmp alltraps
80106838:	e9 41 f7 ff ff       	jmp    80105f7e <alltraps>

8010683d <vector118>:
.globl vector118
vector118:
  pushl $0
8010683d:	6a 00                	push   $0x0
  pushl $118
8010683f:	6a 76                	push   $0x76
  jmp alltraps
80106841:	e9 38 f7 ff ff       	jmp    80105f7e <alltraps>

80106846 <vector119>:
.globl vector119
vector119:
  pushl $0
80106846:	6a 00                	push   $0x0
  pushl $119
80106848:	6a 77                	push   $0x77
  jmp alltraps
8010684a:	e9 2f f7 ff ff       	jmp    80105f7e <alltraps>

8010684f <vector120>:
.globl vector120
vector120:
  pushl $0
8010684f:	6a 00                	push   $0x0
  pushl $120
80106851:	6a 78                	push   $0x78
  jmp alltraps
80106853:	e9 26 f7 ff ff       	jmp    80105f7e <alltraps>

80106858 <vector121>:
.globl vector121
vector121:
  pushl $0
80106858:	6a 00                	push   $0x0
  pushl $121
8010685a:	6a 79                	push   $0x79
  jmp alltraps
8010685c:	e9 1d f7 ff ff       	jmp    80105f7e <alltraps>

80106861 <vector122>:
.globl vector122
vector122:
  pushl $0
80106861:	6a 00                	push   $0x0
  pushl $122
80106863:	6a 7a                	push   $0x7a
  jmp alltraps
80106865:	e9 14 f7 ff ff       	jmp    80105f7e <alltraps>

8010686a <vector123>:
.globl vector123
vector123:
  pushl $0
8010686a:	6a 00                	push   $0x0
  pushl $123
8010686c:	6a 7b                	push   $0x7b
  jmp alltraps
8010686e:	e9 0b f7 ff ff       	jmp    80105f7e <alltraps>

80106873 <vector124>:
.globl vector124
vector124:
  pushl $0
80106873:	6a 00                	push   $0x0
  pushl $124
80106875:	6a 7c                	push   $0x7c
  jmp alltraps
80106877:	e9 02 f7 ff ff       	jmp    80105f7e <alltraps>

8010687c <vector125>:
.globl vector125
vector125:
  pushl $0
8010687c:	6a 00                	push   $0x0
  pushl $125
8010687e:	6a 7d                	push   $0x7d
  jmp alltraps
80106880:	e9 f9 f6 ff ff       	jmp    80105f7e <alltraps>

80106885 <vector126>:
.globl vector126
vector126:
  pushl $0
80106885:	6a 00                	push   $0x0
  pushl $126
80106887:	6a 7e                	push   $0x7e
  jmp alltraps
80106889:	e9 f0 f6 ff ff       	jmp    80105f7e <alltraps>

8010688e <vector127>:
.globl vector127
vector127:
  pushl $0
8010688e:	6a 00                	push   $0x0
  pushl $127
80106890:	6a 7f                	push   $0x7f
  jmp alltraps
80106892:	e9 e7 f6 ff ff       	jmp    80105f7e <alltraps>

80106897 <vector128>:
.globl vector128
vector128:
  pushl $0
80106897:	6a 00                	push   $0x0
  pushl $128
80106899:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010689e:	e9 db f6 ff ff       	jmp    80105f7e <alltraps>

801068a3 <vector129>:
.globl vector129
vector129:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $129
801068a5:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801068aa:	e9 cf f6 ff ff       	jmp    80105f7e <alltraps>

801068af <vector130>:
.globl vector130
vector130:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $130
801068b1:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801068b6:	e9 c3 f6 ff ff       	jmp    80105f7e <alltraps>

801068bb <vector131>:
.globl vector131
vector131:
  pushl $0
801068bb:	6a 00                	push   $0x0
  pushl $131
801068bd:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801068c2:	e9 b7 f6 ff ff       	jmp    80105f7e <alltraps>

801068c7 <vector132>:
.globl vector132
vector132:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $132
801068c9:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801068ce:	e9 ab f6 ff ff       	jmp    80105f7e <alltraps>

801068d3 <vector133>:
.globl vector133
vector133:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $133
801068d5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801068da:	e9 9f f6 ff ff       	jmp    80105f7e <alltraps>

801068df <vector134>:
.globl vector134
vector134:
  pushl $0
801068df:	6a 00                	push   $0x0
  pushl $134
801068e1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801068e6:	e9 93 f6 ff ff       	jmp    80105f7e <alltraps>

801068eb <vector135>:
.globl vector135
vector135:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $135
801068ed:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801068f2:	e9 87 f6 ff ff       	jmp    80105f7e <alltraps>

801068f7 <vector136>:
.globl vector136
vector136:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $136
801068f9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801068fe:	e9 7b f6 ff ff       	jmp    80105f7e <alltraps>

80106903 <vector137>:
.globl vector137
vector137:
  pushl $0
80106903:	6a 00                	push   $0x0
  pushl $137
80106905:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010690a:	e9 6f f6 ff ff       	jmp    80105f7e <alltraps>

8010690f <vector138>:
.globl vector138
vector138:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $138
80106911:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106916:	e9 63 f6 ff ff       	jmp    80105f7e <alltraps>

8010691b <vector139>:
.globl vector139
vector139:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $139
8010691d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106922:	e9 57 f6 ff ff       	jmp    80105f7e <alltraps>

80106927 <vector140>:
.globl vector140
vector140:
  pushl $0
80106927:	6a 00                	push   $0x0
  pushl $140
80106929:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010692e:	e9 4b f6 ff ff       	jmp    80105f7e <alltraps>

80106933 <vector141>:
.globl vector141
vector141:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $141
80106935:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010693a:	e9 3f f6 ff ff       	jmp    80105f7e <alltraps>

8010693f <vector142>:
.globl vector142
vector142:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $142
80106941:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106946:	e9 33 f6 ff ff       	jmp    80105f7e <alltraps>

8010694b <vector143>:
.globl vector143
vector143:
  pushl $0
8010694b:	6a 00                	push   $0x0
  pushl $143
8010694d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106952:	e9 27 f6 ff ff       	jmp    80105f7e <alltraps>

80106957 <vector144>:
.globl vector144
vector144:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $144
80106959:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010695e:	e9 1b f6 ff ff       	jmp    80105f7e <alltraps>

80106963 <vector145>:
.globl vector145
vector145:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $145
80106965:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010696a:	e9 0f f6 ff ff       	jmp    80105f7e <alltraps>

8010696f <vector146>:
.globl vector146
vector146:
  pushl $0
8010696f:	6a 00                	push   $0x0
  pushl $146
80106971:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106976:	e9 03 f6 ff ff       	jmp    80105f7e <alltraps>

8010697b <vector147>:
.globl vector147
vector147:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $147
8010697d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106982:	e9 f7 f5 ff ff       	jmp    80105f7e <alltraps>

80106987 <vector148>:
.globl vector148
vector148:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $148
80106989:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010698e:	e9 eb f5 ff ff       	jmp    80105f7e <alltraps>

80106993 <vector149>:
.globl vector149
vector149:
  pushl $0
80106993:	6a 00                	push   $0x0
  pushl $149
80106995:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010699a:	e9 df f5 ff ff       	jmp    80105f7e <alltraps>

8010699f <vector150>:
.globl vector150
vector150:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $150
801069a1:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801069a6:	e9 d3 f5 ff ff       	jmp    80105f7e <alltraps>

801069ab <vector151>:
.globl vector151
vector151:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $151
801069ad:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801069b2:	e9 c7 f5 ff ff       	jmp    80105f7e <alltraps>

801069b7 <vector152>:
.globl vector152
vector152:
  pushl $0
801069b7:	6a 00                	push   $0x0
  pushl $152
801069b9:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801069be:	e9 bb f5 ff ff       	jmp    80105f7e <alltraps>

801069c3 <vector153>:
.globl vector153
vector153:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $153
801069c5:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801069ca:	e9 af f5 ff ff       	jmp    80105f7e <alltraps>

801069cf <vector154>:
.globl vector154
vector154:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $154
801069d1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801069d6:	e9 a3 f5 ff ff       	jmp    80105f7e <alltraps>

801069db <vector155>:
.globl vector155
vector155:
  pushl $0
801069db:	6a 00                	push   $0x0
  pushl $155
801069dd:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801069e2:	e9 97 f5 ff ff       	jmp    80105f7e <alltraps>

801069e7 <vector156>:
.globl vector156
vector156:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $156
801069e9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801069ee:	e9 8b f5 ff ff       	jmp    80105f7e <alltraps>

801069f3 <vector157>:
.globl vector157
vector157:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $157
801069f5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801069fa:	e9 7f f5 ff ff       	jmp    80105f7e <alltraps>

801069ff <vector158>:
.globl vector158
vector158:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $158
80106a01:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106a06:	e9 73 f5 ff ff       	jmp    80105f7e <alltraps>

80106a0b <vector159>:
.globl vector159
vector159:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $159
80106a0d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106a12:	e9 67 f5 ff ff       	jmp    80105f7e <alltraps>

80106a17 <vector160>:
.globl vector160
vector160:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $160
80106a19:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106a1e:	e9 5b f5 ff ff       	jmp    80105f7e <alltraps>

80106a23 <vector161>:
.globl vector161
vector161:
  pushl $0
80106a23:	6a 00                	push   $0x0
  pushl $161
80106a25:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106a2a:	e9 4f f5 ff ff       	jmp    80105f7e <alltraps>

80106a2f <vector162>:
.globl vector162
vector162:
  pushl $0
80106a2f:	6a 00                	push   $0x0
  pushl $162
80106a31:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106a36:	e9 43 f5 ff ff       	jmp    80105f7e <alltraps>

80106a3b <vector163>:
.globl vector163
vector163:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $163
80106a3d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106a42:	e9 37 f5 ff ff       	jmp    80105f7e <alltraps>

80106a47 <vector164>:
.globl vector164
vector164:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $164
80106a49:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106a4e:	e9 2b f5 ff ff       	jmp    80105f7e <alltraps>

80106a53 <vector165>:
.globl vector165
vector165:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $165
80106a55:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106a5a:	e9 1f f5 ff ff       	jmp    80105f7e <alltraps>

80106a5f <vector166>:
.globl vector166
vector166:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $166
80106a61:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106a66:	e9 13 f5 ff ff       	jmp    80105f7e <alltraps>

80106a6b <vector167>:
.globl vector167
vector167:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $167
80106a6d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106a72:	e9 07 f5 ff ff       	jmp    80105f7e <alltraps>

80106a77 <vector168>:
.globl vector168
vector168:
  pushl $0
80106a77:	6a 00                	push   $0x0
  pushl $168
80106a79:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106a7e:	e9 fb f4 ff ff       	jmp    80105f7e <alltraps>

80106a83 <vector169>:
.globl vector169
vector169:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $169
80106a85:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106a8a:	e9 ef f4 ff ff       	jmp    80105f7e <alltraps>

80106a8f <vector170>:
.globl vector170
vector170:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $170
80106a91:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106a96:	e9 e3 f4 ff ff       	jmp    80105f7e <alltraps>

80106a9b <vector171>:
.globl vector171
vector171:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $171
80106a9d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106aa2:	e9 d7 f4 ff ff       	jmp    80105f7e <alltraps>

80106aa7 <vector172>:
.globl vector172
vector172:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $172
80106aa9:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106aae:	e9 cb f4 ff ff       	jmp    80105f7e <alltraps>

80106ab3 <vector173>:
.globl vector173
vector173:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $173
80106ab5:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106aba:	e9 bf f4 ff ff       	jmp    80105f7e <alltraps>

80106abf <vector174>:
.globl vector174
vector174:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $174
80106ac1:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106ac6:	e9 b3 f4 ff ff       	jmp    80105f7e <alltraps>

80106acb <vector175>:
.globl vector175
vector175:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $175
80106acd:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106ad2:	e9 a7 f4 ff ff       	jmp    80105f7e <alltraps>

80106ad7 <vector176>:
.globl vector176
vector176:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $176
80106ad9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106ade:	e9 9b f4 ff ff       	jmp    80105f7e <alltraps>

80106ae3 <vector177>:
.globl vector177
vector177:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $177
80106ae5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106aea:	e9 8f f4 ff ff       	jmp    80105f7e <alltraps>

80106aef <vector178>:
.globl vector178
vector178:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $178
80106af1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106af6:	e9 83 f4 ff ff       	jmp    80105f7e <alltraps>

80106afb <vector179>:
.globl vector179
vector179:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $179
80106afd:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106b02:	e9 77 f4 ff ff       	jmp    80105f7e <alltraps>

80106b07 <vector180>:
.globl vector180
vector180:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $180
80106b09:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106b0e:	e9 6b f4 ff ff       	jmp    80105f7e <alltraps>

80106b13 <vector181>:
.globl vector181
vector181:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $181
80106b15:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106b1a:	e9 5f f4 ff ff       	jmp    80105f7e <alltraps>

80106b1f <vector182>:
.globl vector182
vector182:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $182
80106b21:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106b26:	e9 53 f4 ff ff       	jmp    80105f7e <alltraps>

80106b2b <vector183>:
.globl vector183
vector183:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $183
80106b2d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106b32:	e9 47 f4 ff ff       	jmp    80105f7e <alltraps>

80106b37 <vector184>:
.globl vector184
vector184:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $184
80106b39:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106b3e:	e9 3b f4 ff ff       	jmp    80105f7e <alltraps>

80106b43 <vector185>:
.globl vector185
vector185:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $185
80106b45:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106b4a:	e9 2f f4 ff ff       	jmp    80105f7e <alltraps>

80106b4f <vector186>:
.globl vector186
vector186:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $186
80106b51:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106b56:	e9 23 f4 ff ff       	jmp    80105f7e <alltraps>

80106b5b <vector187>:
.globl vector187
vector187:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $187
80106b5d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106b62:	e9 17 f4 ff ff       	jmp    80105f7e <alltraps>

80106b67 <vector188>:
.globl vector188
vector188:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $188
80106b69:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106b6e:	e9 0b f4 ff ff       	jmp    80105f7e <alltraps>

80106b73 <vector189>:
.globl vector189
vector189:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $189
80106b75:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106b7a:	e9 ff f3 ff ff       	jmp    80105f7e <alltraps>

80106b7f <vector190>:
.globl vector190
vector190:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $190
80106b81:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106b86:	e9 f3 f3 ff ff       	jmp    80105f7e <alltraps>

80106b8b <vector191>:
.globl vector191
vector191:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $191
80106b8d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106b92:	e9 e7 f3 ff ff       	jmp    80105f7e <alltraps>

80106b97 <vector192>:
.globl vector192
vector192:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $192
80106b99:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106b9e:	e9 db f3 ff ff       	jmp    80105f7e <alltraps>

80106ba3 <vector193>:
.globl vector193
vector193:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $193
80106ba5:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106baa:	e9 cf f3 ff ff       	jmp    80105f7e <alltraps>

80106baf <vector194>:
.globl vector194
vector194:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $194
80106bb1:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106bb6:	e9 c3 f3 ff ff       	jmp    80105f7e <alltraps>

80106bbb <vector195>:
.globl vector195
vector195:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $195
80106bbd:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106bc2:	e9 b7 f3 ff ff       	jmp    80105f7e <alltraps>

80106bc7 <vector196>:
.globl vector196
vector196:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $196
80106bc9:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106bce:	e9 ab f3 ff ff       	jmp    80105f7e <alltraps>

80106bd3 <vector197>:
.globl vector197
vector197:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $197
80106bd5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106bda:	e9 9f f3 ff ff       	jmp    80105f7e <alltraps>

80106bdf <vector198>:
.globl vector198
vector198:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $198
80106be1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106be6:	e9 93 f3 ff ff       	jmp    80105f7e <alltraps>

80106beb <vector199>:
.globl vector199
vector199:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $199
80106bed:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106bf2:	e9 87 f3 ff ff       	jmp    80105f7e <alltraps>

80106bf7 <vector200>:
.globl vector200
vector200:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $200
80106bf9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106bfe:	e9 7b f3 ff ff       	jmp    80105f7e <alltraps>

80106c03 <vector201>:
.globl vector201
vector201:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $201
80106c05:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106c0a:	e9 6f f3 ff ff       	jmp    80105f7e <alltraps>

80106c0f <vector202>:
.globl vector202
vector202:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $202
80106c11:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106c16:	e9 63 f3 ff ff       	jmp    80105f7e <alltraps>

80106c1b <vector203>:
.globl vector203
vector203:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $203
80106c1d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106c22:	e9 57 f3 ff ff       	jmp    80105f7e <alltraps>

80106c27 <vector204>:
.globl vector204
vector204:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $204
80106c29:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106c2e:	e9 4b f3 ff ff       	jmp    80105f7e <alltraps>

80106c33 <vector205>:
.globl vector205
vector205:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $205
80106c35:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106c3a:	e9 3f f3 ff ff       	jmp    80105f7e <alltraps>

80106c3f <vector206>:
.globl vector206
vector206:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $206
80106c41:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106c46:	e9 33 f3 ff ff       	jmp    80105f7e <alltraps>

80106c4b <vector207>:
.globl vector207
vector207:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $207
80106c4d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106c52:	e9 27 f3 ff ff       	jmp    80105f7e <alltraps>

80106c57 <vector208>:
.globl vector208
vector208:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $208
80106c59:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106c5e:	e9 1b f3 ff ff       	jmp    80105f7e <alltraps>

80106c63 <vector209>:
.globl vector209
vector209:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $209
80106c65:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106c6a:	e9 0f f3 ff ff       	jmp    80105f7e <alltraps>

80106c6f <vector210>:
.globl vector210
vector210:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $210
80106c71:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106c76:	e9 03 f3 ff ff       	jmp    80105f7e <alltraps>

80106c7b <vector211>:
.globl vector211
vector211:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $211
80106c7d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106c82:	e9 f7 f2 ff ff       	jmp    80105f7e <alltraps>

80106c87 <vector212>:
.globl vector212
vector212:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $212
80106c89:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106c8e:	e9 eb f2 ff ff       	jmp    80105f7e <alltraps>

80106c93 <vector213>:
.globl vector213
vector213:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $213
80106c95:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106c9a:	e9 df f2 ff ff       	jmp    80105f7e <alltraps>

80106c9f <vector214>:
.globl vector214
vector214:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $214
80106ca1:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106ca6:	e9 d3 f2 ff ff       	jmp    80105f7e <alltraps>

80106cab <vector215>:
.globl vector215
vector215:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $215
80106cad:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106cb2:	e9 c7 f2 ff ff       	jmp    80105f7e <alltraps>

80106cb7 <vector216>:
.globl vector216
vector216:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $216
80106cb9:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106cbe:	e9 bb f2 ff ff       	jmp    80105f7e <alltraps>

80106cc3 <vector217>:
.globl vector217
vector217:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $217
80106cc5:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106cca:	e9 af f2 ff ff       	jmp    80105f7e <alltraps>

80106ccf <vector218>:
.globl vector218
vector218:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $218
80106cd1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106cd6:	e9 a3 f2 ff ff       	jmp    80105f7e <alltraps>

80106cdb <vector219>:
.globl vector219
vector219:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $219
80106cdd:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106ce2:	e9 97 f2 ff ff       	jmp    80105f7e <alltraps>

80106ce7 <vector220>:
.globl vector220
vector220:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $220
80106ce9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106cee:	e9 8b f2 ff ff       	jmp    80105f7e <alltraps>

80106cf3 <vector221>:
.globl vector221
vector221:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $221
80106cf5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106cfa:	e9 7f f2 ff ff       	jmp    80105f7e <alltraps>

80106cff <vector222>:
.globl vector222
vector222:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $222
80106d01:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106d06:	e9 73 f2 ff ff       	jmp    80105f7e <alltraps>

80106d0b <vector223>:
.globl vector223
vector223:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $223
80106d0d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106d12:	e9 67 f2 ff ff       	jmp    80105f7e <alltraps>

80106d17 <vector224>:
.globl vector224
vector224:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $224
80106d19:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106d1e:	e9 5b f2 ff ff       	jmp    80105f7e <alltraps>

80106d23 <vector225>:
.globl vector225
vector225:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $225
80106d25:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106d2a:	e9 4f f2 ff ff       	jmp    80105f7e <alltraps>

80106d2f <vector226>:
.globl vector226
vector226:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $226
80106d31:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106d36:	e9 43 f2 ff ff       	jmp    80105f7e <alltraps>

80106d3b <vector227>:
.globl vector227
vector227:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $227
80106d3d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106d42:	e9 37 f2 ff ff       	jmp    80105f7e <alltraps>

80106d47 <vector228>:
.globl vector228
vector228:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $228
80106d49:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106d4e:	e9 2b f2 ff ff       	jmp    80105f7e <alltraps>

80106d53 <vector229>:
.globl vector229
vector229:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $229
80106d55:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106d5a:	e9 1f f2 ff ff       	jmp    80105f7e <alltraps>

80106d5f <vector230>:
.globl vector230
vector230:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $230
80106d61:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106d66:	e9 13 f2 ff ff       	jmp    80105f7e <alltraps>

80106d6b <vector231>:
.globl vector231
vector231:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $231
80106d6d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106d72:	e9 07 f2 ff ff       	jmp    80105f7e <alltraps>

80106d77 <vector232>:
.globl vector232
vector232:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $232
80106d79:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106d7e:	e9 fb f1 ff ff       	jmp    80105f7e <alltraps>

80106d83 <vector233>:
.globl vector233
vector233:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $233
80106d85:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106d8a:	e9 ef f1 ff ff       	jmp    80105f7e <alltraps>

80106d8f <vector234>:
.globl vector234
vector234:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $234
80106d91:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106d96:	e9 e3 f1 ff ff       	jmp    80105f7e <alltraps>

80106d9b <vector235>:
.globl vector235
vector235:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $235
80106d9d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106da2:	e9 d7 f1 ff ff       	jmp    80105f7e <alltraps>

80106da7 <vector236>:
.globl vector236
vector236:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $236
80106da9:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106dae:	e9 cb f1 ff ff       	jmp    80105f7e <alltraps>

80106db3 <vector237>:
.globl vector237
vector237:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $237
80106db5:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106dba:	e9 bf f1 ff ff       	jmp    80105f7e <alltraps>

80106dbf <vector238>:
.globl vector238
vector238:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $238
80106dc1:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106dc6:	e9 b3 f1 ff ff       	jmp    80105f7e <alltraps>

80106dcb <vector239>:
.globl vector239
vector239:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $239
80106dcd:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106dd2:	e9 a7 f1 ff ff       	jmp    80105f7e <alltraps>

80106dd7 <vector240>:
.globl vector240
vector240:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $240
80106dd9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106dde:	e9 9b f1 ff ff       	jmp    80105f7e <alltraps>

80106de3 <vector241>:
.globl vector241
vector241:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $241
80106de5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106dea:	e9 8f f1 ff ff       	jmp    80105f7e <alltraps>

80106def <vector242>:
.globl vector242
vector242:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $242
80106df1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106df6:	e9 83 f1 ff ff       	jmp    80105f7e <alltraps>

80106dfb <vector243>:
.globl vector243
vector243:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $243
80106dfd:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106e02:	e9 77 f1 ff ff       	jmp    80105f7e <alltraps>

80106e07 <vector244>:
.globl vector244
vector244:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $244
80106e09:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106e0e:	e9 6b f1 ff ff       	jmp    80105f7e <alltraps>

80106e13 <vector245>:
.globl vector245
vector245:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $245
80106e15:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106e1a:	e9 5f f1 ff ff       	jmp    80105f7e <alltraps>

80106e1f <vector246>:
.globl vector246
vector246:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $246
80106e21:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106e26:	e9 53 f1 ff ff       	jmp    80105f7e <alltraps>

80106e2b <vector247>:
.globl vector247
vector247:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $247
80106e2d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106e32:	e9 47 f1 ff ff       	jmp    80105f7e <alltraps>

80106e37 <vector248>:
.globl vector248
vector248:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $248
80106e39:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106e3e:	e9 3b f1 ff ff       	jmp    80105f7e <alltraps>

80106e43 <vector249>:
.globl vector249
vector249:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $249
80106e45:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106e4a:	e9 2f f1 ff ff       	jmp    80105f7e <alltraps>

80106e4f <vector250>:
.globl vector250
vector250:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $250
80106e51:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106e56:	e9 23 f1 ff ff       	jmp    80105f7e <alltraps>

80106e5b <vector251>:
.globl vector251
vector251:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $251
80106e5d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106e62:	e9 17 f1 ff ff       	jmp    80105f7e <alltraps>

80106e67 <vector252>:
.globl vector252
vector252:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $252
80106e69:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106e6e:	e9 0b f1 ff ff       	jmp    80105f7e <alltraps>

80106e73 <vector253>:
.globl vector253
vector253:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $253
80106e75:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106e7a:	e9 ff f0 ff ff       	jmp    80105f7e <alltraps>

80106e7f <vector254>:
.globl vector254
vector254:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $254
80106e81:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106e86:	e9 f3 f0 ff ff       	jmp    80105f7e <alltraps>

80106e8b <vector255>:
.globl vector255
vector255:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $255
80106e8d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106e92:	e9 e7 f0 ff ff       	jmp    80105f7e <alltraps>
80106e97:	66 90                	xchg   %ax,%ax
80106e99:	66 90                	xchg   %ax,%ax
80106e9b:	66 90                	xchg   %ax,%ax
80106e9d:	66 90                	xchg   %ax,%ax
80106e9f:	90                   	nop

80106ea0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106ea0:	55                   	push   %ebp
80106ea1:	89 e5                	mov    %esp,%ebp
80106ea3:	57                   	push   %edi
80106ea4:	56                   	push   %esi
80106ea5:	53                   	push   %ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106ea6:	89 d3                	mov    %edx,%ebx
{
80106ea8:	89 d7                	mov    %edx,%edi
  pde = &pgdir[PDX(va)];
80106eaa:	c1 eb 16             	shr    $0x16,%ebx
80106ead:	8d 34 98             	lea    (%eax,%ebx,4),%esi
{
80106eb0:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80106eb3:	8b 06                	mov    (%esi),%eax
80106eb5:	a8 01                	test   $0x1,%al
80106eb7:	74 27                	je     80106ee0 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106eb9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106ebe:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106ec4:	c1 ef 0a             	shr    $0xa,%edi
}
80106ec7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80106eca:	89 fa                	mov    %edi,%edx
80106ecc:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106ed2:	8d 04 13             	lea    (%ebx,%edx,1),%eax
}
80106ed5:	5b                   	pop    %ebx
80106ed6:	5e                   	pop    %esi
80106ed7:	5f                   	pop    %edi
80106ed8:	5d                   	pop    %ebp
80106ed9:	c3                   	ret    
80106eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106ee0:	85 c9                	test   %ecx,%ecx
80106ee2:	74 2c                	je     80106f10 <walkpgdir+0x70>
80106ee4:	e8 d7 b5 ff ff       	call   801024c0 <kalloc>
80106ee9:	85 c0                	test   %eax,%eax
80106eeb:	89 c3                	mov    %eax,%ebx
80106eed:	74 21                	je     80106f10 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
80106eef:	83 ec 04             	sub    $0x4,%esp
80106ef2:	68 00 10 00 00       	push   $0x1000
80106ef7:	6a 00                	push   $0x0
80106ef9:	50                   	push   %eax
80106efa:	e8 d1 dc ff ff       	call   80104bd0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106eff:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106f05:	83 c4 10             	add    $0x10,%esp
80106f08:	83 c8 07             	or     $0x7,%eax
80106f0b:	89 06                	mov    %eax,(%esi)
80106f0d:	eb b5                	jmp    80106ec4 <walkpgdir+0x24>
80106f0f:	90                   	nop
}
80106f10:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80106f13:	31 c0                	xor    %eax,%eax
}
80106f15:	5b                   	pop    %ebx
80106f16:	5e                   	pop    %esi
80106f17:	5f                   	pop    %edi
80106f18:	5d                   	pop    %ebp
80106f19:	c3                   	ret    
80106f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106f20 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106f20:	55                   	push   %ebp
80106f21:	89 e5                	mov    %esp,%ebp
80106f23:	57                   	push   %edi
80106f24:	56                   	push   %esi
80106f25:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106f26:	89 d3                	mov    %edx,%ebx
80106f28:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
80106f2e:	83 ec 1c             	sub    $0x1c,%esp
80106f31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106f34:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80106f38:	8b 7d 08             	mov    0x8(%ebp),%edi
80106f3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106f40:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
80106f43:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f46:	29 df                	sub    %ebx,%edi
80106f48:	83 c8 01             	or     $0x1,%eax
80106f4b:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106f4e:	eb 15                	jmp    80106f65 <mappages+0x45>
    if(*pte & PTE_P)
80106f50:	f6 00 01             	testb  $0x1,(%eax)
80106f53:	75 45                	jne    80106f9a <mappages+0x7a>
    *pte = pa | perm | PTE_P;
80106f55:	0b 75 dc             	or     -0x24(%ebp),%esi
    if(a == last)
80106f58:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
    *pte = pa | perm | PTE_P;
80106f5b:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106f5d:	74 31                	je     80106f90 <mappages+0x70>
      break;
    a += PGSIZE;
80106f5f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106f65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f68:	b9 01 00 00 00       	mov    $0x1,%ecx
80106f6d:	89 da                	mov    %ebx,%edx
80106f6f:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
80106f72:	e8 29 ff ff ff       	call   80106ea0 <walkpgdir>
80106f77:	85 c0                	test   %eax,%eax
80106f79:	75 d5                	jne    80106f50 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
80106f7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106f7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106f83:	5b                   	pop    %ebx
80106f84:	5e                   	pop    %esi
80106f85:	5f                   	pop    %edi
80106f86:	5d                   	pop    %ebp
80106f87:	c3                   	ret    
80106f88:	90                   	nop
80106f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106f93:	31 c0                	xor    %eax,%eax
}
80106f95:	5b                   	pop    %ebx
80106f96:	5e                   	pop    %esi
80106f97:	5f                   	pop    %edi
80106f98:	5d                   	pop    %ebp
80106f99:	c3                   	ret    
      panic("remap");
80106f9a:	83 ec 0c             	sub    $0xc,%esp
80106f9d:	68 04 83 10 80       	push   $0x80108304
80106fa2:	e8 c9 93 ff ff       	call   80100370 <panic>
80106fa7:	89 f6                	mov    %esi,%esi
80106fa9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106fb0 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106fb0:	55                   	push   %ebp
80106fb1:	89 e5                	mov    %esp,%ebp
80106fb3:	57                   	push   %edi
80106fb4:	56                   	push   %esi
80106fb5:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106fb6:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106fbc:	89 c7                	mov    %eax,%edi
  a = PGROUNDUP(newsz);
80106fbe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106fc4:	83 ec 1c             	sub    $0x1c,%esp
80106fc7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106fca:	39 d3                	cmp    %edx,%ebx
80106fcc:	73 60                	jae    8010702e <deallocuvm.part.0+0x7e>
80106fce:	89 d6                	mov    %edx,%esi
80106fd0:	eb 3d                	jmp    8010700f <deallocuvm.part.0+0x5f>
80106fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a += (NPTENTRIES - 1) * PGSIZE;
    else if((*pte & PTE_P) != 0){
80106fd8:	8b 10                	mov    (%eax),%edx
80106fda:	f6 c2 01             	test   $0x1,%dl
80106fdd:	74 26                	je     80107005 <deallocuvm.part.0+0x55>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106fdf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80106fe5:	74 52                	je     80107039 <deallocuvm.part.0+0x89>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106fe7:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106fea:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80106ff0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80106ff3:	52                   	push   %edx
80106ff4:	e8 17 b3 ff ff       	call   80102310 <kfree>
      *pte = 0;
80106ff9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ffc:	83 c4 10             	add    $0x10,%esp
80106fff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107005:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010700b:	39 f3                	cmp    %esi,%ebx
8010700d:	73 1f                	jae    8010702e <deallocuvm.part.0+0x7e>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010700f:	31 c9                	xor    %ecx,%ecx
80107011:	89 da                	mov    %ebx,%edx
80107013:	89 f8                	mov    %edi,%eax
80107015:	e8 86 fe ff ff       	call   80106ea0 <walkpgdir>
    if(!pte)
8010701a:	85 c0                	test   %eax,%eax
8010701c:	75 ba                	jne    80106fd8 <deallocuvm.part.0+0x28>
      a += (NPTENTRIES - 1) * PGSIZE;
8010701e:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80107024:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010702a:	39 f3                	cmp    %esi,%ebx
8010702c:	72 e1                	jb     8010700f <deallocuvm.part.0+0x5f>
    }
  }
  return newsz;
}
8010702e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107031:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107034:	5b                   	pop    %ebx
80107035:	5e                   	pop    %esi
80107036:	5f                   	pop    %edi
80107037:	5d                   	pop    %ebp
80107038:	c3                   	ret    
        panic("kfree");
80107039:	83 ec 0c             	sub    $0xc,%esp
8010703c:	68 fa 7a 10 80       	push   $0x80107afa
80107041:	e8 2a 93 ff ff       	call   80100370 <panic>
80107046:	8d 76 00             	lea    0x0(%esi),%esi
80107049:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107050 <seginit>:
{
80107050:	55                   	push   %ebp
80107051:	89 e5                	mov    %esp,%ebp
80107053:	53                   	push   %ebx
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107054:	31 db                	xor    %ebx,%ebx
{
80107056:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpunum()];
80107059:	e8 d2 b6 ff ff       	call   80102730 <cpunum>
8010705e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107064:	8d 90 e0 22 11 80    	lea    -0x7feedd20(%eax),%edx
8010706a:	8d 88 94 23 11 80    	lea    -0x7feedc6c(%eax),%ecx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107070:	c7 80 58 23 11 80 ff 	movl   $0xffff,-0x7feedca8(%eax)
80107077:	ff 00 00 
8010707a:	c7 80 5c 23 11 80 00 	movl   $0xcf9a00,-0x7feedca4(%eax)
80107081:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107084:	c7 80 60 23 11 80 ff 	movl   $0xffff,-0x7feedca0(%eax)
8010708b:	ff 00 00 
8010708e:	c7 80 64 23 11 80 00 	movl   $0xcf9200,-0x7feedc9c(%eax)
80107095:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107098:	c7 80 70 23 11 80 ff 	movl   $0xffff,-0x7feedc90(%eax)
8010709f:	ff 00 00 
801070a2:	c7 80 74 23 11 80 00 	movl   $0xcffa00,-0x7feedc8c(%eax)
801070a9:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801070ac:	c7 80 78 23 11 80 ff 	movl   $0xffff,-0x7feedc88(%eax)
801070b3:	ff 00 00 
801070b6:	c7 80 7c 23 11 80 00 	movl   $0xcff200,-0x7feedc84(%eax)
801070bd:	f2 cf 00 
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801070c0:	66 89 9a 88 00 00 00 	mov    %bx,0x88(%edx)
801070c7:	89 cb                	mov    %ecx,%ebx
801070c9:	c1 eb 10             	shr    $0x10,%ebx
801070cc:	66 89 8a 8a 00 00 00 	mov    %cx,0x8a(%edx)
801070d3:	c1 e9 18             	shr    $0x18,%ecx
801070d6:	88 9a 8c 00 00 00    	mov    %bl,0x8c(%edx)
801070dc:	bb 92 c0 ff ff       	mov    $0xffffc092,%ebx
801070e1:	66 89 98 6d 23 11 80 	mov    %bx,-0x7feedc93(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801070e8:	05 50 23 11 80       	add    $0x80112350,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801070ed:	88 8a 8f 00 00 00    	mov    %cl,0x8f(%edx)
  pd[0] = size-1;
801070f3:	b9 37 00 00 00       	mov    $0x37,%ecx
801070f8:	66 89 4d f2          	mov    %cx,-0xe(%ebp)
  pd[1] = (uint)p;
801070fc:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107100:	c1 e8 10             	shr    $0x10,%eax
80107103:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107107:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010710a:	0f 01 10             	lgdtl  (%eax)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010710d:	b8 18 00 00 00       	mov    $0x18,%eax
80107112:	8e e8                	mov    %eax,%gs
  proc = 0;
80107114:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010711b:	00 00 00 00 
  c = &cpus[cpunum()];
8010711f:	65 89 15 00 00 00 00 	mov    %edx,%gs:0x0
}
80107126:	83 c4 14             	add    $0x14,%esp
80107129:	5b                   	pop    %ebx
8010712a:	5d                   	pop    %ebp
8010712b:	c3                   	ret    
8010712c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107130 <setupkvm>:
{
80107130:	55                   	push   %ebp
80107131:	89 e5                	mov    %esp,%ebp
80107133:	56                   	push   %esi
80107134:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80107135:	e8 86 b3 ff ff       	call   801024c0 <kalloc>
8010713a:	85 c0                	test   %eax,%eax
8010713c:	74 52                	je     80107190 <setupkvm+0x60>
  memset(pgdir, 0, PGSIZE);
8010713e:	83 ec 04             	sub    $0x4,%esp
80107141:	89 c6                	mov    %eax,%esi
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107143:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80107148:	68 00 10 00 00       	push   $0x1000
8010714d:	6a 00                	push   $0x0
8010714f:	50                   	push   %eax
80107150:	e8 7b da ff ff       	call   80104bd0 <memset>
80107155:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0)
80107158:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010715b:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010715e:	83 ec 08             	sub    $0x8,%esp
80107161:	8b 13                	mov    (%ebx),%edx
80107163:	ff 73 0c             	pushl  0xc(%ebx)
80107166:	50                   	push   %eax
80107167:	29 c1                	sub    %eax,%ecx
80107169:	89 f0                	mov    %esi,%eax
8010716b:	e8 b0 fd ff ff       	call   80106f20 <mappages>
80107170:	83 c4 10             	add    $0x10,%esp
80107173:	85 c0                	test   %eax,%eax
80107175:	78 19                	js     80107190 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107177:	83 c3 10             	add    $0x10,%ebx
8010717a:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107180:	75 d6                	jne    80107158 <setupkvm+0x28>
}
80107182:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107185:	89 f0                	mov    %esi,%eax
80107187:	5b                   	pop    %ebx
80107188:	5e                   	pop    %esi
80107189:	5d                   	pop    %ebp
8010718a:	c3                   	ret    
8010718b:	90                   	nop
8010718c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107190:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
80107193:	31 f6                	xor    %esi,%esi
}
80107195:	89 f0                	mov    %esi,%eax
80107197:	5b                   	pop    %ebx
80107198:	5e                   	pop    %esi
80107199:	5d                   	pop    %ebp
8010719a:	c3                   	ret    
8010719b:	90                   	nop
8010719c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801071a0 <kvmalloc>:
{
801071a0:	55                   	push   %ebp
801071a1:	89 e5                	mov    %esp,%ebp
801071a3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801071a6:	e8 85 ff ff ff       	call   80107130 <setupkvm>
801071ab:	a3 64 7b 11 80       	mov    %eax,0x80117b64
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801071b0:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801071b5:	0f 22 d8             	mov    %eax,%cr3
}
801071b8:	c9                   	leave  
801071b9:	c3                   	ret    
801071ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801071c0 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801071c0:	a1 64 7b 11 80       	mov    0x80117b64,%eax
{
801071c5:	55                   	push   %ebp
801071c6:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801071c8:	05 00 00 00 80       	add    $0x80000000,%eax
801071cd:	0f 22 d8             	mov    %eax,%cr3
}
801071d0:	5d                   	pop    %ebp
801071d1:	c3                   	ret    
801071d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801071e0 <switchuvm>:
{
801071e0:	55                   	push   %ebp
801071e1:	89 e5                	mov    %esp,%ebp
801071e3:	53                   	push   %ebx
801071e4:	83 ec 04             	sub    $0x4,%esp
801071e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801071ea:	e8 11 d9 ff ff       	call   80104b00 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801071ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801071f5:	b9 67 00 00 00       	mov    $0x67,%ecx
801071fa:	8d 50 08             	lea    0x8(%eax),%edx
801071fd:	66 89 88 a0 00 00 00 	mov    %cx,0xa0(%eax)
80107204:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
8010720b:	89 d1                	mov    %edx,%ecx
8010720d:	c1 ea 18             	shr    $0x18,%edx
80107210:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
80107216:	ba 89 40 00 00       	mov    $0x4089,%edx
8010721b:	c1 e9 10             	shr    $0x10,%ecx
8010721e:	66 89 90 a5 00 00 00 	mov    %dx,0xa5(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107225:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010722c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107232:	b9 10 00 00 00       	mov    $0x10,%ecx
80107237:	66 89 48 10          	mov    %cx,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010723b:	8b 52 08             	mov    0x8(%edx),%edx
8010723e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107244:	89 50 0c             	mov    %edx,0xc(%eax)
  cpu->ts.iomb = (ushort) 0xFFFF;
80107247:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010724c:	66 89 50 6e          	mov    %dx,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80107250:	b8 30 00 00 00       	mov    $0x30,%eax
80107255:	0f 00 d8             	ltr    %ax
  if(p->pgdir == 0)
80107258:	8b 43 04             	mov    0x4(%ebx),%eax
8010725b:	85 c0                	test   %eax,%eax
8010725d:	74 11                	je     80107270 <switchuvm+0x90>
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010725f:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107264:	0f 22 d8             	mov    %eax,%cr3
}
80107267:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010726a:	c9                   	leave  
  popcli();
8010726b:	e9 c0 d8 ff ff       	jmp    80104b30 <popcli>
    panic("switchuvm: no pgdir");
80107270:	83 ec 0c             	sub    $0xc,%esp
80107273:	68 0a 83 10 80       	push   $0x8010830a
80107278:	e8 f3 90 ff ff       	call   80100370 <panic>
8010727d:	8d 76 00             	lea    0x0(%esi),%esi

80107280 <inituvm>:
{
80107280:	55                   	push   %ebp
80107281:	89 e5                	mov    %esp,%ebp
80107283:	57                   	push   %edi
80107284:	56                   	push   %esi
80107285:	53                   	push   %ebx
80107286:	83 ec 1c             	sub    $0x1c,%esp
80107289:	8b 75 10             	mov    0x10(%ebp),%esi
8010728c:	8b 45 08             	mov    0x8(%ebp),%eax
8010728f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(sz >= PGSIZE)
80107292:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
{
80107298:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
8010729b:	77 49                	ja     801072e6 <inituvm+0x66>
  mem = kalloc();
8010729d:	e8 1e b2 ff ff       	call   801024c0 <kalloc>
  memset(mem, 0, PGSIZE);
801072a2:	83 ec 04             	sub    $0x4,%esp
  mem = kalloc();
801072a5:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801072a7:	68 00 10 00 00       	push   $0x1000
801072ac:	6a 00                	push   $0x0
801072ae:	50                   	push   %eax
801072af:	e8 1c d9 ff ff       	call   80104bd0 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801072b4:	58                   	pop    %eax
801072b5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801072bb:	b9 00 10 00 00       	mov    $0x1000,%ecx
801072c0:	5a                   	pop    %edx
801072c1:	6a 06                	push   $0x6
801072c3:	50                   	push   %eax
801072c4:	31 d2                	xor    %edx,%edx
801072c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801072c9:	e8 52 fc ff ff       	call   80106f20 <mappages>
  memmove(mem, init, sz);
801072ce:	89 75 10             	mov    %esi,0x10(%ebp)
801072d1:	89 7d 0c             	mov    %edi,0xc(%ebp)
801072d4:	83 c4 10             	add    $0x10,%esp
801072d7:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801072da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801072dd:	5b                   	pop    %ebx
801072de:	5e                   	pop    %esi
801072df:	5f                   	pop    %edi
801072e0:	5d                   	pop    %ebp
  memmove(mem, init, sz);
801072e1:	e9 9a d9 ff ff       	jmp    80104c80 <memmove>
    panic("inituvm: more than a page");
801072e6:	83 ec 0c             	sub    $0xc,%esp
801072e9:	68 1e 83 10 80       	push   $0x8010831e
801072ee:	e8 7d 90 ff ff       	call   80100370 <panic>
801072f3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801072f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107300 <loaduvm>:
{
80107300:	55                   	push   %ebp
80107301:	89 e5                	mov    %esp,%ebp
80107303:	57                   	push   %edi
80107304:	56                   	push   %esi
80107305:	53                   	push   %ebx
80107306:	83 ec 0c             	sub    $0xc,%esp
  if((uint) addr % PGSIZE != 0)
80107309:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80107310:	0f 85 91 00 00 00    	jne    801073a7 <loaduvm+0xa7>
  for(i = 0; i < sz; i += PGSIZE){
80107316:	8b 75 18             	mov    0x18(%ebp),%esi
80107319:	31 db                	xor    %ebx,%ebx
8010731b:	85 f6                	test   %esi,%esi
8010731d:	75 1a                	jne    80107339 <loaduvm+0x39>
8010731f:	eb 6f                	jmp    80107390 <loaduvm+0x90>
80107321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107328:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010732e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
80107334:	39 5d 18             	cmp    %ebx,0x18(%ebp)
80107337:	76 57                	jbe    80107390 <loaduvm+0x90>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107339:	8b 55 0c             	mov    0xc(%ebp),%edx
8010733c:	8b 45 08             	mov    0x8(%ebp),%eax
8010733f:	31 c9                	xor    %ecx,%ecx
80107341:	01 da                	add    %ebx,%edx
80107343:	e8 58 fb ff ff       	call   80106ea0 <walkpgdir>
80107348:	85 c0                	test   %eax,%eax
8010734a:	74 4e                	je     8010739a <loaduvm+0x9a>
    pa = PTE_ADDR(*pte);
8010734c:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010734e:	8b 4d 14             	mov    0x14(%ebp),%ecx
    if(sz - i < PGSIZE)
80107351:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80107356:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010735b:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80107361:	0f 46 fe             	cmovbe %esi,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107364:	01 d9                	add    %ebx,%ecx
80107366:	05 00 00 00 80       	add    $0x80000000,%eax
8010736b:	57                   	push   %edi
8010736c:	51                   	push   %ecx
8010736d:	50                   	push   %eax
8010736e:	ff 75 10             	pushl  0x10(%ebp)
80107371:	e8 ba a5 ff ff       	call   80101930 <readi>
80107376:	83 c4 10             	add    $0x10,%esp
80107379:	39 f8                	cmp    %edi,%eax
8010737b:	74 ab                	je     80107328 <loaduvm+0x28>
}
8010737d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107380:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107385:	5b                   	pop    %ebx
80107386:	5e                   	pop    %esi
80107387:	5f                   	pop    %edi
80107388:	5d                   	pop    %ebp
80107389:	c3                   	ret    
8010738a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107390:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107393:	31 c0                	xor    %eax,%eax
}
80107395:	5b                   	pop    %ebx
80107396:	5e                   	pop    %esi
80107397:	5f                   	pop    %edi
80107398:	5d                   	pop    %ebp
80107399:	c3                   	ret    
      panic("loaduvm: address should exist");
8010739a:	83 ec 0c             	sub    $0xc,%esp
8010739d:	68 38 83 10 80       	push   $0x80108338
801073a2:	e8 c9 8f ff ff       	call   80100370 <panic>
    panic("loaduvm: addr must be page aligned");
801073a7:	83 ec 0c             	sub    $0xc,%esp
801073aa:	68 dc 83 10 80       	push   $0x801083dc
801073af:	e8 bc 8f ff ff       	call   80100370 <panic>
801073b4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801073ba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801073c0 <allocuvm>:
{
801073c0:	55                   	push   %ebp
801073c1:	89 e5                	mov    %esp,%ebp
801073c3:	57                   	push   %edi
801073c4:	56                   	push   %esi
801073c5:	53                   	push   %ebx
801073c6:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
801073c9:	8b 7d 10             	mov    0x10(%ebp),%edi
801073cc:	85 ff                	test   %edi,%edi
801073ce:	0f 88 8e 00 00 00    	js     80107462 <allocuvm+0xa2>
  if(newsz < oldsz)
801073d4:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801073d7:	0f 82 93 00 00 00    	jb     80107470 <allocuvm+0xb0>
  a = PGROUNDUP(oldsz);
801073dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801073e0:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801073e6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801073ec:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801073ef:	0f 86 7e 00 00 00    	jbe    80107473 <allocuvm+0xb3>
801073f5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801073f8:	8b 7d 08             	mov    0x8(%ebp),%edi
801073fb:	eb 42                	jmp    8010743f <allocuvm+0x7f>
801073fd:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
80107400:	83 ec 04             	sub    $0x4,%esp
80107403:	68 00 10 00 00       	push   $0x1000
80107408:	6a 00                	push   $0x0
8010740a:	50                   	push   %eax
8010740b:	e8 c0 d7 ff ff       	call   80104bd0 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107410:	58                   	pop    %eax
80107411:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80107417:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010741c:	5a                   	pop    %edx
8010741d:	6a 06                	push   $0x6
8010741f:	50                   	push   %eax
80107420:	89 da                	mov    %ebx,%edx
80107422:	89 f8                	mov    %edi,%eax
80107424:	e8 f7 fa ff ff       	call   80106f20 <mappages>
80107429:	83 c4 10             	add    $0x10,%esp
8010742c:	85 c0                	test   %eax,%eax
8010742e:	78 50                	js     80107480 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
80107430:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107436:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80107439:	0f 86 81 00 00 00    	jbe    801074c0 <allocuvm+0x100>
    mem = kalloc();
8010743f:	e8 7c b0 ff ff       	call   801024c0 <kalloc>
    if(mem == 0){
80107444:	85 c0                	test   %eax,%eax
    mem = kalloc();
80107446:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80107448:	75 b6                	jne    80107400 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
8010744a:	83 ec 0c             	sub    $0xc,%esp
8010744d:	68 56 83 10 80       	push   $0x80108356
80107452:	e8 e9 91 ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
80107457:	83 c4 10             	add    $0x10,%esp
8010745a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010745d:	39 45 10             	cmp    %eax,0x10(%ebp)
80107460:	77 6e                	ja     801074d0 <allocuvm+0x110>
}
80107462:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80107465:	31 ff                	xor    %edi,%edi
}
80107467:	89 f8                	mov    %edi,%eax
80107469:	5b                   	pop    %ebx
8010746a:	5e                   	pop    %esi
8010746b:	5f                   	pop    %edi
8010746c:	5d                   	pop    %ebp
8010746d:	c3                   	ret    
8010746e:	66 90                	xchg   %ax,%ax
    return oldsz;
80107470:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
80107473:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107476:	89 f8                	mov    %edi,%eax
80107478:	5b                   	pop    %ebx
80107479:	5e                   	pop    %esi
8010747a:	5f                   	pop    %edi
8010747b:	5d                   	pop    %ebp
8010747c:	c3                   	ret    
8010747d:	8d 76 00             	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
80107480:	83 ec 0c             	sub    $0xc,%esp
80107483:	68 6e 83 10 80       	push   $0x8010836e
80107488:	e8 b3 91 ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
8010748d:	83 c4 10             	add    $0x10,%esp
80107490:	8b 45 0c             	mov    0xc(%ebp),%eax
80107493:	39 45 10             	cmp    %eax,0x10(%ebp)
80107496:	76 0d                	jbe    801074a5 <allocuvm+0xe5>
80107498:	89 c1                	mov    %eax,%ecx
8010749a:	8b 55 10             	mov    0x10(%ebp),%edx
8010749d:	8b 45 08             	mov    0x8(%ebp),%eax
801074a0:	e8 0b fb ff ff       	call   80106fb0 <deallocuvm.part.0>
      kfree(mem);
801074a5:	83 ec 0c             	sub    $0xc,%esp
      return 0;
801074a8:	31 ff                	xor    %edi,%edi
      kfree(mem);
801074aa:	56                   	push   %esi
801074ab:	e8 60 ae ff ff       	call   80102310 <kfree>
      return 0;
801074b0:	83 c4 10             	add    $0x10,%esp
}
801074b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801074b6:	89 f8                	mov    %edi,%eax
801074b8:	5b                   	pop    %ebx
801074b9:	5e                   	pop    %esi
801074ba:	5f                   	pop    %edi
801074bb:	5d                   	pop    %ebp
801074bc:	c3                   	ret    
801074bd:	8d 76 00             	lea    0x0(%esi),%esi
801074c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801074c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801074c6:	5b                   	pop    %ebx
801074c7:	89 f8                	mov    %edi,%eax
801074c9:	5e                   	pop    %esi
801074ca:	5f                   	pop    %edi
801074cb:	5d                   	pop    %ebp
801074cc:	c3                   	ret    
801074cd:	8d 76 00             	lea    0x0(%esi),%esi
801074d0:	89 c1                	mov    %eax,%ecx
801074d2:	8b 55 10             	mov    0x10(%ebp),%edx
801074d5:	8b 45 08             	mov    0x8(%ebp),%eax
      return 0;
801074d8:	31 ff                	xor    %edi,%edi
801074da:	e8 d1 fa ff ff       	call   80106fb0 <deallocuvm.part.0>
801074df:	eb 92                	jmp    80107473 <allocuvm+0xb3>
801074e1:	eb 0d                	jmp    801074f0 <myallocuvm>
801074e3:	90                   	nop
801074e4:	90                   	nop
801074e5:	90                   	nop
801074e6:	90                   	nop
801074e7:	90                   	nop
801074e8:	90                   	nop
801074e9:	90                   	nop
801074ea:	90                   	nop
801074eb:	90                   	nop
801074ec:	90                   	nop
801074ed:	90                   	nop
801074ee:	90                   	nop
801074ef:	90                   	nop

801074f0 <myallocuvm>:
int myallocuvm(pde_t *pgdir,uint start, uint end){
801074f0:	55                   	push   %ebp
801074f1:	89 e5                	mov    %esp,%ebp
801074f3:	57                   	push   %edi
801074f4:	56                   	push   %esi
801074f5:	53                   	push   %ebx
801074f6:	83 ec 0c             	sub    $0xc,%esp
  a = PGROUNDUP(start);
801074f9:	8b 45 0c             	mov    0xc(%ebp),%eax
int myallocuvm(pde_t *pgdir,uint start, uint end){
801074fc:	8b 75 10             	mov    0x10(%ebp),%esi
  a = PGROUNDUP(start);
801074ff:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107505:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end; a += PGSIZE){
8010750b:	39 f3                	cmp    %esi,%ebx
8010750d:	73 3f                	jae    8010754e <myallocuvm+0x5e>
8010750f:	90                   	nop
    mem = kalloc();
80107510:	e8 ab af ff ff       	call   801024c0 <kalloc>
    memset(mem, 0 , PGSIZE);
80107515:	83 ec 04             	sub    $0x4,%esp
    mem = kalloc();
80107518:	89 c7                	mov    %eax,%edi
    memset(mem, 0 , PGSIZE);
8010751a:	68 00 10 00 00       	push   $0x1000
8010751f:	6a 00                	push   $0x0
80107521:	50                   	push   %eax
80107522:	e8 a9 d6 ff ff       	call   80104bd0 <memset>
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
80107527:	58                   	pop    %eax
80107528:	5a                   	pop    %edx
80107529:	8d 97 00 00 00 80    	lea    -0x80000000(%edi),%edx
8010752f:	8b 45 08             	mov    0x8(%ebp),%eax
80107532:	6a 06                	push   $0x6
80107534:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107539:	52                   	push   %edx
8010753a:	89 da                	mov    %ebx,%edx
  for(;a<end; a += PGSIZE){
8010753c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
80107542:	e8 d9 f9 ff ff       	call   80106f20 <mappages>
  for(;a<end; a += PGSIZE){
80107547:	83 c4 10             	add    $0x10,%esp
8010754a:	39 de                	cmp    %ebx,%esi
8010754c:	77 c2                	ja     80107510 <myallocuvm+0x20>
  return (end - start);
8010754e:	89 f0                	mov    %esi,%eax
80107550:	2b 45 0c             	sub    0xc(%ebp),%eax
}
80107553:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107556:	5b                   	pop    %ebx
80107557:	5e                   	pop    %esi
80107558:	5f                   	pop    %edi
80107559:	5d                   	pop    %ebp
8010755a:	c3                   	ret    
8010755b:	90                   	nop
8010755c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107560 <deallocuvm>:
{
80107560:	55                   	push   %ebp
80107561:	89 e5                	mov    %esp,%ebp
80107563:	8b 55 0c             	mov    0xc(%ebp),%edx
80107566:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107569:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
8010756c:	39 d1                	cmp    %edx,%ecx
8010756e:	73 10                	jae    80107580 <deallocuvm+0x20>
}
80107570:	5d                   	pop    %ebp
80107571:	e9 3a fa ff ff       	jmp    80106fb0 <deallocuvm.part.0>
80107576:	8d 76 00             	lea    0x0(%esi),%esi
80107579:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80107580:	89 d0                	mov    %edx,%eax
80107582:	5d                   	pop    %ebp
80107583:	c3                   	ret    
80107584:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010758a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107590 <mydeallocuvm>:

int mydeallocuvm(pde_t *pgdir,uint start,uint end){
80107590:	55                   	push   %ebp
80107591:	89 e5                	mov    %esp,%ebp
80107593:	57                   	push   %edi
80107594:	56                   	push   %esi
80107595:	53                   	push   %ebx
80107596:	83 ec 1c             	sub    $0x1c,%esp
  pte_t *pte;
  uint a,pa;
  a=PGROUNDUP(start);
80107599:	8b 45 0c             	mov    0xc(%ebp),%eax
int mydeallocuvm(pde_t *pgdir,uint start,uint end){
8010759c:	8b 75 10             	mov    0x10(%ebp),%esi
8010759f:	8b 7d 08             	mov    0x8(%ebp),%edi
  a=PGROUNDUP(start);
801075a2:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801075a8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end;a += PGSIZE){
801075ae:	39 f3                	cmp    %esi,%ebx
801075b0:	72 3d                	jb     801075ef <mydeallocuvm+0x5f>
801075b2:	eb 5a                	jmp    8010760e <mydeallocuvm+0x7e>
801075b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir,(char*)a,0);
    if(!pte){
      a += (NPDENTRIES-1)*PGSIZE;
    }else if((*pte & PTE_P)!=0){
801075b8:	8b 10                	mov    (%eax),%edx
801075ba:	f6 c2 01             	test   $0x1,%dl
801075bd:	74 26                	je     801075e5 <mydeallocuvm+0x55>
      pa=PTE_ADDR(*pte);
      if(pa == 0){
801075bf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801075c5:	74 54                	je     8010761b <mydeallocuvm+0x8b>
        panic("kfree");
      }
      char *v = P2V(pa);
      kfree(v);
801075c7:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
801075ca:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801075d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
801075d3:	52                   	push   %edx
801075d4:	e8 37 ad ff ff       	call   80102310 <kfree>
      *pte=0;
801075d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801075dc:	83 c4 10             	add    $0x10,%esp
801075df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(;a<end;a += PGSIZE){
801075e5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801075eb:	39 de                	cmp    %ebx,%esi
801075ed:	76 1f                	jbe    8010760e <mydeallocuvm+0x7e>
    pte = walkpgdir(pgdir,(char*)a,0);
801075ef:	31 c9                	xor    %ecx,%ecx
801075f1:	89 da                	mov    %ebx,%edx
801075f3:	89 f8                	mov    %edi,%eax
801075f5:	e8 a6 f8 ff ff       	call   80106ea0 <walkpgdir>
    if(!pte){
801075fa:	85 c0                	test   %eax,%eax
801075fc:	75 ba                	jne    801075b8 <mydeallocuvm+0x28>
      a += (NPDENTRIES-1)*PGSIZE;
801075fe:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(;a<end;a += PGSIZE){
80107604:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010760a:	39 de                	cmp    %ebx,%esi
8010760c:	77 e1                	ja     801075ef <mydeallocuvm+0x5f>
    }
  }
  return 1;
}
8010760e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107611:	b8 01 00 00 00       	mov    $0x1,%eax
80107616:	5b                   	pop    %ebx
80107617:	5e                   	pop    %esi
80107618:	5f                   	pop    %edi
80107619:	5d                   	pop    %ebp
8010761a:	c3                   	ret    
        panic("kfree");
8010761b:	83 ec 0c             	sub    $0xc,%esp
8010761e:	68 fa 7a 10 80       	push   $0x80107afa
80107623:	e8 48 8d ff ff       	call   80100370 <panic>
80107628:	90                   	nop
80107629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107630 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107630:	55                   	push   %ebp
80107631:	89 e5                	mov    %esp,%ebp
80107633:	57                   	push   %edi
80107634:	56                   	push   %esi
80107635:	53                   	push   %ebx
80107636:	83 ec 0c             	sub    $0xc,%esp
80107639:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010763c:	85 f6                	test   %esi,%esi
8010763e:	74 59                	je     80107699 <freevm+0x69>
80107640:	31 c9                	xor    %ecx,%ecx
80107642:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107647:	89 f0                	mov    %esi,%eax
80107649:	e8 62 f9 ff ff       	call   80106fb0 <deallocuvm.part.0>
8010764e:	89 f3                	mov    %esi,%ebx
80107650:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107656:	eb 0f                	jmp    80107667 <freevm+0x37>
80107658:	90                   	nop
80107659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107660:	83 c3 04             	add    $0x4,%ebx
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107663:	39 fb                	cmp    %edi,%ebx
80107665:	74 23                	je     8010768a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107667:	8b 03                	mov    (%ebx),%eax
80107669:	a8 01                	test   $0x1,%al
8010766b:	74 f3                	je     80107660 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010766d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107672:	83 ec 0c             	sub    $0xc,%esp
80107675:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107678:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010767d:	50                   	push   %eax
8010767e:	e8 8d ac ff ff       	call   80102310 <kfree>
80107683:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107686:	39 fb                	cmp    %edi,%ebx
80107688:	75 dd                	jne    80107667 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010768a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010768d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107690:	5b                   	pop    %ebx
80107691:	5e                   	pop    %esi
80107692:	5f                   	pop    %edi
80107693:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107694:	e9 77 ac ff ff       	jmp    80102310 <kfree>
    panic("freevm: no pgdir");
80107699:	83 ec 0c             	sub    $0xc,%esp
8010769c:	68 8a 83 10 80       	push   $0x8010838a
801076a1:	e8 ca 8c ff ff       	call   80100370 <panic>
801076a6:	8d 76 00             	lea    0x0(%esi),%esi
801076a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801076b0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801076b0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801076b1:	31 c9                	xor    %ecx,%ecx
{
801076b3:	89 e5                	mov    %esp,%ebp
801076b5:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
801076b8:	8b 55 0c             	mov    0xc(%ebp),%edx
801076bb:	8b 45 08             	mov    0x8(%ebp),%eax
801076be:	e8 dd f7 ff ff       	call   80106ea0 <walkpgdir>
  if(pte == 0)
801076c3:	85 c0                	test   %eax,%eax
801076c5:	74 05                	je     801076cc <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
801076c7:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801076ca:	c9                   	leave  
801076cb:	c3                   	ret    
    panic("clearpteu");
801076cc:	83 ec 0c             	sub    $0xc,%esp
801076cf:	68 9b 83 10 80       	push   $0x8010839b
801076d4:	e8 97 8c ff ff       	call   80100370 <panic>
801076d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801076e0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801076e0:	55                   	push   %ebp
801076e1:	89 e5                	mov    %esp,%ebp
801076e3:	57                   	push   %edi
801076e4:	56                   	push   %esi
801076e5:	53                   	push   %ebx
801076e6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801076e9:	e8 42 fa ff ff       	call   80107130 <setupkvm>
801076ee:	85 c0                	test   %eax,%eax
801076f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801076f3:	0f 84 a0 00 00 00    	je     80107799 <copyuvm+0xb9>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801076f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801076fc:	85 c9                	test   %ecx,%ecx
801076fe:	0f 84 95 00 00 00    	je     80107799 <copyuvm+0xb9>
80107704:	31 f6                	xor    %esi,%esi
80107706:	eb 4e                	jmp    80107756 <copyuvm+0x76>
80107708:	90                   	nop
80107709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107710:	83 ec 04             	sub    $0x4,%esp
80107713:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80107719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010771c:	68 00 10 00 00       	push   $0x1000
80107721:	57                   	push   %edi
80107722:	50                   	push   %eax
80107723:	e8 58 d5 ff ff       	call   80104c80 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107728:	58                   	pop    %eax
80107729:	5a                   	pop    %edx
8010772a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010772d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107730:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107735:	53                   	push   %ebx
80107736:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010773c:	52                   	push   %edx
8010773d:	89 f2                	mov    %esi,%edx
8010773f:	e8 dc f7 ff ff       	call   80106f20 <mappages>
80107744:	83 c4 10             	add    $0x10,%esp
80107747:	85 c0                	test   %eax,%eax
80107749:	78 39                	js     80107784 <copyuvm+0xa4>
  for(i = 0; i < sz; i += PGSIZE){
8010774b:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107751:	39 75 0c             	cmp    %esi,0xc(%ebp)
80107754:	76 43                	jbe    80107799 <copyuvm+0xb9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107756:	8b 45 08             	mov    0x8(%ebp),%eax
80107759:	31 c9                	xor    %ecx,%ecx
8010775b:	89 f2                	mov    %esi,%edx
8010775d:	e8 3e f7 ff ff       	call   80106ea0 <walkpgdir>
80107762:	85 c0                	test   %eax,%eax
80107764:	74 3e                	je     801077a4 <copyuvm+0xc4>
    if(!(*pte & PTE_P))
80107766:	8b 18                	mov    (%eax),%ebx
80107768:	f6 c3 01             	test   $0x1,%bl
8010776b:	74 44                	je     801077b1 <copyuvm+0xd1>
    pa = PTE_ADDR(*pte);
8010776d:	89 df                	mov    %ebx,%edi
    flags = PTE_FLAGS(*pte);
8010776f:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    pa = PTE_ADDR(*pte);
80107775:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
8010777b:	e8 40 ad ff ff       	call   801024c0 <kalloc>
80107780:	85 c0                	test   %eax,%eax
80107782:	75 8c                	jne    80107710 <copyuvm+0x30>
      goto bad;
  }
  return d;

bad:
  freevm(d);
80107784:	83 ec 0c             	sub    $0xc,%esp
80107787:	ff 75 e0             	pushl  -0x20(%ebp)
8010778a:	e8 a1 fe ff ff       	call   80107630 <freevm>
  return 0;
8010778f:	83 c4 10             	add    $0x10,%esp
80107792:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
}
80107799:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010779c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010779f:	5b                   	pop    %ebx
801077a0:	5e                   	pop    %esi
801077a1:	5f                   	pop    %edi
801077a2:	5d                   	pop    %ebp
801077a3:	c3                   	ret    
      panic("copyuvm: pte should exist");
801077a4:	83 ec 0c             	sub    $0xc,%esp
801077a7:	68 a5 83 10 80       	push   $0x801083a5
801077ac:	e8 bf 8b ff ff       	call   80100370 <panic>
      panic("copyuvm: page not present");
801077b1:	83 ec 0c             	sub    $0xc,%esp
801077b4:	68 bf 83 10 80       	push   $0x801083bf
801077b9:	e8 b2 8b ff ff       	call   80100370 <panic>
801077be:	66 90                	xchg   %ax,%ax

801077c0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801077c0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801077c1:	31 c9                	xor    %ecx,%ecx
{
801077c3:	89 e5                	mov    %esp,%ebp
801077c5:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
801077c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801077cb:	8b 45 08             	mov    0x8(%ebp),%eax
801077ce:	e8 cd f6 ff ff       	call   80106ea0 <walkpgdir>
  if((*pte & PTE_P) == 0)
801077d3:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
801077d5:	c9                   	leave  
  if((*pte & PTE_U) == 0)
801077d6:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
801077d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
801077dd:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
801077e0:	05 00 00 00 80       	add    $0x80000000,%eax
801077e5:	83 fa 05             	cmp    $0x5,%edx
801077e8:	ba 00 00 00 00       	mov    $0x0,%edx
801077ed:	0f 45 c2             	cmovne %edx,%eax
}
801077f0:	c3                   	ret    
801077f1:	eb 0d                	jmp    80107800 <copyout>
801077f3:	90                   	nop
801077f4:	90                   	nop
801077f5:	90                   	nop
801077f6:	90                   	nop
801077f7:	90                   	nop
801077f8:	90                   	nop
801077f9:	90                   	nop
801077fa:	90                   	nop
801077fb:	90                   	nop
801077fc:	90                   	nop
801077fd:	90                   	nop
801077fe:	90                   	nop
801077ff:	90                   	nop

80107800 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107800:	55                   	push   %ebp
80107801:	89 e5                	mov    %esp,%ebp
80107803:	57                   	push   %edi
80107804:	56                   	push   %esi
80107805:	53                   	push   %ebx
80107806:	83 ec 1c             	sub    $0x1c,%esp
80107809:	8b 5d 14             	mov    0x14(%ebp),%ebx
8010780c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010780f:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107812:	85 db                	test   %ebx,%ebx
80107814:	75 40                	jne    80107856 <copyout+0x56>
80107816:	eb 70                	jmp    80107888 <copyout+0x88>
80107818:	90                   	nop
80107819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80107820:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107823:	89 f1                	mov    %esi,%ecx
80107825:	29 d1                	sub    %edx,%ecx
80107827:	81 c1 00 10 00 00    	add    $0x1000,%ecx
8010782d:	39 d9                	cmp    %ebx,%ecx
8010782f:	0f 47 cb             	cmova  %ebx,%ecx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107832:	29 f2                	sub    %esi,%edx
80107834:	83 ec 04             	sub    $0x4,%esp
80107837:	01 d0                	add    %edx,%eax
80107839:	51                   	push   %ecx
8010783a:	57                   	push   %edi
8010783b:	50                   	push   %eax
8010783c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010783f:	e8 3c d4 ff ff       	call   80104c80 <memmove>
    len -= n;
    buf += n;
80107844:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  while(len > 0){
80107847:	83 c4 10             	add    $0x10,%esp
    va = va0 + PGSIZE;
8010784a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
    buf += n;
80107850:	01 cf                	add    %ecx,%edi
  while(len > 0){
80107852:	29 cb                	sub    %ecx,%ebx
80107854:	74 32                	je     80107888 <copyout+0x88>
    va0 = (uint)PGROUNDDOWN(va);
80107856:	89 d6                	mov    %edx,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107858:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
8010785b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010785e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107864:	56                   	push   %esi
80107865:	ff 75 08             	pushl  0x8(%ebp)
80107868:	e8 53 ff ff ff       	call   801077c0 <uva2ka>
    if(pa0 == 0)
8010786d:	83 c4 10             	add    $0x10,%esp
80107870:	85 c0                	test   %eax,%eax
80107872:	75 ac                	jne    80107820 <copyout+0x20>
  }
  return 0;
}
80107874:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010787c:	5b                   	pop    %ebx
8010787d:	5e                   	pop    %esi
8010787e:	5f                   	pop    %edi
8010787f:	5d                   	pop    %ebp
80107880:	c3                   	ret    
80107881:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107888:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010788b:	31 c0                	xor    %eax,%eax
}
8010788d:	5b                   	pop    %ebx
8010788e:	5e                   	pop    %esi
8010788f:	5f                   	pop    %edi
80107890:	5d                   	pop    %ebp
80107891:	c3                   	ret    
