
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
80100046:	68 60 79 10 80       	push   $0x80107960
8010004b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100050:	e8 6b 4a 00 00       	call   80104ac0 <initlock>

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
801000d4:	e8 07 4a 00 00       	call   80104ae0 <acquire>
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
80100114:	e8 67 3d 00 00       	call   80103e80 <sleep>
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
80100154:	e8 47 4b 00 00       	call   80104ca0 <release>
80100159:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if(!(b->flags & B_VALID)) {
8010015c:	f6 03 02             	testb  $0x2,(%ebx)
8010015f:	75 0c                	jne    8010016d <bread+0xad>
    iderw(b);
80100161:	83 ec 0c             	sub    $0xc,%esp
80100164:	53                   	push   %ebx
80100165:	e8 96 1f 00 00       	call   80102100 <iderw>
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
80100184:	e8 17 4b 00 00       	call   80104ca0 <release>
80100189:	83 c4 10             	add    $0x10,%esp
8010018c:	eb ce                	jmp    8010015c <bread+0x9c>
  panic("bget: no buffers");
8010018e:	83 ec 0c             	sub    $0xc,%esp
80100191:	68 67 79 10 80       	push   $0x80107967
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
801001b5:	e9 46 1f 00 00       	jmp    80102100 <iderw>
    panic("bwrite");
801001ba:	83 ec 0c             	sub    $0xc,%esp
801001bd:	68 78 79 10 80       	push   $0x80107978
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
801001e7:	e8 f4 48 00 00       	call   80104ae0 <acquire>

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
80100221:	e8 ba 3e 00 00       	call   801040e0 <wakeup>

  release(&bcache.lock);
80100226:	83 c4 10             	add    $0x10,%esp
80100229:	c7 45 08 e0 c5 10 80 	movl   $0x8010c5e0,0x8(%ebp)
}
80100230:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100233:	c9                   	leave  
  release(&bcache.lock);
80100234:	e9 67 4a 00 00       	jmp    80104ca0 <release>
    panic("brelse");
80100239:	83 ec 0c             	sub    $0xc,%esp
8010023c:	68 7f 79 10 80       	push   $0x8010797f
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
8010026c:	e8 6f 48 00 00       	call   80104ae0 <acquire>
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
801002a5:	e8 d6 3b 00 00       	call   80103e80 <sleep>
    while(input.r == input.w){
801002aa:	8b 15 80 07 11 80    	mov    0x80110780,%edx
801002b0:	83 c4 10             	add    $0x10,%esp
801002b3:	3b 15 84 07 11 80    	cmp    0x80110784,%edx
801002b9:	75 35                	jne    801002f0 <consoleread+0xa0>
      if(proc->killed){
801002bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801002c1:	8b 40 28             	mov    0x28(%eax),%eax
801002c4:	85 c0                	test   %eax,%eax
801002c6:	74 d0                	je     80100298 <consoleread+0x48>
        release(&cons.lock);
801002c8:	83 ec 0c             	sub    $0xc,%esp
801002cb:	68 20 b5 10 80       	push   $0x8010b520
801002d0:	e8 cb 49 00 00       	call   80104ca0 <release>
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
8010032d:	e8 6e 49 00 00       	call   80104ca0 <release>
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
80100393:	68 86 79 10 80       	push   $0x80107986
80100398:	e8 a3 02 00 00       	call   80100640 <cprintf>
  cprintf(s);
8010039d:	58                   	pop    %eax
8010039e:	ff 75 08             	pushl  0x8(%ebp)
801003a1:	e8 9a 02 00 00       	call   80100640 <cprintf>
  cprintf("\n");
801003a6:	c7 04 24 98 80 10 80 	movl   $0x80108098,(%esp)
801003ad:	e8 8e 02 00 00       	call   80100640 <cprintf>
  getcallerpcs(&s, pcs);
801003b2:	5a                   	pop    %edx
801003b3:	8d 45 08             	lea    0x8(%ebp),%eax
801003b6:	59                   	pop    %ecx
801003b7:	53                   	push   %ebx
801003b8:	50                   	push   %eax
801003b9:	e8 e2 47 00 00       	call   80104ba0 <getcallerpcs>
801003be:	83 c4 10             	add    $0x10,%esp
801003c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf(" %p", pcs[i]);
801003c8:	83 ec 08             	sub    $0x8,%esp
801003cb:	ff 33                	pushl  (%ebx)
801003cd:	83 c3 04             	add    $0x4,%ebx
801003d0:	68 a2 79 10 80       	push   $0x801079a2
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
8010041a:	e8 81 60 00 00       	call   801064a0 <uartputc>
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
801004cc:	e8 cf 5f 00 00       	call   801064a0 <uartputc>
801004d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004d8:	e8 c3 5f 00 00       	call   801064a0 <uartputc>
801004dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004e4:	e8 b7 5f 00 00       	call   801064a0 <uartputc>
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
80100504:	e8 97 48 00 00       	call   80104da0 <memmove>
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
80100521:	e8 ca 47 00 00       	call   80104cf0 <memset>
80100526:	83 c4 10             	add    $0x10,%esp
80100529:	e9 5d ff ff ff       	jmp    8010048b <consputc+0x9b>
    panic("pos under/overflow");
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	68 a6 79 10 80       	push   $0x801079a6
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
80100591:	0f b6 92 d4 79 10 80 	movzbl -0x7fef862c(%edx),%edx
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
801005fb:	e8 e0 44 00 00       	call   80104ae0 <acquire>
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
80100627:	e8 74 46 00 00       	call   80104ca0 <release>
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
801006ff:	e8 9c 45 00 00       	call   80104ca0 <release>
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
801007b0:	ba b9 79 10 80       	mov    $0x801079b9,%edx
      for(; *s; s++)
801007b5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801007b8:	b8 28 00 00 00       	mov    $0x28,%eax
801007bd:	89 d3                	mov    %edx,%ebx
801007bf:	eb bf                	jmp    80100780 <cprintf+0x140>
801007c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    acquire(&cons.lock);
801007c8:	83 ec 0c             	sub    $0xc,%esp
801007cb:	68 20 b5 10 80       	push   $0x8010b520
801007d0:	e8 0b 43 00 00       	call   80104ae0 <acquire>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	e9 7c fe ff ff       	jmp    80100659 <cprintf+0x19>
    panic("null fmt");
801007dd:	83 ec 0c             	sub    $0xc,%esp
801007e0:	68 c0 79 10 80       	push   $0x801079c0
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
80100803:	e8 d8 42 00 00       	call   80104ae0 <acquire>
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
80100868:	e8 33 44 00 00       	call   80104ca0 <release>
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
801008f6:	e8 e5 37 00 00       	call   801040e0 <wakeup>
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
80100977:	e9 e4 3a 00 00       	jmp    80104460 <procdump>
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
801009a6:	68 c9 79 10 80       	push   $0x801079c9
801009ab:	68 20 b5 10 80       	push   $0x8010b520
801009b0:	e8 0b 41 00 00       	call   80104ac0 <initlock>

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
801009e5:	e8 d6 18 00 00       	call   801022c0 <ioapicenable>
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
801009fc:	e8 1f 22 00 00       	call   80102c20 <begin_op>
  if((ip = namei(path)) == 0){
80100a01:	83 ec 0c             	sub    $0xc,%esp
80100a04:	ff 75 08             	pushl  0x8(%ebp)
80100a07:	e8 a4 14 00 00       	call   80101eb0 <namei>
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
80100a44:	e8 47 22 00 00       	call   80102c90 <end_op>
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
80100a6c:	e8 7f 67 00 00       	call   801071f0 <setupkvm>
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
80100a91:	0f 84 89 02 00 00    	je     80100d20 <exec+0x330>
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
80100ace:	e8 ad 69 00 00       	call   80107480 <allocuvm>
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
80100b00:	e8 bb 68 00 00       	call   801073c0 <loaduvm>
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
80100b4a:	e8 a1 6b 00 00       	call   801076f0 <freevm>
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
80100b7b:	e8 10 21 00 00       	call   80102c90 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100b80:	83 c4 0c             	add    $0xc,%esp
80100b83:	56                   	push   %esi
80100b84:	57                   	push   %edi
80100b85:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100b8b:	e8 f0 68 00 00       	call   80107480 <allocuvm>
80100b90:	83 c4 10             	add    $0x10,%esp
80100b93:	85 c0                	test   %eax,%eax
80100b95:	89 c6                	mov    %eax,%esi
80100b97:	75 2a                	jne    80100bc3 <exec+0x1d3>
    freevm(pgdir);
80100b99:	83 ec 0c             	sub    $0xc,%esp
80100b9c:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100ba2:	e8 49 6b 00 00       	call   801076f0 <freevm>
80100ba7:	83 c4 10             	add    $0x10,%esp
  return -1;
80100baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100baf:	e9 9d fe ff ff       	jmp    80100a51 <exec+0x61>
    end_op();
80100bb4:	e8 d7 20 00 00       	call   80102c90 <end_op>
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
80100bd7:	e8 94 6b 00 00       	call   80107770 <clearpteu>
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
80100c09:	e8 02 43 00 00       	call   80104f10 <strlen>
80100c0e:	f7 d0                	not    %eax
80100c10:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c12:	58                   	pop    %eax
80100c13:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100c16:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c19:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c1c:	e8 ef 42 00 00       	call   80104f10 <strlen>
80100c21:	83 c0 01             	add    $0x1,%eax
80100c24:	50                   	push   %eax
80100c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c28:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c2b:	53                   	push   %ebx
80100c2c:	56                   	push   %esi
80100c2d:	e8 8e 6c 00 00       	call   801078c0 <copyout>
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
80100c97:	e8 24 6c 00 00       	call   801078c0 <copyout>
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
80100cd1:	83 c0 70             	add    $0x70,%eax
80100cd4:	50                   	push   %eax
80100cd5:	e8 f6 41 00 00       	call   80104ed0 <safestrcpy>
  oldpgdir = proc->pgdir;
80100cda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  proc->pgdir = pgdir;
80100ce0:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
  oldpgdir = proc->pgdir;
80100ce6:	8b 78 04             	mov    0x4(%eax),%edi
  proc->sz = sz;
80100ce9:	89 30                	mov    %esi,(%eax)
  proc->pgdir = pgdir;
80100ceb:	89 50 04             	mov    %edx,0x4(%eax)
  proc->tf->eip = elf.entry;  // main
80100cee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cf4:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
80100cfa:	8b 50 1c             	mov    0x1c(%eax),%edx
80100cfd:	89 4a 38             	mov    %ecx,0x38(%edx)
  proc->tf->esp = sp;
80100d00:	8b 50 1c             	mov    0x1c(%eax),%edx
80100d03:	89 5a 44             	mov    %ebx,0x44(%edx)
  switchuvm(proc);
80100d06:	89 04 24             	mov    %eax,(%esp)
80100d09:	e8 92 65 00 00       	call   801072a0 <switchuvm>
  freevm(oldpgdir);
80100d0e:	89 3c 24             	mov    %edi,(%esp)
80100d11:	e8 da 69 00 00       	call   801076f0 <freevm>
  return 0;
80100d16:	83 c4 10             	add    $0x10,%esp
80100d19:	31 c0                	xor    %eax,%eax
80100d1b:	e9 31 fd ff ff       	jmp    80100a51 <exec+0x61>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d20:	be 00 20 00 00       	mov    $0x2000,%esi
80100d25:	e9 48 fe ff ff       	jmp    80100b72 <exec+0x182>
80100d2a:	66 90                	xchg   %ax,%ax
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
80100d36:	68 e5 79 10 80       	push   $0x801079e5
80100d3b:	68 a0 07 11 80       	push   $0x801107a0
80100d40:	e8 7b 3d 00 00       	call   80104ac0 <initlock>
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
80100d61:	e8 7a 3d 00 00       	call   80104ae0 <acquire>
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
80100d91:	e8 0a 3f 00 00       	call   80104ca0 <release>
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
80100daa:	e8 f1 3e 00 00       	call   80104ca0 <release>
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
80100dcf:	e8 0c 3d 00 00       	call   80104ae0 <acquire>
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
80100dec:	e8 af 3e 00 00       	call   80104ca0 <release>
  return f;
}
80100df1:	89 d8                	mov    %ebx,%eax
80100df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100df6:	c9                   	leave  
80100df7:	c3                   	ret    
    panic("filedup");
80100df8:	83 ec 0c             	sub    $0xc,%esp
80100dfb:	68 ec 79 10 80       	push   $0x801079ec
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
80100e21:	e8 ba 3c 00 00       	call   80104ae0 <acquire>
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
80100e4c:	e9 4f 3e 00 00       	jmp    80104ca0 <release>
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
80100e78:	e8 23 3e 00 00       	call   80104ca0 <release>
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
80100eb0:	e8 6b 1d 00 00       	call   80102c20 <begin_op>
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
80100eca:	e9 c1 1d 00 00       	jmp    80102c90 <end_op>
    panic("fileclose");
80100ecf:	83 ec 0c             	sub    $0xc,%esp
80100ed2:	68 f4 79 10 80       	push   $0x801079f4
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
80100fb2:	68 fe 79 10 80       	push   $0x801079fe
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
80101019:	e8 72 1c 00 00       	call   80102c90 <end_op>
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
80101046:	e8 d5 1b 00 00       	call   80102c20 <begin_op>
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
8010107d:	e8 0e 1c 00 00       	call   80102c90 <end_op>
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
801010c5:	68 07 7a 10 80       	push   $0x80107a07
801010ca:	e8 a1 f2 ff ff       	call   80100370 <panic>
  panic("filewrite");
801010cf:	83 ec 0c             	sub    $0xc,%esp
801010d2:	68 0d 7a 10 80       	push   $0x80107a0d
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
80101184:	68 17 7a 10 80       	push   $0x80107a17
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
8010119d:	e8 4e 1c 00 00       	call   80102df0 <log_write>
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
801011c5:	e8 26 3b 00 00       	call   80104cf0 <memset>
  log_write(bp);
801011ca:	89 1c 24             	mov    %ebx,(%esp)
801011cd:	e8 1e 1c 00 00       	call   80102df0 <log_write>
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
8010120a:	e8 d1 38 00 00       	call   80104ae0 <acquire>
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
80101269:	e8 32 3a 00 00       	call   80104ca0 <release>

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
80101295:	e8 06 3a 00 00       	call   80104ca0 <release>
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
801012aa:	68 2d 7a 10 80       	push   $0x80107a2d
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
80101327:	e8 c4 1a 00 00       	call   80102df0 <log_write>
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
80101371:	68 3d 7a 10 80       	push   $0x80107a3d
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
801013a1:	e8 fa 39 00 00       	call   80104da0 <memmove>
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
8010141a:	e8 d1 19 00 00       	call   80102df0 <log_write>
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
80101434:	68 50 7a 10 80       	push   $0x80107a50
80101439:	e8 32 ef ff ff       	call   80100370 <panic>
8010143e:	66 90                	xchg   %ax,%ax

80101440 <iinit>:
{
80101440:	55                   	push   %ebp
80101441:	89 e5                	mov    %esp,%ebp
80101443:	83 ec 10             	sub    $0x10,%esp
  initlock(&icache.lock, "icache");
80101446:	68 63 7a 10 80       	push   $0x80107a63
8010144b:	68 c0 11 11 80       	push   $0x801111c0
80101450:	e8 6b 36 00 00       	call   80104ac0 <initlock>
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
8010148e:	68 c4 7a 10 80       	push   $0x80107ac4
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
8010151e:	e8 cd 37 00 00       	call   80104cf0 <memset>
      dip->type = type;
80101523:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80101527:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010152a:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
8010152d:	89 3c 24             	mov    %edi,(%esp)
80101530:	e8 bb 18 00 00       	call   80102df0 <log_write>
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
80101553:	68 6a 7a 10 80       	push   $0x80107a6a
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
801015c1:	e8 da 37 00 00       	call   80104da0 <memmove>
  log_write(bp);
801015c6:	89 34 24             	mov    %esi,(%esp)
801015c9:	e8 22 18 00 00       	call   80102df0 <log_write>
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
801015ef:	e8 ec 34 00 00       	call   80104ae0 <acquire>
  ip->ref++;
801015f4:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801015f8:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
801015ff:	e8 9c 36 00 00       	call   80104ca0 <release>
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
80101633:	e8 a8 34 00 00       	call   80104ae0 <acquire>
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
80101651:	e8 2a 28 00 00       	call   80103e80 <sleep>
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
8010166e:	e8 2d 36 00 00       	call   80104ca0 <release>
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
801016e0:	e8 bb 36 00 00       	call   80104da0 <memmove>
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
801016fe:	68 82 7a 10 80       	push   $0x80107a82
80101703:	e8 68 ec ff ff       	call   80100370 <panic>
    panic("ilock");
80101708:	83 ec 0c             	sub    $0xc,%esp
8010170b:	68 7c 7a 10 80       	push   $0x80107a7c
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
80101743:	e8 98 33 00 00       	call   80104ae0 <acquire>
  ip->flags &= ~I_BUSY;
80101748:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
8010174c:	89 1c 24             	mov    %ebx,(%esp)
8010174f:	e8 8c 29 00 00       	call   801040e0 <wakeup>
  release(&icache.lock);
80101754:	83 c4 10             	add    $0x10,%esp
80101757:	c7 45 08 c0 11 11 80 	movl   $0x801111c0,0x8(%ebp)
}
8010175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101761:	c9                   	leave  
  release(&icache.lock);
80101762:	e9 39 35 00 00       	jmp    80104ca0 <release>
    panic("iunlock");
80101767:	83 ec 0c             	sub    $0xc,%esp
8010176a:	68 91 7a 10 80       	push   $0x80107a91
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
80101791:	e8 4a 33 00 00       	call   80104ae0 <acquire>
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
801017d9:	e8 c2 34 00 00       	call   80104ca0 <release>
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
80101836:	e8 a5 32 00 00       	call   80104ae0 <acquire>
    ip->flags = 0;
8010183b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
80101842:	89 34 24             	mov    %esi,(%esp)
80101845:	e8 96 28 00 00       	call   801040e0 <wakeup>
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
80101864:	e9 37 34 00 00       	jmp    80104ca0 <release>
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
801018cd:	68 99 7a 10 80       	push   $0x80107a99
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
801019d7:	e8 c4 33 00 00       	call   80104da0 <memmove>
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
80101ad3:	e8 c8 32 00 00       	call   80104da0 <memmove>
    log_write(bp);
80101ad8:	89 3c 24             	mov    %edi,(%esp)
80101adb:	e8 10 13 00 00       	call   80102df0 <log_write>
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
80101b6e:	e8 9d 32 00 00       	call   80104e10 <strncmp>
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
80101bcd:	e8 3e 32 00 00       	call   80104e10 <strncmp>
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
80101c12:	68 b5 7a 10 80       	push   $0x80107ab5
80101c17:	e8 54 e7 ff ff       	call   80100370 <panic>
    panic("dirlookup not DIR");
80101c1c:	83 ec 0c             	sub    $0xc,%esp
80101c1f:	68 a3 7a 10 80       	push   $0x80107aa3
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
80101c43:	0f 84 67 01 00 00    	je     80101db0 <namex+0x180>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80101c49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  acquire(&icache.lock);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(proc->cwd);
80101c52:	8b 70 6c             	mov    0x6c(%eax),%esi
  acquire(&icache.lock);
80101c55:	68 c0 11 11 80       	push   $0x801111c0
80101c5a:	e8 81 2e 00 00       	call   80104ae0 <acquire>
  ip->ref++;
80101c5f:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101c63:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
80101c6a:	e8 31 30 00 00       	call   80104ca0 <release>
80101c6f:	83 c4 10             	add    $0x10,%esp
80101c72:	eb 07                	jmp    80101c7b <namex+0x4b>
80101c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101c78:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101c7b:	0f b6 03             	movzbl (%ebx),%eax
80101c7e:	3c 2f                	cmp    $0x2f,%al
80101c80:	74 f6                	je     80101c78 <namex+0x48>
  if(*path == 0)
80101c82:	84 c0                	test   %al,%al
80101c84:	0f 84 ee 00 00 00    	je     80101d78 <namex+0x148>
  while(*path != '/' && *path != 0)
80101c8a:	0f b6 03             	movzbl (%ebx),%eax
80101c8d:	3c 2f                	cmp    $0x2f,%al
80101c8f:	0f 84 b3 00 00 00    	je     80101d48 <namex+0x118>
80101c95:	84 c0                	test   %al,%al
80101c97:	89 da                	mov    %ebx,%edx
80101c99:	75 09                	jne    80101ca4 <namex+0x74>
80101c9b:	e9 a8 00 00 00       	jmp    80101d48 <namex+0x118>
80101ca0:	84 c0                	test   %al,%al
80101ca2:	74 0a                	je     80101cae <namex+0x7e>
    path++;
80101ca4:	83 c2 01             	add    $0x1,%edx
  while(*path != '/' && *path != 0)
80101ca7:	0f b6 02             	movzbl (%edx),%eax
80101caa:	3c 2f                	cmp    $0x2f,%al
80101cac:	75 f2                	jne    80101ca0 <namex+0x70>
80101cae:	89 d1                	mov    %edx,%ecx
80101cb0:	29 d9                	sub    %ebx,%ecx
  if(len >= DIRSIZ)
80101cb2:	83 f9 0d             	cmp    $0xd,%ecx
80101cb5:	0f 8e 91 00 00 00    	jle    80101d4c <namex+0x11c>
    memmove(name, s, DIRSIZ);
80101cbb:	83 ec 04             	sub    $0x4,%esp
80101cbe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101cc1:	6a 0e                	push   $0xe
80101cc3:	53                   	push   %ebx
80101cc4:	57                   	push   %edi
80101cc5:	e8 d6 30 00 00       	call   80104da0 <memmove>
    path++;
80101cca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    memmove(name, s, DIRSIZ);
80101ccd:	83 c4 10             	add    $0x10,%esp
    path++;
80101cd0:	89 d3                	mov    %edx,%ebx
  while(*path == '/')
80101cd2:	80 3a 2f             	cmpb   $0x2f,(%edx)
80101cd5:	75 11                	jne    80101ce8 <namex+0xb8>
80101cd7:	89 f6                	mov    %esi,%esi
80101cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    path++;
80101ce0:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101ce3:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101ce6:	74 f8                	je     80101ce0 <namex+0xb0>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101ce8:	83 ec 0c             	sub    $0xc,%esp
80101ceb:	56                   	push   %esi
80101cec:	e8 1f f9 ff ff       	call   80101610 <ilock>
    if(ip->type != T_DIR){
80101cf1:	83 c4 10             	add    $0x10,%esp
80101cf4:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
80101cf9:	0f 85 91 00 00 00    	jne    80101d90 <namex+0x160>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101cff:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101d02:	85 d2                	test   %edx,%edx
80101d04:	74 09                	je     80101d0f <namex+0xdf>
80101d06:	80 3b 00             	cmpb   $0x0,(%ebx)
80101d09:	0f 84 b7 00 00 00    	je     80101dc6 <namex+0x196>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101d0f:	83 ec 04             	sub    $0x4,%esp
80101d12:	6a 00                	push   $0x0
80101d14:	57                   	push   %edi
80101d15:	56                   	push   %esi
80101d16:	e8 65 fe ff ff       	call   80101b80 <dirlookup>
80101d1b:	83 c4 10             	add    $0x10,%esp
80101d1e:	85 c0                	test   %eax,%eax
80101d20:	74 6e                	je     80101d90 <namex+0x160>
  iunlock(ip);
80101d22:	83 ec 0c             	sub    $0xc,%esp
80101d25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101d28:	56                   	push   %esi
80101d29:	e8 f2 f9 ff ff       	call   80101720 <iunlock>
  iput(ip);
80101d2e:	89 34 24             	mov    %esi,(%esp)
80101d31:	e8 4a fa ff ff       	call   80101780 <iput>
80101d36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d39:	83 c4 10             	add    $0x10,%esp
80101d3c:	89 c6                	mov    %eax,%esi
80101d3e:	e9 38 ff ff ff       	jmp    80101c7b <namex+0x4b>
80101d43:	90                   	nop
80101d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path != '/' && *path != 0)
80101d48:	89 da                	mov    %ebx,%edx
80101d4a:	31 c9                	xor    %ecx,%ecx
    memmove(name, s, len);
80101d4c:	83 ec 04             	sub    $0x4,%esp
80101d4f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101d52:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101d55:	51                   	push   %ecx
80101d56:	53                   	push   %ebx
80101d57:	57                   	push   %edi
80101d58:	e8 43 30 00 00       	call   80104da0 <memmove>
    name[len] = 0;
80101d5d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101d60:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101d63:	83 c4 10             	add    $0x10,%esp
80101d66:	c6 04 0f 00          	movb   $0x0,(%edi,%ecx,1)
80101d6a:	89 d3                	mov    %edx,%ebx
80101d6c:	e9 61 ff ff ff       	jmp    80101cd2 <namex+0xa2>
80101d71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101d7b:	85 c0                	test   %eax,%eax
80101d7d:	75 5d                	jne    80101ddc <namex+0x1ac>
    iput(ip);
    return 0;
  }
  return ip;
}
80101d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d82:	89 f0                	mov    %esi,%eax
80101d84:	5b                   	pop    %ebx
80101d85:	5e                   	pop    %esi
80101d86:	5f                   	pop    %edi
80101d87:	5d                   	pop    %ebp
80101d88:	c3                   	ret    
80101d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  iunlock(ip);
80101d90:	83 ec 0c             	sub    $0xc,%esp
80101d93:	56                   	push   %esi
80101d94:	e8 87 f9 ff ff       	call   80101720 <iunlock>
  iput(ip);
80101d99:	89 34 24             	mov    %esi,(%esp)
      return 0;
80101d9c:	31 f6                	xor    %esi,%esi
  iput(ip);
80101d9e:	e8 dd f9 ff ff       	call   80101780 <iput>
      return 0;
80101da3:	83 c4 10             	add    $0x10,%esp
}
80101da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101da9:	89 f0                	mov    %esi,%eax
80101dab:	5b                   	pop    %ebx
80101dac:	5e                   	pop    %esi
80101dad:	5f                   	pop    %edi
80101dae:	5d                   	pop    %ebp
80101daf:	c3                   	ret    
    ip = iget(ROOTDEV, ROOTINO);
80101db0:	ba 01 00 00 00       	mov    $0x1,%edx
80101db5:	b8 01 00 00 00       	mov    $0x1,%eax
80101dba:	e8 31 f4 ff ff       	call   801011f0 <iget>
80101dbf:	89 c6                	mov    %eax,%esi
80101dc1:	e9 b5 fe ff ff       	jmp    80101c7b <namex+0x4b>
      iunlock(ip);
80101dc6:	83 ec 0c             	sub    $0xc,%esp
80101dc9:	56                   	push   %esi
80101dca:	e8 51 f9 ff ff       	call   80101720 <iunlock>
      return ip;
80101dcf:	83 c4 10             	add    $0x10,%esp
}
80101dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dd5:	89 f0                	mov    %esi,%eax
80101dd7:	5b                   	pop    %ebx
80101dd8:	5e                   	pop    %esi
80101dd9:	5f                   	pop    %edi
80101dda:	5d                   	pop    %ebp
80101ddb:	c3                   	ret    
    iput(ip);
80101ddc:	83 ec 0c             	sub    $0xc,%esp
80101ddf:	56                   	push   %esi
    return 0;
80101de0:	31 f6                	xor    %esi,%esi
    iput(ip);
80101de2:	e8 99 f9 ff ff       	call   80101780 <iput>
    return 0;
80101de7:	83 c4 10             	add    $0x10,%esp
80101dea:	eb 93                	jmp    80101d7f <namex+0x14f>
80101dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101df0 <dirlink>:
{
80101df0:	55                   	push   %ebp
80101df1:	89 e5                	mov    %esp,%ebp
80101df3:	57                   	push   %edi
80101df4:	56                   	push   %esi
80101df5:	53                   	push   %ebx
80101df6:	83 ec 20             	sub    $0x20,%esp
80101df9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101dfc:	6a 00                	push   $0x0
80101dfe:	ff 75 0c             	pushl  0xc(%ebp)
80101e01:	53                   	push   %ebx
80101e02:	e8 79 fd ff ff       	call   80101b80 <dirlookup>
80101e07:	83 c4 10             	add    $0x10,%esp
80101e0a:	85 c0                	test   %eax,%eax
80101e0c:	75 67                	jne    80101e75 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101e0e:	8b 7b 18             	mov    0x18(%ebx),%edi
80101e11:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e14:	85 ff                	test   %edi,%edi
80101e16:	74 29                	je     80101e41 <dirlink+0x51>
80101e18:	31 ff                	xor    %edi,%edi
80101e1a:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e1d:	eb 09                	jmp    80101e28 <dirlink+0x38>
80101e1f:	90                   	nop
80101e20:	83 c7 10             	add    $0x10,%edi
80101e23:	3b 7b 18             	cmp    0x18(%ebx),%edi
80101e26:	73 19                	jae    80101e41 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e28:	6a 10                	push   $0x10
80101e2a:	57                   	push   %edi
80101e2b:	56                   	push   %esi
80101e2c:	53                   	push   %ebx
80101e2d:	e8 fe fa ff ff       	call   80101930 <readi>
80101e32:	83 c4 10             	add    $0x10,%esp
80101e35:	83 f8 10             	cmp    $0x10,%eax
80101e38:	75 4e                	jne    80101e88 <dirlink+0x98>
    if(de.inum == 0)
80101e3a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101e3f:	75 df                	jne    80101e20 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80101e41:	8d 45 da             	lea    -0x26(%ebp),%eax
80101e44:	83 ec 04             	sub    $0x4,%esp
80101e47:	6a 0e                	push   $0xe
80101e49:	ff 75 0c             	pushl  0xc(%ebp)
80101e4c:	50                   	push   %eax
80101e4d:	e8 1e 30 00 00       	call   80104e70 <strncpy>
  de.inum = inum;
80101e52:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e55:	6a 10                	push   $0x10
80101e57:	57                   	push   %edi
80101e58:	56                   	push   %esi
80101e59:	53                   	push   %ebx
  de.inum = inum;
80101e5a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e5e:	e8 cd fb ff ff       	call   80101a30 <writei>
80101e63:	83 c4 20             	add    $0x20,%esp
80101e66:	83 f8 10             	cmp    $0x10,%eax
80101e69:	75 2a                	jne    80101e95 <dirlink+0xa5>
  return 0;
80101e6b:	31 c0                	xor    %eax,%eax
}
80101e6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e70:	5b                   	pop    %ebx
80101e71:	5e                   	pop    %esi
80101e72:	5f                   	pop    %edi
80101e73:	5d                   	pop    %ebp
80101e74:	c3                   	ret    
    iput(ip);
80101e75:	83 ec 0c             	sub    $0xc,%esp
80101e78:	50                   	push   %eax
80101e79:	e8 02 f9 ff ff       	call   80101780 <iput>
    return -1;
80101e7e:	83 c4 10             	add    $0x10,%esp
80101e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e86:	eb e5                	jmp    80101e6d <dirlink+0x7d>
      panic("dirlink read");
80101e88:	83 ec 0c             	sub    $0xc,%esp
80101e8b:	68 b5 7a 10 80       	push   $0x80107ab5
80101e90:	e8 db e4 ff ff       	call   80100370 <panic>
    panic("dirlink");
80101e95:	83 ec 0c             	sub    $0xc,%esp
80101e98:	68 12 82 10 80       	push   $0x80108212
80101e9d:	e8 ce e4 ff ff       	call   80100370 <panic>
80101ea2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101eb0 <namei>:

struct inode*
namei(char *path)
{
80101eb0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101eb1:	31 d2                	xor    %edx,%edx
{
80101eb3:	89 e5                	mov    %esp,%ebp
80101eb5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
80101eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101ebe:	e8 6d fd ff ff       	call   80101c30 <namex>
}
80101ec3:	c9                   	leave  
80101ec4:	c3                   	ret    
80101ec5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101ec9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ed0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101ed0:	55                   	push   %ebp
  return namex(path, 1, name);
80101ed1:	ba 01 00 00 00       	mov    $0x1,%edx
{
80101ed6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80101ed8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101edb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ede:	5d                   	pop    %ebp
  return namex(path, 1, name);
80101edf:	e9 4c fd ff ff       	jmp    80101c30 <namex>
80101ee4:	66 90                	xchg   %ax,%ax
80101ee6:	66 90                	xchg   %ax,%ax
80101ee8:	66 90                	xchg   %ax,%ax
80101eea:	66 90                	xchg   %ax,%ax
80101eec:	66 90                	xchg   %ax,%ax
80101eee:	66 90                	xchg   %ax,%ax

80101ef0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101ef0:	55                   	push   %ebp
80101ef1:	89 e5                	mov    %esp,%ebp
80101ef3:	57                   	push   %edi
80101ef4:	56                   	push   %esi
80101ef5:	53                   	push   %ebx
80101ef6:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80101ef9:	85 c0                	test   %eax,%eax
80101efb:	0f 84 b4 00 00 00    	je     80101fb5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101f01:	8b 58 08             	mov    0x8(%eax),%ebx
80101f04:	89 c6                	mov    %eax,%esi
80101f06:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101f0c:	0f 87 96 00 00 00    	ja     80101fa8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101f12:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80101f17:	89 f6                	mov    %esi,%esi
80101f19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80101f20:	89 ca                	mov    %ecx,%edx
80101f22:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101f23:	83 e0 c0             	and    $0xffffffc0,%eax
80101f26:	3c 40                	cmp    $0x40,%al
80101f28:	75 f6                	jne    80101f20 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101f2a:	31 ff                	xor    %edi,%edi
80101f2c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101f31:	89 f8                	mov    %edi,%eax
80101f33:	ee                   	out    %al,(%dx)
80101f34:	b8 01 00 00 00       	mov    $0x1,%eax
80101f39:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101f3e:	ee                   	out    %al,(%dx)
80101f3f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101f44:	89 d8                	mov    %ebx,%eax
80101f46:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101f47:	89 d8                	mov    %ebx,%eax
80101f49:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101f4e:	c1 f8 08             	sar    $0x8,%eax
80101f51:	ee                   	out    %al,(%dx)
80101f52:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101f57:	89 f8                	mov    %edi,%eax
80101f59:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101f5a:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101f5e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101f63:	c1 e0 04             	shl    $0x4,%eax
80101f66:	83 e0 10             	and    $0x10,%eax
80101f69:	83 c8 e0             	or     $0xffffffe0,%eax
80101f6c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101f6d:	f6 06 04             	testb  $0x4,(%esi)
80101f70:	75 16                	jne    80101f88 <idestart+0x98>
80101f72:	b8 20 00 00 00       	mov    $0x20,%eax
80101f77:	89 ca                	mov    %ecx,%edx
80101f79:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101f7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f7d:	5b                   	pop    %ebx
80101f7e:	5e                   	pop    %esi
80101f7f:	5f                   	pop    %edi
80101f80:	5d                   	pop    %ebp
80101f81:	c3                   	ret    
80101f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101f88:	b8 30 00 00 00       	mov    $0x30,%eax
80101f8d:	89 ca                	mov    %ecx,%edx
80101f8f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80101f90:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80101f95:	83 c6 18             	add    $0x18,%esi
80101f98:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101f9d:	fc                   	cld    
80101f9e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
80101fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fa3:	5b                   	pop    %ebx
80101fa4:	5e                   	pop    %esi
80101fa5:	5f                   	pop    %edi
80101fa6:	5d                   	pop    %ebp
80101fa7:	c3                   	ret    
    panic("incorrect blockno");
80101fa8:	83 ec 0c             	sub    $0xc,%esp
80101fab:	68 29 7b 10 80       	push   $0x80107b29
80101fb0:	e8 bb e3 ff ff       	call   80100370 <panic>
    panic("idestart");
80101fb5:	83 ec 0c             	sub    $0xc,%esp
80101fb8:	68 20 7b 10 80       	push   $0x80107b20
80101fbd:	e8 ae e3 ff ff       	call   80100370 <panic>
80101fc2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101fc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101fd0 <ideinit>:
{
80101fd0:	55                   	push   %ebp
80101fd1:	89 e5                	mov    %esp,%ebp
80101fd3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101fd6:	68 3b 7b 10 80       	push   $0x80107b3b
80101fdb:	68 80 b5 10 80       	push   $0x8010b580
80101fe0:	e8 db 2a 00 00       	call   80104ac0 <initlock>
  picenable(IRQ_IDE);
80101fe5:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80101fec:	e8 0f 13 00 00       	call   80103300 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101ff1:	58                   	pop    %eax
80101ff2:	a1 60 3a 11 80       	mov    0x80113a60,%eax
80101ff7:	5a                   	pop    %edx
80101ff8:	83 e8 01             	sub    $0x1,%eax
80101ffb:	50                   	push   %eax
80101ffc:	6a 0e                	push   $0xe
80101ffe:	e8 bd 02 00 00       	call   801022c0 <ioapicenable>
80102003:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102006:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010200b:	90                   	nop
8010200c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102010:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102011:	83 e0 c0             	and    $0xffffffc0,%eax
80102014:	3c 40                	cmp    $0x40,%al
80102016:	75 f8                	jne    80102010 <ideinit+0x40>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102018:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010201d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102022:	ee                   	out    %al,(%dx)
80102023:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102028:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010202d:	eb 06                	jmp    80102035 <ideinit+0x65>
8010202f:	90                   	nop
  for(i=0; i<1000; i++){
80102030:	83 e9 01             	sub    $0x1,%ecx
80102033:	74 0f                	je     80102044 <ideinit+0x74>
80102035:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102036:	84 c0                	test   %al,%al
80102038:	74 f6                	je     80102030 <ideinit+0x60>
      havedisk1 = 1;
8010203a:	c7 05 60 b5 10 80 01 	movl   $0x1,0x8010b560
80102041:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102044:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102049:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010204e:	ee                   	out    %al,(%dx)
}
8010204f:	c9                   	leave  
80102050:	c3                   	ret    
80102051:	eb 0d                	jmp    80102060 <ideintr>
80102053:	90                   	nop
80102054:	90                   	nop
80102055:	90                   	nop
80102056:	90                   	nop
80102057:	90                   	nop
80102058:	90                   	nop
80102059:	90                   	nop
8010205a:	90                   	nop
8010205b:	90                   	nop
8010205c:	90                   	nop
8010205d:	90                   	nop
8010205e:	90                   	nop
8010205f:	90                   	nop

80102060 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102060:	55                   	push   %ebp
80102061:	89 e5                	mov    %esp,%ebp
80102063:	57                   	push   %edi
80102064:	56                   	push   %esi
80102065:	53                   	push   %ebx
80102066:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102069:	68 80 b5 10 80       	push   $0x8010b580
8010206e:	e8 6d 2a 00 00       	call   80104ae0 <acquire>
  if((b = idequeue) == 0){
80102073:	8b 1d 64 b5 10 80    	mov    0x8010b564,%ebx
80102079:	83 c4 10             	add    $0x10,%esp
8010207c:	85 db                	test   %ebx,%ebx
8010207e:	74 67                	je     801020e7 <ideintr+0x87>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
80102080:	8b 43 14             	mov    0x14(%ebx),%eax
80102083:	a3 64 b5 10 80       	mov    %eax,0x8010b564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102088:	8b 3b                	mov    (%ebx),%edi
8010208a:	f7 c7 04 00 00 00    	test   $0x4,%edi
80102090:	75 31                	jne    801020c3 <ideintr+0x63>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102092:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102097:	89 f6                	mov    %esi,%esi
80102099:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801020a0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801020a1:	89 c6                	mov    %eax,%esi
801020a3:	83 e6 c0             	and    $0xffffffc0,%esi
801020a6:	89 f1                	mov    %esi,%ecx
801020a8:	80 f9 40             	cmp    $0x40,%cl
801020ab:	75 f3                	jne    801020a0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801020ad:	a8 21                	test   $0x21,%al
801020af:	75 12                	jne    801020c3 <ideintr+0x63>
    insl(0x1f0, b->data, BSIZE/4);
801020b1:	8d 7b 18             	lea    0x18(%ebx),%edi
  asm volatile("cld; rep insl" :
801020b4:	b9 80 00 00 00       	mov    $0x80,%ecx
801020b9:	ba f0 01 00 00       	mov    $0x1f0,%edx
801020be:	fc                   	cld    
801020bf:	f3 6d                	rep insl (%dx),%es:(%edi)
801020c1:	8b 3b                	mov    (%ebx),%edi

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
801020c3:	83 e7 fb             	and    $0xfffffffb,%edi
  wakeup(b);
801020c6:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801020c9:	89 f9                	mov    %edi,%ecx
801020cb:	83 c9 02             	or     $0x2,%ecx
801020ce:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
801020d0:	53                   	push   %ebx
801020d1:	e8 0a 20 00 00       	call   801040e0 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801020d6:	a1 64 b5 10 80       	mov    0x8010b564,%eax
801020db:	83 c4 10             	add    $0x10,%esp
801020de:	85 c0                	test   %eax,%eax
801020e0:	74 05                	je     801020e7 <ideintr+0x87>
    idestart(idequeue);
801020e2:	e8 09 fe ff ff       	call   80101ef0 <idestart>
    release(&idelock);
801020e7:	83 ec 0c             	sub    $0xc,%esp
801020ea:	68 80 b5 10 80       	push   $0x8010b580
801020ef:	e8 ac 2b 00 00       	call   80104ca0 <release>

  release(&idelock);
}
801020f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020f7:	5b                   	pop    %ebx
801020f8:	5e                   	pop    %esi
801020f9:	5f                   	pop    %edi
801020fa:	5d                   	pop    %ebp
801020fb:	c3                   	ret    
801020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102100 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102100:	55                   	push   %ebp
80102101:	89 e5                	mov    %esp,%ebp
80102103:	53                   	push   %ebx
80102104:	83 ec 04             	sub    $0x4,%esp
80102107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010210a:	8b 03                	mov    (%ebx),%eax
8010210c:	a8 01                	test   $0x1,%al
8010210e:	0f 84 c0 00 00 00    	je     801021d4 <iderw+0xd4>
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102114:	83 e0 06             	and    $0x6,%eax
80102117:	83 f8 02             	cmp    $0x2,%eax
8010211a:	0f 84 a7 00 00 00    	je     801021c7 <iderw+0xc7>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80102120:	8b 53 04             	mov    0x4(%ebx),%edx
80102123:	85 d2                	test   %edx,%edx
80102125:	74 0d                	je     80102134 <iderw+0x34>
80102127:	a1 60 b5 10 80       	mov    0x8010b560,%eax
8010212c:	85 c0                	test   %eax,%eax
8010212e:	0f 84 ad 00 00 00    	je     801021e1 <iderw+0xe1>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102134:	83 ec 0c             	sub    $0xc,%esp
80102137:	68 80 b5 10 80       	push   $0x8010b580
8010213c:	e8 9f 29 00 00       	call   80104ae0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102141:	8b 15 64 b5 10 80    	mov    0x8010b564,%edx
80102147:	83 c4 10             	add    $0x10,%esp
  b->qnext = 0;
8010214a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102151:	85 d2                	test   %edx,%edx
80102153:	75 0d                	jne    80102162 <iderw+0x62>
80102155:	eb 69                	jmp    801021c0 <iderw+0xc0>
80102157:	89 f6                	mov    %esi,%esi
80102159:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80102160:	89 c2                	mov    %eax,%edx
80102162:	8b 42 14             	mov    0x14(%edx),%eax
80102165:	85 c0                	test   %eax,%eax
80102167:	75 f7                	jne    80102160 <iderw+0x60>
80102169:	83 c2 14             	add    $0x14,%edx
    ;
  *pp = b;
8010216c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010216e:	39 1d 64 b5 10 80    	cmp    %ebx,0x8010b564
80102174:	74 3a                	je     801021b0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102176:	8b 03                	mov    (%ebx),%eax
80102178:	83 e0 06             	and    $0x6,%eax
8010217b:	83 f8 02             	cmp    $0x2,%eax
8010217e:	74 1b                	je     8010219b <iderw+0x9b>
    sleep(b, &idelock);
80102180:	83 ec 08             	sub    $0x8,%esp
80102183:	68 80 b5 10 80       	push   $0x8010b580
80102188:	53                   	push   %ebx
80102189:	e8 f2 1c 00 00       	call   80103e80 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010218e:	8b 03                	mov    (%ebx),%eax
80102190:	83 c4 10             	add    $0x10,%esp
80102193:	83 e0 06             	and    $0x6,%eax
80102196:	83 f8 02             	cmp    $0x2,%eax
80102199:	75 e5                	jne    80102180 <iderw+0x80>
  }

  release(&idelock);
8010219b:	c7 45 08 80 b5 10 80 	movl   $0x8010b580,0x8(%ebp)
}
801021a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801021a5:	c9                   	leave  
  release(&idelock);
801021a6:	e9 f5 2a 00 00       	jmp    80104ca0 <release>
801021ab:	90                   	nop
801021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    idestart(b);
801021b0:	89 d8                	mov    %ebx,%eax
801021b2:	e8 39 fd ff ff       	call   80101ef0 <idestart>
801021b7:	eb bd                	jmp    80102176 <iderw+0x76>
801021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801021c0:	ba 64 b5 10 80       	mov    $0x8010b564,%edx
801021c5:	eb a5                	jmp    8010216c <iderw+0x6c>
    panic("iderw: nothing to do");
801021c7:	83 ec 0c             	sub    $0xc,%esp
801021ca:	68 53 7b 10 80       	push   $0x80107b53
801021cf:	e8 9c e1 ff ff       	call   80100370 <panic>
    panic("iderw: buf not busy");
801021d4:	83 ec 0c             	sub    $0xc,%esp
801021d7:	68 3f 7b 10 80       	push   $0x80107b3f
801021dc:	e8 8f e1 ff ff       	call   80100370 <panic>
    panic("iderw: ide disk 1 not present");
801021e1:	83 ec 0c             	sub    $0xc,%esp
801021e4:	68 68 7b 10 80       	push   $0x80107b68
801021e9:	e8 82 e1 ff ff       	call   80100370 <panic>
801021ee:	66 90                	xchg   %ax,%ax

801021f0 <ioapicinit>:
void
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
801021f0:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801021f5:	85 c0                	test   %eax,%eax
801021f7:	0f 84 b3 00 00 00    	je     801022b0 <ioapicinit+0xc0>
{
801021fd:	55                   	push   %ebp
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801021fe:	c7 05 94 21 11 80 00 	movl   $0xfec00000,0x80112194
80102205:	00 c0 fe 
{
80102208:	89 e5                	mov    %esp,%ebp
8010220a:	56                   	push   %esi
8010220b:	53                   	push   %ebx
  ioapic->reg = reg;
8010220c:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102213:	00 00 00 
  return ioapic->data;
80102216:	a1 94 21 11 80       	mov    0x80112194,%eax
8010221b:	8b 58 10             	mov    0x10(%eax),%ebx
  ioapic->reg = reg;
8010221e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return ioapic->data;
80102224:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010222a:	0f b6 15 c0 22 11 80 	movzbl 0x801122c0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102231:	c1 eb 10             	shr    $0x10,%ebx
  return ioapic->data;
80102234:	8b 41 10             	mov    0x10(%ecx),%eax
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102237:	0f b6 db             	movzbl %bl,%ebx
  id = ioapicread(REG_ID) >> 24;
8010223a:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
8010223d:	39 c2                	cmp    %eax,%edx
8010223f:	75 4f                	jne    80102290 <ioapicinit+0xa0>
80102241:	83 c3 21             	add    $0x21,%ebx
{
80102244:	ba 10 00 00 00       	mov    $0x10,%edx
80102249:	b8 20 00 00 00       	mov    $0x20,%eax
8010224e:	66 90                	xchg   %ax,%ax
  ioapic->reg = reg;
80102250:	89 11                	mov    %edx,(%ecx)
  ioapic->data = data;
80102252:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102258:	89 c6                	mov    %eax,%esi
8010225a:	81 ce 00 00 01 00    	or     $0x10000,%esi
80102260:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
80102263:	89 71 10             	mov    %esi,0x10(%ecx)
80102266:	8d 72 01             	lea    0x1(%edx),%esi
80102269:	83 c2 02             	add    $0x2,%edx
  for(i = 0; i <= maxintr; i++){
8010226c:	39 d8                	cmp    %ebx,%eax
  ioapic->reg = reg;
8010226e:	89 31                	mov    %esi,(%ecx)
  ioapic->data = data;
80102270:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
80102276:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010227d:	75 d1                	jne    80102250 <ioapicinit+0x60>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010227f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102282:	5b                   	pop    %ebx
80102283:	5e                   	pop    %esi
80102284:	5d                   	pop    %ebp
80102285:	c3                   	ret    
80102286:	8d 76 00             	lea    0x0(%esi),%esi
80102289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102290:	83 ec 0c             	sub    $0xc,%esp
80102293:	68 88 7b 10 80       	push   $0x80107b88
80102298:	e8 a3 e3 ff ff       	call   80100640 <cprintf>
8010229d:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
801022a3:	83 c4 10             	add    $0x10,%esp
801022a6:	eb 99                	jmp    80102241 <ioapicinit+0x51>
801022a8:	90                   	nop
801022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022b0:	f3 c3                	repz ret 
801022b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801022c0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
801022c0:	8b 15 c4 22 11 80    	mov    0x801122c4,%edx
{
801022c6:	55                   	push   %ebp
801022c7:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801022c9:	85 d2                	test   %edx,%edx
{
801022cb:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
801022ce:	74 2b                	je     801022fb <ioapicenable+0x3b>
  ioapic->reg = reg;
801022d0:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801022d6:	8d 50 20             	lea    0x20(%eax),%edx
801022d9:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801022dd:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801022df:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801022e5:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801022e8:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801022eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801022ee:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801022f0:	a1 94 21 11 80       	mov    0x80112194,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801022f5:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801022f8:	89 50 10             	mov    %edx,0x10(%eax)
}
801022fb:	5d                   	pop    %ebp
801022fc:	c3                   	ret    
801022fd:	66 90                	xchg   %ax,%ax
801022ff:	90                   	nop

80102300 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102300:	55                   	push   %ebp
80102301:	89 e5                	mov    %esp,%ebp
80102303:	53                   	push   %ebx
80102304:	83 ec 04             	sub    $0x4,%esp
80102307:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010230a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102310:	75 70                	jne    80102382 <kfree+0x82>
80102312:	81 fb 48 83 11 80    	cmp    $0x80118348,%ebx
80102318:	72 68                	jb     80102382 <kfree+0x82>
8010231a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102320:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102325:	77 5b                	ja     80102382 <kfree+0x82>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102327:	83 ec 04             	sub    $0x4,%esp
8010232a:	68 00 10 00 00       	push   $0x1000
8010232f:	6a 01                	push   $0x1
80102331:	53                   	push   %ebx
80102332:	e8 b9 29 00 00       	call   80104cf0 <memset>

  if(kmem.use_lock)
80102337:	8b 15 d4 21 11 80    	mov    0x801121d4,%edx
8010233d:	83 c4 10             	add    $0x10,%esp
80102340:	85 d2                	test   %edx,%edx
80102342:	75 2c                	jne    80102370 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102344:	a1 d8 21 11 80       	mov    0x801121d8,%eax
80102349:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010234b:	a1 d4 21 11 80       	mov    0x801121d4,%eax
  kmem.freelist = r;
80102350:	89 1d d8 21 11 80    	mov    %ebx,0x801121d8
  if(kmem.use_lock)
80102356:	85 c0                	test   %eax,%eax
80102358:	75 06                	jne    80102360 <kfree+0x60>
    release(&kmem.lock);
}
8010235a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010235d:	c9                   	leave  
8010235e:	c3                   	ret    
8010235f:	90                   	nop
    release(&kmem.lock);
80102360:	c7 45 08 a0 21 11 80 	movl   $0x801121a0,0x8(%ebp)
}
80102367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010236a:	c9                   	leave  
    release(&kmem.lock);
8010236b:	e9 30 29 00 00       	jmp    80104ca0 <release>
    acquire(&kmem.lock);
80102370:	83 ec 0c             	sub    $0xc,%esp
80102373:	68 a0 21 11 80       	push   $0x801121a0
80102378:	e8 63 27 00 00       	call   80104ae0 <acquire>
8010237d:	83 c4 10             	add    $0x10,%esp
80102380:	eb c2                	jmp    80102344 <kfree+0x44>
    panic("kfree");
80102382:	83 ec 0c             	sub    $0xc,%esp
80102385:	68 ba 7b 10 80       	push   $0x80107bba
8010238a:	e8 e1 df ff ff       	call   80100370 <panic>
8010238f:	90                   	nop

80102390 <freerange>:
{
80102390:	55                   	push   %ebp
80102391:	89 e5                	mov    %esp,%ebp
80102393:	56                   	push   %esi
80102394:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102395:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102398:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010239b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801023a1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023a7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801023ad:	39 de                	cmp    %ebx,%esi
801023af:	72 23                	jb     801023d4 <freerange+0x44>
801023b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801023b8:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
801023be:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023c1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801023c7:	50                   	push   %eax
801023c8:	e8 33 ff ff ff       	call   80102300 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023cd:	83 c4 10             	add    $0x10,%esp
801023d0:	39 f3                	cmp    %esi,%ebx
801023d2:	76 e4                	jbe    801023b8 <freerange+0x28>
}
801023d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801023d7:	5b                   	pop    %ebx
801023d8:	5e                   	pop    %esi
801023d9:	5d                   	pop    %ebp
801023da:	c3                   	ret    
801023db:	90                   	nop
801023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801023e0 <kinit1>:
{
801023e0:	55                   	push   %ebp
801023e1:	89 e5                	mov    %esp,%ebp
801023e3:	56                   	push   %esi
801023e4:	53                   	push   %ebx
801023e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
801023e8:	83 ec 08             	sub    $0x8,%esp
801023eb:	68 c0 7b 10 80       	push   $0x80107bc0
801023f0:	68 a0 21 11 80       	push   $0x801121a0
801023f5:	e8 c6 26 00 00       	call   80104ac0 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
801023fa:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023fd:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102400:	c7 05 d4 21 11 80 00 	movl   $0x0,0x801121d4
80102407:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010240a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102410:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102416:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010241c:	39 de                	cmp    %ebx,%esi
8010241e:	72 1c                	jb     8010243c <kinit1+0x5c>
    kfree(p);
80102420:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
80102426:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102429:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010242f:	50                   	push   %eax
80102430:	e8 cb fe ff ff       	call   80102300 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102435:	83 c4 10             	add    $0x10,%esp
80102438:	39 de                	cmp    %ebx,%esi
8010243a:	73 e4                	jae    80102420 <kinit1+0x40>
}
8010243c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010243f:	5b                   	pop    %ebx
80102440:	5e                   	pop    %esi
80102441:	5d                   	pop    %ebp
80102442:	c3                   	ret    
80102443:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102449:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102450 <kinit2>:
{
80102450:	55                   	push   %ebp
80102451:	89 e5                	mov    %esp,%ebp
80102453:	56                   	push   %esi
80102454:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102455:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102458:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010245b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102461:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102467:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010246d:	39 de                	cmp    %ebx,%esi
8010246f:	72 23                	jb     80102494 <kinit2+0x44>
80102471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102478:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
8010247e:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102481:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102487:	50                   	push   %eax
80102488:	e8 73 fe ff ff       	call   80102300 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010248d:	83 c4 10             	add    $0x10,%esp
80102490:	39 de                	cmp    %ebx,%esi
80102492:	73 e4                	jae    80102478 <kinit2+0x28>
  kmem.use_lock = 1;
80102494:	c7 05 d4 21 11 80 01 	movl   $0x1,0x801121d4
8010249b:	00 00 00 
}
8010249e:	8d 65 f8             	lea    -0x8(%ebp),%esp
801024a1:	5b                   	pop    %ebx
801024a2:	5e                   	pop    %esi
801024a3:	5d                   	pop    %ebp
801024a4:	c3                   	ret    
801024a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801024a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801024b0 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
801024b0:	a1 d4 21 11 80       	mov    0x801121d4,%eax
801024b5:	85 c0                	test   %eax,%eax
801024b7:	75 1f                	jne    801024d8 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
801024b9:	a1 d8 21 11 80       	mov    0x801121d8,%eax
  if(r)
801024be:	85 c0                	test   %eax,%eax
801024c0:	74 0e                	je     801024d0 <kalloc+0x20>
    kmem.freelist = r->next;
801024c2:	8b 10                	mov    (%eax),%edx
801024c4:	89 15 d8 21 11 80    	mov    %edx,0x801121d8
801024ca:	c3                   	ret    
801024cb:	90                   	nop
801024cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}
801024d0:	f3 c3                	repz ret 
801024d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
801024d8:	55                   	push   %ebp
801024d9:	89 e5                	mov    %esp,%ebp
801024db:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
801024de:	68 a0 21 11 80       	push   $0x801121a0
801024e3:	e8 f8 25 00 00       	call   80104ae0 <acquire>
  r = kmem.freelist;
801024e8:	a1 d8 21 11 80       	mov    0x801121d8,%eax
  if(r)
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	8b 15 d4 21 11 80    	mov    0x801121d4,%edx
801024f6:	85 c0                	test   %eax,%eax
801024f8:	74 08                	je     80102502 <kalloc+0x52>
    kmem.freelist = r->next;
801024fa:	8b 08                	mov    (%eax),%ecx
801024fc:	89 0d d8 21 11 80    	mov    %ecx,0x801121d8
  if(kmem.use_lock)
80102502:	85 d2                	test   %edx,%edx
80102504:	74 16                	je     8010251c <kalloc+0x6c>
    release(&kmem.lock);
80102506:	83 ec 0c             	sub    $0xc,%esp
80102509:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010250c:	68 a0 21 11 80       	push   $0x801121a0
80102511:	e8 8a 27 00 00       	call   80104ca0 <release>
  return (char*)r;
80102516:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
80102519:	83 c4 10             	add    $0x10,%esp
}
8010251c:	c9                   	leave  
8010251d:	c3                   	ret    
8010251e:	66 90                	xchg   %ax,%ax

80102520 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102520:	ba 64 00 00 00       	mov    $0x64,%edx
80102525:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102526:	a8 01                	test   $0x1,%al
80102528:	0f 84 c2 00 00 00    	je     801025f0 <kbdgetc+0xd0>
8010252e:	ba 60 00 00 00       	mov    $0x60,%edx
80102533:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102534:	0f b6 d0             	movzbl %al,%edx
80102537:	8b 0d b4 b5 10 80    	mov    0x8010b5b4,%ecx

  if(data == 0xE0){
8010253d:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102543:	0f 84 7f 00 00 00    	je     801025c8 <kbdgetc+0xa8>
{
80102549:	55                   	push   %ebp
8010254a:	89 e5                	mov    %esp,%ebp
8010254c:	53                   	push   %ebx
8010254d:	89 cb                	mov    %ecx,%ebx
8010254f:	83 e3 40             	and    $0x40,%ebx
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102552:	84 c0                	test   %al,%al
80102554:	78 4a                	js     801025a0 <kbdgetc+0x80>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102556:	85 db                	test   %ebx,%ebx
80102558:	74 09                	je     80102563 <kbdgetc+0x43>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010255a:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
8010255d:	83 e1 bf             	and    $0xffffffbf,%ecx
    data |= 0x80;
80102560:	0f b6 d0             	movzbl %al,%edx
  }

  shift |= shiftcode[data];
80102563:	0f b6 82 00 7d 10 80 	movzbl -0x7fef8300(%edx),%eax
8010256a:	09 c1                	or     %eax,%ecx
  shift ^= togglecode[data];
8010256c:	0f b6 82 00 7c 10 80 	movzbl -0x7fef8400(%edx),%eax
80102573:	31 c1                	xor    %eax,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
80102575:	89 c8                	mov    %ecx,%eax
  shift ^= togglecode[data];
80102577:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010257d:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102580:	83 e1 08             	and    $0x8,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
80102583:	8b 04 85 e0 7b 10 80 	mov    -0x7fef8420(,%eax,4),%eax
8010258a:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010258e:	74 31                	je     801025c1 <kbdgetc+0xa1>
    if('a' <= c && c <= 'z')
80102590:	8d 50 9f             	lea    -0x61(%eax),%edx
80102593:	83 fa 19             	cmp    $0x19,%edx
80102596:	77 40                	ja     801025d8 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102598:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010259b:	5b                   	pop    %ebx
8010259c:	5d                   	pop    %ebp
8010259d:	c3                   	ret    
8010259e:	66 90                	xchg   %ax,%ax
    data = (shift & E0ESC ? data : data & 0x7F);
801025a0:	83 e0 7f             	and    $0x7f,%eax
801025a3:	85 db                	test   %ebx,%ebx
801025a5:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801025a8:	0f b6 82 00 7d 10 80 	movzbl -0x7fef8300(%edx),%eax
801025af:	83 c8 40             	or     $0x40,%eax
801025b2:	0f b6 c0             	movzbl %al,%eax
801025b5:	f7 d0                	not    %eax
801025b7:	21 c1                	and    %eax,%ecx
    return 0;
801025b9:	31 c0                	xor    %eax,%eax
    shift &= ~(shiftcode[data] | E0ESC);
801025bb:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
}
801025c1:	5b                   	pop    %ebx
801025c2:	5d                   	pop    %ebp
801025c3:	c3                   	ret    
801025c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    shift |= E0ESC;
801025c8:	83 c9 40             	or     $0x40,%ecx
    return 0;
801025cb:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
801025cd:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
    return 0;
801025d3:	c3                   	ret    
801025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else if('A' <= c && c <= 'Z')
801025d8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
801025db:	8d 50 20             	lea    0x20(%eax),%edx
}
801025de:	5b                   	pop    %ebx
      c += 'a' - 'A';
801025df:	83 f9 1a             	cmp    $0x1a,%ecx
801025e2:	0f 42 c2             	cmovb  %edx,%eax
}
801025e5:	5d                   	pop    %ebp
801025e6:	c3                   	ret    
801025e7:	89 f6                	mov    %esi,%esi
801025e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
801025f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801025f5:	c3                   	ret    
801025f6:	8d 76 00             	lea    0x0(%esi),%esi
801025f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102600 <kbdintr>:

void
kbdintr(void)
{
80102600:	55                   	push   %ebp
80102601:	89 e5                	mov    %esp,%ebp
80102603:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102606:	68 20 25 10 80       	push   $0x80102520
8010260b:	e8 e0 e1 ff ff       	call   801007f0 <consoleintr>
}
80102610:	83 c4 10             	add    $0x10,%esp
80102613:	c9                   	leave  
80102614:	c3                   	ret    
80102615:	66 90                	xchg   %ax,%ax
80102617:	66 90                	xchg   %ax,%ax
80102619:	66 90                	xchg   %ax,%ax
8010261b:	66 90                	xchg   %ax,%ax
8010261d:	66 90                	xchg   %ax,%ax
8010261f:	90                   	nop

80102620 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
  if(!lapic)
80102620:	a1 dc 21 11 80       	mov    0x801121dc,%eax
{
80102625:	55                   	push   %ebp
80102626:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102628:	85 c0                	test   %eax,%eax
8010262a:	0f 84 c8 00 00 00    	je     801026f8 <lapicinit+0xd8>
  lapic[index] = value;
80102630:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102637:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010263a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010263d:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102644:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102647:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010264a:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102651:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102654:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102657:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010265e:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102661:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102664:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
8010266b:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010266e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102671:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102678:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010267b:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010267e:	8b 50 30             	mov    0x30(%eax),%edx
80102681:	c1 ea 10             	shr    $0x10,%edx
80102684:	80 fa 03             	cmp    $0x3,%dl
80102687:	77 77                	ja     80102700 <lapicinit+0xe0>
  lapic[index] = value;
80102689:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102690:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102693:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102696:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010269d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026a0:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026a3:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801026aa:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026ad:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026b0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801026b7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026ba:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026bd:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
801026c4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026c7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026ca:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801026d1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801026d4:	8b 50 20             	mov    0x20(%eax),%edx
801026d7:	89 f6                	mov    %esi,%esi
801026d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801026e0:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801026e6:	80 e6 10             	and    $0x10,%dh
801026e9:	75 f5                	jne    801026e0 <lapicinit+0xc0>
  lapic[index] = value;
801026eb:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801026f2:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026f5:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801026f8:	5d                   	pop    %ebp
801026f9:	c3                   	ret    
801026fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  lapic[index] = value;
80102700:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102707:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010270a:	8b 50 20             	mov    0x20(%eax),%edx
8010270d:	e9 77 ff ff ff       	jmp    80102689 <lapicinit+0x69>
80102712:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102719:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102720 <cpunum>:

int
  cpunum(void)
{
80102720:	55                   	push   %ebp
80102721:	89 e5                	mov    %esp,%ebp
80102723:	56                   	push   %esi
80102724:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102725:	9c                   	pushf  
80102726:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102727:	f6 c4 02             	test   $0x2,%ah
8010272a:	74 12                	je     8010273e <cpunum+0x1e>
    static int n;
    if(n++ == 0)
8010272c:	a1 b8 b5 10 80       	mov    0x8010b5b8,%eax
80102731:	8d 50 01             	lea    0x1(%eax),%edx
80102734:	85 c0                	test   %eax,%eax
80102736:	89 15 b8 b5 10 80    	mov    %edx,0x8010b5b8
8010273c:	74 62                	je     801027a0 <cpunum+0x80>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if (!lapic)
8010273e:	a1 dc 21 11 80       	mov    0x801121dc,%eax
80102743:	85 c0                	test   %eax,%eax
80102745:	74 49                	je     80102790 <cpunum+0x70>
    return 0;

  apicid = lapic[ID] >> 24;
80102747:	8b 58 20             	mov    0x20(%eax),%ebx
  for (i = 0; i < ncpu; ++i) {
8010274a:	8b 35 60 3a 11 80    	mov    0x80113a60,%esi
  apicid = lapic[ID] >> 24;
80102750:	c1 eb 18             	shr    $0x18,%ebx
  for (i = 0; i < ncpu; ++i) {
80102753:	85 f6                	test   %esi,%esi
80102755:	7e 5e                	jle    801027b5 <cpunum+0x95>
    if (cpus[i].apicid == apicid)
80102757:	0f b6 05 e0 22 11 80 	movzbl 0x801122e0,%eax
8010275e:	39 c3                	cmp    %eax,%ebx
80102760:	74 2e                	je     80102790 <cpunum+0x70>
80102762:	ba 9c 23 11 80       	mov    $0x8011239c,%edx
  for (i = 0; i < ncpu; ++i) {
80102767:	31 c0                	xor    %eax,%eax
80102769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102770:	83 c0 01             	add    $0x1,%eax
80102773:	39 f0                	cmp    %esi,%eax
80102775:	74 3e                	je     801027b5 <cpunum+0x95>
    if (cpus[i].apicid == apicid)
80102777:	0f b6 0a             	movzbl (%edx),%ecx
8010277a:	81 c2 bc 00 00 00    	add    $0xbc,%edx
80102780:	39 d9                	cmp    %ebx,%ecx
80102782:	75 ec                	jne    80102770 <cpunum+0x50>
      return i;
  }
  panic("unknown apicid\n");
}
80102784:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102787:	5b                   	pop    %ebx
80102788:	5e                   	pop    %esi
80102789:	5d                   	pop    %ebp
8010278a:	c3                   	ret    
8010278b:	90                   	nop
8010278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102790:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
80102793:	31 c0                	xor    %eax,%eax
}
80102795:	5b                   	pop    %ebx
80102796:	5e                   	pop    %esi
80102797:	5d                   	pop    %ebp
80102798:	c3                   	ret    
80102799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      cprintf("cpu called from %x with interrupts enabled\n",
801027a0:	83 ec 08             	sub    $0x8,%esp
801027a3:	ff 75 04             	pushl  0x4(%ebp)
801027a6:	68 00 7e 10 80       	push   $0x80107e00
801027ab:	e8 90 de ff ff       	call   80100640 <cprintf>
801027b0:	83 c4 10             	add    $0x10,%esp
801027b3:	eb 89                	jmp    8010273e <cpunum+0x1e>
  panic("unknown apicid\n");
801027b5:	83 ec 0c             	sub    $0xc,%esp
801027b8:	68 2c 7e 10 80       	push   $0x80107e2c
801027bd:	e8 ae db ff ff       	call   80100370 <panic>
801027c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801027d0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
801027d0:	a1 dc 21 11 80       	mov    0x801121dc,%eax
{
801027d5:	55                   	push   %ebp
801027d6:	89 e5                	mov    %esp,%ebp
  if(lapic)
801027d8:	85 c0                	test   %eax,%eax
801027da:	74 0d                	je     801027e9 <lapiceoi+0x19>
  lapic[index] = value;
801027dc:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801027e3:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801027e6:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
801027e9:	5d                   	pop    %ebp
801027ea:	c3                   	ret    
801027eb:	90                   	nop
801027ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801027f0 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801027f0:	55                   	push   %ebp
801027f1:	89 e5                	mov    %esp,%ebp
}
801027f3:	5d                   	pop    %ebp
801027f4:	c3                   	ret    
801027f5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801027f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102800 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102800:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102801:	b8 0f 00 00 00       	mov    $0xf,%eax
80102806:	ba 70 00 00 00       	mov    $0x70,%edx
8010280b:	89 e5                	mov    %esp,%ebp
8010280d:	53                   	push   %ebx
8010280e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102811:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102814:	ee                   	out    %al,(%dx)
80102815:	b8 0a 00 00 00       	mov    $0xa,%eax
8010281a:	ba 71 00 00 00       	mov    $0x71,%edx
8010281f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102820:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102822:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102825:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
8010282b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
8010282d:	c1 e9 0c             	shr    $0xc,%ecx
  wrv[1] = addr >> 4;
80102830:	c1 e8 04             	shr    $0x4,%eax
  lapicw(ICRHI, apicid<<24);
80102833:	89 da                	mov    %ebx,%edx
    lapicw(ICRLO, STARTUP | (addr>>12));
80102835:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102838:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
8010283e:	a1 dc 21 11 80       	mov    0x801121dc,%eax
80102843:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102849:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010284c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102853:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102856:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102859:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102860:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102863:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102866:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010286c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010286f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102875:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102878:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010287e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102881:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102887:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
8010288a:	5b                   	pop    %ebx
8010288b:	5d                   	pop    %ebp
8010288c:	c3                   	ret    
8010288d:	8d 76 00             	lea    0x0(%esi),%esi

80102890 <cmostime>:
  r->year   = cmos_read(YEAR);
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102890:	55                   	push   %ebp
80102891:	b8 0b 00 00 00       	mov    $0xb,%eax
80102896:	ba 70 00 00 00       	mov    $0x70,%edx
8010289b:	89 e5                	mov    %esp,%ebp
8010289d:	57                   	push   %edi
8010289e:	56                   	push   %esi
8010289f:	53                   	push   %ebx
801028a0:	83 ec 4c             	sub    $0x4c,%esp
801028a3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028a4:	ba 71 00 00 00       	mov    $0x71,%edx
801028a9:	ec                   	in     (%dx),%al
801028aa:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028ad:	bb 70 00 00 00       	mov    $0x70,%ebx
801028b2:	88 45 b3             	mov    %al,-0x4d(%ebp)
801028b5:	8d 76 00             	lea    0x0(%esi),%esi
801028b8:	31 c0                	xor    %eax,%eax
801028ba:	89 da                	mov    %ebx,%edx
801028bc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028bd:	b9 71 00 00 00       	mov    $0x71,%ecx
801028c2:	89 ca                	mov    %ecx,%edx
801028c4:	ec                   	in     (%dx),%al
801028c5:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028c8:	89 da                	mov    %ebx,%edx
801028ca:	b8 02 00 00 00       	mov    $0x2,%eax
801028cf:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028d0:	89 ca                	mov    %ecx,%edx
801028d2:	ec                   	in     (%dx),%al
801028d3:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028d6:	89 da                	mov    %ebx,%edx
801028d8:	b8 04 00 00 00       	mov    $0x4,%eax
801028dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028de:	89 ca                	mov    %ecx,%edx
801028e0:	ec                   	in     (%dx),%al
801028e1:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028e4:	89 da                	mov    %ebx,%edx
801028e6:	b8 07 00 00 00       	mov    $0x7,%eax
801028eb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028ec:	89 ca                	mov    %ecx,%edx
801028ee:	ec                   	in     (%dx),%al
801028ef:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028f2:	89 da                	mov    %ebx,%edx
801028f4:	b8 08 00 00 00       	mov    $0x8,%eax
801028f9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028fa:	89 ca                	mov    %ecx,%edx
801028fc:	ec                   	in     (%dx),%al
801028fd:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028ff:	89 da                	mov    %ebx,%edx
80102901:	b8 09 00 00 00       	mov    $0x9,%eax
80102906:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102907:	89 ca                	mov    %ecx,%edx
80102909:	ec                   	in     (%dx),%al
8010290a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010290c:	89 da                	mov    %ebx,%edx
8010290e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102913:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102914:	89 ca                	mov    %ecx,%edx
80102916:	ec                   	in     (%dx),%al
  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102917:	84 c0                	test   %al,%al
80102919:	78 9d                	js     801028b8 <cmostime+0x28>
  return inb(CMOS_RETURN);
8010291b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
8010291f:	89 fa                	mov    %edi,%edx
80102921:	0f b6 fa             	movzbl %dl,%edi
80102924:	89 f2                	mov    %esi,%edx
80102926:	0f b6 f2             	movzbl %dl,%esi
80102929:	89 7d c8             	mov    %edi,-0x38(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010292c:	89 da                	mov    %ebx,%edx
8010292e:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102931:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102934:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102938:	89 45 bc             	mov    %eax,-0x44(%ebp)
8010293b:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
8010293f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102942:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102946:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102949:	31 c0                	xor    %eax,%eax
8010294b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010294c:	89 ca                	mov    %ecx,%edx
8010294e:	ec                   	in     (%dx),%al
8010294f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102952:	89 da                	mov    %ebx,%edx
80102954:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102957:	b8 02 00 00 00       	mov    $0x2,%eax
8010295c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010295d:	89 ca                	mov    %ecx,%edx
8010295f:	ec                   	in     (%dx),%al
80102960:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102963:	89 da                	mov    %ebx,%edx
80102965:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102968:	b8 04 00 00 00       	mov    $0x4,%eax
8010296d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010296e:	89 ca                	mov    %ecx,%edx
80102970:	ec                   	in     (%dx),%al
80102971:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102974:	89 da                	mov    %ebx,%edx
80102976:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102979:	b8 07 00 00 00       	mov    $0x7,%eax
8010297e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010297f:	89 ca                	mov    %ecx,%edx
80102981:	ec                   	in     (%dx),%al
80102982:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102985:	89 da                	mov    %ebx,%edx
80102987:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010298a:	b8 08 00 00 00       	mov    $0x8,%eax
8010298f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102990:	89 ca                	mov    %ecx,%edx
80102992:	ec                   	in     (%dx),%al
80102993:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102996:	89 da                	mov    %ebx,%edx
80102998:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010299b:	b8 09 00 00 00       	mov    $0x9,%eax
801029a0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029a1:	89 ca                	mov    %ecx,%edx
801029a3:	ec                   	in     (%dx),%al
801029a4:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801029a7:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
801029aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801029ad:	8d 45 d0             	lea    -0x30(%ebp),%eax
801029b0:	6a 18                	push   $0x18
801029b2:	50                   	push   %eax
801029b3:	8d 45 b8             	lea    -0x48(%ebp),%eax
801029b6:	50                   	push   %eax
801029b7:	e8 84 23 00 00       	call   80104d40 <memcmp>
801029bc:	83 c4 10             	add    $0x10,%esp
801029bf:	85 c0                	test   %eax,%eax
801029c1:	0f 85 f1 fe ff ff    	jne    801028b8 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
801029c7:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
801029cb:	75 78                	jne    80102a45 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801029cd:	8b 45 b8             	mov    -0x48(%ebp),%eax
801029d0:	89 c2                	mov    %eax,%edx
801029d2:	83 e0 0f             	and    $0xf,%eax
801029d5:	c1 ea 04             	shr    $0x4,%edx
801029d8:	8d 14 92             	lea    (%edx,%edx,4),%edx
801029db:	8d 04 50             	lea    (%eax,%edx,2),%eax
801029de:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
801029e1:	8b 45 bc             	mov    -0x44(%ebp),%eax
801029e4:	89 c2                	mov    %eax,%edx
801029e6:	83 e0 0f             	and    $0xf,%eax
801029e9:	c1 ea 04             	shr    $0x4,%edx
801029ec:	8d 14 92             	lea    (%edx,%edx,4),%edx
801029ef:	8d 04 50             	lea    (%eax,%edx,2),%eax
801029f2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
801029f5:	8b 45 c0             	mov    -0x40(%ebp),%eax
801029f8:	89 c2                	mov    %eax,%edx
801029fa:	83 e0 0f             	and    $0xf,%eax
801029fd:	c1 ea 04             	shr    $0x4,%edx
80102a00:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a03:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a06:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102a09:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102a0c:	89 c2                	mov    %eax,%edx
80102a0e:	83 e0 0f             	and    $0xf,%eax
80102a11:	c1 ea 04             	shr    $0x4,%edx
80102a14:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a17:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a1a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102a1d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102a20:	89 c2                	mov    %eax,%edx
80102a22:	83 e0 0f             	and    $0xf,%eax
80102a25:	c1 ea 04             	shr    $0x4,%edx
80102a28:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a2b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a2e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102a31:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102a34:	89 c2                	mov    %eax,%edx
80102a36:	83 e0 0f             	and    $0xf,%eax
80102a39:	c1 ea 04             	shr    $0x4,%edx
80102a3c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a3f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a42:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102a45:	8b 75 08             	mov    0x8(%ebp),%esi
80102a48:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102a4b:	89 06                	mov    %eax,(%esi)
80102a4d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102a50:	89 46 04             	mov    %eax,0x4(%esi)
80102a53:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102a56:	89 46 08             	mov    %eax,0x8(%esi)
80102a59:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102a5c:	89 46 0c             	mov    %eax,0xc(%esi)
80102a5f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102a62:	89 46 10             	mov    %eax,0x10(%esi)
80102a65:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102a68:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102a6b:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102a72:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102a75:	5b                   	pop    %ebx
80102a76:	5e                   	pop    %esi
80102a77:	5f                   	pop    %edi
80102a78:	5d                   	pop    %ebp
80102a79:	c3                   	ret    
80102a7a:	66 90                	xchg   %ax,%ax
80102a7c:	66 90                	xchg   %ax,%ax
80102a7e:	66 90                	xchg   %ax,%ax

80102a80 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102a80:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102a86:	85 c9                	test   %ecx,%ecx
80102a88:	0f 8e 8a 00 00 00    	jle    80102b18 <install_trans+0x98>
{
80102a8e:	55                   	push   %ebp
80102a8f:	89 e5                	mov    %esp,%ebp
80102a91:	57                   	push   %edi
80102a92:	56                   	push   %esi
80102a93:	53                   	push   %ebx
  for (tail = 0; tail < log.lh.n; tail++) {
80102a94:	31 db                	xor    %ebx,%ebx
{
80102a96:	83 ec 0c             	sub    $0xc,%esp
80102a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102aa0:	a1 14 22 11 80       	mov    0x80112214,%eax
80102aa5:	83 ec 08             	sub    $0x8,%esp
80102aa8:	01 d8                	add    %ebx,%eax
80102aaa:	83 c0 01             	add    $0x1,%eax
80102aad:	50                   	push   %eax
80102aae:	ff 35 24 22 11 80    	pushl  0x80112224
80102ab4:	e8 07 d6 ff ff       	call   801000c0 <bread>
80102ab9:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102abb:	58                   	pop    %eax
80102abc:	5a                   	pop    %edx
80102abd:	ff 34 9d 2c 22 11 80 	pushl  -0x7feeddd4(,%ebx,4)
80102ac4:	ff 35 24 22 11 80    	pushl  0x80112224
  for (tail = 0; tail < log.lh.n; tail++) {
80102aca:	83 c3 01             	add    $0x1,%ebx
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102acd:	e8 ee d5 ff ff       	call   801000c0 <bread>
80102ad2:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ad4:	8d 47 18             	lea    0x18(%edi),%eax
80102ad7:	83 c4 0c             	add    $0xc,%esp
80102ada:	68 00 02 00 00       	push   $0x200
80102adf:	50                   	push   %eax
80102ae0:	8d 46 18             	lea    0x18(%esi),%eax
80102ae3:	50                   	push   %eax
80102ae4:	e8 b7 22 00 00       	call   80104da0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102ae9:	89 34 24             	mov    %esi,(%esp)
80102aec:	e8 af d6 ff ff       	call   801001a0 <bwrite>
    brelse(lbuf);
80102af1:	89 3c 24             	mov    %edi,(%esp)
80102af4:	e8 d7 d6 ff ff       	call   801001d0 <brelse>
    brelse(dbuf);
80102af9:	89 34 24             	mov    %esi,(%esp)
80102afc:	e8 cf d6 ff ff       	call   801001d0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102b01:	83 c4 10             	add    $0x10,%esp
80102b04:	39 1d 28 22 11 80    	cmp    %ebx,0x80112228
80102b0a:	7f 94                	jg     80102aa0 <install_trans+0x20>
  }
}
80102b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102b0f:	5b                   	pop    %ebx
80102b10:	5e                   	pop    %esi
80102b11:	5f                   	pop    %edi
80102b12:	5d                   	pop    %ebp
80102b13:	c3                   	ret    
80102b14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102b18:	f3 c3                	repz ret 
80102b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102b20 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102b20:	55                   	push   %ebp
80102b21:	89 e5                	mov    %esp,%ebp
80102b23:	53                   	push   %ebx
80102b24:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102b27:	ff 35 14 22 11 80    	pushl  0x80112214
80102b2d:	ff 35 24 22 11 80    	pushl  0x80112224
80102b33:	e8 88 d5 ff ff       	call   801000c0 <bread>
80102b38:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102b3a:	a1 28 22 11 80       	mov    0x80112228,%eax
  for (i = 0; i < log.lh.n; i++) {
80102b3f:	83 c4 10             	add    $0x10,%esp
  hb->n = log.lh.n;
80102b42:	89 43 18             	mov    %eax,0x18(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102b45:	a1 28 22 11 80       	mov    0x80112228,%eax
80102b4a:	85 c0                	test   %eax,%eax
80102b4c:	7e 18                	jle    80102b66 <write_head+0x46>
80102b4e:	31 d2                	xor    %edx,%edx
    hb->block[i] = log.lh.block[i];
80102b50:	8b 0c 95 2c 22 11 80 	mov    -0x7feeddd4(,%edx,4),%ecx
80102b57:	89 4c 93 1c          	mov    %ecx,0x1c(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102b5b:	83 c2 01             	add    $0x1,%edx
80102b5e:	39 15 28 22 11 80    	cmp    %edx,0x80112228
80102b64:	7f ea                	jg     80102b50 <write_head+0x30>
  }
  bwrite(buf);
80102b66:	83 ec 0c             	sub    $0xc,%esp
80102b69:	53                   	push   %ebx
80102b6a:	e8 31 d6 ff ff       	call   801001a0 <bwrite>
  brelse(buf);
80102b6f:	89 1c 24             	mov    %ebx,(%esp)
80102b72:	e8 59 d6 ff ff       	call   801001d0 <brelse>
}
80102b77:	83 c4 10             	add    $0x10,%esp
80102b7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b7d:	c9                   	leave  
80102b7e:	c3                   	ret    
80102b7f:	90                   	nop

80102b80 <initlog>:
{
80102b80:	55                   	push   %ebp
80102b81:	89 e5                	mov    %esp,%ebp
80102b83:	53                   	push   %ebx
80102b84:	83 ec 2c             	sub    $0x2c,%esp
80102b87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102b8a:	68 3c 7e 10 80       	push   $0x80107e3c
80102b8f:	68 e0 21 11 80       	push   $0x801121e0
80102b94:	e8 27 1f 00 00       	call   80104ac0 <initlock>
  readsb(dev, &sb);
80102b99:	58                   	pop    %eax
80102b9a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102b9d:	5a                   	pop    %edx
80102b9e:	50                   	push   %eax
80102b9f:	53                   	push   %ebx
80102ba0:	e8 db e7 ff ff       	call   80101380 <readsb>
  log.size = sb.nlog;
80102ba5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102bab:	59                   	pop    %ecx
  log.dev = dev;
80102bac:	89 1d 24 22 11 80    	mov    %ebx,0x80112224
  log.size = sb.nlog;
80102bb2:	89 15 18 22 11 80    	mov    %edx,0x80112218
  log.start = sb.logstart;
80102bb8:	a3 14 22 11 80       	mov    %eax,0x80112214
  struct buf *buf = bread(log.dev, log.start);
80102bbd:	5a                   	pop    %edx
80102bbe:	50                   	push   %eax
80102bbf:	53                   	push   %ebx
80102bc0:	e8 fb d4 ff ff       	call   801000c0 <bread>
  log.lh.n = lh->n;
80102bc5:	8b 58 18             	mov    0x18(%eax),%ebx
  for (i = 0; i < log.lh.n; i++) {
80102bc8:	83 c4 10             	add    $0x10,%esp
80102bcb:	85 db                	test   %ebx,%ebx
  log.lh.n = lh->n;
80102bcd:	89 1d 28 22 11 80    	mov    %ebx,0x80112228
  for (i = 0; i < log.lh.n; i++) {
80102bd3:	7e 1c                	jle    80102bf1 <initlog+0x71>
80102bd5:	c1 e3 02             	shl    $0x2,%ebx
80102bd8:	31 d2                	xor    %edx,%edx
80102bda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    log.lh.block[i] = lh->block[i];
80102be0:	8b 4c 10 1c          	mov    0x1c(%eax,%edx,1),%ecx
80102be4:	83 c2 04             	add    $0x4,%edx
80102be7:	89 8a 28 22 11 80    	mov    %ecx,-0x7feeddd8(%edx)
  for (i = 0; i < log.lh.n; i++) {
80102bed:	39 d3                	cmp    %edx,%ebx
80102bef:	75 ef                	jne    80102be0 <initlog+0x60>
  brelse(buf);
80102bf1:	83 ec 0c             	sub    $0xc,%esp
80102bf4:	50                   	push   %eax
80102bf5:	e8 d6 d5 ff ff       	call   801001d0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102bfa:	e8 81 fe ff ff       	call   80102a80 <install_trans>
  log.lh.n = 0;
80102bff:	c7 05 28 22 11 80 00 	movl   $0x0,0x80112228
80102c06:	00 00 00 
  write_head(); // clear the log
80102c09:	e8 12 ff ff ff       	call   80102b20 <write_head>
}
80102c0e:	83 c4 10             	add    $0x10,%esp
80102c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c14:	c9                   	leave  
80102c15:	c3                   	ret    
80102c16:	8d 76 00             	lea    0x0(%esi),%esi
80102c19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c20 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102c20:	55                   	push   %ebp
80102c21:	89 e5                	mov    %esp,%ebp
80102c23:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102c26:	68 e0 21 11 80       	push   $0x801121e0
80102c2b:	e8 b0 1e 00 00       	call   80104ae0 <acquire>
80102c30:	83 c4 10             	add    $0x10,%esp
80102c33:	eb 18                	jmp    80102c4d <begin_op+0x2d>
80102c35:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102c38:	83 ec 08             	sub    $0x8,%esp
80102c3b:	68 e0 21 11 80       	push   $0x801121e0
80102c40:	68 e0 21 11 80       	push   $0x801121e0
80102c45:	e8 36 12 00 00       	call   80103e80 <sleep>
80102c4a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102c4d:	a1 20 22 11 80       	mov    0x80112220,%eax
80102c52:	85 c0                	test   %eax,%eax
80102c54:	75 e2                	jne    80102c38 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102c56:	a1 1c 22 11 80       	mov    0x8011221c,%eax
80102c5b:	8b 15 28 22 11 80    	mov    0x80112228,%edx
80102c61:	83 c0 01             	add    $0x1,%eax
80102c64:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102c67:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102c6a:	83 fa 1e             	cmp    $0x1e,%edx
80102c6d:	7f c9                	jg     80102c38 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102c6f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102c72:	a3 1c 22 11 80       	mov    %eax,0x8011221c
      release(&log.lock);
80102c77:	68 e0 21 11 80       	push   $0x801121e0
80102c7c:	e8 1f 20 00 00       	call   80104ca0 <release>
      break;
    }
  }
}
80102c81:	83 c4 10             	add    $0x10,%esp
80102c84:	c9                   	leave  
80102c85:	c3                   	ret    
80102c86:	8d 76 00             	lea    0x0(%esi),%esi
80102c89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c90 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102c90:	55                   	push   %ebp
80102c91:	89 e5                	mov    %esp,%ebp
80102c93:	57                   	push   %edi
80102c94:	56                   	push   %esi
80102c95:	53                   	push   %ebx
80102c96:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102c99:	68 e0 21 11 80       	push   $0x801121e0
80102c9e:	e8 3d 1e 00 00       	call   80104ae0 <acquire>
  log.outstanding -= 1;
80102ca3:	a1 1c 22 11 80       	mov    0x8011221c,%eax
  if(log.committing)
80102ca8:	8b 35 20 22 11 80    	mov    0x80112220,%esi
80102cae:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102cb1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  if(log.committing)
80102cb4:	85 f6                	test   %esi,%esi
  log.outstanding -= 1;
80102cb6:	89 1d 1c 22 11 80    	mov    %ebx,0x8011221c
  if(log.committing)
80102cbc:	0f 85 1a 01 00 00    	jne    80102ddc <end_op+0x14c>
    panic("log.committing");
  if(log.outstanding == 0){
80102cc2:	85 db                	test   %ebx,%ebx
80102cc4:	0f 85 ee 00 00 00    	jne    80102db8 <end_op+0x128>
    log.committing = 1;
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
  }
  release(&log.lock);
80102cca:	83 ec 0c             	sub    $0xc,%esp
    log.committing = 1;
80102ccd:	c7 05 20 22 11 80 01 	movl   $0x1,0x80112220
80102cd4:	00 00 00 
  release(&log.lock);
80102cd7:	68 e0 21 11 80       	push   $0x801121e0
80102cdc:	e8 bf 1f 00 00       	call   80104ca0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102ce1:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102ce7:	83 c4 10             	add    $0x10,%esp
80102cea:	85 c9                	test   %ecx,%ecx
80102cec:	0f 8e 85 00 00 00    	jle    80102d77 <end_op+0xe7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102cf2:	a1 14 22 11 80       	mov    0x80112214,%eax
80102cf7:	83 ec 08             	sub    $0x8,%esp
80102cfa:	01 d8                	add    %ebx,%eax
80102cfc:	83 c0 01             	add    $0x1,%eax
80102cff:	50                   	push   %eax
80102d00:	ff 35 24 22 11 80    	pushl  0x80112224
80102d06:	e8 b5 d3 ff ff       	call   801000c0 <bread>
80102d0b:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d0d:	58                   	pop    %eax
80102d0e:	5a                   	pop    %edx
80102d0f:	ff 34 9d 2c 22 11 80 	pushl  -0x7feeddd4(,%ebx,4)
80102d16:	ff 35 24 22 11 80    	pushl  0x80112224
  for (tail = 0; tail < log.lh.n; tail++) {
80102d1c:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d1f:	e8 9c d3 ff ff       	call   801000c0 <bread>
80102d24:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102d26:	8d 40 18             	lea    0x18(%eax),%eax
80102d29:	83 c4 0c             	add    $0xc,%esp
80102d2c:	68 00 02 00 00       	push   $0x200
80102d31:	50                   	push   %eax
80102d32:	8d 46 18             	lea    0x18(%esi),%eax
80102d35:	50                   	push   %eax
80102d36:	e8 65 20 00 00       	call   80104da0 <memmove>
    bwrite(to);  // write the log
80102d3b:	89 34 24             	mov    %esi,(%esp)
80102d3e:	e8 5d d4 ff ff       	call   801001a0 <bwrite>
    brelse(from);
80102d43:	89 3c 24             	mov    %edi,(%esp)
80102d46:	e8 85 d4 ff ff       	call   801001d0 <brelse>
    brelse(to);
80102d4b:	89 34 24             	mov    %esi,(%esp)
80102d4e:	e8 7d d4 ff ff       	call   801001d0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102d53:	83 c4 10             	add    $0x10,%esp
80102d56:	3b 1d 28 22 11 80    	cmp    0x80112228,%ebx
80102d5c:	7c 94                	jl     80102cf2 <end_op+0x62>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102d5e:	e8 bd fd ff ff       	call   80102b20 <write_head>
    install_trans(); // Now install writes to home locations
80102d63:	e8 18 fd ff ff       	call   80102a80 <install_trans>
    log.lh.n = 0;
80102d68:	c7 05 28 22 11 80 00 	movl   $0x0,0x80112228
80102d6f:	00 00 00 
    write_head();    // Erase the transaction from the log
80102d72:	e8 a9 fd ff ff       	call   80102b20 <write_head>
    acquire(&log.lock);
80102d77:	83 ec 0c             	sub    $0xc,%esp
80102d7a:	68 e0 21 11 80       	push   $0x801121e0
80102d7f:	e8 5c 1d 00 00       	call   80104ae0 <acquire>
    wakeup(&log);
80102d84:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
    log.committing = 0;
80102d8b:	c7 05 20 22 11 80 00 	movl   $0x0,0x80112220
80102d92:	00 00 00 
    wakeup(&log);
80102d95:	e8 46 13 00 00       	call   801040e0 <wakeup>
    release(&log.lock);
80102d9a:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102da1:	e8 fa 1e 00 00       	call   80104ca0 <release>
80102da6:	83 c4 10             	add    $0x10,%esp
}
80102da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dac:	5b                   	pop    %ebx
80102dad:	5e                   	pop    %esi
80102dae:	5f                   	pop    %edi
80102daf:	5d                   	pop    %ebp
80102db0:	c3                   	ret    
80102db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&log);
80102db8:	83 ec 0c             	sub    $0xc,%esp
80102dbb:	68 e0 21 11 80       	push   $0x801121e0
80102dc0:	e8 1b 13 00 00       	call   801040e0 <wakeup>
  release(&log.lock);
80102dc5:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102dcc:	e8 cf 1e 00 00       	call   80104ca0 <release>
80102dd1:	83 c4 10             	add    $0x10,%esp
}
80102dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dd7:	5b                   	pop    %ebx
80102dd8:	5e                   	pop    %esi
80102dd9:	5f                   	pop    %edi
80102dda:	5d                   	pop    %ebp
80102ddb:	c3                   	ret    
    panic("log.committing");
80102ddc:	83 ec 0c             	sub    $0xc,%esp
80102ddf:	68 40 7e 10 80       	push   $0x80107e40
80102de4:	e8 87 d5 ff ff       	call   80100370 <panic>
80102de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102df0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102df0:	55                   	push   %ebp
80102df1:	89 e5                	mov    %esp,%ebp
80102df3:	53                   	push   %ebx
80102df4:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102df7:	8b 15 28 22 11 80    	mov    0x80112228,%edx
{
80102dfd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102e00:	83 fa 1d             	cmp    $0x1d,%edx
80102e03:	0f 8f 9d 00 00 00    	jg     80102ea6 <log_write+0xb6>
80102e09:	a1 18 22 11 80       	mov    0x80112218,%eax
80102e0e:	83 e8 01             	sub    $0x1,%eax
80102e11:	39 c2                	cmp    %eax,%edx
80102e13:	0f 8d 8d 00 00 00    	jge    80102ea6 <log_write+0xb6>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102e19:	a1 1c 22 11 80       	mov    0x8011221c,%eax
80102e1e:	85 c0                	test   %eax,%eax
80102e20:	0f 8e 8d 00 00 00    	jle    80102eb3 <log_write+0xc3>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102e26:	83 ec 0c             	sub    $0xc,%esp
80102e29:	68 e0 21 11 80       	push   $0x801121e0
80102e2e:	e8 ad 1c 00 00       	call   80104ae0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102e33:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102e39:	83 c4 10             	add    $0x10,%esp
80102e3c:	83 f9 00             	cmp    $0x0,%ecx
80102e3f:	7e 57                	jle    80102e98 <log_write+0xa8>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102e41:	8b 53 08             	mov    0x8(%ebx),%edx
  for (i = 0; i < log.lh.n; i++) {
80102e44:	31 c0                	xor    %eax,%eax
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102e46:	3b 15 2c 22 11 80    	cmp    0x8011222c,%edx
80102e4c:	75 0b                	jne    80102e59 <log_write+0x69>
80102e4e:	eb 38                	jmp    80102e88 <log_write+0x98>
80102e50:	39 14 85 2c 22 11 80 	cmp    %edx,-0x7feeddd4(,%eax,4)
80102e57:	74 2f                	je     80102e88 <log_write+0x98>
  for (i = 0; i < log.lh.n; i++) {
80102e59:	83 c0 01             	add    $0x1,%eax
80102e5c:	39 c1                	cmp    %eax,%ecx
80102e5e:	75 f0                	jne    80102e50 <log_write+0x60>
      break;
  }
  log.lh.block[i] = b->blockno;
80102e60:	89 14 85 2c 22 11 80 	mov    %edx,-0x7feeddd4(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
80102e67:	83 c0 01             	add    $0x1,%eax
80102e6a:	a3 28 22 11 80       	mov    %eax,0x80112228
  b->flags |= B_DIRTY; // prevent eviction
80102e6f:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102e72:	c7 45 08 e0 21 11 80 	movl   $0x801121e0,0x8(%ebp)
}
80102e79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e7c:	c9                   	leave  
  release(&log.lock);
80102e7d:	e9 1e 1e 00 00       	jmp    80104ca0 <release>
80102e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80102e88:	89 14 85 2c 22 11 80 	mov    %edx,-0x7feeddd4(,%eax,4)
80102e8f:	eb de                	jmp    80102e6f <log_write+0x7f>
80102e91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e98:	8b 43 08             	mov    0x8(%ebx),%eax
80102e9b:	a3 2c 22 11 80       	mov    %eax,0x8011222c
  if (i == log.lh.n)
80102ea0:	75 cd                	jne    80102e6f <log_write+0x7f>
80102ea2:	31 c0                	xor    %eax,%eax
80102ea4:	eb c1                	jmp    80102e67 <log_write+0x77>
    panic("too big a transaction");
80102ea6:	83 ec 0c             	sub    $0xc,%esp
80102ea9:	68 4f 7e 10 80       	push   $0x80107e4f
80102eae:	e8 bd d4 ff ff       	call   80100370 <panic>
    panic("log_write outside of trans");
80102eb3:	83 ec 0c             	sub    $0xc,%esp
80102eb6:	68 65 7e 10 80       	push   $0x80107e65
80102ebb:	e8 b0 d4 ff ff       	call   80100370 <panic>

80102ec0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102ec0:	55                   	push   %ebp
80102ec1:	89 e5                	mov    %esp,%ebp
80102ec3:	53                   	push   %ebx
80102ec4:	83 ec 04             	sub    $0x4,%esp
  int cpuid = cpunum();
80102ec7:	e8 54 f8 ff ff       	call   80102720 <cpunum>
80102ecc:	89 c3                	mov    %eax,%ebx
  cprintf("cpu%d apicid = %d: starting\n", cpuid,cpu->apicid);
80102ece:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80102ed4:	83 ec 04             	sub    $0x4,%esp
80102ed7:	0f b6 00             	movzbl (%eax),%eax
80102eda:	50                   	push   %eax
80102edb:	53                   	push   %ebx
80102edc:	68 80 7e 10 80       	push   $0x80107e80
80102ee1:	e8 5a d7 ff ff       	call   80100640 <cprintf>
  idtinit();       // load idt register
80102ee6:	e8 05 32 00 00       	call   801060f0 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80102eeb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102ef2:	b8 01 00 00 00       	mov    $0x1,%eax
80102ef7:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler(cpuid);     // start running processes
80102efe:	89 1c 24             	mov    %ebx,(%esp)
80102f01:	e8 9a 0d 00 00       	call   80103ca0 <scheduler>
80102f06:	8d 76 00             	lea    0x0(%esi),%esi
80102f09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102f10 <mpenter>:
{
80102f10:	55                   	push   %ebp
80102f11:	89 e5                	mov    %esp,%ebp
80102f13:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102f16:	e8 65 43 00 00       	call   80107280 <switchkvm>
  seginit();
80102f1b:	e8 f0 41 00 00       	call   80107110 <seginit>
  lapicinit();
80102f20:	e8 fb f6 ff ff       	call   80102620 <lapicinit>
  mpmain();
80102f25:	e8 96 ff ff ff       	call   80102ec0 <mpmain>
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
80102f47:	68 48 83 11 80       	push   $0x80118348
80102f4c:	e8 8f f4 ff ff       	call   801023e0 <kinit1>
  kvmalloc();      // kernel page table
80102f51:	e8 0a 43 00 00       	call   80107260 <kvmalloc>
  mpinit();        // detect other processors
80102f56:	e8 b5 01 00 00       	call   80103110 <mpinit>
  lapicinit();     // interrupt controller
80102f5b:	e8 c0 f6 ff ff       	call   80102620 <lapicinit>
  seginit();       // segment descriptors
80102f60:	e8 ab 41 00 00       	call   80107110 <seginit>
  cprintf("\ncpu%d: starting xv6\n----------------------------\nzzx is programming xv6\n----------------------------\n", cpunum());
80102f65:	e8 b6 f7 ff ff       	call   80102720 <cpunum>
80102f6a:	5a                   	pop    %edx
80102f6b:	59                   	pop    %ecx
80102f6c:	50                   	push   %eax
80102f6d:	68 a0 7e 10 80       	push   $0x80107ea0
80102f72:	e8 c9 d6 ff ff       	call   80100640 <cprintf>
  picinit();       // another interrupt controller
80102f77:	e8 b4 03 00 00       	call   80103330 <picinit>
  ioapicinit();    // another interrupt controller
80102f7c:	e8 6f f2 ff ff       	call   801021f0 <ioapicinit>
  consoleinit();   // console hardware
80102f81:	e8 1a da ff ff       	call   801009a0 <consoleinit>
  uartinit();      // serial port
80102f86:	e8 55 34 00 00       	call   801063e0 <uartinit>
  pinit();         // process table
80102f8b:	e8 b0 09 00 00       	call   80103940 <pinit>
  tvinit();        // trap vectors
80102f90:	e8 db 30 00 00       	call   80106070 <tvinit>
  binit();         // buffer cache
80102f95:	e8 a6 d0 ff ff       	call   80100040 <binit>
  fileinit();      // file table
80102f9a:	e8 91 dd ff ff       	call   80100d30 <fileinit>
  ideinit();       // disk
80102f9f:	e8 2c f0 ff ff       	call   80101fd0 <ideinit>
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
80102fc7:	e8 d4 1d 00 00       	call   80104da0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102fcc:	69 05 60 3a 11 80 bc 	imul   $0xbc,0x80113a60,%eax
80102fd3:	00 00 00 
80102fd6:	83 c4 10             	add    $0x10,%esp
80102fd9:	05 e0 22 11 80       	add    $0x801122e0,%eax
80102fde:	3d e0 22 11 80       	cmp    $0x801122e0,%eax
80102fe3:	76 7e                	jbe    80103063 <main+0x133>
80102fe5:	bb e0 22 11 80       	mov    $0x801122e0,%ebx
80102fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(c == cpus+cpunum())  // We've started already.
80102ff0:	e8 2b f7 ff ff       	call   80102720 <cpunum>
80102ff5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80102ffb:	05 e0 22 11 80       	add    $0x801122e0,%eax
80103000:	39 c3                	cmp    %eax,%ebx
80103002:	74 46                	je     8010304a <main+0x11a>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103004:	e8 a7 f4 ff ff       	call   801024b0 <kalloc>
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
80103033:	e8 c8 f7 ff ff       	call   80102800 <lapicstartap>
80103038:	83 c4 10             	add    $0x10,%esp
8010303b:	90                   	nop
8010303c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103040:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
80103046:	85 c0                	test   %eax,%eax
80103048:	74 f6                	je     80103040 <main+0x110>
  for(c = cpus; c < cpus+ncpu; c++){
8010304a:	69 05 60 3a 11 80 bc 	imul   $0xbc,0x80113a60,%eax
80103051:	00 00 00 
80103054:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
8010305a:	05 e0 22 11 80       	add    $0x801122e0,%eax
8010305f:	39 c3                	cmp    %eax,%ebx
80103061:	72 8d                	jb     80102ff0 <main+0xc0>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103063:	83 ec 08             	sub    $0x8,%esp
80103066:	68 00 00 00 8e       	push   $0x8e000000
8010306b:	68 00 00 40 80       	push   $0x80400000
80103070:	e8 db f3 ff ff       	call   80102450 <kinit2>
  userinit();      // first user process
80103075:	e8 06 09 00 00       	call   80103980 <userinit>
  mpmain();        // finish this processor's setup
8010307a:	e8 41 fe ff ff       	call   80102ec0 <mpmain>
    timerinit();   // uniprocessor timer
8010307f:	e8 8c 2f 00 00       	call   80106010 <timerinit>
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
801030be:	68 07 7f 10 80       	push   $0x80107f07
801030c3:	56                   	push   %esi
801030c4:	e8 77 1c 00 00       	call   80104d40 <memcmp>
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
80103178:	68 0c 7f 10 80       	push   $0x80107f0c
8010317d:	56                   	push   %esi
8010317e:	e8 bd 1b 00 00       	call   80104d40 <memcmp>
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
8010321c:	ff 24 95 14 7f 10 80 	jmp    *-0x7fef80ec(,%edx,4)
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
80103238:	c7 05 60 3a 11 80 01 	movl   $0x1,0x80113a60
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
80103260:	8b 15 60 3a 11 80    	mov    0x80113a60,%edx
80103266:	83 fa 1f             	cmp    $0x1f,%edx
80103269:	7f 19                	jg     80103284 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010326b:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
8010326f:	69 da bc 00 00 00    	imul   $0xbc,%edx,%ebx
        ncpu++;
80103275:	83 c2 01             	add    $0x1,%edx
80103278:	89 15 60 3a 11 80    	mov    %edx,0x80113a60
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
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
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
80103401:	e8 aa f0 ff ff       	call   801024b0 <kalloc>
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
8010348b:	68 28 7f 10 80       	push   $0x80107f28
80103490:	50                   	push   %eax
80103491:	e8 2a 16 00 00       	call   80104ac0 <initlock>
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
801034ef:	e8 ec 15 00 00       	call   80104ae0 <acquire>
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
8010350f:	e8 cc 0b 00 00       	call   801040e0 <wakeup>
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
80103534:	e9 67 17 00 00       	jmp    80104ca0 <release>
80103539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&p->nwrite);
80103540:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103546:	83 ec 0c             	sub    $0xc,%esp
    p->readopen = 0;
80103549:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103550:	00 00 00 
    wakeup(&p->nwrite);
80103553:	50                   	push   %eax
80103554:	e8 87 0b 00 00       	call   801040e0 <wakeup>
80103559:	83 c4 10             	add    $0x10,%esp
8010355c:	eb b9                	jmp    80103517 <pipeclose+0x37>
8010355e:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80103560:	83 ec 0c             	sub    $0xc,%esp
80103563:	53                   	push   %ebx
80103564:	e8 37 17 00 00       	call   80104ca0 <release>
    kfree((char*)p);
80103569:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010356c:	83 c4 10             	add    $0x10,%esp
}
8010356f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103572:	5b                   	pop    %ebx
80103573:	5e                   	pop    %esi
80103574:	5d                   	pop    %ebp
    kfree((char*)p);
80103575:	e9 86 ed ff ff       	jmp    80102300 <kfree>
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
8010358d:	e8 4e 15 00 00       	call   80104ae0 <acquire>
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
801035e7:	8b 42 28             	mov    0x28(%edx),%eax
801035ea:	85 c0                	test   %eax,%eax
801035ec:	74 25                	je     80103613 <pipewrite+0x93>
801035ee:	e9 95 00 00 00       	jmp    80103688 <pipewrite+0x108>
801035f3:	90                   	nop
801035f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801035f8:	8b 87 3c 02 00 00    	mov    0x23c(%edi),%eax
801035fe:	85 c0                	test   %eax,%eax
80103600:	0f 84 82 00 00 00    	je     80103688 <pipewrite+0x108>
80103606:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010360c:	8b 40 28             	mov    0x28(%eax),%eax
8010360f:	85 c0                	test   %eax,%eax
80103611:	75 75                	jne    80103688 <pipewrite+0x108>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103613:	83 ec 0c             	sub    $0xc,%esp
80103616:	56                   	push   %esi
80103617:	e8 c4 0a 00 00       	call   801040e0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010361c:	59                   	pop    %ecx
8010361d:	58                   	pop    %eax
8010361e:	57                   	push   %edi
8010361f:	53                   	push   %ebx
80103620:	e8 5b 08 00 00       	call   80103e80 <sleep>
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
80103670:	e8 6b 0a 00 00       	call   801040e0 <wakeup>
  release(&p->lock);
80103675:	89 3c 24             	mov    %edi,(%esp)
80103678:	e8 23 16 00 00       	call   80104ca0 <release>
  return n;
8010367d:	83 c4 10             	add    $0x10,%esp
80103680:	8b 45 10             	mov    0x10(%ebp),%eax
80103683:	eb 14                	jmp    80103699 <pipewrite+0x119>
80103685:	8d 76 00             	lea    0x0(%esi),%esi
        release(&p->lock);
80103688:	83 ec 0c             	sub    $0xc,%esp
8010368b:	57                   	push   %edi
8010368c:	e8 0f 16 00 00       	call   80104ca0 <release>
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
801036c0:	e8 1b 14 00 00       	call   80104ae0 <acquire>
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
801036ea:	8b 58 28             	mov    0x28(%eax),%ebx
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
80103714:	8b 48 28             	mov    0x28(%eax),%ecx
80103717:	85 c9                	test   %ecx,%ecx
80103719:	0f 85 89 00 00 00    	jne    801037a8 <piperead+0xf8>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010371f:	83 ec 08             	sub    $0x8,%esp
80103722:	56                   	push   %esi
80103723:	53                   	push   %ebx
80103724:	e8 57 07 00 00       	call   80103e80 <sleep>
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
8010377f:	e8 5c 09 00 00       	call   801040e0 <wakeup>
  release(&p->lock);
80103784:	89 34 24             	mov    %esi,(%esp)
80103787:	e8 14 15 00 00       	call   80104ca0 <release>
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
801037b1:	e8 ea 14 00 00       	call   80104ca0 <release>
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
// Must hold ptable[0].lock.
static struct proc*
allocproc(int ptableIndex)
{
801037d0:	69 d0 38 20 00 00    	imul   $0x2038,%eax,%edx
801037d6:	55                   	push   %ebp
801037d7:	89 e5                	mov    %esp,%ebp
801037d9:	56                   	push   %esi
801037da:	53                   	push   %ebx
  struct proc *p;
  char *sp;
  

  for(p = ptable[ptableIndex].proc; p < &ptable[ptableIndex].proc[NPROC]; p++)
801037db:	8d 9a b8 3a 11 80    	lea    -0x7feec548(%edx),%ebx
801037e1:	81 c2 b8 5a 11 80    	add    $0x80115ab8,%edx
801037e7:	39 da                	cmp    %ebx,%edx
801037e9:	77 13                	ja     801037fe <allocproc+0x2e>
801037eb:	e9 c0 00 00 00       	jmp    801038b0 <allocproc+0xe0>
801037f0:	81 c3 00 01 00 00    	add    $0x100,%ebx
801037f6:	39 da                	cmp    %ebx,%edx
801037f8:	0f 86 b2 00 00 00    	jbe    801038b0 <allocproc+0xe0>
    if(p->state == UNUSED)
801037fe:	8b 4b 0c             	mov    0xc(%ebx),%ecx
80103801:	85 c9                	test   %ecx,%ecx
80103803:	75 eb                	jne    801037f0 <allocproc+0x20>
      goto found;
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103805:	8b 15 08 b0 10 80    	mov    0x8010b008,%edx
  p->state = EMBRYO;
8010380b:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103812:	8d 4a 01             	lea    0x1(%edx),%ecx
80103815:	89 53 10             	mov    %edx,0x10(%ebx)
80103818:	8d 93 84 00 00 00    	lea    0x84(%ebx),%edx
8010381e:	89 0d 08 b0 10 80    	mov    %ecx,0x8010b008
80103824:	8d 8b fc 00 00 00    	lea    0xfc(%ebx),%ecx
8010382a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  for (int i = 0; i < 10; ++i)
  {
    p->vm[i].next = -1;
80103830:	c7 42 04 ff ff ff ff 	movl   $0xffffffff,0x4(%edx)
    p->vm[i].length = 0;
80103837:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
8010383d:	83 c2 0c             	add    $0xc,%edx
  for (int i = 0; i < 10; ++i)
80103840:	39 ca                	cmp    %ecx,%edx
80103842:	75 ec                	jne    80103830 <allocproc+0x60>
  }
  p->vm[0].next = 0;
80103844:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
8010384b:	00 00 00 
8010384e:	89 c6                	mov    %eax,%esi

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103850:	e8 5b ec ff ff       	call   801024b0 <kalloc>
80103855:	85 c0                	test   %eax,%eax
80103857:	89 43 08             	mov    %eax,0x8(%ebx)
8010385a:	74 5f                	je     801038bb <allocproc+0xeb>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010385c:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
80103862:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103865:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
8010386a:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint*)sp = (uint)trapret;
8010386d:	c7 40 14 5e 60 10 80 	movl   $0x8010605e,0x14(%eax)
  p->context = (struct context*)sp;
80103874:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103877:	6a 14                	push   $0x14
80103879:	6a 00                	push   $0x0
8010387b:	50                   	push   %eax
8010387c:	e8 6f 14 00 00       	call   80104cf0 <memset>
  p->cpuid = ptableIndex;
80103881:	89 73 14             	mov    %esi,0x14(%ebx)
  p->context->eip = (uint)forkret;
80103884:	8b 43 20             	mov    0x20(%ebx),%eax
  
  ptable[ptableIndex].amount += 1;

  return p;
80103887:	83 c4 10             	add    $0x10,%esp
  ptable[ptableIndex].amount += 1;
8010388a:	69 f6 38 20 00 00    	imul   $0x2038,%esi,%esi
  p->context->eip = (uint)forkret;
80103890:	c7 40 10 d0 38 10 80 	movl   $0x801038d0,0x10(%eax)
}
80103897:	89 d8                	mov    %ebx,%eax
  ptable[ptableIndex].amount += 1;
80103899:	83 86 80 3a 11 80 01 	addl   $0x1,-0x7feec580(%esi)
}
801038a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038a3:	5b                   	pop    %ebx
801038a4:	5e                   	pop    %esi
801038a5:	5d                   	pop    %ebp
801038a6:	c3                   	ret    
801038a7:	89 f6                	mov    %esi,%esi
801038a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  return 0;
801038b0:	31 db                	xor    %ebx,%ebx
}
801038b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038b5:	89 d8                	mov    %ebx,%eax
801038b7:	5b                   	pop    %ebx
801038b8:	5e                   	pop    %esi
801038b9:	5d                   	pop    %ebp
801038ba:	c3                   	ret    
    p->state = UNUSED;
801038bb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801038c2:	31 db                	xor    %ebx,%ebx
801038c4:	eb ec                	jmp    801038b2 <allocproc+0xe2>
801038c6:	8d 76 00             	lea    0x0(%esi),%esi
801038c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801038d0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801038d0:	55                   	push   %ebp
801038d1:	89 e5                	mov    %esp,%ebp
801038d3:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable[0].lock from scheduler.
  release(&ptable[proc->cpuid].lock);
801038d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801038dc:	69 40 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%eax
801038e3:	05 84 3a 11 80       	add    $0x80113a84,%eax
801038e8:	50                   	push   %eax
801038e9:	e8 b2 13 00 00       	call   80104ca0 <release>

  if (first) {
801038ee:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801038f3:	83 c4 10             	add    $0x10,%esp
801038f6:	85 c0                	test   %eax,%eax
801038f8:	75 06                	jne    80103900 <forkret+0x30>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801038fa:	c9                   	leave  
801038fb:	c3                   	ret    
801038fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iinit(ROOTDEV);
80103900:	83 ec 0c             	sub    $0xc,%esp
    first = 0;
80103903:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
8010390a:	00 00 00 
    iinit(ROOTDEV);
8010390d:	6a 01                	push   $0x1
8010390f:	e8 2c db ff ff       	call   80101440 <iinit>
    initlog(ROOTDEV);
80103914:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010391b:	e8 60 f2 ff ff       	call   80102b80 <initlog>
80103920:	83 c4 10             	add    $0x10,%esp
}
80103923:	c9                   	leave  
80103924:	c3                   	ret    
80103925:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103929:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103930 <getcpuid>:
{
80103930:	55                   	push   %ebp
80103931:	89 e5                	mov    %esp,%ebp
}
80103933:	5d                   	pop    %ebp
  return cpunum();
80103934:	e9 e7 ed ff ff       	jmp    80102720 <cpunum>
80103939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103940 <pinit>:
{
80103940:	55                   	push   %ebp
80103941:	89 e5                	mov    %esp,%ebp
80103943:	83 ec 10             	sub    $0x10,%esp
    ptable[i].amount = 0;
80103946:	c7 05 80 3a 11 80 00 	movl   $0x0,0x80113a80
8010394d:	00 00 00 
    initlock(&ptable[i].lock, "ptable");
80103950:	68 2d 7f 10 80       	push   $0x80107f2d
80103955:	68 84 3a 11 80       	push   $0x80113a84
8010395a:	e8 61 11 00 00       	call   80104ac0 <initlock>
8010395f:	58                   	pop    %eax
80103960:	5a                   	pop    %edx
80103961:	68 2d 7f 10 80       	push   $0x80107f2d
80103966:	68 bc 5a 11 80       	push   $0x80115abc
    ptable[i].amount = 0;
8010396b:	c7 05 b8 5a 11 80 00 	movl   $0x0,0x80115ab8
80103972:	00 00 00 
    initlock(&ptable[i].lock, "ptable");
80103975:	e8 46 11 00 00       	call   80104ac0 <initlock>
}
8010397a:	83 c4 10             	add    $0x10,%esp
8010397d:	c9                   	leave  
8010397e:	c3                   	ret    
8010397f:	90                   	nop

80103980 <userinit>:
    if(ptable[i].amount < min){
80103980:	a1 80 3a 11 80       	mov    0x80113a80,%eax
{
80103985:	55                   	push   %ebp
  int min = NPROC + 1;
80103986:	ba 21 00 00 00       	mov    $0x21,%edx
{
8010398b:	89 e5                	mov    %esp,%ebp
8010398d:	56                   	push   %esi
8010398e:	53                   	push   %ebx
  int min = NPROC + 1;
8010398f:	83 f8 21             	cmp    $0x21,%eax
80103992:	0f 4d c2             	cmovge %edx,%eax
  acquire(&ptable[ptableIndex].lock);
80103995:	31 db                	xor    %ebx,%ebx
80103997:	3b 05 b8 5a 11 80    	cmp    0x80115ab8,%eax
8010399d:	0f 9f c3             	setg   %bl
801039a0:	83 ec 0c             	sub    $0xc,%esp
801039a3:	69 f3 38 20 00 00    	imul   $0x2038,%ebx,%esi
801039a9:	81 c6 84 3a 11 80    	add    $0x80113a84,%esi
801039af:	56                   	push   %esi
801039b0:	e8 2b 11 00 00       	call   80104ae0 <acquire>
  p = allocproc(ptableIndex);
801039b5:	89 d8                	mov    %ebx,%eax
801039b7:	e8 14 fe ff ff       	call   801037d0 <allocproc>
801039bc:	89 c3                	mov    %eax,%ebx
  initproc = p;
801039be:	a3 bc b5 10 80       	mov    %eax,0x8010b5bc
  if((p->pgdir = setupkvm()) == 0)
801039c3:	e8 28 38 00 00       	call   801071f0 <setupkvm>
801039c8:	83 c4 10             	add    $0x10,%esp
801039cb:	85 c0                	test   %eax,%eax
801039cd:	89 43 04             	mov    %eax,0x4(%ebx)
801039d0:	0f 84 af 00 00 00    	je     80103a85 <userinit+0x105>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801039d6:	83 ec 04             	sub    $0x4,%esp
801039d9:	68 2c 00 00 00       	push   $0x2c
801039de:	68 60 b4 10 80       	push   $0x8010b460
801039e3:	50                   	push   %eax
801039e4:	e8 57 39 00 00       	call   80107340 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
801039e9:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
801039ec:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801039f2:	6a 4c                	push   $0x4c
801039f4:	6a 00                	push   $0x0
801039f6:	ff 73 1c             	pushl  0x1c(%ebx)
801039f9:	e8 f2 12 00 00       	call   80104cf0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801039fe:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a01:	ba 23 00 00 00       	mov    $0x23,%edx
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a06:	b9 2b 00 00 00       	mov    $0x2b,%ecx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a0b:	83 c4 0c             	add    $0xc,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103a0e:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a12:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a15:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103a19:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a1c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a20:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103a24:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a27:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a2b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103a2f:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a32:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103a39:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a3c:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103a43:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a46:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a4d:	8d 43 70             	lea    0x70(%ebx),%eax
80103a50:	6a 10                	push   $0x10
80103a52:	68 4d 7f 10 80       	push   $0x80107f4d
80103a57:	50                   	push   %eax
80103a58:	e8 73 14 00 00       	call   80104ed0 <safestrcpy>
  p->cwd = namei("/");
80103a5d:	c7 04 24 56 7f 10 80 	movl   $0x80107f56,(%esp)
80103a64:	e8 47 e4 ff ff       	call   80101eb0 <namei>
  p->state = RUNNABLE;
80103a69:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->cwd = namei("/");
80103a70:	89 43 6c             	mov    %eax,0x6c(%ebx)
  release(&ptable[ptableIndex].lock);
80103a73:	89 34 24             	mov    %esi,(%esp)
80103a76:	e8 25 12 00 00       	call   80104ca0 <release>
}
80103a7b:	83 c4 10             	add    $0x10,%esp
80103a7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a81:	5b                   	pop    %ebx
80103a82:	5e                   	pop    %esi
80103a83:	5d                   	pop    %ebp
80103a84:	c3                   	ret    
    panic("userinit: out of memory?");
80103a85:	83 ec 0c             	sub    $0xc,%esp
80103a88:	68 34 7f 10 80       	push   $0x80107f34
80103a8d:	e8 de c8 ff ff       	call   80100370 <panic>
80103a92:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103aa0 <growproc>:
{
80103aa0:	55                   	push   %ebp
80103aa1:	89 e5                	mov    %esp,%ebp
80103aa3:	83 ec 08             	sub    $0x8,%esp
  sz = proc->sz;
80103aa6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80103aad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  sz = proc->sz;
80103ab0:	8b 02                	mov    (%edx),%eax
  if(n > 0){
80103ab2:	83 f9 00             	cmp    $0x0,%ecx
80103ab5:	7f 21                	jg     80103ad8 <growproc+0x38>
  } else if(n < 0){
80103ab7:	75 47                	jne    80103b00 <growproc+0x60>
  proc->sz = sz;
80103ab9:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
80103abb:	83 ec 0c             	sub    $0xc,%esp
80103abe:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
80103ac5:	e8 d6 37 00 00       	call   801072a0 <switchuvm>
  return 0;
80103aca:	83 c4 10             	add    $0x10,%esp
80103acd:	31 c0                	xor    %eax,%eax
}
80103acf:	c9                   	leave  
80103ad0:	c3                   	ret    
80103ad1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80103ad8:	83 ec 04             	sub    $0x4,%esp
80103adb:	01 c1                	add    %eax,%ecx
80103add:	51                   	push   %ecx
80103ade:	50                   	push   %eax
80103adf:	ff 72 04             	pushl  0x4(%edx)
80103ae2:	e8 99 39 00 00       	call   80107480 <allocuvm>
80103ae7:	83 c4 10             	add    $0x10,%esp
80103aea:	85 c0                	test   %eax,%eax
80103aec:	74 28                	je     80103b16 <growproc+0x76>
80103aee:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103af5:	eb c2                	jmp    80103ab9 <growproc+0x19>
80103af7:	89 f6                	mov    %esi,%esi
80103af9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80103b00:	83 ec 04             	sub    $0x4,%esp
80103b03:	01 c1                	add    %eax,%ecx
80103b05:	51                   	push   %ecx
80103b06:	50                   	push   %eax
80103b07:	ff 72 04             	pushl  0x4(%edx)
80103b0a:	e8 11 3b 00 00       	call   80107620 <deallocuvm>
80103b0f:	83 c4 10             	add    $0x10,%esp
80103b12:	85 c0                	test   %eax,%eax
80103b14:	75 d8                	jne    80103aee <growproc+0x4e>
      return -1;
80103b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103b1b:	c9                   	leave  
80103b1c:	c3                   	ret    
80103b1d:	8d 76 00             	lea    0x0(%esi),%esi

80103b20 <fork>:
{
80103b20:	55                   	push   %ebp
  int min = NPROC + 1;
80103b21:	ba 21 00 00 00       	mov    $0x21,%edx
{
80103b26:	89 e5                	mov    %esp,%ebp
80103b28:	57                   	push   %edi
80103b29:	56                   	push   %esi
80103b2a:	53                   	push   %ebx
80103b2b:	83 ec 24             	sub    $0x24,%esp
    if(ptable[i].amount < min){
80103b2e:	a1 80 3a 11 80       	mov    0x80113a80,%eax
  int min = NPROC + 1;
80103b33:	83 f8 21             	cmp    $0x21,%eax
80103b36:	0f 4d c2             	cmovge %edx,%eax
    if(ptable[i].amount < min){
80103b39:	3b 05 b8 5a 11 80    	cmp    0x80115ab8,%eax
  for(i = 0;i < CPUNUMBER; ++i){
80103b3f:	0f 9f c0             	setg   %al
80103b42:	0f b6 c0             	movzbl %al,%eax
  cprintf("fork:ptableIndex = %d\n",ptableIndex);
80103b45:	50                   	push   %eax
80103b46:	68 58 7f 10 80       	push   $0x80107f58
  for(i = 0;i < CPUNUMBER; ++i){
80103b4b:	89 c6                	mov    %eax,%esi
  cprintf("fork:ptableIndex = %d\n",ptableIndex);
80103b4d:	e8 ee ca ff ff       	call   80100640 <cprintf>
  acquire(&ptable[ptableIndex].lock);
80103b52:	69 c6 38 20 00 00    	imul   $0x2038,%esi,%eax
80103b58:	05 84 3a 11 80       	add    $0x80113a84,%eax
80103b5d:	89 04 24             	mov    %eax,(%esp)
80103b60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103b63:	e8 78 0f 00 00       	call   80104ae0 <acquire>
  cprintf("fork: checkpoint 1\n");
80103b68:	c7 04 24 6f 7f 10 80 	movl   $0x80107f6f,(%esp)
80103b6f:	e8 cc ca ff ff       	call   80100640 <cprintf>
  if((np = allocproc(ptableIndex)) == 0){
80103b74:	89 f0                	mov    %esi,%eax
80103b76:	e8 55 fc ff ff       	call   801037d0 <allocproc>
80103b7b:	83 c4 10             	add    $0x10,%esp
80103b7e:	85 c0                	test   %eax,%eax
80103b80:	0f 84 d4 00 00 00    	je     80103c5a <fork+0x13a>
80103b86:	89 c3                	mov    %eax,%ebx
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80103b88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b8e:	83 ec 08             	sub    $0x8,%esp
80103b91:	ff 30                	pushl  (%eax)
80103b93:	ff 70 04             	pushl  0x4(%eax)
80103b96:	e8 05 3c 00 00       	call   801077a0 <copyuvm>
80103b9b:	83 c4 10             	add    $0x10,%esp
80103b9e:	85 c0                	test   %eax,%eax
80103ba0:	89 43 04             	mov    %eax,0x4(%ebx)
80103ba3:	0f 84 c6 00 00 00    	je     80103c6f <fork+0x14f>
  np->sz = proc->sz;
80103ba9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  *np->tf = *proc->tf;
80103baf:	8b 7b 1c             	mov    0x1c(%ebx),%edi
80103bb2:	b9 13 00 00 00       	mov    $0x13,%ecx
  np->sz = proc->sz;
80103bb7:	8b 00                	mov    (%eax),%eax
  np->cpuid = ptableIndex;
80103bb9:	89 73 14             	mov    %esi,0x14(%ebx)
  np->sz = proc->sz;
80103bbc:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
80103bbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103bc4:	89 43 18             	mov    %eax,0x18(%ebx)
  *np->tf = *proc->tf;
80103bc7:	8b 70 1c             	mov    0x1c(%eax),%esi
80103bca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103bcc:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103bce:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103bd1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103bd8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
80103bdf:	90                   	nop
    if(proc->ofile[i])
80103be0:	8b 44 b2 2c          	mov    0x2c(%edx,%esi,4),%eax
80103be4:	85 c0                	test   %eax,%eax
80103be6:	74 17                	je     80103bff <fork+0xdf>
      np->ofile[i] = filedup(proc->ofile[i]);
80103be8:	83 ec 0c             	sub    $0xc,%esp
80103beb:	50                   	push   %eax
80103bec:	e8 cf d1 ff ff       	call   80100dc0 <filedup>
80103bf1:	89 44 b3 2c          	mov    %eax,0x2c(%ebx,%esi,4)
80103bf5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103bfc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
80103bff:	83 c6 01             	add    $0x1,%esi
80103c02:	83 fe 10             	cmp    $0x10,%esi
80103c05:	75 d9                	jne    80103be0 <fork+0xc0>
  np->cwd = idup(proc->cwd);
80103c07:	83 ec 0c             	sub    $0xc,%esp
80103c0a:	ff 72 6c             	pushl  0x6c(%edx)
80103c0d:	e8 ce d9 ff ff       	call   801015e0 <idup>
80103c12:	89 43 6c             	mov    %eax,0x6c(%ebx)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80103c15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103c1b:	83 c4 0c             	add    $0xc,%esp
80103c1e:	6a 10                	push   $0x10
80103c20:	83 c0 70             	add    $0x70,%eax
80103c23:	50                   	push   %eax
80103c24:	8d 43 70             	lea    0x70(%ebx),%eax
80103c27:	50                   	push   %eax
80103c28:	e8 a3 12 00 00       	call   80104ed0 <safestrcpy>
  np->state = RUNNABLE;
80103c2d:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  pid = np->pid;
80103c34:	8b 73 10             	mov    0x10(%ebx),%esi
  release(&ptable[ptableIndex].lock);
80103c37:	58                   	pop    %eax
80103c38:	ff 75 e4             	pushl  -0x1c(%ebp)
80103c3b:	e8 60 10 00 00       	call   80104ca0 <release>
  cprintf("fork: checkpoint 2 pid = %d \n",pid);
80103c40:	5a                   	pop    %edx
80103c41:	59                   	pop    %ecx
80103c42:	56                   	push   %esi
80103c43:	68 83 7f 10 80       	push   $0x80107f83
80103c48:	e8 f3 c9 ff ff       	call   80100640 <cprintf>
  return pid;
80103c4d:	83 c4 10             	add    $0x10,%esp
}
80103c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c53:	89 f0                	mov    %esi,%eax
80103c55:	5b                   	pop    %ebx
80103c56:	5e                   	pop    %esi
80103c57:	5f                   	pop    %edi
80103c58:	5d                   	pop    %ebp
80103c59:	c3                   	ret    
    release(&ptable[ptableIndex].lock);
80103c5a:	83 ec 0c             	sub    $0xc,%esp
80103c5d:	ff 75 e4             	pushl  -0x1c(%ebp)
    return -1;
80103c60:	be ff ff ff ff       	mov    $0xffffffff,%esi
    release(&ptable[ptableIndex].lock);
80103c65:	e8 36 10 00 00       	call   80104ca0 <release>
    return -1;
80103c6a:	83 c4 10             	add    $0x10,%esp
80103c6d:	eb e1                	jmp    80103c50 <fork+0x130>
    kfree(np->kstack);
80103c6f:	83 ec 0c             	sub    $0xc,%esp
80103c72:	ff 73 08             	pushl  0x8(%ebx)
    return -1;
80103c75:	be ff ff ff ff       	mov    $0xffffffff,%esi
    kfree(np->kstack);
80103c7a:	e8 81 e6 ff ff       	call   80102300 <kfree>
    np->kstack = 0;
80103c7f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103c86:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    release(&ptable[ptableIndex].lock);
80103c8d:	5b                   	pop    %ebx
80103c8e:	ff 75 e4             	pushl  -0x1c(%ebp)
80103c91:	e8 0a 10 00 00       	call   80104ca0 <release>
    return -1;
80103c96:	83 c4 10             	add    $0x10,%esp
80103c99:	eb b5                	jmp    80103c50 <fork+0x130>
80103c9b:	90                   	nop
80103c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103ca0 <scheduler>:
{
80103ca0:	55                   	push   %ebp
80103ca1:	89 e5                	mov    %esp,%ebp
80103ca3:	57                   	push   %edi
80103ca4:	56                   	push   %esi
80103ca5:	53                   	push   %ebx
80103ca6:	83 ec 1c             	sub    $0x1c,%esp
80103ca9:	69 5d 08 38 20 00 00 	imul   $0x2038,0x8(%ebp),%ebx
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103cb0:	8d 83 b8 3a 11 80    	lea    -0x7feec548(%ebx),%eax
    acquire(&ptable[cpuid].lock);
80103cb6:	8d b3 84 3a 11 80    	lea    -0x7feec57c(%ebx),%esi
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103cbc:	81 c3 b8 5a 11 80    	add    $0x80115ab8,%ebx
80103cc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103cc5:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103cc8:	fb                   	sti    
    acquire(&ptable[cpuid].lock);
80103cc9:	83 ec 0c             	sub    $0xc,%esp
80103ccc:	56                   	push   %esi
80103ccd:	e8 0e 0e 00 00       	call   80104ae0 <acquire>
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cd5:	83 c4 10             	add    $0x10,%esp
80103cd8:	39 d8                	cmp    %ebx,%eax
80103cda:	73 77                	jae    80103d53 <scheduler+0xb3>
80103cdc:	89 c7                	mov    %eax,%edi
80103cde:	eb 0a                	jmp    80103cea <scheduler+0x4a>
80103ce0:	81 c7 00 01 00 00    	add    $0x100,%edi
80103ce6:	39 df                	cmp    %ebx,%edi
80103ce8:	73 69                	jae    80103d53 <scheduler+0xb3>
      if(p->state != RUNNABLE)
80103cea:	83 7f 0c 03          	cmpl   $0x3,0xc(%edi)
80103cee:	75 f0                	jne    80103ce0 <scheduler+0x40>
      switchuvm(p);
80103cf0:	83 ec 0c             	sub    $0xc,%esp
      proc = p;
80103cf3:	65 89 3d 04 00 00 00 	mov    %edi,%gs:0x4
      switchuvm(p);
80103cfa:	57                   	push   %edi
80103cfb:	e8 a0 35 00 00       	call   801072a0 <switchuvm>
      p->cpuid = cpuid;
80103d00:	8b 45 08             	mov    0x8(%ebp),%eax
      p->state = RUNNING;
80103d03:	c7 47 0c 04 00 00 00 	movl   $0x4,0xc(%edi)
      p->cpuid = cpuid;
80103d0a:	89 47 14             	mov    %eax,0x14(%edi)
      swtch(&cpu->scheduler, p->context);
80103d0d:	58                   	pop    %eax
80103d0e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d14:	5a                   	pop    %edx
80103d15:	ff 77 20             	pushl  0x20(%edi)
80103d18:	8d 50 04             	lea    0x4(%eax),%edx
80103d1b:	52                   	push   %edx
80103d1c:	e8 0a 12 00 00       	call   80104f2b <swtch>
      cprintf("scheduler: process pid = %d\n", p->pid);
80103d21:	59                   	pop    %ecx
80103d22:	58                   	pop    %eax
80103d23:	ff 77 10             	pushl  0x10(%edi)
80103d26:	68 a1 7f 10 80       	push   $0x80107fa1
80103d2b:	e8 10 c9 ff ff       	call   80100640 <cprintf>
      switchkvm();
80103d30:	e8 4b 35 00 00       	call   80107280 <switchkvm>
      if(p->pid == 2){
80103d35:	83 c4 10             	add    $0x10,%esp
80103d38:	83 7f 10 02          	cmpl   $0x2,0x10(%edi)
80103d3c:	74 2a                	je     80103d68 <scheduler+0xc8>
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103d3e:	81 c7 00 01 00 00    	add    $0x100,%edi
      proc = 0;
80103d44:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80103d4b:	00 00 00 00 
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103d4f:	39 df                	cmp    %ebx,%edi
80103d51:	72 97                	jb     80103cea <scheduler+0x4a>
    release(&ptable[cpuid].lock);
80103d53:	83 ec 0c             	sub    $0xc,%esp
80103d56:	56                   	push   %esi
80103d57:	e8 44 0f 00 00       	call   80104ca0 <release>
    sti();
80103d5c:	83 c4 10             	add    $0x10,%esp
80103d5f:	e9 64 ff ff ff       	jmp    80103cc8 <scheduler+0x28>
80103d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        cprintf("scheduler:checkpoint 1\n");
80103d68:	83 ec 0c             	sub    $0xc,%esp
80103d6b:	68 be 7f 10 80       	push   $0x80107fbe
80103d70:	e8 cb c8 ff ff       	call   80100640 <cprintf>
80103d75:	83 c4 10             	add    $0x10,%esp
80103d78:	eb c4                	jmp    80103d3e <scheduler+0x9e>
80103d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103d80 <sched>:
{
80103d80:	55                   	push   %ebp
80103d81:	89 e5                	mov    %esp,%ebp
80103d83:	53                   	push   %ebx
80103d84:	83 ec 10             	sub    $0x10,%esp
  if(!holding(&ptable[proc->cpuid].lock))
80103d87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103d8d:	69 40 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%eax
80103d94:	05 84 3a 11 80       	add    $0x80113a84,%eax
80103d99:	50                   	push   %eax
80103d9a:	e8 51 0e 00 00       	call   80104bf0 <holding>
80103d9f:	83 c4 10             	add    $0x10,%esp
80103da2:	85 c0                	test   %eax,%eax
80103da4:	74 4c                	je     80103df2 <sched+0x72>
  if(cpu->ncli != 1)
80103da6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80103dad:	83 ba ac 00 00 00 01 	cmpl   $0x1,0xac(%edx)
80103db4:	75 63                	jne    80103e19 <sched+0x99>
  if(proc->state == RUNNING)
80103db6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103dbc:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80103dc0:	74 4a                	je     80103e0c <sched+0x8c>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103dc2:	9c                   	pushf  
80103dc3:	59                   	pop    %ecx
  if(readeflags()&FL_IF)
80103dc4:	80 e5 02             	and    $0x2,%ch
80103dc7:	75 36                	jne    80103dff <sched+0x7f>
  swtch(&proc->context, cpu->scheduler);
80103dc9:	83 ec 08             	sub    $0x8,%esp
80103dcc:	83 c0 20             	add    $0x20,%eax
  intena = cpu->intena;
80103dcf:	8b 9a b0 00 00 00    	mov    0xb0(%edx),%ebx
  swtch(&proc->context, cpu->scheduler);
80103dd5:	ff 72 04             	pushl  0x4(%edx)
80103dd8:	50                   	push   %eax
80103dd9:	e8 4d 11 00 00       	call   80104f2b <swtch>
  cpu->intena = intena;
80103dde:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
}
80103de4:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80103de7:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
80103ded:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103df0:	c9                   	leave  
80103df1:	c3                   	ret    
    panic("sched ptable.lock");
80103df2:	83 ec 0c             	sub    $0xc,%esp
80103df5:	68 d6 7f 10 80       	push   $0x80107fd6
80103dfa:	e8 71 c5 ff ff       	call   80100370 <panic>
    panic("sched interruptible");
80103dff:	83 ec 0c             	sub    $0xc,%esp
80103e02:	68 02 80 10 80       	push   $0x80108002
80103e07:	e8 64 c5 ff ff       	call   80100370 <panic>
    panic("sched running");
80103e0c:	83 ec 0c             	sub    $0xc,%esp
80103e0f:	68 f4 7f 10 80       	push   $0x80107ff4
80103e14:	e8 57 c5 ff ff       	call   80100370 <panic>
    panic("sched locks");
80103e19:	83 ec 0c             	sub    $0xc,%esp
80103e1c:	68 e8 7f 10 80       	push   $0x80107fe8
80103e21:	e8 4a c5 ff ff       	call   80100370 <panic>
80103e26:	8d 76 00             	lea    0x0(%esi),%esi
80103e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103e30 <yield>:
{
80103e30:	55                   	push   %ebp
80103e31:	89 e5                	mov    %esp,%ebp
80103e33:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable[proc->cpuid].lock);  //DOC: yieldlock
80103e36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e3c:	69 40 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%eax
80103e43:	05 84 3a 11 80       	add    $0x80113a84,%eax
80103e48:	50                   	push   %eax
80103e49:	e8 92 0c 00 00       	call   80104ae0 <acquire>
  proc->state = RUNNABLE;
80103e4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e54:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103e5b:	e8 20 ff ff ff       	call   80103d80 <sched>
  release(&ptable[proc->cpuid].lock);
80103e60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e66:	69 40 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%eax
80103e6d:	05 84 3a 11 80       	add    $0x80113a84,%eax
80103e72:	89 04 24             	mov    %eax,(%esp)
80103e75:	e8 26 0e 00 00       	call   80104ca0 <release>
}
80103e7a:	83 c4 10             	add    $0x10,%esp
80103e7d:	c9                   	leave  
80103e7e:	c3                   	ret    
80103e7f:	90                   	nop

80103e80 <sleep>:
// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
80103e80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80103e86:	55                   	push   %ebp
80103e87:	89 e5                	mov    %esp,%ebp
80103e89:	56                   	push   %esi
80103e8a:	53                   	push   %ebx
  if(proc == 0)
80103e8b:	85 c0                	test   %eax,%eax
{
80103e8d:	8b 75 08             	mov    0x8(%ebp),%esi
80103e90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
80103e93:	0f 84 8b 00 00 00    	je     80103f24 <sleep+0xa4>
    panic("sleep");

  if(lk == 0)
80103e99:	85 db                	test   %ebx,%ebx
80103e9b:	74 7a                	je     80103f17 <sleep+0x97>
  // change p->state and then call sched.
  // Once we hold ptable[0].lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable[0].lock locked),
  // so it's okay to release lk.
  if(lk != &ptable[proc->cpuid].lock){  //DOC: sleeplock0
80103e9d:	69 50 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%edx
80103ea4:	81 c2 84 3a 11 80    	add    $0x80113a84,%edx
80103eaa:	39 da                	cmp    %ebx,%edx
80103eac:	74 1a                	je     80103ec8 <sleep+0x48>
    acquire(&ptable[proc->cpuid].lock);  //DOC: sleeplock1
80103eae:	83 ec 0c             	sub    $0xc,%esp
80103eb1:	52                   	push   %edx
80103eb2:	e8 29 0c 00 00       	call   80104ae0 <acquire>
    release(lk);
80103eb7:	89 1c 24             	mov    %ebx,(%esp)
80103eba:	e8 e1 0d 00 00       	call   80104ca0 <release>
80103ebf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ec5:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80103ec8:	89 70 24             	mov    %esi,0x24(%eax)
  proc->state = SLEEPING;
80103ecb:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80103ed2:	e8 a9 fe ff ff       	call   80103d80 <sched>

  // Tidy up.
  proc->chan = 0;
80103ed7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103edd:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

  // Reacquire original lock.
  if(lk != &ptable[proc->cpuid].lock){  //DOC: sleeplock2
80103ee4:	69 40 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%eax
80103eeb:	05 84 3a 11 80       	add    $0x80113a84,%eax
80103ef0:	39 d8                	cmp    %ebx,%eax
80103ef2:	74 1c                	je     80103f10 <sleep+0x90>
    release(&ptable[proc->cpuid].lock);
80103ef4:	83 ec 0c             	sub    $0xc,%esp
80103ef7:	50                   	push   %eax
80103ef8:	e8 a3 0d 00 00       	call   80104ca0 <release>
    acquire(lk);
80103efd:	89 5d 08             	mov    %ebx,0x8(%ebp)
80103f00:	83 c4 10             	add    $0x10,%esp
  }
}
80103f03:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f06:	5b                   	pop    %ebx
80103f07:	5e                   	pop    %esi
80103f08:	5d                   	pop    %ebp
    acquire(lk);
80103f09:	e9 d2 0b 00 00       	jmp    80104ae0 <acquire>
80103f0e:	66 90                	xchg   %ax,%ax
}
80103f10:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f13:	5b                   	pop    %ebx
80103f14:	5e                   	pop    %esi
80103f15:	5d                   	pop    %ebp
80103f16:	c3                   	ret    
    panic("sleep without lk");
80103f17:	83 ec 0c             	sub    $0xc,%esp
80103f1a:	68 1c 80 10 80       	push   $0x8010801c
80103f1f:	e8 4c c4 ff ff       	call   80100370 <panic>
    panic("sleep");
80103f24:	83 ec 0c             	sub    $0xc,%esp
80103f27:	68 16 80 10 80       	push   $0x80108016
80103f2c:	e8 3f c4 ff ff       	call   80100370 <panic>
80103f31:	eb 0d                	jmp    80103f40 <wait>
80103f33:	90                   	nop
80103f34:	90                   	nop
80103f35:	90                   	nop
80103f36:	90                   	nop
80103f37:	90                   	nop
80103f38:	90                   	nop
80103f39:	90                   	nop
80103f3a:	90                   	nop
80103f3b:	90                   	nop
80103f3c:	90                   	nop
80103f3d:	90                   	nop
80103f3e:	90                   	nop
80103f3f:	90                   	nop

80103f40 <wait>:
{
80103f40:	55                   	push   %ebp
80103f41:	89 e5                	mov    %esp,%ebp
80103f43:	57                   	push   %edi
80103f44:	56                   	push   %esi
80103f45:	53                   	push   %ebx
80103f46:	83 ec 0c             	sub    $0xc,%esp
      acquire(&ptable[i].lock);
80103f49:	83 ec 0c             	sub    $0xc,%esp
    havekids = 0;
80103f4c:	31 f6                	xor    %esi,%esi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80103f4e:	bb b8 3a 11 80       	mov    $0x80113ab8,%ebx
      acquire(&ptable[i].lock);
80103f53:	68 84 3a 11 80       	push   $0x80113a84
80103f58:	e8 83 0b 00 00       	call   80104ae0 <acquire>
        if(p->parent != proc)
80103f5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f63:	83 c4 10             	add    $0x10,%esp
80103f66:	eb 16                	jmp    80103f7e <wait+0x3e>
80103f68:	90                   	nop
80103f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80103f70:	81 c3 00 01 00 00    	add    $0x100,%ebx
80103f76:	81 fb b8 5a 11 80    	cmp    $0x80115ab8,%ebx
80103f7c:	74 22                	je     80103fa0 <wait+0x60>
        if(p->parent != proc)
80103f7e:	3b 43 18             	cmp    0x18(%ebx),%eax
80103f81:	75 ed                	jne    80103f70 <wait+0x30>
        if(p->state == ZOMBIE){
80103f83:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103f87:	0f 84 db 00 00 00    	je     80104068 <wait+0x128>
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80103f8d:	81 c3 00 01 00 00    	add    $0x100,%ebx
        havekids = 1;
80103f93:	be 01 00 00 00       	mov    $0x1,%esi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80103f98:	81 fb b8 5a 11 80    	cmp    $0x80115ab8,%ebx
80103f9e:	75 de                	jne    80103f7e <wait+0x3e>
      release(&ptable[i].lock);
80103fa0:	83 ec 0c             	sub    $0xc,%esp
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80103fa3:	bb f0 5a 11 80       	mov    $0x80115af0,%ebx
      release(&ptable[i].lock);
80103fa8:	68 84 3a 11 80       	push   $0x80113a84
80103fad:	e8 ee 0c 00 00       	call   80104ca0 <release>
      acquire(&ptable[i].lock);
80103fb2:	c7 04 24 bc 5a 11 80 	movl   $0x80115abc,(%esp)
80103fb9:	e8 22 0b 00 00       	call   80104ae0 <acquire>
        if(p->parent != proc)
80103fbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103fc4:	83 c4 10             	add    $0x10,%esp
80103fc7:	eb 15                	jmp    80103fde <wait+0x9e>
80103fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80103fd0:	81 c3 00 01 00 00    	add    $0x100,%ebx
80103fd6:	81 fb f0 7a 11 80    	cmp    $0x80117af0,%ebx
80103fdc:	74 22                	je     80104000 <wait+0xc0>
        if(p->parent != proc)
80103fde:	39 43 18             	cmp    %eax,0x18(%ebx)
80103fe1:	75 ed                	jne    80103fd0 <wait+0x90>
        if(p->state == ZOMBIE){
80103fe3:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103fe7:	0f 84 d3 00 00 00    	je     801040c0 <wait+0x180>
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80103fed:	81 c3 00 01 00 00    	add    $0x100,%ebx
        havekids = 1;
80103ff3:	be 01 00 00 00       	mov    $0x1,%esi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80103ff8:	81 fb f0 7a 11 80    	cmp    $0x80117af0,%ebx
80103ffe:	75 de                	jne    80103fde <wait+0x9e>
      release(&ptable[i].lock);
80104000:	83 ec 0c             	sub    $0xc,%esp
80104003:	68 bc 5a 11 80       	push   $0x80115abc
80104008:	e8 93 0c 00 00       	call   80104ca0 <release>
    if(!havekids || proc->killed){
8010400d:	83 c4 10             	add    $0x10,%esp
80104010:	85 f6                	test   %esi,%esi
80104012:	0f 84 af 00 00 00    	je     801040c7 <wait+0x187>
80104018:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010401e:	8b 58 28             	mov    0x28(%eax),%ebx
80104021:	85 db                	test   %ebx,%ebx
80104023:	0f 85 9e 00 00 00    	jne    801040c7 <wait+0x187>
    acquire(&ptable[proc->cpuid].lock);
80104029:	69 40 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%eax
80104030:	83 ec 0c             	sub    $0xc,%esp
80104033:	05 84 3a 11 80       	add    $0x80113a84,%eax
80104038:	50                   	push   %eax
80104039:	e8 a2 0a 00 00       	call   80104ae0 <acquire>
    sleep(proc, &ptable[proc->cpuid].lock);  //DOC: wait-sleep
8010403e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104045:	58                   	pop    %eax
80104046:	59                   	pop    %ecx
80104047:	69 42 14 38 20 00 00 	imul   $0x2038,0x14(%edx),%eax
8010404e:	05 84 3a 11 80       	add    $0x80113a84,%eax
80104053:	50                   	push   %eax
80104054:	52                   	push   %edx
80104055:	e8 26 fe ff ff       	call   80103e80 <sleep>
    havekids = 0;
8010405a:	83 c4 10             	add    $0x10,%esp
8010405d:	e9 e7 fe ff ff       	jmp    80103f49 <wait+0x9>
80104062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&ptable[i].lock);
80104068:	be 84 3a 11 80       	mov    $0x80113a84,%esi
          kfree(p->kstack);
8010406d:	83 ec 0c             	sub    $0xc,%esp
          pid = p->pid;
80104070:	8b 7b 10             	mov    0x10(%ebx),%edi
          kfree(p->kstack);
80104073:	ff 73 08             	pushl  0x8(%ebx)
80104076:	e8 85 e2 ff ff       	call   80102300 <kfree>
          p->kstack = 0;
8010407b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
          freevm(p->pgdir);
80104082:	58                   	pop    %eax
80104083:	ff 73 04             	pushl  0x4(%ebx)
80104086:	e8 65 36 00 00       	call   801076f0 <freevm>
          p->pid = 0;
8010408b:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
          p->parent = 0;
80104092:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
          p->name[0] = 0;
80104099:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
          p->killed = 0;
8010409d:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
          p->state = UNUSED;
801040a4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
          release(&ptable[i].lock);
801040ab:	89 34 24             	mov    %esi,(%esp)
801040ae:	e8 ed 0b 00 00       	call   80104ca0 <release>
          return pid;
801040b3:	83 c4 10             	add    $0x10,%esp
}
801040b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040b9:	89 f8                	mov    %edi,%eax
801040bb:	5b                   	pop    %ebx
801040bc:	5e                   	pop    %esi
801040bd:	5f                   	pop    %edi
801040be:	5d                   	pop    %ebp
801040bf:	c3                   	ret    
      acquire(&ptable[i].lock);
801040c0:	be bc 5a 11 80       	mov    $0x80115abc,%esi
801040c5:	eb a6                	jmp    8010406d <wait+0x12d>
}
801040c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801040ca:	bf ff ff ff ff       	mov    $0xffffffff,%edi
}
801040cf:	89 f8                	mov    %edi,%eax
801040d1:	5b                   	pop    %ebx
801040d2:	5e                   	pop    %esi
801040d3:	5f                   	pop    %edi
801040d4:	5d                   	pop    %ebp
801040d5:	c3                   	ret    
801040d6:	8d 76 00             	lea    0x0(%esi),%esi
801040d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801040e0 <wakeup>:
// }

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801040e0:	55                   	push   %ebp
801040e1:	89 e5                	mov    %esp,%ebp
801040e3:	53                   	push   %ebx
801040e4:	83 ec 10             	sub    $0x10,%esp
801040e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;
  struct proc *p;
  for(i = 0;i<CPUNUMBER;++i){
    acquire(&ptable[i].lock);
801040ea:	68 84 3a 11 80       	push   $0x80113a84
801040ef:	e8 ec 09 00 00       	call   80104ae0 <acquire>
801040f4:	83 c4 10             	add    $0x10,%esp
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++)
801040f7:	b8 b8 3a 11 80       	mov    $0x80113ab8,%eax
801040fc:	eb 0e                	jmp    8010410c <wakeup+0x2c>
801040fe:	66 90                	xchg   %ax,%ax
80104100:	05 00 01 00 00       	add    $0x100,%eax
80104105:	3d b8 5a 11 80       	cmp    $0x80115ab8,%eax
8010410a:	73 24                	jae    80104130 <wakeup+0x50>
      if(p->state == SLEEPING && p->chan == chan)
8010410c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104110:	75 ee                	jne    80104100 <wakeup+0x20>
80104112:	3b 58 24             	cmp    0x24(%eax),%ebx
80104115:	75 e9                	jne    80104100 <wakeup+0x20>
        p->state = RUNNABLE;
80104117:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++)
8010411e:	05 00 01 00 00       	add    $0x100,%eax
80104123:	3d b8 5a 11 80       	cmp    $0x80115ab8,%eax
80104128:	72 e2                	jb     8010410c <wakeup+0x2c>
8010412a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&ptable[i].lock);
80104130:	83 ec 0c             	sub    $0xc,%esp
80104133:	68 84 3a 11 80       	push   $0x80113a84
80104138:	e8 63 0b 00 00       	call   80104ca0 <release>
    acquire(&ptable[i].lock);
8010413d:	c7 04 24 bc 5a 11 80 	movl   $0x80115abc,(%esp)
80104144:	e8 97 09 00 00       	call   80104ae0 <acquire>
80104149:	83 c4 10             	add    $0x10,%esp
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++)
8010414c:	b8 f0 5a 11 80       	mov    $0x80115af0,%eax
80104151:	eb 11                	jmp    80104164 <wakeup+0x84>
80104153:	90                   	nop
80104154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104158:	05 00 01 00 00       	add    $0x100,%eax
8010415d:	3d f0 7a 11 80       	cmp    $0x80117af0,%eax
80104162:	73 1e                	jae    80104182 <wakeup+0xa2>
      if(p->state == SLEEPING && p->chan == chan)
80104164:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104168:	75 ee                	jne    80104158 <wakeup+0x78>
8010416a:	39 58 24             	cmp    %ebx,0x24(%eax)
8010416d:	75 e9                	jne    80104158 <wakeup+0x78>
        p->state = RUNNABLE;
8010416f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++)
80104176:	05 00 01 00 00       	add    $0x100,%eax
8010417b:	3d f0 7a 11 80       	cmp    $0x80117af0,%eax
80104180:	72 e2                	jb     80104164 <wakeup+0x84>
    release(&ptable[i].lock);
80104182:	c7 45 08 bc 5a 11 80 	movl   $0x80115abc,0x8(%ebp)
  }
}
80104189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010418c:	c9                   	leave  
    release(&ptable[i].lock);
8010418d:	e9 0e 0b 00 00       	jmp    80104ca0 <release>
80104192:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104199:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801041a0 <exit>:
{
801041a0:	55                   	push   %ebp
801041a1:	89 e5                	mov    %esp,%ebp
801041a3:	57                   	push   %edi
801041a4:	56                   	push   %esi
801041a5:	53                   	push   %ebx
801041a6:	83 ec 1c             	sub    $0x1c,%esp
  if(proc == initproc)
801041a9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801041b0:	3b 15 bc b5 10 80    	cmp    0x8010b5bc,%edx
801041b6:	0f 84 d6 01 00 00    	je     80104392 <exit+0x1f2>
  int cpuid = proc->cpuid;
801041bc:	8b 42 14             	mov    0x14(%edx),%eax
  for(fd = 0; fd < NOFILE; fd++){
801041bf:	31 db                	xor    %ebx,%ebx
  int cpuid = proc->cpuid;
801041c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801041c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->ofile[fd]){
801041c8:	8d 73 08             	lea    0x8(%ebx),%esi
801041cb:	8b 44 b2 0c          	mov    0xc(%edx,%esi,4),%eax
801041cf:	85 c0                	test   %eax,%eax
801041d1:	74 1b                	je     801041ee <exit+0x4e>
      fileclose(proc->ofile[fd]);
801041d3:	83 ec 0c             	sub    $0xc,%esp
801041d6:	50                   	push   %eax
801041d7:	e8 34 cc ff ff       	call   80100e10 <fileclose>
      proc->ofile[fd] = 0;
801041dc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801041e3:	83 c4 10             	add    $0x10,%esp
801041e6:	c7 44 b2 0c 00 00 00 	movl   $0x0,0xc(%edx,%esi,4)
801041ed:	00 
  for(fd = 0; fd < NOFILE; fd++){
801041ee:	83 c3 01             	add    $0x1,%ebx
801041f1:	83 fb 10             	cmp    $0x10,%ebx
801041f4:	75 d2                	jne    801041c8 <exit+0x28>
  begin_op();
801041f6:	e8 25 ea ff ff       	call   80102c20 <begin_op>
  iput(proc->cwd);
801041fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104201:	83 ec 0c             	sub    $0xc,%esp
  int i,needWakeinit = 0;
80104204:	31 db                	xor    %ebx,%ebx
          needWakeinit = 1;
80104206:	be 01 00 00 00       	mov    $0x1,%esi
  iput(proc->cwd);
8010420b:	ff 70 6c             	pushl  0x6c(%eax)
8010420e:	e8 6d d5 ff ff       	call   80101780 <iput>
  end_op();
80104213:	e8 78 ea ff ff       	call   80102c90 <end_op>
  proc->cwd = 0;
80104218:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010421e:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
    acquire(&ptable[i].lock);
80104225:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
8010422c:	e8 af 08 00 00       	call   80104ae0 <acquire>
      if(p->chan == proc->parent && p->state == SLEEPING ){
80104231:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
        p->parent = initproc;
80104238:	8b 3d bc b5 10 80    	mov    0x8010b5bc,%edi
8010423e:	83 c4 10             	add    $0x10,%esp
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104241:	b8 b8 3a 11 80       	mov    $0x80113ab8,%eax
80104246:	eb 25                	jmp    8010426d <exit+0xcd>
80104248:	90                   	nop
80104249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      }else if(p->chan == proc->pthread && p->state == SLEEPING ){
80104250:	3b 91 f8 00 00 00    	cmp    0xf8(%ecx),%edx
80104256:	74 1d                	je     80104275 <exit+0xd5>
      }else if(p->parent == proc){
80104258:	3b 48 18             	cmp    0x18(%eax),%ecx
8010425b:	0f 84 ff 00 00 00    	je     80104360 <exit+0x1c0>
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104261:	05 00 01 00 00       	add    $0x100,%eax
80104266:	3d b8 5a 11 80       	cmp    $0x80115ab8,%eax
8010426b:	73 23                	jae    80104290 <exit+0xf0>
      if(p->chan == proc->parent && p->state == SLEEPING ){
8010426d:	8b 50 24             	mov    0x24(%eax),%edx
80104270:	3b 51 18             	cmp    0x18(%ecx),%edx
80104273:	75 db                	jne    80104250 <exit+0xb0>
80104275:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104279:	75 dd                	jne    80104258 <exit+0xb8>
        p->state = RUNNABLE;
8010427b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104282:	05 00 01 00 00       	add    $0x100,%eax
80104287:	3d b8 5a 11 80       	cmp    $0x80115ab8,%eax
8010428c:	72 df                	jb     8010426d <exit+0xcd>
8010428e:	66 90                	xchg   %ax,%ax
    release(&ptable[i].lock);
80104290:	83 ec 0c             	sub    $0xc,%esp
          needWakeinit = 1;
80104293:	be 01 00 00 00       	mov    $0x1,%esi
    release(&ptable[i].lock);
80104298:	68 84 3a 11 80       	push   $0x80113a84
8010429d:	e8 fe 09 00 00       	call   80104ca0 <release>
    acquire(&ptable[i].lock);
801042a2:	c7 04 24 bc 5a 11 80 	movl   $0x80115abc,(%esp)
801042a9:	e8 32 08 00 00       	call   80104ae0 <acquire>
      if(p->chan == proc->parent && p->state == SLEEPING ){
801042ae:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
        p->parent = initproc;
801042b5:	8b 3d bc b5 10 80    	mov    0x8010b5bc,%edi
801042bb:	83 c4 10             	add    $0x10,%esp
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801042be:	b8 f0 5a 11 80       	mov    $0x80115af0,%eax
801042c3:	eb 20                	jmp    801042e5 <exit+0x145>
801042c5:	8d 76 00             	lea    0x0(%esi),%esi
      }else if(p->chan == proc->pthread && p->state == SLEEPING ){
801042c8:	3b 91 f8 00 00 00    	cmp    0xf8(%ecx),%edx
801042ce:	74 1d                	je     801042ed <exit+0x14d>
      }else if(p->parent == proc){
801042d0:	3b 48 18             	cmp    0x18(%eax),%ecx
801042d3:	0f 84 97 00 00 00    	je     80104370 <exit+0x1d0>
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801042d9:	05 00 01 00 00       	add    $0x100,%eax
801042de:	3d f0 7a 11 80       	cmp    $0x80117af0,%eax
801042e3:	73 2b                	jae    80104310 <exit+0x170>
      if(p->chan == proc->parent && p->state == SLEEPING ){
801042e5:	8b 50 24             	mov    0x24(%eax),%edx
801042e8:	3b 51 18             	cmp    0x18(%ecx),%edx
801042eb:	75 db                	jne    801042c8 <exit+0x128>
      }else if(p->chan == proc->pthread && p->state == SLEEPING ){
801042ed:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801042f1:	75 dd                	jne    801042d0 <exit+0x130>
        p->state = RUNNABLE;
801042f3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801042fa:	05 00 01 00 00       	add    $0x100,%eax
801042ff:	3d f0 7a 11 80       	cmp    $0x80117af0,%eax
80104304:	72 df                	jb     801042e5 <exit+0x145>
80104306:	8d 76 00             	lea    0x0(%esi),%esi
80104309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    release(&ptable[i].lock);
80104310:	83 ec 0c             	sub    $0xc,%esp
80104313:	68 bc 5a 11 80       	push   $0x80115abc
80104318:	e8 83 09 00 00       	call   80104ca0 <release>
  if(needWakeinit)wakeup(initproc);
8010431d:	83 c4 10             	add    $0x10,%esp
80104320:	85 db                	test   %ebx,%ebx
80104322:	75 5b                	jne    8010437f <exit+0x1df>
  acquire(&ptable[cpuid].lock);
80104324:	69 45 e4 38 20 00 00 	imul   $0x2038,-0x1c(%ebp),%eax
8010432b:	83 ec 0c             	sub    $0xc,%esp
8010432e:	05 84 3a 11 80       	add    $0x80113a84,%eax
80104333:	50                   	push   %eax
80104334:	e8 a7 07 00 00       	call   80104ae0 <acquire>
  proc->state = ZOMBIE;
80104339:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010433f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104346:	e8 35 fa ff ff       	call   80103d80 <sched>
  panic("zombie exit");
8010434b:	c7 04 24 3a 80 10 80 	movl   $0x8010803a,(%esp)
80104352:	e8 19 c0 ff ff       	call   80100370 <panic>
80104357:	89 f6                	mov    %esi,%esi
80104359:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
          needWakeinit = 1;
80104360:	83 78 0c 05          	cmpl   $0x5,0xc(%eax)
        p->parent = initproc;
80104364:	89 78 18             	mov    %edi,0x18(%eax)
          needWakeinit = 1;
80104367:	0f 44 de             	cmove  %esi,%ebx
8010436a:	e9 f2 fe ff ff       	jmp    80104261 <exit+0xc1>
8010436f:	90                   	nop
80104370:	83 78 0c 05          	cmpl   $0x5,0xc(%eax)
        p->parent = initproc;
80104374:	89 78 18             	mov    %edi,0x18(%eax)
          needWakeinit = 1;
80104377:	0f 44 de             	cmove  %esi,%ebx
8010437a:	e9 5a ff ff ff       	jmp    801042d9 <exit+0x139>
  if(needWakeinit)wakeup(initproc);
8010437f:	83 ec 0c             	sub    $0xc,%esp
80104382:	ff 35 bc b5 10 80    	pushl  0x8010b5bc
80104388:	e8 53 fd ff ff       	call   801040e0 <wakeup>
8010438d:	83 c4 10             	add    $0x10,%esp
80104390:	eb 92                	jmp    80104324 <exit+0x184>
    panic("init exiting");
80104392:	83 ec 0c             	sub    $0xc,%esp
80104395:	68 2d 80 10 80       	push   $0x8010802d
8010439a:	e8 d1 bf ff ff       	call   80100370 <panic>
8010439f:	90                   	nop

801043a0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043a0:	55                   	push   %ebp
801043a1:	89 e5                	mov    %esp,%ebp
801043a3:	53                   	push   %ebx
801043a4:	83 ec 10             	sub    $0x10,%esp
801043a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;
  int i;
  for( i=0;i<CPUNUMBER;++i){
    acquire(&ptable[i].lock);
801043aa:	68 84 3a 11 80       	push   $0x80113a84
801043af:	e8 2c 07 00 00       	call   80104ae0 <acquire>
801043b4:	83 c4 10             	add    $0x10,%esp
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801043b7:	b8 b8 3a 11 80       	mov    $0x80113ab8,%eax
801043bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(p->pid == pid){
801043c0:	3b 58 10             	cmp    0x10(%eax),%ebx
801043c3:	74 63                	je     80104428 <kill+0x88>
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801043c5:	05 00 01 00 00       	add    $0x100,%eax
801043ca:	3d b8 5a 11 80       	cmp    $0x80115ab8,%eax
801043cf:	72 ef                	jb     801043c0 <kill+0x20>
          p->state = RUNNABLE;
        release(&ptable[i].lock);
        return 0;
      }
    }
    release(&ptable[i].lock);
801043d1:	83 ec 0c             	sub    $0xc,%esp
801043d4:	68 84 3a 11 80       	push   $0x80113a84
801043d9:	e8 c2 08 00 00       	call   80104ca0 <release>
    acquire(&ptable[i].lock);
801043de:	c7 04 24 bc 5a 11 80 	movl   $0x80115abc,(%esp)
801043e5:	e8 f6 06 00 00       	call   80104ae0 <acquire>
801043ea:	83 c4 10             	add    $0x10,%esp
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801043ed:	b8 f0 5a 11 80       	mov    $0x80115af0,%eax
801043f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(p->pid == pid){
801043f8:	3b 58 10             	cmp    0x10(%eax),%ebx
801043fb:	74 5b                	je     80104458 <kill+0xb8>
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801043fd:	05 00 01 00 00       	add    $0x100,%eax
80104402:	3d f0 7a 11 80       	cmp    $0x80117af0,%eax
80104407:	72 ef                	jb     801043f8 <kill+0x58>
    release(&ptable[i].lock);
80104409:	83 ec 0c             	sub    $0xc,%esp
8010440c:	68 bc 5a 11 80       	push   $0x80115abc
80104411:	e8 8a 08 00 00       	call   80104ca0 <release>
80104416:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80104419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010441e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104421:	c9                   	leave  
80104422:	c3                   	ret    
80104423:	90                   	nop
80104424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    acquire(&ptable[i].lock);
80104428:	ba 84 3a 11 80       	mov    $0x80113a84,%edx
        if(p->state == SLEEPING)
8010442d:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
        p->killed = 1;
80104431:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
        if(p->state == SLEEPING)
80104438:	75 07                	jne    80104441 <kill+0xa1>
          p->state = RUNNABLE;
8010443a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
        release(&ptable[i].lock);
80104441:	83 ec 0c             	sub    $0xc,%esp
80104444:	52                   	push   %edx
80104445:	e8 56 08 00 00       	call   80104ca0 <release>
        return 0;
8010444a:	83 c4 10             	add    $0x10,%esp
8010444d:	31 c0                	xor    %eax,%eax
}
8010444f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104452:	c9                   	leave  
80104453:	c3                   	ret    
80104454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    acquire(&ptable[i].lock);
80104458:	ba bc 5a 11 80       	mov    $0x80115abc,%edx
8010445d:	eb ce                	jmp    8010442d <kill+0x8d>
8010445f:	90                   	nop

80104460 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104460:	55                   	push   %ebp
80104461:	89 e5                	mov    %esp,%ebp
80104463:	57                   	push   %edi
80104464:	56                   	push   %esi
80104465:	53                   	push   %ebx
  };
  struct proc *p;
  char *state;
  uint pc[10];

  for(i=0;i<CPUNUMBER;++i)
80104466:	31 db                	xor    %ebx,%ebx
{
80104468:	83 ec 3c             	sub    $0x3c,%esp
8010446b:	90                   	nop
8010446c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104470:	69 c3 38 20 00 00    	imul   $0x2038,%ebx,%eax
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104476:	8d b0 b8 3a 11 80    	lea    -0x7feec548(%eax),%esi
8010447c:	05 b8 5a 11 80       	add    $0x80115ab8,%eax
80104481:	39 c6                	cmp    %eax,%esi
80104483:	72 28                	jb     801044ad <procdump+0x4d>
80104485:	e9 c5 00 00 00       	jmp    8010454f <procdump+0xef>
8010448a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104490:	8d 43 01             	lea    0x1(%ebx),%eax
80104493:	81 c6 00 01 00 00    	add    $0x100,%esi
80104499:	69 f8 38 20 00 00    	imul   $0x2038,%eax,%edi
8010449f:	8d 87 80 3a 11 80    	lea    -0x7feec580(%edi),%eax
801044a5:	39 c6                	cmp    %eax,%esi
801044a7:	0f 83 a2 00 00 00    	jae    8010454f <procdump+0xef>
      if(p->state == UNUSED)
801044ad:	8b 46 0c             	mov    0xc(%esi),%eax
801044b0:	85 c0                	test   %eax,%eax
801044b2:	74 dc                	je     80104490 <procdump+0x30>
        continue;
      if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044b4:	83 f8 05             	cmp    $0x5,%eax
        state = states[p->state];
      else
        state = "???";
801044b7:	b9 46 80 10 80       	mov    $0x80108046,%ecx
      if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044bc:	77 11                	ja     801044cf <procdump+0x6f>
801044be:	8b 0c 85 08 81 10 80 	mov    -0x7fef7ef8(,%eax,4),%ecx
        state = "???";
801044c5:	b8 46 80 10 80       	mov    $0x80108046,%eax
801044ca:	85 c9                	test   %ecx,%ecx
801044cc:	0f 44 c8             	cmove  %eax,%ecx
      cprintf("\npid:%d, state: %s, name: %s\n", p->pid, state, p->name);
801044cf:	8d 46 70             	lea    0x70(%esi),%eax
801044d2:	50                   	push   %eax
801044d3:	51                   	push   %ecx
801044d4:	ff 76 10             	pushl  0x10(%esi)
801044d7:	68 4a 80 10 80       	push   $0x8010804a
801044dc:	e8 5f c1 ff ff       	call   80100640 <cprintf>
      for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
801044e1:	8b 86 88 00 00 00    	mov    0x88(%esi),%eax
801044e7:	83 c4 10             	add    $0x10,%esp
801044ea:	85 c0                	test   %eax,%eax
801044ec:	74 2e                	je     8010451c <procdump+0xbc>
801044ee:	66 90                	xchg   %ax,%ax
        cprintf("start: %d, length: %d\n",p->vm[i].start,p->vm[i].length);
801044f0:	8d 04 40             	lea    (%eax,%eax,2),%eax
801044f3:	83 ec 04             	sub    $0x4,%esp
801044f6:	8d 3c 86             	lea    (%esi,%eax,4),%edi
801044f9:	ff b7 84 00 00 00    	pushl  0x84(%edi)
801044ff:	ff b7 80 00 00 00    	pushl  0x80(%edi)
80104505:	68 68 80 10 80       	push   $0x80108068
8010450a:	e8 31 c1 ff ff       	call   80100640 <cprintf>
      for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
8010450f:	8b 87 88 00 00 00    	mov    0x88(%edi),%eax
80104515:	83 c4 10             	add    $0x10,%esp
80104518:	85 c0                	test   %eax,%eax
8010451a:	75 d4                	jne    801044f0 <procdump+0x90>
      }
      if(p->state == SLEEPING){
8010451c:	83 7e 0c 02          	cmpl   $0x2,0xc(%esi)
80104520:	74 3e                	je     80104560 <procdump+0x100>
80104522:	8d 43 01             	lea    0x1(%ebx),%eax
80104525:	69 f8 38 20 00 00    	imul   $0x2038,%eax,%edi
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
8010452b:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
8010452e:	81 c6 00 01 00 00    	add    $0x100,%esi
      cprintf("\n");
80104534:	68 98 80 10 80       	push   $0x80108098
80104539:	e8 02 c1 ff ff       	call   80100640 <cprintf>
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
8010453e:	8d 87 80 3a 11 80    	lea    -0x7feec580(%edi),%eax
      cprintf("\n");
80104544:	83 c4 10             	add    $0x10,%esp
    for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104547:	39 c6                	cmp    %eax,%esi
80104549:	0f 82 5e ff ff ff    	jb     801044ad <procdump+0x4d>
  for(i=0;i<CPUNUMBER;++i)
8010454f:	85 db                	test   %ebx,%ebx
80104551:	75 5d                	jne    801045b0 <procdump+0x150>
80104553:	bb 01 00 00 00       	mov    $0x1,%ebx
80104558:	e9 13 ff ff ff       	jmp    80104470 <procdump+0x10>
8010455d:	8d 76 00             	lea    0x0(%esi),%esi
        getcallerpcs((uint*)p->context->ebp+2, pc);
80104560:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104563:	83 ec 08             	sub    $0x8,%esp
        for(i=0; i<10 && pc[i] != 0; i++)
80104566:	31 db                	xor    %ebx,%ebx
        getcallerpcs((uint*)p->context->ebp+2, pc);
80104568:	50                   	push   %eax
80104569:	8b 46 20             	mov    0x20(%esi),%eax
8010456c:	8b 40 0c             	mov    0xc(%eax),%eax
8010456f:	83 c0 08             	add    $0x8,%eax
80104572:	50                   	push   %eax
80104573:	e8 28 06 00 00       	call   80104ba0 <getcallerpcs>
80104578:	83 c4 10             	add    $0x10,%esp
8010457b:	90                   	nop
8010457c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        for(i=0; i<10 && pc[i] != 0; i++)
80104580:	8b 44 9d c0          	mov    -0x40(%ebp,%ebx,4),%eax
80104584:	85 c0                	test   %eax,%eax
80104586:	74 9a                	je     80104522 <procdump+0xc2>
          cprintf(" %p", pc[i]);
80104588:	83 ec 08             	sub    $0x8,%esp
        for(i=0; i<10 && pc[i] != 0; i++)
8010458b:	83 c3 01             	add    $0x1,%ebx
          cprintf(" %p", pc[i]);
8010458e:	50                   	push   %eax
8010458f:	68 a2 79 10 80       	push   $0x801079a2
80104594:	e8 a7 c0 ff ff       	call   80100640 <cprintf>
        for(i=0; i<10 && pc[i] != 0; i++)
80104599:	83 c4 10             	add    $0x10,%esp
8010459c:	83 fb 0a             	cmp    $0xa,%ebx
8010459f:	75 df                	jne    80104580 <procdump+0x120>
801045a1:	bf 68 62 01 00       	mov    $0x16268,%edi
801045a6:	eb 83                	jmp    8010452b <procdump+0xcb>
801045a8:	90                   	nop
801045a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
}
801045b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045b3:	5b                   	pop    %ebx
801045b4:	5e                   	pop    %esi
801045b5:	5f                   	pop    %edi
801045b6:	5d                   	pop    %ebp
801045b7:	c3                   	ret    
801045b8:	90                   	nop
801045b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801045c0 <mygrowproc>:


int mygrowproc(int n){
801045c0:	55                   	push   %ebp
801045c1:	89 e5                	mov    %esp,%ebp
801045c3:	57                   	push   %edi
801045c4:	56                   	push   %esi
801045c5:	53                   	push   %ebx
801045c6:	83 ec 1c             	sub    $0x1c,%esp
  struct vma *vm = proc->vm;
801045c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  int start = proc->sz;
  int pre=0;
  int i,k;
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801045cf:	8b b8 88 00 00 00    	mov    0x88(%eax),%edi
  struct vma *vm = proc->vm;
801045d5:	8d 88 80 00 00 00    	lea    0x80(%eax),%ecx
801045db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  int start = proc->sz;
801045de:	8b 18                	mov    (%eax),%ebx
  struct vma *vm = proc->vm;
801045e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801045e3:	85 ff                	test   %edi,%edi
801045e5:	0f 84 d5 00 00 00    	je     801046c0 <mygrowproc+0x100>
  {
    if (start + n < vm[i].start)
801045eb:	8d 04 7f             	lea    (%edi,%edi,2),%eax
801045ee:	8d 14 81             	lea    (%ecx,%eax,4),%edx
801045f1:	8b 45 08             	mov    0x8(%ebp),%eax
801045f4:	8b 0a                	mov    (%edx),%ecx
801045f6:	01 d8                	add    %ebx,%eax
801045f8:	39 c8                	cmp    %ecx,%eax
801045fa:	7d 22                	jge    8010461e <mygrowproc+0x5e>
801045fc:	e9 cf 00 00 00       	jmp    801046d0 <mygrowproc+0x110>
80104601:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104608:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010460b:	8d 14 40             	lea    (%eax,%eax,2),%edx
8010460e:	8d 14 96             	lea    (%esi,%edx,4),%edx
80104611:	8b 75 08             	mov    0x8(%ebp),%esi
80104614:	8b 0a                	mov    (%edx),%ecx
80104616:	01 de                	add    %ebx,%esi
80104618:	39 ce                	cmp    %ecx,%esi
8010461a:	7c 0e                	jl     8010462a <mygrowproc+0x6a>
8010461c:	89 c7                	mov    %eax,%edi
    {
      break;
    }
    start = vm[i].start + vm[i].length;
8010461e:	8b 5a 04             	mov    0x4(%edx),%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104621:	8b 42 08             	mov    0x8(%edx),%eax
    start = vm[i].start + vm[i].length;
80104624:	01 cb                	add    %ecx,%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104626:	85 c0                	test   %eax,%eax
80104628:	75 de                	jne    80104608 <mygrowproc+0x48>
8010462a:	8b 75 e0             	mov    -0x20(%ebp),%esi
8010462d:	b9 01 00 00 00       	mov    $0x1,%ecx
80104632:	8d 96 8c 00 00 00    	lea    0x8c(%esi),%edx
80104638:	90                   	nop
80104639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pre = i;
  }
  for(k = 1; k < 10; ++k){
    if(vm[k].next == -1){
80104640:	83 7a 08 ff          	cmpl   $0xffffffff,0x8(%edx)
80104644:	74 2a                	je     80104670 <mygrowproc+0xb0>
  for(k = 1; k < 10; ++k){
80104646:	83 c1 01             	add    $0x1,%ecx
80104649:	83 c2 0c             	add    $0xc,%edx
8010464c:	83 f9 0a             	cmp    $0xa,%ecx
8010464f:	75 ef                	jne    80104640 <mygrowproc+0x80>
      myallocuvm(proc->pgdir, start , start + n);
      switchuvm(proc);
      return start;
    }
  }
  switchuvm(proc);
80104651:	83 ec 0c             	sub    $0xc,%esp
80104654:	ff 75 e0             	pushl  -0x20(%ebp)
  return 0; 
80104657:	31 db                	xor    %ebx,%ebx
  switchuvm(proc);
80104659:	e8 42 2c 00 00       	call   801072a0 <switchuvm>
  return 0; 
8010465e:	83 c4 10             	add    $0x10,%esp
}
80104661:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104664:	89 d8                	mov    %ebx,%eax
80104666:	5b                   	pop    %ebx
80104667:	5e                   	pop    %esi
80104668:	5f                   	pop    %edi
80104669:	5d                   	pop    %ebp
8010466a:	c3                   	ret    
8010466b:	90                   	nop
8010466c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      vm[k].next = i;
80104670:	89 42 08             	mov    %eax,0x8(%edx)
      vm[k].length = n;
80104673:	8b 45 08             	mov    0x8(%ebp),%eax
      myallocuvm(proc->pgdir, start , start + n);
80104676:	83 ec 04             	sub    $0x4,%esp
      vm[k].start = start;
80104679:	89 1a                	mov    %ebx,(%edx)
      vm[k].length = n;
8010467b:	89 42 04             	mov    %eax,0x4(%edx)
      vm[pre].next = k;
8010467e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
80104681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80104684:	89 4c 87 08          	mov    %ecx,0x8(%edi,%eax,4)
      myallocuvm(proc->pgdir, start , start + n);
80104688:	8b 45 08             	mov    0x8(%ebp),%eax
8010468b:	01 d8                	add    %ebx,%eax
8010468d:	50                   	push   %eax
8010468e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104694:	53                   	push   %ebx
80104695:	ff 70 04             	pushl  0x4(%eax)
80104698:	e8 13 2f 00 00       	call   801075b0 <myallocuvm>
      switchuvm(proc);
8010469d:	58                   	pop    %eax
8010469e:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
801046a5:	e8 f6 2b 00 00       	call   801072a0 <switchuvm>
      return start;
801046aa:	83 c4 10             	add    $0x10,%esp
}
801046ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
801046b0:	89 d8                	mov    %ebx,%eax
801046b2:	5b                   	pop    %ebx
801046b3:	5e                   	pop    %esi
801046b4:	5f                   	pop    %edi
801046b5:	5d                   	pop    %ebp
801046b6:	c3                   	ret    
801046b7:	89 f6                	mov    %esi,%esi
801046b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801046c0:	31 c0                	xor    %eax,%eax
801046c2:	e9 63 ff ff ff       	jmp    8010462a <mygrowproc+0x6a>
801046c7:	89 f6                	mov    %esi,%esi
801046c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if (start + n < vm[i].start)
801046d0:	89 f8                	mov    %edi,%eax
  int pre=0;
801046d2:	31 ff                	xor    %edi,%edi
801046d4:	e9 51 ff ff ff       	jmp    8010462a <mygrowproc+0x6a>
801046d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801046e0 <myreduceproc>:

int myreduceproc(int start){
801046e0:	55                   	push   %ebp
801046e1:	89 e5                	mov    %esp,%ebp
801046e3:	57                   	push   %edi
801046e4:	56                   	push   %esi
801046e5:	53                   	push   %ebx
801046e6:	83 ec 0c             	sub    $0xc,%esp
  int prev=0;
  int i;
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
801046e9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
int myreduceproc(int start){
801046f0:	8b 75 08             	mov    0x8(%ebp),%esi
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
801046f3:	8b 9a 88 00 00 00    	mov    0x88(%edx),%ebx
801046f9:	85 db                	test   %ebx,%ebx
801046fb:	74 2f                	je     8010472c <myreduceproc+0x4c>
      if(proc->vm[i].start == start){
801046fd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
80104700:	3b b4 82 80 00 00 00 	cmp    0x80(%edx,%eax,4),%esi
80104707:	75 15                	jne    8010471e <myreduceproc+0x3e>
80104709:	eb 45                	jmp    80104750 <myreduceproc+0x70>
8010470b:	90                   	nop
8010470c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104710:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
80104713:	39 b4 8a 80 00 00 00 	cmp    %esi,0x80(%edx,%ecx,4)
8010471a:	74 38                	je     80104754 <myreduceproc+0x74>
8010471c:	89 c3                	mov    %eax,%ebx
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
8010471e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
80104721:	8b 84 82 88 00 00 00 	mov    0x88(%edx,%eax,4),%eax
80104728:	85 c0                	test   %eax,%eax
8010472a:	75 e4                	jne    80104710 <myreduceproc+0x30>
        switchuvm(proc);
        return 0;
      }
      prev=i;
  }
  cprintf("warning: free vma at %x! \n",start);
8010472c:	83 ec 08             	sub    $0x8,%esp
8010472f:	56                   	push   %esi
80104730:	68 7f 80 10 80       	push   $0x8010807f
80104735:	e8 06 bf ff ff       	call   80100640 <cprintf>
  return -1;
8010473a:	83 c4 10             	add    $0x10,%esp
}
8010473d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80104740:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104745:	5b                   	pop    %ebx
80104746:	5e                   	pop    %esi
80104747:	5f                   	pop    %edi
80104748:	5d                   	pop    %ebp
80104749:	c3                   	ret    
8010474a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(proc->vm[i].start == start){
80104750:	89 d8                	mov    %ebx,%eax
  int prev=0;
80104752:	31 db                	xor    %ebx,%ebx
        mydeallocuvm(proc->pgdir,start,start+proc->vm[i].length);
80104754:	8d 3c 40             	lea    (%eax,%eax,2),%edi
80104757:	83 ec 04             	sub    $0x4,%esp
8010475a:	c1 e7 02             	shl    $0x2,%edi
8010475d:	8b 84 3a 84 00 00 00 	mov    0x84(%edx,%edi,1),%eax
80104764:	01 f0                	add    %esi,%eax
80104766:	50                   	push   %eax
80104767:	56                   	push   %esi
80104768:	ff 72 04             	pushl  0x4(%edx)
8010476b:	e8 e0 2e 00 00       	call   80107650 <mydeallocuvm>
        proc->vm[prev].next = proc->vm[i].next;
80104770:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104776:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
80104779:	01 c7                	add    %eax,%edi
8010477b:	8b 8f 88 00 00 00    	mov    0x88(%edi),%ecx
80104781:	89 8c 90 88 00 00 00 	mov    %ecx,0x88(%eax,%edx,4)
        proc->vm[i].next=-1;
80104788:	c7 87 88 00 00 00 ff 	movl   $0xffffffff,0x88(%edi)
8010478f:	ff ff ff 
        switchuvm(proc);
80104792:	89 04 24             	mov    %eax,(%esp)
80104795:	e8 06 2b 00 00       	call   801072a0 <switchuvm>
        return 0;
8010479a:	83 c4 10             	add    $0x10,%esp
}
8010479d:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
801047a0:	31 c0                	xor    %eax,%eax
}
801047a2:	5b                   	pop    %ebx
801047a3:	5e                   	pop    %esi
801047a4:	5f                   	pop    %edi
801047a5:	5d                   	pop    %ebp
801047a6:	c3                   	ret    
801047a7:	89 f6                	mov    %esi,%esi
801047a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801047b0 <clone>:

// malloc space for new stack then pass to clone
int clone(void(*fcn)(void*), void* arg, void* stack)
{
801047b0:	55                   	push   %ebp
801047b1:	89 e5                	mov    %esp,%ebp
801047b3:	57                   	push   %edi
801047b4:	56                   	push   %esi
801047b5:	53                   	push   %ebx
801047b6:	83 ec 24             	sub    $0x24,%esp
  cprintf("in clone, stack start addr = %p\n", stack);
801047b9:	ff 75 10             	pushl  0x10(%ebp)
801047bc:	68 e4 80 10 80       	push   $0x801080e4
801047c1:	e8 7a be ff ff       	call   80100640 <cprintf>
    if(ptable[i].amount < min){
801047c6:	a1 80 3a 11 80       	mov    0x80113a80,%eax
  int min = NPROC + 1;
801047cb:	b9 21 00 00 00       	mov    $0x21,%ecx
  struct proc *curproc = proc;  // 调用 clone 的进程
801047d0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  int min = NPROC + 1;
801047d7:	83 f8 21             	cmp    $0x21,%eax
  struct proc *curproc = proc;  // 调用 clone 的进程
801047da:	89 55 e0             	mov    %edx,-0x20(%ebp)
  int min = NPROC + 1;
801047dd:	0f 4d c1             	cmovge %ecx,%eax
  struct proc *np;
  int ptableIndex = getPtableIndex();

  acquire(&ptable[ptableIndex].lock);
801047e0:	31 db                	xor    %ebx,%ebx
801047e2:	3b 05 b8 5a 11 80    	cmp    0x80115ab8,%eax
801047e8:	0f 9f c3             	setg   %bl
801047eb:	69 c3 38 20 00 00    	imul   $0x2038,%ebx,%eax
801047f1:	05 84 3a 11 80       	add    $0x80113a84,%eax
801047f6:	89 04 24             	mov    %eax,(%esp)
801047f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801047fc:	e8 df 02 00 00       	call   80104ae0 <acquire>

  // allocate a PCB
  if((np = allocproc(ptableIndex)) == 0)
80104801:	89 d8                	mov    %ebx,%eax
80104803:	e8 c8 ef ff ff       	call   801037d0 <allocproc>
80104808:	83 c4 10             	add    $0x10,%esp
8010480b:	85 c0                	test   %eax,%eax
8010480d:	0f 84 d3 00 00 00    	je     801048e6 <clone+0x136>
   return -1; 
  
  // For clone, don't need to copy entire address space like fork
  np->pgdir = curproc->pgdir;  // 线程间公用页表
80104813:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104816:	89 c3                	mov    %eax,%ebx
  np->sz = curproc->sz;
  np->pthread = curproc;       // exit 时唤醒用
  np->parent = 0;
  *np->tf = *curproc->tf;      // 继承 trapframe
80104818:	b9 13 00 00 00       	mov    $0x13,%ecx
8010481d:	8b 7b 1c             	mov    0x1c(%ebx),%edi
  np->pgdir = curproc->pgdir;  // 线程间公用页表
80104820:	8b 42 04             	mov    0x4(%edx),%eax
80104823:	89 43 04             	mov    %eax,0x4(%ebx)
  np->sz = curproc->sz;
80104826:	8b 02                	mov    (%edx),%eax
  np->pthread = curproc;       // exit 时唤醒用
80104828:	89 93 f8 00 00 00    	mov    %edx,0xf8(%ebx)
  np->parent = 0;
8010482e:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
  np->sz = curproc->sz;
80104835:	89 03                	mov    %eax,(%ebx)
  *np->tf = *curproc->tf;      // 继承 trapframe
80104837:	8b 72 1c             	mov    0x1c(%edx),%esi
8010483a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  int* sp = stack + 4096 - 8;

  // Clone may need to change other registers than ones seen in fork
  np->tf->eip = (int)fcn;
8010483c:	8b 4d 08             	mov    0x8(%ebp),%ecx

  // setup new user stack and some pointers
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
  *sp = 0xffffffff;     // end of stack (fake return PC value)

  for(int i = 0; i < NOFILE; i++)
8010483f:	31 f6                	xor    %esi,%esi
80104841:	89 d7                	mov    %edx,%edi
  np->tf->eip = (int)fcn;
80104843:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104846:	89 48 38             	mov    %ecx,0x38(%eax)
  int* sp = stack + 4096 - 8;
80104849:	8b 45 10             	mov    0x10(%ebp),%eax
  np->tf->esp = (int)sp;  // top of stack
8010484c:	8b 4b 1c             	mov    0x1c(%ebx),%ecx
  int* sp = stack + 4096 - 8;
8010484f:	05 f8 0f 00 00       	add    $0xff8,%eax
  np->tf->esp = (int)sp;  // top of stack
80104854:	89 41 44             	mov    %eax,0x44(%ecx)
  np->tf->ebp = (int)sp;  // 栈帧指针 
80104857:	8b 4b 1c             	mov    0x1c(%ebx),%ecx
8010485a:	89 41 08             	mov    %eax,0x8(%ecx)
  np->tf->eax = 0;    // Clear %eax so that clone returns 0 in the child
8010485d:	8b 43 1c             	mov    0x1c(%ebx),%eax
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
80104860:	8b 4d 10             	mov    0x10(%ebp),%ecx
  np->tf->eax = 0;    // Clear %eax so that clone returns 0 in the child
80104863:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
8010486a:	8b 45 0c             	mov    0xc(%ebp),%eax
  *sp = 0xffffffff;     // end of stack (fake return PC value)
8010486d:	c7 81 f8 0f 00 00 ff 	movl   $0xffffffff,0xff8(%ecx)
80104874:	ff ff ff 
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
80104877:	89 81 fc 0f 00 00    	mov    %eax,0xffc(%ecx)
8010487d:	8d 76 00             	lea    0x0(%esi),%esi
    if(curproc->ofile[i])
80104880:	8b 44 b7 2c          	mov    0x2c(%edi,%esi,4),%eax
80104884:	85 c0                	test   %eax,%eax
80104886:	74 10                	je     80104898 <clone+0xe8>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104888:	83 ec 0c             	sub    $0xc,%esp
8010488b:	50                   	push   %eax
8010488c:	e8 2f c5 ff ff       	call   80100dc0 <filedup>
80104891:	83 c4 10             	add    $0x10,%esp
80104894:	89 44 b3 2c          	mov    %eax,0x2c(%ebx,%esi,4)
  for(int i = 0; i < NOFILE; i++)
80104898:	83 c6 01             	add    $0x1,%esi
8010489b:	83 fe 10             	cmp    $0x10,%esi
8010489e:	75 e0                	jne    80104880 <clone+0xd0>
  np->cwd = idup(curproc->cwd);
801048a0:	83 ec 0c             	sub    $0xc,%esp
801048a3:	ff 77 6c             	pushl  0x6c(%edi)
801048a6:	89 7d e0             	mov    %edi,-0x20(%ebp)
801048a9:	e8 32 cd ff ff       	call   801015e0 <idup>

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801048ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  np->cwd = idup(curproc->cwd);
801048b1:	89 43 6c             	mov    %eax,0x6c(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801048b4:	8d 43 70             	lea    0x70(%ebx),%eax
801048b7:	83 c4 0c             	add    $0xc,%esp
801048ba:	6a 10                	push   $0x10
801048bc:	83 c2 70             	add    $0x70,%edx
801048bf:	52                   	push   %edx
801048c0:	50                   	push   %eax
801048c1:	e8 0a 06 00 00       	call   80104ed0 <safestrcpy>
  
  int pid = np->pid;
  
  
  np->state = RUNNABLE;
801048c6:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  int pid = np->pid;
801048cd:	8b 73 10             	mov    0x10(%ebx),%esi
  release(&ptable[ptableIndex].lock);
801048d0:	58                   	pop    %eax
801048d1:	ff 75 e4             	pushl  -0x1c(%ebp)
801048d4:	e8 c7 03 00 00       	call   80104ca0 <release>
 
  // return the ID of the new thread
  return pid;
801048d9:	83 c4 10             	add    $0x10,%esp
}
801048dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048df:	89 f0                	mov    %esi,%eax
801048e1:	5b                   	pop    %ebx
801048e2:	5e                   	pop    %esi
801048e3:	5f                   	pop    %edi
801048e4:	5d                   	pop    %ebp
801048e5:	c3                   	ret    
   return -1; 
801048e6:	be ff ff ff ff       	mov    $0xffffffff,%esi
801048eb:	eb ef                	jmp    801048dc <clone+0x12c>
801048ed:	8d 76 00             	lea    0x0(%esi),%esi

801048f0 <join>:

int join(void **stack)
{
801048f0:	55                   	push   %ebp
801048f1:	89 e5                	mov    %esp,%ebp
801048f3:	57                   	push   %edi
801048f4:	56                   	push   %esi
801048f5:	53                   	push   %ebx
801048f6:	83 ec 24             	sub    $0x24,%esp
  cprintf("in join, stack pointer = %p\n",*stack);
801048f9:	8b 45 08             	mov    0x8(%ebp),%eax
801048fc:	ff 30                	pushl  (%eax)
801048fe:	68 9a 80 10 80       	push   $0x8010809a
80104903:	e8 38 bd ff ff       	call   80100640 <cprintf>
  struct proc *curproc = proc;
80104908:	65 8b 35 04 00 00 00 	mov    %gs:0x4,%esi
8010490f:	83 c4 10             	add    $0x10,%esp

  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(i = 0; i < CPUNUMBER; ++i){
      acquire(&ptable[i].lock);
80104912:	83 ec 0c             	sub    $0xc,%esp
    havekids = 0;
80104915:	31 ff                	xor    %edi,%edi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104917:	bb b8 3a 11 80       	mov    $0x80113ab8,%ebx
      acquire(&ptable[i].lock);
8010491c:	68 84 3a 11 80       	push   $0x80113a84
80104921:	e8 ba 01 00 00       	call   80104ae0 <acquire>
80104926:	83 c4 10             	add    $0x10,%esp
80104929:	eb 13                	jmp    8010493e <join+0x4e>
8010492b:	90                   	nop
8010492c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104930:	81 c3 00 01 00 00    	add    $0x100,%ebx
80104936:	81 fb b8 5a 11 80    	cmp    $0x80115ab8,%ebx
8010493c:	74 25                	je     80104963 <join+0x73>
        if(p->pthread != curproc)
8010493e:	3b b3 f8 00 00 00    	cmp    0xf8(%ebx),%esi
80104944:	75 ea                	jne    80104930 <join+0x40>
          continue;
        havekids = 1;
        if(p->state == ZOMBIE){
80104946:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010494a:	0f 84 d8 00 00 00    	je     80104a28 <join+0x138>
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104950:	81 c3 00 01 00 00    	add    $0x100,%ebx
        havekids = 1;
80104956:	bf 01 00 00 00       	mov    $0x1,%edi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
8010495b:	81 fb b8 5a 11 80    	cmp    $0x80115ab8,%ebx
80104961:	75 db                	jne    8010493e <join+0x4e>
          ptable[i].amount -= 1;
          release(&ptable[i].lock);
          return pid;
        }
      }
      release(&ptable[i].lock);
80104963:	83 ec 0c             	sub    $0xc,%esp
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104966:	bb f0 5a 11 80       	mov    $0x80115af0,%ebx
      release(&ptable[i].lock);
8010496b:	68 84 3a 11 80       	push   $0x80113a84
80104970:	e8 2b 03 00 00       	call   80104ca0 <release>
      acquire(&ptable[i].lock);
80104975:	c7 04 24 bc 5a 11 80 	movl   $0x80115abc,(%esp)
8010497c:	e8 5f 01 00 00       	call   80104ae0 <acquire>
80104981:	83 c4 10             	add    $0x10,%esp
80104984:	eb 18                	jmp    8010499e <join+0xae>
80104986:	8d 76 00             	lea    0x0(%esi),%esi
80104989:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
80104990:	81 c3 00 01 00 00    	add    $0x100,%ebx
80104996:	81 fb f0 7a 11 80    	cmp    $0x80117af0,%ebx
8010499c:	74 25                	je     801049c3 <join+0xd3>
        if(p->pthread != curproc)
8010499e:	39 b3 f8 00 00 00    	cmp    %esi,0xf8(%ebx)
801049a4:	75 ea                	jne    80104990 <join+0xa0>
        if(p->state == ZOMBIE){
801049a6:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801049aa:	0f 84 e8 00 00 00    	je     80104a98 <join+0x1a8>
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801049b0:	81 c3 00 01 00 00    	add    $0x100,%ebx
        havekids = 1;
801049b6:	bf 01 00 00 00       	mov    $0x1,%edi
      for(p = ptable[i].proc; p < &ptable[i].proc[NPROC]; p++){
801049bb:	81 fb f0 7a 11 80    	cmp    $0x80117af0,%ebx
801049c1:	75 db                	jne    8010499e <join+0xae>
      release(&ptable[i].lock);
801049c3:	83 ec 0c             	sub    $0xc,%esp
801049c6:	68 bc 5a 11 80       	push   $0x80115abc
801049cb:	e8 d0 02 00 00       	call   80104ca0 <release>
    }
    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049d0:	83 c4 10             	add    $0x10,%esp
801049d3:	85 ff                	test   %edi,%edi
801049d5:	0f 84 c9 00 00 00    	je     80104aa4 <join+0x1b4>
801049db:	8b 4e 28             	mov    0x28(%esi),%ecx
801049de:	85 c9                	test   %ecx,%ecx
801049e0:	0f 85 be 00 00 00    	jne    80104aa4 <join+0x1b4>
      return -1;
    }
    acquire(&ptable[proc->cpuid].lock);
801049e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ec:	83 ec 0c             	sub    $0xc,%esp
801049ef:	69 40 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%eax
801049f6:	05 84 3a 11 80       	add    $0x80113a84,%eax
801049fb:	50                   	push   %eax
801049fc:	e8 df 00 00 00       	call   80104ae0 <acquire>
    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable[proc->cpuid].lock);  //DOC: wait-sleep
80104a01:	58                   	pop    %eax
80104a02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a08:	5a                   	pop    %edx
80104a09:	69 40 14 38 20 00 00 	imul   $0x2038,0x14(%eax),%eax
80104a10:	05 84 3a 11 80       	add    $0x80113a84,%eax
80104a15:	50                   	push   %eax
80104a16:	56                   	push   %esi
80104a17:	e8 64 f4 ff ff       	call   80103e80 <sleep>
    havekids = 0;
80104a1c:	83 c4 10             	add    $0x10,%esp
80104a1f:	e9 ee fe ff ff       	jmp    80104912 <join+0x22>
80104a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(i = 0; i < CPUNUMBER; ++i){
80104a28:	31 f6                	xor    %esi,%esi
      acquire(&ptable[i].lock);
80104a2a:	bf 84 3a 11 80       	mov    $0x80113a84,%edi
          int pid = p->pid;
80104a2f:	8b 43 10             	mov    0x10(%ebx),%eax
          kfree(p->kstack);
80104a32:	83 ec 0c             	sub    $0xc,%esp
80104a35:	ff 73 08             	pushl  0x8(%ebx)
          int pid = p->pid;
80104a38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          kfree(p->kstack);
80104a3b:	e8 c0 d8 ff ff       	call   80102300 <kfree>
          ptable[i].amount -= 1;
80104a40:	69 d6 38 20 00 00    	imul   $0x2038,%esi,%edx
          p->kstack = 0;
80104a46:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
          p->state = UNUSED;
80104a4d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
          p->pid = 0;
80104a54:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
          p->parent = 0;
80104a5b:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
          p->pthread = 0;
80104a62:	c7 83 f8 00 00 00 00 	movl   $0x0,0xf8(%ebx)
80104a69:	00 00 00 
          p->name[0] = 0;
80104a6c:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
          p->killed = 0;
80104a70:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
          release(&ptable[i].lock);
80104a77:	89 3c 24             	mov    %edi,(%esp)
          ptable[i].amount -= 1;
80104a7a:	83 aa 80 3a 11 80 01 	subl   $0x1,-0x7feec580(%edx)
          release(&ptable[i].lock);
80104a81:	e8 1a 02 00 00       	call   80104ca0 <release>
          return pid;
80104a86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a89:	83 c4 10             	add    $0x10,%esp
  }

  return 0;
}
80104a8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a8f:	5b                   	pop    %ebx
80104a90:	5e                   	pop    %esi
80104a91:	5f                   	pop    %edi
80104a92:	5d                   	pop    %ebp
80104a93:	c3                   	ret    
80104a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(i = 0; i < CPUNUMBER; ++i){
80104a98:	be 01 00 00 00       	mov    $0x1,%esi
      acquire(&ptable[i].lock);
80104a9d:	bf bc 5a 11 80       	mov    $0x80115abc,%edi
80104aa2:	eb 8b                	jmp    80104a2f <join+0x13f>
}
80104aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80104aa7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104aac:	5b                   	pop    %ebx
80104aad:	5e                   	pop    %esi
80104aae:	5f                   	pop    %edi
80104aaf:	5d                   	pop    %ebp
80104ab0:	c3                   	ret    
80104ab1:	66 90                	xchg   %ax,%ax
80104ab3:	66 90                	xchg   %ax,%ax
80104ab5:	66 90                	xchg   %ax,%ax
80104ab7:	66 90                	xchg   %ax,%ax
80104ab9:	66 90                	xchg   %ax,%ax
80104abb:	66 90                	xchg   %ax,%ax
80104abd:	66 90                	xchg   %ax,%ax
80104abf:	90                   	nop

80104ac0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ac0:	55                   	push   %ebp
80104ac1:	89 e5                	mov    %esp,%ebp
80104ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104ac9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
80104acf:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104ad2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ad9:	5d                   	pop    %ebp
80104ada:	c3                   	ret    
80104adb:	90                   	nop
80104adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104ae0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104ae0:	55                   	push   %ebp
80104ae1:	89 e5                	mov    %esp,%ebp
80104ae3:	53                   	push   %ebx
80104ae4:	83 ec 04             	sub    $0x4,%esp
80104ae7:	9c                   	pushf  
80104ae8:	5a                   	pop    %edx
  asm volatile("cli");
80104ae9:	fa                   	cli    
{
  int eflags;

  eflags = readeflags();
  cli();
  if(cpu->ncli == 0)
80104aea:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80104af1:	8b 81 ac 00 00 00    	mov    0xac(%ecx),%eax
80104af7:	85 c0                	test   %eax,%eax
80104af9:	75 0c                	jne    80104b07 <acquire+0x27>
    cpu->intena = eflags & FL_IF;
80104afb:	81 e2 00 02 00 00    	and    $0x200,%edx
80104b01:	89 91 b0 00 00 00    	mov    %edx,0xb0(%ecx)
  if(holding(lk))
80104b07:	8b 55 08             	mov    0x8(%ebp),%edx
  cpu->ncli += 1;
80104b0a:	83 c0 01             	add    $0x1,%eax
80104b0d:	89 81 ac 00 00 00    	mov    %eax,0xac(%ecx)
  return lock->locked && lock->cpu == cpu;
80104b13:	8b 02                	mov    (%edx),%eax
80104b15:	85 c0                	test   %eax,%eax
80104b17:	74 05                	je     80104b1e <acquire+0x3e>
80104b19:	39 4a 08             	cmp    %ecx,0x8(%edx)
80104b1c:	74 74                	je     80104b92 <acquire+0xb2>
  asm volatile("lock; xchgl %0, %1" :
80104b1e:	b9 01 00 00 00       	mov    $0x1,%ecx
80104b23:	90                   	nop
80104b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104b28:	89 c8                	mov    %ecx,%eax
80104b2a:	f0 87 02             	lock xchg %eax,(%edx)
  while(xchg(&lk->locked, 1) != 0)
80104b2d:	85 c0                	test   %eax,%eax
80104b2f:	75 f7                	jne    80104b28 <acquire+0x48>
  __sync_synchronize();
80104b31:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = cpu;
80104b36:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b39:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  for(i = 0; i < 10; i++){
80104b3f:	31 d2                	xor    %edx,%edx
  lk->cpu = cpu;
80104b41:	89 41 08             	mov    %eax,0x8(%ecx)
  getcallerpcs(&lk, lk->pcs);
80104b44:	83 c1 0c             	add    $0xc,%ecx
  ebp = (uint*)v - 2;
80104b47:	89 e8                	mov    %ebp,%eax
80104b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b50:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104b56:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104b5c:	77 1a                	ja     80104b78 <acquire+0x98>
    pcs[i] = ebp[1];     // saved %eip
80104b5e:	8b 58 04             	mov    0x4(%eax),%ebx
80104b61:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104b64:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104b67:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104b69:	83 fa 0a             	cmp    $0xa,%edx
80104b6c:	75 e2                	jne    80104b50 <acquire+0x70>
}
80104b6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b71:	c9                   	leave  
80104b72:	c3                   	ret    
80104b73:	90                   	nop
80104b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104b78:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104b7b:	83 c1 28             	add    $0x28,%ecx
80104b7e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104b80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b86:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104b89:	39 c8                	cmp    %ecx,%eax
80104b8b:	75 f3                	jne    80104b80 <acquire+0xa0>
}
80104b8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b90:	c9                   	leave  
80104b91:	c3                   	ret    
    panic("acquire");
80104b92:	83 ec 0c             	sub    $0xc,%esp
80104b95:	68 20 81 10 80       	push   $0x80108120
80104b9a:	e8 d1 b7 ff ff       	call   80100370 <panic>
80104b9f:	90                   	nop

80104ba0 <getcallerpcs>:
{
80104ba0:	55                   	push   %ebp
  for(i = 0; i < 10; i++){
80104ba1:	31 d2                	xor    %edx,%edx
{
80104ba3:	89 e5                	mov    %esp,%ebp
80104ba5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104ba6:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
80104bac:	83 e8 08             	sub    $0x8,%eax
80104baf:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bb0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104bb6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104bbc:	77 1a                	ja     80104bd8 <getcallerpcs+0x38>
    pcs[i] = ebp[1];     // saved %eip
80104bbe:	8b 58 04             	mov    0x4(%eax),%ebx
80104bc1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104bc4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104bc7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104bc9:	83 fa 0a             	cmp    $0xa,%edx
80104bcc:	75 e2                	jne    80104bb0 <getcallerpcs+0x10>
}
80104bce:	5b                   	pop    %ebx
80104bcf:	5d                   	pop    %ebp
80104bd0:	c3                   	ret    
80104bd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bd8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104bdb:	83 c1 28             	add    $0x28,%ecx
80104bde:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104be0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104be6:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104be9:	39 c1                	cmp    %eax,%ecx
80104beb:	75 f3                	jne    80104be0 <getcallerpcs+0x40>
}
80104bed:	5b                   	pop    %ebx
80104bee:	5d                   	pop    %ebp
80104bef:	c3                   	ret    

80104bf0 <holding>:
{
80104bf0:	55                   	push   %ebp
80104bf1:	89 e5                	mov    %esp,%ebp
80104bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
80104bf6:	8b 02                	mov    (%edx),%eax
80104bf8:	85 c0                	test   %eax,%eax
80104bfa:	74 14                	je     80104c10 <holding+0x20>
80104bfc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c02:	39 42 08             	cmp    %eax,0x8(%edx)
}
80104c05:	5d                   	pop    %ebp
  return lock->locked && lock->cpu == cpu;
80104c06:	0f 94 c0             	sete   %al
80104c09:	0f b6 c0             	movzbl %al,%eax
}
80104c0c:	c3                   	ret    
80104c0d:	8d 76 00             	lea    0x0(%esi),%esi
80104c10:	31 c0                	xor    %eax,%eax
80104c12:	5d                   	pop    %ebp
80104c13:	c3                   	ret    
80104c14:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104c1a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104c20 <pushcli>:
{
80104c20:	55                   	push   %ebp
80104c21:	89 e5                	mov    %esp,%ebp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c23:	9c                   	pushf  
80104c24:	59                   	pop    %ecx
  asm volatile("cli");
80104c25:	fa                   	cli    
  if(cpu->ncli == 0)
80104c26:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c2d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104c33:	85 c0                	test   %eax,%eax
80104c35:	75 0c                	jne    80104c43 <pushcli+0x23>
    cpu->intena = eflags & FL_IF;
80104c37:	81 e1 00 02 00 00    	and    $0x200,%ecx
80104c3d:	89 8a b0 00 00 00    	mov    %ecx,0xb0(%edx)
  cpu->ncli += 1;
80104c43:	83 c0 01             	add    $0x1,%eax
80104c46:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
}
80104c4c:	5d                   	pop    %ebp
80104c4d:	c3                   	ret    
80104c4e:	66 90                	xchg   %ax,%ax

80104c50 <popcli>:

void
popcli(void)
{
80104c50:	55                   	push   %ebp
80104c51:	89 e5                	mov    %esp,%ebp
80104c53:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c56:	9c                   	pushf  
80104c57:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104c58:	f6 c4 02             	test   $0x2,%ah
80104c5b:	75 2c                	jne    80104c89 <popcli+0x39>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
80104c5d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c64:	83 aa ac 00 00 00 01 	subl   $0x1,0xac(%edx)
80104c6b:	78 0f                	js     80104c7c <popcli+0x2c>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
80104c6d:	75 0b                	jne    80104c7a <popcli+0x2a>
80104c6f:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
80104c75:	85 c0                	test   %eax,%eax
80104c77:	74 01                	je     80104c7a <popcli+0x2a>
  asm volatile("sti");
80104c79:	fb                   	sti    
    sti();
}
80104c7a:	c9                   	leave  
80104c7b:	c3                   	ret    
    panic("popcli");
80104c7c:	83 ec 0c             	sub    $0xc,%esp
80104c7f:	68 3f 81 10 80       	push   $0x8010813f
80104c84:	e8 e7 b6 ff ff       	call   80100370 <panic>
    panic("popcli - interruptible");
80104c89:	83 ec 0c             	sub    $0xc,%esp
80104c8c:	68 28 81 10 80       	push   $0x80108128
80104c91:	e8 da b6 ff ff       	call   80100370 <panic>
80104c96:	8d 76 00             	lea    0x0(%esi),%esi
80104c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ca0 <release>:
{
80104ca0:	55                   	push   %ebp
80104ca1:	89 e5                	mov    %esp,%ebp
80104ca3:	83 ec 08             	sub    $0x8,%esp
80104ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked && lock->cpu == cpu;
80104ca9:	8b 10                	mov    (%eax),%edx
80104cab:	85 d2                	test   %edx,%edx
80104cad:	74 2b                	je     80104cda <release+0x3a>
80104caf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104cb6:	39 50 08             	cmp    %edx,0x8(%eax)
80104cb9:	75 1f                	jne    80104cda <release+0x3a>
  lk->pcs[0] = 0;
80104cbb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104cc2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  __sync_synchronize();
80104cc9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->locked = 0;
80104cce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80104cd4:	c9                   	leave  
  popcli();
80104cd5:	e9 76 ff ff ff       	jmp    80104c50 <popcli>
    panic("release");
80104cda:	83 ec 0c             	sub    $0xc,%esp
80104cdd:	68 46 81 10 80       	push   $0x80108146
80104ce2:	e8 89 b6 ff ff       	call   80100370 <panic>
80104ce7:	66 90                	xchg   %ax,%ax
80104ce9:	66 90                	xchg   %ax,%ax
80104ceb:	66 90                	xchg   %ax,%ax
80104ced:	66 90                	xchg   %ax,%ax
80104cef:	90                   	nop

80104cf0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104cf0:	55                   	push   %ebp
80104cf1:	89 e5                	mov    %esp,%ebp
80104cf3:	57                   	push   %edi
80104cf4:	53                   	push   %ebx
80104cf5:	8b 55 08             	mov    0x8(%ebp),%edx
80104cf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104cfb:	f6 c2 03             	test   $0x3,%dl
80104cfe:	75 05                	jne    80104d05 <memset+0x15>
80104d00:	f6 c1 03             	test   $0x3,%cl
80104d03:	74 13                	je     80104d18 <memset+0x28>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80104d05:	89 d7                	mov    %edx,%edi
80104d07:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d0a:	fc                   	cld    
80104d0b:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104d0d:	5b                   	pop    %ebx
80104d0e:	89 d0                	mov    %edx,%eax
80104d10:	5f                   	pop    %edi
80104d11:	5d                   	pop    %ebp
80104d12:	c3                   	ret    
80104d13:	90                   	nop
80104d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c &= 0xFF;
80104d18:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d1c:	c1 e9 02             	shr    $0x2,%ecx
80104d1f:	89 f8                	mov    %edi,%eax
80104d21:	89 fb                	mov    %edi,%ebx
80104d23:	c1 e0 18             	shl    $0x18,%eax
80104d26:	c1 e3 10             	shl    $0x10,%ebx
80104d29:	09 d8                	or     %ebx,%eax
80104d2b:	09 f8                	or     %edi,%eax
80104d2d:	c1 e7 08             	shl    $0x8,%edi
80104d30:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
80104d32:	89 d7                	mov    %edx,%edi
80104d34:	fc                   	cld    
80104d35:	f3 ab                	rep stos %eax,%es:(%edi)
}
80104d37:	5b                   	pop    %ebx
80104d38:	89 d0                	mov    %edx,%eax
80104d3a:	5f                   	pop    %edi
80104d3b:	5d                   	pop    %ebp
80104d3c:	c3                   	ret    
80104d3d:	8d 76 00             	lea    0x0(%esi),%esi

80104d40 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104d40:	55                   	push   %ebp
80104d41:	89 e5                	mov    %esp,%ebp
80104d43:	57                   	push   %edi
80104d44:	56                   	push   %esi
80104d45:	53                   	push   %ebx
80104d46:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104d49:	8b 75 08             	mov    0x8(%ebp),%esi
80104d4c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104d4f:	85 db                	test   %ebx,%ebx
80104d51:	74 29                	je     80104d7c <memcmp+0x3c>
    if(*s1 != *s2)
80104d53:	0f b6 16             	movzbl (%esi),%edx
80104d56:	0f b6 0f             	movzbl (%edi),%ecx
80104d59:	38 d1                	cmp    %dl,%cl
80104d5b:	75 2b                	jne    80104d88 <memcmp+0x48>
80104d5d:	b8 01 00 00 00       	mov    $0x1,%eax
80104d62:	eb 14                	jmp    80104d78 <memcmp+0x38>
80104d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104d68:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
80104d6c:	83 c0 01             	add    $0x1,%eax
80104d6f:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
80104d74:	38 ca                	cmp    %cl,%dl
80104d76:	75 10                	jne    80104d88 <memcmp+0x48>
  while(n-- > 0){
80104d78:	39 d8                	cmp    %ebx,%eax
80104d7a:	75 ec                	jne    80104d68 <memcmp+0x28>
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
80104d7c:	5b                   	pop    %ebx
  return 0;
80104d7d:	31 c0                	xor    %eax,%eax
}
80104d7f:	5e                   	pop    %esi
80104d80:	5f                   	pop    %edi
80104d81:	5d                   	pop    %ebp
80104d82:	c3                   	ret    
80104d83:	90                   	nop
80104d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return *s1 - *s2;
80104d88:	0f b6 c2             	movzbl %dl,%eax
}
80104d8b:	5b                   	pop    %ebx
      return *s1 - *s2;
80104d8c:	29 c8                	sub    %ecx,%eax
}
80104d8e:	5e                   	pop    %esi
80104d8f:	5f                   	pop    %edi
80104d90:	5d                   	pop    %ebp
80104d91:	c3                   	ret    
80104d92:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104da0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104da0:	55                   	push   %ebp
80104da1:	89 e5                	mov    %esp,%ebp
80104da3:	56                   	push   %esi
80104da4:	53                   	push   %ebx
80104da5:	8b 45 08             	mov    0x8(%ebp),%eax
80104da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104dab:	8b 75 10             	mov    0x10(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104dae:	39 c3                	cmp    %eax,%ebx
80104db0:	73 26                	jae    80104dd8 <memmove+0x38>
80104db2:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
80104db5:	39 c8                	cmp    %ecx,%eax
80104db7:	73 1f                	jae    80104dd8 <memmove+0x38>
    s += n;
    d += n;
    while(n-- > 0)
80104db9:	85 f6                	test   %esi,%esi
80104dbb:	8d 56 ff             	lea    -0x1(%esi),%edx
80104dbe:	74 0f                	je     80104dcf <memmove+0x2f>
      *--d = *--s;
80104dc0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104dc4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    while(n-- > 0)
80104dc7:	83 ea 01             	sub    $0x1,%edx
80104dca:	83 fa ff             	cmp    $0xffffffff,%edx
80104dcd:	75 f1                	jne    80104dc0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104dcf:	5b                   	pop    %ebx
80104dd0:	5e                   	pop    %esi
80104dd1:	5d                   	pop    %ebp
80104dd2:	c3                   	ret    
80104dd3:	90                   	nop
80104dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
80104dd8:	31 d2                	xor    %edx,%edx
80104dda:	85 f6                	test   %esi,%esi
80104ddc:	74 f1                	je     80104dcf <memmove+0x2f>
80104dde:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80104de0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104de4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80104de7:	83 c2 01             	add    $0x1,%edx
    while(n-- > 0)
80104dea:	39 d6                	cmp    %edx,%esi
80104dec:	75 f2                	jne    80104de0 <memmove+0x40>
}
80104dee:	5b                   	pop    %ebx
80104def:	5e                   	pop    %esi
80104df0:	5d                   	pop    %ebp
80104df1:	c3                   	ret    
80104df2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104df9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104e00 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e00:	55                   	push   %ebp
80104e01:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80104e03:	5d                   	pop    %ebp
  return memmove(dst, src, n);
80104e04:	eb 9a                	jmp    80104da0 <memmove>
80104e06:	8d 76 00             	lea    0x0(%esi),%esi
80104e09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104e10 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	57                   	push   %edi
80104e14:	56                   	push   %esi
80104e15:	8b 7d 10             	mov    0x10(%ebp),%edi
80104e18:	53                   	push   %ebx
80104e19:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  while(n > 0 && *p && *p == *q)
80104e1f:	85 ff                	test   %edi,%edi
80104e21:	74 2f                	je     80104e52 <strncmp+0x42>
80104e23:	0f b6 01             	movzbl (%ecx),%eax
80104e26:	0f b6 1e             	movzbl (%esi),%ebx
80104e29:	84 c0                	test   %al,%al
80104e2b:	74 37                	je     80104e64 <strncmp+0x54>
80104e2d:	38 c3                	cmp    %al,%bl
80104e2f:	75 33                	jne    80104e64 <strncmp+0x54>
80104e31:	01 f7                	add    %esi,%edi
80104e33:	eb 13                	jmp    80104e48 <strncmp+0x38>
80104e35:	8d 76 00             	lea    0x0(%esi),%esi
80104e38:	0f b6 01             	movzbl (%ecx),%eax
80104e3b:	84 c0                	test   %al,%al
80104e3d:	74 21                	je     80104e60 <strncmp+0x50>
80104e3f:	0f b6 1a             	movzbl (%edx),%ebx
80104e42:	89 d6                	mov    %edx,%esi
80104e44:	38 d8                	cmp    %bl,%al
80104e46:	75 1c                	jne    80104e64 <strncmp+0x54>
    n--, p++, q++;
80104e48:	8d 56 01             	lea    0x1(%esi),%edx
80104e4b:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104e4e:	39 fa                	cmp    %edi,%edx
80104e50:	75 e6                	jne    80104e38 <strncmp+0x28>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
80104e52:	5b                   	pop    %ebx
    return 0;
80104e53:	31 c0                	xor    %eax,%eax
}
80104e55:	5e                   	pop    %esi
80104e56:	5f                   	pop    %edi
80104e57:	5d                   	pop    %ebp
80104e58:	c3                   	ret    
80104e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e60:	0f b6 5e 01          	movzbl 0x1(%esi),%ebx
  return (uchar)*p - (uchar)*q;
80104e64:	29 d8                	sub    %ebx,%eax
}
80104e66:	5b                   	pop    %ebx
80104e67:	5e                   	pop    %esi
80104e68:	5f                   	pop    %edi
80104e69:	5d                   	pop    %ebp
80104e6a:	c3                   	ret    
80104e6b:	90                   	nop
80104e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104e70 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104e70:	55                   	push   %ebp
80104e71:	89 e5                	mov    %esp,%ebp
80104e73:	56                   	push   %esi
80104e74:	53                   	push   %ebx
80104e75:	8b 45 08             	mov    0x8(%ebp),%eax
80104e78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104e7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104e7e:	89 c2                	mov    %eax,%edx
80104e80:	eb 19                	jmp    80104e9b <strncpy+0x2b>
80104e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104e88:	83 c3 01             	add    $0x1,%ebx
80104e8b:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
80104e8f:	83 c2 01             	add    $0x1,%edx
80104e92:	84 c9                	test   %cl,%cl
80104e94:	88 4a ff             	mov    %cl,-0x1(%edx)
80104e97:	74 09                	je     80104ea2 <strncpy+0x32>
80104e99:	89 f1                	mov    %esi,%ecx
80104e9b:	85 c9                	test   %ecx,%ecx
80104e9d:	8d 71 ff             	lea    -0x1(%ecx),%esi
80104ea0:	7f e6                	jg     80104e88 <strncpy+0x18>
    ;
  while(n-- > 0)
80104ea2:	31 c9                	xor    %ecx,%ecx
80104ea4:	85 f6                	test   %esi,%esi
80104ea6:	7e 17                	jle    80104ebf <strncpy+0x4f>
80104ea8:	90                   	nop
80104ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104eb0:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
80104eb4:	89 f3                	mov    %esi,%ebx
80104eb6:	83 c1 01             	add    $0x1,%ecx
80104eb9:	29 cb                	sub    %ecx,%ebx
  while(n-- > 0)
80104ebb:	85 db                	test   %ebx,%ebx
80104ebd:	7f f1                	jg     80104eb0 <strncpy+0x40>
  return os;
}
80104ebf:	5b                   	pop    %ebx
80104ec0:	5e                   	pop    %esi
80104ec1:	5d                   	pop    %ebp
80104ec2:	c3                   	ret    
80104ec3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104ec9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ed0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ed0:	55                   	push   %ebp
80104ed1:	89 e5                	mov    %esp,%ebp
80104ed3:	56                   	push   %esi
80104ed4:	53                   	push   %ebx
80104ed5:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104ed8:	8b 45 08             	mov    0x8(%ebp),%eax
80104edb:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104ede:	85 c9                	test   %ecx,%ecx
80104ee0:	7e 26                	jle    80104f08 <safestrcpy+0x38>
80104ee2:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
80104ee6:	89 c1                	mov    %eax,%ecx
80104ee8:	eb 17                	jmp    80104f01 <safestrcpy+0x31>
80104eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104ef0:	83 c2 01             	add    $0x1,%edx
80104ef3:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
80104ef7:	83 c1 01             	add    $0x1,%ecx
80104efa:	84 db                	test   %bl,%bl
80104efc:	88 59 ff             	mov    %bl,-0x1(%ecx)
80104eff:	74 04                	je     80104f05 <safestrcpy+0x35>
80104f01:	39 f2                	cmp    %esi,%edx
80104f03:	75 eb                	jne    80104ef0 <safestrcpy+0x20>
    ;
  *s = 0;
80104f05:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104f08:	5b                   	pop    %ebx
80104f09:	5e                   	pop    %esi
80104f0a:	5d                   	pop    %ebp
80104f0b:	c3                   	ret    
80104f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104f10 <strlen>:

int
strlen(const char *s)
{
80104f10:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104f11:	31 c0                	xor    %eax,%eax
{
80104f13:	89 e5                	mov    %esp,%ebp
80104f15:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104f18:	80 3a 00             	cmpb   $0x0,(%edx)
80104f1b:	74 0c                	je     80104f29 <strlen+0x19>
80104f1d:	8d 76 00             	lea    0x0(%esi),%esi
80104f20:	83 c0 01             	add    $0x1,%eax
80104f23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104f27:	75 f7                	jne    80104f20 <strlen+0x10>
    ;
  return n;
}
80104f29:	5d                   	pop    %ebp
80104f2a:	c3                   	ret    

80104f2b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104f2b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104f2f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104f33:	55                   	push   %ebp
  pushl %ebx
80104f34:	53                   	push   %ebx
  pushl %esi
80104f35:	56                   	push   %esi
  pushl %edi
80104f36:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104f37:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104f39:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104f3b:	5f                   	pop    %edi
  popl %esi
80104f3c:	5e                   	pop    %esi
  popl %ebx
80104f3d:	5b                   	pop    %ebx
  popl %ebp
80104f3e:	5d                   	pop    %ebp
  ret
80104f3f:	c3                   	ret    

80104f40 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104f40:	55                   	push   %ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f41:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80104f48:	89 e5                	mov    %esp,%ebp
80104f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f4d:	8b 12                	mov    (%edx),%edx
80104f4f:	39 c2                	cmp    %eax,%edx
80104f51:	76 15                	jbe    80104f68 <fetchint+0x28>
80104f53:	8d 48 04             	lea    0x4(%eax),%ecx
80104f56:	39 ca                	cmp    %ecx,%edx
80104f58:	72 0e                	jb     80104f68 <fetchint+0x28>
    return -1;
  *ip = *(int*)(addr);
80104f5a:	8b 10                	mov    (%eax),%edx
80104f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f5f:	89 10                	mov    %edx,(%eax)
  return 0;
80104f61:	31 c0                	xor    %eax,%eax
}
80104f63:	5d                   	pop    %ebp
80104f64:	c3                   	ret    
80104f65:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104f68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f6d:	5d                   	pop    %ebp
80104f6e:	c3                   	ret    
80104f6f:	90                   	nop

80104f70 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104f70:	55                   	push   %ebp
  char *s, *ep;

  if(addr >= proc->sz)
80104f71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80104f77:	89 e5                	mov    %esp,%ebp
80104f79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz)
80104f7c:	39 08                	cmp    %ecx,(%eax)
80104f7e:	76 2c                	jbe    80104fac <fetchstr+0x3c>
    return -1;
  *pp = (char*)addr;
80104f80:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f83:	89 c8                	mov    %ecx,%eax
80104f85:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
80104f87:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f8e:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
80104f90:	39 d1                	cmp    %edx,%ecx
80104f92:	73 18                	jae    80104fac <fetchstr+0x3c>
    if(*s == 0)
80104f94:	80 39 00             	cmpb   $0x0,(%ecx)
80104f97:	75 0c                	jne    80104fa5 <fetchstr+0x35>
80104f99:	eb 25                	jmp    80104fc0 <fetchstr+0x50>
80104f9b:	90                   	nop
80104f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104fa0:	80 38 00             	cmpb   $0x0,(%eax)
80104fa3:	74 13                	je     80104fb8 <fetchstr+0x48>
  for(s = *pp; s < ep; s++)
80104fa5:	83 c0 01             	add    $0x1,%eax
80104fa8:	39 c2                	cmp    %eax,%edx
80104faa:	77 f4                	ja     80104fa0 <fetchstr+0x30>
    return -1;
80104fac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return s - *pp;
  return -1;
}
80104fb1:	5d                   	pop    %ebp
80104fb2:	c3                   	ret    
80104fb3:	90                   	nop
80104fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104fb8:	29 c8                	sub    %ecx,%eax
80104fba:	5d                   	pop    %ebp
80104fbb:	c3                   	ret    
80104fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
80104fc0:	31 c0                	xor    %eax,%eax
}
80104fc2:	5d                   	pop    %ebp
80104fc3:	c3                   	ret    
80104fc4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104fca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104fd0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104fd0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80104fd7:	55                   	push   %ebp
80104fd8:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104fda:	8b 42 1c             	mov    0x1c(%edx),%eax
80104fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104fe0:	8b 12                	mov    (%edx),%edx
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104fe2:	8b 40 44             	mov    0x44(%eax),%eax
80104fe5:	8d 04 88             	lea    (%eax,%ecx,4),%eax
80104fe8:	8d 48 04             	lea    0x4(%eax),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104feb:	39 d1                	cmp    %edx,%ecx
80104fed:	73 19                	jae    80105008 <argint+0x38>
80104fef:	8d 48 08             	lea    0x8(%eax),%ecx
80104ff2:	39 ca                	cmp    %ecx,%edx
80104ff4:	72 12                	jb     80105008 <argint+0x38>
  *ip = *(int*)(addr);
80104ff6:	8b 50 04             	mov    0x4(%eax),%edx
80104ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffc:	89 10                	mov    %edx,(%eax)
  return 0;
80104ffe:	31 c0                	xor    %eax,%eax
}
80105000:	5d                   	pop    %ebp
80105001:	c3                   	ret    
80105002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105008:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010500d:	5d                   	pop    %ebp
8010500e:	c3                   	ret    
8010500f:	90                   	nop

80105010 <argptr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105010:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105016:	55                   	push   %ebp
80105017:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105019:	8b 50 1c             	mov    0x1c(%eax),%edx
8010501c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
8010501f:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105021:	8b 52 44             	mov    0x44(%edx),%edx
80105024:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
80105027:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
8010502a:	39 c1                	cmp    %eax,%ecx
8010502c:	73 22                	jae    80105050 <argptr+0x40>
8010502e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105031:	39 c8                	cmp    %ecx,%eax
80105033:	72 1b                	jb     80105050 <argptr+0x40>
  *ip = *(int*)(addr);
80105035:	8b 52 04             	mov    0x4(%edx),%edx
  int i;

  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105038:	39 c2                	cmp    %eax,%edx
8010503a:	73 14                	jae    80105050 <argptr+0x40>
8010503c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010503f:	01 d1                	add    %edx,%ecx
80105041:	39 c1                	cmp    %eax,%ecx
80105043:	77 0b                	ja     80105050 <argptr+0x40>
    return -1;
  *pp = (char*)i;
80105045:	8b 45 0c             	mov    0xc(%ebp),%eax
80105048:	89 10                	mov    %edx,(%eax)
  return 0;
8010504a:	31 c0                	xor    %eax,%eax
}
8010504c:	5d                   	pop    %ebp
8010504d:	c3                   	ret    
8010504e:	66 90                	xchg   %ax,%ax
    return -1;
80105050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105055:	5d                   	pop    %ebp
80105056:	c3                   	ret    
80105057:	89 f6                	mov    %esi,%esi
80105059:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105060 <argstr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105060:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105066:	55                   	push   %ebp
80105067:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105069:	8b 50 1c             	mov    0x1c(%eax),%edx
8010506c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
8010506f:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105071:	8b 52 44             	mov    0x44(%edx),%edx
80105074:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
80105077:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
8010507a:	39 c1                	cmp    %eax,%ecx
8010507c:	73 3e                	jae    801050bc <argstr+0x5c>
8010507e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105081:	39 c8                	cmp    %ecx,%eax
80105083:	72 37                	jb     801050bc <argstr+0x5c>
  *ip = *(int*)(addr);
80105085:	8b 4a 04             	mov    0x4(%edx),%ecx
  if(addr >= proc->sz)
80105088:	39 c1                	cmp    %eax,%ecx
8010508a:	73 30                	jae    801050bc <argstr+0x5c>
  *pp = (char*)addr;
8010508c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010508f:	89 c8                	mov    %ecx,%eax
80105091:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
80105093:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010509a:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
8010509c:	39 d1                	cmp    %edx,%ecx
8010509e:	73 1c                	jae    801050bc <argstr+0x5c>
    if(*s == 0)
801050a0:	80 39 00             	cmpb   $0x0,(%ecx)
801050a3:	75 10                	jne    801050b5 <argstr+0x55>
801050a5:	eb 29                	jmp    801050d0 <argstr+0x70>
801050a7:	89 f6                	mov    %esi,%esi
801050a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801050b0:	80 38 00             	cmpb   $0x0,(%eax)
801050b3:	74 13                	je     801050c8 <argstr+0x68>
  for(s = *pp; s < ep; s++)
801050b5:	83 c0 01             	add    $0x1,%eax
801050b8:	39 c2                	cmp    %eax,%edx
801050ba:	77 f4                	ja     801050b0 <argstr+0x50>
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
801050bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchstr(addr, pp);
}
801050c1:	5d                   	pop    %ebp
801050c2:	c3                   	ret    
801050c3:	90                   	nop
801050c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801050c8:	29 c8                	sub    %ecx,%eax
801050ca:	5d                   	pop    %ebp
801050cb:	c3                   	ret    
801050cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
801050d0:	31 c0                	xor    %eax,%eax
}
801050d2:	5d                   	pop    %ebp
801050d3:	c3                   	ret    
801050d4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801050da:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801050e0 <syscall>:
[SYS_join]      sys_join,
};

void
syscall(void)
{
801050e0:	55                   	push   %ebp
801050e1:	89 e5                	mov    %esp,%ebp
801050e3:	83 ec 08             	sub    $0x8,%esp
  int num;

  num = proc->tf->eax;
801050e6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050ed:	8b 42 1c             	mov    0x1c(%edx),%eax
801050f0:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801050f3:	8d 48 ff             	lea    -0x1(%eax),%ecx
801050f6:	83 f9 19             	cmp    $0x19,%ecx
801050f9:	77 25                	ja     80105120 <syscall+0x40>
801050fb:	8b 0c 85 80 81 10 80 	mov    -0x7fef7e80(,%eax,4),%ecx
80105102:	85 c9                	test   %ecx,%ecx
80105104:	74 1a                	je     80105120 <syscall+0x40>
    proc->tf->eax = syscalls[num]();
80105106:	ff d1                	call   *%ecx
80105108:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010510f:	8b 52 1c             	mov    0x1c(%edx),%edx
80105112:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
80105115:	c9                   	leave  
80105116:	c3                   	ret    
80105117:	89 f6                	mov    %esi,%esi
80105119:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    cprintf("%d %s: unknown sys call %d\n",
80105120:	50                   	push   %eax
            proc->pid, proc->name, num);
80105121:	8d 42 70             	lea    0x70(%edx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80105124:	50                   	push   %eax
80105125:	ff 72 10             	pushl  0x10(%edx)
80105128:	68 4e 81 10 80       	push   $0x8010814e
8010512d:	e8 0e b5 ff ff       	call   80100640 <cprintf>
    proc->tf->eax = -1;
80105132:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105138:	83 c4 10             	add    $0x10,%esp
8010513b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010513e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80105145:	c9                   	leave  
80105146:	c3                   	ret    
80105147:	66 90                	xchg   %ax,%ax
80105149:	66 90                	xchg   %ax,%ax
8010514b:	66 90                	xchg   %ax,%ax
8010514d:	66 90                	xchg   %ax,%ax
8010514f:	90                   	nop

80105150 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80105150:	55                   	push   %ebp
80105151:	89 e5                	mov    %esp,%ebp
80105153:	57                   	push   %edi
80105154:	56                   	push   %esi
80105155:	53                   	push   %ebx
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105156:	8d 75 da             	lea    -0x26(%ebp),%esi
{
80105159:	83 ec 44             	sub    $0x44,%esp
8010515c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
8010515f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80105162:	56                   	push   %esi
80105163:	50                   	push   %eax
{
80105164:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80105167:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  if((dp = nameiparent(path, name)) == 0)
8010516a:	e8 61 cd ff ff       	call   80101ed0 <nameiparent>
8010516f:	83 c4 10             	add    $0x10,%esp
80105172:	85 c0                	test   %eax,%eax
80105174:	0f 84 46 01 00 00    	je     801052c0 <create+0x170>
    return 0;
  ilock(dp);
8010517a:	83 ec 0c             	sub    $0xc,%esp
8010517d:	89 c3                	mov    %eax,%ebx
8010517f:	50                   	push   %eax
80105180:	e8 8b c4 ff ff       	call   80101610 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105185:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80105188:	83 c4 0c             	add    $0xc,%esp
8010518b:	50                   	push   %eax
8010518c:	56                   	push   %esi
8010518d:	53                   	push   %ebx
8010518e:	e8 ed c9 ff ff       	call   80101b80 <dirlookup>
80105193:	83 c4 10             	add    $0x10,%esp
80105196:	85 c0                	test   %eax,%eax
80105198:	89 c7                	mov    %eax,%edi
8010519a:	74 34                	je     801051d0 <create+0x80>
    iunlockput(dp);
8010519c:	83 ec 0c             	sub    $0xc,%esp
8010519f:	53                   	push   %ebx
801051a0:	e8 3b c7 ff ff       	call   801018e0 <iunlockput>
    ilock(ip);
801051a5:	89 3c 24             	mov    %edi,(%esp)
801051a8:	e8 63 c4 ff ff       	call   80101610 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801051ad:	83 c4 10             	add    $0x10,%esp
801051b0:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801051b5:	0f 85 95 00 00 00    	jne    80105250 <create+0x100>
801051bb:	66 83 7f 10 02       	cmpw   $0x2,0x10(%edi)
801051c0:	0f 85 8a 00 00 00    	jne    80105250 <create+0x100>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801051c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801051c9:	89 f8                	mov    %edi,%eax
801051cb:	5b                   	pop    %ebx
801051cc:	5e                   	pop    %esi
801051cd:	5f                   	pop    %edi
801051ce:	5d                   	pop    %ebp
801051cf:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
801051d0:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801051d4:	83 ec 08             	sub    $0x8,%esp
801051d7:	50                   	push   %eax
801051d8:	ff 33                	pushl  (%ebx)
801051da:	e8 c1 c2 ff ff       	call   801014a0 <ialloc>
801051df:	83 c4 10             	add    $0x10,%esp
801051e2:	85 c0                	test   %eax,%eax
801051e4:	89 c7                	mov    %eax,%edi
801051e6:	0f 84 e8 00 00 00    	je     801052d4 <create+0x184>
  ilock(ip);
801051ec:	83 ec 0c             	sub    $0xc,%esp
801051ef:	50                   	push   %eax
801051f0:	e8 1b c4 ff ff       	call   80101610 <ilock>
  ip->major = major;
801051f5:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801051f9:	66 89 47 12          	mov    %ax,0x12(%edi)
  ip->minor = minor;
801051fd:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
80105201:	66 89 47 14          	mov    %ax,0x14(%edi)
  ip->nlink = 1;
80105205:	b8 01 00 00 00       	mov    $0x1,%eax
8010520a:	66 89 47 16          	mov    %ax,0x16(%edi)
  iupdate(ip);
8010520e:	89 3c 24             	mov    %edi,(%esp)
80105211:	e8 4a c3 ff ff       	call   80101560 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80105216:	83 c4 10             	add    $0x10,%esp
80105219:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010521e:	74 50                	je     80105270 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80105220:	83 ec 04             	sub    $0x4,%esp
80105223:	ff 77 04             	pushl  0x4(%edi)
80105226:	56                   	push   %esi
80105227:	53                   	push   %ebx
80105228:	e8 c3 cb ff ff       	call   80101df0 <dirlink>
8010522d:	83 c4 10             	add    $0x10,%esp
80105230:	85 c0                	test   %eax,%eax
80105232:	0f 88 8f 00 00 00    	js     801052c7 <create+0x177>
  iunlockput(dp);
80105238:	83 ec 0c             	sub    $0xc,%esp
8010523b:	53                   	push   %ebx
8010523c:	e8 9f c6 ff ff       	call   801018e0 <iunlockput>
  return ip;
80105241:	83 c4 10             	add    $0x10,%esp
}
80105244:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105247:	89 f8                	mov    %edi,%eax
80105249:	5b                   	pop    %ebx
8010524a:	5e                   	pop    %esi
8010524b:	5f                   	pop    %edi
8010524c:	5d                   	pop    %ebp
8010524d:	c3                   	ret    
8010524e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80105250:	83 ec 0c             	sub    $0xc,%esp
80105253:	57                   	push   %edi
    return 0;
80105254:	31 ff                	xor    %edi,%edi
    iunlockput(ip);
80105256:	e8 85 c6 ff ff       	call   801018e0 <iunlockput>
    return 0;
8010525b:	83 c4 10             	add    $0x10,%esp
}
8010525e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105261:	89 f8                	mov    %edi,%eax
80105263:	5b                   	pop    %ebx
80105264:	5e                   	pop    %esi
80105265:	5f                   	pop    %edi
80105266:	5d                   	pop    %ebp
80105267:	c3                   	ret    
80105268:	90                   	nop
80105269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink++;  // for ".."
80105270:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
    iupdate(dp);
80105275:	83 ec 0c             	sub    $0xc,%esp
80105278:	53                   	push   %ebx
80105279:	e8 e2 c2 ff ff       	call   80101560 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010527e:	83 c4 0c             	add    $0xc,%esp
80105281:	ff 77 04             	pushl  0x4(%edi)
80105284:	68 08 82 10 80       	push   $0x80108208
80105289:	57                   	push   %edi
8010528a:	e8 61 cb ff ff       	call   80101df0 <dirlink>
8010528f:	83 c4 10             	add    $0x10,%esp
80105292:	85 c0                	test   %eax,%eax
80105294:	78 1c                	js     801052b2 <create+0x162>
80105296:	83 ec 04             	sub    $0x4,%esp
80105299:	ff 73 04             	pushl  0x4(%ebx)
8010529c:	68 07 82 10 80       	push   $0x80108207
801052a1:	57                   	push   %edi
801052a2:	e8 49 cb ff ff       	call   80101df0 <dirlink>
801052a7:	83 c4 10             	add    $0x10,%esp
801052aa:	85 c0                	test   %eax,%eax
801052ac:	0f 89 6e ff ff ff    	jns    80105220 <create+0xd0>
      panic("create dots");
801052b2:	83 ec 0c             	sub    $0xc,%esp
801052b5:	68 fb 81 10 80       	push   $0x801081fb
801052ba:	e8 b1 b0 ff ff       	call   80100370 <panic>
801052bf:	90                   	nop
    return 0;
801052c0:	31 ff                	xor    %edi,%edi
801052c2:	e9 ff fe ff ff       	jmp    801051c6 <create+0x76>
    panic("create: dirlink");
801052c7:	83 ec 0c             	sub    $0xc,%esp
801052ca:	68 0a 82 10 80       	push   $0x8010820a
801052cf:	e8 9c b0 ff ff       	call   80100370 <panic>
    panic("create: ialloc");
801052d4:	83 ec 0c             	sub    $0xc,%esp
801052d7:	68 ec 81 10 80       	push   $0x801081ec
801052dc:	e8 8f b0 ff ff       	call   80100370 <panic>
801052e1:	eb 0d                	jmp    801052f0 <argfd.constprop.0>
801052e3:	90                   	nop
801052e4:	90                   	nop
801052e5:	90                   	nop
801052e6:	90                   	nop
801052e7:	90                   	nop
801052e8:	90                   	nop
801052e9:	90                   	nop
801052ea:	90                   	nop
801052eb:	90                   	nop
801052ec:	90                   	nop
801052ed:	90                   	nop
801052ee:	90                   	nop
801052ef:	90                   	nop

801052f0 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
801052f0:	55                   	push   %ebp
801052f1:	89 e5                	mov    %esp,%ebp
801052f3:	56                   	push   %esi
801052f4:	53                   	push   %ebx
801052f5:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
801052f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
801052fa:	89 d6                	mov    %edx,%esi
801052fc:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801052ff:	50                   	push   %eax
80105300:	6a 00                	push   $0x0
80105302:	e8 c9 fc ff ff       	call   80104fd0 <argint>
80105307:	83 c4 10             	add    $0x10,%esp
8010530a:	85 c0                	test   %eax,%eax
8010530c:	78 32                	js     80105340 <argfd.constprop.0+0x50>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010530e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105311:	83 f8 0f             	cmp    $0xf,%eax
80105314:	77 2a                	ja     80105340 <argfd.constprop.0+0x50>
80105316:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010531d:	8b 4c 82 2c          	mov    0x2c(%edx,%eax,4),%ecx
80105321:	85 c9                	test   %ecx,%ecx
80105323:	74 1b                	je     80105340 <argfd.constprop.0+0x50>
  if(pfd)
80105325:	85 db                	test   %ebx,%ebx
80105327:	74 02                	je     8010532b <argfd.constprop.0+0x3b>
    *pfd = fd;
80105329:	89 03                	mov    %eax,(%ebx)
    *pf = f;
8010532b:	89 0e                	mov    %ecx,(%esi)
  return 0;
8010532d:	31 c0                	xor    %eax,%eax
}
8010532f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105332:	5b                   	pop    %ebx
80105333:	5e                   	pop    %esi
80105334:	5d                   	pop    %ebp
80105335:	c3                   	ret    
80105336:	8d 76 00             	lea    0x0(%esi),%esi
80105339:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105340:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105345:	eb e8                	jmp    8010532f <argfd.constprop.0+0x3f>
80105347:	89 f6                	mov    %esi,%esi
80105349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105350 <sys_dup>:
{
80105350:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
80105351:	31 c0                	xor    %eax,%eax
{
80105353:	89 e5                	mov    %esp,%ebp
80105355:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
80105356:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
80105359:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010535c:	e8 8f ff ff ff       	call   801052f0 <argfd.constprop.0>
80105361:	85 c0                	test   %eax,%eax
80105363:	78 3b                	js     801053a0 <sys_dup+0x50>
  if((fd=fdalloc(f)) < 0)
80105365:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if(proc->ofile[fd] == 0){
80105368:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  for(fd = 0; fd < NOFILE; fd++){
8010536e:	31 db                	xor    %ebx,%ebx
80105370:	eb 0e                	jmp    80105380 <sys_dup+0x30>
80105372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105378:	83 c3 01             	add    $0x1,%ebx
8010537b:	83 fb 10             	cmp    $0x10,%ebx
8010537e:	74 20                	je     801053a0 <sys_dup+0x50>
    if(proc->ofile[fd] == 0){
80105380:	8b 4c 98 2c          	mov    0x2c(%eax,%ebx,4),%ecx
80105384:	85 c9                	test   %ecx,%ecx
80105386:	75 f0                	jne    80105378 <sys_dup+0x28>
  filedup(f);
80105388:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
8010538b:	89 54 98 2c          	mov    %edx,0x2c(%eax,%ebx,4)
  filedup(f);
8010538f:	52                   	push   %edx
80105390:	e8 2b ba ff ff       	call   80100dc0 <filedup>
}
80105395:	89 d8                	mov    %ebx,%eax
  return fd;
80105397:	83 c4 10             	add    $0x10,%esp
}
8010539a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010539d:	c9                   	leave  
8010539e:	c3                   	ret    
8010539f:	90                   	nop
    return -1;
801053a0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
801053a5:	89 d8                	mov    %ebx,%eax
801053a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801053aa:	c9                   	leave  
801053ab:	c3                   	ret    
801053ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801053b0 <sys_read>:
{
801053b0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053b1:	31 c0                	xor    %eax,%eax
{
801053b3:	89 e5                	mov    %esp,%ebp
801053b5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053b8:	8d 55 ec             	lea    -0x14(%ebp),%edx
801053bb:	e8 30 ff ff ff       	call   801052f0 <argfd.constprop.0>
801053c0:	85 c0                	test   %eax,%eax
801053c2:	78 4c                	js     80105410 <sys_read+0x60>
801053c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053c7:	83 ec 08             	sub    $0x8,%esp
801053ca:	50                   	push   %eax
801053cb:	6a 02                	push   $0x2
801053cd:	e8 fe fb ff ff       	call   80104fd0 <argint>
801053d2:	83 c4 10             	add    $0x10,%esp
801053d5:	85 c0                	test   %eax,%eax
801053d7:	78 37                	js     80105410 <sys_read+0x60>
801053d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053dc:	83 ec 04             	sub    $0x4,%esp
801053df:	ff 75 f0             	pushl  -0x10(%ebp)
801053e2:	50                   	push   %eax
801053e3:	6a 01                	push   $0x1
801053e5:	e8 26 fc ff ff       	call   80105010 <argptr>
801053ea:	83 c4 10             	add    $0x10,%esp
801053ed:	85 c0                	test   %eax,%eax
801053ef:	78 1f                	js     80105410 <sys_read+0x60>
  return fileread(f, p, n);
801053f1:	83 ec 04             	sub    $0x4,%esp
801053f4:	ff 75 f0             	pushl  -0x10(%ebp)
801053f7:	ff 75 f4             	pushl  -0xc(%ebp)
801053fa:	ff 75 ec             	pushl  -0x14(%ebp)
801053fd:	e8 2e bb ff ff       	call   80100f30 <fileread>
80105402:	83 c4 10             	add    $0x10,%esp
}
80105405:	c9                   	leave  
80105406:	c3                   	ret    
80105407:	89 f6                	mov    %esi,%esi
80105409:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105410:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105415:	c9                   	leave  
80105416:	c3                   	ret    
80105417:	89 f6                	mov    %esi,%esi
80105419:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105420 <sys_write>:
{
80105420:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105421:	31 c0                	xor    %eax,%eax
{
80105423:	89 e5                	mov    %esp,%ebp
80105425:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105428:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010542b:	e8 c0 fe ff ff       	call   801052f0 <argfd.constprop.0>
80105430:	85 c0                	test   %eax,%eax
80105432:	78 4c                	js     80105480 <sys_write+0x60>
80105434:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105437:	83 ec 08             	sub    $0x8,%esp
8010543a:	50                   	push   %eax
8010543b:	6a 02                	push   $0x2
8010543d:	e8 8e fb ff ff       	call   80104fd0 <argint>
80105442:	83 c4 10             	add    $0x10,%esp
80105445:	85 c0                	test   %eax,%eax
80105447:	78 37                	js     80105480 <sys_write+0x60>
80105449:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010544c:	83 ec 04             	sub    $0x4,%esp
8010544f:	ff 75 f0             	pushl  -0x10(%ebp)
80105452:	50                   	push   %eax
80105453:	6a 01                	push   $0x1
80105455:	e8 b6 fb ff ff       	call   80105010 <argptr>
8010545a:	83 c4 10             	add    $0x10,%esp
8010545d:	85 c0                	test   %eax,%eax
8010545f:	78 1f                	js     80105480 <sys_write+0x60>
  return filewrite(f, p, n);
80105461:	83 ec 04             	sub    $0x4,%esp
80105464:	ff 75 f0             	pushl  -0x10(%ebp)
80105467:	ff 75 f4             	pushl  -0xc(%ebp)
8010546a:	ff 75 ec             	pushl  -0x14(%ebp)
8010546d:	e8 4e bb ff ff       	call   80100fc0 <filewrite>
80105472:	83 c4 10             	add    $0x10,%esp
}
80105475:	c9                   	leave  
80105476:	c3                   	ret    
80105477:	89 f6                	mov    %esi,%esi
80105479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105485:	c9                   	leave  
80105486:	c3                   	ret    
80105487:	89 f6                	mov    %esi,%esi
80105489:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105490 <sys_close>:
{
80105490:	55                   	push   %ebp
80105491:	89 e5                	mov    %esp,%ebp
80105493:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80105496:	8d 55 f4             	lea    -0xc(%ebp),%edx
80105499:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010549c:	e8 4f fe ff ff       	call   801052f0 <argfd.constprop.0>
801054a1:	85 c0                	test   %eax,%eax
801054a3:	78 2b                	js     801054d0 <sys_close+0x40>
  proc->ofile[fd] = 0;
801054a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
801054ae:	83 ec 0c             	sub    $0xc,%esp
  proc->ofile[fd] = 0;
801054b1:	c7 44 90 2c 00 00 00 	movl   $0x0,0x2c(%eax,%edx,4)
801054b8:	00 
  fileclose(f);
801054b9:	ff 75 f4             	pushl  -0xc(%ebp)
801054bc:	e8 4f b9 ff ff       	call   80100e10 <fileclose>
  return 0;
801054c1:	83 c4 10             	add    $0x10,%esp
801054c4:	31 c0                	xor    %eax,%eax
}
801054c6:	c9                   	leave  
801054c7:	c3                   	ret    
801054c8:	90                   	nop
801054c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801054d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054d5:	c9                   	leave  
801054d6:	c3                   	ret    
801054d7:	89 f6                	mov    %esi,%esi
801054d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801054e0 <sys_fstat>:
{
801054e0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054e1:	31 c0                	xor    %eax,%eax
{
801054e3:	89 e5                	mov    %esp,%ebp
801054e5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054e8:	8d 55 f0             	lea    -0x10(%ebp),%edx
801054eb:	e8 00 fe ff ff       	call   801052f0 <argfd.constprop.0>
801054f0:	85 c0                	test   %eax,%eax
801054f2:	78 2c                	js     80105520 <sys_fstat+0x40>
801054f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054f7:	83 ec 04             	sub    $0x4,%esp
801054fa:	6a 14                	push   $0x14
801054fc:	50                   	push   %eax
801054fd:	6a 01                	push   $0x1
801054ff:	e8 0c fb ff ff       	call   80105010 <argptr>
80105504:	83 c4 10             	add    $0x10,%esp
80105507:	85 c0                	test   %eax,%eax
80105509:	78 15                	js     80105520 <sys_fstat+0x40>
  return filestat(f, st);
8010550b:	83 ec 08             	sub    $0x8,%esp
8010550e:	ff 75 f4             	pushl  -0xc(%ebp)
80105511:	ff 75 f0             	pushl  -0x10(%ebp)
80105514:	e8 c7 b9 ff ff       	call   80100ee0 <filestat>
80105519:	83 c4 10             	add    $0x10,%esp
}
8010551c:	c9                   	leave  
8010551d:	c3                   	ret    
8010551e:	66 90                	xchg   %ax,%ax
    return -1;
80105520:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105525:	c9                   	leave  
80105526:	c3                   	ret    
80105527:	89 f6                	mov    %esi,%esi
80105529:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105530 <sys_link>:
{
80105530:	55                   	push   %ebp
80105531:	89 e5                	mov    %esp,%ebp
80105533:	57                   	push   %edi
80105534:	56                   	push   %esi
80105535:	53                   	push   %ebx
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105536:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105539:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010553c:	50                   	push   %eax
8010553d:	6a 00                	push   $0x0
8010553f:	e8 1c fb ff ff       	call   80105060 <argstr>
80105544:	83 c4 10             	add    $0x10,%esp
80105547:	85 c0                	test   %eax,%eax
80105549:	0f 88 fb 00 00 00    	js     8010564a <sys_link+0x11a>
8010554f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105552:	83 ec 08             	sub    $0x8,%esp
80105555:	50                   	push   %eax
80105556:	6a 01                	push   $0x1
80105558:	e8 03 fb ff ff       	call   80105060 <argstr>
8010555d:	83 c4 10             	add    $0x10,%esp
80105560:	85 c0                	test   %eax,%eax
80105562:	0f 88 e2 00 00 00    	js     8010564a <sys_link+0x11a>
  begin_op();
80105568:	e8 b3 d6 ff ff       	call   80102c20 <begin_op>
  if((ip = namei(old)) == 0){
8010556d:	83 ec 0c             	sub    $0xc,%esp
80105570:	ff 75 d4             	pushl  -0x2c(%ebp)
80105573:	e8 38 c9 ff ff       	call   80101eb0 <namei>
80105578:	83 c4 10             	add    $0x10,%esp
8010557b:	85 c0                	test   %eax,%eax
8010557d:	89 c3                	mov    %eax,%ebx
8010557f:	0f 84 ea 00 00 00    	je     8010566f <sys_link+0x13f>
  ilock(ip);
80105585:	83 ec 0c             	sub    $0xc,%esp
80105588:	50                   	push   %eax
80105589:	e8 82 c0 ff ff       	call   80101610 <ilock>
  if(ip->type == T_DIR){
8010558e:	83 c4 10             	add    $0x10,%esp
80105591:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105596:	0f 84 bb 00 00 00    	je     80105657 <sys_link+0x127>
  ip->nlink++;
8010559c:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
801055a1:	83 ec 0c             	sub    $0xc,%esp
  if((dp = nameiparent(new, name)) == 0)
801055a4:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801055a7:	53                   	push   %ebx
801055a8:	e8 b3 bf ff ff       	call   80101560 <iupdate>
  iunlock(ip);
801055ad:	89 1c 24             	mov    %ebx,(%esp)
801055b0:	e8 6b c1 ff ff       	call   80101720 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801055b5:	58                   	pop    %eax
801055b6:	5a                   	pop    %edx
801055b7:	57                   	push   %edi
801055b8:	ff 75 d0             	pushl  -0x30(%ebp)
801055bb:	e8 10 c9 ff ff       	call   80101ed0 <nameiparent>
801055c0:	83 c4 10             	add    $0x10,%esp
801055c3:	85 c0                	test   %eax,%eax
801055c5:	89 c6                	mov    %eax,%esi
801055c7:	74 5b                	je     80105624 <sys_link+0xf4>
  ilock(dp);
801055c9:	83 ec 0c             	sub    $0xc,%esp
801055cc:	50                   	push   %eax
801055cd:	e8 3e c0 ff ff       	call   80101610 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801055d2:	83 c4 10             	add    $0x10,%esp
801055d5:	8b 03                	mov    (%ebx),%eax
801055d7:	39 06                	cmp    %eax,(%esi)
801055d9:	75 3d                	jne    80105618 <sys_link+0xe8>
801055db:	83 ec 04             	sub    $0x4,%esp
801055de:	ff 73 04             	pushl  0x4(%ebx)
801055e1:	57                   	push   %edi
801055e2:	56                   	push   %esi
801055e3:	e8 08 c8 ff ff       	call   80101df0 <dirlink>
801055e8:	83 c4 10             	add    $0x10,%esp
801055eb:	85 c0                	test   %eax,%eax
801055ed:	78 29                	js     80105618 <sys_link+0xe8>
  iunlockput(dp);
801055ef:	83 ec 0c             	sub    $0xc,%esp
801055f2:	56                   	push   %esi
801055f3:	e8 e8 c2 ff ff       	call   801018e0 <iunlockput>
  iput(ip);
801055f8:	89 1c 24             	mov    %ebx,(%esp)
801055fb:	e8 80 c1 ff ff       	call   80101780 <iput>
  end_op();
80105600:	e8 8b d6 ff ff       	call   80102c90 <end_op>
  return 0;
80105605:	83 c4 10             	add    $0x10,%esp
80105608:	31 c0                	xor    %eax,%eax
}
8010560a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010560d:	5b                   	pop    %ebx
8010560e:	5e                   	pop    %esi
8010560f:	5f                   	pop    %edi
80105610:	5d                   	pop    %ebp
80105611:	c3                   	ret    
80105612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105618:	83 ec 0c             	sub    $0xc,%esp
8010561b:	56                   	push   %esi
8010561c:	e8 bf c2 ff ff       	call   801018e0 <iunlockput>
    goto bad;
80105621:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105624:	83 ec 0c             	sub    $0xc,%esp
80105627:	53                   	push   %ebx
80105628:	e8 e3 bf ff ff       	call   80101610 <ilock>
  ip->nlink--;
8010562d:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
80105632:	89 1c 24             	mov    %ebx,(%esp)
80105635:	e8 26 bf ff ff       	call   80101560 <iupdate>
  iunlockput(ip);
8010563a:	89 1c 24             	mov    %ebx,(%esp)
8010563d:	e8 9e c2 ff ff       	call   801018e0 <iunlockput>
  end_op();
80105642:	e8 49 d6 ff ff       	call   80102c90 <end_op>
  return -1;
80105647:	83 c4 10             	add    $0x10,%esp
}
8010564a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010564d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105652:	5b                   	pop    %ebx
80105653:	5e                   	pop    %esi
80105654:	5f                   	pop    %edi
80105655:	5d                   	pop    %ebp
80105656:	c3                   	ret    
    iunlockput(ip);
80105657:	83 ec 0c             	sub    $0xc,%esp
8010565a:	53                   	push   %ebx
8010565b:	e8 80 c2 ff ff       	call   801018e0 <iunlockput>
    end_op();
80105660:	e8 2b d6 ff ff       	call   80102c90 <end_op>
    return -1;
80105665:	83 c4 10             	add    $0x10,%esp
80105668:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010566d:	eb 9b                	jmp    8010560a <sys_link+0xda>
    end_op();
8010566f:	e8 1c d6 ff ff       	call   80102c90 <end_op>
    return -1;
80105674:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105679:	eb 8f                	jmp    8010560a <sys_link+0xda>
8010567b:	90                   	nop
8010567c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105680 <sys_unlink>:
{
80105680:	55                   	push   %ebp
80105681:	89 e5                	mov    %esp,%ebp
80105683:	57                   	push   %edi
80105684:	56                   	push   %esi
80105685:	53                   	push   %ebx
  if(argstr(0, &path) < 0)
80105686:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80105689:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
8010568c:	50                   	push   %eax
8010568d:	6a 00                	push   $0x0
8010568f:	e8 cc f9 ff ff       	call   80105060 <argstr>
80105694:	83 c4 10             	add    $0x10,%esp
80105697:	85 c0                	test   %eax,%eax
80105699:	0f 88 77 01 00 00    	js     80105816 <sys_unlink+0x196>
  if((dp = nameiparent(path, name)) == 0){
8010569f:	8d 5d ca             	lea    -0x36(%ebp),%ebx
  begin_op();
801056a2:	e8 79 d5 ff ff       	call   80102c20 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801056a7:	83 ec 08             	sub    $0x8,%esp
801056aa:	53                   	push   %ebx
801056ab:	ff 75 c0             	pushl  -0x40(%ebp)
801056ae:	e8 1d c8 ff ff       	call   80101ed0 <nameiparent>
801056b3:	83 c4 10             	add    $0x10,%esp
801056b6:	85 c0                	test   %eax,%eax
801056b8:	89 c6                	mov    %eax,%esi
801056ba:	0f 84 60 01 00 00    	je     80105820 <sys_unlink+0x1a0>
  ilock(dp);
801056c0:	83 ec 0c             	sub    $0xc,%esp
801056c3:	50                   	push   %eax
801056c4:	e8 47 bf ff ff       	call   80101610 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801056c9:	58                   	pop    %eax
801056ca:	5a                   	pop    %edx
801056cb:	68 08 82 10 80       	push   $0x80108208
801056d0:	53                   	push   %ebx
801056d1:	e8 8a c4 ff ff       	call   80101b60 <namecmp>
801056d6:	83 c4 10             	add    $0x10,%esp
801056d9:	85 c0                	test   %eax,%eax
801056db:	0f 84 03 01 00 00    	je     801057e4 <sys_unlink+0x164>
801056e1:	83 ec 08             	sub    $0x8,%esp
801056e4:	68 07 82 10 80       	push   $0x80108207
801056e9:	53                   	push   %ebx
801056ea:	e8 71 c4 ff ff       	call   80101b60 <namecmp>
801056ef:	83 c4 10             	add    $0x10,%esp
801056f2:	85 c0                	test   %eax,%eax
801056f4:	0f 84 ea 00 00 00    	je     801057e4 <sys_unlink+0x164>
  if((ip = dirlookup(dp, name, &off)) == 0)
801056fa:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801056fd:	83 ec 04             	sub    $0x4,%esp
80105700:	50                   	push   %eax
80105701:	53                   	push   %ebx
80105702:	56                   	push   %esi
80105703:	e8 78 c4 ff ff       	call   80101b80 <dirlookup>
80105708:	83 c4 10             	add    $0x10,%esp
8010570b:	85 c0                	test   %eax,%eax
8010570d:	89 c3                	mov    %eax,%ebx
8010570f:	0f 84 cf 00 00 00    	je     801057e4 <sys_unlink+0x164>
  ilock(ip);
80105715:	83 ec 0c             	sub    $0xc,%esp
80105718:	50                   	push   %eax
80105719:	e8 f2 be ff ff       	call   80101610 <ilock>
  if(ip->nlink < 1)
8010571e:	83 c4 10             	add    $0x10,%esp
80105721:	66 83 7b 16 00       	cmpw   $0x0,0x16(%ebx)
80105726:	0f 8e 10 01 00 00    	jle    8010583c <sys_unlink+0x1bc>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010572c:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105731:	74 6d                	je     801057a0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
80105733:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105736:	83 ec 04             	sub    $0x4,%esp
80105739:	6a 10                	push   $0x10
8010573b:	6a 00                	push   $0x0
8010573d:	50                   	push   %eax
8010573e:	e8 ad f5 ff ff       	call   80104cf0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105743:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105746:	6a 10                	push   $0x10
80105748:	ff 75 c4             	pushl  -0x3c(%ebp)
8010574b:	50                   	push   %eax
8010574c:	56                   	push   %esi
8010574d:	e8 de c2 ff ff       	call   80101a30 <writei>
80105752:	83 c4 20             	add    $0x20,%esp
80105755:	83 f8 10             	cmp    $0x10,%eax
80105758:	0f 85 eb 00 00 00    	jne    80105849 <sys_unlink+0x1c9>
  if(ip->type == T_DIR){
8010575e:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105763:	0f 84 97 00 00 00    	je     80105800 <sys_unlink+0x180>
  iunlockput(dp);
80105769:	83 ec 0c             	sub    $0xc,%esp
8010576c:	56                   	push   %esi
8010576d:	e8 6e c1 ff ff       	call   801018e0 <iunlockput>
  ip->nlink--;
80105772:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
80105777:	89 1c 24             	mov    %ebx,(%esp)
8010577a:	e8 e1 bd ff ff       	call   80101560 <iupdate>
  iunlockput(ip);
8010577f:	89 1c 24             	mov    %ebx,(%esp)
80105782:	e8 59 c1 ff ff       	call   801018e0 <iunlockput>
  end_op();
80105787:	e8 04 d5 ff ff       	call   80102c90 <end_op>
  return 0;
8010578c:	83 c4 10             	add    $0x10,%esp
8010578f:	31 c0                	xor    %eax,%eax
}
80105791:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105794:	5b                   	pop    %ebx
80105795:	5e                   	pop    %esi
80105796:	5f                   	pop    %edi
80105797:	5d                   	pop    %ebp
80105798:	c3                   	ret    
80105799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801057a0:	83 7b 18 20          	cmpl   $0x20,0x18(%ebx)
801057a4:	76 8d                	jbe    80105733 <sys_unlink+0xb3>
801057a6:	bf 20 00 00 00       	mov    $0x20,%edi
801057ab:	eb 0f                	jmp    801057bc <sys_unlink+0x13c>
801057ad:	8d 76 00             	lea    0x0(%esi),%esi
801057b0:	83 c7 10             	add    $0x10,%edi
801057b3:	3b 7b 18             	cmp    0x18(%ebx),%edi
801057b6:	0f 83 77 ff ff ff    	jae    80105733 <sys_unlink+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057bc:	8d 45 d8             	lea    -0x28(%ebp),%eax
801057bf:	6a 10                	push   $0x10
801057c1:	57                   	push   %edi
801057c2:	50                   	push   %eax
801057c3:	53                   	push   %ebx
801057c4:	e8 67 c1 ff ff       	call   80101930 <readi>
801057c9:	83 c4 10             	add    $0x10,%esp
801057cc:	83 f8 10             	cmp    $0x10,%eax
801057cf:	75 5e                	jne    8010582f <sys_unlink+0x1af>
    if(de.inum != 0)
801057d1:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801057d6:	74 d8                	je     801057b0 <sys_unlink+0x130>
    iunlockput(ip);
801057d8:	83 ec 0c             	sub    $0xc,%esp
801057db:	53                   	push   %ebx
801057dc:	e8 ff c0 ff ff       	call   801018e0 <iunlockput>
    goto bad;
801057e1:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801057e4:	83 ec 0c             	sub    $0xc,%esp
801057e7:	56                   	push   %esi
801057e8:	e8 f3 c0 ff ff       	call   801018e0 <iunlockput>
  end_op();
801057ed:	e8 9e d4 ff ff       	call   80102c90 <end_op>
  return -1;
801057f2:	83 c4 10             	add    $0x10,%esp
801057f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057fa:	eb 95                	jmp    80105791 <sys_unlink+0x111>
801057fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink--;
80105800:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
    iupdate(dp);
80105805:	83 ec 0c             	sub    $0xc,%esp
80105808:	56                   	push   %esi
80105809:	e8 52 bd ff ff       	call   80101560 <iupdate>
8010580e:	83 c4 10             	add    $0x10,%esp
80105811:	e9 53 ff ff ff       	jmp    80105769 <sys_unlink+0xe9>
    return -1;
80105816:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010581b:	e9 71 ff ff ff       	jmp    80105791 <sys_unlink+0x111>
    end_op();
80105820:	e8 6b d4 ff ff       	call   80102c90 <end_op>
    return -1;
80105825:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582a:	e9 62 ff ff ff       	jmp    80105791 <sys_unlink+0x111>
      panic("isdirempty: readi");
8010582f:	83 ec 0c             	sub    $0xc,%esp
80105832:	68 2c 82 10 80       	push   $0x8010822c
80105837:	e8 34 ab ff ff       	call   80100370 <panic>
    panic("unlink: nlink < 1");
8010583c:	83 ec 0c             	sub    $0xc,%esp
8010583f:	68 1a 82 10 80       	push   $0x8010821a
80105844:	e8 27 ab ff ff       	call   80100370 <panic>
    panic("unlink: writei");
80105849:	83 ec 0c             	sub    $0xc,%esp
8010584c:	68 3e 82 10 80       	push   $0x8010823e
80105851:	e8 1a ab ff ff       	call   80100370 <panic>
80105856:	8d 76 00             	lea    0x0(%esi),%esi
80105859:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105860 <sys_open>:

int
sys_open(void)
{
80105860:	55                   	push   %ebp
80105861:	89 e5                	mov    %esp,%ebp
80105863:	57                   	push   %edi
80105864:	56                   	push   %esi
80105865:	53                   	push   %ebx
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105866:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105869:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010586c:	50                   	push   %eax
8010586d:	6a 00                	push   $0x0
8010586f:	e8 ec f7 ff ff       	call   80105060 <argstr>
80105874:	83 c4 10             	add    $0x10,%esp
80105877:	85 c0                	test   %eax,%eax
80105879:	0f 88 1d 01 00 00    	js     8010599c <sys_open+0x13c>
8010587f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105882:	83 ec 08             	sub    $0x8,%esp
80105885:	50                   	push   %eax
80105886:	6a 01                	push   $0x1
80105888:	e8 43 f7 ff ff       	call   80104fd0 <argint>
8010588d:	83 c4 10             	add    $0x10,%esp
80105890:	85 c0                	test   %eax,%eax
80105892:	0f 88 04 01 00 00    	js     8010599c <sys_open+0x13c>
    return -1;

  begin_op();
80105898:	e8 83 d3 ff ff       	call   80102c20 <begin_op>

  if(omode & O_CREATE){
8010589d:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801058a1:	0f 85 a9 00 00 00    	jne    80105950 <sys_open+0xf0>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801058a7:	83 ec 0c             	sub    $0xc,%esp
801058aa:	ff 75 e0             	pushl  -0x20(%ebp)
801058ad:	e8 fe c5 ff ff       	call   80101eb0 <namei>
801058b2:	83 c4 10             	add    $0x10,%esp
801058b5:	85 c0                	test   %eax,%eax
801058b7:	89 c6                	mov    %eax,%esi
801058b9:	0f 84 b2 00 00 00    	je     80105971 <sys_open+0x111>
      end_op();
      return -1;
    }
    ilock(ip);
801058bf:	83 ec 0c             	sub    $0xc,%esp
801058c2:	50                   	push   %eax
801058c3:	e8 48 bd ff ff       	call   80101610 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801058c8:	83 c4 10             	add    $0x10,%esp
801058cb:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
801058d0:	0f 84 aa 00 00 00    	je     80105980 <sys_open+0x120>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801058d6:	e8 75 b4 ff ff       	call   80100d50 <filealloc>
801058db:	85 c0                	test   %eax,%eax
801058dd:	89 c7                	mov    %eax,%edi
801058df:	0f 84 a6 00 00 00    	je     8010598b <sys_open+0x12b>
    if(proc->ofile[fd] == 0){
801058e5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  for(fd = 0; fd < NOFILE; fd++){
801058ec:	31 db                	xor    %ebx,%ebx
801058ee:	eb 0c                	jmp    801058fc <sys_open+0x9c>
801058f0:	83 c3 01             	add    $0x1,%ebx
801058f3:	83 fb 10             	cmp    $0x10,%ebx
801058f6:	0f 84 ac 00 00 00    	je     801059a8 <sys_open+0x148>
    if(proc->ofile[fd] == 0){
801058fc:	8b 44 9a 2c          	mov    0x2c(%edx,%ebx,4),%eax
80105900:	85 c0                	test   %eax,%eax
80105902:	75 ec                	jne    801058f0 <sys_open+0x90>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105904:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
80105907:	89 7c 9a 2c          	mov    %edi,0x2c(%edx,%ebx,4)
  iunlock(ip);
8010590b:	56                   	push   %esi
8010590c:	e8 0f be ff ff       	call   80101720 <iunlock>
  end_op();
80105911:	e8 7a d3 ff ff       	call   80102c90 <end_op>

  f->type = FD_INODE;
80105916:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
8010591c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010591f:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105922:	89 77 10             	mov    %esi,0x10(%edi)
  f->off = 0;
80105925:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
8010592c:	89 d0                	mov    %edx,%eax
8010592e:	f7 d0                	not    %eax
80105930:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105933:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
80105936:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105939:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
8010593d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105940:	89 d8                	mov    %ebx,%eax
80105942:	5b                   	pop    %ebx
80105943:	5e                   	pop    %esi
80105944:	5f                   	pop    %edi
80105945:	5d                   	pop    %ebp
80105946:	c3                   	ret    
80105947:	89 f6                	mov    %esi,%esi
80105949:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ip = create(path, T_FILE, 0, 0);
80105950:	83 ec 0c             	sub    $0xc,%esp
80105953:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105956:	31 c9                	xor    %ecx,%ecx
80105958:	6a 00                	push   $0x0
8010595a:	ba 02 00 00 00       	mov    $0x2,%edx
8010595f:	e8 ec f7 ff ff       	call   80105150 <create>
    if(ip == 0){
80105964:	83 c4 10             	add    $0x10,%esp
80105967:	85 c0                	test   %eax,%eax
    ip = create(path, T_FILE, 0, 0);
80105969:	89 c6                	mov    %eax,%esi
    if(ip == 0){
8010596b:	0f 85 65 ff ff ff    	jne    801058d6 <sys_open+0x76>
      end_op();
80105971:	e8 1a d3 ff ff       	call   80102c90 <end_op>
      return -1;
80105976:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010597b:	eb c0                	jmp    8010593d <sys_open+0xdd>
8010597d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->type == T_DIR && omode != O_RDONLY){
80105980:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105983:	85 d2                	test   %edx,%edx
80105985:	0f 84 4b ff ff ff    	je     801058d6 <sys_open+0x76>
    iunlockput(ip);
8010598b:	83 ec 0c             	sub    $0xc,%esp
8010598e:	56                   	push   %esi
8010598f:	e8 4c bf ff ff       	call   801018e0 <iunlockput>
    end_op();
80105994:	e8 f7 d2 ff ff       	call   80102c90 <end_op>
    return -1;
80105999:	83 c4 10             	add    $0x10,%esp
8010599c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801059a1:	eb 9a                	jmp    8010593d <sys_open+0xdd>
801059a3:	90                   	nop
801059a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      fileclose(f);
801059a8:	83 ec 0c             	sub    $0xc,%esp
801059ab:	57                   	push   %edi
801059ac:	e8 5f b4 ff ff       	call   80100e10 <fileclose>
801059b1:	83 c4 10             	add    $0x10,%esp
801059b4:	eb d5                	jmp    8010598b <sys_open+0x12b>
801059b6:	8d 76 00             	lea    0x0(%esi),%esi
801059b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801059c0 <sys_mkdir>:

int
sys_mkdir(void)
{
801059c0:	55                   	push   %ebp
801059c1:	89 e5                	mov    %esp,%ebp
801059c3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801059c6:	e8 55 d2 ff ff       	call   80102c20 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801059cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059ce:	83 ec 08             	sub    $0x8,%esp
801059d1:	50                   	push   %eax
801059d2:	6a 00                	push   $0x0
801059d4:	e8 87 f6 ff ff       	call   80105060 <argstr>
801059d9:	83 c4 10             	add    $0x10,%esp
801059dc:	85 c0                	test   %eax,%eax
801059de:	78 30                	js     80105a10 <sys_mkdir+0x50>
801059e0:	83 ec 0c             	sub    $0xc,%esp
801059e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e6:	31 c9                	xor    %ecx,%ecx
801059e8:	6a 00                	push   $0x0
801059ea:	ba 01 00 00 00       	mov    $0x1,%edx
801059ef:	e8 5c f7 ff ff       	call   80105150 <create>
801059f4:	83 c4 10             	add    $0x10,%esp
801059f7:	85 c0                	test   %eax,%eax
801059f9:	74 15                	je     80105a10 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
801059fb:	83 ec 0c             	sub    $0xc,%esp
801059fe:	50                   	push   %eax
801059ff:	e8 dc be ff ff       	call   801018e0 <iunlockput>
  end_op();
80105a04:	e8 87 d2 ff ff       	call   80102c90 <end_op>
  return 0;
80105a09:	83 c4 10             	add    $0x10,%esp
80105a0c:	31 c0                	xor    %eax,%eax
}
80105a0e:	c9                   	leave  
80105a0f:	c3                   	ret    
    end_op();
80105a10:	e8 7b d2 ff ff       	call   80102c90 <end_op>
    return -1;
80105a15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a1a:	c9                   	leave  
80105a1b:	c3                   	ret    
80105a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a20 <sys_mknod>:

int
sys_mknod(void)
{
80105a20:	55                   	push   %ebp
80105a21:	89 e5                	mov    %esp,%ebp
80105a23:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105a26:	e8 f5 d1 ff ff       	call   80102c20 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105a2b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a2e:	83 ec 08             	sub    $0x8,%esp
80105a31:	50                   	push   %eax
80105a32:	6a 00                	push   $0x0
80105a34:	e8 27 f6 ff ff       	call   80105060 <argstr>
80105a39:	83 c4 10             	add    $0x10,%esp
80105a3c:	85 c0                	test   %eax,%eax
80105a3e:	78 60                	js     80105aa0 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105a40:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a43:	83 ec 08             	sub    $0x8,%esp
80105a46:	50                   	push   %eax
80105a47:	6a 01                	push   $0x1
80105a49:	e8 82 f5 ff ff       	call   80104fd0 <argint>
  if((argstr(0, &path)) < 0 ||
80105a4e:	83 c4 10             	add    $0x10,%esp
80105a51:	85 c0                	test   %eax,%eax
80105a53:	78 4b                	js     80105aa0 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105a55:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a58:	83 ec 08             	sub    $0x8,%esp
80105a5b:	50                   	push   %eax
80105a5c:	6a 02                	push   $0x2
80105a5e:	e8 6d f5 ff ff       	call   80104fd0 <argint>
     argint(1, &major) < 0 ||
80105a63:	83 c4 10             	add    $0x10,%esp
80105a66:	85 c0                	test   %eax,%eax
80105a68:	78 36                	js     80105aa0 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105a6a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
     argint(2, &minor) < 0 ||
80105a6e:	83 ec 0c             	sub    $0xc,%esp
     (ip = create(path, T_DEV, major, minor)) == 0){
80105a71:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80105a75:	ba 03 00 00 00       	mov    $0x3,%edx
80105a7a:	50                   	push   %eax
80105a7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a7e:	e8 cd f6 ff ff       	call   80105150 <create>
80105a83:	83 c4 10             	add    $0x10,%esp
80105a86:	85 c0                	test   %eax,%eax
80105a88:	74 16                	je     80105aa0 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
80105a8a:	83 ec 0c             	sub    $0xc,%esp
80105a8d:	50                   	push   %eax
80105a8e:	e8 4d be ff ff       	call   801018e0 <iunlockput>
  end_op();
80105a93:	e8 f8 d1 ff ff       	call   80102c90 <end_op>
  return 0;
80105a98:	83 c4 10             	add    $0x10,%esp
80105a9b:	31 c0                	xor    %eax,%eax
}
80105a9d:	c9                   	leave  
80105a9e:	c3                   	ret    
80105a9f:	90                   	nop
    end_op();
80105aa0:	e8 eb d1 ff ff       	call   80102c90 <end_op>
    return -1;
80105aa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aaa:	c9                   	leave  
80105aab:	c3                   	ret    
80105aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105ab0 <sys_chdir>:

int
sys_chdir(void)
{
80105ab0:	55                   	push   %ebp
80105ab1:	89 e5                	mov    %esp,%ebp
80105ab3:	53                   	push   %ebx
80105ab4:	83 ec 14             	sub    $0x14,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105ab7:	e8 64 d1 ff ff       	call   80102c20 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105abc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105abf:	83 ec 08             	sub    $0x8,%esp
80105ac2:	50                   	push   %eax
80105ac3:	6a 00                	push   $0x0
80105ac5:	e8 96 f5 ff ff       	call   80105060 <argstr>
80105aca:	83 c4 10             	add    $0x10,%esp
80105acd:	85 c0                	test   %eax,%eax
80105acf:	78 7f                	js     80105b50 <sys_chdir+0xa0>
80105ad1:	83 ec 0c             	sub    $0xc,%esp
80105ad4:	ff 75 f4             	pushl  -0xc(%ebp)
80105ad7:	e8 d4 c3 ff ff       	call   80101eb0 <namei>
80105adc:	83 c4 10             	add    $0x10,%esp
80105adf:	85 c0                	test   %eax,%eax
80105ae1:	89 c3                	mov    %eax,%ebx
80105ae3:	74 6b                	je     80105b50 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105ae5:	83 ec 0c             	sub    $0xc,%esp
80105ae8:	50                   	push   %eax
80105ae9:	e8 22 bb ff ff       	call   80101610 <ilock>
  if(ip->type != T_DIR){
80105aee:	83 c4 10             	add    $0x10,%esp
80105af1:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105af6:	75 38                	jne    80105b30 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105af8:	83 ec 0c             	sub    $0xc,%esp
80105afb:	53                   	push   %ebx
80105afc:	e8 1f bc ff ff       	call   80101720 <iunlock>
  iput(proc->cwd);
80105b01:	58                   	pop    %eax
80105b02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b08:	ff 70 6c             	pushl  0x6c(%eax)
80105b0b:	e8 70 bc ff ff       	call   80101780 <iput>
  end_op();
80105b10:	e8 7b d1 ff ff       	call   80102c90 <end_op>
  proc->cwd = ip;
80105b15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return 0;
80105b1b:	83 c4 10             	add    $0x10,%esp
  proc->cwd = ip;
80105b1e:	89 58 6c             	mov    %ebx,0x6c(%eax)
  return 0;
80105b21:	31 c0                	xor    %eax,%eax
}
80105b23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105b26:	c9                   	leave  
80105b27:	c3                   	ret    
80105b28:	90                   	nop
80105b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    iunlockput(ip);
80105b30:	83 ec 0c             	sub    $0xc,%esp
80105b33:	53                   	push   %ebx
80105b34:	e8 a7 bd ff ff       	call   801018e0 <iunlockput>
    end_op();
80105b39:	e8 52 d1 ff ff       	call   80102c90 <end_op>
    return -1;
80105b3e:	83 c4 10             	add    $0x10,%esp
80105b41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b46:	eb db                	jmp    80105b23 <sys_chdir+0x73>
80105b48:	90                   	nop
80105b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    end_op();
80105b50:	e8 3b d1 ff ff       	call   80102c90 <end_op>
    return -1;
80105b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5a:	eb c7                	jmp    80105b23 <sys_chdir+0x73>
80105b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105b60 <sys_exec>:

int
sys_exec(void)
{
80105b60:	55                   	push   %ebp
80105b61:	89 e5                	mov    %esp,%ebp
80105b63:	57                   	push   %edi
80105b64:	56                   	push   %esi
80105b65:	53                   	push   %ebx
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105b66:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
80105b6c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105b72:	50                   	push   %eax
80105b73:	6a 00                	push   $0x0
80105b75:	e8 e6 f4 ff ff       	call   80105060 <argstr>
80105b7a:	83 c4 10             	add    $0x10,%esp
80105b7d:	85 c0                	test   %eax,%eax
80105b7f:	0f 88 87 00 00 00    	js     80105c0c <sys_exec+0xac>
80105b85:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105b8b:	83 ec 08             	sub    $0x8,%esp
80105b8e:	50                   	push   %eax
80105b8f:	6a 01                	push   $0x1
80105b91:	e8 3a f4 ff ff       	call   80104fd0 <argint>
80105b96:	83 c4 10             	add    $0x10,%esp
80105b99:	85 c0                	test   %eax,%eax
80105b9b:	78 6f                	js     80105c0c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105b9d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ba3:	83 ec 04             	sub    $0x4,%esp
  for(i=0;; i++){
80105ba6:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105ba8:	68 80 00 00 00       	push   $0x80
80105bad:	6a 00                	push   $0x0
80105baf:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
80105bb5:	50                   	push   %eax
80105bb6:	e8 35 f1 ff ff       	call   80104cf0 <memset>
80105bbb:	83 c4 10             	add    $0x10,%esp
80105bbe:	eb 2c                	jmp    80105bec <sys_exec+0x8c>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
80105bc0:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105bc6:	85 c0                	test   %eax,%eax
80105bc8:	74 56                	je     80105c20 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105bca:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
80105bd0:	83 ec 08             	sub    $0x8,%esp
80105bd3:	8d 14 31             	lea    (%ecx,%esi,1),%edx
80105bd6:	52                   	push   %edx
80105bd7:	50                   	push   %eax
80105bd8:	e8 93 f3 ff ff       	call   80104f70 <fetchstr>
80105bdd:	83 c4 10             	add    $0x10,%esp
80105be0:	85 c0                	test   %eax,%eax
80105be2:	78 28                	js     80105c0c <sys_exec+0xac>
  for(i=0;; i++){
80105be4:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105be7:	83 fb 20             	cmp    $0x20,%ebx
80105bea:	74 20                	je     80105c0c <sys_exec+0xac>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105bec:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105bf2:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
80105bf9:	83 ec 08             	sub    $0x8,%esp
80105bfc:	57                   	push   %edi
80105bfd:	01 f0                	add    %esi,%eax
80105bff:	50                   	push   %eax
80105c00:	e8 3b f3 ff ff       	call   80104f40 <fetchint>
80105c05:	83 c4 10             	add    $0x10,%esp
80105c08:	85 c0                	test   %eax,%eax
80105c0a:	79 b4                	jns    80105bc0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
80105c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c14:	5b                   	pop    %ebx
80105c15:	5e                   	pop    %esi
80105c16:	5f                   	pop    %edi
80105c17:	5d                   	pop    %ebp
80105c18:	c3                   	ret    
80105c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105c20:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105c26:	83 ec 08             	sub    $0x8,%esp
      argv[i] = 0;
80105c29:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105c30:	00 00 00 00 
  return exec(path, argv);
80105c34:	50                   	push   %eax
80105c35:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
80105c3b:	e8 b0 ad ff ff       	call   801009f0 <exec>
80105c40:	83 c4 10             	add    $0x10,%esp
}
80105c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c46:	5b                   	pop    %ebx
80105c47:	5e                   	pop    %esi
80105c48:	5f                   	pop    %edi
80105c49:	5d                   	pop    %ebp
80105c4a:	c3                   	ret    
80105c4b:	90                   	nop
80105c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105c50 <sys_pipe>:

int
sys_pipe(void)
{
80105c50:	55                   	push   %ebp
80105c51:	89 e5                	mov    %esp,%ebp
80105c53:	57                   	push   %edi
80105c54:	56                   	push   %esi
80105c55:	53                   	push   %ebx
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105c56:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105c59:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105c5c:	6a 08                	push   $0x8
80105c5e:	50                   	push   %eax
80105c5f:	6a 00                	push   $0x0
80105c61:	e8 aa f3 ff ff       	call   80105010 <argptr>
80105c66:	83 c4 10             	add    $0x10,%esp
80105c69:	85 c0                	test   %eax,%eax
80105c6b:	0f 88 a4 00 00 00    	js     80105d15 <sys_pipe+0xc5>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105c71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c74:	83 ec 08             	sub    $0x8,%esp
80105c77:	50                   	push   %eax
80105c78:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c7b:	50                   	push   %eax
80105c7c:	e8 4f d7 ff ff       	call   801033d0 <pipealloc>
80105c81:	83 c4 10             	add    $0x10,%esp
80105c84:	85 c0                	test   %eax,%eax
80105c86:	0f 88 89 00 00 00    	js     80105d15 <sys_pipe+0xc5>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c8c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
    if(proc->ofile[fd] == 0){
80105c8f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  for(fd = 0; fd < NOFILE; fd++){
80105c96:	31 c0                	xor    %eax,%eax
80105c98:	eb 0e                	jmp    80105ca8 <sys_pipe+0x58>
80105c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105ca0:	83 c0 01             	add    $0x1,%eax
80105ca3:	83 f8 10             	cmp    $0x10,%eax
80105ca6:	74 58                	je     80105d00 <sys_pipe+0xb0>
    if(proc->ofile[fd] == 0){
80105ca8:	8b 54 81 2c          	mov    0x2c(%ecx,%eax,4),%edx
80105cac:	85 d2                	test   %edx,%edx
80105cae:	75 f0                	jne    80105ca0 <sys_pipe+0x50>
80105cb0:	8d 34 81             	lea    (%ecx,%eax,4),%esi
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105cb3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105cb6:	31 d2                	xor    %edx,%edx
      proc->ofile[fd] = f;
80105cb8:	89 5e 2c             	mov    %ebx,0x2c(%esi)
80105cbb:	eb 0b                	jmp    80105cc8 <sys_pipe+0x78>
80105cbd:	8d 76 00             	lea    0x0(%esi),%esi
  for(fd = 0; fd < NOFILE; fd++){
80105cc0:	83 c2 01             	add    $0x1,%edx
80105cc3:	83 fa 10             	cmp    $0x10,%edx
80105cc6:	74 28                	je     80105cf0 <sys_pipe+0xa0>
    if(proc->ofile[fd] == 0){
80105cc8:	83 7c 91 2c 00       	cmpl   $0x0,0x2c(%ecx,%edx,4)
80105ccd:	75 f1                	jne    80105cc0 <sys_pipe+0x70>
      proc->ofile[fd] = f;
80105ccf:	89 7c 91 2c          	mov    %edi,0x2c(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105cd3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80105cd6:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
80105cd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105cdb:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105cde:	31 c0                	xor    %eax,%eax
}
80105ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ce3:	5b                   	pop    %ebx
80105ce4:	5e                   	pop    %esi
80105ce5:	5f                   	pop    %edi
80105ce6:	5d                   	pop    %ebp
80105ce7:	c3                   	ret    
80105ce8:	90                   	nop
80105ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      proc->ofile[fd0] = 0;
80105cf0:	c7 46 2c 00 00 00 00 	movl   $0x0,0x2c(%esi)
80105cf7:	89 f6                	mov    %esi,%esi
80105cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    fileclose(rf);
80105d00:	83 ec 0c             	sub    $0xc,%esp
80105d03:	53                   	push   %ebx
80105d04:	e8 07 b1 ff ff       	call   80100e10 <fileclose>
    fileclose(wf);
80105d09:	58                   	pop    %eax
80105d0a:	ff 75 e4             	pushl  -0x1c(%ebp)
80105d0d:	e8 fe b0 ff ff       	call   80100e10 <fileclose>
    return -1;
80105d12:	83 c4 10             	add    $0x10,%esp
80105d15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1a:	eb c4                	jmp    80105ce0 <sys_pipe+0x90>
80105d1c:	66 90                	xchg   %ax,%ax
80105d1e:	66 90                	xchg   %ax,%ax

80105d20 <sys_clone>:
#include "mmu.h"
#include "proc.h"

int 
sys_clone(void)
{
80105d20:	55                   	push   %ebp
80105d21:	89 e5                	mov    %esp,%ebp
80105d23:	83 ec 20             	sub    $0x20,%esp
  int func_add;
  int arg;
  int stack_add;

  if (argint(0, &func_add) < 0)
80105d26:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d29:	50                   	push   %eax
80105d2a:	6a 00                	push   $0x0
80105d2c:	e8 9f f2 ff ff       	call   80104fd0 <argint>
80105d31:	83 c4 10             	add    $0x10,%esp
80105d34:	85 c0                	test   %eax,%eax
80105d36:	78 48                	js     80105d80 <sys_clone+0x60>
     return -1;
  if (argint(1, &arg) < 0)
80105d38:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d3b:	83 ec 08             	sub    $0x8,%esp
80105d3e:	50                   	push   %eax
80105d3f:	6a 01                	push   $0x1
80105d41:	e8 8a f2 ff ff       	call   80104fd0 <argint>
80105d46:	83 c4 10             	add    $0x10,%esp
80105d49:	85 c0                	test   %eax,%eax
80105d4b:	78 33                	js     80105d80 <sys_clone+0x60>
     return -1;
  if (argint(2, &stack_add) < 0)
80105d4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d50:	83 ec 08             	sub    $0x8,%esp
80105d53:	50                   	push   %eax
80105d54:	6a 02                	push   $0x2
80105d56:	e8 75 f2 ff ff       	call   80104fd0 <argint>
80105d5b:	83 c4 10             	add    $0x10,%esp
80105d5e:	85 c0                	test   %eax,%eax
80105d60:	78 1e                	js     80105d80 <sys_clone+0x60>
     return -1;
 
  return clone((void *)func_add, (void *)arg, (void *)stack_add);
80105d62:	83 ec 04             	sub    $0x4,%esp
80105d65:	ff 75 f4             	pushl  -0xc(%ebp)
80105d68:	ff 75 f0             	pushl  -0x10(%ebp)
80105d6b:	ff 75 ec             	pushl  -0x14(%ebp)
80105d6e:	e8 3d ea ff ff       	call   801047b0 <clone>
80105d73:	83 c4 10             	add    $0x10,%esp
  
}
80105d76:	c9                   	leave  
80105d77:	c3                   	ret    
80105d78:	90                   	nop
80105d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
80105d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d85:	c9                   	leave  
80105d86:	c3                   	ret    
80105d87:	89 f6                	mov    %esi,%esi
80105d89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105d90 <sys_join>:

int 
sys_join(void)
{
80105d90:	55                   	push   %ebp
80105d91:	89 e5                	mov    %esp,%ebp
80105d93:	83 ec 20             	sub    $0x20,%esp
  int stack_add;

  if (argint(0, &stack_add) < 0)
80105d96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d99:	50                   	push   %eax
80105d9a:	6a 00                	push   $0x0
80105d9c:	e8 2f f2 ff ff       	call   80104fd0 <argint>
80105da1:	83 c4 10             	add    $0x10,%esp
80105da4:	85 c0                	test   %eax,%eax
80105da6:	78 18                	js     80105dc0 <sys_join+0x30>
     return -1;

  return join((void **)stack_add);
80105da8:	83 ec 0c             	sub    $0xc,%esp
80105dab:	ff 75 f4             	pushl  -0xc(%ebp)
80105dae:	e8 3d eb ff ff       	call   801048f0 <join>
80105db3:	83 c4 10             	add    $0x10,%esp
}
80105db6:	c9                   	leave  
80105db7:	c3                   	ret    
80105db8:	90                   	nop
80105db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
80105dc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dc5:	c9                   	leave  
80105dc6:	c3                   	ret    
80105dc7:	89 f6                	mov    %esi,%esi
80105dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105dd0 <sys_myalloc>:

int 
sys_myalloc(void)
{
80105dd0:	55                   	push   %ebp
80105dd1:	89 e5                	mov    %esp,%ebp
80105dd3:	83 ec 20             	sub    $0x20,%esp
  int n;   // 分配 n 个字节
  if(argint(0, &n) < 0)
80105dd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dd9:	50                   	push   %eax
80105dda:	6a 00                	push   $0x0
80105ddc:	e8 ef f1 ff ff       	call   80104fd0 <argint>
80105de1:	83 c4 10             	add    $0x10,%esp
    return 0;
80105de4:	31 d2                	xor    %edx,%edx
  if(argint(0, &n) < 0)
80105de6:	85 c0                	test   %eax,%eax
80105de8:	78 15                	js     80105dff <sys_myalloc+0x2f>
  if(n <= 0)
80105dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ded:	85 c0                	test   %eax,%eax
80105def:	7e 0e                	jle    80105dff <sys_myalloc+0x2f>
    return 0;
  return mygrowproc(n);
80105df1:	83 ec 0c             	sub    $0xc,%esp
80105df4:	50                   	push   %eax
80105df5:	e8 c6 e7 ff ff       	call   801045c0 <mygrowproc>
80105dfa:	83 c4 10             	add    $0x10,%esp
80105dfd:	89 c2                	mov    %eax,%edx
}
80105dff:	89 d0                	mov    %edx,%eax
80105e01:	c9                   	leave  
80105e02:	c3                   	ret    
80105e03:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105e09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105e10 <sys_myfree>:

int 
sys_myfree(void) {
80105e10:	55                   	push   %ebp
80105e11:	89 e5                	mov    %esp,%ebp
80105e13:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(0, &addr) < 0)
80105e16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e19:	50                   	push   %eax
80105e1a:	6a 00                	push   $0x0
80105e1c:	e8 af f1 ff ff       	call   80104fd0 <argint>
80105e21:	83 c4 10             	add    $0x10,%esp
80105e24:	85 c0                	test   %eax,%eax
80105e26:	78 18                	js     80105e40 <sys_myfree+0x30>
    return -1;
  return myreduceproc(addr);
80105e28:	83 ec 0c             	sub    $0xc,%esp
80105e2b:	ff 75 f4             	pushl  -0xc(%ebp)
80105e2e:	e8 ad e8 ff ff       	call   801046e0 <myreduceproc>
80105e33:	83 c4 10             	add    $0x10,%esp
}
80105e36:	c9                   	leave  
80105e37:	c3                   	ret    
80105e38:	90                   	nop
80105e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e45:	c9                   	leave  
80105e46:	c3                   	ret    
80105e47:	89 f6                	mov    %esi,%esi
80105e49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105e50 <sys_getcpuid>:

//achieve sys_getcpuid, just my homework
int
sys_getcpuid()
{
80105e50:	55                   	push   %ebp
80105e51:	89 e5                	mov    %esp,%ebp
  return getcpuid();
}
80105e53:	5d                   	pop    %ebp
  return getcpuid();
80105e54:	e9 d7 da ff ff       	jmp    80103930 <getcpuid>
80105e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105e60 <sys_fork>:

int
sys_fork(void)
{
80105e60:	55                   	push   %ebp
80105e61:	89 e5                	mov    %esp,%ebp
  return fork();
}
80105e63:	5d                   	pop    %ebp
  return fork();
80105e64:	e9 b7 dc ff ff       	jmp    80103b20 <fork>
80105e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105e70 <sys_exit>:

int
sys_exit(void)
{
80105e70:	55                   	push   %ebp
80105e71:	89 e5                	mov    %esp,%ebp
80105e73:	83 ec 08             	sub    $0x8,%esp
  exit();
80105e76:	e8 25 e3 ff ff       	call   801041a0 <exit>
  return 0;  // not reached
}
80105e7b:	31 c0                	xor    %eax,%eax
80105e7d:	c9                   	leave  
80105e7e:	c3                   	ret    
80105e7f:	90                   	nop

80105e80 <sys_wait>:

int
sys_wait(void)
{
80105e80:	55                   	push   %ebp
80105e81:	89 e5                	mov    %esp,%ebp
  return wait();
}
80105e83:	5d                   	pop    %ebp
  return wait();
80105e84:	e9 b7 e0 ff ff       	jmp    80103f40 <wait>
80105e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105e90 <sys_kill>:

int
sys_kill(void)
{
80105e90:	55                   	push   %ebp
80105e91:	89 e5                	mov    %esp,%ebp
80105e93:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e99:	50                   	push   %eax
80105e9a:	6a 00                	push   $0x0
80105e9c:	e8 2f f1 ff ff       	call   80104fd0 <argint>
80105ea1:	83 c4 10             	add    $0x10,%esp
80105ea4:	85 c0                	test   %eax,%eax
80105ea6:	78 18                	js     80105ec0 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	ff 75 f4             	pushl  -0xc(%ebp)
80105eae:	e8 ed e4 ff ff       	call   801043a0 <kill>
80105eb3:	83 c4 10             	add    $0x10,%esp
}
80105eb6:	c9                   	leave  
80105eb7:	c3                   	ret    
80105eb8:	90                   	nop
80105eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105ec0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ec5:	c9                   	leave  
80105ec6:	c3                   	ret    
80105ec7:	89 f6                	mov    %esi,%esi
80105ec9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105ed0 <sys_getpid>:

int
sys_getpid(void)
{
  return proc->pid;
80105ed0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80105ed6:	55                   	push   %ebp
80105ed7:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80105ed9:	8b 40 10             	mov    0x10(%eax),%eax
}
80105edc:	5d                   	pop    %ebp
80105edd:	c3                   	ret    
80105ede:	66 90                	xchg   %ax,%ax

80105ee0 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ee0:	55                   	push   %ebp
80105ee1:	89 e5                	mov    %esp,%ebp
80105ee3:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ee4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105ee7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105eea:	50                   	push   %eax
80105eeb:	6a 00                	push   $0x0
80105eed:	e8 de f0 ff ff       	call   80104fd0 <argint>
80105ef2:	83 c4 10             	add    $0x10,%esp
80105ef5:	85 c0                	test   %eax,%eax
80105ef7:	78 27                	js     80105f20 <sys_sbrk+0x40>
    return -1;
  addr = proc->sz;
80105ef9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(growproc(n) < 0)
80105eff:	83 ec 0c             	sub    $0xc,%esp
  addr = proc->sz;
80105f02:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105f04:	ff 75 f4             	pushl  -0xc(%ebp)
80105f07:	e8 94 db ff ff       	call   80103aa0 <growproc>
80105f0c:	83 c4 10             	add    $0x10,%esp
80105f0f:	85 c0                	test   %eax,%eax
80105f11:	78 0d                	js     80105f20 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105f13:	89 d8                	mov    %ebx,%eax
80105f15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105f18:	c9                   	leave  
80105f19:	c3                   	ret    
80105f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105f20:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105f25:	eb ec                	jmp    80105f13 <sys_sbrk+0x33>
80105f27:	89 f6                	mov    %esi,%esi
80105f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105f30 <sys_sleep>:

int
sys_sleep(void)
{
80105f30:	55                   	push   %ebp
80105f31:	89 e5                	mov    %esp,%ebp
80105f33:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105f34:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105f37:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105f3a:	50                   	push   %eax
80105f3b:	6a 00                	push   $0x0
80105f3d:	e8 8e f0 ff ff       	call   80104fd0 <argint>
80105f42:	83 c4 10             	add    $0x10,%esp
80105f45:	85 c0                	test   %eax,%eax
80105f47:	0f 88 8a 00 00 00    	js     80105fd7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105f4d:	83 ec 0c             	sub    $0xc,%esp
80105f50:	68 00 7b 11 80       	push   $0x80117b00
80105f55:	e8 86 eb ff ff       	call   80104ae0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105f5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f5d:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105f60:	8b 1d 40 83 11 80    	mov    0x80118340,%ebx
  while(ticks - ticks0 < n){
80105f66:	85 d2                	test   %edx,%edx
80105f68:	75 27                	jne    80105f91 <sys_sleep+0x61>
80105f6a:	eb 54                	jmp    80105fc0 <sys_sleep+0x90>
80105f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105f70:	83 ec 08             	sub    $0x8,%esp
80105f73:	68 00 7b 11 80       	push   $0x80117b00
80105f78:	68 40 83 11 80       	push   $0x80118340
80105f7d:	e8 fe de ff ff       	call   80103e80 <sleep>
  while(ticks - ticks0 < n){
80105f82:	a1 40 83 11 80       	mov    0x80118340,%eax
80105f87:	83 c4 10             	add    $0x10,%esp
80105f8a:	29 d8                	sub    %ebx,%eax
80105f8c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105f8f:	73 2f                	jae    80105fc0 <sys_sleep+0x90>
    if(proc->killed){
80105f91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f97:	8b 40 28             	mov    0x28(%eax),%eax
80105f9a:	85 c0                	test   %eax,%eax
80105f9c:	74 d2                	je     80105f70 <sys_sleep+0x40>
      release(&tickslock);
80105f9e:	83 ec 0c             	sub    $0xc,%esp
80105fa1:	68 00 7b 11 80       	push   $0x80117b00
80105fa6:	e8 f5 ec ff ff       	call   80104ca0 <release>
      return -1;
80105fab:	83 c4 10             	add    $0x10,%esp
80105fae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&tickslock);
  return 0;
}
80105fb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105fb6:	c9                   	leave  
80105fb7:	c3                   	ret    
80105fb8:	90                   	nop
80105fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  release(&tickslock);
80105fc0:	83 ec 0c             	sub    $0xc,%esp
80105fc3:	68 00 7b 11 80       	push   $0x80117b00
80105fc8:	e8 d3 ec ff ff       	call   80104ca0 <release>
  return 0;
80105fcd:	83 c4 10             	add    $0x10,%esp
80105fd0:	31 c0                	xor    %eax,%eax
}
80105fd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105fd5:	c9                   	leave  
80105fd6:	c3                   	ret    
    return -1;
80105fd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fdc:	eb f4                	jmp    80105fd2 <sys_sleep+0xa2>
80105fde:	66 90                	xchg   %ax,%ax

80105fe0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105fe0:	55                   	push   %ebp
80105fe1:	89 e5                	mov    %esp,%ebp
80105fe3:	53                   	push   %ebx
80105fe4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105fe7:	68 00 7b 11 80       	push   $0x80117b00
80105fec:	e8 ef ea ff ff       	call   80104ae0 <acquire>
  xticks = ticks;
80105ff1:	8b 1d 40 83 11 80    	mov    0x80118340,%ebx
  release(&tickslock);
80105ff7:	c7 04 24 00 7b 11 80 	movl   $0x80117b00,(%esp)
80105ffe:	e8 9d ec ff ff       	call   80104ca0 <release>
  return xticks;
}
80106003:	89 d8                	mov    %ebx,%eax
80106005:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106008:	c9                   	leave  
80106009:	c3                   	ret    
8010600a:	66 90                	xchg   %ax,%ax
8010600c:	66 90                	xchg   %ax,%ax
8010600e:	66 90                	xchg   %ax,%ax

80106010 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106010:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106011:	b8 34 00 00 00       	mov    $0x34,%eax
80106016:	ba 43 00 00 00       	mov    $0x43,%edx
8010601b:	89 e5                	mov    %esp,%ebp
8010601d:	83 ec 14             	sub    $0x14,%esp
80106020:	ee                   	out    %al,(%dx)
80106021:	ba 40 00 00 00       	mov    $0x40,%edx
80106026:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
8010602b:	ee                   	out    %al,(%dx)
8010602c:	b8 2e 00 00 00       	mov    $0x2e,%eax
80106031:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
80106032:	6a 00                	push   $0x0
80106034:	e8 c7 d2 ff ff       	call   80103300 <picenable>
}
80106039:	83 c4 10             	add    $0x10,%esp
8010603c:	c9                   	leave  
8010603d:	c3                   	ret    

8010603e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010603e:	1e                   	push   %ds
  pushl %es
8010603f:	06                   	push   %es
  pushl %fs
80106040:	0f a0                	push   %fs
  pushl %gs
80106042:	0f a8                	push   %gs
  pushal
80106044:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106045:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106049:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010604b:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010604d:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106051:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106053:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106055:	54                   	push   %esp
  call trap
80106056:	e8 c5 00 00 00       	call   80106120 <trap>
  addl $4, %esp
8010605b:	83 c4 04             	add    $0x4,%esp

8010605e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010605e:	61                   	popa   
  popl %gs
8010605f:	0f a9                	pop    %gs
  popl %fs
80106061:	0f a1                	pop    %fs
  popl %es
80106063:	07                   	pop    %es
  popl %ds
80106064:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106065:	83 c4 08             	add    $0x8,%esp
  iret
80106068:	cf                   	iret   
80106069:	66 90                	xchg   %ax,%ax
8010606b:	66 90                	xchg   %ax,%ax
8010606d:	66 90                	xchg   %ax,%ax
8010606f:	90                   	nop

80106070 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106070:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80106071:	31 c0                	xor    %eax,%eax
{
80106073:	89 e5                	mov    %esp,%ebp
80106075:	83 ec 08             	sub    $0x8,%esp
80106078:	90                   	nop
80106079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106080:	8b 14 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%edx
80106087:	c7 04 c5 42 7b 11 80 	movl   $0x8e000008,-0x7fee84be(,%eax,8)
8010608e:	08 00 00 8e 
80106092:	66 89 14 c5 40 7b 11 	mov    %dx,-0x7fee84c0(,%eax,8)
80106099:	80 
8010609a:	c1 ea 10             	shr    $0x10,%edx
8010609d:	66 89 14 c5 46 7b 11 	mov    %dx,-0x7fee84ba(,%eax,8)
801060a4:	80 
  for(i = 0; i < 256; i++)
801060a5:	83 c0 01             	add    $0x1,%eax
801060a8:	3d 00 01 00 00       	cmp    $0x100,%eax
801060ad:	75 d1                	jne    80106080 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801060af:	a1 0c b1 10 80       	mov    0x8010b10c,%eax

  initlock(&tickslock, "time");
801060b4:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801060b7:	c7 05 42 7d 11 80 08 	movl   $0xef000008,0x80117d42
801060be:	00 00 ef 
  initlock(&tickslock, "time");
801060c1:	68 4d 82 10 80       	push   $0x8010824d
801060c6:	68 00 7b 11 80       	push   $0x80117b00
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801060cb:	66 a3 40 7d 11 80    	mov    %ax,0x80117d40
801060d1:	c1 e8 10             	shr    $0x10,%eax
801060d4:	66 a3 46 7d 11 80    	mov    %ax,0x80117d46
  initlock(&tickslock, "time");
801060da:	e8 e1 e9 ff ff       	call   80104ac0 <initlock>
}
801060df:	83 c4 10             	add    $0x10,%esp
801060e2:	c9                   	leave  
801060e3:	c3                   	ret    
801060e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801060ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801060f0 <idtinit>:

void
idtinit(void)
{
801060f0:	55                   	push   %ebp
  pd[0] = size-1;
801060f1:	b8 ff 07 00 00       	mov    $0x7ff,%eax
801060f6:	89 e5                	mov    %esp,%ebp
801060f8:	83 ec 10             	sub    $0x10,%esp
801060fb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801060ff:	b8 40 7b 11 80       	mov    $0x80117b40,%eax
80106104:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106108:	c1 e8 10             	shr    $0x10,%eax
8010610b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010610f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106112:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80106115:	c9                   	leave  
80106116:	c3                   	ret    
80106117:	89 f6                	mov    %esi,%esi
80106119:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106120 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106120:	55                   	push   %ebp
80106121:	89 e5                	mov    %esp,%ebp
80106123:	57                   	push   %edi
80106124:	56                   	push   %esi
80106125:	53                   	push   %ebx
80106126:	83 ec 0c             	sub    $0xc,%esp
80106129:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010612c:	8b 43 30             	mov    0x30(%ebx),%eax
8010612f:	83 f8 40             	cmp    $0x40,%eax
80106132:	74 6c                	je     801061a0 <trap+0x80>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80106134:	83 e8 20             	sub    $0x20,%eax
80106137:	83 f8 1f             	cmp    $0x1f,%eax
8010613a:	0f 87 98 00 00 00    	ja     801061d8 <trap+0xb8>
80106140:	ff 24 85 f4 82 10 80 	jmp    *-0x7fef7d0c(,%eax,4)
80106147:	89 f6                	mov    %esi,%esi
80106149:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  case T_IRQ0 + IRQ_TIMER:
    if(cpunum() == 0){
80106150:	e8 cb c5 ff ff       	call   80102720 <cpunum>
80106155:	85 c0                	test   %eax,%eax
80106157:	0f 84 a3 01 00 00    	je     80106300 <trap+0x1e0>
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
8010615d:	e8 6e c6 ff ff       	call   801027d0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106162:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106168:	85 c0                	test   %eax,%eax
8010616a:	74 29                	je     80106195 <trap+0x75>
8010616c:	8b 50 28             	mov    0x28(%eax),%edx
8010616f:	85 d2                	test   %edx,%edx
80106171:	0f 85 b6 00 00 00    	jne    8010622d <trap+0x10d>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106177:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010617b:	0f 84 3f 01 00 00    	je     801062c0 <trap+0x1a0>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106181:	8b 40 28             	mov    0x28(%eax),%eax
80106184:	85 c0                	test   %eax,%eax
80106186:	74 0d                	je     80106195 <trap+0x75>
80106188:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010618c:	83 e0 03             	and    $0x3,%eax
8010618f:	66 83 f8 03          	cmp    $0x3,%ax
80106193:	74 31                	je     801061c6 <trap+0xa6>
    exit();
}
80106195:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106198:	5b                   	pop    %ebx
80106199:	5e                   	pop    %esi
8010619a:	5f                   	pop    %edi
8010619b:	5d                   	pop    %ebp
8010619c:	c3                   	ret    
8010619d:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
801061a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061a6:	8b 70 28             	mov    0x28(%eax),%esi
801061a9:	85 f6                	test   %esi,%esi
801061ab:	0f 85 37 01 00 00    	jne    801062e8 <trap+0x1c8>
    proc->tf = tf;
801061b1:	89 58 1c             	mov    %ebx,0x1c(%eax)
    syscall();
801061b4:	e8 27 ef ff ff       	call   801050e0 <syscall>
    if(proc->killed)
801061b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061bf:	8b 58 28             	mov    0x28(%eax),%ebx
801061c2:	85 db                	test   %ebx,%ebx
801061c4:	74 cf                	je     80106195 <trap+0x75>
}
801061c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061c9:	5b                   	pop    %ebx
801061ca:	5e                   	pop    %esi
801061cb:	5f                   	pop    %edi
801061cc:	5d                   	pop    %ebp
      exit();
801061cd:	e9 ce df ff ff       	jmp    801041a0 <exit>
801061d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(proc == 0 || (tf->cs&3) == 0){
801061d8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801061df:	8b 73 38             	mov    0x38(%ebx),%esi
801061e2:	85 c9                	test   %ecx,%ecx
801061e4:	0f 84 4a 01 00 00    	je     80106334 <trap+0x214>
801061ea:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801061ee:	0f 84 40 01 00 00    	je     80106334 <trap+0x214>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801061f4:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061f7:	e8 24 c5 ff ff       	call   80102720 <cpunum>
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
801061fc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106203:	57                   	push   %edi
80106204:	56                   	push   %esi
80106205:	50                   	push   %eax
80106206:	ff 73 34             	pushl  0x34(%ebx)
80106209:	ff 73 30             	pushl  0x30(%ebx)
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
8010620c:	8d 42 70             	lea    0x70(%edx),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010620f:	50                   	push   %eax
80106210:	ff 72 10             	pushl  0x10(%edx)
80106213:	68 b0 82 10 80       	push   $0x801082b0
80106218:	e8 23 a4 ff ff       	call   80100640 <cprintf>
    proc->killed = 1;
8010621d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106223:	83 c4 20             	add    $0x20,%esp
80106226:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010622d:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
80106231:	83 e2 03             	and    $0x3,%edx
80106234:	66 83 fa 03          	cmp    $0x3,%dx
80106238:	0f 85 39 ff ff ff    	jne    80106177 <trap+0x57>
    exit();
8010623e:	e8 5d df ff ff       	call   801041a0 <exit>
80106243:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106249:	85 c0                	test   %eax,%eax
8010624b:	0f 85 26 ff ff ff    	jne    80106177 <trap+0x57>
80106251:	e9 3f ff ff ff       	jmp    80106195 <trap+0x75>
80106256:	8d 76 00             	lea    0x0(%esi),%esi
80106259:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    kbdintr();
80106260:	e8 9b c3 ff ff       	call   80102600 <kbdintr>
    lapiceoi();
80106265:	e8 66 c5 ff ff       	call   801027d0 <lapiceoi>
    break;
8010626a:	e9 f3 fe ff ff       	jmp    80106162 <trap+0x42>
8010626f:	90                   	nop
    uartintr();
80106270:	e8 5b 02 00 00       	call   801064d0 <uartintr>
80106275:	e9 e3 fe ff ff       	jmp    8010615d <trap+0x3d>
8010627a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106280:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80106284:	8b 7b 38             	mov    0x38(%ebx),%edi
80106287:	e8 94 c4 ff ff       	call   80102720 <cpunum>
8010628c:	57                   	push   %edi
8010628d:	56                   	push   %esi
8010628e:	50                   	push   %eax
8010628f:	68 58 82 10 80       	push   $0x80108258
80106294:	e8 a7 a3 ff ff       	call   80100640 <cprintf>
    lapiceoi();
80106299:	e8 32 c5 ff ff       	call   801027d0 <lapiceoi>
    break;
8010629e:	83 c4 10             	add    $0x10,%esp
801062a1:	e9 bc fe ff ff       	jmp    80106162 <trap+0x42>
801062a6:	8d 76 00             	lea    0x0(%esi),%esi
801062a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ideintr();
801062b0:	e8 ab bd ff ff       	call   80102060 <ideintr>
    lapiceoi();
801062b5:	e8 16 c5 ff ff       	call   801027d0 <lapiceoi>
    break;
801062ba:	e9 a3 fe ff ff       	jmp    80106162 <trap+0x42>
801062bf:	90                   	nop
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801062c0:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801062c4:	0f 85 b7 fe ff ff    	jne    80106181 <trap+0x61>
    yield();
801062ca:	e8 61 db ff ff       	call   80103e30 <yield>
801062cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801062d5:	85 c0                	test   %eax,%eax
801062d7:	0f 85 a4 fe ff ff    	jne    80106181 <trap+0x61>
801062dd:	e9 b3 fe ff ff       	jmp    80106195 <trap+0x75>
801062e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
801062e8:	e8 b3 de ff ff       	call   801041a0 <exit>
801062ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062f3:	e9 b9 fe ff ff       	jmp    801061b1 <trap+0x91>
801062f8:	90                   	nop
801062f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      acquire(&tickslock);
80106300:	83 ec 0c             	sub    $0xc,%esp
80106303:	68 00 7b 11 80       	push   $0x80117b00
80106308:	e8 d3 e7 ff ff       	call   80104ae0 <acquire>
      wakeup(&ticks);
8010630d:	c7 04 24 40 83 11 80 	movl   $0x80118340,(%esp)
      ticks++;
80106314:	83 05 40 83 11 80 01 	addl   $0x1,0x80118340
      wakeup(&ticks);
8010631b:	e8 c0 dd ff ff       	call   801040e0 <wakeup>
      release(&tickslock);
80106320:	c7 04 24 00 7b 11 80 	movl   $0x80117b00,(%esp)
80106327:	e8 74 e9 ff ff       	call   80104ca0 <release>
8010632c:	83 c4 10             	add    $0x10,%esp
8010632f:	e9 29 fe ff ff       	jmp    8010615d <trap+0x3d>
80106334:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106337:	e8 e4 c3 ff ff       	call   80102720 <cpunum>
8010633c:	83 ec 0c             	sub    $0xc,%esp
8010633f:	57                   	push   %edi
80106340:	56                   	push   %esi
80106341:	50                   	push   %eax
80106342:	ff 73 30             	pushl  0x30(%ebx)
80106345:	68 7c 82 10 80       	push   $0x8010827c
8010634a:	e8 f1 a2 ff ff       	call   80100640 <cprintf>
      panic("trap");
8010634f:	83 c4 14             	add    $0x14,%esp
80106352:	68 52 82 10 80       	push   $0x80108252
80106357:	e8 14 a0 ff ff       	call   80100370 <panic>
8010635c:	66 90                	xchg   %ax,%ax
8010635e:	66 90                	xchg   %ax,%ax

80106360 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80106360:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
{
80106365:	55                   	push   %ebp
80106366:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106368:	85 c0                	test   %eax,%eax
8010636a:	74 1c                	je     80106388 <uartgetc+0x28>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010636c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106371:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80106372:	a8 01                	test   $0x1,%al
80106374:	74 12                	je     80106388 <uartgetc+0x28>
80106376:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010637b:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010637c:	0f b6 c0             	movzbl %al,%eax
}
8010637f:	5d                   	pop    %ebp
80106380:	c3                   	ret    
80106381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80106388:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010638d:	5d                   	pop    %ebp
8010638e:	c3                   	ret    
8010638f:	90                   	nop

80106390 <uartputc.part.0>:
uartputc(int c)
80106390:	55                   	push   %ebp
80106391:	89 e5                	mov    %esp,%ebp
80106393:	57                   	push   %edi
80106394:	56                   	push   %esi
80106395:	53                   	push   %ebx
80106396:	89 c7                	mov    %eax,%edi
80106398:	bb 80 00 00 00       	mov    $0x80,%ebx
8010639d:	be fd 03 00 00       	mov    $0x3fd,%esi
801063a2:	83 ec 0c             	sub    $0xc,%esp
801063a5:	eb 1b                	jmp    801063c2 <uartputc.part.0+0x32>
801063a7:	89 f6                	mov    %esi,%esi
801063a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    microdelay(10);
801063b0:	83 ec 0c             	sub    $0xc,%esp
801063b3:	6a 0a                	push   $0xa
801063b5:	e8 36 c4 ff ff       	call   801027f0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801063ba:	83 c4 10             	add    $0x10,%esp
801063bd:	83 eb 01             	sub    $0x1,%ebx
801063c0:	74 07                	je     801063c9 <uartputc.part.0+0x39>
801063c2:	89 f2                	mov    %esi,%edx
801063c4:	ec                   	in     (%dx),%al
801063c5:	a8 20                	test   $0x20,%al
801063c7:	74 e7                	je     801063b0 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801063c9:	ba f8 03 00 00       	mov    $0x3f8,%edx
801063ce:	89 f8                	mov    %edi,%eax
801063d0:	ee                   	out    %al,(%dx)
}
801063d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063d4:	5b                   	pop    %ebx
801063d5:	5e                   	pop    %esi
801063d6:	5f                   	pop    %edi
801063d7:	5d                   	pop    %ebp
801063d8:	c3                   	ret    
801063d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801063e0 <uartinit>:
{
801063e0:	55                   	push   %ebp
801063e1:	31 c9                	xor    %ecx,%ecx
801063e3:	89 c8                	mov    %ecx,%eax
801063e5:	89 e5                	mov    %esp,%ebp
801063e7:	57                   	push   %edi
801063e8:	56                   	push   %esi
801063e9:	53                   	push   %ebx
801063ea:	bb fa 03 00 00       	mov    $0x3fa,%ebx
801063ef:	89 da                	mov    %ebx,%edx
801063f1:	83 ec 0c             	sub    $0xc,%esp
801063f4:	ee                   	out    %al,(%dx)
801063f5:	bf fb 03 00 00       	mov    $0x3fb,%edi
801063fa:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801063ff:	89 fa                	mov    %edi,%edx
80106401:	ee                   	out    %al,(%dx)
80106402:	b8 0c 00 00 00       	mov    $0xc,%eax
80106407:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010640c:	ee                   	out    %al,(%dx)
8010640d:	be f9 03 00 00       	mov    $0x3f9,%esi
80106412:	89 c8                	mov    %ecx,%eax
80106414:	89 f2                	mov    %esi,%edx
80106416:	ee                   	out    %al,(%dx)
80106417:	b8 03 00 00 00       	mov    $0x3,%eax
8010641c:	89 fa                	mov    %edi,%edx
8010641e:	ee                   	out    %al,(%dx)
8010641f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106424:	89 c8                	mov    %ecx,%eax
80106426:	ee                   	out    %al,(%dx)
80106427:	b8 01 00 00 00       	mov    $0x1,%eax
8010642c:	89 f2                	mov    %esi,%edx
8010642e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010642f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106434:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80106435:	3c ff                	cmp    $0xff,%al
80106437:	74 5a                	je     80106493 <uartinit+0xb3>
  uart = 1;
80106439:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
80106440:	00 00 00 
80106443:	89 da                	mov    %ebx,%edx
80106445:	ec                   	in     (%dx),%al
80106446:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010644b:	ec                   	in     (%dx),%al
  picenable(IRQ_COM1);
8010644c:	83 ec 0c             	sub    $0xc,%esp
8010644f:	6a 04                	push   $0x4
80106451:	e8 aa ce ff ff       	call   80103300 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106456:	59                   	pop    %ecx
80106457:	5b                   	pop    %ebx
80106458:	6a 00                	push   $0x0
8010645a:	6a 04                	push   $0x4
  for(p="xv6...\n"; *p; p++)
8010645c:	bb 74 83 10 80       	mov    $0x80108374,%ebx
  ioapicenable(IRQ_COM1, 0);
80106461:	e8 5a be ff ff       	call   801022c0 <ioapicenable>
80106466:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106469:	b8 78 00 00 00       	mov    $0x78,%eax
8010646e:	eb 0a                	jmp    8010647a <uartinit+0x9a>
80106470:	83 c3 01             	add    $0x1,%ebx
80106473:	0f be 03             	movsbl (%ebx),%eax
80106476:	84 c0                	test   %al,%al
80106478:	74 19                	je     80106493 <uartinit+0xb3>
  if(!uart)
8010647a:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
80106480:	85 d2                	test   %edx,%edx
80106482:	74 ec                	je     80106470 <uartinit+0x90>
  for(p="xv6...\n"; *p; p++)
80106484:	83 c3 01             	add    $0x1,%ebx
80106487:	e8 04 ff ff ff       	call   80106390 <uartputc.part.0>
8010648c:	0f be 03             	movsbl (%ebx),%eax
8010648f:	84 c0                	test   %al,%al
80106491:	75 e7                	jne    8010647a <uartinit+0x9a>
}
80106493:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106496:	5b                   	pop    %ebx
80106497:	5e                   	pop    %esi
80106498:	5f                   	pop    %edi
80106499:	5d                   	pop    %ebp
8010649a:	c3                   	ret    
8010649b:	90                   	nop
8010649c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801064a0 <uartputc>:
  if(!uart)
801064a0:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
{
801064a6:	55                   	push   %ebp
801064a7:	89 e5                	mov    %esp,%ebp
  if(!uart)
801064a9:	85 d2                	test   %edx,%edx
{
801064ab:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
801064ae:	74 10                	je     801064c0 <uartputc+0x20>
}
801064b0:	5d                   	pop    %ebp
801064b1:	e9 da fe ff ff       	jmp    80106390 <uartputc.part.0>
801064b6:	8d 76 00             	lea    0x0(%esi),%esi
801064b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801064c0:	5d                   	pop    %ebp
801064c1:	c3                   	ret    
801064c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801064c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801064d0 <uartintr>:

void
uartintr(void)
{
801064d0:	55                   	push   %ebp
801064d1:	89 e5                	mov    %esp,%ebp
801064d3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801064d6:	68 60 63 10 80       	push   $0x80106360
801064db:	e8 10 a3 ff ff       	call   801007f0 <consoleintr>
}
801064e0:	83 c4 10             	add    $0x10,%esp
801064e3:	c9                   	leave  
801064e4:	c3                   	ret    

801064e5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801064e5:	6a 00                	push   $0x0
  pushl $0
801064e7:	6a 00                	push   $0x0
  jmp alltraps
801064e9:	e9 50 fb ff ff       	jmp    8010603e <alltraps>

801064ee <vector1>:
.globl vector1
vector1:
  pushl $0
801064ee:	6a 00                	push   $0x0
  pushl $1
801064f0:	6a 01                	push   $0x1
  jmp alltraps
801064f2:	e9 47 fb ff ff       	jmp    8010603e <alltraps>

801064f7 <vector2>:
.globl vector2
vector2:
  pushl $0
801064f7:	6a 00                	push   $0x0
  pushl $2
801064f9:	6a 02                	push   $0x2
  jmp alltraps
801064fb:	e9 3e fb ff ff       	jmp    8010603e <alltraps>

80106500 <vector3>:
.globl vector3
vector3:
  pushl $0
80106500:	6a 00                	push   $0x0
  pushl $3
80106502:	6a 03                	push   $0x3
  jmp alltraps
80106504:	e9 35 fb ff ff       	jmp    8010603e <alltraps>

80106509 <vector4>:
.globl vector4
vector4:
  pushl $0
80106509:	6a 00                	push   $0x0
  pushl $4
8010650b:	6a 04                	push   $0x4
  jmp alltraps
8010650d:	e9 2c fb ff ff       	jmp    8010603e <alltraps>

80106512 <vector5>:
.globl vector5
vector5:
  pushl $0
80106512:	6a 00                	push   $0x0
  pushl $5
80106514:	6a 05                	push   $0x5
  jmp alltraps
80106516:	e9 23 fb ff ff       	jmp    8010603e <alltraps>

8010651b <vector6>:
.globl vector6
vector6:
  pushl $0
8010651b:	6a 00                	push   $0x0
  pushl $6
8010651d:	6a 06                	push   $0x6
  jmp alltraps
8010651f:	e9 1a fb ff ff       	jmp    8010603e <alltraps>

80106524 <vector7>:
.globl vector7
vector7:
  pushl $0
80106524:	6a 00                	push   $0x0
  pushl $7
80106526:	6a 07                	push   $0x7
  jmp alltraps
80106528:	e9 11 fb ff ff       	jmp    8010603e <alltraps>

8010652d <vector8>:
.globl vector8
vector8:
  pushl $8
8010652d:	6a 08                	push   $0x8
  jmp alltraps
8010652f:	e9 0a fb ff ff       	jmp    8010603e <alltraps>

80106534 <vector9>:
.globl vector9
vector9:
  pushl $0
80106534:	6a 00                	push   $0x0
  pushl $9
80106536:	6a 09                	push   $0x9
  jmp alltraps
80106538:	e9 01 fb ff ff       	jmp    8010603e <alltraps>

8010653d <vector10>:
.globl vector10
vector10:
  pushl $10
8010653d:	6a 0a                	push   $0xa
  jmp alltraps
8010653f:	e9 fa fa ff ff       	jmp    8010603e <alltraps>

80106544 <vector11>:
.globl vector11
vector11:
  pushl $11
80106544:	6a 0b                	push   $0xb
  jmp alltraps
80106546:	e9 f3 fa ff ff       	jmp    8010603e <alltraps>

8010654b <vector12>:
.globl vector12
vector12:
  pushl $12
8010654b:	6a 0c                	push   $0xc
  jmp alltraps
8010654d:	e9 ec fa ff ff       	jmp    8010603e <alltraps>

80106552 <vector13>:
.globl vector13
vector13:
  pushl $13
80106552:	6a 0d                	push   $0xd
  jmp alltraps
80106554:	e9 e5 fa ff ff       	jmp    8010603e <alltraps>

80106559 <vector14>:
.globl vector14
vector14:
  pushl $14
80106559:	6a 0e                	push   $0xe
  jmp alltraps
8010655b:	e9 de fa ff ff       	jmp    8010603e <alltraps>

80106560 <vector15>:
.globl vector15
vector15:
  pushl $0
80106560:	6a 00                	push   $0x0
  pushl $15
80106562:	6a 0f                	push   $0xf
  jmp alltraps
80106564:	e9 d5 fa ff ff       	jmp    8010603e <alltraps>

80106569 <vector16>:
.globl vector16
vector16:
  pushl $0
80106569:	6a 00                	push   $0x0
  pushl $16
8010656b:	6a 10                	push   $0x10
  jmp alltraps
8010656d:	e9 cc fa ff ff       	jmp    8010603e <alltraps>

80106572 <vector17>:
.globl vector17
vector17:
  pushl $17
80106572:	6a 11                	push   $0x11
  jmp alltraps
80106574:	e9 c5 fa ff ff       	jmp    8010603e <alltraps>

80106579 <vector18>:
.globl vector18
vector18:
  pushl $0
80106579:	6a 00                	push   $0x0
  pushl $18
8010657b:	6a 12                	push   $0x12
  jmp alltraps
8010657d:	e9 bc fa ff ff       	jmp    8010603e <alltraps>

80106582 <vector19>:
.globl vector19
vector19:
  pushl $0
80106582:	6a 00                	push   $0x0
  pushl $19
80106584:	6a 13                	push   $0x13
  jmp alltraps
80106586:	e9 b3 fa ff ff       	jmp    8010603e <alltraps>

8010658b <vector20>:
.globl vector20
vector20:
  pushl $0
8010658b:	6a 00                	push   $0x0
  pushl $20
8010658d:	6a 14                	push   $0x14
  jmp alltraps
8010658f:	e9 aa fa ff ff       	jmp    8010603e <alltraps>

80106594 <vector21>:
.globl vector21
vector21:
  pushl $0
80106594:	6a 00                	push   $0x0
  pushl $21
80106596:	6a 15                	push   $0x15
  jmp alltraps
80106598:	e9 a1 fa ff ff       	jmp    8010603e <alltraps>

8010659d <vector22>:
.globl vector22
vector22:
  pushl $0
8010659d:	6a 00                	push   $0x0
  pushl $22
8010659f:	6a 16                	push   $0x16
  jmp alltraps
801065a1:	e9 98 fa ff ff       	jmp    8010603e <alltraps>

801065a6 <vector23>:
.globl vector23
vector23:
  pushl $0
801065a6:	6a 00                	push   $0x0
  pushl $23
801065a8:	6a 17                	push   $0x17
  jmp alltraps
801065aa:	e9 8f fa ff ff       	jmp    8010603e <alltraps>

801065af <vector24>:
.globl vector24
vector24:
  pushl $0
801065af:	6a 00                	push   $0x0
  pushl $24
801065b1:	6a 18                	push   $0x18
  jmp alltraps
801065b3:	e9 86 fa ff ff       	jmp    8010603e <alltraps>

801065b8 <vector25>:
.globl vector25
vector25:
  pushl $0
801065b8:	6a 00                	push   $0x0
  pushl $25
801065ba:	6a 19                	push   $0x19
  jmp alltraps
801065bc:	e9 7d fa ff ff       	jmp    8010603e <alltraps>

801065c1 <vector26>:
.globl vector26
vector26:
  pushl $0
801065c1:	6a 00                	push   $0x0
  pushl $26
801065c3:	6a 1a                	push   $0x1a
  jmp alltraps
801065c5:	e9 74 fa ff ff       	jmp    8010603e <alltraps>

801065ca <vector27>:
.globl vector27
vector27:
  pushl $0
801065ca:	6a 00                	push   $0x0
  pushl $27
801065cc:	6a 1b                	push   $0x1b
  jmp alltraps
801065ce:	e9 6b fa ff ff       	jmp    8010603e <alltraps>

801065d3 <vector28>:
.globl vector28
vector28:
  pushl $0
801065d3:	6a 00                	push   $0x0
  pushl $28
801065d5:	6a 1c                	push   $0x1c
  jmp alltraps
801065d7:	e9 62 fa ff ff       	jmp    8010603e <alltraps>

801065dc <vector29>:
.globl vector29
vector29:
  pushl $0
801065dc:	6a 00                	push   $0x0
  pushl $29
801065de:	6a 1d                	push   $0x1d
  jmp alltraps
801065e0:	e9 59 fa ff ff       	jmp    8010603e <alltraps>

801065e5 <vector30>:
.globl vector30
vector30:
  pushl $0
801065e5:	6a 00                	push   $0x0
  pushl $30
801065e7:	6a 1e                	push   $0x1e
  jmp alltraps
801065e9:	e9 50 fa ff ff       	jmp    8010603e <alltraps>

801065ee <vector31>:
.globl vector31
vector31:
  pushl $0
801065ee:	6a 00                	push   $0x0
  pushl $31
801065f0:	6a 1f                	push   $0x1f
  jmp alltraps
801065f2:	e9 47 fa ff ff       	jmp    8010603e <alltraps>

801065f7 <vector32>:
.globl vector32
vector32:
  pushl $0
801065f7:	6a 00                	push   $0x0
  pushl $32
801065f9:	6a 20                	push   $0x20
  jmp alltraps
801065fb:	e9 3e fa ff ff       	jmp    8010603e <alltraps>

80106600 <vector33>:
.globl vector33
vector33:
  pushl $0
80106600:	6a 00                	push   $0x0
  pushl $33
80106602:	6a 21                	push   $0x21
  jmp alltraps
80106604:	e9 35 fa ff ff       	jmp    8010603e <alltraps>

80106609 <vector34>:
.globl vector34
vector34:
  pushl $0
80106609:	6a 00                	push   $0x0
  pushl $34
8010660b:	6a 22                	push   $0x22
  jmp alltraps
8010660d:	e9 2c fa ff ff       	jmp    8010603e <alltraps>

80106612 <vector35>:
.globl vector35
vector35:
  pushl $0
80106612:	6a 00                	push   $0x0
  pushl $35
80106614:	6a 23                	push   $0x23
  jmp alltraps
80106616:	e9 23 fa ff ff       	jmp    8010603e <alltraps>

8010661b <vector36>:
.globl vector36
vector36:
  pushl $0
8010661b:	6a 00                	push   $0x0
  pushl $36
8010661d:	6a 24                	push   $0x24
  jmp alltraps
8010661f:	e9 1a fa ff ff       	jmp    8010603e <alltraps>

80106624 <vector37>:
.globl vector37
vector37:
  pushl $0
80106624:	6a 00                	push   $0x0
  pushl $37
80106626:	6a 25                	push   $0x25
  jmp alltraps
80106628:	e9 11 fa ff ff       	jmp    8010603e <alltraps>

8010662d <vector38>:
.globl vector38
vector38:
  pushl $0
8010662d:	6a 00                	push   $0x0
  pushl $38
8010662f:	6a 26                	push   $0x26
  jmp alltraps
80106631:	e9 08 fa ff ff       	jmp    8010603e <alltraps>

80106636 <vector39>:
.globl vector39
vector39:
  pushl $0
80106636:	6a 00                	push   $0x0
  pushl $39
80106638:	6a 27                	push   $0x27
  jmp alltraps
8010663a:	e9 ff f9 ff ff       	jmp    8010603e <alltraps>

8010663f <vector40>:
.globl vector40
vector40:
  pushl $0
8010663f:	6a 00                	push   $0x0
  pushl $40
80106641:	6a 28                	push   $0x28
  jmp alltraps
80106643:	e9 f6 f9 ff ff       	jmp    8010603e <alltraps>

80106648 <vector41>:
.globl vector41
vector41:
  pushl $0
80106648:	6a 00                	push   $0x0
  pushl $41
8010664a:	6a 29                	push   $0x29
  jmp alltraps
8010664c:	e9 ed f9 ff ff       	jmp    8010603e <alltraps>

80106651 <vector42>:
.globl vector42
vector42:
  pushl $0
80106651:	6a 00                	push   $0x0
  pushl $42
80106653:	6a 2a                	push   $0x2a
  jmp alltraps
80106655:	e9 e4 f9 ff ff       	jmp    8010603e <alltraps>

8010665a <vector43>:
.globl vector43
vector43:
  pushl $0
8010665a:	6a 00                	push   $0x0
  pushl $43
8010665c:	6a 2b                	push   $0x2b
  jmp alltraps
8010665e:	e9 db f9 ff ff       	jmp    8010603e <alltraps>

80106663 <vector44>:
.globl vector44
vector44:
  pushl $0
80106663:	6a 00                	push   $0x0
  pushl $44
80106665:	6a 2c                	push   $0x2c
  jmp alltraps
80106667:	e9 d2 f9 ff ff       	jmp    8010603e <alltraps>

8010666c <vector45>:
.globl vector45
vector45:
  pushl $0
8010666c:	6a 00                	push   $0x0
  pushl $45
8010666e:	6a 2d                	push   $0x2d
  jmp alltraps
80106670:	e9 c9 f9 ff ff       	jmp    8010603e <alltraps>

80106675 <vector46>:
.globl vector46
vector46:
  pushl $0
80106675:	6a 00                	push   $0x0
  pushl $46
80106677:	6a 2e                	push   $0x2e
  jmp alltraps
80106679:	e9 c0 f9 ff ff       	jmp    8010603e <alltraps>

8010667e <vector47>:
.globl vector47
vector47:
  pushl $0
8010667e:	6a 00                	push   $0x0
  pushl $47
80106680:	6a 2f                	push   $0x2f
  jmp alltraps
80106682:	e9 b7 f9 ff ff       	jmp    8010603e <alltraps>

80106687 <vector48>:
.globl vector48
vector48:
  pushl $0
80106687:	6a 00                	push   $0x0
  pushl $48
80106689:	6a 30                	push   $0x30
  jmp alltraps
8010668b:	e9 ae f9 ff ff       	jmp    8010603e <alltraps>

80106690 <vector49>:
.globl vector49
vector49:
  pushl $0
80106690:	6a 00                	push   $0x0
  pushl $49
80106692:	6a 31                	push   $0x31
  jmp alltraps
80106694:	e9 a5 f9 ff ff       	jmp    8010603e <alltraps>

80106699 <vector50>:
.globl vector50
vector50:
  pushl $0
80106699:	6a 00                	push   $0x0
  pushl $50
8010669b:	6a 32                	push   $0x32
  jmp alltraps
8010669d:	e9 9c f9 ff ff       	jmp    8010603e <alltraps>

801066a2 <vector51>:
.globl vector51
vector51:
  pushl $0
801066a2:	6a 00                	push   $0x0
  pushl $51
801066a4:	6a 33                	push   $0x33
  jmp alltraps
801066a6:	e9 93 f9 ff ff       	jmp    8010603e <alltraps>

801066ab <vector52>:
.globl vector52
vector52:
  pushl $0
801066ab:	6a 00                	push   $0x0
  pushl $52
801066ad:	6a 34                	push   $0x34
  jmp alltraps
801066af:	e9 8a f9 ff ff       	jmp    8010603e <alltraps>

801066b4 <vector53>:
.globl vector53
vector53:
  pushl $0
801066b4:	6a 00                	push   $0x0
  pushl $53
801066b6:	6a 35                	push   $0x35
  jmp alltraps
801066b8:	e9 81 f9 ff ff       	jmp    8010603e <alltraps>

801066bd <vector54>:
.globl vector54
vector54:
  pushl $0
801066bd:	6a 00                	push   $0x0
  pushl $54
801066bf:	6a 36                	push   $0x36
  jmp alltraps
801066c1:	e9 78 f9 ff ff       	jmp    8010603e <alltraps>

801066c6 <vector55>:
.globl vector55
vector55:
  pushl $0
801066c6:	6a 00                	push   $0x0
  pushl $55
801066c8:	6a 37                	push   $0x37
  jmp alltraps
801066ca:	e9 6f f9 ff ff       	jmp    8010603e <alltraps>

801066cf <vector56>:
.globl vector56
vector56:
  pushl $0
801066cf:	6a 00                	push   $0x0
  pushl $56
801066d1:	6a 38                	push   $0x38
  jmp alltraps
801066d3:	e9 66 f9 ff ff       	jmp    8010603e <alltraps>

801066d8 <vector57>:
.globl vector57
vector57:
  pushl $0
801066d8:	6a 00                	push   $0x0
  pushl $57
801066da:	6a 39                	push   $0x39
  jmp alltraps
801066dc:	e9 5d f9 ff ff       	jmp    8010603e <alltraps>

801066e1 <vector58>:
.globl vector58
vector58:
  pushl $0
801066e1:	6a 00                	push   $0x0
  pushl $58
801066e3:	6a 3a                	push   $0x3a
  jmp alltraps
801066e5:	e9 54 f9 ff ff       	jmp    8010603e <alltraps>

801066ea <vector59>:
.globl vector59
vector59:
  pushl $0
801066ea:	6a 00                	push   $0x0
  pushl $59
801066ec:	6a 3b                	push   $0x3b
  jmp alltraps
801066ee:	e9 4b f9 ff ff       	jmp    8010603e <alltraps>

801066f3 <vector60>:
.globl vector60
vector60:
  pushl $0
801066f3:	6a 00                	push   $0x0
  pushl $60
801066f5:	6a 3c                	push   $0x3c
  jmp alltraps
801066f7:	e9 42 f9 ff ff       	jmp    8010603e <alltraps>

801066fc <vector61>:
.globl vector61
vector61:
  pushl $0
801066fc:	6a 00                	push   $0x0
  pushl $61
801066fe:	6a 3d                	push   $0x3d
  jmp alltraps
80106700:	e9 39 f9 ff ff       	jmp    8010603e <alltraps>

80106705 <vector62>:
.globl vector62
vector62:
  pushl $0
80106705:	6a 00                	push   $0x0
  pushl $62
80106707:	6a 3e                	push   $0x3e
  jmp alltraps
80106709:	e9 30 f9 ff ff       	jmp    8010603e <alltraps>

8010670e <vector63>:
.globl vector63
vector63:
  pushl $0
8010670e:	6a 00                	push   $0x0
  pushl $63
80106710:	6a 3f                	push   $0x3f
  jmp alltraps
80106712:	e9 27 f9 ff ff       	jmp    8010603e <alltraps>

80106717 <vector64>:
.globl vector64
vector64:
  pushl $0
80106717:	6a 00                	push   $0x0
  pushl $64
80106719:	6a 40                	push   $0x40
  jmp alltraps
8010671b:	e9 1e f9 ff ff       	jmp    8010603e <alltraps>

80106720 <vector65>:
.globl vector65
vector65:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $65
80106722:	6a 41                	push   $0x41
  jmp alltraps
80106724:	e9 15 f9 ff ff       	jmp    8010603e <alltraps>

80106729 <vector66>:
.globl vector66
vector66:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $66
8010672b:	6a 42                	push   $0x42
  jmp alltraps
8010672d:	e9 0c f9 ff ff       	jmp    8010603e <alltraps>

80106732 <vector67>:
.globl vector67
vector67:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $67
80106734:	6a 43                	push   $0x43
  jmp alltraps
80106736:	e9 03 f9 ff ff       	jmp    8010603e <alltraps>

8010673b <vector68>:
.globl vector68
vector68:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $68
8010673d:	6a 44                	push   $0x44
  jmp alltraps
8010673f:	e9 fa f8 ff ff       	jmp    8010603e <alltraps>

80106744 <vector69>:
.globl vector69
vector69:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $69
80106746:	6a 45                	push   $0x45
  jmp alltraps
80106748:	e9 f1 f8 ff ff       	jmp    8010603e <alltraps>

8010674d <vector70>:
.globl vector70
vector70:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $70
8010674f:	6a 46                	push   $0x46
  jmp alltraps
80106751:	e9 e8 f8 ff ff       	jmp    8010603e <alltraps>

80106756 <vector71>:
.globl vector71
vector71:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $71
80106758:	6a 47                	push   $0x47
  jmp alltraps
8010675a:	e9 df f8 ff ff       	jmp    8010603e <alltraps>

8010675f <vector72>:
.globl vector72
vector72:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $72
80106761:	6a 48                	push   $0x48
  jmp alltraps
80106763:	e9 d6 f8 ff ff       	jmp    8010603e <alltraps>

80106768 <vector73>:
.globl vector73
vector73:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $73
8010676a:	6a 49                	push   $0x49
  jmp alltraps
8010676c:	e9 cd f8 ff ff       	jmp    8010603e <alltraps>

80106771 <vector74>:
.globl vector74
vector74:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $74
80106773:	6a 4a                	push   $0x4a
  jmp alltraps
80106775:	e9 c4 f8 ff ff       	jmp    8010603e <alltraps>

8010677a <vector75>:
.globl vector75
vector75:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $75
8010677c:	6a 4b                	push   $0x4b
  jmp alltraps
8010677e:	e9 bb f8 ff ff       	jmp    8010603e <alltraps>

80106783 <vector76>:
.globl vector76
vector76:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $76
80106785:	6a 4c                	push   $0x4c
  jmp alltraps
80106787:	e9 b2 f8 ff ff       	jmp    8010603e <alltraps>

8010678c <vector77>:
.globl vector77
vector77:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $77
8010678e:	6a 4d                	push   $0x4d
  jmp alltraps
80106790:	e9 a9 f8 ff ff       	jmp    8010603e <alltraps>

80106795 <vector78>:
.globl vector78
vector78:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $78
80106797:	6a 4e                	push   $0x4e
  jmp alltraps
80106799:	e9 a0 f8 ff ff       	jmp    8010603e <alltraps>

8010679e <vector79>:
.globl vector79
vector79:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $79
801067a0:	6a 4f                	push   $0x4f
  jmp alltraps
801067a2:	e9 97 f8 ff ff       	jmp    8010603e <alltraps>

801067a7 <vector80>:
.globl vector80
vector80:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $80
801067a9:	6a 50                	push   $0x50
  jmp alltraps
801067ab:	e9 8e f8 ff ff       	jmp    8010603e <alltraps>

801067b0 <vector81>:
.globl vector81
vector81:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $81
801067b2:	6a 51                	push   $0x51
  jmp alltraps
801067b4:	e9 85 f8 ff ff       	jmp    8010603e <alltraps>

801067b9 <vector82>:
.globl vector82
vector82:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $82
801067bb:	6a 52                	push   $0x52
  jmp alltraps
801067bd:	e9 7c f8 ff ff       	jmp    8010603e <alltraps>

801067c2 <vector83>:
.globl vector83
vector83:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $83
801067c4:	6a 53                	push   $0x53
  jmp alltraps
801067c6:	e9 73 f8 ff ff       	jmp    8010603e <alltraps>

801067cb <vector84>:
.globl vector84
vector84:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $84
801067cd:	6a 54                	push   $0x54
  jmp alltraps
801067cf:	e9 6a f8 ff ff       	jmp    8010603e <alltraps>

801067d4 <vector85>:
.globl vector85
vector85:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $85
801067d6:	6a 55                	push   $0x55
  jmp alltraps
801067d8:	e9 61 f8 ff ff       	jmp    8010603e <alltraps>

801067dd <vector86>:
.globl vector86
vector86:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $86
801067df:	6a 56                	push   $0x56
  jmp alltraps
801067e1:	e9 58 f8 ff ff       	jmp    8010603e <alltraps>

801067e6 <vector87>:
.globl vector87
vector87:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $87
801067e8:	6a 57                	push   $0x57
  jmp alltraps
801067ea:	e9 4f f8 ff ff       	jmp    8010603e <alltraps>

801067ef <vector88>:
.globl vector88
vector88:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $88
801067f1:	6a 58                	push   $0x58
  jmp alltraps
801067f3:	e9 46 f8 ff ff       	jmp    8010603e <alltraps>

801067f8 <vector89>:
.globl vector89
vector89:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $89
801067fa:	6a 59                	push   $0x59
  jmp alltraps
801067fc:	e9 3d f8 ff ff       	jmp    8010603e <alltraps>

80106801 <vector90>:
.globl vector90
vector90:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $90
80106803:	6a 5a                	push   $0x5a
  jmp alltraps
80106805:	e9 34 f8 ff ff       	jmp    8010603e <alltraps>

8010680a <vector91>:
.globl vector91
vector91:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $91
8010680c:	6a 5b                	push   $0x5b
  jmp alltraps
8010680e:	e9 2b f8 ff ff       	jmp    8010603e <alltraps>

80106813 <vector92>:
.globl vector92
vector92:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $92
80106815:	6a 5c                	push   $0x5c
  jmp alltraps
80106817:	e9 22 f8 ff ff       	jmp    8010603e <alltraps>

8010681c <vector93>:
.globl vector93
vector93:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $93
8010681e:	6a 5d                	push   $0x5d
  jmp alltraps
80106820:	e9 19 f8 ff ff       	jmp    8010603e <alltraps>

80106825 <vector94>:
.globl vector94
vector94:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $94
80106827:	6a 5e                	push   $0x5e
  jmp alltraps
80106829:	e9 10 f8 ff ff       	jmp    8010603e <alltraps>

8010682e <vector95>:
.globl vector95
vector95:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $95
80106830:	6a 5f                	push   $0x5f
  jmp alltraps
80106832:	e9 07 f8 ff ff       	jmp    8010603e <alltraps>

80106837 <vector96>:
.globl vector96
vector96:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $96
80106839:	6a 60                	push   $0x60
  jmp alltraps
8010683b:	e9 fe f7 ff ff       	jmp    8010603e <alltraps>

80106840 <vector97>:
.globl vector97
vector97:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $97
80106842:	6a 61                	push   $0x61
  jmp alltraps
80106844:	e9 f5 f7 ff ff       	jmp    8010603e <alltraps>

80106849 <vector98>:
.globl vector98
vector98:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $98
8010684b:	6a 62                	push   $0x62
  jmp alltraps
8010684d:	e9 ec f7 ff ff       	jmp    8010603e <alltraps>

80106852 <vector99>:
.globl vector99
vector99:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $99
80106854:	6a 63                	push   $0x63
  jmp alltraps
80106856:	e9 e3 f7 ff ff       	jmp    8010603e <alltraps>

8010685b <vector100>:
.globl vector100
vector100:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $100
8010685d:	6a 64                	push   $0x64
  jmp alltraps
8010685f:	e9 da f7 ff ff       	jmp    8010603e <alltraps>

80106864 <vector101>:
.globl vector101
vector101:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $101
80106866:	6a 65                	push   $0x65
  jmp alltraps
80106868:	e9 d1 f7 ff ff       	jmp    8010603e <alltraps>

8010686d <vector102>:
.globl vector102
vector102:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $102
8010686f:	6a 66                	push   $0x66
  jmp alltraps
80106871:	e9 c8 f7 ff ff       	jmp    8010603e <alltraps>

80106876 <vector103>:
.globl vector103
vector103:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $103
80106878:	6a 67                	push   $0x67
  jmp alltraps
8010687a:	e9 bf f7 ff ff       	jmp    8010603e <alltraps>

8010687f <vector104>:
.globl vector104
vector104:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $104
80106881:	6a 68                	push   $0x68
  jmp alltraps
80106883:	e9 b6 f7 ff ff       	jmp    8010603e <alltraps>

80106888 <vector105>:
.globl vector105
vector105:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $105
8010688a:	6a 69                	push   $0x69
  jmp alltraps
8010688c:	e9 ad f7 ff ff       	jmp    8010603e <alltraps>

80106891 <vector106>:
.globl vector106
vector106:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $106
80106893:	6a 6a                	push   $0x6a
  jmp alltraps
80106895:	e9 a4 f7 ff ff       	jmp    8010603e <alltraps>

8010689a <vector107>:
.globl vector107
vector107:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $107
8010689c:	6a 6b                	push   $0x6b
  jmp alltraps
8010689e:	e9 9b f7 ff ff       	jmp    8010603e <alltraps>

801068a3 <vector108>:
.globl vector108
vector108:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $108
801068a5:	6a 6c                	push   $0x6c
  jmp alltraps
801068a7:	e9 92 f7 ff ff       	jmp    8010603e <alltraps>

801068ac <vector109>:
.globl vector109
vector109:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $109
801068ae:	6a 6d                	push   $0x6d
  jmp alltraps
801068b0:	e9 89 f7 ff ff       	jmp    8010603e <alltraps>

801068b5 <vector110>:
.globl vector110
vector110:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $110
801068b7:	6a 6e                	push   $0x6e
  jmp alltraps
801068b9:	e9 80 f7 ff ff       	jmp    8010603e <alltraps>

801068be <vector111>:
.globl vector111
vector111:
  pushl $0
801068be:	6a 00                	push   $0x0
  pushl $111
801068c0:	6a 6f                	push   $0x6f
  jmp alltraps
801068c2:	e9 77 f7 ff ff       	jmp    8010603e <alltraps>

801068c7 <vector112>:
.globl vector112
vector112:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $112
801068c9:	6a 70                	push   $0x70
  jmp alltraps
801068cb:	e9 6e f7 ff ff       	jmp    8010603e <alltraps>

801068d0 <vector113>:
.globl vector113
vector113:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $113
801068d2:	6a 71                	push   $0x71
  jmp alltraps
801068d4:	e9 65 f7 ff ff       	jmp    8010603e <alltraps>

801068d9 <vector114>:
.globl vector114
vector114:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $114
801068db:	6a 72                	push   $0x72
  jmp alltraps
801068dd:	e9 5c f7 ff ff       	jmp    8010603e <alltraps>

801068e2 <vector115>:
.globl vector115
vector115:
  pushl $0
801068e2:	6a 00                	push   $0x0
  pushl $115
801068e4:	6a 73                	push   $0x73
  jmp alltraps
801068e6:	e9 53 f7 ff ff       	jmp    8010603e <alltraps>

801068eb <vector116>:
.globl vector116
vector116:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $116
801068ed:	6a 74                	push   $0x74
  jmp alltraps
801068ef:	e9 4a f7 ff ff       	jmp    8010603e <alltraps>

801068f4 <vector117>:
.globl vector117
vector117:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $117
801068f6:	6a 75                	push   $0x75
  jmp alltraps
801068f8:	e9 41 f7 ff ff       	jmp    8010603e <alltraps>

801068fd <vector118>:
.globl vector118
vector118:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $118
801068ff:	6a 76                	push   $0x76
  jmp alltraps
80106901:	e9 38 f7 ff ff       	jmp    8010603e <alltraps>

80106906 <vector119>:
.globl vector119
vector119:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $119
80106908:	6a 77                	push   $0x77
  jmp alltraps
8010690a:	e9 2f f7 ff ff       	jmp    8010603e <alltraps>

8010690f <vector120>:
.globl vector120
vector120:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $120
80106911:	6a 78                	push   $0x78
  jmp alltraps
80106913:	e9 26 f7 ff ff       	jmp    8010603e <alltraps>

80106918 <vector121>:
.globl vector121
vector121:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $121
8010691a:	6a 79                	push   $0x79
  jmp alltraps
8010691c:	e9 1d f7 ff ff       	jmp    8010603e <alltraps>

80106921 <vector122>:
.globl vector122
vector122:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $122
80106923:	6a 7a                	push   $0x7a
  jmp alltraps
80106925:	e9 14 f7 ff ff       	jmp    8010603e <alltraps>

8010692a <vector123>:
.globl vector123
vector123:
  pushl $0
8010692a:	6a 00                	push   $0x0
  pushl $123
8010692c:	6a 7b                	push   $0x7b
  jmp alltraps
8010692e:	e9 0b f7 ff ff       	jmp    8010603e <alltraps>

80106933 <vector124>:
.globl vector124
vector124:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $124
80106935:	6a 7c                	push   $0x7c
  jmp alltraps
80106937:	e9 02 f7 ff ff       	jmp    8010603e <alltraps>

8010693c <vector125>:
.globl vector125
vector125:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $125
8010693e:	6a 7d                	push   $0x7d
  jmp alltraps
80106940:	e9 f9 f6 ff ff       	jmp    8010603e <alltraps>

80106945 <vector126>:
.globl vector126
vector126:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $126
80106947:	6a 7e                	push   $0x7e
  jmp alltraps
80106949:	e9 f0 f6 ff ff       	jmp    8010603e <alltraps>

8010694e <vector127>:
.globl vector127
vector127:
  pushl $0
8010694e:	6a 00                	push   $0x0
  pushl $127
80106950:	6a 7f                	push   $0x7f
  jmp alltraps
80106952:	e9 e7 f6 ff ff       	jmp    8010603e <alltraps>

80106957 <vector128>:
.globl vector128
vector128:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $128
80106959:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010695e:	e9 db f6 ff ff       	jmp    8010603e <alltraps>

80106963 <vector129>:
.globl vector129
vector129:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $129
80106965:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010696a:	e9 cf f6 ff ff       	jmp    8010603e <alltraps>

8010696f <vector130>:
.globl vector130
vector130:
  pushl $0
8010696f:	6a 00                	push   $0x0
  pushl $130
80106971:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106976:	e9 c3 f6 ff ff       	jmp    8010603e <alltraps>

8010697b <vector131>:
.globl vector131
vector131:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $131
8010697d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106982:	e9 b7 f6 ff ff       	jmp    8010603e <alltraps>

80106987 <vector132>:
.globl vector132
vector132:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $132
80106989:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010698e:	e9 ab f6 ff ff       	jmp    8010603e <alltraps>

80106993 <vector133>:
.globl vector133
vector133:
  pushl $0
80106993:	6a 00                	push   $0x0
  pushl $133
80106995:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010699a:	e9 9f f6 ff ff       	jmp    8010603e <alltraps>

8010699f <vector134>:
.globl vector134
vector134:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $134
801069a1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801069a6:	e9 93 f6 ff ff       	jmp    8010603e <alltraps>

801069ab <vector135>:
.globl vector135
vector135:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $135
801069ad:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801069b2:	e9 87 f6 ff ff       	jmp    8010603e <alltraps>

801069b7 <vector136>:
.globl vector136
vector136:
  pushl $0
801069b7:	6a 00                	push   $0x0
  pushl $136
801069b9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801069be:	e9 7b f6 ff ff       	jmp    8010603e <alltraps>

801069c3 <vector137>:
.globl vector137
vector137:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $137
801069c5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801069ca:	e9 6f f6 ff ff       	jmp    8010603e <alltraps>

801069cf <vector138>:
.globl vector138
vector138:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $138
801069d1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801069d6:	e9 63 f6 ff ff       	jmp    8010603e <alltraps>

801069db <vector139>:
.globl vector139
vector139:
  pushl $0
801069db:	6a 00                	push   $0x0
  pushl $139
801069dd:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801069e2:	e9 57 f6 ff ff       	jmp    8010603e <alltraps>

801069e7 <vector140>:
.globl vector140
vector140:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $140
801069e9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801069ee:	e9 4b f6 ff ff       	jmp    8010603e <alltraps>

801069f3 <vector141>:
.globl vector141
vector141:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $141
801069f5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801069fa:	e9 3f f6 ff ff       	jmp    8010603e <alltraps>

801069ff <vector142>:
.globl vector142
vector142:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $142
80106a01:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106a06:	e9 33 f6 ff ff       	jmp    8010603e <alltraps>

80106a0b <vector143>:
.globl vector143
vector143:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $143
80106a0d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106a12:	e9 27 f6 ff ff       	jmp    8010603e <alltraps>

80106a17 <vector144>:
.globl vector144
vector144:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $144
80106a19:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106a1e:	e9 1b f6 ff ff       	jmp    8010603e <alltraps>

80106a23 <vector145>:
.globl vector145
vector145:
  pushl $0
80106a23:	6a 00                	push   $0x0
  pushl $145
80106a25:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106a2a:	e9 0f f6 ff ff       	jmp    8010603e <alltraps>

80106a2f <vector146>:
.globl vector146
vector146:
  pushl $0
80106a2f:	6a 00                	push   $0x0
  pushl $146
80106a31:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106a36:	e9 03 f6 ff ff       	jmp    8010603e <alltraps>

80106a3b <vector147>:
.globl vector147
vector147:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $147
80106a3d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106a42:	e9 f7 f5 ff ff       	jmp    8010603e <alltraps>

80106a47 <vector148>:
.globl vector148
vector148:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $148
80106a49:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106a4e:	e9 eb f5 ff ff       	jmp    8010603e <alltraps>

80106a53 <vector149>:
.globl vector149
vector149:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $149
80106a55:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106a5a:	e9 df f5 ff ff       	jmp    8010603e <alltraps>

80106a5f <vector150>:
.globl vector150
vector150:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $150
80106a61:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106a66:	e9 d3 f5 ff ff       	jmp    8010603e <alltraps>

80106a6b <vector151>:
.globl vector151
vector151:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $151
80106a6d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a72:	e9 c7 f5 ff ff       	jmp    8010603e <alltraps>

80106a77 <vector152>:
.globl vector152
vector152:
  pushl $0
80106a77:	6a 00                	push   $0x0
  pushl $152
80106a79:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a7e:	e9 bb f5 ff ff       	jmp    8010603e <alltraps>

80106a83 <vector153>:
.globl vector153
vector153:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $153
80106a85:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a8a:	e9 af f5 ff ff       	jmp    8010603e <alltraps>

80106a8f <vector154>:
.globl vector154
vector154:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $154
80106a91:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106a96:	e9 a3 f5 ff ff       	jmp    8010603e <alltraps>

80106a9b <vector155>:
.globl vector155
vector155:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $155
80106a9d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106aa2:	e9 97 f5 ff ff       	jmp    8010603e <alltraps>

80106aa7 <vector156>:
.globl vector156
vector156:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $156
80106aa9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106aae:	e9 8b f5 ff ff       	jmp    8010603e <alltraps>

80106ab3 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $157
80106ab5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106aba:	e9 7f f5 ff ff       	jmp    8010603e <alltraps>

80106abf <vector158>:
.globl vector158
vector158:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $158
80106ac1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106ac6:	e9 73 f5 ff ff       	jmp    8010603e <alltraps>

80106acb <vector159>:
.globl vector159
vector159:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $159
80106acd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ad2:	e9 67 f5 ff ff       	jmp    8010603e <alltraps>

80106ad7 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $160
80106ad9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ade:	e9 5b f5 ff ff       	jmp    8010603e <alltraps>

80106ae3 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $161
80106ae5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106aea:	e9 4f f5 ff ff       	jmp    8010603e <alltraps>

80106aef <vector162>:
.globl vector162
vector162:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $162
80106af1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106af6:	e9 43 f5 ff ff       	jmp    8010603e <alltraps>

80106afb <vector163>:
.globl vector163
vector163:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $163
80106afd:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106b02:	e9 37 f5 ff ff       	jmp    8010603e <alltraps>

80106b07 <vector164>:
.globl vector164
vector164:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $164
80106b09:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106b0e:	e9 2b f5 ff ff       	jmp    8010603e <alltraps>

80106b13 <vector165>:
.globl vector165
vector165:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $165
80106b15:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106b1a:	e9 1f f5 ff ff       	jmp    8010603e <alltraps>

80106b1f <vector166>:
.globl vector166
vector166:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $166
80106b21:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106b26:	e9 13 f5 ff ff       	jmp    8010603e <alltraps>

80106b2b <vector167>:
.globl vector167
vector167:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $167
80106b2d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106b32:	e9 07 f5 ff ff       	jmp    8010603e <alltraps>

80106b37 <vector168>:
.globl vector168
vector168:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $168
80106b39:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106b3e:	e9 fb f4 ff ff       	jmp    8010603e <alltraps>

80106b43 <vector169>:
.globl vector169
vector169:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $169
80106b45:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106b4a:	e9 ef f4 ff ff       	jmp    8010603e <alltraps>

80106b4f <vector170>:
.globl vector170
vector170:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $170
80106b51:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106b56:	e9 e3 f4 ff ff       	jmp    8010603e <alltraps>

80106b5b <vector171>:
.globl vector171
vector171:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $171
80106b5d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106b62:	e9 d7 f4 ff ff       	jmp    8010603e <alltraps>

80106b67 <vector172>:
.globl vector172
vector172:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $172
80106b69:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b6e:	e9 cb f4 ff ff       	jmp    8010603e <alltraps>

80106b73 <vector173>:
.globl vector173
vector173:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $173
80106b75:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b7a:	e9 bf f4 ff ff       	jmp    8010603e <alltraps>

80106b7f <vector174>:
.globl vector174
vector174:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $174
80106b81:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b86:	e9 b3 f4 ff ff       	jmp    8010603e <alltraps>

80106b8b <vector175>:
.globl vector175
vector175:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $175
80106b8d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106b92:	e9 a7 f4 ff ff       	jmp    8010603e <alltraps>

80106b97 <vector176>:
.globl vector176
vector176:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $176
80106b99:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106b9e:	e9 9b f4 ff ff       	jmp    8010603e <alltraps>

80106ba3 <vector177>:
.globl vector177
vector177:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $177
80106ba5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106baa:	e9 8f f4 ff ff       	jmp    8010603e <alltraps>

80106baf <vector178>:
.globl vector178
vector178:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $178
80106bb1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106bb6:	e9 83 f4 ff ff       	jmp    8010603e <alltraps>

80106bbb <vector179>:
.globl vector179
vector179:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $179
80106bbd:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106bc2:	e9 77 f4 ff ff       	jmp    8010603e <alltraps>

80106bc7 <vector180>:
.globl vector180
vector180:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $180
80106bc9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106bce:	e9 6b f4 ff ff       	jmp    8010603e <alltraps>

80106bd3 <vector181>:
.globl vector181
vector181:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $181
80106bd5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106bda:	e9 5f f4 ff ff       	jmp    8010603e <alltraps>

80106bdf <vector182>:
.globl vector182
vector182:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $182
80106be1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106be6:	e9 53 f4 ff ff       	jmp    8010603e <alltraps>

80106beb <vector183>:
.globl vector183
vector183:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $183
80106bed:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106bf2:	e9 47 f4 ff ff       	jmp    8010603e <alltraps>

80106bf7 <vector184>:
.globl vector184
vector184:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $184
80106bf9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106bfe:	e9 3b f4 ff ff       	jmp    8010603e <alltraps>

80106c03 <vector185>:
.globl vector185
vector185:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $185
80106c05:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106c0a:	e9 2f f4 ff ff       	jmp    8010603e <alltraps>

80106c0f <vector186>:
.globl vector186
vector186:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $186
80106c11:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106c16:	e9 23 f4 ff ff       	jmp    8010603e <alltraps>

80106c1b <vector187>:
.globl vector187
vector187:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $187
80106c1d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106c22:	e9 17 f4 ff ff       	jmp    8010603e <alltraps>

80106c27 <vector188>:
.globl vector188
vector188:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $188
80106c29:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106c2e:	e9 0b f4 ff ff       	jmp    8010603e <alltraps>

80106c33 <vector189>:
.globl vector189
vector189:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $189
80106c35:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106c3a:	e9 ff f3 ff ff       	jmp    8010603e <alltraps>

80106c3f <vector190>:
.globl vector190
vector190:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $190
80106c41:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106c46:	e9 f3 f3 ff ff       	jmp    8010603e <alltraps>

80106c4b <vector191>:
.globl vector191
vector191:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $191
80106c4d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106c52:	e9 e7 f3 ff ff       	jmp    8010603e <alltraps>

80106c57 <vector192>:
.globl vector192
vector192:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $192
80106c59:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106c5e:	e9 db f3 ff ff       	jmp    8010603e <alltraps>

80106c63 <vector193>:
.globl vector193
vector193:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $193
80106c65:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106c6a:	e9 cf f3 ff ff       	jmp    8010603e <alltraps>

80106c6f <vector194>:
.globl vector194
vector194:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $194
80106c71:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c76:	e9 c3 f3 ff ff       	jmp    8010603e <alltraps>

80106c7b <vector195>:
.globl vector195
vector195:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $195
80106c7d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c82:	e9 b7 f3 ff ff       	jmp    8010603e <alltraps>

80106c87 <vector196>:
.globl vector196
vector196:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $196
80106c89:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106c8e:	e9 ab f3 ff ff       	jmp    8010603e <alltraps>

80106c93 <vector197>:
.globl vector197
vector197:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $197
80106c95:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106c9a:	e9 9f f3 ff ff       	jmp    8010603e <alltraps>

80106c9f <vector198>:
.globl vector198
vector198:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $198
80106ca1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106ca6:	e9 93 f3 ff ff       	jmp    8010603e <alltraps>

80106cab <vector199>:
.globl vector199
vector199:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $199
80106cad:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106cb2:	e9 87 f3 ff ff       	jmp    8010603e <alltraps>

80106cb7 <vector200>:
.globl vector200
vector200:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $200
80106cb9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106cbe:	e9 7b f3 ff ff       	jmp    8010603e <alltraps>

80106cc3 <vector201>:
.globl vector201
vector201:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $201
80106cc5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106cca:	e9 6f f3 ff ff       	jmp    8010603e <alltraps>

80106ccf <vector202>:
.globl vector202
vector202:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $202
80106cd1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106cd6:	e9 63 f3 ff ff       	jmp    8010603e <alltraps>

80106cdb <vector203>:
.globl vector203
vector203:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $203
80106cdd:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106ce2:	e9 57 f3 ff ff       	jmp    8010603e <alltraps>

80106ce7 <vector204>:
.globl vector204
vector204:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $204
80106ce9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106cee:	e9 4b f3 ff ff       	jmp    8010603e <alltraps>

80106cf3 <vector205>:
.globl vector205
vector205:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $205
80106cf5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106cfa:	e9 3f f3 ff ff       	jmp    8010603e <alltraps>

80106cff <vector206>:
.globl vector206
vector206:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $206
80106d01:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106d06:	e9 33 f3 ff ff       	jmp    8010603e <alltraps>

80106d0b <vector207>:
.globl vector207
vector207:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $207
80106d0d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106d12:	e9 27 f3 ff ff       	jmp    8010603e <alltraps>

80106d17 <vector208>:
.globl vector208
vector208:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $208
80106d19:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106d1e:	e9 1b f3 ff ff       	jmp    8010603e <alltraps>

80106d23 <vector209>:
.globl vector209
vector209:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $209
80106d25:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106d2a:	e9 0f f3 ff ff       	jmp    8010603e <alltraps>

80106d2f <vector210>:
.globl vector210
vector210:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $210
80106d31:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106d36:	e9 03 f3 ff ff       	jmp    8010603e <alltraps>

80106d3b <vector211>:
.globl vector211
vector211:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $211
80106d3d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106d42:	e9 f7 f2 ff ff       	jmp    8010603e <alltraps>

80106d47 <vector212>:
.globl vector212
vector212:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $212
80106d49:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106d4e:	e9 eb f2 ff ff       	jmp    8010603e <alltraps>

80106d53 <vector213>:
.globl vector213
vector213:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $213
80106d55:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106d5a:	e9 df f2 ff ff       	jmp    8010603e <alltraps>

80106d5f <vector214>:
.globl vector214
vector214:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $214
80106d61:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106d66:	e9 d3 f2 ff ff       	jmp    8010603e <alltraps>

80106d6b <vector215>:
.globl vector215
vector215:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $215
80106d6d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d72:	e9 c7 f2 ff ff       	jmp    8010603e <alltraps>

80106d77 <vector216>:
.globl vector216
vector216:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $216
80106d79:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d7e:	e9 bb f2 ff ff       	jmp    8010603e <alltraps>

80106d83 <vector217>:
.globl vector217
vector217:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $217
80106d85:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d8a:	e9 af f2 ff ff       	jmp    8010603e <alltraps>

80106d8f <vector218>:
.globl vector218
vector218:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $218
80106d91:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106d96:	e9 a3 f2 ff ff       	jmp    8010603e <alltraps>

80106d9b <vector219>:
.globl vector219
vector219:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $219
80106d9d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106da2:	e9 97 f2 ff ff       	jmp    8010603e <alltraps>

80106da7 <vector220>:
.globl vector220
vector220:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $220
80106da9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106dae:	e9 8b f2 ff ff       	jmp    8010603e <alltraps>

80106db3 <vector221>:
.globl vector221
vector221:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $221
80106db5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106dba:	e9 7f f2 ff ff       	jmp    8010603e <alltraps>

80106dbf <vector222>:
.globl vector222
vector222:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $222
80106dc1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106dc6:	e9 73 f2 ff ff       	jmp    8010603e <alltraps>

80106dcb <vector223>:
.globl vector223
vector223:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $223
80106dcd:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106dd2:	e9 67 f2 ff ff       	jmp    8010603e <alltraps>

80106dd7 <vector224>:
.globl vector224
vector224:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $224
80106dd9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106dde:	e9 5b f2 ff ff       	jmp    8010603e <alltraps>

80106de3 <vector225>:
.globl vector225
vector225:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $225
80106de5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106dea:	e9 4f f2 ff ff       	jmp    8010603e <alltraps>

80106def <vector226>:
.globl vector226
vector226:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $226
80106df1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106df6:	e9 43 f2 ff ff       	jmp    8010603e <alltraps>

80106dfb <vector227>:
.globl vector227
vector227:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $227
80106dfd:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106e02:	e9 37 f2 ff ff       	jmp    8010603e <alltraps>

80106e07 <vector228>:
.globl vector228
vector228:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $228
80106e09:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106e0e:	e9 2b f2 ff ff       	jmp    8010603e <alltraps>

80106e13 <vector229>:
.globl vector229
vector229:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $229
80106e15:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106e1a:	e9 1f f2 ff ff       	jmp    8010603e <alltraps>

80106e1f <vector230>:
.globl vector230
vector230:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $230
80106e21:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106e26:	e9 13 f2 ff ff       	jmp    8010603e <alltraps>

80106e2b <vector231>:
.globl vector231
vector231:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $231
80106e2d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106e32:	e9 07 f2 ff ff       	jmp    8010603e <alltraps>

80106e37 <vector232>:
.globl vector232
vector232:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $232
80106e39:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106e3e:	e9 fb f1 ff ff       	jmp    8010603e <alltraps>

80106e43 <vector233>:
.globl vector233
vector233:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $233
80106e45:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106e4a:	e9 ef f1 ff ff       	jmp    8010603e <alltraps>

80106e4f <vector234>:
.globl vector234
vector234:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $234
80106e51:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106e56:	e9 e3 f1 ff ff       	jmp    8010603e <alltraps>

80106e5b <vector235>:
.globl vector235
vector235:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $235
80106e5d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106e62:	e9 d7 f1 ff ff       	jmp    8010603e <alltraps>

80106e67 <vector236>:
.globl vector236
vector236:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $236
80106e69:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e6e:	e9 cb f1 ff ff       	jmp    8010603e <alltraps>

80106e73 <vector237>:
.globl vector237
vector237:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $237
80106e75:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e7a:	e9 bf f1 ff ff       	jmp    8010603e <alltraps>

80106e7f <vector238>:
.globl vector238
vector238:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $238
80106e81:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e86:	e9 b3 f1 ff ff       	jmp    8010603e <alltraps>

80106e8b <vector239>:
.globl vector239
vector239:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $239
80106e8d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106e92:	e9 a7 f1 ff ff       	jmp    8010603e <alltraps>

80106e97 <vector240>:
.globl vector240
vector240:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $240
80106e99:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106e9e:	e9 9b f1 ff ff       	jmp    8010603e <alltraps>

80106ea3 <vector241>:
.globl vector241
vector241:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $241
80106ea5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106eaa:	e9 8f f1 ff ff       	jmp    8010603e <alltraps>

80106eaf <vector242>:
.globl vector242
vector242:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $242
80106eb1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106eb6:	e9 83 f1 ff ff       	jmp    8010603e <alltraps>

80106ebb <vector243>:
.globl vector243
vector243:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $243
80106ebd:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106ec2:	e9 77 f1 ff ff       	jmp    8010603e <alltraps>

80106ec7 <vector244>:
.globl vector244
vector244:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $244
80106ec9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106ece:	e9 6b f1 ff ff       	jmp    8010603e <alltraps>

80106ed3 <vector245>:
.globl vector245
vector245:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $245
80106ed5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106eda:	e9 5f f1 ff ff       	jmp    8010603e <alltraps>

80106edf <vector246>:
.globl vector246
vector246:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $246
80106ee1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106ee6:	e9 53 f1 ff ff       	jmp    8010603e <alltraps>

80106eeb <vector247>:
.globl vector247
vector247:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $247
80106eed:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106ef2:	e9 47 f1 ff ff       	jmp    8010603e <alltraps>

80106ef7 <vector248>:
.globl vector248
vector248:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $248
80106ef9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106efe:	e9 3b f1 ff ff       	jmp    8010603e <alltraps>

80106f03 <vector249>:
.globl vector249
vector249:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $249
80106f05:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106f0a:	e9 2f f1 ff ff       	jmp    8010603e <alltraps>

80106f0f <vector250>:
.globl vector250
vector250:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $250
80106f11:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106f16:	e9 23 f1 ff ff       	jmp    8010603e <alltraps>

80106f1b <vector251>:
.globl vector251
vector251:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $251
80106f1d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106f22:	e9 17 f1 ff ff       	jmp    8010603e <alltraps>

80106f27 <vector252>:
.globl vector252
vector252:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $252
80106f29:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106f2e:	e9 0b f1 ff ff       	jmp    8010603e <alltraps>

80106f33 <vector253>:
.globl vector253
vector253:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $253
80106f35:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106f3a:	e9 ff f0 ff ff       	jmp    8010603e <alltraps>

80106f3f <vector254>:
.globl vector254
vector254:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $254
80106f41:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106f46:	e9 f3 f0 ff ff       	jmp    8010603e <alltraps>

80106f4b <vector255>:
.globl vector255
vector255:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $255
80106f4d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106f52:	e9 e7 f0 ff ff       	jmp    8010603e <alltraps>
80106f57:	66 90                	xchg   %ax,%ax
80106f59:	66 90                	xchg   %ax,%ax
80106f5b:	66 90                	xchg   %ax,%ax
80106f5d:	66 90                	xchg   %ax,%ax
80106f5f:	90                   	nop

80106f60 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106f60:	55                   	push   %ebp
80106f61:	89 e5                	mov    %esp,%ebp
80106f63:	57                   	push   %edi
80106f64:	56                   	push   %esi
80106f65:	53                   	push   %ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106f66:	89 d3                	mov    %edx,%ebx
{
80106f68:	89 d7                	mov    %edx,%edi
  pde = &pgdir[PDX(va)];
80106f6a:	c1 eb 16             	shr    $0x16,%ebx
80106f6d:	8d 34 98             	lea    (%eax,%ebx,4),%esi
{
80106f70:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80106f73:	8b 06                	mov    (%esi),%eax
80106f75:	a8 01                	test   $0x1,%al
80106f77:	74 27                	je     80106fa0 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106f79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106f7e:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106f84:	c1 ef 0a             	shr    $0xa,%edi
}
80106f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80106f8a:	89 fa                	mov    %edi,%edx
80106f8c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106f92:	8d 04 13             	lea    (%ebx,%edx,1),%eax
}
80106f95:	5b                   	pop    %ebx
80106f96:	5e                   	pop    %esi
80106f97:	5f                   	pop    %edi
80106f98:	5d                   	pop    %ebp
80106f99:	c3                   	ret    
80106f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106fa0:	85 c9                	test   %ecx,%ecx
80106fa2:	74 2c                	je     80106fd0 <walkpgdir+0x70>
80106fa4:	e8 07 b5 ff ff       	call   801024b0 <kalloc>
80106fa9:	85 c0                	test   %eax,%eax
80106fab:	89 c3                	mov    %eax,%ebx
80106fad:	74 21                	je     80106fd0 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
80106faf:	83 ec 04             	sub    $0x4,%esp
80106fb2:	68 00 10 00 00       	push   $0x1000
80106fb7:	6a 00                	push   $0x0
80106fb9:	50                   	push   %eax
80106fba:	e8 31 dd ff ff       	call   80104cf0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106fbf:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106fc5:	83 c4 10             	add    $0x10,%esp
80106fc8:	83 c8 07             	or     $0x7,%eax
80106fcb:	89 06                	mov    %eax,(%esi)
80106fcd:	eb b5                	jmp    80106f84 <walkpgdir+0x24>
80106fcf:	90                   	nop
}
80106fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80106fd3:	31 c0                	xor    %eax,%eax
}
80106fd5:	5b                   	pop    %ebx
80106fd6:	5e                   	pop    %esi
80106fd7:	5f                   	pop    %edi
80106fd8:	5d                   	pop    %ebp
80106fd9:	c3                   	ret    
80106fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106fe0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106fe0:	55                   	push   %ebp
80106fe1:	89 e5                	mov    %esp,%ebp
80106fe3:	57                   	push   %edi
80106fe4:	56                   	push   %esi
80106fe5:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106fe6:	89 d3                	mov    %edx,%ebx
80106fe8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
80106fee:	83 ec 1c             	sub    $0x1c,%esp
80106ff1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106ff4:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80106ff8:	8b 7d 08             	mov    0x8(%ebp),%edi
80106ffb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107000:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
80107003:	8b 45 0c             	mov    0xc(%ebp),%eax
80107006:	29 df                	sub    %ebx,%edi
80107008:	83 c8 01             	or     $0x1,%eax
8010700b:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010700e:	eb 15                	jmp    80107025 <mappages+0x45>
    if(*pte & PTE_P)
80107010:	f6 00 01             	testb  $0x1,(%eax)
80107013:	75 45                	jne    8010705a <mappages+0x7a>
    *pte = pa | perm | PTE_P;
80107015:	0b 75 dc             	or     -0x24(%ebp),%esi
    if(a == last)
80107018:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
    *pte = pa | perm | PTE_P;
8010701b:	89 30                	mov    %esi,(%eax)
    if(a == last)
8010701d:	74 31                	je     80107050 <mappages+0x70>
      break;
    a += PGSIZE;
8010701f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107028:	b9 01 00 00 00       	mov    $0x1,%ecx
8010702d:	89 da                	mov    %ebx,%edx
8010702f:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
80107032:	e8 29 ff ff ff       	call   80106f60 <walkpgdir>
80107037:	85 c0                	test   %eax,%eax
80107039:	75 d5                	jne    80107010 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
8010703b:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
8010703e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107043:	5b                   	pop    %ebx
80107044:	5e                   	pop    %esi
80107045:	5f                   	pop    %edi
80107046:	5d                   	pop    %ebp
80107047:	c3                   	ret    
80107048:	90                   	nop
80107049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107053:	31 c0                	xor    %eax,%eax
}
80107055:	5b                   	pop    %ebx
80107056:	5e                   	pop    %esi
80107057:	5f                   	pop    %edi
80107058:	5d                   	pop    %ebp
80107059:	c3                   	ret    
      panic("remap");
8010705a:	83 ec 0c             	sub    $0xc,%esp
8010705d:	68 7c 83 10 80       	push   $0x8010837c
80107062:	e8 09 93 ff ff       	call   80100370 <panic>
80107067:	89 f6                	mov    %esi,%esi
80107069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107070 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107070:	55                   	push   %ebp
80107071:	89 e5                	mov    %esp,%ebp
80107073:	57                   	push   %edi
80107074:	56                   	push   %esi
80107075:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80107076:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
8010707c:	89 c7                	mov    %eax,%edi
  a = PGROUNDUP(newsz);
8010707e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107084:	83 ec 1c             	sub    $0x1c,%esp
80107087:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010708a:	39 d3                	cmp    %edx,%ebx
8010708c:	73 60                	jae    801070ee <deallocuvm.part.0+0x7e>
8010708e:	89 d6                	mov    %edx,%esi
80107090:	eb 3d                	jmp    801070cf <deallocuvm.part.0+0x5f>
80107092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a += (NPTENTRIES - 1) * PGSIZE;
    else if((*pte & PTE_P) != 0){
80107098:	8b 10                	mov    (%eax),%edx
8010709a:	f6 c2 01             	test   $0x1,%dl
8010709d:	74 26                	je     801070c5 <deallocuvm.part.0+0x55>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010709f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801070a5:	74 52                	je     801070f9 <deallocuvm.part.0+0x89>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
801070a7:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
801070aa:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801070b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
801070b3:	52                   	push   %edx
801070b4:	e8 47 b2 ff ff       	call   80102300 <kfree>
      *pte = 0;
801070b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070bc:	83 c4 10             	add    $0x10,%esp
801070bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801070c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801070cb:	39 f3                	cmp    %esi,%ebx
801070cd:	73 1f                	jae    801070ee <deallocuvm.part.0+0x7e>
    pte = walkpgdir(pgdir, (char*)a, 0);
801070cf:	31 c9                	xor    %ecx,%ecx
801070d1:	89 da                	mov    %ebx,%edx
801070d3:	89 f8                	mov    %edi,%eax
801070d5:	e8 86 fe ff ff       	call   80106f60 <walkpgdir>
    if(!pte)
801070da:	85 c0                	test   %eax,%eax
801070dc:	75 ba                	jne    80107098 <deallocuvm.part.0+0x28>
      a += (NPTENTRIES - 1) * PGSIZE;
801070de:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801070e4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801070ea:	39 f3                	cmp    %esi,%ebx
801070ec:	72 e1                	jb     801070cf <deallocuvm.part.0+0x5f>
    }
  }
  return newsz;
}
801070ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801070f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801070f4:	5b                   	pop    %ebx
801070f5:	5e                   	pop    %esi
801070f6:	5f                   	pop    %edi
801070f7:	5d                   	pop    %ebp
801070f8:	c3                   	ret    
        panic("kfree");
801070f9:	83 ec 0c             	sub    $0xc,%esp
801070fc:	68 ba 7b 10 80       	push   $0x80107bba
80107101:	e8 6a 92 ff ff       	call   80100370 <panic>
80107106:	8d 76 00             	lea    0x0(%esi),%esi
80107109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107110 <seginit>:
{
80107110:	55                   	push   %ebp
80107111:	89 e5                	mov    %esp,%ebp
80107113:	53                   	push   %ebx
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107114:	31 db                	xor    %ebx,%ebx
{
80107116:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpunum()];
80107119:	e8 02 b6 ff ff       	call   80102720 <cpunum>
8010711e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107124:	8d 90 e0 22 11 80    	lea    -0x7feedd20(%eax),%edx
8010712a:	8d 88 94 23 11 80    	lea    -0x7feedc6c(%eax),%ecx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107130:	c7 80 58 23 11 80 ff 	movl   $0xffff,-0x7feedca8(%eax)
80107137:	ff 00 00 
8010713a:	c7 80 5c 23 11 80 00 	movl   $0xcf9a00,-0x7feedca4(%eax)
80107141:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107144:	c7 80 60 23 11 80 ff 	movl   $0xffff,-0x7feedca0(%eax)
8010714b:	ff 00 00 
8010714e:	c7 80 64 23 11 80 00 	movl   $0xcf9200,-0x7feedc9c(%eax)
80107155:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107158:	c7 80 70 23 11 80 ff 	movl   $0xffff,-0x7feedc90(%eax)
8010715f:	ff 00 00 
80107162:	c7 80 74 23 11 80 00 	movl   $0xcffa00,-0x7feedc8c(%eax)
80107169:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010716c:	c7 80 78 23 11 80 ff 	movl   $0xffff,-0x7feedc88(%eax)
80107173:	ff 00 00 
80107176:	c7 80 7c 23 11 80 00 	movl   $0xcff200,-0x7feedc84(%eax)
8010717d:	f2 cf 00 
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107180:	66 89 9a 88 00 00 00 	mov    %bx,0x88(%edx)
80107187:	89 cb                	mov    %ecx,%ebx
80107189:	c1 eb 10             	shr    $0x10,%ebx
8010718c:	66 89 8a 8a 00 00 00 	mov    %cx,0x8a(%edx)
80107193:	c1 e9 18             	shr    $0x18,%ecx
80107196:	88 9a 8c 00 00 00    	mov    %bl,0x8c(%edx)
8010719c:	bb 92 c0 ff ff       	mov    $0xffffc092,%ebx
801071a1:	66 89 98 6d 23 11 80 	mov    %bx,-0x7feedc93(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801071a8:	05 50 23 11 80       	add    $0x80112350,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801071ad:	88 8a 8f 00 00 00    	mov    %cl,0x8f(%edx)
  pd[0] = size-1;
801071b3:	b9 37 00 00 00       	mov    $0x37,%ecx
801071b8:	66 89 4d f2          	mov    %cx,-0xe(%ebp)
  pd[1] = (uint)p;
801071bc:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
801071c0:	c1 e8 10             	shr    $0x10,%eax
801071c3:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801071c7:	8d 45 f2             	lea    -0xe(%ebp),%eax
801071ca:	0f 01 10             	lgdtl  (%eax)
  asm volatile("movw %0, %%gs" : : "r" (v));
801071cd:	b8 18 00 00 00       	mov    $0x18,%eax
801071d2:	8e e8                	mov    %eax,%gs
  proc = 0;
801071d4:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801071db:	00 00 00 00 
  c = &cpus[cpunum()];
801071df:	65 89 15 00 00 00 00 	mov    %edx,%gs:0x0
}
801071e6:	83 c4 14             	add    $0x14,%esp
801071e9:	5b                   	pop    %ebx
801071ea:	5d                   	pop    %ebp
801071eb:	c3                   	ret    
801071ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801071f0 <setupkvm>:
{
801071f0:	55                   	push   %ebp
801071f1:	89 e5                	mov    %esp,%ebp
801071f3:	56                   	push   %esi
801071f4:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801071f5:	e8 b6 b2 ff ff       	call   801024b0 <kalloc>
801071fa:	85 c0                	test   %eax,%eax
801071fc:	74 52                	je     80107250 <setupkvm+0x60>
  memset(pgdir, 0, PGSIZE);
801071fe:	83 ec 04             	sub    $0x4,%esp
80107201:	89 c6                	mov    %eax,%esi
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107203:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80107208:	68 00 10 00 00       	push   $0x1000
8010720d:	6a 00                	push   $0x0
8010720f:	50                   	push   %eax
80107210:	e8 db da ff ff       	call   80104cf0 <memset>
80107215:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0)
80107218:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010721b:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010721e:	83 ec 08             	sub    $0x8,%esp
80107221:	8b 13                	mov    (%ebx),%edx
80107223:	ff 73 0c             	pushl  0xc(%ebx)
80107226:	50                   	push   %eax
80107227:	29 c1                	sub    %eax,%ecx
80107229:	89 f0                	mov    %esi,%eax
8010722b:	e8 b0 fd ff ff       	call   80106fe0 <mappages>
80107230:	83 c4 10             	add    $0x10,%esp
80107233:	85 c0                	test   %eax,%eax
80107235:	78 19                	js     80107250 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107237:	83 c3 10             	add    $0x10,%ebx
8010723a:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107240:	75 d6                	jne    80107218 <setupkvm+0x28>
}
80107242:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107245:	89 f0                	mov    %esi,%eax
80107247:	5b                   	pop    %ebx
80107248:	5e                   	pop    %esi
80107249:	5d                   	pop    %ebp
8010724a:	c3                   	ret    
8010724b:	90                   	nop
8010724c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107250:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
80107253:	31 f6                	xor    %esi,%esi
}
80107255:	89 f0                	mov    %esi,%eax
80107257:	5b                   	pop    %ebx
80107258:	5e                   	pop    %esi
80107259:	5d                   	pop    %ebp
8010725a:	c3                   	ret    
8010725b:	90                   	nop
8010725c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107260 <kvmalloc>:
{
80107260:	55                   	push   %ebp
80107261:	89 e5                	mov    %esp,%ebp
80107263:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107266:	e8 85 ff ff ff       	call   801071f0 <setupkvm>
8010726b:	a3 44 83 11 80       	mov    %eax,0x80118344
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107270:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107275:	0f 22 d8             	mov    %eax,%cr3
}
80107278:	c9                   	leave  
80107279:	c3                   	ret    
8010727a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107280 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107280:	a1 44 83 11 80       	mov    0x80118344,%eax
{
80107285:	55                   	push   %ebp
80107286:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107288:	05 00 00 00 80       	add    $0x80000000,%eax
8010728d:	0f 22 d8             	mov    %eax,%cr3
}
80107290:	5d                   	pop    %ebp
80107291:	c3                   	ret    
80107292:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801072a0 <switchuvm>:
{
801072a0:	55                   	push   %ebp
801072a1:	89 e5                	mov    %esp,%ebp
801072a3:	53                   	push   %ebx
801072a4:	83 ec 04             	sub    $0x4,%esp
801072a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801072aa:	e8 71 d9 ff ff       	call   80104c20 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801072af:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801072b5:	b9 67 00 00 00       	mov    $0x67,%ecx
801072ba:	8d 50 08             	lea    0x8(%eax),%edx
801072bd:	66 89 88 a0 00 00 00 	mov    %cx,0xa0(%eax)
801072c4:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
801072cb:	89 d1                	mov    %edx,%ecx
801072cd:	c1 ea 18             	shr    $0x18,%edx
801072d0:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
801072d6:	ba 89 40 00 00       	mov    $0x4089,%edx
801072db:	c1 e9 10             	shr    $0x10,%ecx
801072de:	66 89 90 a5 00 00 00 	mov    %dx,0xa5(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801072e5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801072ec:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801072f2:	b9 10 00 00 00       	mov    $0x10,%ecx
801072f7:	66 89 48 10          	mov    %cx,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801072fb:	8b 52 08             	mov    0x8(%edx),%edx
801072fe:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107304:	89 50 0c             	mov    %edx,0xc(%eax)
  cpu->ts.iomb = (ushort) 0xFFFF;
80107307:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010730c:	66 89 50 6e          	mov    %dx,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80107310:	b8 30 00 00 00       	mov    $0x30,%eax
80107315:	0f 00 d8             	ltr    %ax
  if(p->pgdir == 0)
80107318:	8b 43 04             	mov    0x4(%ebx),%eax
8010731b:	85 c0                	test   %eax,%eax
8010731d:	74 11                	je     80107330 <switchuvm+0x90>
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010731f:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107324:	0f 22 d8             	mov    %eax,%cr3
}
80107327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010732a:	c9                   	leave  
  popcli();
8010732b:	e9 20 d9 ff ff       	jmp    80104c50 <popcli>
    panic("switchuvm: no pgdir");
80107330:	83 ec 0c             	sub    $0xc,%esp
80107333:	68 82 83 10 80       	push   $0x80108382
80107338:	e8 33 90 ff ff       	call   80100370 <panic>
8010733d:	8d 76 00             	lea    0x0(%esi),%esi

80107340 <inituvm>:
{
80107340:	55                   	push   %ebp
80107341:	89 e5                	mov    %esp,%ebp
80107343:	57                   	push   %edi
80107344:	56                   	push   %esi
80107345:	53                   	push   %ebx
80107346:	83 ec 1c             	sub    $0x1c,%esp
80107349:	8b 75 10             	mov    0x10(%ebp),%esi
8010734c:	8b 45 08             	mov    0x8(%ebp),%eax
8010734f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(sz >= PGSIZE)
80107352:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
{
80107358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
8010735b:	77 49                	ja     801073a6 <inituvm+0x66>
  mem = kalloc();
8010735d:	e8 4e b1 ff ff       	call   801024b0 <kalloc>
  memset(mem, 0, PGSIZE);
80107362:	83 ec 04             	sub    $0x4,%esp
  mem = kalloc();
80107365:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80107367:	68 00 10 00 00       	push   $0x1000
8010736c:	6a 00                	push   $0x0
8010736e:	50                   	push   %eax
8010736f:	e8 7c d9 ff ff       	call   80104cf0 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107374:	58                   	pop    %eax
80107375:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010737b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107380:	5a                   	pop    %edx
80107381:	6a 06                	push   $0x6
80107383:	50                   	push   %eax
80107384:	31 d2                	xor    %edx,%edx
80107386:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107389:	e8 52 fc ff ff       	call   80106fe0 <mappages>
  memmove(mem, init, sz);
8010738e:	89 75 10             	mov    %esi,0x10(%ebp)
80107391:	89 7d 0c             	mov    %edi,0xc(%ebp)
80107394:	83 c4 10             	add    $0x10,%esp
80107397:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010739a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010739d:	5b                   	pop    %ebx
8010739e:	5e                   	pop    %esi
8010739f:	5f                   	pop    %edi
801073a0:	5d                   	pop    %ebp
  memmove(mem, init, sz);
801073a1:	e9 fa d9 ff ff       	jmp    80104da0 <memmove>
    panic("inituvm: more than a page");
801073a6:	83 ec 0c             	sub    $0xc,%esp
801073a9:	68 96 83 10 80       	push   $0x80108396
801073ae:	e8 bd 8f ff ff       	call   80100370 <panic>
801073b3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801073b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801073c0 <loaduvm>:
{
801073c0:	55                   	push   %ebp
801073c1:	89 e5                	mov    %esp,%ebp
801073c3:	57                   	push   %edi
801073c4:	56                   	push   %esi
801073c5:	53                   	push   %ebx
801073c6:	83 ec 0c             	sub    $0xc,%esp
  if((uint) addr % PGSIZE != 0)
801073c9:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
801073d0:	0f 85 91 00 00 00    	jne    80107467 <loaduvm+0xa7>
  for(i = 0; i < sz; i += PGSIZE){
801073d6:	8b 75 18             	mov    0x18(%ebp),%esi
801073d9:	31 db                	xor    %ebx,%ebx
801073db:	85 f6                	test   %esi,%esi
801073dd:	75 1a                	jne    801073f9 <loaduvm+0x39>
801073df:	eb 6f                	jmp    80107450 <loaduvm+0x90>
801073e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801073e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801073ee:	81 ee 00 10 00 00    	sub    $0x1000,%esi
801073f4:	39 5d 18             	cmp    %ebx,0x18(%ebp)
801073f7:	76 57                	jbe    80107450 <loaduvm+0x90>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801073f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801073fc:	8b 45 08             	mov    0x8(%ebp),%eax
801073ff:	31 c9                	xor    %ecx,%ecx
80107401:	01 da                	add    %ebx,%edx
80107403:	e8 58 fb ff ff       	call   80106f60 <walkpgdir>
80107408:	85 c0                	test   %eax,%eax
8010740a:	74 4e                	je     8010745a <loaduvm+0x9a>
    pa = PTE_ADDR(*pte);
8010740c:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010740e:	8b 4d 14             	mov    0x14(%ebp),%ecx
    if(sz - i < PGSIZE)
80107411:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80107416:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010741b:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80107421:	0f 46 fe             	cmovbe %esi,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107424:	01 d9                	add    %ebx,%ecx
80107426:	05 00 00 00 80       	add    $0x80000000,%eax
8010742b:	57                   	push   %edi
8010742c:	51                   	push   %ecx
8010742d:	50                   	push   %eax
8010742e:	ff 75 10             	pushl  0x10(%ebp)
80107431:	e8 fa a4 ff ff       	call   80101930 <readi>
80107436:	83 c4 10             	add    $0x10,%esp
80107439:	39 f8                	cmp    %edi,%eax
8010743b:	74 ab                	je     801073e8 <loaduvm+0x28>
}
8010743d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107440:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107445:	5b                   	pop    %ebx
80107446:	5e                   	pop    %esi
80107447:	5f                   	pop    %edi
80107448:	5d                   	pop    %ebp
80107449:	c3                   	ret    
8010744a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107450:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107453:	31 c0                	xor    %eax,%eax
}
80107455:	5b                   	pop    %ebx
80107456:	5e                   	pop    %esi
80107457:	5f                   	pop    %edi
80107458:	5d                   	pop    %ebp
80107459:	c3                   	ret    
      panic("loaduvm: address should exist");
8010745a:	83 ec 0c             	sub    $0xc,%esp
8010745d:	68 b0 83 10 80       	push   $0x801083b0
80107462:	e8 09 8f ff ff       	call   80100370 <panic>
    panic("loaduvm: addr must be page aligned");
80107467:	83 ec 0c             	sub    $0xc,%esp
8010746a:	68 54 84 10 80       	push   $0x80108454
8010746f:	e8 fc 8e ff ff       	call   80100370 <panic>
80107474:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010747a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107480 <allocuvm>:
{
80107480:	55                   	push   %ebp
80107481:	89 e5                	mov    %esp,%ebp
80107483:	57                   	push   %edi
80107484:	56                   	push   %esi
80107485:	53                   	push   %ebx
80107486:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80107489:	8b 7d 10             	mov    0x10(%ebp),%edi
8010748c:	85 ff                	test   %edi,%edi
8010748e:	0f 88 8e 00 00 00    	js     80107522 <allocuvm+0xa2>
  if(newsz < oldsz)
80107494:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80107497:	0f 82 93 00 00 00    	jb     80107530 <allocuvm+0xb0>
  a = PGROUNDUP(oldsz);
8010749d:	8b 45 0c             	mov    0xc(%ebp),%eax
801074a0:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801074a6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801074ac:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801074af:	0f 86 7e 00 00 00    	jbe    80107533 <allocuvm+0xb3>
801074b5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801074b8:	8b 7d 08             	mov    0x8(%ebp),%edi
801074bb:	eb 42                	jmp    801074ff <allocuvm+0x7f>
801074bd:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
801074c0:	83 ec 04             	sub    $0x4,%esp
801074c3:	68 00 10 00 00       	push   $0x1000
801074c8:	6a 00                	push   $0x0
801074ca:	50                   	push   %eax
801074cb:	e8 20 d8 ff ff       	call   80104cf0 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801074d0:	58                   	pop    %eax
801074d1:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801074d7:	b9 00 10 00 00       	mov    $0x1000,%ecx
801074dc:	5a                   	pop    %edx
801074dd:	6a 06                	push   $0x6
801074df:	50                   	push   %eax
801074e0:	89 da                	mov    %ebx,%edx
801074e2:	89 f8                	mov    %edi,%eax
801074e4:	e8 f7 fa ff ff       	call   80106fe0 <mappages>
801074e9:	83 c4 10             	add    $0x10,%esp
801074ec:	85 c0                	test   %eax,%eax
801074ee:	78 50                	js     80107540 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
801074f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801074f6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801074f9:	0f 86 81 00 00 00    	jbe    80107580 <allocuvm+0x100>
    mem = kalloc();
801074ff:	e8 ac af ff ff       	call   801024b0 <kalloc>
    if(mem == 0){
80107504:	85 c0                	test   %eax,%eax
    mem = kalloc();
80107506:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80107508:	75 b6                	jne    801074c0 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
8010750a:	83 ec 0c             	sub    $0xc,%esp
8010750d:	68 ce 83 10 80       	push   $0x801083ce
80107512:	e8 29 91 ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
80107517:	83 c4 10             	add    $0x10,%esp
8010751a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010751d:	39 45 10             	cmp    %eax,0x10(%ebp)
80107520:	77 6e                	ja     80107590 <allocuvm+0x110>
}
80107522:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80107525:	31 ff                	xor    %edi,%edi
}
80107527:	89 f8                	mov    %edi,%eax
80107529:	5b                   	pop    %ebx
8010752a:	5e                   	pop    %esi
8010752b:	5f                   	pop    %edi
8010752c:	5d                   	pop    %ebp
8010752d:	c3                   	ret    
8010752e:	66 90                	xchg   %ax,%ax
    return oldsz;
80107530:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
80107533:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107536:	89 f8                	mov    %edi,%eax
80107538:	5b                   	pop    %ebx
80107539:	5e                   	pop    %esi
8010753a:	5f                   	pop    %edi
8010753b:	5d                   	pop    %ebp
8010753c:	c3                   	ret    
8010753d:	8d 76 00             	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
80107540:	83 ec 0c             	sub    $0xc,%esp
80107543:	68 e6 83 10 80       	push   $0x801083e6
80107548:	e8 f3 90 ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
8010754d:	83 c4 10             	add    $0x10,%esp
80107550:	8b 45 0c             	mov    0xc(%ebp),%eax
80107553:	39 45 10             	cmp    %eax,0x10(%ebp)
80107556:	76 0d                	jbe    80107565 <allocuvm+0xe5>
80107558:	89 c1                	mov    %eax,%ecx
8010755a:	8b 55 10             	mov    0x10(%ebp),%edx
8010755d:	8b 45 08             	mov    0x8(%ebp),%eax
80107560:	e8 0b fb ff ff       	call   80107070 <deallocuvm.part.0>
      kfree(mem);
80107565:	83 ec 0c             	sub    $0xc,%esp
      return 0;
80107568:	31 ff                	xor    %edi,%edi
      kfree(mem);
8010756a:	56                   	push   %esi
8010756b:	e8 90 ad ff ff       	call   80102300 <kfree>
      return 0;
80107570:	83 c4 10             	add    $0x10,%esp
}
80107573:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107576:	89 f8                	mov    %edi,%eax
80107578:	5b                   	pop    %ebx
80107579:	5e                   	pop    %esi
8010757a:	5f                   	pop    %edi
8010757b:	5d                   	pop    %ebp
8010757c:	c3                   	ret    
8010757d:	8d 76 00             	lea    0x0(%esi),%esi
80107580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80107583:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107586:	5b                   	pop    %ebx
80107587:	89 f8                	mov    %edi,%eax
80107589:	5e                   	pop    %esi
8010758a:	5f                   	pop    %edi
8010758b:	5d                   	pop    %ebp
8010758c:	c3                   	ret    
8010758d:	8d 76 00             	lea    0x0(%esi),%esi
80107590:	89 c1                	mov    %eax,%ecx
80107592:	8b 55 10             	mov    0x10(%ebp),%edx
80107595:	8b 45 08             	mov    0x8(%ebp),%eax
      return 0;
80107598:	31 ff                	xor    %edi,%edi
8010759a:	e8 d1 fa ff ff       	call   80107070 <deallocuvm.part.0>
8010759f:	eb 92                	jmp    80107533 <allocuvm+0xb3>
801075a1:	eb 0d                	jmp    801075b0 <myallocuvm>
801075a3:	90                   	nop
801075a4:	90                   	nop
801075a5:	90                   	nop
801075a6:	90                   	nop
801075a7:	90                   	nop
801075a8:	90                   	nop
801075a9:	90                   	nop
801075aa:	90                   	nop
801075ab:	90                   	nop
801075ac:	90                   	nop
801075ad:	90                   	nop
801075ae:	90                   	nop
801075af:	90                   	nop

801075b0 <myallocuvm>:
int myallocuvm(pde_t *pgdir,uint start, uint end){
801075b0:	55                   	push   %ebp
801075b1:	89 e5                	mov    %esp,%ebp
801075b3:	57                   	push   %edi
801075b4:	56                   	push   %esi
801075b5:	53                   	push   %ebx
801075b6:	83 ec 0c             	sub    $0xc,%esp
  a = PGROUNDUP(start);
801075b9:	8b 45 0c             	mov    0xc(%ebp),%eax
int myallocuvm(pde_t *pgdir,uint start, uint end){
801075bc:	8b 75 10             	mov    0x10(%ebp),%esi
  a = PGROUNDUP(start);
801075bf:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801075c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end; a += PGSIZE){
801075cb:	39 f3                	cmp    %esi,%ebx
801075cd:	73 3f                	jae    8010760e <myallocuvm+0x5e>
801075cf:	90                   	nop
    mem = kalloc();
801075d0:	e8 db ae ff ff       	call   801024b0 <kalloc>
    memset(mem, 0 , PGSIZE);
801075d5:	83 ec 04             	sub    $0x4,%esp
    mem = kalloc();
801075d8:	89 c7                	mov    %eax,%edi
    memset(mem, 0 , PGSIZE);
801075da:	68 00 10 00 00       	push   $0x1000
801075df:	6a 00                	push   $0x0
801075e1:	50                   	push   %eax
801075e2:	e8 09 d7 ff ff       	call   80104cf0 <memset>
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
801075e7:	58                   	pop    %eax
801075e8:	5a                   	pop    %edx
801075e9:	8d 97 00 00 00 80    	lea    -0x80000000(%edi),%edx
801075ef:	8b 45 08             	mov    0x8(%ebp),%eax
801075f2:	6a 06                	push   $0x6
801075f4:	b9 00 10 00 00       	mov    $0x1000,%ecx
801075f9:	52                   	push   %edx
801075fa:	89 da                	mov    %ebx,%edx
  for(;a<end; a += PGSIZE){
801075fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
80107602:	e8 d9 f9 ff ff       	call   80106fe0 <mappages>
  for(;a<end; a += PGSIZE){
80107607:	83 c4 10             	add    $0x10,%esp
8010760a:	39 de                	cmp    %ebx,%esi
8010760c:	77 c2                	ja     801075d0 <myallocuvm+0x20>
  return (end - start);
8010760e:	89 f0                	mov    %esi,%eax
80107610:	2b 45 0c             	sub    0xc(%ebp),%eax
}
80107613:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107616:	5b                   	pop    %ebx
80107617:	5e                   	pop    %esi
80107618:	5f                   	pop    %edi
80107619:	5d                   	pop    %ebp
8010761a:	c3                   	ret    
8010761b:	90                   	nop
8010761c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107620 <deallocuvm>:
{
80107620:	55                   	push   %ebp
80107621:	89 e5                	mov    %esp,%ebp
80107623:	8b 55 0c             	mov    0xc(%ebp),%edx
80107626:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107629:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
8010762c:	39 d1                	cmp    %edx,%ecx
8010762e:	73 10                	jae    80107640 <deallocuvm+0x20>
}
80107630:	5d                   	pop    %ebp
80107631:	e9 3a fa ff ff       	jmp    80107070 <deallocuvm.part.0>
80107636:	8d 76 00             	lea    0x0(%esi),%esi
80107639:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80107640:	89 d0                	mov    %edx,%eax
80107642:	5d                   	pop    %ebp
80107643:	c3                   	ret    
80107644:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010764a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107650 <mydeallocuvm>:

int mydeallocuvm(pde_t *pgdir,uint start,uint end){
80107650:	55                   	push   %ebp
80107651:	89 e5                	mov    %esp,%ebp
80107653:	57                   	push   %edi
80107654:	56                   	push   %esi
80107655:	53                   	push   %ebx
80107656:	83 ec 1c             	sub    $0x1c,%esp
  pte_t *pte;
  uint a,pa;
  a=PGROUNDUP(start);
80107659:	8b 45 0c             	mov    0xc(%ebp),%eax
int mydeallocuvm(pde_t *pgdir,uint start,uint end){
8010765c:	8b 75 10             	mov    0x10(%ebp),%esi
8010765f:	8b 7d 08             	mov    0x8(%ebp),%edi
  a=PGROUNDUP(start);
80107662:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107668:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end;a += PGSIZE){
8010766e:	39 f3                	cmp    %esi,%ebx
80107670:	72 3d                	jb     801076af <mydeallocuvm+0x5f>
80107672:	eb 5a                	jmp    801076ce <mydeallocuvm+0x7e>
80107674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir,(char*)a,0);
    if(!pte){
      a += (NPDENTRIES-1)*PGSIZE;
    }else if((*pte & PTE_P)!=0){
80107678:	8b 10                	mov    (%eax),%edx
8010767a:	f6 c2 01             	test   $0x1,%dl
8010767d:	74 26                	je     801076a5 <mydeallocuvm+0x55>
      pa=PTE_ADDR(*pte);
      if(pa == 0){
8010767f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80107685:	74 54                	je     801076db <mydeallocuvm+0x8b>
        panic("kfree");
      }
      char *v = P2V(pa);
      kfree(v);
80107687:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010768a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107690:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80107693:	52                   	push   %edx
80107694:	e8 67 ac ff ff       	call   80102300 <kfree>
      *pte=0;
80107699:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010769c:	83 c4 10             	add    $0x10,%esp
8010769f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(;a<end;a += PGSIZE){
801076a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801076ab:	39 de                	cmp    %ebx,%esi
801076ad:	76 1f                	jbe    801076ce <mydeallocuvm+0x7e>
    pte = walkpgdir(pgdir,(char*)a,0);
801076af:	31 c9                	xor    %ecx,%ecx
801076b1:	89 da                	mov    %ebx,%edx
801076b3:	89 f8                	mov    %edi,%eax
801076b5:	e8 a6 f8 ff ff       	call   80106f60 <walkpgdir>
    if(!pte){
801076ba:	85 c0                	test   %eax,%eax
801076bc:	75 ba                	jne    80107678 <mydeallocuvm+0x28>
      a += (NPDENTRIES-1)*PGSIZE;
801076be:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(;a<end;a += PGSIZE){
801076c4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801076ca:	39 de                	cmp    %ebx,%esi
801076cc:	77 e1                	ja     801076af <mydeallocuvm+0x5f>
    }
  }
  return 1;
}
801076ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
801076d1:	b8 01 00 00 00       	mov    $0x1,%eax
801076d6:	5b                   	pop    %ebx
801076d7:	5e                   	pop    %esi
801076d8:	5f                   	pop    %edi
801076d9:	5d                   	pop    %ebp
801076da:	c3                   	ret    
        panic("kfree");
801076db:	83 ec 0c             	sub    $0xc,%esp
801076de:	68 ba 7b 10 80       	push   $0x80107bba
801076e3:	e8 88 8c ff ff       	call   80100370 <panic>
801076e8:	90                   	nop
801076e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801076f0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801076f0:	55                   	push   %ebp
801076f1:	89 e5                	mov    %esp,%ebp
801076f3:	57                   	push   %edi
801076f4:	56                   	push   %esi
801076f5:	53                   	push   %ebx
801076f6:	83 ec 0c             	sub    $0xc,%esp
801076f9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801076fc:	85 f6                	test   %esi,%esi
801076fe:	74 59                	je     80107759 <freevm+0x69>
80107700:	31 c9                	xor    %ecx,%ecx
80107702:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107707:	89 f0                	mov    %esi,%eax
80107709:	e8 62 f9 ff ff       	call   80107070 <deallocuvm.part.0>
8010770e:	89 f3                	mov    %esi,%ebx
80107710:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107716:	eb 0f                	jmp    80107727 <freevm+0x37>
80107718:	90                   	nop
80107719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107720:	83 c3 04             	add    $0x4,%ebx
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107723:	39 fb                	cmp    %edi,%ebx
80107725:	74 23                	je     8010774a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107727:	8b 03                	mov    (%ebx),%eax
80107729:	a8 01                	test   $0x1,%al
8010772b:	74 f3                	je     80107720 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010772d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107732:	83 ec 0c             	sub    $0xc,%esp
80107735:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107738:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010773d:	50                   	push   %eax
8010773e:	e8 bd ab ff ff       	call   80102300 <kfree>
80107743:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107746:	39 fb                	cmp    %edi,%ebx
80107748:	75 dd                	jne    80107727 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010774a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010774d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107750:	5b                   	pop    %ebx
80107751:	5e                   	pop    %esi
80107752:	5f                   	pop    %edi
80107753:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107754:	e9 a7 ab ff ff       	jmp    80102300 <kfree>
    panic("freevm: no pgdir");
80107759:	83 ec 0c             	sub    $0xc,%esp
8010775c:	68 02 84 10 80       	push   $0x80108402
80107761:	e8 0a 8c ff ff       	call   80100370 <panic>
80107766:	8d 76 00             	lea    0x0(%esi),%esi
80107769:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107770 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107770:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107771:	31 c9                	xor    %ecx,%ecx
{
80107773:	89 e5                	mov    %esp,%ebp
80107775:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80107778:	8b 55 0c             	mov    0xc(%ebp),%edx
8010777b:	8b 45 08             	mov    0x8(%ebp),%eax
8010777e:	e8 dd f7 ff ff       	call   80106f60 <walkpgdir>
  if(pte == 0)
80107783:	85 c0                	test   %eax,%eax
80107785:	74 05                	je     8010778c <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
80107787:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010778a:	c9                   	leave  
8010778b:	c3                   	ret    
    panic("clearpteu");
8010778c:	83 ec 0c             	sub    $0xc,%esp
8010778f:	68 13 84 10 80       	push   $0x80108413
80107794:	e8 d7 8b ff ff       	call   80100370 <panic>
80107799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801077a0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801077a0:	55                   	push   %ebp
801077a1:	89 e5                	mov    %esp,%ebp
801077a3:	57                   	push   %edi
801077a4:	56                   	push   %esi
801077a5:	53                   	push   %ebx
801077a6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801077a9:	e8 42 fa ff ff       	call   801071f0 <setupkvm>
801077ae:	85 c0                	test   %eax,%eax
801077b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801077b3:	0f 84 a0 00 00 00    	je     80107859 <copyuvm+0xb9>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801077b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801077bc:	85 c9                	test   %ecx,%ecx
801077be:	0f 84 95 00 00 00    	je     80107859 <copyuvm+0xb9>
801077c4:	31 f6                	xor    %esi,%esi
801077c6:	eb 4e                	jmp    80107816 <copyuvm+0x76>
801077c8:	90                   	nop
801077c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801077d0:	83 ec 04             	sub    $0x4,%esp
801077d3:	81 c7 00 00 00 80    	add    $0x80000000,%edi
801077d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077dc:	68 00 10 00 00       	push   $0x1000
801077e1:	57                   	push   %edi
801077e2:	50                   	push   %eax
801077e3:	e8 b8 d5 ff ff       	call   80104da0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801077e8:	58                   	pop    %eax
801077e9:	5a                   	pop    %edx
801077ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801077ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
801077f0:	b9 00 10 00 00       	mov    $0x1000,%ecx
801077f5:	53                   	push   %ebx
801077f6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801077fc:	52                   	push   %edx
801077fd:	89 f2                	mov    %esi,%edx
801077ff:	e8 dc f7 ff ff       	call   80106fe0 <mappages>
80107804:	83 c4 10             	add    $0x10,%esp
80107807:	85 c0                	test   %eax,%eax
80107809:	78 39                	js     80107844 <copyuvm+0xa4>
  for(i = 0; i < sz; i += PGSIZE){
8010780b:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107811:	39 75 0c             	cmp    %esi,0xc(%ebp)
80107814:	76 43                	jbe    80107859 <copyuvm+0xb9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107816:	8b 45 08             	mov    0x8(%ebp),%eax
80107819:	31 c9                	xor    %ecx,%ecx
8010781b:	89 f2                	mov    %esi,%edx
8010781d:	e8 3e f7 ff ff       	call   80106f60 <walkpgdir>
80107822:	85 c0                	test   %eax,%eax
80107824:	74 3e                	je     80107864 <copyuvm+0xc4>
    if(!(*pte & PTE_P))
80107826:	8b 18                	mov    (%eax),%ebx
80107828:	f6 c3 01             	test   $0x1,%bl
8010782b:	74 44                	je     80107871 <copyuvm+0xd1>
    pa = PTE_ADDR(*pte);
8010782d:	89 df                	mov    %ebx,%edi
    flags = PTE_FLAGS(*pte);
8010782f:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    pa = PTE_ADDR(*pte);
80107835:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
8010783b:	e8 70 ac ff ff       	call   801024b0 <kalloc>
80107840:	85 c0                	test   %eax,%eax
80107842:	75 8c                	jne    801077d0 <copyuvm+0x30>
      goto bad;
  }
  return d;

bad:
  freevm(d);
80107844:	83 ec 0c             	sub    $0xc,%esp
80107847:	ff 75 e0             	pushl  -0x20(%ebp)
8010784a:	e8 a1 fe ff ff       	call   801076f0 <freevm>
  return 0;
8010784f:	83 c4 10             	add    $0x10,%esp
80107852:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
}
80107859:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010785c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010785f:	5b                   	pop    %ebx
80107860:	5e                   	pop    %esi
80107861:	5f                   	pop    %edi
80107862:	5d                   	pop    %ebp
80107863:	c3                   	ret    
      panic("copyuvm: pte should exist");
80107864:	83 ec 0c             	sub    $0xc,%esp
80107867:	68 1d 84 10 80       	push   $0x8010841d
8010786c:	e8 ff 8a ff ff       	call   80100370 <panic>
      panic("copyuvm: page not present");
80107871:	83 ec 0c             	sub    $0xc,%esp
80107874:	68 37 84 10 80       	push   $0x80108437
80107879:	e8 f2 8a ff ff       	call   80100370 <panic>
8010787e:	66 90                	xchg   %ax,%ax

80107880 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107880:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107881:	31 c9                	xor    %ecx,%ecx
{
80107883:	89 e5                	mov    %esp,%ebp
80107885:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80107888:	8b 55 0c             	mov    0xc(%ebp),%edx
8010788b:	8b 45 08             	mov    0x8(%ebp),%eax
8010788e:	e8 cd f6 ff ff       	call   80106f60 <walkpgdir>
  if((*pte & PTE_P) == 0)
80107893:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107895:	c9                   	leave  
  if((*pte & PTE_U) == 0)
80107896:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107898:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
8010789d:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
801078a0:	05 00 00 00 80       	add    $0x80000000,%eax
801078a5:	83 fa 05             	cmp    $0x5,%edx
801078a8:	ba 00 00 00 00       	mov    $0x0,%edx
801078ad:	0f 45 c2             	cmovne %edx,%eax
}
801078b0:	c3                   	ret    
801078b1:	eb 0d                	jmp    801078c0 <copyout>
801078b3:	90                   	nop
801078b4:	90                   	nop
801078b5:	90                   	nop
801078b6:	90                   	nop
801078b7:	90                   	nop
801078b8:	90                   	nop
801078b9:	90                   	nop
801078ba:	90                   	nop
801078bb:	90                   	nop
801078bc:	90                   	nop
801078bd:	90                   	nop
801078be:	90                   	nop
801078bf:	90                   	nop

801078c0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801078c0:	55                   	push   %ebp
801078c1:	89 e5                	mov    %esp,%ebp
801078c3:	57                   	push   %edi
801078c4:	56                   	push   %esi
801078c5:	53                   	push   %ebx
801078c6:	83 ec 1c             	sub    $0x1c,%esp
801078c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
801078cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801078cf:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801078d2:	85 db                	test   %ebx,%ebx
801078d4:	75 40                	jne    80107916 <copyout+0x56>
801078d6:	eb 70                	jmp    80107948 <copyout+0x88>
801078d8:	90                   	nop
801078d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
801078e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801078e3:	89 f1                	mov    %esi,%ecx
801078e5:	29 d1                	sub    %edx,%ecx
801078e7:	81 c1 00 10 00 00    	add    $0x1000,%ecx
801078ed:	39 d9                	cmp    %ebx,%ecx
801078ef:	0f 47 cb             	cmova  %ebx,%ecx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801078f2:	29 f2                	sub    %esi,%edx
801078f4:	83 ec 04             	sub    $0x4,%esp
801078f7:	01 d0                	add    %edx,%eax
801078f9:	51                   	push   %ecx
801078fa:	57                   	push   %edi
801078fb:	50                   	push   %eax
801078fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801078ff:	e8 9c d4 ff ff       	call   80104da0 <memmove>
    len -= n;
    buf += n;
80107904:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  while(len > 0){
80107907:	83 c4 10             	add    $0x10,%esp
    va = va0 + PGSIZE;
8010790a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
    buf += n;
80107910:	01 cf                	add    %ecx,%edi
  while(len > 0){
80107912:	29 cb                	sub    %ecx,%ebx
80107914:	74 32                	je     80107948 <copyout+0x88>
    va0 = (uint)PGROUNDDOWN(va);
80107916:	89 d6                	mov    %edx,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107918:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
8010791b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010791e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107924:	56                   	push   %esi
80107925:	ff 75 08             	pushl  0x8(%ebp)
80107928:	e8 53 ff ff ff       	call   80107880 <uva2ka>
    if(pa0 == 0)
8010792d:	83 c4 10             	add    $0x10,%esp
80107930:	85 c0                	test   %eax,%eax
80107932:	75 ac                	jne    801078e0 <copyout+0x20>
  }
  return 0;
}
80107934:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107937:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010793c:	5b                   	pop    %ebx
8010793d:	5e                   	pop    %esi
8010793e:	5f                   	pop    %edi
8010793f:	5d                   	pop    %ebp
80107940:	c3                   	ret    
80107941:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107948:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010794b:	31 c0                	xor    %eax,%eax
}
8010794d:	5b                   	pop    %ebx
8010794e:	5e                   	pop    %esi
8010794f:	5f                   	pop    %edi
80107950:	5d                   	pop    %ebp
80107951:	c3                   	ret    
