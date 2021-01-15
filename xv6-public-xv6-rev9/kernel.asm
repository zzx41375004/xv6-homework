
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
80100046:	68 20 79 10 80       	push   $0x80107920
8010004b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100050:	e8 bb 49 00 00       	call   80104a10 <initlock>

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
801000d4:	e8 57 49 00 00       	call   80104a30 <acquire>
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
80100114:	e8 77 3f 00 00       	call   80104090 <sleep>
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
80100154:	e8 97 4a 00 00       	call   80104bf0 <release>
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
80100184:	e8 67 4a 00 00       	call   80104bf0 <release>
80100189:	83 c4 10             	add    $0x10,%esp
8010018c:	eb ce                	jmp    8010015c <bread+0x9c>
  panic("bget: no buffers");
8010018e:	83 ec 0c             	sub    $0xc,%esp
80100191:	68 27 79 10 80       	push   $0x80107927
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
801001bd:	68 38 79 10 80       	push   $0x80107938
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
801001e7:	e8 44 48 00 00       	call   80104a30 <acquire>

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
80100221:	e8 5a 40 00 00       	call   80104280 <wakeup>

  release(&bcache.lock);
80100226:	83 c4 10             	add    $0x10,%esp
80100229:	c7 45 08 e0 c5 10 80 	movl   $0x8010c5e0,0x8(%ebp)
}
80100230:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100233:	c9                   	leave  
  release(&bcache.lock);
80100234:	e9 b7 49 00 00       	jmp    80104bf0 <release>
    panic("brelse");
80100239:	83 ec 0c             	sub    $0xc,%esp
8010023c:	68 3f 79 10 80       	push   $0x8010793f
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
8010026c:	e8 bf 47 00 00       	call   80104a30 <acquire>
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
801002a5:	e8 e6 3d 00 00       	call   80104090 <sleep>
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
801002d0:	e8 1b 49 00 00       	call   80104bf0 <release>
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
8010032d:	e8 be 48 00 00       	call   80104bf0 <release>
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
80100393:	68 46 79 10 80       	push   $0x80107946
80100398:	e8 a3 02 00 00       	call   80100640 <cprintf>
  cprintf(s);
8010039d:	58                   	pop    %eax
8010039e:	ff 75 08             	pushl  0x8(%ebp)
801003a1:	e8 9a 02 00 00       	call   80100640 <cprintf>
  cprintf("\n");
801003a6:	c7 04 24 b0 7f 10 80 	movl   $0x80107fb0,(%esp)
801003ad:	e8 8e 02 00 00       	call   80100640 <cprintf>
  getcallerpcs(&s, pcs);
801003b2:	5a                   	pop    %edx
801003b3:	8d 45 08             	lea    0x8(%ebp),%eax
801003b6:	59                   	pop    %ecx
801003b7:	53                   	push   %ebx
801003b8:	50                   	push   %eax
801003b9:	e8 32 47 00 00       	call   80104af0 <getcallerpcs>
801003be:	83 c4 10             	add    $0x10,%esp
801003c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf(" %p", pcs[i]);
801003c8:	83 ec 08             	sub    $0x8,%esp
801003cb:	ff 33                	pushl  (%ebx)
801003cd:	83 c3 04             	add    $0x4,%ebx
801003d0:	68 62 79 10 80       	push   $0x80107962
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
8010041a:	e8 31 60 00 00       	call   80106450 <uartputc>
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
801004cc:	e8 7f 5f 00 00       	call   80106450 <uartputc>
801004d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004d8:	e8 73 5f 00 00       	call   80106450 <uartputc>
801004dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004e4:	e8 67 5f 00 00       	call   80106450 <uartputc>
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
80100504:	e8 e7 47 00 00       	call   80104cf0 <memmove>
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
80100521:	e8 1a 47 00 00       	call   80104c40 <memset>
80100526:	83 c4 10             	add    $0x10,%esp
80100529:	e9 5d ff ff ff       	jmp    8010048b <consputc+0x9b>
    panic("pos under/overflow");
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	68 66 79 10 80       	push   $0x80107966
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
80100591:	0f b6 92 94 79 10 80 	movzbl -0x7fef866c(%edx),%edx
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
801005fb:	e8 30 44 00 00       	call   80104a30 <acquire>
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
80100627:	e8 c4 45 00 00       	call   80104bf0 <release>
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
801006ff:	e8 ec 44 00 00       	call   80104bf0 <release>
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
801007b0:	ba 79 79 10 80       	mov    $0x80107979,%edx
      for(; *s; s++)
801007b5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801007b8:	b8 28 00 00 00       	mov    $0x28,%eax
801007bd:	89 d3                	mov    %edx,%ebx
801007bf:	eb bf                	jmp    80100780 <cprintf+0x140>
801007c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    acquire(&cons.lock);
801007c8:	83 ec 0c             	sub    $0xc,%esp
801007cb:	68 20 b5 10 80       	push   $0x8010b520
801007d0:	e8 5b 42 00 00       	call   80104a30 <acquire>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	e9 7c fe ff ff       	jmp    80100659 <cprintf+0x19>
    panic("null fmt");
801007dd:	83 ec 0c             	sub    $0xc,%esp
801007e0:	68 80 79 10 80       	push   $0x80107980
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
80100803:	e8 28 42 00 00       	call   80104a30 <acquire>
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
80100868:	e8 83 43 00 00       	call   80104bf0 <release>
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
801008f6:	e8 85 39 00 00       	call   80104280 <wakeup>
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
80100977:	e9 e4 39 00 00       	jmp    80104360 <procdump>
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
801009a6:	68 89 79 10 80       	push   $0x80107989
801009ab:	68 20 b5 10 80       	push   $0x8010b520
801009b0:	e8 5b 40 00 00       	call   80104a10 <initlock>

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
80100a6c:	e8 2f 67 00 00       	call   801071a0 <setupkvm>
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
80100ace:	e8 5d 69 00 00       	call   80107430 <allocuvm>
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
80100b00:	e8 6b 68 00 00       	call   80107370 <loaduvm>
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
80100b4a:	e8 51 6b 00 00       	call   801076a0 <freevm>
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
80100b8b:	e8 a0 68 00 00       	call   80107430 <allocuvm>
80100b90:	83 c4 10             	add    $0x10,%esp
80100b93:	85 c0                	test   %eax,%eax
80100b95:	89 c6                	mov    %eax,%esi
80100b97:	75 2a                	jne    80100bc3 <exec+0x1d3>
    freevm(pgdir);
80100b99:	83 ec 0c             	sub    $0xc,%esp
80100b9c:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100ba2:	e8 f9 6a 00 00       	call   801076a0 <freevm>
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
80100bd7:	e8 44 6b 00 00       	call   80107720 <clearpteu>
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
80100c09:	e8 52 42 00 00       	call   80104e60 <strlen>
80100c0e:	f7 d0                	not    %eax
80100c10:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c12:	58                   	pop    %eax
80100c13:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100c16:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c19:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c1c:	e8 3f 42 00 00       	call   80104e60 <strlen>
80100c21:	83 c0 01             	add    $0x1,%eax
80100c24:	50                   	push   %eax
80100c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c28:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c2b:	53                   	push   %ebx
80100c2c:	56                   	push   %esi
80100c2d:	e8 3e 6c 00 00       	call   80107870 <copyout>
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
80100c97:	e8 d4 6b 00 00       	call   80107870 <copyout>
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
80100cd7:	e8 44 41 00 00       	call   80104e20 <safestrcpy>
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
80100d0b:	e8 40 65 00 00       	call   80107250 <switchuvm>
  freevm(oldpgdir);
80100d10:	89 3c 24             	mov    %edi,(%esp)
80100d13:	e8 88 69 00 00       	call   801076a0 <freevm>
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
80100d36:	68 a5 79 10 80       	push   $0x801079a5
80100d3b:	68 a0 07 11 80       	push   $0x801107a0
80100d40:	e8 cb 3c 00 00       	call   80104a10 <initlock>
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
80100d61:	e8 ca 3c 00 00       	call   80104a30 <acquire>
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
80100d91:	e8 5a 3e 00 00       	call   80104bf0 <release>
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
80100daa:	e8 41 3e 00 00       	call   80104bf0 <release>
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
80100dcf:	e8 5c 3c 00 00       	call   80104a30 <acquire>
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
80100dec:	e8 ff 3d 00 00       	call   80104bf0 <release>
  return f;
}
80100df1:	89 d8                	mov    %ebx,%eax
80100df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100df6:	c9                   	leave  
80100df7:	c3                   	ret    
    panic("filedup");
80100df8:	83 ec 0c             	sub    $0xc,%esp
80100dfb:	68 ac 79 10 80       	push   $0x801079ac
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
80100e21:	e8 0a 3c 00 00       	call   80104a30 <acquire>
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
80100e4c:	e9 9f 3d 00 00       	jmp    80104bf0 <release>
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
80100e78:	e8 73 3d 00 00       	call   80104bf0 <release>
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
80100ed2:	68 b4 79 10 80       	push   $0x801079b4
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
80100fb2:	68 be 79 10 80       	push   $0x801079be
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
801010c5:	68 c7 79 10 80       	push   $0x801079c7
801010ca:	e8 a1 f2 ff ff       	call   80100370 <panic>
  panic("filewrite");
801010cf:	83 ec 0c             	sub    $0xc,%esp
801010d2:	68 cd 79 10 80       	push   $0x801079cd
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
80101184:	68 d7 79 10 80       	push   $0x801079d7
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
801011c5:	e8 76 3a 00 00       	call   80104c40 <memset>
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
8010120a:	e8 21 38 00 00       	call   80104a30 <acquire>
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
80101269:	e8 82 39 00 00       	call   80104bf0 <release>

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
80101295:	e8 56 39 00 00       	call   80104bf0 <release>
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
801012aa:	68 ed 79 10 80       	push   $0x801079ed
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
80101371:	68 fd 79 10 80       	push   $0x801079fd
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
801013a1:	e8 4a 39 00 00       	call   80104cf0 <memmove>
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
80101434:	68 10 7a 10 80       	push   $0x80107a10
80101439:	e8 32 ef ff ff       	call   80100370 <panic>
8010143e:	66 90                	xchg   %ax,%ax

80101440 <iinit>:
{
80101440:	55                   	push   %ebp
80101441:	89 e5                	mov    %esp,%ebp
80101443:	83 ec 10             	sub    $0x10,%esp
  initlock(&icache.lock, "icache");
80101446:	68 23 7a 10 80       	push   $0x80107a23
8010144b:	68 c0 11 11 80       	push   $0x801111c0
80101450:	e8 bb 35 00 00       	call   80104a10 <initlock>
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
8010148e:	68 84 7a 10 80       	push   $0x80107a84
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
8010151e:	e8 1d 37 00 00       	call   80104c40 <memset>
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
80101553:	68 2a 7a 10 80       	push   $0x80107a2a
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
801015c1:	e8 2a 37 00 00       	call   80104cf0 <memmove>
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
801015ef:	e8 3c 34 00 00       	call   80104a30 <acquire>
  ip->ref++;
801015f4:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801015f8:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
801015ff:	e8 ec 35 00 00       	call   80104bf0 <release>
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
80101633:	e8 f8 33 00 00       	call   80104a30 <acquire>
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
80101651:	e8 3a 2a 00 00       	call   80104090 <sleep>
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
8010166e:	e8 7d 35 00 00       	call   80104bf0 <release>
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
801016e0:	e8 0b 36 00 00       	call   80104cf0 <memmove>
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
801016fe:	68 42 7a 10 80       	push   $0x80107a42
80101703:	e8 68 ec ff ff       	call   80100370 <panic>
    panic("ilock");
80101708:	83 ec 0c             	sub    $0xc,%esp
8010170b:	68 3c 7a 10 80       	push   $0x80107a3c
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
80101743:	e8 e8 32 00 00       	call   80104a30 <acquire>
  ip->flags &= ~I_BUSY;
80101748:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
8010174c:	89 1c 24             	mov    %ebx,(%esp)
8010174f:	e8 2c 2b 00 00       	call   80104280 <wakeup>
  release(&icache.lock);
80101754:	83 c4 10             	add    $0x10,%esp
80101757:	c7 45 08 c0 11 11 80 	movl   $0x801111c0,0x8(%ebp)
}
8010175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101761:	c9                   	leave  
  release(&icache.lock);
80101762:	e9 89 34 00 00       	jmp    80104bf0 <release>
    panic("iunlock");
80101767:	83 ec 0c             	sub    $0xc,%esp
8010176a:	68 51 7a 10 80       	push   $0x80107a51
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
80101791:	e8 9a 32 00 00       	call   80104a30 <acquire>
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
801017d9:	e8 12 34 00 00       	call   80104bf0 <release>
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
80101836:	e8 f5 31 00 00       	call   80104a30 <acquire>
    ip->flags = 0;
8010183b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
80101842:	89 34 24             	mov    %esi,(%esp)
80101845:	e8 36 2a 00 00       	call   80104280 <wakeup>
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
80101864:	e9 87 33 00 00       	jmp    80104bf0 <release>
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
801018cd:	68 59 7a 10 80       	push   $0x80107a59
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
801019d7:	e8 14 33 00 00       	call   80104cf0 <memmove>
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
80101ad3:	e8 18 32 00 00       	call   80104cf0 <memmove>
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
80101b6e:	e8 ed 31 00 00       	call   80104d60 <strncmp>
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
80101bcd:	e8 8e 31 00 00       	call   80104d60 <strncmp>
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
80101c12:	68 75 7a 10 80       	push   $0x80107a75
80101c17:	e8 54 e7 ff ff       	call   80100370 <panic>
    panic("dirlookup not DIR");
80101c1c:	83 ec 0c             	sub    $0xc,%esp
80101c1f:	68 63 7a 10 80       	push   $0x80107a63
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
80101c5d:	e8 ce 2d 00 00       	call   80104a30 <acquire>
  ip->ref++;
80101c62:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101c66:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
80101c6d:	e8 7e 2f 00 00       	call   80104bf0 <release>
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
80101cd5:	e8 16 30 00 00       	call   80104cf0 <memmove>
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
80101d68:	e8 83 2f 00 00       	call   80104cf0 <memmove>
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
80101e5d:	e8 5e 2f 00 00       	call   80104dc0 <strncpy>
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
80101e9b:	68 75 7a 10 80       	push   $0x80107a75
80101ea0:	e8 cb e4 ff ff       	call   80100370 <panic>
    panic("dirlink");
80101ea5:	83 ec 0c             	sub    $0xc,%esp
80101ea8:	68 3a 82 10 80       	push   $0x8010823a
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
80101fbb:	68 e9 7a 10 80       	push   $0x80107ae9
80101fc0:	e8 ab e3 ff ff       	call   80100370 <panic>
    panic("idestart");
80101fc5:	83 ec 0c             	sub    $0xc,%esp
80101fc8:	68 e0 7a 10 80       	push   $0x80107ae0
80101fcd:	e8 9e e3 ff ff       	call   80100370 <panic>
80101fd2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101fd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101fe0 <ideinit>:
{
80101fe0:	55                   	push   %ebp
80101fe1:	89 e5                	mov    %esp,%ebp
80101fe3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101fe6:	68 fb 7a 10 80       	push   $0x80107afb
80101feb:	68 80 b5 10 80       	push   $0x8010b580
80101ff0:	e8 1b 2a 00 00       	call   80104a10 <initlock>
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
8010207e:	e8 ad 29 00 00       	call   80104a30 <acquire>
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
801020e1:	e8 9a 21 00 00       	call   80104280 <wakeup>

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
801020ff:	e8 ec 2a 00 00       	call   80104bf0 <release>

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
8010214c:	e8 df 28 00 00       	call   80104a30 <acquire>

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
80102199:	e8 f2 1e 00 00       	call   80104090 <sleep>
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
801021b6:	e9 35 2a 00 00       	jmp    80104bf0 <release>
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
801021da:	68 13 7b 10 80       	push   $0x80107b13
801021df:	e8 8c e1 ff ff       	call   80100370 <panic>
    panic("iderw: buf not busy");
801021e4:	83 ec 0c             	sub    $0xc,%esp
801021e7:	68 ff 7a 10 80       	push   $0x80107aff
801021ec:	e8 7f e1 ff ff       	call   80100370 <panic>
    panic("iderw: ide disk 1 not present");
801021f1:	83 ec 0c             	sub    $0xc,%esp
801021f4:	68 28 7b 10 80       	push   $0x80107b28
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
801022a3:	68 48 7b 10 80       	push   $0x80107b48
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
80102342:	e8 f9 28 00 00       	call   80104c40 <memset>

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
8010237b:	e9 70 28 00 00       	jmp    80104bf0 <release>
    acquire(&kmem.lock);
80102380:	83 ec 0c             	sub    $0xc,%esp
80102383:	68 a0 21 11 80       	push   $0x801121a0
80102388:	e8 a3 26 00 00       	call   80104a30 <acquire>
8010238d:	83 c4 10             	add    $0x10,%esp
80102390:	eb c2                	jmp    80102354 <kfree+0x44>
    panic("kfree");
80102392:	83 ec 0c             	sub    $0xc,%esp
80102395:	68 7a 7b 10 80       	push   $0x80107b7a
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
801023fb:	68 80 7b 10 80       	push   $0x80107b80
80102400:	68 a0 21 11 80       	push   $0x801121a0
80102405:	e8 06 26 00 00       	call   80104a10 <initlock>
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
801024f3:	e8 38 25 00 00       	call   80104a30 <acquire>
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
80102521:	e8 ca 26 00 00       	call   80104bf0 <release>
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
80102573:	0f b6 82 c0 7c 10 80 	movzbl -0x7fef8340(%edx),%eax
8010257a:	09 c1                	or     %eax,%ecx
  shift ^= togglecode[data];
8010257c:	0f b6 82 c0 7b 10 80 	movzbl -0x7fef8440(%edx),%eax
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
80102593:	8b 04 85 a0 7b 10 80 	mov    -0x7fef8460(,%eax,4),%eax
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
801025b8:	0f b6 82 c0 7c 10 80 	movzbl -0x7fef8340(%edx),%eax
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
801027b6:	68 c0 7d 10 80       	push   $0x80107dc0
801027bb:	e8 80 de ff ff       	call   80100640 <cprintf>
801027c0:	83 c4 10             	add    $0x10,%esp
801027c3:	eb 89                	jmp    8010274e <cpunum+0x1e>
  panic("unknown apicid\n");
801027c5:	83 ec 0c             	sub    $0xc,%esp
801027c8:	68 ec 7d 10 80       	push   $0x80107dec
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
801029c7:	e8 c4 22 00 00       	call   80104c90 <memcmp>
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
80102af4:	e8 f7 21 00 00       	call   80104cf0 <memmove>
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
80102b9a:	68 fc 7d 10 80       	push   $0x80107dfc
80102b9f:	68 e0 21 11 80       	push   $0x801121e0
80102ba4:	e8 67 1e 00 00       	call   80104a10 <initlock>
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
80102c3b:	e8 f0 1d 00 00       	call   80104a30 <acquire>
80102c40:	83 c4 10             	add    $0x10,%esp
80102c43:	eb 18                	jmp    80102c5d <begin_op+0x2d>
80102c45:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102c48:	83 ec 08             	sub    $0x8,%esp
80102c4b:	68 e0 21 11 80       	push   $0x801121e0
80102c50:	68 e0 21 11 80       	push   $0x801121e0
80102c55:	e8 36 14 00 00       	call   80104090 <sleep>
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
80102c8c:	e8 5f 1f 00 00       	call   80104bf0 <release>
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
80102cae:	e8 7d 1d 00 00       	call   80104a30 <acquire>
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
80102cec:	e8 ff 1e 00 00       	call   80104bf0 <release>
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
80102d46:	e8 a5 1f 00 00       	call   80104cf0 <memmove>
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
80102d8f:	e8 9c 1c 00 00       	call   80104a30 <acquire>
    wakeup(&log);
80102d94:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
    log.committing = 0;
80102d9b:	c7 05 20 22 11 80 00 	movl   $0x0,0x80112220
80102da2:	00 00 00 
    wakeup(&log);
80102da5:	e8 d6 14 00 00       	call   80104280 <wakeup>
    release(&log.lock);
80102daa:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102db1:	e8 3a 1e 00 00       	call   80104bf0 <release>
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
80102dd0:	e8 ab 14 00 00       	call   80104280 <wakeup>
  release(&log.lock);
80102dd5:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102ddc:	e8 0f 1e 00 00       	call   80104bf0 <release>
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
80102def:	68 00 7e 10 80       	push   $0x80107e00
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
80102e3e:	e8 ed 1b 00 00       	call   80104a30 <acquire>
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
80102e8d:	e9 5e 1d 00 00       	jmp    80104bf0 <release>
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
80102eb9:	68 0f 7e 10 80       	push   $0x80107e0f
80102ebe:	e8 ad d4 ff ff       	call   80100370 <panic>
    panic("log_write outside of trans");
80102ec3:	83 ec 0c             	sub    $0xc,%esp
80102ec6:	68 25 7e 10 80       	push   $0x80107e25
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
80102ee2:	68 40 7e 10 80       	push   $0x80107e40
80102ee7:	e8 54 d7 ff ff       	call   80100640 <cprintf>
  idtinit();       // load idt register
80102eec:	e8 af 31 00 00       	call   801060a0 <idtinit>
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
80102f16:	e8 15 43 00 00       	call   80107230 <switchkvm>
  seginit();
80102f1b:	e8 a0 41 00 00       	call   801070c0 <seginit>
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
80102f51:	e8 ba 42 00 00       	call   80107210 <kvmalloc>
  mpinit();        // detect other processors
80102f56:	e8 b5 01 00 00       	call   80103110 <mpinit>
  lapicinit();     // interrupt controller
80102f5b:	e8 d0 f6 ff ff       	call   80102630 <lapicinit>
  seginit();       // segment descriptors
80102f60:	e8 5b 41 00 00       	call   801070c0 <seginit>
  cprintf("\ncpu%d: starting xv6\n----------------------------\nzzx is programming xv6\n----------------------------\n", cpunum());
80102f65:	e8 c6 f7 ff ff       	call   80102730 <cpunum>
80102f6a:	5a                   	pop    %edx
80102f6b:	59                   	pop    %ecx
80102f6c:	50                   	push   %eax
80102f6d:	68 54 7e 10 80       	push   $0x80107e54
80102f72:	e8 c9 d6 ff ff       	call   80100640 <cprintf>
  picinit();       // another interrupt controller
80102f77:	e8 b4 03 00 00       	call   80103330 <picinit>
  ioapicinit();    // another interrupt controller
80102f7c:	e8 7f f2 ff ff       	call   80102200 <ioapicinit>
  consoleinit();   // console hardware
80102f81:	e8 1a da ff ff       	call   801009a0 <consoleinit>
  uartinit();      // serial port
80102f86:	e8 05 34 00 00       	call   80106390 <uartinit>
  pinit();         // process table
80102f8b:	e8 c0 09 00 00       	call   80103950 <pinit>
  tvinit();        // trap vectors
80102f90:	e8 8b 30 00 00       	call   80106020 <tvinit>
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
80102fc7:	e8 24 1d 00 00       	call   80104cf0 <memmove>

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
8010307f:	e8 3c 2f 00 00       	call   80105fc0 <timerinit>
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
801030be:	68 bb 7e 10 80       	push   $0x80107ebb
801030c3:	56                   	push   %esi
801030c4:	e8 c7 1b 00 00       	call   80104c90 <memcmp>
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
80103178:	68 c0 7e 10 80       	push   $0x80107ec0
8010317d:	56                   	push   %esi
8010317e:	e8 0d 1b 00 00       	call   80104c90 <memcmp>
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
8010321c:	ff 24 95 c8 7e 10 80 	jmp    *-0x7fef8138(,%edx,4)
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
8010348b:	68 dc 7e 10 80       	push   $0x80107edc
80103490:	50                   	push   %eax
80103491:	e8 7a 15 00 00       	call   80104a10 <initlock>
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
801034ef:	e8 3c 15 00 00       	call   80104a30 <acquire>
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
8010350f:	e8 6c 0d 00 00       	call   80104280 <wakeup>
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
80103534:	e9 b7 16 00 00       	jmp    80104bf0 <release>
80103539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&p->nwrite);
80103540:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103546:	83 ec 0c             	sub    $0xc,%esp
    p->readopen = 0;
80103549:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103550:	00 00 00 
    wakeup(&p->nwrite);
80103553:	50                   	push   %eax
80103554:	e8 27 0d 00 00       	call   80104280 <wakeup>
80103559:	83 c4 10             	add    $0x10,%esp
8010355c:	eb b9                	jmp    80103517 <pipeclose+0x37>
8010355e:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80103560:	83 ec 0c             	sub    $0xc,%esp
80103563:	53                   	push   %ebx
80103564:	e8 87 16 00 00       	call   80104bf0 <release>
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
8010358d:	e8 9e 14 00 00       	call   80104a30 <acquire>
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
80103617:	e8 64 0c 00 00       	call   80104280 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010361c:	59                   	pop    %ecx
8010361d:	58                   	pop    %eax
8010361e:	57                   	push   %edi
8010361f:	53                   	push   %ebx
80103620:	e8 6b 0a 00 00       	call   80104090 <sleep>
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
80103670:	e8 0b 0c 00 00       	call   80104280 <wakeup>
  release(&p->lock);
80103675:	89 3c 24             	mov    %edi,(%esp)
80103678:	e8 73 15 00 00       	call   80104bf0 <release>
  return n;
8010367d:	83 c4 10             	add    $0x10,%esp
80103680:	8b 45 10             	mov    0x10(%ebp),%eax
80103683:	eb 14                	jmp    80103699 <pipewrite+0x119>
80103685:	8d 76 00             	lea    0x0(%esi),%esi
        release(&p->lock);
80103688:	83 ec 0c             	sub    $0xc,%esp
8010368b:	57                   	push   %edi
8010368c:	e8 5f 15 00 00       	call   80104bf0 <release>
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
801036c0:	e8 6b 13 00 00       	call   80104a30 <acquire>
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
80103724:	e8 67 09 00 00       	call   80104090 <sleep>
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
8010377f:	e8 fc 0a 00 00       	call   80104280 <wakeup>
  release(&p->lock);
80103784:	89 34 24             	mov    %esi,(%esp)
80103787:	e8 64 14 00 00       	call   80104bf0 <release>
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
801037b1:	e8 3a 14 00 00       	call   80104bf0 <release>
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
801038ab:	c7 40 14 0e 60 10 80 	movl   $0x8010600e,0x14(%eax)
  p->context = (struct context*)sp;
801038b2:	89 43 40             	mov    %eax,0x40(%ebx)
  memset(p->context, 0, sizeof *p->context);
801038b5:	6a 14                	push   $0x14
801038b7:	6a 00                	push   $0x0
801038b9:	50                   	push   %eax
801038ba:	e8 81 13 00 00       	call   80104c40 <memset>
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
801038fb:	e8 f0 12 00 00       	call   80104bf0 <release>

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
80103956:	68 e1 7e 10 80       	push   $0x80107ee1
8010395b:	68 e0 28 11 80       	push   $0x801128e0
80103960:	e8 ab 10 00 00       	call   80104a10 <initlock>
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
8010397c:	e8 af 10 00 00       	call   80104a30 <acquire>
  p = allocproc();
80103981:	e8 4a fe ff ff       	call   801037d0 <allocproc>
80103986:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103988:	a3 bc b5 10 80       	mov    %eax,0x8010b5bc
  if((p->pgdir = setupkvm()) == 0)
8010398d:	e8 0e 38 00 00       	call   801071a0 <setupkvm>
80103992:	83 c4 10             	add    $0x10,%esp
80103995:	85 c0                	test   %eax,%eax
80103997:	89 43 04             	mov    %eax,0x4(%ebx)
8010399a:	0f 84 c1 00 00 00    	je     80103a61 <userinit+0xf1>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801039a0:	83 ec 04             	sub    $0x4,%esp
801039a3:	68 2c 00 00 00       	push   $0x2c
801039a8:	68 60 b4 10 80       	push   $0x8010b460
801039ad:	50                   	push   %eax
801039ae:	e8 3d 39 00 00       	call   801072f0 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
801039b3:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
801039b6:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801039bc:	6a 4c                	push   $0x4c
801039be:	6a 00                	push   $0x0
801039c0:	ff 73 3c             	pushl  0x3c(%ebx)
801039c3:	e8 78 12 00 00       	call   80104c40 <memset>
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
80103a1f:	68 01 7f 10 80       	push   $0x80107f01
80103a24:	50                   	push   %eax
80103a25:	e8 f6 13 00 00       	call   80104e20 <safestrcpy>
  p->cwd = namei("/");
80103a2a:	c7 04 24 0a 7f 10 80 	movl   $0x80107f0a,(%esp)
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
80103a54:	e8 97 11 00 00       	call   80104bf0 <release>
}
80103a59:	83 c4 10             	add    $0x10,%esp
80103a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a5f:	c9                   	leave  
80103a60:	c3                   	ret    
    panic("userinit: out of memory?");
80103a61:	83 ec 0c             	sub    $0xc,%esp
80103a64:	68 e8 7e 10 80       	push   $0x80107ee8
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
80103a95:	e8 b6 37 00 00       	call   80107250 <switchuvm>
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
80103ab2:	e8 79 39 00 00       	call   80107430 <allocuvm>
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
80103ada:	e8 f1 3a 00 00       	call   801075d0 <deallocuvm>
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
80103afe:	e8 2d 0f 00 00       	call   80104a30 <acquire>
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
80103b23:	e8 28 3c 00 00       	call   80107750 <copyuvm>
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
80103beb:	e8 30 12 00 00       	call   80104e20 <safestrcpy>
  np->state = RUNNABLE;
80103bf0:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  pid = np->pid;
80103bf7:	8b 73 10             	mov    0x10(%ebx),%esi
  release(&ptable.lock);
80103bfa:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103c01:	e8 ea 0f 00 00       	call   80104bf0 <release>
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
80103c2f:	68 60 80 10 80       	push   $0x80108060
80103c34:	e8 07 ca ff ff       	call   80100640 <cprintf>
    release(&ptable.lock);
80103c39:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103c40:	e8 ab 0f 00 00       	call   80104bf0 <release>
    return -1;
80103c45:	83 c4 10             	add    $0x10,%esp
80103c48:	eb bf                	jmp    80103c09 <fork+0x119>
    release(&ptable.lock);
80103c4a:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80103c4d:	be ff ff ff ff       	mov    $0xffffffff,%esi
    release(&ptable.lock);
80103c52:	68 e0 28 11 80       	push   $0x801128e0
80103c57:	e8 94 0f 00 00       	call   80104bf0 <release>
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
80103c86:	e8 65 0f 00 00       	call   80104bf0 <release>
    return -1;
80103c8b:	83 c4 10             	add    $0x10,%esp
80103c8e:	e9 76 ff ff ff       	jmp    80103c09 <fork+0x119>
80103c93:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103ca0 <scheduler>:
{
80103ca0:	55                   	push   %ebp
80103ca1:	ba 01 00 00 00       	mov    $0x1,%edx
80103ca6:	89 e5                	mov    %esp,%ebp
80103ca8:	57                   	push   %edi
80103ca9:	56                   	push   %esi
80103caa:	53                   	push   %ebx
80103cab:	83 ec 1c             	sub    $0x1c,%esp
80103cae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  asm volatile("sti");
80103cb1:	fb                   	sti    
    acquire(&ptable.lock);
80103cb2:	83 ec 0c             	sub    $0xc,%esp
    for (prio = 0; prio < 20; prio++)
80103cb5:	31 ff                	xor    %edi,%edi
    acquire(&ptable.lock);
80103cb7:	68 e0 28 11 80       	push   $0x801128e0
80103cbc:	e8 6f 0d 00 00       	call   80104a30 <acquire>
80103cc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103cc4:	83 c4 10             	add    $0x10,%esp
80103cc7:	89 f6                	mov    %esi,%esi
80103cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      for (proc_num = 0; proc_num < NPROC; proc_num++)
80103cd0:	31 c0                	xor    %eax,%eax
80103cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        p = ptable.proc + ((last_proc_num + 1 + proc_num) % NPROC);
80103cd8:	8d 34 02             	lea    (%edx,%eax,1),%esi
80103cdb:	83 e6 3f             	and    $0x3f,%esi
80103cde:	69 de 28 01 00 00    	imul   $0x128,%esi,%ebx
80103ce4:	81 c3 14 29 11 80    	add    $0x80112914,%ebx
        if (p->state != RUNNABLE)
80103cea:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103cee:	75 60                	jne    80103d50 <scheduler+0xb0>
        if (p->priority != prio)
80103cf0:	39 bb 20 01 00 00    	cmp    %edi,0x120(%ebx)
80103cf6:	75 58                	jne    80103d50 <scheduler+0xb0>
        switchuvm(p);
80103cf8:	83 ec 0c             	sub    $0xc,%esp
80103cfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        proc = p;
80103cfe:	65 89 1d 04 00 00 00 	mov    %ebx,%gs:0x4
        switchuvm(p);
80103d05:	53                   	push   %ebx
80103d06:	e8 45 35 00 00       	call   80107250 <switchuvm>
        p->cpuID = cpuID;
80103d0b:	8b 45 08             	mov    0x8(%ebp),%eax
        p->state = RUNNING;
80103d0e:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
        p->cpuID = cpuID;
80103d15:	89 83 24 01 00 00    	mov    %eax,0x124(%ebx)
        swtch(&cpu->scheduler, p->context);
80103d1b:	58                   	pop    %eax
80103d1c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d22:	5a                   	pop    %edx
80103d23:	ff 73 40             	pushl  0x40(%ebx)
80103d26:	8d 50 04             	lea    0x4(%eax),%edx
80103d29:	52                   	push   %edx
80103d2a:	e8 4c 11 00 00       	call   80104e7b <swtch>
        switchkvm();
80103d2f:	e8 fc 34 00 00       	call   80107230 <switchkvm>
80103d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d37:	8d 56 01             	lea    0x1(%esi),%edx
        proc = 0;
80103d3a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80103d41:	00 00 00 00 
80103d45:	83 c4 10             	add    $0x10,%esp
80103d48:	90                   	nop
80103d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      for (proc_num = 0; proc_num < NPROC; proc_num++)
80103d50:	83 c0 01             	add    $0x1,%eax
80103d53:	83 f8 40             	cmp    $0x40,%eax
80103d56:	75 80                	jne    80103cd8 <scheduler+0x38>
    for (prio = 0; prio < 20; prio++)
80103d58:	83 c7 01             	add    $0x1,%edi
80103d5b:	83 ff 14             	cmp    $0x14,%edi
80103d5e:	0f 85 6c ff ff ff    	jne    80103cd0 <scheduler+0x30>
    release(&ptable.lock);
80103d64:	83 ec 0c             	sub    $0xc,%esp
80103d67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80103d6a:	68 e0 28 11 80       	push   $0x801128e0
80103d6f:	e8 7c 0e 00 00       	call   80104bf0 <release>
    sti();
80103d74:	83 c4 10             	add    $0x10,%esp
80103d77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103d7a:	e9 2f ff ff ff       	jmp    80103cae <scheduler+0xe>
80103d7f:	90                   	nop

80103d80 <sched>:
{
80103d80:	55                   	push   %ebp
80103d81:	89 e5                	mov    %esp,%ebp
80103d83:	53                   	push   %ebx
80103d84:	83 ec 10             	sub    $0x10,%esp
  if(!holding(&ptable.lock))
80103d87:	68 e0 28 11 80       	push   $0x801128e0
80103d8c:	e8 af 0d 00 00       	call   80104b40 <holding>
80103d91:	83 c4 10             	add    $0x10,%esp
80103d94:	85 c0                	test   %eax,%eax
80103d96:	74 4c                	je     80103de4 <sched+0x64>
  if(cpu->ncli != 1)
80103d98:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80103d9f:	83 ba ac 00 00 00 01 	cmpl   $0x1,0xac(%edx)
80103da6:	75 63                	jne    80103e0b <sched+0x8b>
  if(proc->state == RUNNING)
80103da8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103dae:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80103db2:	74 4a                	je     80103dfe <sched+0x7e>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103db4:	9c                   	pushf  
80103db5:	59                   	pop    %ecx
  if(readeflags()&FL_IF)
80103db6:	80 e5 02             	and    $0x2,%ch
80103db9:	75 36                	jne    80103df1 <sched+0x71>
  swtch(&proc->context, cpu->scheduler);
80103dbb:	83 ec 08             	sub    $0x8,%esp
80103dbe:	83 c0 40             	add    $0x40,%eax
  intena = cpu->intena;
80103dc1:	8b 9a b0 00 00 00    	mov    0xb0(%edx),%ebx
  swtch(&proc->context, cpu->scheduler);
80103dc7:	ff 72 04             	pushl  0x4(%edx)
80103dca:	50                   	push   %eax
80103dcb:	e8 ab 10 00 00       	call   80104e7b <swtch>
  cpu->intena = intena;
80103dd0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
}
80103dd6:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80103dd9:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
80103ddf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103de2:	c9                   	leave  
80103de3:	c3                   	ret    
    panic("sched ptable.lock");
80103de4:	83 ec 0c             	sub    $0xc,%esp
80103de7:	68 0c 7f 10 80       	push   $0x80107f0c
80103dec:	e8 7f c5 ff ff       	call   80100370 <panic>
    panic("sched interruptible");
80103df1:	83 ec 0c             	sub    $0xc,%esp
80103df4:	68 38 7f 10 80       	push   $0x80107f38
80103df9:	e8 72 c5 ff ff       	call   80100370 <panic>
    panic("sched running");
80103dfe:	83 ec 0c             	sub    $0xc,%esp
80103e01:	68 2a 7f 10 80       	push   $0x80107f2a
80103e06:	e8 65 c5 ff ff       	call   80100370 <panic>
    panic("sched locks");
80103e0b:	83 ec 0c             	sub    $0xc,%esp
80103e0e:	68 1e 7f 10 80       	push   $0x80107f1e
80103e13:	e8 58 c5 ff ff       	call   80100370 <panic>
80103e18:	90                   	nop
80103e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103e20 <exit>:
{
80103e20:	55                   	push   %ebp
  if(proc == initproc)
80103e21:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80103e28:	89 e5                	mov    %esp,%ebp
80103e2a:	56                   	push   %esi
80103e2b:	53                   	push   %ebx
80103e2c:	31 db                	xor    %ebx,%ebx
  if(proc == initproc)
80103e2e:	3b 15 bc b5 10 80    	cmp    0x8010b5bc,%edx
80103e34:	0f 84 fa 01 00 00    	je     80104034 <exit+0x214>
80103e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(proc->ofile[fd]){
80103e40:	8d 73 10             	lea    0x10(%ebx),%esi
80103e43:	8b 44 b2 0c          	mov    0xc(%edx,%esi,4),%eax
80103e47:	85 c0                	test   %eax,%eax
80103e49:	74 1b                	je     80103e66 <exit+0x46>
      fileclose(proc->ofile[fd]);
80103e4b:	83 ec 0c             	sub    $0xc,%esp
80103e4e:	50                   	push   %eax
80103e4f:	e8 bc cf ff ff       	call   80100e10 <fileclose>
      proc->ofile[fd] = 0;
80103e54:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103e5b:	83 c4 10             	add    $0x10,%esp
80103e5e:	c7 44 b2 0c 00 00 00 	movl   $0x0,0xc(%edx,%esi,4)
80103e65:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103e66:	83 c3 01             	add    $0x1,%ebx
80103e69:	83 fb 10             	cmp    $0x10,%ebx
80103e6c:	75 d2                	jne    80103e40 <exit+0x20>
  begin_op();
80103e6e:	e8 bd ed ff ff       	call   80102c30 <begin_op>
  iput(proc->cwd);
80103e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e79:	83 ec 0c             	sub    $0xc,%esp
80103e7c:	ff b0 8c 00 00 00    	pushl  0x8c(%eax)
80103e82:	e8 f9 d8 ff ff       	call   80101780 <iput>
  end_op();
80103e87:	e8 14 ee ff ff       	call   80102ca0 <end_op>
  proc->cwd = 0;
80103e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e92:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80103e99:	00 00 00 
  acquire(&ptable.lock);
80103e9c:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103ea3:	e8 88 0b 00 00       	call   80104a30 <acquire>
  if(proc->parent == 0 && proc -> pthread!=0){
80103ea8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103eaf:	83 c4 10             	add    $0x10,%esp
80103eb2:	31 c0                	xor    %eax,%eax
80103eb4:	8b 4a 14             	mov    0x14(%edx),%ecx
80103eb7:	85 c9                	test   %ecx,%ecx
80103eb9:	0f 84 36 01 00 00    	je     80103ff5 <exit+0x1d5>
80103ebf:	90                   	nop
    if(parent->son[i] == son){
80103ec0:	3b 54 81 18          	cmp    0x18(%ecx,%eax,4),%edx
80103ec4:	0f 84 1a 01 00 00    	je     80103fe4 <exit+0x1c4>
  for(int i=0;i<MAXSON;++i){
80103eca:	83 c0 01             	add    $0x1,%eax
80103ecd:	83 f8 08             	cmp    $0x8,%eax
80103ed0:	75 ee                	jne    80103ec0 <exit+0xa0>
      cprintf("exit: son(%s) doesn't exist in parent(%s)\n", proc->name, proc->parent->name);
80103ed2:	81 c2 90 00 00 00    	add    $0x90,%edx
80103ed8:	81 c1 90 00 00 00    	add    $0x90,%ecx
80103ede:	50                   	push   %eax
80103edf:	51                   	push   %ecx
80103ee0:	52                   	push   %edx
80103ee1:	68 88 80 10 80       	push   $0x80108088
80103ee6:	e8 55 c7 ff ff       	call   80100640 <cprintf>
80103eeb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103ef2:	83 c4 10             	add    $0x10,%esp
    wakeup1(proc->parent);
80103ef5:	8b 4a 14             	mov    0x14(%edx),%ecx
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ef8:	b8 14 29 11 80       	mov    $0x80112914,%eax
80103efd:	eb 0d                	jmp    80103f0c <exit+0xec>
80103eff:	90                   	nop
80103f00:	05 28 01 00 00       	add    $0x128,%eax
80103f05:	3d 14 73 11 80       	cmp    $0x80117314,%eax
80103f0a:	73 1e                	jae    80103f2a <exit+0x10a>
    if(p->state == SLEEPING && p->chan == chan)
80103f0c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103f10:	75 ee                	jne    80103f00 <exit+0xe0>
80103f12:	3b 48 44             	cmp    0x44(%eax),%ecx
80103f15:	75 e9                	jne    80103f00 <exit+0xe0>
      p->state = RUNNABLE;
80103f17:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f1e:	05 28 01 00 00       	add    $0x128,%eax
80103f23:	3d 14 73 11 80       	cmp    $0x80117314,%eax
80103f28:	72 e2                	jb     80103f0c <exit+0xec>
80103f2a:	bb 14 29 11 80       	mov    $0x80112914,%ebx
80103f2f:	eb 19                	jmp    80103f4a <exit+0x12a>
80103f31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f38:	81 c3 28 01 00 00    	add    $0x128,%ebx
80103f3e:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
80103f44:	0f 83 81 00 00 00    	jae    80103fcb <exit+0x1ab>
    if(p->parent == proc){
80103f4a:	39 53 14             	cmp    %edx,0x14(%ebx)
80103f4d:	75 e9                	jne    80103f38 <exit+0x118>
      p->parent = initproc;
80103f4f:	8b 0d bc b5 10 80    	mov    0x8010b5bc,%ecx
  for (int i = 0; i < MAXSON; ++i){
80103f55:	31 c0                	xor    %eax,%eax
      p->parent = initproc;
80103f57:	89 4b 14             	mov    %ecx,0x14(%ebx)
  if(parent->numberOfSon >= MAXSON){
80103f5a:	8b 71 38             	mov    0x38(%ecx),%esi
80103f5d:	83 fe 07             	cmp    $0x7,%esi
80103f60:	7e 56                	jle    80103fb8 <exit+0x198>
        cprintf("fork: the number of sons is too much\n");
80103f62:	83 ec 0c             	sub    $0xc,%esp
80103f65:	68 60 80 10 80       	push   $0x80108060
80103f6a:	e8 d1 c6 ff ff       	call   80100640 <cprintf>
80103f6f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103f76:	83 c4 10             	add    $0x10,%esp
      if(p->state == ZOMBIE)
80103f79:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103f7d:	75 b9                	jne    80103f38 <exit+0x118>
        wakeup1(initproc);
80103f7f:	8b 0d bc b5 10 80    	mov    0x8010b5bc,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f85:	b8 14 29 11 80       	mov    $0x80112914,%eax
80103f8a:	eb 10                	jmp    80103f9c <exit+0x17c>
80103f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103f90:	05 28 01 00 00       	add    $0x128,%eax
80103f95:	3d 14 73 11 80       	cmp    $0x80117314,%eax
80103f9a:	73 9c                	jae    80103f38 <exit+0x118>
    if(p->state == SLEEPING && p->chan == chan)
80103f9c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103fa0:	75 ee                	jne    80103f90 <exit+0x170>
80103fa2:	3b 48 44             	cmp    0x44(%eax),%ecx
80103fa5:	75 e9                	jne    80103f90 <exit+0x170>
      p->state = RUNNABLE;
80103fa7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103fae:	eb e0                	jmp    80103f90 <exit+0x170>
  for (int i = 0; i < MAXSON; ++i){
80103fb0:	83 c0 01             	add    $0x1,%eax
80103fb3:	83 f8 08             	cmp    $0x8,%eax
80103fb6:	74 c1                	je     80103f79 <exit+0x159>
    if (parent->son[i] == 0){
80103fb8:	83 7c 81 18 00       	cmpl   $0x0,0x18(%ecx,%eax,4)
80103fbd:	75 f1                	jne    80103fb0 <exit+0x190>
      parent->numberOfSon++;
80103fbf:	83 c6 01             	add    $0x1,%esi
      parent->son[i] = son;
80103fc2:	89 5c 81 18          	mov    %ebx,0x18(%ecx,%eax,4)
      parent->numberOfSon++;
80103fc6:	89 71 38             	mov    %esi,0x38(%ecx)
80103fc9:	eb ae                	jmp    80103f79 <exit+0x159>
  proc->state = ZOMBIE;
80103fcb:	c7 42 0c 05 00 00 00 	movl   $0x5,0xc(%edx)
  sched();
80103fd2:	e8 a9 fd ff ff       	call   80103d80 <sched>
  panic("zombie exit");
80103fd7:	83 ec 0c             	sub    $0xc,%esp
80103fda:	68 59 7f 10 80       	push   $0x80107f59
80103fdf:	e8 8c c3 ff ff       	call   80100370 <panic>
      parent->son[i] = 0;
80103fe4:	c7 44 81 18 00 00 00 	movl   $0x0,0x18(%ecx,%eax,4)
80103feb:	00 
      parent->numberOfSon--;
80103fec:	83 69 38 01          	subl   $0x1,0x38(%ecx)
80103ff0:	e9 00 ff ff ff       	jmp    80103ef5 <exit+0xd5>
  if(proc->parent == 0 && proc -> pthread!=0){
80103ff5:	8b 9a 18 01 00 00    	mov    0x118(%edx),%ebx
80103ffb:	85 db                	test   %ebx,%ebx
80103ffd:	0f 84 bd fe ff ff    	je     80103ec0 <exit+0xa0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104003:	b8 14 29 11 80       	mov    $0x80112914,%eax
80104008:	eb 16                	jmp    80104020 <exit+0x200>
8010400a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104010:	05 28 01 00 00       	add    $0x128,%eax
80104015:	3d 14 73 11 80       	cmp    $0x80117314,%eax
8010401a:	0f 83 0a ff ff ff    	jae    80103f2a <exit+0x10a>
    if(p->state == SLEEPING && p->chan == chan)
80104020:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104024:	75 ea                	jne    80104010 <exit+0x1f0>
80104026:	3b 58 44             	cmp    0x44(%eax),%ebx
80104029:	75 e5                	jne    80104010 <exit+0x1f0>
      p->state = RUNNABLE;
8010402b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80104032:	eb dc                	jmp    80104010 <exit+0x1f0>
    panic("init exiting");
80104034:	83 ec 0c             	sub    $0xc,%esp
80104037:	68 4c 7f 10 80       	push   $0x80107f4c
8010403c:	e8 2f c3 ff ff       	call   80100370 <panic>
80104041:	eb 0d                	jmp    80104050 <yield>
80104043:	90                   	nop
80104044:	90                   	nop
80104045:	90                   	nop
80104046:	90                   	nop
80104047:	90                   	nop
80104048:	90                   	nop
80104049:	90                   	nop
8010404a:	90                   	nop
8010404b:	90                   	nop
8010404c:	90                   	nop
8010404d:	90                   	nop
8010404e:	90                   	nop
8010404f:	90                   	nop

80104050 <yield>:
{
80104050:	55                   	push   %ebp
80104051:	89 e5                	mov    %esp,%ebp
80104053:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104056:	68 e0 28 11 80       	push   $0x801128e0
8010405b:	e8 d0 09 00 00       	call   80104a30 <acquire>
  proc->state = RUNNABLE;
80104060:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104066:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010406d:	e8 0e fd ff ff       	call   80103d80 <sched>
  release(&ptable.lock);
80104072:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80104079:	e8 72 0b 00 00       	call   80104bf0 <release>
}
8010407e:	83 c4 10             	add    $0x10,%esp
80104081:	c9                   	leave  
80104082:	c3                   	ret    
80104083:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104089:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104090 <sleep>:
  if(proc == 0)
80104090:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80104096:	55                   	push   %ebp
80104097:	89 e5                	mov    %esp,%ebp
80104099:	56                   	push   %esi
8010409a:	53                   	push   %ebx
  if(proc == 0)
8010409b:	85 c0                	test   %eax,%eax
{
8010409d:	8b 75 08             	mov    0x8(%ebp),%esi
801040a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
801040a3:	0f 84 97 00 00 00    	je     80104140 <sleep+0xb0>
  if(lk == 0)
801040a9:	85 db                	test   %ebx,%ebx
801040ab:	0f 84 82 00 00 00    	je     80104133 <sleep+0xa3>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801040b1:	81 fb e0 28 11 80    	cmp    $0x801128e0,%ebx
801040b7:	74 57                	je     80104110 <sleep+0x80>
    acquire(&ptable.lock);  //DOC: sleeplock1
801040b9:	83 ec 0c             	sub    $0xc,%esp
801040bc:	68 e0 28 11 80       	push   $0x801128e0
801040c1:	e8 6a 09 00 00       	call   80104a30 <acquire>
    release(lk);
801040c6:	89 1c 24             	mov    %ebx,(%esp)
801040c9:	e8 22 0b 00 00       	call   80104bf0 <release>
  proc->chan = chan;
801040ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040d4:	89 70 44             	mov    %esi,0x44(%eax)
  proc->state = SLEEPING;
801040d7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801040de:	e8 9d fc ff ff       	call   80103d80 <sched>
  proc->chan = 0;
801040e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040e9:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
    release(&ptable.lock);
801040f0:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
801040f7:	e8 f4 0a 00 00       	call   80104bf0 <release>
    acquire(lk);
801040fc:	89 5d 08             	mov    %ebx,0x8(%ebp)
801040ff:	83 c4 10             	add    $0x10,%esp
}
80104102:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104105:	5b                   	pop    %ebx
80104106:	5e                   	pop    %esi
80104107:	5d                   	pop    %ebp
    acquire(lk);
80104108:	e9 23 09 00 00       	jmp    80104a30 <acquire>
8010410d:	8d 76 00             	lea    0x0(%esi),%esi
  proc->chan = chan;
80104110:	89 70 44             	mov    %esi,0x44(%eax)
  proc->state = SLEEPING;
80104113:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010411a:	e8 61 fc ff ff       	call   80103d80 <sched>
  proc->chan = 0;
8010411f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104125:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
}
8010412c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010412f:	5b                   	pop    %ebx
80104130:	5e                   	pop    %esi
80104131:	5d                   	pop    %ebp
80104132:	c3                   	ret    
    panic("sleep without lk");
80104133:	83 ec 0c             	sub    $0xc,%esp
80104136:	68 6b 7f 10 80       	push   $0x80107f6b
8010413b:	e8 30 c2 ff ff       	call   80100370 <panic>
    panic("sleep");
80104140:	83 ec 0c             	sub    $0xc,%esp
80104143:	68 65 7f 10 80       	push   $0x80107f65
80104148:	e8 23 c2 ff ff       	call   80100370 <panic>
8010414d:	8d 76 00             	lea    0x0(%esi),%esi

80104150 <wait>:
{
80104150:	55                   	push   %ebp
80104151:	89 e5                	mov    %esp,%ebp
80104153:	56                   	push   %esi
80104154:	53                   	push   %ebx
  acquire(&ptable.lock);
80104155:	83 ec 0c             	sub    $0xc,%esp
80104158:	68 e0 28 11 80       	push   $0x801128e0
8010415d:	e8 ce 08 00 00       	call   80104a30 <acquire>
80104162:	83 c4 10             	add    $0x10,%esp
      if(p->parent != proc)
80104165:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    havekids = 0;
8010416b:	31 d2                	xor    %edx,%edx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010416d:	bb 14 29 11 80       	mov    $0x80112914,%ebx
80104172:	eb 12                	jmp    80104186 <wait+0x36>
80104174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104178:	81 c3 28 01 00 00    	add    $0x128,%ebx
8010417e:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
80104184:	73 1e                	jae    801041a4 <wait+0x54>
      if(p->parent != proc)
80104186:	39 43 14             	cmp    %eax,0x14(%ebx)
80104189:	75 ed                	jne    80104178 <wait+0x28>
      if(p->state == ZOMBIE){
8010418b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010418f:	74 3f                	je     801041d0 <wait+0x80>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104191:	81 c3 28 01 00 00    	add    $0x128,%ebx
      havekids = 1;
80104197:	ba 01 00 00 00       	mov    $0x1,%edx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010419c:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
801041a2:	72 e2                	jb     80104186 <wait+0x36>
    if(!havekids || proc->killed){
801041a4:	85 d2                	test   %edx,%edx
801041a6:	0f 84 bc 00 00 00    	je     80104268 <wait+0x118>
801041ac:	8b 50 48             	mov    0x48(%eax),%edx
801041af:	85 d2                	test   %edx,%edx
801041b1:	0f 85 b1 00 00 00    	jne    80104268 <wait+0x118>
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801041b7:	83 ec 08             	sub    $0x8,%esp
801041ba:	68 e0 28 11 80       	push   $0x801128e0
801041bf:	50                   	push   %eax
801041c0:	e8 cb fe ff ff       	call   80104090 <sleep>
    havekids = 0;
801041c5:	83 c4 10             	add    $0x10,%esp
801041c8:	eb 9b                	jmp    80104165 <wait+0x15>
801041ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        kfree(p->kstack);
801041d0:	83 ec 0c             	sub    $0xc,%esp
801041d3:	ff 73 08             	pushl  0x8(%ebx)
        pid = p->pid;
801041d6:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801041d9:	e8 32 e1 ff ff       	call   80102310 <kfree>
        freevm(p->pgdir);
801041de:	59                   	pop    %ecx
801041df:	ff 73 04             	pushl  0x4(%ebx)
        p->kstack = 0;
801041e2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801041e9:	e8 b2 34 00 00       	call   801076a0 <freevm>
        release(&ptable.lock);
801041ee:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
        p->pid = 0;
801041f5:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801041fc:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80104203:	c6 83 90 00 00 00 00 	movb   $0x0,0x90(%ebx)
        p->killed = 0;
8010420a:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        p->state = UNUSED;
80104211:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->numberOfSon = 0;
80104218:	c7 43 38 00 00 00 00 	movl   $0x0,0x38(%ebx)
          p->son[i] = 0;
8010421f:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
80104226:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
8010422d:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
80104234:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
8010423b:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
80104242:	c7 43 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
80104249:	c7 43 30 00 00 00 00 	movl   $0x0,0x30(%ebx)
80104250:	c7 43 34 00 00 00 00 	movl   $0x0,0x34(%ebx)
        release(&ptable.lock);
80104257:	e8 94 09 00 00       	call   80104bf0 <release>
        return pid;
8010425c:	83 c4 10             	add    $0x10,%esp
}
8010425f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104262:	89 f0                	mov    %esi,%eax
80104264:	5b                   	pop    %ebx
80104265:	5e                   	pop    %esi
80104266:	5d                   	pop    %ebp
80104267:	c3                   	ret    
      release(&ptable.lock);
80104268:	83 ec 0c             	sub    $0xc,%esp
      return -1;
8010426b:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104270:	68 e0 28 11 80       	push   $0x801128e0
80104275:	e8 76 09 00 00       	call   80104bf0 <release>
      return -1;
8010427a:	83 c4 10             	add    $0x10,%esp
8010427d:	eb e0                	jmp    8010425f <wait+0x10f>
8010427f:	90                   	nop

80104280 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104280:	55                   	push   %ebp
80104281:	89 e5                	mov    %esp,%ebp
80104283:	53                   	push   %ebx
80104284:	83 ec 10             	sub    $0x10,%esp
80104287:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010428a:	68 e0 28 11 80       	push   $0x801128e0
8010428f:	e8 9c 07 00 00       	call   80104a30 <acquire>
80104294:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104297:	b8 14 29 11 80       	mov    $0x80112914,%eax
8010429c:	eb 0e                	jmp    801042ac <wakeup+0x2c>
8010429e:	66 90                	xchg   %ax,%ax
801042a0:	05 28 01 00 00       	add    $0x128,%eax
801042a5:	3d 14 73 11 80       	cmp    $0x80117314,%eax
801042aa:	73 1e                	jae    801042ca <wakeup+0x4a>
    if(p->state == SLEEPING && p->chan == chan)
801042ac:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801042b0:	75 ee                	jne    801042a0 <wakeup+0x20>
801042b2:	3b 58 44             	cmp    0x44(%eax),%ebx
801042b5:	75 e9                	jne    801042a0 <wakeup+0x20>
      p->state = RUNNABLE;
801042b7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042be:	05 28 01 00 00       	add    $0x128,%eax
801042c3:	3d 14 73 11 80       	cmp    $0x80117314,%eax
801042c8:	72 e2                	jb     801042ac <wakeup+0x2c>
  wakeup1(chan);
  release(&ptable.lock);
801042ca:	c7 45 08 e0 28 11 80 	movl   $0x801128e0,0x8(%ebp)
}
801042d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042d4:	c9                   	leave  
  release(&ptable.lock);
801042d5:	e9 16 09 00 00       	jmp    80104bf0 <release>
801042da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801042e0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801042e0:	55                   	push   %ebp
801042e1:	89 e5                	mov    %esp,%ebp
801042e3:	53                   	push   %ebx
801042e4:	83 ec 10             	sub    $0x10,%esp
801042e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801042ea:	68 e0 28 11 80       	push   $0x801128e0
801042ef:	e8 3c 07 00 00       	call   80104a30 <acquire>
801042f4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042f7:	b8 14 29 11 80       	mov    $0x80112914,%eax
801042fc:	eb 0e                	jmp    8010430c <kill+0x2c>
801042fe:	66 90                	xchg   %ax,%ax
80104300:	05 28 01 00 00       	add    $0x128,%eax
80104305:	3d 14 73 11 80       	cmp    $0x80117314,%eax
8010430a:	73 34                	jae    80104340 <kill+0x60>
    if(p->pid == pid){
8010430c:	39 58 10             	cmp    %ebx,0x10(%eax)
8010430f:	75 ef                	jne    80104300 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104311:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
80104315:	c7 40 48 01 00 00 00 	movl   $0x1,0x48(%eax)
      if(p->state == SLEEPING)
8010431c:	75 07                	jne    80104325 <kill+0x45>
        p->state = RUNNABLE;
8010431e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104325:	83 ec 0c             	sub    $0xc,%esp
80104328:	68 e0 28 11 80       	push   $0x801128e0
8010432d:	e8 be 08 00 00       	call   80104bf0 <release>
      return 0;
80104332:	83 c4 10             	add    $0x10,%esp
80104335:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80104337:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010433a:	c9                   	leave  
8010433b:	c3                   	ret    
8010433c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable.lock);
80104340:	83 ec 0c             	sub    $0xc,%esp
80104343:	68 e0 28 11 80       	push   $0x801128e0
80104348:	e8 a3 08 00 00       	call   80104bf0 <release>
  return -1;
8010434d:	83 c4 10             	add    $0x10,%esp
80104350:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104358:	c9                   	leave  
80104359:	c3                   	ret    
8010435a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104360 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104360:	55                   	push   %ebp
80104361:	89 e5                	mov    %esp,%ebp
80104363:	57                   	push   %edi
80104364:	56                   	push   %esi
80104365:	53                   	push   %ebx
80104366:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104369:	be 14 29 11 80       	mov    $0x80112914,%esi
{
8010436e:	83 ec 3c             	sub    $0x3c,%esp
80104371:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p->state == UNUSED)
80104378:	8b 46 0c             	mov    0xc(%esi),%eax
8010437b:	85 c0                	test   %eax,%eax
8010437d:	0f 84 97 00 00 00    	je     8010441a <procdump+0xba>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104383:	83 f8 05             	cmp    $0x5,%eax
      state = states[p->state];
    else
      state = "???";
80104386:	b9 7c 7f 10 80       	mov    $0x80107f7c,%ecx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010438b:	77 11                	ja     8010439e <procdump+0x3e>
8010438d:	8b 0c 85 24 81 10 80 	mov    -0x7fef7edc(,%eax,4),%ecx
      state = "???";
80104394:	b8 7c 7f 10 80       	mov    $0x80107f7c,%eax
80104399:	85 c9                	test   %ecx,%ecx
8010439b:	0f 44 c8             	cmove  %eax,%ecx
    cprintf("\npid:%d, state: %s, name: %s, priority = %d, numOfSon is %d, cpuID = %d\n", p->pid, state, p->name, p->priority,p->numberOfSon,p->cpuID);
8010439e:	8d 86 90 00 00 00    	lea    0x90(%esi),%eax
801043a4:	83 ec 04             	sub    $0x4,%esp
801043a7:	ff b6 24 01 00 00    	pushl  0x124(%esi)
801043ad:	ff 76 38             	pushl  0x38(%esi)
801043b0:	ff b6 20 01 00 00    	pushl  0x120(%esi)
801043b6:	50                   	push   %eax
801043b7:	51                   	push   %ecx
801043b8:	ff 76 10             	pushl  0x10(%esi)
801043bb:	68 b4 80 10 80       	push   $0x801080b4
801043c0:	e8 7b c2 ff ff       	call   80100640 <cprintf>
    //     }
    //   }
    //   cprintf("\n");
    // }
    
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
801043c5:	8b 86 a8 00 00 00    	mov    0xa8(%esi),%eax
801043cb:	83 c4 20             	add    $0x20,%esp
801043ce:	85 c0                	test   %eax,%eax
801043d0:	74 32                	je     80104404 <procdump+0xa4>
801043d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("start: %d, length: %d\n",p->vm[i].start,p->vm[i].length);
801043d8:	8d 04 40             	lea    (%eax,%eax,2),%eax
801043db:	83 ec 04             	sub    $0x4,%esp
801043de:	8d 3c 86             	lea    (%esi,%eax,4),%edi
801043e1:	ff b7 a4 00 00 00    	pushl  0xa4(%edi)
801043e7:	ff b7 a0 00 00 00    	pushl  0xa0(%edi)
801043ed:	68 80 7f 10 80       	push   $0x80107f80
801043f2:	e8 49 c2 ff ff       	call   80100640 <cprintf>
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
801043f7:	8b 87 a8 00 00 00    	mov    0xa8(%edi),%eax
801043fd:	83 c4 10             	add    $0x10,%esp
80104400:	85 c0                	test   %eax,%eax
80104402:	75 d4                	jne    801043d8 <procdump+0x78>
    }
    if(p->state == SLEEPING){
80104404:	83 7e 0c 02          	cmpl   $0x2,0xc(%esi)
80104408:	74 2e                	je     80104438 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010440a:	83 ec 0c             	sub    $0xc,%esp
8010440d:	68 b0 7f 10 80       	push   $0x80107fb0
80104412:	e8 29 c2 ff ff       	call   80100640 <cprintf>
80104417:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010441a:	81 c6 28 01 00 00    	add    $0x128,%esi
80104420:	81 fe 14 73 11 80    	cmp    $0x80117314,%esi
80104426:	0f 82 4c ff ff ff    	jb     80104378 <procdump+0x18>
  }
}
8010442c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010442f:	5b                   	pop    %ebx
80104430:	5e                   	pop    %esi
80104431:	5f                   	pop    %edi
80104432:	5d                   	pop    %ebp
80104433:	c3                   	ret    
80104434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104438:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010443b:	83 ec 08             	sub    $0x8,%esp
8010443e:	8d 7d c0             	lea    -0x40(%ebp),%edi
80104441:	50                   	push   %eax
80104442:	8b 46 40             	mov    0x40(%esi),%eax
80104445:	8b 40 0c             	mov    0xc(%eax),%eax
80104448:	83 c0 08             	add    $0x8,%eax
8010444b:	50                   	push   %eax
8010444c:	e8 9f 06 00 00       	call   80104af0 <getcallerpcs>
80104451:	83 c4 10             	add    $0x10,%esp
80104454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      for(i=0; i<10 && pc[i] != 0; i++)
80104458:	8b 07                	mov    (%edi),%eax
8010445a:	85 c0                	test   %eax,%eax
8010445c:	74 ac                	je     8010440a <procdump+0xaa>
        cprintf(" %p", pc[i]);
8010445e:	83 ec 08             	sub    $0x8,%esp
80104461:	83 c7 04             	add    $0x4,%edi
80104464:	50                   	push   %eax
80104465:	68 62 79 10 80       	push   $0x80107962
8010446a:	e8 d1 c1 ff ff       	call   80100640 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
8010446f:	83 c4 10             	add    $0x10,%esp
80104472:	39 df                	cmp    %ebx,%edi
80104474:	75 e2                	jne    80104458 <procdump+0xf8>
80104476:	eb 92                	jmp    8010440a <procdump+0xaa>
80104478:	90                   	nop
80104479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104480 <mygrowproc>:


int mygrowproc(int n){
80104480:	55                   	push   %ebp
80104481:	89 e5                	mov    %esp,%ebp
80104483:	57                   	push   %edi
80104484:	56                   	push   %esi
80104485:	53                   	push   %ebx
80104486:	83 ec 1c             	sub    $0x1c,%esp
  struct vma *vm = proc->vm;
80104489:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  int start = proc->sz;
  int pre=0;
  int i,k;
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
8010448f:	8b b8 a8 00 00 00    	mov    0xa8(%eax),%edi
  struct vma *vm = proc->vm;
80104495:	8d 88 a0 00 00 00    	lea    0xa0(%eax),%ecx
8010449b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  int start = proc->sz;
8010449e:	8b 18                	mov    (%eax),%ebx
  struct vma *vm = proc->vm;
801044a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801044a3:	85 ff                	test   %edi,%edi
801044a5:	0f 84 d5 00 00 00    	je     80104580 <mygrowproc+0x100>
  {
    if (start + n < vm[i].start)
801044ab:	8d 04 7f             	lea    (%edi,%edi,2),%eax
801044ae:	8d 14 81             	lea    (%ecx,%eax,4),%edx
801044b1:	8b 45 08             	mov    0x8(%ebp),%eax
801044b4:	8b 0a                	mov    (%edx),%ecx
801044b6:	01 d8                	add    %ebx,%eax
801044b8:	39 c8                	cmp    %ecx,%eax
801044ba:	7d 22                	jge    801044de <mygrowproc+0x5e>
801044bc:	e9 cf 00 00 00       	jmp    80104590 <mygrowproc+0x110>
801044c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801044c8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801044cb:	8d 14 40             	lea    (%eax,%eax,2),%edx
801044ce:	8d 14 96             	lea    (%esi,%edx,4),%edx
801044d1:	8b 75 08             	mov    0x8(%ebp),%esi
801044d4:	8b 0a                	mov    (%edx),%ecx
801044d6:	01 de                	add    %ebx,%esi
801044d8:	39 ce                	cmp    %ecx,%esi
801044da:	7c 0e                	jl     801044ea <mygrowproc+0x6a>
801044dc:	89 c7                	mov    %eax,%edi
    {
      break;
    }
    start = vm[i].start + vm[i].length;
801044de:	8b 5a 04             	mov    0x4(%edx),%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801044e1:	8b 42 08             	mov    0x8(%edx),%eax
    start = vm[i].start + vm[i].length;
801044e4:	01 cb                	add    %ecx,%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801044e6:	85 c0                	test   %eax,%eax
801044e8:	75 de                	jne    801044c8 <mygrowproc+0x48>
801044ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
801044ed:	b9 01 00 00 00       	mov    $0x1,%ecx
801044f2:	8d 96 ac 00 00 00    	lea    0xac(%esi),%edx
801044f8:	90                   	nop
801044f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pre = i;
  }
  for(k = 1; k < 10; ++k){
    if(vm[k].next == -1){
80104500:	83 7a 08 ff          	cmpl   $0xffffffff,0x8(%edx)
80104504:	74 2a                	je     80104530 <mygrowproc+0xb0>
  for(k = 1; k < 10; ++k){
80104506:	83 c1 01             	add    $0x1,%ecx
80104509:	83 c2 0c             	add    $0xc,%edx
8010450c:	83 f9 0a             	cmp    $0xa,%ecx
8010450f:	75 ef                	jne    80104500 <mygrowproc+0x80>
      myallocuvm(proc->pgdir, start , start + n);
      switchuvm(proc);
      return start;
    }
  }
  switchuvm(proc);
80104511:	83 ec 0c             	sub    $0xc,%esp
80104514:	ff 75 e0             	pushl  -0x20(%ebp)
  return 0; 
80104517:	31 db                	xor    %ebx,%ebx
  switchuvm(proc);
80104519:	e8 32 2d 00 00       	call   80107250 <switchuvm>
  return 0; 
8010451e:	83 c4 10             	add    $0x10,%esp
}
80104521:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104524:	89 d8                	mov    %ebx,%eax
80104526:	5b                   	pop    %ebx
80104527:	5e                   	pop    %esi
80104528:	5f                   	pop    %edi
80104529:	5d                   	pop    %ebp
8010452a:	c3                   	ret    
8010452b:	90                   	nop
8010452c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      vm[k].next = i;
80104530:	89 42 08             	mov    %eax,0x8(%edx)
      vm[k].length = n;
80104533:	8b 45 08             	mov    0x8(%ebp),%eax
      myallocuvm(proc->pgdir, start , start + n);
80104536:	83 ec 04             	sub    $0x4,%esp
      vm[k].start = start;
80104539:	89 1a                	mov    %ebx,(%edx)
      vm[k].length = n;
8010453b:	89 42 04             	mov    %eax,0x4(%edx)
      vm[pre].next = k;
8010453e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
80104541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80104544:	89 4c 87 08          	mov    %ecx,0x8(%edi,%eax,4)
      myallocuvm(proc->pgdir, start , start + n);
80104548:	8b 45 08             	mov    0x8(%ebp),%eax
8010454b:	01 d8                	add    %ebx,%eax
8010454d:	50                   	push   %eax
8010454e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104554:	53                   	push   %ebx
80104555:	ff 70 04             	pushl  0x4(%eax)
80104558:	e8 03 30 00 00       	call   80107560 <myallocuvm>
      switchuvm(proc);
8010455d:	58                   	pop    %eax
8010455e:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
80104565:	e8 e6 2c 00 00       	call   80107250 <switchuvm>
      return start;
8010456a:	83 c4 10             	add    $0x10,%esp
}
8010456d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104570:	89 d8                	mov    %ebx,%eax
80104572:	5b                   	pop    %ebx
80104573:	5e                   	pop    %esi
80104574:	5f                   	pop    %edi
80104575:	5d                   	pop    %ebp
80104576:	c3                   	ret    
80104577:	89 f6                	mov    %esi,%esi
80104579:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104580:	31 c0                	xor    %eax,%eax
80104582:	e9 63 ff ff ff       	jmp    801044ea <mygrowproc+0x6a>
80104587:	89 f6                	mov    %esi,%esi
80104589:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if (start + n < vm[i].start)
80104590:	89 f8                	mov    %edi,%eax
  int pre=0;
80104592:	31 ff                	xor    %edi,%edi
80104594:	e9 51 ff ff ff       	jmp    801044ea <mygrowproc+0x6a>
80104599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801045a0 <myreduceproc>:

int myreduceproc(int start){
801045a0:	55                   	push   %ebp
801045a1:	89 e5                	mov    %esp,%ebp
801045a3:	57                   	push   %edi
801045a4:	56                   	push   %esi
801045a5:	53                   	push   %ebx
801045a6:	83 ec 0c             	sub    $0xc,%esp
  int prev=0;
  int i;
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
801045a9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
int myreduceproc(int start){
801045b0:	8b 75 08             	mov    0x8(%ebp),%esi
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
801045b3:	8b 9a a8 00 00 00    	mov    0xa8(%edx),%ebx
801045b9:	85 db                	test   %ebx,%ebx
801045bb:	74 2f                	je     801045ec <myreduceproc+0x4c>
      if(proc->vm[i].start == start){
801045bd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
801045c0:	3b b4 82 a0 00 00 00 	cmp    0xa0(%edx,%eax,4),%esi
801045c7:	75 15                	jne    801045de <myreduceproc+0x3e>
801045c9:	eb 45                	jmp    80104610 <myreduceproc+0x70>
801045cb:	90                   	nop
801045cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801045d0:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
801045d3:	39 b4 8a a0 00 00 00 	cmp    %esi,0xa0(%edx,%ecx,4)
801045da:	74 38                	je     80104614 <myreduceproc+0x74>
801045dc:	89 c3                	mov    %eax,%ebx
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
801045de:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
801045e1:	8b 84 82 a8 00 00 00 	mov    0xa8(%edx,%eax,4),%eax
801045e8:	85 c0                	test   %eax,%eax
801045ea:	75 e4                	jne    801045d0 <myreduceproc+0x30>
        switchuvm(proc);
        return 0;
      }
      prev=i;
  }
  cprintf("warning: free vma at %x! \n",start);
801045ec:	83 ec 08             	sub    $0x8,%esp
801045ef:	56                   	push   %esi
801045f0:	68 97 7f 10 80       	push   $0x80107f97
801045f5:	e8 46 c0 ff ff       	call   80100640 <cprintf>
  return -1;
801045fa:	83 c4 10             	add    $0x10,%esp
}
801045fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80104600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104605:	5b                   	pop    %ebx
80104606:	5e                   	pop    %esi
80104607:	5f                   	pop    %edi
80104608:	5d                   	pop    %ebp
80104609:	c3                   	ret    
8010460a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(proc->vm[i].start == start){
80104610:	89 d8                	mov    %ebx,%eax
  int prev=0;
80104612:	31 db                	xor    %ebx,%ebx
        mydeallocuvm(proc->pgdir,start,start+proc->vm[i].length);
80104614:	8d 3c 40             	lea    (%eax,%eax,2),%edi
80104617:	83 ec 04             	sub    $0x4,%esp
8010461a:	c1 e7 02             	shl    $0x2,%edi
8010461d:	8b 84 3a a4 00 00 00 	mov    0xa4(%edx,%edi,1),%eax
80104624:	01 f0                	add    %esi,%eax
80104626:	50                   	push   %eax
80104627:	56                   	push   %esi
80104628:	ff 72 04             	pushl  0x4(%edx)
8010462b:	e8 d0 2f 00 00       	call   80107600 <mydeallocuvm>
        proc->vm[prev].next = proc->vm[i].next;
80104630:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104636:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
80104639:	01 c7                	add    %eax,%edi
8010463b:	8b 8f a8 00 00 00    	mov    0xa8(%edi),%ecx
80104641:	89 8c 90 a8 00 00 00 	mov    %ecx,0xa8(%eax,%edx,4)
        proc->vm[i].next=-1;
80104648:	c7 87 a8 00 00 00 ff 	movl   $0xffffffff,0xa8(%edi)
8010464f:	ff ff ff 
        switchuvm(proc);
80104652:	89 04 24             	mov    %eax,(%esp)
80104655:	e8 f6 2b 00 00       	call   80107250 <switchuvm>
        return 0;
8010465a:	83 c4 10             	add    $0x10,%esp
}
8010465d:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
80104660:	31 c0                	xor    %eax,%eax
}
80104662:	5b                   	pop    %ebx
80104663:	5e                   	pop    %esi
80104664:	5f                   	pop    %edi
80104665:	5d                   	pop    %ebp
80104666:	c3                   	ret    
80104667:	89 f6                	mov    %esi,%esi
80104669:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104670 <clone>:

// malloc space for new stack then pass to clone
int clone(void(*fcn)(void*), void* arg, void* stack)
{
80104670:	55                   	push   %ebp
80104671:	89 e5                	mov    %esp,%ebp
80104673:	57                   	push   %edi
80104674:	56                   	push   %esi
80104675:	53                   	push   %ebx
80104676:	83 ec 24             	sub    $0x24,%esp
   cprintf("in clone, stack start addr = %p\n", stack);
80104679:	ff 75 10             	pushl  0x10(%ebp)
8010467c:	68 00 81 10 80       	push   $0x80108100
80104681:	e8 ba bf ff ff       	call   80100640 <cprintf>
  struct proc *curproc = proc;  // 调用 clone 的进程
80104686:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010468d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  struct proc *np;

  // allocate a PCB
  if((np = allocproc()) == 0)
80104690:	e8 3b f1 ff ff       	call   801037d0 <allocproc>
80104695:	83 c4 10             	add    $0x10,%esp
80104698:	85 c0                	test   %eax,%eax
8010469a:	0f 84 f1 00 00 00    	je     80104791 <clone+0x121>
   return -1; 
  
  // For clone, don't need to copy entire address space like fork
  np->pgdir = curproc->pgdir;  // 线程间公用页表
801046a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046a3:	89 c3                	mov    %eax,%ebx
  np->sz = curproc->sz;
  np->pthread = curproc;       // exit 时唤醒用
  np->parent = 0;
  *np->tf = *curproc->tf;      // 继承 trapframe
801046a5:	b9 13 00 00 00       	mov    $0x13,%ecx
801046aa:	8b 7b 3c             	mov    0x3c(%ebx),%edi
  np->pgdir = curproc->pgdir;  // 线程间公用页表
801046ad:	8b 42 04             	mov    0x4(%edx),%eax
801046b0:	89 43 04             	mov    %eax,0x4(%ebx)
  np->sz = curproc->sz;
801046b3:	8b 02                	mov    (%edx),%eax
  np->pthread = curproc;       // exit 时唤醒用
801046b5:	89 93 18 01 00 00    	mov    %edx,0x118(%ebx)
  np->parent = 0;
801046bb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  np->sz = curproc->sz;
801046c2:	89 03                	mov    %eax,(%ebx)
  *np->tf = *curproc->tf;      // 继承 trapframe
801046c4:	8b 72 3c             	mov    0x3c(%edx),%esi
801046c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  int* sp = stack + 4096 - 8;

  // Clone may need to change other registers than ones seen in fork
  np->tf->eip = (int)fcn;
801046c9:	8b 4d 08             	mov    0x8(%ebp),%ecx

  // setup new user stack and some pointers
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
  *sp = 0xffffffff; 

  for(int i = 0; i < NOFILE; i++)
801046cc:	31 f6                	xor    %esi,%esi
801046ce:	89 d7                	mov    %edx,%edi
  np->tf->eip = (int)fcn;
801046d0:	8b 43 3c             	mov    0x3c(%ebx),%eax
801046d3:	89 48 38             	mov    %ecx,0x38(%eax)
  int* sp = stack + 4096 - 8;
801046d6:	8b 45 10             	mov    0x10(%ebp),%eax
  np->tf->esp = (int)sp; 
801046d9:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
  int* sp = stack + 4096 - 8;
801046dc:	05 f8 0f 00 00       	add    $0xff8,%eax
  np->tf->esp = (int)sp; 
801046e1:	89 41 44             	mov    %eax,0x44(%ecx)
  np->tf->ebp = (int)sp; 
801046e4:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
801046e7:	89 41 08             	mov    %eax,0x8(%ecx)
  np->tf->eax = 0; 
801046ea:	8b 43 3c             	mov    0x3c(%ebx),%eax
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
801046ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  np->tf->eax = 0; 
801046f0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
801046f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  *sp = 0xffffffff; 
801046fa:	c7 81 f8 0f 00 00 ff 	movl   $0xffffffff,0xff8(%ecx)
80104701:	ff ff ff 
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
80104704:	89 81 fc 0f 00 00    	mov    %eax,0xffc(%ecx)
8010470a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[i])
80104710:	8b 44 b7 4c          	mov    0x4c(%edi,%esi,4),%eax
80104714:	85 c0                	test   %eax,%eax
80104716:	74 10                	je     80104728 <clone+0xb8>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104718:	83 ec 0c             	sub    $0xc,%esp
8010471b:	50                   	push   %eax
8010471c:	e8 9f c6 ff ff       	call   80100dc0 <filedup>
80104721:	83 c4 10             	add    $0x10,%esp
80104724:	89 44 b3 4c          	mov    %eax,0x4c(%ebx,%esi,4)
  for(int i = 0; i < NOFILE; i++)
80104728:	83 c6 01             	add    $0x1,%esi
8010472b:	83 fe 10             	cmp    $0x10,%esi
8010472e:	75 e0                	jne    80104710 <clone+0xa0>
  np->cwd = idup(curproc->cwd);
80104730:	83 ec 0c             	sub    $0xc,%esp
80104733:	ff b7 8c 00 00 00    	pushl  0x8c(%edi)
80104739:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010473c:	e8 9f ce ff ff       	call   801015e0 <idup>

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104741:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  np->cwd = idup(curproc->cwd);
80104744:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010474a:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80104750:	83 c4 0c             	add    $0xc,%esp
80104753:	6a 10                	push   $0x10
80104755:	81 c2 90 00 00 00    	add    $0x90,%edx
8010475b:	52                   	push   %edx
8010475c:	50                   	push   %eax
8010475d:	e8 be 06 00 00       	call   80104e20 <safestrcpy>
  
  int pid = np->pid;
80104762:	8b 73 10             	mov    0x10(%ebx),%esi
  
  acquire(&ptable.lock);
80104765:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
8010476c:	e8 bf 02 00 00       	call   80104a30 <acquire>
  np->state = RUNNABLE;
80104771:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80104778:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
8010477f:	e8 6c 04 00 00       	call   80104bf0 <release>
 
  // return the ID of the new thread
  return pid;
80104784:	83 c4 10             	add    $0x10,%esp
}
80104787:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010478a:	89 f0                	mov    %esi,%eax
8010478c:	5b                   	pop    %ebx
8010478d:	5e                   	pop    %esi
8010478e:	5f                   	pop    %edi
8010478f:	5d                   	pop    %ebp
80104790:	c3                   	ret    
   return -1; 
80104791:	be ff ff ff ff       	mov    $0xffffffff,%esi
80104796:	eb ef                	jmp    80104787 <clone+0x117>
80104798:	90                   	nop
80104799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801047a0 <join>:

int
join(void **stack)
{
801047a0:	55                   	push   %ebp
801047a1:	89 e5                	mov    %esp,%ebp
801047a3:	56                   	push   %esi
801047a4:	53                   	push   %ebx
  cprintf("in join, stack pointer = %p\n",*stack);
801047a5:	8b 45 08             	mov    0x8(%ebp),%eax
801047a8:	83 ec 08             	sub    $0x8,%esp
801047ab:	ff 30                	pushl  (%eax)
801047ad:	68 b2 7f 10 80       	push   $0x80107fb2
801047b2:	e8 89 be ff ff       	call   80100640 <cprintf>
  struct proc *curproc = proc;
  struct proc *p;
  int havekids;

  acquire(&ptable.lock);
801047b7:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
  struct proc *curproc = proc;
801047be:	65 8b 35 04 00 00 00 	mov    %gs:0x4,%esi
  acquire(&ptable.lock);
801047c5:	e8 66 02 00 00       	call   80104a30 <acquire>
801047ca:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801047cd:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047cf:	bb 14 29 11 80       	mov    $0x80112914,%ebx
801047d4:	eb 18                	jmp    801047ee <join+0x4e>
801047d6:	8d 76 00             	lea    0x0(%esi),%esi
801047d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801047e0:	81 c3 28 01 00 00    	add    $0x128,%ebx
801047e6:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
801047ec:	73 21                	jae    8010480f <join+0x6f>
      if(p->pthread != curproc)
801047ee:	39 b3 18 01 00 00    	cmp    %esi,0x118(%ebx)
801047f4:	75 ea                	jne    801047e0 <join+0x40>
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
801047f6:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801047fa:	74 34                	je     80104830 <join+0x90>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047fc:	81 c3 28 01 00 00    	add    $0x128,%ebx
      havekids = 1;
80104802:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104807:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
8010480d:	72 df                	jb     801047ee <join+0x4e>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010480f:	85 c0                	test   %eax,%eax
80104811:	74 77                	je     8010488a <join+0xea>
80104813:	8b 46 48             	mov    0x48(%esi),%eax
80104816:	85 c0                	test   %eax,%eax
80104818:	75 70                	jne    8010488a <join+0xea>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010481a:	83 ec 08             	sub    $0x8,%esp
8010481d:	68 e0 28 11 80       	push   $0x801128e0
80104822:	56                   	push   %esi
80104823:	e8 68 f8 ff ff       	call   80104090 <sleep>
    havekids = 0;
80104828:	83 c4 10             	add    $0x10,%esp
8010482b:	eb a0                	jmp    801047cd <join+0x2d>
8010482d:	8d 76 00             	lea    0x0(%esi),%esi
        kfree(p->kstack);
80104830:	83 ec 0c             	sub    $0xc,%esp
80104833:	ff 73 08             	pushl  0x8(%ebx)
        int pid = p->pid;
80104836:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104839:	e8 d2 da ff ff       	call   80102310 <kfree>
        release(&ptable.lock);
8010483e:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
        p->kstack = 0;
80104845:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        p->state = UNUSED;
8010484c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
80104853:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010485a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->pthread = 0;
80104861:	c7 83 18 01 00 00 00 	movl   $0x0,0x118(%ebx)
80104868:	00 00 00 
        p->name[0] = 0;
8010486b:	c6 83 90 00 00 00 00 	movb   $0x0,0x90(%ebx)
        p->killed = 0;
80104872:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        release(&ptable.lock);
80104879:	e8 72 03 00 00       	call   80104bf0 <release>
        return pid;
8010487e:	83 c4 10             	add    $0x10,%esp
  }

  return 0;
}
80104881:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104884:	89 f0                	mov    %esi,%eax
80104886:	5b                   	pop    %ebx
80104887:	5e                   	pop    %esi
80104888:	5d                   	pop    %ebp
80104889:	c3                   	ret    
      release(&ptable.lock);
8010488a:	83 ec 0c             	sub    $0xc,%esp
      return -1;
8010488d:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104892:	68 e0 28 11 80       	push   $0x801128e0
80104897:	e8 54 03 00 00       	call   80104bf0 <release>
      return -1;
8010489c:	83 c4 10             	add    $0x10,%esp
8010489f:	eb e0                	jmp    80104881 <join+0xe1>
801048a1:	eb 0d                	jmp    801048b0 <cps>
801048a3:	90                   	nop
801048a4:	90                   	nop
801048a5:	90                   	nop
801048a6:	90                   	nop
801048a7:	90                   	nop
801048a8:	90                   	nop
801048a9:	90                   	nop
801048aa:	90                   	nop
801048ab:	90                   	nop
801048ac:	90                   	nop
801048ad:	90                   	nop
801048ae:	90                   	nop
801048af:	90                   	nop

801048b0 <cps>:

int cps(void)
{
801048b0:	55                   	push   %ebp
801048b1:	89 e5                	mov    %esp,%ebp
801048b3:	53                   	push   %ebx
801048b4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("sti");
801048b7:	fb                   	sti    
  struct proc *p;
  sti(); // Enable interrupts
  acquire(&ptable.lock);
801048b8:	68 e0 28 11 80       	push   $0x801128e0
  cprintf("name\tpid\tstate\t\tpriority\n");
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048bd:	bb 14 29 11 80       	mov    $0x80112914,%ebx
  acquire(&ptable.lock);
801048c2:	e8 69 01 00 00       	call   80104a30 <acquire>
  cprintf("name\tpid\tstate\t\tpriority\n");
801048c7:	c7 04 24 cf 7f 10 80 	movl   $0x80107fcf,(%esp)
801048ce:	e8 6d bd ff ff       	call   80100640 <cprintf>
801048d3:	83 c4 10             	add    $0x10,%esp
801048d6:	eb 2d                	jmp    80104905 <cps+0x55>
801048d8:	90                   	nop
801048d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  {
    if (p->state == SLEEPING)
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
    else if (p->state == RUNNING)
801048e0:	83 f8 04             	cmp    $0x4,%eax
801048e3:	74 6b                	je     80104950 <cps+0xa0>
      cprintf("%s\t%d\tRUNNING\t\t%d\n", p->name, p->pid, p->priority);
    else if (p->state == RUNNABLE)
801048e5:	83 f8 03             	cmp    $0x3,%eax
801048e8:	0f 84 82 00 00 00    	je     80104970 <cps+0xc0>
      cprintf("%s\t%d\tRUNNABLE\t%d\n", p->name, p->pid, p->priority);
    else if (p->state == ZOMBIE)
801048ee:	83 f8 05             	cmp    $0x5,%eax
801048f1:	0f 84 a1 00 00 00    	je     80104998 <cps+0xe8>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048f7:	81 c3 28 01 00 00    	add    $0x128,%ebx
801048fd:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
80104903:	73 33                	jae    80104938 <cps+0x88>
    if (p->state == SLEEPING)
80104905:	8b 43 0c             	mov    0xc(%ebx),%eax
80104908:	83 f8 02             	cmp    $0x2,%eax
8010490b:	75 d3                	jne    801048e0 <cps+0x30>
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
8010490d:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80104913:	ff b3 20 01 00 00    	pushl  0x120(%ebx)
80104919:	ff 73 10             	pushl  0x10(%ebx)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010491c:	81 c3 28 01 00 00    	add    $0x128,%ebx
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
80104922:	50                   	push   %eax
80104923:	68 e9 7f 10 80       	push   $0x80107fe9
80104928:	e8 13 bd ff ff       	call   80100640 <cprintf>
8010492d:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104930:	81 fb 14 73 11 80    	cmp    $0x80117314,%ebx
80104936:	72 cd                	jb     80104905 <cps+0x55>
      cprintf("%s\t%d\tZOMBIE\t%d\n", p->name, p->pid, p->priority);
  }
  release(&ptable.lock);
80104938:	83 ec 0c             	sub    $0xc,%esp
8010493b:	68 e0 28 11 80       	push   $0x801128e0
80104940:	e8 ab 02 00 00       	call   80104bf0 <release>
  return 0;
}
80104945:	31 c0                	xor    %eax,%eax
80104947:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010494a:	c9                   	leave  
8010494b:	c3                   	ret    
8010494c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      cprintf("%s\t%d\tRUNNING\t\t%d\n", p->name, p->pid, p->priority);
80104950:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80104956:	ff b3 20 01 00 00    	pushl  0x120(%ebx)
8010495c:	ff 73 10             	pushl  0x10(%ebx)
8010495f:	50                   	push   %eax
80104960:	68 fc 7f 10 80       	push   $0x80107ffc
80104965:	e8 d6 bc ff ff       	call   80100640 <cprintf>
8010496a:	83 c4 10             	add    $0x10,%esp
8010496d:	eb 88                	jmp    801048f7 <cps+0x47>
8010496f:	90                   	nop
      cprintf("%s\t%d\tRUNNABLE\t%d\n", p->name, p->pid, p->priority);
80104970:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
80104976:	ff b3 20 01 00 00    	pushl  0x120(%ebx)
8010497c:	ff 73 10             	pushl  0x10(%ebx)
8010497f:	50                   	push   %eax
80104980:	68 0f 80 10 80       	push   $0x8010800f
80104985:	e8 b6 bc ff ff       	call   80100640 <cprintf>
8010498a:	83 c4 10             	add    $0x10,%esp
8010498d:	e9 65 ff ff ff       	jmp    801048f7 <cps+0x47>
80104992:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("%s\t%d\tZOMBIE\t%d\n", p->name, p->pid, p->priority);
80104998:	8d 83 90 00 00 00    	lea    0x90(%ebx),%eax
8010499e:	ff b3 20 01 00 00    	pushl  0x120(%ebx)
801049a4:	ff 73 10             	pushl  0x10(%ebx)
801049a7:	50                   	push   %eax
801049a8:	68 22 80 10 80       	push   $0x80108022
801049ad:	e8 8e bc ff ff       	call   80100640 <cprintf>
801049b2:	83 c4 10             	add    $0x10,%esp
801049b5:	e9 3d ff ff ff       	jmp    801048f7 <cps+0x47>
801049ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801049c0 <chpri>:

int chpri(int pid, int priority)
{
801049c0:	55                   	push   %ebp
801049c1:	89 e5                	mov    %esp,%ebp
801049c3:	53                   	push   %ebx
801049c4:	83 ec 10             	sub    $0x10,%esp
801049c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;
  acquire(&ptable.lock);
801049ca:	68 e0 28 11 80       	push   $0x801128e0
801049cf:	e8 5c 00 00 00       	call   80104a30 <acquire>
801049d4:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801049d7:	ba 14 29 11 80       	mov    $0x80112914,%edx
801049dc:	eb 10                	jmp    801049ee <chpri+0x2e>
801049de:	66 90                	xchg   %ax,%ax
801049e0:	81 c2 28 01 00 00    	add    $0x128,%edx
801049e6:	81 fa 14 73 11 80    	cmp    $0x80117314,%edx
801049ec:	73 0e                	jae    801049fc <chpri+0x3c>
  {
    if (p->pid == pid)
801049ee:	39 5a 10             	cmp    %ebx,0x10(%edx)
801049f1:	75 ed                	jne    801049e0 <chpri+0x20>
    {
      p->priority = priority;
801049f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f6:	89 82 20 01 00 00    	mov    %eax,0x120(%edx)
      break;
    }
  }
  release(&ptable.lock);
801049fc:	83 ec 0c             	sub    $0xc,%esp
801049ff:	68 e0 28 11 80       	push   $0x801128e0
80104a04:	e8 e7 01 00 00       	call   80104bf0 <release>
  return pid;
}
80104a09:	89 d8                	mov    %ebx,%eax
80104a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a0e:	c9                   	leave  
80104a0f:	c3                   	ret    

80104a10 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a10:	55                   	push   %ebp
80104a11:	89 e5                	mov    %esp,%ebp
80104a13:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104a16:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104a19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
80104a1f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104a22:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104a29:	5d                   	pop    %ebp
80104a2a:	c3                   	ret    
80104a2b:	90                   	nop
80104a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104a30 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104a30:	55                   	push   %ebp
80104a31:	89 e5                	mov    %esp,%ebp
80104a33:	53                   	push   %ebx
80104a34:	83 ec 04             	sub    $0x4,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a37:	9c                   	pushf  
80104a38:	5a                   	pop    %edx
  asm volatile("cli");
80104a39:	fa                   	cli    
{
  int eflags;

  eflags = readeflags();
  cli();
  if(cpu->ncli == 0)
80104a3a:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80104a41:	8b 81 ac 00 00 00    	mov    0xac(%ecx),%eax
80104a47:	85 c0                	test   %eax,%eax
80104a49:	75 0c                	jne    80104a57 <acquire+0x27>
    cpu->intena = eflags & FL_IF;
80104a4b:	81 e2 00 02 00 00    	and    $0x200,%edx
80104a51:	89 91 b0 00 00 00    	mov    %edx,0xb0(%ecx)
  if(holding(lk))
80104a57:	8b 55 08             	mov    0x8(%ebp),%edx
  cpu->ncli += 1;
80104a5a:	83 c0 01             	add    $0x1,%eax
80104a5d:	89 81 ac 00 00 00    	mov    %eax,0xac(%ecx)
  return lock->locked && lock->cpu == cpu;
80104a63:	8b 02                	mov    (%edx),%eax
80104a65:	85 c0                	test   %eax,%eax
80104a67:	74 05                	je     80104a6e <acquire+0x3e>
80104a69:	39 4a 08             	cmp    %ecx,0x8(%edx)
80104a6c:	74 74                	je     80104ae2 <acquire+0xb2>
  asm volatile("lock; xchgl %0, %1" :
80104a6e:	b9 01 00 00 00       	mov    $0x1,%ecx
80104a73:	90                   	nop
80104a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a78:	89 c8                	mov    %ecx,%eax
80104a7a:	f0 87 02             	lock xchg %eax,(%edx)
  while(xchg(&lk->locked, 1) != 0)
80104a7d:	85 c0                	test   %eax,%eax
80104a7f:	75 f7                	jne    80104a78 <acquire+0x48>
  __sync_synchronize();
80104a81:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = cpu;
80104a86:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a89:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  for(i = 0; i < 10; i++){
80104a8f:	31 d2                	xor    %edx,%edx
  lk->cpu = cpu;
80104a91:	89 41 08             	mov    %eax,0x8(%ecx)
  getcallerpcs(&lk, lk->pcs);
80104a94:	83 c1 0c             	add    $0xc,%ecx
  ebp = (uint*)v - 2;
80104a97:	89 e8                	mov    %ebp,%eax
80104a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104aa0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104aa6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104aac:	77 1a                	ja     80104ac8 <acquire+0x98>
    pcs[i] = ebp[1];     // saved %eip
80104aae:	8b 58 04             	mov    0x4(%eax),%ebx
80104ab1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104ab4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104ab7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104ab9:	83 fa 0a             	cmp    $0xa,%edx
80104abc:	75 e2                	jne    80104aa0 <acquire+0x70>
}
80104abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ac1:	c9                   	leave  
80104ac2:	c3                   	ret    
80104ac3:	90                   	nop
80104ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104ac8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104acb:	83 c1 28             	add    $0x28,%ecx
80104ace:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104ad0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104ad6:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104ad9:	39 c8                	cmp    %ecx,%eax
80104adb:	75 f3                	jne    80104ad0 <acquire+0xa0>
}
80104add:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ae0:	c9                   	leave  
80104ae1:	c3                   	ret    
    panic("acquire");
80104ae2:	83 ec 0c             	sub    $0xc,%esp
80104ae5:	68 3c 81 10 80       	push   $0x8010813c
80104aea:	e8 81 b8 ff ff       	call   80100370 <panic>
80104aef:	90                   	nop

80104af0 <getcallerpcs>:
{
80104af0:	55                   	push   %ebp
  for(i = 0; i < 10; i++){
80104af1:	31 d2                	xor    %edx,%edx
{
80104af3:	89 e5                	mov    %esp,%ebp
80104af5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104af6:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
80104afc:	83 e8 08             	sub    $0x8,%eax
80104aff:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b00:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104b06:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104b0c:	77 1a                	ja     80104b28 <getcallerpcs+0x38>
    pcs[i] = ebp[1];     // saved %eip
80104b0e:	8b 58 04             	mov    0x4(%eax),%ebx
80104b11:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104b14:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104b17:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104b19:	83 fa 0a             	cmp    $0xa,%edx
80104b1c:	75 e2                	jne    80104b00 <getcallerpcs+0x10>
}
80104b1e:	5b                   	pop    %ebx
80104b1f:	5d                   	pop    %ebp
80104b20:	c3                   	ret    
80104b21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b28:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104b2b:	83 c1 28             	add    $0x28,%ecx
80104b2e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104b30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b36:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104b39:	39 c1                	cmp    %eax,%ecx
80104b3b:	75 f3                	jne    80104b30 <getcallerpcs+0x40>
}
80104b3d:	5b                   	pop    %ebx
80104b3e:	5d                   	pop    %ebp
80104b3f:	c3                   	ret    

80104b40 <holding>:
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
80104b46:	8b 02                	mov    (%edx),%eax
80104b48:	85 c0                	test   %eax,%eax
80104b4a:	74 14                	je     80104b60 <holding+0x20>
80104b4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b52:	39 42 08             	cmp    %eax,0x8(%edx)
}
80104b55:	5d                   	pop    %ebp
  return lock->locked && lock->cpu == cpu;
80104b56:	0f 94 c0             	sete   %al
80104b59:	0f b6 c0             	movzbl %al,%eax
}
80104b5c:	c3                   	ret    
80104b5d:	8d 76 00             	lea    0x0(%esi),%esi
80104b60:	31 c0                	xor    %eax,%eax
80104b62:	5d                   	pop    %ebp
80104b63:	c3                   	ret    
80104b64:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104b6a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104b70 <pushcli>:
{
80104b70:	55                   	push   %ebp
80104b71:	89 e5                	mov    %esp,%ebp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b73:	9c                   	pushf  
80104b74:	59                   	pop    %ecx
  asm volatile("cli");
80104b75:	fa                   	cli    
  if(cpu->ncli == 0)
80104b76:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b7d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104b83:	85 c0                	test   %eax,%eax
80104b85:	75 0c                	jne    80104b93 <pushcli+0x23>
    cpu->intena = eflags & FL_IF;
80104b87:	81 e1 00 02 00 00    	and    $0x200,%ecx
80104b8d:	89 8a b0 00 00 00    	mov    %ecx,0xb0(%edx)
  cpu->ncli += 1;
80104b93:	83 c0 01             	add    $0x1,%eax
80104b96:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
}
80104b9c:	5d                   	pop    %ebp
80104b9d:	c3                   	ret    
80104b9e:	66 90                	xchg   %ax,%ax

80104ba0 <popcli>:

void
popcli(void)
{
80104ba0:	55                   	push   %ebp
80104ba1:	89 e5                	mov    %esp,%ebp
80104ba3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ba6:	9c                   	pushf  
80104ba7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104ba8:	f6 c4 02             	test   $0x2,%ah
80104bab:	75 2c                	jne    80104bd9 <popcli+0x39>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
80104bad:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bb4:	83 aa ac 00 00 00 01 	subl   $0x1,0xac(%edx)
80104bbb:	78 0f                	js     80104bcc <popcli+0x2c>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
80104bbd:	75 0b                	jne    80104bca <popcli+0x2a>
80104bbf:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
80104bc5:	85 c0                	test   %eax,%eax
80104bc7:	74 01                	je     80104bca <popcli+0x2a>
  asm volatile("sti");
80104bc9:	fb                   	sti    
    sti();
}
80104bca:	c9                   	leave  
80104bcb:	c3                   	ret    
    panic("popcli");
80104bcc:	83 ec 0c             	sub    $0xc,%esp
80104bcf:	68 5b 81 10 80       	push   $0x8010815b
80104bd4:	e8 97 b7 ff ff       	call   80100370 <panic>
    panic("popcli - interruptible");
80104bd9:	83 ec 0c             	sub    $0xc,%esp
80104bdc:	68 44 81 10 80       	push   $0x80108144
80104be1:	e8 8a b7 ff ff       	call   80100370 <panic>
80104be6:	8d 76 00             	lea    0x0(%esi),%esi
80104be9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104bf0 <release>:
{
80104bf0:	55                   	push   %ebp
80104bf1:	89 e5                	mov    %esp,%ebp
80104bf3:	83 ec 08             	sub    $0x8,%esp
80104bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked && lock->cpu == cpu;
80104bf9:	8b 10                	mov    (%eax),%edx
80104bfb:	85 d2                	test   %edx,%edx
80104bfd:	74 2b                	je     80104c2a <release+0x3a>
80104bff:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c06:	39 50 08             	cmp    %edx,0x8(%eax)
80104c09:	75 1f                	jne    80104c2a <release+0x3a>
  lk->pcs[0] = 0;
80104c0b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c12:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  __sync_synchronize();
80104c19:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->locked = 0;
80104c1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80104c24:	c9                   	leave  
  popcli();
80104c25:	e9 76 ff ff ff       	jmp    80104ba0 <popcli>
    panic("release");
80104c2a:	83 ec 0c             	sub    $0xc,%esp
80104c2d:	68 62 81 10 80       	push   $0x80108162
80104c32:	e8 39 b7 ff ff       	call   80100370 <panic>
80104c37:	66 90                	xchg   %ax,%ax
80104c39:	66 90                	xchg   %ax,%ax
80104c3b:	66 90                	xchg   %ax,%ax
80104c3d:	66 90                	xchg   %ax,%ax
80104c3f:	90                   	nop

80104c40 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104c40:	55                   	push   %ebp
80104c41:	89 e5                	mov    %esp,%ebp
80104c43:	57                   	push   %edi
80104c44:	53                   	push   %ebx
80104c45:	8b 55 08             	mov    0x8(%ebp),%edx
80104c48:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104c4b:	f6 c2 03             	test   $0x3,%dl
80104c4e:	75 05                	jne    80104c55 <memset+0x15>
80104c50:	f6 c1 03             	test   $0x3,%cl
80104c53:	74 13                	je     80104c68 <memset+0x28>
  asm volatile("cld; rep stosb" :
80104c55:	89 d7                	mov    %edx,%edi
80104c57:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c5a:	fc                   	cld    
80104c5b:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104c5d:	5b                   	pop    %ebx
80104c5e:	89 d0                	mov    %edx,%eax
80104c60:	5f                   	pop    %edi
80104c61:	5d                   	pop    %ebp
80104c62:	c3                   	ret    
80104c63:	90                   	nop
80104c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c &= 0xFF;
80104c68:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104c6c:	c1 e9 02             	shr    $0x2,%ecx
80104c6f:	89 f8                	mov    %edi,%eax
80104c71:	89 fb                	mov    %edi,%ebx
80104c73:	c1 e0 18             	shl    $0x18,%eax
80104c76:	c1 e3 10             	shl    $0x10,%ebx
80104c79:	09 d8                	or     %ebx,%eax
80104c7b:	09 f8                	or     %edi,%eax
80104c7d:	c1 e7 08             	shl    $0x8,%edi
80104c80:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104c82:	89 d7                	mov    %edx,%edi
80104c84:	fc                   	cld    
80104c85:	f3 ab                	rep stos %eax,%es:(%edi)
}
80104c87:	5b                   	pop    %ebx
80104c88:	89 d0                	mov    %edx,%eax
80104c8a:	5f                   	pop    %edi
80104c8b:	5d                   	pop    %ebp
80104c8c:	c3                   	ret    
80104c8d:	8d 76 00             	lea    0x0(%esi),%esi

80104c90 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104c90:	55                   	push   %ebp
80104c91:	89 e5                	mov    %esp,%ebp
80104c93:	57                   	push   %edi
80104c94:	56                   	push   %esi
80104c95:	53                   	push   %ebx
80104c96:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104c99:	8b 75 08             	mov    0x8(%ebp),%esi
80104c9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104c9f:	85 db                	test   %ebx,%ebx
80104ca1:	74 29                	je     80104ccc <memcmp+0x3c>
    if(*s1 != *s2)
80104ca3:	0f b6 16             	movzbl (%esi),%edx
80104ca6:	0f b6 0f             	movzbl (%edi),%ecx
80104ca9:	38 d1                	cmp    %dl,%cl
80104cab:	75 2b                	jne    80104cd8 <memcmp+0x48>
80104cad:	b8 01 00 00 00       	mov    $0x1,%eax
80104cb2:	eb 14                	jmp    80104cc8 <memcmp+0x38>
80104cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104cb8:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
80104cbc:	83 c0 01             	add    $0x1,%eax
80104cbf:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
80104cc4:	38 ca                	cmp    %cl,%dl
80104cc6:	75 10                	jne    80104cd8 <memcmp+0x48>
  while(n-- > 0){
80104cc8:	39 d8                	cmp    %ebx,%eax
80104cca:	75 ec                	jne    80104cb8 <memcmp+0x28>
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
80104ccc:	5b                   	pop    %ebx
  return 0;
80104ccd:	31 c0                	xor    %eax,%eax
}
80104ccf:	5e                   	pop    %esi
80104cd0:	5f                   	pop    %edi
80104cd1:	5d                   	pop    %ebp
80104cd2:	c3                   	ret    
80104cd3:	90                   	nop
80104cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return *s1 - *s2;
80104cd8:	0f b6 c2             	movzbl %dl,%eax
}
80104cdb:	5b                   	pop    %ebx
      return *s1 - *s2;
80104cdc:	29 c8                	sub    %ecx,%eax
}
80104cde:	5e                   	pop    %esi
80104cdf:	5f                   	pop    %edi
80104ce0:	5d                   	pop    %ebp
80104ce1:	c3                   	ret    
80104ce2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104cf0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104cf0:	55                   	push   %ebp
80104cf1:	89 e5                	mov    %esp,%ebp
80104cf3:	56                   	push   %esi
80104cf4:	53                   	push   %ebx
80104cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104cfb:	8b 75 10             	mov    0x10(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104cfe:	39 c3                	cmp    %eax,%ebx
80104d00:	73 26                	jae    80104d28 <memmove+0x38>
80104d02:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
80104d05:	39 c8                	cmp    %ecx,%eax
80104d07:	73 1f                	jae    80104d28 <memmove+0x38>
    s += n;
    d += n;
    while(n-- > 0)
80104d09:	85 f6                	test   %esi,%esi
80104d0b:	8d 56 ff             	lea    -0x1(%esi),%edx
80104d0e:	74 0f                	je     80104d1f <memmove+0x2f>
      *--d = *--s;
80104d10:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104d14:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    while(n-- > 0)
80104d17:	83 ea 01             	sub    $0x1,%edx
80104d1a:	83 fa ff             	cmp    $0xffffffff,%edx
80104d1d:	75 f1                	jne    80104d10 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104d1f:	5b                   	pop    %ebx
80104d20:	5e                   	pop    %esi
80104d21:	5d                   	pop    %ebp
80104d22:	c3                   	ret    
80104d23:	90                   	nop
80104d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
80104d28:	31 d2                	xor    %edx,%edx
80104d2a:	85 f6                	test   %esi,%esi
80104d2c:	74 f1                	je     80104d1f <memmove+0x2f>
80104d2e:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80104d30:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104d34:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80104d37:	83 c2 01             	add    $0x1,%edx
    while(n-- > 0)
80104d3a:	39 d6                	cmp    %edx,%esi
80104d3c:	75 f2                	jne    80104d30 <memmove+0x40>
}
80104d3e:	5b                   	pop    %ebx
80104d3f:	5e                   	pop    %esi
80104d40:	5d                   	pop    %ebp
80104d41:	c3                   	ret    
80104d42:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104d50 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104d50:	55                   	push   %ebp
80104d51:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80104d53:	5d                   	pop    %ebp
  return memmove(dst, src, n);
80104d54:	eb 9a                	jmp    80104cf0 <memmove>
80104d56:	8d 76 00             	lea    0x0(%esi),%esi
80104d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104d60 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104d60:	55                   	push   %ebp
80104d61:	89 e5                	mov    %esp,%ebp
80104d63:	57                   	push   %edi
80104d64:	56                   	push   %esi
80104d65:	8b 7d 10             	mov    0x10(%ebp),%edi
80104d68:	53                   	push   %ebx
80104d69:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  while(n > 0 && *p && *p == *q)
80104d6f:	85 ff                	test   %edi,%edi
80104d71:	74 2f                	je     80104da2 <strncmp+0x42>
80104d73:	0f b6 01             	movzbl (%ecx),%eax
80104d76:	0f b6 1e             	movzbl (%esi),%ebx
80104d79:	84 c0                	test   %al,%al
80104d7b:	74 37                	je     80104db4 <strncmp+0x54>
80104d7d:	38 c3                	cmp    %al,%bl
80104d7f:	75 33                	jne    80104db4 <strncmp+0x54>
80104d81:	01 f7                	add    %esi,%edi
80104d83:	eb 13                	jmp    80104d98 <strncmp+0x38>
80104d85:	8d 76 00             	lea    0x0(%esi),%esi
80104d88:	0f b6 01             	movzbl (%ecx),%eax
80104d8b:	84 c0                	test   %al,%al
80104d8d:	74 21                	je     80104db0 <strncmp+0x50>
80104d8f:	0f b6 1a             	movzbl (%edx),%ebx
80104d92:	89 d6                	mov    %edx,%esi
80104d94:	38 d8                	cmp    %bl,%al
80104d96:	75 1c                	jne    80104db4 <strncmp+0x54>
    n--, p++, q++;
80104d98:	8d 56 01             	lea    0x1(%esi),%edx
80104d9b:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104d9e:	39 fa                	cmp    %edi,%edx
80104da0:	75 e6                	jne    80104d88 <strncmp+0x28>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
80104da2:	5b                   	pop    %ebx
    return 0;
80104da3:	31 c0                	xor    %eax,%eax
}
80104da5:	5e                   	pop    %esi
80104da6:	5f                   	pop    %edi
80104da7:	5d                   	pop    %ebp
80104da8:	c3                   	ret    
80104da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104db0:	0f b6 5e 01          	movzbl 0x1(%esi),%ebx
  return (uchar)*p - (uchar)*q;
80104db4:	29 d8                	sub    %ebx,%eax
}
80104db6:	5b                   	pop    %ebx
80104db7:	5e                   	pop    %esi
80104db8:	5f                   	pop    %edi
80104db9:	5d                   	pop    %ebp
80104dba:	c3                   	ret    
80104dbb:	90                   	nop
80104dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104dc0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104dc0:	55                   	push   %ebp
80104dc1:	89 e5                	mov    %esp,%ebp
80104dc3:	56                   	push   %esi
80104dc4:	53                   	push   %ebx
80104dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104dcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104dce:	89 c2                	mov    %eax,%edx
80104dd0:	eb 19                	jmp    80104deb <strncpy+0x2b>
80104dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104dd8:	83 c3 01             	add    $0x1,%ebx
80104ddb:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
80104ddf:	83 c2 01             	add    $0x1,%edx
80104de2:	84 c9                	test   %cl,%cl
80104de4:	88 4a ff             	mov    %cl,-0x1(%edx)
80104de7:	74 09                	je     80104df2 <strncpy+0x32>
80104de9:	89 f1                	mov    %esi,%ecx
80104deb:	85 c9                	test   %ecx,%ecx
80104ded:	8d 71 ff             	lea    -0x1(%ecx),%esi
80104df0:	7f e6                	jg     80104dd8 <strncpy+0x18>
    ;
  while(n-- > 0)
80104df2:	31 c9                	xor    %ecx,%ecx
80104df4:	85 f6                	test   %esi,%esi
80104df6:	7e 17                	jle    80104e0f <strncpy+0x4f>
80104df8:	90                   	nop
80104df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104e00:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
80104e04:	89 f3                	mov    %esi,%ebx
80104e06:	83 c1 01             	add    $0x1,%ecx
80104e09:	29 cb                	sub    %ecx,%ebx
  while(n-- > 0)
80104e0b:	85 db                	test   %ebx,%ebx
80104e0d:	7f f1                	jg     80104e00 <strncpy+0x40>
  return os;
}
80104e0f:	5b                   	pop    %ebx
80104e10:	5e                   	pop    %esi
80104e11:	5d                   	pop    %ebp
80104e12:	c3                   	ret    
80104e13:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104e20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104e20:	55                   	push   %ebp
80104e21:	89 e5                	mov    %esp,%ebp
80104e23:	56                   	push   %esi
80104e24:	53                   	push   %ebx
80104e25:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104e28:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104e2e:	85 c9                	test   %ecx,%ecx
80104e30:	7e 26                	jle    80104e58 <safestrcpy+0x38>
80104e32:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
80104e36:	89 c1                	mov    %eax,%ecx
80104e38:	eb 17                	jmp    80104e51 <safestrcpy+0x31>
80104e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104e40:	83 c2 01             	add    $0x1,%edx
80104e43:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
80104e47:	83 c1 01             	add    $0x1,%ecx
80104e4a:	84 db                	test   %bl,%bl
80104e4c:	88 59 ff             	mov    %bl,-0x1(%ecx)
80104e4f:	74 04                	je     80104e55 <safestrcpy+0x35>
80104e51:	39 f2                	cmp    %esi,%edx
80104e53:	75 eb                	jne    80104e40 <safestrcpy+0x20>
    ;
  *s = 0;
80104e55:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104e58:	5b                   	pop    %ebx
80104e59:	5e                   	pop    %esi
80104e5a:	5d                   	pop    %ebp
80104e5b:	c3                   	ret    
80104e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104e60 <strlen>:

int
strlen(const char *s)
{
80104e60:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104e61:	31 c0                	xor    %eax,%eax
{
80104e63:	89 e5                	mov    %esp,%ebp
80104e65:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104e68:	80 3a 00             	cmpb   $0x0,(%edx)
80104e6b:	74 0c                	je     80104e79 <strlen+0x19>
80104e6d:	8d 76 00             	lea    0x0(%esi),%esi
80104e70:	83 c0 01             	add    $0x1,%eax
80104e73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104e77:	75 f7                	jne    80104e70 <strlen+0x10>
    ;
  return n;
}
80104e79:	5d                   	pop    %ebp
80104e7a:	c3                   	ret    

80104e7b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104e7b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104e7f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104e83:	55                   	push   %ebp
  pushl %ebx
80104e84:	53                   	push   %ebx
  pushl %esi
80104e85:	56                   	push   %esi
  pushl %edi
80104e86:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104e87:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e89:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104e8b:	5f                   	pop    %edi
  popl %esi
80104e8c:	5e                   	pop    %esi
  popl %ebx
80104e8d:	5b                   	pop    %ebx
  popl %ebp
80104e8e:	5d                   	pop    %ebp
  ret
80104e8f:	c3                   	ret    

80104e90 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e90:	55                   	push   %ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80104e91:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80104e98:	89 e5                	mov    %esp,%ebp
80104e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  if(addr >= proc->sz || addr+4 > proc->sz)
80104e9d:	8b 12                	mov    (%edx),%edx
80104e9f:	39 c2                	cmp    %eax,%edx
80104ea1:	76 15                	jbe    80104eb8 <fetchint+0x28>
80104ea3:	8d 48 04             	lea    0x4(%eax),%ecx
80104ea6:	39 ca                	cmp    %ecx,%edx
80104ea8:	72 0e                	jb     80104eb8 <fetchint+0x28>
    return -1;
  *ip = *(int*)(addr);
80104eaa:	8b 10                	mov    (%eax),%edx
80104eac:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eaf:	89 10                	mov    %edx,(%eax)
  return 0;
80104eb1:	31 c0                	xor    %eax,%eax
}
80104eb3:	5d                   	pop    %ebp
80104eb4:	c3                   	ret    
80104eb5:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104eb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ebd:	5d                   	pop    %ebp
80104ebe:	c3                   	ret    
80104ebf:	90                   	nop

80104ec0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104ec0:	55                   	push   %ebp
  char *s, *ep;

  if(addr >= proc->sz)
80104ec1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80104ec7:	89 e5                	mov    %esp,%ebp
80104ec9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz)
80104ecc:	39 08                	cmp    %ecx,(%eax)
80104ece:	76 2c                	jbe    80104efc <fetchstr+0x3c>
    return -1;
  *pp = (char*)addr;
80104ed0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ed3:	89 c8                	mov    %ecx,%eax
80104ed5:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
80104ed7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ede:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
80104ee0:	39 d1                	cmp    %edx,%ecx
80104ee2:	73 18                	jae    80104efc <fetchstr+0x3c>
    if(*s == 0)
80104ee4:	80 39 00             	cmpb   $0x0,(%ecx)
80104ee7:	75 0c                	jne    80104ef5 <fetchstr+0x35>
80104ee9:	eb 25                	jmp    80104f10 <fetchstr+0x50>
80104eeb:	90                   	nop
80104eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104ef0:	80 38 00             	cmpb   $0x0,(%eax)
80104ef3:	74 13                	je     80104f08 <fetchstr+0x48>
  for(s = *pp; s < ep; s++)
80104ef5:	83 c0 01             	add    $0x1,%eax
80104ef8:	39 c2                	cmp    %eax,%edx
80104efa:	77 f4                	ja     80104ef0 <fetchstr+0x30>
    return -1;
80104efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return s - *pp;
  return -1;
}
80104f01:	5d                   	pop    %ebp
80104f02:	c3                   	ret    
80104f03:	90                   	nop
80104f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104f08:	29 c8                	sub    %ecx,%eax
80104f0a:	5d                   	pop    %ebp
80104f0b:	c3                   	ret    
80104f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
80104f10:	31 c0                	xor    %eax,%eax
}
80104f12:	5d                   	pop    %ebp
80104f13:	c3                   	ret    
80104f14:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104f1a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104f20 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f20:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80104f27:	55                   	push   %ebp
80104f28:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f2a:	8b 42 3c             	mov    0x3c(%edx),%eax
80104f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f30:	8b 12                	mov    (%edx),%edx
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f32:	8b 40 44             	mov    0x44(%eax),%eax
80104f35:	8d 04 88             	lea    (%eax,%ecx,4),%eax
80104f38:	8d 48 04             	lea    0x4(%eax),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f3b:	39 d1                	cmp    %edx,%ecx
80104f3d:	73 19                	jae    80104f58 <argint+0x38>
80104f3f:	8d 48 08             	lea    0x8(%eax),%ecx
80104f42:	39 ca                	cmp    %ecx,%edx
80104f44:	72 12                	jb     80104f58 <argint+0x38>
  *ip = *(int*)(addr);
80104f46:	8b 50 04             	mov    0x4(%eax),%edx
80104f49:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f4c:	89 10                	mov    %edx,(%eax)
  return 0;
80104f4e:	31 c0                	xor    %eax,%eax
}
80104f50:	5d                   	pop    %ebp
80104f51:	c3                   	ret    
80104f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f5d:	5d                   	pop    %ebp
80104f5e:	c3                   	ret    
80104f5f:	90                   	nop

80104f60 <argptr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104f66:	55                   	push   %ebp
80104f67:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f69:	8b 50 3c             	mov    0x3c(%eax),%edx
80104f6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f6f:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104f71:	8b 52 44             	mov    0x44(%edx),%edx
80104f74:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
80104f77:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f7a:	39 c1                	cmp    %eax,%ecx
80104f7c:	73 22                	jae    80104fa0 <argptr+0x40>
80104f7e:	8d 4a 08             	lea    0x8(%edx),%ecx
80104f81:	39 c8                	cmp    %ecx,%eax
80104f83:	72 1b                	jb     80104fa0 <argptr+0x40>
  *ip = *(int*)(addr);
80104f85:	8b 52 04             	mov    0x4(%edx),%edx
  int i;

  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80104f88:	39 c2                	cmp    %eax,%edx
80104f8a:	73 14                	jae    80104fa0 <argptr+0x40>
80104f8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104f8f:	01 d1                	add    %edx,%ecx
80104f91:	39 c1                	cmp    %eax,%ecx
80104f93:	77 0b                	ja     80104fa0 <argptr+0x40>
    return -1;
  *pp = (char*)i;
80104f95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f98:	89 10                	mov    %edx,(%eax)
  return 0;
80104f9a:	31 c0                	xor    %eax,%eax
}
80104f9c:	5d                   	pop    %ebp
80104f9d:	c3                   	ret    
80104f9e:	66 90                	xchg   %ax,%ax
    return -1;
80104fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fa5:	5d                   	pop    %ebp
80104fa6:	c3                   	ret    
80104fa7:	89 f6                	mov    %esi,%esi
80104fa9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104fb0 <argstr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104fb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104fb6:	55                   	push   %ebp
80104fb7:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104fb9:	8b 50 3c             	mov    0x3c(%eax),%edx
80104fbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104fbf:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104fc1:	8b 52 44             	mov    0x44(%edx),%edx
80104fc4:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
80104fc7:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104fca:	39 c1                	cmp    %eax,%ecx
80104fcc:	73 3e                	jae    8010500c <argstr+0x5c>
80104fce:	8d 4a 08             	lea    0x8(%edx),%ecx
80104fd1:	39 c8                	cmp    %ecx,%eax
80104fd3:	72 37                	jb     8010500c <argstr+0x5c>
  *ip = *(int*)(addr);
80104fd5:	8b 4a 04             	mov    0x4(%edx),%ecx
  if(addr >= proc->sz)
80104fd8:	39 c1                	cmp    %eax,%ecx
80104fda:	73 30                	jae    8010500c <argstr+0x5c>
  *pp = (char*)addr;
80104fdc:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fdf:	89 c8                	mov    %ecx,%eax
80104fe1:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
80104fe3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fea:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
80104fec:	39 d1                	cmp    %edx,%ecx
80104fee:	73 1c                	jae    8010500c <argstr+0x5c>
    if(*s == 0)
80104ff0:	80 39 00             	cmpb   $0x0,(%ecx)
80104ff3:	75 10                	jne    80105005 <argstr+0x55>
80104ff5:	eb 29                	jmp    80105020 <argstr+0x70>
80104ff7:	89 f6                	mov    %esi,%esi
80104ff9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80105000:	80 38 00             	cmpb   $0x0,(%eax)
80105003:	74 13                	je     80105018 <argstr+0x68>
  for(s = *pp; s < ep; s++)
80105005:	83 c0 01             	add    $0x1,%eax
80105008:	39 c2                	cmp    %eax,%edx
8010500a:	77 f4                	ja     80105000 <argstr+0x50>
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
8010500c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchstr(addr, pp);
}
80105011:	5d                   	pop    %ebp
80105012:	c3                   	ret    
80105013:	90                   	nop
80105014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105018:	29 c8                	sub    %ecx,%eax
8010501a:	5d                   	pop    %ebp
8010501b:	c3                   	ret    
8010501c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
80105020:	31 c0                	xor    %eax,%eax
}
80105022:	5d                   	pop    %ebp
80105023:	c3                   	ret    
80105024:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010502a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80105030 <syscall>:
[SYS_chpri]     sys_chpri,
};

void
syscall(void)
{
80105030:	55                   	push   %ebp
80105031:	89 e5                	mov    %esp,%ebp
80105033:	83 ec 08             	sub    $0x8,%esp
  int num;

  num = proc->tf->eax;
80105036:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010503d:	8b 42 3c             	mov    0x3c(%edx),%eax
80105040:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105043:	8d 48 ff             	lea    -0x1(%eax),%ecx
80105046:	83 f9 1b             	cmp    $0x1b,%ecx
80105049:	77 25                	ja     80105070 <syscall+0x40>
8010504b:	8b 0c 85 a0 81 10 80 	mov    -0x7fef7e60(,%eax,4),%ecx
80105052:	85 c9                	test   %ecx,%ecx
80105054:	74 1a                	je     80105070 <syscall+0x40>
    proc->tf->eax = syscalls[num]();
80105056:	ff d1                	call   *%ecx
80105058:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010505f:	8b 52 3c             	mov    0x3c(%edx),%edx
80105062:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
80105065:	c9                   	leave  
80105066:	c3                   	ret    
80105067:	89 f6                	mov    %esi,%esi
80105069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    cprintf("%d %s: unknown sys call %d\n",
80105070:	50                   	push   %eax
            proc->pid, proc->name, num);
80105071:	8d 82 90 00 00 00    	lea    0x90(%edx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80105077:	50                   	push   %eax
80105078:	ff 72 10             	pushl  0x10(%edx)
8010507b:	68 6a 81 10 80       	push   $0x8010816a
80105080:	e8 bb b5 ff ff       	call   80100640 <cprintf>
    proc->tf->eax = -1;
80105085:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010508b:	83 c4 10             	add    $0x10,%esp
8010508e:	8b 40 3c             	mov    0x3c(%eax),%eax
80105091:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80105098:	c9                   	leave  
80105099:	c3                   	ret    
8010509a:	66 90                	xchg   %ax,%ax
8010509c:	66 90                	xchg   %ax,%ax
8010509e:	66 90                	xchg   %ax,%ax

801050a0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801050a0:	55                   	push   %ebp
801050a1:	89 e5                	mov    %esp,%ebp
801050a3:	57                   	push   %edi
801050a4:	56                   	push   %esi
801050a5:	53                   	push   %ebx
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801050a6:	8d 75 da             	lea    -0x26(%ebp),%esi
{
801050a9:	83 ec 44             	sub    $0x44,%esp
801050ac:	89 4d c0             	mov    %ecx,-0x40(%ebp)
801050af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
801050b2:	56                   	push   %esi
801050b3:	50                   	push   %eax
{
801050b4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
801050b7:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  if((dp = nameiparent(path, name)) == 0)
801050ba:	e8 21 ce ff ff       	call   80101ee0 <nameiparent>
801050bf:	83 c4 10             	add    $0x10,%esp
801050c2:	85 c0                	test   %eax,%eax
801050c4:	0f 84 46 01 00 00    	je     80105210 <create+0x170>
    return 0;
  ilock(dp);
801050ca:	83 ec 0c             	sub    $0xc,%esp
801050cd:	89 c3                	mov    %eax,%ebx
801050cf:	50                   	push   %eax
801050d0:	e8 3b c5 ff ff       	call   80101610 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801050d5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
801050d8:	83 c4 0c             	add    $0xc,%esp
801050db:	50                   	push   %eax
801050dc:	56                   	push   %esi
801050dd:	53                   	push   %ebx
801050de:	e8 9d ca ff ff       	call   80101b80 <dirlookup>
801050e3:	83 c4 10             	add    $0x10,%esp
801050e6:	85 c0                	test   %eax,%eax
801050e8:	89 c7                	mov    %eax,%edi
801050ea:	74 34                	je     80105120 <create+0x80>
    iunlockput(dp);
801050ec:	83 ec 0c             	sub    $0xc,%esp
801050ef:	53                   	push   %ebx
801050f0:	e8 eb c7 ff ff       	call   801018e0 <iunlockput>
    ilock(ip);
801050f5:	89 3c 24             	mov    %edi,(%esp)
801050f8:	e8 13 c5 ff ff       	call   80101610 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801050fd:	83 c4 10             	add    $0x10,%esp
80105100:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80105105:	0f 85 95 00 00 00    	jne    801051a0 <create+0x100>
8010510b:	66 83 7f 10 02       	cmpw   $0x2,0x10(%edi)
80105110:	0f 85 8a 00 00 00    	jne    801051a0 <create+0x100>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80105116:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105119:	89 f8                	mov    %edi,%eax
8010511b:	5b                   	pop    %ebx
8010511c:	5e                   	pop    %esi
8010511d:	5f                   	pop    %edi
8010511e:	5d                   	pop    %ebp
8010511f:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80105120:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80105124:	83 ec 08             	sub    $0x8,%esp
80105127:	50                   	push   %eax
80105128:	ff 33                	pushl  (%ebx)
8010512a:	e8 71 c3 ff ff       	call   801014a0 <ialloc>
8010512f:	83 c4 10             	add    $0x10,%esp
80105132:	85 c0                	test   %eax,%eax
80105134:	89 c7                	mov    %eax,%edi
80105136:	0f 84 e8 00 00 00    	je     80105224 <create+0x184>
  ilock(ip);
8010513c:	83 ec 0c             	sub    $0xc,%esp
8010513f:	50                   	push   %eax
80105140:	e8 cb c4 ff ff       	call   80101610 <ilock>
  ip->major = major;
80105145:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80105149:	66 89 47 12          	mov    %ax,0x12(%edi)
  ip->minor = minor;
8010514d:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
80105151:	66 89 47 14          	mov    %ax,0x14(%edi)
  ip->nlink = 1;
80105155:	b8 01 00 00 00       	mov    $0x1,%eax
8010515a:	66 89 47 16          	mov    %ax,0x16(%edi)
  iupdate(ip);
8010515e:	89 3c 24             	mov    %edi,(%esp)
80105161:	e8 fa c3 ff ff       	call   80101560 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80105166:	83 c4 10             	add    $0x10,%esp
80105169:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010516e:	74 50                	je     801051c0 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80105170:	83 ec 04             	sub    $0x4,%esp
80105173:	ff 77 04             	pushl  0x4(%edi)
80105176:	56                   	push   %esi
80105177:	53                   	push   %ebx
80105178:	e8 83 cc ff ff       	call   80101e00 <dirlink>
8010517d:	83 c4 10             	add    $0x10,%esp
80105180:	85 c0                	test   %eax,%eax
80105182:	0f 88 8f 00 00 00    	js     80105217 <create+0x177>
  iunlockput(dp);
80105188:	83 ec 0c             	sub    $0xc,%esp
8010518b:	53                   	push   %ebx
8010518c:	e8 4f c7 ff ff       	call   801018e0 <iunlockput>
  return ip;
80105191:	83 c4 10             	add    $0x10,%esp
}
80105194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105197:	89 f8                	mov    %edi,%eax
80105199:	5b                   	pop    %ebx
8010519a:	5e                   	pop    %esi
8010519b:	5f                   	pop    %edi
8010519c:	5d                   	pop    %ebp
8010519d:	c3                   	ret    
8010519e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
801051a0:	83 ec 0c             	sub    $0xc,%esp
801051a3:	57                   	push   %edi
    return 0;
801051a4:	31 ff                	xor    %edi,%edi
    iunlockput(ip);
801051a6:	e8 35 c7 ff ff       	call   801018e0 <iunlockput>
    return 0;
801051ab:	83 c4 10             	add    $0x10,%esp
}
801051ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
801051b1:	89 f8                	mov    %edi,%eax
801051b3:	5b                   	pop    %ebx
801051b4:	5e                   	pop    %esi
801051b5:	5f                   	pop    %edi
801051b6:	5d                   	pop    %ebp
801051b7:	c3                   	ret    
801051b8:	90                   	nop
801051b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink++;  // for ".."
801051c0:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
    iupdate(dp);
801051c5:	83 ec 0c             	sub    $0xc,%esp
801051c8:	53                   	push   %ebx
801051c9:	e8 92 c3 ff ff       	call   80101560 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801051ce:	83 c4 0c             	add    $0xc,%esp
801051d1:	ff 77 04             	pushl  0x4(%edi)
801051d4:	68 30 82 10 80       	push   $0x80108230
801051d9:	57                   	push   %edi
801051da:	e8 21 cc ff ff       	call   80101e00 <dirlink>
801051df:	83 c4 10             	add    $0x10,%esp
801051e2:	85 c0                	test   %eax,%eax
801051e4:	78 1c                	js     80105202 <create+0x162>
801051e6:	83 ec 04             	sub    $0x4,%esp
801051e9:	ff 73 04             	pushl  0x4(%ebx)
801051ec:	68 2f 82 10 80       	push   $0x8010822f
801051f1:	57                   	push   %edi
801051f2:	e8 09 cc ff ff       	call   80101e00 <dirlink>
801051f7:	83 c4 10             	add    $0x10,%esp
801051fa:	85 c0                	test   %eax,%eax
801051fc:	0f 89 6e ff ff ff    	jns    80105170 <create+0xd0>
      panic("create dots");
80105202:	83 ec 0c             	sub    $0xc,%esp
80105205:	68 23 82 10 80       	push   $0x80108223
8010520a:	e8 61 b1 ff ff       	call   80100370 <panic>
8010520f:	90                   	nop
    return 0;
80105210:	31 ff                	xor    %edi,%edi
80105212:	e9 ff fe ff ff       	jmp    80105116 <create+0x76>
    panic("create: dirlink");
80105217:	83 ec 0c             	sub    $0xc,%esp
8010521a:	68 32 82 10 80       	push   $0x80108232
8010521f:	e8 4c b1 ff ff       	call   80100370 <panic>
    panic("create: ialloc");
80105224:	83 ec 0c             	sub    $0xc,%esp
80105227:	68 14 82 10 80       	push   $0x80108214
8010522c:	e8 3f b1 ff ff       	call   80100370 <panic>
80105231:	eb 0d                	jmp    80105240 <argfd.constprop.0>
80105233:	90                   	nop
80105234:	90                   	nop
80105235:	90                   	nop
80105236:	90                   	nop
80105237:	90                   	nop
80105238:	90                   	nop
80105239:	90                   	nop
8010523a:	90                   	nop
8010523b:	90                   	nop
8010523c:	90                   	nop
8010523d:	90                   	nop
8010523e:	90                   	nop
8010523f:	90                   	nop

80105240 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
80105240:	55                   	push   %ebp
80105241:	89 e5                	mov    %esp,%ebp
80105243:	56                   	push   %esi
80105244:	53                   	push   %ebx
80105245:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
80105247:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
8010524a:	89 d6                	mov    %edx,%esi
8010524c:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010524f:	50                   	push   %eax
80105250:	6a 00                	push   $0x0
80105252:	e8 c9 fc ff ff       	call   80104f20 <argint>
80105257:	83 c4 10             	add    $0x10,%esp
8010525a:	85 c0                	test   %eax,%eax
8010525c:	78 32                	js     80105290 <argfd.constprop.0+0x50>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010525e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105261:	83 f8 0f             	cmp    $0xf,%eax
80105264:	77 2a                	ja     80105290 <argfd.constprop.0+0x50>
80105266:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010526d:	8b 4c 82 4c          	mov    0x4c(%edx,%eax,4),%ecx
80105271:	85 c9                	test   %ecx,%ecx
80105273:	74 1b                	je     80105290 <argfd.constprop.0+0x50>
  if(pfd)
80105275:	85 db                	test   %ebx,%ebx
80105277:	74 02                	je     8010527b <argfd.constprop.0+0x3b>
    *pfd = fd;
80105279:	89 03                	mov    %eax,(%ebx)
    *pf = f;
8010527b:	89 0e                	mov    %ecx,(%esi)
  return 0;
8010527d:	31 c0                	xor    %eax,%eax
}
8010527f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105282:	5b                   	pop    %ebx
80105283:	5e                   	pop    %esi
80105284:	5d                   	pop    %ebp
80105285:	c3                   	ret    
80105286:	8d 76 00             	lea    0x0(%esi),%esi
80105289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105290:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105295:	eb e8                	jmp    8010527f <argfd.constprop.0+0x3f>
80105297:	89 f6                	mov    %esi,%esi
80105299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801052a0 <sys_dup>:
{
801052a0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
801052a1:	31 c0                	xor    %eax,%eax
{
801052a3:	89 e5                	mov    %esp,%ebp
801052a5:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
801052a6:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
801052a9:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801052ac:	e8 8f ff ff ff       	call   80105240 <argfd.constprop.0>
801052b1:	85 c0                	test   %eax,%eax
801052b3:	78 3b                	js     801052f0 <sys_dup+0x50>
  if((fd=fdalloc(f)) < 0)
801052b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if(proc->ofile[fd] == 0){
801052b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  for(fd = 0; fd < NOFILE; fd++){
801052be:	31 db                	xor    %ebx,%ebx
801052c0:	eb 0e                	jmp    801052d0 <sys_dup+0x30>
801052c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801052c8:	83 c3 01             	add    $0x1,%ebx
801052cb:	83 fb 10             	cmp    $0x10,%ebx
801052ce:	74 20                	je     801052f0 <sys_dup+0x50>
    if(proc->ofile[fd] == 0){
801052d0:	8b 4c 98 4c          	mov    0x4c(%eax,%ebx,4),%ecx
801052d4:	85 c9                	test   %ecx,%ecx
801052d6:	75 f0                	jne    801052c8 <sys_dup+0x28>
  filedup(f);
801052d8:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
801052db:	89 54 98 4c          	mov    %edx,0x4c(%eax,%ebx,4)
  filedup(f);
801052df:	52                   	push   %edx
801052e0:	e8 db ba ff ff       	call   80100dc0 <filedup>
}
801052e5:	89 d8                	mov    %ebx,%eax
  return fd;
801052e7:	83 c4 10             	add    $0x10,%esp
}
801052ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052ed:	c9                   	leave  
801052ee:	c3                   	ret    
801052ef:	90                   	nop
    return -1;
801052f0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
801052f5:	89 d8                	mov    %ebx,%eax
801052f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052fa:	c9                   	leave  
801052fb:	c3                   	ret    
801052fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105300 <sys_read>:
{
80105300:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105301:	31 c0                	xor    %eax,%eax
{
80105303:	89 e5                	mov    %esp,%ebp
80105305:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105308:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010530b:	e8 30 ff ff ff       	call   80105240 <argfd.constprop.0>
80105310:	85 c0                	test   %eax,%eax
80105312:	78 4c                	js     80105360 <sys_read+0x60>
80105314:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105317:	83 ec 08             	sub    $0x8,%esp
8010531a:	50                   	push   %eax
8010531b:	6a 02                	push   $0x2
8010531d:	e8 fe fb ff ff       	call   80104f20 <argint>
80105322:	83 c4 10             	add    $0x10,%esp
80105325:	85 c0                	test   %eax,%eax
80105327:	78 37                	js     80105360 <sys_read+0x60>
80105329:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010532c:	83 ec 04             	sub    $0x4,%esp
8010532f:	ff 75 f0             	pushl  -0x10(%ebp)
80105332:	50                   	push   %eax
80105333:	6a 01                	push   $0x1
80105335:	e8 26 fc ff ff       	call   80104f60 <argptr>
8010533a:	83 c4 10             	add    $0x10,%esp
8010533d:	85 c0                	test   %eax,%eax
8010533f:	78 1f                	js     80105360 <sys_read+0x60>
  return fileread(f, p, n);
80105341:	83 ec 04             	sub    $0x4,%esp
80105344:	ff 75 f0             	pushl  -0x10(%ebp)
80105347:	ff 75 f4             	pushl  -0xc(%ebp)
8010534a:	ff 75 ec             	pushl  -0x14(%ebp)
8010534d:	e8 de bb ff ff       	call   80100f30 <fileread>
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

80105370 <sys_write>:
{
80105370:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105371:	31 c0                	xor    %eax,%eax
{
80105373:	89 e5                	mov    %esp,%ebp
80105375:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105378:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010537b:	e8 c0 fe ff ff       	call   80105240 <argfd.constprop.0>
80105380:	85 c0                	test   %eax,%eax
80105382:	78 4c                	js     801053d0 <sys_write+0x60>
80105384:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105387:	83 ec 08             	sub    $0x8,%esp
8010538a:	50                   	push   %eax
8010538b:	6a 02                	push   $0x2
8010538d:	e8 8e fb ff ff       	call   80104f20 <argint>
80105392:	83 c4 10             	add    $0x10,%esp
80105395:	85 c0                	test   %eax,%eax
80105397:	78 37                	js     801053d0 <sys_write+0x60>
80105399:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010539c:	83 ec 04             	sub    $0x4,%esp
8010539f:	ff 75 f0             	pushl  -0x10(%ebp)
801053a2:	50                   	push   %eax
801053a3:	6a 01                	push   $0x1
801053a5:	e8 b6 fb ff ff       	call   80104f60 <argptr>
801053aa:	83 c4 10             	add    $0x10,%esp
801053ad:	85 c0                	test   %eax,%eax
801053af:	78 1f                	js     801053d0 <sys_write+0x60>
  return filewrite(f, p, n);
801053b1:	83 ec 04             	sub    $0x4,%esp
801053b4:	ff 75 f0             	pushl  -0x10(%ebp)
801053b7:	ff 75 f4             	pushl  -0xc(%ebp)
801053ba:	ff 75 ec             	pushl  -0x14(%ebp)
801053bd:	e8 fe bb ff ff       	call   80100fc0 <filewrite>
801053c2:	83 c4 10             	add    $0x10,%esp
}
801053c5:	c9                   	leave  
801053c6:	c3                   	ret    
801053c7:	89 f6                	mov    %esi,%esi
801053c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
801053d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053d5:	c9                   	leave  
801053d6:	c3                   	ret    
801053d7:	89 f6                	mov    %esi,%esi
801053d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801053e0 <sys_close>:
{
801053e0:	55                   	push   %ebp
801053e1:	89 e5                	mov    %esp,%ebp
801053e3:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801053e6:	8d 55 f4             	lea    -0xc(%ebp),%edx
801053e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053ec:	e8 4f fe ff ff       	call   80105240 <argfd.constprop.0>
801053f1:	85 c0                	test   %eax,%eax
801053f3:	78 2b                	js     80105420 <sys_close+0x40>
  proc->ofile[fd] = 0;
801053f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
801053fe:	83 ec 0c             	sub    $0xc,%esp
  proc->ofile[fd] = 0;
80105401:	c7 44 90 4c 00 00 00 	movl   $0x0,0x4c(%eax,%edx,4)
80105408:	00 
  fileclose(f);
80105409:	ff 75 f4             	pushl  -0xc(%ebp)
8010540c:	e8 ff b9 ff ff       	call   80100e10 <fileclose>
  return 0;
80105411:	83 c4 10             	add    $0x10,%esp
80105414:	31 c0                	xor    %eax,%eax
}
80105416:	c9                   	leave  
80105417:	c3                   	ret    
80105418:	90                   	nop
80105419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105420:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105425:	c9                   	leave  
80105426:	c3                   	ret    
80105427:	89 f6                	mov    %esi,%esi
80105429:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105430 <sys_fstat>:
{
80105430:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105431:	31 c0                	xor    %eax,%eax
{
80105433:	89 e5                	mov    %esp,%ebp
80105435:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105438:	8d 55 f0             	lea    -0x10(%ebp),%edx
8010543b:	e8 00 fe ff ff       	call   80105240 <argfd.constprop.0>
80105440:	85 c0                	test   %eax,%eax
80105442:	78 2c                	js     80105470 <sys_fstat+0x40>
80105444:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105447:	83 ec 04             	sub    $0x4,%esp
8010544a:	6a 14                	push   $0x14
8010544c:	50                   	push   %eax
8010544d:	6a 01                	push   $0x1
8010544f:	e8 0c fb ff ff       	call   80104f60 <argptr>
80105454:	83 c4 10             	add    $0x10,%esp
80105457:	85 c0                	test   %eax,%eax
80105459:	78 15                	js     80105470 <sys_fstat+0x40>
  return filestat(f, st);
8010545b:	83 ec 08             	sub    $0x8,%esp
8010545e:	ff 75 f4             	pushl  -0xc(%ebp)
80105461:	ff 75 f0             	pushl  -0x10(%ebp)
80105464:	e8 77 ba ff ff       	call   80100ee0 <filestat>
80105469:	83 c4 10             	add    $0x10,%esp
}
8010546c:	c9                   	leave  
8010546d:	c3                   	ret    
8010546e:	66 90                	xchg   %ax,%ax
    return -1;
80105470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105475:	c9                   	leave  
80105476:	c3                   	ret    
80105477:	89 f6                	mov    %esi,%esi
80105479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105480 <sys_link>:
{
80105480:	55                   	push   %ebp
80105481:	89 e5                	mov    %esp,%ebp
80105483:	57                   	push   %edi
80105484:	56                   	push   %esi
80105485:	53                   	push   %ebx
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105486:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105489:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010548c:	50                   	push   %eax
8010548d:	6a 00                	push   $0x0
8010548f:	e8 1c fb ff ff       	call   80104fb0 <argstr>
80105494:	83 c4 10             	add    $0x10,%esp
80105497:	85 c0                	test   %eax,%eax
80105499:	0f 88 fb 00 00 00    	js     8010559a <sys_link+0x11a>
8010549f:	8d 45 d0             	lea    -0x30(%ebp),%eax
801054a2:	83 ec 08             	sub    $0x8,%esp
801054a5:	50                   	push   %eax
801054a6:	6a 01                	push   $0x1
801054a8:	e8 03 fb ff ff       	call   80104fb0 <argstr>
801054ad:	83 c4 10             	add    $0x10,%esp
801054b0:	85 c0                	test   %eax,%eax
801054b2:	0f 88 e2 00 00 00    	js     8010559a <sys_link+0x11a>
  begin_op();
801054b8:	e8 73 d7 ff ff       	call   80102c30 <begin_op>
  if((ip = namei(old)) == 0){
801054bd:	83 ec 0c             	sub    $0xc,%esp
801054c0:	ff 75 d4             	pushl  -0x2c(%ebp)
801054c3:	e8 f8 c9 ff ff       	call   80101ec0 <namei>
801054c8:	83 c4 10             	add    $0x10,%esp
801054cb:	85 c0                	test   %eax,%eax
801054cd:	89 c3                	mov    %eax,%ebx
801054cf:	0f 84 ea 00 00 00    	je     801055bf <sys_link+0x13f>
  ilock(ip);
801054d5:	83 ec 0c             	sub    $0xc,%esp
801054d8:	50                   	push   %eax
801054d9:	e8 32 c1 ff ff       	call   80101610 <ilock>
  if(ip->type == T_DIR){
801054de:	83 c4 10             	add    $0x10,%esp
801054e1:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
801054e6:	0f 84 bb 00 00 00    	je     801055a7 <sys_link+0x127>
  ip->nlink++;
801054ec:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
801054f1:	83 ec 0c             	sub    $0xc,%esp
  if((dp = nameiparent(new, name)) == 0)
801054f4:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801054f7:	53                   	push   %ebx
801054f8:	e8 63 c0 ff ff       	call   80101560 <iupdate>
  iunlock(ip);
801054fd:	89 1c 24             	mov    %ebx,(%esp)
80105500:	e8 1b c2 ff ff       	call   80101720 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80105505:	58                   	pop    %eax
80105506:	5a                   	pop    %edx
80105507:	57                   	push   %edi
80105508:	ff 75 d0             	pushl  -0x30(%ebp)
8010550b:	e8 d0 c9 ff ff       	call   80101ee0 <nameiparent>
80105510:	83 c4 10             	add    $0x10,%esp
80105513:	85 c0                	test   %eax,%eax
80105515:	89 c6                	mov    %eax,%esi
80105517:	74 5b                	je     80105574 <sys_link+0xf4>
  ilock(dp);
80105519:	83 ec 0c             	sub    $0xc,%esp
8010551c:	50                   	push   %eax
8010551d:	e8 ee c0 ff ff       	call   80101610 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105522:	83 c4 10             	add    $0x10,%esp
80105525:	8b 03                	mov    (%ebx),%eax
80105527:	39 06                	cmp    %eax,(%esi)
80105529:	75 3d                	jne    80105568 <sys_link+0xe8>
8010552b:	83 ec 04             	sub    $0x4,%esp
8010552e:	ff 73 04             	pushl  0x4(%ebx)
80105531:	57                   	push   %edi
80105532:	56                   	push   %esi
80105533:	e8 c8 c8 ff ff       	call   80101e00 <dirlink>
80105538:	83 c4 10             	add    $0x10,%esp
8010553b:	85 c0                	test   %eax,%eax
8010553d:	78 29                	js     80105568 <sys_link+0xe8>
  iunlockput(dp);
8010553f:	83 ec 0c             	sub    $0xc,%esp
80105542:	56                   	push   %esi
80105543:	e8 98 c3 ff ff       	call   801018e0 <iunlockput>
  iput(ip);
80105548:	89 1c 24             	mov    %ebx,(%esp)
8010554b:	e8 30 c2 ff ff       	call   80101780 <iput>
  end_op();
80105550:	e8 4b d7 ff ff       	call   80102ca0 <end_op>
  return 0;
80105555:	83 c4 10             	add    $0x10,%esp
80105558:	31 c0                	xor    %eax,%eax
}
8010555a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010555d:	5b                   	pop    %ebx
8010555e:	5e                   	pop    %esi
8010555f:	5f                   	pop    %edi
80105560:	5d                   	pop    %ebp
80105561:	c3                   	ret    
80105562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105568:	83 ec 0c             	sub    $0xc,%esp
8010556b:	56                   	push   %esi
8010556c:	e8 6f c3 ff ff       	call   801018e0 <iunlockput>
    goto bad;
80105571:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105574:	83 ec 0c             	sub    $0xc,%esp
80105577:	53                   	push   %ebx
80105578:	e8 93 c0 ff ff       	call   80101610 <ilock>
  ip->nlink--;
8010557d:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
80105582:	89 1c 24             	mov    %ebx,(%esp)
80105585:	e8 d6 bf ff ff       	call   80101560 <iupdate>
  iunlockput(ip);
8010558a:	89 1c 24             	mov    %ebx,(%esp)
8010558d:	e8 4e c3 ff ff       	call   801018e0 <iunlockput>
  end_op();
80105592:	e8 09 d7 ff ff       	call   80102ca0 <end_op>
  return -1;
80105597:	83 c4 10             	add    $0x10,%esp
}
8010559a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010559d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055a2:	5b                   	pop    %ebx
801055a3:	5e                   	pop    %esi
801055a4:	5f                   	pop    %edi
801055a5:	5d                   	pop    %ebp
801055a6:	c3                   	ret    
    iunlockput(ip);
801055a7:	83 ec 0c             	sub    $0xc,%esp
801055aa:	53                   	push   %ebx
801055ab:	e8 30 c3 ff ff       	call   801018e0 <iunlockput>
    end_op();
801055b0:	e8 eb d6 ff ff       	call   80102ca0 <end_op>
    return -1;
801055b5:	83 c4 10             	add    $0x10,%esp
801055b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055bd:	eb 9b                	jmp    8010555a <sys_link+0xda>
    end_op();
801055bf:	e8 dc d6 ff ff       	call   80102ca0 <end_op>
    return -1;
801055c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c9:	eb 8f                	jmp    8010555a <sys_link+0xda>
801055cb:	90                   	nop
801055cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801055d0 <sys_unlink>:
{
801055d0:	55                   	push   %ebp
801055d1:	89 e5                	mov    %esp,%ebp
801055d3:	57                   	push   %edi
801055d4:	56                   	push   %esi
801055d5:	53                   	push   %ebx
  if(argstr(0, &path) < 0)
801055d6:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
801055d9:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801055dc:	50                   	push   %eax
801055dd:	6a 00                	push   $0x0
801055df:	e8 cc f9 ff ff       	call   80104fb0 <argstr>
801055e4:	83 c4 10             	add    $0x10,%esp
801055e7:	85 c0                	test   %eax,%eax
801055e9:	0f 88 77 01 00 00    	js     80105766 <sys_unlink+0x196>
  if((dp = nameiparent(path, name)) == 0){
801055ef:	8d 5d ca             	lea    -0x36(%ebp),%ebx
  begin_op();
801055f2:	e8 39 d6 ff ff       	call   80102c30 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801055f7:	83 ec 08             	sub    $0x8,%esp
801055fa:	53                   	push   %ebx
801055fb:	ff 75 c0             	pushl  -0x40(%ebp)
801055fe:	e8 dd c8 ff ff       	call   80101ee0 <nameiparent>
80105603:	83 c4 10             	add    $0x10,%esp
80105606:	85 c0                	test   %eax,%eax
80105608:	89 c6                	mov    %eax,%esi
8010560a:	0f 84 60 01 00 00    	je     80105770 <sys_unlink+0x1a0>
  ilock(dp);
80105610:	83 ec 0c             	sub    $0xc,%esp
80105613:	50                   	push   %eax
80105614:	e8 f7 bf ff ff       	call   80101610 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105619:	58                   	pop    %eax
8010561a:	5a                   	pop    %edx
8010561b:	68 30 82 10 80       	push   $0x80108230
80105620:	53                   	push   %ebx
80105621:	e8 3a c5 ff ff       	call   80101b60 <namecmp>
80105626:	83 c4 10             	add    $0x10,%esp
80105629:	85 c0                	test   %eax,%eax
8010562b:	0f 84 03 01 00 00    	je     80105734 <sys_unlink+0x164>
80105631:	83 ec 08             	sub    $0x8,%esp
80105634:	68 2f 82 10 80       	push   $0x8010822f
80105639:	53                   	push   %ebx
8010563a:	e8 21 c5 ff ff       	call   80101b60 <namecmp>
8010563f:	83 c4 10             	add    $0x10,%esp
80105642:	85 c0                	test   %eax,%eax
80105644:	0f 84 ea 00 00 00    	je     80105734 <sys_unlink+0x164>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010564a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010564d:	83 ec 04             	sub    $0x4,%esp
80105650:	50                   	push   %eax
80105651:	53                   	push   %ebx
80105652:	56                   	push   %esi
80105653:	e8 28 c5 ff ff       	call   80101b80 <dirlookup>
80105658:	83 c4 10             	add    $0x10,%esp
8010565b:	85 c0                	test   %eax,%eax
8010565d:	89 c3                	mov    %eax,%ebx
8010565f:	0f 84 cf 00 00 00    	je     80105734 <sys_unlink+0x164>
  ilock(ip);
80105665:	83 ec 0c             	sub    $0xc,%esp
80105668:	50                   	push   %eax
80105669:	e8 a2 bf ff ff       	call   80101610 <ilock>
  if(ip->nlink < 1)
8010566e:	83 c4 10             	add    $0x10,%esp
80105671:	66 83 7b 16 00       	cmpw   $0x0,0x16(%ebx)
80105676:	0f 8e 10 01 00 00    	jle    8010578c <sys_unlink+0x1bc>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010567c:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105681:	74 6d                	je     801056f0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
80105683:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105686:	83 ec 04             	sub    $0x4,%esp
80105689:	6a 10                	push   $0x10
8010568b:	6a 00                	push   $0x0
8010568d:	50                   	push   %eax
8010568e:	e8 ad f5 ff ff       	call   80104c40 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105693:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105696:	6a 10                	push   $0x10
80105698:	ff 75 c4             	pushl  -0x3c(%ebp)
8010569b:	50                   	push   %eax
8010569c:	56                   	push   %esi
8010569d:	e8 8e c3 ff ff       	call   80101a30 <writei>
801056a2:	83 c4 20             	add    $0x20,%esp
801056a5:	83 f8 10             	cmp    $0x10,%eax
801056a8:	0f 85 eb 00 00 00    	jne    80105799 <sys_unlink+0x1c9>
  if(ip->type == T_DIR){
801056ae:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
801056b3:	0f 84 97 00 00 00    	je     80105750 <sys_unlink+0x180>
  iunlockput(dp);
801056b9:	83 ec 0c             	sub    $0xc,%esp
801056bc:	56                   	push   %esi
801056bd:	e8 1e c2 ff ff       	call   801018e0 <iunlockput>
  ip->nlink--;
801056c2:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
801056c7:	89 1c 24             	mov    %ebx,(%esp)
801056ca:	e8 91 be ff ff       	call   80101560 <iupdate>
  iunlockput(ip);
801056cf:	89 1c 24             	mov    %ebx,(%esp)
801056d2:	e8 09 c2 ff ff       	call   801018e0 <iunlockput>
  end_op();
801056d7:	e8 c4 d5 ff ff       	call   80102ca0 <end_op>
  return 0;
801056dc:	83 c4 10             	add    $0x10,%esp
801056df:	31 c0                	xor    %eax,%eax
}
801056e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801056e4:	5b                   	pop    %ebx
801056e5:	5e                   	pop    %esi
801056e6:	5f                   	pop    %edi
801056e7:	5d                   	pop    %ebp
801056e8:	c3                   	ret    
801056e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056f0:	83 7b 18 20          	cmpl   $0x20,0x18(%ebx)
801056f4:	76 8d                	jbe    80105683 <sys_unlink+0xb3>
801056f6:	bf 20 00 00 00       	mov    $0x20,%edi
801056fb:	eb 0f                	jmp    8010570c <sys_unlink+0x13c>
801056fd:	8d 76 00             	lea    0x0(%esi),%esi
80105700:	83 c7 10             	add    $0x10,%edi
80105703:	3b 7b 18             	cmp    0x18(%ebx),%edi
80105706:	0f 83 77 ff ff ff    	jae    80105683 <sys_unlink+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010570c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010570f:	6a 10                	push   $0x10
80105711:	57                   	push   %edi
80105712:	50                   	push   %eax
80105713:	53                   	push   %ebx
80105714:	e8 17 c2 ff ff       	call   80101930 <readi>
80105719:	83 c4 10             	add    $0x10,%esp
8010571c:	83 f8 10             	cmp    $0x10,%eax
8010571f:	75 5e                	jne    8010577f <sys_unlink+0x1af>
    if(de.inum != 0)
80105721:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80105726:	74 d8                	je     80105700 <sys_unlink+0x130>
    iunlockput(ip);
80105728:	83 ec 0c             	sub    $0xc,%esp
8010572b:	53                   	push   %ebx
8010572c:	e8 af c1 ff ff       	call   801018e0 <iunlockput>
    goto bad;
80105731:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80105734:	83 ec 0c             	sub    $0xc,%esp
80105737:	56                   	push   %esi
80105738:	e8 a3 c1 ff ff       	call   801018e0 <iunlockput>
  end_op();
8010573d:	e8 5e d5 ff ff       	call   80102ca0 <end_op>
  return -1;
80105742:	83 c4 10             	add    $0x10,%esp
80105745:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010574a:	eb 95                	jmp    801056e1 <sys_unlink+0x111>
8010574c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink--;
80105750:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
    iupdate(dp);
80105755:	83 ec 0c             	sub    $0xc,%esp
80105758:	56                   	push   %esi
80105759:	e8 02 be ff ff       	call   80101560 <iupdate>
8010575e:	83 c4 10             	add    $0x10,%esp
80105761:	e9 53 ff ff ff       	jmp    801056b9 <sys_unlink+0xe9>
    return -1;
80105766:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576b:	e9 71 ff ff ff       	jmp    801056e1 <sys_unlink+0x111>
    end_op();
80105770:	e8 2b d5 ff ff       	call   80102ca0 <end_op>
    return -1;
80105775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577a:	e9 62 ff ff ff       	jmp    801056e1 <sys_unlink+0x111>
      panic("isdirempty: readi");
8010577f:	83 ec 0c             	sub    $0xc,%esp
80105782:	68 54 82 10 80       	push   $0x80108254
80105787:	e8 e4 ab ff ff       	call   80100370 <panic>
    panic("unlink: nlink < 1");
8010578c:	83 ec 0c             	sub    $0xc,%esp
8010578f:	68 42 82 10 80       	push   $0x80108242
80105794:	e8 d7 ab ff ff       	call   80100370 <panic>
    panic("unlink: writei");
80105799:	83 ec 0c             	sub    $0xc,%esp
8010579c:	68 66 82 10 80       	push   $0x80108266
801057a1:	e8 ca ab ff ff       	call   80100370 <panic>
801057a6:	8d 76 00             	lea    0x0(%esi),%esi
801057a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801057b0 <sys_open>:

int
sys_open(void)
{
801057b0:	55                   	push   %ebp
801057b1:	89 e5                	mov    %esp,%ebp
801057b3:	57                   	push   %edi
801057b4:	56                   	push   %esi
801057b5:	53                   	push   %ebx
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
801057b9:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057bc:	50                   	push   %eax
801057bd:	6a 00                	push   $0x0
801057bf:	e8 ec f7 ff ff       	call   80104fb0 <argstr>
801057c4:	83 c4 10             	add    $0x10,%esp
801057c7:	85 c0                	test   %eax,%eax
801057c9:	0f 88 1d 01 00 00    	js     801058ec <sys_open+0x13c>
801057cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801057d2:	83 ec 08             	sub    $0x8,%esp
801057d5:	50                   	push   %eax
801057d6:	6a 01                	push   $0x1
801057d8:	e8 43 f7 ff ff       	call   80104f20 <argint>
801057dd:	83 c4 10             	add    $0x10,%esp
801057e0:	85 c0                	test   %eax,%eax
801057e2:	0f 88 04 01 00 00    	js     801058ec <sys_open+0x13c>
    return -1;

  begin_op();
801057e8:	e8 43 d4 ff ff       	call   80102c30 <begin_op>

  if(omode & O_CREATE){
801057ed:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801057f1:	0f 85 a9 00 00 00    	jne    801058a0 <sys_open+0xf0>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801057f7:	83 ec 0c             	sub    $0xc,%esp
801057fa:	ff 75 e0             	pushl  -0x20(%ebp)
801057fd:	e8 be c6 ff ff       	call   80101ec0 <namei>
80105802:	83 c4 10             	add    $0x10,%esp
80105805:	85 c0                	test   %eax,%eax
80105807:	89 c6                	mov    %eax,%esi
80105809:	0f 84 b2 00 00 00    	je     801058c1 <sys_open+0x111>
      end_op();
      return -1;
    }
    ilock(ip);
8010580f:	83 ec 0c             	sub    $0xc,%esp
80105812:	50                   	push   %eax
80105813:	e8 f8 bd ff ff       	call   80101610 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105818:	83 c4 10             	add    $0x10,%esp
8010581b:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
80105820:	0f 84 aa 00 00 00    	je     801058d0 <sys_open+0x120>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105826:	e8 25 b5 ff ff       	call   80100d50 <filealloc>
8010582b:	85 c0                	test   %eax,%eax
8010582d:	89 c7                	mov    %eax,%edi
8010582f:	0f 84 a6 00 00 00    	je     801058db <sys_open+0x12b>
    if(proc->ofile[fd] == 0){
80105835:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  for(fd = 0; fd < NOFILE; fd++){
8010583c:	31 db                	xor    %ebx,%ebx
8010583e:	eb 0c                	jmp    8010584c <sys_open+0x9c>
80105840:	83 c3 01             	add    $0x1,%ebx
80105843:	83 fb 10             	cmp    $0x10,%ebx
80105846:	0f 84 ac 00 00 00    	je     801058f8 <sys_open+0x148>
    if(proc->ofile[fd] == 0){
8010584c:	8b 44 9a 4c          	mov    0x4c(%edx,%ebx,4),%eax
80105850:	85 c0                	test   %eax,%eax
80105852:	75 ec                	jne    80105840 <sys_open+0x90>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105854:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
80105857:	89 7c 9a 4c          	mov    %edi,0x4c(%edx,%ebx,4)
  iunlock(ip);
8010585b:	56                   	push   %esi
8010585c:	e8 bf be ff ff       	call   80101720 <iunlock>
  end_op();
80105861:	e8 3a d4 ff ff       	call   80102ca0 <end_op>

  f->type = FD_INODE;
80105866:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
8010586c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010586f:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105872:	89 77 10             	mov    %esi,0x10(%edi)
  f->off = 0;
80105875:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
8010587c:	89 d0                	mov    %edx,%eax
8010587e:	f7 d0                	not    %eax
80105880:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105883:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
80105886:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105889:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
8010588d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105890:	89 d8                	mov    %ebx,%eax
80105892:	5b                   	pop    %ebx
80105893:	5e                   	pop    %esi
80105894:	5f                   	pop    %edi
80105895:	5d                   	pop    %ebp
80105896:	c3                   	ret    
80105897:	89 f6                	mov    %esi,%esi
80105899:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ip = create(path, T_FILE, 0, 0);
801058a0:	83 ec 0c             	sub    $0xc,%esp
801058a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801058a6:	31 c9                	xor    %ecx,%ecx
801058a8:	6a 00                	push   $0x0
801058aa:	ba 02 00 00 00       	mov    $0x2,%edx
801058af:	e8 ec f7 ff ff       	call   801050a0 <create>
    if(ip == 0){
801058b4:	83 c4 10             	add    $0x10,%esp
801058b7:	85 c0                	test   %eax,%eax
    ip = create(path, T_FILE, 0, 0);
801058b9:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801058bb:	0f 85 65 ff ff ff    	jne    80105826 <sys_open+0x76>
      end_op();
801058c1:	e8 da d3 ff ff       	call   80102ca0 <end_op>
      return -1;
801058c6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801058cb:	eb c0                	jmp    8010588d <sys_open+0xdd>
801058cd:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->type == T_DIR && omode != O_RDONLY){
801058d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801058d3:	85 d2                	test   %edx,%edx
801058d5:	0f 84 4b ff ff ff    	je     80105826 <sys_open+0x76>
    iunlockput(ip);
801058db:	83 ec 0c             	sub    $0xc,%esp
801058de:	56                   	push   %esi
801058df:	e8 fc bf ff ff       	call   801018e0 <iunlockput>
    end_op();
801058e4:	e8 b7 d3 ff ff       	call   80102ca0 <end_op>
    return -1;
801058e9:	83 c4 10             	add    $0x10,%esp
801058ec:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801058f1:	eb 9a                	jmp    8010588d <sys_open+0xdd>
801058f3:	90                   	nop
801058f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      fileclose(f);
801058f8:	83 ec 0c             	sub    $0xc,%esp
801058fb:	57                   	push   %edi
801058fc:	e8 0f b5 ff ff       	call   80100e10 <fileclose>
80105901:	83 c4 10             	add    $0x10,%esp
80105904:	eb d5                	jmp    801058db <sys_open+0x12b>
80105906:	8d 76 00             	lea    0x0(%esi),%esi
80105909:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105910 <sys_mkdir>:

int
sys_mkdir(void)
{
80105910:	55                   	push   %ebp
80105911:	89 e5                	mov    %esp,%ebp
80105913:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105916:	e8 15 d3 ff ff       	call   80102c30 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010591b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010591e:	83 ec 08             	sub    $0x8,%esp
80105921:	50                   	push   %eax
80105922:	6a 00                	push   $0x0
80105924:	e8 87 f6 ff ff       	call   80104fb0 <argstr>
80105929:	83 c4 10             	add    $0x10,%esp
8010592c:	85 c0                	test   %eax,%eax
8010592e:	78 30                	js     80105960 <sys_mkdir+0x50>
80105930:	83 ec 0c             	sub    $0xc,%esp
80105933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105936:	31 c9                	xor    %ecx,%ecx
80105938:	6a 00                	push   $0x0
8010593a:	ba 01 00 00 00       	mov    $0x1,%edx
8010593f:	e8 5c f7 ff ff       	call   801050a0 <create>
80105944:	83 c4 10             	add    $0x10,%esp
80105947:	85 c0                	test   %eax,%eax
80105949:	74 15                	je     80105960 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010594b:	83 ec 0c             	sub    $0xc,%esp
8010594e:	50                   	push   %eax
8010594f:	e8 8c bf ff ff       	call   801018e0 <iunlockput>
  end_op();
80105954:	e8 47 d3 ff ff       	call   80102ca0 <end_op>
  return 0;
80105959:	83 c4 10             	add    $0x10,%esp
8010595c:	31 c0                	xor    %eax,%eax
}
8010595e:	c9                   	leave  
8010595f:	c3                   	ret    
    end_op();
80105960:	e8 3b d3 ff ff       	call   80102ca0 <end_op>
    return -1;
80105965:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010596a:	c9                   	leave  
8010596b:	c3                   	ret    
8010596c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105970 <sys_mknod>:

int
sys_mknod(void)
{
80105970:	55                   	push   %ebp
80105971:	89 e5                	mov    %esp,%ebp
80105973:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105976:	e8 b5 d2 ff ff       	call   80102c30 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010597b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010597e:	83 ec 08             	sub    $0x8,%esp
80105981:	50                   	push   %eax
80105982:	6a 00                	push   $0x0
80105984:	e8 27 f6 ff ff       	call   80104fb0 <argstr>
80105989:	83 c4 10             	add    $0x10,%esp
8010598c:	85 c0                	test   %eax,%eax
8010598e:	78 60                	js     801059f0 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105990:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105993:	83 ec 08             	sub    $0x8,%esp
80105996:	50                   	push   %eax
80105997:	6a 01                	push   $0x1
80105999:	e8 82 f5 ff ff       	call   80104f20 <argint>
  if((argstr(0, &path)) < 0 ||
8010599e:	83 c4 10             	add    $0x10,%esp
801059a1:	85 c0                	test   %eax,%eax
801059a3:	78 4b                	js     801059f0 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
801059a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059a8:	83 ec 08             	sub    $0x8,%esp
801059ab:	50                   	push   %eax
801059ac:	6a 02                	push   $0x2
801059ae:	e8 6d f5 ff ff       	call   80104f20 <argint>
     argint(1, &major) < 0 ||
801059b3:	83 c4 10             	add    $0x10,%esp
801059b6:	85 c0                	test   %eax,%eax
801059b8:	78 36                	js     801059f0 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059ba:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
     argint(2, &minor) < 0 ||
801059be:	83 ec 0c             	sub    $0xc,%esp
     (ip = create(path, T_DEV, major, minor)) == 0){
801059c1:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
801059c5:	ba 03 00 00 00       	mov    $0x3,%edx
801059ca:	50                   	push   %eax
801059cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059ce:	e8 cd f6 ff ff       	call   801050a0 <create>
801059d3:	83 c4 10             	add    $0x10,%esp
801059d6:	85 c0                	test   %eax,%eax
801059d8:	74 16                	je     801059f0 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
801059da:	83 ec 0c             	sub    $0xc,%esp
801059dd:	50                   	push   %eax
801059de:	e8 fd be ff ff       	call   801018e0 <iunlockput>
  end_op();
801059e3:	e8 b8 d2 ff ff       	call   80102ca0 <end_op>
  return 0;
801059e8:	83 c4 10             	add    $0x10,%esp
801059eb:	31 c0                	xor    %eax,%eax
}
801059ed:	c9                   	leave  
801059ee:	c3                   	ret    
801059ef:	90                   	nop
    end_op();
801059f0:	e8 ab d2 ff ff       	call   80102ca0 <end_op>
    return -1;
801059f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059fa:	c9                   	leave  
801059fb:	c3                   	ret    
801059fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a00 <sys_chdir>:

int
sys_chdir(void)
{
80105a00:	55                   	push   %ebp
80105a01:	89 e5                	mov    %esp,%ebp
80105a03:	53                   	push   %ebx
80105a04:	83 ec 14             	sub    $0x14,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105a07:	e8 24 d2 ff ff       	call   80102c30 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a0f:	83 ec 08             	sub    $0x8,%esp
80105a12:	50                   	push   %eax
80105a13:	6a 00                	push   $0x0
80105a15:	e8 96 f5 ff ff       	call   80104fb0 <argstr>
80105a1a:	83 c4 10             	add    $0x10,%esp
80105a1d:	85 c0                	test   %eax,%eax
80105a1f:	78 7f                	js     80105aa0 <sys_chdir+0xa0>
80105a21:	83 ec 0c             	sub    $0xc,%esp
80105a24:	ff 75 f4             	pushl  -0xc(%ebp)
80105a27:	e8 94 c4 ff ff       	call   80101ec0 <namei>
80105a2c:	83 c4 10             	add    $0x10,%esp
80105a2f:	85 c0                	test   %eax,%eax
80105a31:	89 c3                	mov    %eax,%ebx
80105a33:	74 6b                	je     80105aa0 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105a35:	83 ec 0c             	sub    $0xc,%esp
80105a38:	50                   	push   %eax
80105a39:	e8 d2 bb ff ff       	call   80101610 <ilock>
  if(ip->type != T_DIR){
80105a3e:	83 c4 10             	add    $0x10,%esp
80105a41:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105a46:	75 38                	jne    80105a80 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105a48:	83 ec 0c             	sub    $0xc,%esp
80105a4b:	53                   	push   %ebx
80105a4c:	e8 cf bc ff ff       	call   80101720 <iunlock>
  iput(proc->cwd);
80105a51:	58                   	pop    %eax
80105a52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a58:	ff b0 8c 00 00 00    	pushl  0x8c(%eax)
80105a5e:	e8 1d bd ff ff       	call   80101780 <iput>
  end_op();
80105a63:	e8 38 d2 ff ff       	call   80102ca0 <end_op>
  proc->cwd = ip;
80105a68:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return 0;
80105a6e:	83 c4 10             	add    $0x10,%esp
  proc->cwd = ip;
80105a71:	89 98 8c 00 00 00    	mov    %ebx,0x8c(%eax)
  return 0;
80105a77:	31 c0                	xor    %eax,%eax
}
80105a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105a7c:	c9                   	leave  
80105a7d:	c3                   	ret    
80105a7e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80105a80:	83 ec 0c             	sub    $0xc,%esp
80105a83:	53                   	push   %ebx
80105a84:	e8 57 be ff ff       	call   801018e0 <iunlockput>
    end_op();
80105a89:	e8 12 d2 ff ff       	call   80102ca0 <end_op>
    return -1;
80105a8e:	83 c4 10             	add    $0x10,%esp
80105a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a96:	eb e1                	jmp    80105a79 <sys_chdir+0x79>
80105a98:	90                   	nop
80105a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    end_op();
80105aa0:	e8 fb d1 ff ff       	call   80102ca0 <end_op>
    return -1;
80105aa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aaa:	eb cd                	jmp    80105a79 <sys_chdir+0x79>
80105aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105ab0 <sys_exec>:

int
sys_exec(void)
{
80105ab0:	55                   	push   %ebp
80105ab1:	89 e5                	mov    %esp,%ebp
80105ab3:	57                   	push   %edi
80105ab4:	56                   	push   %esi
80105ab5:	53                   	push   %ebx
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ab6:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
80105abc:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ac2:	50                   	push   %eax
80105ac3:	6a 00                	push   $0x0
80105ac5:	e8 e6 f4 ff ff       	call   80104fb0 <argstr>
80105aca:	83 c4 10             	add    $0x10,%esp
80105acd:	85 c0                	test   %eax,%eax
80105acf:	0f 88 87 00 00 00    	js     80105b5c <sys_exec+0xac>
80105ad5:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105adb:	83 ec 08             	sub    $0x8,%esp
80105ade:	50                   	push   %eax
80105adf:	6a 01                	push   $0x1
80105ae1:	e8 3a f4 ff ff       	call   80104f20 <argint>
80105ae6:	83 c4 10             	add    $0x10,%esp
80105ae9:	85 c0                	test   %eax,%eax
80105aeb:	78 6f                	js     80105b5c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105aed:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105af3:	83 ec 04             	sub    $0x4,%esp
  for(i=0;; i++){
80105af6:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105af8:	68 80 00 00 00       	push   $0x80
80105afd:	6a 00                	push   $0x0
80105aff:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
80105b05:	50                   	push   %eax
80105b06:	e8 35 f1 ff ff       	call   80104c40 <memset>
80105b0b:	83 c4 10             	add    $0x10,%esp
80105b0e:	eb 2c                	jmp    80105b3c <sys_exec+0x8c>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
80105b10:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105b16:	85 c0                	test   %eax,%eax
80105b18:	74 56                	je     80105b70 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105b1a:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
80105b20:	83 ec 08             	sub    $0x8,%esp
80105b23:	8d 14 31             	lea    (%ecx,%esi,1),%edx
80105b26:	52                   	push   %edx
80105b27:	50                   	push   %eax
80105b28:	e8 93 f3 ff ff       	call   80104ec0 <fetchstr>
80105b2d:	83 c4 10             	add    $0x10,%esp
80105b30:	85 c0                	test   %eax,%eax
80105b32:	78 28                	js     80105b5c <sys_exec+0xac>
  for(i=0;; i++){
80105b34:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105b37:	83 fb 20             	cmp    $0x20,%ebx
80105b3a:	74 20                	je     80105b5c <sys_exec+0xac>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b3c:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105b42:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
80105b49:	83 ec 08             	sub    $0x8,%esp
80105b4c:	57                   	push   %edi
80105b4d:	01 f0                	add    %esi,%eax
80105b4f:	50                   	push   %eax
80105b50:	e8 3b f3 ff ff       	call   80104e90 <fetchint>
80105b55:	83 c4 10             	add    $0x10,%esp
80105b58:	85 c0                	test   %eax,%eax
80105b5a:	79 b4                	jns    80105b10 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
80105b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b64:	5b                   	pop    %ebx
80105b65:	5e                   	pop    %esi
80105b66:	5f                   	pop    %edi
80105b67:	5d                   	pop    %ebp
80105b68:	c3                   	ret    
80105b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105b70:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b76:	83 ec 08             	sub    $0x8,%esp
      argv[i] = 0;
80105b79:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105b80:	00 00 00 00 
  return exec(path, argv);
80105b84:	50                   	push   %eax
80105b85:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
80105b8b:	e8 60 ae ff ff       	call   801009f0 <exec>
80105b90:	83 c4 10             	add    $0x10,%esp
}
80105b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105b96:	5b                   	pop    %ebx
80105b97:	5e                   	pop    %esi
80105b98:	5f                   	pop    %edi
80105b99:	5d                   	pop    %ebp
80105b9a:	c3                   	ret    
80105b9b:	90                   	nop
80105b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105ba0 <sys_pipe>:

int
sys_pipe(void)
{
80105ba0:	55                   	push   %ebp
80105ba1:	89 e5                	mov    %esp,%ebp
80105ba3:	57                   	push   %edi
80105ba4:	56                   	push   %esi
80105ba5:	53                   	push   %ebx
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ba6:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105ba9:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bac:	6a 08                	push   $0x8
80105bae:	50                   	push   %eax
80105baf:	6a 00                	push   $0x0
80105bb1:	e8 aa f3 ff ff       	call   80104f60 <argptr>
80105bb6:	83 c4 10             	add    $0x10,%esp
80105bb9:	85 c0                	test   %eax,%eax
80105bbb:	0f 88 a4 00 00 00    	js     80105c65 <sys_pipe+0xc5>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105bc1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105bc4:	83 ec 08             	sub    $0x8,%esp
80105bc7:	50                   	push   %eax
80105bc8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bcb:	50                   	push   %eax
80105bcc:	e8 ff d7 ff ff       	call   801033d0 <pipealloc>
80105bd1:	83 c4 10             	add    $0x10,%esp
80105bd4:	85 c0                	test   %eax,%eax
80105bd6:	0f 88 89 00 00 00    	js     80105c65 <sys_pipe+0xc5>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bdc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
    if(proc->ofile[fd] == 0){
80105bdf:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  for(fd = 0; fd < NOFILE; fd++){
80105be6:	31 c0                	xor    %eax,%eax
80105be8:	eb 0e                	jmp    80105bf8 <sys_pipe+0x58>
80105bea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105bf0:	83 c0 01             	add    $0x1,%eax
80105bf3:	83 f8 10             	cmp    $0x10,%eax
80105bf6:	74 58                	je     80105c50 <sys_pipe+0xb0>
    if(proc->ofile[fd] == 0){
80105bf8:	8b 54 81 4c          	mov    0x4c(%ecx,%eax,4),%edx
80105bfc:	85 d2                	test   %edx,%edx
80105bfe:	75 f0                	jne    80105bf0 <sys_pipe+0x50>
80105c00:	8d 34 81             	lea    (%ecx,%eax,4),%esi
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c03:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105c06:	31 d2                	xor    %edx,%edx
      proc->ofile[fd] = f;
80105c08:	89 5e 4c             	mov    %ebx,0x4c(%esi)
80105c0b:	eb 0b                	jmp    80105c18 <sys_pipe+0x78>
80105c0d:	8d 76 00             	lea    0x0(%esi),%esi
  for(fd = 0; fd < NOFILE; fd++){
80105c10:	83 c2 01             	add    $0x1,%edx
80105c13:	83 fa 10             	cmp    $0x10,%edx
80105c16:	74 28                	je     80105c40 <sys_pipe+0xa0>
    if(proc->ofile[fd] == 0){
80105c18:	83 7c 91 4c 00       	cmpl   $0x0,0x4c(%ecx,%edx,4)
80105c1d:	75 f1                	jne    80105c10 <sys_pipe+0x70>
      proc->ofile[fd] = f;
80105c1f:	89 7c 91 4c          	mov    %edi,0x4c(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105c23:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80105c26:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
80105c28:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c2b:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105c2e:	31 c0                	xor    %eax,%eax
}
80105c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c33:	5b                   	pop    %ebx
80105c34:	5e                   	pop    %esi
80105c35:	5f                   	pop    %edi
80105c36:	5d                   	pop    %ebp
80105c37:	c3                   	ret    
80105c38:	90                   	nop
80105c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      proc->ofile[fd0] = 0;
80105c40:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
80105c47:	89 f6                	mov    %esi,%esi
80105c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    fileclose(rf);
80105c50:	83 ec 0c             	sub    $0xc,%esp
80105c53:	53                   	push   %ebx
80105c54:	e8 b7 b1 ff ff       	call   80100e10 <fileclose>
    fileclose(wf);
80105c59:	58                   	pop    %eax
80105c5a:	ff 75 e4             	pushl  -0x1c(%ebp)
80105c5d:	e8 ae b1 ff ff       	call   80100e10 <fileclose>
    return -1;
80105c62:	83 c4 10             	add    $0x10,%esp
80105c65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c6a:	eb c4                	jmp    80105c30 <sys_pipe+0x90>
80105c6c:	66 90                	xchg   %ax,%ax
80105c6e:	66 90                	xchg   %ax,%ax

80105c70 <sys_clone>:
#include "mmu.h"
#include "proc.h"

int 
sys_clone(void)
{
80105c70:	55                   	push   %ebp
80105c71:	89 e5                	mov    %esp,%ebp
80105c73:	83 ec 20             	sub    $0x20,%esp
  int func_add;
  int arg;
  int stack_add;

  if (argint(0, &func_add) < 0)
80105c76:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c79:	50                   	push   %eax
80105c7a:	6a 00                	push   $0x0
80105c7c:	e8 9f f2 ff ff       	call   80104f20 <argint>
80105c81:	83 c4 10             	add    $0x10,%esp
80105c84:	85 c0                	test   %eax,%eax
80105c86:	78 48                	js     80105cd0 <sys_clone+0x60>
     return -1;
  if (argint(1, &arg) < 0)
80105c88:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c8b:	83 ec 08             	sub    $0x8,%esp
80105c8e:	50                   	push   %eax
80105c8f:	6a 01                	push   $0x1
80105c91:	e8 8a f2 ff ff       	call   80104f20 <argint>
80105c96:	83 c4 10             	add    $0x10,%esp
80105c99:	85 c0                	test   %eax,%eax
80105c9b:	78 33                	js     80105cd0 <sys_clone+0x60>
     return -1;
  if (argint(2, &stack_add) < 0)
80105c9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ca0:	83 ec 08             	sub    $0x8,%esp
80105ca3:	50                   	push   %eax
80105ca4:	6a 02                	push   $0x2
80105ca6:	e8 75 f2 ff ff       	call   80104f20 <argint>
80105cab:	83 c4 10             	add    $0x10,%esp
80105cae:	85 c0                	test   %eax,%eax
80105cb0:	78 1e                	js     80105cd0 <sys_clone+0x60>
     return -1;
 
  return clone((void *)func_add, (void *)arg, (void *)stack_add);
80105cb2:	83 ec 04             	sub    $0x4,%esp
80105cb5:	ff 75 f4             	pushl  -0xc(%ebp)
80105cb8:	ff 75 f0             	pushl  -0x10(%ebp)
80105cbb:	ff 75 ec             	pushl  -0x14(%ebp)
80105cbe:	e8 ad e9 ff ff       	call   80104670 <clone>
80105cc3:	83 c4 10             	add    $0x10,%esp
  
}
80105cc6:	c9                   	leave  
80105cc7:	c3                   	ret    
80105cc8:	90                   	nop
80105cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
80105cd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cd5:	c9                   	leave  
80105cd6:	c3                   	ret    
80105cd7:	89 f6                	mov    %esi,%esi
80105cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105ce0 <sys_join>:

int 
sys_join(void)
{
80105ce0:	55                   	push   %ebp
80105ce1:	89 e5                	mov    %esp,%ebp
80105ce3:	83 ec 20             	sub    $0x20,%esp
  int stack_add;

  if (argint(0, &stack_add) < 0)
80105ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ce9:	50                   	push   %eax
80105cea:	6a 00                	push   $0x0
80105cec:	e8 2f f2 ff ff       	call   80104f20 <argint>
80105cf1:	83 c4 10             	add    $0x10,%esp
80105cf4:	85 c0                	test   %eax,%eax
80105cf6:	78 18                	js     80105d10 <sys_join+0x30>
     return -1;

  return join((void **)stack_add);
80105cf8:	83 ec 0c             	sub    $0xc,%esp
80105cfb:	ff 75 f4             	pushl  -0xc(%ebp)
80105cfe:	e8 9d ea ff ff       	call   801047a0 <join>
80105d03:	83 c4 10             	add    $0x10,%esp
}
80105d06:	c9                   	leave  
80105d07:	c3                   	ret    
80105d08:	90                   	nop
80105d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
80105d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d15:	c9                   	leave  
80105d16:	c3                   	ret    
80105d17:	89 f6                	mov    %esi,%esi
80105d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105d20 <sys_myalloc>:

int 
sys_myalloc(void)
{
80105d20:	55                   	push   %ebp
80105d21:	89 e5                	mov    %esp,%ebp
80105d23:	83 ec 20             	sub    $0x20,%esp
  int n;   // 分配 n 个字节
  if(argint(0, &n) < 0)
80105d26:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d29:	50                   	push   %eax
80105d2a:	6a 00                	push   $0x0
80105d2c:	e8 ef f1 ff ff       	call   80104f20 <argint>
80105d31:	83 c4 10             	add    $0x10,%esp
    return 0;
80105d34:	31 d2                	xor    %edx,%edx
  if(argint(0, &n) < 0)
80105d36:	85 c0                	test   %eax,%eax
80105d38:	78 15                	js     80105d4f <sys_myalloc+0x2f>
  if(n <= 0)
80105d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3d:	85 c0                	test   %eax,%eax
80105d3f:	7e 0e                	jle    80105d4f <sys_myalloc+0x2f>
    return 0;
  return mygrowproc(n);
80105d41:	83 ec 0c             	sub    $0xc,%esp
80105d44:	50                   	push   %eax
80105d45:	e8 36 e7 ff ff       	call   80104480 <mygrowproc>
80105d4a:	83 c4 10             	add    $0x10,%esp
80105d4d:	89 c2                	mov    %eax,%edx
}
80105d4f:	89 d0                	mov    %edx,%eax
80105d51:	c9                   	leave  
80105d52:	c3                   	ret    
80105d53:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105d60 <sys_myfree>:

int 
sys_myfree(void) {
80105d60:	55                   	push   %ebp
80105d61:	89 e5                	mov    %esp,%ebp
80105d63:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(0, &addr) < 0)
80105d66:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d69:	50                   	push   %eax
80105d6a:	6a 00                	push   $0x0
80105d6c:	e8 af f1 ff ff       	call   80104f20 <argint>
80105d71:	83 c4 10             	add    $0x10,%esp
80105d74:	85 c0                	test   %eax,%eax
80105d76:	78 18                	js     80105d90 <sys_myfree+0x30>
    return -1;
  return myreduceproc(addr);
80105d78:	83 ec 0c             	sub    $0xc,%esp
80105d7b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d7e:	e8 1d e8 ff ff       	call   801045a0 <myreduceproc>
80105d83:	83 c4 10             	add    $0x10,%esp
}
80105d86:	c9                   	leave  
80105d87:	c3                   	ret    
80105d88:	90                   	nop
80105d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105d90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d95:	c9                   	leave  
80105d96:	c3                   	ret    
80105d97:	89 f6                	mov    %esi,%esi
80105d99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105da0 <sys_getcpuid>:

//achieve sys_getcpuid, just my homework
int
sys_getcpuid()
{
80105da0:	55                   	push   %ebp
80105da1:	89 e5                	mov    %esp,%ebp
  return getcpuid();
}
80105da3:	5d                   	pop    %ebp
  return getcpuid();
80105da4:	e9 97 db ff ff       	jmp    80103940 <getcpuid>
80105da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105db0 <sys_fork>:

int
sys_fork(void)
{
80105db0:	55                   	push   %ebp
80105db1:	89 e5                	mov    %esp,%ebp
  return fork();
}
80105db3:	5d                   	pop    %ebp
  return fork();
80105db4:	e9 37 dd ff ff       	jmp    80103af0 <fork>
80105db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105dc0 <sys_exit>:

int
sys_exit(void)
{
80105dc0:	55                   	push   %ebp
80105dc1:	89 e5                	mov    %esp,%ebp
80105dc3:	83 ec 08             	sub    $0x8,%esp
  exit();
80105dc6:	e8 55 e0 ff ff       	call   80103e20 <exit>
  return 0;  // not reached
}
80105dcb:	31 c0                	xor    %eax,%eax
80105dcd:	c9                   	leave  
80105dce:	c3                   	ret    
80105dcf:	90                   	nop

80105dd0 <sys_wait>:

int
sys_wait(void)
{
80105dd0:	55                   	push   %ebp
80105dd1:	89 e5                	mov    %esp,%ebp
  return wait();
}
80105dd3:	5d                   	pop    %ebp
  return wait();
80105dd4:	e9 77 e3 ff ff       	jmp    80104150 <wait>
80105dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105de0 <sys_kill>:

int
sys_kill(void)
{
80105de0:	55                   	push   %ebp
80105de1:	89 e5                	mov    %esp,%ebp
80105de3:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105de6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105de9:	50                   	push   %eax
80105dea:	6a 00                	push   $0x0
80105dec:	e8 2f f1 ff ff       	call   80104f20 <argint>
80105df1:	83 c4 10             	add    $0x10,%esp
80105df4:	85 c0                	test   %eax,%eax
80105df6:	78 18                	js     80105e10 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105df8:	83 ec 0c             	sub    $0xc,%esp
80105dfb:	ff 75 f4             	pushl  -0xc(%ebp)
80105dfe:	e8 dd e4 ff ff       	call   801042e0 <kill>
80105e03:	83 c4 10             	add    $0x10,%esp
}
80105e06:	c9                   	leave  
80105e07:	c3                   	ret    
80105e08:	90                   	nop
80105e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e15:	c9                   	leave  
80105e16:	c3                   	ret    
80105e17:	89 f6                	mov    %esi,%esi
80105e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105e20 <sys_getpid>:

int
sys_getpid(void)
{
  return proc->pid;
80105e20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80105e26:	55                   	push   %ebp
80105e27:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80105e29:	8b 40 10             	mov    0x10(%eax),%eax
}
80105e2c:	5d                   	pop    %ebp
80105e2d:	c3                   	ret    
80105e2e:	66 90                	xchg   %ax,%ax

80105e30 <sys_sbrk>:

int
sys_sbrk(void)
{
80105e30:	55                   	push   %ebp
80105e31:	89 e5                	mov    %esp,%ebp
80105e33:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105e34:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105e37:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105e3a:	50                   	push   %eax
80105e3b:	6a 00                	push   $0x0
80105e3d:	e8 de f0 ff ff       	call   80104f20 <argint>
80105e42:	83 c4 10             	add    $0x10,%esp
80105e45:	85 c0                	test   %eax,%eax
80105e47:	78 27                	js     80105e70 <sys_sbrk+0x40>
    return -1;
  addr = proc->sz;
80105e49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(growproc(n) < 0)
80105e4f:	83 ec 0c             	sub    $0xc,%esp
  addr = proc->sz;
80105e52:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105e54:	ff 75 f4             	pushl  -0xc(%ebp)
80105e57:	e8 14 dc ff ff       	call   80103a70 <growproc>
80105e5c:	83 c4 10             	add    $0x10,%esp
80105e5f:	85 c0                	test   %eax,%eax
80105e61:	78 0d                	js     80105e70 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105e63:	89 d8                	mov    %ebx,%eax
80105e65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e68:	c9                   	leave  
80105e69:	c3                   	ret    
80105e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105e70:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105e75:	eb ec                	jmp    80105e63 <sys_sbrk+0x33>
80105e77:	89 f6                	mov    %esi,%esi
80105e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105e80 <sys_sleep>:

int
sys_sleep(void)
{
80105e80:	55                   	push   %ebp
80105e81:	89 e5                	mov    %esp,%ebp
80105e83:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105e87:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105e8a:	50                   	push   %eax
80105e8b:	6a 00                	push   $0x0
80105e8d:	e8 8e f0 ff ff       	call   80104f20 <argint>
80105e92:	83 c4 10             	add    $0x10,%esp
80105e95:	85 c0                	test   %eax,%eax
80105e97:	0f 88 8a 00 00 00    	js     80105f27 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105e9d:	83 ec 0c             	sub    $0xc,%esp
80105ea0:	68 20 73 11 80       	push   $0x80117320
80105ea5:	e8 86 eb ff ff       	call   80104a30 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105eaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ead:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105eb0:	8b 1d 60 7b 11 80    	mov    0x80117b60,%ebx
  while(ticks - ticks0 < n){
80105eb6:	85 d2                	test   %edx,%edx
80105eb8:	75 27                	jne    80105ee1 <sys_sleep+0x61>
80105eba:	eb 54                	jmp    80105f10 <sys_sleep+0x90>
80105ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105ec0:	83 ec 08             	sub    $0x8,%esp
80105ec3:	68 20 73 11 80       	push   $0x80117320
80105ec8:	68 60 7b 11 80       	push   $0x80117b60
80105ecd:	e8 be e1 ff ff       	call   80104090 <sleep>
  while(ticks - ticks0 < n){
80105ed2:	a1 60 7b 11 80       	mov    0x80117b60,%eax
80105ed7:	83 c4 10             	add    $0x10,%esp
80105eda:	29 d8                	sub    %ebx,%eax
80105edc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105edf:	73 2f                	jae    80105f10 <sys_sleep+0x90>
    if(proc->killed){
80105ee1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ee7:	8b 40 48             	mov    0x48(%eax),%eax
80105eea:	85 c0                	test   %eax,%eax
80105eec:	74 d2                	je     80105ec0 <sys_sleep+0x40>
      release(&tickslock);
80105eee:	83 ec 0c             	sub    $0xc,%esp
80105ef1:	68 20 73 11 80       	push   $0x80117320
80105ef6:	e8 f5 ec ff ff       	call   80104bf0 <release>
      return -1;
80105efb:	83 c4 10             	add    $0x10,%esp
80105efe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&tickslock);
  return 0;
}
80105f03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105f06:	c9                   	leave  
80105f07:	c3                   	ret    
80105f08:	90                   	nop
80105f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  release(&tickslock);
80105f10:	83 ec 0c             	sub    $0xc,%esp
80105f13:	68 20 73 11 80       	push   $0x80117320
80105f18:	e8 d3 ec ff ff       	call   80104bf0 <release>
  return 0;
80105f1d:	83 c4 10             	add    $0x10,%esp
80105f20:	31 c0                	xor    %eax,%eax
}
80105f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105f25:	c9                   	leave  
80105f26:	c3                   	ret    
    return -1;
80105f27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2c:	eb f4                	jmp    80105f22 <sys_sleep+0xa2>
80105f2e:	66 90                	xchg   %ax,%ax

80105f30 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105f30:	55                   	push   %ebp
80105f31:	89 e5                	mov    %esp,%ebp
80105f33:	53                   	push   %ebx
80105f34:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105f37:	68 20 73 11 80       	push   $0x80117320
80105f3c:	e8 ef ea ff ff       	call   80104a30 <acquire>
  xticks = ticks;
80105f41:	8b 1d 60 7b 11 80    	mov    0x80117b60,%ebx
  release(&tickslock);
80105f47:	c7 04 24 20 73 11 80 	movl   $0x80117320,(%esp)
80105f4e:	e8 9d ec ff ff       	call   80104bf0 <release>
  return xticks;
}
80105f53:	89 d8                	mov    %ebx,%eax
80105f55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105f58:	c9                   	leave  
80105f59:	c3                   	ret    
80105f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105f60 <sys_cps>:

int sys_cps(void){
80105f60:	55                   	push   %ebp
80105f61:	89 e5                	mov    %esp,%ebp
  return cps();
}
80105f63:	5d                   	pop    %ebp
  return cps();
80105f64:	e9 47 e9 ff ff       	jmp    801048b0 <cps>
80105f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105f70 <sys_chpri>:

int sys_chpri(void)
{
80105f70:	55                   	push   %ebp
80105f71:	89 e5                	mov    %esp,%ebp
80105f73:	83 ec 20             	sub    $0x20,%esp
  int pid, pr;
  if (argint(0, &pid) < 0)
80105f76:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f79:	50                   	push   %eax
80105f7a:	6a 00                	push   $0x0
80105f7c:	e8 9f ef ff ff       	call   80104f20 <argint>
80105f81:	83 c4 10             	add    $0x10,%esp
80105f84:	85 c0                	test   %eax,%eax
80105f86:	78 28                	js     80105fb0 <sys_chpri+0x40>
    return -1;
  if (argint(1, &pr) < 0)
80105f88:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f8b:	83 ec 08             	sub    $0x8,%esp
80105f8e:	50                   	push   %eax
80105f8f:	6a 01                	push   $0x1
80105f91:	e8 8a ef ff ff       	call   80104f20 <argint>
80105f96:	83 c4 10             	add    $0x10,%esp
80105f99:	85 c0                	test   %eax,%eax
80105f9b:	78 13                	js     80105fb0 <sys_chpri+0x40>
    return -1;
  return chpri(pid, pr);
80105f9d:	83 ec 08             	sub    $0x8,%esp
80105fa0:	ff 75 f4             	pushl  -0xc(%ebp)
80105fa3:	ff 75 f0             	pushl  -0x10(%ebp)
80105fa6:	e8 15 ea ff ff       	call   801049c0 <chpri>
80105fab:	83 c4 10             	add    $0x10,%esp
}
80105fae:	c9                   	leave  
80105faf:	c3                   	ret    
    return -1;
80105fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fb5:	c9                   	leave  
80105fb6:	c3                   	ret    
80105fb7:	66 90                	xchg   %ax,%ax
80105fb9:	66 90                	xchg   %ax,%ax
80105fbb:	66 90                	xchg   %ax,%ax
80105fbd:	66 90                	xchg   %ax,%ax
80105fbf:	90                   	nop

80105fc0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80105fc0:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105fc1:	b8 34 00 00 00       	mov    $0x34,%eax
80105fc6:	ba 43 00 00 00       	mov    $0x43,%edx
80105fcb:	89 e5                	mov    %esp,%ebp
80105fcd:	83 ec 14             	sub    $0x14,%esp
80105fd0:	ee                   	out    %al,(%dx)
80105fd1:	ba 40 00 00 00       	mov    $0x40,%edx
80105fd6:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
80105fdb:	ee                   	out    %al,(%dx)
80105fdc:	b8 2e 00 00 00       	mov    $0x2e,%eax
80105fe1:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
80105fe2:	6a 00                	push   $0x0
80105fe4:	e8 17 d3 ff ff       	call   80103300 <picenable>
}
80105fe9:	83 c4 10             	add    $0x10,%esp
80105fec:	c9                   	leave  
80105fed:	c3                   	ret    

80105fee <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105fee:	1e                   	push   %ds
  pushl %es
80105fef:	06                   	push   %es
  pushl %fs
80105ff0:	0f a0                	push   %fs
  pushl %gs
80105ff2:	0f a8                	push   %gs
  pushal
80105ff4:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80105ff5:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105ff9:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105ffb:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80105ffd:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106001:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106003:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106005:	54                   	push   %esp
  call trap
80106006:	e8 c5 00 00 00       	call   801060d0 <trap>
  addl $4, %esp
8010600b:	83 c4 04             	add    $0x4,%esp

8010600e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010600e:	61                   	popa   
  popl %gs
8010600f:	0f a9                	pop    %gs
  popl %fs
80106011:	0f a1                	pop    %fs
  popl %es
80106013:	07                   	pop    %es
  popl %ds
80106014:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106015:	83 c4 08             	add    $0x8,%esp
  iret
80106018:	cf                   	iret   
80106019:	66 90                	xchg   %ax,%ax
8010601b:	66 90                	xchg   %ax,%ax
8010601d:	66 90                	xchg   %ax,%ax
8010601f:	90                   	nop

80106020 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106020:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80106021:	31 c0                	xor    %eax,%eax
{
80106023:	89 e5                	mov    %esp,%ebp
80106025:	83 ec 08             	sub    $0x8,%esp
80106028:	90                   	nop
80106029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106030:	8b 14 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%edx
80106037:	c7 04 c5 62 73 11 80 	movl   $0x8e000008,-0x7fee8c9e(,%eax,8)
8010603e:	08 00 00 8e 
80106042:	66 89 14 c5 60 73 11 	mov    %dx,-0x7fee8ca0(,%eax,8)
80106049:	80 
8010604a:	c1 ea 10             	shr    $0x10,%edx
8010604d:	66 89 14 c5 66 73 11 	mov    %dx,-0x7fee8c9a(,%eax,8)
80106054:	80 
  for(i = 0; i < 256; i++)
80106055:	83 c0 01             	add    $0x1,%eax
80106058:	3d 00 01 00 00       	cmp    $0x100,%eax
8010605d:	75 d1                	jne    80106030 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010605f:	a1 0c b1 10 80       	mov    0x8010b10c,%eax

  initlock(&tickslock, "time");
80106064:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106067:	c7 05 62 75 11 80 08 	movl   $0xef000008,0x80117562
8010606e:	00 00 ef 
  initlock(&tickslock, "time");
80106071:	68 75 82 10 80       	push   $0x80108275
80106076:	68 20 73 11 80       	push   $0x80117320
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010607b:	66 a3 60 75 11 80    	mov    %ax,0x80117560
80106081:	c1 e8 10             	shr    $0x10,%eax
80106084:	66 a3 66 75 11 80    	mov    %ax,0x80117566
  initlock(&tickslock, "time");
8010608a:	e8 81 e9 ff ff       	call   80104a10 <initlock>
}
8010608f:	83 c4 10             	add    $0x10,%esp
80106092:	c9                   	leave  
80106093:	c3                   	ret    
80106094:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010609a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801060a0 <idtinit>:

void
idtinit(void)
{
801060a0:	55                   	push   %ebp
  pd[0] = size-1;
801060a1:	b8 ff 07 00 00       	mov    $0x7ff,%eax
801060a6:	89 e5                	mov    %esp,%ebp
801060a8:	83 ec 10             	sub    $0x10,%esp
801060ab:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801060af:	b8 60 73 11 80       	mov    $0x80117360,%eax
801060b4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801060b8:	c1 e8 10             	shr    $0x10,%eax
801060bb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801060bf:	8d 45 fa             	lea    -0x6(%ebp),%eax
801060c2:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801060c5:	c9                   	leave  
801060c6:	c3                   	ret    
801060c7:	89 f6                	mov    %esi,%esi
801060c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801060d0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801060d0:	55                   	push   %ebp
801060d1:	89 e5                	mov    %esp,%ebp
801060d3:	57                   	push   %edi
801060d4:	56                   	push   %esi
801060d5:	53                   	push   %ebx
801060d6:	83 ec 0c             	sub    $0xc,%esp
801060d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
801060dc:	8b 43 30             	mov    0x30(%ebx),%eax
801060df:	83 f8 40             	cmp    $0x40,%eax
801060e2:	74 6c                	je     80106150 <trap+0x80>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
801060e4:	83 e8 20             	sub    $0x20,%eax
801060e7:	83 f8 1f             	cmp    $0x1f,%eax
801060ea:	0f 87 98 00 00 00    	ja     80106188 <trap+0xb8>
801060f0:	ff 24 85 1c 83 10 80 	jmp    *-0x7fef7ce4(,%eax,4)
801060f7:	89 f6                	mov    %esi,%esi
801060f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  case T_IRQ0 + IRQ_TIMER:
    if(cpunum() == 0){
80106100:	e8 2b c6 ff ff       	call   80102730 <cpunum>
80106105:	85 c0                	test   %eax,%eax
80106107:	0f 84 a3 01 00 00    	je     801062b0 <trap+0x1e0>
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
8010610d:	e8 ce c6 ff ff       	call   801027e0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106112:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106118:	85 c0                	test   %eax,%eax
8010611a:	74 29                	je     80106145 <trap+0x75>
8010611c:	8b 50 48             	mov    0x48(%eax),%edx
8010611f:	85 d2                	test   %edx,%edx
80106121:	0f 85 b9 00 00 00    	jne    801061e0 <trap+0x110>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106127:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010612b:	0f 84 3f 01 00 00    	je     80106270 <trap+0x1a0>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106131:	8b 40 48             	mov    0x48(%eax),%eax
80106134:	85 c0                	test   %eax,%eax
80106136:	74 0d                	je     80106145 <trap+0x75>
80106138:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010613c:	83 e0 03             	and    $0x3,%eax
8010613f:	66 83 f8 03          	cmp    $0x3,%ax
80106143:	74 31                	je     80106176 <trap+0xa6>
    exit();
}
80106145:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106148:	5b                   	pop    %ebx
80106149:	5e                   	pop    %esi
8010614a:	5f                   	pop    %edi
8010614b:	5d                   	pop    %ebp
8010614c:	c3                   	ret    
8010614d:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
80106150:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106156:	8b 70 48             	mov    0x48(%eax),%esi
80106159:	85 f6                	test   %esi,%esi
8010615b:	0f 85 37 01 00 00    	jne    80106298 <trap+0x1c8>
    proc->tf = tf;
80106161:	89 58 3c             	mov    %ebx,0x3c(%eax)
    syscall();
80106164:	e8 c7 ee ff ff       	call   80105030 <syscall>
    if(proc->killed)
80106169:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010616f:	8b 58 48             	mov    0x48(%eax),%ebx
80106172:	85 db                	test   %ebx,%ebx
80106174:	74 cf                	je     80106145 <trap+0x75>
}
80106176:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106179:	5b                   	pop    %ebx
8010617a:	5e                   	pop    %esi
8010617b:	5f                   	pop    %edi
8010617c:	5d                   	pop    %ebp
      exit();
8010617d:	e9 9e dc ff ff       	jmp    80103e20 <exit>
80106182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(proc == 0 || (tf->cs&3) == 0){
80106188:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010618f:	8b 73 38             	mov    0x38(%ebx),%esi
80106192:	85 c9                	test   %ecx,%ecx
80106194:	0f 84 4a 01 00 00    	je     801062e4 <trap+0x214>
8010619a:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010619e:	0f 84 40 01 00 00    	je     801062e4 <trap+0x214>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801061a4:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061a7:	e8 84 c5 ff ff       	call   80102730 <cpunum>
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
801061ac:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061b3:	57                   	push   %edi
801061b4:	56                   	push   %esi
801061b5:	50                   	push   %eax
801061b6:	ff 73 34             	pushl  0x34(%ebx)
801061b9:	ff 73 30             	pushl  0x30(%ebx)
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
801061bc:	8d 82 90 00 00 00    	lea    0x90(%edx),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061c2:	50                   	push   %eax
801061c3:	ff 72 10             	pushl  0x10(%edx)
801061c6:	68 d8 82 10 80       	push   $0x801082d8
801061cb:	e8 70 a4 ff ff       	call   80100640 <cprintf>
    proc->killed = 1;
801061d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061d6:	83 c4 20             	add    $0x20,%esp
801061d9:	c7 40 48 01 00 00 00 	movl   $0x1,0x48(%eax)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801061e0:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
801061e4:	83 e2 03             	and    $0x3,%edx
801061e7:	66 83 fa 03          	cmp    $0x3,%dx
801061eb:	0f 85 36 ff ff ff    	jne    80106127 <trap+0x57>
    exit();
801061f1:	e8 2a dc ff ff       	call   80103e20 <exit>
801061f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801061fc:	85 c0                	test   %eax,%eax
801061fe:	0f 85 23 ff ff ff    	jne    80106127 <trap+0x57>
80106204:	e9 3c ff ff ff       	jmp    80106145 <trap+0x75>
80106209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kbdintr();
80106210:	e8 fb c3 ff ff       	call   80102610 <kbdintr>
    lapiceoi();
80106215:	e8 c6 c5 ff ff       	call   801027e0 <lapiceoi>
    break;
8010621a:	e9 f3 fe ff ff       	jmp    80106112 <trap+0x42>
8010621f:	90                   	nop
    uartintr();
80106220:	e8 5b 02 00 00       	call   80106480 <uartintr>
80106225:	e9 e3 fe ff ff       	jmp    8010610d <trap+0x3d>
8010622a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106230:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80106234:	8b 7b 38             	mov    0x38(%ebx),%edi
80106237:	e8 f4 c4 ff ff       	call   80102730 <cpunum>
8010623c:	57                   	push   %edi
8010623d:	56                   	push   %esi
8010623e:	50                   	push   %eax
8010623f:	68 80 82 10 80       	push   $0x80108280
80106244:	e8 f7 a3 ff ff       	call   80100640 <cprintf>
    lapiceoi();
80106249:	e8 92 c5 ff ff       	call   801027e0 <lapiceoi>
    break;
8010624e:	83 c4 10             	add    $0x10,%esp
80106251:	e9 bc fe ff ff       	jmp    80106112 <trap+0x42>
80106256:	8d 76 00             	lea    0x0(%esi),%esi
80106259:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ideintr();
80106260:	e8 0b be ff ff       	call   80102070 <ideintr>
    lapiceoi();
80106265:	e8 76 c5 ff ff       	call   801027e0 <lapiceoi>
    break;
8010626a:	e9 a3 fe ff ff       	jmp    80106112 <trap+0x42>
8010626f:	90                   	nop
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106270:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80106274:	0f 85 b7 fe ff ff    	jne    80106131 <trap+0x61>
    yield();
8010627a:	e8 d1 dd ff ff       	call   80104050 <yield>
8010627f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106285:	85 c0                	test   %eax,%eax
80106287:	0f 85 a4 fe ff ff    	jne    80106131 <trap+0x61>
8010628d:	e9 b3 fe ff ff       	jmp    80106145 <trap+0x75>
80106292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80106298:	e8 83 db ff ff       	call   80103e20 <exit>
8010629d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062a3:	e9 b9 fe ff ff       	jmp    80106161 <trap+0x91>
801062a8:	90                   	nop
801062a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      acquire(&tickslock);
801062b0:	83 ec 0c             	sub    $0xc,%esp
801062b3:	68 20 73 11 80       	push   $0x80117320
801062b8:	e8 73 e7 ff ff       	call   80104a30 <acquire>
      wakeup(&ticks);
801062bd:	c7 04 24 60 7b 11 80 	movl   $0x80117b60,(%esp)
      ticks++;
801062c4:	83 05 60 7b 11 80 01 	addl   $0x1,0x80117b60
      wakeup(&ticks);
801062cb:	e8 b0 df ff ff       	call   80104280 <wakeup>
      release(&tickslock);
801062d0:	c7 04 24 20 73 11 80 	movl   $0x80117320,(%esp)
801062d7:	e8 14 e9 ff ff       	call   80104bf0 <release>
801062dc:	83 c4 10             	add    $0x10,%esp
801062df:	e9 29 fe ff ff       	jmp    8010610d <trap+0x3d>
801062e4:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801062e7:	e8 44 c4 ff ff       	call   80102730 <cpunum>
801062ec:	83 ec 0c             	sub    $0xc,%esp
801062ef:	57                   	push   %edi
801062f0:	56                   	push   %esi
801062f1:	50                   	push   %eax
801062f2:	ff 73 30             	pushl  0x30(%ebx)
801062f5:	68 a4 82 10 80       	push   $0x801082a4
801062fa:	e8 41 a3 ff ff       	call   80100640 <cprintf>
      panic("trap");
801062ff:	83 c4 14             	add    $0x14,%esp
80106302:	68 7a 82 10 80       	push   $0x8010827a
80106307:	e8 64 a0 ff ff       	call   80100370 <panic>
8010630c:	66 90                	xchg   %ax,%ax
8010630e:	66 90                	xchg   %ax,%ax

80106310 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80106310:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
{
80106315:	55                   	push   %ebp
80106316:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106318:	85 c0                	test   %eax,%eax
8010631a:	74 1c                	je     80106338 <uartgetc+0x28>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010631c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106321:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80106322:	a8 01                	test   $0x1,%al
80106324:	74 12                	je     80106338 <uartgetc+0x28>
80106326:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010632b:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010632c:	0f b6 c0             	movzbl %al,%eax
}
8010632f:	5d                   	pop    %ebp
80106330:	c3                   	ret    
80106331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80106338:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010633d:	5d                   	pop    %ebp
8010633e:	c3                   	ret    
8010633f:	90                   	nop

80106340 <uartputc.part.0>:
uartputc(int c)
80106340:	55                   	push   %ebp
80106341:	89 e5                	mov    %esp,%ebp
80106343:	57                   	push   %edi
80106344:	56                   	push   %esi
80106345:	53                   	push   %ebx
80106346:	89 c7                	mov    %eax,%edi
80106348:	bb 80 00 00 00       	mov    $0x80,%ebx
8010634d:	be fd 03 00 00       	mov    $0x3fd,%esi
80106352:	83 ec 0c             	sub    $0xc,%esp
80106355:	eb 1b                	jmp    80106372 <uartputc.part.0+0x32>
80106357:	89 f6                	mov    %esi,%esi
80106359:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    microdelay(10);
80106360:	83 ec 0c             	sub    $0xc,%esp
80106363:	6a 0a                	push   $0xa
80106365:	e8 96 c4 ff ff       	call   80102800 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010636a:	83 c4 10             	add    $0x10,%esp
8010636d:	83 eb 01             	sub    $0x1,%ebx
80106370:	74 07                	je     80106379 <uartputc.part.0+0x39>
80106372:	89 f2                	mov    %esi,%edx
80106374:	ec                   	in     (%dx),%al
80106375:	a8 20                	test   $0x20,%al
80106377:	74 e7                	je     80106360 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106379:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010637e:	89 f8                	mov    %edi,%eax
80106380:	ee                   	out    %al,(%dx)
}
80106381:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106384:	5b                   	pop    %ebx
80106385:	5e                   	pop    %esi
80106386:	5f                   	pop    %edi
80106387:	5d                   	pop    %ebp
80106388:	c3                   	ret    
80106389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106390 <uartinit>:
{
80106390:	55                   	push   %ebp
80106391:	31 c9                	xor    %ecx,%ecx
80106393:	89 c8                	mov    %ecx,%eax
80106395:	89 e5                	mov    %esp,%ebp
80106397:	57                   	push   %edi
80106398:	56                   	push   %esi
80106399:	53                   	push   %ebx
8010639a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
8010639f:	89 da                	mov    %ebx,%edx
801063a1:	83 ec 0c             	sub    $0xc,%esp
801063a4:	ee                   	out    %al,(%dx)
801063a5:	bf fb 03 00 00       	mov    $0x3fb,%edi
801063aa:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801063af:	89 fa                	mov    %edi,%edx
801063b1:	ee                   	out    %al,(%dx)
801063b2:	b8 0c 00 00 00       	mov    $0xc,%eax
801063b7:	ba f8 03 00 00       	mov    $0x3f8,%edx
801063bc:	ee                   	out    %al,(%dx)
801063bd:	be f9 03 00 00       	mov    $0x3f9,%esi
801063c2:	89 c8                	mov    %ecx,%eax
801063c4:	89 f2                	mov    %esi,%edx
801063c6:	ee                   	out    %al,(%dx)
801063c7:	b8 03 00 00 00       	mov    $0x3,%eax
801063cc:	89 fa                	mov    %edi,%edx
801063ce:	ee                   	out    %al,(%dx)
801063cf:	ba fc 03 00 00       	mov    $0x3fc,%edx
801063d4:	89 c8                	mov    %ecx,%eax
801063d6:	ee                   	out    %al,(%dx)
801063d7:	b8 01 00 00 00       	mov    $0x1,%eax
801063dc:	89 f2                	mov    %esi,%edx
801063de:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801063df:	ba fd 03 00 00       	mov    $0x3fd,%edx
801063e4:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801063e5:	3c ff                	cmp    $0xff,%al
801063e7:	74 5a                	je     80106443 <uartinit+0xb3>
  uart = 1;
801063e9:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801063f0:	00 00 00 
801063f3:	89 da                	mov    %ebx,%edx
801063f5:	ec                   	in     (%dx),%al
801063f6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801063fb:	ec                   	in     (%dx),%al
  picenable(IRQ_COM1);
801063fc:	83 ec 0c             	sub    $0xc,%esp
801063ff:	6a 04                	push   $0x4
80106401:	e8 fa ce ff ff       	call   80103300 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106406:	59                   	pop    %ecx
80106407:	5b                   	pop    %ebx
80106408:	6a 00                	push   $0x0
8010640a:	6a 04                	push   $0x4
  for(p="xv6...\n"; *p; p++)
8010640c:	bb 9c 83 10 80       	mov    $0x8010839c,%ebx
  ioapicenable(IRQ_COM1, 0);
80106411:	e8 ba be ff ff       	call   801022d0 <ioapicenable>
80106416:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106419:	b8 78 00 00 00       	mov    $0x78,%eax
8010641e:	eb 0a                	jmp    8010642a <uartinit+0x9a>
80106420:	83 c3 01             	add    $0x1,%ebx
80106423:	0f be 03             	movsbl (%ebx),%eax
80106426:	84 c0                	test   %al,%al
80106428:	74 19                	je     80106443 <uartinit+0xb3>
  if(!uart)
8010642a:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
80106430:	85 d2                	test   %edx,%edx
80106432:	74 ec                	je     80106420 <uartinit+0x90>
  for(p="xv6...\n"; *p; p++)
80106434:	83 c3 01             	add    $0x1,%ebx
80106437:	e8 04 ff ff ff       	call   80106340 <uartputc.part.0>
8010643c:	0f be 03             	movsbl (%ebx),%eax
8010643f:	84 c0                	test   %al,%al
80106441:	75 e7                	jne    8010642a <uartinit+0x9a>
}
80106443:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106446:	5b                   	pop    %ebx
80106447:	5e                   	pop    %esi
80106448:	5f                   	pop    %edi
80106449:	5d                   	pop    %ebp
8010644a:	c3                   	ret    
8010644b:	90                   	nop
8010644c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106450 <uartputc>:
  if(!uart)
80106450:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
{
80106456:	55                   	push   %ebp
80106457:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106459:	85 d2                	test   %edx,%edx
{
8010645b:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
8010645e:	74 10                	je     80106470 <uartputc+0x20>
}
80106460:	5d                   	pop    %ebp
80106461:	e9 da fe ff ff       	jmp    80106340 <uartputc.part.0>
80106466:	8d 76 00             	lea    0x0(%esi),%esi
80106469:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80106470:	5d                   	pop    %ebp
80106471:	c3                   	ret    
80106472:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106480 <uartintr>:

void
uartintr(void)
{
80106480:	55                   	push   %ebp
80106481:	89 e5                	mov    %esp,%ebp
80106483:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106486:	68 10 63 10 80       	push   $0x80106310
8010648b:	e8 60 a3 ff ff       	call   801007f0 <consoleintr>
}
80106490:	83 c4 10             	add    $0x10,%esp
80106493:	c9                   	leave  
80106494:	c3                   	ret    

80106495 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106495:	6a 00                	push   $0x0
  pushl $0
80106497:	6a 00                	push   $0x0
  jmp alltraps
80106499:	e9 50 fb ff ff       	jmp    80105fee <alltraps>

8010649e <vector1>:
.globl vector1
vector1:
  pushl $0
8010649e:	6a 00                	push   $0x0
  pushl $1
801064a0:	6a 01                	push   $0x1
  jmp alltraps
801064a2:	e9 47 fb ff ff       	jmp    80105fee <alltraps>

801064a7 <vector2>:
.globl vector2
vector2:
  pushl $0
801064a7:	6a 00                	push   $0x0
  pushl $2
801064a9:	6a 02                	push   $0x2
  jmp alltraps
801064ab:	e9 3e fb ff ff       	jmp    80105fee <alltraps>

801064b0 <vector3>:
.globl vector3
vector3:
  pushl $0
801064b0:	6a 00                	push   $0x0
  pushl $3
801064b2:	6a 03                	push   $0x3
  jmp alltraps
801064b4:	e9 35 fb ff ff       	jmp    80105fee <alltraps>

801064b9 <vector4>:
.globl vector4
vector4:
  pushl $0
801064b9:	6a 00                	push   $0x0
  pushl $4
801064bb:	6a 04                	push   $0x4
  jmp alltraps
801064bd:	e9 2c fb ff ff       	jmp    80105fee <alltraps>

801064c2 <vector5>:
.globl vector5
vector5:
  pushl $0
801064c2:	6a 00                	push   $0x0
  pushl $5
801064c4:	6a 05                	push   $0x5
  jmp alltraps
801064c6:	e9 23 fb ff ff       	jmp    80105fee <alltraps>

801064cb <vector6>:
.globl vector6
vector6:
  pushl $0
801064cb:	6a 00                	push   $0x0
  pushl $6
801064cd:	6a 06                	push   $0x6
  jmp alltraps
801064cf:	e9 1a fb ff ff       	jmp    80105fee <alltraps>

801064d4 <vector7>:
.globl vector7
vector7:
  pushl $0
801064d4:	6a 00                	push   $0x0
  pushl $7
801064d6:	6a 07                	push   $0x7
  jmp alltraps
801064d8:	e9 11 fb ff ff       	jmp    80105fee <alltraps>

801064dd <vector8>:
.globl vector8
vector8:
  pushl $8
801064dd:	6a 08                	push   $0x8
  jmp alltraps
801064df:	e9 0a fb ff ff       	jmp    80105fee <alltraps>

801064e4 <vector9>:
.globl vector9
vector9:
  pushl $0
801064e4:	6a 00                	push   $0x0
  pushl $9
801064e6:	6a 09                	push   $0x9
  jmp alltraps
801064e8:	e9 01 fb ff ff       	jmp    80105fee <alltraps>

801064ed <vector10>:
.globl vector10
vector10:
  pushl $10
801064ed:	6a 0a                	push   $0xa
  jmp alltraps
801064ef:	e9 fa fa ff ff       	jmp    80105fee <alltraps>

801064f4 <vector11>:
.globl vector11
vector11:
  pushl $11
801064f4:	6a 0b                	push   $0xb
  jmp alltraps
801064f6:	e9 f3 fa ff ff       	jmp    80105fee <alltraps>

801064fb <vector12>:
.globl vector12
vector12:
  pushl $12
801064fb:	6a 0c                	push   $0xc
  jmp alltraps
801064fd:	e9 ec fa ff ff       	jmp    80105fee <alltraps>

80106502 <vector13>:
.globl vector13
vector13:
  pushl $13
80106502:	6a 0d                	push   $0xd
  jmp alltraps
80106504:	e9 e5 fa ff ff       	jmp    80105fee <alltraps>

80106509 <vector14>:
.globl vector14
vector14:
  pushl $14
80106509:	6a 0e                	push   $0xe
  jmp alltraps
8010650b:	e9 de fa ff ff       	jmp    80105fee <alltraps>

80106510 <vector15>:
.globl vector15
vector15:
  pushl $0
80106510:	6a 00                	push   $0x0
  pushl $15
80106512:	6a 0f                	push   $0xf
  jmp alltraps
80106514:	e9 d5 fa ff ff       	jmp    80105fee <alltraps>

80106519 <vector16>:
.globl vector16
vector16:
  pushl $0
80106519:	6a 00                	push   $0x0
  pushl $16
8010651b:	6a 10                	push   $0x10
  jmp alltraps
8010651d:	e9 cc fa ff ff       	jmp    80105fee <alltraps>

80106522 <vector17>:
.globl vector17
vector17:
  pushl $17
80106522:	6a 11                	push   $0x11
  jmp alltraps
80106524:	e9 c5 fa ff ff       	jmp    80105fee <alltraps>

80106529 <vector18>:
.globl vector18
vector18:
  pushl $0
80106529:	6a 00                	push   $0x0
  pushl $18
8010652b:	6a 12                	push   $0x12
  jmp alltraps
8010652d:	e9 bc fa ff ff       	jmp    80105fee <alltraps>

80106532 <vector19>:
.globl vector19
vector19:
  pushl $0
80106532:	6a 00                	push   $0x0
  pushl $19
80106534:	6a 13                	push   $0x13
  jmp alltraps
80106536:	e9 b3 fa ff ff       	jmp    80105fee <alltraps>

8010653b <vector20>:
.globl vector20
vector20:
  pushl $0
8010653b:	6a 00                	push   $0x0
  pushl $20
8010653d:	6a 14                	push   $0x14
  jmp alltraps
8010653f:	e9 aa fa ff ff       	jmp    80105fee <alltraps>

80106544 <vector21>:
.globl vector21
vector21:
  pushl $0
80106544:	6a 00                	push   $0x0
  pushl $21
80106546:	6a 15                	push   $0x15
  jmp alltraps
80106548:	e9 a1 fa ff ff       	jmp    80105fee <alltraps>

8010654d <vector22>:
.globl vector22
vector22:
  pushl $0
8010654d:	6a 00                	push   $0x0
  pushl $22
8010654f:	6a 16                	push   $0x16
  jmp alltraps
80106551:	e9 98 fa ff ff       	jmp    80105fee <alltraps>

80106556 <vector23>:
.globl vector23
vector23:
  pushl $0
80106556:	6a 00                	push   $0x0
  pushl $23
80106558:	6a 17                	push   $0x17
  jmp alltraps
8010655a:	e9 8f fa ff ff       	jmp    80105fee <alltraps>

8010655f <vector24>:
.globl vector24
vector24:
  pushl $0
8010655f:	6a 00                	push   $0x0
  pushl $24
80106561:	6a 18                	push   $0x18
  jmp alltraps
80106563:	e9 86 fa ff ff       	jmp    80105fee <alltraps>

80106568 <vector25>:
.globl vector25
vector25:
  pushl $0
80106568:	6a 00                	push   $0x0
  pushl $25
8010656a:	6a 19                	push   $0x19
  jmp alltraps
8010656c:	e9 7d fa ff ff       	jmp    80105fee <alltraps>

80106571 <vector26>:
.globl vector26
vector26:
  pushl $0
80106571:	6a 00                	push   $0x0
  pushl $26
80106573:	6a 1a                	push   $0x1a
  jmp alltraps
80106575:	e9 74 fa ff ff       	jmp    80105fee <alltraps>

8010657a <vector27>:
.globl vector27
vector27:
  pushl $0
8010657a:	6a 00                	push   $0x0
  pushl $27
8010657c:	6a 1b                	push   $0x1b
  jmp alltraps
8010657e:	e9 6b fa ff ff       	jmp    80105fee <alltraps>

80106583 <vector28>:
.globl vector28
vector28:
  pushl $0
80106583:	6a 00                	push   $0x0
  pushl $28
80106585:	6a 1c                	push   $0x1c
  jmp alltraps
80106587:	e9 62 fa ff ff       	jmp    80105fee <alltraps>

8010658c <vector29>:
.globl vector29
vector29:
  pushl $0
8010658c:	6a 00                	push   $0x0
  pushl $29
8010658e:	6a 1d                	push   $0x1d
  jmp alltraps
80106590:	e9 59 fa ff ff       	jmp    80105fee <alltraps>

80106595 <vector30>:
.globl vector30
vector30:
  pushl $0
80106595:	6a 00                	push   $0x0
  pushl $30
80106597:	6a 1e                	push   $0x1e
  jmp alltraps
80106599:	e9 50 fa ff ff       	jmp    80105fee <alltraps>

8010659e <vector31>:
.globl vector31
vector31:
  pushl $0
8010659e:	6a 00                	push   $0x0
  pushl $31
801065a0:	6a 1f                	push   $0x1f
  jmp alltraps
801065a2:	e9 47 fa ff ff       	jmp    80105fee <alltraps>

801065a7 <vector32>:
.globl vector32
vector32:
  pushl $0
801065a7:	6a 00                	push   $0x0
  pushl $32
801065a9:	6a 20                	push   $0x20
  jmp alltraps
801065ab:	e9 3e fa ff ff       	jmp    80105fee <alltraps>

801065b0 <vector33>:
.globl vector33
vector33:
  pushl $0
801065b0:	6a 00                	push   $0x0
  pushl $33
801065b2:	6a 21                	push   $0x21
  jmp alltraps
801065b4:	e9 35 fa ff ff       	jmp    80105fee <alltraps>

801065b9 <vector34>:
.globl vector34
vector34:
  pushl $0
801065b9:	6a 00                	push   $0x0
  pushl $34
801065bb:	6a 22                	push   $0x22
  jmp alltraps
801065bd:	e9 2c fa ff ff       	jmp    80105fee <alltraps>

801065c2 <vector35>:
.globl vector35
vector35:
  pushl $0
801065c2:	6a 00                	push   $0x0
  pushl $35
801065c4:	6a 23                	push   $0x23
  jmp alltraps
801065c6:	e9 23 fa ff ff       	jmp    80105fee <alltraps>

801065cb <vector36>:
.globl vector36
vector36:
  pushl $0
801065cb:	6a 00                	push   $0x0
  pushl $36
801065cd:	6a 24                	push   $0x24
  jmp alltraps
801065cf:	e9 1a fa ff ff       	jmp    80105fee <alltraps>

801065d4 <vector37>:
.globl vector37
vector37:
  pushl $0
801065d4:	6a 00                	push   $0x0
  pushl $37
801065d6:	6a 25                	push   $0x25
  jmp alltraps
801065d8:	e9 11 fa ff ff       	jmp    80105fee <alltraps>

801065dd <vector38>:
.globl vector38
vector38:
  pushl $0
801065dd:	6a 00                	push   $0x0
  pushl $38
801065df:	6a 26                	push   $0x26
  jmp alltraps
801065e1:	e9 08 fa ff ff       	jmp    80105fee <alltraps>

801065e6 <vector39>:
.globl vector39
vector39:
  pushl $0
801065e6:	6a 00                	push   $0x0
  pushl $39
801065e8:	6a 27                	push   $0x27
  jmp alltraps
801065ea:	e9 ff f9 ff ff       	jmp    80105fee <alltraps>

801065ef <vector40>:
.globl vector40
vector40:
  pushl $0
801065ef:	6a 00                	push   $0x0
  pushl $40
801065f1:	6a 28                	push   $0x28
  jmp alltraps
801065f3:	e9 f6 f9 ff ff       	jmp    80105fee <alltraps>

801065f8 <vector41>:
.globl vector41
vector41:
  pushl $0
801065f8:	6a 00                	push   $0x0
  pushl $41
801065fa:	6a 29                	push   $0x29
  jmp alltraps
801065fc:	e9 ed f9 ff ff       	jmp    80105fee <alltraps>

80106601 <vector42>:
.globl vector42
vector42:
  pushl $0
80106601:	6a 00                	push   $0x0
  pushl $42
80106603:	6a 2a                	push   $0x2a
  jmp alltraps
80106605:	e9 e4 f9 ff ff       	jmp    80105fee <alltraps>

8010660a <vector43>:
.globl vector43
vector43:
  pushl $0
8010660a:	6a 00                	push   $0x0
  pushl $43
8010660c:	6a 2b                	push   $0x2b
  jmp alltraps
8010660e:	e9 db f9 ff ff       	jmp    80105fee <alltraps>

80106613 <vector44>:
.globl vector44
vector44:
  pushl $0
80106613:	6a 00                	push   $0x0
  pushl $44
80106615:	6a 2c                	push   $0x2c
  jmp alltraps
80106617:	e9 d2 f9 ff ff       	jmp    80105fee <alltraps>

8010661c <vector45>:
.globl vector45
vector45:
  pushl $0
8010661c:	6a 00                	push   $0x0
  pushl $45
8010661e:	6a 2d                	push   $0x2d
  jmp alltraps
80106620:	e9 c9 f9 ff ff       	jmp    80105fee <alltraps>

80106625 <vector46>:
.globl vector46
vector46:
  pushl $0
80106625:	6a 00                	push   $0x0
  pushl $46
80106627:	6a 2e                	push   $0x2e
  jmp alltraps
80106629:	e9 c0 f9 ff ff       	jmp    80105fee <alltraps>

8010662e <vector47>:
.globl vector47
vector47:
  pushl $0
8010662e:	6a 00                	push   $0x0
  pushl $47
80106630:	6a 2f                	push   $0x2f
  jmp alltraps
80106632:	e9 b7 f9 ff ff       	jmp    80105fee <alltraps>

80106637 <vector48>:
.globl vector48
vector48:
  pushl $0
80106637:	6a 00                	push   $0x0
  pushl $48
80106639:	6a 30                	push   $0x30
  jmp alltraps
8010663b:	e9 ae f9 ff ff       	jmp    80105fee <alltraps>

80106640 <vector49>:
.globl vector49
vector49:
  pushl $0
80106640:	6a 00                	push   $0x0
  pushl $49
80106642:	6a 31                	push   $0x31
  jmp alltraps
80106644:	e9 a5 f9 ff ff       	jmp    80105fee <alltraps>

80106649 <vector50>:
.globl vector50
vector50:
  pushl $0
80106649:	6a 00                	push   $0x0
  pushl $50
8010664b:	6a 32                	push   $0x32
  jmp alltraps
8010664d:	e9 9c f9 ff ff       	jmp    80105fee <alltraps>

80106652 <vector51>:
.globl vector51
vector51:
  pushl $0
80106652:	6a 00                	push   $0x0
  pushl $51
80106654:	6a 33                	push   $0x33
  jmp alltraps
80106656:	e9 93 f9 ff ff       	jmp    80105fee <alltraps>

8010665b <vector52>:
.globl vector52
vector52:
  pushl $0
8010665b:	6a 00                	push   $0x0
  pushl $52
8010665d:	6a 34                	push   $0x34
  jmp alltraps
8010665f:	e9 8a f9 ff ff       	jmp    80105fee <alltraps>

80106664 <vector53>:
.globl vector53
vector53:
  pushl $0
80106664:	6a 00                	push   $0x0
  pushl $53
80106666:	6a 35                	push   $0x35
  jmp alltraps
80106668:	e9 81 f9 ff ff       	jmp    80105fee <alltraps>

8010666d <vector54>:
.globl vector54
vector54:
  pushl $0
8010666d:	6a 00                	push   $0x0
  pushl $54
8010666f:	6a 36                	push   $0x36
  jmp alltraps
80106671:	e9 78 f9 ff ff       	jmp    80105fee <alltraps>

80106676 <vector55>:
.globl vector55
vector55:
  pushl $0
80106676:	6a 00                	push   $0x0
  pushl $55
80106678:	6a 37                	push   $0x37
  jmp alltraps
8010667a:	e9 6f f9 ff ff       	jmp    80105fee <alltraps>

8010667f <vector56>:
.globl vector56
vector56:
  pushl $0
8010667f:	6a 00                	push   $0x0
  pushl $56
80106681:	6a 38                	push   $0x38
  jmp alltraps
80106683:	e9 66 f9 ff ff       	jmp    80105fee <alltraps>

80106688 <vector57>:
.globl vector57
vector57:
  pushl $0
80106688:	6a 00                	push   $0x0
  pushl $57
8010668a:	6a 39                	push   $0x39
  jmp alltraps
8010668c:	e9 5d f9 ff ff       	jmp    80105fee <alltraps>

80106691 <vector58>:
.globl vector58
vector58:
  pushl $0
80106691:	6a 00                	push   $0x0
  pushl $58
80106693:	6a 3a                	push   $0x3a
  jmp alltraps
80106695:	e9 54 f9 ff ff       	jmp    80105fee <alltraps>

8010669a <vector59>:
.globl vector59
vector59:
  pushl $0
8010669a:	6a 00                	push   $0x0
  pushl $59
8010669c:	6a 3b                	push   $0x3b
  jmp alltraps
8010669e:	e9 4b f9 ff ff       	jmp    80105fee <alltraps>

801066a3 <vector60>:
.globl vector60
vector60:
  pushl $0
801066a3:	6a 00                	push   $0x0
  pushl $60
801066a5:	6a 3c                	push   $0x3c
  jmp alltraps
801066a7:	e9 42 f9 ff ff       	jmp    80105fee <alltraps>

801066ac <vector61>:
.globl vector61
vector61:
  pushl $0
801066ac:	6a 00                	push   $0x0
  pushl $61
801066ae:	6a 3d                	push   $0x3d
  jmp alltraps
801066b0:	e9 39 f9 ff ff       	jmp    80105fee <alltraps>

801066b5 <vector62>:
.globl vector62
vector62:
  pushl $0
801066b5:	6a 00                	push   $0x0
  pushl $62
801066b7:	6a 3e                	push   $0x3e
  jmp alltraps
801066b9:	e9 30 f9 ff ff       	jmp    80105fee <alltraps>

801066be <vector63>:
.globl vector63
vector63:
  pushl $0
801066be:	6a 00                	push   $0x0
  pushl $63
801066c0:	6a 3f                	push   $0x3f
  jmp alltraps
801066c2:	e9 27 f9 ff ff       	jmp    80105fee <alltraps>

801066c7 <vector64>:
.globl vector64
vector64:
  pushl $0
801066c7:	6a 00                	push   $0x0
  pushl $64
801066c9:	6a 40                	push   $0x40
  jmp alltraps
801066cb:	e9 1e f9 ff ff       	jmp    80105fee <alltraps>

801066d0 <vector65>:
.globl vector65
vector65:
  pushl $0
801066d0:	6a 00                	push   $0x0
  pushl $65
801066d2:	6a 41                	push   $0x41
  jmp alltraps
801066d4:	e9 15 f9 ff ff       	jmp    80105fee <alltraps>

801066d9 <vector66>:
.globl vector66
vector66:
  pushl $0
801066d9:	6a 00                	push   $0x0
  pushl $66
801066db:	6a 42                	push   $0x42
  jmp alltraps
801066dd:	e9 0c f9 ff ff       	jmp    80105fee <alltraps>

801066e2 <vector67>:
.globl vector67
vector67:
  pushl $0
801066e2:	6a 00                	push   $0x0
  pushl $67
801066e4:	6a 43                	push   $0x43
  jmp alltraps
801066e6:	e9 03 f9 ff ff       	jmp    80105fee <alltraps>

801066eb <vector68>:
.globl vector68
vector68:
  pushl $0
801066eb:	6a 00                	push   $0x0
  pushl $68
801066ed:	6a 44                	push   $0x44
  jmp alltraps
801066ef:	e9 fa f8 ff ff       	jmp    80105fee <alltraps>

801066f4 <vector69>:
.globl vector69
vector69:
  pushl $0
801066f4:	6a 00                	push   $0x0
  pushl $69
801066f6:	6a 45                	push   $0x45
  jmp alltraps
801066f8:	e9 f1 f8 ff ff       	jmp    80105fee <alltraps>

801066fd <vector70>:
.globl vector70
vector70:
  pushl $0
801066fd:	6a 00                	push   $0x0
  pushl $70
801066ff:	6a 46                	push   $0x46
  jmp alltraps
80106701:	e9 e8 f8 ff ff       	jmp    80105fee <alltraps>

80106706 <vector71>:
.globl vector71
vector71:
  pushl $0
80106706:	6a 00                	push   $0x0
  pushl $71
80106708:	6a 47                	push   $0x47
  jmp alltraps
8010670a:	e9 df f8 ff ff       	jmp    80105fee <alltraps>

8010670f <vector72>:
.globl vector72
vector72:
  pushl $0
8010670f:	6a 00                	push   $0x0
  pushl $72
80106711:	6a 48                	push   $0x48
  jmp alltraps
80106713:	e9 d6 f8 ff ff       	jmp    80105fee <alltraps>

80106718 <vector73>:
.globl vector73
vector73:
  pushl $0
80106718:	6a 00                	push   $0x0
  pushl $73
8010671a:	6a 49                	push   $0x49
  jmp alltraps
8010671c:	e9 cd f8 ff ff       	jmp    80105fee <alltraps>

80106721 <vector74>:
.globl vector74
vector74:
  pushl $0
80106721:	6a 00                	push   $0x0
  pushl $74
80106723:	6a 4a                	push   $0x4a
  jmp alltraps
80106725:	e9 c4 f8 ff ff       	jmp    80105fee <alltraps>

8010672a <vector75>:
.globl vector75
vector75:
  pushl $0
8010672a:	6a 00                	push   $0x0
  pushl $75
8010672c:	6a 4b                	push   $0x4b
  jmp alltraps
8010672e:	e9 bb f8 ff ff       	jmp    80105fee <alltraps>

80106733 <vector76>:
.globl vector76
vector76:
  pushl $0
80106733:	6a 00                	push   $0x0
  pushl $76
80106735:	6a 4c                	push   $0x4c
  jmp alltraps
80106737:	e9 b2 f8 ff ff       	jmp    80105fee <alltraps>

8010673c <vector77>:
.globl vector77
vector77:
  pushl $0
8010673c:	6a 00                	push   $0x0
  pushl $77
8010673e:	6a 4d                	push   $0x4d
  jmp alltraps
80106740:	e9 a9 f8 ff ff       	jmp    80105fee <alltraps>

80106745 <vector78>:
.globl vector78
vector78:
  pushl $0
80106745:	6a 00                	push   $0x0
  pushl $78
80106747:	6a 4e                	push   $0x4e
  jmp alltraps
80106749:	e9 a0 f8 ff ff       	jmp    80105fee <alltraps>

8010674e <vector79>:
.globl vector79
vector79:
  pushl $0
8010674e:	6a 00                	push   $0x0
  pushl $79
80106750:	6a 4f                	push   $0x4f
  jmp alltraps
80106752:	e9 97 f8 ff ff       	jmp    80105fee <alltraps>

80106757 <vector80>:
.globl vector80
vector80:
  pushl $0
80106757:	6a 00                	push   $0x0
  pushl $80
80106759:	6a 50                	push   $0x50
  jmp alltraps
8010675b:	e9 8e f8 ff ff       	jmp    80105fee <alltraps>

80106760 <vector81>:
.globl vector81
vector81:
  pushl $0
80106760:	6a 00                	push   $0x0
  pushl $81
80106762:	6a 51                	push   $0x51
  jmp alltraps
80106764:	e9 85 f8 ff ff       	jmp    80105fee <alltraps>

80106769 <vector82>:
.globl vector82
vector82:
  pushl $0
80106769:	6a 00                	push   $0x0
  pushl $82
8010676b:	6a 52                	push   $0x52
  jmp alltraps
8010676d:	e9 7c f8 ff ff       	jmp    80105fee <alltraps>

80106772 <vector83>:
.globl vector83
vector83:
  pushl $0
80106772:	6a 00                	push   $0x0
  pushl $83
80106774:	6a 53                	push   $0x53
  jmp alltraps
80106776:	e9 73 f8 ff ff       	jmp    80105fee <alltraps>

8010677b <vector84>:
.globl vector84
vector84:
  pushl $0
8010677b:	6a 00                	push   $0x0
  pushl $84
8010677d:	6a 54                	push   $0x54
  jmp alltraps
8010677f:	e9 6a f8 ff ff       	jmp    80105fee <alltraps>

80106784 <vector85>:
.globl vector85
vector85:
  pushl $0
80106784:	6a 00                	push   $0x0
  pushl $85
80106786:	6a 55                	push   $0x55
  jmp alltraps
80106788:	e9 61 f8 ff ff       	jmp    80105fee <alltraps>

8010678d <vector86>:
.globl vector86
vector86:
  pushl $0
8010678d:	6a 00                	push   $0x0
  pushl $86
8010678f:	6a 56                	push   $0x56
  jmp alltraps
80106791:	e9 58 f8 ff ff       	jmp    80105fee <alltraps>

80106796 <vector87>:
.globl vector87
vector87:
  pushl $0
80106796:	6a 00                	push   $0x0
  pushl $87
80106798:	6a 57                	push   $0x57
  jmp alltraps
8010679a:	e9 4f f8 ff ff       	jmp    80105fee <alltraps>

8010679f <vector88>:
.globl vector88
vector88:
  pushl $0
8010679f:	6a 00                	push   $0x0
  pushl $88
801067a1:	6a 58                	push   $0x58
  jmp alltraps
801067a3:	e9 46 f8 ff ff       	jmp    80105fee <alltraps>

801067a8 <vector89>:
.globl vector89
vector89:
  pushl $0
801067a8:	6a 00                	push   $0x0
  pushl $89
801067aa:	6a 59                	push   $0x59
  jmp alltraps
801067ac:	e9 3d f8 ff ff       	jmp    80105fee <alltraps>

801067b1 <vector90>:
.globl vector90
vector90:
  pushl $0
801067b1:	6a 00                	push   $0x0
  pushl $90
801067b3:	6a 5a                	push   $0x5a
  jmp alltraps
801067b5:	e9 34 f8 ff ff       	jmp    80105fee <alltraps>

801067ba <vector91>:
.globl vector91
vector91:
  pushl $0
801067ba:	6a 00                	push   $0x0
  pushl $91
801067bc:	6a 5b                	push   $0x5b
  jmp alltraps
801067be:	e9 2b f8 ff ff       	jmp    80105fee <alltraps>

801067c3 <vector92>:
.globl vector92
vector92:
  pushl $0
801067c3:	6a 00                	push   $0x0
  pushl $92
801067c5:	6a 5c                	push   $0x5c
  jmp alltraps
801067c7:	e9 22 f8 ff ff       	jmp    80105fee <alltraps>

801067cc <vector93>:
.globl vector93
vector93:
  pushl $0
801067cc:	6a 00                	push   $0x0
  pushl $93
801067ce:	6a 5d                	push   $0x5d
  jmp alltraps
801067d0:	e9 19 f8 ff ff       	jmp    80105fee <alltraps>

801067d5 <vector94>:
.globl vector94
vector94:
  pushl $0
801067d5:	6a 00                	push   $0x0
  pushl $94
801067d7:	6a 5e                	push   $0x5e
  jmp alltraps
801067d9:	e9 10 f8 ff ff       	jmp    80105fee <alltraps>

801067de <vector95>:
.globl vector95
vector95:
  pushl $0
801067de:	6a 00                	push   $0x0
  pushl $95
801067e0:	6a 5f                	push   $0x5f
  jmp alltraps
801067e2:	e9 07 f8 ff ff       	jmp    80105fee <alltraps>

801067e7 <vector96>:
.globl vector96
vector96:
  pushl $0
801067e7:	6a 00                	push   $0x0
  pushl $96
801067e9:	6a 60                	push   $0x60
  jmp alltraps
801067eb:	e9 fe f7 ff ff       	jmp    80105fee <alltraps>

801067f0 <vector97>:
.globl vector97
vector97:
  pushl $0
801067f0:	6a 00                	push   $0x0
  pushl $97
801067f2:	6a 61                	push   $0x61
  jmp alltraps
801067f4:	e9 f5 f7 ff ff       	jmp    80105fee <alltraps>

801067f9 <vector98>:
.globl vector98
vector98:
  pushl $0
801067f9:	6a 00                	push   $0x0
  pushl $98
801067fb:	6a 62                	push   $0x62
  jmp alltraps
801067fd:	e9 ec f7 ff ff       	jmp    80105fee <alltraps>

80106802 <vector99>:
.globl vector99
vector99:
  pushl $0
80106802:	6a 00                	push   $0x0
  pushl $99
80106804:	6a 63                	push   $0x63
  jmp alltraps
80106806:	e9 e3 f7 ff ff       	jmp    80105fee <alltraps>

8010680b <vector100>:
.globl vector100
vector100:
  pushl $0
8010680b:	6a 00                	push   $0x0
  pushl $100
8010680d:	6a 64                	push   $0x64
  jmp alltraps
8010680f:	e9 da f7 ff ff       	jmp    80105fee <alltraps>

80106814 <vector101>:
.globl vector101
vector101:
  pushl $0
80106814:	6a 00                	push   $0x0
  pushl $101
80106816:	6a 65                	push   $0x65
  jmp alltraps
80106818:	e9 d1 f7 ff ff       	jmp    80105fee <alltraps>

8010681d <vector102>:
.globl vector102
vector102:
  pushl $0
8010681d:	6a 00                	push   $0x0
  pushl $102
8010681f:	6a 66                	push   $0x66
  jmp alltraps
80106821:	e9 c8 f7 ff ff       	jmp    80105fee <alltraps>

80106826 <vector103>:
.globl vector103
vector103:
  pushl $0
80106826:	6a 00                	push   $0x0
  pushl $103
80106828:	6a 67                	push   $0x67
  jmp alltraps
8010682a:	e9 bf f7 ff ff       	jmp    80105fee <alltraps>

8010682f <vector104>:
.globl vector104
vector104:
  pushl $0
8010682f:	6a 00                	push   $0x0
  pushl $104
80106831:	6a 68                	push   $0x68
  jmp alltraps
80106833:	e9 b6 f7 ff ff       	jmp    80105fee <alltraps>

80106838 <vector105>:
.globl vector105
vector105:
  pushl $0
80106838:	6a 00                	push   $0x0
  pushl $105
8010683a:	6a 69                	push   $0x69
  jmp alltraps
8010683c:	e9 ad f7 ff ff       	jmp    80105fee <alltraps>

80106841 <vector106>:
.globl vector106
vector106:
  pushl $0
80106841:	6a 00                	push   $0x0
  pushl $106
80106843:	6a 6a                	push   $0x6a
  jmp alltraps
80106845:	e9 a4 f7 ff ff       	jmp    80105fee <alltraps>

8010684a <vector107>:
.globl vector107
vector107:
  pushl $0
8010684a:	6a 00                	push   $0x0
  pushl $107
8010684c:	6a 6b                	push   $0x6b
  jmp alltraps
8010684e:	e9 9b f7 ff ff       	jmp    80105fee <alltraps>

80106853 <vector108>:
.globl vector108
vector108:
  pushl $0
80106853:	6a 00                	push   $0x0
  pushl $108
80106855:	6a 6c                	push   $0x6c
  jmp alltraps
80106857:	e9 92 f7 ff ff       	jmp    80105fee <alltraps>

8010685c <vector109>:
.globl vector109
vector109:
  pushl $0
8010685c:	6a 00                	push   $0x0
  pushl $109
8010685e:	6a 6d                	push   $0x6d
  jmp alltraps
80106860:	e9 89 f7 ff ff       	jmp    80105fee <alltraps>

80106865 <vector110>:
.globl vector110
vector110:
  pushl $0
80106865:	6a 00                	push   $0x0
  pushl $110
80106867:	6a 6e                	push   $0x6e
  jmp alltraps
80106869:	e9 80 f7 ff ff       	jmp    80105fee <alltraps>

8010686e <vector111>:
.globl vector111
vector111:
  pushl $0
8010686e:	6a 00                	push   $0x0
  pushl $111
80106870:	6a 6f                	push   $0x6f
  jmp alltraps
80106872:	e9 77 f7 ff ff       	jmp    80105fee <alltraps>

80106877 <vector112>:
.globl vector112
vector112:
  pushl $0
80106877:	6a 00                	push   $0x0
  pushl $112
80106879:	6a 70                	push   $0x70
  jmp alltraps
8010687b:	e9 6e f7 ff ff       	jmp    80105fee <alltraps>

80106880 <vector113>:
.globl vector113
vector113:
  pushl $0
80106880:	6a 00                	push   $0x0
  pushl $113
80106882:	6a 71                	push   $0x71
  jmp alltraps
80106884:	e9 65 f7 ff ff       	jmp    80105fee <alltraps>

80106889 <vector114>:
.globl vector114
vector114:
  pushl $0
80106889:	6a 00                	push   $0x0
  pushl $114
8010688b:	6a 72                	push   $0x72
  jmp alltraps
8010688d:	e9 5c f7 ff ff       	jmp    80105fee <alltraps>

80106892 <vector115>:
.globl vector115
vector115:
  pushl $0
80106892:	6a 00                	push   $0x0
  pushl $115
80106894:	6a 73                	push   $0x73
  jmp alltraps
80106896:	e9 53 f7 ff ff       	jmp    80105fee <alltraps>

8010689b <vector116>:
.globl vector116
vector116:
  pushl $0
8010689b:	6a 00                	push   $0x0
  pushl $116
8010689d:	6a 74                	push   $0x74
  jmp alltraps
8010689f:	e9 4a f7 ff ff       	jmp    80105fee <alltraps>

801068a4 <vector117>:
.globl vector117
vector117:
  pushl $0
801068a4:	6a 00                	push   $0x0
  pushl $117
801068a6:	6a 75                	push   $0x75
  jmp alltraps
801068a8:	e9 41 f7 ff ff       	jmp    80105fee <alltraps>

801068ad <vector118>:
.globl vector118
vector118:
  pushl $0
801068ad:	6a 00                	push   $0x0
  pushl $118
801068af:	6a 76                	push   $0x76
  jmp alltraps
801068b1:	e9 38 f7 ff ff       	jmp    80105fee <alltraps>

801068b6 <vector119>:
.globl vector119
vector119:
  pushl $0
801068b6:	6a 00                	push   $0x0
  pushl $119
801068b8:	6a 77                	push   $0x77
  jmp alltraps
801068ba:	e9 2f f7 ff ff       	jmp    80105fee <alltraps>

801068bf <vector120>:
.globl vector120
vector120:
  pushl $0
801068bf:	6a 00                	push   $0x0
  pushl $120
801068c1:	6a 78                	push   $0x78
  jmp alltraps
801068c3:	e9 26 f7 ff ff       	jmp    80105fee <alltraps>

801068c8 <vector121>:
.globl vector121
vector121:
  pushl $0
801068c8:	6a 00                	push   $0x0
  pushl $121
801068ca:	6a 79                	push   $0x79
  jmp alltraps
801068cc:	e9 1d f7 ff ff       	jmp    80105fee <alltraps>

801068d1 <vector122>:
.globl vector122
vector122:
  pushl $0
801068d1:	6a 00                	push   $0x0
  pushl $122
801068d3:	6a 7a                	push   $0x7a
  jmp alltraps
801068d5:	e9 14 f7 ff ff       	jmp    80105fee <alltraps>

801068da <vector123>:
.globl vector123
vector123:
  pushl $0
801068da:	6a 00                	push   $0x0
  pushl $123
801068dc:	6a 7b                	push   $0x7b
  jmp alltraps
801068de:	e9 0b f7 ff ff       	jmp    80105fee <alltraps>

801068e3 <vector124>:
.globl vector124
vector124:
  pushl $0
801068e3:	6a 00                	push   $0x0
  pushl $124
801068e5:	6a 7c                	push   $0x7c
  jmp alltraps
801068e7:	e9 02 f7 ff ff       	jmp    80105fee <alltraps>

801068ec <vector125>:
.globl vector125
vector125:
  pushl $0
801068ec:	6a 00                	push   $0x0
  pushl $125
801068ee:	6a 7d                	push   $0x7d
  jmp alltraps
801068f0:	e9 f9 f6 ff ff       	jmp    80105fee <alltraps>

801068f5 <vector126>:
.globl vector126
vector126:
  pushl $0
801068f5:	6a 00                	push   $0x0
  pushl $126
801068f7:	6a 7e                	push   $0x7e
  jmp alltraps
801068f9:	e9 f0 f6 ff ff       	jmp    80105fee <alltraps>

801068fe <vector127>:
.globl vector127
vector127:
  pushl $0
801068fe:	6a 00                	push   $0x0
  pushl $127
80106900:	6a 7f                	push   $0x7f
  jmp alltraps
80106902:	e9 e7 f6 ff ff       	jmp    80105fee <alltraps>

80106907 <vector128>:
.globl vector128
vector128:
  pushl $0
80106907:	6a 00                	push   $0x0
  pushl $128
80106909:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010690e:	e9 db f6 ff ff       	jmp    80105fee <alltraps>

80106913 <vector129>:
.globl vector129
vector129:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $129
80106915:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010691a:	e9 cf f6 ff ff       	jmp    80105fee <alltraps>

8010691f <vector130>:
.globl vector130
vector130:
  pushl $0
8010691f:	6a 00                	push   $0x0
  pushl $130
80106921:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106926:	e9 c3 f6 ff ff       	jmp    80105fee <alltraps>

8010692b <vector131>:
.globl vector131
vector131:
  pushl $0
8010692b:	6a 00                	push   $0x0
  pushl $131
8010692d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106932:	e9 b7 f6 ff ff       	jmp    80105fee <alltraps>

80106937 <vector132>:
.globl vector132
vector132:
  pushl $0
80106937:	6a 00                	push   $0x0
  pushl $132
80106939:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010693e:	e9 ab f6 ff ff       	jmp    80105fee <alltraps>

80106943 <vector133>:
.globl vector133
vector133:
  pushl $0
80106943:	6a 00                	push   $0x0
  pushl $133
80106945:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010694a:	e9 9f f6 ff ff       	jmp    80105fee <alltraps>

8010694f <vector134>:
.globl vector134
vector134:
  pushl $0
8010694f:	6a 00                	push   $0x0
  pushl $134
80106951:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106956:	e9 93 f6 ff ff       	jmp    80105fee <alltraps>

8010695b <vector135>:
.globl vector135
vector135:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $135
8010695d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106962:	e9 87 f6 ff ff       	jmp    80105fee <alltraps>

80106967 <vector136>:
.globl vector136
vector136:
  pushl $0
80106967:	6a 00                	push   $0x0
  pushl $136
80106969:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010696e:	e9 7b f6 ff ff       	jmp    80105fee <alltraps>

80106973 <vector137>:
.globl vector137
vector137:
  pushl $0
80106973:	6a 00                	push   $0x0
  pushl $137
80106975:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010697a:	e9 6f f6 ff ff       	jmp    80105fee <alltraps>

8010697f <vector138>:
.globl vector138
vector138:
  pushl $0
8010697f:	6a 00                	push   $0x0
  pushl $138
80106981:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106986:	e9 63 f6 ff ff       	jmp    80105fee <alltraps>

8010698b <vector139>:
.globl vector139
vector139:
  pushl $0
8010698b:	6a 00                	push   $0x0
  pushl $139
8010698d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106992:	e9 57 f6 ff ff       	jmp    80105fee <alltraps>

80106997 <vector140>:
.globl vector140
vector140:
  pushl $0
80106997:	6a 00                	push   $0x0
  pushl $140
80106999:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010699e:	e9 4b f6 ff ff       	jmp    80105fee <alltraps>

801069a3 <vector141>:
.globl vector141
vector141:
  pushl $0
801069a3:	6a 00                	push   $0x0
  pushl $141
801069a5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801069aa:	e9 3f f6 ff ff       	jmp    80105fee <alltraps>

801069af <vector142>:
.globl vector142
vector142:
  pushl $0
801069af:	6a 00                	push   $0x0
  pushl $142
801069b1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801069b6:	e9 33 f6 ff ff       	jmp    80105fee <alltraps>

801069bb <vector143>:
.globl vector143
vector143:
  pushl $0
801069bb:	6a 00                	push   $0x0
  pushl $143
801069bd:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801069c2:	e9 27 f6 ff ff       	jmp    80105fee <alltraps>

801069c7 <vector144>:
.globl vector144
vector144:
  pushl $0
801069c7:	6a 00                	push   $0x0
  pushl $144
801069c9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801069ce:	e9 1b f6 ff ff       	jmp    80105fee <alltraps>

801069d3 <vector145>:
.globl vector145
vector145:
  pushl $0
801069d3:	6a 00                	push   $0x0
  pushl $145
801069d5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801069da:	e9 0f f6 ff ff       	jmp    80105fee <alltraps>

801069df <vector146>:
.globl vector146
vector146:
  pushl $0
801069df:	6a 00                	push   $0x0
  pushl $146
801069e1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801069e6:	e9 03 f6 ff ff       	jmp    80105fee <alltraps>

801069eb <vector147>:
.globl vector147
vector147:
  pushl $0
801069eb:	6a 00                	push   $0x0
  pushl $147
801069ed:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801069f2:	e9 f7 f5 ff ff       	jmp    80105fee <alltraps>

801069f7 <vector148>:
.globl vector148
vector148:
  pushl $0
801069f7:	6a 00                	push   $0x0
  pushl $148
801069f9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801069fe:	e9 eb f5 ff ff       	jmp    80105fee <alltraps>

80106a03 <vector149>:
.globl vector149
vector149:
  pushl $0
80106a03:	6a 00                	push   $0x0
  pushl $149
80106a05:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106a0a:	e9 df f5 ff ff       	jmp    80105fee <alltraps>

80106a0f <vector150>:
.globl vector150
vector150:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $150
80106a11:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106a16:	e9 d3 f5 ff ff       	jmp    80105fee <alltraps>

80106a1b <vector151>:
.globl vector151
vector151:
  pushl $0
80106a1b:	6a 00                	push   $0x0
  pushl $151
80106a1d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a22:	e9 c7 f5 ff ff       	jmp    80105fee <alltraps>

80106a27 <vector152>:
.globl vector152
vector152:
  pushl $0
80106a27:	6a 00                	push   $0x0
  pushl $152
80106a29:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a2e:	e9 bb f5 ff ff       	jmp    80105fee <alltraps>

80106a33 <vector153>:
.globl vector153
vector153:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $153
80106a35:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a3a:	e9 af f5 ff ff       	jmp    80105fee <alltraps>

80106a3f <vector154>:
.globl vector154
vector154:
  pushl $0
80106a3f:	6a 00                	push   $0x0
  pushl $154
80106a41:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106a46:	e9 a3 f5 ff ff       	jmp    80105fee <alltraps>

80106a4b <vector155>:
.globl vector155
vector155:
  pushl $0
80106a4b:	6a 00                	push   $0x0
  pushl $155
80106a4d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106a52:	e9 97 f5 ff ff       	jmp    80105fee <alltraps>

80106a57 <vector156>:
.globl vector156
vector156:
  pushl $0
80106a57:	6a 00                	push   $0x0
  pushl $156
80106a59:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106a5e:	e9 8b f5 ff ff       	jmp    80105fee <alltraps>

80106a63 <vector157>:
.globl vector157
vector157:
  pushl $0
80106a63:	6a 00                	push   $0x0
  pushl $157
80106a65:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106a6a:	e9 7f f5 ff ff       	jmp    80105fee <alltraps>

80106a6f <vector158>:
.globl vector158
vector158:
  pushl $0
80106a6f:	6a 00                	push   $0x0
  pushl $158
80106a71:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106a76:	e9 73 f5 ff ff       	jmp    80105fee <alltraps>

80106a7b <vector159>:
.globl vector159
vector159:
  pushl $0
80106a7b:	6a 00                	push   $0x0
  pushl $159
80106a7d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106a82:	e9 67 f5 ff ff       	jmp    80105fee <alltraps>

80106a87 <vector160>:
.globl vector160
vector160:
  pushl $0
80106a87:	6a 00                	push   $0x0
  pushl $160
80106a89:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106a8e:	e9 5b f5 ff ff       	jmp    80105fee <alltraps>

80106a93 <vector161>:
.globl vector161
vector161:
  pushl $0
80106a93:	6a 00                	push   $0x0
  pushl $161
80106a95:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106a9a:	e9 4f f5 ff ff       	jmp    80105fee <alltraps>

80106a9f <vector162>:
.globl vector162
vector162:
  pushl $0
80106a9f:	6a 00                	push   $0x0
  pushl $162
80106aa1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106aa6:	e9 43 f5 ff ff       	jmp    80105fee <alltraps>

80106aab <vector163>:
.globl vector163
vector163:
  pushl $0
80106aab:	6a 00                	push   $0x0
  pushl $163
80106aad:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ab2:	e9 37 f5 ff ff       	jmp    80105fee <alltraps>

80106ab7 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ab7:	6a 00                	push   $0x0
  pushl $164
80106ab9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106abe:	e9 2b f5 ff ff       	jmp    80105fee <alltraps>

80106ac3 <vector165>:
.globl vector165
vector165:
  pushl $0
80106ac3:	6a 00                	push   $0x0
  pushl $165
80106ac5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106aca:	e9 1f f5 ff ff       	jmp    80105fee <alltraps>

80106acf <vector166>:
.globl vector166
vector166:
  pushl $0
80106acf:	6a 00                	push   $0x0
  pushl $166
80106ad1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ad6:	e9 13 f5 ff ff       	jmp    80105fee <alltraps>

80106adb <vector167>:
.globl vector167
vector167:
  pushl $0
80106adb:	6a 00                	push   $0x0
  pushl $167
80106add:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106ae2:	e9 07 f5 ff ff       	jmp    80105fee <alltraps>

80106ae7 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ae7:	6a 00                	push   $0x0
  pushl $168
80106ae9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106aee:	e9 fb f4 ff ff       	jmp    80105fee <alltraps>

80106af3 <vector169>:
.globl vector169
vector169:
  pushl $0
80106af3:	6a 00                	push   $0x0
  pushl $169
80106af5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106afa:	e9 ef f4 ff ff       	jmp    80105fee <alltraps>

80106aff <vector170>:
.globl vector170
vector170:
  pushl $0
80106aff:	6a 00                	push   $0x0
  pushl $170
80106b01:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106b06:	e9 e3 f4 ff ff       	jmp    80105fee <alltraps>

80106b0b <vector171>:
.globl vector171
vector171:
  pushl $0
80106b0b:	6a 00                	push   $0x0
  pushl $171
80106b0d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106b12:	e9 d7 f4 ff ff       	jmp    80105fee <alltraps>

80106b17 <vector172>:
.globl vector172
vector172:
  pushl $0
80106b17:	6a 00                	push   $0x0
  pushl $172
80106b19:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b1e:	e9 cb f4 ff ff       	jmp    80105fee <alltraps>

80106b23 <vector173>:
.globl vector173
vector173:
  pushl $0
80106b23:	6a 00                	push   $0x0
  pushl $173
80106b25:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b2a:	e9 bf f4 ff ff       	jmp    80105fee <alltraps>

80106b2f <vector174>:
.globl vector174
vector174:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $174
80106b31:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b36:	e9 b3 f4 ff ff       	jmp    80105fee <alltraps>

80106b3b <vector175>:
.globl vector175
vector175:
  pushl $0
80106b3b:	6a 00                	push   $0x0
  pushl $175
80106b3d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106b42:	e9 a7 f4 ff ff       	jmp    80105fee <alltraps>

80106b47 <vector176>:
.globl vector176
vector176:
  pushl $0
80106b47:	6a 00                	push   $0x0
  pushl $176
80106b49:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106b4e:	e9 9b f4 ff ff       	jmp    80105fee <alltraps>

80106b53 <vector177>:
.globl vector177
vector177:
  pushl $0
80106b53:	6a 00                	push   $0x0
  pushl $177
80106b55:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106b5a:	e9 8f f4 ff ff       	jmp    80105fee <alltraps>

80106b5f <vector178>:
.globl vector178
vector178:
  pushl $0
80106b5f:	6a 00                	push   $0x0
  pushl $178
80106b61:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106b66:	e9 83 f4 ff ff       	jmp    80105fee <alltraps>

80106b6b <vector179>:
.globl vector179
vector179:
  pushl $0
80106b6b:	6a 00                	push   $0x0
  pushl $179
80106b6d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106b72:	e9 77 f4 ff ff       	jmp    80105fee <alltraps>

80106b77 <vector180>:
.globl vector180
vector180:
  pushl $0
80106b77:	6a 00                	push   $0x0
  pushl $180
80106b79:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106b7e:	e9 6b f4 ff ff       	jmp    80105fee <alltraps>

80106b83 <vector181>:
.globl vector181
vector181:
  pushl $0
80106b83:	6a 00                	push   $0x0
  pushl $181
80106b85:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106b8a:	e9 5f f4 ff ff       	jmp    80105fee <alltraps>

80106b8f <vector182>:
.globl vector182
vector182:
  pushl $0
80106b8f:	6a 00                	push   $0x0
  pushl $182
80106b91:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106b96:	e9 53 f4 ff ff       	jmp    80105fee <alltraps>

80106b9b <vector183>:
.globl vector183
vector183:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $183
80106b9d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106ba2:	e9 47 f4 ff ff       	jmp    80105fee <alltraps>

80106ba7 <vector184>:
.globl vector184
vector184:
  pushl $0
80106ba7:	6a 00                	push   $0x0
  pushl $184
80106ba9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106bae:	e9 3b f4 ff ff       	jmp    80105fee <alltraps>

80106bb3 <vector185>:
.globl vector185
vector185:
  pushl $0
80106bb3:	6a 00                	push   $0x0
  pushl $185
80106bb5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106bba:	e9 2f f4 ff ff       	jmp    80105fee <alltraps>

80106bbf <vector186>:
.globl vector186
vector186:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $186
80106bc1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106bc6:	e9 23 f4 ff ff       	jmp    80105fee <alltraps>

80106bcb <vector187>:
.globl vector187
vector187:
  pushl $0
80106bcb:	6a 00                	push   $0x0
  pushl $187
80106bcd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106bd2:	e9 17 f4 ff ff       	jmp    80105fee <alltraps>

80106bd7 <vector188>:
.globl vector188
vector188:
  pushl $0
80106bd7:	6a 00                	push   $0x0
  pushl $188
80106bd9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106bde:	e9 0b f4 ff ff       	jmp    80105fee <alltraps>

80106be3 <vector189>:
.globl vector189
vector189:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $189
80106be5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106bea:	e9 ff f3 ff ff       	jmp    80105fee <alltraps>

80106bef <vector190>:
.globl vector190
vector190:
  pushl $0
80106bef:	6a 00                	push   $0x0
  pushl $190
80106bf1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106bf6:	e9 f3 f3 ff ff       	jmp    80105fee <alltraps>

80106bfb <vector191>:
.globl vector191
vector191:
  pushl $0
80106bfb:	6a 00                	push   $0x0
  pushl $191
80106bfd:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106c02:	e9 e7 f3 ff ff       	jmp    80105fee <alltraps>

80106c07 <vector192>:
.globl vector192
vector192:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $192
80106c09:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106c0e:	e9 db f3 ff ff       	jmp    80105fee <alltraps>

80106c13 <vector193>:
.globl vector193
vector193:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $193
80106c15:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106c1a:	e9 cf f3 ff ff       	jmp    80105fee <alltraps>

80106c1f <vector194>:
.globl vector194
vector194:
  pushl $0
80106c1f:	6a 00                	push   $0x0
  pushl $194
80106c21:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c26:	e9 c3 f3 ff ff       	jmp    80105fee <alltraps>

80106c2b <vector195>:
.globl vector195
vector195:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $195
80106c2d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c32:	e9 b7 f3 ff ff       	jmp    80105fee <alltraps>

80106c37 <vector196>:
.globl vector196
vector196:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $196
80106c39:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106c3e:	e9 ab f3 ff ff       	jmp    80105fee <alltraps>

80106c43 <vector197>:
.globl vector197
vector197:
  pushl $0
80106c43:	6a 00                	push   $0x0
  pushl $197
80106c45:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106c4a:	e9 9f f3 ff ff       	jmp    80105fee <alltraps>

80106c4f <vector198>:
.globl vector198
vector198:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $198
80106c51:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106c56:	e9 93 f3 ff ff       	jmp    80105fee <alltraps>

80106c5b <vector199>:
.globl vector199
vector199:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $199
80106c5d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106c62:	e9 87 f3 ff ff       	jmp    80105fee <alltraps>

80106c67 <vector200>:
.globl vector200
vector200:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $200
80106c69:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106c6e:	e9 7b f3 ff ff       	jmp    80105fee <alltraps>

80106c73 <vector201>:
.globl vector201
vector201:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $201
80106c75:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106c7a:	e9 6f f3 ff ff       	jmp    80105fee <alltraps>

80106c7f <vector202>:
.globl vector202
vector202:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $202
80106c81:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106c86:	e9 63 f3 ff ff       	jmp    80105fee <alltraps>

80106c8b <vector203>:
.globl vector203
vector203:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $203
80106c8d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106c92:	e9 57 f3 ff ff       	jmp    80105fee <alltraps>

80106c97 <vector204>:
.globl vector204
vector204:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $204
80106c99:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106c9e:	e9 4b f3 ff ff       	jmp    80105fee <alltraps>

80106ca3 <vector205>:
.globl vector205
vector205:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $205
80106ca5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106caa:	e9 3f f3 ff ff       	jmp    80105fee <alltraps>

80106caf <vector206>:
.globl vector206
vector206:
  pushl $0
80106caf:	6a 00                	push   $0x0
  pushl $206
80106cb1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106cb6:	e9 33 f3 ff ff       	jmp    80105fee <alltraps>

80106cbb <vector207>:
.globl vector207
vector207:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $207
80106cbd:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106cc2:	e9 27 f3 ff ff       	jmp    80105fee <alltraps>

80106cc7 <vector208>:
.globl vector208
vector208:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $208
80106cc9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106cce:	e9 1b f3 ff ff       	jmp    80105fee <alltraps>

80106cd3 <vector209>:
.globl vector209
vector209:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $209
80106cd5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106cda:	e9 0f f3 ff ff       	jmp    80105fee <alltraps>

80106cdf <vector210>:
.globl vector210
vector210:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $210
80106ce1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106ce6:	e9 03 f3 ff ff       	jmp    80105fee <alltraps>

80106ceb <vector211>:
.globl vector211
vector211:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $211
80106ced:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106cf2:	e9 f7 f2 ff ff       	jmp    80105fee <alltraps>

80106cf7 <vector212>:
.globl vector212
vector212:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $212
80106cf9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106cfe:	e9 eb f2 ff ff       	jmp    80105fee <alltraps>

80106d03 <vector213>:
.globl vector213
vector213:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $213
80106d05:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106d0a:	e9 df f2 ff ff       	jmp    80105fee <alltraps>

80106d0f <vector214>:
.globl vector214
vector214:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $214
80106d11:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106d16:	e9 d3 f2 ff ff       	jmp    80105fee <alltraps>

80106d1b <vector215>:
.globl vector215
vector215:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $215
80106d1d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d22:	e9 c7 f2 ff ff       	jmp    80105fee <alltraps>

80106d27 <vector216>:
.globl vector216
vector216:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $216
80106d29:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d2e:	e9 bb f2 ff ff       	jmp    80105fee <alltraps>

80106d33 <vector217>:
.globl vector217
vector217:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $217
80106d35:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d3a:	e9 af f2 ff ff       	jmp    80105fee <alltraps>

80106d3f <vector218>:
.globl vector218
vector218:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $218
80106d41:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106d46:	e9 a3 f2 ff ff       	jmp    80105fee <alltraps>

80106d4b <vector219>:
.globl vector219
vector219:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $219
80106d4d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106d52:	e9 97 f2 ff ff       	jmp    80105fee <alltraps>

80106d57 <vector220>:
.globl vector220
vector220:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $220
80106d59:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106d5e:	e9 8b f2 ff ff       	jmp    80105fee <alltraps>

80106d63 <vector221>:
.globl vector221
vector221:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $221
80106d65:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106d6a:	e9 7f f2 ff ff       	jmp    80105fee <alltraps>

80106d6f <vector222>:
.globl vector222
vector222:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $222
80106d71:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106d76:	e9 73 f2 ff ff       	jmp    80105fee <alltraps>

80106d7b <vector223>:
.globl vector223
vector223:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $223
80106d7d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106d82:	e9 67 f2 ff ff       	jmp    80105fee <alltraps>

80106d87 <vector224>:
.globl vector224
vector224:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $224
80106d89:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106d8e:	e9 5b f2 ff ff       	jmp    80105fee <alltraps>

80106d93 <vector225>:
.globl vector225
vector225:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $225
80106d95:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106d9a:	e9 4f f2 ff ff       	jmp    80105fee <alltraps>

80106d9f <vector226>:
.globl vector226
vector226:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $226
80106da1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106da6:	e9 43 f2 ff ff       	jmp    80105fee <alltraps>

80106dab <vector227>:
.globl vector227
vector227:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $227
80106dad:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106db2:	e9 37 f2 ff ff       	jmp    80105fee <alltraps>

80106db7 <vector228>:
.globl vector228
vector228:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $228
80106db9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106dbe:	e9 2b f2 ff ff       	jmp    80105fee <alltraps>

80106dc3 <vector229>:
.globl vector229
vector229:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $229
80106dc5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106dca:	e9 1f f2 ff ff       	jmp    80105fee <alltraps>

80106dcf <vector230>:
.globl vector230
vector230:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $230
80106dd1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106dd6:	e9 13 f2 ff ff       	jmp    80105fee <alltraps>

80106ddb <vector231>:
.globl vector231
vector231:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $231
80106ddd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106de2:	e9 07 f2 ff ff       	jmp    80105fee <alltraps>

80106de7 <vector232>:
.globl vector232
vector232:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $232
80106de9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106dee:	e9 fb f1 ff ff       	jmp    80105fee <alltraps>

80106df3 <vector233>:
.globl vector233
vector233:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $233
80106df5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106dfa:	e9 ef f1 ff ff       	jmp    80105fee <alltraps>

80106dff <vector234>:
.globl vector234
vector234:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $234
80106e01:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106e06:	e9 e3 f1 ff ff       	jmp    80105fee <alltraps>

80106e0b <vector235>:
.globl vector235
vector235:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $235
80106e0d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106e12:	e9 d7 f1 ff ff       	jmp    80105fee <alltraps>

80106e17 <vector236>:
.globl vector236
vector236:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $236
80106e19:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e1e:	e9 cb f1 ff ff       	jmp    80105fee <alltraps>

80106e23 <vector237>:
.globl vector237
vector237:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $237
80106e25:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e2a:	e9 bf f1 ff ff       	jmp    80105fee <alltraps>

80106e2f <vector238>:
.globl vector238
vector238:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $238
80106e31:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e36:	e9 b3 f1 ff ff       	jmp    80105fee <alltraps>

80106e3b <vector239>:
.globl vector239
vector239:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $239
80106e3d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106e42:	e9 a7 f1 ff ff       	jmp    80105fee <alltraps>

80106e47 <vector240>:
.globl vector240
vector240:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $240
80106e49:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106e4e:	e9 9b f1 ff ff       	jmp    80105fee <alltraps>

80106e53 <vector241>:
.globl vector241
vector241:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $241
80106e55:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106e5a:	e9 8f f1 ff ff       	jmp    80105fee <alltraps>

80106e5f <vector242>:
.globl vector242
vector242:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $242
80106e61:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106e66:	e9 83 f1 ff ff       	jmp    80105fee <alltraps>

80106e6b <vector243>:
.globl vector243
vector243:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $243
80106e6d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106e72:	e9 77 f1 ff ff       	jmp    80105fee <alltraps>

80106e77 <vector244>:
.globl vector244
vector244:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $244
80106e79:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106e7e:	e9 6b f1 ff ff       	jmp    80105fee <alltraps>

80106e83 <vector245>:
.globl vector245
vector245:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $245
80106e85:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106e8a:	e9 5f f1 ff ff       	jmp    80105fee <alltraps>

80106e8f <vector246>:
.globl vector246
vector246:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $246
80106e91:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106e96:	e9 53 f1 ff ff       	jmp    80105fee <alltraps>

80106e9b <vector247>:
.globl vector247
vector247:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $247
80106e9d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106ea2:	e9 47 f1 ff ff       	jmp    80105fee <alltraps>

80106ea7 <vector248>:
.globl vector248
vector248:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $248
80106ea9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106eae:	e9 3b f1 ff ff       	jmp    80105fee <alltraps>

80106eb3 <vector249>:
.globl vector249
vector249:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $249
80106eb5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106eba:	e9 2f f1 ff ff       	jmp    80105fee <alltraps>

80106ebf <vector250>:
.globl vector250
vector250:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $250
80106ec1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106ec6:	e9 23 f1 ff ff       	jmp    80105fee <alltraps>

80106ecb <vector251>:
.globl vector251
vector251:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $251
80106ecd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106ed2:	e9 17 f1 ff ff       	jmp    80105fee <alltraps>

80106ed7 <vector252>:
.globl vector252
vector252:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $252
80106ed9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106ede:	e9 0b f1 ff ff       	jmp    80105fee <alltraps>

80106ee3 <vector253>:
.globl vector253
vector253:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $253
80106ee5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106eea:	e9 ff f0 ff ff       	jmp    80105fee <alltraps>

80106eef <vector254>:
.globl vector254
vector254:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $254
80106ef1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106ef6:	e9 f3 f0 ff ff       	jmp    80105fee <alltraps>

80106efb <vector255>:
.globl vector255
vector255:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $255
80106efd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106f02:	e9 e7 f0 ff ff       	jmp    80105fee <alltraps>
80106f07:	66 90                	xchg   %ax,%ax
80106f09:	66 90                	xchg   %ax,%ax
80106f0b:	66 90                	xchg   %ax,%ax
80106f0d:	66 90                	xchg   %ax,%ax
80106f0f:	90                   	nop

80106f10 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106f10:	55                   	push   %ebp
80106f11:	89 e5                	mov    %esp,%ebp
80106f13:	57                   	push   %edi
80106f14:	56                   	push   %esi
80106f15:	53                   	push   %ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106f16:	89 d3                	mov    %edx,%ebx
{
80106f18:	89 d7                	mov    %edx,%edi
  pde = &pgdir[PDX(va)];
80106f1a:	c1 eb 16             	shr    $0x16,%ebx
80106f1d:	8d 34 98             	lea    (%eax,%ebx,4),%esi
{
80106f20:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80106f23:	8b 06                	mov    (%esi),%eax
80106f25:	a8 01                	test   $0x1,%al
80106f27:	74 27                	je     80106f50 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106f29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106f2e:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106f34:	c1 ef 0a             	shr    $0xa,%edi
}
80106f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80106f3a:	89 fa                	mov    %edi,%edx
80106f3c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106f42:	8d 04 13             	lea    (%ebx,%edx,1),%eax
}
80106f45:	5b                   	pop    %ebx
80106f46:	5e                   	pop    %esi
80106f47:	5f                   	pop    %edi
80106f48:	5d                   	pop    %ebp
80106f49:	c3                   	ret    
80106f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106f50:	85 c9                	test   %ecx,%ecx
80106f52:	74 2c                	je     80106f80 <walkpgdir+0x70>
80106f54:	e8 67 b5 ff ff       	call   801024c0 <kalloc>
80106f59:	85 c0                	test   %eax,%eax
80106f5b:	89 c3                	mov    %eax,%ebx
80106f5d:	74 21                	je     80106f80 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
80106f5f:	83 ec 04             	sub    $0x4,%esp
80106f62:	68 00 10 00 00       	push   $0x1000
80106f67:	6a 00                	push   $0x0
80106f69:	50                   	push   %eax
80106f6a:	e8 d1 dc ff ff       	call   80104c40 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106f6f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106f75:	83 c4 10             	add    $0x10,%esp
80106f78:	83 c8 07             	or     $0x7,%eax
80106f7b:	89 06                	mov    %eax,(%esi)
80106f7d:	eb b5                	jmp    80106f34 <walkpgdir+0x24>
80106f7f:	90                   	nop
}
80106f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80106f83:	31 c0                	xor    %eax,%eax
}
80106f85:	5b                   	pop    %ebx
80106f86:	5e                   	pop    %esi
80106f87:	5f                   	pop    %edi
80106f88:	5d                   	pop    %ebp
80106f89:	c3                   	ret    
80106f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106f90 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106f90:	55                   	push   %ebp
80106f91:	89 e5                	mov    %esp,%ebp
80106f93:	57                   	push   %edi
80106f94:	56                   	push   %esi
80106f95:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106f96:	89 d3                	mov    %edx,%ebx
80106f98:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
80106f9e:	83 ec 1c             	sub    $0x1c,%esp
80106fa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106fa4:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80106fa8:	8b 7d 08             	mov    0x8(%ebp),%edi
80106fab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106fb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
80106fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fb6:	29 df                	sub    %ebx,%edi
80106fb8:	83 c8 01             	or     $0x1,%eax
80106fbb:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106fbe:	eb 15                	jmp    80106fd5 <mappages+0x45>
    if(*pte & PTE_P)
80106fc0:	f6 00 01             	testb  $0x1,(%eax)
80106fc3:	75 45                	jne    8010700a <mappages+0x7a>
    *pte = pa | perm | PTE_P;
80106fc5:	0b 75 dc             	or     -0x24(%ebp),%esi
    if(a == last)
80106fc8:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
    *pte = pa | perm | PTE_P;
80106fcb:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106fcd:	74 31                	je     80107000 <mappages+0x70>
      break;
    a += PGSIZE;
80106fcf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106fd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fd8:	b9 01 00 00 00       	mov    $0x1,%ecx
80106fdd:	89 da                	mov    %ebx,%edx
80106fdf:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
80106fe2:	e8 29 ff ff ff       	call   80106f10 <walkpgdir>
80106fe7:	85 c0                	test   %eax,%eax
80106fe9:	75 d5                	jne    80106fc0 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
80106feb:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106fee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106ff3:	5b                   	pop    %ebx
80106ff4:	5e                   	pop    %esi
80106ff5:	5f                   	pop    %edi
80106ff6:	5d                   	pop    %ebp
80106ff7:	c3                   	ret    
80106ff8:	90                   	nop
80106ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107000:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107003:	31 c0                	xor    %eax,%eax
}
80107005:	5b                   	pop    %ebx
80107006:	5e                   	pop    %esi
80107007:	5f                   	pop    %edi
80107008:	5d                   	pop    %ebp
80107009:	c3                   	ret    
      panic("remap");
8010700a:	83 ec 0c             	sub    $0xc,%esp
8010700d:	68 a4 83 10 80       	push   $0x801083a4
80107012:	e8 59 93 ff ff       	call   80100370 <panic>
80107017:	89 f6                	mov    %esi,%esi
80107019:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107020 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107020:	55                   	push   %ebp
80107021:	89 e5                	mov    %esp,%ebp
80107023:	57                   	push   %edi
80107024:	56                   	push   %esi
80107025:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80107026:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
8010702c:	89 c7                	mov    %eax,%edi
  a = PGROUNDUP(newsz);
8010702e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107034:	83 ec 1c             	sub    $0x1c,%esp
80107037:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010703a:	39 d3                	cmp    %edx,%ebx
8010703c:	73 60                	jae    8010709e <deallocuvm.part.0+0x7e>
8010703e:	89 d6                	mov    %edx,%esi
80107040:	eb 3d                	jmp    8010707f <deallocuvm.part.0+0x5f>
80107042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a += (NPTENTRIES - 1) * PGSIZE;
    else if((*pte & PTE_P) != 0){
80107048:	8b 10                	mov    (%eax),%edx
8010704a:	f6 c2 01             	test   $0x1,%dl
8010704d:	74 26                	je     80107075 <deallocuvm.part.0+0x55>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010704f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80107055:	74 52                	je     801070a9 <deallocuvm.part.0+0x89>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80107057:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010705a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107060:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80107063:	52                   	push   %edx
80107064:	e8 a7 b2 ff ff       	call   80102310 <kfree>
      *pte = 0;
80107069:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010706c:	83 c4 10             	add    $0x10,%esp
8010706f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107075:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010707b:	39 f3                	cmp    %esi,%ebx
8010707d:	73 1f                	jae    8010709e <deallocuvm.part.0+0x7e>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010707f:	31 c9                	xor    %ecx,%ecx
80107081:	89 da                	mov    %ebx,%edx
80107083:	89 f8                	mov    %edi,%eax
80107085:	e8 86 fe ff ff       	call   80106f10 <walkpgdir>
    if(!pte)
8010708a:	85 c0                	test   %eax,%eax
8010708c:	75 ba                	jne    80107048 <deallocuvm.part.0+0x28>
      a += (NPTENTRIES - 1) * PGSIZE;
8010708e:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80107094:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010709a:	39 f3                	cmp    %esi,%ebx
8010709c:	72 e1                	jb     8010707f <deallocuvm.part.0+0x5f>
    }
  }
  return newsz;
}
8010709e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801070a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801070a4:	5b                   	pop    %ebx
801070a5:	5e                   	pop    %esi
801070a6:	5f                   	pop    %edi
801070a7:	5d                   	pop    %ebp
801070a8:	c3                   	ret    
        panic("kfree");
801070a9:	83 ec 0c             	sub    $0xc,%esp
801070ac:	68 7a 7b 10 80       	push   $0x80107b7a
801070b1:	e8 ba 92 ff ff       	call   80100370 <panic>
801070b6:	8d 76 00             	lea    0x0(%esi),%esi
801070b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801070c0 <seginit>:
{
801070c0:	55                   	push   %ebp
801070c1:	89 e5                	mov    %esp,%ebp
801070c3:	53                   	push   %ebx
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801070c4:	31 db                	xor    %ebx,%ebx
{
801070c6:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpunum()];
801070c9:	e8 62 b6 ff ff       	call   80102730 <cpunum>
801070ce:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801070d4:	8d 90 e0 22 11 80    	lea    -0x7feedd20(%eax),%edx
801070da:	8d 88 94 23 11 80    	lea    -0x7feedc6c(%eax),%ecx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801070e0:	c7 80 58 23 11 80 ff 	movl   $0xffff,-0x7feedca8(%eax)
801070e7:	ff 00 00 
801070ea:	c7 80 5c 23 11 80 00 	movl   $0xcf9a00,-0x7feedca4(%eax)
801070f1:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801070f4:	c7 80 60 23 11 80 ff 	movl   $0xffff,-0x7feedca0(%eax)
801070fb:	ff 00 00 
801070fe:	c7 80 64 23 11 80 00 	movl   $0xcf9200,-0x7feedc9c(%eax)
80107105:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107108:	c7 80 70 23 11 80 ff 	movl   $0xffff,-0x7feedc90(%eax)
8010710f:	ff 00 00 
80107112:	c7 80 74 23 11 80 00 	movl   $0xcffa00,-0x7feedc8c(%eax)
80107119:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010711c:	c7 80 78 23 11 80 ff 	movl   $0xffff,-0x7feedc88(%eax)
80107123:	ff 00 00 
80107126:	c7 80 7c 23 11 80 00 	movl   $0xcff200,-0x7feedc84(%eax)
8010712d:	f2 cf 00 
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107130:	66 89 9a 88 00 00 00 	mov    %bx,0x88(%edx)
80107137:	89 cb                	mov    %ecx,%ebx
80107139:	c1 eb 10             	shr    $0x10,%ebx
8010713c:	66 89 8a 8a 00 00 00 	mov    %cx,0x8a(%edx)
80107143:	c1 e9 18             	shr    $0x18,%ecx
80107146:	88 9a 8c 00 00 00    	mov    %bl,0x8c(%edx)
8010714c:	bb 92 c0 ff ff       	mov    $0xffffc092,%ebx
80107151:	66 89 98 6d 23 11 80 	mov    %bx,-0x7feedc93(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107158:	05 50 23 11 80       	add    $0x80112350,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010715d:	88 8a 8f 00 00 00    	mov    %cl,0x8f(%edx)
  pd[0] = size-1;
80107163:	b9 37 00 00 00       	mov    $0x37,%ecx
80107168:	66 89 4d f2          	mov    %cx,-0xe(%ebp)
  pd[1] = (uint)p;
8010716c:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107170:	c1 e8 10             	shr    $0x10,%eax
80107173:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107177:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010717a:	0f 01 10             	lgdtl  (%eax)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010717d:	b8 18 00 00 00       	mov    $0x18,%eax
80107182:	8e e8                	mov    %eax,%gs
  proc = 0;
80107184:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010718b:	00 00 00 00 
  c = &cpus[cpunum()];
8010718f:	65 89 15 00 00 00 00 	mov    %edx,%gs:0x0
}
80107196:	83 c4 14             	add    $0x14,%esp
80107199:	5b                   	pop    %ebx
8010719a:	5d                   	pop    %ebp
8010719b:	c3                   	ret    
8010719c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801071a0 <setupkvm>:
{
801071a0:	55                   	push   %ebp
801071a1:	89 e5                	mov    %esp,%ebp
801071a3:	56                   	push   %esi
801071a4:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801071a5:	e8 16 b3 ff ff       	call   801024c0 <kalloc>
801071aa:	85 c0                	test   %eax,%eax
801071ac:	74 52                	je     80107200 <setupkvm+0x60>
  memset(pgdir, 0, PGSIZE);
801071ae:	83 ec 04             	sub    $0x4,%esp
801071b1:	89 c6                	mov    %eax,%esi
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801071b3:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
801071b8:	68 00 10 00 00       	push   $0x1000
801071bd:	6a 00                	push   $0x0
801071bf:	50                   	push   %eax
801071c0:	e8 7b da ff ff       	call   80104c40 <memset>
801071c5:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0)
801071c8:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801071cb:	8b 4b 08             	mov    0x8(%ebx),%ecx
801071ce:	83 ec 08             	sub    $0x8,%esp
801071d1:	8b 13                	mov    (%ebx),%edx
801071d3:	ff 73 0c             	pushl  0xc(%ebx)
801071d6:	50                   	push   %eax
801071d7:	29 c1                	sub    %eax,%ecx
801071d9:	89 f0                	mov    %esi,%eax
801071db:	e8 b0 fd ff ff       	call   80106f90 <mappages>
801071e0:	83 c4 10             	add    $0x10,%esp
801071e3:	85 c0                	test   %eax,%eax
801071e5:	78 19                	js     80107200 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801071e7:	83 c3 10             	add    $0x10,%ebx
801071ea:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
801071f0:	75 d6                	jne    801071c8 <setupkvm+0x28>
}
801071f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801071f5:	89 f0                	mov    %esi,%eax
801071f7:	5b                   	pop    %ebx
801071f8:	5e                   	pop    %esi
801071f9:	5d                   	pop    %ebp
801071fa:	c3                   	ret    
801071fb:	90                   	nop
801071fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107200:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
80107203:	31 f6                	xor    %esi,%esi
}
80107205:	89 f0                	mov    %esi,%eax
80107207:	5b                   	pop    %ebx
80107208:	5e                   	pop    %esi
80107209:	5d                   	pop    %ebp
8010720a:	c3                   	ret    
8010720b:	90                   	nop
8010720c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107210 <kvmalloc>:
{
80107210:	55                   	push   %ebp
80107211:	89 e5                	mov    %esp,%ebp
80107213:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107216:	e8 85 ff ff ff       	call   801071a0 <setupkvm>
8010721b:	a3 64 7b 11 80       	mov    %eax,0x80117b64
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107220:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107225:	0f 22 d8             	mov    %eax,%cr3
}
80107228:	c9                   	leave  
80107229:	c3                   	ret    
8010722a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107230 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107230:	a1 64 7b 11 80       	mov    0x80117b64,%eax
{
80107235:	55                   	push   %ebp
80107236:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107238:	05 00 00 00 80       	add    $0x80000000,%eax
8010723d:	0f 22 d8             	mov    %eax,%cr3
}
80107240:	5d                   	pop    %ebp
80107241:	c3                   	ret    
80107242:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107250 <switchuvm>:
{
80107250:	55                   	push   %ebp
80107251:	89 e5                	mov    %esp,%ebp
80107253:	53                   	push   %ebx
80107254:	83 ec 04             	sub    $0x4,%esp
80107257:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010725a:	e8 11 d9 ff ff       	call   80104b70 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010725f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107265:	b9 67 00 00 00       	mov    $0x67,%ecx
8010726a:	8d 50 08             	lea    0x8(%eax),%edx
8010726d:	66 89 88 a0 00 00 00 	mov    %cx,0xa0(%eax)
80107274:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
8010727b:	89 d1                	mov    %edx,%ecx
8010727d:	c1 ea 18             	shr    $0x18,%edx
80107280:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
80107286:	ba 89 40 00 00       	mov    $0x4089,%edx
8010728b:	c1 e9 10             	shr    $0x10,%ecx
8010728e:	66 89 90 a5 00 00 00 	mov    %dx,0xa5(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107295:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010729c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801072a2:	b9 10 00 00 00       	mov    $0x10,%ecx
801072a7:	66 89 48 10          	mov    %cx,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801072ab:	8b 52 08             	mov    0x8(%edx),%edx
801072ae:	81 c2 00 10 00 00    	add    $0x1000,%edx
801072b4:	89 50 0c             	mov    %edx,0xc(%eax)
  cpu->ts.iomb = (ushort) 0xFFFF;
801072b7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801072bc:	66 89 50 6e          	mov    %dx,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801072c0:	b8 30 00 00 00       	mov    $0x30,%eax
801072c5:	0f 00 d8             	ltr    %ax
  if(p->pgdir == 0)
801072c8:	8b 43 04             	mov    0x4(%ebx),%eax
801072cb:	85 c0                	test   %eax,%eax
801072cd:	74 11                	je     801072e0 <switchuvm+0x90>
  lcr3(V2P(p->pgdir));  // switch to process's address space
801072cf:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801072d4:	0f 22 d8             	mov    %eax,%cr3
}
801072d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801072da:	c9                   	leave  
  popcli();
801072db:	e9 c0 d8 ff ff       	jmp    80104ba0 <popcli>
    panic("switchuvm: no pgdir");
801072e0:	83 ec 0c             	sub    $0xc,%esp
801072e3:	68 aa 83 10 80       	push   $0x801083aa
801072e8:	e8 83 90 ff ff       	call   80100370 <panic>
801072ed:	8d 76 00             	lea    0x0(%esi),%esi

801072f0 <inituvm>:
{
801072f0:	55                   	push   %ebp
801072f1:	89 e5                	mov    %esp,%ebp
801072f3:	57                   	push   %edi
801072f4:	56                   	push   %esi
801072f5:	53                   	push   %ebx
801072f6:	83 ec 1c             	sub    $0x1c,%esp
801072f9:	8b 75 10             	mov    0x10(%ebp),%esi
801072fc:	8b 45 08             	mov    0x8(%ebp),%eax
801072ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(sz >= PGSIZE)
80107302:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
{
80107308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
8010730b:	77 49                	ja     80107356 <inituvm+0x66>
  mem = kalloc();
8010730d:	e8 ae b1 ff ff       	call   801024c0 <kalloc>
  memset(mem, 0, PGSIZE);
80107312:	83 ec 04             	sub    $0x4,%esp
  mem = kalloc();
80107315:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80107317:	68 00 10 00 00       	push   $0x1000
8010731c:	6a 00                	push   $0x0
8010731e:	50                   	push   %eax
8010731f:	e8 1c d9 ff ff       	call   80104c40 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107324:	58                   	pop    %eax
80107325:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010732b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107330:	5a                   	pop    %edx
80107331:	6a 06                	push   $0x6
80107333:	50                   	push   %eax
80107334:	31 d2                	xor    %edx,%edx
80107336:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107339:	e8 52 fc ff ff       	call   80106f90 <mappages>
  memmove(mem, init, sz);
8010733e:	89 75 10             	mov    %esi,0x10(%ebp)
80107341:	89 7d 0c             	mov    %edi,0xc(%ebp)
80107344:	83 c4 10             	add    $0x10,%esp
80107347:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010734a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010734d:	5b                   	pop    %ebx
8010734e:	5e                   	pop    %esi
8010734f:	5f                   	pop    %edi
80107350:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80107351:	e9 9a d9 ff ff       	jmp    80104cf0 <memmove>
    panic("inituvm: more than a page");
80107356:	83 ec 0c             	sub    $0xc,%esp
80107359:	68 be 83 10 80       	push   $0x801083be
8010735e:	e8 0d 90 ff ff       	call   80100370 <panic>
80107363:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107370 <loaduvm>:
{
80107370:	55                   	push   %ebp
80107371:	89 e5                	mov    %esp,%ebp
80107373:	57                   	push   %edi
80107374:	56                   	push   %esi
80107375:	53                   	push   %ebx
80107376:	83 ec 0c             	sub    $0xc,%esp
  if((uint) addr % PGSIZE != 0)
80107379:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80107380:	0f 85 91 00 00 00    	jne    80107417 <loaduvm+0xa7>
  for(i = 0; i < sz; i += PGSIZE){
80107386:	8b 75 18             	mov    0x18(%ebp),%esi
80107389:	31 db                	xor    %ebx,%ebx
8010738b:	85 f6                	test   %esi,%esi
8010738d:	75 1a                	jne    801073a9 <loaduvm+0x39>
8010738f:	eb 6f                	jmp    80107400 <loaduvm+0x90>
80107391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107398:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010739e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
801073a4:	39 5d 18             	cmp    %ebx,0x18(%ebp)
801073a7:	76 57                	jbe    80107400 <loaduvm+0x90>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801073a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801073ac:	8b 45 08             	mov    0x8(%ebp),%eax
801073af:	31 c9                	xor    %ecx,%ecx
801073b1:	01 da                	add    %ebx,%edx
801073b3:	e8 58 fb ff ff       	call   80106f10 <walkpgdir>
801073b8:	85 c0                	test   %eax,%eax
801073ba:	74 4e                	je     8010740a <loaduvm+0x9a>
    pa = PTE_ADDR(*pte);
801073bc:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
801073be:	8b 4d 14             	mov    0x14(%ebp),%ecx
    if(sz - i < PGSIZE)
801073c1:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
801073c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801073cb:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801073d1:	0f 46 fe             	cmovbe %esi,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
801073d4:	01 d9                	add    %ebx,%ecx
801073d6:	05 00 00 00 80       	add    $0x80000000,%eax
801073db:	57                   	push   %edi
801073dc:	51                   	push   %ecx
801073dd:	50                   	push   %eax
801073de:	ff 75 10             	pushl  0x10(%ebp)
801073e1:	e8 4a a5 ff ff       	call   80101930 <readi>
801073e6:	83 c4 10             	add    $0x10,%esp
801073e9:	39 f8                	cmp    %edi,%eax
801073eb:	74 ab                	je     80107398 <loaduvm+0x28>
}
801073ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801073f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801073f5:	5b                   	pop    %ebx
801073f6:	5e                   	pop    %esi
801073f7:	5f                   	pop    %edi
801073f8:	5d                   	pop    %ebp
801073f9:	c3                   	ret    
801073fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107400:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107403:	31 c0                	xor    %eax,%eax
}
80107405:	5b                   	pop    %ebx
80107406:	5e                   	pop    %esi
80107407:	5f                   	pop    %edi
80107408:	5d                   	pop    %ebp
80107409:	c3                   	ret    
      panic("loaduvm: address should exist");
8010740a:	83 ec 0c             	sub    $0xc,%esp
8010740d:	68 d8 83 10 80       	push   $0x801083d8
80107412:	e8 59 8f ff ff       	call   80100370 <panic>
    panic("loaduvm: addr must be page aligned");
80107417:	83 ec 0c             	sub    $0xc,%esp
8010741a:	68 7c 84 10 80       	push   $0x8010847c
8010741f:	e8 4c 8f ff ff       	call   80100370 <panic>
80107424:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010742a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107430 <allocuvm>:
{
80107430:	55                   	push   %ebp
80107431:	89 e5                	mov    %esp,%ebp
80107433:	57                   	push   %edi
80107434:	56                   	push   %esi
80107435:	53                   	push   %ebx
80107436:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80107439:	8b 7d 10             	mov    0x10(%ebp),%edi
8010743c:	85 ff                	test   %edi,%edi
8010743e:	0f 88 8e 00 00 00    	js     801074d2 <allocuvm+0xa2>
  if(newsz < oldsz)
80107444:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80107447:	0f 82 93 00 00 00    	jb     801074e0 <allocuvm+0xb0>
  a = PGROUNDUP(oldsz);
8010744d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107450:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107456:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
8010745c:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010745f:	0f 86 7e 00 00 00    	jbe    801074e3 <allocuvm+0xb3>
80107465:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80107468:	8b 7d 08             	mov    0x8(%ebp),%edi
8010746b:	eb 42                	jmp    801074af <allocuvm+0x7f>
8010746d:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
80107470:	83 ec 04             	sub    $0x4,%esp
80107473:	68 00 10 00 00       	push   $0x1000
80107478:	6a 00                	push   $0x0
8010747a:	50                   	push   %eax
8010747b:	e8 c0 d7 ff ff       	call   80104c40 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107480:	58                   	pop    %eax
80107481:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80107487:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010748c:	5a                   	pop    %edx
8010748d:	6a 06                	push   $0x6
8010748f:	50                   	push   %eax
80107490:	89 da                	mov    %ebx,%edx
80107492:	89 f8                	mov    %edi,%eax
80107494:	e8 f7 fa ff ff       	call   80106f90 <mappages>
80107499:	83 c4 10             	add    $0x10,%esp
8010749c:	85 c0                	test   %eax,%eax
8010749e:	78 50                	js     801074f0 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
801074a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801074a6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801074a9:	0f 86 81 00 00 00    	jbe    80107530 <allocuvm+0x100>
    mem = kalloc();
801074af:	e8 0c b0 ff ff       	call   801024c0 <kalloc>
    if(mem == 0){
801074b4:	85 c0                	test   %eax,%eax
    mem = kalloc();
801074b6:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801074b8:	75 b6                	jne    80107470 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
801074ba:	83 ec 0c             	sub    $0xc,%esp
801074bd:	68 f6 83 10 80       	push   $0x801083f6
801074c2:	e8 79 91 ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
801074c7:	83 c4 10             	add    $0x10,%esp
801074ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801074cd:	39 45 10             	cmp    %eax,0x10(%ebp)
801074d0:	77 6e                	ja     80107540 <allocuvm+0x110>
}
801074d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
801074d5:	31 ff                	xor    %edi,%edi
}
801074d7:	89 f8                	mov    %edi,%eax
801074d9:	5b                   	pop    %ebx
801074da:	5e                   	pop    %esi
801074db:	5f                   	pop    %edi
801074dc:	5d                   	pop    %ebp
801074dd:	c3                   	ret    
801074de:	66 90                	xchg   %ax,%ax
    return oldsz;
801074e0:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
801074e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801074e6:	89 f8                	mov    %edi,%eax
801074e8:	5b                   	pop    %ebx
801074e9:	5e                   	pop    %esi
801074ea:	5f                   	pop    %edi
801074eb:	5d                   	pop    %ebp
801074ec:	c3                   	ret    
801074ed:	8d 76 00             	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
801074f0:	83 ec 0c             	sub    $0xc,%esp
801074f3:	68 0e 84 10 80       	push   $0x8010840e
801074f8:	e8 43 91 ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
801074fd:	83 c4 10             	add    $0x10,%esp
80107500:	8b 45 0c             	mov    0xc(%ebp),%eax
80107503:	39 45 10             	cmp    %eax,0x10(%ebp)
80107506:	76 0d                	jbe    80107515 <allocuvm+0xe5>
80107508:	89 c1                	mov    %eax,%ecx
8010750a:	8b 55 10             	mov    0x10(%ebp),%edx
8010750d:	8b 45 08             	mov    0x8(%ebp),%eax
80107510:	e8 0b fb ff ff       	call   80107020 <deallocuvm.part.0>
      kfree(mem);
80107515:	83 ec 0c             	sub    $0xc,%esp
      return 0;
80107518:	31 ff                	xor    %edi,%edi
      kfree(mem);
8010751a:	56                   	push   %esi
8010751b:	e8 f0 ad ff ff       	call   80102310 <kfree>
      return 0;
80107520:	83 c4 10             	add    $0x10,%esp
}
80107523:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107526:	89 f8                	mov    %edi,%eax
80107528:	5b                   	pop    %ebx
80107529:	5e                   	pop    %esi
8010752a:	5f                   	pop    %edi
8010752b:	5d                   	pop    %ebp
8010752c:	c3                   	ret    
8010752d:	8d 76 00             	lea    0x0(%esi),%esi
80107530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80107533:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107536:	5b                   	pop    %ebx
80107537:	89 f8                	mov    %edi,%eax
80107539:	5e                   	pop    %esi
8010753a:	5f                   	pop    %edi
8010753b:	5d                   	pop    %ebp
8010753c:	c3                   	ret    
8010753d:	8d 76 00             	lea    0x0(%esi),%esi
80107540:	89 c1                	mov    %eax,%ecx
80107542:	8b 55 10             	mov    0x10(%ebp),%edx
80107545:	8b 45 08             	mov    0x8(%ebp),%eax
      return 0;
80107548:	31 ff                	xor    %edi,%edi
8010754a:	e8 d1 fa ff ff       	call   80107020 <deallocuvm.part.0>
8010754f:	eb 92                	jmp    801074e3 <allocuvm+0xb3>
80107551:	eb 0d                	jmp    80107560 <myallocuvm>
80107553:	90                   	nop
80107554:	90                   	nop
80107555:	90                   	nop
80107556:	90                   	nop
80107557:	90                   	nop
80107558:	90                   	nop
80107559:	90                   	nop
8010755a:	90                   	nop
8010755b:	90                   	nop
8010755c:	90                   	nop
8010755d:	90                   	nop
8010755e:	90                   	nop
8010755f:	90                   	nop

80107560 <myallocuvm>:
int myallocuvm(pde_t *pgdir,uint start, uint end){
80107560:	55                   	push   %ebp
80107561:	89 e5                	mov    %esp,%ebp
80107563:	57                   	push   %edi
80107564:	56                   	push   %esi
80107565:	53                   	push   %ebx
80107566:	83 ec 0c             	sub    $0xc,%esp
  a = PGROUNDUP(start);
80107569:	8b 45 0c             	mov    0xc(%ebp),%eax
int myallocuvm(pde_t *pgdir,uint start, uint end){
8010756c:	8b 75 10             	mov    0x10(%ebp),%esi
  a = PGROUNDUP(start);
8010756f:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107575:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end; a += PGSIZE){
8010757b:	39 f3                	cmp    %esi,%ebx
8010757d:	73 3f                	jae    801075be <myallocuvm+0x5e>
8010757f:	90                   	nop
    mem = kalloc();
80107580:	e8 3b af ff ff       	call   801024c0 <kalloc>
    memset(mem, 0 , PGSIZE);
80107585:	83 ec 04             	sub    $0x4,%esp
    mem = kalloc();
80107588:	89 c7                	mov    %eax,%edi
    memset(mem, 0 , PGSIZE);
8010758a:	68 00 10 00 00       	push   $0x1000
8010758f:	6a 00                	push   $0x0
80107591:	50                   	push   %eax
80107592:	e8 a9 d6 ff ff       	call   80104c40 <memset>
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
80107597:	58                   	pop    %eax
80107598:	5a                   	pop    %edx
80107599:	8d 97 00 00 00 80    	lea    -0x80000000(%edi),%edx
8010759f:	8b 45 08             	mov    0x8(%ebp),%eax
801075a2:	6a 06                	push   $0x6
801075a4:	b9 00 10 00 00       	mov    $0x1000,%ecx
801075a9:	52                   	push   %edx
801075aa:	89 da                	mov    %ebx,%edx
  for(;a<end; a += PGSIZE){
801075ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
801075b2:	e8 d9 f9 ff ff       	call   80106f90 <mappages>
  for(;a<end; a += PGSIZE){
801075b7:	83 c4 10             	add    $0x10,%esp
801075ba:	39 de                	cmp    %ebx,%esi
801075bc:	77 c2                	ja     80107580 <myallocuvm+0x20>
  return (end - start);
801075be:	89 f0                	mov    %esi,%eax
801075c0:	2b 45 0c             	sub    0xc(%ebp),%eax
}
801075c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801075c6:	5b                   	pop    %ebx
801075c7:	5e                   	pop    %esi
801075c8:	5f                   	pop    %edi
801075c9:	5d                   	pop    %ebp
801075ca:	c3                   	ret    
801075cb:	90                   	nop
801075cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801075d0 <deallocuvm>:
{
801075d0:	55                   	push   %ebp
801075d1:	89 e5                	mov    %esp,%ebp
801075d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801075d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
801075d9:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
801075dc:	39 d1                	cmp    %edx,%ecx
801075de:	73 10                	jae    801075f0 <deallocuvm+0x20>
}
801075e0:	5d                   	pop    %ebp
801075e1:	e9 3a fa ff ff       	jmp    80107020 <deallocuvm.part.0>
801075e6:	8d 76 00             	lea    0x0(%esi),%esi
801075e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801075f0:	89 d0                	mov    %edx,%eax
801075f2:	5d                   	pop    %ebp
801075f3:	c3                   	ret    
801075f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801075fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107600 <mydeallocuvm>:

int mydeallocuvm(pde_t *pgdir,uint start,uint end){
80107600:	55                   	push   %ebp
80107601:	89 e5                	mov    %esp,%ebp
80107603:	57                   	push   %edi
80107604:	56                   	push   %esi
80107605:	53                   	push   %ebx
80107606:	83 ec 1c             	sub    $0x1c,%esp
  pte_t *pte;
  uint a,pa;
  a=PGROUNDUP(start);
80107609:	8b 45 0c             	mov    0xc(%ebp),%eax
int mydeallocuvm(pde_t *pgdir,uint start,uint end){
8010760c:	8b 75 10             	mov    0x10(%ebp),%esi
8010760f:	8b 7d 08             	mov    0x8(%ebp),%edi
  a=PGROUNDUP(start);
80107612:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107618:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end;a += PGSIZE){
8010761e:	39 f3                	cmp    %esi,%ebx
80107620:	72 3d                	jb     8010765f <mydeallocuvm+0x5f>
80107622:	eb 5a                	jmp    8010767e <mydeallocuvm+0x7e>
80107624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir,(char*)a,0);
    if(!pte){
      a += (NPDENTRIES-1)*PGSIZE;
    }else if((*pte & PTE_P)!=0){
80107628:	8b 10                	mov    (%eax),%edx
8010762a:	f6 c2 01             	test   $0x1,%dl
8010762d:	74 26                	je     80107655 <mydeallocuvm+0x55>
      pa=PTE_ADDR(*pte);
      if(pa == 0){
8010762f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80107635:	74 54                	je     8010768b <mydeallocuvm+0x8b>
        panic("kfree");
      }
      char *v = P2V(pa);
      kfree(v);
80107637:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010763a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107640:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80107643:	52                   	push   %edx
80107644:	e8 c7 ac ff ff       	call   80102310 <kfree>
      *pte=0;
80107649:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010764c:	83 c4 10             	add    $0x10,%esp
8010764f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(;a<end;a += PGSIZE){
80107655:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010765b:	39 de                	cmp    %ebx,%esi
8010765d:	76 1f                	jbe    8010767e <mydeallocuvm+0x7e>
    pte = walkpgdir(pgdir,(char*)a,0);
8010765f:	31 c9                	xor    %ecx,%ecx
80107661:	89 da                	mov    %ebx,%edx
80107663:	89 f8                	mov    %edi,%eax
80107665:	e8 a6 f8 ff ff       	call   80106f10 <walkpgdir>
    if(!pte){
8010766a:	85 c0                	test   %eax,%eax
8010766c:	75 ba                	jne    80107628 <mydeallocuvm+0x28>
      a += (NPDENTRIES-1)*PGSIZE;
8010766e:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(;a<end;a += PGSIZE){
80107674:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010767a:	39 de                	cmp    %ebx,%esi
8010767c:	77 e1                	ja     8010765f <mydeallocuvm+0x5f>
    }
  }
  return 1;
}
8010767e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107681:	b8 01 00 00 00       	mov    $0x1,%eax
80107686:	5b                   	pop    %ebx
80107687:	5e                   	pop    %esi
80107688:	5f                   	pop    %edi
80107689:	5d                   	pop    %ebp
8010768a:	c3                   	ret    
        panic("kfree");
8010768b:	83 ec 0c             	sub    $0xc,%esp
8010768e:	68 7a 7b 10 80       	push   $0x80107b7a
80107693:	e8 d8 8c ff ff       	call   80100370 <panic>
80107698:	90                   	nop
80107699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801076a0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801076a0:	55                   	push   %ebp
801076a1:	89 e5                	mov    %esp,%ebp
801076a3:	57                   	push   %edi
801076a4:	56                   	push   %esi
801076a5:	53                   	push   %ebx
801076a6:	83 ec 0c             	sub    $0xc,%esp
801076a9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801076ac:	85 f6                	test   %esi,%esi
801076ae:	74 59                	je     80107709 <freevm+0x69>
801076b0:	31 c9                	xor    %ecx,%ecx
801076b2:	ba 00 00 00 80       	mov    $0x80000000,%edx
801076b7:	89 f0                	mov    %esi,%eax
801076b9:	e8 62 f9 ff ff       	call   80107020 <deallocuvm.part.0>
801076be:	89 f3                	mov    %esi,%ebx
801076c0:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
801076c6:	eb 0f                	jmp    801076d7 <freevm+0x37>
801076c8:	90                   	nop
801076c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801076d0:	83 c3 04             	add    $0x4,%ebx
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801076d3:	39 fb                	cmp    %edi,%ebx
801076d5:	74 23                	je     801076fa <freevm+0x5a>
    if(pgdir[i] & PTE_P){
801076d7:	8b 03                	mov    (%ebx),%eax
801076d9:	a8 01                	test   $0x1,%al
801076db:	74 f3                	je     801076d0 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801076dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
801076e2:	83 ec 0c             	sub    $0xc,%esp
801076e5:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
801076e8:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801076ed:	50                   	push   %eax
801076ee:	e8 1d ac ff ff       	call   80102310 <kfree>
801076f3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801076f6:	39 fb                	cmp    %edi,%ebx
801076f8:	75 dd                	jne    801076d7 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801076fa:	89 75 08             	mov    %esi,0x8(%ebp)
}
801076fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107700:	5b                   	pop    %ebx
80107701:	5e                   	pop    %esi
80107702:	5f                   	pop    %edi
80107703:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107704:	e9 07 ac ff ff       	jmp    80102310 <kfree>
    panic("freevm: no pgdir");
80107709:	83 ec 0c             	sub    $0xc,%esp
8010770c:	68 2a 84 10 80       	push   $0x8010842a
80107711:	e8 5a 8c ff ff       	call   80100370 <panic>
80107716:	8d 76 00             	lea    0x0(%esi),%esi
80107719:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107720 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107720:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107721:	31 c9                	xor    %ecx,%ecx
{
80107723:	89 e5                	mov    %esp,%ebp
80107725:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80107728:	8b 55 0c             	mov    0xc(%ebp),%edx
8010772b:	8b 45 08             	mov    0x8(%ebp),%eax
8010772e:	e8 dd f7 ff ff       	call   80106f10 <walkpgdir>
  if(pte == 0)
80107733:	85 c0                	test   %eax,%eax
80107735:	74 05                	je     8010773c <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
80107737:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010773a:	c9                   	leave  
8010773b:	c3                   	ret    
    panic("clearpteu");
8010773c:	83 ec 0c             	sub    $0xc,%esp
8010773f:	68 3b 84 10 80       	push   $0x8010843b
80107744:	e8 27 8c ff ff       	call   80100370 <panic>
80107749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107750 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107750:	55                   	push   %ebp
80107751:	89 e5                	mov    %esp,%ebp
80107753:	57                   	push   %edi
80107754:	56                   	push   %esi
80107755:	53                   	push   %ebx
80107756:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107759:	e8 42 fa ff ff       	call   801071a0 <setupkvm>
8010775e:	85 c0                	test   %eax,%eax
80107760:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107763:	0f 84 a0 00 00 00    	je     80107809 <copyuvm+0xb9>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80107769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010776c:	85 c9                	test   %ecx,%ecx
8010776e:	0f 84 95 00 00 00    	je     80107809 <copyuvm+0xb9>
80107774:	31 f6                	xor    %esi,%esi
80107776:	eb 4e                	jmp    801077c6 <copyuvm+0x76>
80107778:	90                   	nop
80107779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107780:	83 ec 04             	sub    $0x4,%esp
80107783:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80107789:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010778c:	68 00 10 00 00       	push   $0x1000
80107791:	57                   	push   %edi
80107792:	50                   	push   %eax
80107793:	e8 58 d5 ff ff       	call   80104cf0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107798:	58                   	pop    %eax
80107799:	5a                   	pop    %edx
8010779a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010779d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801077a0:	b9 00 10 00 00       	mov    $0x1000,%ecx
801077a5:	53                   	push   %ebx
801077a6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801077ac:	52                   	push   %edx
801077ad:	89 f2                	mov    %esi,%edx
801077af:	e8 dc f7 ff ff       	call   80106f90 <mappages>
801077b4:	83 c4 10             	add    $0x10,%esp
801077b7:	85 c0                	test   %eax,%eax
801077b9:	78 39                	js     801077f4 <copyuvm+0xa4>
  for(i = 0; i < sz; i += PGSIZE){
801077bb:	81 c6 00 10 00 00    	add    $0x1000,%esi
801077c1:	39 75 0c             	cmp    %esi,0xc(%ebp)
801077c4:	76 43                	jbe    80107809 <copyuvm+0xb9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801077c6:	8b 45 08             	mov    0x8(%ebp),%eax
801077c9:	31 c9                	xor    %ecx,%ecx
801077cb:	89 f2                	mov    %esi,%edx
801077cd:	e8 3e f7 ff ff       	call   80106f10 <walkpgdir>
801077d2:	85 c0                	test   %eax,%eax
801077d4:	74 3e                	je     80107814 <copyuvm+0xc4>
    if(!(*pte & PTE_P))
801077d6:	8b 18                	mov    (%eax),%ebx
801077d8:	f6 c3 01             	test   $0x1,%bl
801077db:	74 44                	je     80107821 <copyuvm+0xd1>
    pa = PTE_ADDR(*pte);
801077dd:	89 df                	mov    %ebx,%edi
    flags = PTE_FLAGS(*pte);
801077df:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    pa = PTE_ADDR(*pte);
801077e5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
801077eb:	e8 d0 ac ff ff       	call   801024c0 <kalloc>
801077f0:	85 c0                	test   %eax,%eax
801077f2:	75 8c                	jne    80107780 <copyuvm+0x30>
      goto bad;
  }
  return d;

bad:
  freevm(d);
801077f4:	83 ec 0c             	sub    $0xc,%esp
801077f7:	ff 75 e0             	pushl  -0x20(%ebp)
801077fa:	e8 a1 fe ff ff       	call   801076a0 <freevm>
  return 0;
801077ff:	83 c4 10             	add    $0x10,%esp
80107802:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
}
80107809:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010780c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010780f:	5b                   	pop    %ebx
80107810:	5e                   	pop    %esi
80107811:	5f                   	pop    %edi
80107812:	5d                   	pop    %ebp
80107813:	c3                   	ret    
      panic("copyuvm: pte should exist");
80107814:	83 ec 0c             	sub    $0xc,%esp
80107817:	68 45 84 10 80       	push   $0x80108445
8010781c:	e8 4f 8b ff ff       	call   80100370 <panic>
      panic("copyuvm: page not present");
80107821:	83 ec 0c             	sub    $0xc,%esp
80107824:	68 5f 84 10 80       	push   $0x8010845f
80107829:	e8 42 8b ff ff       	call   80100370 <panic>
8010782e:	66 90                	xchg   %ax,%ax

80107830 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107830:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107831:	31 c9                	xor    %ecx,%ecx
{
80107833:	89 e5                	mov    %esp,%ebp
80107835:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80107838:	8b 55 0c             	mov    0xc(%ebp),%edx
8010783b:	8b 45 08             	mov    0x8(%ebp),%eax
8010783e:	e8 cd f6 ff ff       	call   80106f10 <walkpgdir>
  if((*pte & PTE_P) == 0)
80107843:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107845:	c9                   	leave  
  if((*pte & PTE_U) == 0)
80107846:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107848:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
8010784d:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107850:	05 00 00 00 80       	add    $0x80000000,%eax
80107855:	83 fa 05             	cmp    $0x5,%edx
80107858:	ba 00 00 00 00       	mov    $0x0,%edx
8010785d:	0f 45 c2             	cmovne %edx,%eax
}
80107860:	c3                   	ret    
80107861:	eb 0d                	jmp    80107870 <copyout>
80107863:	90                   	nop
80107864:	90                   	nop
80107865:	90                   	nop
80107866:	90                   	nop
80107867:	90                   	nop
80107868:	90                   	nop
80107869:	90                   	nop
8010786a:	90                   	nop
8010786b:	90                   	nop
8010786c:	90                   	nop
8010786d:	90                   	nop
8010786e:	90                   	nop
8010786f:	90                   	nop

80107870 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107870:	55                   	push   %ebp
80107871:	89 e5                	mov    %esp,%ebp
80107873:	57                   	push   %edi
80107874:	56                   	push   %esi
80107875:	53                   	push   %ebx
80107876:	83 ec 1c             	sub    $0x1c,%esp
80107879:	8b 5d 14             	mov    0x14(%ebp),%ebx
8010787c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010787f:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107882:	85 db                	test   %ebx,%ebx
80107884:	75 40                	jne    801078c6 <copyout+0x56>
80107886:	eb 70                	jmp    801078f8 <copyout+0x88>
80107888:	90                   	nop
80107889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80107890:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107893:	89 f1                	mov    %esi,%ecx
80107895:	29 d1                	sub    %edx,%ecx
80107897:	81 c1 00 10 00 00    	add    $0x1000,%ecx
8010789d:	39 d9                	cmp    %ebx,%ecx
8010789f:	0f 47 cb             	cmova  %ebx,%ecx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801078a2:	29 f2                	sub    %esi,%edx
801078a4:	83 ec 04             	sub    $0x4,%esp
801078a7:	01 d0                	add    %edx,%eax
801078a9:	51                   	push   %ecx
801078aa:	57                   	push   %edi
801078ab:	50                   	push   %eax
801078ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801078af:	e8 3c d4 ff ff       	call   80104cf0 <memmove>
    len -= n;
    buf += n;
801078b4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  while(len > 0){
801078b7:	83 c4 10             	add    $0x10,%esp
    va = va0 + PGSIZE;
801078ba:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
    buf += n;
801078c0:	01 cf                	add    %ecx,%edi
  while(len > 0){
801078c2:	29 cb                	sub    %ecx,%ebx
801078c4:	74 32                	je     801078f8 <copyout+0x88>
    va0 = (uint)PGROUNDDOWN(va);
801078c6:	89 d6                	mov    %edx,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801078c8:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
801078cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801078ce:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801078d4:	56                   	push   %esi
801078d5:	ff 75 08             	pushl  0x8(%ebp)
801078d8:	e8 53 ff ff ff       	call   80107830 <uva2ka>
    if(pa0 == 0)
801078dd:	83 c4 10             	add    $0x10,%esp
801078e0:	85 c0                	test   %eax,%eax
801078e2:	75 ac                	jne    80107890 <copyout+0x20>
  }
  return 0;
}
801078e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801078e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801078ec:	5b                   	pop    %ebx
801078ed:	5e                   	pop    %esi
801078ee:	5f                   	pop    %edi
801078ef:	5d                   	pop    %ebp
801078f0:	c3                   	ret    
801078f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801078f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801078fb:	31 c0                	xor    %eax,%eax
}
801078fd:	5b                   	pop    %ebx
801078fe:	5e                   	pop    %esi
801078ff:	5f                   	pop    %edi
80107900:	5d                   	pop    %ebp
80107901:	c3                   	ret    
