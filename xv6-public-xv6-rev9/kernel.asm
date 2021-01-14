
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
8010002d:	b8 20 2f 10 80       	mov    $0x80102f20,%eax
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
80100046:	68 80 75 10 80       	push   $0x80107580
8010004b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100050:	e8 8b 46 00 00       	call   801046e0 <initlock>

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
801000d4:	e8 27 46 00 00       	call   80104700 <acquire>
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
80100114:	e8 27 3e 00 00       	call   80103f40 <sleep>
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
80100154:	e8 67 47 00 00       	call   801048c0 <release>
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
80100184:	e8 37 47 00 00       	call   801048c0 <release>
80100189:	83 c4 10             	add    $0x10,%esp
8010018c:	eb ce                	jmp    8010015c <bread+0x9c>
  panic("bget: no buffers");
8010018e:	83 ec 0c             	sub    $0xc,%esp
80100191:	68 87 75 10 80       	push   $0x80107587
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
801001bd:	68 98 75 10 80       	push   $0x80107598
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
801001e7:	e8 14 45 00 00       	call   80104700 <acquire>

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
80100221:	e8 ca 3e 00 00       	call   801040f0 <wakeup>

  release(&bcache.lock);
80100226:	83 c4 10             	add    $0x10,%esp
80100229:	c7 45 08 e0 c5 10 80 	movl   $0x8010c5e0,0x8(%ebp)
}
80100230:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100233:	c9                   	leave  
  release(&bcache.lock);
80100234:	e9 87 46 00 00       	jmp    801048c0 <release>
    panic("brelse");
80100239:	83 ec 0c             	sub    $0xc,%esp
8010023c:	68 9f 75 10 80       	push   $0x8010759f
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
8010026c:	e8 8f 44 00 00       	call   80104700 <acquire>
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
801002a5:	e8 96 3c 00 00       	call   80103f40 <sleep>
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
801002d0:	e8 eb 45 00 00       	call   801048c0 <release>
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
8010032d:	e8 8e 45 00 00       	call   801048c0 <release>
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
80100393:	68 a6 75 10 80       	push   $0x801075a6
80100398:	e8 a3 02 00 00       	call   80100640 <cprintf>
  cprintf(s);
8010039d:	58                   	pop    %eax
8010039e:	ff 75 08             	pushl  0x8(%ebp)
801003a1:	e8 9a 02 00 00       	call   80100640 <cprintf>
  cprintf("\n");
801003a6:	c7 04 24 34 7c 10 80 	movl   $0x80107c34,(%esp)
801003ad:	e8 8e 02 00 00       	call   80100640 <cprintf>
  getcallerpcs(&s, pcs);
801003b2:	5a                   	pop    %edx
801003b3:	8d 45 08             	lea    0x8(%ebp),%eax
801003b6:	59                   	pop    %ecx
801003b7:	53                   	push   %ebx
801003b8:	50                   	push   %eax
801003b9:	e8 02 44 00 00       	call   801047c0 <getcallerpcs>
801003be:	83 c4 10             	add    $0x10,%esp
801003c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf(" %p", pcs[i]);
801003c8:	83 ec 08             	sub    $0x8,%esp
801003cb:	ff 33                	pushl  (%ebx)
801003cd:	83 c3 04             	add    $0x4,%ebx
801003d0:	68 c2 75 10 80       	push   $0x801075c2
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
8010041a:	e8 a1 5c 00 00       	call   801060c0 <uartputc>
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
801004cc:	e8 ef 5b 00 00       	call   801060c0 <uartputc>
801004d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004d8:	e8 e3 5b 00 00       	call   801060c0 <uartputc>
801004dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004e4:	e8 d7 5b 00 00       	call   801060c0 <uartputc>
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
80100504:	e8 b7 44 00 00       	call   801049c0 <memmove>
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
80100521:	e8 ea 43 00 00       	call   80104910 <memset>
80100526:	83 c4 10             	add    $0x10,%esp
80100529:	e9 5d ff ff ff       	jmp    8010048b <consputc+0x9b>
    panic("pos under/overflow");
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	68 c6 75 10 80       	push   $0x801075c6
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
80100591:	0f b6 92 f4 75 10 80 	movzbl -0x7fef8a0c(%edx),%edx
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
801005fb:	e8 00 41 00 00       	call   80104700 <acquire>
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
80100627:	e8 94 42 00 00       	call   801048c0 <release>
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
801006ff:	e8 bc 41 00 00       	call   801048c0 <release>
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
801007b0:	ba d9 75 10 80       	mov    $0x801075d9,%edx
      for(; *s; s++)
801007b5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801007b8:	b8 28 00 00 00       	mov    $0x28,%eax
801007bd:	89 d3                	mov    %edx,%ebx
801007bf:	eb bf                	jmp    80100780 <cprintf+0x140>
801007c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    acquire(&cons.lock);
801007c8:	83 ec 0c             	sub    $0xc,%esp
801007cb:	68 20 b5 10 80       	push   $0x8010b520
801007d0:	e8 2b 3f 00 00       	call   80104700 <acquire>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	e9 7c fe ff ff       	jmp    80100659 <cprintf+0x19>
    panic("null fmt");
801007dd:	83 ec 0c             	sub    $0xc,%esp
801007e0:	68 e0 75 10 80       	push   $0x801075e0
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
80100803:	e8 f8 3e 00 00       	call   80104700 <acquire>
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
80100868:	e8 53 40 00 00       	call   801048c0 <release>
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
801008f6:	e8 f5 37 00 00       	call   801040f0 <wakeup>
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
80100977:	e9 54 38 00 00       	jmp    801041d0 <procdump>
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
801009a6:	68 e9 75 10 80       	push   $0x801075e9
801009ab:	68 20 b5 10 80       	push   $0x8010b520
801009b0:	e8 2b 3d 00 00       	call   801046e0 <initlock>

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
801009da:	e8 11 29 00 00       	call   801032f0 <picenable>
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
80100a6c:	e8 9f 63 00 00       	call   80106e10 <setupkvm>
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
80100ace:	e8 cd 65 00 00       	call   801070a0 <allocuvm>
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
80100b00:	e8 db 64 00 00       	call   80106fe0 <loaduvm>
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
80100b4a:	e8 c1 67 00 00       	call   80107310 <freevm>
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
80100b8b:	e8 10 65 00 00       	call   801070a0 <allocuvm>
80100b90:	83 c4 10             	add    $0x10,%esp
80100b93:	85 c0                	test   %eax,%eax
80100b95:	89 c6                	mov    %eax,%esi
80100b97:	75 2a                	jne    80100bc3 <exec+0x1d3>
    freevm(pgdir);
80100b99:	83 ec 0c             	sub    $0xc,%esp
80100b9c:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100ba2:	e8 69 67 00 00       	call   80107310 <freevm>
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
80100bd7:	e8 b4 67 00 00       	call   80107390 <clearpteu>
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
80100c09:	e8 22 3f 00 00       	call   80104b30 <strlen>
80100c0e:	f7 d0                	not    %eax
80100c10:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c12:	58                   	pop    %eax
80100c13:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100c16:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c19:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c1c:	e8 0f 3f 00 00       	call   80104b30 <strlen>
80100c21:	83 c0 01             	add    $0x1,%eax
80100c24:	50                   	push   %eax
80100c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c28:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c2b:	53                   	push   %ebx
80100c2c:	56                   	push   %esi
80100c2d:	e8 ae 68 00 00       	call   801074e0 <copyout>
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
80100c97:	e8 44 68 00 00       	call   801074e0 <copyout>
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
80100cd5:	e8 16 3e 00 00       	call   80104af0 <safestrcpy>
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
80100d09:	e8 b2 61 00 00       	call   80106ec0 <switchuvm>
  freevm(oldpgdir);
80100d0e:	89 3c 24             	mov    %edi,(%esp)
80100d11:	e8 fa 65 00 00       	call   80107310 <freevm>
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
80100d36:	68 05 76 10 80       	push   $0x80107605
80100d3b:	68 a0 07 11 80       	push   $0x801107a0
80100d40:	e8 9b 39 00 00       	call   801046e0 <initlock>
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
80100d61:	e8 9a 39 00 00       	call   80104700 <acquire>
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
80100d91:	e8 2a 3b 00 00       	call   801048c0 <release>
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
80100daa:	e8 11 3b 00 00       	call   801048c0 <release>
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
80100dcf:	e8 2c 39 00 00       	call   80104700 <acquire>
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
80100dec:	e8 cf 3a 00 00       	call   801048c0 <release>
  return f;
}
80100df1:	89 d8                	mov    %ebx,%eax
80100df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100df6:	c9                   	leave  
80100df7:	c3                   	ret    
    panic("filedup");
80100df8:	83 ec 0c             	sub    $0xc,%esp
80100dfb:	68 0c 76 10 80       	push   $0x8010760c
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
80100e21:	e8 da 38 00 00       	call   80104700 <acquire>
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
80100e4c:	e9 6f 3a 00 00       	jmp    801048c0 <release>
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
80100e78:	e8 43 3a 00 00       	call   801048c0 <release>
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
80100ea1:	e8 2a 26 00 00       	call   801034d0 <pipeclose>
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
80100ed2:	68 14 76 10 80       	push   $0x80107614
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
80100f9d:	e9 fe 26 00 00       	jmp    801036a0 <piperead>
80100fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80100fa8:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100fad:	eb d7                	jmp    80100f86 <fileread+0x56>
  panic("fileread");
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	68 1e 76 10 80       	push   $0x8010761e
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
801010bd:	e9 ae 24 00 00       	jmp    80103570 <pipewrite>
        panic("short filewrite");
801010c2:	83 ec 0c             	sub    $0xc,%esp
801010c5:	68 27 76 10 80       	push   $0x80107627
801010ca:	e8 a1 f2 ff ff       	call   80100370 <panic>
  panic("filewrite");
801010cf:	83 ec 0c             	sub    $0xc,%esp
801010d2:	68 2d 76 10 80       	push   $0x8010762d
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
80101184:	68 37 76 10 80       	push   $0x80107637
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
801011c5:	e8 46 37 00 00       	call   80104910 <memset>
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
8010120a:	e8 f1 34 00 00       	call   80104700 <acquire>
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
80101269:	e8 52 36 00 00       	call   801048c0 <release>

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
80101295:	e8 26 36 00 00       	call   801048c0 <release>
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
801012aa:	68 4d 76 10 80       	push   $0x8010764d
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
80101371:	68 5d 76 10 80       	push   $0x8010765d
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
801013a1:	e8 1a 36 00 00       	call   801049c0 <memmove>
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
80101434:	68 70 76 10 80       	push   $0x80107670
80101439:	e8 32 ef ff ff       	call   80100370 <panic>
8010143e:	66 90                	xchg   %ax,%ax

80101440 <iinit>:
{
80101440:	55                   	push   %ebp
80101441:	89 e5                	mov    %esp,%ebp
80101443:	83 ec 10             	sub    $0x10,%esp
  initlock(&icache.lock, "icache");
80101446:	68 83 76 10 80       	push   $0x80107683
8010144b:	68 c0 11 11 80       	push   $0x801111c0
80101450:	e8 8b 32 00 00       	call   801046e0 <initlock>
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
8010148e:	68 e4 76 10 80       	push   $0x801076e4
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
8010151e:	e8 ed 33 00 00       	call   80104910 <memset>
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
80101553:	68 8a 76 10 80       	push   $0x8010768a
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
801015c1:	e8 fa 33 00 00       	call   801049c0 <memmove>
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
801015ef:	e8 0c 31 00 00       	call   80104700 <acquire>
  ip->ref++;
801015f4:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801015f8:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
801015ff:	e8 bc 32 00 00       	call   801048c0 <release>
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
80101633:	e8 c8 30 00 00       	call   80104700 <acquire>
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
80101651:	e8 ea 28 00 00       	call   80103f40 <sleep>
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
8010166e:	e8 4d 32 00 00       	call   801048c0 <release>
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
801016e0:	e8 db 32 00 00       	call   801049c0 <memmove>
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
801016fe:	68 a2 76 10 80       	push   $0x801076a2
80101703:	e8 68 ec ff ff       	call   80100370 <panic>
    panic("ilock");
80101708:	83 ec 0c             	sub    $0xc,%esp
8010170b:	68 9c 76 10 80       	push   $0x8010769c
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
80101743:	e8 b8 2f 00 00       	call   80104700 <acquire>
  ip->flags &= ~I_BUSY;
80101748:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
8010174c:	89 1c 24             	mov    %ebx,(%esp)
8010174f:	e8 9c 29 00 00       	call   801040f0 <wakeup>
  release(&icache.lock);
80101754:	83 c4 10             	add    $0x10,%esp
80101757:	c7 45 08 c0 11 11 80 	movl   $0x801111c0,0x8(%ebp)
}
8010175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101761:	c9                   	leave  
  release(&icache.lock);
80101762:	e9 59 31 00 00       	jmp    801048c0 <release>
    panic("iunlock");
80101767:	83 ec 0c             	sub    $0xc,%esp
8010176a:	68 b1 76 10 80       	push   $0x801076b1
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
80101791:	e8 6a 2f 00 00       	call   80104700 <acquire>
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
801017d9:	e8 e2 30 00 00       	call   801048c0 <release>
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
80101836:	e8 c5 2e 00 00       	call   80104700 <acquire>
    ip->flags = 0;
8010183b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
80101842:	89 34 24             	mov    %esi,(%esp)
80101845:	e8 a6 28 00 00       	call   801040f0 <wakeup>
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
80101864:	e9 57 30 00 00       	jmp    801048c0 <release>
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
801018cd:	68 b9 76 10 80       	push   $0x801076b9
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
801019d7:	e8 e4 2f 00 00       	call   801049c0 <memmove>
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
80101ad3:	e8 e8 2e 00 00       	call   801049c0 <memmove>
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
80101b6e:	e8 bd 2e 00 00       	call   80104a30 <strncmp>
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
80101bcd:	e8 5e 2e 00 00       	call   80104a30 <strncmp>
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
80101c12:	68 d5 76 10 80       	push   $0x801076d5
80101c17:	e8 54 e7 ff ff       	call   80100370 <panic>
    panic("dirlookup not DIR");
80101c1c:	83 ec 0c             	sub    $0xc,%esp
80101c1f:	68 c3 76 10 80       	push   $0x801076c3
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
80101c5a:	e8 a1 2a 00 00       	call   80104700 <acquire>
  ip->ref++;
80101c5f:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101c63:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
80101c6a:	e8 51 2c 00 00       	call   801048c0 <release>
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
80101cc5:	e8 f6 2c 00 00       	call   801049c0 <memmove>
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
80101d58:	e8 63 2c 00 00       	call   801049c0 <memmove>
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
80101e4d:	e8 3e 2c 00 00       	call   80104a90 <strncpy>
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
80101e8b:	68 d5 76 10 80       	push   $0x801076d5
80101e90:	e8 db e4 ff ff       	call   80100370 <panic>
    panic("dirlink");
80101e95:	83 ec 0c             	sub    $0xc,%esp
80101e98:	68 b2 7d 10 80       	push   $0x80107db2
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
80101fab:	68 49 77 10 80       	push   $0x80107749
80101fb0:	e8 bb e3 ff ff       	call   80100370 <panic>
    panic("idestart");
80101fb5:	83 ec 0c             	sub    $0xc,%esp
80101fb8:	68 40 77 10 80       	push   $0x80107740
80101fbd:	e8 ae e3 ff ff       	call   80100370 <panic>
80101fc2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101fc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101fd0 <ideinit>:
{
80101fd0:	55                   	push   %ebp
80101fd1:	89 e5                	mov    %esp,%ebp
80101fd3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101fd6:	68 5b 77 10 80       	push   $0x8010775b
80101fdb:	68 80 b5 10 80       	push   $0x8010b580
80101fe0:	e8 fb 26 00 00       	call   801046e0 <initlock>
  picenable(IRQ_IDE);
80101fe5:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80101fec:	e8 ff 12 00 00       	call   801032f0 <picenable>
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
8010206e:	e8 8d 26 00 00       	call   80104700 <acquire>
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
801020d1:	e8 1a 20 00 00       	call   801040f0 <wakeup>

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
801020ef:	e8 cc 27 00 00       	call   801048c0 <release>

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
8010213c:	e8 bf 25 00 00       	call   80104700 <acquire>

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
80102189:	e8 b2 1d 00 00       	call   80103f40 <sleep>
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
801021a6:	e9 15 27 00 00       	jmp    801048c0 <release>
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
801021ca:	68 73 77 10 80       	push   $0x80107773
801021cf:	e8 9c e1 ff ff       	call   80100370 <panic>
    panic("iderw: buf not busy");
801021d4:	83 ec 0c             	sub    $0xc,%esp
801021d7:	68 5f 77 10 80       	push   $0x8010775f
801021dc:	e8 8f e1 ff ff       	call   80100370 <panic>
    panic("iderw: ide disk 1 not present");
801021e1:	83 ec 0c             	sub    $0xc,%esp
801021e4:	68 88 77 10 80       	push   $0x80107788
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
80102293:	68 a8 77 10 80       	push   $0x801077a8
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
80102312:	81 fb 48 c3 11 80    	cmp    $0x8011c348,%ebx
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
80102332:	e8 d9 25 00 00       	call   80104910 <memset>

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
8010236b:	e9 50 25 00 00       	jmp    801048c0 <release>
    acquire(&kmem.lock);
80102370:	83 ec 0c             	sub    $0xc,%esp
80102373:	68 a0 21 11 80       	push   $0x801121a0
80102378:	e8 83 23 00 00       	call   80104700 <acquire>
8010237d:	83 c4 10             	add    $0x10,%esp
80102380:	eb c2                	jmp    80102344 <kfree+0x44>
    panic("kfree");
80102382:	83 ec 0c             	sub    $0xc,%esp
80102385:	68 da 77 10 80       	push   $0x801077da
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
801023eb:	68 e0 77 10 80       	push   $0x801077e0
801023f0:	68 a0 21 11 80       	push   $0x801121a0
801023f5:	e8 e6 22 00 00       	call   801046e0 <initlock>
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
801024e3:	e8 18 22 00 00       	call   80104700 <acquire>
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
80102511:	e8 aa 23 00 00       	call   801048c0 <release>
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
80102563:	0f b6 82 20 79 10 80 	movzbl -0x7fef86e0(%edx),%eax
8010256a:	09 c1                	or     %eax,%ecx
  shift ^= togglecode[data];
8010256c:	0f b6 82 20 78 10 80 	movzbl -0x7fef87e0(%edx),%eax
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
80102583:	8b 04 85 00 78 10 80 	mov    -0x7fef8800(,%eax,4),%eax
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
801025a8:	0f b6 82 20 79 10 80 	movzbl -0x7fef86e0(%edx),%eax
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
801027a6:	68 20 7a 10 80       	push   $0x80107a20
801027ab:	e8 90 de ff ff       	call   80100640 <cprintf>
801027b0:	83 c4 10             	add    $0x10,%esp
801027b3:	eb 89                	jmp    8010273e <cpunum+0x1e>
  panic("unknown apicid\n");
801027b5:	83 ec 0c             	sub    $0xc,%esp
801027b8:	68 4c 7a 10 80       	push   $0x80107a4c
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
801029b7:	e8 a4 1f 00 00       	call   80104960 <memcmp>
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
80102ae4:	e8 d7 1e 00 00       	call   801049c0 <memmove>
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
80102b8a:	68 5c 7a 10 80       	push   $0x80107a5c
80102b8f:	68 e0 21 11 80       	push   $0x801121e0
80102b94:	e8 47 1b 00 00       	call   801046e0 <initlock>
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
80102c2b:	e8 d0 1a 00 00       	call   80104700 <acquire>
80102c30:	83 c4 10             	add    $0x10,%esp
80102c33:	eb 18                	jmp    80102c4d <begin_op+0x2d>
80102c35:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102c38:	83 ec 08             	sub    $0x8,%esp
80102c3b:	68 e0 21 11 80       	push   $0x801121e0
80102c40:	68 e0 21 11 80       	push   $0x801121e0
80102c45:	e8 f6 12 00 00       	call   80103f40 <sleep>
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
80102c7c:	e8 3f 1c 00 00       	call   801048c0 <release>
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
80102c9e:	e8 5d 1a 00 00       	call   80104700 <acquire>
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
80102cdc:	e8 df 1b 00 00       	call   801048c0 <release>
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
80102d36:	e8 85 1c 00 00       	call   801049c0 <memmove>
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
80102d7f:	e8 7c 19 00 00       	call   80104700 <acquire>
    wakeup(&log);
80102d84:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
    log.committing = 0;
80102d8b:	c7 05 20 22 11 80 00 	movl   $0x0,0x80112220
80102d92:	00 00 00 
    wakeup(&log);
80102d95:	e8 56 13 00 00       	call   801040f0 <wakeup>
    release(&log.lock);
80102d9a:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102da1:	e8 1a 1b 00 00       	call   801048c0 <release>
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
80102dc0:	e8 2b 13 00 00       	call   801040f0 <wakeup>
  release(&log.lock);
80102dc5:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102dcc:	e8 ef 1a 00 00       	call   801048c0 <release>
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
80102ddf:	68 60 7a 10 80       	push   $0x80107a60
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
80102e2e:	e8 cd 18 00 00       	call   80104700 <acquire>
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
80102e7d:	e9 3e 1a 00 00       	jmp    801048c0 <release>
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
80102ea9:	68 6f 7a 10 80       	push   $0x80107a6f
80102eae:	e8 bd d4 ff ff       	call   80100370 <panic>
    panic("log_write outside of trans");
80102eb3:	83 ec 0c             	sub    $0xc,%esp
80102eb6:	68 85 7a 10 80       	push   $0x80107a85
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
  cprintf("cpu%d: starting\n", cpuid);
80102ecc:	83 ec 08             	sub    $0x8,%esp
  int cpuid = cpunum();
80102ecf:	89 c3                	mov    %eax,%ebx
  cprintf("cpu%d: starting\n", cpuid);
80102ed1:	50                   	push   %eax
80102ed2:	68 a0 7a 10 80       	push   $0x80107aa0
80102ed7:	e8 64 d7 ff ff       	call   80100640 <cprintf>
  idtinit();       // load idt register
80102edc:	e8 2f 2e 00 00       	call   80105d10 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80102ee1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102ee8:	b8 01 00 00 00       	mov    $0x1,%eax
80102eed:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler(cpuid);     // start running processes
80102ef4:	89 1c 24             	mov    %ebx,(%esp)
80102ef7:	e8 24 0d 00 00       	call   80103c20 <scheduler>
80102efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102f00 <mpenter>:
{
80102f00:	55                   	push   %ebp
80102f01:	89 e5                	mov    %esp,%ebp
80102f03:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102f06:	e8 95 3f 00 00       	call   80106ea0 <switchkvm>
  seginit();
80102f0b:	e8 20 3e 00 00       	call   80106d30 <seginit>
  lapicinit();
80102f10:	e8 0b f7 ff ff       	call   80102620 <lapicinit>
  mpmain();
80102f15:	e8 a6 ff ff ff       	call   80102ec0 <mpmain>
80102f1a:	66 90                	xchg   %ax,%ax
80102f1c:	66 90                	xchg   %ax,%ax
80102f1e:	66 90                	xchg   %ax,%ax

80102f20 <main>:
{
80102f20:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102f24:	83 e4 f0             	and    $0xfffffff0,%esp
80102f27:	ff 71 fc             	pushl  -0x4(%ecx)
80102f2a:	55                   	push   %ebp
80102f2b:	89 e5                	mov    %esp,%ebp
80102f2d:	53                   	push   %ebx
80102f2e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102f2f:	83 ec 08             	sub    $0x8,%esp
80102f32:	68 00 00 40 80       	push   $0x80400000
80102f37:	68 48 c3 11 80       	push   $0x8011c348
80102f3c:	e8 9f f4 ff ff       	call   801023e0 <kinit1>
  kvmalloc();      // kernel page table
80102f41:	e8 3a 3f 00 00       	call   80106e80 <kvmalloc>
  mpinit();        // detect other processors
80102f46:	e8 b5 01 00 00       	call   80103100 <mpinit>
  lapicinit();     // interrupt controller
80102f4b:	e8 d0 f6 ff ff       	call   80102620 <lapicinit>
  seginit();       // segment descriptors
80102f50:	e8 db 3d 00 00       	call   80106d30 <seginit>
  cprintf("\ncpu%d: starting xv6\n----------------------------\nzzx is programming xv6\n----------------------------\n", cpunum());
80102f55:	e8 c6 f7 ff ff       	call   80102720 <cpunum>
80102f5a:	5a                   	pop    %edx
80102f5b:	59                   	pop    %ecx
80102f5c:	50                   	push   %eax
80102f5d:	68 b4 7a 10 80       	push   $0x80107ab4
80102f62:	e8 d9 d6 ff ff       	call   80100640 <cprintf>
  picinit();       // another interrupt controller
80102f67:	e8 b4 03 00 00       	call   80103320 <picinit>
  ioapicinit();    // another interrupt controller
80102f6c:	e8 7f f2 ff ff       	call   801021f0 <ioapicinit>
  consoleinit();   // console hardware
80102f71:	e8 2a da ff ff       	call   801009a0 <consoleinit>
  uartinit();      // serial port
80102f76:	e8 85 30 00 00       	call   80106000 <uartinit>
  pinit();         // process table
80102f7b:	e8 b0 09 00 00       	call   80103930 <pinit>
  tvinit();        // trap vectors
80102f80:	e8 0b 2d 00 00       	call   80105c90 <tvinit>
  binit();         // buffer cache
80102f85:	e8 b6 d0 ff ff       	call   80100040 <binit>
  fileinit();      // file table
80102f8a:	e8 a1 dd ff ff       	call   80100d30 <fileinit>
  ideinit();       // disk
80102f8f:	e8 3c f0 ff ff       	call   80101fd0 <ideinit>
  if(!ismp)
80102f94:	8b 1d c4 22 11 80    	mov    0x801122c4,%ebx
80102f9a:	83 c4 10             	add    $0x10,%esp
80102f9d:	85 db                	test   %ebx,%ebx
80102f9f:	0f 84 ca 00 00 00    	je     8010306f <main+0x14f>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102fa5:	83 ec 04             	sub    $0x4,%esp
80102fa8:	68 8a 00 00 00       	push   $0x8a
80102fad:	68 8c b4 10 80       	push   $0x8010b48c
80102fb2:	68 00 70 00 80       	push   $0x80007000
80102fb7:	e8 04 1a 00 00       	call   801049c0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102fbc:	69 05 60 3a 11 80 bc 	imul   $0xbc,0x80113a60,%eax
80102fc3:	00 00 00 
80102fc6:	83 c4 10             	add    $0x10,%esp
80102fc9:	05 e0 22 11 80       	add    $0x801122e0,%eax
80102fce:	3d e0 22 11 80       	cmp    $0x801122e0,%eax
80102fd3:	76 7e                	jbe    80103053 <main+0x133>
80102fd5:	bb e0 22 11 80       	mov    $0x801122e0,%ebx
80102fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(c == cpus+cpunum())  // We've started already.
80102fe0:	e8 3b f7 ff ff       	call   80102720 <cpunum>
80102fe5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80102feb:	05 e0 22 11 80       	add    $0x801122e0,%eax
80102ff0:	39 c3                	cmp    %eax,%ebx
80102ff2:	74 46                	je     8010303a <main+0x11a>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102ff4:	e8 b7 f4 ff ff       	call   801024b0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80102ff9:	83 ec 08             	sub    $0x8,%esp
    *(void**)(code-4) = stack + KSTACKSIZE;
80102ffc:	05 00 10 00 00       	add    $0x1000,%eax
    *(void**)(code-8) = mpenter;
80103001:	c7 05 f8 6f 00 80 00 	movl   $0x80102f00,0x80006ff8
80103008:	2f 10 80 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010300b:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103010:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
80103017:	a0 10 00 
    lapicstartap(c->apicid, V2P(code));
8010301a:	68 00 70 00 00       	push   $0x7000
8010301f:	0f b6 03             	movzbl (%ebx),%eax
80103022:	50                   	push   %eax
80103023:	e8 d8 f7 ff ff       	call   80102800 <lapicstartap>
80103028:	83 c4 10             	add    $0x10,%esp
8010302b:	90                   	nop
8010302c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103030:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
80103036:	85 c0                	test   %eax,%eax
80103038:	74 f6                	je     80103030 <main+0x110>
  for(c = cpus; c < cpus+ncpu; c++){
8010303a:	69 05 60 3a 11 80 bc 	imul   $0xbc,0x80113a60,%eax
80103041:	00 00 00 
80103044:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
8010304a:	05 e0 22 11 80       	add    $0x801122e0,%eax
8010304f:	39 c3                	cmp    %eax,%ebx
80103051:	72 8d                	jb     80102fe0 <main+0xc0>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103053:	83 ec 08             	sub    $0x8,%esp
80103056:	68 00 00 00 8e       	push   $0x8e000000
8010305b:	68 00 00 40 80       	push   $0x80400000
80103060:	e8 eb f3 ff ff       	call   80102450 <kinit2>
  userinit();      // first user process
80103065:	e8 06 09 00 00       	call   80103970 <userinit>
  mpmain();        // finish this processor's setup
8010306a:	e8 51 fe ff ff       	call   80102ec0 <mpmain>
    timerinit();   // uniprocessor timer
8010306f:	e8 bc 2b 00 00       	call   80105c30 <timerinit>
80103074:	e9 2c ff ff ff       	jmp    80102fa5 <main+0x85>
80103079:	66 90                	xchg   %ax,%ax
8010307b:	66 90                	xchg   %ax,%ax
8010307d:	66 90                	xchg   %ax,%ax
8010307f:	90                   	nop

80103080 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103080:	55                   	push   %ebp
80103081:	89 e5                	mov    %esp,%ebp
80103083:	57                   	push   %edi
80103084:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103085:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010308b:	53                   	push   %ebx
  e = addr+len;
8010308c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010308f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103092:	39 de                	cmp    %ebx,%esi
80103094:	72 10                	jb     801030a6 <mpsearch1+0x26>
80103096:	eb 50                	jmp    801030e8 <mpsearch1+0x68>
80103098:	90                   	nop
80103099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030a0:	39 fb                	cmp    %edi,%ebx
801030a2:	89 fe                	mov    %edi,%esi
801030a4:	76 42                	jbe    801030e8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801030a6:	83 ec 04             	sub    $0x4,%esp
801030a9:	8d 7e 10             	lea    0x10(%esi),%edi
801030ac:	6a 04                	push   $0x4
801030ae:	68 1b 7b 10 80       	push   $0x80107b1b
801030b3:	56                   	push   %esi
801030b4:	e8 a7 18 00 00       	call   80104960 <memcmp>
801030b9:	83 c4 10             	add    $0x10,%esp
801030bc:	85 c0                	test   %eax,%eax
801030be:	75 e0                	jne    801030a0 <mpsearch1+0x20>
801030c0:	89 f1                	mov    %esi,%ecx
801030c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801030c8:	0f b6 11             	movzbl (%ecx),%edx
801030cb:	83 c1 01             	add    $0x1,%ecx
801030ce:	01 d0                	add    %edx,%eax
  for(i=0; i<len; i++)
801030d0:	39 f9                	cmp    %edi,%ecx
801030d2:	75 f4                	jne    801030c8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801030d4:	84 c0                	test   %al,%al
801030d6:	75 c8                	jne    801030a0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801030d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030db:	89 f0                	mov    %esi,%eax
801030dd:	5b                   	pop    %ebx
801030de:	5e                   	pop    %esi
801030df:	5f                   	pop    %edi
801030e0:	5d                   	pop    %ebp
801030e1:	c3                   	ret    
801030e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801030e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801030eb:	31 f6                	xor    %esi,%esi
}
801030ed:	89 f0                	mov    %esi,%eax
801030ef:	5b                   	pop    %ebx
801030f0:	5e                   	pop    %esi
801030f1:	5f                   	pop    %edi
801030f2:	5d                   	pop    %ebp
801030f3:	c3                   	ret    
801030f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801030fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103100 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103100:	55                   	push   %ebp
80103101:	89 e5                	mov    %esp,%ebp
80103103:	57                   	push   %edi
80103104:	56                   	push   %esi
80103105:	53                   	push   %ebx
80103106:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103109:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103110:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103117:	c1 e0 08             	shl    $0x8,%eax
8010311a:	09 d0                	or     %edx,%eax
8010311c:	c1 e0 04             	shl    $0x4,%eax
8010311f:	85 c0                	test   %eax,%eax
80103121:	75 1b                	jne    8010313e <mpinit+0x3e>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103123:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
8010312a:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80103131:	c1 e0 08             	shl    $0x8,%eax
80103134:	09 d0                	or     %edx,%eax
80103136:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103139:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010313e:	ba 00 04 00 00       	mov    $0x400,%edx
80103143:	e8 38 ff ff ff       	call   80103080 <mpsearch1>
80103148:	85 c0                	test   %eax,%eax
8010314a:	89 c7                	mov    %eax,%edi
8010314c:	0f 84 76 01 00 00    	je     801032c8 <mpinit+0x1c8>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103152:	8b 5f 04             	mov    0x4(%edi),%ebx
80103155:	85 db                	test   %ebx,%ebx
80103157:	0f 84 e6 00 00 00    	je     80103243 <mpinit+0x143>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010315d:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80103163:	83 ec 04             	sub    $0x4,%esp
80103166:	6a 04                	push   $0x4
80103168:	68 20 7b 10 80       	push   $0x80107b20
8010316d:	56                   	push   %esi
8010316e:	e8 ed 17 00 00       	call   80104960 <memcmp>
80103173:	83 c4 10             	add    $0x10,%esp
80103176:	85 c0                	test   %eax,%eax
80103178:	0f 85 c5 00 00 00    	jne    80103243 <mpinit+0x143>
  if(conf->version != 1 && conf->version != 4)
8010317e:	0f b6 93 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%edx
80103185:	80 fa 01             	cmp    $0x1,%dl
80103188:	0f 95 c1             	setne  %cl
8010318b:	80 fa 04             	cmp    $0x4,%dl
8010318e:	0f 95 c2             	setne  %dl
80103191:	20 ca                	and    %cl,%dl
80103193:	0f 85 aa 00 00 00    	jne    80103243 <mpinit+0x143>
  if(sum((uchar*)conf, conf->length) != 0)
80103199:	0f b7 8b 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%ecx
  for(i=0; i<len; i++)
801031a0:	66 85 c9             	test   %cx,%cx
801031a3:	74 1f                	je     801031c4 <mpinit+0xc4>
801031a5:	01 f1                	add    %esi,%ecx
801031a7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801031aa:	89 f2                	mov    %esi,%edx
801031ac:	89 cb                	mov    %ecx,%ebx
801031ae:	66 90                	xchg   %ax,%ax
    sum += addr[i];
801031b0:	0f b6 0a             	movzbl (%edx),%ecx
801031b3:	83 c2 01             	add    $0x1,%edx
801031b6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801031b8:	39 da                	cmp    %ebx,%edx
801031ba:	75 f4                	jne    801031b0 <mpinit+0xb0>
801031bc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801031bf:	84 c0                	test   %al,%al
801031c1:	0f 95 c2             	setne  %dl
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
801031c4:	85 f6                	test   %esi,%esi
801031c6:	74 7b                	je     80103243 <mpinit+0x143>
801031c8:	84 d2                	test   %dl,%dl
801031ca:	75 77                	jne    80103243 <mpinit+0x143>
    return;
  ismp = 1;
801031cc:	c7 05 c4 22 11 80 01 	movl   $0x1,0x801122c4
801031d3:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801031d6:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
801031dc:	a3 dc 21 11 80       	mov    %eax,0x801121dc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801031e1:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
801031e8:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
801031ee:	01 d6                	add    %edx,%esi
801031f0:	39 f0                	cmp    %esi,%eax
801031f2:	0f 83 a8 00 00 00    	jae    801032a0 <mpinit+0x1a0>
801031f8:	90                   	nop
801031f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(*p){
80103200:	80 38 04             	cmpb   $0x4,(%eax)
80103203:	0f 87 87 00 00 00    	ja     80103290 <mpinit+0x190>
80103209:	0f b6 10             	movzbl (%eax),%edx
8010320c:	ff 24 95 28 7b 10 80 	jmp    *-0x7fef84d8(,%edx,4)
80103213:	90                   	nop
80103214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103218:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010321b:	39 c6                	cmp    %eax,%esi
8010321d:	77 e1                	ja     80103200 <mpinit+0x100>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp){
8010321f:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103224:	85 c0                	test   %eax,%eax
80103226:	75 78                	jne    801032a0 <mpinit+0x1a0>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103228:	c7 05 60 3a 11 80 01 	movl   $0x1,0x80113a60
8010322f:	00 00 00 
    lapic = 0;
80103232:	c7 05 dc 21 11 80 00 	movl   $0x0,0x801121dc
80103239:	00 00 00 
    ioapicid = 0;
8010323c:	c6 05 c0 22 11 80 00 	movb   $0x0,0x801122c0
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103243:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103246:	5b                   	pop    %ebx
80103247:	5e                   	pop    %esi
80103248:	5f                   	pop    %edi
80103249:	5d                   	pop    %ebp
8010324a:	c3                   	ret    
8010324b:	90                   	nop
8010324c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(ncpu < NCPU) {
80103250:	8b 15 60 3a 11 80    	mov    0x80113a60,%edx
80103256:	83 fa 1f             	cmp    $0x1f,%edx
80103259:	7f 19                	jg     80103274 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010325b:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
8010325f:	69 da bc 00 00 00    	imul   $0xbc,%edx,%ebx
        ncpu++;
80103265:	83 c2 01             	add    $0x1,%edx
80103268:	89 15 60 3a 11 80    	mov    %edx,0x80113a60
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010326e:	88 8b e0 22 11 80    	mov    %cl,-0x7feedd20(%ebx)
      p += sizeof(struct mpproc);
80103274:	83 c0 14             	add    $0x14,%eax
      continue;
80103277:	eb a2                	jmp    8010321b <mpinit+0x11b>
80103279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103280:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      p += sizeof(struct mpioapic);
80103284:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103287:	88 15 c0 22 11 80    	mov    %dl,0x801122c0
      continue;
8010328d:	eb 8c                	jmp    8010321b <mpinit+0x11b>
8010328f:	90                   	nop
      ismp = 0;
80103290:	c7 05 c4 22 11 80 00 	movl   $0x0,0x801122c4
80103297:	00 00 00 
      break;
8010329a:	e9 7c ff ff ff       	jmp    8010321b <mpinit+0x11b>
8010329f:	90                   	nop
  if(mp->imcrp){
801032a0:	80 7f 0c 00          	cmpb   $0x0,0xc(%edi)
801032a4:	74 9d                	je     80103243 <mpinit+0x143>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801032a6:	b8 70 00 00 00       	mov    $0x70,%eax
801032ab:	ba 22 00 00 00       	mov    $0x22,%edx
801032b0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801032b1:	ba 23 00 00 00       	mov    $0x23,%edx
801032b6:	ec                   	in     (%dx),%al
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801032b7:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801032ba:	ee                   	out    %al,(%dx)
}
801032bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801032be:	5b                   	pop    %ebx
801032bf:	5e                   	pop    %esi
801032c0:	5f                   	pop    %edi
801032c1:	5d                   	pop    %ebp
801032c2:	c3                   	ret    
801032c3:	90                   	nop
801032c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return mpsearch1(0xF0000, 0x10000);
801032c8:	ba 00 00 01 00       	mov    $0x10000,%edx
801032cd:	b8 00 00 0f 00       	mov    $0xf0000,%eax
801032d2:	e8 a9 fd ff ff       	call   80103080 <mpsearch1>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801032d7:	85 c0                	test   %eax,%eax
  return mpsearch1(0xF0000, 0x10000);
801032d9:	89 c7                	mov    %eax,%edi
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801032db:	0f 85 71 fe ff ff    	jne    80103152 <mpinit+0x52>
801032e1:	e9 5d ff ff ff       	jmp    80103243 <mpinit+0x143>
801032e6:	66 90                	xchg   %ax,%ax
801032e8:	66 90                	xchg   %ax,%ax
801032ea:	66 90                	xchg   %ax,%ax
801032ec:	66 90                	xchg   %ax,%ax
801032ee:	66 90                	xchg   %ax,%ax

801032f0 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
801032f0:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
801032f1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801032f6:	ba 21 00 00 00       	mov    $0x21,%edx
{
801032fb:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
801032fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103300:	d3 c0                	rol    %cl,%eax
80103302:	66 23 05 00 b0 10 80 	and    0x8010b000,%ax
  irqmask = mask;
80103309:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
8010330f:	ee                   	out    %al,(%dx)
80103310:	ba a1 00 00 00       	mov    $0xa1,%edx
  outb(IO_PIC2+1, mask >> 8);
80103315:	66 c1 e8 08          	shr    $0x8,%ax
80103319:	ee                   	out    %al,(%dx)
}
8010331a:	5d                   	pop    %ebp
8010331b:	c3                   	ret    
8010331c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103320 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103320:	55                   	push   %ebp
80103321:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103326:	89 e5                	mov    %esp,%ebp
80103328:	57                   	push   %edi
80103329:	56                   	push   %esi
8010332a:	53                   	push   %ebx
8010332b:	bb 21 00 00 00       	mov    $0x21,%ebx
80103330:	89 da                	mov    %ebx,%edx
80103332:	ee                   	out    %al,(%dx)
80103333:	b9 a1 00 00 00       	mov    $0xa1,%ecx
80103338:	89 ca                	mov    %ecx,%edx
8010333a:	ee                   	out    %al,(%dx)
8010333b:	be 11 00 00 00       	mov    $0x11,%esi
80103340:	ba 20 00 00 00       	mov    $0x20,%edx
80103345:	89 f0                	mov    %esi,%eax
80103347:	ee                   	out    %al,(%dx)
80103348:	b8 20 00 00 00       	mov    $0x20,%eax
8010334d:	89 da                	mov    %ebx,%edx
8010334f:	ee                   	out    %al,(%dx)
80103350:	b8 04 00 00 00       	mov    $0x4,%eax
80103355:	ee                   	out    %al,(%dx)
80103356:	bf 03 00 00 00       	mov    $0x3,%edi
8010335b:	89 f8                	mov    %edi,%eax
8010335d:	ee                   	out    %al,(%dx)
8010335e:	ba a0 00 00 00       	mov    $0xa0,%edx
80103363:	89 f0                	mov    %esi,%eax
80103365:	ee                   	out    %al,(%dx)
80103366:	b8 28 00 00 00       	mov    $0x28,%eax
8010336b:	89 ca                	mov    %ecx,%edx
8010336d:	ee                   	out    %al,(%dx)
8010336e:	b8 02 00 00 00       	mov    $0x2,%eax
80103373:	ee                   	out    %al,(%dx)
80103374:	89 f8                	mov    %edi,%eax
80103376:	ee                   	out    %al,(%dx)
80103377:	bf 68 00 00 00       	mov    $0x68,%edi
8010337c:	ba 20 00 00 00       	mov    $0x20,%edx
80103381:	89 f8                	mov    %edi,%eax
80103383:	ee                   	out    %al,(%dx)
80103384:	be 0a 00 00 00       	mov    $0xa,%esi
80103389:	89 f0                	mov    %esi,%eax
8010338b:	ee                   	out    %al,(%dx)
8010338c:	ba a0 00 00 00       	mov    $0xa0,%edx
80103391:	89 f8                	mov    %edi,%eax
80103393:	ee                   	out    %al,(%dx)
80103394:	89 f0                	mov    %esi,%eax
80103396:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
80103397:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010339e:	66 83 f8 ff          	cmp    $0xffff,%ax
801033a2:	74 0a                	je     801033ae <picinit+0x8e>
801033a4:	89 da                	mov    %ebx,%edx
801033a6:	ee                   	out    %al,(%dx)
  outb(IO_PIC2+1, mask >> 8);
801033a7:	66 c1 e8 08          	shr    $0x8,%ax
801033ab:	89 ca                	mov    %ecx,%edx
801033ad:	ee                   	out    %al,(%dx)
    picsetmask(irqmask);
}
801033ae:	5b                   	pop    %ebx
801033af:	5e                   	pop    %esi
801033b0:	5f                   	pop    %edi
801033b1:	5d                   	pop    %ebp
801033b2:	c3                   	ret    
801033b3:	66 90                	xchg   %ax,%ax
801033b5:	66 90                	xchg   %ax,%ax
801033b7:	66 90                	xchg   %ax,%ax
801033b9:	66 90                	xchg   %ax,%ax
801033bb:	66 90                	xchg   %ax,%ax
801033bd:	66 90                	xchg   %ax,%ax
801033bf:	90                   	nop

801033c0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801033c0:	55                   	push   %ebp
801033c1:	89 e5                	mov    %esp,%ebp
801033c3:	57                   	push   %edi
801033c4:	56                   	push   %esi
801033c5:	53                   	push   %ebx
801033c6:	83 ec 0c             	sub    $0xc,%esp
801033c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801033cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
801033cf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801033d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801033db:	e8 70 d9 ff ff       	call   80100d50 <filealloc>
801033e0:	85 c0                	test   %eax,%eax
801033e2:	89 03                	mov    %eax,(%ebx)
801033e4:	74 22                	je     80103408 <pipealloc+0x48>
801033e6:	e8 65 d9 ff ff       	call   80100d50 <filealloc>
801033eb:	85 c0                	test   %eax,%eax
801033ed:	89 06                	mov    %eax,(%esi)
801033ef:	74 3f                	je     80103430 <pipealloc+0x70>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801033f1:	e8 ba f0 ff ff       	call   801024b0 <kalloc>
801033f6:	85 c0                	test   %eax,%eax
801033f8:	89 c7                	mov    %eax,%edi
801033fa:	75 54                	jne    80103450 <pipealloc+0x90>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
801033fc:	8b 03                	mov    (%ebx),%eax
801033fe:	85 c0                	test   %eax,%eax
80103400:	75 34                	jne    80103436 <pipealloc+0x76>
80103402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    fileclose(*f0);
  if(*f1)
80103408:	8b 06                	mov    (%esi),%eax
8010340a:	85 c0                	test   %eax,%eax
8010340c:	74 0c                	je     8010341a <pipealloc+0x5a>
    fileclose(*f1);
8010340e:	83 ec 0c             	sub    $0xc,%esp
80103411:	50                   	push   %eax
80103412:	e8 f9 d9 ff ff       	call   80100e10 <fileclose>
80103417:	83 c4 10             	add    $0x10,%esp
  return -1;
}
8010341a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010341d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103422:	5b                   	pop    %ebx
80103423:	5e                   	pop    %esi
80103424:	5f                   	pop    %edi
80103425:	5d                   	pop    %ebp
80103426:	c3                   	ret    
80103427:	89 f6                	mov    %esi,%esi
80103429:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  if(*f0)
80103430:	8b 03                	mov    (%ebx),%eax
80103432:	85 c0                	test   %eax,%eax
80103434:	74 e4                	je     8010341a <pipealloc+0x5a>
    fileclose(*f0);
80103436:	83 ec 0c             	sub    $0xc,%esp
80103439:	50                   	push   %eax
8010343a:	e8 d1 d9 ff ff       	call   80100e10 <fileclose>
  if(*f1)
8010343f:	8b 06                	mov    (%esi),%eax
    fileclose(*f0);
80103441:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103444:	85 c0                	test   %eax,%eax
80103446:	75 c6                	jne    8010340e <pipealloc+0x4e>
80103448:	eb d0                	jmp    8010341a <pipealloc+0x5a>
8010344a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  initlock(&p->lock, "pipe");
80103450:	83 ec 08             	sub    $0x8,%esp
  p->readopen = 1;
80103453:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010345a:	00 00 00 
  p->writeopen = 1;
8010345d:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103464:	00 00 00 
  p->nwrite = 0;
80103467:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010346e:	00 00 00 
  p->nread = 0;
80103471:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103478:	00 00 00 
  initlock(&p->lock, "pipe");
8010347b:	68 3c 7b 10 80       	push   $0x80107b3c
80103480:	50                   	push   %eax
80103481:	e8 5a 12 00 00       	call   801046e0 <initlock>
  (*f0)->type = FD_PIPE;
80103486:	8b 03                	mov    (%ebx),%eax
  return 0;
80103488:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010348b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103491:	8b 03                	mov    (%ebx),%eax
80103493:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103497:	8b 03                	mov    (%ebx),%eax
80103499:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010349d:	8b 03                	mov    (%ebx),%eax
8010349f:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801034a2:	8b 06                	mov    (%esi),%eax
801034a4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801034aa:	8b 06                	mov    (%esi),%eax
801034ac:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801034b0:	8b 06                	mov    (%esi),%eax
801034b2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801034b6:	8b 06                	mov    (%esi),%eax
801034b8:	89 78 0c             	mov    %edi,0xc(%eax)
}
801034bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801034be:	31 c0                	xor    %eax,%eax
}
801034c0:	5b                   	pop    %ebx
801034c1:	5e                   	pop    %esi
801034c2:	5f                   	pop    %edi
801034c3:	5d                   	pop    %ebp
801034c4:	c3                   	ret    
801034c5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801034c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801034d0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801034d0:	55                   	push   %ebp
801034d1:	89 e5                	mov    %esp,%ebp
801034d3:	56                   	push   %esi
801034d4:	53                   	push   %ebx
801034d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801034d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801034db:	83 ec 0c             	sub    $0xc,%esp
801034de:	53                   	push   %ebx
801034df:	e8 1c 12 00 00       	call   80104700 <acquire>
  if(writable){
801034e4:	83 c4 10             	add    $0x10,%esp
801034e7:	85 f6                	test   %esi,%esi
801034e9:	74 45                	je     80103530 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
801034eb:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801034f1:	83 ec 0c             	sub    $0xc,%esp
    p->writeopen = 0;
801034f4:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
801034fb:	00 00 00 
    wakeup(&p->nread);
801034fe:	50                   	push   %eax
801034ff:	e8 ec 0b 00 00       	call   801040f0 <wakeup>
80103504:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103507:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010350d:	85 d2                	test   %edx,%edx
8010350f:	75 0a                	jne    8010351b <pipeclose+0x4b>
80103511:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103517:	85 c0                	test   %eax,%eax
80103519:	74 35                	je     80103550 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010351b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010351e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103521:	5b                   	pop    %ebx
80103522:	5e                   	pop    %esi
80103523:	5d                   	pop    %ebp
    release(&p->lock);
80103524:	e9 97 13 00 00       	jmp    801048c0 <release>
80103529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&p->nwrite);
80103530:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103536:	83 ec 0c             	sub    $0xc,%esp
    p->readopen = 0;
80103539:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103540:	00 00 00 
    wakeup(&p->nwrite);
80103543:	50                   	push   %eax
80103544:	e8 a7 0b 00 00       	call   801040f0 <wakeup>
80103549:	83 c4 10             	add    $0x10,%esp
8010354c:	eb b9                	jmp    80103507 <pipeclose+0x37>
8010354e:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80103550:	83 ec 0c             	sub    $0xc,%esp
80103553:	53                   	push   %ebx
80103554:	e8 67 13 00 00       	call   801048c0 <release>
    kfree((char*)p);
80103559:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010355c:	83 c4 10             	add    $0x10,%esp
}
8010355f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103562:	5b                   	pop    %ebx
80103563:	5e                   	pop    %esi
80103564:	5d                   	pop    %ebp
    kfree((char*)p);
80103565:	e9 96 ed ff ff       	jmp    80102300 <kfree>
8010356a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103570 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103570:	55                   	push   %ebp
80103571:	89 e5                	mov    %esp,%ebp
80103573:	57                   	push   %edi
80103574:	56                   	push   %esi
80103575:	53                   	push   %ebx
80103576:	83 ec 28             	sub    $0x28,%esp
80103579:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i;

  acquire(&p->lock);
8010357c:	57                   	push   %edi
8010357d:	e8 7e 11 00 00       	call   80104700 <acquire>
  for(i = 0; i < n; i++){
80103582:	8b 45 10             	mov    0x10(%ebp),%eax
80103585:	83 c4 10             	add    $0x10,%esp
80103588:	85 c0                	test   %eax,%eax
8010358a:	0f 8e c6 00 00 00    	jle    80103656 <pipewrite+0xe6>
80103590:	8b 45 0c             	mov    0xc(%ebp),%eax
80103593:	8b 8f 38 02 00 00    	mov    0x238(%edi),%ecx
80103599:	8d b7 34 02 00 00    	lea    0x234(%edi),%esi
8010359f:	8d 9f 38 02 00 00    	lea    0x238(%edi),%ebx
801035a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801035a8:	03 45 10             	add    0x10(%ebp),%eax
801035ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801035ae:	8b 87 34 02 00 00    	mov    0x234(%edi),%eax
801035b4:	8d 90 00 02 00 00    	lea    0x200(%eax),%edx
801035ba:	39 d1                	cmp    %edx,%ecx
801035bc:	0f 85 cf 00 00 00    	jne    80103691 <pipewrite+0x121>
      if(p->readopen == 0 || proc->killed){
801035c2:	8b 97 3c 02 00 00    	mov    0x23c(%edi),%edx
801035c8:	85 d2                	test   %edx,%edx
801035ca:	0f 84 a8 00 00 00    	je     80103678 <pipewrite+0x108>
801035d0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801035d7:	8b 42 28             	mov    0x28(%edx),%eax
801035da:	85 c0                	test   %eax,%eax
801035dc:	74 25                	je     80103603 <pipewrite+0x93>
801035de:	e9 95 00 00 00       	jmp    80103678 <pipewrite+0x108>
801035e3:	90                   	nop
801035e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801035e8:	8b 87 3c 02 00 00    	mov    0x23c(%edi),%eax
801035ee:	85 c0                	test   %eax,%eax
801035f0:	0f 84 82 00 00 00    	je     80103678 <pipewrite+0x108>
801035f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801035fc:	8b 40 28             	mov    0x28(%eax),%eax
801035ff:	85 c0                	test   %eax,%eax
80103601:	75 75                	jne    80103678 <pipewrite+0x108>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103603:	83 ec 0c             	sub    $0xc,%esp
80103606:	56                   	push   %esi
80103607:	e8 e4 0a 00 00       	call   801040f0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010360c:	59                   	pop    %ecx
8010360d:	58                   	pop    %eax
8010360e:	57                   	push   %edi
8010360f:	53                   	push   %ebx
80103610:	e8 2b 09 00 00       	call   80103f40 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103615:	8b 87 34 02 00 00    	mov    0x234(%edi),%eax
8010361b:	8b 97 38 02 00 00    	mov    0x238(%edi),%edx
80103621:	83 c4 10             	add    $0x10,%esp
80103624:	05 00 02 00 00       	add    $0x200,%eax
80103629:	39 c2                	cmp    %eax,%edx
8010362b:	74 bb                	je     801035e8 <pipewrite+0x78>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010362d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103630:	8d 4a 01             	lea    0x1(%edx),%ecx
80103633:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103637:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010363d:	89 8f 38 02 00 00    	mov    %ecx,0x238(%edi)
80103643:	0f b6 00             	movzbl (%eax),%eax
80103646:	88 44 17 34          	mov    %al,0x34(%edi,%edx,1)
8010364a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  for(i = 0; i < n; i++){
8010364d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80103650:	0f 85 58 ff ff ff    	jne    801035ae <pipewrite+0x3e>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103656:	8d 97 34 02 00 00    	lea    0x234(%edi),%edx
8010365c:	83 ec 0c             	sub    $0xc,%esp
8010365f:	52                   	push   %edx
80103660:	e8 8b 0a 00 00       	call   801040f0 <wakeup>
  release(&p->lock);
80103665:	89 3c 24             	mov    %edi,(%esp)
80103668:	e8 53 12 00 00       	call   801048c0 <release>
  return n;
8010366d:	83 c4 10             	add    $0x10,%esp
80103670:	8b 45 10             	mov    0x10(%ebp),%eax
80103673:	eb 14                	jmp    80103689 <pipewrite+0x119>
80103675:	8d 76 00             	lea    0x0(%esi),%esi
        release(&p->lock);
80103678:	83 ec 0c             	sub    $0xc,%esp
8010367b:	57                   	push   %edi
8010367c:	e8 3f 12 00 00       	call   801048c0 <release>
        return -1;
80103681:	83 c4 10             	add    $0x10,%esp
80103684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103689:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010368c:	5b                   	pop    %ebx
8010368d:	5e                   	pop    %esi
8010368e:	5f                   	pop    %edi
8010368f:	5d                   	pop    %ebp
80103690:	c3                   	ret    
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103691:	89 ca                	mov    %ecx,%edx
80103693:	eb 98                	jmp    8010362d <pipewrite+0xbd>
80103695:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103699:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801036a0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801036a0:	55                   	push   %ebp
801036a1:	89 e5                	mov    %esp,%ebp
801036a3:	57                   	push   %edi
801036a4:	56                   	push   %esi
801036a5:	53                   	push   %ebx
801036a6:	83 ec 18             	sub    $0x18,%esp
801036a9:	8b 75 08             	mov    0x8(%ebp),%esi
801036ac:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801036af:	56                   	push   %esi
801036b0:	e8 4b 10 00 00       	call   80104700 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801036b5:	83 c4 10             	add    $0x10,%esp
801036b8:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
801036be:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
801036c4:	75 64                	jne    8010372a <piperead+0x8a>
801036c6:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
801036cc:	85 c0                	test   %eax,%eax
801036ce:	0f 84 bc 00 00 00    	je     80103790 <piperead+0xf0>
    if(proc->killed){
801036d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801036da:	8b 58 28             	mov    0x28(%eax),%ebx
801036dd:	85 db                	test   %ebx,%ebx
801036df:	0f 85 b3 00 00 00    	jne    80103798 <piperead+0xf8>
801036e5:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801036eb:	eb 22                	jmp    8010370f <piperead+0x6f>
801036ed:	8d 76 00             	lea    0x0(%esi),%esi
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801036f0:	8b 96 40 02 00 00    	mov    0x240(%esi),%edx
801036f6:	85 d2                	test   %edx,%edx
801036f8:	0f 84 92 00 00 00    	je     80103790 <piperead+0xf0>
    if(proc->killed){
801036fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103704:	8b 48 28             	mov    0x28(%eax),%ecx
80103707:	85 c9                	test   %ecx,%ecx
80103709:	0f 85 89 00 00 00    	jne    80103798 <piperead+0xf8>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010370f:	83 ec 08             	sub    $0x8,%esp
80103712:	56                   	push   %esi
80103713:	53                   	push   %ebx
80103714:	e8 27 08 00 00       	call   80103f40 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103719:	83 c4 10             	add    $0x10,%esp
8010371c:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
80103722:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
80103728:	74 c6                	je     801036f0 <piperead+0x50>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010372a:	8b 45 10             	mov    0x10(%ebp),%eax
8010372d:	85 c0                	test   %eax,%eax
8010372f:	7e 5f                	jle    80103790 <piperead+0xf0>
    if(p->nread == p->nwrite)
80103731:	31 db                	xor    %ebx,%ebx
80103733:	eb 11                	jmp    80103746 <piperead+0xa6>
80103735:	8d 76 00             	lea    0x0(%esi),%esi
80103738:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
8010373e:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
80103744:	74 1f                	je     80103765 <piperead+0xc5>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103746:	8d 41 01             	lea    0x1(%ecx),%eax
80103749:	81 e1 ff 01 00 00    	and    $0x1ff,%ecx
8010374f:	89 86 34 02 00 00    	mov    %eax,0x234(%esi)
80103755:	0f b6 44 0e 34       	movzbl 0x34(%esi,%ecx,1),%eax
8010375a:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010375d:	83 c3 01             	add    $0x1,%ebx
80103760:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80103763:	75 d3                	jne    80103738 <piperead+0x98>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103765:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
8010376b:	83 ec 0c             	sub    $0xc,%esp
8010376e:	50                   	push   %eax
8010376f:	e8 7c 09 00 00       	call   801040f0 <wakeup>
  release(&p->lock);
80103774:	89 34 24             	mov    %esi,(%esp)
80103777:	e8 44 11 00 00       	call   801048c0 <release>
  return i;
8010377c:	83 c4 10             	add    $0x10,%esp
}
8010377f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103782:	89 d8                	mov    %ebx,%eax
80103784:	5b                   	pop    %ebx
80103785:	5e                   	pop    %esi
80103786:	5f                   	pop    %edi
80103787:	5d                   	pop    %ebp
80103788:	c3                   	ret    
80103789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p->nread == p->nwrite)
80103790:	31 db                	xor    %ebx,%ebx
80103792:	eb d1                	jmp    80103765 <piperead+0xc5>
80103794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&p->lock);
80103798:	83 ec 0c             	sub    $0xc,%esp
      return -1;
8010379b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
801037a0:	56                   	push   %esi
801037a1:	e8 1a 11 00 00       	call   801048c0 <release>
      return -1;
801037a6:	83 c4 10             	add    $0x10,%esp
}
801037a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801037ac:	89 d8                	mov    %ebx,%eax
801037ae:	5b                   	pop    %ebx
801037af:	5e                   	pop    %esi
801037b0:	5f                   	pop    %edi
801037b1:	5d                   	pop    %ebp
801037b2:	c3                   	ret    
801037b3:	66 90                	xchg   %ax,%ax
801037b5:	66 90                	xchg   %ax,%ax
801037b7:	66 90                	xchg   %ax,%ax
801037b9:	66 90                	xchg   %ax,%ax
801037bb:	66 90                	xchg   %ax,%ax
801037bd:	66 90                	xchg   %ax,%ax
801037bf:	90                   	nop

801037c0 <allocproc>:
// as well as choose the cpu
static int getPtableIndex(){
  int i, ret;
  int min = NPROC + 1;
  for(i = 0;i < CPUNUMBER; ++i){
    if(ptable[i].amount < min){
801037c0:	a1 80 3a 11 80       	mov    0x80113a80,%eax
  int min = NPROC + 1;
801037c5:	ba 41 00 00 00       	mov    $0x41,%edx
// state required to run in the kernel.
// Otherwise return 0.
// Must hold ptable[0].lock.
static struct proc*
allocproc(void)
{
801037ca:	55                   	push   %ebp
801037cb:	89 e5                	mov    %esp,%ebp
801037cd:	56                   	push   %esi
801037ce:	53                   	push   %ebx
  int min = NPROC + 1;
801037cf:	83 f8 41             	cmp    $0x41,%eax
801037d2:	0f 4d c2             	cmovge %edx,%eax
    if(ptable[i].amount < min){
801037d5:	3b 05 b8 7a 11 80    	cmp    0x80117ab8,%eax
  for(i = 0;i < CPUNUMBER; ++i){
801037db:	0f 9f c0             	setg   %al
801037de:	0f b6 c0             	movzbl %al,%eax
801037e1:	89 c6                	mov    %eax,%esi
801037e3:	69 c0 38 40 00 00    	imul   $0x4038,%eax,%eax
  struct proc *p;
  char *sp;
  int ptableIndex = getPtableIndex();

  for(p = ptable[ptableIndex].proc; p < &ptable[ptableIndex].proc[NPROC]; p++)
801037e9:	8d 98 b8 3a 11 80    	lea    -0x7feec548(%eax),%ebx
801037ef:	05 b8 7a 11 80       	add    $0x80117ab8,%eax
801037f4:	39 c3                	cmp    %eax,%ebx
801037f6:	72 16                	jb     8010380e <allocproc+0x4e>
801037f8:	e9 bb 00 00 00       	jmp    801038b8 <allocproc+0xf8>
801037fd:	8d 76 00             	lea    0x0(%esi),%esi
80103800:	81 c3 00 01 00 00    	add    $0x100,%ebx
80103806:	39 c3                	cmp    %eax,%ebx
80103808:	0f 83 aa 00 00 00    	jae    801038b8 <allocproc+0xf8>
    if(p->state == UNUSED)
8010380e:	8b 53 0c             	mov    0xc(%ebx),%edx
80103811:	85 d2                	test   %edx,%edx
80103813:	75 eb                	jne    80103800 <allocproc+0x40>
      goto found;
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103815:	a1 08 b0 10 80       	mov    0x8010b008,%eax
  p->state = EMBRYO;
8010381a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103821:	8d 50 01             	lea    0x1(%eax),%edx
80103824:	89 43 10             	mov    %eax,0x10(%ebx)
80103827:	8d 83 84 00 00 00    	lea    0x84(%ebx),%eax
8010382d:	89 15 08 b0 10 80    	mov    %edx,0x8010b008
80103833:	8d 93 fc 00 00 00    	lea    0xfc(%ebx),%edx
80103839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  for (int i = 0; i < 10; ++i)
  {
    p->vm[i].next = -1;
80103840:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    p->vm[i].length = 0;
80103847:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010384d:	83 c0 0c             	add    $0xc,%eax
  for (int i = 0; i < 10; ++i)
80103850:	39 c2                	cmp    %eax,%edx
80103852:	75 ec                	jne    80103840 <allocproc+0x80>
  }
  p->vm[0].next = 0;
80103854:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
8010385b:	00 00 00 

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010385e:	e8 4d ec ff ff       	call   801024b0 <kalloc>
80103863:	85 c0                	test   %eax,%eax
80103865:	89 43 08             	mov    %eax,0x8(%ebx)
80103868:	74 59                	je     801038c3 <allocproc+0x103>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010386a:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
80103870:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103873:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103878:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint*)sp = (uint)trapret;
8010387b:	c7 40 14 7e 5c 10 80 	movl   $0x80105c7e,0x14(%eax)
  p->context = (struct context*)sp;
80103882:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103885:	6a 14                	push   $0x14
80103887:	6a 00                	push   $0x0
80103889:	50                   	push   %eax
8010388a:	e8 81 10 00 00       	call   80104910 <memset>
  p->context->eip = (uint)forkret;
8010388f:	8b 43 20             	mov    0x20(%ebx),%eax
  p->cpuid = ptableIndex;
  ptable[ptableIndex].amount += 1;

  return p;
80103892:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103895:	c7 40 10 d0 38 10 80 	movl   $0x801038d0,0x10(%eax)
  p->cpuid = ptableIndex;
8010389c:	89 73 14             	mov    %esi,0x14(%ebx)
}
8010389f:	89 d8                	mov    %ebx,%eax
  ptable[ptableIndex].amount += 1;
801038a1:	69 f6 38 40 00 00    	imul   $0x4038,%esi,%esi
801038a7:	83 86 80 3a 11 80 01 	addl   $0x1,-0x7feec580(%esi)
}
801038ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038b1:	5b                   	pop    %ebx
801038b2:	5e                   	pop    %esi
801038b3:	5d                   	pop    %ebp
801038b4:	c3                   	ret    
801038b5:	8d 76 00             	lea    0x0(%esi),%esi
  return 0;
801038b8:	31 db                	xor    %ebx,%ebx
}
801038ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038bd:	89 d8                	mov    %ebx,%eax
801038bf:	5b                   	pop    %ebx
801038c0:	5e                   	pop    %esi
801038c1:	5d                   	pop    %ebp
801038c2:	c3                   	ret    
    p->state = UNUSED;
801038c3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801038ca:	31 db                	xor    %ebx,%ebx
801038cc:	eb ec                	jmp    801038ba <allocproc+0xfa>
801038ce:	66 90                	xchg   %ax,%ax

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
  release(&ptable[0].lock);
801038d6:	68 84 3a 11 80       	push   $0x80113a84
801038db:	e8 e0 0f 00 00       	call   801048c0 <release>

  if (first) {
801038e0:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801038e5:	83 c4 10             	add    $0x10,%esp
801038e8:	85 c0                	test   %eax,%eax
801038ea:	75 04                	jne    801038f0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801038ec:	c9                   	leave  
801038ed:	c3                   	ret    
801038ee:	66 90                	xchg   %ax,%ax
    iinit(ROOTDEV);
801038f0:	83 ec 0c             	sub    $0xc,%esp
    first = 0;
801038f3:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
801038fa:	00 00 00 
    iinit(ROOTDEV);
801038fd:	6a 01                	push   $0x1
801038ff:	e8 3c db ff ff       	call   80101440 <iinit>
    initlog(ROOTDEV);
80103904:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010390b:	e8 70 f2 ff ff       	call   80102b80 <initlog>
80103910:	83 c4 10             	add    $0x10,%esp
}
80103913:	c9                   	leave  
80103914:	c3                   	ret    
80103915:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103919:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103920 <getcpuid>:
{
80103920:	55                   	push   %ebp
80103921:	89 e5                	mov    %esp,%ebp
}
80103923:	5d                   	pop    %ebp
  return cpunum();
80103924:	e9 f7 ed ff ff       	jmp    80102720 <cpunum>
80103929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103930 <pinit>:
{
80103930:	55                   	push   %ebp
80103931:	89 e5                	mov    %esp,%ebp
80103933:	83 ec 10             	sub    $0x10,%esp
    ptable[i].amount = 0;
80103936:	c7 05 80 3a 11 80 00 	movl   $0x0,0x80113a80
8010393d:	00 00 00 
    initlock(&ptable[i].lock, "ptable[i]");
80103940:	68 41 7b 10 80       	push   $0x80107b41
80103945:	68 84 3a 11 80       	push   $0x80113a84
8010394a:	e8 91 0d 00 00       	call   801046e0 <initlock>
8010394f:	58                   	pop    %eax
80103950:	5a                   	pop    %edx
80103951:	68 41 7b 10 80       	push   $0x80107b41
80103956:	68 bc 7a 11 80       	push   $0x80117abc
    ptable[i].amount = 0;
8010395b:	c7 05 b8 7a 11 80 00 	movl   $0x0,0x80117ab8
80103962:	00 00 00 
    initlock(&ptable[i].lock, "ptable[i]");
80103965:	e8 76 0d 00 00       	call   801046e0 <initlock>
}
8010396a:	83 c4 10             	add    $0x10,%esp
8010396d:	c9                   	leave  
8010396e:	c3                   	ret    
8010396f:	90                   	nop

80103970 <userinit>:
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	53                   	push   %ebx
80103974:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable[0].lock);
80103977:	68 84 3a 11 80       	push   $0x80113a84
8010397c:	e8 7f 0d 00 00       	call   80104700 <acquire>
  p = allocproc();
80103981:	e8 3a fe ff ff       	call   801037c0 <allocproc>
80103986:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103988:	a3 bc b5 10 80       	mov    %eax,0x8010b5bc
  if((p->pgdir = setupkvm()) == 0)
8010398d:	e8 7e 34 00 00       	call   80106e10 <setupkvm>
80103992:	83 c4 10             	add    $0x10,%esp
80103995:	85 c0                	test   %eax,%eax
80103997:	89 43 04             	mov    %eax,0x4(%ebx)
8010399a:	0f 84 b1 00 00 00    	je     80103a51 <userinit+0xe1>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801039a0:	83 ec 04             	sub    $0x4,%esp
801039a3:	68 2c 00 00 00       	push   $0x2c
801039a8:	68 60 b4 10 80       	push   $0x8010b460
801039ad:	50                   	push   %eax
801039ae:	e8 ad 35 00 00       	call   80106f60 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
801039b3:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
801039b6:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801039bc:	6a 4c                	push   $0x4c
801039be:	6a 00                	push   $0x0
801039c0:	ff 73 1c             	pushl  0x1c(%ebx)
801039c3:	e8 48 0f 00 00       	call   80104910 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801039c8:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039cb:	ba 23 00 00 00       	mov    $0x23,%edx
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801039d0:	b9 2b 00 00 00       	mov    $0x2b,%ecx
  safestrcpy(p->name, "initcode", sizeof(p->name));
801039d5:	83 c4 0c             	add    $0xc,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801039d8:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801039dc:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039df:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
801039e3:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039e6:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801039ea:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801039ee:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039f1:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801039f5:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801039f9:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039fc:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103a03:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a06:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103a0d:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a10:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a17:	8d 43 70             	lea    0x70(%ebx),%eax
80103a1a:	6a 10                	push   $0x10
80103a1c:	68 64 7b 10 80       	push   $0x80107b64
80103a21:	50                   	push   %eax
80103a22:	e8 c9 10 00 00       	call   80104af0 <safestrcpy>
  p->cwd = namei("/");
80103a27:	c7 04 24 6d 7b 10 80 	movl   $0x80107b6d,(%esp)
80103a2e:	e8 7d e4 ff ff       	call   80101eb0 <namei>
  p->state = RUNNABLE;
80103a33:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->cwd = namei("/");
80103a3a:	89 43 6c             	mov    %eax,0x6c(%ebx)
  release(&ptable[0].lock);
80103a3d:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
80103a44:	e8 77 0e 00 00       	call   801048c0 <release>
}
80103a49:	83 c4 10             	add    $0x10,%esp
80103a4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a4f:	c9                   	leave  
80103a50:	c3                   	ret    
    panic("userinit: out of memory?");
80103a51:	83 ec 0c             	sub    $0xc,%esp
80103a54:	68 4b 7b 10 80       	push   $0x80107b4b
80103a59:	e8 12 c9 ff ff       	call   80100370 <panic>
80103a5e:	66 90                	xchg   %ax,%ax

80103a60 <growproc>:
{
80103a60:	55                   	push   %ebp
80103a61:	89 e5                	mov    %esp,%ebp
80103a63:	83 ec 08             	sub    $0x8,%esp
  sz = proc->sz;
80103a66:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80103a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  sz = proc->sz;
80103a70:	8b 02                	mov    (%edx),%eax
  if(n > 0){
80103a72:	83 f9 00             	cmp    $0x0,%ecx
80103a75:	7f 21                	jg     80103a98 <growproc+0x38>
  } else if(n < 0){
80103a77:	75 47                	jne    80103ac0 <growproc+0x60>
  proc->sz = sz;
80103a79:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
80103a7b:	83 ec 0c             	sub    $0xc,%esp
80103a7e:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
80103a85:	e8 36 34 00 00       	call   80106ec0 <switchuvm>
  return 0;
80103a8a:	83 c4 10             	add    $0x10,%esp
80103a8d:	31 c0                	xor    %eax,%eax
}
80103a8f:	c9                   	leave  
80103a90:	c3                   	ret    
80103a91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80103a98:	83 ec 04             	sub    $0x4,%esp
80103a9b:	01 c1                	add    %eax,%ecx
80103a9d:	51                   	push   %ecx
80103a9e:	50                   	push   %eax
80103a9f:	ff 72 04             	pushl  0x4(%edx)
80103aa2:	e8 f9 35 00 00       	call   801070a0 <allocuvm>
80103aa7:	83 c4 10             	add    $0x10,%esp
80103aaa:	85 c0                	test   %eax,%eax
80103aac:	74 28                	je     80103ad6 <growproc+0x76>
80103aae:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103ab5:	eb c2                	jmp    80103a79 <growproc+0x19>
80103ab7:	89 f6                	mov    %esi,%esi
80103ab9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80103ac0:	83 ec 04             	sub    $0x4,%esp
80103ac3:	01 c1                	add    %eax,%ecx
80103ac5:	51                   	push   %ecx
80103ac6:	50                   	push   %eax
80103ac7:	ff 72 04             	pushl  0x4(%edx)
80103aca:	e8 71 37 00 00       	call   80107240 <deallocuvm>
80103acf:	83 c4 10             	add    $0x10,%esp
80103ad2:	85 c0                	test   %eax,%eax
80103ad4:	75 d8                	jne    80103aae <growproc+0x4e>
      return -1;
80103ad6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103adb:	c9                   	leave  
80103adc:	c3                   	ret    
80103add:	8d 76 00             	lea    0x0(%esi),%esi

80103ae0 <fork>:
{
80103ae0:	55                   	push   %ebp
80103ae1:	89 e5                	mov    %esp,%ebp
80103ae3:	57                   	push   %edi
80103ae4:	56                   	push   %esi
80103ae5:	53                   	push   %ebx
80103ae6:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable[0].lock);
80103ae9:	68 84 3a 11 80       	push   $0x80113a84
80103aee:	e8 0d 0c 00 00       	call   80104700 <acquire>
  if((np = allocproc()) == 0){
80103af3:	e8 c8 fc ff ff       	call   801037c0 <allocproc>
80103af8:	83 c4 10             	add    $0x10,%esp
80103afb:	85 c0                	test   %eax,%eax
80103afd:	0f 84 cd 00 00 00    	je     80103bd0 <fork+0xf0>
80103b03:	89 c3                	mov    %eax,%ebx
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80103b05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b0b:	83 ec 08             	sub    $0x8,%esp
80103b0e:	ff 30                	pushl  (%eax)
80103b10:	ff 70 04             	pushl  0x4(%eax)
80103b13:	e8 a8 38 00 00       	call   801073c0 <copyuvm>
80103b18:	83 c4 10             	add    $0x10,%esp
80103b1b:	85 c0                	test   %eax,%eax
80103b1d:	89 43 04             	mov    %eax,0x4(%ebx)
80103b20:	0f 84 c1 00 00 00    	je     80103be7 <fork+0x107>
  np->sz = proc->sz;
80103b26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  *np->tf = *proc->tf;
80103b2c:	8b 7b 1c             	mov    0x1c(%ebx),%edi
80103b2f:	b9 13 00 00 00       	mov    $0x13,%ecx
  np->sz = proc->sz;
80103b34:	8b 00                	mov    (%eax),%eax
80103b36:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
80103b38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b3e:	89 43 18             	mov    %eax,0x18(%ebx)
  *np->tf = *proc->tf;
80103b41:	8b 70 1c             	mov    0x1c(%eax),%esi
80103b44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103b46:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103b48:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103b4b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b52:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
80103b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(proc->ofile[i])
80103b60:	8b 44 b2 2c          	mov    0x2c(%edx,%esi,4),%eax
80103b64:	85 c0                	test   %eax,%eax
80103b66:	74 17                	je     80103b7f <fork+0x9f>
      np->ofile[i] = filedup(proc->ofile[i]);
80103b68:	83 ec 0c             	sub    $0xc,%esp
80103b6b:	50                   	push   %eax
80103b6c:	e8 4f d2 ff ff       	call   80100dc0 <filedup>
80103b71:	89 44 b3 2c          	mov    %eax,0x2c(%ebx,%esi,4)
80103b75:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b7c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
80103b7f:	83 c6 01             	add    $0x1,%esi
80103b82:	83 fe 10             	cmp    $0x10,%esi
80103b85:	75 d9                	jne    80103b60 <fork+0x80>
  np->cwd = idup(proc->cwd);
80103b87:	83 ec 0c             	sub    $0xc,%esp
80103b8a:	ff 72 6c             	pushl  0x6c(%edx)
80103b8d:	e8 4e da ff ff       	call   801015e0 <idup>
80103b92:	89 43 6c             	mov    %eax,0x6c(%ebx)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80103b95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b9b:	83 c4 0c             	add    $0xc,%esp
80103b9e:	6a 10                	push   $0x10
80103ba0:	83 c0 70             	add    $0x70,%eax
80103ba3:	50                   	push   %eax
80103ba4:	8d 43 70             	lea    0x70(%ebx),%eax
80103ba7:	50                   	push   %eax
80103ba8:	e8 43 0f 00 00       	call   80104af0 <safestrcpy>
  np->state = RUNNABLE;
80103bad:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  pid = np->pid;
80103bb4:	8b 73 10             	mov    0x10(%ebx),%esi
  release(&ptable[0].lock);
80103bb7:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
80103bbe:	e8 fd 0c 00 00       	call   801048c0 <release>
  return pid;
80103bc3:	83 c4 10             	add    $0x10,%esp
}
80103bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103bc9:	89 f0                	mov    %esi,%eax
80103bcb:	5b                   	pop    %ebx
80103bcc:	5e                   	pop    %esi
80103bcd:	5f                   	pop    %edi
80103bce:	5d                   	pop    %ebp
80103bcf:	c3                   	ret    
    release(&ptable[0].lock);
80103bd0:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80103bd3:	be ff ff ff ff       	mov    $0xffffffff,%esi
    release(&ptable[0].lock);
80103bd8:	68 84 3a 11 80       	push   $0x80113a84
80103bdd:	e8 de 0c 00 00       	call   801048c0 <release>
    return -1;
80103be2:	83 c4 10             	add    $0x10,%esp
80103be5:	eb df                	jmp    80103bc6 <fork+0xe6>
    kfree(np->kstack);
80103be7:	83 ec 0c             	sub    $0xc,%esp
80103bea:	ff 73 08             	pushl  0x8(%ebx)
    return -1;
80103bed:	be ff ff ff ff       	mov    $0xffffffff,%esi
    kfree(np->kstack);
80103bf2:	e8 09 e7 ff ff       	call   80102300 <kfree>
    np->kstack = 0;
80103bf7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103bfe:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    release(&ptable[0].lock);
80103c05:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
80103c0c:	e8 af 0c 00 00       	call   801048c0 <release>
    return -1;
80103c11:	83 c4 10             	add    $0x10,%esp
80103c14:	eb b0                	jmp    80103bc6 <fork+0xe6>
80103c16:	8d 76 00             	lea    0x0(%esi),%esi
80103c19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103c20 <scheduler>:
{
80103c20:	55                   	push   %ebp
80103c21:	89 e5                	mov    %esp,%ebp
80103c23:	57                   	push   %edi
80103c24:	56                   	push   %esi
80103c25:	53                   	push   %ebx
80103c26:	83 ec 1c             	sub    $0x1c,%esp
80103c29:	69 5d 08 38 40 00 00 	imul   $0x4038,0x8(%ebp),%ebx
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103c30:	8d 83 b8 3a 11 80    	lea    -0x7feec548(%ebx),%eax
    acquire(&ptable[cpuid].lock);
80103c36:	8d b3 84 3a 11 80    	lea    -0x7feec57c(%ebx),%esi
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103c3c:	81 c3 b8 7a 11 80    	add    $0x80117ab8,%ebx
80103c42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103c45:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103c48:	fb                   	sti    
    acquire(&ptable[cpuid].lock);
80103c49:	83 ec 0c             	sub    $0xc,%esp
80103c4c:	56                   	push   %esi
80103c4d:	e8 ae 0a 00 00       	call   80104700 <acquire>
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103c52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c55:	83 c4 10             	add    $0x10,%esp
80103c58:	39 d8                	cmp    %ebx,%eax
80103c5a:	73 58                	jae    80103cb4 <scheduler+0x94>
80103c5c:	89 c7                	mov    %eax,%edi
80103c5e:	66 90                	xchg   %ax,%ax
      if(p->state != RUNNABLE)
80103c60:	83 7f 0c 03          	cmpl   $0x3,0xc(%edi)
80103c64:	75 44                	jne    80103caa <scheduler+0x8a>
      switchuvm(p);
80103c66:	83 ec 0c             	sub    $0xc,%esp
      proc = p;
80103c69:	65 89 3d 04 00 00 00 	mov    %edi,%gs:0x4
      switchuvm(p);
80103c70:	57                   	push   %edi
80103c71:	e8 4a 32 00 00       	call   80106ec0 <switchuvm>
      p->cpuid = cpuid;
80103c76:	8b 45 08             	mov    0x8(%ebp),%eax
      p->state = RUNNING;
80103c79:	c7 47 0c 04 00 00 00 	movl   $0x4,0xc(%edi)
      p->cpuid = cpuid;
80103c80:	89 47 14             	mov    %eax,0x14(%edi)
      swtch(&cpu->scheduler, p->context);
80103c83:	58                   	pop    %eax
80103c84:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c8a:	5a                   	pop    %edx
80103c8b:	ff 77 20             	pushl  0x20(%edi)
80103c8e:	8d 50 04             	lea    0x4(%eax),%edx
80103c91:	52                   	push   %edx
80103c92:	e8 b4 0e 00 00       	call   80104b4b <swtch>
      switchkvm();
80103c97:	e8 04 32 00 00       	call   80106ea0 <switchkvm>
      proc = 0;
80103c9c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80103ca3:	00 00 00 00 
80103ca7:	83 c4 10             	add    $0x10,%esp
    for(p = ptable[cpuid].proc; p < &ptable[cpuid].proc[NPROC]; p++){
80103caa:	81 c7 00 01 00 00    	add    $0x100,%edi
80103cb0:	39 df                	cmp    %ebx,%edi
80103cb2:	72 ac                	jb     80103c60 <scheduler+0x40>
    release(&ptable[cpuid].lock);
80103cb4:	83 ec 0c             	sub    $0xc,%esp
80103cb7:	56                   	push   %esi
80103cb8:	e8 03 0c 00 00       	call   801048c0 <release>
    sti();
80103cbd:	83 c4 10             	add    $0x10,%esp
80103cc0:	eb 86                	jmp    80103c48 <scheduler+0x28>
80103cc2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103cd0 <sched>:
{
80103cd0:	55                   	push   %ebp
80103cd1:	89 e5                	mov    %esp,%ebp
80103cd3:	53                   	push   %ebx
80103cd4:	83 ec 10             	sub    $0x10,%esp
  if(!holding(&ptable[0].lock))
80103cd7:	68 84 3a 11 80       	push   $0x80113a84
80103cdc:	e8 2f 0b 00 00       	call   80104810 <holding>
80103ce1:	83 c4 10             	add    $0x10,%esp
80103ce4:	85 c0                	test   %eax,%eax
80103ce6:	74 4c                	je     80103d34 <sched+0x64>
  if(cpu->ncli != 1)
80103ce8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80103cef:	83 ba ac 00 00 00 01 	cmpl   $0x1,0xac(%edx)
80103cf6:	75 63                	jne    80103d5b <sched+0x8b>
  if(proc->state == RUNNING)
80103cf8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103cfe:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80103d02:	74 4a                	je     80103d4e <sched+0x7e>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d04:	9c                   	pushf  
80103d05:	59                   	pop    %ecx
  if(readeflags()&FL_IF)
80103d06:	80 e5 02             	and    $0x2,%ch
80103d09:	75 36                	jne    80103d41 <sched+0x71>
  swtch(&proc->context, cpu->scheduler);
80103d0b:	83 ec 08             	sub    $0x8,%esp
80103d0e:	83 c0 20             	add    $0x20,%eax
  intena = cpu->intena;
80103d11:	8b 9a b0 00 00 00    	mov    0xb0(%edx),%ebx
  swtch(&proc->context, cpu->scheduler);
80103d17:	ff 72 04             	pushl  0x4(%edx)
80103d1a:	50                   	push   %eax
80103d1b:	e8 2b 0e 00 00       	call   80104b4b <swtch>
  cpu->intena = intena;
80103d20:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
}
80103d26:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80103d29:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
80103d2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d32:	c9                   	leave  
80103d33:	c3                   	ret    
    panic("sched ptable[0].lock");
80103d34:	83 ec 0c             	sub    $0xc,%esp
80103d37:	68 6f 7b 10 80       	push   $0x80107b6f
80103d3c:	e8 2f c6 ff ff       	call   80100370 <panic>
    panic("sched interruptible");
80103d41:	83 ec 0c             	sub    $0xc,%esp
80103d44:	68 9e 7b 10 80       	push   $0x80107b9e
80103d49:	e8 22 c6 ff ff       	call   80100370 <panic>
    panic("sched running");
80103d4e:	83 ec 0c             	sub    $0xc,%esp
80103d51:	68 90 7b 10 80       	push   $0x80107b90
80103d56:	e8 15 c6 ff ff       	call   80100370 <panic>
    panic("sched locks");
80103d5b:	83 ec 0c             	sub    $0xc,%esp
80103d5e:	68 84 7b 10 80       	push   $0x80107b84
80103d63:	e8 08 c6 ff ff       	call   80100370 <panic>
80103d68:	90                   	nop
80103d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103d70 <exit>:
{
80103d70:	55                   	push   %ebp
  if(proc == initproc)
80103d71:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80103d78:	89 e5                	mov    %esp,%ebp
80103d7a:	56                   	push   %esi
80103d7b:	53                   	push   %ebx
80103d7c:	31 db                	xor    %ebx,%ebx
  if(proc == initproc)
80103d7e:	3b 15 bc b5 10 80    	cmp    0x8010b5bc,%edx
80103d84:	0f 84 5e 01 00 00    	je     80103ee8 <exit+0x178>
80103d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(proc->ofile[fd]){
80103d90:	8d 73 08             	lea    0x8(%ebx),%esi
80103d93:	8b 44 b2 0c          	mov    0xc(%edx,%esi,4),%eax
80103d97:	85 c0                	test   %eax,%eax
80103d99:	74 1b                	je     80103db6 <exit+0x46>
      fileclose(proc->ofile[fd]);
80103d9b:	83 ec 0c             	sub    $0xc,%esp
80103d9e:	50                   	push   %eax
80103d9f:	e8 6c d0 ff ff       	call   80100e10 <fileclose>
      proc->ofile[fd] = 0;
80103da4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103dab:	83 c4 10             	add    $0x10,%esp
80103dae:	c7 44 b2 0c 00 00 00 	movl   $0x0,0xc(%edx,%esi,4)
80103db5:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103db6:	83 c3 01             	add    $0x1,%ebx
80103db9:	83 fb 10             	cmp    $0x10,%ebx
80103dbc:	75 d2                	jne    80103d90 <exit+0x20>
  begin_op();
80103dbe:	e8 5d ee ff ff       	call   80102c20 <begin_op>
  iput(proc->cwd);
80103dc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103dc9:	83 ec 0c             	sub    $0xc,%esp
80103dcc:	ff 70 6c             	pushl  0x6c(%eax)
80103dcf:	e8 ac d9 ff ff       	call   80101780 <iput>
  end_op();
80103dd4:	e8 b7 ee ff ff       	call   80102c90 <end_op>
  proc->cwd = 0;
80103dd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ddf:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
  acquire(&ptable[0].lock);
80103de6:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
80103ded:	e8 0e 09 00 00       	call   80104700 <acquire>
  if(proc->parent == 0 && proc -> pthread!=0){
80103df2:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80103df9:	83 c4 10             	add    $0x10,%esp
80103dfc:	b8 b8 3a 11 80       	mov    $0x80113ab8,%eax
80103e01:	8b 53 18             	mov    0x18(%ebx),%edx
80103e04:	85 d2                	test   %edx,%edx
80103e06:	75 14                	jne    80103e1c <exit+0xac>
80103e08:	e9 a4 00 00 00       	jmp    80103eb1 <exit+0x141>
80103e0d:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++)
80103e10:	05 00 01 00 00       	add    $0x100,%eax
80103e15:	3d b8 7a 11 80       	cmp    $0x80117ab8,%eax
80103e1a:	73 1e                	jae    80103e3a <exit+0xca>
    if(p->state == SLEEPING && p->chan == chan)
80103e1c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103e20:	75 ee                	jne    80103e10 <exit+0xa0>
80103e22:	3b 50 24             	cmp    0x24(%eax),%edx
80103e25:	75 e9                	jne    80103e10 <exit+0xa0>
      p->state = RUNNABLE;
80103e27:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++)
80103e2e:	05 00 01 00 00       	add    $0x100,%eax
80103e33:	3d b8 7a 11 80       	cmp    $0x80117ab8,%eax
80103e38:	72 e2                	jb     80103e1c <exit+0xac>
      p->parent = initproc;
80103e3a:	8b 0d bc b5 10 80    	mov    0x8010b5bc,%ecx
80103e40:	ba b8 3a 11 80       	mov    $0x80113ab8,%edx
80103e45:	eb 17                	jmp    80103e5e <exit+0xee>
80103e47:	89 f6                	mov    %esi,%esi
80103e49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
80103e50:	81 c2 00 01 00 00    	add    $0x100,%edx
80103e56:	81 fa b8 7a 11 80    	cmp    $0x80117ab8,%edx
80103e5c:	73 3a                	jae    80103e98 <exit+0x128>
    if(p->parent == proc){
80103e5e:	3b 5a 18             	cmp    0x18(%edx),%ebx
80103e61:	75 ed                	jne    80103e50 <exit+0xe0>
      if(p->state == ZOMBIE)
80103e63:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
80103e67:	89 4a 18             	mov    %ecx,0x18(%edx)
      if(p->state == ZOMBIE)
80103e6a:	75 e4                	jne    80103e50 <exit+0xe0>
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++)
80103e6c:	b8 b8 3a 11 80       	mov    $0x80113ab8,%eax
80103e71:	eb 11                	jmp    80103e84 <exit+0x114>
80103e73:	90                   	nop
80103e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103e78:	05 00 01 00 00       	add    $0x100,%eax
80103e7d:	3d b8 7a 11 80       	cmp    $0x80117ab8,%eax
80103e82:	73 cc                	jae    80103e50 <exit+0xe0>
    if(p->state == SLEEPING && p->chan == chan)
80103e84:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103e88:	75 ee                	jne    80103e78 <exit+0x108>
80103e8a:	3b 48 24             	cmp    0x24(%eax),%ecx
80103e8d:	75 e9                	jne    80103e78 <exit+0x108>
      p->state = RUNNABLE;
80103e8f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103e96:	eb e0                	jmp    80103e78 <exit+0x108>
  proc->state = ZOMBIE;
80103e98:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
80103e9f:	e8 2c fe ff ff       	call   80103cd0 <sched>
  panic("zombie exit");
80103ea4:	83 ec 0c             	sub    $0xc,%esp
80103ea7:	68 bf 7b 10 80       	push   $0x80107bbf
80103eac:	e8 bf c4 ff ff       	call   80100370 <panic>
  if(proc->parent == 0 && proc -> pthread!=0){
80103eb1:	8b 8b f8 00 00 00    	mov    0xf8(%ebx),%ecx
80103eb7:	85 c9                	test   %ecx,%ecx
80103eb9:	75 25                	jne    80103ee0 <exit+0x170>
80103ebb:	e9 5c ff ff ff       	jmp    80103e1c <exit+0xac>
    if(p->state == SLEEPING && p->chan == chan)
80103ec0:	3b 48 24             	cmp    0x24(%eax),%ecx
80103ec3:	75 0b                	jne    80103ed0 <exit+0x160>
      p->state = RUNNABLE;
80103ec5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++)
80103ed0:	05 00 01 00 00       	add    $0x100,%eax
80103ed5:	3d b8 7a 11 80       	cmp    $0x80117ab8,%eax
80103eda:	0f 83 5a ff ff ff    	jae    80103e3a <exit+0xca>
    if(p->state == SLEEPING && p->chan == chan)
80103ee0:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103ee4:	75 ea                	jne    80103ed0 <exit+0x160>
80103ee6:	eb d8                	jmp    80103ec0 <exit+0x150>
    panic("init exiting");
80103ee8:	83 ec 0c             	sub    $0xc,%esp
80103eeb:	68 b2 7b 10 80       	push   $0x80107bb2
80103ef0:	e8 7b c4 ff ff       	call   80100370 <panic>
80103ef5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103ef9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103f00 <yield>:
{
80103f00:	55                   	push   %ebp
80103f01:	89 e5                	mov    %esp,%ebp
80103f03:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable[0].lock);  //DOC: yieldlock
80103f06:	68 84 3a 11 80       	push   $0x80113a84
80103f0b:	e8 f0 07 00 00       	call   80104700 <acquire>
  proc->state = RUNNABLE;
80103f10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f16:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103f1d:	e8 ae fd ff ff       	call   80103cd0 <sched>
  release(&ptable[0].lock);
80103f22:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
80103f29:	e8 92 09 00 00       	call   801048c0 <release>
}
80103f2e:	83 c4 10             	add    $0x10,%esp
80103f31:	c9                   	leave  
80103f32:	c3                   	ret    
80103f33:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103f40 <sleep>:
  if(proc == 0)
80103f40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80103f46:	55                   	push   %ebp
80103f47:	89 e5                	mov    %esp,%ebp
80103f49:	56                   	push   %esi
80103f4a:	53                   	push   %ebx
  if(proc == 0)
80103f4b:	85 c0                	test   %eax,%eax
{
80103f4d:	8b 75 08             	mov    0x8(%ebp),%esi
80103f50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
80103f53:	0f 84 97 00 00 00    	je     80103ff0 <sleep+0xb0>
  if(lk == 0)
80103f59:	85 db                	test   %ebx,%ebx
80103f5b:	0f 84 82 00 00 00    	je     80103fe3 <sleep+0xa3>
  if(lk != &ptable[0].lock){  //DOC: sleeplock0
80103f61:	81 fb 84 3a 11 80    	cmp    $0x80113a84,%ebx
80103f67:	74 57                	je     80103fc0 <sleep+0x80>
    acquire(&ptable[0].lock);  //DOC: sleeplock1
80103f69:	83 ec 0c             	sub    $0xc,%esp
80103f6c:	68 84 3a 11 80       	push   $0x80113a84
80103f71:	e8 8a 07 00 00       	call   80104700 <acquire>
    release(lk);
80103f76:	89 1c 24             	mov    %ebx,(%esp)
80103f79:	e8 42 09 00 00       	call   801048c0 <release>
  proc->chan = chan;
80103f7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f84:	89 70 24             	mov    %esi,0x24(%eax)
  proc->state = SLEEPING;
80103f87:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80103f8e:	e8 3d fd ff ff       	call   80103cd0 <sched>
  proc->chan = 0;
80103f93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f99:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
    release(&ptable[0].lock);
80103fa0:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
80103fa7:	e8 14 09 00 00       	call   801048c0 <release>
    acquire(lk);
80103fac:	89 5d 08             	mov    %ebx,0x8(%ebp)
80103faf:	83 c4 10             	add    $0x10,%esp
}
80103fb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fb5:	5b                   	pop    %ebx
80103fb6:	5e                   	pop    %esi
80103fb7:	5d                   	pop    %ebp
    acquire(lk);
80103fb8:	e9 43 07 00 00       	jmp    80104700 <acquire>
80103fbd:	8d 76 00             	lea    0x0(%esi),%esi
  proc->chan = chan;
80103fc0:	89 70 24             	mov    %esi,0x24(%eax)
  proc->state = SLEEPING;
80103fc3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80103fca:	e8 01 fd ff ff       	call   80103cd0 <sched>
  proc->chan = 0;
80103fcf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103fd5:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
}
80103fdc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fdf:	5b                   	pop    %ebx
80103fe0:	5e                   	pop    %esi
80103fe1:	5d                   	pop    %ebp
80103fe2:	c3                   	ret    
    panic("sleep without lk");
80103fe3:	83 ec 0c             	sub    $0xc,%esp
80103fe6:	68 d1 7b 10 80       	push   $0x80107bd1
80103feb:	e8 80 c3 ff ff       	call   80100370 <panic>
    panic("sleep");
80103ff0:	83 ec 0c             	sub    $0xc,%esp
80103ff3:	68 cb 7b 10 80       	push   $0x80107bcb
80103ff8:	e8 73 c3 ff ff       	call   80100370 <panic>
80103ffd:	8d 76 00             	lea    0x0(%esi),%esi

80104000 <wait>:
{
80104000:	55                   	push   %ebp
80104001:	89 e5                	mov    %esp,%ebp
80104003:	56                   	push   %esi
80104004:	53                   	push   %ebx
  acquire(&ptable[0].lock);
80104005:	83 ec 0c             	sub    $0xc,%esp
80104008:	68 84 3a 11 80       	push   $0x80113a84
8010400d:	e8 ee 06 00 00       	call   80104700 <acquire>
80104012:	83 c4 10             	add    $0x10,%esp
      if(p->parent != proc)
80104015:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    havekids = 0;
8010401b:	31 d2                	xor    %edx,%edx
    for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
8010401d:	bb b8 3a 11 80       	mov    $0x80113ab8,%ebx
80104022:	eb 12                	jmp    80104036 <wait+0x36>
80104024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104028:	81 c3 00 01 00 00    	add    $0x100,%ebx
8010402e:	81 fb b8 7a 11 80    	cmp    $0x80117ab8,%ebx
80104034:	73 1e                	jae    80104054 <wait+0x54>
      if(p->parent != proc)
80104036:	39 43 18             	cmp    %eax,0x18(%ebx)
80104039:	75 ed                	jne    80104028 <wait+0x28>
      if(p->state == ZOMBIE){
8010403b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010403f:	74 37                	je     80104078 <wait+0x78>
    for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
80104041:	81 c3 00 01 00 00    	add    $0x100,%ebx
      havekids = 1;
80104047:	ba 01 00 00 00       	mov    $0x1,%edx
    for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
8010404c:	81 fb b8 7a 11 80    	cmp    $0x80117ab8,%ebx
80104052:	72 e2                	jb     80104036 <wait+0x36>
    if(!havekids || proc->killed){
80104054:	85 d2                	test   %edx,%edx
80104056:	74 76                	je     801040ce <wait+0xce>
80104058:	8b 50 28             	mov    0x28(%eax),%edx
8010405b:	85 d2                	test   %edx,%edx
8010405d:	75 6f                	jne    801040ce <wait+0xce>
    sleep(proc, &ptable[0].lock);  //DOC: wait-sleep
8010405f:	83 ec 08             	sub    $0x8,%esp
80104062:	68 84 3a 11 80       	push   $0x80113a84
80104067:	50                   	push   %eax
80104068:	e8 d3 fe ff ff       	call   80103f40 <sleep>
    havekids = 0;
8010406d:	83 c4 10             	add    $0x10,%esp
80104070:	eb a3                	jmp    80104015 <wait+0x15>
80104072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        kfree(p->kstack);
80104078:	83 ec 0c             	sub    $0xc,%esp
8010407b:	ff 73 08             	pushl  0x8(%ebx)
        pid = p->pid;
8010407e:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104081:	e8 7a e2 ff ff       	call   80102300 <kfree>
        freevm(p->pgdir);
80104086:	59                   	pop    %ecx
80104087:	ff 73 04             	pushl  0x4(%ebx)
        p->kstack = 0;
8010408a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80104091:	e8 7a 32 00 00       	call   80107310 <freevm>
        release(&ptable[0].lock);
80104096:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
        p->pid = 0;
8010409d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801040a4:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->name[0] = 0;
801040ab:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
801040af:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        p->state = UNUSED;
801040b6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable[0].lock);
801040bd:	e8 fe 07 00 00       	call   801048c0 <release>
        return pid;
801040c2:	83 c4 10             	add    $0x10,%esp
}
801040c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040c8:	89 f0                	mov    %esi,%eax
801040ca:	5b                   	pop    %ebx
801040cb:	5e                   	pop    %esi
801040cc:	5d                   	pop    %ebp
801040cd:	c3                   	ret    
      release(&ptable[0].lock);
801040ce:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801040d1:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable[0].lock);
801040d6:	68 84 3a 11 80       	push   $0x80113a84
801040db:	e8 e0 07 00 00       	call   801048c0 <release>
      return -1;
801040e0:	83 c4 10             	add    $0x10,%esp
801040e3:	eb e0                	jmp    801040c5 <wait+0xc5>
801040e5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801040e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801040f0 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801040f0:	55                   	push   %ebp
801040f1:	89 e5                	mov    %esp,%ebp
801040f3:	53                   	push   %ebx
801040f4:	83 ec 10             	sub    $0x10,%esp
801040f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable[0].lock);
801040fa:	68 84 3a 11 80       	push   $0x80113a84
801040ff:	e8 fc 05 00 00       	call   80104700 <acquire>
80104104:	83 c4 10             	add    $0x10,%esp
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++)
80104107:	b8 b8 3a 11 80       	mov    $0x80113ab8,%eax
8010410c:	eb 0e                	jmp    8010411c <wakeup+0x2c>
8010410e:	66 90                	xchg   %ax,%ax
80104110:	05 00 01 00 00       	add    $0x100,%eax
80104115:	3d b8 7a 11 80       	cmp    $0x80117ab8,%eax
8010411a:	73 1e                	jae    8010413a <wakeup+0x4a>
    if(p->state == SLEEPING && p->chan == chan)
8010411c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104120:	75 ee                	jne    80104110 <wakeup+0x20>
80104122:	3b 58 24             	cmp    0x24(%eax),%ebx
80104125:	75 e9                	jne    80104110 <wakeup+0x20>
      p->state = RUNNABLE;
80104127:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++)
8010412e:	05 00 01 00 00       	add    $0x100,%eax
80104133:	3d b8 7a 11 80       	cmp    $0x80117ab8,%eax
80104138:	72 e2                	jb     8010411c <wakeup+0x2c>
  wakeup1(chan);
  release(&ptable[0].lock);
8010413a:	c7 45 08 84 3a 11 80 	movl   $0x80113a84,0x8(%ebp)
}
80104141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104144:	c9                   	leave  
  release(&ptable[0].lock);
80104145:	e9 76 07 00 00       	jmp    801048c0 <release>
8010414a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104150 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104150:	55                   	push   %ebp
80104151:	89 e5                	mov    %esp,%ebp
80104153:	53                   	push   %ebx
80104154:	83 ec 10             	sub    $0x10,%esp
80104157:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable[0].lock);
8010415a:	68 84 3a 11 80       	push   $0x80113a84
8010415f:	e8 9c 05 00 00       	call   80104700 <acquire>
80104164:	83 c4 10             	add    $0x10,%esp
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
80104167:	b8 b8 3a 11 80       	mov    $0x80113ab8,%eax
8010416c:	eb 0e                	jmp    8010417c <kill+0x2c>
8010416e:	66 90                	xchg   %ax,%ax
80104170:	05 00 01 00 00       	add    $0x100,%eax
80104175:	3d b8 7a 11 80       	cmp    $0x80117ab8,%eax
8010417a:	73 34                	jae    801041b0 <kill+0x60>
    if(p->pid == pid){
8010417c:	39 58 10             	cmp    %ebx,0x10(%eax)
8010417f:	75 ef                	jne    80104170 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104181:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
80104185:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      if(p->state == SLEEPING)
8010418c:	75 07                	jne    80104195 <kill+0x45>
        p->state = RUNNABLE;
8010418e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable[0].lock);
80104195:	83 ec 0c             	sub    $0xc,%esp
80104198:	68 84 3a 11 80       	push   $0x80113a84
8010419d:	e8 1e 07 00 00       	call   801048c0 <release>
      return 0;
801041a2:	83 c4 10             	add    $0x10,%esp
801041a5:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable[0].lock);
  return -1;
}
801041a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041aa:	c9                   	leave  
801041ab:	c3                   	ret    
801041ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable[0].lock);
801041b0:	83 ec 0c             	sub    $0xc,%esp
801041b3:	68 84 3a 11 80       	push   $0x80113a84
801041b8:	e8 03 07 00 00       	call   801048c0 <release>
  return -1;
801041bd:	83 c4 10             	add    $0x10,%esp
801041c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041c8:	c9                   	leave  
801041c9:	c3                   	ret    
801041ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801041d0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801041d0:	55                   	push   %ebp
801041d1:	89 e5                	mov    %esp,%ebp
801041d3:	57                   	push   %edi
801041d4:	56                   	push   %esi
801041d5:	53                   	push   %ebx
801041d6:	8d 75 e8             	lea    -0x18(%ebp),%esi
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
801041d9:	bb b8 3a 11 80       	mov    $0x80113ab8,%ebx
{
801041de:	83 ec 3c             	sub    $0x3c,%esp
801041e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p->state == UNUSED)
801041e8:	8b 43 0c             	mov    0xc(%ebx),%eax
801041eb:	85 c0                	test   %eax,%eax
801041ed:	0f 84 7f 00 00 00    	je     80104272 <procdump+0xa2>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801041f3:	83 f8 05             	cmp    $0x5,%eax
      state = states[p->state];
    else
      state = "???";
801041f6:	ba e2 7b 10 80       	mov    $0x80107be2,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801041fb:	77 11                	ja     8010420e <procdump+0x3e>
801041fd:	8b 14 85 a4 7c 10 80 	mov    -0x7fef835c(,%eax,4),%edx
      state = "???";
80104204:	b8 e2 7b 10 80       	mov    $0x80107be2,%eax
80104209:	85 d2                	test   %edx,%edx
8010420b:	0f 44 d0             	cmove  %eax,%edx
    cprintf("\npid:%d, state: %s, name: %s\n", p->pid, state, p->name);
8010420e:	8d 43 70             	lea    0x70(%ebx),%eax
80104211:	50                   	push   %eax
80104212:	52                   	push   %edx
80104213:	ff 73 10             	pushl  0x10(%ebx)
80104216:	68 e6 7b 10 80       	push   $0x80107be6
8010421b:	e8 20 c4 ff ff       	call   80100640 <cprintf>
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
80104220:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
80104226:	83 c4 10             	add    $0x10,%esp
80104229:	85 c0                	test   %eax,%eax
8010422b:	74 2f                	je     8010425c <procdump+0x8c>
8010422d:	8d 76 00             	lea    0x0(%esi),%esi
      cprintf("start: %d, length: %d\n",p->vm[i].start,p->vm[i].length);
80104230:	8d 04 40             	lea    (%eax,%eax,2),%eax
80104233:	83 ec 04             	sub    $0x4,%esp
80104236:	8d 3c 83             	lea    (%ebx,%eax,4),%edi
80104239:	ff b7 84 00 00 00    	pushl  0x84(%edi)
8010423f:	ff b7 80 00 00 00    	pushl  0x80(%edi)
80104245:	68 04 7c 10 80       	push   $0x80107c04
8010424a:	e8 f1 c3 ff ff       	call   80100640 <cprintf>
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
8010424f:	8b 87 88 00 00 00    	mov    0x88(%edi),%eax
80104255:	83 c4 10             	add    $0x10,%esp
80104258:	85 c0                	test   %eax,%eax
8010425a:	75 d4                	jne    80104230 <procdump+0x60>
    }
    if(p->state == SLEEPING){
8010425c:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80104260:	74 2e                	je     80104290 <procdump+0xc0>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104262:	83 ec 0c             	sub    $0xc,%esp
80104265:	68 34 7c 10 80       	push   $0x80107c34
8010426a:	e8 d1 c3 ff ff       	call   80100640 <cprintf>
8010426f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
80104272:	81 c3 00 01 00 00    	add    $0x100,%ebx
80104278:	81 fb b8 7a 11 80    	cmp    $0x80117ab8,%ebx
8010427e:	0f 82 64 ff ff ff    	jb     801041e8 <procdump+0x18>
  }
}
80104284:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104287:	5b                   	pop    %ebx
80104288:	5e                   	pop    %esi
80104289:	5f                   	pop    %edi
8010428a:	5d                   	pop    %ebp
8010428b:	c3                   	ret    
8010428c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104290:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104293:	83 ec 08             	sub    $0x8,%esp
80104296:	8d 7d c0             	lea    -0x40(%ebp),%edi
80104299:	50                   	push   %eax
8010429a:	8b 43 20             	mov    0x20(%ebx),%eax
8010429d:	8b 40 0c             	mov    0xc(%eax),%eax
801042a0:	83 c0 08             	add    $0x8,%eax
801042a3:	50                   	push   %eax
801042a4:	e8 17 05 00 00       	call   801047c0 <getcallerpcs>
801042a9:	83 c4 10             	add    $0x10,%esp
801042ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      for(i=0; i<10 && pc[i] != 0; i++)
801042b0:	8b 17                	mov    (%edi),%edx
801042b2:	85 d2                	test   %edx,%edx
801042b4:	74 ac                	je     80104262 <procdump+0x92>
        cprintf(" %p", pc[i]);
801042b6:	83 ec 08             	sub    $0x8,%esp
801042b9:	83 c7 04             	add    $0x4,%edi
801042bc:	52                   	push   %edx
801042bd:	68 c2 75 10 80       	push   $0x801075c2
801042c2:	e8 79 c3 ff ff       	call   80100640 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801042c7:	83 c4 10             	add    $0x10,%esp
801042ca:	39 f7                	cmp    %esi,%edi
801042cc:	75 e2                	jne    801042b0 <procdump+0xe0>
801042ce:	eb 92                	jmp    80104262 <procdump+0x92>

801042d0 <mygrowproc>:


int mygrowproc(int n){
801042d0:	55                   	push   %ebp
801042d1:	89 e5                	mov    %esp,%ebp
801042d3:	57                   	push   %edi
801042d4:	56                   	push   %esi
801042d5:	53                   	push   %ebx
801042d6:	83 ec 1c             	sub    $0x1c,%esp
  struct vma *vm = proc->vm;
801042d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  int start = proc->sz;
  int pre=0;
  int i,k;
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801042df:	8b b8 88 00 00 00    	mov    0x88(%eax),%edi
  struct vma *vm = proc->vm;
801042e5:	8d 88 80 00 00 00    	lea    0x80(%eax),%ecx
801042eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  int start = proc->sz;
801042ee:	8b 18                	mov    (%eax),%ebx
  struct vma *vm = proc->vm;
801042f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801042f3:	85 ff                	test   %edi,%edi
801042f5:	0f 84 d5 00 00 00    	je     801043d0 <mygrowproc+0x100>
  {
    if (start + n < vm[i].start)
801042fb:	8d 04 7f             	lea    (%edi,%edi,2),%eax
801042fe:	8d 14 81             	lea    (%ecx,%eax,4),%edx
80104301:	8b 45 08             	mov    0x8(%ebp),%eax
80104304:	8b 0a                	mov    (%edx),%ecx
80104306:	01 d8                	add    %ebx,%eax
80104308:	39 c8                	cmp    %ecx,%eax
8010430a:	7d 22                	jge    8010432e <mygrowproc+0x5e>
8010430c:	e9 cf 00 00 00       	jmp    801043e0 <mygrowproc+0x110>
80104311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104318:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010431b:	8d 14 40             	lea    (%eax,%eax,2),%edx
8010431e:	8d 14 96             	lea    (%esi,%edx,4),%edx
80104321:	8b 75 08             	mov    0x8(%ebp),%esi
80104324:	8b 0a                	mov    (%edx),%ecx
80104326:	01 de                	add    %ebx,%esi
80104328:	39 ce                	cmp    %ecx,%esi
8010432a:	7c 0e                	jl     8010433a <mygrowproc+0x6a>
8010432c:	89 c7                	mov    %eax,%edi
    {
      break;
    }
    start = vm[i].start + vm[i].length;
8010432e:	8b 5a 04             	mov    0x4(%edx),%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104331:	8b 42 08             	mov    0x8(%edx),%eax
    start = vm[i].start + vm[i].length;
80104334:	01 cb                	add    %ecx,%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104336:	85 c0                	test   %eax,%eax
80104338:	75 de                	jne    80104318 <mygrowproc+0x48>
8010433a:	8b 75 e0             	mov    -0x20(%ebp),%esi
8010433d:	b9 01 00 00 00       	mov    $0x1,%ecx
80104342:	8d 96 8c 00 00 00    	lea    0x8c(%esi),%edx
80104348:	90                   	nop
80104349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pre = i;
  }
  for(k = 1; k < 10; ++k){
    if(vm[k].next == -1){
80104350:	83 7a 08 ff          	cmpl   $0xffffffff,0x8(%edx)
80104354:	74 2a                	je     80104380 <mygrowproc+0xb0>
  for(k = 1; k < 10; ++k){
80104356:	83 c1 01             	add    $0x1,%ecx
80104359:	83 c2 0c             	add    $0xc,%edx
8010435c:	83 f9 0a             	cmp    $0xa,%ecx
8010435f:	75 ef                	jne    80104350 <mygrowproc+0x80>
      myallocuvm(proc->pgdir, start , start + n);
      switchuvm(proc);
      return start;
    }
  }
  switchuvm(proc);
80104361:	83 ec 0c             	sub    $0xc,%esp
80104364:	ff 75 e0             	pushl  -0x20(%ebp)
  return 0; 
80104367:	31 db                	xor    %ebx,%ebx
  switchuvm(proc);
80104369:	e8 52 2b 00 00       	call   80106ec0 <switchuvm>
  return 0; 
8010436e:	83 c4 10             	add    $0x10,%esp
}
80104371:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104374:	89 d8                	mov    %ebx,%eax
80104376:	5b                   	pop    %ebx
80104377:	5e                   	pop    %esi
80104378:	5f                   	pop    %edi
80104379:	5d                   	pop    %ebp
8010437a:	c3                   	ret    
8010437b:	90                   	nop
8010437c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      vm[k].next = i;
80104380:	89 42 08             	mov    %eax,0x8(%edx)
      vm[k].length = n;
80104383:	8b 45 08             	mov    0x8(%ebp),%eax
      myallocuvm(proc->pgdir, start , start + n);
80104386:	83 ec 04             	sub    $0x4,%esp
      vm[k].start = start;
80104389:	89 1a                	mov    %ebx,(%edx)
      vm[k].length = n;
8010438b:	89 42 04             	mov    %eax,0x4(%edx)
      vm[pre].next = k;
8010438e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
80104391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80104394:	89 4c 87 08          	mov    %ecx,0x8(%edi,%eax,4)
      myallocuvm(proc->pgdir, start , start + n);
80104398:	8b 45 08             	mov    0x8(%ebp),%eax
8010439b:	01 d8                	add    %ebx,%eax
8010439d:	50                   	push   %eax
8010439e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043a4:	53                   	push   %ebx
801043a5:	ff 70 04             	pushl  0x4(%eax)
801043a8:	e8 23 2e 00 00       	call   801071d0 <myallocuvm>
      switchuvm(proc);
801043ad:	58                   	pop    %eax
801043ae:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
801043b5:	e8 06 2b 00 00       	call   80106ec0 <switchuvm>
      return start;
801043ba:	83 c4 10             	add    $0x10,%esp
}
801043bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043c0:	89 d8                	mov    %ebx,%eax
801043c2:	5b                   	pop    %ebx
801043c3:	5e                   	pop    %esi
801043c4:	5f                   	pop    %edi
801043c5:	5d                   	pop    %ebp
801043c6:	c3                   	ret    
801043c7:	89 f6                	mov    %esi,%esi
801043c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801043d0:	31 c0                	xor    %eax,%eax
801043d2:	e9 63 ff ff ff       	jmp    8010433a <mygrowproc+0x6a>
801043d7:	89 f6                	mov    %esi,%esi
801043d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if (start + n < vm[i].start)
801043e0:	89 f8                	mov    %edi,%eax
  int pre=0;
801043e2:	31 ff                	xor    %edi,%edi
801043e4:	e9 51 ff ff ff       	jmp    8010433a <mygrowproc+0x6a>
801043e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801043f0 <myreduceproc>:

int myreduceproc(int start){
801043f0:	55                   	push   %ebp
801043f1:	89 e5                	mov    %esp,%ebp
801043f3:	57                   	push   %edi
801043f4:	56                   	push   %esi
801043f5:	53                   	push   %ebx
801043f6:	83 ec 0c             	sub    $0xc,%esp
  int prev=0;
  int i;
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
801043f9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
int myreduceproc(int start){
80104400:	8b 75 08             	mov    0x8(%ebp),%esi
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
80104403:	8b 9a 88 00 00 00    	mov    0x88(%edx),%ebx
80104409:	85 db                	test   %ebx,%ebx
8010440b:	74 2f                	je     8010443c <myreduceproc+0x4c>
      if(proc->vm[i].start == start){
8010440d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
80104410:	3b b4 82 80 00 00 00 	cmp    0x80(%edx,%eax,4),%esi
80104417:	75 15                	jne    8010442e <myreduceproc+0x3e>
80104419:	eb 45                	jmp    80104460 <myreduceproc+0x70>
8010441b:	90                   	nop
8010441c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104420:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
80104423:	39 b4 8a 80 00 00 00 	cmp    %esi,0x80(%edx,%ecx,4)
8010442a:	74 38                	je     80104464 <myreduceproc+0x74>
8010442c:	89 c3                	mov    %eax,%ebx
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
8010442e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
80104431:	8b 84 82 88 00 00 00 	mov    0x88(%edx,%eax,4),%eax
80104438:	85 c0                	test   %eax,%eax
8010443a:	75 e4                	jne    80104420 <myreduceproc+0x30>
        switchuvm(proc);
        return 0;
      }
      prev=i;
  }
  cprintf("warning: free vma at %x! \n",start);
8010443c:	83 ec 08             	sub    $0x8,%esp
8010443f:	56                   	push   %esi
80104440:	68 1b 7c 10 80       	push   $0x80107c1b
80104445:	e8 f6 c1 ff ff       	call   80100640 <cprintf>
  return -1;
8010444a:	83 c4 10             	add    $0x10,%esp
}
8010444d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80104450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104455:	5b                   	pop    %ebx
80104456:	5e                   	pop    %esi
80104457:	5f                   	pop    %edi
80104458:	5d                   	pop    %ebp
80104459:	c3                   	ret    
8010445a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(proc->vm[i].start == start){
80104460:	89 d8                	mov    %ebx,%eax
  int prev=0;
80104462:	31 db                	xor    %ebx,%ebx
        mydeallocuvm(proc->pgdir,start,start+proc->vm[i].length);
80104464:	8d 3c 40             	lea    (%eax,%eax,2),%edi
80104467:	83 ec 04             	sub    $0x4,%esp
8010446a:	c1 e7 02             	shl    $0x2,%edi
8010446d:	8b 84 3a 84 00 00 00 	mov    0x84(%edx,%edi,1),%eax
80104474:	01 f0                	add    %esi,%eax
80104476:	50                   	push   %eax
80104477:	56                   	push   %esi
80104478:	ff 72 04             	pushl  0x4(%edx)
8010447b:	e8 f0 2d 00 00       	call   80107270 <mydeallocuvm>
        proc->vm[prev].next = proc->vm[i].next;
80104480:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104486:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
80104489:	01 c7                	add    %eax,%edi
8010448b:	8b 8f 88 00 00 00    	mov    0x88(%edi),%ecx
80104491:	89 8c 90 88 00 00 00 	mov    %ecx,0x88(%eax,%edx,4)
        proc->vm[i].next=-1;
80104498:	c7 87 88 00 00 00 ff 	movl   $0xffffffff,0x88(%edi)
8010449f:	ff ff ff 
        switchuvm(proc);
801044a2:	89 04 24             	mov    %eax,(%esp)
801044a5:	e8 16 2a 00 00       	call   80106ec0 <switchuvm>
        return 0;
801044aa:	83 c4 10             	add    $0x10,%esp
}
801044ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
801044b0:	31 c0                	xor    %eax,%eax
}
801044b2:	5b                   	pop    %ebx
801044b3:	5e                   	pop    %esi
801044b4:	5f                   	pop    %edi
801044b5:	5d                   	pop    %ebp
801044b6:	c3                   	ret    
801044b7:	89 f6                	mov    %esi,%esi
801044b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801044c0 <clone>:

// malloc space for new stack then pass to clone
int clone(void(*fcn)(void*), void* arg, void* stack)
{
801044c0:	55                   	push   %ebp
801044c1:	89 e5                	mov    %esp,%ebp
801044c3:	57                   	push   %edi
801044c4:	56                   	push   %esi
801044c5:	53                   	push   %ebx
801044c6:	83 ec 24             	sub    $0x24,%esp
  cprintf("in clone, stack start addr = %p\n", stack);
801044c9:	ff 75 10             	pushl  0x10(%ebp)
801044cc:	68 80 7c 10 80       	push   $0x80107c80
801044d1:	e8 6a c1 ff ff       	call   80100640 <cprintf>
  struct proc *curproc = proc;  // 调用 clone 的进程
801044d6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801044dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  struct proc *np;

  // allocate a PCB
  if((np = allocproc()) == 0)
801044e0:	e8 db f2 ff ff       	call   801037c0 <allocproc>
801044e5:	83 c4 10             	add    $0x10,%esp
801044e8:	85 c0                	test   %eax,%eax
801044ea:	0f 84 e5 00 00 00    	je     801045d5 <clone+0x115>
   return -1; 
  
  // For clone, don't need to copy entire address space like fork
  np->pgdir = curproc->pgdir;  // 线程间公用页表
801044f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801044f3:	89 c3                	mov    %eax,%ebx
  np->sz = curproc->sz;
  np->pthread = curproc;       // exit 时唤醒用
  np->parent = 0;
  *np->tf = *curproc->tf;      // 继承 trapframe
801044f5:	b9 13 00 00 00       	mov    $0x13,%ecx
801044fa:	8b 7b 1c             	mov    0x1c(%ebx),%edi
  np->pgdir = curproc->pgdir;  // 线程间公用页表
801044fd:	8b 42 04             	mov    0x4(%edx),%eax
80104500:	89 43 04             	mov    %eax,0x4(%ebx)
  np->sz = curproc->sz;
80104503:	8b 02                	mov    (%edx),%eax
  np->pthread = curproc;       // exit 时唤醒用
80104505:	89 93 f8 00 00 00    	mov    %edx,0xf8(%ebx)
  np->parent = 0;
8010450b:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
  np->sz = curproc->sz;
80104512:	89 03                	mov    %eax,(%ebx)
  *np->tf = *curproc->tf;      // 继承 trapframe
80104514:	8b 72 1c             	mov    0x1c(%edx),%esi
80104517:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  int* sp = stack + 4096 - 8;

  // Clone may need to change other registers than ones seen in fork
  np->tf->eip = (int)fcn;
80104519:	8b 4d 08             	mov    0x8(%ebp),%ecx

  // setup new user stack and some pointers
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
  *sp = 0xffffffff;     // end of stack (fake return PC value)

  for(int i = 0; i < NOFILE; i++)
8010451c:	31 f6                	xor    %esi,%esi
8010451e:	89 d7                	mov    %edx,%edi
  np->tf->eip = (int)fcn;
80104520:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104523:	89 48 38             	mov    %ecx,0x38(%eax)
  int* sp = stack + 4096 - 8;
80104526:	8b 45 10             	mov    0x10(%ebp),%eax
  np->tf->esp = (int)sp;  // top of stack
80104529:	8b 4b 1c             	mov    0x1c(%ebx),%ecx
  int* sp = stack + 4096 - 8;
8010452c:	05 f8 0f 00 00       	add    $0xff8,%eax
  np->tf->esp = (int)sp;  // top of stack
80104531:	89 41 44             	mov    %eax,0x44(%ecx)
  np->tf->ebp = (int)sp;  // 栈帧指针 
80104534:	8b 4b 1c             	mov    0x1c(%ebx),%ecx
80104537:	89 41 08             	mov    %eax,0x8(%ecx)
  np->tf->eax = 0;    // Clear %eax so that clone returns 0 in the child
8010453a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
8010453d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  np->tf->eax = 0;    // Clear %eax so that clone returns 0 in the child
80104540:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
80104547:	8b 45 0c             	mov    0xc(%ebp),%eax
  *sp = 0xffffffff;     // end of stack (fake return PC value)
8010454a:	c7 81 f8 0f 00 00 ff 	movl   $0xffffffff,0xff8(%ecx)
80104551:	ff ff ff 
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
80104554:	89 81 fc 0f 00 00    	mov    %eax,0xffc(%ecx)
8010455a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[i])
80104560:	8b 44 b7 2c          	mov    0x2c(%edi,%esi,4),%eax
80104564:	85 c0                	test   %eax,%eax
80104566:	74 10                	je     80104578 <clone+0xb8>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104568:	83 ec 0c             	sub    $0xc,%esp
8010456b:	50                   	push   %eax
8010456c:	e8 4f c8 ff ff       	call   80100dc0 <filedup>
80104571:	83 c4 10             	add    $0x10,%esp
80104574:	89 44 b3 2c          	mov    %eax,0x2c(%ebx,%esi,4)
  for(int i = 0; i < NOFILE; i++)
80104578:	83 c6 01             	add    $0x1,%esi
8010457b:	83 fe 10             	cmp    $0x10,%esi
8010457e:	75 e0                	jne    80104560 <clone+0xa0>
  np->cwd = idup(curproc->cwd);
80104580:	83 ec 0c             	sub    $0xc,%esp
80104583:	ff 77 6c             	pushl  0x6c(%edi)
80104586:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80104589:	e8 52 d0 ff ff       	call   801015e0 <idup>

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010458e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  np->cwd = idup(curproc->cwd);
80104591:	89 43 6c             	mov    %eax,0x6c(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104594:	8d 43 70             	lea    0x70(%ebx),%eax
80104597:	83 c4 0c             	add    $0xc,%esp
8010459a:	6a 10                	push   $0x10
8010459c:	83 c2 70             	add    $0x70,%edx
8010459f:	52                   	push   %edx
801045a0:	50                   	push   %eax
801045a1:	e8 4a 05 00 00       	call   80104af0 <safestrcpy>
  
  int pid = np->pid;
801045a6:	8b 73 10             	mov    0x10(%ebx),%esi
  
  acquire(&ptable[0].lock);
801045a9:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
801045b0:	e8 4b 01 00 00       	call   80104700 <acquire>
  np->state = RUNNABLE;
801045b5:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable[0].lock);
801045bc:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
801045c3:	e8 f8 02 00 00       	call   801048c0 <release>
 
  // return the ID of the new thread
  return pid;
801045c8:	83 c4 10             	add    $0x10,%esp
}
801045cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045ce:	89 f0                	mov    %esi,%eax
801045d0:	5b                   	pop    %ebx
801045d1:	5e                   	pop    %esi
801045d2:	5f                   	pop    %edi
801045d3:	5d                   	pop    %ebp
801045d4:	c3                   	ret    
   return -1; 
801045d5:	be ff ff ff ff       	mov    $0xffffffff,%esi
801045da:	eb ef                	jmp    801045cb <clone+0x10b>
801045dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801045e0 <join>:

int join(void **stack)
{
801045e0:	55                   	push   %ebp
801045e1:	89 e5                	mov    %esp,%ebp
801045e3:	56                   	push   %esi
801045e4:	53                   	push   %ebx
  cprintf("in join, stack pointer = %p\n",*stack);
801045e5:	8b 45 08             	mov    0x8(%ebp),%eax
801045e8:	83 ec 08             	sub    $0x8,%esp
801045eb:	ff 30                	pushl  (%eax)
801045ed:	68 36 7c 10 80       	push   $0x80107c36
801045f2:	e8 49 c0 ff ff       	call   80100640 <cprintf>
  struct proc *curproc = proc;
  struct proc *p;
  int havekids;

  acquire(&ptable[0].lock);
801045f7:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
  struct proc *curproc = proc;
801045fe:	65 8b 35 04 00 00 00 	mov    %gs:0x4,%esi
  acquire(&ptable[0].lock);
80104605:	e8 f6 00 00 00       	call   80104700 <acquire>
8010460a:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010460d:	31 c0                	xor    %eax,%eax
    for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
8010460f:	bb b8 3a 11 80       	mov    $0x80113ab8,%ebx
80104614:	eb 18                	jmp    8010462e <join+0x4e>
80104616:	8d 76 00             	lea    0x0(%esi),%esi
80104619:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80104620:	81 c3 00 01 00 00    	add    $0x100,%ebx
80104626:	81 fb b8 7a 11 80    	cmp    $0x80117ab8,%ebx
8010462c:	73 21                	jae    8010464f <join+0x6f>
      if(p->pthread != curproc)
8010462e:	39 b3 f8 00 00 00    	cmp    %esi,0xf8(%ebx)
80104634:	75 ea                	jne    80104620 <join+0x40>
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
80104636:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010463a:	74 34                	je     80104670 <join+0x90>
    for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
8010463c:	81 c3 00 01 00 00    	add    $0x100,%ebx
      havekids = 1;
80104642:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable[0].proc; p < &ptable[0].proc[NPROC]; p++){
80104647:	81 fb b8 7a 11 80    	cmp    $0x80117ab8,%ebx
8010464d:	72 df                	jb     8010462e <join+0x4e>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010464f:	85 c0                	test   %eax,%eax
80104651:	74 74                	je     801046c7 <join+0xe7>
80104653:	8b 46 28             	mov    0x28(%esi),%eax
80104656:	85 c0                	test   %eax,%eax
80104658:	75 6d                	jne    801046c7 <join+0xe7>
      release(&ptable[0].lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable[0].lock);  //DOC: wait-sleep
8010465a:	83 ec 08             	sub    $0x8,%esp
8010465d:	68 84 3a 11 80       	push   $0x80113a84
80104662:	56                   	push   %esi
80104663:	e8 d8 f8 ff ff       	call   80103f40 <sleep>
    havekids = 0;
80104668:	83 c4 10             	add    $0x10,%esp
8010466b:	eb a0                	jmp    8010460d <join+0x2d>
8010466d:	8d 76 00             	lea    0x0(%esi),%esi
        kfree(p->kstack);
80104670:	83 ec 0c             	sub    $0xc,%esp
80104673:	ff 73 08             	pushl  0x8(%ebx)
        int pid = p->pid;
80104676:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104679:	e8 82 dc ff ff       	call   80102300 <kfree>
        release(&ptable[0].lock);
8010467e:	c7 04 24 84 3a 11 80 	movl   $0x80113a84,(%esp)
        p->kstack = 0;
80104685:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        p->state = UNUSED;
8010468c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
80104693:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010469a:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->pthread = 0;
801046a1:	c7 83 f8 00 00 00 00 	movl   $0x0,0xf8(%ebx)
801046a8:	00 00 00 
        p->name[0] = 0;
801046ab:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
801046af:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        release(&ptable[0].lock);
801046b6:	e8 05 02 00 00       	call   801048c0 <release>
        return pid;
801046bb:	83 c4 10             	add    $0x10,%esp
  }

  return 0;
}
801046be:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046c1:	89 f0                	mov    %esi,%eax
801046c3:	5b                   	pop    %ebx
801046c4:	5e                   	pop    %esi
801046c5:	5d                   	pop    %ebp
801046c6:	c3                   	ret    
      release(&ptable[0].lock);
801046c7:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801046ca:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable[0].lock);
801046cf:	68 84 3a 11 80       	push   $0x80113a84
801046d4:	e8 e7 01 00 00       	call   801048c0 <release>
      return -1;
801046d9:	83 c4 10             	add    $0x10,%esp
801046dc:	eb e0                	jmp    801046be <join+0xde>
801046de:	66 90                	xchg   %ax,%ax

801046e0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801046e0:	55                   	push   %ebp
801046e1:	89 e5                	mov    %esp,%ebp
801046e3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801046e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
801046e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
801046ef:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
801046f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801046f9:	5d                   	pop    %ebp
801046fa:	c3                   	ret    
801046fb:	90                   	nop
801046fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104700 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	53                   	push   %ebx
80104704:	83 ec 04             	sub    $0x4,%esp
80104707:	9c                   	pushf  
80104708:	5a                   	pop    %edx
  asm volatile("cli");
80104709:	fa                   	cli    
{
  int eflags;

  eflags = readeflags();
  cli();
  if(cpu->ncli == 0)
8010470a:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80104711:	8b 81 ac 00 00 00    	mov    0xac(%ecx),%eax
80104717:	85 c0                	test   %eax,%eax
80104719:	75 0c                	jne    80104727 <acquire+0x27>
    cpu->intena = eflags & FL_IF;
8010471b:	81 e2 00 02 00 00    	and    $0x200,%edx
80104721:	89 91 b0 00 00 00    	mov    %edx,0xb0(%ecx)
  if(holding(lk))
80104727:	8b 55 08             	mov    0x8(%ebp),%edx
  cpu->ncli += 1;
8010472a:	83 c0 01             	add    $0x1,%eax
8010472d:	89 81 ac 00 00 00    	mov    %eax,0xac(%ecx)
  return lock->locked && lock->cpu == cpu;
80104733:	8b 02                	mov    (%edx),%eax
80104735:	85 c0                	test   %eax,%eax
80104737:	74 05                	je     8010473e <acquire+0x3e>
80104739:	39 4a 08             	cmp    %ecx,0x8(%edx)
8010473c:	74 74                	je     801047b2 <acquire+0xb2>
  asm volatile("lock; xchgl %0, %1" :
8010473e:	b9 01 00 00 00       	mov    $0x1,%ecx
80104743:	90                   	nop
80104744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104748:	89 c8                	mov    %ecx,%eax
8010474a:	f0 87 02             	lock xchg %eax,(%edx)
  while(xchg(&lk->locked, 1) != 0)
8010474d:	85 c0                	test   %eax,%eax
8010474f:	75 f7                	jne    80104748 <acquire+0x48>
  __sync_synchronize();
80104751:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = cpu;
80104756:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104759:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  for(i = 0; i < 10; i++){
8010475f:	31 d2                	xor    %edx,%edx
  lk->cpu = cpu;
80104761:	89 41 08             	mov    %eax,0x8(%ecx)
  getcallerpcs(&lk, lk->pcs);
80104764:	83 c1 0c             	add    $0xc,%ecx
  ebp = (uint*)v - 2;
80104767:	89 e8                	mov    %ebp,%eax
80104769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104770:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104776:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010477c:	77 1a                	ja     80104798 <acquire+0x98>
    pcs[i] = ebp[1];     // saved %eip
8010477e:	8b 58 04             	mov    0x4(%eax),%ebx
80104781:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104784:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104787:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104789:	83 fa 0a             	cmp    $0xa,%edx
8010478c:	75 e2                	jne    80104770 <acquire+0x70>
}
8010478e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104791:	c9                   	leave  
80104792:	c3                   	ret    
80104793:	90                   	nop
80104794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104798:	8d 04 91             	lea    (%ecx,%edx,4),%eax
8010479b:	83 c1 28             	add    $0x28,%ecx
8010479e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
801047a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801047a6:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
801047a9:	39 c8                	cmp    %ecx,%eax
801047ab:	75 f3                	jne    801047a0 <acquire+0xa0>
}
801047ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047b0:	c9                   	leave  
801047b1:	c3                   	ret    
    panic("acquire");
801047b2:	83 ec 0c             	sub    $0xc,%esp
801047b5:	68 bc 7c 10 80       	push   $0x80107cbc
801047ba:	e8 b1 bb ff ff       	call   80100370 <panic>
801047bf:	90                   	nop

801047c0 <getcallerpcs>:
{
801047c0:	55                   	push   %ebp
  for(i = 0; i < 10; i++){
801047c1:	31 d2                	xor    %edx,%edx
{
801047c3:	89 e5                	mov    %esp,%ebp
801047c5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
801047c6:	8b 45 08             	mov    0x8(%ebp),%eax
{
801047c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
801047cc:	83 e8 08             	sub    $0x8,%eax
801047cf:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047d0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
801047d6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801047dc:	77 1a                	ja     801047f8 <getcallerpcs+0x38>
    pcs[i] = ebp[1];     // saved %eip
801047de:	8b 58 04             	mov    0x4(%eax),%ebx
801047e1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
801047e4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
801047e7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
801047e9:	83 fa 0a             	cmp    $0xa,%edx
801047ec:	75 e2                	jne    801047d0 <getcallerpcs+0x10>
}
801047ee:	5b                   	pop    %ebx
801047ef:	5d                   	pop    %ebp
801047f0:	c3                   	ret    
801047f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801047f8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
801047fb:	83 c1 28             	add    $0x28,%ecx
801047fe:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104800:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104806:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104809:	39 c1                	cmp    %eax,%ecx
8010480b:	75 f3                	jne    80104800 <getcallerpcs+0x40>
}
8010480d:	5b                   	pop    %ebx
8010480e:	5d                   	pop    %ebp
8010480f:	c3                   	ret    

80104810 <holding>:
{
80104810:	55                   	push   %ebp
80104811:	89 e5                	mov    %esp,%ebp
80104813:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
80104816:	8b 02                	mov    (%edx),%eax
80104818:	85 c0                	test   %eax,%eax
8010481a:	74 14                	je     80104830 <holding+0x20>
8010481c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104822:	39 42 08             	cmp    %eax,0x8(%edx)
}
80104825:	5d                   	pop    %ebp
  return lock->locked && lock->cpu == cpu;
80104826:	0f 94 c0             	sete   %al
80104829:	0f b6 c0             	movzbl %al,%eax
}
8010482c:	c3                   	ret    
8010482d:	8d 76 00             	lea    0x0(%esi),%esi
80104830:	31 c0                	xor    %eax,%eax
80104832:	5d                   	pop    %ebp
80104833:	c3                   	ret    
80104834:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010483a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104840 <pushcli>:
{
80104840:	55                   	push   %ebp
80104841:	89 e5                	mov    %esp,%ebp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104843:	9c                   	pushf  
80104844:	59                   	pop    %ecx
  asm volatile("cli");
80104845:	fa                   	cli    
  if(cpu->ncli == 0)
80104846:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010484d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104853:	85 c0                	test   %eax,%eax
80104855:	75 0c                	jne    80104863 <pushcli+0x23>
    cpu->intena = eflags & FL_IF;
80104857:	81 e1 00 02 00 00    	and    $0x200,%ecx
8010485d:	89 8a b0 00 00 00    	mov    %ecx,0xb0(%edx)
  cpu->ncli += 1;
80104863:	83 c0 01             	add    $0x1,%eax
80104866:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
}
8010486c:	5d                   	pop    %ebp
8010486d:	c3                   	ret    
8010486e:	66 90                	xchg   %ax,%ax

80104870 <popcli>:

void
popcli(void)
{
80104870:	55                   	push   %ebp
80104871:	89 e5                	mov    %esp,%ebp
80104873:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104876:	9c                   	pushf  
80104877:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104878:	f6 c4 02             	test   $0x2,%ah
8010487b:	75 2c                	jne    801048a9 <popcli+0x39>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
8010487d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104884:	83 aa ac 00 00 00 01 	subl   $0x1,0xac(%edx)
8010488b:	78 0f                	js     8010489c <popcli+0x2c>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
8010488d:	75 0b                	jne    8010489a <popcli+0x2a>
8010488f:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
80104895:	85 c0                	test   %eax,%eax
80104897:	74 01                	je     8010489a <popcli+0x2a>
  asm volatile("sti");
80104899:	fb                   	sti    
    sti();
}
8010489a:	c9                   	leave  
8010489b:	c3                   	ret    
    panic("popcli");
8010489c:	83 ec 0c             	sub    $0xc,%esp
8010489f:	68 db 7c 10 80       	push   $0x80107cdb
801048a4:	e8 c7 ba ff ff       	call   80100370 <panic>
    panic("popcli - interruptible");
801048a9:	83 ec 0c             	sub    $0xc,%esp
801048ac:	68 c4 7c 10 80       	push   $0x80107cc4
801048b1:	e8 ba ba ff ff       	call   80100370 <panic>
801048b6:	8d 76 00             	lea    0x0(%esi),%esi
801048b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801048c0 <release>:
{
801048c0:	55                   	push   %ebp
801048c1:	89 e5                	mov    %esp,%ebp
801048c3:	83 ec 08             	sub    $0x8,%esp
801048c6:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked && lock->cpu == cpu;
801048c9:	8b 10                	mov    (%eax),%edx
801048cb:	85 d2                	test   %edx,%edx
801048cd:	74 2b                	je     801048fa <release+0x3a>
801048cf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801048d6:	39 50 08             	cmp    %edx,0x8(%eax)
801048d9:	75 1f                	jne    801048fa <release+0x3a>
  lk->pcs[0] = 0;
801048db:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  __sync_synchronize();
801048e9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->locked = 0;
801048ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801048f4:	c9                   	leave  
  popcli();
801048f5:	e9 76 ff ff ff       	jmp    80104870 <popcli>
    panic("release");
801048fa:	83 ec 0c             	sub    $0xc,%esp
801048fd:	68 e2 7c 10 80       	push   $0x80107ce2
80104902:	e8 69 ba ff ff       	call   80100370 <panic>
80104907:	66 90                	xchg   %ax,%ax
80104909:	66 90                	xchg   %ax,%ax
8010490b:	66 90                	xchg   %ax,%ax
8010490d:	66 90                	xchg   %ax,%ax
8010490f:	90                   	nop

80104910 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104910:	55                   	push   %ebp
80104911:	89 e5                	mov    %esp,%ebp
80104913:	57                   	push   %edi
80104914:	53                   	push   %ebx
80104915:	8b 55 08             	mov    0x8(%ebp),%edx
80104918:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
8010491b:	f6 c2 03             	test   $0x3,%dl
8010491e:	75 05                	jne    80104925 <memset+0x15>
80104920:	f6 c1 03             	test   $0x3,%cl
80104923:	74 13                	je     80104938 <memset+0x28>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80104925:	89 d7                	mov    %edx,%edi
80104927:	8b 45 0c             	mov    0xc(%ebp),%eax
8010492a:	fc                   	cld    
8010492b:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
8010492d:	5b                   	pop    %ebx
8010492e:	89 d0                	mov    %edx,%eax
80104930:	5f                   	pop    %edi
80104931:	5d                   	pop    %ebp
80104932:	c3                   	ret    
80104933:	90                   	nop
80104934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c &= 0xFF;
80104938:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010493c:	c1 e9 02             	shr    $0x2,%ecx
8010493f:	89 f8                	mov    %edi,%eax
80104941:	89 fb                	mov    %edi,%ebx
80104943:	c1 e0 18             	shl    $0x18,%eax
80104946:	c1 e3 10             	shl    $0x10,%ebx
80104949:	09 d8                	or     %ebx,%eax
8010494b:	09 f8                	or     %edi,%eax
8010494d:	c1 e7 08             	shl    $0x8,%edi
80104950:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
80104952:	89 d7                	mov    %edx,%edi
80104954:	fc                   	cld    
80104955:	f3 ab                	rep stos %eax,%es:(%edi)
}
80104957:	5b                   	pop    %ebx
80104958:	89 d0                	mov    %edx,%eax
8010495a:	5f                   	pop    %edi
8010495b:	5d                   	pop    %ebp
8010495c:	c3                   	ret    
8010495d:	8d 76 00             	lea    0x0(%esi),%esi

80104960 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104960:	55                   	push   %ebp
80104961:	89 e5                	mov    %esp,%ebp
80104963:	57                   	push   %edi
80104964:	56                   	push   %esi
80104965:	53                   	push   %ebx
80104966:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104969:	8b 75 08             	mov    0x8(%ebp),%esi
8010496c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010496f:	85 db                	test   %ebx,%ebx
80104971:	74 29                	je     8010499c <memcmp+0x3c>
    if(*s1 != *s2)
80104973:	0f b6 16             	movzbl (%esi),%edx
80104976:	0f b6 0f             	movzbl (%edi),%ecx
80104979:	38 d1                	cmp    %dl,%cl
8010497b:	75 2b                	jne    801049a8 <memcmp+0x48>
8010497d:	b8 01 00 00 00       	mov    $0x1,%eax
80104982:	eb 14                	jmp    80104998 <memcmp+0x38>
80104984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104988:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
8010498c:	83 c0 01             	add    $0x1,%eax
8010498f:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
80104994:	38 ca                	cmp    %cl,%dl
80104996:	75 10                	jne    801049a8 <memcmp+0x48>
  while(n-- > 0){
80104998:	39 d8                	cmp    %ebx,%eax
8010499a:	75 ec                	jne    80104988 <memcmp+0x28>
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
8010499c:	5b                   	pop    %ebx
  return 0;
8010499d:	31 c0                	xor    %eax,%eax
}
8010499f:	5e                   	pop    %esi
801049a0:	5f                   	pop    %edi
801049a1:	5d                   	pop    %ebp
801049a2:	c3                   	ret    
801049a3:	90                   	nop
801049a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return *s1 - *s2;
801049a8:	0f b6 c2             	movzbl %dl,%eax
}
801049ab:	5b                   	pop    %ebx
      return *s1 - *s2;
801049ac:	29 c8                	sub    %ecx,%eax
}
801049ae:	5e                   	pop    %esi
801049af:	5f                   	pop    %edi
801049b0:	5d                   	pop    %ebp
801049b1:	c3                   	ret    
801049b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801049b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801049c0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801049c0:	55                   	push   %ebp
801049c1:	89 e5                	mov    %esp,%ebp
801049c3:	56                   	push   %esi
801049c4:	53                   	push   %ebx
801049c5:	8b 45 08             	mov    0x8(%ebp),%eax
801049c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801049cb:	8b 75 10             	mov    0x10(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801049ce:	39 c3                	cmp    %eax,%ebx
801049d0:	73 26                	jae    801049f8 <memmove+0x38>
801049d2:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
801049d5:	39 c8                	cmp    %ecx,%eax
801049d7:	73 1f                	jae    801049f8 <memmove+0x38>
    s += n;
    d += n;
    while(n-- > 0)
801049d9:	85 f6                	test   %esi,%esi
801049db:	8d 56 ff             	lea    -0x1(%esi),%edx
801049de:	74 0f                	je     801049ef <memmove+0x2f>
      *--d = *--s;
801049e0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
801049e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    while(n-- > 0)
801049e7:	83 ea 01             	sub    $0x1,%edx
801049ea:	83 fa ff             	cmp    $0xffffffff,%edx
801049ed:	75 f1                	jne    801049e0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
801049ef:	5b                   	pop    %ebx
801049f0:	5e                   	pop    %esi
801049f1:	5d                   	pop    %ebp
801049f2:	c3                   	ret    
801049f3:	90                   	nop
801049f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
801049f8:	31 d2                	xor    %edx,%edx
801049fa:	85 f6                	test   %esi,%esi
801049fc:	74 f1                	je     801049ef <memmove+0x2f>
801049fe:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80104a00:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104a04:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80104a07:	83 c2 01             	add    $0x1,%edx
    while(n-- > 0)
80104a0a:	39 d6                	cmp    %edx,%esi
80104a0c:	75 f2                	jne    80104a00 <memmove+0x40>
}
80104a0e:	5b                   	pop    %ebx
80104a0f:	5e                   	pop    %esi
80104a10:	5d                   	pop    %ebp
80104a11:	c3                   	ret    
80104a12:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104a20 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104a20:	55                   	push   %ebp
80104a21:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80104a23:	5d                   	pop    %ebp
  return memmove(dst, src, n);
80104a24:	eb 9a                	jmp    801049c0 <memmove>
80104a26:	8d 76 00             	lea    0x0(%esi),%esi
80104a29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104a30 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104a30:	55                   	push   %ebp
80104a31:	89 e5                	mov    %esp,%ebp
80104a33:	57                   	push   %edi
80104a34:	56                   	push   %esi
80104a35:	8b 7d 10             	mov    0x10(%ebp),%edi
80104a38:	53                   	push   %ebx
80104a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  while(n > 0 && *p && *p == *q)
80104a3f:	85 ff                	test   %edi,%edi
80104a41:	74 2f                	je     80104a72 <strncmp+0x42>
80104a43:	0f b6 01             	movzbl (%ecx),%eax
80104a46:	0f b6 1e             	movzbl (%esi),%ebx
80104a49:	84 c0                	test   %al,%al
80104a4b:	74 37                	je     80104a84 <strncmp+0x54>
80104a4d:	38 c3                	cmp    %al,%bl
80104a4f:	75 33                	jne    80104a84 <strncmp+0x54>
80104a51:	01 f7                	add    %esi,%edi
80104a53:	eb 13                	jmp    80104a68 <strncmp+0x38>
80104a55:	8d 76 00             	lea    0x0(%esi),%esi
80104a58:	0f b6 01             	movzbl (%ecx),%eax
80104a5b:	84 c0                	test   %al,%al
80104a5d:	74 21                	je     80104a80 <strncmp+0x50>
80104a5f:	0f b6 1a             	movzbl (%edx),%ebx
80104a62:	89 d6                	mov    %edx,%esi
80104a64:	38 d8                	cmp    %bl,%al
80104a66:	75 1c                	jne    80104a84 <strncmp+0x54>
    n--, p++, q++;
80104a68:	8d 56 01             	lea    0x1(%esi),%edx
80104a6b:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104a6e:	39 fa                	cmp    %edi,%edx
80104a70:	75 e6                	jne    80104a58 <strncmp+0x28>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
80104a72:	5b                   	pop    %ebx
    return 0;
80104a73:	31 c0                	xor    %eax,%eax
}
80104a75:	5e                   	pop    %esi
80104a76:	5f                   	pop    %edi
80104a77:	5d                   	pop    %ebp
80104a78:	c3                   	ret    
80104a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a80:	0f b6 5e 01          	movzbl 0x1(%esi),%ebx
  return (uchar)*p - (uchar)*q;
80104a84:	29 d8                	sub    %ebx,%eax
}
80104a86:	5b                   	pop    %ebx
80104a87:	5e                   	pop    %esi
80104a88:	5f                   	pop    %edi
80104a89:	5d                   	pop    %ebp
80104a8a:	c3                   	ret    
80104a8b:	90                   	nop
80104a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104a90 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104a90:	55                   	push   %ebp
80104a91:	89 e5                	mov    %esp,%ebp
80104a93:	56                   	push   %esi
80104a94:	53                   	push   %ebx
80104a95:	8b 45 08             	mov    0x8(%ebp),%eax
80104a98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104a9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104a9e:	89 c2                	mov    %eax,%edx
80104aa0:	eb 19                	jmp    80104abb <strncpy+0x2b>
80104aa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104aa8:	83 c3 01             	add    $0x1,%ebx
80104aab:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
80104aaf:	83 c2 01             	add    $0x1,%edx
80104ab2:	84 c9                	test   %cl,%cl
80104ab4:	88 4a ff             	mov    %cl,-0x1(%edx)
80104ab7:	74 09                	je     80104ac2 <strncpy+0x32>
80104ab9:	89 f1                	mov    %esi,%ecx
80104abb:	85 c9                	test   %ecx,%ecx
80104abd:	8d 71 ff             	lea    -0x1(%ecx),%esi
80104ac0:	7f e6                	jg     80104aa8 <strncpy+0x18>
    ;
  while(n-- > 0)
80104ac2:	31 c9                	xor    %ecx,%ecx
80104ac4:	85 f6                	test   %esi,%esi
80104ac6:	7e 17                	jle    80104adf <strncpy+0x4f>
80104ac8:	90                   	nop
80104ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104ad0:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
80104ad4:	89 f3                	mov    %esi,%ebx
80104ad6:	83 c1 01             	add    $0x1,%ecx
80104ad9:	29 cb                	sub    %ecx,%ebx
  while(n-- > 0)
80104adb:	85 db                	test   %ebx,%ebx
80104add:	7f f1                	jg     80104ad0 <strncpy+0x40>
  return os;
}
80104adf:	5b                   	pop    %ebx
80104ae0:	5e                   	pop    %esi
80104ae1:	5d                   	pop    %ebp
80104ae2:	c3                   	ret    
80104ae3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104ae9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104af0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104af0:	55                   	push   %ebp
80104af1:	89 e5                	mov    %esp,%ebp
80104af3:	56                   	push   %esi
80104af4:	53                   	push   %ebx
80104af5:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104af8:	8b 45 08             	mov    0x8(%ebp),%eax
80104afb:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104afe:	85 c9                	test   %ecx,%ecx
80104b00:	7e 26                	jle    80104b28 <safestrcpy+0x38>
80104b02:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
80104b06:	89 c1                	mov    %eax,%ecx
80104b08:	eb 17                	jmp    80104b21 <safestrcpy+0x31>
80104b0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104b10:	83 c2 01             	add    $0x1,%edx
80104b13:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
80104b17:	83 c1 01             	add    $0x1,%ecx
80104b1a:	84 db                	test   %bl,%bl
80104b1c:	88 59 ff             	mov    %bl,-0x1(%ecx)
80104b1f:	74 04                	je     80104b25 <safestrcpy+0x35>
80104b21:	39 f2                	cmp    %esi,%edx
80104b23:	75 eb                	jne    80104b10 <safestrcpy+0x20>
    ;
  *s = 0;
80104b25:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104b28:	5b                   	pop    %ebx
80104b29:	5e                   	pop    %esi
80104b2a:	5d                   	pop    %ebp
80104b2b:	c3                   	ret    
80104b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104b30 <strlen>:

int
strlen(const char *s)
{
80104b30:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104b31:	31 c0                	xor    %eax,%eax
{
80104b33:	89 e5                	mov    %esp,%ebp
80104b35:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104b38:	80 3a 00             	cmpb   $0x0,(%edx)
80104b3b:	74 0c                	je     80104b49 <strlen+0x19>
80104b3d:	8d 76 00             	lea    0x0(%esi),%esi
80104b40:	83 c0 01             	add    $0x1,%eax
80104b43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104b47:	75 f7                	jne    80104b40 <strlen+0x10>
    ;
  return n;
}
80104b49:	5d                   	pop    %ebp
80104b4a:	c3                   	ret    

80104b4b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104b4b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104b4f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104b53:	55                   	push   %ebp
  pushl %ebx
80104b54:	53                   	push   %ebx
  pushl %esi
80104b55:	56                   	push   %esi
  pushl %edi
80104b56:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104b57:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104b59:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104b5b:	5f                   	pop    %edi
  popl %esi
80104b5c:	5e                   	pop    %esi
  popl %ebx
80104b5d:	5b                   	pop    %ebx
  popl %ebp
80104b5e:	5d                   	pop    %ebp
  ret
80104b5f:	c3                   	ret    

80104b60 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104b60:	55                   	push   %ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80104b61:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80104b68:	89 e5                	mov    %esp,%ebp
80104b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  if(addr >= proc->sz || addr+4 > proc->sz)
80104b6d:	8b 12                	mov    (%edx),%edx
80104b6f:	39 c2                	cmp    %eax,%edx
80104b71:	76 15                	jbe    80104b88 <fetchint+0x28>
80104b73:	8d 48 04             	lea    0x4(%eax),%ecx
80104b76:	39 ca                	cmp    %ecx,%edx
80104b78:	72 0e                	jb     80104b88 <fetchint+0x28>
    return -1;
  *ip = *(int*)(addr);
80104b7a:	8b 10                	mov    (%eax),%edx
80104b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b7f:	89 10                	mov    %edx,(%eax)
  return 0;
80104b81:	31 c0                	xor    %eax,%eax
}
80104b83:	5d                   	pop    %ebp
80104b84:	c3                   	ret    
80104b85:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b8d:	5d                   	pop    %ebp
80104b8e:	c3                   	ret    
80104b8f:	90                   	nop

80104b90 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104b90:	55                   	push   %ebp
  char *s, *ep;

  if(addr >= proc->sz)
80104b91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80104b97:	89 e5                	mov    %esp,%ebp
80104b99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz)
80104b9c:	39 08                	cmp    %ecx,(%eax)
80104b9e:	76 2c                	jbe    80104bcc <fetchstr+0x3c>
    return -1;
  *pp = (char*)addr;
80104ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ba3:	89 c8                	mov    %ecx,%eax
80104ba5:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
80104ba7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bae:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
80104bb0:	39 d1                	cmp    %edx,%ecx
80104bb2:	73 18                	jae    80104bcc <fetchstr+0x3c>
    if(*s == 0)
80104bb4:	80 39 00             	cmpb   $0x0,(%ecx)
80104bb7:	75 0c                	jne    80104bc5 <fetchstr+0x35>
80104bb9:	eb 25                	jmp    80104be0 <fetchstr+0x50>
80104bbb:	90                   	nop
80104bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104bc0:	80 38 00             	cmpb   $0x0,(%eax)
80104bc3:	74 13                	je     80104bd8 <fetchstr+0x48>
  for(s = *pp; s < ep; s++)
80104bc5:	83 c0 01             	add    $0x1,%eax
80104bc8:	39 c2                	cmp    %eax,%edx
80104bca:	77 f4                	ja     80104bc0 <fetchstr+0x30>
    return -1;
80104bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return s - *pp;
  return -1;
}
80104bd1:	5d                   	pop    %ebp
80104bd2:	c3                   	ret    
80104bd3:	90                   	nop
80104bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104bd8:	29 c8                	sub    %ecx,%eax
80104bda:	5d                   	pop    %ebp
80104bdb:	c3                   	ret    
80104bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
80104be0:	31 c0                	xor    %eax,%eax
}
80104be2:	5d                   	pop    %ebp
80104be3:	c3                   	ret    
80104be4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104bea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104bf0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104bf0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80104bf7:	55                   	push   %ebp
80104bf8:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104bfa:	8b 42 1c             	mov    0x1c(%edx),%eax
80104bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104c00:	8b 12                	mov    (%edx),%edx
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104c02:	8b 40 44             	mov    0x44(%eax),%eax
80104c05:	8d 04 88             	lea    (%eax,%ecx,4),%eax
80104c08:	8d 48 04             	lea    0x4(%eax),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104c0b:	39 d1                	cmp    %edx,%ecx
80104c0d:	73 19                	jae    80104c28 <argint+0x38>
80104c0f:	8d 48 08             	lea    0x8(%eax),%ecx
80104c12:	39 ca                	cmp    %ecx,%edx
80104c14:	72 12                	jb     80104c28 <argint+0x38>
  *ip = *(int*)(addr);
80104c16:	8b 50 04             	mov    0x4(%eax),%edx
80104c19:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c1c:	89 10                	mov    %edx,(%eax)
  return 0;
80104c1e:	31 c0                	xor    %eax,%eax
}
80104c20:	5d                   	pop    %ebp
80104c21:	c3                   	ret    
80104c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104c28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c2d:	5d                   	pop    %ebp
80104c2e:	c3                   	ret    
80104c2f:	90                   	nop

80104c30 <argptr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104c30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104c36:	55                   	push   %ebp
80104c37:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104c39:	8b 50 1c             	mov    0x1c(%eax),%edx
80104c3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104c3f:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104c41:	8b 52 44             	mov    0x44(%edx),%edx
80104c44:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
80104c47:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104c4a:	39 c1                	cmp    %eax,%ecx
80104c4c:	73 22                	jae    80104c70 <argptr+0x40>
80104c4e:	8d 4a 08             	lea    0x8(%edx),%ecx
80104c51:	39 c8                	cmp    %ecx,%eax
80104c53:	72 1b                	jb     80104c70 <argptr+0x40>
  *ip = *(int*)(addr);
80104c55:	8b 52 04             	mov    0x4(%edx),%edx
  int i;

  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80104c58:	39 c2                	cmp    %eax,%edx
80104c5a:	73 14                	jae    80104c70 <argptr+0x40>
80104c5c:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104c5f:	01 d1                	add    %edx,%ecx
80104c61:	39 c1                	cmp    %eax,%ecx
80104c63:	77 0b                	ja     80104c70 <argptr+0x40>
    return -1;
  *pp = (char*)i;
80104c65:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c68:	89 10                	mov    %edx,(%eax)
  return 0;
80104c6a:	31 c0                	xor    %eax,%eax
}
80104c6c:	5d                   	pop    %ebp
80104c6d:	c3                   	ret    
80104c6e:	66 90                	xchg   %ax,%ax
    return -1;
80104c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c75:	5d                   	pop    %ebp
80104c76:	c3                   	ret    
80104c77:	89 f6                	mov    %esi,%esi
80104c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104c80 <argstr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104c80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104c86:	55                   	push   %ebp
80104c87:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104c89:	8b 50 1c             	mov    0x1c(%eax),%edx
80104c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104c8f:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80104c91:	8b 52 44             	mov    0x44(%edx),%edx
80104c94:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
80104c97:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80104c9a:	39 c1                	cmp    %eax,%ecx
80104c9c:	73 3e                	jae    80104cdc <argstr+0x5c>
80104c9e:	8d 4a 08             	lea    0x8(%edx),%ecx
80104ca1:	39 c8                	cmp    %ecx,%eax
80104ca3:	72 37                	jb     80104cdc <argstr+0x5c>
  *ip = *(int*)(addr);
80104ca5:	8b 4a 04             	mov    0x4(%edx),%ecx
  if(addr >= proc->sz)
80104ca8:	39 c1                	cmp    %eax,%ecx
80104caa:	73 30                	jae    80104cdc <argstr+0x5c>
  *pp = (char*)addr;
80104cac:	8b 55 0c             	mov    0xc(%ebp),%edx
80104caf:	89 c8                	mov    %ecx,%eax
80104cb1:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
80104cb3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cba:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
80104cbc:	39 d1                	cmp    %edx,%ecx
80104cbe:	73 1c                	jae    80104cdc <argstr+0x5c>
    if(*s == 0)
80104cc0:	80 39 00             	cmpb   $0x0,(%ecx)
80104cc3:	75 10                	jne    80104cd5 <argstr+0x55>
80104cc5:	eb 29                	jmp    80104cf0 <argstr+0x70>
80104cc7:	89 f6                	mov    %esi,%esi
80104cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80104cd0:	80 38 00             	cmpb   $0x0,(%eax)
80104cd3:	74 13                	je     80104ce8 <argstr+0x68>
  for(s = *pp; s < ep; s++)
80104cd5:	83 c0 01             	add    $0x1,%eax
80104cd8:	39 c2                	cmp    %eax,%edx
80104cda:	77 f4                	ja     80104cd0 <argstr+0x50>
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
80104cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchstr(addr, pp);
}
80104ce1:	5d                   	pop    %ebp
80104ce2:	c3                   	ret    
80104ce3:	90                   	nop
80104ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104ce8:	29 c8                	sub    %ecx,%eax
80104cea:	5d                   	pop    %ebp
80104ceb:	c3                   	ret    
80104cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
80104cf0:	31 c0                	xor    %eax,%eax
}
80104cf2:	5d                   	pop    %ebp
80104cf3:	c3                   	ret    
80104cf4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104cfa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104d00 <syscall>:
[SYS_join]      sys_join,
};

void
syscall(void)
{
80104d00:	55                   	push   %ebp
80104d01:	89 e5                	mov    %esp,%ebp
80104d03:	83 ec 08             	sub    $0x8,%esp
  int num;

  num = proc->tf->eax;
80104d06:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d0d:	8b 42 1c             	mov    0x1c(%edx),%eax
80104d10:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104d13:	8d 48 ff             	lea    -0x1(%eax),%ecx
80104d16:	83 f9 19             	cmp    $0x19,%ecx
80104d19:	77 25                	ja     80104d40 <syscall+0x40>
80104d1b:	8b 0c 85 20 7d 10 80 	mov    -0x7fef82e0(,%eax,4),%ecx
80104d22:	85 c9                	test   %ecx,%ecx
80104d24:	74 1a                	je     80104d40 <syscall+0x40>
    proc->tf->eax = syscalls[num]();
80104d26:	ff d1                	call   *%ecx
80104d28:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d2f:	8b 52 1c             	mov    0x1c(%edx),%edx
80104d32:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
80104d35:	c9                   	leave  
80104d36:	c3                   	ret    
80104d37:	89 f6                	mov    %esi,%esi
80104d39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    cprintf("%d %s: unknown sys call %d\n",
80104d40:	50                   	push   %eax
            proc->pid, proc->name, num);
80104d41:	8d 42 70             	lea    0x70(%edx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104d44:	50                   	push   %eax
80104d45:	ff 72 10             	pushl  0x10(%edx)
80104d48:	68 ea 7c 10 80       	push   $0x80107cea
80104d4d:	e8 ee b8 ff ff       	call   80100640 <cprintf>
    proc->tf->eax = -1;
80104d52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d58:	83 c4 10             	add    $0x10,%esp
80104d5b:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d5e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80104d65:	c9                   	leave  
80104d66:	c3                   	ret    
80104d67:	66 90                	xchg   %ax,%ax
80104d69:	66 90                	xchg   %ax,%ax
80104d6b:	66 90                	xchg   %ax,%ax
80104d6d:	66 90                	xchg   %ax,%ax
80104d6f:	90                   	nop

80104d70 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104d70:	55                   	push   %ebp
80104d71:	89 e5                	mov    %esp,%ebp
80104d73:	57                   	push   %edi
80104d74:	56                   	push   %esi
80104d75:	53                   	push   %ebx
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104d76:	8d 75 da             	lea    -0x26(%ebp),%esi
{
80104d79:	83 ec 44             	sub    $0x44,%esp
80104d7c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104d7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80104d82:	56                   	push   %esi
80104d83:	50                   	push   %eax
{
80104d84:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104d87:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80104d8a:	e8 41 d1 ff ff       	call   80101ed0 <nameiparent>
80104d8f:	83 c4 10             	add    $0x10,%esp
80104d92:	85 c0                	test   %eax,%eax
80104d94:	0f 84 46 01 00 00    	je     80104ee0 <create+0x170>
    return 0;
  ilock(dp);
80104d9a:	83 ec 0c             	sub    $0xc,%esp
80104d9d:	89 c3                	mov    %eax,%ebx
80104d9f:	50                   	push   %eax
80104da0:	e8 6b c8 ff ff       	call   80101610 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104da5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80104da8:	83 c4 0c             	add    $0xc,%esp
80104dab:	50                   	push   %eax
80104dac:	56                   	push   %esi
80104dad:	53                   	push   %ebx
80104dae:	e8 cd cd ff ff       	call   80101b80 <dirlookup>
80104db3:	83 c4 10             	add    $0x10,%esp
80104db6:	85 c0                	test   %eax,%eax
80104db8:	89 c7                	mov    %eax,%edi
80104dba:	74 34                	je     80104df0 <create+0x80>
    iunlockput(dp);
80104dbc:	83 ec 0c             	sub    $0xc,%esp
80104dbf:	53                   	push   %ebx
80104dc0:	e8 1b cb ff ff       	call   801018e0 <iunlockput>
    ilock(ip);
80104dc5:	89 3c 24             	mov    %edi,(%esp)
80104dc8:	e8 43 c8 ff ff       	call   80101610 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104dcd:	83 c4 10             	add    $0x10,%esp
80104dd0:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104dd5:	0f 85 95 00 00 00    	jne    80104e70 <create+0x100>
80104ddb:	66 83 7f 10 02       	cmpw   $0x2,0x10(%edi)
80104de0:	0f 85 8a 00 00 00    	jne    80104e70 <create+0x100>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104de9:	89 f8                	mov    %edi,%eax
80104deb:	5b                   	pop    %ebx
80104dec:	5e                   	pop    %esi
80104ded:	5f                   	pop    %edi
80104dee:	5d                   	pop    %ebp
80104def:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104df0:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104df4:	83 ec 08             	sub    $0x8,%esp
80104df7:	50                   	push   %eax
80104df8:	ff 33                	pushl  (%ebx)
80104dfa:	e8 a1 c6 ff ff       	call   801014a0 <ialloc>
80104dff:	83 c4 10             	add    $0x10,%esp
80104e02:	85 c0                	test   %eax,%eax
80104e04:	89 c7                	mov    %eax,%edi
80104e06:	0f 84 e8 00 00 00    	je     80104ef4 <create+0x184>
  ilock(ip);
80104e0c:	83 ec 0c             	sub    $0xc,%esp
80104e0f:	50                   	push   %eax
80104e10:	e8 fb c7 ff ff       	call   80101610 <ilock>
  ip->major = major;
80104e15:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104e19:	66 89 47 12          	mov    %ax,0x12(%edi)
  ip->minor = minor;
80104e1d:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
80104e21:	66 89 47 14          	mov    %ax,0x14(%edi)
  ip->nlink = 1;
80104e25:	b8 01 00 00 00       	mov    $0x1,%eax
80104e2a:	66 89 47 16          	mov    %ax,0x16(%edi)
  iupdate(ip);
80104e2e:	89 3c 24             	mov    %edi,(%esp)
80104e31:	e8 2a c7 ff ff       	call   80101560 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104e36:	83 c4 10             	add    $0x10,%esp
80104e39:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104e3e:	74 50                	je     80104e90 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80104e40:	83 ec 04             	sub    $0x4,%esp
80104e43:	ff 77 04             	pushl  0x4(%edi)
80104e46:	56                   	push   %esi
80104e47:	53                   	push   %ebx
80104e48:	e8 a3 cf ff ff       	call   80101df0 <dirlink>
80104e4d:	83 c4 10             	add    $0x10,%esp
80104e50:	85 c0                	test   %eax,%eax
80104e52:	0f 88 8f 00 00 00    	js     80104ee7 <create+0x177>
  iunlockput(dp);
80104e58:	83 ec 0c             	sub    $0xc,%esp
80104e5b:	53                   	push   %ebx
80104e5c:	e8 7f ca ff ff       	call   801018e0 <iunlockput>
  return ip;
80104e61:	83 c4 10             	add    $0x10,%esp
}
80104e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e67:	89 f8                	mov    %edi,%eax
80104e69:	5b                   	pop    %ebx
80104e6a:	5e                   	pop    %esi
80104e6b:	5f                   	pop    %edi
80104e6c:	5d                   	pop    %ebp
80104e6d:	c3                   	ret    
80104e6e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80104e70:	83 ec 0c             	sub    $0xc,%esp
80104e73:	57                   	push   %edi
    return 0;
80104e74:	31 ff                	xor    %edi,%edi
    iunlockput(ip);
80104e76:	e8 65 ca ff ff       	call   801018e0 <iunlockput>
    return 0;
80104e7b:	83 c4 10             	add    $0x10,%esp
}
80104e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e81:	89 f8                	mov    %edi,%eax
80104e83:	5b                   	pop    %ebx
80104e84:	5e                   	pop    %esi
80104e85:	5f                   	pop    %edi
80104e86:	5d                   	pop    %ebp
80104e87:	c3                   	ret    
80104e88:	90                   	nop
80104e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink++;  // for ".."
80104e90:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
    iupdate(dp);
80104e95:	83 ec 0c             	sub    $0xc,%esp
80104e98:	53                   	push   %ebx
80104e99:	e8 c2 c6 ff ff       	call   80101560 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104e9e:	83 c4 0c             	add    $0xc,%esp
80104ea1:	ff 77 04             	pushl  0x4(%edi)
80104ea4:	68 a8 7d 10 80       	push   $0x80107da8
80104ea9:	57                   	push   %edi
80104eaa:	e8 41 cf ff ff       	call   80101df0 <dirlink>
80104eaf:	83 c4 10             	add    $0x10,%esp
80104eb2:	85 c0                	test   %eax,%eax
80104eb4:	78 1c                	js     80104ed2 <create+0x162>
80104eb6:	83 ec 04             	sub    $0x4,%esp
80104eb9:	ff 73 04             	pushl  0x4(%ebx)
80104ebc:	68 a7 7d 10 80       	push   $0x80107da7
80104ec1:	57                   	push   %edi
80104ec2:	e8 29 cf ff ff       	call   80101df0 <dirlink>
80104ec7:	83 c4 10             	add    $0x10,%esp
80104eca:	85 c0                	test   %eax,%eax
80104ecc:	0f 89 6e ff ff ff    	jns    80104e40 <create+0xd0>
      panic("create dots");
80104ed2:	83 ec 0c             	sub    $0xc,%esp
80104ed5:	68 9b 7d 10 80       	push   $0x80107d9b
80104eda:	e8 91 b4 ff ff       	call   80100370 <panic>
80104edf:	90                   	nop
    return 0;
80104ee0:	31 ff                	xor    %edi,%edi
80104ee2:	e9 ff fe ff ff       	jmp    80104de6 <create+0x76>
    panic("create: dirlink");
80104ee7:	83 ec 0c             	sub    $0xc,%esp
80104eea:	68 aa 7d 10 80       	push   $0x80107daa
80104eef:	e8 7c b4 ff ff       	call   80100370 <panic>
    panic("create: ialloc");
80104ef4:	83 ec 0c             	sub    $0xc,%esp
80104ef7:	68 8c 7d 10 80       	push   $0x80107d8c
80104efc:	e8 6f b4 ff ff       	call   80100370 <panic>
80104f01:	eb 0d                	jmp    80104f10 <argfd.constprop.0>
80104f03:	90                   	nop
80104f04:	90                   	nop
80104f05:	90                   	nop
80104f06:	90                   	nop
80104f07:	90                   	nop
80104f08:	90                   	nop
80104f09:	90                   	nop
80104f0a:	90                   	nop
80104f0b:	90                   	nop
80104f0c:	90                   	nop
80104f0d:	90                   	nop
80104f0e:	90                   	nop
80104f0f:	90                   	nop

80104f10 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
80104f10:	55                   	push   %ebp
80104f11:	89 e5                	mov    %esp,%ebp
80104f13:	56                   	push   %esi
80104f14:	53                   	push   %ebx
80104f15:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
80104f17:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
80104f1a:	89 d6                	mov    %edx,%esi
80104f1c:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104f1f:	50                   	push   %eax
80104f20:	6a 00                	push   $0x0
80104f22:	e8 c9 fc ff ff       	call   80104bf0 <argint>
80104f27:	83 c4 10             	add    $0x10,%esp
80104f2a:	85 c0                	test   %eax,%eax
80104f2c:	78 32                	js     80104f60 <argfd.constprop.0+0x50>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80104f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f31:	83 f8 0f             	cmp    $0xf,%eax
80104f34:	77 2a                	ja     80104f60 <argfd.constprop.0+0x50>
80104f36:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f3d:	8b 4c 82 2c          	mov    0x2c(%edx,%eax,4),%ecx
80104f41:	85 c9                	test   %ecx,%ecx
80104f43:	74 1b                	je     80104f60 <argfd.constprop.0+0x50>
  if(pfd)
80104f45:	85 db                	test   %ebx,%ebx
80104f47:	74 02                	je     80104f4b <argfd.constprop.0+0x3b>
    *pfd = fd;
80104f49:	89 03                	mov    %eax,(%ebx)
    *pf = f;
80104f4b:	89 0e                	mov    %ecx,(%esi)
  return 0;
80104f4d:	31 c0                	xor    %eax,%eax
}
80104f4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104f52:	5b                   	pop    %ebx
80104f53:	5e                   	pop    %esi
80104f54:	5d                   	pop    %ebp
80104f55:	c3                   	ret    
80104f56:	8d 76 00             	lea    0x0(%esi),%esi
80104f59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80104f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f65:	eb e8                	jmp    80104f4f <argfd.constprop.0+0x3f>
80104f67:	89 f6                	mov    %esi,%esi
80104f69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104f70 <sys_dup>:
{
80104f70:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
80104f71:	31 c0                	xor    %eax,%eax
{
80104f73:	89 e5                	mov    %esp,%ebp
80104f75:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
80104f76:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
80104f79:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
80104f7c:	e8 8f ff ff ff       	call   80104f10 <argfd.constprop.0>
80104f81:	85 c0                	test   %eax,%eax
80104f83:	78 3b                	js     80104fc0 <sys_dup+0x50>
  if((fd=fdalloc(f)) < 0)
80104f85:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if(proc->ofile[fd] == 0){
80104f88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  for(fd = 0; fd < NOFILE; fd++){
80104f8e:	31 db                	xor    %ebx,%ebx
80104f90:	eb 0e                	jmp    80104fa0 <sys_dup+0x30>
80104f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104f98:	83 c3 01             	add    $0x1,%ebx
80104f9b:	83 fb 10             	cmp    $0x10,%ebx
80104f9e:	74 20                	je     80104fc0 <sys_dup+0x50>
    if(proc->ofile[fd] == 0){
80104fa0:	8b 4c 98 2c          	mov    0x2c(%eax,%ebx,4),%ecx
80104fa4:	85 c9                	test   %ecx,%ecx
80104fa6:	75 f0                	jne    80104f98 <sys_dup+0x28>
  filedup(f);
80104fa8:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
80104fab:	89 54 98 2c          	mov    %edx,0x2c(%eax,%ebx,4)
  filedup(f);
80104faf:	52                   	push   %edx
80104fb0:	e8 0b be ff ff       	call   80100dc0 <filedup>
}
80104fb5:	89 d8                	mov    %ebx,%eax
  return fd;
80104fb7:	83 c4 10             	add    $0x10,%esp
}
80104fba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104fbd:	c9                   	leave  
80104fbe:	c3                   	ret    
80104fbf:	90                   	nop
    return -1;
80104fc0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80104fc5:	89 d8                	mov    %ebx,%eax
80104fc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104fca:	c9                   	leave  
80104fcb:	c3                   	ret    
80104fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104fd0 <sys_read>:
{
80104fd0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104fd1:	31 c0                	xor    %eax,%eax
{
80104fd3:	89 e5                	mov    %esp,%ebp
80104fd5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104fd8:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104fdb:	e8 30 ff ff ff       	call   80104f10 <argfd.constprop.0>
80104fe0:	85 c0                	test   %eax,%eax
80104fe2:	78 4c                	js     80105030 <sys_read+0x60>
80104fe4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fe7:	83 ec 08             	sub    $0x8,%esp
80104fea:	50                   	push   %eax
80104feb:	6a 02                	push   $0x2
80104fed:	e8 fe fb ff ff       	call   80104bf0 <argint>
80104ff2:	83 c4 10             	add    $0x10,%esp
80104ff5:	85 c0                	test   %eax,%eax
80104ff7:	78 37                	js     80105030 <sys_read+0x60>
80104ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ffc:	83 ec 04             	sub    $0x4,%esp
80104fff:	ff 75 f0             	pushl  -0x10(%ebp)
80105002:	50                   	push   %eax
80105003:	6a 01                	push   $0x1
80105005:	e8 26 fc ff ff       	call   80104c30 <argptr>
8010500a:	83 c4 10             	add    $0x10,%esp
8010500d:	85 c0                	test   %eax,%eax
8010500f:	78 1f                	js     80105030 <sys_read+0x60>
  return fileread(f, p, n);
80105011:	83 ec 04             	sub    $0x4,%esp
80105014:	ff 75 f0             	pushl  -0x10(%ebp)
80105017:	ff 75 f4             	pushl  -0xc(%ebp)
8010501a:	ff 75 ec             	pushl  -0x14(%ebp)
8010501d:	e8 0e bf ff ff       	call   80100f30 <fileread>
80105022:	83 c4 10             	add    $0x10,%esp
}
80105025:	c9                   	leave  
80105026:	c3                   	ret    
80105027:	89 f6                	mov    %esi,%esi
80105029:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105035:	c9                   	leave  
80105036:	c3                   	ret    
80105037:	89 f6                	mov    %esi,%esi
80105039:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105040 <sys_write>:
{
80105040:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105041:	31 c0                	xor    %eax,%eax
{
80105043:	89 e5                	mov    %esp,%ebp
80105045:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105048:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010504b:	e8 c0 fe ff ff       	call   80104f10 <argfd.constprop.0>
80105050:	85 c0                	test   %eax,%eax
80105052:	78 4c                	js     801050a0 <sys_write+0x60>
80105054:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105057:	83 ec 08             	sub    $0x8,%esp
8010505a:	50                   	push   %eax
8010505b:	6a 02                	push   $0x2
8010505d:	e8 8e fb ff ff       	call   80104bf0 <argint>
80105062:	83 c4 10             	add    $0x10,%esp
80105065:	85 c0                	test   %eax,%eax
80105067:	78 37                	js     801050a0 <sys_write+0x60>
80105069:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010506c:	83 ec 04             	sub    $0x4,%esp
8010506f:	ff 75 f0             	pushl  -0x10(%ebp)
80105072:	50                   	push   %eax
80105073:	6a 01                	push   $0x1
80105075:	e8 b6 fb ff ff       	call   80104c30 <argptr>
8010507a:	83 c4 10             	add    $0x10,%esp
8010507d:	85 c0                	test   %eax,%eax
8010507f:	78 1f                	js     801050a0 <sys_write+0x60>
  return filewrite(f, p, n);
80105081:	83 ec 04             	sub    $0x4,%esp
80105084:	ff 75 f0             	pushl  -0x10(%ebp)
80105087:	ff 75 f4             	pushl  -0xc(%ebp)
8010508a:	ff 75 ec             	pushl  -0x14(%ebp)
8010508d:	e8 2e bf ff ff       	call   80100fc0 <filewrite>
80105092:	83 c4 10             	add    $0x10,%esp
}
80105095:	c9                   	leave  
80105096:	c3                   	ret    
80105097:	89 f6                	mov    %esi,%esi
80105099:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
801050a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050a5:	c9                   	leave  
801050a6:	c3                   	ret    
801050a7:	89 f6                	mov    %esi,%esi
801050a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801050b0 <sys_close>:
{
801050b0:	55                   	push   %ebp
801050b1:	89 e5                	mov    %esp,%ebp
801050b3:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801050b6:	8d 55 f4             	lea    -0xc(%ebp),%edx
801050b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050bc:	e8 4f fe ff ff       	call   80104f10 <argfd.constprop.0>
801050c1:	85 c0                	test   %eax,%eax
801050c3:	78 2b                	js     801050f0 <sys_close+0x40>
  proc->ofile[fd] = 0;
801050c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
801050ce:	83 ec 0c             	sub    $0xc,%esp
  proc->ofile[fd] = 0;
801050d1:	c7 44 90 2c 00 00 00 	movl   $0x0,0x2c(%eax,%edx,4)
801050d8:	00 
  fileclose(f);
801050d9:	ff 75 f4             	pushl  -0xc(%ebp)
801050dc:	e8 2f bd ff ff       	call   80100e10 <fileclose>
  return 0;
801050e1:	83 c4 10             	add    $0x10,%esp
801050e4:	31 c0                	xor    %eax,%eax
}
801050e6:	c9                   	leave  
801050e7:	c3                   	ret    
801050e8:	90                   	nop
801050e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801050f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050f5:	c9                   	leave  
801050f6:	c3                   	ret    
801050f7:	89 f6                	mov    %esi,%esi
801050f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105100 <sys_fstat>:
{
80105100:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105101:	31 c0                	xor    %eax,%eax
{
80105103:	89 e5                	mov    %esp,%ebp
80105105:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105108:	8d 55 f0             	lea    -0x10(%ebp),%edx
8010510b:	e8 00 fe ff ff       	call   80104f10 <argfd.constprop.0>
80105110:	85 c0                	test   %eax,%eax
80105112:	78 2c                	js     80105140 <sys_fstat+0x40>
80105114:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105117:	83 ec 04             	sub    $0x4,%esp
8010511a:	6a 14                	push   $0x14
8010511c:	50                   	push   %eax
8010511d:	6a 01                	push   $0x1
8010511f:	e8 0c fb ff ff       	call   80104c30 <argptr>
80105124:	83 c4 10             	add    $0x10,%esp
80105127:	85 c0                	test   %eax,%eax
80105129:	78 15                	js     80105140 <sys_fstat+0x40>
  return filestat(f, st);
8010512b:	83 ec 08             	sub    $0x8,%esp
8010512e:	ff 75 f4             	pushl  -0xc(%ebp)
80105131:	ff 75 f0             	pushl  -0x10(%ebp)
80105134:	e8 a7 bd ff ff       	call   80100ee0 <filestat>
80105139:	83 c4 10             	add    $0x10,%esp
}
8010513c:	c9                   	leave  
8010513d:	c3                   	ret    
8010513e:	66 90                	xchg   %ax,%ax
    return -1;
80105140:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105145:	c9                   	leave  
80105146:	c3                   	ret    
80105147:	89 f6                	mov    %esi,%esi
80105149:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105150 <sys_link>:
{
80105150:	55                   	push   %ebp
80105151:	89 e5                	mov    %esp,%ebp
80105153:	57                   	push   %edi
80105154:	56                   	push   %esi
80105155:	53                   	push   %ebx
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105156:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105159:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010515c:	50                   	push   %eax
8010515d:	6a 00                	push   $0x0
8010515f:	e8 1c fb ff ff       	call   80104c80 <argstr>
80105164:	83 c4 10             	add    $0x10,%esp
80105167:	85 c0                	test   %eax,%eax
80105169:	0f 88 fb 00 00 00    	js     8010526a <sys_link+0x11a>
8010516f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105172:	83 ec 08             	sub    $0x8,%esp
80105175:	50                   	push   %eax
80105176:	6a 01                	push   $0x1
80105178:	e8 03 fb ff ff       	call   80104c80 <argstr>
8010517d:	83 c4 10             	add    $0x10,%esp
80105180:	85 c0                	test   %eax,%eax
80105182:	0f 88 e2 00 00 00    	js     8010526a <sys_link+0x11a>
  begin_op();
80105188:	e8 93 da ff ff       	call   80102c20 <begin_op>
  if((ip = namei(old)) == 0){
8010518d:	83 ec 0c             	sub    $0xc,%esp
80105190:	ff 75 d4             	pushl  -0x2c(%ebp)
80105193:	e8 18 cd ff ff       	call   80101eb0 <namei>
80105198:	83 c4 10             	add    $0x10,%esp
8010519b:	85 c0                	test   %eax,%eax
8010519d:	89 c3                	mov    %eax,%ebx
8010519f:	0f 84 ea 00 00 00    	je     8010528f <sys_link+0x13f>
  ilock(ip);
801051a5:	83 ec 0c             	sub    $0xc,%esp
801051a8:	50                   	push   %eax
801051a9:	e8 62 c4 ff ff       	call   80101610 <ilock>
  if(ip->type == T_DIR){
801051ae:	83 c4 10             	add    $0x10,%esp
801051b1:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
801051b6:	0f 84 bb 00 00 00    	je     80105277 <sys_link+0x127>
  ip->nlink++;
801051bc:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
801051c1:	83 ec 0c             	sub    $0xc,%esp
  if((dp = nameiparent(new, name)) == 0)
801051c4:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801051c7:	53                   	push   %ebx
801051c8:	e8 93 c3 ff ff       	call   80101560 <iupdate>
  iunlock(ip);
801051cd:	89 1c 24             	mov    %ebx,(%esp)
801051d0:	e8 4b c5 ff ff       	call   80101720 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801051d5:	58                   	pop    %eax
801051d6:	5a                   	pop    %edx
801051d7:	57                   	push   %edi
801051d8:	ff 75 d0             	pushl  -0x30(%ebp)
801051db:	e8 f0 cc ff ff       	call   80101ed0 <nameiparent>
801051e0:	83 c4 10             	add    $0x10,%esp
801051e3:	85 c0                	test   %eax,%eax
801051e5:	89 c6                	mov    %eax,%esi
801051e7:	74 5b                	je     80105244 <sys_link+0xf4>
  ilock(dp);
801051e9:	83 ec 0c             	sub    $0xc,%esp
801051ec:	50                   	push   %eax
801051ed:	e8 1e c4 ff ff       	call   80101610 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801051f2:	83 c4 10             	add    $0x10,%esp
801051f5:	8b 03                	mov    (%ebx),%eax
801051f7:	39 06                	cmp    %eax,(%esi)
801051f9:	75 3d                	jne    80105238 <sys_link+0xe8>
801051fb:	83 ec 04             	sub    $0x4,%esp
801051fe:	ff 73 04             	pushl  0x4(%ebx)
80105201:	57                   	push   %edi
80105202:	56                   	push   %esi
80105203:	e8 e8 cb ff ff       	call   80101df0 <dirlink>
80105208:	83 c4 10             	add    $0x10,%esp
8010520b:	85 c0                	test   %eax,%eax
8010520d:	78 29                	js     80105238 <sys_link+0xe8>
  iunlockput(dp);
8010520f:	83 ec 0c             	sub    $0xc,%esp
80105212:	56                   	push   %esi
80105213:	e8 c8 c6 ff ff       	call   801018e0 <iunlockput>
  iput(ip);
80105218:	89 1c 24             	mov    %ebx,(%esp)
8010521b:	e8 60 c5 ff ff       	call   80101780 <iput>
  end_op();
80105220:	e8 6b da ff ff       	call   80102c90 <end_op>
  return 0;
80105225:	83 c4 10             	add    $0x10,%esp
80105228:	31 c0                	xor    %eax,%eax
}
8010522a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010522d:	5b                   	pop    %ebx
8010522e:	5e                   	pop    %esi
8010522f:	5f                   	pop    %edi
80105230:	5d                   	pop    %ebp
80105231:	c3                   	ret    
80105232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105238:	83 ec 0c             	sub    $0xc,%esp
8010523b:	56                   	push   %esi
8010523c:	e8 9f c6 ff ff       	call   801018e0 <iunlockput>
    goto bad;
80105241:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105244:	83 ec 0c             	sub    $0xc,%esp
80105247:	53                   	push   %ebx
80105248:	e8 c3 c3 ff ff       	call   80101610 <ilock>
  ip->nlink--;
8010524d:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
80105252:	89 1c 24             	mov    %ebx,(%esp)
80105255:	e8 06 c3 ff ff       	call   80101560 <iupdate>
  iunlockput(ip);
8010525a:	89 1c 24             	mov    %ebx,(%esp)
8010525d:	e8 7e c6 ff ff       	call   801018e0 <iunlockput>
  end_op();
80105262:	e8 29 da ff ff       	call   80102c90 <end_op>
  return -1;
80105267:	83 c4 10             	add    $0x10,%esp
}
8010526a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010526d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105272:	5b                   	pop    %ebx
80105273:	5e                   	pop    %esi
80105274:	5f                   	pop    %edi
80105275:	5d                   	pop    %ebp
80105276:	c3                   	ret    
    iunlockput(ip);
80105277:	83 ec 0c             	sub    $0xc,%esp
8010527a:	53                   	push   %ebx
8010527b:	e8 60 c6 ff ff       	call   801018e0 <iunlockput>
    end_op();
80105280:	e8 0b da ff ff       	call   80102c90 <end_op>
    return -1;
80105285:	83 c4 10             	add    $0x10,%esp
80105288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010528d:	eb 9b                	jmp    8010522a <sys_link+0xda>
    end_op();
8010528f:	e8 fc d9 ff ff       	call   80102c90 <end_op>
    return -1;
80105294:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105299:	eb 8f                	jmp    8010522a <sys_link+0xda>
8010529b:	90                   	nop
8010529c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801052a0 <sys_unlink>:
{
801052a0:	55                   	push   %ebp
801052a1:	89 e5                	mov    %esp,%ebp
801052a3:	57                   	push   %edi
801052a4:	56                   	push   %esi
801052a5:	53                   	push   %ebx
  if(argstr(0, &path) < 0)
801052a6:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
801052a9:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801052ac:	50                   	push   %eax
801052ad:	6a 00                	push   $0x0
801052af:	e8 cc f9 ff ff       	call   80104c80 <argstr>
801052b4:	83 c4 10             	add    $0x10,%esp
801052b7:	85 c0                	test   %eax,%eax
801052b9:	0f 88 77 01 00 00    	js     80105436 <sys_unlink+0x196>
  if((dp = nameiparent(path, name)) == 0){
801052bf:	8d 5d ca             	lea    -0x36(%ebp),%ebx
  begin_op();
801052c2:	e8 59 d9 ff ff       	call   80102c20 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052c7:	83 ec 08             	sub    $0x8,%esp
801052ca:	53                   	push   %ebx
801052cb:	ff 75 c0             	pushl  -0x40(%ebp)
801052ce:	e8 fd cb ff ff       	call   80101ed0 <nameiparent>
801052d3:	83 c4 10             	add    $0x10,%esp
801052d6:	85 c0                	test   %eax,%eax
801052d8:	89 c6                	mov    %eax,%esi
801052da:	0f 84 60 01 00 00    	je     80105440 <sys_unlink+0x1a0>
  ilock(dp);
801052e0:	83 ec 0c             	sub    $0xc,%esp
801052e3:	50                   	push   %eax
801052e4:	e8 27 c3 ff ff       	call   80101610 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801052e9:	58                   	pop    %eax
801052ea:	5a                   	pop    %edx
801052eb:	68 a8 7d 10 80       	push   $0x80107da8
801052f0:	53                   	push   %ebx
801052f1:	e8 6a c8 ff ff       	call   80101b60 <namecmp>
801052f6:	83 c4 10             	add    $0x10,%esp
801052f9:	85 c0                	test   %eax,%eax
801052fb:	0f 84 03 01 00 00    	je     80105404 <sys_unlink+0x164>
80105301:	83 ec 08             	sub    $0x8,%esp
80105304:	68 a7 7d 10 80       	push   $0x80107da7
80105309:	53                   	push   %ebx
8010530a:	e8 51 c8 ff ff       	call   80101b60 <namecmp>
8010530f:	83 c4 10             	add    $0x10,%esp
80105312:	85 c0                	test   %eax,%eax
80105314:	0f 84 ea 00 00 00    	je     80105404 <sys_unlink+0x164>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010531a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010531d:	83 ec 04             	sub    $0x4,%esp
80105320:	50                   	push   %eax
80105321:	53                   	push   %ebx
80105322:	56                   	push   %esi
80105323:	e8 58 c8 ff ff       	call   80101b80 <dirlookup>
80105328:	83 c4 10             	add    $0x10,%esp
8010532b:	85 c0                	test   %eax,%eax
8010532d:	89 c3                	mov    %eax,%ebx
8010532f:	0f 84 cf 00 00 00    	je     80105404 <sys_unlink+0x164>
  ilock(ip);
80105335:	83 ec 0c             	sub    $0xc,%esp
80105338:	50                   	push   %eax
80105339:	e8 d2 c2 ff ff       	call   80101610 <ilock>
  if(ip->nlink < 1)
8010533e:	83 c4 10             	add    $0x10,%esp
80105341:	66 83 7b 16 00       	cmpw   $0x0,0x16(%ebx)
80105346:	0f 8e 10 01 00 00    	jle    8010545c <sys_unlink+0x1bc>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010534c:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105351:	74 6d                	je     801053c0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
80105353:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105356:	83 ec 04             	sub    $0x4,%esp
80105359:	6a 10                	push   $0x10
8010535b:	6a 00                	push   $0x0
8010535d:	50                   	push   %eax
8010535e:	e8 ad f5 ff ff       	call   80104910 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105363:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105366:	6a 10                	push   $0x10
80105368:	ff 75 c4             	pushl  -0x3c(%ebp)
8010536b:	50                   	push   %eax
8010536c:	56                   	push   %esi
8010536d:	e8 be c6 ff ff       	call   80101a30 <writei>
80105372:	83 c4 20             	add    $0x20,%esp
80105375:	83 f8 10             	cmp    $0x10,%eax
80105378:	0f 85 eb 00 00 00    	jne    80105469 <sys_unlink+0x1c9>
  if(ip->type == T_DIR){
8010537e:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105383:	0f 84 97 00 00 00    	je     80105420 <sys_unlink+0x180>
  iunlockput(dp);
80105389:	83 ec 0c             	sub    $0xc,%esp
8010538c:	56                   	push   %esi
8010538d:	e8 4e c5 ff ff       	call   801018e0 <iunlockput>
  ip->nlink--;
80105392:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
80105397:	89 1c 24             	mov    %ebx,(%esp)
8010539a:	e8 c1 c1 ff ff       	call   80101560 <iupdate>
  iunlockput(ip);
8010539f:	89 1c 24             	mov    %ebx,(%esp)
801053a2:	e8 39 c5 ff ff       	call   801018e0 <iunlockput>
  end_op();
801053a7:	e8 e4 d8 ff ff       	call   80102c90 <end_op>
  return 0;
801053ac:	83 c4 10             	add    $0x10,%esp
801053af:	31 c0                	xor    %eax,%eax
}
801053b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053b4:	5b                   	pop    %ebx
801053b5:	5e                   	pop    %esi
801053b6:	5f                   	pop    %edi
801053b7:	5d                   	pop    %ebp
801053b8:	c3                   	ret    
801053b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801053c0:	83 7b 18 20          	cmpl   $0x20,0x18(%ebx)
801053c4:	76 8d                	jbe    80105353 <sys_unlink+0xb3>
801053c6:	bf 20 00 00 00       	mov    $0x20,%edi
801053cb:	eb 0f                	jmp    801053dc <sys_unlink+0x13c>
801053cd:	8d 76 00             	lea    0x0(%esi),%esi
801053d0:	83 c7 10             	add    $0x10,%edi
801053d3:	3b 7b 18             	cmp    0x18(%ebx),%edi
801053d6:	0f 83 77 ff ff ff    	jae    80105353 <sys_unlink+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053dc:	8d 45 d8             	lea    -0x28(%ebp),%eax
801053df:	6a 10                	push   $0x10
801053e1:	57                   	push   %edi
801053e2:	50                   	push   %eax
801053e3:	53                   	push   %ebx
801053e4:	e8 47 c5 ff ff       	call   80101930 <readi>
801053e9:	83 c4 10             	add    $0x10,%esp
801053ec:	83 f8 10             	cmp    $0x10,%eax
801053ef:	75 5e                	jne    8010544f <sys_unlink+0x1af>
    if(de.inum != 0)
801053f1:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801053f6:	74 d8                	je     801053d0 <sys_unlink+0x130>
    iunlockput(ip);
801053f8:	83 ec 0c             	sub    $0xc,%esp
801053fb:	53                   	push   %ebx
801053fc:	e8 df c4 ff ff       	call   801018e0 <iunlockput>
    goto bad;
80105401:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80105404:	83 ec 0c             	sub    $0xc,%esp
80105407:	56                   	push   %esi
80105408:	e8 d3 c4 ff ff       	call   801018e0 <iunlockput>
  end_op();
8010540d:	e8 7e d8 ff ff       	call   80102c90 <end_op>
  return -1;
80105412:	83 c4 10             	add    $0x10,%esp
80105415:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010541a:	eb 95                	jmp    801053b1 <sys_unlink+0x111>
8010541c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink--;
80105420:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
    iupdate(dp);
80105425:	83 ec 0c             	sub    $0xc,%esp
80105428:	56                   	push   %esi
80105429:	e8 32 c1 ff ff       	call   80101560 <iupdate>
8010542e:	83 c4 10             	add    $0x10,%esp
80105431:	e9 53 ff ff ff       	jmp    80105389 <sys_unlink+0xe9>
    return -1;
80105436:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010543b:	e9 71 ff ff ff       	jmp    801053b1 <sys_unlink+0x111>
    end_op();
80105440:	e8 4b d8 ff ff       	call   80102c90 <end_op>
    return -1;
80105445:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010544a:	e9 62 ff ff ff       	jmp    801053b1 <sys_unlink+0x111>
      panic("isdirempty: readi");
8010544f:	83 ec 0c             	sub    $0xc,%esp
80105452:	68 cc 7d 10 80       	push   $0x80107dcc
80105457:	e8 14 af ff ff       	call   80100370 <panic>
    panic("unlink: nlink < 1");
8010545c:	83 ec 0c             	sub    $0xc,%esp
8010545f:	68 ba 7d 10 80       	push   $0x80107dba
80105464:	e8 07 af ff ff       	call   80100370 <panic>
    panic("unlink: writei");
80105469:	83 ec 0c             	sub    $0xc,%esp
8010546c:	68 de 7d 10 80       	push   $0x80107dde
80105471:	e8 fa ae ff ff       	call   80100370 <panic>
80105476:	8d 76 00             	lea    0x0(%esi),%esi
80105479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105480 <sys_open>:

int
sys_open(void)
{
80105480:	55                   	push   %ebp
80105481:	89 e5                	mov    %esp,%ebp
80105483:	57                   	push   %edi
80105484:	56                   	push   %esi
80105485:	53                   	push   %ebx
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105486:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105489:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010548c:	50                   	push   %eax
8010548d:	6a 00                	push   $0x0
8010548f:	e8 ec f7 ff ff       	call   80104c80 <argstr>
80105494:	83 c4 10             	add    $0x10,%esp
80105497:	85 c0                	test   %eax,%eax
80105499:	0f 88 1d 01 00 00    	js     801055bc <sys_open+0x13c>
8010549f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801054a2:	83 ec 08             	sub    $0x8,%esp
801054a5:	50                   	push   %eax
801054a6:	6a 01                	push   $0x1
801054a8:	e8 43 f7 ff ff       	call   80104bf0 <argint>
801054ad:	83 c4 10             	add    $0x10,%esp
801054b0:	85 c0                	test   %eax,%eax
801054b2:	0f 88 04 01 00 00    	js     801055bc <sys_open+0x13c>
    return -1;

  begin_op();
801054b8:	e8 63 d7 ff ff       	call   80102c20 <begin_op>

  if(omode & O_CREATE){
801054bd:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801054c1:	0f 85 a9 00 00 00    	jne    80105570 <sys_open+0xf0>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801054c7:	83 ec 0c             	sub    $0xc,%esp
801054ca:	ff 75 e0             	pushl  -0x20(%ebp)
801054cd:	e8 de c9 ff ff       	call   80101eb0 <namei>
801054d2:	83 c4 10             	add    $0x10,%esp
801054d5:	85 c0                	test   %eax,%eax
801054d7:	89 c6                	mov    %eax,%esi
801054d9:	0f 84 b2 00 00 00    	je     80105591 <sys_open+0x111>
      end_op();
      return -1;
    }
    ilock(ip);
801054df:	83 ec 0c             	sub    $0xc,%esp
801054e2:	50                   	push   %eax
801054e3:	e8 28 c1 ff ff       	call   80101610 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801054e8:	83 c4 10             	add    $0x10,%esp
801054eb:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
801054f0:	0f 84 aa 00 00 00    	je     801055a0 <sys_open+0x120>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801054f6:	e8 55 b8 ff ff       	call   80100d50 <filealloc>
801054fb:	85 c0                	test   %eax,%eax
801054fd:	89 c7                	mov    %eax,%edi
801054ff:	0f 84 a6 00 00 00    	je     801055ab <sys_open+0x12b>
    if(proc->ofile[fd] == 0){
80105505:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  for(fd = 0; fd < NOFILE; fd++){
8010550c:	31 db                	xor    %ebx,%ebx
8010550e:	eb 0c                	jmp    8010551c <sys_open+0x9c>
80105510:	83 c3 01             	add    $0x1,%ebx
80105513:	83 fb 10             	cmp    $0x10,%ebx
80105516:	0f 84 ac 00 00 00    	je     801055c8 <sys_open+0x148>
    if(proc->ofile[fd] == 0){
8010551c:	8b 44 9a 2c          	mov    0x2c(%edx,%ebx,4),%eax
80105520:	85 c0                	test   %eax,%eax
80105522:	75 ec                	jne    80105510 <sys_open+0x90>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105524:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
80105527:	89 7c 9a 2c          	mov    %edi,0x2c(%edx,%ebx,4)
  iunlock(ip);
8010552b:	56                   	push   %esi
8010552c:	e8 ef c1 ff ff       	call   80101720 <iunlock>
  end_op();
80105531:	e8 5a d7 ff ff       	call   80102c90 <end_op>

  f->type = FD_INODE;
80105536:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
8010553c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010553f:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105542:	89 77 10             	mov    %esi,0x10(%edi)
  f->off = 0;
80105545:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
8010554c:	89 d0                	mov    %edx,%eax
8010554e:	f7 d0                	not    %eax
80105550:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105553:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
80105556:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105559:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
8010555d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105560:	89 d8                	mov    %ebx,%eax
80105562:	5b                   	pop    %ebx
80105563:	5e                   	pop    %esi
80105564:	5f                   	pop    %edi
80105565:	5d                   	pop    %ebp
80105566:	c3                   	ret    
80105567:	89 f6                	mov    %esi,%esi
80105569:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ip = create(path, T_FILE, 0, 0);
80105570:	83 ec 0c             	sub    $0xc,%esp
80105573:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105576:	31 c9                	xor    %ecx,%ecx
80105578:	6a 00                	push   $0x0
8010557a:	ba 02 00 00 00       	mov    $0x2,%edx
8010557f:	e8 ec f7 ff ff       	call   80104d70 <create>
    if(ip == 0){
80105584:	83 c4 10             	add    $0x10,%esp
80105587:	85 c0                	test   %eax,%eax
    ip = create(path, T_FILE, 0, 0);
80105589:	89 c6                	mov    %eax,%esi
    if(ip == 0){
8010558b:	0f 85 65 ff ff ff    	jne    801054f6 <sys_open+0x76>
      end_op();
80105591:	e8 fa d6 ff ff       	call   80102c90 <end_op>
      return -1;
80105596:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010559b:	eb c0                	jmp    8010555d <sys_open+0xdd>
8010559d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->type == T_DIR && omode != O_RDONLY){
801055a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801055a3:	85 d2                	test   %edx,%edx
801055a5:	0f 84 4b ff ff ff    	je     801054f6 <sys_open+0x76>
    iunlockput(ip);
801055ab:	83 ec 0c             	sub    $0xc,%esp
801055ae:	56                   	push   %esi
801055af:	e8 2c c3 ff ff       	call   801018e0 <iunlockput>
    end_op();
801055b4:	e8 d7 d6 ff ff       	call   80102c90 <end_op>
    return -1;
801055b9:	83 c4 10             	add    $0x10,%esp
801055bc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801055c1:	eb 9a                	jmp    8010555d <sys_open+0xdd>
801055c3:	90                   	nop
801055c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      fileclose(f);
801055c8:	83 ec 0c             	sub    $0xc,%esp
801055cb:	57                   	push   %edi
801055cc:	e8 3f b8 ff ff       	call   80100e10 <fileclose>
801055d1:	83 c4 10             	add    $0x10,%esp
801055d4:	eb d5                	jmp    801055ab <sys_open+0x12b>
801055d6:	8d 76 00             	lea    0x0(%esi),%esi
801055d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801055e0 <sys_mkdir>:

int
sys_mkdir(void)
{
801055e0:	55                   	push   %ebp
801055e1:	89 e5                	mov    %esp,%ebp
801055e3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801055e6:	e8 35 d6 ff ff       	call   80102c20 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801055eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055ee:	83 ec 08             	sub    $0x8,%esp
801055f1:	50                   	push   %eax
801055f2:	6a 00                	push   $0x0
801055f4:	e8 87 f6 ff ff       	call   80104c80 <argstr>
801055f9:	83 c4 10             	add    $0x10,%esp
801055fc:	85 c0                	test   %eax,%eax
801055fe:	78 30                	js     80105630 <sys_mkdir+0x50>
80105600:	83 ec 0c             	sub    $0xc,%esp
80105603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105606:	31 c9                	xor    %ecx,%ecx
80105608:	6a 00                	push   $0x0
8010560a:	ba 01 00 00 00       	mov    $0x1,%edx
8010560f:	e8 5c f7 ff ff       	call   80104d70 <create>
80105614:	83 c4 10             	add    $0x10,%esp
80105617:	85 c0                	test   %eax,%eax
80105619:	74 15                	je     80105630 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010561b:	83 ec 0c             	sub    $0xc,%esp
8010561e:	50                   	push   %eax
8010561f:	e8 bc c2 ff ff       	call   801018e0 <iunlockput>
  end_op();
80105624:	e8 67 d6 ff ff       	call   80102c90 <end_op>
  return 0;
80105629:	83 c4 10             	add    $0x10,%esp
8010562c:	31 c0                	xor    %eax,%eax
}
8010562e:	c9                   	leave  
8010562f:	c3                   	ret    
    end_op();
80105630:	e8 5b d6 ff ff       	call   80102c90 <end_op>
    return -1;
80105635:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010563a:	c9                   	leave  
8010563b:	c3                   	ret    
8010563c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105640 <sys_mknod>:

int
sys_mknod(void)
{
80105640:	55                   	push   %ebp
80105641:	89 e5                	mov    %esp,%ebp
80105643:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105646:	e8 d5 d5 ff ff       	call   80102c20 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010564b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010564e:	83 ec 08             	sub    $0x8,%esp
80105651:	50                   	push   %eax
80105652:	6a 00                	push   $0x0
80105654:	e8 27 f6 ff ff       	call   80104c80 <argstr>
80105659:	83 c4 10             	add    $0x10,%esp
8010565c:	85 c0                	test   %eax,%eax
8010565e:	78 60                	js     801056c0 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105660:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105663:	83 ec 08             	sub    $0x8,%esp
80105666:	50                   	push   %eax
80105667:	6a 01                	push   $0x1
80105669:	e8 82 f5 ff ff       	call   80104bf0 <argint>
  if((argstr(0, &path)) < 0 ||
8010566e:	83 c4 10             	add    $0x10,%esp
80105671:	85 c0                	test   %eax,%eax
80105673:	78 4b                	js     801056c0 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105675:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105678:	83 ec 08             	sub    $0x8,%esp
8010567b:	50                   	push   %eax
8010567c:	6a 02                	push   $0x2
8010567e:	e8 6d f5 ff ff       	call   80104bf0 <argint>
     argint(1, &major) < 0 ||
80105683:	83 c4 10             	add    $0x10,%esp
80105686:	85 c0                	test   %eax,%eax
80105688:	78 36                	js     801056c0 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010568a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
     argint(2, &minor) < 0 ||
8010568e:	83 ec 0c             	sub    $0xc,%esp
     (ip = create(path, T_DEV, major, minor)) == 0){
80105691:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80105695:	ba 03 00 00 00       	mov    $0x3,%edx
8010569a:	50                   	push   %eax
8010569b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010569e:	e8 cd f6 ff ff       	call   80104d70 <create>
801056a3:	83 c4 10             	add    $0x10,%esp
801056a6:	85 c0                	test   %eax,%eax
801056a8:	74 16                	je     801056c0 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
801056aa:	83 ec 0c             	sub    $0xc,%esp
801056ad:	50                   	push   %eax
801056ae:	e8 2d c2 ff ff       	call   801018e0 <iunlockput>
  end_op();
801056b3:	e8 d8 d5 ff ff       	call   80102c90 <end_op>
  return 0;
801056b8:	83 c4 10             	add    $0x10,%esp
801056bb:	31 c0                	xor    %eax,%eax
}
801056bd:	c9                   	leave  
801056be:	c3                   	ret    
801056bf:	90                   	nop
    end_op();
801056c0:	e8 cb d5 ff ff       	call   80102c90 <end_op>
    return -1;
801056c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056ca:	c9                   	leave  
801056cb:	c3                   	ret    
801056cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801056d0 <sys_chdir>:

int
sys_chdir(void)
{
801056d0:	55                   	push   %ebp
801056d1:	89 e5                	mov    %esp,%ebp
801056d3:	53                   	push   %ebx
801056d4:	83 ec 14             	sub    $0x14,%esp
  char *path;
  struct inode *ip;

  begin_op();
801056d7:	e8 44 d5 ff ff       	call   80102c20 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801056dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056df:	83 ec 08             	sub    $0x8,%esp
801056e2:	50                   	push   %eax
801056e3:	6a 00                	push   $0x0
801056e5:	e8 96 f5 ff ff       	call   80104c80 <argstr>
801056ea:	83 c4 10             	add    $0x10,%esp
801056ed:	85 c0                	test   %eax,%eax
801056ef:	78 7f                	js     80105770 <sys_chdir+0xa0>
801056f1:	83 ec 0c             	sub    $0xc,%esp
801056f4:	ff 75 f4             	pushl  -0xc(%ebp)
801056f7:	e8 b4 c7 ff ff       	call   80101eb0 <namei>
801056fc:	83 c4 10             	add    $0x10,%esp
801056ff:	85 c0                	test   %eax,%eax
80105701:	89 c3                	mov    %eax,%ebx
80105703:	74 6b                	je     80105770 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105705:	83 ec 0c             	sub    $0xc,%esp
80105708:	50                   	push   %eax
80105709:	e8 02 bf ff ff       	call   80101610 <ilock>
  if(ip->type != T_DIR){
8010570e:	83 c4 10             	add    $0x10,%esp
80105711:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105716:	75 38                	jne    80105750 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105718:	83 ec 0c             	sub    $0xc,%esp
8010571b:	53                   	push   %ebx
8010571c:	e8 ff bf ff ff       	call   80101720 <iunlock>
  iput(proc->cwd);
80105721:	58                   	pop    %eax
80105722:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105728:	ff 70 6c             	pushl  0x6c(%eax)
8010572b:	e8 50 c0 ff ff       	call   80101780 <iput>
  end_op();
80105730:	e8 5b d5 ff ff       	call   80102c90 <end_op>
  proc->cwd = ip;
80105735:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return 0;
8010573b:	83 c4 10             	add    $0x10,%esp
  proc->cwd = ip;
8010573e:	89 58 6c             	mov    %ebx,0x6c(%eax)
  return 0;
80105741:	31 c0                	xor    %eax,%eax
}
80105743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105746:	c9                   	leave  
80105747:	c3                   	ret    
80105748:	90                   	nop
80105749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    iunlockput(ip);
80105750:	83 ec 0c             	sub    $0xc,%esp
80105753:	53                   	push   %ebx
80105754:	e8 87 c1 ff ff       	call   801018e0 <iunlockput>
    end_op();
80105759:	e8 32 d5 ff ff       	call   80102c90 <end_op>
    return -1;
8010575e:	83 c4 10             	add    $0x10,%esp
80105761:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105766:	eb db                	jmp    80105743 <sys_chdir+0x73>
80105768:	90                   	nop
80105769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    end_op();
80105770:	e8 1b d5 ff ff       	call   80102c90 <end_op>
    return -1;
80105775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577a:	eb c7                	jmp    80105743 <sys_chdir+0x73>
8010577c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105780 <sys_exec>:

int
sys_exec(void)
{
80105780:	55                   	push   %ebp
80105781:	89 e5                	mov    %esp,%ebp
80105783:	57                   	push   %edi
80105784:	56                   	push   %esi
80105785:	53                   	push   %ebx
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105786:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
8010578c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105792:	50                   	push   %eax
80105793:	6a 00                	push   $0x0
80105795:	e8 e6 f4 ff ff       	call   80104c80 <argstr>
8010579a:	83 c4 10             	add    $0x10,%esp
8010579d:	85 c0                	test   %eax,%eax
8010579f:	0f 88 87 00 00 00    	js     8010582c <sys_exec+0xac>
801057a5:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
801057ab:	83 ec 08             	sub    $0x8,%esp
801057ae:	50                   	push   %eax
801057af:	6a 01                	push   $0x1
801057b1:	e8 3a f4 ff ff       	call   80104bf0 <argint>
801057b6:	83 c4 10             	add    $0x10,%esp
801057b9:	85 c0                	test   %eax,%eax
801057bb:	78 6f                	js     8010582c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801057bd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801057c3:	83 ec 04             	sub    $0x4,%esp
  for(i=0;; i++){
801057c6:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
801057c8:	68 80 00 00 00       	push   $0x80
801057cd:	6a 00                	push   $0x0
801057cf:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
801057d5:	50                   	push   %eax
801057d6:	e8 35 f1 ff ff       	call   80104910 <memset>
801057db:	83 c4 10             	add    $0x10,%esp
801057de:	eb 2c                	jmp    8010580c <sys_exec+0x8c>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
801057e0:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801057e6:	85 c0                	test   %eax,%eax
801057e8:	74 56                	je     80105840 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801057ea:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
801057f0:	83 ec 08             	sub    $0x8,%esp
801057f3:	8d 14 31             	lea    (%ecx,%esi,1),%edx
801057f6:	52                   	push   %edx
801057f7:	50                   	push   %eax
801057f8:	e8 93 f3 ff ff       	call   80104b90 <fetchstr>
801057fd:	83 c4 10             	add    $0x10,%esp
80105800:	85 c0                	test   %eax,%eax
80105802:	78 28                	js     8010582c <sys_exec+0xac>
  for(i=0;; i++){
80105804:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105807:	83 fb 20             	cmp    $0x20,%ebx
8010580a:	74 20                	je     8010582c <sys_exec+0xac>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010580c:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105812:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
80105819:	83 ec 08             	sub    $0x8,%esp
8010581c:	57                   	push   %edi
8010581d:	01 f0                	add    %esi,%eax
8010581f:	50                   	push   %eax
80105820:	e8 3b f3 ff ff       	call   80104b60 <fetchint>
80105825:	83 c4 10             	add    $0x10,%esp
80105828:	85 c0                	test   %eax,%eax
8010582a:	79 b4                	jns    801057e0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
8010582c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010582f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105834:	5b                   	pop    %ebx
80105835:	5e                   	pop    %esi
80105836:	5f                   	pop    %edi
80105837:	5d                   	pop    %ebp
80105838:	c3                   	ret    
80105839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105840:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105846:	83 ec 08             	sub    $0x8,%esp
      argv[i] = 0;
80105849:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105850:	00 00 00 00 
  return exec(path, argv);
80105854:	50                   	push   %eax
80105855:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
8010585b:	e8 90 b1 ff ff       	call   801009f0 <exec>
80105860:	83 c4 10             	add    $0x10,%esp
}
80105863:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105866:	5b                   	pop    %ebx
80105867:	5e                   	pop    %esi
80105868:	5f                   	pop    %edi
80105869:	5d                   	pop    %ebp
8010586a:	c3                   	ret    
8010586b:	90                   	nop
8010586c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105870 <sys_pipe>:

int
sys_pipe(void)
{
80105870:	55                   	push   %ebp
80105871:	89 e5                	mov    %esp,%ebp
80105873:	57                   	push   %edi
80105874:	56                   	push   %esi
80105875:	53                   	push   %ebx
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105876:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105879:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010587c:	6a 08                	push   $0x8
8010587e:	50                   	push   %eax
8010587f:	6a 00                	push   $0x0
80105881:	e8 aa f3 ff ff       	call   80104c30 <argptr>
80105886:	83 c4 10             	add    $0x10,%esp
80105889:	85 c0                	test   %eax,%eax
8010588b:	0f 88 a4 00 00 00    	js     80105935 <sys_pipe+0xc5>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105891:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105894:	83 ec 08             	sub    $0x8,%esp
80105897:	50                   	push   %eax
80105898:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010589b:	50                   	push   %eax
8010589c:	e8 1f db ff ff       	call   801033c0 <pipealloc>
801058a1:	83 c4 10             	add    $0x10,%esp
801058a4:	85 c0                	test   %eax,%eax
801058a6:	0f 88 89 00 00 00    	js     80105935 <sys_pipe+0xc5>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801058ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
    if(proc->ofile[fd] == 0){
801058af:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  for(fd = 0; fd < NOFILE; fd++){
801058b6:	31 c0                	xor    %eax,%eax
801058b8:	eb 0e                	jmp    801058c8 <sys_pipe+0x58>
801058ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801058c0:	83 c0 01             	add    $0x1,%eax
801058c3:	83 f8 10             	cmp    $0x10,%eax
801058c6:	74 58                	je     80105920 <sys_pipe+0xb0>
    if(proc->ofile[fd] == 0){
801058c8:	8b 54 81 2c          	mov    0x2c(%ecx,%eax,4),%edx
801058cc:	85 d2                	test   %edx,%edx
801058ce:	75 f0                	jne    801058c0 <sys_pipe+0x50>
801058d0:	8d 34 81             	lea    (%ecx,%eax,4),%esi
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801058d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
801058d6:	31 d2                	xor    %edx,%edx
      proc->ofile[fd] = f;
801058d8:	89 5e 2c             	mov    %ebx,0x2c(%esi)
801058db:	eb 0b                	jmp    801058e8 <sys_pipe+0x78>
801058dd:	8d 76 00             	lea    0x0(%esi),%esi
  for(fd = 0; fd < NOFILE; fd++){
801058e0:	83 c2 01             	add    $0x1,%edx
801058e3:	83 fa 10             	cmp    $0x10,%edx
801058e6:	74 28                	je     80105910 <sys_pipe+0xa0>
    if(proc->ofile[fd] == 0){
801058e8:	83 7c 91 2c 00       	cmpl   $0x0,0x2c(%ecx,%edx,4)
801058ed:	75 f1                	jne    801058e0 <sys_pipe+0x70>
      proc->ofile[fd] = f;
801058ef:	89 7c 91 2c          	mov    %edi,0x2c(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
801058f3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801058f6:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
801058f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801058fb:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
801058fe:	31 c0                	xor    %eax,%eax
}
80105900:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105903:	5b                   	pop    %ebx
80105904:	5e                   	pop    %esi
80105905:	5f                   	pop    %edi
80105906:	5d                   	pop    %ebp
80105907:	c3                   	ret    
80105908:	90                   	nop
80105909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      proc->ofile[fd0] = 0;
80105910:	c7 46 2c 00 00 00 00 	movl   $0x0,0x2c(%esi)
80105917:	89 f6                	mov    %esi,%esi
80105919:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    fileclose(rf);
80105920:	83 ec 0c             	sub    $0xc,%esp
80105923:	53                   	push   %ebx
80105924:	e8 e7 b4 ff ff       	call   80100e10 <fileclose>
    fileclose(wf);
80105929:	58                   	pop    %eax
8010592a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010592d:	e8 de b4 ff ff       	call   80100e10 <fileclose>
    return -1;
80105932:	83 c4 10             	add    $0x10,%esp
80105935:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010593a:	eb c4                	jmp    80105900 <sys_pipe+0x90>
8010593c:	66 90                	xchg   %ax,%ax
8010593e:	66 90                	xchg   %ax,%ax

80105940 <sys_clone>:
#include "mmu.h"
#include "proc.h"

int 
sys_clone(void)
{
80105940:	55                   	push   %ebp
80105941:	89 e5                	mov    %esp,%ebp
80105943:	83 ec 20             	sub    $0x20,%esp
  int func_add;
  int arg;
  int stack_add;

  if (argint(0, &func_add) < 0)
80105946:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105949:	50                   	push   %eax
8010594a:	6a 00                	push   $0x0
8010594c:	e8 9f f2 ff ff       	call   80104bf0 <argint>
80105951:	83 c4 10             	add    $0x10,%esp
80105954:	85 c0                	test   %eax,%eax
80105956:	78 48                	js     801059a0 <sys_clone+0x60>
     return -1;
  if (argint(1, &arg) < 0)
80105958:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010595b:	83 ec 08             	sub    $0x8,%esp
8010595e:	50                   	push   %eax
8010595f:	6a 01                	push   $0x1
80105961:	e8 8a f2 ff ff       	call   80104bf0 <argint>
80105966:	83 c4 10             	add    $0x10,%esp
80105969:	85 c0                	test   %eax,%eax
8010596b:	78 33                	js     801059a0 <sys_clone+0x60>
     return -1;
  if (argint(2, &stack_add) < 0)
8010596d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105970:	83 ec 08             	sub    $0x8,%esp
80105973:	50                   	push   %eax
80105974:	6a 02                	push   $0x2
80105976:	e8 75 f2 ff ff       	call   80104bf0 <argint>
8010597b:	83 c4 10             	add    $0x10,%esp
8010597e:	85 c0                	test   %eax,%eax
80105980:	78 1e                	js     801059a0 <sys_clone+0x60>
     return -1;
 
  return clone((void *)func_add, (void *)arg, (void *)stack_add);
80105982:	83 ec 04             	sub    $0x4,%esp
80105985:	ff 75 f4             	pushl  -0xc(%ebp)
80105988:	ff 75 f0             	pushl  -0x10(%ebp)
8010598b:	ff 75 ec             	pushl  -0x14(%ebp)
8010598e:	e8 2d eb ff ff       	call   801044c0 <clone>
80105993:	83 c4 10             	add    $0x10,%esp
  
}
80105996:	c9                   	leave  
80105997:	c3                   	ret    
80105998:	90                   	nop
80105999:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
801059a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059a5:	c9                   	leave  
801059a6:	c3                   	ret    
801059a7:	89 f6                	mov    %esi,%esi
801059a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801059b0 <sys_join>:

int 
sys_join(void)
{
801059b0:	55                   	push   %ebp
801059b1:	89 e5                	mov    %esp,%ebp
801059b3:	83 ec 20             	sub    $0x20,%esp
  int stack_add;

  if (argint(0, &stack_add) < 0)
801059b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059b9:	50                   	push   %eax
801059ba:	6a 00                	push   $0x0
801059bc:	e8 2f f2 ff ff       	call   80104bf0 <argint>
801059c1:	83 c4 10             	add    $0x10,%esp
801059c4:	85 c0                	test   %eax,%eax
801059c6:	78 18                	js     801059e0 <sys_join+0x30>
     return -1;

  return join((void **)stack_add);
801059c8:	83 ec 0c             	sub    $0xc,%esp
801059cb:	ff 75 f4             	pushl  -0xc(%ebp)
801059ce:	e8 0d ec ff ff       	call   801045e0 <join>
801059d3:	83 c4 10             	add    $0x10,%esp
}
801059d6:	c9                   	leave  
801059d7:	c3                   	ret    
801059d8:	90                   	nop
801059d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
801059e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059e5:	c9                   	leave  
801059e6:	c3                   	ret    
801059e7:	89 f6                	mov    %esi,%esi
801059e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801059f0 <sys_myalloc>:

int 
sys_myalloc(void)
{
801059f0:	55                   	push   %ebp
801059f1:	89 e5                	mov    %esp,%ebp
801059f3:	83 ec 20             	sub    $0x20,%esp
  int n;   // 分配 n 个字节
  if(argint(0, &n) < 0)
801059f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059f9:	50                   	push   %eax
801059fa:	6a 00                	push   $0x0
801059fc:	e8 ef f1 ff ff       	call   80104bf0 <argint>
80105a01:	83 c4 10             	add    $0x10,%esp
    return 0;
80105a04:	31 d2                	xor    %edx,%edx
  if(argint(0, &n) < 0)
80105a06:	85 c0                	test   %eax,%eax
80105a08:	78 15                	js     80105a1f <sys_myalloc+0x2f>
  if(n <= 0)
80105a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0d:	85 c0                	test   %eax,%eax
80105a0f:	7e 0e                	jle    80105a1f <sys_myalloc+0x2f>
    return 0;
  return mygrowproc(n);
80105a11:	83 ec 0c             	sub    $0xc,%esp
80105a14:	50                   	push   %eax
80105a15:	e8 b6 e8 ff ff       	call   801042d0 <mygrowproc>
80105a1a:	83 c4 10             	add    $0x10,%esp
80105a1d:	89 c2                	mov    %eax,%edx
}
80105a1f:	89 d0                	mov    %edx,%eax
80105a21:	c9                   	leave  
80105a22:	c3                   	ret    
80105a23:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105a29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105a30 <sys_myfree>:

int 
sys_myfree(void) {
80105a30:	55                   	push   %ebp
80105a31:	89 e5                	mov    %esp,%ebp
80105a33:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(0, &addr) < 0)
80105a36:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a39:	50                   	push   %eax
80105a3a:	6a 00                	push   $0x0
80105a3c:	e8 af f1 ff ff       	call   80104bf0 <argint>
80105a41:	83 c4 10             	add    $0x10,%esp
80105a44:	85 c0                	test   %eax,%eax
80105a46:	78 18                	js     80105a60 <sys_myfree+0x30>
    return -1;
  return myreduceproc(addr);
80105a48:	83 ec 0c             	sub    $0xc,%esp
80105a4b:	ff 75 f4             	pushl  -0xc(%ebp)
80105a4e:	e8 9d e9 ff ff       	call   801043f0 <myreduceproc>
80105a53:	83 c4 10             	add    $0x10,%esp
}
80105a56:	c9                   	leave  
80105a57:	c3                   	ret    
80105a58:	90                   	nop
80105a59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105a60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a65:	c9                   	leave  
80105a66:	c3                   	ret    
80105a67:	89 f6                	mov    %esi,%esi
80105a69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105a70 <sys_getcpuid>:

//achieve sys_getcpuid, just my homework
int
sys_getcpuid()
{
80105a70:	55                   	push   %ebp
80105a71:	89 e5                	mov    %esp,%ebp
  return getcpuid();
}
80105a73:	5d                   	pop    %ebp
  return getcpuid();
80105a74:	e9 a7 de ff ff       	jmp    80103920 <getcpuid>
80105a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105a80 <sys_fork>:

int
sys_fork(void)
{
80105a80:	55                   	push   %ebp
80105a81:	89 e5                	mov    %esp,%ebp
  return fork();
}
80105a83:	5d                   	pop    %ebp
  return fork();
80105a84:	e9 57 e0 ff ff       	jmp    80103ae0 <fork>
80105a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105a90 <sys_exit>:

int
sys_exit(void)
{
80105a90:	55                   	push   %ebp
80105a91:	89 e5                	mov    %esp,%ebp
80105a93:	83 ec 08             	sub    $0x8,%esp
  exit();
80105a96:	e8 d5 e2 ff ff       	call   80103d70 <exit>
  return 0;  // not reached
}
80105a9b:	31 c0                	xor    %eax,%eax
80105a9d:	c9                   	leave  
80105a9e:	c3                   	ret    
80105a9f:	90                   	nop

80105aa0 <sys_wait>:

int
sys_wait(void)
{
80105aa0:	55                   	push   %ebp
80105aa1:	89 e5                	mov    %esp,%ebp
  return wait();
}
80105aa3:	5d                   	pop    %ebp
  return wait();
80105aa4:	e9 57 e5 ff ff       	jmp    80104000 <wait>
80105aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105ab0 <sys_kill>:

int
sys_kill(void)
{
80105ab0:	55                   	push   %ebp
80105ab1:	89 e5                	mov    %esp,%ebp
80105ab3:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105ab6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ab9:	50                   	push   %eax
80105aba:	6a 00                	push   $0x0
80105abc:	e8 2f f1 ff ff       	call   80104bf0 <argint>
80105ac1:	83 c4 10             	add    $0x10,%esp
80105ac4:	85 c0                	test   %eax,%eax
80105ac6:	78 18                	js     80105ae0 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105ac8:	83 ec 0c             	sub    $0xc,%esp
80105acb:	ff 75 f4             	pushl  -0xc(%ebp)
80105ace:	e8 7d e6 ff ff       	call   80104150 <kill>
80105ad3:	83 c4 10             	add    $0x10,%esp
}
80105ad6:	c9                   	leave  
80105ad7:	c3                   	ret    
80105ad8:	90                   	nop
80105ad9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105ae0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ae5:	c9                   	leave  
80105ae6:	c3                   	ret    
80105ae7:	89 f6                	mov    %esi,%esi
80105ae9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105af0 <sys_getpid>:

int
sys_getpid(void)
{
  return proc->pid;
80105af0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80105af6:	55                   	push   %ebp
80105af7:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80105af9:	8b 40 10             	mov    0x10(%eax),%eax
}
80105afc:	5d                   	pop    %ebp
80105afd:	c3                   	ret    
80105afe:	66 90                	xchg   %ax,%ax

80105b00 <sys_sbrk>:

int
sys_sbrk(void)
{
80105b00:	55                   	push   %ebp
80105b01:	89 e5                	mov    %esp,%ebp
80105b03:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105b07:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105b0a:	50                   	push   %eax
80105b0b:	6a 00                	push   $0x0
80105b0d:	e8 de f0 ff ff       	call   80104bf0 <argint>
80105b12:	83 c4 10             	add    $0x10,%esp
80105b15:	85 c0                	test   %eax,%eax
80105b17:	78 27                	js     80105b40 <sys_sbrk+0x40>
    return -1;
  addr = proc->sz;
80105b19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(growproc(n) < 0)
80105b1f:	83 ec 0c             	sub    $0xc,%esp
  addr = proc->sz;
80105b22:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105b24:	ff 75 f4             	pushl  -0xc(%ebp)
80105b27:	e8 34 df ff ff       	call   80103a60 <growproc>
80105b2c:	83 c4 10             	add    $0x10,%esp
80105b2f:	85 c0                	test   %eax,%eax
80105b31:	78 0d                	js     80105b40 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105b33:	89 d8                	mov    %ebx,%eax
80105b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105b38:	c9                   	leave  
80105b39:	c3                   	ret    
80105b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105b40:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105b45:	eb ec                	jmp    80105b33 <sys_sbrk+0x33>
80105b47:	89 f6                	mov    %esi,%esi
80105b49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105b50 <sys_sleep>:

int
sys_sleep(void)
{
80105b50:	55                   	push   %ebp
80105b51:	89 e5                	mov    %esp,%ebp
80105b53:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105b57:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105b5a:	50                   	push   %eax
80105b5b:	6a 00                	push   $0x0
80105b5d:	e8 8e f0 ff ff       	call   80104bf0 <argint>
80105b62:	83 c4 10             	add    $0x10,%esp
80105b65:	85 c0                	test   %eax,%eax
80105b67:	0f 88 8a 00 00 00    	js     80105bf7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105b6d:	83 ec 0c             	sub    $0xc,%esp
80105b70:	68 00 bb 11 80       	push   $0x8011bb00
80105b75:	e8 86 eb ff ff       	call   80104700 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105b7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b7d:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105b80:	8b 1d 40 c3 11 80    	mov    0x8011c340,%ebx
  while(ticks - ticks0 < n){
80105b86:	85 d2                	test   %edx,%edx
80105b88:	75 27                	jne    80105bb1 <sys_sleep+0x61>
80105b8a:	eb 54                	jmp    80105be0 <sys_sleep+0x90>
80105b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105b90:	83 ec 08             	sub    $0x8,%esp
80105b93:	68 00 bb 11 80       	push   $0x8011bb00
80105b98:	68 40 c3 11 80       	push   $0x8011c340
80105b9d:	e8 9e e3 ff ff       	call   80103f40 <sleep>
  while(ticks - ticks0 < n){
80105ba2:	a1 40 c3 11 80       	mov    0x8011c340,%eax
80105ba7:	83 c4 10             	add    $0x10,%esp
80105baa:	29 d8                	sub    %ebx,%eax
80105bac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105baf:	73 2f                	jae    80105be0 <sys_sleep+0x90>
    if(proc->killed){
80105bb1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bb7:	8b 40 28             	mov    0x28(%eax),%eax
80105bba:	85 c0                	test   %eax,%eax
80105bbc:	74 d2                	je     80105b90 <sys_sleep+0x40>
      release(&tickslock);
80105bbe:	83 ec 0c             	sub    $0xc,%esp
80105bc1:	68 00 bb 11 80       	push   $0x8011bb00
80105bc6:	e8 f5 ec ff ff       	call   801048c0 <release>
      return -1;
80105bcb:	83 c4 10             	add    $0x10,%esp
80105bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&tickslock);
  return 0;
}
80105bd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105bd6:	c9                   	leave  
80105bd7:	c3                   	ret    
80105bd8:	90                   	nop
80105bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  release(&tickslock);
80105be0:	83 ec 0c             	sub    $0xc,%esp
80105be3:	68 00 bb 11 80       	push   $0x8011bb00
80105be8:	e8 d3 ec ff ff       	call   801048c0 <release>
  return 0;
80105bed:	83 c4 10             	add    $0x10,%esp
80105bf0:	31 c0                	xor    %eax,%eax
}
80105bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105bf5:	c9                   	leave  
80105bf6:	c3                   	ret    
    return -1;
80105bf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfc:	eb f4                	jmp    80105bf2 <sys_sleep+0xa2>
80105bfe:	66 90                	xchg   %ax,%ax

80105c00 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105c00:	55                   	push   %ebp
80105c01:	89 e5                	mov    %esp,%ebp
80105c03:	53                   	push   %ebx
80105c04:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105c07:	68 00 bb 11 80       	push   $0x8011bb00
80105c0c:	e8 ef ea ff ff       	call   80104700 <acquire>
  xticks = ticks;
80105c11:	8b 1d 40 c3 11 80    	mov    0x8011c340,%ebx
  release(&tickslock);
80105c17:	c7 04 24 00 bb 11 80 	movl   $0x8011bb00,(%esp)
80105c1e:	e8 9d ec ff ff       	call   801048c0 <release>
  return xticks;
}
80105c23:	89 d8                	mov    %ebx,%eax
80105c25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105c28:	c9                   	leave  
80105c29:	c3                   	ret    
80105c2a:	66 90                	xchg   %ax,%ax
80105c2c:	66 90                	xchg   %ax,%ax
80105c2e:	66 90                	xchg   %ax,%ax

80105c30 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80105c30:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105c31:	b8 34 00 00 00       	mov    $0x34,%eax
80105c36:	ba 43 00 00 00       	mov    $0x43,%edx
80105c3b:	89 e5                	mov    %esp,%ebp
80105c3d:	83 ec 14             	sub    $0x14,%esp
80105c40:	ee                   	out    %al,(%dx)
80105c41:	ba 40 00 00 00       	mov    $0x40,%edx
80105c46:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
80105c4b:	ee                   	out    %al,(%dx)
80105c4c:	b8 2e 00 00 00       	mov    $0x2e,%eax
80105c51:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
80105c52:	6a 00                	push   $0x0
80105c54:	e8 97 d6 ff ff       	call   801032f0 <picenable>
}
80105c59:	83 c4 10             	add    $0x10,%esp
80105c5c:	c9                   	leave  
80105c5d:	c3                   	ret    

80105c5e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105c5e:	1e                   	push   %ds
  pushl %es
80105c5f:	06                   	push   %es
  pushl %fs
80105c60:	0f a0                	push   %fs
  pushl %gs
80105c62:	0f a8                	push   %gs
  pushal
80105c64:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80105c65:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105c69:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105c6b:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80105c6d:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80105c71:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80105c73:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80105c75:	54                   	push   %esp
  call trap
80105c76:	e8 c5 00 00 00       	call   80105d40 <trap>
  addl $4, %esp
80105c7b:	83 c4 04             	add    $0x4,%esp

80105c7e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105c7e:	61                   	popa   
  popl %gs
80105c7f:	0f a9                	pop    %gs
  popl %fs
80105c81:	0f a1                	pop    %fs
  popl %es
80105c83:	07                   	pop    %es
  popl %ds
80105c84:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105c85:	83 c4 08             	add    $0x8,%esp
  iret
80105c88:	cf                   	iret   
80105c89:	66 90                	xchg   %ax,%ax
80105c8b:	66 90                	xchg   %ax,%ax
80105c8d:	66 90                	xchg   %ax,%ax
80105c8f:	90                   	nop

80105c90 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105c90:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105c91:	31 c0                	xor    %eax,%eax
{
80105c93:	89 e5                	mov    %esp,%ebp
80105c95:	83 ec 08             	sub    $0x8,%esp
80105c98:	90                   	nop
80105c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105ca0:	8b 14 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%edx
80105ca7:	c7 04 c5 42 bb 11 80 	movl   $0x8e000008,-0x7fee44be(,%eax,8)
80105cae:	08 00 00 8e 
80105cb2:	66 89 14 c5 40 bb 11 	mov    %dx,-0x7fee44c0(,%eax,8)
80105cb9:	80 
80105cba:	c1 ea 10             	shr    $0x10,%edx
80105cbd:	66 89 14 c5 46 bb 11 	mov    %dx,-0x7fee44ba(,%eax,8)
80105cc4:	80 
  for(i = 0; i < 256; i++)
80105cc5:	83 c0 01             	add    $0x1,%eax
80105cc8:	3d 00 01 00 00       	cmp    $0x100,%eax
80105ccd:	75 d1                	jne    80105ca0 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105ccf:	a1 0c b1 10 80       	mov    0x8010b10c,%eax

  initlock(&tickslock, "time");
80105cd4:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105cd7:	c7 05 42 bd 11 80 08 	movl   $0xef000008,0x8011bd42
80105cde:	00 00 ef 
  initlock(&tickslock, "time");
80105ce1:	68 ed 7d 10 80       	push   $0x80107ded
80105ce6:	68 00 bb 11 80       	push   $0x8011bb00
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105ceb:	66 a3 40 bd 11 80    	mov    %ax,0x8011bd40
80105cf1:	c1 e8 10             	shr    $0x10,%eax
80105cf4:	66 a3 46 bd 11 80    	mov    %ax,0x8011bd46
  initlock(&tickslock, "time");
80105cfa:	e8 e1 e9 ff ff       	call   801046e0 <initlock>
}
80105cff:	83 c4 10             	add    $0x10,%esp
80105d02:	c9                   	leave  
80105d03:	c3                   	ret    
80105d04:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105d0a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80105d10 <idtinit>:

void
idtinit(void)
{
80105d10:	55                   	push   %ebp
  pd[0] = size-1;
80105d11:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105d16:	89 e5                	mov    %esp,%ebp
80105d18:	83 ec 10             	sub    $0x10,%esp
80105d1b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105d1f:	b8 40 bb 11 80       	mov    $0x8011bb40,%eax
80105d24:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105d28:	c1 e8 10             	shr    $0x10,%eax
80105d2b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105d2f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105d32:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105d35:	c9                   	leave  
80105d36:	c3                   	ret    
80105d37:	89 f6                	mov    %esi,%esi
80105d39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105d40 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105d40:	55                   	push   %ebp
80105d41:	89 e5                	mov    %esp,%ebp
80105d43:	57                   	push   %edi
80105d44:	56                   	push   %esi
80105d45:	53                   	push   %ebx
80105d46:	83 ec 0c             	sub    $0xc,%esp
80105d49:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105d4c:	8b 43 30             	mov    0x30(%ebx),%eax
80105d4f:	83 f8 40             	cmp    $0x40,%eax
80105d52:	74 6c                	je     80105dc0 <trap+0x80>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105d54:	83 e8 20             	sub    $0x20,%eax
80105d57:	83 f8 1f             	cmp    $0x1f,%eax
80105d5a:	0f 87 98 00 00 00    	ja     80105df8 <trap+0xb8>
80105d60:	ff 24 85 94 7e 10 80 	jmp    *-0x7fef816c(,%eax,4)
80105d67:	89 f6                	mov    %esi,%esi
80105d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  case T_IRQ0 + IRQ_TIMER:
    if(cpunum() == 0){
80105d70:	e8 ab c9 ff ff       	call   80102720 <cpunum>
80105d75:	85 c0                	test   %eax,%eax
80105d77:	0f 84 a3 01 00 00    	je     80105f20 <trap+0x1e0>
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
80105d7d:	e8 4e ca ff ff       	call   801027d0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80105d82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d88:	85 c0                	test   %eax,%eax
80105d8a:	74 29                	je     80105db5 <trap+0x75>
80105d8c:	8b 50 28             	mov    0x28(%eax),%edx
80105d8f:	85 d2                	test   %edx,%edx
80105d91:	0f 85 b6 00 00 00    	jne    80105e4d <trap+0x10d>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80105d97:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105d9b:	0f 84 3f 01 00 00    	je     80105ee0 <trap+0x1a0>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80105da1:	8b 40 28             	mov    0x28(%eax),%eax
80105da4:	85 c0                	test   %eax,%eax
80105da6:	74 0d                	je     80105db5 <trap+0x75>
80105da8:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105dac:	83 e0 03             	and    $0x3,%eax
80105daf:	66 83 f8 03          	cmp    $0x3,%ax
80105db3:	74 31                	je     80105de6 <trap+0xa6>
    exit();
}
80105db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105db8:	5b                   	pop    %ebx
80105db9:	5e                   	pop    %esi
80105dba:	5f                   	pop    %edi
80105dbb:	5d                   	pop    %ebp
80105dbc:	c3                   	ret    
80105dbd:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
80105dc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dc6:	8b 70 28             	mov    0x28(%eax),%esi
80105dc9:	85 f6                	test   %esi,%esi
80105dcb:	0f 85 37 01 00 00    	jne    80105f08 <trap+0x1c8>
    proc->tf = tf;
80105dd1:	89 58 1c             	mov    %ebx,0x1c(%eax)
    syscall();
80105dd4:	e8 27 ef ff ff       	call   80104d00 <syscall>
    if(proc->killed)
80105dd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ddf:	8b 58 28             	mov    0x28(%eax),%ebx
80105de2:	85 db                	test   %ebx,%ebx
80105de4:	74 cf                	je     80105db5 <trap+0x75>
}
80105de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105de9:	5b                   	pop    %ebx
80105dea:	5e                   	pop    %esi
80105deb:	5f                   	pop    %edi
80105dec:	5d                   	pop    %ebp
      exit();
80105ded:	e9 7e df ff ff       	jmp    80103d70 <exit>
80105df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(proc == 0 || (tf->cs&3) == 0){
80105df8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105dff:	8b 73 38             	mov    0x38(%ebx),%esi
80105e02:	85 c9                	test   %ecx,%ecx
80105e04:	0f 84 4a 01 00 00    	je     80105f54 <trap+0x214>
80105e0a:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105e0e:	0f 84 40 01 00 00    	je     80105f54 <trap+0x214>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105e14:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105e17:	e8 04 c9 ff ff       	call   80102720 <cpunum>
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
80105e1c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105e23:	57                   	push   %edi
80105e24:	56                   	push   %esi
80105e25:	50                   	push   %eax
80105e26:	ff 73 34             	pushl  0x34(%ebx)
80105e29:	ff 73 30             	pushl  0x30(%ebx)
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
80105e2c:	8d 42 70             	lea    0x70(%edx),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105e2f:	50                   	push   %eax
80105e30:	ff 72 10             	pushl  0x10(%edx)
80105e33:	68 50 7e 10 80       	push   $0x80107e50
80105e38:	e8 03 a8 ff ff       	call   80100640 <cprintf>
    proc->killed = 1;
80105e3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e43:	83 c4 20             	add    $0x20,%esp
80105e46:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80105e4d:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
80105e51:	83 e2 03             	and    $0x3,%edx
80105e54:	66 83 fa 03          	cmp    $0x3,%dx
80105e58:	0f 85 39 ff ff ff    	jne    80105d97 <trap+0x57>
    exit();
80105e5e:	e8 0d df ff ff       	call   80103d70 <exit>
80105e63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80105e69:	85 c0                	test   %eax,%eax
80105e6b:	0f 85 26 ff ff ff    	jne    80105d97 <trap+0x57>
80105e71:	e9 3f ff ff ff       	jmp    80105db5 <trap+0x75>
80105e76:	8d 76 00             	lea    0x0(%esi),%esi
80105e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    kbdintr();
80105e80:	e8 7b c7 ff ff       	call   80102600 <kbdintr>
    lapiceoi();
80105e85:	e8 46 c9 ff ff       	call   801027d0 <lapiceoi>
    break;
80105e8a:	e9 f3 fe ff ff       	jmp    80105d82 <trap+0x42>
80105e8f:	90                   	nop
    uartintr();
80105e90:	e8 5b 02 00 00       	call   801060f0 <uartintr>
80105e95:	e9 e3 fe ff ff       	jmp    80105d7d <trap+0x3d>
80105e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105ea0:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80105ea4:	8b 7b 38             	mov    0x38(%ebx),%edi
80105ea7:	e8 74 c8 ff ff       	call   80102720 <cpunum>
80105eac:	57                   	push   %edi
80105ead:	56                   	push   %esi
80105eae:	50                   	push   %eax
80105eaf:	68 f8 7d 10 80       	push   $0x80107df8
80105eb4:	e8 87 a7 ff ff       	call   80100640 <cprintf>
    lapiceoi();
80105eb9:	e8 12 c9 ff ff       	call   801027d0 <lapiceoi>
    break;
80105ebe:	83 c4 10             	add    $0x10,%esp
80105ec1:	e9 bc fe ff ff       	jmp    80105d82 <trap+0x42>
80105ec6:	8d 76 00             	lea    0x0(%esi),%esi
80105ec9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ideintr();
80105ed0:	e8 8b c1 ff ff       	call   80102060 <ideintr>
    lapiceoi();
80105ed5:	e8 f6 c8 ff ff       	call   801027d0 <lapiceoi>
    break;
80105eda:	e9 a3 fe ff ff       	jmp    80105d82 <trap+0x42>
80105edf:	90                   	nop
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80105ee0:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105ee4:	0f 85 b7 fe ff ff    	jne    80105da1 <trap+0x61>
    yield();
80105eea:	e8 11 e0 ff ff       	call   80103f00 <yield>
80105eef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80105ef5:	85 c0                	test   %eax,%eax
80105ef7:	0f 85 a4 fe ff ff    	jne    80105da1 <trap+0x61>
80105efd:	e9 b3 fe ff ff       	jmp    80105db5 <trap+0x75>
80105f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80105f08:	e8 63 de ff ff       	call   80103d70 <exit>
80105f0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f13:	e9 b9 fe ff ff       	jmp    80105dd1 <trap+0x91>
80105f18:	90                   	nop
80105f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      acquire(&tickslock);
80105f20:	83 ec 0c             	sub    $0xc,%esp
80105f23:	68 00 bb 11 80       	push   $0x8011bb00
80105f28:	e8 d3 e7 ff ff       	call   80104700 <acquire>
      wakeup(&ticks);
80105f2d:	c7 04 24 40 c3 11 80 	movl   $0x8011c340,(%esp)
      ticks++;
80105f34:	83 05 40 c3 11 80 01 	addl   $0x1,0x8011c340
      wakeup(&ticks);
80105f3b:	e8 b0 e1 ff ff       	call   801040f0 <wakeup>
      release(&tickslock);
80105f40:	c7 04 24 00 bb 11 80 	movl   $0x8011bb00,(%esp)
80105f47:	e8 74 e9 ff ff       	call   801048c0 <release>
80105f4c:	83 c4 10             	add    $0x10,%esp
80105f4f:	e9 29 fe ff ff       	jmp    80105d7d <trap+0x3d>
80105f54:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105f57:	e8 c4 c7 ff ff       	call   80102720 <cpunum>
80105f5c:	83 ec 0c             	sub    $0xc,%esp
80105f5f:	57                   	push   %edi
80105f60:	56                   	push   %esi
80105f61:	50                   	push   %eax
80105f62:	ff 73 30             	pushl  0x30(%ebx)
80105f65:	68 1c 7e 10 80       	push   $0x80107e1c
80105f6a:	e8 d1 a6 ff ff       	call   80100640 <cprintf>
      panic("trap");
80105f6f:	83 c4 14             	add    $0x14,%esp
80105f72:	68 f2 7d 10 80       	push   $0x80107df2
80105f77:	e8 f4 a3 ff ff       	call   80100370 <panic>
80105f7c:	66 90                	xchg   %ax,%ax
80105f7e:	66 90                	xchg   %ax,%ax

80105f80 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105f80:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
{
80105f85:	55                   	push   %ebp
80105f86:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105f88:	85 c0                	test   %eax,%eax
80105f8a:	74 1c                	je     80105fa8 <uartgetc+0x28>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105f8c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105f91:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105f92:	a8 01                	test   $0x1,%al
80105f94:	74 12                	je     80105fa8 <uartgetc+0x28>
80105f96:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105f9b:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105f9c:	0f b6 c0             	movzbl %al,%eax
}
80105f9f:	5d                   	pop    %ebp
80105fa0:	c3                   	ret    
80105fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105fa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fad:	5d                   	pop    %ebp
80105fae:	c3                   	ret    
80105faf:	90                   	nop

80105fb0 <uartputc.part.0>:
uartputc(int c)
80105fb0:	55                   	push   %ebp
80105fb1:	89 e5                	mov    %esp,%ebp
80105fb3:	57                   	push   %edi
80105fb4:	56                   	push   %esi
80105fb5:	53                   	push   %ebx
80105fb6:	89 c7                	mov    %eax,%edi
80105fb8:	bb 80 00 00 00       	mov    $0x80,%ebx
80105fbd:	be fd 03 00 00       	mov    $0x3fd,%esi
80105fc2:	83 ec 0c             	sub    $0xc,%esp
80105fc5:	eb 1b                	jmp    80105fe2 <uartputc.part.0+0x32>
80105fc7:	89 f6                	mov    %esi,%esi
80105fc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    microdelay(10);
80105fd0:	83 ec 0c             	sub    $0xc,%esp
80105fd3:	6a 0a                	push   $0xa
80105fd5:	e8 16 c8 ff ff       	call   801027f0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105fda:	83 c4 10             	add    $0x10,%esp
80105fdd:	83 eb 01             	sub    $0x1,%ebx
80105fe0:	74 07                	je     80105fe9 <uartputc.part.0+0x39>
80105fe2:	89 f2                	mov    %esi,%edx
80105fe4:	ec                   	in     (%dx),%al
80105fe5:	a8 20                	test   $0x20,%al
80105fe7:	74 e7                	je     80105fd0 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105fe9:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105fee:	89 f8                	mov    %edi,%eax
80105ff0:	ee                   	out    %al,(%dx)
}
80105ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ff4:	5b                   	pop    %ebx
80105ff5:	5e                   	pop    %esi
80105ff6:	5f                   	pop    %edi
80105ff7:	5d                   	pop    %ebp
80105ff8:	c3                   	ret    
80105ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106000 <uartinit>:
{
80106000:	55                   	push   %ebp
80106001:	31 c9                	xor    %ecx,%ecx
80106003:	89 c8                	mov    %ecx,%eax
80106005:	89 e5                	mov    %esp,%ebp
80106007:	57                   	push   %edi
80106008:	56                   	push   %esi
80106009:	53                   	push   %ebx
8010600a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
8010600f:	89 da                	mov    %ebx,%edx
80106011:	83 ec 0c             	sub    $0xc,%esp
80106014:	ee                   	out    %al,(%dx)
80106015:	bf fb 03 00 00       	mov    $0x3fb,%edi
8010601a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010601f:	89 fa                	mov    %edi,%edx
80106021:	ee                   	out    %al,(%dx)
80106022:	b8 0c 00 00 00       	mov    $0xc,%eax
80106027:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010602c:	ee                   	out    %al,(%dx)
8010602d:	be f9 03 00 00       	mov    $0x3f9,%esi
80106032:	89 c8                	mov    %ecx,%eax
80106034:	89 f2                	mov    %esi,%edx
80106036:	ee                   	out    %al,(%dx)
80106037:	b8 03 00 00 00       	mov    $0x3,%eax
8010603c:	89 fa                	mov    %edi,%edx
8010603e:	ee                   	out    %al,(%dx)
8010603f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106044:	89 c8                	mov    %ecx,%eax
80106046:	ee                   	out    %al,(%dx)
80106047:	b8 01 00 00 00       	mov    $0x1,%eax
8010604c:	89 f2                	mov    %esi,%edx
8010604e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010604f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106054:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80106055:	3c ff                	cmp    $0xff,%al
80106057:	74 5a                	je     801060b3 <uartinit+0xb3>
  uart = 1;
80106059:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
80106060:	00 00 00 
80106063:	89 da                	mov    %ebx,%edx
80106065:	ec                   	in     (%dx),%al
80106066:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010606b:	ec                   	in     (%dx),%al
  picenable(IRQ_COM1);
8010606c:	83 ec 0c             	sub    $0xc,%esp
8010606f:	6a 04                	push   $0x4
80106071:	e8 7a d2 ff ff       	call   801032f0 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106076:	59                   	pop    %ecx
80106077:	5b                   	pop    %ebx
80106078:	6a 00                	push   $0x0
8010607a:	6a 04                	push   $0x4
  for(p="xv6...\n"; *p; p++)
8010607c:	bb 14 7f 10 80       	mov    $0x80107f14,%ebx
  ioapicenable(IRQ_COM1, 0);
80106081:	e8 3a c2 ff ff       	call   801022c0 <ioapicenable>
80106086:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106089:	b8 78 00 00 00       	mov    $0x78,%eax
8010608e:	eb 0a                	jmp    8010609a <uartinit+0x9a>
80106090:	83 c3 01             	add    $0x1,%ebx
80106093:	0f be 03             	movsbl (%ebx),%eax
80106096:	84 c0                	test   %al,%al
80106098:	74 19                	je     801060b3 <uartinit+0xb3>
  if(!uart)
8010609a:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
801060a0:	85 d2                	test   %edx,%edx
801060a2:	74 ec                	je     80106090 <uartinit+0x90>
  for(p="xv6...\n"; *p; p++)
801060a4:	83 c3 01             	add    $0x1,%ebx
801060a7:	e8 04 ff ff ff       	call   80105fb0 <uartputc.part.0>
801060ac:	0f be 03             	movsbl (%ebx),%eax
801060af:	84 c0                	test   %al,%al
801060b1:	75 e7                	jne    8010609a <uartinit+0x9a>
}
801060b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060b6:	5b                   	pop    %ebx
801060b7:	5e                   	pop    %esi
801060b8:	5f                   	pop    %edi
801060b9:	5d                   	pop    %ebp
801060ba:	c3                   	ret    
801060bb:	90                   	nop
801060bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801060c0 <uartputc>:
  if(!uart)
801060c0:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
{
801060c6:	55                   	push   %ebp
801060c7:	89 e5                	mov    %esp,%ebp
  if(!uart)
801060c9:	85 d2                	test   %edx,%edx
{
801060cb:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
801060ce:	74 10                	je     801060e0 <uartputc+0x20>
}
801060d0:	5d                   	pop    %ebp
801060d1:	e9 da fe ff ff       	jmp    80105fb0 <uartputc.part.0>
801060d6:	8d 76 00             	lea    0x0(%esi),%esi
801060d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801060e0:	5d                   	pop    %ebp
801060e1:	c3                   	ret    
801060e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801060e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801060f0 <uartintr>:

void
uartintr(void)
{
801060f0:	55                   	push   %ebp
801060f1:	89 e5                	mov    %esp,%ebp
801060f3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801060f6:	68 80 5f 10 80       	push   $0x80105f80
801060fb:	e8 f0 a6 ff ff       	call   801007f0 <consoleintr>
}
80106100:	83 c4 10             	add    $0x10,%esp
80106103:	c9                   	leave  
80106104:	c3                   	ret    

80106105 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106105:	6a 00                	push   $0x0
  pushl $0
80106107:	6a 00                	push   $0x0
  jmp alltraps
80106109:	e9 50 fb ff ff       	jmp    80105c5e <alltraps>

8010610e <vector1>:
.globl vector1
vector1:
  pushl $0
8010610e:	6a 00                	push   $0x0
  pushl $1
80106110:	6a 01                	push   $0x1
  jmp alltraps
80106112:	e9 47 fb ff ff       	jmp    80105c5e <alltraps>

80106117 <vector2>:
.globl vector2
vector2:
  pushl $0
80106117:	6a 00                	push   $0x0
  pushl $2
80106119:	6a 02                	push   $0x2
  jmp alltraps
8010611b:	e9 3e fb ff ff       	jmp    80105c5e <alltraps>

80106120 <vector3>:
.globl vector3
vector3:
  pushl $0
80106120:	6a 00                	push   $0x0
  pushl $3
80106122:	6a 03                	push   $0x3
  jmp alltraps
80106124:	e9 35 fb ff ff       	jmp    80105c5e <alltraps>

80106129 <vector4>:
.globl vector4
vector4:
  pushl $0
80106129:	6a 00                	push   $0x0
  pushl $4
8010612b:	6a 04                	push   $0x4
  jmp alltraps
8010612d:	e9 2c fb ff ff       	jmp    80105c5e <alltraps>

80106132 <vector5>:
.globl vector5
vector5:
  pushl $0
80106132:	6a 00                	push   $0x0
  pushl $5
80106134:	6a 05                	push   $0x5
  jmp alltraps
80106136:	e9 23 fb ff ff       	jmp    80105c5e <alltraps>

8010613b <vector6>:
.globl vector6
vector6:
  pushl $0
8010613b:	6a 00                	push   $0x0
  pushl $6
8010613d:	6a 06                	push   $0x6
  jmp alltraps
8010613f:	e9 1a fb ff ff       	jmp    80105c5e <alltraps>

80106144 <vector7>:
.globl vector7
vector7:
  pushl $0
80106144:	6a 00                	push   $0x0
  pushl $7
80106146:	6a 07                	push   $0x7
  jmp alltraps
80106148:	e9 11 fb ff ff       	jmp    80105c5e <alltraps>

8010614d <vector8>:
.globl vector8
vector8:
  pushl $8
8010614d:	6a 08                	push   $0x8
  jmp alltraps
8010614f:	e9 0a fb ff ff       	jmp    80105c5e <alltraps>

80106154 <vector9>:
.globl vector9
vector9:
  pushl $0
80106154:	6a 00                	push   $0x0
  pushl $9
80106156:	6a 09                	push   $0x9
  jmp alltraps
80106158:	e9 01 fb ff ff       	jmp    80105c5e <alltraps>

8010615d <vector10>:
.globl vector10
vector10:
  pushl $10
8010615d:	6a 0a                	push   $0xa
  jmp alltraps
8010615f:	e9 fa fa ff ff       	jmp    80105c5e <alltraps>

80106164 <vector11>:
.globl vector11
vector11:
  pushl $11
80106164:	6a 0b                	push   $0xb
  jmp alltraps
80106166:	e9 f3 fa ff ff       	jmp    80105c5e <alltraps>

8010616b <vector12>:
.globl vector12
vector12:
  pushl $12
8010616b:	6a 0c                	push   $0xc
  jmp alltraps
8010616d:	e9 ec fa ff ff       	jmp    80105c5e <alltraps>

80106172 <vector13>:
.globl vector13
vector13:
  pushl $13
80106172:	6a 0d                	push   $0xd
  jmp alltraps
80106174:	e9 e5 fa ff ff       	jmp    80105c5e <alltraps>

80106179 <vector14>:
.globl vector14
vector14:
  pushl $14
80106179:	6a 0e                	push   $0xe
  jmp alltraps
8010617b:	e9 de fa ff ff       	jmp    80105c5e <alltraps>

80106180 <vector15>:
.globl vector15
vector15:
  pushl $0
80106180:	6a 00                	push   $0x0
  pushl $15
80106182:	6a 0f                	push   $0xf
  jmp alltraps
80106184:	e9 d5 fa ff ff       	jmp    80105c5e <alltraps>

80106189 <vector16>:
.globl vector16
vector16:
  pushl $0
80106189:	6a 00                	push   $0x0
  pushl $16
8010618b:	6a 10                	push   $0x10
  jmp alltraps
8010618d:	e9 cc fa ff ff       	jmp    80105c5e <alltraps>

80106192 <vector17>:
.globl vector17
vector17:
  pushl $17
80106192:	6a 11                	push   $0x11
  jmp alltraps
80106194:	e9 c5 fa ff ff       	jmp    80105c5e <alltraps>

80106199 <vector18>:
.globl vector18
vector18:
  pushl $0
80106199:	6a 00                	push   $0x0
  pushl $18
8010619b:	6a 12                	push   $0x12
  jmp alltraps
8010619d:	e9 bc fa ff ff       	jmp    80105c5e <alltraps>

801061a2 <vector19>:
.globl vector19
vector19:
  pushl $0
801061a2:	6a 00                	push   $0x0
  pushl $19
801061a4:	6a 13                	push   $0x13
  jmp alltraps
801061a6:	e9 b3 fa ff ff       	jmp    80105c5e <alltraps>

801061ab <vector20>:
.globl vector20
vector20:
  pushl $0
801061ab:	6a 00                	push   $0x0
  pushl $20
801061ad:	6a 14                	push   $0x14
  jmp alltraps
801061af:	e9 aa fa ff ff       	jmp    80105c5e <alltraps>

801061b4 <vector21>:
.globl vector21
vector21:
  pushl $0
801061b4:	6a 00                	push   $0x0
  pushl $21
801061b6:	6a 15                	push   $0x15
  jmp alltraps
801061b8:	e9 a1 fa ff ff       	jmp    80105c5e <alltraps>

801061bd <vector22>:
.globl vector22
vector22:
  pushl $0
801061bd:	6a 00                	push   $0x0
  pushl $22
801061bf:	6a 16                	push   $0x16
  jmp alltraps
801061c1:	e9 98 fa ff ff       	jmp    80105c5e <alltraps>

801061c6 <vector23>:
.globl vector23
vector23:
  pushl $0
801061c6:	6a 00                	push   $0x0
  pushl $23
801061c8:	6a 17                	push   $0x17
  jmp alltraps
801061ca:	e9 8f fa ff ff       	jmp    80105c5e <alltraps>

801061cf <vector24>:
.globl vector24
vector24:
  pushl $0
801061cf:	6a 00                	push   $0x0
  pushl $24
801061d1:	6a 18                	push   $0x18
  jmp alltraps
801061d3:	e9 86 fa ff ff       	jmp    80105c5e <alltraps>

801061d8 <vector25>:
.globl vector25
vector25:
  pushl $0
801061d8:	6a 00                	push   $0x0
  pushl $25
801061da:	6a 19                	push   $0x19
  jmp alltraps
801061dc:	e9 7d fa ff ff       	jmp    80105c5e <alltraps>

801061e1 <vector26>:
.globl vector26
vector26:
  pushl $0
801061e1:	6a 00                	push   $0x0
  pushl $26
801061e3:	6a 1a                	push   $0x1a
  jmp alltraps
801061e5:	e9 74 fa ff ff       	jmp    80105c5e <alltraps>

801061ea <vector27>:
.globl vector27
vector27:
  pushl $0
801061ea:	6a 00                	push   $0x0
  pushl $27
801061ec:	6a 1b                	push   $0x1b
  jmp alltraps
801061ee:	e9 6b fa ff ff       	jmp    80105c5e <alltraps>

801061f3 <vector28>:
.globl vector28
vector28:
  pushl $0
801061f3:	6a 00                	push   $0x0
  pushl $28
801061f5:	6a 1c                	push   $0x1c
  jmp alltraps
801061f7:	e9 62 fa ff ff       	jmp    80105c5e <alltraps>

801061fc <vector29>:
.globl vector29
vector29:
  pushl $0
801061fc:	6a 00                	push   $0x0
  pushl $29
801061fe:	6a 1d                	push   $0x1d
  jmp alltraps
80106200:	e9 59 fa ff ff       	jmp    80105c5e <alltraps>

80106205 <vector30>:
.globl vector30
vector30:
  pushl $0
80106205:	6a 00                	push   $0x0
  pushl $30
80106207:	6a 1e                	push   $0x1e
  jmp alltraps
80106209:	e9 50 fa ff ff       	jmp    80105c5e <alltraps>

8010620e <vector31>:
.globl vector31
vector31:
  pushl $0
8010620e:	6a 00                	push   $0x0
  pushl $31
80106210:	6a 1f                	push   $0x1f
  jmp alltraps
80106212:	e9 47 fa ff ff       	jmp    80105c5e <alltraps>

80106217 <vector32>:
.globl vector32
vector32:
  pushl $0
80106217:	6a 00                	push   $0x0
  pushl $32
80106219:	6a 20                	push   $0x20
  jmp alltraps
8010621b:	e9 3e fa ff ff       	jmp    80105c5e <alltraps>

80106220 <vector33>:
.globl vector33
vector33:
  pushl $0
80106220:	6a 00                	push   $0x0
  pushl $33
80106222:	6a 21                	push   $0x21
  jmp alltraps
80106224:	e9 35 fa ff ff       	jmp    80105c5e <alltraps>

80106229 <vector34>:
.globl vector34
vector34:
  pushl $0
80106229:	6a 00                	push   $0x0
  pushl $34
8010622b:	6a 22                	push   $0x22
  jmp alltraps
8010622d:	e9 2c fa ff ff       	jmp    80105c5e <alltraps>

80106232 <vector35>:
.globl vector35
vector35:
  pushl $0
80106232:	6a 00                	push   $0x0
  pushl $35
80106234:	6a 23                	push   $0x23
  jmp alltraps
80106236:	e9 23 fa ff ff       	jmp    80105c5e <alltraps>

8010623b <vector36>:
.globl vector36
vector36:
  pushl $0
8010623b:	6a 00                	push   $0x0
  pushl $36
8010623d:	6a 24                	push   $0x24
  jmp alltraps
8010623f:	e9 1a fa ff ff       	jmp    80105c5e <alltraps>

80106244 <vector37>:
.globl vector37
vector37:
  pushl $0
80106244:	6a 00                	push   $0x0
  pushl $37
80106246:	6a 25                	push   $0x25
  jmp alltraps
80106248:	e9 11 fa ff ff       	jmp    80105c5e <alltraps>

8010624d <vector38>:
.globl vector38
vector38:
  pushl $0
8010624d:	6a 00                	push   $0x0
  pushl $38
8010624f:	6a 26                	push   $0x26
  jmp alltraps
80106251:	e9 08 fa ff ff       	jmp    80105c5e <alltraps>

80106256 <vector39>:
.globl vector39
vector39:
  pushl $0
80106256:	6a 00                	push   $0x0
  pushl $39
80106258:	6a 27                	push   $0x27
  jmp alltraps
8010625a:	e9 ff f9 ff ff       	jmp    80105c5e <alltraps>

8010625f <vector40>:
.globl vector40
vector40:
  pushl $0
8010625f:	6a 00                	push   $0x0
  pushl $40
80106261:	6a 28                	push   $0x28
  jmp alltraps
80106263:	e9 f6 f9 ff ff       	jmp    80105c5e <alltraps>

80106268 <vector41>:
.globl vector41
vector41:
  pushl $0
80106268:	6a 00                	push   $0x0
  pushl $41
8010626a:	6a 29                	push   $0x29
  jmp alltraps
8010626c:	e9 ed f9 ff ff       	jmp    80105c5e <alltraps>

80106271 <vector42>:
.globl vector42
vector42:
  pushl $0
80106271:	6a 00                	push   $0x0
  pushl $42
80106273:	6a 2a                	push   $0x2a
  jmp alltraps
80106275:	e9 e4 f9 ff ff       	jmp    80105c5e <alltraps>

8010627a <vector43>:
.globl vector43
vector43:
  pushl $0
8010627a:	6a 00                	push   $0x0
  pushl $43
8010627c:	6a 2b                	push   $0x2b
  jmp alltraps
8010627e:	e9 db f9 ff ff       	jmp    80105c5e <alltraps>

80106283 <vector44>:
.globl vector44
vector44:
  pushl $0
80106283:	6a 00                	push   $0x0
  pushl $44
80106285:	6a 2c                	push   $0x2c
  jmp alltraps
80106287:	e9 d2 f9 ff ff       	jmp    80105c5e <alltraps>

8010628c <vector45>:
.globl vector45
vector45:
  pushl $0
8010628c:	6a 00                	push   $0x0
  pushl $45
8010628e:	6a 2d                	push   $0x2d
  jmp alltraps
80106290:	e9 c9 f9 ff ff       	jmp    80105c5e <alltraps>

80106295 <vector46>:
.globl vector46
vector46:
  pushl $0
80106295:	6a 00                	push   $0x0
  pushl $46
80106297:	6a 2e                	push   $0x2e
  jmp alltraps
80106299:	e9 c0 f9 ff ff       	jmp    80105c5e <alltraps>

8010629e <vector47>:
.globl vector47
vector47:
  pushl $0
8010629e:	6a 00                	push   $0x0
  pushl $47
801062a0:	6a 2f                	push   $0x2f
  jmp alltraps
801062a2:	e9 b7 f9 ff ff       	jmp    80105c5e <alltraps>

801062a7 <vector48>:
.globl vector48
vector48:
  pushl $0
801062a7:	6a 00                	push   $0x0
  pushl $48
801062a9:	6a 30                	push   $0x30
  jmp alltraps
801062ab:	e9 ae f9 ff ff       	jmp    80105c5e <alltraps>

801062b0 <vector49>:
.globl vector49
vector49:
  pushl $0
801062b0:	6a 00                	push   $0x0
  pushl $49
801062b2:	6a 31                	push   $0x31
  jmp alltraps
801062b4:	e9 a5 f9 ff ff       	jmp    80105c5e <alltraps>

801062b9 <vector50>:
.globl vector50
vector50:
  pushl $0
801062b9:	6a 00                	push   $0x0
  pushl $50
801062bb:	6a 32                	push   $0x32
  jmp alltraps
801062bd:	e9 9c f9 ff ff       	jmp    80105c5e <alltraps>

801062c2 <vector51>:
.globl vector51
vector51:
  pushl $0
801062c2:	6a 00                	push   $0x0
  pushl $51
801062c4:	6a 33                	push   $0x33
  jmp alltraps
801062c6:	e9 93 f9 ff ff       	jmp    80105c5e <alltraps>

801062cb <vector52>:
.globl vector52
vector52:
  pushl $0
801062cb:	6a 00                	push   $0x0
  pushl $52
801062cd:	6a 34                	push   $0x34
  jmp alltraps
801062cf:	e9 8a f9 ff ff       	jmp    80105c5e <alltraps>

801062d4 <vector53>:
.globl vector53
vector53:
  pushl $0
801062d4:	6a 00                	push   $0x0
  pushl $53
801062d6:	6a 35                	push   $0x35
  jmp alltraps
801062d8:	e9 81 f9 ff ff       	jmp    80105c5e <alltraps>

801062dd <vector54>:
.globl vector54
vector54:
  pushl $0
801062dd:	6a 00                	push   $0x0
  pushl $54
801062df:	6a 36                	push   $0x36
  jmp alltraps
801062e1:	e9 78 f9 ff ff       	jmp    80105c5e <alltraps>

801062e6 <vector55>:
.globl vector55
vector55:
  pushl $0
801062e6:	6a 00                	push   $0x0
  pushl $55
801062e8:	6a 37                	push   $0x37
  jmp alltraps
801062ea:	e9 6f f9 ff ff       	jmp    80105c5e <alltraps>

801062ef <vector56>:
.globl vector56
vector56:
  pushl $0
801062ef:	6a 00                	push   $0x0
  pushl $56
801062f1:	6a 38                	push   $0x38
  jmp alltraps
801062f3:	e9 66 f9 ff ff       	jmp    80105c5e <alltraps>

801062f8 <vector57>:
.globl vector57
vector57:
  pushl $0
801062f8:	6a 00                	push   $0x0
  pushl $57
801062fa:	6a 39                	push   $0x39
  jmp alltraps
801062fc:	e9 5d f9 ff ff       	jmp    80105c5e <alltraps>

80106301 <vector58>:
.globl vector58
vector58:
  pushl $0
80106301:	6a 00                	push   $0x0
  pushl $58
80106303:	6a 3a                	push   $0x3a
  jmp alltraps
80106305:	e9 54 f9 ff ff       	jmp    80105c5e <alltraps>

8010630a <vector59>:
.globl vector59
vector59:
  pushl $0
8010630a:	6a 00                	push   $0x0
  pushl $59
8010630c:	6a 3b                	push   $0x3b
  jmp alltraps
8010630e:	e9 4b f9 ff ff       	jmp    80105c5e <alltraps>

80106313 <vector60>:
.globl vector60
vector60:
  pushl $0
80106313:	6a 00                	push   $0x0
  pushl $60
80106315:	6a 3c                	push   $0x3c
  jmp alltraps
80106317:	e9 42 f9 ff ff       	jmp    80105c5e <alltraps>

8010631c <vector61>:
.globl vector61
vector61:
  pushl $0
8010631c:	6a 00                	push   $0x0
  pushl $61
8010631e:	6a 3d                	push   $0x3d
  jmp alltraps
80106320:	e9 39 f9 ff ff       	jmp    80105c5e <alltraps>

80106325 <vector62>:
.globl vector62
vector62:
  pushl $0
80106325:	6a 00                	push   $0x0
  pushl $62
80106327:	6a 3e                	push   $0x3e
  jmp alltraps
80106329:	e9 30 f9 ff ff       	jmp    80105c5e <alltraps>

8010632e <vector63>:
.globl vector63
vector63:
  pushl $0
8010632e:	6a 00                	push   $0x0
  pushl $63
80106330:	6a 3f                	push   $0x3f
  jmp alltraps
80106332:	e9 27 f9 ff ff       	jmp    80105c5e <alltraps>

80106337 <vector64>:
.globl vector64
vector64:
  pushl $0
80106337:	6a 00                	push   $0x0
  pushl $64
80106339:	6a 40                	push   $0x40
  jmp alltraps
8010633b:	e9 1e f9 ff ff       	jmp    80105c5e <alltraps>

80106340 <vector65>:
.globl vector65
vector65:
  pushl $0
80106340:	6a 00                	push   $0x0
  pushl $65
80106342:	6a 41                	push   $0x41
  jmp alltraps
80106344:	e9 15 f9 ff ff       	jmp    80105c5e <alltraps>

80106349 <vector66>:
.globl vector66
vector66:
  pushl $0
80106349:	6a 00                	push   $0x0
  pushl $66
8010634b:	6a 42                	push   $0x42
  jmp alltraps
8010634d:	e9 0c f9 ff ff       	jmp    80105c5e <alltraps>

80106352 <vector67>:
.globl vector67
vector67:
  pushl $0
80106352:	6a 00                	push   $0x0
  pushl $67
80106354:	6a 43                	push   $0x43
  jmp alltraps
80106356:	e9 03 f9 ff ff       	jmp    80105c5e <alltraps>

8010635b <vector68>:
.globl vector68
vector68:
  pushl $0
8010635b:	6a 00                	push   $0x0
  pushl $68
8010635d:	6a 44                	push   $0x44
  jmp alltraps
8010635f:	e9 fa f8 ff ff       	jmp    80105c5e <alltraps>

80106364 <vector69>:
.globl vector69
vector69:
  pushl $0
80106364:	6a 00                	push   $0x0
  pushl $69
80106366:	6a 45                	push   $0x45
  jmp alltraps
80106368:	e9 f1 f8 ff ff       	jmp    80105c5e <alltraps>

8010636d <vector70>:
.globl vector70
vector70:
  pushl $0
8010636d:	6a 00                	push   $0x0
  pushl $70
8010636f:	6a 46                	push   $0x46
  jmp alltraps
80106371:	e9 e8 f8 ff ff       	jmp    80105c5e <alltraps>

80106376 <vector71>:
.globl vector71
vector71:
  pushl $0
80106376:	6a 00                	push   $0x0
  pushl $71
80106378:	6a 47                	push   $0x47
  jmp alltraps
8010637a:	e9 df f8 ff ff       	jmp    80105c5e <alltraps>

8010637f <vector72>:
.globl vector72
vector72:
  pushl $0
8010637f:	6a 00                	push   $0x0
  pushl $72
80106381:	6a 48                	push   $0x48
  jmp alltraps
80106383:	e9 d6 f8 ff ff       	jmp    80105c5e <alltraps>

80106388 <vector73>:
.globl vector73
vector73:
  pushl $0
80106388:	6a 00                	push   $0x0
  pushl $73
8010638a:	6a 49                	push   $0x49
  jmp alltraps
8010638c:	e9 cd f8 ff ff       	jmp    80105c5e <alltraps>

80106391 <vector74>:
.globl vector74
vector74:
  pushl $0
80106391:	6a 00                	push   $0x0
  pushl $74
80106393:	6a 4a                	push   $0x4a
  jmp alltraps
80106395:	e9 c4 f8 ff ff       	jmp    80105c5e <alltraps>

8010639a <vector75>:
.globl vector75
vector75:
  pushl $0
8010639a:	6a 00                	push   $0x0
  pushl $75
8010639c:	6a 4b                	push   $0x4b
  jmp alltraps
8010639e:	e9 bb f8 ff ff       	jmp    80105c5e <alltraps>

801063a3 <vector76>:
.globl vector76
vector76:
  pushl $0
801063a3:	6a 00                	push   $0x0
  pushl $76
801063a5:	6a 4c                	push   $0x4c
  jmp alltraps
801063a7:	e9 b2 f8 ff ff       	jmp    80105c5e <alltraps>

801063ac <vector77>:
.globl vector77
vector77:
  pushl $0
801063ac:	6a 00                	push   $0x0
  pushl $77
801063ae:	6a 4d                	push   $0x4d
  jmp alltraps
801063b0:	e9 a9 f8 ff ff       	jmp    80105c5e <alltraps>

801063b5 <vector78>:
.globl vector78
vector78:
  pushl $0
801063b5:	6a 00                	push   $0x0
  pushl $78
801063b7:	6a 4e                	push   $0x4e
  jmp alltraps
801063b9:	e9 a0 f8 ff ff       	jmp    80105c5e <alltraps>

801063be <vector79>:
.globl vector79
vector79:
  pushl $0
801063be:	6a 00                	push   $0x0
  pushl $79
801063c0:	6a 4f                	push   $0x4f
  jmp alltraps
801063c2:	e9 97 f8 ff ff       	jmp    80105c5e <alltraps>

801063c7 <vector80>:
.globl vector80
vector80:
  pushl $0
801063c7:	6a 00                	push   $0x0
  pushl $80
801063c9:	6a 50                	push   $0x50
  jmp alltraps
801063cb:	e9 8e f8 ff ff       	jmp    80105c5e <alltraps>

801063d0 <vector81>:
.globl vector81
vector81:
  pushl $0
801063d0:	6a 00                	push   $0x0
  pushl $81
801063d2:	6a 51                	push   $0x51
  jmp alltraps
801063d4:	e9 85 f8 ff ff       	jmp    80105c5e <alltraps>

801063d9 <vector82>:
.globl vector82
vector82:
  pushl $0
801063d9:	6a 00                	push   $0x0
  pushl $82
801063db:	6a 52                	push   $0x52
  jmp alltraps
801063dd:	e9 7c f8 ff ff       	jmp    80105c5e <alltraps>

801063e2 <vector83>:
.globl vector83
vector83:
  pushl $0
801063e2:	6a 00                	push   $0x0
  pushl $83
801063e4:	6a 53                	push   $0x53
  jmp alltraps
801063e6:	e9 73 f8 ff ff       	jmp    80105c5e <alltraps>

801063eb <vector84>:
.globl vector84
vector84:
  pushl $0
801063eb:	6a 00                	push   $0x0
  pushl $84
801063ed:	6a 54                	push   $0x54
  jmp alltraps
801063ef:	e9 6a f8 ff ff       	jmp    80105c5e <alltraps>

801063f4 <vector85>:
.globl vector85
vector85:
  pushl $0
801063f4:	6a 00                	push   $0x0
  pushl $85
801063f6:	6a 55                	push   $0x55
  jmp alltraps
801063f8:	e9 61 f8 ff ff       	jmp    80105c5e <alltraps>

801063fd <vector86>:
.globl vector86
vector86:
  pushl $0
801063fd:	6a 00                	push   $0x0
  pushl $86
801063ff:	6a 56                	push   $0x56
  jmp alltraps
80106401:	e9 58 f8 ff ff       	jmp    80105c5e <alltraps>

80106406 <vector87>:
.globl vector87
vector87:
  pushl $0
80106406:	6a 00                	push   $0x0
  pushl $87
80106408:	6a 57                	push   $0x57
  jmp alltraps
8010640a:	e9 4f f8 ff ff       	jmp    80105c5e <alltraps>

8010640f <vector88>:
.globl vector88
vector88:
  pushl $0
8010640f:	6a 00                	push   $0x0
  pushl $88
80106411:	6a 58                	push   $0x58
  jmp alltraps
80106413:	e9 46 f8 ff ff       	jmp    80105c5e <alltraps>

80106418 <vector89>:
.globl vector89
vector89:
  pushl $0
80106418:	6a 00                	push   $0x0
  pushl $89
8010641a:	6a 59                	push   $0x59
  jmp alltraps
8010641c:	e9 3d f8 ff ff       	jmp    80105c5e <alltraps>

80106421 <vector90>:
.globl vector90
vector90:
  pushl $0
80106421:	6a 00                	push   $0x0
  pushl $90
80106423:	6a 5a                	push   $0x5a
  jmp alltraps
80106425:	e9 34 f8 ff ff       	jmp    80105c5e <alltraps>

8010642a <vector91>:
.globl vector91
vector91:
  pushl $0
8010642a:	6a 00                	push   $0x0
  pushl $91
8010642c:	6a 5b                	push   $0x5b
  jmp alltraps
8010642e:	e9 2b f8 ff ff       	jmp    80105c5e <alltraps>

80106433 <vector92>:
.globl vector92
vector92:
  pushl $0
80106433:	6a 00                	push   $0x0
  pushl $92
80106435:	6a 5c                	push   $0x5c
  jmp alltraps
80106437:	e9 22 f8 ff ff       	jmp    80105c5e <alltraps>

8010643c <vector93>:
.globl vector93
vector93:
  pushl $0
8010643c:	6a 00                	push   $0x0
  pushl $93
8010643e:	6a 5d                	push   $0x5d
  jmp alltraps
80106440:	e9 19 f8 ff ff       	jmp    80105c5e <alltraps>

80106445 <vector94>:
.globl vector94
vector94:
  pushl $0
80106445:	6a 00                	push   $0x0
  pushl $94
80106447:	6a 5e                	push   $0x5e
  jmp alltraps
80106449:	e9 10 f8 ff ff       	jmp    80105c5e <alltraps>

8010644e <vector95>:
.globl vector95
vector95:
  pushl $0
8010644e:	6a 00                	push   $0x0
  pushl $95
80106450:	6a 5f                	push   $0x5f
  jmp alltraps
80106452:	e9 07 f8 ff ff       	jmp    80105c5e <alltraps>

80106457 <vector96>:
.globl vector96
vector96:
  pushl $0
80106457:	6a 00                	push   $0x0
  pushl $96
80106459:	6a 60                	push   $0x60
  jmp alltraps
8010645b:	e9 fe f7 ff ff       	jmp    80105c5e <alltraps>

80106460 <vector97>:
.globl vector97
vector97:
  pushl $0
80106460:	6a 00                	push   $0x0
  pushl $97
80106462:	6a 61                	push   $0x61
  jmp alltraps
80106464:	e9 f5 f7 ff ff       	jmp    80105c5e <alltraps>

80106469 <vector98>:
.globl vector98
vector98:
  pushl $0
80106469:	6a 00                	push   $0x0
  pushl $98
8010646b:	6a 62                	push   $0x62
  jmp alltraps
8010646d:	e9 ec f7 ff ff       	jmp    80105c5e <alltraps>

80106472 <vector99>:
.globl vector99
vector99:
  pushl $0
80106472:	6a 00                	push   $0x0
  pushl $99
80106474:	6a 63                	push   $0x63
  jmp alltraps
80106476:	e9 e3 f7 ff ff       	jmp    80105c5e <alltraps>

8010647b <vector100>:
.globl vector100
vector100:
  pushl $0
8010647b:	6a 00                	push   $0x0
  pushl $100
8010647d:	6a 64                	push   $0x64
  jmp alltraps
8010647f:	e9 da f7 ff ff       	jmp    80105c5e <alltraps>

80106484 <vector101>:
.globl vector101
vector101:
  pushl $0
80106484:	6a 00                	push   $0x0
  pushl $101
80106486:	6a 65                	push   $0x65
  jmp alltraps
80106488:	e9 d1 f7 ff ff       	jmp    80105c5e <alltraps>

8010648d <vector102>:
.globl vector102
vector102:
  pushl $0
8010648d:	6a 00                	push   $0x0
  pushl $102
8010648f:	6a 66                	push   $0x66
  jmp alltraps
80106491:	e9 c8 f7 ff ff       	jmp    80105c5e <alltraps>

80106496 <vector103>:
.globl vector103
vector103:
  pushl $0
80106496:	6a 00                	push   $0x0
  pushl $103
80106498:	6a 67                	push   $0x67
  jmp alltraps
8010649a:	e9 bf f7 ff ff       	jmp    80105c5e <alltraps>

8010649f <vector104>:
.globl vector104
vector104:
  pushl $0
8010649f:	6a 00                	push   $0x0
  pushl $104
801064a1:	6a 68                	push   $0x68
  jmp alltraps
801064a3:	e9 b6 f7 ff ff       	jmp    80105c5e <alltraps>

801064a8 <vector105>:
.globl vector105
vector105:
  pushl $0
801064a8:	6a 00                	push   $0x0
  pushl $105
801064aa:	6a 69                	push   $0x69
  jmp alltraps
801064ac:	e9 ad f7 ff ff       	jmp    80105c5e <alltraps>

801064b1 <vector106>:
.globl vector106
vector106:
  pushl $0
801064b1:	6a 00                	push   $0x0
  pushl $106
801064b3:	6a 6a                	push   $0x6a
  jmp alltraps
801064b5:	e9 a4 f7 ff ff       	jmp    80105c5e <alltraps>

801064ba <vector107>:
.globl vector107
vector107:
  pushl $0
801064ba:	6a 00                	push   $0x0
  pushl $107
801064bc:	6a 6b                	push   $0x6b
  jmp alltraps
801064be:	e9 9b f7 ff ff       	jmp    80105c5e <alltraps>

801064c3 <vector108>:
.globl vector108
vector108:
  pushl $0
801064c3:	6a 00                	push   $0x0
  pushl $108
801064c5:	6a 6c                	push   $0x6c
  jmp alltraps
801064c7:	e9 92 f7 ff ff       	jmp    80105c5e <alltraps>

801064cc <vector109>:
.globl vector109
vector109:
  pushl $0
801064cc:	6a 00                	push   $0x0
  pushl $109
801064ce:	6a 6d                	push   $0x6d
  jmp alltraps
801064d0:	e9 89 f7 ff ff       	jmp    80105c5e <alltraps>

801064d5 <vector110>:
.globl vector110
vector110:
  pushl $0
801064d5:	6a 00                	push   $0x0
  pushl $110
801064d7:	6a 6e                	push   $0x6e
  jmp alltraps
801064d9:	e9 80 f7 ff ff       	jmp    80105c5e <alltraps>

801064de <vector111>:
.globl vector111
vector111:
  pushl $0
801064de:	6a 00                	push   $0x0
  pushl $111
801064e0:	6a 6f                	push   $0x6f
  jmp alltraps
801064e2:	e9 77 f7 ff ff       	jmp    80105c5e <alltraps>

801064e7 <vector112>:
.globl vector112
vector112:
  pushl $0
801064e7:	6a 00                	push   $0x0
  pushl $112
801064e9:	6a 70                	push   $0x70
  jmp alltraps
801064eb:	e9 6e f7 ff ff       	jmp    80105c5e <alltraps>

801064f0 <vector113>:
.globl vector113
vector113:
  pushl $0
801064f0:	6a 00                	push   $0x0
  pushl $113
801064f2:	6a 71                	push   $0x71
  jmp alltraps
801064f4:	e9 65 f7 ff ff       	jmp    80105c5e <alltraps>

801064f9 <vector114>:
.globl vector114
vector114:
  pushl $0
801064f9:	6a 00                	push   $0x0
  pushl $114
801064fb:	6a 72                	push   $0x72
  jmp alltraps
801064fd:	e9 5c f7 ff ff       	jmp    80105c5e <alltraps>

80106502 <vector115>:
.globl vector115
vector115:
  pushl $0
80106502:	6a 00                	push   $0x0
  pushl $115
80106504:	6a 73                	push   $0x73
  jmp alltraps
80106506:	e9 53 f7 ff ff       	jmp    80105c5e <alltraps>

8010650b <vector116>:
.globl vector116
vector116:
  pushl $0
8010650b:	6a 00                	push   $0x0
  pushl $116
8010650d:	6a 74                	push   $0x74
  jmp alltraps
8010650f:	e9 4a f7 ff ff       	jmp    80105c5e <alltraps>

80106514 <vector117>:
.globl vector117
vector117:
  pushl $0
80106514:	6a 00                	push   $0x0
  pushl $117
80106516:	6a 75                	push   $0x75
  jmp alltraps
80106518:	e9 41 f7 ff ff       	jmp    80105c5e <alltraps>

8010651d <vector118>:
.globl vector118
vector118:
  pushl $0
8010651d:	6a 00                	push   $0x0
  pushl $118
8010651f:	6a 76                	push   $0x76
  jmp alltraps
80106521:	e9 38 f7 ff ff       	jmp    80105c5e <alltraps>

80106526 <vector119>:
.globl vector119
vector119:
  pushl $0
80106526:	6a 00                	push   $0x0
  pushl $119
80106528:	6a 77                	push   $0x77
  jmp alltraps
8010652a:	e9 2f f7 ff ff       	jmp    80105c5e <alltraps>

8010652f <vector120>:
.globl vector120
vector120:
  pushl $0
8010652f:	6a 00                	push   $0x0
  pushl $120
80106531:	6a 78                	push   $0x78
  jmp alltraps
80106533:	e9 26 f7 ff ff       	jmp    80105c5e <alltraps>

80106538 <vector121>:
.globl vector121
vector121:
  pushl $0
80106538:	6a 00                	push   $0x0
  pushl $121
8010653a:	6a 79                	push   $0x79
  jmp alltraps
8010653c:	e9 1d f7 ff ff       	jmp    80105c5e <alltraps>

80106541 <vector122>:
.globl vector122
vector122:
  pushl $0
80106541:	6a 00                	push   $0x0
  pushl $122
80106543:	6a 7a                	push   $0x7a
  jmp alltraps
80106545:	e9 14 f7 ff ff       	jmp    80105c5e <alltraps>

8010654a <vector123>:
.globl vector123
vector123:
  pushl $0
8010654a:	6a 00                	push   $0x0
  pushl $123
8010654c:	6a 7b                	push   $0x7b
  jmp alltraps
8010654e:	e9 0b f7 ff ff       	jmp    80105c5e <alltraps>

80106553 <vector124>:
.globl vector124
vector124:
  pushl $0
80106553:	6a 00                	push   $0x0
  pushl $124
80106555:	6a 7c                	push   $0x7c
  jmp alltraps
80106557:	e9 02 f7 ff ff       	jmp    80105c5e <alltraps>

8010655c <vector125>:
.globl vector125
vector125:
  pushl $0
8010655c:	6a 00                	push   $0x0
  pushl $125
8010655e:	6a 7d                	push   $0x7d
  jmp alltraps
80106560:	e9 f9 f6 ff ff       	jmp    80105c5e <alltraps>

80106565 <vector126>:
.globl vector126
vector126:
  pushl $0
80106565:	6a 00                	push   $0x0
  pushl $126
80106567:	6a 7e                	push   $0x7e
  jmp alltraps
80106569:	e9 f0 f6 ff ff       	jmp    80105c5e <alltraps>

8010656e <vector127>:
.globl vector127
vector127:
  pushl $0
8010656e:	6a 00                	push   $0x0
  pushl $127
80106570:	6a 7f                	push   $0x7f
  jmp alltraps
80106572:	e9 e7 f6 ff ff       	jmp    80105c5e <alltraps>

80106577 <vector128>:
.globl vector128
vector128:
  pushl $0
80106577:	6a 00                	push   $0x0
  pushl $128
80106579:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010657e:	e9 db f6 ff ff       	jmp    80105c5e <alltraps>

80106583 <vector129>:
.globl vector129
vector129:
  pushl $0
80106583:	6a 00                	push   $0x0
  pushl $129
80106585:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010658a:	e9 cf f6 ff ff       	jmp    80105c5e <alltraps>

8010658f <vector130>:
.globl vector130
vector130:
  pushl $0
8010658f:	6a 00                	push   $0x0
  pushl $130
80106591:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106596:	e9 c3 f6 ff ff       	jmp    80105c5e <alltraps>

8010659b <vector131>:
.globl vector131
vector131:
  pushl $0
8010659b:	6a 00                	push   $0x0
  pushl $131
8010659d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801065a2:	e9 b7 f6 ff ff       	jmp    80105c5e <alltraps>

801065a7 <vector132>:
.globl vector132
vector132:
  pushl $0
801065a7:	6a 00                	push   $0x0
  pushl $132
801065a9:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801065ae:	e9 ab f6 ff ff       	jmp    80105c5e <alltraps>

801065b3 <vector133>:
.globl vector133
vector133:
  pushl $0
801065b3:	6a 00                	push   $0x0
  pushl $133
801065b5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801065ba:	e9 9f f6 ff ff       	jmp    80105c5e <alltraps>

801065bf <vector134>:
.globl vector134
vector134:
  pushl $0
801065bf:	6a 00                	push   $0x0
  pushl $134
801065c1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801065c6:	e9 93 f6 ff ff       	jmp    80105c5e <alltraps>

801065cb <vector135>:
.globl vector135
vector135:
  pushl $0
801065cb:	6a 00                	push   $0x0
  pushl $135
801065cd:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801065d2:	e9 87 f6 ff ff       	jmp    80105c5e <alltraps>

801065d7 <vector136>:
.globl vector136
vector136:
  pushl $0
801065d7:	6a 00                	push   $0x0
  pushl $136
801065d9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801065de:	e9 7b f6 ff ff       	jmp    80105c5e <alltraps>

801065e3 <vector137>:
.globl vector137
vector137:
  pushl $0
801065e3:	6a 00                	push   $0x0
  pushl $137
801065e5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801065ea:	e9 6f f6 ff ff       	jmp    80105c5e <alltraps>

801065ef <vector138>:
.globl vector138
vector138:
  pushl $0
801065ef:	6a 00                	push   $0x0
  pushl $138
801065f1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801065f6:	e9 63 f6 ff ff       	jmp    80105c5e <alltraps>

801065fb <vector139>:
.globl vector139
vector139:
  pushl $0
801065fb:	6a 00                	push   $0x0
  pushl $139
801065fd:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106602:	e9 57 f6 ff ff       	jmp    80105c5e <alltraps>

80106607 <vector140>:
.globl vector140
vector140:
  pushl $0
80106607:	6a 00                	push   $0x0
  pushl $140
80106609:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010660e:	e9 4b f6 ff ff       	jmp    80105c5e <alltraps>

80106613 <vector141>:
.globl vector141
vector141:
  pushl $0
80106613:	6a 00                	push   $0x0
  pushl $141
80106615:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010661a:	e9 3f f6 ff ff       	jmp    80105c5e <alltraps>

8010661f <vector142>:
.globl vector142
vector142:
  pushl $0
8010661f:	6a 00                	push   $0x0
  pushl $142
80106621:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106626:	e9 33 f6 ff ff       	jmp    80105c5e <alltraps>

8010662b <vector143>:
.globl vector143
vector143:
  pushl $0
8010662b:	6a 00                	push   $0x0
  pushl $143
8010662d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106632:	e9 27 f6 ff ff       	jmp    80105c5e <alltraps>

80106637 <vector144>:
.globl vector144
vector144:
  pushl $0
80106637:	6a 00                	push   $0x0
  pushl $144
80106639:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010663e:	e9 1b f6 ff ff       	jmp    80105c5e <alltraps>

80106643 <vector145>:
.globl vector145
vector145:
  pushl $0
80106643:	6a 00                	push   $0x0
  pushl $145
80106645:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010664a:	e9 0f f6 ff ff       	jmp    80105c5e <alltraps>

8010664f <vector146>:
.globl vector146
vector146:
  pushl $0
8010664f:	6a 00                	push   $0x0
  pushl $146
80106651:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106656:	e9 03 f6 ff ff       	jmp    80105c5e <alltraps>

8010665b <vector147>:
.globl vector147
vector147:
  pushl $0
8010665b:	6a 00                	push   $0x0
  pushl $147
8010665d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106662:	e9 f7 f5 ff ff       	jmp    80105c5e <alltraps>

80106667 <vector148>:
.globl vector148
vector148:
  pushl $0
80106667:	6a 00                	push   $0x0
  pushl $148
80106669:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010666e:	e9 eb f5 ff ff       	jmp    80105c5e <alltraps>

80106673 <vector149>:
.globl vector149
vector149:
  pushl $0
80106673:	6a 00                	push   $0x0
  pushl $149
80106675:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010667a:	e9 df f5 ff ff       	jmp    80105c5e <alltraps>

8010667f <vector150>:
.globl vector150
vector150:
  pushl $0
8010667f:	6a 00                	push   $0x0
  pushl $150
80106681:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106686:	e9 d3 f5 ff ff       	jmp    80105c5e <alltraps>

8010668b <vector151>:
.globl vector151
vector151:
  pushl $0
8010668b:	6a 00                	push   $0x0
  pushl $151
8010668d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106692:	e9 c7 f5 ff ff       	jmp    80105c5e <alltraps>

80106697 <vector152>:
.globl vector152
vector152:
  pushl $0
80106697:	6a 00                	push   $0x0
  pushl $152
80106699:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010669e:	e9 bb f5 ff ff       	jmp    80105c5e <alltraps>

801066a3 <vector153>:
.globl vector153
vector153:
  pushl $0
801066a3:	6a 00                	push   $0x0
  pushl $153
801066a5:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801066aa:	e9 af f5 ff ff       	jmp    80105c5e <alltraps>

801066af <vector154>:
.globl vector154
vector154:
  pushl $0
801066af:	6a 00                	push   $0x0
  pushl $154
801066b1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801066b6:	e9 a3 f5 ff ff       	jmp    80105c5e <alltraps>

801066bb <vector155>:
.globl vector155
vector155:
  pushl $0
801066bb:	6a 00                	push   $0x0
  pushl $155
801066bd:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801066c2:	e9 97 f5 ff ff       	jmp    80105c5e <alltraps>

801066c7 <vector156>:
.globl vector156
vector156:
  pushl $0
801066c7:	6a 00                	push   $0x0
  pushl $156
801066c9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801066ce:	e9 8b f5 ff ff       	jmp    80105c5e <alltraps>

801066d3 <vector157>:
.globl vector157
vector157:
  pushl $0
801066d3:	6a 00                	push   $0x0
  pushl $157
801066d5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801066da:	e9 7f f5 ff ff       	jmp    80105c5e <alltraps>

801066df <vector158>:
.globl vector158
vector158:
  pushl $0
801066df:	6a 00                	push   $0x0
  pushl $158
801066e1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801066e6:	e9 73 f5 ff ff       	jmp    80105c5e <alltraps>

801066eb <vector159>:
.globl vector159
vector159:
  pushl $0
801066eb:	6a 00                	push   $0x0
  pushl $159
801066ed:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801066f2:	e9 67 f5 ff ff       	jmp    80105c5e <alltraps>

801066f7 <vector160>:
.globl vector160
vector160:
  pushl $0
801066f7:	6a 00                	push   $0x0
  pushl $160
801066f9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801066fe:	e9 5b f5 ff ff       	jmp    80105c5e <alltraps>

80106703 <vector161>:
.globl vector161
vector161:
  pushl $0
80106703:	6a 00                	push   $0x0
  pushl $161
80106705:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010670a:	e9 4f f5 ff ff       	jmp    80105c5e <alltraps>

8010670f <vector162>:
.globl vector162
vector162:
  pushl $0
8010670f:	6a 00                	push   $0x0
  pushl $162
80106711:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106716:	e9 43 f5 ff ff       	jmp    80105c5e <alltraps>

8010671b <vector163>:
.globl vector163
vector163:
  pushl $0
8010671b:	6a 00                	push   $0x0
  pushl $163
8010671d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106722:	e9 37 f5 ff ff       	jmp    80105c5e <alltraps>

80106727 <vector164>:
.globl vector164
vector164:
  pushl $0
80106727:	6a 00                	push   $0x0
  pushl $164
80106729:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010672e:	e9 2b f5 ff ff       	jmp    80105c5e <alltraps>

80106733 <vector165>:
.globl vector165
vector165:
  pushl $0
80106733:	6a 00                	push   $0x0
  pushl $165
80106735:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010673a:	e9 1f f5 ff ff       	jmp    80105c5e <alltraps>

8010673f <vector166>:
.globl vector166
vector166:
  pushl $0
8010673f:	6a 00                	push   $0x0
  pushl $166
80106741:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106746:	e9 13 f5 ff ff       	jmp    80105c5e <alltraps>

8010674b <vector167>:
.globl vector167
vector167:
  pushl $0
8010674b:	6a 00                	push   $0x0
  pushl $167
8010674d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106752:	e9 07 f5 ff ff       	jmp    80105c5e <alltraps>

80106757 <vector168>:
.globl vector168
vector168:
  pushl $0
80106757:	6a 00                	push   $0x0
  pushl $168
80106759:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010675e:	e9 fb f4 ff ff       	jmp    80105c5e <alltraps>

80106763 <vector169>:
.globl vector169
vector169:
  pushl $0
80106763:	6a 00                	push   $0x0
  pushl $169
80106765:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010676a:	e9 ef f4 ff ff       	jmp    80105c5e <alltraps>

8010676f <vector170>:
.globl vector170
vector170:
  pushl $0
8010676f:	6a 00                	push   $0x0
  pushl $170
80106771:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106776:	e9 e3 f4 ff ff       	jmp    80105c5e <alltraps>

8010677b <vector171>:
.globl vector171
vector171:
  pushl $0
8010677b:	6a 00                	push   $0x0
  pushl $171
8010677d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106782:	e9 d7 f4 ff ff       	jmp    80105c5e <alltraps>

80106787 <vector172>:
.globl vector172
vector172:
  pushl $0
80106787:	6a 00                	push   $0x0
  pushl $172
80106789:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010678e:	e9 cb f4 ff ff       	jmp    80105c5e <alltraps>

80106793 <vector173>:
.globl vector173
vector173:
  pushl $0
80106793:	6a 00                	push   $0x0
  pushl $173
80106795:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010679a:	e9 bf f4 ff ff       	jmp    80105c5e <alltraps>

8010679f <vector174>:
.globl vector174
vector174:
  pushl $0
8010679f:	6a 00                	push   $0x0
  pushl $174
801067a1:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801067a6:	e9 b3 f4 ff ff       	jmp    80105c5e <alltraps>

801067ab <vector175>:
.globl vector175
vector175:
  pushl $0
801067ab:	6a 00                	push   $0x0
  pushl $175
801067ad:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801067b2:	e9 a7 f4 ff ff       	jmp    80105c5e <alltraps>

801067b7 <vector176>:
.globl vector176
vector176:
  pushl $0
801067b7:	6a 00                	push   $0x0
  pushl $176
801067b9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801067be:	e9 9b f4 ff ff       	jmp    80105c5e <alltraps>

801067c3 <vector177>:
.globl vector177
vector177:
  pushl $0
801067c3:	6a 00                	push   $0x0
  pushl $177
801067c5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801067ca:	e9 8f f4 ff ff       	jmp    80105c5e <alltraps>

801067cf <vector178>:
.globl vector178
vector178:
  pushl $0
801067cf:	6a 00                	push   $0x0
  pushl $178
801067d1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801067d6:	e9 83 f4 ff ff       	jmp    80105c5e <alltraps>

801067db <vector179>:
.globl vector179
vector179:
  pushl $0
801067db:	6a 00                	push   $0x0
  pushl $179
801067dd:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801067e2:	e9 77 f4 ff ff       	jmp    80105c5e <alltraps>

801067e7 <vector180>:
.globl vector180
vector180:
  pushl $0
801067e7:	6a 00                	push   $0x0
  pushl $180
801067e9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801067ee:	e9 6b f4 ff ff       	jmp    80105c5e <alltraps>

801067f3 <vector181>:
.globl vector181
vector181:
  pushl $0
801067f3:	6a 00                	push   $0x0
  pushl $181
801067f5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801067fa:	e9 5f f4 ff ff       	jmp    80105c5e <alltraps>

801067ff <vector182>:
.globl vector182
vector182:
  pushl $0
801067ff:	6a 00                	push   $0x0
  pushl $182
80106801:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106806:	e9 53 f4 ff ff       	jmp    80105c5e <alltraps>

8010680b <vector183>:
.globl vector183
vector183:
  pushl $0
8010680b:	6a 00                	push   $0x0
  pushl $183
8010680d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106812:	e9 47 f4 ff ff       	jmp    80105c5e <alltraps>

80106817 <vector184>:
.globl vector184
vector184:
  pushl $0
80106817:	6a 00                	push   $0x0
  pushl $184
80106819:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010681e:	e9 3b f4 ff ff       	jmp    80105c5e <alltraps>

80106823 <vector185>:
.globl vector185
vector185:
  pushl $0
80106823:	6a 00                	push   $0x0
  pushl $185
80106825:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010682a:	e9 2f f4 ff ff       	jmp    80105c5e <alltraps>

8010682f <vector186>:
.globl vector186
vector186:
  pushl $0
8010682f:	6a 00                	push   $0x0
  pushl $186
80106831:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106836:	e9 23 f4 ff ff       	jmp    80105c5e <alltraps>

8010683b <vector187>:
.globl vector187
vector187:
  pushl $0
8010683b:	6a 00                	push   $0x0
  pushl $187
8010683d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106842:	e9 17 f4 ff ff       	jmp    80105c5e <alltraps>

80106847 <vector188>:
.globl vector188
vector188:
  pushl $0
80106847:	6a 00                	push   $0x0
  pushl $188
80106849:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010684e:	e9 0b f4 ff ff       	jmp    80105c5e <alltraps>

80106853 <vector189>:
.globl vector189
vector189:
  pushl $0
80106853:	6a 00                	push   $0x0
  pushl $189
80106855:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010685a:	e9 ff f3 ff ff       	jmp    80105c5e <alltraps>

8010685f <vector190>:
.globl vector190
vector190:
  pushl $0
8010685f:	6a 00                	push   $0x0
  pushl $190
80106861:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106866:	e9 f3 f3 ff ff       	jmp    80105c5e <alltraps>

8010686b <vector191>:
.globl vector191
vector191:
  pushl $0
8010686b:	6a 00                	push   $0x0
  pushl $191
8010686d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106872:	e9 e7 f3 ff ff       	jmp    80105c5e <alltraps>

80106877 <vector192>:
.globl vector192
vector192:
  pushl $0
80106877:	6a 00                	push   $0x0
  pushl $192
80106879:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010687e:	e9 db f3 ff ff       	jmp    80105c5e <alltraps>

80106883 <vector193>:
.globl vector193
vector193:
  pushl $0
80106883:	6a 00                	push   $0x0
  pushl $193
80106885:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010688a:	e9 cf f3 ff ff       	jmp    80105c5e <alltraps>

8010688f <vector194>:
.globl vector194
vector194:
  pushl $0
8010688f:	6a 00                	push   $0x0
  pushl $194
80106891:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106896:	e9 c3 f3 ff ff       	jmp    80105c5e <alltraps>

8010689b <vector195>:
.globl vector195
vector195:
  pushl $0
8010689b:	6a 00                	push   $0x0
  pushl $195
8010689d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801068a2:	e9 b7 f3 ff ff       	jmp    80105c5e <alltraps>

801068a7 <vector196>:
.globl vector196
vector196:
  pushl $0
801068a7:	6a 00                	push   $0x0
  pushl $196
801068a9:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801068ae:	e9 ab f3 ff ff       	jmp    80105c5e <alltraps>

801068b3 <vector197>:
.globl vector197
vector197:
  pushl $0
801068b3:	6a 00                	push   $0x0
  pushl $197
801068b5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801068ba:	e9 9f f3 ff ff       	jmp    80105c5e <alltraps>

801068bf <vector198>:
.globl vector198
vector198:
  pushl $0
801068bf:	6a 00                	push   $0x0
  pushl $198
801068c1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801068c6:	e9 93 f3 ff ff       	jmp    80105c5e <alltraps>

801068cb <vector199>:
.globl vector199
vector199:
  pushl $0
801068cb:	6a 00                	push   $0x0
  pushl $199
801068cd:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801068d2:	e9 87 f3 ff ff       	jmp    80105c5e <alltraps>

801068d7 <vector200>:
.globl vector200
vector200:
  pushl $0
801068d7:	6a 00                	push   $0x0
  pushl $200
801068d9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801068de:	e9 7b f3 ff ff       	jmp    80105c5e <alltraps>

801068e3 <vector201>:
.globl vector201
vector201:
  pushl $0
801068e3:	6a 00                	push   $0x0
  pushl $201
801068e5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801068ea:	e9 6f f3 ff ff       	jmp    80105c5e <alltraps>

801068ef <vector202>:
.globl vector202
vector202:
  pushl $0
801068ef:	6a 00                	push   $0x0
  pushl $202
801068f1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801068f6:	e9 63 f3 ff ff       	jmp    80105c5e <alltraps>

801068fb <vector203>:
.globl vector203
vector203:
  pushl $0
801068fb:	6a 00                	push   $0x0
  pushl $203
801068fd:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106902:	e9 57 f3 ff ff       	jmp    80105c5e <alltraps>

80106907 <vector204>:
.globl vector204
vector204:
  pushl $0
80106907:	6a 00                	push   $0x0
  pushl $204
80106909:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010690e:	e9 4b f3 ff ff       	jmp    80105c5e <alltraps>

80106913 <vector205>:
.globl vector205
vector205:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $205
80106915:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010691a:	e9 3f f3 ff ff       	jmp    80105c5e <alltraps>

8010691f <vector206>:
.globl vector206
vector206:
  pushl $0
8010691f:	6a 00                	push   $0x0
  pushl $206
80106921:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106926:	e9 33 f3 ff ff       	jmp    80105c5e <alltraps>

8010692b <vector207>:
.globl vector207
vector207:
  pushl $0
8010692b:	6a 00                	push   $0x0
  pushl $207
8010692d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106932:	e9 27 f3 ff ff       	jmp    80105c5e <alltraps>

80106937 <vector208>:
.globl vector208
vector208:
  pushl $0
80106937:	6a 00                	push   $0x0
  pushl $208
80106939:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010693e:	e9 1b f3 ff ff       	jmp    80105c5e <alltraps>

80106943 <vector209>:
.globl vector209
vector209:
  pushl $0
80106943:	6a 00                	push   $0x0
  pushl $209
80106945:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010694a:	e9 0f f3 ff ff       	jmp    80105c5e <alltraps>

8010694f <vector210>:
.globl vector210
vector210:
  pushl $0
8010694f:	6a 00                	push   $0x0
  pushl $210
80106951:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106956:	e9 03 f3 ff ff       	jmp    80105c5e <alltraps>

8010695b <vector211>:
.globl vector211
vector211:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $211
8010695d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106962:	e9 f7 f2 ff ff       	jmp    80105c5e <alltraps>

80106967 <vector212>:
.globl vector212
vector212:
  pushl $0
80106967:	6a 00                	push   $0x0
  pushl $212
80106969:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010696e:	e9 eb f2 ff ff       	jmp    80105c5e <alltraps>

80106973 <vector213>:
.globl vector213
vector213:
  pushl $0
80106973:	6a 00                	push   $0x0
  pushl $213
80106975:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010697a:	e9 df f2 ff ff       	jmp    80105c5e <alltraps>

8010697f <vector214>:
.globl vector214
vector214:
  pushl $0
8010697f:	6a 00                	push   $0x0
  pushl $214
80106981:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106986:	e9 d3 f2 ff ff       	jmp    80105c5e <alltraps>

8010698b <vector215>:
.globl vector215
vector215:
  pushl $0
8010698b:	6a 00                	push   $0x0
  pushl $215
8010698d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106992:	e9 c7 f2 ff ff       	jmp    80105c5e <alltraps>

80106997 <vector216>:
.globl vector216
vector216:
  pushl $0
80106997:	6a 00                	push   $0x0
  pushl $216
80106999:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010699e:	e9 bb f2 ff ff       	jmp    80105c5e <alltraps>

801069a3 <vector217>:
.globl vector217
vector217:
  pushl $0
801069a3:	6a 00                	push   $0x0
  pushl $217
801069a5:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801069aa:	e9 af f2 ff ff       	jmp    80105c5e <alltraps>

801069af <vector218>:
.globl vector218
vector218:
  pushl $0
801069af:	6a 00                	push   $0x0
  pushl $218
801069b1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801069b6:	e9 a3 f2 ff ff       	jmp    80105c5e <alltraps>

801069bb <vector219>:
.globl vector219
vector219:
  pushl $0
801069bb:	6a 00                	push   $0x0
  pushl $219
801069bd:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801069c2:	e9 97 f2 ff ff       	jmp    80105c5e <alltraps>

801069c7 <vector220>:
.globl vector220
vector220:
  pushl $0
801069c7:	6a 00                	push   $0x0
  pushl $220
801069c9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801069ce:	e9 8b f2 ff ff       	jmp    80105c5e <alltraps>

801069d3 <vector221>:
.globl vector221
vector221:
  pushl $0
801069d3:	6a 00                	push   $0x0
  pushl $221
801069d5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801069da:	e9 7f f2 ff ff       	jmp    80105c5e <alltraps>

801069df <vector222>:
.globl vector222
vector222:
  pushl $0
801069df:	6a 00                	push   $0x0
  pushl $222
801069e1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801069e6:	e9 73 f2 ff ff       	jmp    80105c5e <alltraps>

801069eb <vector223>:
.globl vector223
vector223:
  pushl $0
801069eb:	6a 00                	push   $0x0
  pushl $223
801069ed:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801069f2:	e9 67 f2 ff ff       	jmp    80105c5e <alltraps>

801069f7 <vector224>:
.globl vector224
vector224:
  pushl $0
801069f7:	6a 00                	push   $0x0
  pushl $224
801069f9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801069fe:	e9 5b f2 ff ff       	jmp    80105c5e <alltraps>

80106a03 <vector225>:
.globl vector225
vector225:
  pushl $0
80106a03:	6a 00                	push   $0x0
  pushl $225
80106a05:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106a0a:	e9 4f f2 ff ff       	jmp    80105c5e <alltraps>

80106a0f <vector226>:
.globl vector226
vector226:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $226
80106a11:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106a16:	e9 43 f2 ff ff       	jmp    80105c5e <alltraps>

80106a1b <vector227>:
.globl vector227
vector227:
  pushl $0
80106a1b:	6a 00                	push   $0x0
  pushl $227
80106a1d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106a22:	e9 37 f2 ff ff       	jmp    80105c5e <alltraps>

80106a27 <vector228>:
.globl vector228
vector228:
  pushl $0
80106a27:	6a 00                	push   $0x0
  pushl $228
80106a29:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106a2e:	e9 2b f2 ff ff       	jmp    80105c5e <alltraps>

80106a33 <vector229>:
.globl vector229
vector229:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $229
80106a35:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106a3a:	e9 1f f2 ff ff       	jmp    80105c5e <alltraps>

80106a3f <vector230>:
.globl vector230
vector230:
  pushl $0
80106a3f:	6a 00                	push   $0x0
  pushl $230
80106a41:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106a46:	e9 13 f2 ff ff       	jmp    80105c5e <alltraps>

80106a4b <vector231>:
.globl vector231
vector231:
  pushl $0
80106a4b:	6a 00                	push   $0x0
  pushl $231
80106a4d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106a52:	e9 07 f2 ff ff       	jmp    80105c5e <alltraps>

80106a57 <vector232>:
.globl vector232
vector232:
  pushl $0
80106a57:	6a 00                	push   $0x0
  pushl $232
80106a59:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106a5e:	e9 fb f1 ff ff       	jmp    80105c5e <alltraps>

80106a63 <vector233>:
.globl vector233
vector233:
  pushl $0
80106a63:	6a 00                	push   $0x0
  pushl $233
80106a65:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106a6a:	e9 ef f1 ff ff       	jmp    80105c5e <alltraps>

80106a6f <vector234>:
.globl vector234
vector234:
  pushl $0
80106a6f:	6a 00                	push   $0x0
  pushl $234
80106a71:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106a76:	e9 e3 f1 ff ff       	jmp    80105c5e <alltraps>

80106a7b <vector235>:
.globl vector235
vector235:
  pushl $0
80106a7b:	6a 00                	push   $0x0
  pushl $235
80106a7d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106a82:	e9 d7 f1 ff ff       	jmp    80105c5e <alltraps>

80106a87 <vector236>:
.globl vector236
vector236:
  pushl $0
80106a87:	6a 00                	push   $0x0
  pushl $236
80106a89:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106a8e:	e9 cb f1 ff ff       	jmp    80105c5e <alltraps>

80106a93 <vector237>:
.globl vector237
vector237:
  pushl $0
80106a93:	6a 00                	push   $0x0
  pushl $237
80106a95:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106a9a:	e9 bf f1 ff ff       	jmp    80105c5e <alltraps>

80106a9f <vector238>:
.globl vector238
vector238:
  pushl $0
80106a9f:	6a 00                	push   $0x0
  pushl $238
80106aa1:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106aa6:	e9 b3 f1 ff ff       	jmp    80105c5e <alltraps>

80106aab <vector239>:
.globl vector239
vector239:
  pushl $0
80106aab:	6a 00                	push   $0x0
  pushl $239
80106aad:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106ab2:	e9 a7 f1 ff ff       	jmp    80105c5e <alltraps>

80106ab7 <vector240>:
.globl vector240
vector240:
  pushl $0
80106ab7:	6a 00                	push   $0x0
  pushl $240
80106ab9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106abe:	e9 9b f1 ff ff       	jmp    80105c5e <alltraps>

80106ac3 <vector241>:
.globl vector241
vector241:
  pushl $0
80106ac3:	6a 00                	push   $0x0
  pushl $241
80106ac5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106aca:	e9 8f f1 ff ff       	jmp    80105c5e <alltraps>

80106acf <vector242>:
.globl vector242
vector242:
  pushl $0
80106acf:	6a 00                	push   $0x0
  pushl $242
80106ad1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106ad6:	e9 83 f1 ff ff       	jmp    80105c5e <alltraps>

80106adb <vector243>:
.globl vector243
vector243:
  pushl $0
80106adb:	6a 00                	push   $0x0
  pushl $243
80106add:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106ae2:	e9 77 f1 ff ff       	jmp    80105c5e <alltraps>

80106ae7 <vector244>:
.globl vector244
vector244:
  pushl $0
80106ae7:	6a 00                	push   $0x0
  pushl $244
80106ae9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106aee:	e9 6b f1 ff ff       	jmp    80105c5e <alltraps>

80106af3 <vector245>:
.globl vector245
vector245:
  pushl $0
80106af3:	6a 00                	push   $0x0
  pushl $245
80106af5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106afa:	e9 5f f1 ff ff       	jmp    80105c5e <alltraps>

80106aff <vector246>:
.globl vector246
vector246:
  pushl $0
80106aff:	6a 00                	push   $0x0
  pushl $246
80106b01:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106b06:	e9 53 f1 ff ff       	jmp    80105c5e <alltraps>

80106b0b <vector247>:
.globl vector247
vector247:
  pushl $0
80106b0b:	6a 00                	push   $0x0
  pushl $247
80106b0d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106b12:	e9 47 f1 ff ff       	jmp    80105c5e <alltraps>

80106b17 <vector248>:
.globl vector248
vector248:
  pushl $0
80106b17:	6a 00                	push   $0x0
  pushl $248
80106b19:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106b1e:	e9 3b f1 ff ff       	jmp    80105c5e <alltraps>

80106b23 <vector249>:
.globl vector249
vector249:
  pushl $0
80106b23:	6a 00                	push   $0x0
  pushl $249
80106b25:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106b2a:	e9 2f f1 ff ff       	jmp    80105c5e <alltraps>

80106b2f <vector250>:
.globl vector250
vector250:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $250
80106b31:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106b36:	e9 23 f1 ff ff       	jmp    80105c5e <alltraps>

80106b3b <vector251>:
.globl vector251
vector251:
  pushl $0
80106b3b:	6a 00                	push   $0x0
  pushl $251
80106b3d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106b42:	e9 17 f1 ff ff       	jmp    80105c5e <alltraps>

80106b47 <vector252>:
.globl vector252
vector252:
  pushl $0
80106b47:	6a 00                	push   $0x0
  pushl $252
80106b49:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106b4e:	e9 0b f1 ff ff       	jmp    80105c5e <alltraps>

80106b53 <vector253>:
.globl vector253
vector253:
  pushl $0
80106b53:	6a 00                	push   $0x0
  pushl $253
80106b55:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106b5a:	e9 ff f0 ff ff       	jmp    80105c5e <alltraps>

80106b5f <vector254>:
.globl vector254
vector254:
  pushl $0
80106b5f:	6a 00                	push   $0x0
  pushl $254
80106b61:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106b66:	e9 f3 f0 ff ff       	jmp    80105c5e <alltraps>

80106b6b <vector255>:
.globl vector255
vector255:
  pushl $0
80106b6b:	6a 00                	push   $0x0
  pushl $255
80106b6d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106b72:	e9 e7 f0 ff ff       	jmp    80105c5e <alltraps>
80106b77:	66 90                	xchg   %ax,%ax
80106b79:	66 90                	xchg   %ax,%ax
80106b7b:	66 90                	xchg   %ax,%ax
80106b7d:	66 90                	xchg   %ax,%ax
80106b7f:	90                   	nop

80106b80 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106b80:	55                   	push   %ebp
80106b81:	89 e5                	mov    %esp,%ebp
80106b83:	57                   	push   %edi
80106b84:	56                   	push   %esi
80106b85:	53                   	push   %ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106b86:	89 d3                	mov    %edx,%ebx
{
80106b88:	89 d7                	mov    %edx,%edi
  pde = &pgdir[PDX(va)];
80106b8a:	c1 eb 16             	shr    $0x16,%ebx
80106b8d:	8d 34 98             	lea    (%eax,%ebx,4),%esi
{
80106b90:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80106b93:	8b 06                	mov    (%esi),%eax
80106b95:	a8 01                	test   $0x1,%al
80106b97:	74 27                	je     80106bc0 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106b99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106b9e:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106ba4:	c1 ef 0a             	shr    $0xa,%edi
}
80106ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80106baa:	89 fa                	mov    %edi,%edx
80106bac:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106bb2:	8d 04 13             	lea    (%ebx,%edx,1),%eax
}
80106bb5:	5b                   	pop    %ebx
80106bb6:	5e                   	pop    %esi
80106bb7:	5f                   	pop    %edi
80106bb8:	5d                   	pop    %ebp
80106bb9:	c3                   	ret    
80106bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106bc0:	85 c9                	test   %ecx,%ecx
80106bc2:	74 2c                	je     80106bf0 <walkpgdir+0x70>
80106bc4:	e8 e7 b8 ff ff       	call   801024b0 <kalloc>
80106bc9:	85 c0                	test   %eax,%eax
80106bcb:	89 c3                	mov    %eax,%ebx
80106bcd:	74 21                	je     80106bf0 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
80106bcf:	83 ec 04             	sub    $0x4,%esp
80106bd2:	68 00 10 00 00       	push   $0x1000
80106bd7:	6a 00                	push   $0x0
80106bd9:	50                   	push   %eax
80106bda:	e8 31 dd ff ff       	call   80104910 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106bdf:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106be5:	83 c4 10             	add    $0x10,%esp
80106be8:	83 c8 07             	or     $0x7,%eax
80106beb:	89 06                	mov    %eax,(%esi)
80106bed:	eb b5                	jmp    80106ba4 <walkpgdir+0x24>
80106bef:	90                   	nop
}
80106bf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80106bf3:	31 c0                	xor    %eax,%eax
}
80106bf5:	5b                   	pop    %ebx
80106bf6:	5e                   	pop    %esi
80106bf7:	5f                   	pop    %edi
80106bf8:	5d                   	pop    %ebp
80106bf9:	c3                   	ret    
80106bfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106c00 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106c00:	55                   	push   %ebp
80106c01:	89 e5                	mov    %esp,%ebp
80106c03:	57                   	push   %edi
80106c04:	56                   	push   %esi
80106c05:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106c06:	89 d3                	mov    %edx,%ebx
80106c08:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
80106c0e:	83 ec 1c             	sub    $0x1c,%esp
80106c11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106c14:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80106c18:	8b 7d 08             	mov    0x8(%ebp),%edi
80106c1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106c20:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
80106c23:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c26:	29 df                	sub    %ebx,%edi
80106c28:	83 c8 01             	or     $0x1,%eax
80106c2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106c2e:	eb 15                	jmp    80106c45 <mappages+0x45>
    if(*pte & PTE_P)
80106c30:	f6 00 01             	testb  $0x1,(%eax)
80106c33:	75 45                	jne    80106c7a <mappages+0x7a>
    *pte = pa | perm | PTE_P;
80106c35:	0b 75 dc             	or     -0x24(%ebp),%esi
    if(a == last)
80106c38:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
    *pte = pa | perm | PTE_P;
80106c3b:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106c3d:	74 31                	je     80106c70 <mappages+0x70>
      break;
    a += PGSIZE;
80106c3f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106c45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c48:	b9 01 00 00 00       	mov    $0x1,%ecx
80106c4d:	89 da                	mov    %ebx,%edx
80106c4f:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
80106c52:	e8 29 ff ff ff       	call   80106b80 <walkpgdir>
80106c57:	85 c0                	test   %eax,%eax
80106c59:	75 d5                	jne    80106c30 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
80106c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106c63:	5b                   	pop    %ebx
80106c64:	5e                   	pop    %esi
80106c65:	5f                   	pop    %edi
80106c66:	5d                   	pop    %ebp
80106c67:	c3                   	ret    
80106c68:	90                   	nop
80106c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106c73:	31 c0                	xor    %eax,%eax
}
80106c75:	5b                   	pop    %ebx
80106c76:	5e                   	pop    %esi
80106c77:	5f                   	pop    %edi
80106c78:	5d                   	pop    %ebp
80106c79:	c3                   	ret    
      panic("remap");
80106c7a:	83 ec 0c             	sub    $0xc,%esp
80106c7d:	68 1c 7f 10 80       	push   $0x80107f1c
80106c82:	e8 e9 96 ff ff       	call   80100370 <panic>
80106c87:	89 f6                	mov    %esi,%esi
80106c89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106c90 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106c90:	55                   	push   %ebp
80106c91:	89 e5                	mov    %esp,%ebp
80106c93:	57                   	push   %edi
80106c94:	56                   	push   %esi
80106c95:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106c96:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106c9c:	89 c7                	mov    %eax,%edi
  a = PGROUNDUP(newsz);
80106c9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106ca4:	83 ec 1c             	sub    $0x1c,%esp
80106ca7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106caa:	39 d3                	cmp    %edx,%ebx
80106cac:	73 60                	jae    80106d0e <deallocuvm.part.0+0x7e>
80106cae:	89 d6                	mov    %edx,%esi
80106cb0:	eb 3d                	jmp    80106cef <deallocuvm.part.0+0x5f>
80106cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a += (NPTENTRIES - 1) * PGSIZE;
    else if((*pte & PTE_P) != 0){
80106cb8:	8b 10                	mov    (%eax),%edx
80106cba:	f6 c2 01             	test   $0x1,%dl
80106cbd:	74 26                	je     80106ce5 <deallocuvm.part.0+0x55>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106cbf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80106cc5:	74 52                	je     80106d19 <deallocuvm.part.0+0x89>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106cc7:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106cca:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80106cd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80106cd3:	52                   	push   %edx
80106cd4:	e8 27 b6 ff ff       	call   80102300 <kfree>
      *pte = 0;
80106cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106cdc:	83 c4 10             	add    $0x10,%esp
80106cdf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80106ce5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106ceb:	39 f3                	cmp    %esi,%ebx
80106ced:	73 1f                	jae    80106d0e <deallocuvm.part.0+0x7e>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106cef:	31 c9                	xor    %ecx,%ecx
80106cf1:	89 da                	mov    %ebx,%edx
80106cf3:	89 f8                	mov    %edi,%eax
80106cf5:	e8 86 fe ff ff       	call   80106b80 <walkpgdir>
    if(!pte)
80106cfa:	85 c0                	test   %eax,%eax
80106cfc:	75 ba                	jne    80106cb8 <deallocuvm.part.0+0x28>
      a += (NPTENTRIES - 1) * PGSIZE;
80106cfe:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106d04:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106d0a:	39 f3                	cmp    %esi,%ebx
80106d0c:	72 e1                	jb     80106cef <deallocuvm.part.0+0x5f>
    }
  }
  return newsz;
}
80106d0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d14:	5b                   	pop    %ebx
80106d15:	5e                   	pop    %esi
80106d16:	5f                   	pop    %edi
80106d17:	5d                   	pop    %ebp
80106d18:	c3                   	ret    
        panic("kfree");
80106d19:	83 ec 0c             	sub    $0xc,%esp
80106d1c:	68 da 77 10 80       	push   $0x801077da
80106d21:	e8 4a 96 ff ff       	call   80100370 <panic>
80106d26:	8d 76 00             	lea    0x0(%esi),%esi
80106d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106d30 <seginit>:
{
80106d30:	55                   	push   %ebp
80106d31:	89 e5                	mov    %esp,%ebp
80106d33:	53                   	push   %ebx
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80106d34:	31 db                	xor    %ebx,%ebx
{
80106d36:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpunum()];
80106d39:	e8 e2 b9 ff ff       	call   80102720 <cpunum>
80106d3e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80106d44:	8d 90 e0 22 11 80    	lea    -0x7feedd20(%eax),%edx
80106d4a:	8d 88 94 23 11 80    	lea    -0x7feedc6c(%eax),%ecx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106d50:	c7 80 58 23 11 80 ff 	movl   $0xffff,-0x7feedca8(%eax)
80106d57:	ff 00 00 
80106d5a:	c7 80 5c 23 11 80 00 	movl   $0xcf9a00,-0x7feedca4(%eax)
80106d61:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106d64:	c7 80 60 23 11 80 ff 	movl   $0xffff,-0x7feedca0(%eax)
80106d6b:	ff 00 00 
80106d6e:	c7 80 64 23 11 80 00 	movl   $0xcf9200,-0x7feedc9c(%eax)
80106d75:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106d78:	c7 80 70 23 11 80 ff 	movl   $0xffff,-0x7feedc90(%eax)
80106d7f:	ff 00 00 
80106d82:	c7 80 74 23 11 80 00 	movl   $0xcffa00,-0x7feedc8c(%eax)
80106d89:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106d8c:	c7 80 78 23 11 80 ff 	movl   $0xffff,-0x7feedc88(%eax)
80106d93:	ff 00 00 
80106d96:	c7 80 7c 23 11 80 00 	movl   $0xcff200,-0x7feedc84(%eax)
80106d9d:	f2 cf 00 
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80106da0:	66 89 9a 88 00 00 00 	mov    %bx,0x88(%edx)
80106da7:	89 cb                	mov    %ecx,%ebx
80106da9:	c1 eb 10             	shr    $0x10,%ebx
80106dac:	66 89 8a 8a 00 00 00 	mov    %cx,0x8a(%edx)
80106db3:	c1 e9 18             	shr    $0x18,%ecx
80106db6:	88 9a 8c 00 00 00    	mov    %bl,0x8c(%edx)
80106dbc:	bb 92 c0 ff ff       	mov    $0xffffc092,%ebx
80106dc1:	66 89 98 6d 23 11 80 	mov    %bx,-0x7feedc93(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106dc8:	05 50 23 11 80       	add    $0x80112350,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80106dcd:	88 8a 8f 00 00 00    	mov    %cl,0x8f(%edx)
  pd[0] = size-1;
80106dd3:	b9 37 00 00 00       	mov    $0x37,%ecx
80106dd8:	66 89 4d f2          	mov    %cx,-0xe(%ebp)
  pd[1] = (uint)p;
80106ddc:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106de0:	c1 e8 10             	shr    $0x10,%eax
80106de3:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106de7:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106dea:	0f 01 10             	lgdtl  (%eax)
  asm volatile("movw %0, %%gs" : : "r" (v));
80106ded:	b8 18 00 00 00       	mov    $0x18,%eax
80106df2:	8e e8                	mov    %eax,%gs
  proc = 0;
80106df4:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80106dfb:	00 00 00 00 
  c = &cpus[cpunum()];
80106dff:	65 89 15 00 00 00 00 	mov    %edx,%gs:0x0
}
80106e06:	83 c4 14             	add    $0x14,%esp
80106e09:	5b                   	pop    %ebx
80106e0a:	5d                   	pop    %ebp
80106e0b:	c3                   	ret    
80106e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106e10 <setupkvm>:
{
80106e10:	55                   	push   %ebp
80106e11:	89 e5                	mov    %esp,%ebp
80106e13:	56                   	push   %esi
80106e14:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106e15:	e8 96 b6 ff ff       	call   801024b0 <kalloc>
80106e1a:	85 c0                	test   %eax,%eax
80106e1c:	74 52                	je     80106e70 <setupkvm+0x60>
  memset(pgdir, 0, PGSIZE);
80106e1e:	83 ec 04             	sub    $0x4,%esp
80106e21:	89 c6                	mov    %eax,%esi
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106e23:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80106e28:	68 00 10 00 00       	push   $0x1000
80106e2d:	6a 00                	push   $0x0
80106e2f:	50                   	push   %eax
80106e30:	e8 db da ff ff       	call   80104910 <memset>
80106e35:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0)
80106e38:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106e3b:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106e3e:	83 ec 08             	sub    $0x8,%esp
80106e41:	8b 13                	mov    (%ebx),%edx
80106e43:	ff 73 0c             	pushl  0xc(%ebx)
80106e46:	50                   	push   %eax
80106e47:	29 c1                	sub    %eax,%ecx
80106e49:	89 f0                	mov    %esi,%eax
80106e4b:	e8 b0 fd ff ff       	call   80106c00 <mappages>
80106e50:	83 c4 10             	add    $0x10,%esp
80106e53:	85 c0                	test   %eax,%eax
80106e55:	78 19                	js     80106e70 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106e57:	83 c3 10             	add    $0x10,%ebx
80106e5a:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80106e60:	75 d6                	jne    80106e38 <setupkvm+0x28>
}
80106e62:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106e65:	89 f0                	mov    %esi,%eax
80106e67:	5b                   	pop    %ebx
80106e68:	5e                   	pop    %esi
80106e69:	5d                   	pop    %ebp
80106e6a:	c3                   	ret    
80106e6b:	90                   	nop
80106e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106e70:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
80106e73:	31 f6                	xor    %esi,%esi
}
80106e75:	89 f0                	mov    %esi,%eax
80106e77:	5b                   	pop    %ebx
80106e78:	5e                   	pop    %esi
80106e79:	5d                   	pop    %ebp
80106e7a:	c3                   	ret    
80106e7b:	90                   	nop
80106e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106e80 <kvmalloc>:
{
80106e80:	55                   	push   %ebp
80106e81:	89 e5                	mov    %esp,%ebp
80106e83:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106e86:	e8 85 ff ff ff       	call   80106e10 <setupkvm>
80106e8b:	a3 44 c3 11 80       	mov    %eax,0x8011c344
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106e90:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106e95:	0f 22 d8             	mov    %eax,%cr3
}
80106e98:	c9                   	leave  
80106e99:	c3                   	ret    
80106e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106ea0 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106ea0:	a1 44 c3 11 80       	mov    0x8011c344,%eax
{
80106ea5:	55                   	push   %ebp
80106ea6:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106ea8:	05 00 00 00 80       	add    $0x80000000,%eax
80106ead:	0f 22 d8             	mov    %eax,%cr3
}
80106eb0:	5d                   	pop    %ebp
80106eb1:	c3                   	ret    
80106eb2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106ec0 <switchuvm>:
{
80106ec0:	55                   	push   %ebp
80106ec1:	89 e5                	mov    %esp,%ebp
80106ec3:	53                   	push   %ebx
80106ec4:	83 ec 04             	sub    $0x4,%esp
80106ec7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80106eca:	e8 71 d9 ff ff       	call   80104840 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80106ecf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ed5:	b9 67 00 00 00       	mov    $0x67,%ecx
80106eda:	8d 50 08             	lea    0x8(%eax),%edx
80106edd:	66 89 88 a0 00 00 00 	mov    %cx,0xa0(%eax)
80106ee4:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
80106eeb:	89 d1                	mov    %edx,%ecx
80106eed:	c1 ea 18             	shr    $0x18,%edx
80106ef0:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
80106ef6:	ba 89 40 00 00       	mov    $0x4089,%edx
80106efb:	c1 e9 10             	shr    $0x10,%ecx
80106efe:	66 89 90 a5 00 00 00 	mov    %dx,0xa5(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80106f05:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80106f0c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80106f12:	b9 10 00 00 00       	mov    $0x10,%ecx
80106f17:	66 89 48 10          	mov    %cx,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80106f1b:	8b 52 08             	mov    0x8(%edx),%edx
80106f1e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80106f24:	89 50 0c             	mov    %edx,0xc(%eax)
  cpu->ts.iomb = (ushort) 0xFFFF;
80106f27:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80106f2c:	66 89 50 6e          	mov    %dx,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106f30:	b8 30 00 00 00       	mov    $0x30,%eax
80106f35:	0f 00 d8             	ltr    %ax
  if(p->pgdir == 0)
80106f38:	8b 43 04             	mov    0x4(%ebx),%eax
80106f3b:	85 c0                	test   %eax,%eax
80106f3d:	74 11                	je     80106f50 <switchuvm+0x90>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106f3f:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106f44:	0f 22 d8             	mov    %eax,%cr3
}
80106f47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106f4a:	c9                   	leave  
  popcli();
80106f4b:	e9 20 d9 ff ff       	jmp    80104870 <popcli>
    panic("switchuvm: no pgdir");
80106f50:	83 ec 0c             	sub    $0xc,%esp
80106f53:	68 22 7f 10 80       	push   $0x80107f22
80106f58:	e8 13 94 ff ff       	call   80100370 <panic>
80106f5d:	8d 76 00             	lea    0x0(%esi),%esi

80106f60 <inituvm>:
{
80106f60:	55                   	push   %ebp
80106f61:	89 e5                	mov    %esp,%ebp
80106f63:	57                   	push   %edi
80106f64:	56                   	push   %esi
80106f65:	53                   	push   %ebx
80106f66:	83 ec 1c             	sub    $0x1c,%esp
80106f69:	8b 75 10             	mov    0x10(%ebp),%esi
80106f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f6f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(sz >= PGSIZE)
80106f72:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
{
80106f78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80106f7b:	77 49                	ja     80106fc6 <inituvm+0x66>
  mem = kalloc();
80106f7d:	e8 2e b5 ff ff       	call   801024b0 <kalloc>
  memset(mem, 0, PGSIZE);
80106f82:	83 ec 04             	sub    $0x4,%esp
  mem = kalloc();
80106f85:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106f87:	68 00 10 00 00       	push   $0x1000
80106f8c:	6a 00                	push   $0x0
80106f8e:	50                   	push   %eax
80106f8f:	e8 7c d9 ff ff       	call   80104910 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106f94:	58                   	pop    %eax
80106f95:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106f9b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106fa0:	5a                   	pop    %edx
80106fa1:	6a 06                	push   $0x6
80106fa3:	50                   	push   %eax
80106fa4:	31 d2                	xor    %edx,%edx
80106fa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fa9:	e8 52 fc ff ff       	call   80106c00 <mappages>
  memmove(mem, init, sz);
80106fae:	89 75 10             	mov    %esi,0x10(%ebp)
80106fb1:	89 7d 0c             	mov    %edi,0xc(%ebp)
80106fb4:	83 c4 10             	add    $0x10,%esp
80106fb7:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80106fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106fbd:	5b                   	pop    %ebx
80106fbe:	5e                   	pop    %esi
80106fbf:	5f                   	pop    %edi
80106fc0:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80106fc1:	e9 fa d9 ff ff       	jmp    801049c0 <memmove>
    panic("inituvm: more than a page");
80106fc6:	83 ec 0c             	sub    $0xc,%esp
80106fc9:	68 36 7f 10 80       	push   $0x80107f36
80106fce:	e8 9d 93 ff ff       	call   80100370 <panic>
80106fd3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106fd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106fe0 <loaduvm>:
{
80106fe0:	55                   	push   %ebp
80106fe1:	89 e5                	mov    %esp,%ebp
80106fe3:	57                   	push   %edi
80106fe4:	56                   	push   %esi
80106fe5:	53                   	push   %ebx
80106fe6:	83 ec 0c             	sub    $0xc,%esp
  if((uint) addr % PGSIZE != 0)
80106fe9:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106ff0:	0f 85 91 00 00 00    	jne    80107087 <loaduvm+0xa7>
  for(i = 0; i < sz; i += PGSIZE){
80106ff6:	8b 75 18             	mov    0x18(%ebp),%esi
80106ff9:	31 db                	xor    %ebx,%ebx
80106ffb:	85 f6                	test   %esi,%esi
80106ffd:	75 1a                	jne    80107019 <loaduvm+0x39>
80106fff:	eb 6f                	jmp    80107070 <loaduvm+0x90>
80107001:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107008:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010700e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
80107014:	39 5d 18             	cmp    %ebx,0x18(%ebp)
80107017:	76 57                	jbe    80107070 <loaduvm+0x90>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107019:	8b 55 0c             	mov    0xc(%ebp),%edx
8010701c:	8b 45 08             	mov    0x8(%ebp),%eax
8010701f:	31 c9                	xor    %ecx,%ecx
80107021:	01 da                	add    %ebx,%edx
80107023:	e8 58 fb ff ff       	call   80106b80 <walkpgdir>
80107028:	85 c0                	test   %eax,%eax
8010702a:	74 4e                	je     8010707a <loaduvm+0x9a>
    pa = PTE_ADDR(*pte);
8010702c:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010702e:	8b 4d 14             	mov    0x14(%ebp),%ecx
    if(sz - i < PGSIZE)
80107031:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80107036:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010703b:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80107041:	0f 46 fe             	cmovbe %esi,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107044:	01 d9                	add    %ebx,%ecx
80107046:	05 00 00 00 80       	add    $0x80000000,%eax
8010704b:	57                   	push   %edi
8010704c:	51                   	push   %ecx
8010704d:	50                   	push   %eax
8010704e:	ff 75 10             	pushl  0x10(%ebp)
80107051:	e8 da a8 ff ff       	call   80101930 <readi>
80107056:	83 c4 10             	add    $0x10,%esp
80107059:	39 f8                	cmp    %edi,%eax
8010705b:	74 ab                	je     80107008 <loaduvm+0x28>
}
8010705d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107065:	5b                   	pop    %ebx
80107066:	5e                   	pop    %esi
80107067:	5f                   	pop    %edi
80107068:	5d                   	pop    %ebp
80107069:	c3                   	ret    
8010706a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107073:	31 c0                	xor    %eax,%eax
}
80107075:	5b                   	pop    %ebx
80107076:	5e                   	pop    %esi
80107077:	5f                   	pop    %edi
80107078:	5d                   	pop    %ebp
80107079:	c3                   	ret    
      panic("loaduvm: address should exist");
8010707a:	83 ec 0c             	sub    $0xc,%esp
8010707d:	68 50 7f 10 80       	push   $0x80107f50
80107082:	e8 e9 92 ff ff       	call   80100370 <panic>
    panic("loaduvm: addr must be page aligned");
80107087:	83 ec 0c             	sub    $0xc,%esp
8010708a:	68 f4 7f 10 80       	push   $0x80107ff4
8010708f:	e8 dc 92 ff ff       	call   80100370 <panic>
80107094:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010709a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801070a0 <allocuvm>:
{
801070a0:	55                   	push   %ebp
801070a1:	89 e5                	mov    %esp,%ebp
801070a3:	57                   	push   %edi
801070a4:	56                   	push   %esi
801070a5:	53                   	push   %ebx
801070a6:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
801070a9:	8b 7d 10             	mov    0x10(%ebp),%edi
801070ac:	85 ff                	test   %edi,%edi
801070ae:	0f 88 8e 00 00 00    	js     80107142 <allocuvm+0xa2>
  if(newsz < oldsz)
801070b4:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801070b7:	0f 82 93 00 00 00    	jb     80107150 <allocuvm+0xb0>
  a = PGROUNDUP(oldsz);
801070bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801070c0:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801070c6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801070cc:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801070cf:	0f 86 7e 00 00 00    	jbe    80107153 <allocuvm+0xb3>
801070d5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801070d8:	8b 7d 08             	mov    0x8(%ebp),%edi
801070db:	eb 42                	jmp    8010711f <allocuvm+0x7f>
801070dd:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
801070e0:	83 ec 04             	sub    $0x4,%esp
801070e3:	68 00 10 00 00       	push   $0x1000
801070e8:	6a 00                	push   $0x0
801070ea:	50                   	push   %eax
801070eb:	e8 20 d8 ff ff       	call   80104910 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801070f0:	58                   	pop    %eax
801070f1:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801070f7:	b9 00 10 00 00       	mov    $0x1000,%ecx
801070fc:	5a                   	pop    %edx
801070fd:	6a 06                	push   $0x6
801070ff:	50                   	push   %eax
80107100:	89 da                	mov    %ebx,%edx
80107102:	89 f8                	mov    %edi,%eax
80107104:	e8 f7 fa ff ff       	call   80106c00 <mappages>
80107109:	83 c4 10             	add    $0x10,%esp
8010710c:	85 c0                	test   %eax,%eax
8010710e:	78 50                	js     80107160 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
80107110:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107116:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80107119:	0f 86 81 00 00 00    	jbe    801071a0 <allocuvm+0x100>
    mem = kalloc();
8010711f:	e8 8c b3 ff ff       	call   801024b0 <kalloc>
    if(mem == 0){
80107124:	85 c0                	test   %eax,%eax
    mem = kalloc();
80107126:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80107128:	75 b6                	jne    801070e0 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
8010712a:	83 ec 0c             	sub    $0xc,%esp
8010712d:	68 6e 7f 10 80       	push   $0x80107f6e
80107132:	e8 09 95 ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
80107137:	83 c4 10             	add    $0x10,%esp
8010713a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010713d:	39 45 10             	cmp    %eax,0x10(%ebp)
80107140:	77 6e                	ja     801071b0 <allocuvm+0x110>
}
80107142:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80107145:	31 ff                	xor    %edi,%edi
}
80107147:	89 f8                	mov    %edi,%eax
80107149:	5b                   	pop    %ebx
8010714a:	5e                   	pop    %esi
8010714b:	5f                   	pop    %edi
8010714c:	5d                   	pop    %ebp
8010714d:	c3                   	ret    
8010714e:	66 90                	xchg   %ax,%ax
    return oldsz;
80107150:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
80107153:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107156:	89 f8                	mov    %edi,%eax
80107158:	5b                   	pop    %ebx
80107159:	5e                   	pop    %esi
8010715a:	5f                   	pop    %edi
8010715b:	5d                   	pop    %ebp
8010715c:	c3                   	ret    
8010715d:	8d 76 00             	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
80107160:	83 ec 0c             	sub    $0xc,%esp
80107163:	68 86 7f 10 80       	push   $0x80107f86
80107168:	e8 d3 94 ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
8010716d:	83 c4 10             	add    $0x10,%esp
80107170:	8b 45 0c             	mov    0xc(%ebp),%eax
80107173:	39 45 10             	cmp    %eax,0x10(%ebp)
80107176:	76 0d                	jbe    80107185 <allocuvm+0xe5>
80107178:	89 c1                	mov    %eax,%ecx
8010717a:	8b 55 10             	mov    0x10(%ebp),%edx
8010717d:	8b 45 08             	mov    0x8(%ebp),%eax
80107180:	e8 0b fb ff ff       	call   80106c90 <deallocuvm.part.0>
      kfree(mem);
80107185:	83 ec 0c             	sub    $0xc,%esp
      return 0;
80107188:	31 ff                	xor    %edi,%edi
      kfree(mem);
8010718a:	56                   	push   %esi
8010718b:	e8 70 b1 ff ff       	call   80102300 <kfree>
      return 0;
80107190:	83 c4 10             	add    $0x10,%esp
}
80107193:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107196:	89 f8                	mov    %edi,%eax
80107198:	5b                   	pop    %ebx
80107199:	5e                   	pop    %esi
8010719a:	5f                   	pop    %edi
8010719b:	5d                   	pop    %ebp
8010719c:	c3                   	ret    
8010719d:	8d 76 00             	lea    0x0(%esi),%esi
801071a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801071a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801071a6:	5b                   	pop    %ebx
801071a7:	89 f8                	mov    %edi,%eax
801071a9:	5e                   	pop    %esi
801071aa:	5f                   	pop    %edi
801071ab:	5d                   	pop    %ebp
801071ac:	c3                   	ret    
801071ad:	8d 76 00             	lea    0x0(%esi),%esi
801071b0:	89 c1                	mov    %eax,%ecx
801071b2:	8b 55 10             	mov    0x10(%ebp),%edx
801071b5:	8b 45 08             	mov    0x8(%ebp),%eax
      return 0;
801071b8:	31 ff                	xor    %edi,%edi
801071ba:	e8 d1 fa ff ff       	call   80106c90 <deallocuvm.part.0>
801071bf:	eb 92                	jmp    80107153 <allocuvm+0xb3>
801071c1:	eb 0d                	jmp    801071d0 <myallocuvm>
801071c3:	90                   	nop
801071c4:	90                   	nop
801071c5:	90                   	nop
801071c6:	90                   	nop
801071c7:	90                   	nop
801071c8:	90                   	nop
801071c9:	90                   	nop
801071ca:	90                   	nop
801071cb:	90                   	nop
801071cc:	90                   	nop
801071cd:	90                   	nop
801071ce:	90                   	nop
801071cf:	90                   	nop

801071d0 <myallocuvm>:
int myallocuvm(pde_t *pgdir,uint start, uint end){
801071d0:	55                   	push   %ebp
801071d1:	89 e5                	mov    %esp,%ebp
801071d3:	57                   	push   %edi
801071d4:	56                   	push   %esi
801071d5:	53                   	push   %ebx
801071d6:	83 ec 0c             	sub    $0xc,%esp
  a = PGROUNDUP(start);
801071d9:	8b 45 0c             	mov    0xc(%ebp),%eax
int myallocuvm(pde_t *pgdir,uint start, uint end){
801071dc:	8b 75 10             	mov    0x10(%ebp),%esi
  a = PGROUNDUP(start);
801071df:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801071e5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end; a += PGSIZE){
801071eb:	39 f3                	cmp    %esi,%ebx
801071ed:	73 3f                	jae    8010722e <myallocuvm+0x5e>
801071ef:	90                   	nop
    mem = kalloc();
801071f0:	e8 bb b2 ff ff       	call   801024b0 <kalloc>
    memset(mem, 0 , PGSIZE);
801071f5:	83 ec 04             	sub    $0x4,%esp
    mem = kalloc();
801071f8:	89 c7                	mov    %eax,%edi
    memset(mem, 0 , PGSIZE);
801071fa:	68 00 10 00 00       	push   $0x1000
801071ff:	6a 00                	push   $0x0
80107201:	50                   	push   %eax
80107202:	e8 09 d7 ff ff       	call   80104910 <memset>
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
80107207:	58                   	pop    %eax
80107208:	5a                   	pop    %edx
80107209:	8d 97 00 00 00 80    	lea    -0x80000000(%edi),%edx
8010720f:	8b 45 08             	mov    0x8(%ebp),%eax
80107212:	6a 06                	push   $0x6
80107214:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107219:	52                   	push   %edx
8010721a:	89 da                	mov    %ebx,%edx
  for(;a<end; a += PGSIZE){
8010721c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
80107222:	e8 d9 f9 ff ff       	call   80106c00 <mappages>
  for(;a<end; a += PGSIZE){
80107227:	83 c4 10             	add    $0x10,%esp
8010722a:	39 de                	cmp    %ebx,%esi
8010722c:	77 c2                	ja     801071f0 <myallocuvm+0x20>
  return (end - start);
8010722e:	89 f0                	mov    %esi,%eax
80107230:	2b 45 0c             	sub    0xc(%ebp),%eax
}
80107233:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107236:	5b                   	pop    %ebx
80107237:	5e                   	pop    %esi
80107238:	5f                   	pop    %edi
80107239:	5d                   	pop    %ebp
8010723a:	c3                   	ret    
8010723b:	90                   	nop
8010723c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107240 <deallocuvm>:
{
80107240:	55                   	push   %ebp
80107241:	89 e5                	mov    %esp,%ebp
80107243:	8b 55 0c             	mov    0xc(%ebp),%edx
80107246:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107249:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
8010724c:	39 d1                	cmp    %edx,%ecx
8010724e:	73 10                	jae    80107260 <deallocuvm+0x20>
}
80107250:	5d                   	pop    %ebp
80107251:	e9 3a fa ff ff       	jmp    80106c90 <deallocuvm.part.0>
80107256:	8d 76 00             	lea    0x0(%esi),%esi
80107259:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80107260:	89 d0                	mov    %edx,%eax
80107262:	5d                   	pop    %ebp
80107263:	c3                   	ret    
80107264:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010726a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107270 <mydeallocuvm>:

int mydeallocuvm(pde_t *pgdir,uint start,uint end){
80107270:	55                   	push   %ebp
80107271:	89 e5                	mov    %esp,%ebp
80107273:	57                   	push   %edi
80107274:	56                   	push   %esi
80107275:	53                   	push   %ebx
80107276:	83 ec 1c             	sub    $0x1c,%esp
  pte_t *pte;
  uint a,pa;
  a=PGROUNDUP(start);
80107279:	8b 45 0c             	mov    0xc(%ebp),%eax
int mydeallocuvm(pde_t *pgdir,uint start,uint end){
8010727c:	8b 75 10             	mov    0x10(%ebp),%esi
8010727f:	8b 7d 08             	mov    0x8(%ebp),%edi
  a=PGROUNDUP(start);
80107282:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107288:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end;a += PGSIZE){
8010728e:	39 f3                	cmp    %esi,%ebx
80107290:	72 3d                	jb     801072cf <mydeallocuvm+0x5f>
80107292:	eb 5a                	jmp    801072ee <mydeallocuvm+0x7e>
80107294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir,(char*)a,0);
    if(!pte){
      a += (NPDENTRIES-1)*PGSIZE;
    }else if((*pte & PTE_P)!=0){
80107298:	8b 10                	mov    (%eax),%edx
8010729a:	f6 c2 01             	test   $0x1,%dl
8010729d:	74 26                	je     801072c5 <mydeallocuvm+0x55>
      pa=PTE_ADDR(*pte);
      if(pa == 0){
8010729f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801072a5:	74 54                	je     801072fb <mydeallocuvm+0x8b>
        panic("kfree");
      }
      char *v = P2V(pa);
      kfree(v);
801072a7:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
801072aa:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801072b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
801072b3:	52                   	push   %edx
801072b4:	e8 47 b0 ff ff       	call   80102300 <kfree>
      *pte=0;
801072b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801072bc:	83 c4 10             	add    $0x10,%esp
801072bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(;a<end;a += PGSIZE){
801072c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801072cb:	39 de                	cmp    %ebx,%esi
801072cd:	76 1f                	jbe    801072ee <mydeallocuvm+0x7e>
    pte = walkpgdir(pgdir,(char*)a,0);
801072cf:	31 c9                	xor    %ecx,%ecx
801072d1:	89 da                	mov    %ebx,%edx
801072d3:	89 f8                	mov    %edi,%eax
801072d5:	e8 a6 f8 ff ff       	call   80106b80 <walkpgdir>
    if(!pte){
801072da:	85 c0                	test   %eax,%eax
801072dc:	75 ba                	jne    80107298 <mydeallocuvm+0x28>
      a += (NPDENTRIES-1)*PGSIZE;
801072de:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(;a<end;a += PGSIZE){
801072e4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801072ea:	39 de                	cmp    %ebx,%esi
801072ec:	77 e1                	ja     801072cf <mydeallocuvm+0x5f>
    }
  }
  return 1;
}
801072ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
801072f1:	b8 01 00 00 00       	mov    $0x1,%eax
801072f6:	5b                   	pop    %ebx
801072f7:	5e                   	pop    %esi
801072f8:	5f                   	pop    %edi
801072f9:	5d                   	pop    %ebp
801072fa:	c3                   	ret    
        panic("kfree");
801072fb:	83 ec 0c             	sub    $0xc,%esp
801072fe:	68 da 77 10 80       	push   $0x801077da
80107303:	e8 68 90 ff ff       	call   80100370 <panic>
80107308:	90                   	nop
80107309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107310 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107310:	55                   	push   %ebp
80107311:	89 e5                	mov    %esp,%ebp
80107313:	57                   	push   %edi
80107314:	56                   	push   %esi
80107315:	53                   	push   %ebx
80107316:	83 ec 0c             	sub    $0xc,%esp
80107319:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010731c:	85 f6                	test   %esi,%esi
8010731e:	74 59                	je     80107379 <freevm+0x69>
80107320:	31 c9                	xor    %ecx,%ecx
80107322:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107327:	89 f0                	mov    %esi,%eax
80107329:	e8 62 f9 ff ff       	call   80106c90 <deallocuvm.part.0>
8010732e:	89 f3                	mov    %esi,%ebx
80107330:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107336:	eb 0f                	jmp    80107347 <freevm+0x37>
80107338:	90                   	nop
80107339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107340:	83 c3 04             	add    $0x4,%ebx
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107343:	39 fb                	cmp    %edi,%ebx
80107345:	74 23                	je     8010736a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107347:	8b 03                	mov    (%ebx),%eax
80107349:	a8 01                	test   $0x1,%al
8010734b:	74 f3                	je     80107340 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010734d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107352:	83 ec 0c             	sub    $0xc,%esp
80107355:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107358:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010735d:	50                   	push   %eax
8010735e:	e8 9d af ff ff       	call   80102300 <kfree>
80107363:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107366:	39 fb                	cmp    %edi,%ebx
80107368:	75 dd                	jne    80107347 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010736a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010736d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107370:	5b                   	pop    %ebx
80107371:	5e                   	pop    %esi
80107372:	5f                   	pop    %edi
80107373:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107374:	e9 87 af ff ff       	jmp    80102300 <kfree>
    panic("freevm: no pgdir");
80107379:	83 ec 0c             	sub    $0xc,%esp
8010737c:	68 a2 7f 10 80       	push   $0x80107fa2
80107381:	e8 ea 8f ff ff       	call   80100370 <panic>
80107386:	8d 76 00             	lea    0x0(%esi),%esi
80107389:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107390 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107390:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107391:	31 c9                	xor    %ecx,%ecx
{
80107393:	89 e5                	mov    %esp,%ebp
80107395:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80107398:	8b 55 0c             	mov    0xc(%ebp),%edx
8010739b:	8b 45 08             	mov    0x8(%ebp),%eax
8010739e:	e8 dd f7 ff ff       	call   80106b80 <walkpgdir>
  if(pte == 0)
801073a3:	85 c0                	test   %eax,%eax
801073a5:	74 05                	je     801073ac <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
801073a7:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801073aa:	c9                   	leave  
801073ab:	c3                   	ret    
    panic("clearpteu");
801073ac:	83 ec 0c             	sub    $0xc,%esp
801073af:	68 b3 7f 10 80       	push   $0x80107fb3
801073b4:	e8 b7 8f ff ff       	call   80100370 <panic>
801073b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801073c0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801073c0:	55                   	push   %ebp
801073c1:	89 e5                	mov    %esp,%ebp
801073c3:	57                   	push   %edi
801073c4:	56                   	push   %esi
801073c5:	53                   	push   %ebx
801073c6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801073c9:	e8 42 fa ff ff       	call   80106e10 <setupkvm>
801073ce:	85 c0                	test   %eax,%eax
801073d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801073d3:	0f 84 a0 00 00 00    	je     80107479 <copyuvm+0xb9>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801073d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801073dc:	85 c9                	test   %ecx,%ecx
801073de:	0f 84 95 00 00 00    	je     80107479 <copyuvm+0xb9>
801073e4:	31 f6                	xor    %esi,%esi
801073e6:	eb 4e                	jmp    80107436 <copyuvm+0x76>
801073e8:	90                   	nop
801073e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801073f0:	83 ec 04             	sub    $0x4,%esp
801073f3:	81 c7 00 00 00 80    	add    $0x80000000,%edi
801073f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801073fc:	68 00 10 00 00       	push   $0x1000
80107401:	57                   	push   %edi
80107402:	50                   	push   %eax
80107403:	e8 b8 d5 ff ff       	call   801049c0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107408:	58                   	pop    %eax
80107409:	5a                   	pop    %edx
8010740a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010740d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107410:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107415:	53                   	push   %ebx
80107416:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010741c:	52                   	push   %edx
8010741d:	89 f2                	mov    %esi,%edx
8010741f:	e8 dc f7 ff ff       	call   80106c00 <mappages>
80107424:	83 c4 10             	add    $0x10,%esp
80107427:	85 c0                	test   %eax,%eax
80107429:	78 39                	js     80107464 <copyuvm+0xa4>
  for(i = 0; i < sz; i += PGSIZE){
8010742b:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107431:	39 75 0c             	cmp    %esi,0xc(%ebp)
80107434:	76 43                	jbe    80107479 <copyuvm+0xb9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107436:	8b 45 08             	mov    0x8(%ebp),%eax
80107439:	31 c9                	xor    %ecx,%ecx
8010743b:	89 f2                	mov    %esi,%edx
8010743d:	e8 3e f7 ff ff       	call   80106b80 <walkpgdir>
80107442:	85 c0                	test   %eax,%eax
80107444:	74 3e                	je     80107484 <copyuvm+0xc4>
    if(!(*pte & PTE_P))
80107446:	8b 18                	mov    (%eax),%ebx
80107448:	f6 c3 01             	test   $0x1,%bl
8010744b:	74 44                	je     80107491 <copyuvm+0xd1>
    pa = PTE_ADDR(*pte);
8010744d:	89 df                	mov    %ebx,%edi
    flags = PTE_FLAGS(*pte);
8010744f:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    pa = PTE_ADDR(*pte);
80107455:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
8010745b:	e8 50 b0 ff ff       	call   801024b0 <kalloc>
80107460:	85 c0                	test   %eax,%eax
80107462:	75 8c                	jne    801073f0 <copyuvm+0x30>
      goto bad;
  }
  return d;

bad:
  freevm(d);
80107464:	83 ec 0c             	sub    $0xc,%esp
80107467:	ff 75 e0             	pushl  -0x20(%ebp)
8010746a:	e8 a1 fe ff ff       	call   80107310 <freevm>
  return 0;
8010746f:	83 c4 10             	add    $0x10,%esp
80107472:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
}
80107479:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010747c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010747f:	5b                   	pop    %ebx
80107480:	5e                   	pop    %esi
80107481:	5f                   	pop    %edi
80107482:	5d                   	pop    %ebp
80107483:	c3                   	ret    
      panic("copyuvm: pte should exist");
80107484:	83 ec 0c             	sub    $0xc,%esp
80107487:	68 bd 7f 10 80       	push   $0x80107fbd
8010748c:	e8 df 8e ff ff       	call   80100370 <panic>
      panic("copyuvm: page not present");
80107491:	83 ec 0c             	sub    $0xc,%esp
80107494:	68 d7 7f 10 80       	push   $0x80107fd7
80107499:	e8 d2 8e ff ff       	call   80100370 <panic>
8010749e:	66 90                	xchg   %ax,%ax

801074a0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801074a0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801074a1:	31 c9                	xor    %ecx,%ecx
{
801074a3:	89 e5                	mov    %esp,%ebp
801074a5:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
801074a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801074ab:	8b 45 08             	mov    0x8(%ebp),%eax
801074ae:	e8 cd f6 ff ff       	call   80106b80 <walkpgdir>
  if((*pte & PTE_P) == 0)
801074b3:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
801074b5:	c9                   	leave  
  if((*pte & PTE_U) == 0)
801074b6:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
801074b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
801074bd:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
801074c0:	05 00 00 00 80       	add    $0x80000000,%eax
801074c5:	83 fa 05             	cmp    $0x5,%edx
801074c8:	ba 00 00 00 00       	mov    $0x0,%edx
801074cd:	0f 45 c2             	cmovne %edx,%eax
}
801074d0:	c3                   	ret    
801074d1:	eb 0d                	jmp    801074e0 <copyout>
801074d3:	90                   	nop
801074d4:	90                   	nop
801074d5:	90                   	nop
801074d6:	90                   	nop
801074d7:	90                   	nop
801074d8:	90                   	nop
801074d9:	90                   	nop
801074da:	90                   	nop
801074db:	90                   	nop
801074dc:	90                   	nop
801074dd:	90                   	nop
801074de:	90                   	nop
801074df:	90                   	nop

801074e0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801074e0:	55                   	push   %ebp
801074e1:	89 e5                	mov    %esp,%ebp
801074e3:	57                   	push   %edi
801074e4:	56                   	push   %esi
801074e5:	53                   	push   %ebx
801074e6:	83 ec 1c             	sub    $0x1c,%esp
801074e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
801074ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801074ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801074f2:	85 db                	test   %ebx,%ebx
801074f4:	75 40                	jne    80107536 <copyout+0x56>
801074f6:	eb 70                	jmp    80107568 <copyout+0x88>
801074f8:	90                   	nop
801074f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80107500:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107503:	89 f1                	mov    %esi,%ecx
80107505:	29 d1                	sub    %edx,%ecx
80107507:	81 c1 00 10 00 00    	add    $0x1000,%ecx
8010750d:	39 d9                	cmp    %ebx,%ecx
8010750f:	0f 47 cb             	cmova  %ebx,%ecx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107512:	29 f2                	sub    %esi,%edx
80107514:	83 ec 04             	sub    $0x4,%esp
80107517:	01 d0                	add    %edx,%eax
80107519:	51                   	push   %ecx
8010751a:	57                   	push   %edi
8010751b:	50                   	push   %eax
8010751c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010751f:	e8 9c d4 ff ff       	call   801049c0 <memmove>
    len -= n;
    buf += n;
80107524:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  while(len > 0){
80107527:	83 c4 10             	add    $0x10,%esp
    va = va0 + PGSIZE;
8010752a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
    buf += n;
80107530:	01 cf                	add    %ecx,%edi
  while(len > 0){
80107532:	29 cb                	sub    %ecx,%ebx
80107534:	74 32                	je     80107568 <copyout+0x88>
    va0 = (uint)PGROUNDDOWN(va);
80107536:	89 d6                	mov    %edx,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107538:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
8010753b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010753e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107544:	56                   	push   %esi
80107545:	ff 75 08             	pushl  0x8(%ebp)
80107548:	e8 53 ff ff ff       	call   801074a0 <uva2ka>
    if(pa0 == 0)
8010754d:	83 c4 10             	add    $0x10,%esp
80107550:	85 c0                	test   %eax,%eax
80107552:	75 ac                	jne    80107500 <copyout+0x20>
  }
  return 0;
}
80107554:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107557:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010755c:	5b                   	pop    %ebx
8010755d:	5e                   	pop    %esi
8010755e:	5f                   	pop    %edi
8010755f:	5d                   	pop    %ebp
80107560:	c3                   	ret    
80107561:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107568:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010756b:	31 c0                	xor    %eax,%eax
}
8010756d:	5b                   	pop    %ebx
8010756e:	5e                   	pop    %esi
8010756f:	5f                   	pop    %edi
80107570:	5d                   	pop    %ebp
80107571:	c3                   	ret    
