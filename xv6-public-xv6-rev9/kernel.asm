
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
8010002d:	b8 40 2f 10 80       	mov    $0x80102f40,%eax
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
80100046:	68 20 7b 10 80       	push   $0x80107b20
8010004b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100050:	e8 8b 4b 00 00       	call   80104be0 <initlock>

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
801000d4:	e8 27 4b 00 00       	call   80104c00 <acquire>
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
80100114:	e8 07 40 00 00       	call   80104120 <sleep>
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
80100154:	e8 67 4c 00 00       	call   80104dc0 <release>
80100159:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if(!(b->flags & B_VALID)) {
8010015c:	f6 03 02             	testb  $0x2,(%ebx)
8010015f:	75 0c                	jne    8010016d <bread+0xad>
    iderw(b);
80100161:	83 ec 0c             	sub    $0xc,%esp
80100164:	53                   	push   %ebx
80100165:	e8 b6 1f 00 00       	call   80102120 <iderw>
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
80100184:	e8 37 4c 00 00       	call   80104dc0 <release>
80100189:	83 c4 10             	add    $0x10,%esp
8010018c:	eb ce                	jmp    8010015c <bread+0x9c>
  panic("bget: no buffers");
8010018e:	83 ec 0c             	sub    $0xc,%esp
80100191:	68 27 7b 10 80       	push   $0x80107b27
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
801001b5:	e9 66 1f 00 00       	jmp    80102120 <iderw>
    panic("bwrite");
801001ba:	83 ec 0c             	sub    $0xc,%esp
801001bd:	68 38 7b 10 80       	push   $0x80107b38
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
801001e7:	e8 14 4a 00 00       	call   80104c00 <acquire>

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
80100221:	e8 ea 40 00 00       	call   80104310 <wakeup>

  release(&bcache.lock);
80100226:	83 c4 10             	add    $0x10,%esp
80100229:	c7 45 08 e0 c5 10 80 	movl   $0x8010c5e0,0x8(%ebp)
}
80100230:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100233:	c9                   	leave  
  release(&bcache.lock);
80100234:	e9 87 4b 00 00       	jmp    80104dc0 <release>
    panic("brelse");
80100239:	83 ec 0c             	sub    $0xc,%esp
8010023c:	68 3f 7b 10 80       	push   $0x80107b3f
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
80100260:	e8 cb 14 00 00       	call   80101730 <iunlock>
  target = n;
  acquire(&cons.lock);
80100265:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010026c:	e8 8f 49 00 00       	call   80104c00 <acquire>
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
801002a5:	e8 76 3e 00 00       	call   80104120 <sleep>
    while(input.r == input.w){
801002aa:	8b 15 80 07 11 80    	mov    0x80110780,%edx
801002b0:	83 c4 10             	add    $0x10,%esp
801002b3:	3b 15 84 07 11 80    	cmp    0x80110784,%edx
801002b9:	75 35                	jne    801002f0 <consoleread+0xa0>
      if(proc->killed){
801002bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801002c1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801002c7:	85 c0                	test   %eax,%eax
801002c9:	74 cd                	je     80100298 <consoleread+0x48>
        release(&cons.lock);
801002cb:	83 ec 0c             	sub    $0xc,%esp
801002ce:	68 20 b5 10 80       	push   $0x8010b520
801002d3:	e8 e8 4a 00 00       	call   80104dc0 <release>
        ilock(ip);
801002d8:	89 3c 24             	mov    %edi,(%esp)
801002db:	e8 40 13 00 00       	call   80101620 <ilock>
        return -1;
801002e0:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
801002e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801002eb:	5b                   	pop    %ebx
801002ec:	5e                   	pop    %esi
801002ed:	5f                   	pop    %edi
801002ee:	5d                   	pop    %ebp
801002ef:	c3                   	ret    
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
8010032d:	e8 8e 4a 00 00       	call   80104dc0 <release>
  ilock(ip);
80100332:	89 3c 24             	mov    %edi,(%esp)
80100335:	e8 e6 12 00 00       	call   80101620 <ilock>
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
80100393:	68 46 7b 10 80       	push   $0x80107b46
80100398:	e8 a3 02 00 00       	call   80100640 <cprintf>
  cprintf(s);
8010039d:	58                   	pop    %eax
8010039e:	ff 75 08             	pushl  0x8(%ebp)
801003a1:	e8 9a 02 00 00       	call   80100640 <cprintf>
  cprintf("\n");
801003a6:	c7 04 24 df 81 10 80 	movl   $0x801081df,(%esp)
801003ad:	e8 8e 02 00 00       	call   80100640 <cprintf>
  getcallerpcs(&s, pcs);
801003b2:	5a                   	pop    %edx
801003b3:	8d 45 08             	lea    0x8(%ebp),%eax
801003b6:	59                   	pop    %ecx
801003b7:	53                   	push   %ebx
801003b8:	50                   	push   %eax
801003b9:	e8 02 49 00 00       	call   80104cc0 <getcallerpcs>
801003be:	83 c4 10             	add    $0x10,%esp
801003c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf(" %p", pcs[i]);
801003c8:	83 ec 08             	sub    $0x8,%esp
801003cb:	ff 33                	pushl  (%ebx)
801003cd:	83 c3 04             	add    $0x4,%ebx
801003d0:	68 62 7b 10 80       	push   $0x80107b62
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
8010041a:	e8 31 62 00 00       	call   80106650 <uartputc>
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
801004cc:	e8 7f 61 00 00       	call   80106650 <uartputc>
801004d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004d8:	e8 73 61 00 00       	call   80106650 <uartputc>
801004dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004e4:	e8 67 61 00 00       	call   80106650 <uartputc>
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
80100504:	e8 b7 49 00 00       	call   80104ec0 <memmove>
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
80100521:	e8 ea 48 00 00       	call   80104e10 <memset>
80100526:	83 c4 10             	add    $0x10,%esp
80100529:	e9 5d ff ff ff       	jmp    8010048b <consputc+0x9b>
    panic("pos under/overflow");
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	68 66 7b 10 80       	push   $0x80107b66
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
80100591:	0f b6 92 94 7b 10 80 	movzbl -0x7fef846c(%edx),%edx
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
801005ef:	e8 3c 11 00 00       	call   80101730 <iunlock>
  acquire(&cons.lock);
801005f4:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
801005fb:	e8 00 46 00 00       	call   80104c00 <acquire>
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
80100627:	e8 94 47 00 00       	call   80104dc0 <release>
  ilock(ip);
8010062c:	58                   	pop    %eax
8010062d:	ff 75 08             	pushl  0x8(%ebp)
80100630:	e8 eb 0f 00 00       	call   80101620 <ilock>

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
801006ff:	e8 bc 46 00 00       	call   80104dc0 <release>
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
801007b0:	ba 79 7b 10 80       	mov    $0x80107b79,%edx
      for(; *s; s++)
801007b5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801007b8:	b8 28 00 00 00       	mov    $0x28,%eax
801007bd:	89 d3                	mov    %edx,%ebx
801007bf:	eb bf                	jmp    80100780 <cprintf+0x140>
801007c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    acquire(&cons.lock);
801007c8:	83 ec 0c             	sub    $0xc,%esp
801007cb:	68 20 b5 10 80       	push   $0x8010b520
801007d0:	e8 2b 44 00 00       	call   80104c00 <acquire>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	e9 7c fe ff ff       	jmp    80100659 <cprintf+0x19>
    panic("null fmt");
801007dd:	83 ec 0c             	sub    $0xc,%esp
801007e0:	68 80 7b 10 80       	push   $0x80107b80
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
80100803:	e8 f8 43 00 00       	call   80104c00 <acquire>
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
80100868:	e8 53 45 00 00       	call   80104dc0 <release>
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
801008f6:	e8 15 3a 00 00       	call   80104310 <wakeup>
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
80100977:	e9 74 3a 00 00       	jmp    801043f0 <procdump>
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
801009a6:	68 89 7b 10 80       	push   $0x80107b89
801009ab:	68 20 b5 10 80       	push   $0x8010b520
801009b0:	e8 2b 42 00 00       	call   80104be0 <initlock>

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
801009da:	e8 31 29 00 00       	call   80103310 <picenable>
  ioapicenable(IRQ_KBD, 0);
801009df:	58                   	pop    %eax
801009e0:	5a                   	pop    %edx
801009e1:	6a 00                	push   $0x0
801009e3:	6a 01                	push   $0x1
801009e5:	e8 f6 18 00 00       	call   801022e0 <ioapicenable>
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
801009fc:	e8 3f 22 00 00       	call   80102c40 <begin_op>
  if((ip = namei(path)) == 0){
80100a01:	83 ec 0c             	sub    $0xc,%esp
80100a04:	ff 75 08             	pushl  0x8(%ebp)
80100a07:	e8 c4 14 00 00       	call   80101ed0 <namei>
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
80100a1d:	e8 fe 0b 00 00       	call   80101620 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100a22:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100a28:	6a 34                	push   $0x34
80100a2a:	6a 00                	push   $0x0
80100a2c:	50                   	push   %eax
80100a2d:	53                   	push   %ebx
80100a2e:	e8 0d 0f 00 00       	call   80101940 <readi>
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
80100a3f:	e8 ac 0e 00 00       	call   801018f0 <iunlockput>
    end_op();
80100a44:	e8 67 22 00 00       	call   80102cb0 <end_op>
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
80100a6c:	e8 2f 69 00 00       	call   801073a0 <setupkvm>
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
80100a91:	0f 84 91 02 00 00    	je     80100d28 <exec+0x338>
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
80100ace:	e8 5d 6b 00 00       	call   80107630 <allocuvm>
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
80100b00:	e8 6b 6a 00 00       	call   80107570 <loaduvm>
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
80100b30:	e8 0b 0e 00 00       	call   80101940 <readi>
80100b35:	83 c4 10             	add    $0x10,%esp
80100b38:	83 f8 20             	cmp    $0x20,%eax
80100b3b:	0f 84 5f ff ff ff    	je     80100aa0 <exec+0xb0>
    freevm(pgdir);
80100b41:	83 ec 0c             	sub    $0xc,%esp
80100b44:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100b4a:	e8 51 6d 00 00       	call   801078a0 <freevm>
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
80100b76:	e8 75 0d 00 00       	call   801018f0 <iunlockput>
  end_op();
80100b7b:	e8 30 21 00 00       	call   80102cb0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100b80:	83 c4 0c             	add    $0xc,%esp
80100b83:	56                   	push   %esi
80100b84:	57                   	push   %edi
80100b85:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100b8b:	e8 a0 6a 00 00       	call   80107630 <allocuvm>
80100b90:	83 c4 10             	add    $0x10,%esp
80100b93:	85 c0                	test   %eax,%eax
80100b95:	89 c6                	mov    %eax,%esi
80100b97:	75 2a                	jne    80100bc3 <exec+0x1d3>
    freevm(pgdir);
80100b99:	83 ec 0c             	sub    $0xc,%esp
80100b9c:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100ba2:	e8 f9 6c 00 00       	call   801078a0 <freevm>
80100ba7:	83 c4 10             	add    $0x10,%esp
  return -1;
80100baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100baf:	e9 9d fe ff ff       	jmp    80100a51 <exec+0x61>
    end_op();
80100bb4:	e8 f7 20 00 00       	call   80102cb0 <end_op>
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
80100bd7:	e8 44 6d 00 00       	call   80107920 <clearpteu>
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
80100c09:	e8 22 44 00 00       	call   80105030 <strlen>
80100c0e:	f7 d0                	not    %eax
80100c10:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c12:	58                   	pop    %eax
80100c13:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100c16:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c19:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c1c:	e8 0f 44 00 00       	call   80105030 <strlen>
80100c21:	83 c0 01             	add    $0x1,%eax
80100c24:	50                   	push   %eax
80100c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c28:	ff 34 b8             	pushl  (%eax,%edi,4)
80100c2b:	53                   	push   %ebx
80100c2c:	56                   	push   %esi
80100c2d:	e8 3e 6e 00 00       	call   80107a70 <copyout>
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
80100c97:	e8 d4 6d 00 00       	call   80107a70 <copyout>
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
80100cd1:	05 f0 00 00 00       	add    $0xf0,%eax
80100cd6:	50                   	push   %eax
80100cd7:	e8 14 43 00 00       	call   80104ff0 <safestrcpy>
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
80100cfc:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80100d02:	89 4a 38             	mov    %ecx,0x38(%edx)
  proc->tf->esp = sp;
80100d05:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80100d0b:	89 5a 44             	mov    %ebx,0x44(%edx)
  switchuvm(proc);
80100d0e:	89 04 24             	mov    %eax,(%esp)
80100d11:	e8 3a 67 00 00       	call   80107450 <switchuvm>
  freevm(oldpgdir);
80100d16:	89 3c 24             	mov    %edi,(%esp)
80100d19:	e8 82 6b 00 00       	call   801078a0 <freevm>
  return 0;
80100d1e:	83 c4 10             	add    $0x10,%esp
80100d21:	31 c0                	xor    %eax,%eax
80100d23:	e9 29 fd ff ff       	jmp    80100a51 <exec+0x61>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d28:	be 00 20 00 00       	mov    $0x2000,%esi
80100d2d:	e9 40 fe ff ff       	jmp    80100b72 <exec+0x182>
80100d32:	66 90                	xchg   %ax,%ax
80100d34:	66 90                	xchg   %ax,%ax
80100d36:	66 90                	xchg   %ax,%ax
80100d38:	66 90                	xchg   %ax,%ax
80100d3a:	66 90                	xchg   %ax,%ax
80100d3c:	66 90                	xchg   %ax,%ax
80100d3e:	66 90                	xchg   %ax,%ax

80100d40 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100d40:	55                   	push   %ebp
80100d41:	89 e5                	mov    %esp,%ebp
80100d43:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100d46:	68 a5 7b 10 80       	push   $0x80107ba5
80100d4b:	68 a0 07 11 80       	push   $0x801107a0
80100d50:	e8 8b 3e 00 00       	call   80104be0 <initlock>
}
80100d55:	83 c4 10             	add    $0x10,%esp
80100d58:	c9                   	leave  
80100d59:	c3                   	ret    
80100d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100d60 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100d60:	55                   	push   %ebp
80100d61:	89 e5                	mov    %esp,%ebp
80100d63:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100d64:	bb d4 07 11 80       	mov    $0x801107d4,%ebx
{
80100d69:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100d6c:	68 a0 07 11 80       	push   $0x801107a0
80100d71:	e8 8a 3e 00 00       	call   80104c00 <acquire>
80100d76:	83 c4 10             	add    $0x10,%esp
80100d79:	eb 10                	jmp    80100d8b <filealloc+0x2b>
80100d7b:	90                   	nop
80100d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100d80:	83 c3 18             	add    $0x18,%ebx
80100d83:	81 fb 34 11 11 80    	cmp    $0x80111134,%ebx
80100d89:	73 25                	jae    80100db0 <filealloc+0x50>
    if(f->ref == 0){
80100d8b:	8b 43 04             	mov    0x4(%ebx),%eax
80100d8e:	85 c0                	test   %eax,%eax
80100d90:	75 ee                	jne    80100d80 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100d92:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100d95:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100d9c:	68 a0 07 11 80       	push   $0x801107a0
80100da1:	e8 1a 40 00 00       	call   80104dc0 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100da6:	89 d8                	mov    %ebx,%eax
      return f;
80100da8:	83 c4 10             	add    $0x10,%esp
}
80100dab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dae:	c9                   	leave  
80100daf:	c3                   	ret    
  release(&ftable.lock);
80100db0:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100db3:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100db5:	68 a0 07 11 80       	push   $0x801107a0
80100dba:	e8 01 40 00 00       	call   80104dc0 <release>
}
80100dbf:	89 d8                	mov    %ebx,%eax
  return 0;
80100dc1:	83 c4 10             	add    $0x10,%esp
}
80100dc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dc7:	c9                   	leave  
80100dc8:	c3                   	ret    
80100dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100dd0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100dd0:	55                   	push   %ebp
80100dd1:	89 e5                	mov    %esp,%ebp
80100dd3:	53                   	push   %ebx
80100dd4:	83 ec 10             	sub    $0x10,%esp
80100dd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100dda:	68 a0 07 11 80       	push   $0x801107a0
80100ddf:	e8 1c 3e 00 00       	call   80104c00 <acquire>
  if(f->ref < 1)
80100de4:	8b 43 04             	mov    0x4(%ebx),%eax
80100de7:	83 c4 10             	add    $0x10,%esp
80100dea:	85 c0                	test   %eax,%eax
80100dec:	7e 1a                	jle    80100e08 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100dee:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100df1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100df4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100df7:	68 a0 07 11 80       	push   $0x801107a0
80100dfc:	e8 bf 3f 00 00       	call   80104dc0 <release>
  return f;
}
80100e01:	89 d8                	mov    %ebx,%eax
80100e03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e06:	c9                   	leave  
80100e07:	c3                   	ret    
    panic("filedup");
80100e08:	83 ec 0c             	sub    $0xc,%esp
80100e0b:	68 ac 7b 10 80       	push   $0x80107bac
80100e10:	e8 5b f5 ff ff       	call   80100370 <panic>
80100e15:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100e20 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100e20:	55                   	push   %ebp
80100e21:	89 e5                	mov    %esp,%ebp
80100e23:	57                   	push   %edi
80100e24:	56                   	push   %esi
80100e25:	53                   	push   %ebx
80100e26:	83 ec 28             	sub    $0x28,%esp
80100e29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100e2c:	68 a0 07 11 80       	push   $0x801107a0
80100e31:	e8 ca 3d 00 00       	call   80104c00 <acquire>
  if(f->ref < 1)
80100e36:	8b 43 04             	mov    0x4(%ebx),%eax
80100e39:	83 c4 10             	add    $0x10,%esp
80100e3c:	85 c0                	test   %eax,%eax
80100e3e:	0f 8e 9b 00 00 00    	jle    80100edf <fileclose+0xbf>
    panic("fileclose");
  if(--f->ref > 0){
80100e44:	83 e8 01             	sub    $0x1,%eax
80100e47:	85 c0                	test   %eax,%eax
80100e49:	89 43 04             	mov    %eax,0x4(%ebx)
80100e4c:	74 1a                	je     80100e68 <fileclose+0x48>
    release(&ftable.lock);
80100e4e:	c7 45 08 a0 07 11 80 	movl   $0x801107a0,0x8(%ebp)
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100e55:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100e58:	5b                   	pop    %ebx
80100e59:	5e                   	pop    %esi
80100e5a:	5f                   	pop    %edi
80100e5b:	5d                   	pop    %ebp
    release(&ftable.lock);
80100e5c:	e9 5f 3f 00 00       	jmp    80104dc0 <release>
80100e61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  ff = *f;
80100e68:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
80100e6c:	8b 3b                	mov    (%ebx),%edi
  release(&ftable.lock);
80100e6e:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80100e71:	8b 73 0c             	mov    0xc(%ebx),%esi
  f->type = FD_NONE;
80100e74:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
80100e7a:	88 45 e7             	mov    %al,-0x19(%ebp)
80100e7d:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80100e80:	68 a0 07 11 80       	push   $0x801107a0
  ff = *f;
80100e85:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80100e88:	e8 33 3f 00 00       	call   80104dc0 <release>
  if(ff.type == FD_PIPE)
80100e8d:	83 c4 10             	add    $0x10,%esp
80100e90:	83 ff 01             	cmp    $0x1,%edi
80100e93:	74 13                	je     80100ea8 <fileclose+0x88>
  else if(ff.type == FD_INODE){
80100e95:	83 ff 02             	cmp    $0x2,%edi
80100e98:	74 26                	je     80100ec0 <fileclose+0xa0>
}
80100e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100e9d:	5b                   	pop    %ebx
80100e9e:	5e                   	pop    %esi
80100e9f:	5f                   	pop    %edi
80100ea0:	5d                   	pop    %ebp
80100ea1:	c3                   	ret    
80100ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pipeclose(ff.pipe, ff.writable);
80100ea8:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80100eac:	83 ec 08             	sub    $0x8,%esp
80100eaf:	53                   	push   %ebx
80100eb0:	56                   	push   %esi
80100eb1:	e8 3a 26 00 00       	call   801034f0 <pipeclose>
80100eb6:	83 c4 10             	add    $0x10,%esp
80100eb9:	eb df                	jmp    80100e9a <fileclose+0x7a>
80100ebb:	90                   	nop
80100ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    begin_op();
80100ec0:	e8 7b 1d 00 00       	call   80102c40 <begin_op>
    iput(ff.ip);
80100ec5:	83 ec 0c             	sub    $0xc,%esp
80100ec8:	ff 75 e0             	pushl  -0x20(%ebp)
80100ecb:	e8 c0 08 00 00       	call   80101790 <iput>
    end_op();
80100ed0:	83 c4 10             	add    $0x10,%esp
}
80100ed3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100ed6:	5b                   	pop    %ebx
80100ed7:	5e                   	pop    %esi
80100ed8:	5f                   	pop    %edi
80100ed9:	5d                   	pop    %ebp
    end_op();
80100eda:	e9 d1 1d 00 00       	jmp    80102cb0 <end_op>
    panic("fileclose");
80100edf:	83 ec 0c             	sub    $0xc,%esp
80100ee2:	68 b4 7b 10 80       	push   $0x80107bb4
80100ee7:	e8 84 f4 ff ff       	call   80100370 <panic>
80100eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100ef0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100ef0:	55                   	push   %ebp
80100ef1:	89 e5                	mov    %esp,%ebp
80100ef3:	53                   	push   %ebx
80100ef4:	83 ec 04             	sub    $0x4,%esp
80100ef7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100efa:	83 3b 02             	cmpl   $0x2,(%ebx)
80100efd:	75 31                	jne    80100f30 <filestat+0x40>
    ilock(f->ip);
80100eff:	83 ec 0c             	sub    $0xc,%esp
80100f02:	ff 73 10             	pushl  0x10(%ebx)
80100f05:	e8 16 07 00 00       	call   80101620 <ilock>
    stati(f->ip, st);
80100f0a:	58                   	pop    %eax
80100f0b:	5a                   	pop    %edx
80100f0c:	ff 75 0c             	pushl  0xc(%ebp)
80100f0f:	ff 73 10             	pushl  0x10(%ebx)
80100f12:	e8 f9 09 00 00       	call   80101910 <stati>
    iunlock(f->ip);
80100f17:	59                   	pop    %ecx
80100f18:	ff 73 10             	pushl  0x10(%ebx)
80100f1b:	e8 10 08 00 00       	call   80101730 <iunlock>
    return 0;
80100f20:	83 c4 10             	add    $0x10,%esp
80100f23:	31 c0                	xor    %eax,%eax
  }
  return -1;
}
80100f25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f28:	c9                   	leave  
80100f29:	c3                   	ret    
80100f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return -1;
80100f30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f35:	eb ee                	jmp    80100f25 <filestat+0x35>
80100f37:	89 f6                	mov    %esi,%esi
80100f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100f40 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100f40:	55                   	push   %ebp
80100f41:	89 e5                	mov    %esp,%ebp
80100f43:	57                   	push   %edi
80100f44:	56                   	push   %esi
80100f45:	53                   	push   %ebx
80100f46:	83 ec 0c             	sub    $0xc,%esp
80100f49:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100f4c:	8b 75 0c             	mov    0xc(%ebp),%esi
80100f4f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80100f52:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100f56:	74 60                	je     80100fb8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80100f58:	8b 03                	mov    (%ebx),%eax
80100f5a:	83 f8 01             	cmp    $0x1,%eax
80100f5d:	74 41                	je     80100fa0 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100f5f:	83 f8 02             	cmp    $0x2,%eax
80100f62:	75 5b                	jne    80100fbf <fileread+0x7f>
    ilock(f->ip);
80100f64:	83 ec 0c             	sub    $0xc,%esp
80100f67:	ff 73 10             	pushl  0x10(%ebx)
80100f6a:	e8 b1 06 00 00       	call   80101620 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100f6f:	57                   	push   %edi
80100f70:	ff 73 14             	pushl  0x14(%ebx)
80100f73:	56                   	push   %esi
80100f74:	ff 73 10             	pushl  0x10(%ebx)
80100f77:	e8 c4 09 00 00       	call   80101940 <readi>
80100f7c:	83 c4 20             	add    $0x20,%esp
80100f7f:	85 c0                	test   %eax,%eax
80100f81:	89 c6                	mov    %eax,%esi
80100f83:	7e 03                	jle    80100f88 <fileread+0x48>
      f->off += r;
80100f85:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100f88:	83 ec 0c             	sub    $0xc,%esp
80100f8b:	ff 73 10             	pushl  0x10(%ebx)
80100f8e:	e8 9d 07 00 00       	call   80101730 <iunlock>
    return r;
80100f93:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f99:	89 f0                	mov    %esi,%eax
80100f9b:	5b                   	pop    %ebx
80100f9c:	5e                   	pop    %esi
80100f9d:	5f                   	pop    %edi
80100f9e:	5d                   	pop    %ebp
80100f9f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100fa0:	8b 43 0c             	mov    0xc(%ebx),%eax
80100fa3:	89 45 08             	mov    %eax,0x8(%ebp)
}
80100fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fa9:	5b                   	pop    %ebx
80100faa:	5e                   	pop    %esi
80100fab:	5f                   	pop    %edi
80100fac:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
80100fad:	e9 0e 27 00 00       	jmp    801036c0 <piperead>
80100fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80100fb8:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100fbd:	eb d7                	jmp    80100f96 <fileread+0x56>
  panic("fileread");
80100fbf:	83 ec 0c             	sub    $0xc,%esp
80100fc2:	68 be 7b 10 80       	push   $0x80107bbe
80100fc7:	e8 a4 f3 ff ff       	call   80100370 <panic>
80100fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100fd0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100fd0:	55                   	push   %ebp
80100fd1:	89 e5                	mov    %esp,%ebp
80100fd3:	57                   	push   %edi
80100fd4:	56                   	push   %esi
80100fd5:	53                   	push   %ebx
80100fd6:	83 ec 1c             	sub    $0x1c,%esp
80100fd9:	8b 75 08             	mov    0x8(%ebp),%esi
80100fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  int r;

  if(f->writable == 0)
80100fdf:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
{
80100fe3:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80100fe9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
80100fec:	0f 84 aa 00 00 00    	je     8010109c <filewrite+0xcc>
    return -1;
  if(f->type == FD_PIPE)
80100ff2:	8b 06                	mov    (%esi),%eax
80100ff4:	83 f8 01             	cmp    $0x1,%eax
80100ff7:	0f 84 c3 00 00 00    	je     801010c0 <filewrite+0xf0>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100ffd:	83 f8 02             	cmp    $0x2,%eax
80101000:	0f 85 d9 00 00 00    	jne    801010df <filewrite+0x10f>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101006:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
80101009:	31 ff                	xor    %edi,%edi
    while(i < n){
8010100b:	85 c0                	test   %eax,%eax
8010100d:	7f 34                	jg     80101043 <filewrite+0x73>
8010100f:	e9 9c 00 00 00       	jmp    801010b0 <filewrite+0xe0>
80101014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101018:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	ff 76 10             	pushl  0x10(%esi)
        f->off += r;
80101021:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101024:	e8 07 07 00 00       	call   80101730 <iunlock>
      end_op();
80101029:	e8 82 1c 00 00       	call   80102cb0 <end_op>
8010102e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101031:	83 c4 10             	add    $0x10,%esp

      if(r < 0)
        break;
      if(r != n1)
80101034:	39 c3                	cmp    %eax,%ebx
80101036:	0f 85 96 00 00 00    	jne    801010d2 <filewrite+0x102>
        panic("short filewrite");
      i += r;
8010103c:	01 df                	add    %ebx,%edi
    while(i < n){
8010103e:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101041:	7e 6d                	jle    801010b0 <filewrite+0xe0>
      int n1 = n - i;
80101043:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101046:	b8 00 1a 00 00       	mov    $0x1a00,%eax
8010104b:	29 fb                	sub    %edi,%ebx
8010104d:	81 fb 00 1a 00 00    	cmp    $0x1a00,%ebx
80101053:	0f 4f d8             	cmovg  %eax,%ebx
      begin_op();
80101056:	e8 e5 1b 00 00       	call   80102c40 <begin_op>
      ilock(f->ip);
8010105b:	83 ec 0c             	sub    $0xc,%esp
8010105e:	ff 76 10             	pushl  0x10(%esi)
80101061:	e8 ba 05 00 00       	call   80101620 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101066:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101069:	53                   	push   %ebx
8010106a:	ff 76 14             	pushl  0x14(%esi)
8010106d:	01 f8                	add    %edi,%eax
8010106f:	50                   	push   %eax
80101070:	ff 76 10             	pushl  0x10(%esi)
80101073:	e8 c8 09 00 00       	call   80101a40 <writei>
80101078:	83 c4 20             	add    $0x20,%esp
8010107b:	85 c0                	test   %eax,%eax
8010107d:	7f 99                	jg     80101018 <filewrite+0x48>
      iunlock(f->ip);
8010107f:	83 ec 0c             	sub    $0xc,%esp
80101082:	ff 76 10             	pushl  0x10(%esi)
80101085:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101088:	e8 a3 06 00 00       	call   80101730 <iunlock>
      end_op();
8010108d:	e8 1e 1c 00 00       	call   80102cb0 <end_op>
      if(r < 0)
80101092:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101095:	83 c4 10             	add    $0x10,%esp
80101098:	85 c0                	test   %eax,%eax
8010109a:	74 98                	je     80101034 <filewrite+0x64>
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
8010109c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010109f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
}
801010a4:	89 f8                	mov    %edi,%eax
801010a6:	5b                   	pop    %ebx
801010a7:	5e                   	pop    %esi
801010a8:	5f                   	pop    %edi
801010a9:	5d                   	pop    %ebp
801010aa:	c3                   	ret    
801010ab:	90                   	nop
801010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return i == n ? n : -1;
801010b0:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
801010b3:	75 e7                	jne    8010109c <filewrite+0xcc>
}
801010b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010b8:	89 f8                	mov    %edi,%eax
801010ba:	5b                   	pop    %ebx
801010bb:	5e                   	pop    %esi
801010bc:	5f                   	pop    %edi
801010bd:	5d                   	pop    %ebp
801010be:	c3                   	ret    
801010bf:	90                   	nop
    return pipewrite(f->pipe, addr, n);
801010c0:	8b 46 0c             	mov    0xc(%esi),%eax
801010c3:	89 45 08             	mov    %eax,0x8(%ebp)
}
801010c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010c9:	5b                   	pop    %ebx
801010ca:	5e                   	pop    %esi
801010cb:	5f                   	pop    %edi
801010cc:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801010cd:	e9 be 24 00 00       	jmp    80103590 <pipewrite>
        panic("short filewrite");
801010d2:	83 ec 0c             	sub    $0xc,%esp
801010d5:	68 c7 7b 10 80       	push   $0x80107bc7
801010da:	e8 91 f2 ff ff       	call   80100370 <panic>
  panic("filewrite");
801010df:	83 ec 0c             	sub    $0xc,%esp
801010e2:	68 cd 7b 10 80       	push   $0x80107bcd
801010e7:	e8 84 f2 ff ff       	call   80100370 <panic>
801010ec:	66 90                	xchg   %ax,%ax
801010ee:	66 90                	xchg   %ax,%ax

801010f0 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801010f0:	55                   	push   %ebp
801010f1:	89 e5                	mov    %esp,%ebp
801010f3:	57                   	push   %edi
801010f4:	56                   	push   %esi
801010f5:	53                   	push   %ebx
801010f6:	83 ec 1c             	sub    $0x1c,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801010f9:	8b 0d a0 11 11 80    	mov    0x801111a0,%ecx
{
801010ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101102:	85 c9                	test   %ecx,%ecx
80101104:	0f 84 87 00 00 00    	je     80101191 <balloc+0xa1>
8010110a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101111:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101114:	83 ec 08             	sub    $0x8,%esp
80101117:	89 f0                	mov    %esi,%eax
80101119:	c1 f8 0c             	sar    $0xc,%eax
8010111c:	03 05 b8 11 11 80    	add    0x801111b8,%eax
80101122:	50                   	push   %eax
80101123:	ff 75 d8             	pushl  -0x28(%ebp)
80101126:	e8 95 ef ff ff       	call   801000c0 <bread>
8010112b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010112e:	a1 a0 11 11 80       	mov    0x801111a0,%eax
80101133:	83 c4 10             	add    $0x10,%esp
80101136:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101139:	31 c0                	xor    %eax,%eax
8010113b:	eb 2f                	jmp    8010116c <balloc+0x7c>
8010113d:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
80101140:	89 c1                	mov    %eax,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101142:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
80101145:	bb 01 00 00 00       	mov    $0x1,%ebx
8010114a:	83 e1 07             	and    $0x7,%ecx
8010114d:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010114f:	89 c1                	mov    %eax,%ecx
80101151:	c1 f9 03             	sar    $0x3,%ecx
80101154:	0f b6 7c 0a 18       	movzbl 0x18(%edx,%ecx,1),%edi
80101159:	85 df                	test   %ebx,%edi
8010115b:	89 fa                	mov    %edi,%edx
8010115d:	74 41                	je     801011a0 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010115f:	83 c0 01             	add    $0x1,%eax
80101162:	83 c6 01             	add    $0x1,%esi
80101165:	3d 00 10 00 00       	cmp    $0x1000,%eax
8010116a:	74 05                	je     80101171 <balloc+0x81>
8010116c:	39 75 e0             	cmp    %esi,-0x20(%ebp)
8010116f:	77 cf                	ja     80101140 <balloc+0x50>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	ff 75 e4             	pushl  -0x1c(%ebp)
80101177:	e8 54 f0 ff ff       	call   801001d0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010117c:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
80101183:	83 c4 10             	add    $0x10,%esp
80101186:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101189:	39 05 a0 11 11 80    	cmp    %eax,0x801111a0
8010118f:	77 80                	ja     80101111 <balloc+0x21>
  }
  panic("balloc: out of blocks");
80101191:	83 ec 0c             	sub    $0xc,%esp
80101194:	68 d7 7b 10 80       	push   $0x80107bd7
80101199:	e8 d2 f1 ff ff       	call   80100370 <panic>
8010119e:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
801011a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
801011a3:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
801011a6:	09 da                	or     %ebx,%edx
801011a8:	88 54 0f 18          	mov    %dl,0x18(%edi,%ecx,1)
        log_write(bp);
801011ac:	57                   	push   %edi
801011ad:	e8 5e 1c 00 00       	call   80102e10 <log_write>
        brelse(bp);
801011b2:	89 3c 24             	mov    %edi,(%esp)
801011b5:	e8 16 f0 ff ff       	call   801001d0 <brelse>
  bp = bread(dev, bno);
801011ba:	58                   	pop    %eax
801011bb:	5a                   	pop    %edx
801011bc:	56                   	push   %esi
801011bd:	ff 75 d8             	pushl  -0x28(%ebp)
801011c0:	e8 fb ee ff ff       	call   801000c0 <bread>
801011c5:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
801011c7:	8d 40 18             	lea    0x18(%eax),%eax
801011ca:	83 c4 0c             	add    $0xc,%esp
801011cd:	68 00 02 00 00       	push   $0x200
801011d2:	6a 00                	push   $0x0
801011d4:	50                   	push   %eax
801011d5:	e8 36 3c 00 00       	call   80104e10 <memset>
  log_write(bp);
801011da:	89 1c 24             	mov    %ebx,(%esp)
801011dd:	e8 2e 1c 00 00       	call   80102e10 <log_write>
  brelse(bp);
801011e2:	89 1c 24             	mov    %ebx,(%esp)
801011e5:	e8 e6 ef ff ff       	call   801001d0 <brelse>
}
801011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011ed:	89 f0                	mov    %esi,%eax
801011ef:	5b                   	pop    %ebx
801011f0:	5e                   	pop    %esi
801011f1:	5f                   	pop    %edi
801011f2:	5d                   	pop    %ebp
801011f3:	c3                   	ret    
801011f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801011fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80101200 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101200:	55                   	push   %ebp
80101201:	89 e5                	mov    %esp,%ebp
80101203:	57                   	push   %edi
80101204:	56                   	push   %esi
80101205:	53                   	push   %ebx
80101206:	89 c7                	mov    %eax,%edi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101208:	31 f6                	xor    %esi,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010120a:	bb f4 11 11 80       	mov    $0x801111f4,%ebx
{
8010120f:	83 ec 28             	sub    $0x28,%esp
80101212:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101215:	68 c0 11 11 80       	push   $0x801111c0
8010121a:	e8 e1 39 00 00       	call   80104c00 <acquire>
8010121f:	83 c4 10             	add    $0x10,%esp
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101222:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101225:	eb 14                	jmp    8010123b <iget+0x3b>
80101227:	89 f6                	mov    %esi,%esi
80101229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80101230:	83 c3 50             	add    $0x50,%ebx
80101233:	81 fb 94 21 11 80    	cmp    $0x80112194,%ebx
80101239:	73 1f                	jae    8010125a <iget+0x5a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010123b:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010123e:	85 c9                	test   %ecx,%ecx
80101240:	7e 04                	jle    80101246 <iget+0x46>
80101242:	39 3b                	cmp    %edi,(%ebx)
80101244:	74 4a                	je     80101290 <iget+0x90>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101246:	85 f6                	test   %esi,%esi
80101248:	75 e6                	jne    80101230 <iget+0x30>
8010124a:	85 c9                	test   %ecx,%ecx
8010124c:	0f 44 f3             	cmove  %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010124f:	83 c3 50             	add    $0x50,%ebx
80101252:	81 fb 94 21 11 80    	cmp    $0x80112194,%ebx
80101258:	72 e1                	jb     8010123b <iget+0x3b>
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010125a:	85 f6                	test   %esi,%esi
8010125c:	74 59                	je     801012b7 <iget+0xb7>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);
8010125e:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
80101261:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101263:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
80101266:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->flags = 0;
8010126d:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
  release(&icache.lock);
80101274:	68 c0 11 11 80       	push   $0x801111c0
80101279:	e8 42 3b 00 00       	call   80104dc0 <release>

  return ip;
8010127e:	83 c4 10             	add    $0x10,%esp
}
80101281:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101284:	89 f0                	mov    %esi,%eax
80101286:	5b                   	pop    %ebx
80101287:	5e                   	pop    %esi
80101288:	5f                   	pop    %edi
80101289:	5d                   	pop    %ebp
8010128a:	c3                   	ret    
8010128b:	90                   	nop
8010128c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101290:	39 53 04             	cmp    %edx,0x4(%ebx)
80101293:	75 b1                	jne    80101246 <iget+0x46>
      release(&icache.lock);
80101295:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101298:	83 c1 01             	add    $0x1,%ecx
      return ip;
8010129b:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
8010129d:	68 c0 11 11 80       	push   $0x801111c0
      ip->ref++;
801012a2:	89 4b 08             	mov    %ecx,0x8(%ebx)
      release(&icache.lock);
801012a5:	e8 16 3b 00 00       	call   80104dc0 <release>
      return ip;
801012aa:	83 c4 10             	add    $0x10,%esp
}
801012ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012b0:	89 f0                	mov    %esi,%eax
801012b2:	5b                   	pop    %ebx
801012b3:	5e                   	pop    %esi
801012b4:	5f                   	pop    %edi
801012b5:	5d                   	pop    %ebp
801012b6:	c3                   	ret    
    panic("iget: no inodes");
801012b7:	83 ec 0c             	sub    $0xc,%esp
801012ba:	68 ed 7b 10 80       	push   $0x80107bed
801012bf:	e8 ac f0 ff ff       	call   80100370 <panic>
801012c4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801012ca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801012d0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
801012d0:	55                   	push   %ebp
801012d1:	89 e5                	mov    %esp,%ebp
801012d3:	57                   	push   %edi
801012d4:	56                   	push   %esi
801012d5:	53                   	push   %ebx
801012d6:	89 c6                	mov    %eax,%esi
801012d8:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
801012db:	83 fa 0b             	cmp    $0xb,%edx
801012de:	77 18                	ja     801012f8 <bmap+0x28>
801012e0:	8d 3c 90             	lea    (%eax,%edx,4),%edi
    if((addr = ip->addrs[bn]) == 0)
801012e3:	8b 5f 1c             	mov    0x1c(%edi),%ebx
801012e6:	85 db                	test   %ebx,%ebx
801012e8:	74 6e                	je     80101358 <bmap+0x88>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
801012ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012ed:	89 d8                	mov    %ebx,%eax
801012ef:	5b                   	pop    %ebx
801012f0:	5e                   	pop    %esi
801012f1:	5f                   	pop    %edi
801012f2:	5d                   	pop    %ebp
801012f3:	c3                   	ret    
801012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  bn -= NDIRECT;
801012f8:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
801012fb:	83 fb 7f             	cmp    $0x7f,%ebx
801012fe:	77 7e                	ja     8010137e <bmap+0xae>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101300:	8b 50 4c             	mov    0x4c(%eax),%edx
80101303:	8b 00                	mov    (%eax),%eax
80101305:	85 d2                	test   %edx,%edx
80101307:	74 67                	je     80101370 <bmap+0xa0>
    bp = bread(ip->dev, addr);
80101309:	83 ec 08             	sub    $0x8,%esp
8010130c:	52                   	push   %edx
8010130d:	50                   	push   %eax
8010130e:	e8 ad ed ff ff       	call   801000c0 <bread>
    if((addr = a[bn]) == 0){
80101313:	8d 54 98 18          	lea    0x18(%eax,%ebx,4),%edx
80101317:	83 c4 10             	add    $0x10,%esp
    bp = bread(ip->dev, addr);
8010131a:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
8010131c:	8b 1a                	mov    (%edx),%ebx
8010131e:	85 db                	test   %ebx,%ebx
80101320:	75 1d                	jne    8010133f <bmap+0x6f>
      a[bn] = addr = balloc(ip->dev);
80101322:	8b 06                	mov    (%esi),%eax
80101324:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101327:	e8 c4 fd ff ff       	call   801010f0 <balloc>
8010132c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      log_write(bp);
8010132f:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
80101332:	89 c3                	mov    %eax,%ebx
80101334:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101336:	57                   	push   %edi
80101337:	e8 d4 1a 00 00       	call   80102e10 <log_write>
8010133c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010133f:	83 ec 0c             	sub    $0xc,%esp
80101342:	57                   	push   %edi
80101343:	e8 88 ee ff ff       	call   801001d0 <brelse>
80101348:	83 c4 10             	add    $0x10,%esp
}
8010134b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010134e:	89 d8                	mov    %ebx,%eax
80101350:	5b                   	pop    %ebx
80101351:	5e                   	pop    %esi
80101352:	5f                   	pop    %edi
80101353:	5d                   	pop    %ebp
80101354:	c3                   	ret    
80101355:	8d 76 00             	lea    0x0(%esi),%esi
      ip->addrs[bn] = addr = balloc(ip->dev);
80101358:	8b 00                	mov    (%eax),%eax
8010135a:	e8 91 fd ff ff       	call   801010f0 <balloc>
8010135f:	89 47 1c             	mov    %eax,0x1c(%edi)
}
80101362:	8d 65 f4             	lea    -0xc(%ebp),%esp
      ip->addrs[bn] = addr = balloc(ip->dev);
80101365:	89 c3                	mov    %eax,%ebx
}
80101367:	89 d8                	mov    %ebx,%eax
80101369:	5b                   	pop    %ebx
8010136a:	5e                   	pop    %esi
8010136b:	5f                   	pop    %edi
8010136c:	5d                   	pop    %ebp
8010136d:	c3                   	ret    
8010136e:	66 90                	xchg   %ax,%ax
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101370:	e8 7b fd ff ff       	call   801010f0 <balloc>
80101375:	89 c2                	mov    %eax,%edx
80101377:	89 46 4c             	mov    %eax,0x4c(%esi)
8010137a:	8b 06                	mov    (%esi),%eax
8010137c:	eb 8b                	jmp    80101309 <bmap+0x39>
  panic("bmap: out of range");
8010137e:	83 ec 0c             	sub    $0xc,%esp
80101381:	68 fd 7b 10 80       	push   $0x80107bfd
80101386:	e8 e5 ef ff ff       	call   80100370 <panic>
8010138b:	90                   	nop
8010138c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101390 <readsb>:
{
80101390:	55                   	push   %ebp
80101391:	89 e5                	mov    %esp,%ebp
80101393:	56                   	push   %esi
80101394:	53                   	push   %ebx
80101395:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101398:	83 ec 08             	sub    $0x8,%esp
8010139b:	6a 01                	push   $0x1
8010139d:	ff 75 08             	pushl  0x8(%ebp)
801013a0:	e8 1b ed ff ff       	call   801000c0 <bread>
801013a5:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801013a7:	8d 40 18             	lea    0x18(%eax),%eax
801013aa:	83 c4 0c             	add    $0xc,%esp
801013ad:	6a 1c                	push   $0x1c
801013af:	50                   	push   %eax
801013b0:	56                   	push   %esi
801013b1:	e8 0a 3b 00 00       	call   80104ec0 <memmove>
  brelse(bp);
801013b6:	89 5d 08             	mov    %ebx,0x8(%ebp)
801013b9:	83 c4 10             	add    $0x10,%esp
}
801013bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801013bf:	5b                   	pop    %ebx
801013c0:	5e                   	pop    %esi
801013c1:	5d                   	pop    %ebp
  brelse(bp);
801013c2:	e9 09 ee ff ff       	jmp    801001d0 <brelse>
801013c7:	89 f6                	mov    %esi,%esi
801013c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801013d0 <bfree>:
{
801013d0:	55                   	push   %ebp
801013d1:	89 e5                	mov    %esp,%ebp
801013d3:	56                   	push   %esi
801013d4:	53                   	push   %ebx
801013d5:	89 d3                	mov    %edx,%ebx
801013d7:	89 c6                	mov    %eax,%esi
  readsb(dev, &sb);
801013d9:	83 ec 08             	sub    $0x8,%esp
801013dc:	68 a0 11 11 80       	push   $0x801111a0
801013e1:	50                   	push   %eax
801013e2:	e8 a9 ff ff ff       	call   80101390 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801013e7:	58                   	pop    %eax
801013e8:	5a                   	pop    %edx
801013e9:	89 da                	mov    %ebx,%edx
801013eb:	c1 ea 0c             	shr    $0xc,%edx
801013ee:	03 15 b8 11 11 80    	add    0x801111b8,%edx
801013f4:	52                   	push   %edx
801013f5:	56                   	push   %esi
801013f6:	e8 c5 ec ff ff       	call   801000c0 <bread>
  m = 1 << (bi % 8);
801013fb:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801013fd:	c1 fb 03             	sar    $0x3,%ebx
  m = 1 << (bi % 8);
80101400:	ba 01 00 00 00       	mov    $0x1,%edx
80101405:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
80101408:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010140e:	83 c4 10             	add    $0x10,%esp
  m = 1 << (bi % 8);
80101411:	d3 e2                	shl    %cl,%edx
  if((bp->data[bi/8] & m) == 0)
80101413:	0f b6 4c 18 18       	movzbl 0x18(%eax,%ebx,1),%ecx
80101418:	85 d1                	test   %edx,%ecx
8010141a:	74 25                	je     80101441 <bfree+0x71>
  bp->data[bi/8] &= ~m;
8010141c:	f7 d2                	not    %edx
8010141e:	89 c6                	mov    %eax,%esi
  log_write(bp);
80101420:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101423:	21 ca                	and    %ecx,%edx
80101425:	88 54 1e 18          	mov    %dl,0x18(%esi,%ebx,1)
  log_write(bp);
80101429:	56                   	push   %esi
8010142a:	e8 e1 19 00 00       	call   80102e10 <log_write>
  brelse(bp);
8010142f:	89 34 24             	mov    %esi,(%esp)
80101432:	e8 99 ed ff ff       	call   801001d0 <brelse>
}
80101437:	83 c4 10             	add    $0x10,%esp
8010143a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010143d:	5b                   	pop    %ebx
8010143e:	5e                   	pop    %esi
8010143f:	5d                   	pop    %ebp
80101440:	c3                   	ret    
    panic("freeing free block");
80101441:	83 ec 0c             	sub    $0xc,%esp
80101444:	68 10 7c 10 80       	push   $0x80107c10
80101449:	e8 22 ef ff ff       	call   80100370 <panic>
8010144e:	66 90                	xchg   %ax,%ax

80101450 <iinit>:
{
80101450:	55                   	push   %ebp
80101451:	89 e5                	mov    %esp,%ebp
80101453:	83 ec 10             	sub    $0x10,%esp
  initlock(&icache.lock, "icache");
80101456:	68 23 7c 10 80       	push   $0x80107c23
8010145b:	68 c0 11 11 80       	push   $0x801111c0
80101460:	e8 7b 37 00 00       	call   80104be0 <initlock>
  readsb(dev, &sb);
80101465:	58                   	pop    %eax
80101466:	5a                   	pop    %edx
80101467:	68 a0 11 11 80       	push   $0x801111a0
8010146c:	ff 75 08             	pushl  0x8(%ebp)
8010146f:	e8 1c ff ff ff       	call   80101390 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101474:	ff 35 b8 11 11 80    	pushl  0x801111b8
8010147a:	ff 35 b4 11 11 80    	pushl  0x801111b4
80101480:	ff 35 b0 11 11 80    	pushl  0x801111b0
80101486:	ff 35 ac 11 11 80    	pushl  0x801111ac
8010148c:	ff 35 a8 11 11 80    	pushl  0x801111a8
80101492:	ff 35 a4 11 11 80    	pushl  0x801111a4
80101498:	ff 35 a0 11 11 80    	pushl  0x801111a0
8010149e:	68 84 7c 10 80       	push   $0x80107c84
801014a3:	e8 98 f1 ff ff       	call   80100640 <cprintf>
}
801014a8:	83 c4 30             	add    $0x30,%esp
801014ab:	c9                   	leave  
801014ac:	c3                   	ret    
801014ad:	8d 76 00             	lea    0x0(%esi),%esi

801014b0 <ialloc>:
{
801014b0:	55                   	push   %ebp
801014b1:	89 e5                	mov    %esp,%ebp
801014b3:	57                   	push   %edi
801014b4:	56                   	push   %esi
801014b5:	53                   	push   %ebx
801014b6:	83 ec 1c             	sub    $0x1c,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801014b9:	83 3d a8 11 11 80 01 	cmpl   $0x1,0x801111a8
{
801014c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801014c3:	8b 75 08             	mov    0x8(%ebp),%esi
801014c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
801014c9:	0f 86 91 00 00 00    	jbe    80101560 <ialloc+0xb0>
801014cf:	bb 01 00 00 00       	mov    $0x1,%ebx
801014d4:	eb 21                	jmp    801014f7 <ialloc+0x47>
801014d6:	8d 76 00             	lea    0x0(%esi),%esi
801014d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    brelse(bp);
801014e0:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801014e3:	83 c3 01             	add    $0x1,%ebx
    brelse(bp);
801014e6:	57                   	push   %edi
801014e7:	e8 e4 ec ff ff       	call   801001d0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801014ec:	83 c4 10             	add    $0x10,%esp
801014ef:	39 1d a8 11 11 80    	cmp    %ebx,0x801111a8
801014f5:	76 69                	jbe    80101560 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
801014f7:	89 d8                	mov    %ebx,%eax
801014f9:	83 ec 08             	sub    $0x8,%esp
801014fc:	c1 e8 03             	shr    $0x3,%eax
801014ff:	03 05 b4 11 11 80    	add    0x801111b4,%eax
80101505:	50                   	push   %eax
80101506:	56                   	push   %esi
80101507:	e8 b4 eb ff ff       	call   801000c0 <bread>
8010150c:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
8010150e:	89 d8                	mov    %ebx,%eax
    if(dip->type == 0){  // a free inode
80101510:	83 c4 10             	add    $0x10,%esp
    dip = (struct dinode*)bp->data + inum%IPB;
80101513:	83 e0 07             	and    $0x7,%eax
80101516:	c1 e0 06             	shl    $0x6,%eax
80101519:	8d 4c 07 18          	lea    0x18(%edi,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010151d:	66 83 39 00          	cmpw   $0x0,(%ecx)
80101521:	75 bd                	jne    801014e0 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101523:	83 ec 04             	sub    $0x4,%esp
80101526:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101529:	6a 40                	push   $0x40
8010152b:	6a 00                	push   $0x0
8010152d:	51                   	push   %ecx
8010152e:	e8 dd 38 00 00       	call   80104e10 <memset>
      dip->type = type;
80101533:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80101537:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010153a:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
8010153d:	89 3c 24             	mov    %edi,(%esp)
80101540:	e8 cb 18 00 00       	call   80102e10 <log_write>
      brelse(bp);
80101545:	89 3c 24             	mov    %edi,(%esp)
80101548:	e8 83 ec ff ff       	call   801001d0 <brelse>
      return iget(dev, inum);
8010154d:	83 c4 10             	add    $0x10,%esp
}
80101550:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
80101553:	89 da                	mov    %ebx,%edx
80101555:	89 f0                	mov    %esi,%eax
}
80101557:	5b                   	pop    %ebx
80101558:	5e                   	pop    %esi
80101559:	5f                   	pop    %edi
8010155a:	5d                   	pop    %ebp
      return iget(dev, inum);
8010155b:	e9 a0 fc ff ff       	jmp    80101200 <iget>
  panic("ialloc: no inodes");
80101560:	83 ec 0c             	sub    $0xc,%esp
80101563:	68 2a 7c 10 80       	push   $0x80107c2a
80101568:	e8 03 ee ff ff       	call   80100370 <panic>
8010156d:	8d 76 00             	lea    0x0(%esi),%esi

80101570 <iupdate>:
{
80101570:	55                   	push   %ebp
80101571:	89 e5                	mov    %esp,%ebp
80101573:	56                   	push   %esi
80101574:	53                   	push   %ebx
80101575:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101578:	83 ec 08             	sub    $0x8,%esp
8010157b:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010157e:	83 c3 1c             	add    $0x1c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101581:	c1 e8 03             	shr    $0x3,%eax
80101584:	03 05 b4 11 11 80    	add    0x801111b4,%eax
8010158a:	50                   	push   %eax
8010158b:	ff 73 e4             	pushl  -0x1c(%ebx)
8010158e:	e8 2d eb ff ff       	call   801000c0 <bread>
80101593:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101595:	8b 43 e8             	mov    -0x18(%ebx),%eax
  dip->type = ip->type;
80101598:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010159c:	83 c4 0c             	add    $0xc,%esp
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010159f:	83 e0 07             	and    $0x7,%eax
801015a2:	c1 e0 06             	shl    $0x6,%eax
801015a5:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
  dip->type = ip->type;
801015a9:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801015ac:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801015b0:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
801015b3:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
801015b7:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
801015bb:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
801015bf:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
801015c3:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
801015c7:	8b 53 fc             	mov    -0x4(%ebx),%edx
801015ca:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801015cd:	6a 34                	push   $0x34
801015cf:	53                   	push   %ebx
801015d0:	50                   	push   %eax
801015d1:	e8 ea 38 00 00       	call   80104ec0 <memmove>
  log_write(bp);
801015d6:	89 34 24             	mov    %esi,(%esp)
801015d9:	e8 32 18 00 00       	call   80102e10 <log_write>
  brelse(bp);
801015de:	89 75 08             	mov    %esi,0x8(%ebp)
801015e1:	83 c4 10             	add    $0x10,%esp
}
801015e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015e7:	5b                   	pop    %ebx
801015e8:	5e                   	pop    %esi
801015e9:	5d                   	pop    %ebp
  brelse(bp);
801015ea:	e9 e1 eb ff ff       	jmp    801001d0 <brelse>
801015ef:	90                   	nop

801015f0 <idup>:
{
801015f0:	55                   	push   %ebp
801015f1:	89 e5                	mov    %esp,%ebp
801015f3:	53                   	push   %ebx
801015f4:	83 ec 10             	sub    $0x10,%esp
801015f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801015fa:	68 c0 11 11 80       	push   $0x801111c0
801015ff:	e8 fc 35 00 00       	call   80104c00 <acquire>
  ip->ref++;
80101604:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101608:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
8010160f:	e8 ac 37 00 00       	call   80104dc0 <release>
}
80101614:	89 d8                	mov    %ebx,%eax
80101616:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101619:	c9                   	leave  
8010161a:	c3                   	ret    
8010161b:	90                   	nop
8010161c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101620 <ilock>:
{
80101620:	55                   	push   %ebp
80101621:	89 e5                	mov    %esp,%ebp
80101623:	56                   	push   %esi
80101624:	53                   	push   %ebx
80101625:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101628:	85 db                	test   %ebx,%ebx
8010162a:	0f 84 e8 00 00 00    	je     80101718 <ilock+0xf8>
80101630:	8b 43 08             	mov    0x8(%ebx),%eax
80101633:	85 c0                	test   %eax,%eax
80101635:	0f 8e dd 00 00 00    	jle    80101718 <ilock+0xf8>
  acquire(&icache.lock);
8010163b:	83 ec 0c             	sub    $0xc,%esp
8010163e:	68 c0 11 11 80       	push   $0x801111c0
80101643:	e8 b8 35 00 00       	call   80104c00 <acquire>
  while(ip->flags & I_BUSY)
80101648:	8b 43 0c             	mov    0xc(%ebx),%eax
8010164b:	83 c4 10             	add    $0x10,%esp
8010164e:	a8 01                	test   $0x1,%al
80101650:	74 1e                	je     80101670 <ilock+0x50>
80101652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sleep(ip, &icache.lock);
80101658:	83 ec 08             	sub    $0x8,%esp
8010165b:	68 c0 11 11 80       	push   $0x801111c0
80101660:	53                   	push   %ebx
80101661:	e8 ba 2a 00 00       	call   80104120 <sleep>
  while(ip->flags & I_BUSY)
80101666:	8b 43 0c             	mov    0xc(%ebx),%eax
80101669:	83 c4 10             	add    $0x10,%esp
8010166c:	a8 01                	test   $0x1,%al
8010166e:	75 e8                	jne    80101658 <ilock+0x38>
  release(&icache.lock);
80101670:	83 ec 0c             	sub    $0xc,%esp
  ip->flags |= I_BUSY;
80101673:	83 c8 01             	or     $0x1,%eax
80101676:	89 43 0c             	mov    %eax,0xc(%ebx)
  release(&icache.lock);
80101679:	68 c0 11 11 80       	push   $0x801111c0
8010167e:	e8 3d 37 00 00       	call   80104dc0 <release>
  if(!(ip->flags & I_VALID)){
80101683:	83 c4 10             	add    $0x10,%esp
80101686:	f6 43 0c 02          	testb  $0x2,0xc(%ebx)
8010168a:	74 0c                	je     80101698 <ilock+0x78>
}
8010168c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010168f:	5b                   	pop    %ebx
80101690:	5e                   	pop    %esi
80101691:	5d                   	pop    %ebp
80101692:	c3                   	ret    
80101693:	90                   	nop
80101694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101698:	8b 43 04             	mov    0x4(%ebx),%eax
8010169b:	83 ec 08             	sub    $0x8,%esp
8010169e:	c1 e8 03             	shr    $0x3,%eax
801016a1:	03 05 b4 11 11 80    	add    0x801111b4,%eax
801016a7:	50                   	push   %eax
801016a8:	ff 33                	pushl  (%ebx)
801016aa:	e8 11 ea ff ff       	call   801000c0 <bread>
801016af:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801016b1:	8b 43 04             	mov    0x4(%ebx),%eax
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801016b4:	83 c4 0c             	add    $0xc,%esp
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801016b7:	83 e0 07             	and    $0x7,%eax
801016ba:	c1 e0 06             	shl    $0x6,%eax
801016bd:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
    ip->type = dip->type;
801016c1:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801016c4:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
801016c7:	66 89 53 10          	mov    %dx,0x10(%ebx)
    ip->major = dip->major;
801016cb:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
801016cf:	66 89 53 12          	mov    %dx,0x12(%ebx)
    ip->minor = dip->minor;
801016d3:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
801016d7:	66 89 53 14          	mov    %dx,0x14(%ebx)
    ip->nlink = dip->nlink;
801016db:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
801016df:	66 89 53 16          	mov    %dx,0x16(%ebx)
    ip->size = dip->size;
801016e3:	8b 50 fc             	mov    -0x4(%eax),%edx
801016e6:	89 53 18             	mov    %edx,0x18(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801016e9:	6a 34                	push   $0x34
801016eb:	50                   	push   %eax
801016ec:	8d 43 1c             	lea    0x1c(%ebx),%eax
801016ef:	50                   	push   %eax
801016f0:	e8 cb 37 00 00       	call   80104ec0 <memmove>
    brelse(bp);
801016f5:	89 34 24             	mov    %esi,(%esp)
801016f8:	e8 d3 ea ff ff       	call   801001d0 <brelse>
    ip->flags |= I_VALID;
801016fd:	83 4b 0c 02          	orl    $0x2,0xc(%ebx)
    if(ip->type == 0)
80101701:	83 c4 10             	add    $0x10,%esp
80101704:	66 83 7b 10 00       	cmpw   $0x0,0x10(%ebx)
80101709:	75 81                	jne    8010168c <ilock+0x6c>
      panic("ilock: no type");
8010170b:	83 ec 0c             	sub    $0xc,%esp
8010170e:	68 42 7c 10 80       	push   $0x80107c42
80101713:	e8 58 ec ff ff       	call   80100370 <panic>
    panic("ilock");
80101718:	83 ec 0c             	sub    $0xc,%esp
8010171b:	68 3c 7c 10 80       	push   $0x80107c3c
80101720:	e8 4b ec ff ff       	call   80100370 <panic>
80101725:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101729:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101730 <iunlock>:
{
80101730:	55                   	push   %ebp
80101731:	89 e5                	mov    %esp,%ebp
80101733:	53                   	push   %ebx
80101734:	83 ec 04             	sub    $0x4,%esp
80101737:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
8010173a:	85 db                	test   %ebx,%ebx
8010173c:	74 39                	je     80101777 <iunlock+0x47>
8010173e:	f6 43 0c 01          	testb  $0x1,0xc(%ebx)
80101742:	74 33                	je     80101777 <iunlock+0x47>
80101744:	8b 43 08             	mov    0x8(%ebx),%eax
80101747:	85 c0                	test   %eax,%eax
80101749:	7e 2c                	jle    80101777 <iunlock+0x47>
  acquire(&icache.lock);
8010174b:	83 ec 0c             	sub    $0xc,%esp
8010174e:	68 c0 11 11 80       	push   $0x801111c0
80101753:	e8 a8 34 00 00       	call   80104c00 <acquire>
  ip->flags &= ~I_BUSY;
80101758:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
8010175c:	89 1c 24             	mov    %ebx,(%esp)
8010175f:	e8 ac 2b 00 00       	call   80104310 <wakeup>
  release(&icache.lock);
80101764:	83 c4 10             	add    $0x10,%esp
80101767:	c7 45 08 c0 11 11 80 	movl   $0x801111c0,0x8(%ebp)
}
8010176e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101771:	c9                   	leave  
  release(&icache.lock);
80101772:	e9 49 36 00 00       	jmp    80104dc0 <release>
    panic("iunlock");
80101777:	83 ec 0c             	sub    $0xc,%esp
8010177a:	68 51 7c 10 80       	push   $0x80107c51
8010177f:	e8 ec eb ff ff       	call   80100370 <panic>
80101784:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010178a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80101790 <iput>:
{
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	57                   	push   %edi
80101794:	56                   	push   %esi
80101795:	53                   	push   %ebx
80101796:	83 ec 28             	sub    $0x28,%esp
80101799:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&icache.lock);
8010179c:	68 c0 11 11 80       	push   $0x801111c0
801017a1:	e8 5a 34 00 00       	call   80104c00 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
801017a6:	8b 46 08             	mov    0x8(%esi),%eax
801017a9:	83 c4 10             	add    $0x10,%esp
801017ac:	83 f8 01             	cmp    $0x1,%eax
801017af:	0f 85 ab 00 00 00    	jne    80101860 <iput+0xd0>
801017b5:	8b 56 0c             	mov    0xc(%esi),%edx
801017b8:	f6 c2 02             	test   $0x2,%dl
801017bb:	0f 84 9f 00 00 00    	je     80101860 <iput+0xd0>
801017c1:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
801017c6:	0f 85 94 00 00 00    	jne    80101860 <iput+0xd0>
    if(ip->flags & I_BUSY)
801017cc:	f6 c2 01             	test   $0x1,%dl
801017cf:	0f 85 05 01 00 00    	jne    801018da <iput+0x14a>
    release(&icache.lock);
801017d5:	83 ec 0c             	sub    $0xc,%esp
    ip->flags |= I_BUSY;
801017d8:	83 ca 01             	or     $0x1,%edx
801017db:	8d 5e 1c             	lea    0x1c(%esi),%ebx
801017de:	89 56 0c             	mov    %edx,0xc(%esi)
    release(&icache.lock);
801017e1:	68 c0 11 11 80       	push   $0x801111c0
801017e6:	8d 7e 4c             	lea    0x4c(%esi),%edi
801017e9:	e8 d2 35 00 00       	call   80104dc0 <release>
801017ee:	83 c4 10             	add    $0x10,%esp
801017f1:	eb 0c                	jmp    801017ff <iput+0x6f>
801017f3:	90                   	nop
801017f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801017f8:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801017fb:	39 fb                	cmp    %edi,%ebx
801017fd:	74 1b                	je     8010181a <iput+0x8a>
    if(ip->addrs[i]){
801017ff:	8b 13                	mov    (%ebx),%edx
80101801:	85 d2                	test   %edx,%edx
80101803:	74 f3                	je     801017f8 <iput+0x68>
      bfree(ip->dev, ip->addrs[i]);
80101805:	8b 06                	mov    (%esi),%eax
80101807:	83 c3 04             	add    $0x4,%ebx
8010180a:	e8 c1 fb ff ff       	call   801013d0 <bfree>
      ip->addrs[i] = 0;
8010180f:	c7 43 fc 00 00 00 00 	movl   $0x0,-0x4(%ebx)
  for(i = 0; i < NDIRECT; i++){
80101816:	39 fb                	cmp    %edi,%ebx
80101818:	75 e5                	jne    801017ff <iput+0x6f>
    }
  }

  if(ip->addrs[NDIRECT]){
8010181a:	8b 46 4c             	mov    0x4c(%esi),%eax
8010181d:	85 c0                	test   %eax,%eax
8010181f:	75 5f                	jne    80101880 <iput+0xf0>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101821:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101824:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
  iupdate(ip);
8010182b:	56                   	push   %esi
8010182c:	e8 3f fd ff ff       	call   80101570 <iupdate>
    ip->type = 0;
80101831:	31 c0                	xor    %eax,%eax
80101833:	66 89 46 10          	mov    %ax,0x10(%esi)
    iupdate(ip);
80101837:	89 34 24             	mov    %esi,(%esp)
8010183a:	e8 31 fd ff ff       	call   80101570 <iupdate>
    acquire(&icache.lock);
8010183f:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
80101846:	e8 b5 33 00 00       	call   80104c00 <acquire>
    ip->flags = 0;
8010184b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
80101852:	89 34 24             	mov    %esi,(%esp)
80101855:	e8 b6 2a 00 00       	call   80104310 <wakeup>
8010185a:	8b 46 08             	mov    0x8(%esi),%eax
8010185d:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101860:	83 e8 01             	sub    $0x1,%eax
80101863:	89 46 08             	mov    %eax,0x8(%esi)
  release(&icache.lock);
80101866:	c7 45 08 c0 11 11 80 	movl   $0x801111c0,0x8(%ebp)
}
8010186d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101870:	5b                   	pop    %ebx
80101871:	5e                   	pop    %esi
80101872:	5f                   	pop    %edi
80101873:	5d                   	pop    %ebp
  release(&icache.lock);
80101874:	e9 47 35 00 00       	jmp    80104dc0 <release>
80101879:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101880:	83 ec 08             	sub    $0x8,%esp
80101883:	50                   	push   %eax
80101884:	ff 36                	pushl  (%esi)
80101886:	e8 35 e8 ff ff       	call   801000c0 <bread>
8010188b:	83 c4 10             	add    $0x10,%esp
8010188e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101891:	8d 58 18             	lea    0x18(%eax),%ebx
80101894:	8d b8 18 02 00 00    	lea    0x218(%eax),%edi
8010189a:	eb 0b                	jmp    801018a7 <iput+0x117>
8010189c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801018a0:	83 c3 04             	add    $0x4,%ebx
    for(j = 0; j < NINDIRECT; j++){
801018a3:	39 df                	cmp    %ebx,%edi
801018a5:	74 0f                	je     801018b6 <iput+0x126>
      if(a[j])
801018a7:	8b 13                	mov    (%ebx),%edx
801018a9:	85 d2                	test   %edx,%edx
801018ab:	74 f3                	je     801018a0 <iput+0x110>
        bfree(ip->dev, a[j]);
801018ad:	8b 06                	mov    (%esi),%eax
801018af:	e8 1c fb ff ff       	call   801013d0 <bfree>
801018b4:	eb ea                	jmp    801018a0 <iput+0x110>
    brelse(bp);
801018b6:	83 ec 0c             	sub    $0xc,%esp
801018b9:	ff 75 e4             	pushl  -0x1c(%ebp)
801018bc:	e8 0f e9 ff ff       	call   801001d0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801018c1:	8b 56 4c             	mov    0x4c(%esi),%edx
801018c4:	8b 06                	mov    (%esi),%eax
801018c6:	e8 05 fb ff ff       	call   801013d0 <bfree>
    ip->addrs[NDIRECT] = 0;
801018cb:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
801018d2:	83 c4 10             	add    $0x10,%esp
801018d5:	e9 47 ff ff ff       	jmp    80101821 <iput+0x91>
      panic("iput busy");
801018da:	83 ec 0c             	sub    $0xc,%esp
801018dd:	68 59 7c 10 80       	push   $0x80107c59
801018e2:	e8 89 ea ff ff       	call   80100370 <panic>
801018e7:	89 f6                	mov    %esi,%esi
801018e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801018f0 <iunlockput>:
{
801018f0:	55                   	push   %ebp
801018f1:	89 e5                	mov    %esp,%ebp
801018f3:	53                   	push   %ebx
801018f4:	83 ec 10             	sub    $0x10,%esp
801018f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801018fa:	53                   	push   %ebx
801018fb:	e8 30 fe ff ff       	call   80101730 <iunlock>
  iput(ip);
80101900:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101903:	83 c4 10             	add    $0x10,%esp
}
80101906:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101909:	c9                   	leave  
  iput(ip);
8010190a:	e9 81 fe ff ff       	jmp    80101790 <iput>
8010190f:	90                   	nop

80101910 <stati>:
}

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101910:	55                   	push   %ebp
80101911:	89 e5                	mov    %esp,%ebp
80101913:	8b 55 08             	mov    0x8(%ebp),%edx
80101916:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101919:	8b 0a                	mov    (%edx),%ecx
8010191b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
8010191e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101921:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101924:	0f b7 4a 10          	movzwl 0x10(%edx),%ecx
80101928:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
8010192b:	0f b7 4a 16          	movzwl 0x16(%edx),%ecx
8010192f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101933:	8b 52 18             	mov    0x18(%edx),%edx
80101936:	89 50 10             	mov    %edx,0x10(%eax)
}
80101939:	5d                   	pop    %ebp
8010193a:	c3                   	ret    
8010193b:	90                   	nop
8010193c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101940 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101940:	55                   	push   %ebp
80101941:	89 e5                	mov    %esp,%ebp
80101943:	57                   	push   %edi
80101944:	56                   	push   %esi
80101945:	53                   	push   %ebx
80101946:	83 ec 1c             	sub    $0x1c,%esp
80101949:	8b 45 08             	mov    0x8(%ebp),%eax
8010194c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010194f:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101952:	66 83 78 10 03       	cmpw   $0x3,0x10(%eax)
{
80101957:	89 75 e0             	mov    %esi,-0x20(%ebp)
8010195a:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010195d:	8b 75 10             	mov    0x10(%ebp),%esi
80101960:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101963:	0f 84 a7 00 00 00    	je     80101a10 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101969:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010196c:	8b 40 18             	mov    0x18(%eax),%eax
8010196f:	39 c6                	cmp    %eax,%esi
80101971:	0f 87 ba 00 00 00    	ja     80101a31 <readi+0xf1>
80101977:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010197a:	89 f9                	mov    %edi,%ecx
8010197c:	01 f1                	add    %esi,%ecx
8010197e:	0f 82 ad 00 00 00    	jb     80101a31 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101984:	89 c2                	mov    %eax,%edx
80101986:	29 f2                	sub    %esi,%edx
80101988:	39 c8                	cmp    %ecx,%eax
8010198a:	0f 43 d7             	cmovae %edi,%edx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010198d:	31 ff                	xor    %edi,%edi
8010198f:	85 d2                	test   %edx,%edx
    n = ip->size - off;
80101991:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101994:	74 6c                	je     80101a02 <readi+0xc2>
80101996:	8d 76 00             	lea    0x0(%esi),%esi
80101999:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801019a0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
801019a3:	89 f2                	mov    %esi,%edx
801019a5:	c1 ea 09             	shr    $0x9,%edx
801019a8:	89 d8                	mov    %ebx,%eax
801019aa:	e8 21 f9 ff ff       	call   801012d0 <bmap>
801019af:	83 ec 08             	sub    $0x8,%esp
801019b2:	50                   	push   %eax
801019b3:	ff 33                	pushl  (%ebx)
801019b5:	e8 06 e7 ff ff       	call   801000c0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
801019ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801019bd:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
801019bf:	89 f0                	mov    %esi,%eax
801019c1:	25 ff 01 00 00       	and    $0x1ff,%eax
801019c6:	b9 00 02 00 00       	mov    $0x200,%ecx
801019cb:	83 c4 0c             	add    $0xc,%esp
801019ce:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
801019d0:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
801019d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801019d7:	29 fb                	sub    %edi,%ebx
801019d9:	39 d9                	cmp    %ebx,%ecx
801019db:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
801019de:	53                   	push   %ebx
801019df:	50                   	push   %eax
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801019e0:	01 df                	add    %ebx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
801019e2:	ff 75 e0             	pushl  -0x20(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801019e5:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
801019e7:	e8 d4 34 00 00       	call   80104ec0 <memmove>
    brelse(bp);
801019ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
801019ef:	89 14 24             	mov    %edx,(%esp)
801019f2:	e8 d9 e7 ff ff       	call   801001d0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801019f7:	01 5d e0             	add    %ebx,-0x20(%ebp)
801019fa:	83 c4 10             	add    $0x10,%esp
801019fd:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101a00:	77 9e                	ja     801019a0 <readi+0x60>
  }
  return n;
80101a02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101a05:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a08:	5b                   	pop    %ebx
80101a09:	5e                   	pop    %esi
80101a0a:	5f                   	pop    %edi
80101a0b:	5d                   	pop    %ebp
80101a0c:	c3                   	ret    
80101a0d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101a10:	0f bf 40 12          	movswl 0x12(%eax),%eax
80101a14:	66 83 f8 09          	cmp    $0x9,%ax
80101a18:	77 17                	ja     80101a31 <readi+0xf1>
80101a1a:	8b 04 c5 40 11 11 80 	mov    -0x7feeeec0(,%eax,8),%eax
80101a21:	85 c0                	test   %eax,%eax
80101a23:	74 0c                	je     80101a31 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101a25:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101a28:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a2b:	5b                   	pop    %ebx
80101a2c:	5e                   	pop    %esi
80101a2d:	5f                   	pop    %edi
80101a2e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101a2f:	ff e0                	jmp    *%eax
      return -1;
80101a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a36:	eb cd                	jmp    80101a05 <readi+0xc5>
80101a38:	90                   	nop
80101a39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101a40 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101a40:	55                   	push   %ebp
80101a41:	89 e5                	mov    %esp,%ebp
80101a43:	57                   	push   %edi
80101a44:	56                   	push   %esi
80101a45:	53                   	push   %ebx
80101a46:	83 ec 1c             	sub    $0x1c,%esp
80101a49:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
80101a4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101a52:	66 83 78 10 03       	cmpw   $0x3,0x10(%eax)
{
80101a57:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101a5a:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101a5d:	8b 75 10             	mov    0x10(%ebp),%esi
80101a60:	89 7d e0             	mov    %edi,-0x20(%ebp)
  if(ip->type == T_DEV){
80101a63:	0f 84 b7 00 00 00    	je     80101b20 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101a69:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101a6c:	39 70 18             	cmp    %esi,0x18(%eax)
80101a6f:	0f 82 eb 00 00 00    	jb     80101b60 <writei+0x120>
80101a75:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101a78:	31 d2                	xor    %edx,%edx
80101a7a:	89 f8                	mov    %edi,%eax
80101a7c:	01 f0                	add    %esi,%eax
80101a7e:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101a81:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101a86:	0f 87 d4 00 00 00    	ja     80101b60 <writei+0x120>
80101a8c:	85 d2                	test   %edx,%edx
80101a8e:	0f 85 cc 00 00 00    	jne    80101b60 <writei+0x120>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101a94:	85 ff                	test   %edi,%edi
80101a96:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101a9d:	74 72                	je     80101b11 <writei+0xd1>
80101a9f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101aa0:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101aa3:	89 f2                	mov    %esi,%edx
80101aa5:	c1 ea 09             	shr    $0x9,%edx
80101aa8:	89 f8                	mov    %edi,%eax
80101aaa:	e8 21 f8 ff ff       	call   801012d0 <bmap>
80101aaf:	83 ec 08             	sub    $0x8,%esp
80101ab2:	50                   	push   %eax
80101ab3:	ff 37                	pushl  (%edi)
80101ab5:	e8 06 e6 ff ff       	call   801000c0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101aba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101abd:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ac0:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101ac2:	89 f0                	mov    %esi,%eax
80101ac4:	b9 00 02 00 00       	mov    $0x200,%ecx
80101ac9:	83 c4 0c             	add    $0xc,%esp
80101acc:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ad1:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101ad3:	8d 44 07 18          	lea    0x18(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101ad7:	39 d9                	cmp    %ebx,%ecx
80101ad9:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101adc:	53                   	push   %ebx
80101add:	ff 75 dc             	pushl  -0x24(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ae0:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101ae2:	50                   	push   %eax
80101ae3:	e8 d8 33 00 00       	call   80104ec0 <memmove>
    log_write(bp);
80101ae8:	89 3c 24             	mov    %edi,(%esp)
80101aeb:	e8 20 13 00 00       	call   80102e10 <log_write>
    brelse(bp);
80101af0:	89 3c 24             	mov    %edi,(%esp)
80101af3:	e8 d8 e6 ff ff       	call   801001d0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101af8:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101afb:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101afe:	83 c4 10             	add    $0x10,%esp
80101b01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101b04:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101b07:	77 97                	ja     80101aa0 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101b09:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101b0c:	3b 70 18             	cmp    0x18(%eax),%esi
80101b0f:	77 37                	ja     80101b48 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b17:	5b                   	pop    %ebx
80101b18:	5e                   	pop    %esi
80101b19:	5f                   	pop    %edi
80101b1a:	5d                   	pop    %ebp
80101b1b:	c3                   	ret    
80101b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101b20:	0f bf 40 12          	movswl 0x12(%eax),%eax
80101b24:	66 83 f8 09          	cmp    $0x9,%ax
80101b28:	77 36                	ja     80101b60 <writei+0x120>
80101b2a:	8b 04 c5 44 11 11 80 	mov    -0x7feeeebc(,%eax,8),%eax
80101b31:	85 c0                	test   %eax,%eax
80101b33:	74 2b                	je     80101b60 <writei+0x120>
    return devsw[ip->major].write(ip, src, n);
80101b35:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b3b:	5b                   	pop    %ebx
80101b3c:	5e                   	pop    %esi
80101b3d:	5f                   	pop    %edi
80101b3e:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101b3f:	ff e0                	jmp    *%eax
80101b41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101b48:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101b4b:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101b4e:	89 70 18             	mov    %esi,0x18(%eax)
    iupdate(ip);
80101b51:	50                   	push   %eax
80101b52:	e8 19 fa ff ff       	call   80101570 <iupdate>
80101b57:	83 c4 10             	add    $0x10,%esp
80101b5a:	eb b5                	jmp    80101b11 <writei+0xd1>
80101b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
80101b60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b65:	eb ad                	jmp    80101b14 <writei+0xd4>
80101b67:	89 f6                	mov    %esi,%esi
80101b69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101b70 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101b70:	55                   	push   %ebp
80101b71:	89 e5                	mov    %esp,%ebp
80101b73:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101b76:	6a 0e                	push   $0xe
80101b78:	ff 75 0c             	pushl  0xc(%ebp)
80101b7b:	ff 75 08             	pushl  0x8(%ebp)
80101b7e:	e8 ad 33 00 00       	call   80104f30 <strncmp>
}
80101b83:	c9                   	leave  
80101b84:	c3                   	ret    
80101b85:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101b89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101b90 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101b90:	55                   	push   %ebp
80101b91:	89 e5                	mov    %esp,%ebp
80101b93:	57                   	push   %edi
80101b94:	56                   	push   %esi
80101b95:	53                   	push   %ebx
80101b96:	83 ec 1c             	sub    $0x1c,%esp
80101b99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101b9c:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80101ba1:	0f 85 85 00 00 00    	jne    80101c2c <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101ba7:	8b 53 18             	mov    0x18(%ebx),%edx
80101baa:	31 ff                	xor    %edi,%edi
80101bac:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101baf:	85 d2                	test   %edx,%edx
80101bb1:	74 3e                	je     80101bf1 <dirlookup+0x61>
80101bb3:	90                   	nop
80101bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bb8:	6a 10                	push   $0x10
80101bba:	57                   	push   %edi
80101bbb:	56                   	push   %esi
80101bbc:	53                   	push   %ebx
80101bbd:	e8 7e fd ff ff       	call   80101940 <readi>
80101bc2:	83 c4 10             	add    $0x10,%esp
80101bc5:	83 f8 10             	cmp    $0x10,%eax
80101bc8:	75 55                	jne    80101c1f <dirlookup+0x8f>
      panic("dirlink read");
    if(de.inum == 0)
80101bca:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101bcf:	74 18                	je     80101be9 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101bd1:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bd4:	83 ec 04             	sub    $0x4,%esp
80101bd7:	6a 0e                	push   $0xe
80101bd9:	50                   	push   %eax
80101bda:	ff 75 0c             	pushl  0xc(%ebp)
80101bdd:	e8 4e 33 00 00       	call   80104f30 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101be2:	83 c4 10             	add    $0x10,%esp
80101be5:	85 c0                	test   %eax,%eax
80101be7:	74 17                	je     80101c00 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101be9:	83 c7 10             	add    $0x10,%edi
80101bec:	3b 7b 18             	cmp    0x18(%ebx),%edi
80101bef:	72 c7                	jb     80101bb8 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101bf4:	31 c0                	xor    %eax,%eax
}
80101bf6:	5b                   	pop    %ebx
80101bf7:	5e                   	pop    %esi
80101bf8:	5f                   	pop    %edi
80101bf9:	5d                   	pop    %ebp
80101bfa:	c3                   	ret    
80101bfb:	90                   	nop
80101bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(poff)
80101c00:	8b 45 10             	mov    0x10(%ebp),%eax
80101c03:	85 c0                	test   %eax,%eax
80101c05:	74 05                	je     80101c0c <dirlookup+0x7c>
        *poff = off;
80101c07:	8b 45 10             	mov    0x10(%ebp),%eax
80101c0a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101c0c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101c10:	8b 03                	mov    (%ebx),%eax
80101c12:	e8 e9 f5 ff ff       	call   80101200 <iget>
}
80101c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c1a:	5b                   	pop    %ebx
80101c1b:	5e                   	pop    %esi
80101c1c:	5f                   	pop    %edi
80101c1d:	5d                   	pop    %ebp
80101c1e:	c3                   	ret    
      panic("dirlink read");
80101c1f:	83 ec 0c             	sub    $0xc,%esp
80101c22:	68 75 7c 10 80       	push   $0x80107c75
80101c27:	e8 44 e7 ff ff       	call   80100370 <panic>
    panic("dirlookup not DIR");
80101c2c:	83 ec 0c             	sub    $0xc,%esp
80101c2f:	68 63 7c 10 80       	push   $0x80107c63
80101c34:	e8 37 e7 ff ff       	call   80100370 <panic>
80101c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101c40 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	57                   	push   %edi
80101c44:	56                   	push   %esi
80101c45:	53                   	push   %ebx
80101c46:	89 cf                	mov    %ecx,%edi
80101c48:	89 c3                	mov    %eax,%ebx
80101c4a:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101c4d:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101c50:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(*path == '/')
80101c53:	0f 84 77 01 00 00    	je     80101dd0 <namex+0x190>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80101c59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  acquire(&icache.lock);
80101c5f:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(proc->cwd);
80101c62:	8b b0 ec 00 00 00    	mov    0xec(%eax),%esi
  acquire(&icache.lock);
80101c68:	68 c0 11 11 80       	push   $0x801111c0
80101c6d:	e8 8e 2f 00 00       	call   80104c00 <acquire>
  ip->ref++;
80101c72:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101c76:	c7 04 24 c0 11 11 80 	movl   $0x801111c0,(%esp)
80101c7d:	e8 3e 31 00 00       	call   80104dc0 <release>
80101c82:	83 c4 10             	add    $0x10,%esp
80101c85:	eb 0c                	jmp    80101c93 <namex+0x53>
80101c87:	89 f6                	mov    %esi,%esi
80101c89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    path++;
80101c90:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101c93:	0f b6 03             	movzbl (%ebx),%eax
80101c96:	3c 2f                	cmp    $0x2f,%al
80101c98:	74 f6                	je     80101c90 <namex+0x50>
  if(*path == 0)
80101c9a:	84 c0                	test   %al,%al
80101c9c:	0f 84 f6 00 00 00    	je     80101d98 <namex+0x158>
  while(*path != '/' && *path != 0)
80101ca2:	0f b6 03             	movzbl (%ebx),%eax
80101ca5:	3c 2f                	cmp    $0x2f,%al
80101ca7:	0f 84 bb 00 00 00    	je     80101d68 <namex+0x128>
80101cad:	84 c0                	test   %al,%al
80101caf:	89 da                	mov    %ebx,%edx
80101cb1:	75 11                	jne    80101cc4 <namex+0x84>
80101cb3:	e9 b0 00 00 00       	jmp    80101d68 <namex+0x128>
80101cb8:	90                   	nop
80101cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cc0:	84 c0                	test   %al,%al
80101cc2:	74 0a                	je     80101cce <namex+0x8e>
    path++;
80101cc4:	83 c2 01             	add    $0x1,%edx
  while(*path != '/' && *path != 0)
80101cc7:	0f b6 02             	movzbl (%edx),%eax
80101cca:	3c 2f                	cmp    $0x2f,%al
80101ccc:	75 f2                	jne    80101cc0 <namex+0x80>
80101cce:	89 d1                	mov    %edx,%ecx
80101cd0:	29 d9                	sub    %ebx,%ecx
  if(len >= DIRSIZ)
80101cd2:	83 f9 0d             	cmp    $0xd,%ecx
80101cd5:	0f 8e 91 00 00 00    	jle    80101d6c <namex+0x12c>
    memmove(name, s, DIRSIZ);
80101cdb:	83 ec 04             	sub    $0x4,%esp
80101cde:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101ce1:	6a 0e                	push   $0xe
80101ce3:	53                   	push   %ebx
80101ce4:	57                   	push   %edi
80101ce5:	e8 d6 31 00 00       	call   80104ec0 <memmove>
    path++;
80101cea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    memmove(name, s, DIRSIZ);
80101ced:	83 c4 10             	add    $0x10,%esp
    path++;
80101cf0:	89 d3                	mov    %edx,%ebx
  while(*path == '/')
80101cf2:	80 3a 2f             	cmpb   $0x2f,(%edx)
80101cf5:	75 11                	jne    80101d08 <namex+0xc8>
80101cf7:	89 f6                	mov    %esi,%esi
80101cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    path++;
80101d00:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101d03:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101d06:	74 f8                	je     80101d00 <namex+0xc0>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101d08:	83 ec 0c             	sub    $0xc,%esp
80101d0b:	56                   	push   %esi
80101d0c:	e8 0f f9 ff ff       	call   80101620 <ilock>
    if(ip->type != T_DIR){
80101d11:	83 c4 10             	add    $0x10,%esp
80101d14:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
80101d19:	0f 85 91 00 00 00    	jne    80101db0 <namex+0x170>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101d1f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101d22:	85 d2                	test   %edx,%edx
80101d24:	74 09                	je     80101d2f <namex+0xef>
80101d26:	80 3b 00             	cmpb   $0x0,(%ebx)
80101d29:	0f 84 b7 00 00 00    	je     80101de6 <namex+0x1a6>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101d2f:	83 ec 04             	sub    $0x4,%esp
80101d32:	6a 00                	push   $0x0
80101d34:	57                   	push   %edi
80101d35:	56                   	push   %esi
80101d36:	e8 55 fe ff ff       	call   80101b90 <dirlookup>
80101d3b:	83 c4 10             	add    $0x10,%esp
80101d3e:	85 c0                	test   %eax,%eax
80101d40:	74 6e                	je     80101db0 <namex+0x170>
  iunlock(ip);
80101d42:	83 ec 0c             	sub    $0xc,%esp
80101d45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101d48:	56                   	push   %esi
80101d49:	e8 e2 f9 ff ff       	call   80101730 <iunlock>
  iput(ip);
80101d4e:	89 34 24             	mov    %esi,(%esp)
80101d51:	e8 3a fa ff ff       	call   80101790 <iput>
80101d56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d59:	83 c4 10             	add    $0x10,%esp
80101d5c:	89 c6                	mov    %eax,%esi
80101d5e:	e9 30 ff ff ff       	jmp    80101c93 <namex+0x53>
80101d63:	90                   	nop
80101d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path != '/' && *path != 0)
80101d68:	89 da                	mov    %ebx,%edx
80101d6a:	31 c9                	xor    %ecx,%ecx
    memmove(name, s, len);
80101d6c:	83 ec 04             	sub    $0x4,%esp
80101d6f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101d72:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101d75:	51                   	push   %ecx
80101d76:	53                   	push   %ebx
80101d77:	57                   	push   %edi
80101d78:	e8 43 31 00 00       	call   80104ec0 <memmove>
    name[len] = 0;
80101d7d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101d80:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101d83:	83 c4 10             	add    $0x10,%esp
80101d86:	c6 04 0f 00          	movb   $0x0,(%edi,%ecx,1)
80101d8a:	89 d3                	mov    %edx,%ebx
80101d8c:	e9 61 ff ff ff       	jmp    80101cf2 <namex+0xb2>
80101d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101d9b:	85 c0                	test   %eax,%eax
80101d9d:	75 5d                	jne    80101dfc <namex+0x1bc>
    iput(ip);
    return 0;
  }
  return ip;
}
80101d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101da2:	89 f0                	mov    %esi,%eax
80101da4:	5b                   	pop    %ebx
80101da5:	5e                   	pop    %esi
80101da6:	5f                   	pop    %edi
80101da7:	5d                   	pop    %ebp
80101da8:	c3                   	ret    
80101da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  iunlock(ip);
80101db0:	83 ec 0c             	sub    $0xc,%esp
80101db3:	56                   	push   %esi
80101db4:	e8 77 f9 ff ff       	call   80101730 <iunlock>
  iput(ip);
80101db9:	89 34 24             	mov    %esi,(%esp)
      return 0;
80101dbc:	31 f6                	xor    %esi,%esi
  iput(ip);
80101dbe:	e8 cd f9 ff ff       	call   80101790 <iput>
      return 0;
80101dc3:	83 c4 10             	add    $0x10,%esp
}
80101dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dc9:	89 f0                	mov    %esi,%eax
80101dcb:	5b                   	pop    %ebx
80101dcc:	5e                   	pop    %esi
80101dcd:	5f                   	pop    %edi
80101dce:	5d                   	pop    %ebp
80101dcf:	c3                   	ret    
    ip = iget(ROOTDEV, ROOTINO);
80101dd0:	ba 01 00 00 00       	mov    $0x1,%edx
80101dd5:	b8 01 00 00 00       	mov    $0x1,%eax
80101dda:	e8 21 f4 ff ff       	call   80101200 <iget>
80101ddf:	89 c6                	mov    %eax,%esi
80101de1:	e9 ad fe ff ff       	jmp    80101c93 <namex+0x53>
      iunlock(ip);
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	56                   	push   %esi
80101dea:	e8 41 f9 ff ff       	call   80101730 <iunlock>
      return ip;
80101def:	83 c4 10             	add    $0x10,%esp
}
80101df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101df5:	89 f0                	mov    %esi,%eax
80101df7:	5b                   	pop    %ebx
80101df8:	5e                   	pop    %esi
80101df9:	5f                   	pop    %edi
80101dfa:	5d                   	pop    %ebp
80101dfb:	c3                   	ret    
    iput(ip);
80101dfc:	83 ec 0c             	sub    $0xc,%esp
80101dff:	56                   	push   %esi
    return 0;
80101e00:	31 f6                	xor    %esi,%esi
    iput(ip);
80101e02:	e8 89 f9 ff ff       	call   80101790 <iput>
    return 0;
80101e07:	83 c4 10             	add    $0x10,%esp
80101e0a:	eb 93                	jmp    80101d9f <namex+0x15f>
80101e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101e10 <dirlink>:
{
80101e10:	55                   	push   %ebp
80101e11:	89 e5                	mov    %esp,%ebp
80101e13:	57                   	push   %edi
80101e14:	56                   	push   %esi
80101e15:	53                   	push   %ebx
80101e16:	83 ec 20             	sub    $0x20,%esp
80101e19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101e1c:	6a 00                	push   $0x0
80101e1e:	ff 75 0c             	pushl  0xc(%ebp)
80101e21:	53                   	push   %ebx
80101e22:	e8 69 fd ff ff       	call   80101b90 <dirlookup>
80101e27:	83 c4 10             	add    $0x10,%esp
80101e2a:	85 c0                	test   %eax,%eax
80101e2c:	75 67                	jne    80101e95 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101e2e:	8b 7b 18             	mov    0x18(%ebx),%edi
80101e31:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e34:	85 ff                	test   %edi,%edi
80101e36:	74 29                	je     80101e61 <dirlink+0x51>
80101e38:	31 ff                	xor    %edi,%edi
80101e3a:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e3d:	eb 09                	jmp    80101e48 <dirlink+0x38>
80101e3f:	90                   	nop
80101e40:	83 c7 10             	add    $0x10,%edi
80101e43:	3b 7b 18             	cmp    0x18(%ebx),%edi
80101e46:	73 19                	jae    80101e61 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e48:	6a 10                	push   $0x10
80101e4a:	57                   	push   %edi
80101e4b:	56                   	push   %esi
80101e4c:	53                   	push   %ebx
80101e4d:	e8 ee fa ff ff       	call   80101940 <readi>
80101e52:	83 c4 10             	add    $0x10,%esp
80101e55:	83 f8 10             	cmp    $0x10,%eax
80101e58:	75 4e                	jne    80101ea8 <dirlink+0x98>
    if(de.inum == 0)
80101e5a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101e5f:	75 df                	jne    80101e40 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80101e61:	8d 45 da             	lea    -0x26(%ebp),%eax
80101e64:	83 ec 04             	sub    $0x4,%esp
80101e67:	6a 0e                	push   $0xe
80101e69:	ff 75 0c             	pushl  0xc(%ebp)
80101e6c:	50                   	push   %eax
80101e6d:	e8 1e 31 00 00       	call   80104f90 <strncpy>
  de.inum = inum;
80101e72:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e75:	6a 10                	push   $0x10
80101e77:	57                   	push   %edi
80101e78:	56                   	push   %esi
80101e79:	53                   	push   %ebx
  de.inum = inum;
80101e7a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e7e:	e8 bd fb ff ff       	call   80101a40 <writei>
80101e83:	83 c4 20             	add    $0x20,%esp
80101e86:	83 f8 10             	cmp    $0x10,%eax
80101e89:	75 2a                	jne    80101eb5 <dirlink+0xa5>
  return 0;
80101e8b:	31 c0                	xor    %eax,%eax
}
80101e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e90:	5b                   	pop    %ebx
80101e91:	5e                   	pop    %esi
80101e92:	5f                   	pop    %edi
80101e93:	5d                   	pop    %ebp
80101e94:	c3                   	ret    
    iput(ip);
80101e95:	83 ec 0c             	sub    $0xc,%esp
80101e98:	50                   	push   %eax
80101e99:	e8 f2 f8 ff ff       	call   80101790 <iput>
    return -1;
80101e9e:	83 c4 10             	add    $0x10,%esp
80101ea1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ea6:	eb e5                	jmp    80101e8d <dirlink+0x7d>
      panic("dirlink read");
80101ea8:	83 ec 0c             	sub    $0xc,%esp
80101eab:	68 75 7c 10 80       	push   $0x80107c75
80101eb0:	e8 bb e4 ff ff       	call   80100370 <panic>
    panic("dirlink");
80101eb5:	83 ec 0c             	sub    $0xc,%esp
80101eb8:	68 9a 84 10 80       	push   $0x8010849a
80101ebd:	e8 ae e4 ff ff       	call   80100370 <panic>
80101ec2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101ec9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ed0 <namei>:

struct inode*
namei(char *path)
{
80101ed0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101ed1:	31 d2                	xor    %edx,%edx
{
80101ed3:	89 e5                	mov    %esp,%ebp
80101ed5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
80101ed8:	8b 45 08             	mov    0x8(%ebp),%eax
80101edb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101ede:	e8 5d fd ff ff       	call   80101c40 <namex>
}
80101ee3:	c9                   	leave  
80101ee4:	c3                   	ret    
80101ee5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101ee9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ef0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101ef0:	55                   	push   %ebp
  return namex(path, 1, name);
80101ef1:	ba 01 00 00 00       	mov    $0x1,%edx
{
80101ef6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80101ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101efb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101efe:	5d                   	pop    %ebp
  return namex(path, 1, name);
80101eff:	e9 3c fd ff ff       	jmp    80101c40 <namex>
80101f04:	66 90                	xchg   %ax,%ax
80101f06:	66 90                	xchg   %ax,%ax
80101f08:	66 90                	xchg   %ax,%ax
80101f0a:	66 90                	xchg   %ax,%ax
80101f0c:	66 90                	xchg   %ax,%ax
80101f0e:	66 90                	xchg   %ax,%ax

80101f10 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101f10:	55                   	push   %ebp
80101f11:	89 e5                	mov    %esp,%ebp
80101f13:	57                   	push   %edi
80101f14:	56                   	push   %esi
80101f15:	53                   	push   %ebx
80101f16:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	0f 84 b4 00 00 00    	je     80101fd5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101f21:	8b 58 08             	mov    0x8(%eax),%ebx
80101f24:	89 c6                	mov    %eax,%esi
80101f26:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101f2c:	0f 87 96 00 00 00    	ja     80101fc8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101f32:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80101f37:	89 f6                	mov    %esi,%esi
80101f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80101f40:	89 ca                	mov    %ecx,%edx
80101f42:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101f43:	83 e0 c0             	and    $0xffffffc0,%eax
80101f46:	3c 40                	cmp    $0x40,%al
80101f48:	75 f6                	jne    80101f40 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101f4a:	31 ff                	xor    %edi,%edi
80101f4c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101f51:	89 f8                	mov    %edi,%eax
80101f53:	ee                   	out    %al,(%dx)
80101f54:	b8 01 00 00 00       	mov    $0x1,%eax
80101f59:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101f5e:	ee                   	out    %al,(%dx)
80101f5f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101f64:	89 d8                	mov    %ebx,%eax
80101f66:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101f67:	89 d8                	mov    %ebx,%eax
80101f69:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101f6e:	c1 f8 08             	sar    $0x8,%eax
80101f71:	ee                   	out    %al,(%dx)
80101f72:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101f77:	89 f8                	mov    %edi,%eax
80101f79:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101f7a:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101f7e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101f83:	c1 e0 04             	shl    $0x4,%eax
80101f86:	83 e0 10             	and    $0x10,%eax
80101f89:	83 c8 e0             	or     $0xffffffe0,%eax
80101f8c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101f8d:	f6 06 04             	testb  $0x4,(%esi)
80101f90:	75 16                	jne    80101fa8 <idestart+0x98>
80101f92:	b8 20 00 00 00       	mov    $0x20,%eax
80101f97:	89 ca                	mov    %ecx,%edx
80101f99:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f9d:	5b                   	pop    %ebx
80101f9e:	5e                   	pop    %esi
80101f9f:	5f                   	pop    %edi
80101fa0:	5d                   	pop    %ebp
80101fa1:	c3                   	ret    
80101fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101fa8:	b8 30 00 00 00       	mov    $0x30,%eax
80101fad:	89 ca                	mov    %ecx,%edx
80101faf:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80101fb0:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80101fb5:	83 c6 18             	add    $0x18,%esi
80101fb8:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101fbd:	fc                   	cld    
80101fbe:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
80101fc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fc3:	5b                   	pop    %ebx
80101fc4:	5e                   	pop    %esi
80101fc5:	5f                   	pop    %edi
80101fc6:	5d                   	pop    %ebp
80101fc7:	c3                   	ret    
    panic("incorrect blockno");
80101fc8:	83 ec 0c             	sub    $0xc,%esp
80101fcb:	68 e9 7c 10 80       	push   $0x80107ce9
80101fd0:	e8 9b e3 ff ff       	call   80100370 <panic>
    panic("idestart");
80101fd5:	83 ec 0c             	sub    $0xc,%esp
80101fd8:	68 e0 7c 10 80       	push   $0x80107ce0
80101fdd:	e8 8e e3 ff ff       	call   80100370 <panic>
80101fe2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101fe9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ff0 <ideinit>:
{
80101ff0:	55                   	push   %ebp
80101ff1:	89 e5                	mov    %esp,%ebp
80101ff3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101ff6:	68 fb 7c 10 80       	push   $0x80107cfb
80101ffb:	68 80 b5 10 80       	push   $0x8010b580
80102000:	e8 db 2b 00 00       	call   80104be0 <initlock>
  picenable(IRQ_IDE);
80102005:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010200c:	e8 ff 12 00 00       	call   80103310 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102011:	58                   	pop    %eax
80102012:	a1 c0 28 11 80       	mov    0x801128c0,%eax
80102017:	5a                   	pop    %edx
80102018:	83 e8 01             	sub    $0x1,%eax
8010201b:	50                   	push   %eax
8010201c:	6a 0e                	push   $0xe
8010201e:	e8 bd 02 00 00       	call   801022e0 <ioapicenable>
80102023:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102026:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010202b:	90                   	nop
8010202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102030:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102031:	83 e0 c0             	and    $0xffffffc0,%eax
80102034:	3c 40                	cmp    $0x40,%al
80102036:	75 f8                	jne    80102030 <ideinit+0x40>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102038:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010203d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102042:	ee                   	out    %al,(%dx)
80102043:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102048:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010204d:	eb 06                	jmp    80102055 <ideinit+0x65>
8010204f:	90                   	nop
  for(i=0; i<1000; i++){
80102050:	83 e9 01             	sub    $0x1,%ecx
80102053:	74 0f                	je     80102064 <ideinit+0x74>
80102055:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102056:	84 c0                	test   %al,%al
80102058:	74 f6                	je     80102050 <ideinit+0x60>
      havedisk1 = 1;
8010205a:	c7 05 60 b5 10 80 01 	movl   $0x1,0x8010b560
80102061:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102064:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102069:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010206e:	ee                   	out    %al,(%dx)
}
8010206f:	c9                   	leave  
80102070:	c3                   	ret    
80102071:	eb 0d                	jmp    80102080 <ideintr>
80102073:	90                   	nop
80102074:	90                   	nop
80102075:	90                   	nop
80102076:	90                   	nop
80102077:	90                   	nop
80102078:	90                   	nop
80102079:	90                   	nop
8010207a:	90                   	nop
8010207b:	90                   	nop
8010207c:	90                   	nop
8010207d:	90                   	nop
8010207e:	90                   	nop
8010207f:	90                   	nop

80102080 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102080:	55                   	push   %ebp
80102081:	89 e5                	mov    %esp,%ebp
80102083:	57                   	push   %edi
80102084:	56                   	push   %esi
80102085:	53                   	push   %ebx
80102086:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102089:	68 80 b5 10 80       	push   $0x8010b580
8010208e:	e8 6d 2b 00 00       	call   80104c00 <acquire>
  if((b = idequeue) == 0){
80102093:	8b 1d 64 b5 10 80    	mov    0x8010b564,%ebx
80102099:	83 c4 10             	add    $0x10,%esp
8010209c:	85 db                	test   %ebx,%ebx
8010209e:	74 67                	je     80102107 <ideintr+0x87>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
801020a0:	8b 43 14             	mov    0x14(%ebx),%eax
801020a3:	a3 64 b5 10 80       	mov    %eax,0x8010b564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801020a8:	8b 3b                	mov    (%ebx),%edi
801020aa:	f7 c7 04 00 00 00    	test   $0x4,%edi
801020b0:	75 31                	jne    801020e3 <ideintr+0x63>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801020b2:	ba f7 01 00 00       	mov    $0x1f7,%edx
801020b7:	89 f6                	mov    %esi,%esi
801020b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801020c0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801020c1:	89 c6                	mov    %eax,%esi
801020c3:	83 e6 c0             	and    $0xffffffc0,%esi
801020c6:	89 f1                	mov    %esi,%ecx
801020c8:	80 f9 40             	cmp    $0x40,%cl
801020cb:	75 f3                	jne    801020c0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801020cd:	a8 21                	test   $0x21,%al
801020cf:	75 12                	jne    801020e3 <ideintr+0x63>
    insl(0x1f0, b->data, BSIZE/4);
801020d1:	8d 7b 18             	lea    0x18(%ebx),%edi
  asm volatile("cld; rep insl" :
801020d4:	b9 80 00 00 00       	mov    $0x80,%ecx
801020d9:	ba f0 01 00 00       	mov    $0x1f0,%edx
801020de:	fc                   	cld    
801020df:	f3 6d                	rep insl (%dx),%es:(%edi)
801020e1:	8b 3b                	mov    (%ebx),%edi

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
801020e3:	83 e7 fb             	and    $0xfffffffb,%edi
  wakeup(b);
801020e6:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801020e9:	89 f9                	mov    %edi,%ecx
801020eb:	83 c9 02             	or     $0x2,%ecx
801020ee:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
801020f0:	53                   	push   %ebx
801020f1:	e8 1a 22 00 00       	call   80104310 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801020f6:	a1 64 b5 10 80       	mov    0x8010b564,%eax
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	85 c0                	test   %eax,%eax
80102100:	74 05                	je     80102107 <ideintr+0x87>
    idestart(idequeue);
80102102:	e8 09 fe ff ff       	call   80101f10 <idestart>
    release(&idelock);
80102107:	83 ec 0c             	sub    $0xc,%esp
8010210a:	68 80 b5 10 80       	push   $0x8010b580
8010210f:	e8 ac 2c 00 00       	call   80104dc0 <release>

  release(&idelock);
}
80102114:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102117:	5b                   	pop    %ebx
80102118:	5e                   	pop    %esi
80102119:	5f                   	pop    %edi
8010211a:	5d                   	pop    %ebp
8010211b:	c3                   	ret    
8010211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102120 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102120:	55                   	push   %ebp
80102121:	89 e5                	mov    %esp,%ebp
80102123:	53                   	push   %ebx
80102124:	83 ec 04             	sub    $0x4,%esp
80102127:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010212a:	8b 03                	mov    (%ebx),%eax
8010212c:	a8 01                	test   $0x1,%al
8010212e:	0f 84 c0 00 00 00    	je     801021f4 <iderw+0xd4>
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102134:	83 e0 06             	and    $0x6,%eax
80102137:	83 f8 02             	cmp    $0x2,%eax
8010213a:	0f 84 a7 00 00 00    	je     801021e7 <iderw+0xc7>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80102140:	8b 53 04             	mov    0x4(%ebx),%edx
80102143:	85 d2                	test   %edx,%edx
80102145:	74 0d                	je     80102154 <iderw+0x34>
80102147:	a1 60 b5 10 80       	mov    0x8010b560,%eax
8010214c:	85 c0                	test   %eax,%eax
8010214e:	0f 84 ad 00 00 00    	je     80102201 <iderw+0xe1>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102154:	83 ec 0c             	sub    $0xc,%esp
80102157:	68 80 b5 10 80       	push   $0x8010b580
8010215c:	e8 9f 2a 00 00       	call   80104c00 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102161:	8b 15 64 b5 10 80    	mov    0x8010b564,%edx
80102167:	83 c4 10             	add    $0x10,%esp
  b->qnext = 0;
8010216a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102171:	85 d2                	test   %edx,%edx
80102173:	75 0d                	jne    80102182 <iderw+0x62>
80102175:	eb 69                	jmp    801021e0 <iderw+0xc0>
80102177:	89 f6                	mov    %esi,%esi
80102179:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80102180:	89 c2                	mov    %eax,%edx
80102182:	8b 42 14             	mov    0x14(%edx),%eax
80102185:	85 c0                	test   %eax,%eax
80102187:	75 f7                	jne    80102180 <iderw+0x60>
80102189:	83 c2 14             	add    $0x14,%edx
    ;
  *pp = b;
8010218c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010218e:	39 1d 64 b5 10 80    	cmp    %ebx,0x8010b564
80102194:	74 3a                	je     801021d0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102196:	8b 03                	mov    (%ebx),%eax
80102198:	83 e0 06             	and    $0x6,%eax
8010219b:	83 f8 02             	cmp    $0x2,%eax
8010219e:	74 1b                	je     801021bb <iderw+0x9b>
    sleep(b, &idelock);
801021a0:	83 ec 08             	sub    $0x8,%esp
801021a3:	68 80 b5 10 80       	push   $0x8010b580
801021a8:	53                   	push   %ebx
801021a9:	e8 72 1f 00 00       	call   80104120 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801021ae:	8b 03                	mov    (%ebx),%eax
801021b0:	83 c4 10             	add    $0x10,%esp
801021b3:	83 e0 06             	and    $0x6,%eax
801021b6:	83 f8 02             	cmp    $0x2,%eax
801021b9:	75 e5                	jne    801021a0 <iderw+0x80>
  }

  release(&idelock);
801021bb:	c7 45 08 80 b5 10 80 	movl   $0x8010b580,0x8(%ebp)
}
801021c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801021c5:	c9                   	leave  
  release(&idelock);
801021c6:	e9 f5 2b 00 00       	jmp    80104dc0 <release>
801021cb:	90                   	nop
801021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    idestart(b);
801021d0:	89 d8                	mov    %ebx,%eax
801021d2:	e8 39 fd ff ff       	call   80101f10 <idestart>
801021d7:	eb bd                	jmp    80102196 <iderw+0x76>
801021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801021e0:	ba 64 b5 10 80       	mov    $0x8010b564,%edx
801021e5:	eb a5                	jmp    8010218c <iderw+0x6c>
    panic("iderw: nothing to do");
801021e7:	83 ec 0c             	sub    $0xc,%esp
801021ea:	68 13 7d 10 80       	push   $0x80107d13
801021ef:	e8 7c e1 ff ff       	call   80100370 <panic>
    panic("iderw: buf not busy");
801021f4:	83 ec 0c             	sub    $0xc,%esp
801021f7:	68 ff 7c 10 80       	push   $0x80107cff
801021fc:	e8 6f e1 ff ff       	call   80100370 <panic>
    panic("iderw: ide disk 1 not present");
80102201:	83 ec 0c             	sub    $0xc,%esp
80102204:	68 28 7d 10 80       	push   $0x80107d28
80102209:	e8 62 e1 ff ff       	call   80100370 <panic>
8010220e:	66 90                	xchg   %ax,%ax

80102210 <ioapicinit>:
void
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
80102210:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80102215:	85 c0                	test   %eax,%eax
80102217:	0f 84 b3 00 00 00    	je     801022d0 <ioapicinit+0xc0>
{
8010221d:	55                   	push   %ebp
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010221e:	c7 05 94 21 11 80 00 	movl   $0xfec00000,0x80112194
80102225:	00 c0 fe 
{
80102228:	89 e5                	mov    %esp,%ebp
8010222a:	56                   	push   %esi
8010222b:	53                   	push   %ebx
  ioapic->reg = reg;
8010222c:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102233:	00 00 00 
  return ioapic->data;
80102236:	a1 94 21 11 80       	mov    0x80112194,%eax
8010223b:	8b 58 10             	mov    0x10(%eax),%ebx
  ioapic->reg = reg;
8010223e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return ioapic->data;
80102244:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010224a:	0f b6 15 c0 22 11 80 	movzbl 0x801122c0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102251:	c1 eb 10             	shr    $0x10,%ebx
  return ioapic->data;
80102254:	8b 41 10             	mov    0x10(%ecx),%eax
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102257:	0f b6 db             	movzbl %bl,%ebx
  id = ioapicread(REG_ID) >> 24;
8010225a:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
8010225d:	39 c2                	cmp    %eax,%edx
8010225f:	75 4f                	jne    801022b0 <ioapicinit+0xa0>
80102261:	83 c3 21             	add    $0x21,%ebx
{
80102264:	ba 10 00 00 00       	mov    $0x10,%edx
80102269:	b8 20 00 00 00       	mov    $0x20,%eax
8010226e:	66 90                	xchg   %ax,%ax
  ioapic->reg = reg;
80102270:	89 11                	mov    %edx,(%ecx)
  ioapic->data = data;
80102272:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102278:	89 c6                	mov    %eax,%esi
8010227a:	81 ce 00 00 01 00    	or     $0x10000,%esi
80102280:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
80102283:	89 71 10             	mov    %esi,0x10(%ecx)
80102286:	8d 72 01             	lea    0x1(%edx),%esi
80102289:	83 c2 02             	add    $0x2,%edx
  for(i = 0; i <= maxintr; i++){
8010228c:	39 d8                	cmp    %ebx,%eax
  ioapic->reg = reg;
8010228e:	89 31                	mov    %esi,(%ecx)
  ioapic->data = data;
80102290:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
80102296:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010229d:	75 d1                	jne    80102270 <ioapicinit+0x60>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010229f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801022a2:	5b                   	pop    %ebx
801022a3:	5e                   	pop    %esi
801022a4:	5d                   	pop    %ebp
801022a5:	c3                   	ret    
801022a6:	8d 76 00             	lea    0x0(%esi),%esi
801022a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801022b0:	83 ec 0c             	sub    $0xc,%esp
801022b3:	68 48 7d 10 80       	push   $0x80107d48
801022b8:	e8 83 e3 ff ff       	call   80100640 <cprintf>
801022bd:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
801022c3:	83 c4 10             	add    $0x10,%esp
801022c6:	eb 99                	jmp    80102261 <ioapicinit+0x51>
801022c8:	90                   	nop
801022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022d0:	f3 c3                	repz ret 
801022d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801022e0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
801022e0:	8b 15 c4 22 11 80    	mov    0x801122c4,%edx
{
801022e6:	55                   	push   %ebp
801022e7:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801022e9:	85 d2                	test   %edx,%edx
{
801022eb:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
801022ee:	74 2b                	je     8010231b <ioapicenable+0x3b>
  ioapic->reg = reg;
801022f0:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801022f6:	8d 50 20             	lea    0x20(%eax),%edx
801022f9:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801022fd:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801022ff:	8b 0d 94 21 11 80    	mov    0x80112194,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102305:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
80102308:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010230b:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
8010230e:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102310:	a1 94 21 11 80       	mov    0x80112194,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102315:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
80102318:	89 50 10             	mov    %edx,0x10(%eax)
}
8010231b:	5d                   	pop    %ebp
8010231c:	c3                   	ret    
8010231d:	66 90                	xchg   %ax,%ax
8010231f:	90                   	nop

80102320 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102320:	55                   	push   %ebp
80102321:	89 e5                	mov    %esp,%ebp
80102323:	53                   	push   %ebx
80102324:	83 ec 04             	sub    $0x4,%esp
80102327:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010232a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102330:	75 70                	jne    801023a2 <kfree+0x82>
80102332:	81 fb 68 b4 11 80    	cmp    $0x8011b468,%ebx
80102338:	72 68                	jb     801023a2 <kfree+0x82>
8010233a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102340:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102345:	77 5b                	ja     801023a2 <kfree+0x82>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102347:	83 ec 04             	sub    $0x4,%esp
8010234a:	68 00 10 00 00       	push   $0x1000
8010234f:	6a 01                	push   $0x1
80102351:	53                   	push   %ebx
80102352:	e8 b9 2a 00 00       	call   80104e10 <memset>

  if(kmem.use_lock)
80102357:	8b 15 d4 21 11 80    	mov    0x801121d4,%edx
8010235d:	83 c4 10             	add    $0x10,%esp
80102360:	85 d2                	test   %edx,%edx
80102362:	75 2c                	jne    80102390 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102364:	a1 d8 21 11 80       	mov    0x801121d8,%eax
80102369:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010236b:	a1 d4 21 11 80       	mov    0x801121d4,%eax
  kmem.freelist = r;
80102370:	89 1d d8 21 11 80    	mov    %ebx,0x801121d8
  if(kmem.use_lock)
80102376:	85 c0                	test   %eax,%eax
80102378:	75 06                	jne    80102380 <kfree+0x60>
    release(&kmem.lock);
}
8010237a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010237d:	c9                   	leave  
8010237e:	c3                   	ret    
8010237f:	90                   	nop
    release(&kmem.lock);
80102380:	c7 45 08 a0 21 11 80 	movl   $0x801121a0,0x8(%ebp)
}
80102387:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010238a:	c9                   	leave  
    release(&kmem.lock);
8010238b:	e9 30 2a 00 00       	jmp    80104dc0 <release>
    acquire(&kmem.lock);
80102390:	83 ec 0c             	sub    $0xc,%esp
80102393:	68 a0 21 11 80       	push   $0x801121a0
80102398:	e8 63 28 00 00       	call   80104c00 <acquire>
8010239d:	83 c4 10             	add    $0x10,%esp
801023a0:	eb c2                	jmp    80102364 <kfree+0x44>
    panic("kfree");
801023a2:	83 ec 0c             	sub    $0xc,%esp
801023a5:	68 7a 7d 10 80       	push   $0x80107d7a
801023aa:	e8 c1 df ff ff       	call   80100370 <panic>
801023af:	90                   	nop

801023b0 <freerange>:
{
801023b0:	55                   	push   %ebp
801023b1:	89 e5                	mov    %esp,%ebp
801023b3:	56                   	push   %esi
801023b4:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801023b5:	8b 45 08             	mov    0x8(%ebp),%eax
{
801023b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
801023bb:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801023c1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801023cd:	39 de                	cmp    %ebx,%esi
801023cf:	72 23                	jb     801023f4 <freerange+0x44>
801023d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801023d8:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
801023de:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023e1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801023e7:	50                   	push   %eax
801023e8:	e8 33 ff ff ff       	call   80102320 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801023ed:	83 c4 10             	add    $0x10,%esp
801023f0:	39 f3                	cmp    %esi,%ebx
801023f2:	76 e4                	jbe    801023d8 <freerange+0x28>
}
801023f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801023f7:	5b                   	pop    %ebx
801023f8:	5e                   	pop    %esi
801023f9:	5d                   	pop    %ebp
801023fa:	c3                   	ret    
801023fb:	90                   	nop
801023fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102400 <kinit1>:
{
80102400:	55                   	push   %ebp
80102401:	89 e5                	mov    %esp,%ebp
80102403:	56                   	push   %esi
80102404:	53                   	push   %ebx
80102405:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102408:	83 ec 08             	sub    $0x8,%esp
8010240b:	68 80 7d 10 80       	push   $0x80107d80
80102410:	68 a0 21 11 80       	push   $0x801121a0
80102415:	e8 c6 27 00 00       	call   80104be0 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010241a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010241d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102420:	c7 05 d4 21 11 80 00 	movl   $0x0,0x801121d4
80102427:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010242a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102430:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102436:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010243c:	39 de                	cmp    %ebx,%esi
8010243e:	72 1c                	jb     8010245c <kinit1+0x5c>
    kfree(p);
80102440:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
80102446:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102449:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010244f:	50                   	push   %eax
80102450:	e8 cb fe ff ff       	call   80102320 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102455:	83 c4 10             	add    $0x10,%esp
80102458:	39 de                	cmp    %ebx,%esi
8010245a:	73 e4                	jae    80102440 <kinit1+0x40>
}
8010245c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010245f:	5b                   	pop    %ebx
80102460:	5e                   	pop    %esi
80102461:	5d                   	pop    %ebp
80102462:	c3                   	ret    
80102463:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102469:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102470 <kinit2>:
{
80102470:	55                   	push   %ebp
80102471:	89 e5                	mov    %esp,%ebp
80102473:	56                   	push   %esi
80102474:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102475:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102478:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010247b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102481:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102487:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010248d:	39 de                	cmp    %ebx,%esi
8010248f:	72 23                	jb     801024b4 <kinit2+0x44>
80102491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102498:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
8010249e:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801024a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801024a7:	50                   	push   %eax
801024a8:	e8 73 fe ff ff       	call   80102320 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801024ad:	83 c4 10             	add    $0x10,%esp
801024b0:	39 de                	cmp    %ebx,%esi
801024b2:	73 e4                	jae    80102498 <kinit2+0x28>
  kmem.use_lock = 1;
801024b4:	c7 05 d4 21 11 80 01 	movl   $0x1,0x801121d4
801024bb:	00 00 00 
}
801024be:	8d 65 f8             	lea    -0x8(%ebp),%esp
801024c1:	5b                   	pop    %ebx
801024c2:	5e                   	pop    %esi
801024c3:	5d                   	pop    %ebp
801024c4:	c3                   	ret    
801024c5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801024c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801024d0 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
801024d0:	a1 d4 21 11 80       	mov    0x801121d4,%eax
801024d5:	85 c0                	test   %eax,%eax
801024d7:	75 1f                	jne    801024f8 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
801024d9:	a1 d8 21 11 80       	mov    0x801121d8,%eax
  if(r)
801024de:	85 c0                	test   %eax,%eax
801024e0:	74 0e                	je     801024f0 <kalloc+0x20>
    kmem.freelist = r->next;
801024e2:	8b 10                	mov    (%eax),%edx
801024e4:	89 15 d8 21 11 80    	mov    %edx,0x801121d8
801024ea:	c3                   	ret    
801024eb:	90                   	nop
801024ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}
801024f0:	f3 c3                	repz ret 
801024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
801024f8:	55                   	push   %ebp
801024f9:	89 e5                	mov    %esp,%ebp
801024fb:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
801024fe:	68 a0 21 11 80       	push   $0x801121a0
80102503:	e8 f8 26 00 00       	call   80104c00 <acquire>
  r = kmem.freelist;
80102508:	a1 d8 21 11 80       	mov    0x801121d8,%eax
  if(r)
8010250d:	83 c4 10             	add    $0x10,%esp
80102510:	8b 15 d4 21 11 80    	mov    0x801121d4,%edx
80102516:	85 c0                	test   %eax,%eax
80102518:	74 08                	je     80102522 <kalloc+0x52>
    kmem.freelist = r->next;
8010251a:	8b 08                	mov    (%eax),%ecx
8010251c:	89 0d d8 21 11 80    	mov    %ecx,0x801121d8
  if(kmem.use_lock)
80102522:	85 d2                	test   %edx,%edx
80102524:	74 16                	je     8010253c <kalloc+0x6c>
    release(&kmem.lock);
80102526:	83 ec 0c             	sub    $0xc,%esp
80102529:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010252c:	68 a0 21 11 80       	push   $0x801121a0
80102531:	e8 8a 28 00 00       	call   80104dc0 <release>
  return (char*)r;
80102536:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
80102539:	83 c4 10             	add    $0x10,%esp
}
8010253c:	c9                   	leave  
8010253d:	c3                   	ret    
8010253e:	66 90                	xchg   %ax,%ax

80102540 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102540:	ba 64 00 00 00       	mov    $0x64,%edx
80102545:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102546:	a8 01                	test   $0x1,%al
80102548:	0f 84 c2 00 00 00    	je     80102610 <kbdgetc+0xd0>
8010254e:	ba 60 00 00 00       	mov    $0x60,%edx
80102553:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102554:	0f b6 d0             	movzbl %al,%edx
80102557:	8b 0d b4 b5 10 80    	mov    0x8010b5b4,%ecx

  if(data == 0xE0){
8010255d:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102563:	0f 84 7f 00 00 00    	je     801025e8 <kbdgetc+0xa8>
{
80102569:	55                   	push   %ebp
8010256a:	89 e5                	mov    %esp,%ebp
8010256c:	53                   	push   %ebx
8010256d:	89 cb                	mov    %ecx,%ebx
8010256f:	83 e3 40             	and    $0x40,%ebx
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102572:	84 c0                	test   %al,%al
80102574:	78 4a                	js     801025c0 <kbdgetc+0x80>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102576:	85 db                	test   %ebx,%ebx
80102578:	74 09                	je     80102583 <kbdgetc+0x43>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010257a:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
8010257d:	83 e1 bf             	and    $0xffffffbf,%ecx
    data |= 0x80;
80102580:	0f b6 d0             	movzbl %al,%edx
  }

  shift |= shiftcode[data];
80102583:	0f b6 82 c0 7e 10 80 	movzbl -0x7fef8140(%edx),%eax
8010258a:	09 c1                	or     %eax,%ecx
  shift ^= togglecode[data];
8010258c:	0f b6 82 c0 7d 10 80 	movzbl -0x7fef8240(%edx),%eax
80102593:	31 c1                	xor    %eax,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
80102595:	89 c8                	mov    %ecx,%eax
  shift ^= togglecode[data];
80102597:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010259d:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
801025a0:	83 e1 08             	and    $0x8,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
801025a3:	8b 04 85 a0 7d 10 80 	mov    -0x7fef8260(,%eax,4),%eax
801025aa:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801025ae:	74 31                	je     801025e1 <kbdgetc+0xa1>
    if('a' <= c && c <= 'z')
801025b0:	8d 50 9f             	lea    -0x61(%eax),%edx
801025b3:	83 fa 19             	cmp    $0x19,%edx
801025b6:	77 40                	ja     801025f8 <kbdgetc+0xb8>
      c += 'A' - 'a';
801025b8:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801025bb:	5b                   	pop    %ebx
801025bc:	5d                   	pop    %ebp
801025bd:	c3                   	ret    
801025be:	66 90                	xchg   %ax,%ax
    data = (shift & E0ESC ? data : data & 0x7F);
801025c0:	83 e0 7f             	and    $0x7f,%eax
801025c3:	85 db                	test   %ebx,%ebx
801025c5:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801025c8:	0f b6 82 c0 7e 10 80 	movzbl -0x7fef8140(%edx),%eax
801025cf:	83 c8 40             	or     $0x40,%eax
801025d2:	0f b6 c0             	movzbl %al,%eax
801025d5:	f7 d0                	not    %eax
801025d7:	21 c1                	and    %eax,%ecx
    return 0;
801025d9:	31 c0                	xor    %eax,%eax
    shift &= ~(shiftcode[data] | E0ESC);
801025db:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
}
801025e1:	5b                   	pop    %ebx
801025e2:	5d                   	pop    %ebp
801025e3:	c3                   	ret    
801025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    shift |= E0ESC;
801025e8:	83 c9 40             	or     $0x40,%ecx
    return 0;
801025eb:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
801025ed:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
    return 0;
801025f3:	c3                   	ret    
801025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else if('A' <= c && c <= 'Z')
801025f8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
801025fb:	8d 50 20             	lea    0x20(%eax),%edx
}
801025fe:	5b                   	pop    %ebx
      c += 'a' - 'A';
801025ff:	83 f9 1a             	cmp    $0x1a,%ecx
80102602:	0f 42 c2             	cmovb  %edx,%eax
}
80102605:	5d                   	pop    %ebp
80102606:	c3                   	ret    
80102607:	89 f6                	mov    %esi,%esi
80102609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80102610:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102615:	c3                   	ret    
80102616:	8d 76 00             	lea    0x0(%esi),%esi
80102619:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102620 <kbdintr>:

void
kbdintr(void)
{
80102620:	55                   	push   %ebp
80102621:	89 e5                	mov    %esp,%ebp
80102623:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102626:	68 40 25 10 80       	push   $0x80102540
8010262b:	e8 c0 e1 ff ff       	call   801007f0 <consoleintr>
}
80102630:	83 c4 10             	add    $0x10,%esp
80102633:	c9                   	leave  
80102634:	c3                   	ret    
80102635:	66 90                	xchg   %ax,%ax
80102637:	66 90                	xchg   %ax,%ax
80102639:	66 90                	xchg   %ax,%ax
8010263b:	66 90                	xchg   %ax,%ax
8010263d:	66 90                	xchg   %ax,%ax
8010263f:	90                   	nop

80102640 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
  if(!lapic)
80102640:	a1 dc 21 11 80       	mov    0x801121dc,%eax
{
80102645:	55                   	push   %ebp
80102646:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102648:	85 c0                	test   %eax,%eax
8010264a:	0f 84 c8 00 00 00    	je     80102718 <lapicinit+0xd8>
  lapic[index] = value;
80102650:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102657:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010265a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010265d:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102664:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102667:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010266a:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102671:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102674:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102677:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010267e:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102681:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102684:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
8010268b:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010268e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102691:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102698:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010269b:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010269e:	8b 50 30             	mov    0x30(%eax),%edx
801026a1:	c1 ea 10             	shr    $0x10,%edx
801026a4:	80 fa 03             	cmp    $0x3,%dl
801026a7:	77 77                	ja     80102720 <lapicinit+0xe0>
  lapic[index] = value;
801026a9:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
801026b0:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026b3:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026b6:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801026bd:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026c0:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026c3:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801026ca:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026cd:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026d0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801026d7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026da:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026dd:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
801026e4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026e7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801026ea:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801026f1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801026f4:	8b 50 20             	mov    0x20(%eax),%edx
801026f7:	89 f6                	mov    %esi,%esi
801026f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102700:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102706:	80 e6 10             	and    $0x10,%dh
80102709:	75 f5                	jne    80102700 <lapicinit+0xc0>
  lapic[index] = value;
8010270b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102712:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102715:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102718:	5d                   	pop    %ebp
80102719:	c3                   	ret    
8010271a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  lapic[index] = value;
80102720:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102727:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010272a:	8b 50 20             	mov    0x20(%eax),%edx
8010272d:	e9 77 ff ff ff       	jmp    801026a9 <lapicinit+0x69>
80102732:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102739:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102740 <cpunum>:

int
  cpunum(void)
{
80102740:	55                   	push   %ebp
80102741:	89 e5                	mov    %esp,%ebp
80102743:	56                   	push   %esi
80102744:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102745:	9c                   	pushf  
80102746:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102747:	f6 c4 02             	test   $0x2,%ah
8010274a:	74 12                	je     8010275e <cpunum+0x1e>
    static int n;
    if(n++ == 0)
8010274c:	a1 b8 b5 10 80       	mov    0x8010b5b8,%eax
80102751:	8d 50 01             	lea    0x1(%eax),%edx
80102754:	85 c0                	test   %eax,%eax
80102756:	89 15 b8 b5 10 80    	mov    %edx,0x8010b5b8
8010275c:	74 62                	je     801027c0 <cpunum+0x80>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if (!lapic)
8010275e:	a1 dc 21 11 80       	mov    0x801121dc,%eax
80102763:	85 c0                	test   %eax,%eax
80102765:	74 49                	je     801027b0 <cpunum+0x70>
    return 0;

  apicid = lapic[ID] >> 24;
80102767:	8b 58 20             	mov    0x20(%eax),%ebx
  for (i = 0; i < ncpu; ++i) {
8010276a:	8b 35 c0 28 11 80    	mov    0x801128c0,%esi
  apicid = lapic[ID] >> 24;
80102770:	c1 eb 18             	shr    $0x18,%ebx
  for (i = 0; i < ncpu; ++i) {
80102773:	85 f6                	test   %esi,%esi
80102775:	7e 5e                	jle    801027d5 <cpunum+0x95>
    if (cpus[i].apicid == apicid)
80102777:	0f b6 05 e0 22 11 80 	movzbl 0x801122e0,%eax
8010277e:	39 c3                	cmp    %eax,%ebx
80102780:	74 2e                	je     801027b0 <cpunum+0x70>
80102782:	ba 9c 23 11 80       	mov    $0x8011239c,%edx
  for (i = 0; i < ncpu; ++i) {
80102787:	31 c0                	xor    %eax,%eax
80102789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102790:	83 c0 01             	add    $0x1,%eax
80102793:	39 f0                	cmp    %esi,%eax
80102795:	74 3e                	je     801027d5 <cpunum+0x95>
    if (cpus[i].apicid == apicid)
80102797:	0f b6 0a             	movzbl (%edx),%ecx
8010279a:	81 c2 bc 00 00 00    	add    $0xbc,%edx
801027a0:	39 d9                	cmp    %ebx,%ecx
801027a2:	75 ec                	jne    80102790 <cpunum+0x50>
      return i;
  }
  panic("unknown apicid\n");
}
801027a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801027a7:	5b                   	pop    %ebx
801027a8:	5e                   	pop    %esi
801027a9:	5d                   	pop    %ebp
801027aa:	c3                   	ret    
801027ab:	90                   	nop
801027ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801027b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
801027b3:	31 c0                	xor    %eax,%eax
}
801027b5:	5b                   	pop    %ebx
801027b6:	5e                   	pop    %esi
801027b7:	5d                   	pop    %ebp
801027b8:	c3                   	ret    
801027b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      cprintf("cpu called from %x with interrupts enabled\n",
801027c0:	83 ec 08             	sub    $0x8,%esp
801027c3:	ff 75 04             	pushl  0x4(%ebp)
801027c6:	68 c0 7f 10 80       	push   $0x80107fc0
801027cb:	e8 70 de ff ff       	call   80100640 <cprintf>
801027d0:	83 c4 10             	add    $0x10,%esp
801027d3:	eb 89                	jmp    8010275e <cpunum+0x1e>
  panic("unknown apicid\n");
801027d5:	83 ec 0c             	sub    $0xc,%esp
801027d8:	68 ec 7f 10 80       	push   $0x80107fec
801027dd:	e8 8e db ff ff       	call   80100370 <panic>
801027e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801027f0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
801027f0:	a1 dc 21 11 80       	mov    0x801121dc,%eax
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
  if(lapic)
801027f8:	85 c0                	test   %eax,%eax
801027fa:	74 0d                	je     80102809 <lapiceoi+0x19>
  lapic[index] = value;
801027fc:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102803:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102806:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102809:	5d                   	pop    %ebp
8010280a:	c3                   	ret    
8010280b:	90                   	nop
8010280c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102810 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102810:	55                   	push   %ebp
80102811:	89 e5                	mov    %esp,%ebp
}
80102813:	5d                   	pop    %ebp
80102814:	c3                   	ret    
80102815:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102819:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102820 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102820:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102821:	b8 0f 00 00 00       	mov    $0xf,%eax
80102826:	ba 70 00 00 00       	mov    $0x70,%edx
8010282b:	89 e5                	mov    %esp,%ebp
8010282d:	53                   	push   %ebx
8010282e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102831:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102834:	ee                   	out    %al,(%dx)
80102835:	b8 0a 00 00 00       	mov    $0xa,%eax
8010283a:	ba 71 00 00 00       	mov    $0x71,%edx
8010283f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102840:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102842:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102845:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
8010284b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
8010284d:	c1 e9 0c             	shr    $0xc,%ecx
  wrv[1] = addr >> 4;
80102850:	c1 e8 04             	shr    $0x4,%eax
  lapicw(ICRHI, apicid<<24);
80102853:	89 da                	mov    %ebx,%edx
    lapicw(ICRLO, STARTUP | (addr>>12));
80102855:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102858:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
8010285e:	a1 dc 21 11 80       	mov    0x801121dc,%eax
80102863:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102869:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010286c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102873:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102876:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102879:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102880:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102883:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102886:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010288c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010288f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102895:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102898:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010289e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801028a1:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801028a7:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
801028aa:	5b                   	pop    %ebx
801028ab:	5d                   	pop    %ebp
801028ac:	c3                   	ret    
801028ad:	8d 76 00             	lea    0x0(%esi),%esi

801028b0 <cmostime>:
  r->year   = cmos_read(YEAR);
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801028b0:	55                   	push   %ebp
801028b1:	b8 0b 00 00 00       	mov    $0xb,%eax
801028b6:	ba 70 00 00 00       	mov    $0x70,%edx
801028bb:	89 e5                	mov    %esp,%ebp
801028bd:	57                   	push   %edi
801028be:	56                   	push   %esi
801028bf:	53                   	push   %ebx
801028c0:	83 ec 4c             	sub    $0x4c,%esp
801028c3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028c4:	ba 71 00 00 00       	mov    $0x71,%edx
801028c9:	ec                   	in     (%dx),%al
801028ca:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028cd:	bb 70 00 00 00       	mov    $0x70,%ebx
801028d2:	88 45 b3             	mov    %al,-0x4d(%ebp)
801028d5:	8d 76 00             	lea    0x0(%esi),%esi
801028d8:	31 c0                	xor    %eax,%eax
801028da:	89 da                	mov    %ebx,%edx
801028dc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028dd:	b9 71 00 00 00       	mov    $0x71,%ecx
801028e2:	89 ca                	mov    %ecx,%edx
801028e4:	ec                   	in     (%dx),%al
801028e5:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028e8:	89 da                	mov    %ebx,%edx
801028ea:	b8 02 00 00 00       	mov    $0x2,%eax
801028ef:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028f0:	89 ca                	mov    %ecx,%edx
801028f2:	ec                   	in     (%dx),%al
801028f3:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028f6:	89 da                	mov    %ebx,%edx
801028f8:	b8 04 00 00 00       	mov    $0x4,%eax
801028fd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028fe:	89 ca                	mov    %ecx,%edx
80102900:	ec                   	in     (%dx),%al
80102901:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102904:	89 da                	mov    %ebx,%edx
80102906:	b8 07 00 00 00       	mov    $0x7,%eax
8010290b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010290c:	89 ca                	mov    %ecx,%edx
8010290e:	ec                   	in     (%dx),%al
8010290f:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102912:	89 da                	mov    %ebx,%edx
80102914:	b8 08 00 00 00       	mov    $0x8,%eax
80102919:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010291a:	89 ca                	mov    %ecx,%edx
8010291c:	ec                   	in     (%dx),%al
8010291d:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010291f:	89 da                	mov    %ebx,%edx
80102921:	b8 09 00 00 00       	mov    $0x9,%eax
80102926:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102927:	89 ca                	mov    %ecx,%edx
80102929:	ec                   	in     (%dx),%al
8010292a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010292c:	89 da                	mov    %ebx,%edx
8010292e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102933:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102934:	89 ca                	mov    %ecx,%edx
80102936:	ec                   	in     (%dx),%al
  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102937:	84 c0                	test   %al,%al
80102939:	78 9d                	js     801028d8 <cmostime+0x28>
  return inb(CMOS_RETURN);
8010293b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
8010293f:	89 fa                	mov    %edi,%edx
80102941:	0f b6 fa             	movzbl %dl,%edi
80102944:	89 f2                	mov    %esi,%edx
80102946:	0f b6 f2             	movzbl %dl,%esi
80102949:	89 7d c8             	mov    %edi,-0x38(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010294c:	89 da                	mov    %ebx,%edx
8010294e:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102951:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102954:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102958:	89 45 bc             	mov    %eax,-0x44(%ebp)
8010295b:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
8010295f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102962:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102966:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102969:	31 c0                	xor    %eax,%eax
8010296b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010296c:	89 ca                	mov    %ecx,%edx
8010296e:	ec                   	in     (%dx),%al
8010296f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102972:	89 da                	mov    %ebx,%edx
80102974:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102977:	b8 02 00 00 00       	mov    $0x2,%eax
8010297c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010297d:	89 ca                	mov    %ecx,%edx
8010297f:	ec                   	in     (%dx),%al
80102980:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102983:	89 da                	mov    %ebx,%edx
80102985:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102988:	b8 04 00 00 00       	mov    $0x4,%eax
8010298d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010298e:	89 ca                	mov    %ecx,%edx
80102990:	ec                   	in     (%dx),%al
80102991:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102994:	89 da                	mov    %ebx,%edx
80102996:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102999:	b8 07 00 00 00       	mov    $0x7,%eax
8010299e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010299f:	89 ca                	mov    %ecx,%edx
801029a1:	ec                   	in     (%dx),%al
801029a2:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029a5:	89 da                	mov    %ebx,%edx
801029a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
801029aa:	b8 08 00 00 00       	mov    $0x8,%eax
801029af:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029b0:	89 ca                	mov    %ecx,%edx
801029b2:	ec                   	in     (%dx),%al
801029b3:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029b6:	89 da                	mov    %ebx,%edx
801029b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801029bb:	b8 09 00 00 00       	mov    $0x9,%eax
801029c0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029c1:	89 ca                	mov    %ecx,%edx
801029c3:	ec                   	in     (%dx),%al
801029c4:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801029c7:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
801029ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801029cd:	8d 45 d0             	lea    -0x30(%ebp),%eax
801029d0:	6a 18                	push   $0x18
801029d2:	50                   	push   %eax
801029d3:	8d 45 b8             	lea    -0x48(%ebp),%eax
801029d6:	50                   	push   %eax
801029d7:	e8 84 24 00 00       	call   80104e60 <memcmp>
801029dc:	83 c4 10             	add    $0x10,%esp
801029df:	85 c0                	test   %eax,%eax
801029e1:	0f 85 f1 fe ff ff    	jne    801028d8 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
801029e7:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
801029eb:	75 78                	jne    80102a65 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801029ed:	8b 45 b8             	mov    -0x48(%ebp),%eax
801029f0:	89 c2                	mov    %eax,%edx
801029f2:	83 e0 0f             	and    $0xf,%eax
801029f5:	c1 ea 04             	shr    $0x4,%edx
801029f8:	8d 14 92             	lea    (%edx,%edx,4),%edx
801029fb:	8d 04 50             	lea    (%eax,%edx,2),%eax
801029fe:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102a01:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102a04:	89 c2                	mov    %eax,%edx
80102a06:	83 e0 0f             	and    $0xf,%eax
80102a09:	c1 ea 04             	shr    $0x4,%edx
80102a0c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a0f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a12:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102a15:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102a18:	89 c2                	mov    %eax,%edx
80102a1a:	83 e0 0f             	and    $0xf,%eax
80102a1d:	c1 ea 04             	shr    $0x4,%edx
80102a20:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a23:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a26:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102a29:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102a2c:	89 c2                	mov    %eax,%edx
80102a2e:	83 e0 0f             	and    $0xf,%eax
80102a31:	c1 ea 04             	shr    $0x4,%edx
80102a34:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a37:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a3a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102a3d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102a40:	89 c2                	mov    %eax,%edx
80102a42:	83 e0 0f             	and    $0xf,%eax
80102a45:	c1 ea 04             	shr    $0x4,%edx
80102a48:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a4b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a4e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102a51:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102a54:	89 c2                	mov    %eax,%edx
80102a56:	83 e0 0f             	and    $0xf,%eax
80102a59:	c1 ea 04             	shr    $0x4,%edx
80102a5c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a5f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a62:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102a65:	8b 75 08             	mov    0x8(%ebp),%esi
80102a68:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102a6b:	89 06                	mov    %eax,(%esi)
80102a6d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102a70:	89 46 04             	mov    %eax,0x4(%esi)
80102a73:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102a76:	89 46 08             	mov    %eax,0x8(%esi)
80102a79:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102a7c:	89 46 0c             	mov    %eax,0xc(%esi)
80102a7f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102a82:	89 46 10             	mov    %eax,0x10(%esi)
80102a85:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102a88:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102a8b:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102a92:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102a95:	5b                   	pop    %ebx
80102a96:	5e                   	pop    %esi
80102a97:	5f                   	pop    %edi
80102a98:	5d                   	pop    %ebp
80102a99:	c3                   	ret    
80102a9a:	66 90                	xchg   %ax,%ax
80102a9c:	66 90                	xchg   %ax,%ax
80102a9e:	66 90                	xchg   %ax,%ax

80102aa0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102aa0:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102aa6:	85 c9                	test   %ecx,%ecx
80102aa8:	0f 8e 8a 00 00 00    	jle    80102b38 <install_trans+0x98>
{
80102aae:	55                   	push   %ebp
80102aaf:	89 e5                	mov    %esp,%ebp
80102ab1:	57                   	push   %edi
80102ab2:	56                   	push   %esi
80102ab3:	53                   	push   %ebx
  for (tail = 0; tail < log.lh.n; tail++) {
80102ab4:	31 db                	xor    %ebx,%ebx
{
80102ab6:	83 ec 0c             	sub    $0xc,%esp
80102ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102ac0:	a1 14 22 11 80       	mov    0x80112214,%eax
80102ac5:	83 ec 08             	sub    $0x8,%esp
80102ac8:	01 d8                	add    %ebx,%eax
80102aca:	83 c0 01             	add    $0x1,%eax
80102acd:	50                   	push   %eax
80102ace:	ff 35 24 22 11 80    	pushl  0x80112224
80102ad4:	e8 e7 d5 ff ff       	call   801000c0 <bread>
80102ad9:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102adb:	58                   	pop    %eax
80102adc:	5a                   	pop    %edx
80102add:	ff 34 9d 2c 22 11 80 	pushl  -0x7feeddd4(,%ebx,4)
80102ae4:	ff 35 24 22 11 80    	pushl  0x80112224
  for (tail = 0; tail < log.lh.n; tail++) {
80102aea:	83 c3 01             	add    $0x1,%ebx
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102aed:	e8 ce d5 ff ff       	call   801000c0 <bread>
80102af2:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102af4:	8d 47 18             	lea    0x18(%edi),%eax
80102af7:	83 c4 0c             	add    $0xc,%esp
80102afa:	68 00 02 00 00       	push   $0x200
80102aff:	50                   	push   %eax
80102b00:	8d 46 18             	lea    0x18(%esi),%eax
80102b03:	50                   	push   %eax
80102b04:	e8 b7 23 00 00       	call   80104ec0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102b09:	89 34 24             	mov    %esi,(%esp)
80102b0c:	e8 8f d6 ff ff       	call   801001a0 <bwrite>
    brelse(lbuf);
80102b11:	89 3c 24             	mov    %edi,(%esp)
80102b14:	e8 b7 d6 ff ff       	call   801001d0 <brelse>
    brelse(dbuf);
80102b19:	89 34 24             	mov    %esi,(%esp)
80102b1c:	e8 af d6 ff ff       	call   801001d0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102b21:	83 c4 10             	add    $0x10,%esp
80102b24:	39 1d 28 22 11 80    	cmp    %ebx,0x80112228
80102b2a:	7f 94                	jg     80102ac0 <install_trans+0x20>
  }
}
80102b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102b2f:	5b                   	pop    %ebx
80102b30:	5e                   	pop    %esi
80102b31:	5f                   	pop    %edi
80102b32:	5d                   	pop    %ebp
80102b33:	c3                   	ret    
80102b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102b38:	f3 c3                	repz ret 
80102b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102b40 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102b40:	55                   	push   %ebp
80102b41:	89 e5                	mov    %esp,%ebp
80102b43:	53                   	push   %ebx
80102b44:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102b47:	ff 35 14 22 11 80    	pushl  0x80112214
80102b4d:	ff 35 24 22 11 80    	pushl  0x80112224
80102b53:	e8 68 d5 ff ff       	call   801000c0 <bread>
80102b58:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102b5a:	a1 28 22 11 80       	mov    0x80112228,%eax
  for (i = 0; i < log.lh.n; i++) {
80102b5f:	83 c4 10             	add    $0x10,%esp
  hb->n = log.lh.n;
80102b62:	89 43 18             	mov    %eax,0x18(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102b65:	a1 28 22 11 80       	mov    0x80112228,%eax
80102b6a:	85 c0                	test   %eax,%eax
80102b6c:	7e 18                	jle    80102b86 <write_head+0x46>
80102b6e:	31 d2                	xor    %edx,%edx
    hb->block[i] = log.lh.block[i];
80102b70:	8b 0c 95 2c 22 11 80 	mov    -0x7feeddd4(,%edx,4),%ecx
80102b77:	89 4c 93 1c          	mov    %ecx,0x1c(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102b7b:	83 c2 01             	add    $0x1,%edx
80102b7e:	39 15 28 22 11 80    	cmp    %edx,0x80112228
80102b84:	7f ea                	jg     80102b70 <write_head+0x30>
  }
  bwrite(buf);
80102b86:	83 ec 0c             	sub    $0xc,%esp
80102b89:	53                   	push   %ebx
80102b8a:	e8 11 d6 ff ff       	call   801001a0 <bwrite>
  brelse(buf);
80102b8f:	89 1c 24             	mov    %ebx,(%esp)
80102b92:	e8 39 d6 ff ff       	call   801001d0 <brelse>
}
80102b97:	83 c4 10             	add    $0x10,%esp
80102b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b9d:	c9                   	leave  
80102b9e:	c3                   	ret    
80102b9f:	90                   	nop

80102ba0 <initlog>:
{
80102ba0:	55                   	push   %ebp
80102ba1:	89 e5                	mov    %esp,%ebp
80102ba3:	53                   	push   %ebx
80102ba4:	83 ec 2c             	sub    $0x2c,%esp
80102ba7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102baa:	68 fc 7f 10 80       	push   $0x80107ffc
80102baf:	68 e0 21 11 80       	push   $0x801121e0
80102bb4:	e8 27 20 00 00       	call   80104be0 <initlock>
  readsb(dev, &sb);
80102bb9:	58                   	pop    %eax
80102bba:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102bbd:	5a                   	pop    %edx
80102bbe:	50                   	push   %eax
80102bbf:	53                   	push   %ebx
80102bc0:	e8 cb e7 ff ff       	call   80101390 <readsb>
  log.size = sb.nlog;
80102bc5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102bc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102bcb:	59                   	pop    %ecx
  log.dev = dev;
80102bcc:	89 1d 24 22 11 80    	mov    %ebx,0x80112224
  log.size = sb.nlog;
80102bd2:	89 15 18 22 11 80    	mov    %edx,0x80112218
  log.start = sb.logstart;
80102bd8:	a3 14 22 11 80       	mov    %eax,0x80112214
  struct buf *buf = bread(log.dev, log.start);
80102bdd:	5a                   	pop    %edx
80102bde:	50                   	push   %eax
80102bdf:	53                   	push   %ebx
80102be0:	e8 db d4 ff ff       	call   801000c0 <bread>
  log.lh.n = lh->n;
80102be5:	8b 58 18             	mov    0x18(%eax),%ebx
  for (i = 0; i < log.lh.n; i++) {
80102be8:	83 c4 10             	add    $0x10,%esp
80102beb:	85 db                	test   %ebx,%ebx
  log.lh.n = lh->n;
80102bed:	89 1d 28 22 11 80    	mov    %ebx,0x80112228
  for (i = 0; i < log.lh.n; i++) {
80102bf3:	7e 1c                	jle    80102c11 <initlog+0x71>
80102bf5:	c1 e3 02             	shl    $0x2,%ebx
80102bf8:	31 d2                	xor    %edx,%edx
80102bfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    log.lh.block[i] = lh->block[i];
80102c00:	8b 4c 10 1c          	mov    0x1c(%eax,%edx,1),%ecx
80102c04:	83 c2 04             	add    $0x4,%edx
80102c07:	89 8a 28 22 11 80    	mov    %ecx,-0x7feeddd8(%edx)
  for (i = 0; i < log.lh.n; i++) {
80102c0d:	39 d3                	cmp    %edx,%ebx
80102c0f:	75 ef                	jne    80102c00 <initlog+0x60>
  brelse(buf);
80102c11:	83 ec 0c             	sub    $0xc,%esp
80102c14:	50                   	push   %eax
80102c15:	e8 b6 d5 ff ff       	call   801001d0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102c1a:	e8 81 fe ff ff       	call   80102aa0 <install_trans>
  log.lh.n = 0;
80102c1f:	c7 05 28 22 11 80 00 	movl   $0x0,0x80112228
80102c26:	00 00 00 
  write_head(); // clear the log
80102c29:	e8 12 ff ff ff       	call   80102b40 <write_head>
}
80102c2e:	83 c4 10             	add    $0x10,%esp
80102c31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c34:	c9                   	leave  
80102c35:	c3                   	ret    
80102c36:	8d 76 00             	lea    0x0(%esi),%esi
80102c39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c40 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102c40:	55                   	push   %ebp
80102c41:	89 e5                	mov    %esp,%ebp
80102c43:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102c46:	68 e0 21 11 80       	push   $0x801121e0
80102c4b:	e8 b0 1f 00 00       	call   80104c00 <acquire>
80102c50:	83 c4 10             	add    $0x10,%esp
80102c53:	eb 18                	jmp    80102c6d <begin_op+0x2d>
80102c55:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102c58:	83 ec 08             	sub    $0x8,%esp
80102c5b:	68 e0 21 11 80       	push   $0x801121e0
80102c60:	68 e0 21 11 80       	push   $0x801121e0
80102c65:	e8 b6 14 00 00       	call   80104120 <sleep>
80102c6a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102c6d:	a1 20 22 11 80       	mov    0x80112220,%eax
80102c72:	85 c0                	test   %eax,%eax
80102c74:	75 e2                	jne    80102c58 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102c76:	a1 1c 22 11 80       	mov    0x8011221c,%eax
80102c7b:	8b 15 28 22 11 80    	mov    0x80112228,%edx
80102c81:	83 c0 01             	add    $0x1,%eax
80102c84:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102c87:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102c8a:	83 fa 1e             	cmp    $0x1e,%edx
80102c8d:	7f c9                	jg     80102c58 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102c8f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102c92:	a3 1c 22 11 80       	mov    %eax,0x8011221c
      release(&log.lock);
80102c97:	68 e0 21 11 80       	push   $0x801121e0
80102c9c:	e8 1f 21 00 00       	call   80104dc0 <release>
      break;
    }
  }
}
80102ca1:	83 c4 10             	add    $0x10,%esp
80102ca4:	c9                   	leave  
80102ca5:	c3                   	ret    
80102ca6:	8d 76 00             	lea    0x0(%esi),%esi
80102ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102cb0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102cb0:	55                   	push   %ebp
80102cb1:	89 e5                	mov    %esp,%ebp
80102cb3:	57                   	push   %edi
80102cb4:	56                   	push   %esi
80102cb5:	53                   	push   %ebx
80102cb6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102cb9:	68 e0 21 11 80       	push   $0x801121e0
80102cbe:	e8 3d 1f 00 00       	call   80104c00 <acquire>
  log.outstanding -= 1;
80102cc3:	a1 1c 22 11 80       	mov    0x8011221c,%eax
  if(log.committing)
80102cc8:	8b 35 20 22 11 80    	mov    0x80112220,%esi
80102cce:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102cd1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  if(log.committing)
80102cd4:	85 f6                	test   %esi,%esi
  log.outstanding -= 1;
80102cd6:	89 1d 1c 22 11 80    	mov    %ebx,0x8011221c
  if(log.committing)
80102cdc:	0f 85 1a 01 00 00    	jne    80102dfc <end_op+0x14c>
    panic("log.committing");
  if(log.outstanding == 0){
80102ce2:	85 db                	test   %ebx,%ebx
80102ce4:	0f 85 ee 00 00 00    	jne    80102dd8 <end_op+0x128>
    log.committing = 1;
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
  }
  release(&log.lock);
80102cea:	83 ec 0c             	sub    $0xc,%esp
    log.committing = 1;
80102ced:	c7 05 20 22 11 80 01 	movl   $0x1,0x80112220
80102cf4:	00 00 00 
  release(&log.lock);
80102cf7:	68 e0 21 11 80       	push   $0x801121e0
80102cfc:	e8 bf 20 00 00       	call   80104dc0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102d01:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102d07:	83 c4 10             	add    $0x10,%esp
80102d0a:	85 c9                	test   %ecx,%ecx
80102d0c:	0f 8e 85 00 00 00    	jle    80102d97 <end_op+0xe7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102d12:	a1 14 22 11 80       	mov    0x80112214,%eax
80102d17:	83 ec 08             	sub    $0x8,%esp
80102d1a:	01 d8                	add    %ebx,%eax
80102d1c:	83 c0 01             	add    $0x1,%eax
80102d1f:	50                   	push   %eax
80102d20:	ff 35 24 22 11 80    	pushl  0x80112224
80102d26:	e8 95 d3 ff ff       	call   801000c0 <bread>
80102d2b:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d2d:	58                   	pop    %eax
80102d2e:	5a                   	pop    %edx
80102d2f:	ff 34 9d 2c 22 11 80 	pushl  -0x7feeddd4(,%ebx,4)
80102d36:	ff 35 24 22 11 80    	pushl  0x80112224
  for (tail = 0; tail < log.lh.n; tail++) {
80102d3c:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d3f:	e8 7c d3 ff ff       	call   801000c0 <bread>
80102d44:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102d46:	8d 40 18             	lea    0x18(%eax),%eax
80102d49:	83 c4 0c             	add    $0xc,%esp
80102d4c:	68 00 02 00 00       	push   $0x200
80102d51:	50                   	push   %eax
80102d52:	8d 46 18             	lea    0x18(%esi),%eax
80102d55:	50                   	push   %eax
80102d56:	e8 65 21 00 00       	call   80104ec0 <memmove>
    bwrite(to);  // write the log
80102d5b:	89 34 24             	mov    %esi,(%esp)
80102d5e:	e8 3d d4 ff ff       	call   801001a0 <bwrite>
    brelse(from);
80102d63:	89 3c 24             	mov    %edi,(%esp)
80102d66:	e8 65 d4 ff ff       	call   801001d0 <brelse>
    brelse(to);
80102d6b:	89 34 24             	mov    %esi,(%esp)
80102d6e:	e8 5d d4 ff ff       	call   801001d0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102d73:	83 c4 10             	add    $0x10,%esp
80102d76:	3b 1d 28 22 11 80    	cmp    0x80112228,%ebx
80102d7c:	7c 94                	jl     80102d12 <end_op+0x62>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102d7e:	e8 bd fd ff ff       	call   80102b40 <write_head>
    install_trans(); // Now install writes to home locations
80102d83:	e8 18 fd ff ff       	call   80102aa0 <install_trans>
    log.lh.n = 0;
80102d88:	c7 05 28 22 11 80 00 	movl   $0x0,0x80112228
80102d8f:	00 00 00 
    write_head();    // Erase the transaction from the log
80102d92:	e8 a9 fd ff ff       	call   80102b40 <write_head>
    acquire(&log.lock);
80102d97:	83 ec 0c             	sub    $0xc,%esp
80102d9a:	68 e0 21 11 80       	push   $0x801121e0
80102d9f:	e8 5c 1e 00 00       	call   80104c00 <acquire>
    wakeup(&log);
80102da4:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
    log.committing = 0;
80102dab:	c7 05 20 22 11 80 00 	movl   $0x0,0x80112220
80102db2:	00 00 00 
    wakeup(&log);
80102db5:	e8 56 15 00 00       	call   80104310 <wakeup>
    release(&log.lock);
80102dba:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102dc1:	e8 fa 1f 00 00       	call   80104dc0 <release>
80102dc6:	83 c4 10             	add    $0x10,%esp
}
80102dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dcc:	5b                   	pop    %ebx
80102dcd:	5e                   	pop    %esi
80102dce:	5f                   	pop    %edi
80102dcf:	5d                   	pop    %ebp
80102dd0:	c3                   	ret    
80102dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&log);
80102dd8:	83 ec 0c             	sub    $0xc,%esp
80102ddb:	68 e0 21 11 80       	push   $0x801121e0
80102de0:	e8 2b 15 00 00       	call   80104310 <wakeup>
  release(&log.lock);
80102de5:	c7 04 24 e0 21 11 80 	movl   $0x801121e0,(%esp)
80102dec:	e8 cf 1f 00 00       	call   80104dc0 <release>
80102df1:	83 c4 10             	add    $0x10,%esp
}
80102df4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102df7:	5b                   	pop    %ebx
80102df8:	5e                   	pop    %esi
80102df9:	5f                   	pop    %edi
80102dfa:	5d                   	pop    %ebp
80102dfb:	c3                   	ret    
    panic("log.committing");
80102dfc:	83 ec 0c             	sub    $0xc,%esp
80102dff:	68 00 80 10 80       	push   $0x80108000
80102e04:	e8 67 d5 ff ff       	call   80100370 <panic>
80102e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102e10 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102e10:	55                   	push   %ebp
80102e11:	89 e5                	mov    %esp,%ebp
80102e13:	53                   	push   %ebx
80102e14:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102e17:	8b 15 28 22 11 80    	mov    0x80112228,%edx
{
80102e1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102e20:	83 fa 1d             	cmp    $0x1d,%edx
80102e23:	0f 8f 9d 00 00 00    	jg     80102ec6 <log_write+0xb6>
80102e29:	a1 18 22 11 80       	mov    0x80112218,%eax
80102e2e:	83 e8 01             	sub    $0x1,%eax
80102e31:	39 c2                	cmp    %eax,%edx
80102e33:	0f 8d 8d 00 00 00    	jge    80102ec6 <log_write+0xb6>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102e39:	a1 1c 22 11 80       	mov    0x8011221c,%eax
80102e3e:	85 c0                	test   %eax,%eax
80102e40:	0f 8e 8d 00 00 00    	jle    80102ed3 <log_write+0xc3>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102e46:	83 ec 0c             	sub    $0xc,%esp
80102e49:	68 e0 21 11 80       	push   $0x801121e0
80102e4e:	e8 ad 1d 00 00       	call   80104c00 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102e53:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
80102e59:	83 c4 10             	add    $0x10,%esp
80102e5c:	83 f9 00             	cmp    $0x0,%ecx
80102e5f:	7e 57                	jle    80102eb8 <log_write+0xa8>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102e61:	8b 53 08             	mov    0x8(%ebx),%edx
  for (i = 0; i < log.lh.n; i++) {
80102e64:	31 c0                	xor    %eax,%eax
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102e66:	3b 15 2c 22 11 80    	cmp    0x8011222c,%edx
80102e6c:	75 0b                	jne    80102e79 <log_write+0x69>
80102e6e:	eb 38                	jmp    80102ea8 <log_write+0x98>
80102e70:	39 14 85 2c 22 11 80 	cmp    %edx,-0x7feeddd4(,%eax,4)
80102e77:	74 2f                	je     80102ea8 <log_write+0x98>
  for (i = 0; i < log.lh.n; i++) {
80102e79:	83 c0 01             	add    $0x1,%eax
80102e7c:	39 c1                	cmp    %eax,%ecx
80102e7e:	75 f0                	jne    80102e70 <log_write+0x60>
      break;
  }
  log.lh.block[i] = b->blockno;
80102e80:	89 14 85 2c 22 11 80 	mov    %edx,-0x7feeddd4(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	a3 28 22 11 80       	mov    %eax,0x80112228
  b->flags |= B_DIRTY; // prevent eviction
80102e8f:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102e92:	c7 45 08 e0 21 11 80 	movl   $0x801121e0,0x8(%ebp)
}
80102e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e9c:	c9                   	leave  
  release(&log.lock);
80102e9d:	e9 1e 1f 00 00       	jmp    80104dc0 <release>
80102ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80102ea8:	89 14 85 2c 22 11 80 	mov    %edx,-0x7feeddd4(,%eax,4)
80102eaf:	eb de                	jmp    80102e8f <log_write+0x7f>
80102eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102eb8:	8b 43 08             	mov    0x8(%ebx),%eax
80102ebb:	a3 2c 22 11 80       	mov    %eax,0x8011222c
  if (i == log.lh.n)
80102ec0:	75 cd                	jne    80102e8f <log_write+0x7f>
80102ec2:	31 c0                	xor    %eax,%eax
80102ec4:	eb c1                	jmp    80102e87 <log_write+0x77>
    panic("too big a transaction");
80102ec6:	83 ec 0c             	sub    $0xc,%esp
80102ec9:	68 0f 80 10 80       	push   $0x8010800f
80102ece:	e8 9d d4 ff ff       	call   80100370 <panic>
    panic("log_write outside of trans");
80102ed3:	83 ec 0c             	sub    $0xc,%esp
80102ed6:	68 25 80 10 80       	push   $0x80108025
80102edb:	e8 90 d4 ff ff       	call   80100370 <panic>

80102ee0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102ee0:	55                   	push   %ebp
80102ee1:	89 e5                	mov    %esp,%ebp
80102ee3:	53                   	push   %ebx
80102ee4:	83 ec 04             	sub    $0x4,%esp
  int cpuID = cpunum();
80102ee7:	e8 54 f8 ff ff       	call   80102740 <cpunum>
  cprintf("cpu%d: starting\n", cpuID);
80102eec:	83 ec 08             	sub    $0x8,%esp
  int cpuID = cpunum();
80102eef:	89 c3                	mov    %eax,%ebx
  cprintf("cpu%d: starting\n", cpuID);
80102ef1:	50                   	push   %eax
80102ef2:	68 40 80 10 80       	push   $0x80108040
80102ef7:	e8 44 d7 ff ff       	call   80100640 <cprintf>
  idtinit();       // load idt register
80102efc:	e8 8f 33 00 00       	call   80106290 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80102f01:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102f08:	b8 01 00 00 00       	mov    $0x1,%eax
80102f0d:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler(cpuID);     // start running processes
80102f14:	89 1c 24             	mov    %ebx,(%esp)
80102f17:	e8 c4 0d 00 00       	call   80103ce0 <scheduler>
80102f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102f20 <mpenter>:
{
80102f20:	55                   	push   %ebp
80102f21:	89 e5                	mov    %esp,%ebp
80102f23:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102f26:	e8 05 45 00 00       	call   80107430 <switchkvm>
  seginit();
80102f2b:	e8 90 43 00 00       	call   801072c0 <seginit>
  lapicinit();
80102f30:	e8 0b f7 ff ff       	call   80102640 <lapicinit>
  mpmain();
80102f35:	e8 a6 ff ff ff       	call   80102ee0 <mpmain>
80102f3a:	66 90                	xchg   %ax,%ax
80102f3c:	66 90                	xchg   %ax,%ax
80102f3e:	66 90                	xchg   %ax,%ax

80102f40 <main>:
{
80102f40:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102f44:	83 e4 f0             	and    $0xfffffff0,%esp
80102f47:	ff 71 fc             	pushl  -0x4(%ecx)
80102f4a:	55                   	push   %ebp
80102f4b:	89 e5                	mov    %esp,%ebp
80102f4d:	53                   	push   %ebx
80102f4e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102f4f:	83 ec 08             	sub    $0x8,%esp
80102f52:	68 00 00 40 80       	push   $0x80400000
80102f57:	68 68 b4 11 80       	push   $0x8011b468
80102f5c:	e8 9f f4 ff ff       	call   80102400 <kinit1>
  kvmalloc();      // kernel page table
80102f61:	e8 aa 44 00 00       	call   80107410 <kvmalloc>
  mpinit();        // detect other processors
80102f66:	e8 b5 01 00 00       	call   80103120 <mpinit>
  lapicinit();     // interrupt controller
80102f6b:	e8 d0 f6 ff ff       	call   80102640 <lapicinit>
  seginit();       // segment descriptors
80102f70:	e8 4b 43 00 00       	call   801072c0 <seginit>
  cprintf("\ncpu%d: starting xv6\n----------------------------\nzzx is programming xv6\n----------------------------\n", cpunum());
80102f75:	e8 c6 f7 ff ff       	call   80102740 <cpunum>
80102f7a:	5a                   	pop    %edx
80102f7b:	59                   	pop    %ecx
80102f7c:	50                   	push   %eax
80102f7d:	68 54 80 10 80       	push   $0x80108054
80102f82:	e8 b9 d6 ff ff       	call   80100640 <cprintf>
  picinit();       // another interrupt controller
80102f87:	e8 b4 03 00 00       	call   80103340 <picinit>
  ioapicinit();    // another interrupt controller
80102f8c:	e8 7f f2 ff ff       	call   80102210 <ioapicinit>
  consoleinit();   // console hardware
80102f91:	e8 0a da ff ff       	call   801009a0 <consoleinit>
  uartinit();      // serial port
80102f96:	e8 f5 35 00 00       	call   80106590 <uartinit>
  pinit();         // process table
80102f9b:	e8 d0 09 00 00       	call   80103970 <pinit>
  tvinit();        // trap vectors
80102fa0:	e8 6b 32 00 00       	call   80106210 <tvinit>
  binit();         // buffer cache
80102fa5:	e8 96 d0 ff ff       	call   80100040 <binit>
  fileinit();      // file table
80102faa:	e8 91 dd ff ff       	call   80100d40 <fileinit>
  ideinit();       // disk
80102faf:	e8 3c f0 ff ff       	call   80101ff0 <ideinit>
  if(!ismp)
80102fb4:	8b 1d c4 22 11 80    	mov    0x801122c4,%ebx
80102fba:	83 c4 10             	add    $0x10,%esp
80102fbd:	85 db                	test   %ebx,%ebx
80102fbf:	0f 84 ca 00 00 00    	je     8010308f <main+0x14f>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102fc5:	83 ec 04             	sub    $0x4,%esp
80102fc8:	68 8a 00 00 00       	push   $0x8a
80102fcd:	68 8c b4 10 80       	push   $0x8010b48c
80102fd2:	68 00 70 00 80       	push   $0x80007000
80102fd7:	e8 e4 1e 00 00       	call   80104ec0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102fdc:	69 05 c0 28 11 80 bc 	imul   $0xbc,0x801128c0,%eax
80102fe3:	00 00 00 
80102fe6:	83 c4 10             	add    $0x10,%esp
80102fe9:	05 e0 22 11 80       	add    $0x801122e0,%eax
80102fee:	3d e0 22 11 80       	cmp    $0x801122e0,%eax
80102ff3:	76 7e                	jbe    80103073 <main+0x133>
80102ff5:	bb e0 22 11 80       	mov    $0x801122e0,%ebx
80102ffa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(c == cpus+cpunum())  // We've started already.
80103000:	e8 3b f7 ff ff       	call   80102740 <cpunum>
80103005:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010300b:	05 e0 22 11 80       	add    $0x801122e0,%eax
80103010:	39 c3                	cmp    %eax,%ebx
80103012:	74 46                	je     8010305a <main+0x11a>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103014:	e8 b7 f4 ff ff       	call   801024d0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80103019:	83 ec 08             	sub    $0x8,%esp
    *(void**)(code-4) = stack + KSTACKSIZE;
8010301c:	05 00 10 00 00       	add    $0x1000,%eax
    *(void**)(code-8) = mpenter;
80103021:	c7 05 f8 6f 00 80 20 	movl   $0x80102f20,0x80006ff8
80103028:	2f 10 80 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010302b:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103030:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
80103037:	a0 10 00 
    lapicstartap(c->apicid, V2P(code));
8010303a:	68 00 70 00 00       	push   $0x7000
8010303f:	0f b6 03             	movzbl (%ebx),%eax
80103042:	50                   	push   %eax
80103043:	e8 d8 f7 ff ff       	call   80102820 <lapicstartap>
80103048:	83 c4 10             	add    $0x10,%esp
8010304b:	90                   	nop
8010304c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103050:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
80103056:	85 c0                	test   %eax,%eax
80103058:	74 f6                	je     80103050 <main+0x110>
  for(c = cpus; c < cpus+ncpu; c++){
8010305a:	69 05 c0 28 11 80 bc 	imul   $0xbc,0x801128c0,%eax
80103061:	00 00 00 
80103064:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
8010306a:	05 e0 22 11 80       	add    $0x801122e0,%eax
8010306f:	39 c3                	cmp    %eax,%ebx
80103071:	72 8d                	jb     80103000 <main+0xc0>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103073:	83 ec 08             	sub    $0x8,%esp
80103076:	68 00 00 00 8e       	push   $0x8e000000
8010307b:	68 00 00 40 80       	push   $0x80400000
80103080:	e8 eb f3 ff ff       	call   80102470 <kinit2>
  userinit();      // first user process
80103085:	e8 06 09 00 00       	call   80103990 <userinit>
  mpmain();        // finish this processor's setup
8010308a:	e8 51 fe ff ff       	call   80102ee0 <mpmain>
    timerinit();   // uniprocessor timer
8010308f:	e8 1c 31 00 00       	call   801061b0 <timerinit>
80103094:	e9 2c ff ff ff       	jmp    80102fc5 <main+0x85>
80103099:	66 90                	xchg   %ax,%ax
8010309b:	66 90                	xchg   %ax,%ax
8010309d:	66 90                	xchg   %ax,%ax
8010309f:	90                   	nop

801030a0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801030a0:	55                   	push   %ebp
801030a1:	89 e5                	mov    %esp,%ebp
801030a3:	57                   	push   %edi
801030a4:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
801030a5:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
801030ab:	53                   	push   %ebx
  e = addr+len;
801030ac:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
801030af:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
801030b2:	39 de                	cmp    %ebx,%esi
801030b4:	72 10                	jb     801030c6 <mpsearch1+0x26>
801030b6:	eb 50                	jmp    80103108 <mpsearch1+0x68>
801030b8:	90                   	nop
801030b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030c0:	39 fb                	cmp    %edi,%ebx
801030c2:	89 fe                	mov    %edi,%esi
801030c4:	76 42                	jbe    80103108 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801030c6:	83 ec 04             	sub    $0x4,%esp
801030c9:	8d 7e 10             	lea    0x10(%esi),%edi
801030cc:	6a 04                	push   $0x4
801030ce:	68 bb 80 10 80       	push   $0x801080bb
801030d3:	56                   	push   %esi
801030d4:	e8 87 1d 00 00       	call   80104e60 <memcmp>
801030d9:	83 c4 10             	add    $0x10,%esp
801030dc:	85 c0                	test   %eax,%eax
801030de:	75 e0                	jne    801030c0 <mpsearch1+0x20>
801030e0:	89 f1                	mov    %esi,%ecx
801030e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801030e8:	0f b6 11             	movzbl (%ecx),%edx
801030eb:	83 c1 01             	add    $0x1,%ecx
801030ee:	01 d0                	add    %edx,%eax
  for(i=0; i<len; i++)
801030f0:	39 f9                	cmp    %edi,%ecx
801030f2:	75 f4                	jne    801030e8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801030f4:	84 c0                	test   %al,%al
801030f6:	75 c8                	jne    801030c0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801030f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030fb:	89 f0                	mov    %esi,%eax
801030fd:	5b                   	pop    %ebx
801030fe:	5e                   	pop    %esi
801030ff:	5f                   	pop    %edi
80103100:	5d                   	pop    %ebp
80103101:	c3                   	ret    
80103102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010310b:	31 f6                	xor    %esi,%esi
}
8010310d:	89 f0                	mov    %esi,%eax
8010310f:	5b                   	pop    %ebx
80103110:	5e                   	pop    %esi
80103111:	5f                   	pop    %edi
80103112:	5d                   	pop    %ebp
80103113:	c3                   	ret    
80103114:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010311a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103120 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103120:	55                   	push   %ebp
80103121:	89 e5                	mov    %esp,%ebp
80103123:	57                   	push   %edi
80103124:	56                   	push   %esi
80103125:	53                   	push   %ebx
80103126:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103129:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103130:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103137:	c1 e0 08             	shl    $0x8,%eax
8010313a:	09 d0                	or     %edx,%eax
8010313c:	c1 e0 04             	shl    $0x4,%eax
8010313f:	85 c0                	test   %eax,%eax
80103141:	75 1b                	jne    8010315e <mpinit+0x3e>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103143:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
8010314a:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80103151:	c1 e0 08             	shl    $0x8,%eax
80103154:	09 d0                	or     %edx,%eax
80103156:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103159:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010315e:	ba 00 04 00 00       	mov    $0x400,%edx
80103163:	e8 38 ff ff ff       	call   801030a0 <mpsearch1>
80103168:	85 c0                	test   %eax,%eax
8010316a:	89 c7                	mov    %eax,%edi
8010316c:	0f 84 76 01 00 00    	je     801032e8 <mpinit+0x1c8>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103172:	8b 5f 04             	mov    0x4(%edi),%ebx
80103175:	85 db                	test   %ebx,%ebx
80103177:	0f 84 e6 00 00 00    	je     80103263 <mpinit+0x143>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010317d:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80103183:	83 ec 04             	sub    $0x4,%esp
80103186:	6a 04                	push   $0x4
80103188:	68 c0 80 10 80       	push   $0x801080c0
8010318d:	56                   	push   %esi
8010318e:	e8 cd 1c 00 00       	call   80104e60 <memcmp>
80103193:	83 c4 10             	add    $0x10,%esp
80103196:	85 c0                	test   %eax,%eax
80103198:	0f 85 c5 00 00 00    	jne    80103263 <mpinit+0x143>
  if(conf->version != 1 && conf->version != 4)
8010319e:	0f b6 93 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%edx
801031a5:	80 fa 01             	cmp    $0x1,%dl
801031a8:	0f 95 c1             	setne  %cl
801031ab:	80 fa 04             	cmp    $0x4,%dl
801031ae:	0f 95 c2             	setne  %dl
801031b1:	20 ca                	and    %cl,%dl
801031b3:	0f 85 aa 00 00 00    	jne    80103263 <mpinit+0x143>
  if(sum((uchar*)conf, conf->length) != 0)
801031b9:	0f b7 8b 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%ecx
  for(i=0; i<len; i++)
801031c0:	66 85 c9             	test   %cx,%cx
801031c3:	74 1f                	je     801031e4 <mpinit+0xc4>
801031c5:	01 f1                	add    %esi,%ecx
801031c7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801031ca:	89 f2                	mov    %esi,%edx
801031cc:	89 cb                	mov    %ecx,%ebx
801031ce:	66 90                	xchg   %ax,%ax
    sum += addr[i];
801031d0:	0f b6 0a             	movzbl (%edx),%ecx
801031d3:	83 c2 01             	add    $0x1,%edx
801031d6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801031d8:	39 da                	cmp    %ebx,%edx
801031da:	75 f4                	jne    801031d0 <mpinit+0xb0>
801031dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801031df:	84 c0                	test   %al,%al
801031e1:	0f 95 c2             	setne  %dl
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
801031e4:	85 f6                	test   %esi,%esi
801031e6:	74 7b                	je     80103263 <mpinit+0x143>
801031e8:	84 d2                	test   %dl,%dl
801031ea:	75 77                	jne    80103263 <mpinit+0x143>
    return;
  ismp = 1;
801031ec:	c7 05 c4 22 11 80 01 	movl   $0x1,0x801122c4
801031f3:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801031f6:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
801031fc:	a3 dc 21 11 80       	mov    %eax,0x801121dc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103201:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80103208:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
8010320e:	01 d6                	add    %edx,%esi
80103210:	39 f0                	cmp    %esi,%eax
80103212:	0f 83 a8 00 00 00    	jae    801032c0 <mpinit+0x1a0>
80103218:	90                   	nop
80103219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(*p){
80103220:	80 38 04             	cmpb   $0x4,(%eax)
80103223:	0f 87 87 00 00 00    	ja     801032b0 <mpinit+0x190>
80103229:	0f b6 10             	movzbl (%eax),%edx
8010322c:	ff 24 95 c8 80 10 80 	jmp    *-0x7fef7f38(,%edx,4)
80103233:	90                   	nop
80103234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103238:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010323b:	39 c6                	cmp    %eax,%esi
8010323d:	77 e1                	ja     80103220 <mpinit+0x100>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp){
8010323f:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103244:	85 c0                	test   %eax,%eax
80103246:	75 78                	jne    801032c0 <mpinit+0x1a0>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103248:	c7 05 c0 28 11 80 01 	movl   $0x1,0x801128c0
8010324f:	00 00 00 
    lapic = 0;
80103252:	c7 05 dc 21 11 80 00 	movl   $0x0,0x801121dc
80103259:	00 00 00 
    ioapicid = 0;
8010325c:	c6 05 c0 22 11 80 00 	movb   $0x0,0x801122c0
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103263:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103266:	5b                   	pop    %ebx
80103267:	5e                   	pop    %esi
80103268:	5f                   	pop    %edi
80103269:	5d                   	pop    %ebp
8010326a:	c3                   	ret    
8010326b:	90                   	nop
8010326c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(ncpu < NCPU) {
80103270:	8b 15 c0 28 11 80    	mov    0x801128c0,%edx
80103276:	83 fa 07             	cmp    $0x7,%edx
80103279:	7f 19                	jg     80103294 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010327b:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
8010327f:	69 da bc 00 00 00    	imul   $0xbc,%edx,%ebx
        ncpu++;
80103285:	83 c2 01             	add    $0x1,%edx
80103288:	89 15 c0 28 11 80    	mov    %edx,0x801128c0
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010328e:	88 8b e0 22 11 80    	mov    %cl,-0x7feedd20(%ebx)
      p += sizeof(struct mpproc);
80103294:	83 c0 14             	add    $0x14,%eax
      continue;
80103297:	eb a2                	jmp    8010323b <mpinit+0x11b>
80103299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
801032a0:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      p += sizeof(struct mpioapic);
801032a4:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
801032a7:	88 15 c0 22 11 80    	mov    %dl,0x801122c0
      continue;
801032ad:	eb 8c                	jmp    8010323b <mpinit+0x11b>
801032af:	90                   	nop
      ismp = 0;
801032b0:	c7 05 c4 22 11 80 00 	movl   $0x0,0x801122c4
801032b7:	00 00 00 
      break;
801032ba:	e9 7c ff ff ff       	jmp    8010323b <mpinit+0x11b>
801032bf:	90                   	nop
  if(mp->imcrp){
801032c0:	80 7f 0c 00          	cmpb   $0x0,0xc(%edi)
801032c4:	74 9d                	je     80103263 <mpinit+0x143>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801032c6:	b8 70 00 00 00       	mov    $0x70,%eax
801032cb:	ba 22 00 00 00       	mov    $0x22,%edx
801032d0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801032d1:	ba 23 00 00 00       	mov    $0x23,%edx
801032d6:	ec                   	in     (%dx),%al
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801032d7:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801032da:	ee                   	out    %al,(%dx)
}
801032db:	8d 65 f4             	lea    -0xc(%ebp),%esp
801032de:	5b                   	pop    %ebx
801032df:	5e                   	pop    %esi
801032e0:	5f                   	pop    %edi
801032e1:	5d                   	pop    %ebp
801032e2:	c3                   	ret    
801032e3:	90                   	nop
801032e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return mpsearch1(0xF0000, 0x10000);
801032e8:	ba 00 00 01 00       	mov    $0x10000,%edx
801032ed:	b8 00 00 0f 00       	mov    $0xf0000,%eax
801032f2:	e8 a9 fd ff ff       	call   801030a0 <mpsearch1>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801032f7:	85 c0                	test   %eax,%eax
  return mpsearch1(0xF0000, 0x10000);
801032f9:	89 c7                	mov    %eax,%edi
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801032fb:	0f 85 71 fe ff ff    	jne    80103172 <mpinit+0x52>
80103301:	e9 5d ff ff ff       	jmp    80103263 <mpinit+0x143>
80103306:	66 90                	xchg   %ax,%ax
80103308:	66 90                	xchg   %ax,%ax
8010330a:	66 90                	xchg   %ax,%ax
8010330c:	66 90                	xchg   %ax,%ax
8010330e:	66 90                	xchg   %ax,%ax

80103310 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
80103310:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
80103311:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
80103316:	ba 21 00 00 00       	mov    $0x21,%edx
{
8010331b:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
8010331d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103320:	d3 c0                	rol    %cl,%eax
80103322:	66 23 05 00 b0 10 80 	and    0x8010b000,%ax
  irqmask = mask;
80103329:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
8010332f:	ee                   	out    %al,(%dx)
80103330:	ba a1 00 00 00       	mov    $0xa1,%edx
  outb(IO_PIC2+1, mask >> 8);
80103335:	66 c1 e8 08          	shr    $0x8,%ax
80103339:	ee                   	out    %al,(%dx)
}
8010333a:	5d                   	pop    %ebp
8010333b:	c3                   	ret    
8010333c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103340 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103340:	55                   	push   %ebp
80103341:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103346:	89 e5                	mov    %esp,%ebp
80103348:	57                   	push   %edi
80103349:	56                   	push   %esi
8010334a:	53                   	push   %ebx
8010334b:	bb 21 00 00 00       	mov    $0x21,%ebx
80103350:	89 da                	mov    %ebx,%edx
80103352:	ee                   	out    %al,(%dx)
80103353:	b9 a1 00 00 00       	mov    $0xa1,%ecx
80103358:	89 ca                	mov    %ecx,%edx
8010335a:	ee                   	out    %al,(%dx)
8010335b:	be 11 00 00 00       	mov    $0x11,%esi
80103360:	ba 20 00 00 00       	mov    $0x20,%edx
80103365:	89 f0                	mov    %esi,%eax
80103367:	ee                   	out    %al,(%dx)
80103368:	b8 20 00 00 00       	mov    $0x20,%eax
8010336d:	89 da                	mov    %ebx,%edx
8010336f:	ee                   	out    %al,(%dx)
80103370:	b8 04 00 00 00       	mov    $0x4,%eax
80103375:	ee                   	out    %al,(%dx)
80103376:	bf 03 00 00 00       	mov    $0x3,%edi
8010337b:	89 f8                	mov    %edi,%eax
8010337d:	ee                   	out    %al,(%dx)
8010337e:	ba a0 00 00 00       	mov    $0xa0,%edx
80103383:	89 f0                	mov    %esi,%eax
80103385:	ee                   	out    %al,(%dx)
80103386:	b8 28 00 00 00       	mov    $0x28,%eax
8010338b:	89 ca                	mov    %ecx,%edx
8010338d:	ee                   	out    %al,(%dx)
8010338e:	b8 02 00 00 00       	mov    $0x2,%eax
80103393:	ee                   	out    %al,(%dx)
80103394:	89 f8                	mov    %edi,%eax
80103396:	ee                   	out    %al,(%dx)
80103397:	bf 68 00 00 00       	mov    $0x68,%edi
8010339c:	ba 20 00 00 00       	mov    $0x20,%edx
801033a1:	89 f8                	mov    %edi,%eax
801033a3:	ee                   	out    %al,(%dx)
801033a4:	be 0a 00 00 00       	mov    $0xa,%esi
801033a9:	89 f0                	mov    %esi,%eax
801033ab:	ee                   	out    %al,(%dx)
801033ac:	ba a0 00 00 00       	mov    $0xa0,%edx
801033b1:	89 f8                	mov    %edi,%eax
801033b3:	ee                   	out    %al,(%dx)
801033b4:	89 f0                	mov    %esi,%eax
801033b6:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
801033b7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
801033be:	66 83 f8 ff          	cmp    $0xffff,%ax
801033c2:	74 0a                	je     801033ce <picinit+0x8e>
801033c4:	89 da                	mov    %ebx,%edx
801033c6:	ee                   	out    %al,(%dx)
  outb(IO_PIC2+1, mask >> 8);
801033c7:	66 c1 e8 08          	shr    $0x8,%ax
801033cb:	89 ca                	mov    %ecx,%edx
801033cd:	ee                   	out    %al,(%dx)
    picsetmask(irqmask);
}
801033ce:	5b                   	pop    %ebx
801033cf:	5e                   	pop    %esi
801033d0:	5f                   	pop    %edi
801033d1:	5d                   	pop    %ebp
801033d2:	c3                   	ret    
801033d3:	66 90                	xchg   %ax,%ax
801033d5:	66 90                	xchg   %ax,%ax
801033d7:	66 90                	xchg   %ax,%ax
801033d9:	66 90                	xchg   %ax,%ax
801033db:	66 90                	xchg   %ax,%ax
801033dd:	66 90                	xchg   %ax,%ax
801033df:	90                   	nop

801033e0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801033e0:	55                   	push   %ebp
801033e1:	89 e5                	mov    %esp,%ebp
801033e3:	57                   	push   %edi
801033e4:	56                   	push   %esi
801033e5:	53                   	push   %ebx
801033e6:	83 ec 0c             	sub    $0xc,%esp
801033e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801033ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
801033ef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801033f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801033fb:	e8 60 d9 ff ff       	call   80100d60 <filealloc>
80103400:	85 c0                	test   %eax,%eax
80103402:	89 03                	mov    %eax,(%ebx)
80103404:	74 22                	je     80103428 <pipealloc+0x48>
80103406:	e8 55 d9 ff ff       	call   80100d60 <filealloc>
8010340b:	85 c0                	test   %eax,%eax
8010340d:	89 06                	mov    %eax,(%esi)
8010340f:	74 3f                	je     80103450 <pipealloc+0x70>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103411:	e8 ba f0 ff ff       	call   801024d0 <kalloc>
80103416:	85 c0                	test   %eax,%eax
80103418:	89 c7                	mov    %eax,%edi
8010341a:	75 54                	jne    80103470 <pipealloc+0x90>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
8010341c:	8b 03                	mov    (%ebx),%eax
8010341e:	85 c0                	test   %eax,%eax
80103420:	75 34                	jne    80103456 <pipealloc+0x76>
80103422:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    fileclose(*f0);
  if(*f1)
80103428:	8b 06                	mov    (%esi),%eax
8010342a:	85 c0                	test   %eax,%eax
8010342c:	74 0c                	je     8010343a <pipealloc+0x5a>
    fileclose(*f1);
8010342e:	83 ec 0c             	sub    $0xc,%esp
80103431:	50                   	push   %eax
80103432:	e8 e9 d9 ff ff       	call   80100e20 <fileclose>
80103437:	83 c4 10             	add    $0x10,%esp
  return -1;
}
8010343a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010343d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103442:	5b                   	pop    %ebx
80103443:	5e                   	pop    %esi
80103444:	5f                   	pop    %edi
80103445:	5d                   	pop    %ebp
80103446:	c3                   	ret    
80103447:	89 f6                	mov    %esi,%esi
80103449:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  if(*f0)
80103450:	8b 03                	mov    (%ebx),%eax
80103452:	85 c0                	test   %eax,%eax
80103454:	74 e4                	je     8010343a <pipealloc+0x5a>
    fileclose(*f0);
80103456:	83 ec 0c             	sub    $0xc,%esp
80103459:	50                   	push   %eax
8010345a:	e8 c1 d9 ff ff       	call   80100e20 <fileclose>
  if(*f1)
8010345f:	8b 06                	mov    (%esi),%eax
    fileclose(*f0);
80103461:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103464:	85 c0                	test   %eax,%eax
80103466:	75 c6                	jne    8010342e <pipealloc+0x4e>
80103468:	eb d0                	jmp    8010343a <pipealloc+0x5a>
8010346a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  initlock(&p->lock, "pipe");
80103470:	83 ec 08             	sub    $0x8,%esp
  p->readopen = 1;
80103473:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010347a:	00 00 00 
  p->writeopen = 1;
8010347d:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103484:	00 00 00 
  p->nwrite = 0;
80103487:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010348e:	00 00 00 
  p->nread = 0;
80103491:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103498:	00 00 00 
  initlock(&p->lock, "pipe");
8010349b:	68 dc 80 10 80       	push   $0x801080dc
801034a0:	50                   	push   %eax
801034a1:	e8 3a 17 00 00       	call   80104be0 <initlock>
  (*f0)->type = FD_PIPE;
801034a6:	8b 03                	mov    (%ebx),%eax
  return 0;
801034a8:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801034ab:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801034b1:	8b 03                	mov    (%ebx),%eax
801034b3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801034b7:	8b 03                	mov    (%ebx),%eax
801034b9:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801034bd:	8b 03                	mov    (%ebx),%eax
801034bf:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801034c2:	8b 06                	mov    (%esi),%eax
801034c4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801034ca:	8b 06                	mov    (%esi),%eax
801034cc:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801034d0:	8b 06                	mov    (%esi),%eax
801034d2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801034d6:	8b 06                	mov    (%esi),%eax
801034d8:	89 78 0c             	mov    %edi,0xc(%eax)
}
801034db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801034de:	31 c0                	xor    %eax,%eax
}
801034e0:	5b                   	pop    %ebx
801034e1:	5e                   	pop    %esi
801034e2:	5f                   	pop    %edi
801034e3:	5d                   	pop    %ebp
801034e4:	c3                   	ret    
801034e5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801034e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801034f0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801034f0:	55                   	push   %ebp
801034f1:	89 e5                	mov    %esp,%ebp
801034f3:	56                   	push   %esi
801034f4:	53                   	push   %ebx
801034f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801034f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801034fb:	83 ec 0c             	sub    $0xc,%esp
801034fe:	53                   	push   %ebx
801034ff:	e8 fc 16 00 00       	call   80104c00 <acquire>
  if(writable){
80103504:	83 c4 10             	add    $0x10,%esp
80103507:	85 f6                	test   %esi,%esi
80103509:	74 45                	je     80103550 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
8010350b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103511:	83 ec 0c             	sub    $0xc,%esp
    p->writeopen = 0;
80103514:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010351b:	00 00 00 
    wakeup(&p->nread);
8010351e:	50                   	push   %eax
8010351f:	e8 ec 0d 00 00       	call   80104310 <wakeup>
80103524:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103527:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010352d:	85 d2                	test   %edx,%edx
8010352f:	75 0a                	jne    8010353b <pipeclose+0x4b>
80103531:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103537:	85 c0                	test   %eax,%eax
80103539:	74 35                	je     80103570 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010353b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010353e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103541:	5b                   	pop    %ebx
80103542:	5e                   	pop    %esi
80103543:	5d                   	pop    %ebp
    release(&p->lock);
80103544:	e9 77 18 00 00       	jmp    80104dc0 <release>
80103549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&p->nwrite);
80103550:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103556:	83 ec 0c             	sub    $0xc,%esp
    p->readopen = 0;
80103559:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103560:	00 00 00 
    wakeup(&p->nwrite);
80103563:	50                   	push   %eax
80103564:	e8 a7 0d 00 00       	call   80104310 <wakeup>
80103569:	83 c4 10             	add    $0x10,%esp
8010356c:	eb b9                	jmp    80103527 <pipeclose+0x37>
8010356e:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80103570:	83 ec 0c             	sub    $0xc,%esp
80103573:	53                   	push   %ebx
80103574:	e8 47 18 00 00       	call   80104dc0 <release>
    kfree((char*)p);
80103579:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010357c:	83 c4 10             	add    $0x10,%esp
}
8010357f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103582:	5b                   	pop    %ebx
80103583:	5e                   	pop    %esi
80103584:	5d                   	pop    %ebp
    kfree((char*)p);
80103585:	e9 96 ed ff ff       	jmp    80102320 <kfree>
8010358a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103590 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103590:	55                   	push   %ebp
80103591:	89 e5                	mov    %esp,%ebp
80103593:	57                   	push   %edi
80103594:	56                   	push   %esi
80103595:	53                   	push   %ebx
80103596:	83 ec 28             	sub    $0x28,%esp
80103599:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i;

  acquire(&p->lock);
8010359c:	57                   	push   %edi
8010359d:	e8 5e 16 00 00       	call   80104c00 <acquire>
  for(i = 0; i < n; i++){
801035a2:	8b 45 10             	mov    0x10(%ebp),%eax
801035a5:	83 c4 10             	add    $0x10,%esp
801035a8:	85 c0                	test   %eax,%eax
801035aa:	0f 8e d1 00 00 00    	jle    80103681 <pipewrite+0xf1>
801035b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b3:	8b 8f 38 02 00 00    	mov    0x238(%edi),%ecx
801035b9:	8d b7 34 02 00 00    	lea    0x234(%edi),%esi
801035bf:	8d 9f 38 02 00 00    	lea    0x238(%edi),%ebx
801035c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801035c8:	03 45 10             	add    0x10(%ebp),%eax
801035cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801035ce:	8b 87 34 02 00 00    	mov    0x234(%edi),%eax
801035d4:	8d 90 00 02 00 00    	lea    0x200(%eax),%edx
801035da:	39 d1                	cmp    %edx,%ecx
801035dc:	0f 85 d7 00 00 00    	jne    801036b9 <pipewrite+0x129>
      if(p->readopen == 0 || proc->killed){
801035e2:	8b 97 3c 02 00 00    	mov    0x23c(%edi),%edx
801035e8:	85 d2                	test   %edx,%edx
801035ea:	0f 84 b0 00 00 00    	je     801036a0 <pipewrite+0x110>
801035f0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801035f7:	8b 82 a8 00 00 00    	mov    0xa8(%edx),%eax
801035fd:	85 c0                	test   %eax,%eax
801035ff:	74 2d                	je     8010362e <pipewrite+0x9e>
80103601:	e9 9a 00 00 00       	jmp    801036a0 <pipewrite+0x110>
80103606:	8d 76 00             	lea    0x0(%esi),%esi
80103609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80103610:	8b 87 3c 02 00 00    	mov    0x23c(%edi),%eax
80103616:	85 c0                	test   %eax,%eax
80103618:	0f 84 82 00 00 00    	je     801036a0 <pipewrite+0x110>
8010361e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103624:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010362a:	85 c0                	test   %eax,%eax
8010362c:	75 72                	jne    801036a0 <pipewrite+0x110>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
8010362e:	83 ec 0c             	sub    $0xc,%esp
80103631:	56                   	push   %esi
80103632:	e8 d9 0c 00 00       	call   80104310 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103637:	59                   	pop    %ecx
80103638:	58                   	pop    %eax
80103639:	57                   	push   %edi
8010363a:	53                   	push   %ebx
8010363b:	e8 e0 0a 00 00       	call   80104120 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103640:	8b 87 34 02 00 00    	mov    0x234(%edi),%eax
80103646:	8b 97 38 02 00 00    	mov    0x238(%edi),%edx
8010364c:	83 c4 10             	add    $0x10,%esp
8010364f:	05 00 02 00 00       	add    $0x200,%eax
80103654:	39 c2                	cmp    %eax,%edx
80103656:	74 b8                	je     80103610 <pipewrite+0x80>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010365b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010365e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103662:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103668:	89 8f 38 02 00 00    	mov    %ecx,0x238(%edi)
8010366e:	0f b6 00             	movzbl (%eax),%eax
80103671:	88 44 17 34          	mov    %al,0x34(%edi,%edx,1)
80103675:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  for(i = 0; i < n; i++){
80103678:	39 45 e0             	cmp    %eax,-0x20(%ebp)
8010367b:	0f 85 4d ff ff ff    	jne    801035ce <pipewrite+0x3e>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103681:	8d 97 34 02 00 00    	lea    0x234(%edi),%edx
80103687:	83 ec 0c             	sub    $0xc,%esp
8010368a:	52                   	push   %edx
8010368b:	e8 80 0c 00 00       	call   80104310 <wakeup>
  release(&p->lock);
80103690:	89 3c 24             	mov    %edi,(%esp)
80103693:	e8 28 17 00 00       	call   80104dc0 <release>
  return n;
80103698:	83 c4 10             	add    $0x10,%esp
8010369b:	8b 45 10             	mov    0x10(%ebp),%eax
8010369e:	eb 11                	jmp    801036b1 <pipewrite+0x121>
        release(&p->lock);
801036a0:	83 ec 0c             	sub    $0xc,%esp
801036a3:	57                   	push   %edi
801036a4:	e8 17 17 00 00       	call   80104dc0 <release>
        return -1;
801036a9:	83 c4 10             	add    $0x10,%esp
801036ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801036b4:	5b                   	pop    %ebx
801036b5:	5e                   	pop    %esi
801036b6:	5f                   	pop    %edi
801036b7:	5d                   	pop    %ebp
801036b8:	c3                   	ret    
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801036b9:	89 ca                	mov    %ecx,%edx
801036bb:	eb 9b                	jmp    80103658 <pipewrite+0xc8>
801036bd:	8d 76 00             	lea    0x0(%esi),%esi

801036c0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	57                   	push   %edi
801036c4:	56                   	push   %esi
801036c5:	53                   	push   %ebx
801036c6:	83 ec 18             	sub    $0x18,%esp
801036c9:	8b 75 08             	mov    0x8(%ebp),%esi
801036cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801036cf:	56                   	push   %esi
801036d0:	e8 2b 15 00 00       	call   80104c00 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801036d5:	83 c4 10             	add    $0x10,%esp
801036d8:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
801036de:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
801036e4:	75 67                	jne    8010374d <piperead+0x8d>
801036e6:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
801036ec:	85 c0                	test   %eax,%eax
801036ee:	0f 84 c4 00 00 00    	je     801037b8 <piperead+0xf8>
    if(proc->killed){
801036f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801036fa:	8b 98 a8 00 00 00    	mov    0xa8(%eax),%ebx
80103700:	85 db                	test   %ebx,%ebx
80103702:	0f 85 b8 00 00 00    	jne    801037c0 <piperead+0x100>
80103708:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
8010370e:	eb 22                	jmp    80103732 <piperead+0x72>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103710:	8b 96 40 02 00 00    	mov    0x240(%esi),%edx
80103716:	85 d2                	test   %edx,%edx
80103718:	0f 84 9a 00 00 00    	je     801037b8 <piperead+0xf8>
    if(proc->killed){
8010371e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103724:	8b 88 a8 00 00 00    	mov    0xa8(%eax),%ecx
8010372a:	85 c9                	test   %ecx,%ecx
8010372c:	0f 85 8e 00 00 00    	jne    801037c0 <piperead+0x100>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103732:	83 ec 08             	sub    $0x8,%esp
80103735:	56                   	push   %esi
80103736:	53                   	push   %ebx
80103737:	e8 e4 09 00 00       	call   80104120 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010373c:	83 c4 10             	add    $0x10,%esp
8010373f:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
80103745:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
8010374b:	74 c3                	je     80103710 <piperead+0x50>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010374d:	8b 45 10             	mov    0x10(%ebp),%eax
80103750:	85 c0                	test   %eax,%eax
80103752:	7e 64                	jle    801037b8 <piperead+0xf8>
    if(p->nread == p->nwrite)
80103754:	31 db                	xor    %ebx,%ebx
80103756:	eb 16                	jmp    8010376e <piperead+0xae>
80103758:	90                   	nop
80103759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103760:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
80103766:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
8010376c:	74 1f                	je     8010378d <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010376e:	8d 41 01             	lea    0x1(%ecx),%eax
80103771:	81 e1 ff 01 00 00    	and    $0x1ff,%ecx
80103777:	89 86 34 02 00 00    	mov    %eax,0x234(%esi)
8010377d:	0f b6 44 0e 34       	movzbl 0x34(%esi,%ecx,1),%eax
80103782:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103785:	83 c3 01             	add    $0x1,%ebx
80103788:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010378b:	75 d3                	jne    80103760 <piperead+0xa0>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010378d:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103793:	83 ec 0c             	sub    $0xc,%esp
80103796:	50                   	push   %eax
80103797:	e8 74 0b 00 00       	call   80104310 <wakeup>
  release(&p->lock);
8010379c:	89 34 24             	mov    %esi,(%esp)
8010379f:	e8 1c 16 00 00       	call   80104dc0 <release>
  return i;
801037a4:	83 c4 10             	add    $0x10,%esp
}
801037a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801037aa:	89 d8                	mov    %ebx,%eax
801037ac:	5b                   	pop    %ebx
801037ad:	5e                   	pop    %esi
801037ae:	5f                   	pop    %edi
801037af:	5d                   	pop    %ebp
801037b0:	c3                   	ret    
801037b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(p->nread == p->nwrite)
801037b8:	31 db                	xor    %ebx,%ebx
801037ba:	eb d1                	jmp    8010378d <piperead+0xcd>
801037bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&p->lock);
801037c0:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801037c3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
801037c8:	56                   	push   %esi
801037c9:	e8 f2 15 00 00       	call   80104dc0 <release>
      return -1;
801037ce:	83 c4 10             	add    $0x10,%esp
}
801037d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801037d4:	89 d8                	mov    %ebx,%eax
801037d6:	5b                   	pop    %ebx
801037d7:	5e                   	pop    %esi
801037d8:	5f                   	pop    %edi
801037d9:	5d                   	pop    %ebp
801037da:	c3                   	ret    
801037db:	66 90                	xchg   %ax,%ax
801037dd:	66 90                	xchg   %ax,%ax
801037df:	90                   	nop

801037e0 <allocproc>:
// state required to run in the kernel.
// Otherwise return 0.
// Must hold ptable.lock.
static struct proc*
allocproc(void)
{
801037e0:	55                   	push   %ebp
801037e1:	89 e5                	mov    %esp,%ebp
801037e3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037e4:	bb 14 29 11 80       	mov    $0x80112914,%ebx
{
801037e9:	83 ec 04             	sub    $0x4,%esp
801037ec:	eb 14                	jmp    80103802 <allocproc+0x22>
801037ee:	66 90                	xchg   %ax,%ax
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037f0:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
801037f6:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
801037fc:	0f 83 f9 00 00 00    	jae    801038fb <allocproc+0x11b>
    if(p->state == UNUSED)
80103802:	8b 43 0c             	mov    0xc(%ebx),%eax
80103805:	85 c0                	test   %eax,%eax
80103807:	75 e7                	jne    801037f0 <allocproc+0x10>
      goto found;
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103809:	a1 08 b0 10 80       	mov    0x8010b008,%eax
  p->state = EMBRYO;
8010380e:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->priority = 10;
80103815:	c7 83 04 02 00 00 0a 	movl   $0xa,0x204(%ebx)
8010381c:	00 00 00 
  p->numofchild = 0;
8010381f:	c7 83 98 00 00 00 00 	movl   $0x0,0x98(%ebx)
80103826:	00 00 00 
  p->numofthreads = 0;
80103829:	c7 83 fc 01 00 00 00 	movl   $0x0,0x1fc(%ebx)
80103830:	00 00 00 
  p->pid = nextpid++;
80103833:	8d 50 01             	lea    0x1(%eax),%edx
80103836:	89 43 10             	mov    %eax,0x10(%ebx)
80103839:	8d 43 18             	lea    0x18(%ebx),%eax
8010383c:	89 15 08 b0 10 80    	mov    %edx,0x8010b008
80103842:	8d 93 98 00 00 00    	lea    0x98(%ebx),%edx
80103848:	90                   	nop
80103849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(int i = 0; i < MAXSON; ++i){
    p->son[i] = 0;
80103850:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103856:	83 c0 04             	add    $0x4,%eax
  for(int i = 0; i < MAXSON; ++i){
80103859:	39 d0                	cmp    %edx,%eax
8010385b:	75 f3                	jne    80103850 <allocproc+0x70>
8010385d:	8d 8b 7c 01 00 00    	lea    0x17c(%ebx),%ecx
80103863:	8d 93 fc 01 00 00    	lea    0x1fc(%ebx),%edx
80103869:	89 c8                	mov    %ecx,%eax
8010386b:	90                   	nop
8010386c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }
  for(int i = 0; i<MAXTHREADS; ++i){
    p->cthread[i] = 0;
80103870:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103876:	83 c0 04             	add    $0x4,%eax
  for(int i = 0; i<MAXTHREADS; ++i){
80103879:	39 d0                	cmp    %edx,%eax
8010387b:	75 f3                	jne    80103870 <allocproc+0x90>
8010387d:	8d 83 04 01 00 00    	lea    0x104(%ebx),%eax
80103883:	90                   	nop
80103884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }
  for (int i = 0; i < 10; ++i)
  {
    p->vm[i].next = -1;
80103888:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    p->vm[i].length = 0;
8010388f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103895:	83 c0 0c             	add    $0xc,%eax
  for (int i = 0; i < 10; ++i)
80103898:	39 c1                	cmp    %eax,%ecx
8010389a:	75 ec                	jne    80103888 <allocproc+0xa8>
  }
  p->vm[0].next = 0;
8010389c:	c7 83 08 01 00 00 00 	movl   $0x0,0x108(%ebx)
801038a3:	00 00 00 

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801038a6:	e8 25 ec ff ff       	call   801024d0 <kalloc>
801038ab:	85 c0                	test   %eax,%eax
801038ad:	89 43 08             	mov    %eax,0x8(%ebx)
801038b0:	74 42                	je     801038f4 <allocproc+0x114>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801038b2:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
801038b8:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
801038bb:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
801038c0:	89 93 9c 00 00 00    	mov    %edx,0x9c(%ebx)
  *(uint*)sp = (uint)trapret;
801038c6:	c7 40 14 fe 61 10 80 	movl   $0x801061fe,0x14(%eax)
  p->context = (struct context*)sp;
801038cd:	89 83 a0 00 00 00    	mov    %eax,0xa0(%ebx)
  memset(p->context, 0, sizeof *p->context);
801038d3:	6a 14                	push   $0x14
801038d5:	6a 00                	push   $0x0
801038d7:	50                   	push   %eax
801038d8:	e8 33 15 00 00       	call   80104e10 <memset>
  p->context->eip = (uint)forkret;
801038dd:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax

  return p;
801038e3:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801038e6:	c7 40 10 10 39 10 80 	movl   $0x80103910,0x10(%eax)
}
801038ed:	89 d8                	mov    %ebx,%eax
801038ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038f2:	c9                   	leave  
801038f3:	c3                   	ret    
    p->state = UNUSED;
801038f4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801038fb:	31 db                	xor    %ebx,%ebx
}
801038fd:	89 d8                	mov    %ebx,%eax
801038ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103902:	c9                   	leave  
80103903:	c3                   	ret    
80103904:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010390a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103910:	55                   	push   %ebp
80103911:	89 e5                	mov    %esp,%ebp
80103913:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103916:	68 e0 28 11 80       	push   $0x801128e0
8010391b:	e8 a0 14 00 00       	call   80104dc0 <release>

  if (first) {
80103920:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80103925:	83 c4 10             	add    $0x10,%esp
80103928:	85 c0                	test   %eax,%eax
8010392a:	75 04                	jne    80103930 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010392c:	c9                   	leave  
8010392d:	c3                   	ret    
8010392e:	66 90                	xchg   %ax,%ax
    iinit(ROOTDEV);
80103930:	83 ec 0c             	sub    $0xc,%esp
    first = 0;
80103933:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
8010393a:	00 00 00 
    iinit(ROOTDEV);
8010393d:	6a 01                	push   $0x1
8010393f:	e8 0c db ff ff       	call   80101450 <iinit>
    initlog(ROOTDEV);
80103944:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010394b:	e8 50 f2 ff ff       	call   80102ba0 <initlog>
80103950:	83 c4 10             	add    $0x10,%esp
}
80103953:	c9                   	leave  
80103954:	c3                   	ret    
80103955:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103959:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103960 <getcpuid>:
{
80103960:	55                   	push   %ebp
80103961:	89 e5                	mov    %esp,%ebp
}
80103963:	5d                   	pop    %ebp
  return cpunum();
80103964:	e9 d7 ed ff ff       	jmp    80102740 <cpunum>
80103969:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103970 <pinit>:
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103976:	68 e1 80 10 80       	push   $0x801080e1
8010397b:	68 e0 28 11 80       	push   $0x801128e0
80103980:	e8 5b 12 00 00       	call   80104be0 <initlock>
}
80103985:	83 c4 10             	add    $0x10,%esp
80103988:	c9                   	leave  
80103989:	c3                   	ret    
8010398a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103990 <userinit>:
{
80103990:	55                   	push   %ebp
80103991:	89 e5                	mov    %esp,%ebp
80103993:	53                   	push   %ebx
80103994:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103997:	68 e0 28 11 80       	push   $0x801128e0
8010399c:	e8 5f 12 00 00       	call   80104c00 <acquire>
  p = allocproc();
801039a1:	e8 3a fe ff ff       	call   801037e0 <allocproc>
801039a6:	89 c3                	mov    %eax,%ebx
  initproc = p;
801039a8:	a3 bc b5 10 80       	mov    %eax,0x8010b5bc
  if((p->pgdir = setupkvm()) == 0)
801039ad:	e8 ee 39 00 00       	call   801073a0 <setupkvm>
801039b2:	83 c4 10             	add    $0x10,%esp
801039b5:	85 c0                	test   %eax,%eax
801039b7:	89 43 04             	mov    %eax,0x4(%ebx)
801039ba:	0f 84 d9 00 00 00    	je     80103a99 <userinit+0x109>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801039c0:	83 ec 04             	sub    $0x4,%esp
801039c3:	68 2c 00 00 00       	push   $0x2c
801039c8:	68 60 b4 10 80       	push   $0x8010b460
801039cd:	50                   	push   %eax
801039ce:	e8 1d 3b 00 00       	call   801074f0 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
801039d3:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
801039d6:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801039dc:	6a 4c                	push   $0x4c
801039de:	6a 00                	push   $0x0
801039e0:	ff b3 9c 00 00 00    	pushl  0x9c(%ebx)
801039e6:	e8 25 14 00 00       	call   80104e10 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801039eb:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
801039f1:	ba 23 00 00 00       	mov    $0x23,%edx
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801039f6:	b9 2b 00 00 00       	mov    $0x2b,%ecx
  safestrcpy(p->name, "initcode", sizeof(p->name));
801039fb:	83 c4 0c             	add    $0xc,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801039fe:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a02:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
80103a08:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103a0c:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
80103a12:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a16:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103a1a:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
80103a20:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a24:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103a28:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
80103a2e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103a35:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
80103a3b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103a42:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
80103a48:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a4f:	8d 83 f0 00 00 00    	lea    0xf0(%ebx),%eax
80103a55:	6a 10                	push   $0x10
80103a57:	68 01 81 10 80       	push   $0x80108101
80103a5c:	50                   	push   %eax
80103a5d:	e8 8e 15 00 00       	call   80104ff0 <safestrcpy>
  p->cwd = namei("/");
80103a62:	c7 04 24 0a 81 10 80 	movl   $0x8010810a,(%esp)
80103a69:	e8 62 e4 ff ff       	call   80101ed0 <namei>
  p->cpuID = 0;   //init进程在0号cpu上运行
80103a6e:	c7 83 08 02 00 00 00 	movl   $0x0,0x208(%ebx)
80103a75:	00 00 00 
  p->cwd = namei("/");
80103a78:	89 83 ec 00 00 00    	mov    %eax,0xec(%ebx)
  p->state = RUNNABLE;
80103a7e:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103a85:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103a8c:	e8 2f 13 00 00       	call   80104dc0 <release>
}
80103a91:	83 c4 10             	add    $0x10,%esp
80103a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a97:	c9                   	leave  
80103a98:	c3                   	ret    
    panic("userinit: out of memory?");
80103a99:	83 ec 0c             	sub    $0xc,%esp
80103a9c:	68 e8 80 10 80       	push   $0x801080e8
80103aa1:	e8 ca c8 ff ff       	call   80100370 <panic>
80103aa6:	8d 76 00             	lea    0x0(%esi),%esi
80103aa9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103ab0 <growproc>:
{
80103ab0:	55                   	push   %ebp
80103ab1:	89 e5                	mov    %esp,%ebp
80103ab3:	83 ec 08             	sub    $0x8,%esp
  sz = proc->sz;
80103ab6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80103abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  sz = proc->sz;
80103ac0:	8b 02                	mov    (%edx),%eax
  if(n > 0){
80103ac2:	83 f9 00             	cmp    $0x0,%ecx
80103ac5:	7f 21                	jg     80103ae8 <growproc+0x38>
  } else if(n < 0){
80103ac7:	75 47                	jne    80103b10 <growproc+0x60>
  proc->sz = sz;
80103ac9:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
80103acb:	83 ec 0c             	sub    $0xc,%esp
80103ace:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
80103ad5:	e8 76 39 00 00       	call   80107450 <switchuvm>
  return 0;
80103ada:	83 c4 10             	add    $0x10,%esp
80103add:	31 c0                	xor    %eax,%eax
}
80103adf:	c9                   	leave  
80103ae0:	c3                   	ret    
80103ae1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80103ae8:	83 ec 04             	sub    $0x4,%esp
80103aeb:	01 c1                	add    %eax,%ecx
80103aed:	51                   	push   %ecx
80103aee:	50                   	push   %eax
80103aef:	ff 72 04             	pushl  0x4(%edx)
80103af2:	e8 39 3b 00 00       	call   80107630 <allocuvm>
80103af7:	83 c4 10             	add    $0x10,%esp
80103afa:	85 c0                	test   %eax,%eax
80103afc:	74 28                	je     80103b26 <growproc+0x76>
80103afe:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b05:	eb c2                	jmp    80103ac9 <growproc+0x19>
80103b07:	89 f6                	mov    %esi,%esi
80103b09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80103b10:	83 ec 04             	sub    $0x4,%esp
80103b13:	01 c1                	add    %eax,%ecx
80103b15:	51                   	push   %ecx
80103b16:	50                   	push   %eax
80103b17:	ff 72 04             	pushl  0x4(%edx)
80103b1a:	e8 b1 3c 00 00       	call   801077d0 <deallocuvm>
80103b1f:	83 c4 10             	add    $0x10,%esp
80103b22:	85 c0                	test   %eax,%eax
80103b24:	75 d8                	jne    80103afe <growproc+0x4e>
      return -1;
80103b26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103b2b:	c9                   	leave  
80103b2c:	c3                   	ret    
80103b2d:	8d 76 00             	lea    0x0(%esi),%esi

80103b30 <fork>:
{
80103b30:	55                   	push   %ebp
80103b31:	89 e5                	mov    %esp,%ebp
80103b33:	57                   	push   %edi
80103b34:	56                   	push   %esi
80103b35:	53                   	push   %ebx
80103b36:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80103b39:	68 e0 28 11 80       	push   $0x801128e0
80103b3e:	e8 bd 10 00 00       	call   80104c00 <acquire>
  if((np = allocproc()) == 0){
80103b43:	e8 98 fc ff ff       	call   801037e0 <allocproc>
80103b48:	83 c4 10             	add    $0x10,%esp
80103b4b:	85 c0                	test   %eax,%eax
80103b4d:	0f 84 39 01 00 00    	je     80103c8c <fork+0x15c>
  if (add_son(proc, np))
80103b53:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  if(parent->numofchild >= MAXSON){
80103b5a:	8b 8a 98 00 00 00    	mov    0x98(%edx),%ecx
80103b60:	83 f9 1f             	cmp    $0x1f,%ecx
80103b63:	0f 8f 00 01 00 00    	jg     80103c69 <fork+0x139>
80103b69:	89 c3                	mov    %eax,%ebx
  for (int i = 0; i < MAXSON; ++i){
80103b6b:	31 c0                	xor    %eax,%eax
80103b6d:	eb 09                	jmp    80103b78 <fork+0x48>
80103b6f:	90                   	nop
80103b70:	83 c0 01             	add    $0x1,%eax
80103b73:	83 f8 20             	cmp    $0x20,%eax
80103b76:	74 15                	je     80103b8d <fork+0x5d>
    if (parent->son[i] == 0){
80103b78:	8b 74 82 18          	mov    0x18(%edx,%eax,4),%esi
80103b7c:	85 f6                	test   %esi,%esi
80103b7e:	75 f0                	jne    80103b70 <fork+0x40>
      parent->numofchild++;
80103b80:	83 c1 01             	add    $0x1,%ecx
      parent->son[i] = son;
80103b83:	89 5c 82 18          	mov    %ebx,0x18(%edx,%eax,4)
      parent->numofchild++;
80103b87:	89 8a 98 00 00 00    	mov    %ecx,0x98(%edx)
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80103b8d:	83 ec 08             	sub    $0x8,%esp
80103b90:	ff 32                	pushl  (%edx)
80103b92:	ff 72 04             	pushl  0x4(%edx)
80103b95:	e8 b6 3d 00 00       	call   80107950 <copyuvm>
80103b9a:	83 c4 10             	add    $0x10,%esp
80103b9d:	85 c0                	test   %eax,%eax
80103b9f:	89 43 04             	mov    %eax,0x4(%ebx)
80103ba2:	0f 84 fb 00 00 00    	je     80103ca3 <fork+0x173>
  np->sz = proc->sz;
80103ba8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  *np->tf = *proc->tf;
80103bae:	8b bb 9c 00 00 00    	mov    0x9c(%ebx),%edi
80103bb4:	b9 13 00 00 00       	mov    $0x13,%ecx
  np->sz = proc->sz;
80103bb9:	8b 00                	mov    (%eax),%eax
80103bbb:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
80103bbd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103bc3:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
80103bc6:	8b b0 9c 00 00 00    	mov    0x9c(%eax),%esi
80103bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103bce:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103bd0:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
80103bd6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103bdd:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
80103be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->ofile[i])
80103be8:	8b 84 b2 ac 00 00 00 	mov    0xac(%edx,%esi,4),%eax
80103bef:	85 c0                	test   %eax,%eax
80103bf1:	74 1a                	je     80103c0d <fork+0xdd>
      np->ofile[i] = filedup(proc->ofile[i]);
80103bf3:	83 ec 0c             	sub    $0xc,%esp
80103bf6:	50                   	push   %eax
80103bf7:	e8 d4 d1 ff ff       	call   80100dd0 <filedup>
80103bfc:	89 84 b3 ac 00 00 00 	mov    %eax,0xac(%ebx,%esi,4)
80103c03:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103c0a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
80103c0d:	83 c6 01             	add    $0x1,%esi
80103c10:	83 fe 10             	cmp    $0x10,%esi
80103c13:	75 d3                	jne    80103be8 <fork+0xb8>
  np->cwd = idup(proc->cwd);
80103c15:	83 ec 0c             	sub    $0xc,%esp
80103c18:	ff b2 ec 00 00 00    	pushl  0xec(%edx)
80103c1e:	e8 cd d9 ff ff       	call   801015f0 <idup>
80103c23:	89 83 ec 00 00 00    	mov    %eax,0xec(%ebx)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80103c29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103c2f:	83 c4 0c             	add    $0xc,%esp
80103c32:	6a 10                	push   $0x10
80103c34:	05 f0 00 00 00       	add    $0xf0,%eax
80103c39:	50                   	push   %eax
80103c3a:	8d 83 f0 00 00 00    	lea    0xf0(%ebx),%eax
80103c40:	50                   	push   %eax
80103c41:	e8 aa 13 00 00       	call   80104ff0 <safestrcpy>
  np->state = RUNNABLE;
80103c46:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  pid = np->pid;
80103c4d:	8b 73 10             	mov    0x10(%ebx),%esi
  release(&ptable.lock);
80103c50:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103c57:	e8 64 11 00 00       	call   80104dc0 <release>
  return pid;
80103c5c:	83 c4 10             	add    $0x10,%esp
}
80103c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c62:	89 f0                	mov    %esi,%eax
80103c64:	5b                   	pop    %ebx
80103c65:	5e                   	pop    %esi
80103c66:	5f                   	pop    %edi
80103c67:	5d                   	pop    %ebp
80103c68:	c3                   	ret    
    cprintf("fork: the number of sons is too much\n");
80103c69:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80103c6c:	be ff ff ff ff       	mov    $0xffffffff,%esi
    cprintf("fork: the number of sons is too much\n");
80103c71:	68 8c 82 10 80       	push   $0x8010828c
80103c76:	e8 c5 c9 ff ff       	call   80100640 <cprintf>
    release(&ptable.lock);
80103c7b:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103c82:	e8 39 11 00 00       	call   80104dc0 <release>
    return -1;
80103c87:	83 c4 10             	add    $0x10,%esp
80103c8a:	eb d3                	jmp    80103c5f <fork+0x12f>
    release(&ptable.lock);
80103c8c:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80103c8f:	be ff ff ff ff       	mov    $0xffffffff,%esi
    release(&ptable.lock);
80103c94:	68 e0 28 11 80       	push   $0x801128e0
80103c99:	e8 22 11 00 00       	call   80104dc0 <release>
    return -1;
80103c9e:	83 c4 10             	add    $0x10,%esp
80103ca1:	eb bc                	jmp    80103c5f <fork+0x12f>
    kfree(np->kstack);
80103ca3:	83 ec 0c             	sub    $0xc,%esp
80103ca6:	ff 73 08             	pushl  0x8(%ebx)
    return -1;
80103ca9:	be ff ff ff ff       	mov    $0xffffffff,%esi
    kfree(np->kstack);
80103cae:	e8 6d e6 ff ff       	call   80102320 <kfree>
    np->kstack = 0;
80103cb3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103cba:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    release(&ptable.lock);
80103cc1:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103cc8:	e8 f3 10 00 00       	call   80104dc0 <release>
    return -1;
80103ccd:	83 c4 10             	add    $0x10,%esp
80103cd0:	eb 8d                	jmp    80103c5f <fork+0x12f>
80103cd2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103ce0 <scheduler>:
{
80103ce0:	55                   	push   %ebp
80103ce1:	ba 01 00 00 00       	mov    $0x1,%edx
80103ce6:	89 e5                	mov    %esp,%ebp
80103ce8:	57                   	push   %edi
80103ce9:	56                   	push   %esi
80103cea:	53                   	push   %ebx
80103ceb:	83 ec 1c             	sub    $0x1c,%esp
80103cee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  asm volatile("sti");
80103cf1:	fb                   	sti    
    acquire(&ptable.lock);
80103cf2:	83 ec 0c             	sub    $0xc,%esp
    for (prio = 0; prio < 20; prio++)
80103cf5:	31 ff                	xor    %edi,%edi
    acquire(&ptable.lock);
80103cf7:	68 e0 28 11 80       	push   $0x801128e0
80103cfc:	e8 ff 0e 00 00       	call   80104c00 <acquire>
80103d01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103d04:	83 c4 10             	add    $0x10,%esp
80103d07:	89 f6                	mov    %esi,%esi
80103d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      for (proc_num = 0; proc_num < NPROC; proc_num++)
80103d10:	31 c0                	xor    %eax,%eax
80103d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        p = ptable.proc + ((last_proc_num + 1 + proc_num) % NPROC);
80103d18:	8d 34 02             	lea    (%edx,%eax,1),%esi
80103d1b:	83 e6 3f             	and    $0x3f,%esi
80103d1e:	69 de 0c 02 00 00    	imul   $0x20c,%esi,%ebx
80103d24:	81 c3 14 29 11 80    	add    $0x80112914,%ebx
        if (p->state != RUNNABLE)
80103d2a:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103d2e:	75 60                	jne    80103d90 <scheduler+0xb0>
        if (p->priority != prio)
80103d30:	39 bb 04 02 00 00    	cmp    %edi,0x204(%ebx)
80103d36:	75 58                	jne    80103d90 <scheduler+0xb0>
        switchuvm(p);
80103d38:	83 ec 0c             	sub    $0xc,%esp
80103d3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        proc = p;
80103d3e:	65 89 1d 04 00 00 00 	mov    %ebx,%gs:0x4
        switchuvm(p);
80103d45:	53                   	push   %ebx
80103d46:	e8 05 37 00 00       	call   80107450 <switchuvm>
        p->cpuID = cpuID;
80103d4b:	8b 45 08             	mov    0x8(%ebp),%eax
        p->state = RUNNING;
80103d4e:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
        p->cpuID = cpuID;
80103d55:	89 83 08 02 00 00    	mov    %eax,0x208(%ebx)
        swtch(&cpu->scheduler, p->context);
80103d5b:	58                   	pop    %eax
80103d5c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d62:	5a                   	pop    %edx
80103d63:	ff b3 a0 00 00 00    	pushl  0xa0(%ebx)
80103d69:	8d 50 04             	lea    0x4(%eax),%edx
80103d6c:	52                   	push   %edx
80103d6d:	e8 d9 12 00 00       	call   8010504b <swtch>
        switchkvm();
80103d72:	e8 b9 36 00 00       	call   80107430 <switchkvm>
80103d77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d7a:	8d 56 01             	lea    0x1(%esi),%edx
        proc = 0;
80103d7d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80103d84:	00 00 00 00 
80103d88:	83 c4 10             	add    $0x10,%esp
80103d8b:	90                   	nop
80103d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      for (proc_num = 0; proc_num < NPROC; proc_num++)
80103d90:	83 c0 01             	add    $0x1,%eax
80103d93:	83 f8 40             	cmp    $0x40,%eax
80103d96:	75 80                	jne    80103d18 <scheduler+0x38>
    for (prio = 0; prio < 20; prio++)
80103d98:	83 c7 01             	add    $0x1,%edi
80103d9b:	83 ff 14             	cmp    $0x14,%edi
80103d9e:	0f 85 6c ff ff ff    	jne    80103d10 <scheduler+0x30>
    release(&ptable.lock);
80103da4:	83 ec 0c             	sub    $0xc,%esp
80103da7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80103daa:	68 e0 28 11 80       	push   $0x801128e0
80103daf:	e8 0c 10 00 00       	call   80104dc0 <release>
    sti();
80103db4:	83 c4 10             	add    $0x10,%esp
80103db7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dba:	e9 2f ff ff ff       	jmp    80103cee <scheduler+0xe>
80103dbf:	90                   	nop

80103dc0 <sched>:
{
80103dc0:	55                   	push   %ebp
80103dc1:	89 e5                	mov    %esp,%ebp
80103dc3:	53                   	push   %ebx
80103dc4:	83 ec 10             	sub    $0x10,%esp
  if(!holding(&ptable.lock))
80103dc7:	68 e0 28 11 80       	push   $0x801128e0
80103dcc:	e8 3f 0f 00 00       	call   80104d10 <holding>
80103dd1:	83 c4 10             	add    $0x10,%esp
80103dd4:	85 c0                	test   %eax,%eax
80103dd6:	74 4e                	je     80103e26 <sched+0x66>
  if(cpu->ncli != 1)
80103dd8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80103ddf:	83 ba ac 00 00 00 01 	cmpl   $0x1,0xac(%edx)
80103de6:	75 65                	jne    80103e4d <sched+0x8d>
  if(proc->state == RUNNING)
80103de8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103dee:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80103df2:	74 4c                	je     80103e40 <sched+0x80>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103df4:	9c                   	pushf  
80103df5:	59                   	pop    %ecx
  if(readeflags()&FL_IF)
80103df6:	80 e5 02             	and    $0x2,%ch
80103df9:	75 38                	jne    80103e33 <sched+0x73>
  swtch(&proc->context, cpu->scheduler);
80103dfb:	83 ec 08             	sub    $0x8,%esp
80103dfe:	05 a0 00 00 00       	add    $0xa0,%eax
  intena = cpu->intena;
80103e03:	8b 9a b0 00 00 00    	mov    0xb0(%edx),%ebx
  swtch(&proc->context, cpu->scheduler);
80103e09:	ff 72 04             	pushl  0x4(%edx)
80103e0c:	50                   	push   %eax
80103e0d:	e8 39 12 00 00       	call   8010504b <swtch>
  cpu->intena = intena;
80103e12:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
}
80103e18:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80103e1b:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
80103e21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e24:	c9                   	leave  
80103e25:	c3                   	ret    
    panic("sched ptable.lock");
80103e26:	83 ec 0c             	sub    $0xc,%esp
80103e29:	68 0c 81 10 80       	push   $0x8010810c
80103e2e:	e8 3d c5 ff ff       	call   80100370 <panic>
    panic("sched interruptible");
80103e33:	83 ec 0c             	sub    $0xc,%esp
80103e36:	68 38 81 10 80       	push   $0x80108138
80103e3b:	e8 30 c5 ff ff       	call   80100370 <panic>
    panic("sched running");
80103e40:	83 ec 0c             	sub    $0xc,%esp
80103e43:	68 2a 81 10 80       	push   $0x8010812a
80103e48:	e8 23 c5 ff ff       	call   80100370 <panic>
    panic("sched locks");
80103e4d:	83 ec 0c             	sub    $0xc,%esp
80103e50:	68 1e 81 10 80       	push   $0x8010811e
80103e55:	e8 16 c5 ff ff       	call   80100370 <panic>
80103e5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103e60 <exit>:
{
80103e60:	55                   	push   %ebp
  if(proc == initproc)
80103e61:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
{
80103e68:	89 e5                	mov    %esp,%ebp
80103e6a:	56                   	push   %esi
80103e6b:	53                   	push   %ebx
80103e6c:	31 db                	xor    %ebx,%ebx
  if(proc == initproc)
80103e6e:	3b 0d bc b5 10 80    	cmp    0x8010b5bc,%ecx
80103e74:	0f 84 4f 02 00 00    	je     801040c9 <exit+0x269>
80103e7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(proc->ofile[fd]){
80103e80:	8d 73 28             	lea    0x28(%ebx),%esi
80103e83:	8b 44 b1 0c          	mov    0xc(%ecx,%esi,4),%eax
80103e87:	85 c0                	test   %eax,%eax
80103e89:	74 1b                	je     80103ea6 <exit+0x46>
      fileclose(proc->ofile[fd]);
80103e8b:	83 ec 0c             	sub    $0xc,%esp
80103e8e:	50                   	push   %eax
80103e8f:	e8 8c cf ff ff       	call   80100e20 <fileclose>
      proc->ofile[fd] = 0;
80103e94:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80103e9b:	83 c4 10             	add    $0x10,%esp
80103e9e:	c7 44 b1 0c 00 00 00 	movl   $0x0,0xc(%ecx,%esi,4)
80103ea5:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103ea6:	83 c3 01             	add    $0x1,%ebx
80103ea9:	83 fb 10             	cmp    $0x10,%ebx
80103eac:	75 d2                	jne    80103e80 <exit+0x20>
  begin_op();
80103eae:	e8 8d ed ff ff       	call   80102c40 <begin_op>
  iput(proc->cwd);
80103eb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103eb9:	83 ec 0c             	sub    $0xc,%esp
80103ebc:	ff b0 ec 00 00 00    	pushl  0xec(%eax)
80103ec2:	e8 c9 d8 ff ff       	call   80101790 <iput>
  end_op();
80103ec7:	e8 e4 ed ff ff       	call   80102cb0 <end_op>
  proc->cwd = 0;
80103ecc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ed2:	c7 80 ec 00 00 00 00 	movl   $0x0,0xec(%eax)
80103ed9:	00 00 00 
  acquire(&ptable.lock);
80103edc:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80103ee3:	e8 18 0d 00 00       	call   80104c00 <acquire>
  if(proc->parent == 0 && proc -> pthread!=0){
80103ee8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80103eef:	83 c4 10             	add    $0x10,%esp
80103ef2:	31 c0                	xor    %eax,%eax
80103ef4:	8b 51 14             	mov    0x14(%ecx),%edx
80103ef7:	85 d2                	test   %edx,%edx
80103ef9:	75 11                	jne    80103f0c <exit+0xac>
80103efb:	e9 1f 01 00 00       	jmp    8010401f <exit+0x1bf>
  for(int i=0;i<MAXSON;++i){
80103f00:	83 c0 01             	add    $0x1,%eax
80103f03:	83 f8 20             	cmp    $0x20,%eax
80103f06:	0f 84 95 01 00 00    	je     801040a1 <exit+0x241>
    if(parent->son[i] == son){
80103f0c:	3b 4c 82 18          	cmp    0x18(%edx,%eax,4),%ecx
80103f10:	75 ee                	jne    80103f00 <exit+0xa0>
      parent->son[i] = 0;
80103f12:	c7 44 82 18 00 00 00 	movl   $0x0,0x18(%edx,%eax,4)
80103f19:	00 
      parent->numofchild--;
80103f1a:	83 aa 98 00 00 00 01 	subl   $0x1,0x98(%edx)
    wakeup1(proc->parent);
80103f21:	8b 51 14             	mov    0x14(%ecx),%edx
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f24:	b8 14 29 11 80       	mov    $0x80112914,%eax
80103f29:	eb 11                	jmp    80103f3c <exit+0xdc>
80103f2b:	90                   	nop
80103f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103f30:	05 0c 02 00 00       	add    $0x20c,%eax
80103f35:	3d 14 ac 11 80       	cmp    $0x8011ac14,%eax
80103f3a:	73 21                	jae    80103f5d <exit+0xfd>
    if(p->state == SLEEPING && p->chan == chan)
80103f3c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103f40:	75 ee                	jne    80103f30 <exit+0xd0>
80103f42:	3b 90 a4 00 00 00    	cmp    0xa4(%eax),%edx
80103f48:	75 e6                	jne    80103f30 <exit+0xd0>
      p->state = RUNNABLE;
80103f4a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f51:	05 0c 02 00 00       	add    $0x20c,%eax
80103f56:	3d 14 ac 11 80       	cmp    $0x8011ac14,%eax
80103f5b:	72 df                	jb     80103f3c <exit+0xdc>
80103f5d:	bb 14 29 11 80       	mov    $0x80112914,%ebx
80103f62:	eb 16                	jmp    80103f7a <exit+0x11a>
80103f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f68:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
80103f6e:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
80103f74:	0f 83 8c 00 00 00    	jae    80104006 <exit+0x1a6>
    if(p->parent == proc){
80103f7a:	39 4b 14             	cmp    %ecx,0x14(%ebx)
80103f7d:	75 e9                	jne    80103f68 <exit+0x108>
      p->parent = initproc;
80103f7f:	8b 15 bc b5 10 80    	mov    0x8010b5bc,%edx
  for (int i = 0; i < MAXSON; ++i){
80103f85:	31 c0                	xor    %eax,%eax
      p->parent = initproc;
80103f87:	89 53 14             	mov    %edx,0x14(%ebx)
  if(parent->numofchild >= MAXSON){
80103f8a:	8b b2 98 00 00 00    	mov    0x98(%edx),%esi
80103f90:	83 fe 1f             	cmp    $0x1f,%esi
80103f93:	7e 5b                	jle    80103ff0 <exit+0x190>
        cprintf("initproc: the number of sons is too much\n");
80103f95:	83 ec 0c             	sub    $0xc,%esp
80103f98:	68 e0 82 10 80       	push   $0x801082e0
80103f9d:	e8 9e c6 ff ff       	call   80100640 <cprintf>
80103fa2:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80103fa9:	83 c4 10             	add    $0x10,%esp
      if(p->state == ZOMBIE)
80103fac:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103fb0:	75 b6                	jne    80103f68 <exit+0x108>
        wakeup1(initproc);
80103fb2:	8b 15 bc b5 10 80    	mov    0x8010b5bc,%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fb8:	b8 14 29 11 80       	mov    $0x80112914,%eax
80103fbd:	eb 0d                	jmp    80103fcc <exit+0x16c>
80103fbf:	90                   	nop
80103fc0:	05 0c 02 00 00       	add    $0x20c,%eax
80103fc5:	3d 14 ac 11 80       	cmp    $0x8011ac14,%eax
80103fca:	73 9c                	jae    80103f68 <exit+0x108>
    if(p->state == SLEEPING && p->chan == chan)
80103fcc:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103fd0:	75 ee                	jne    80103fc0 <exit+0x160>
80103fd2:	3b 90 a4 00 00 00    	cmp    0xa4(%eax),%edx
80103fd8:	75 e6                	jne    80103fc0 <exit+0x160>
      p->state = RUNNABLE;
80103fda:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103fe1:	eb dd                	jmp    80103fc0 <exit+0x160>
80103fe3:	90                   	nop
80103fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for (int i = 0; i < MAXSON; ++i){
80103fe8:	83 c0 01             	add    $0x1,%eax
80103feb:	83 f8 20             	cmp    $0x20,%eax
80103fee:	74 bc                	je     80103fac <exit+0x14c>
    if (parent->son[i] == 0){
80103ff0:	83 7c 82 18 00       	cmpl   $0x0,0x18(%edx,%eax,4)
80103ff5:	75 f1                	jne    80103fe8 <exit+0x188>
      parent->numofchild++;
80103ff7:	83 c6 01             	add    $0x1,%esi
      parent->son[i] = son;
80103ffa:	89 5c 82 18          	mov    %ebx,0x18(%edx,%eax,4)
      parent->numofchild++;
80103ffe:	89 b2 98 00 00 00    	mov    %esi,0x98(%edx)
80104004:	eb a6                	jmp    80103fac <exit+0x14c>
  proc->state = ZOMBIE;
80104006:	c7 41 0c 05 00 00 00 	movl   $0x5,0xc(%ecx)
  sched();
8010400d:	e8 ae fd ff ff       	call   80103dc0 <sched>
  panic("zombie exit");
80104012:	83 ec 0c             	sub    $0xc,%esp
80104015:	68 59 81 10 80       	push   $0x80108159
8010401a:	e8 51 c3 ff ff       	call   80100370 <panic>
  if(proc->parent == 0 && proc -> pthread!=0){
8010401f:	8b 99 78 01 00 00    	mov    0x178(%ecx),%ebx
80104025:	85 db                	test   %ebx,%ebx
80104027:	0f 84 df fe ff ff    	je     80103f0c <exit+0xac>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010402d:	b8 14 29 11 80       	mov    $0x80112914,%eax
80104032:	eb 10                	jmp    80104044 <exit+0x1e4>
80104034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104038:	05 0c 02 00 00       	add    $0x20c,%eax
8010403d:	3d 14 ac 11 80       	cmp    $0x8011ac14,%eax
80104042:	73 21                	jae    80104065 <exit+0x205>
    if(p->state == SLEEPING && p->chan == chan)
80104044:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104048:	75 ee                	jne    80104038 <exit+0x1d8>
8010404a:	3b 98 a4 00 00 00    	cmp    0xa4(%eax),%ebx
80104050:	75 e6                	jne    80104038 <exit+0x1d8>
      p->state = RUNNABLE;
80104052:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104059:	05 0c 02 00 00       	add    $0x20c,%eax
8010405e:	3d 14 ac 11 80       	cmp    $0x8011ac14,%eax
80104063:	72 df                	jb     80104044 <exit+0x1e4>
    proc->pthread->numofthreads--;
80104065:	8b 81 78 01 00 00    	mov    0x178(%ecx),%eax
8010406b:	83 a8 fc 01 00 00 01 	subl   $0x1,0x1fc(%eax)
    for(int i = 0; i<MAXTHREADS; ++i){
80104072:	31 c0                	xor    %eax,%eax
      if(proc->pthread->cthread[i] == proc){
80104074:	8b 91 78 01 00 00    	mov    0x178(%ecx),%edx
8010407a:	eb 0c                	jmp    80104088 <exit+0x228>
    for(int i = 0; i<MAXTHREADS; ++i){
8010407c:	83 c0 01             	add    $0x1,%eax
8010407f:	83 f8 20             	cmp    $0x20,%eax
80104082:	0f 84 d5 fe ff ff    	je     80103f5d <exit+0xfd>
      if(proc->pthread->cthread[i] == proc){
80104088:	3b 8c 82 7c 01 00 00 	cmp    0x17c(%edx,%eax,4),%ecx
8010408f:	75 eb                	jne    8010407c <exit+0x21c>
        proc->pthread->cthread[i] = 0;
80104091:	c7 84 82 7c 01 00 00 	movl   $0x0,0x17c(%edx,%eax,4)
80104098:	00 00 00 00 
        break;
8010409c:	e9 bc fe ff ff       	jmp    80103f5d <exit+0xfd>
      cprintf("exit: son(%s) doesn't exist in parent(%s)\n", proc->name, proc->parent->name);
801040a1:	81 c1 f0 00 00 00    	add    $0xf0,%ecx
801040a7:	81 c2 f0 00 00 00    	add    $0xf0,%edx
801040ad:	50                   	push   %eax
801040ae:	52                   	push   %edx
801040af:	51                   	push   %ecx
801040b0:	68 b4 82 10 80       	push   $0x801082b4
801040b5:	e8 86 c5 ff ff       	call   80100640 <cprintf>
801040ba:	83 c4 10             	add    $0x10,%esp
801040bd:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801040c4:	e9 58 fe ff ff       	jmp    80103f21 <exit+0xc1>
    panic("init exiting");
801040c9:	83 ec 0c             	sub    $0xc,%esp
801040cc:	68 4c 81 10 80       	push   $0x8010814c
801040d1:	e8 9a c2 ff ff       	call   80100370 <panic>
801040d6:	8d 76 00             	lea    0x0(%esi),%esi
801040d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801040e0 <yield>:
{
801040e0:	55                   	push   %ebp
801040e1:	89 e5                	mov    %esp,%ebp
801040e3:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801040e6:	68 e0 28 11 80       	push   $0x801128e0
801040eb:	e8 10 0b 00 00       	call   80104c00 <acquire>
  proc->state = RUNNABLE;
801040f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040f6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801040fd:	e8 be fc ff ff       	call   80103dc0 <sched>
  release(&ptable.lock);
80104102:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
80104109:	e8 b2 0c 00 00       	call   80104dc0 <release>
}
8010410e:	83 c4 10             	add    $0x10,%esp
80104111:	c9                   	leave  
80104112:	c3                   	ret    
80104113:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104119:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104120 <sleep>:
  if(proc == 0)
80104120:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80104126:	55                   	push   %ebp
80104127:	89 e5                	mov    %esp,%ebp
80104129:	56                   	push   %esi
8010412a:	53                   	push   %ebx
  if(proc == 0)
8010412b:	85 c0                	test   %eax,%eax
{
8010412d:	8b 75 08             	mov    0x8(%ebp),%esi
80104130:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
80104133:	0f 84 a5 00 00 00    	je     801041de <sleep+0xbe>
  if(lk == 0)
80104139:	85 db                	test   %ebx,%ebx
8010413b:	0f 84 90 00 00 00    	je     801041d1 <sleep+0xb1>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104141:	81 fb e0 28 11 80    	cmp    $0x801128e0,%ebx
80104147:	74 5f                	je     801041a8 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104149:	83 ec 0c             	sub    $0xc,%esp
8010414c:	68 e0 28 11 80       	push   $0x801128e0
80104151:	e8 aa 0a 00 00       	call   80104c00 <acquire>
    release(lk);
80104156:	89 1c 24             	mov    %ebx,(%esp)
80104159:	e8 62 0c 00 00       	call   80104dc0 <release>
  proc->chan = chan;
8010415e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104164:	89 b0 a4 00 00 00    	mov    %esi,0xa4(%eax)
  proc->state = SLEEPING;
8010416a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104171:	e8 4a fc ff ff       	call   80103dc0 <sched>
  proc->chan = 0;
80104176:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010417c:	c7 80 a4 00 00 00 00 	movl   $0x0,0xa4(%eax)
80104183:	00 00 00 
    release(&ptable.lock);
80104186:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
8010418d:	e8 2e 0c 00 00       	call   80104dc0 <release>
    acquire(lk);
80104192:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104195:	83 c4 10             	add    $0x10,%esp
}
80104198:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010419b:	5b                   	pop    %ebx
8010419c:	5e                   	pop    %esi
8010419d:	5d                   	pop    %ebp
    acquire(lk);
8010419e:	e9 5d 0a 00 00       	jmp    80104c00 <acquire>
801041a3:	90                   	nop
801041a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  proc->chan = chan;
801041a8:	89 b0 a4 00 00 00    	mov    %esi,0xa4(%eax)
  proc->state = SLEEPING;
801041ae:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801041b5:	e8 06 fc ff ff       	call   80103dc0 <sched>
  proc->chan = 0;
801041ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041c0:	c7 80 a4 00 00 00 00 	movl   $0x0,0xa4(%eax)
801041c7:	00 00 00 
}
801041ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041cd:	5b                   	pop    %ebx
801041ce:	5e                   	pop    %esi
801041cf:	5d                   	pop    %ebp
801041d0:	c3                   	ret    
    panic("sleep without lk");
801041d1:	83 ec 0c             	sub    $0xc,%esp
801041d4:	68 6b 81 10 80       	push   $0x8010816b
801041d9:	e8 92 c1 ff ff       	call   80100370 <panic>
    panic("sleep");
801041de:	83 ec 0c             	sub    $0xc,%esp
801041e1:	68 65 81 10 80       	push   $0x80108165
801041e6:	e8 85 c1 ff ff       	call   80100370 <panic>
801041eb:	90                   	nop
801041ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801041f0 <wait>:
{
801041f0:	55                   	push   %ebp
801041f1:	89 e5                	mov    %esp,%ebp
801041f3:	56                   	push   %esi
801041f4:	53                   	push   %ebx
  acquire(&ptable.lock);
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	68 e0 28 11 80       	push   $0x801128e0
801041fd:	e8 fe 09 00 00       	call   80104c00 <acquire>
80104202:	83 c4 10             	add    $0x10,%esp
      if(p->parent != proc)
80104205:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    havekids = 0;
8010420b:	31 d2                	xor    %edx,%edx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010420d:	bb 14 29 11 80       	mov    $0x80112914,%ebx
80104212:	eb 12                	jmp    80104226 <wait+0x36>
80104214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104218:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
8010421e:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
80104224:	73 1e                	jae    80104244 <wait+0x54>
      if(p->parent != proc)
80104226:	39 43 14             	cmp    %eax,0x14(%ebx)
80104229:	75 ed                	jne    80104218 <wait+0x28>
      if(p->state == ZOMBIE){
8010422b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010422f:	74 3f                	je     80104270 <wait+0x80>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104231:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
      havekids = 1;
80104237:	ba 01 00 00 00       	mov    $0x1,%edx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010423c:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
80104242:	72 e2                	jb     80104226 <wait+0x36>
    if(!havekids || proc->killed){
80104244:	85 d2                	test   %edx,%edx
80104246:	0f 84 aa 00 00 00    	je     801042f6 <wait+0x106>
8010424c:	8b 90 a8 00 00 00    	mov    0xa8(%eax),%edx
80104252:	85 d2                	test   %edx,%edx
80104254:	0f 85 9c 00 00 00    	jne    801042f6 <wait+0x106>
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010425a:	83 ec 08             	sub    $0x8,%esp
8010425d:	68 e0 28 11 80       	push   $0x801128e0
80104262:	50                   	push   %eax
80104263:	e8 b8 fe ff ff       	call   80104120 <sleep>
    havekids = 0;
80104268:	83 c4 10             	add    $0x10,%esp
8010426b:	eb 98                	jmp    80104205 <wait+0x15>
8010426d:	8d 76 00             	lea    0x0(%esi),%esi
        kfree(p->kstack);
80104270:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
80104273:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104276:	ff 73 08             	pushl  0x8(%ebx)
80104279:	e8 a2 e0 ff ff       	call   80102320 <kfree>
        p->kstack = 0;
8010427e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80104285:	59                   	pop    %ecx
80104286:	ff 73 04             	pushl  0x4(%ebx)
80104289:	e8 12 36 00 00       	call   801078a0 <freevm>
        p->pid = 0;
8010428e:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80104295:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
8010429c:	8d 43 18             	lea    0x18(%ebx),%eax
        p->name[0] = 0;
8010429f:	c6 83 f0 00 00 00 00 	movb   $0x0,0xf0(%ebx)
        p->killed = 0;
801042a6:	c7 83 a8 00 00 00 00 	movl   $0x0,0xa8(%ebx)
801042ad:	00 00 00 
801042b0:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801042b3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->numofchild = 0;
801042ba:	c7 83 98 00 00 00 00 	movl   $0x0,0x98(%ebx)
801042c1:	00 00 00 
801042c4:	81 c3 98 00 00 00    	add    $0x98,%ebx
801042ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
          p->son[i] = 0;
801042d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801042d6:	83 c0 04             	add    $0x4,%eax
        for(int i = 0; i < MAXSON ; ++i){
801042d9:	39 d8                	cmp    %ebx,%eax
801042db:	75 f3                	jne    801042d0 <wait+0xe0>
        release(&ptable.lock);
801042dd:	83 ec 0c             	sub    $0xc,%esp
801042e0:	68 e0 28 11 80       	push   $0x801128e0
801042e5:	e8 d6 0a 00 00       	call   80104dc0 <release>
        return pid;
801042ea:	83 c4 10             	add    $0x10,%esp
}
801042ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
801042f0:	89 f0                	mov    %esi,%eax
801042f2:	5b                   	pop    %ebx
801042f3:	5e                   	pop    %esi
801042f4:	5d                   	pop    %ebp
801042f5:	c3                   	ret    
      release(&ptable.lock);
801042f6:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801042f9:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
801042fe:	68 e0 28 11 80       	push   $0x801128e0
80104303:	e8 b8 0a 00 00       	call   80104dc0 <release>
      return -1;
80104308:	83 c4 10             	add    $0x10,%esp
8010430b:	eb e0                	jmp    801042ed <wait+0xfd>
8010430d:	8d 76 00             	lea    0x0(%esi),%esi

80104310 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104310:	55                   	push   %ebp
80104311:	89 e5                	mov    %esp,%ebp
80104313:	53                   	push   %ebx
80104314:	83 ec 10             	sub    $0x10,%esp
80104317:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010431a:	68 e0 28 11 80       	push   $0x801128e0
8010431f:	e8 dc 08 00 00       	call   80104c00 <acquire>
80104324:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104327:	b8 14 29 11 80       	mov    $0x80112914,%eax
8010432c:	eb 0e                	jmp    8010433c <wakeup+0x2c>
8010432e:	66 90                	xchg   %ax,%ax
80104330:	05 0c 02 00 00       	add    $0x20c,%eax
80104335:	3d 14 ac 11 80       	cmp    $0x8011ac14,%eax
8010433a:	73 21                	jae    8010435d <wakeup+0x4d>
    if(p->state == SLEEPING && p->chan == chan)
8010433c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104340:	75 ee                	jne    80104330 <wakeup+0x20>
80104342:	3b 98 a4 00 00 00    	cmp    0xa4(%eax),%ebx
80104348:	75 e6                	jne    80104330 <wakeup+0x20>
      p->state = RUNNABLE;
8010434a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104351:	05 0c 02 00 00       	add    $0x20c,%eax
80104356:	3d 14 ac 11 80       	cmp    $0x8011ac14,%eax
8010435b:	72 df                	jb     8010433c <wakeup+0x2c>
  wakeup1(chan);
  release(&ptable.lock);
8010435d:	c7 45 08 e0 28 11 80 	movl   $0x801128e0,0x8(%ebp)
}
80104364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104367:	c9                   	leave  
  release(&ptable.lock);
80104368:	e9 53 0a 00 00       	jmp    80104dc0 <release>
8010436d:	8d 76 00             	lea    0x0(%esi),%esi

80104370 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104370:	55                   	push   %ebp
80104371:	89 e5                	mov    %esp,%ebp
80104373:	53                   	push   %ebx
80104374:	83 ec 10             	sub    $0x10,%esp
80104377:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010437a:	68 e0 28 11 80       	push   $0x801128e0
8010437f:	e8 7c 08 00 00       	call   80104c00 <acquire>
80104384:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104387:	b8 14 29 11 80       	mov    $0x80112914,%eax
8010438c:	eb 0e                	jmp    8010439c <kill+0x2c>
8010438e:	66 90                	xchg   %ax,%ax
80104390:	05 0c 02 00 00       	add    $0x20c,%eax
80104395:	3d 14 ac 11 80       	cmp    $0x8011ac14,%eax
8010439a:	73 34                	jae    801043d0 <kill+0x60>
    if(p->pid == pid){
8010439c:	39 58 10             	cmp    %ebx,0x10(%eax)
8010439f:	75 ef                	jne    80104390 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801043a1:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
801043a5:	c7 80 a8 00 00 00 01 	movl   $0x1,0xa8(%eax)
801043ac:	00 00 00 
      if(p->state == SLEEPING)
801043af:	75 07                	jne    801043b8 <kill+0x48>
        p->state = RUNNABLE;
801043b1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801043b8:	83 ec 0c             	sub    $0xc,%esp
801043bb:	68 e0 28 11 80       	push   $0x801128e0
801043c0:	e8 fb 09 00 00       	call   80104dc0 <release>
      return 0;
801043c5:	83 c4 10             	add    $0x10,%esp
801043c8:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801043ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043cd:	c9                   	leave  
801043ce:	c3                   	ret    
801043cf:	90                   	nop
  release(&ptable.lock);
801043d0:	83 ec 0c             	sub    $0xc,%esp
801043d3:	68 e0 28 11 80       	push   $0x801128e0
801043d8:	e8 e3 09 00 00       	call   80104dc0 <release>
  return -1;
801043dd:	83 c4 10             	add    $0x10,%esp
801043e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801043e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043e8:	c9                   	leave  
801043e9:	c3                   	ret    
801043ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801043f0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801043f0:	55                   	push   %ebp
801043f1:	89 e5                	mov    %esp,%ebp
801043f3:	57                   	push   %edi
801043f4:	56                   	push   %esi
801043f5:	53                   	push   %ebx
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043f6:	bb 14 29 11 80       	mov    $0x80112914,%ebx
{
801043fb:	83 ec 3c             	sub    $0x3c,%esp
801043fe:	66 90                	xchg   %ax,%ax
    if(p->state == UNUSED)
80104400:	8b 43 0c             	mov    0xc(%ebx),%eax
80104403:	85 c0                	test   %eax,%eax
80104405:	0f 84 ab 00 00 00    	je     801044b6 <procdump+0xc6>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010440b:	83 f8 05             	cmp    $0x5,%eax
      state = states[p->state];
    else
      state = "???";
8010440e:	ba 7c 81 10 80       	mov    $0x8010817c,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104413:	77 11                	ja     80104426 <procdump+0x36>
80104415:	8b 14 85 98 83 10 80 	mov    -0x7fef7c68(,%eax,4),%edx
      state = "???";
8010441c:	b8 7c 81 10 80       	mov    $0x8010817c,%eax
80104421:	85 d2                	test   %edx,%edx
80104423:	0f 44 d0             	cmove  %eax,%edx
    cprintf("\npid:%d, state: %s, name: %s, priority = %d, cpuID = %d\n", p->pid, state, p->name, p->priority,p->cpuID);
80104426:	8d 83 f0 00 00 00    	lea    0xf0(%ebx),%eax
8010442c:	83 ec 08             	sub    $0x8,%esp
8010442f:	ff b3 08 02 00 00    	pushl  0x208(%ebx)
80104435:	ff b3 04 02 00 00    	pushl  0x204(%ebx)
8010443b:	50                   	push   %eax
8010443c:	52                   	push   %edx
8010443d:	ff 73 10             	pushl  0x10(%ebx)
80104440:	68 0c 83 10 80       	push   $0x8010830c
80104445:	e8 f6 c1 ff ff       	call   80100640 <cprintf>
    if(p->numofchild){
8010444a:	8b 83 98 00 00 00    	mov    0x98(%ebx),%eax
80104450:	83 c4 20             	add    $0x20,%esp
80104453:	85 c0                	test   %eax,%eax
80104455:	0f 85 d5 00 00 00    	jne    80104530 <procdump+0x140>
          cprintf("%d:%s\t",p->son[i]->pid,p->son[i]->name);
        }
      }
      cprintf("\n");
    }
    if(p->numofthreads){
8010445b:	8b 83 fc 01 00 00    	mov    0x1fc(%ebx),%eax
80104461:	85 c0                	test   %eax,%eax
80104463:	75 6b                	jne    801044d0 <procdump+0xe0>
        }
      }
      cprintf("\n");
    }
    
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
80104465:	8b 83 08 01 00 00    	mov    0x108(%ebx),%eax
8010446b:	85 c0                	test   %eax,%eax
8010446d:	74 2d                	je     8010449c <procdump+0xac>
8010446f:	90                   	nop
      cprintf("start: %d, length: %d\n",p->vm[i].start,p->vm[i].length);
80104470:	8d 04 40             	lea    (%eax,%eax,2),%eax
80104473:	83 ec 04             	sub    $0x4,%esp
80104476:	8d 34 83             	lea    (%ebx,%eax,4),%esi
80104479:	ff b6 04 01 00 00    	pushl  0x104(%esi)
8010447f:	ff b6 00 01 00 00    	pushl  0x100(%esi)
80104485:	68 af 81 10 80       	push   $0x801081af
8010448a:	e8 b1 c1 ff ff       	call   80100640 <cprintf>
    for(int i = p->vm[0].next; i!=0; i=p->vm[i].next){
8010448f:	8b 86 08 01 00 00    	mov    0x108(%esi),%eax
80104495:	83 c4 10             	add    $0x10,%esp
80104498:	85 c0                	test   %eax,%eax
8010449a:	75 d4                	jne    80104470 <procdump+0x80>
    }
    if(p->state == SLEEPING){
8010449c:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801044a0:	0f 84 ea 00 00 00    	je     80104590 <procdump+0x1a0>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801044a6:	83 ec 0c             	sub    $0xc,%esp
801044a9:	68 df 81 10 80       	push   $0x801081df
801044ae:	e8 8d c1 ff ff       	call   80100640 <cprintf>
801044b3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044b6:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
801044bc:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
801044c2:	0f 82 38 ff ff ff    	jb     80104400 <procdump+0x10>
  }
}
801044c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044cb:	5b                   	pop    %ebx
801044cc:	5e                   	pop    %esi
801044cd:	5f                   	pop    %edi
801044ce:	5d                   	pop    %ebp
801044cf:	c3                   	ret    
      cprintf("共%d个子线程: ", p->numofthreads);
801044d0:	83 ec 08             	sub    $0x8,%esp
801044d3:	8d b3 7c 01 00 00    	lea    0x17c(%ebx),%esi
801044d9:	8d bb fc 01 00 00    	lea    0x1fc(%ebx),%edi
801044df:	50                   	push   %eax
801044e0:	68 9b 81 10 80       	push   $0x8010819b
801044e5:	e8 56 c1 ff ff       	call   80100640 <cprintf>
801044ea:	83 c4 10             	add    $0x10,%esp
801044ed:	8d 76 00             	lea    0x0(%esi),%esi
        if (p->cthread[i] != 0)
801044f0:	8b 06                	mov    (%esi),%eax
801044f2:	85 c0                	test   %eax,%eax
801044f4:	74 1a                	je     80104510 <procdump+0x120>
          cprintf("%d:%s\t", p->cthread[i]->pid, p->cthread[i]->name);
801044f6:	8d 90 f0 00 00 00    	lea    0xf0(%eax),%edx
801044fc:	83 ec 04             	sub    $0x4,%esp
801044ff:	52                   	push   %edx
80104500:	ff 70 10             	pushl  0x10(%eax)
80104503:	68 94 81 10 80       	push   $0x80108194
80104508:	e8 33 c1 ff ff       	call   80100640 <cprintf>
8010450d:	83 c4 10             	add    $0x10,%esp
80104510:	83 c6 04             	add    $0x4,%esi
      for (i = 0; i < MAXSON; ++i)
80104513:	39 fe                	cmp    %edi,%esi
80104515:	75 d9                	jne    801044f0 <procdump+0x100>
      cprintf("\n");
80104517:	83 ec 0c             	sub    $0xc,%esp
8010451a:	68 df 81 10 80       	push   $0x801081df
8010451f:	e8 1c c1 ff ff       	call   80100640 <cprintf>
80104524:	83 c4 10             	add    $0x10,%esp
80104527:	e9 39 ff ff ff       	jmp    80104465 <procdump+0x75>
8010452c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      cprintf("共%d个子进程: ", p->numofchild);
80104530:	83 ec 08             	sub    $0x8,%esp
80104533:	8d 73 18             	lea    0x18(%ebx),%esi
80104536:	8d bb 98 00 00 00    	lea    0x98(%ebx),%edi
8010453c:	50                   	push   %eax
8010453d:	68 80 81 10 80       	push   $0x80108180
80104542:	e8 f9 c0 ff ff       	call   80100640 <cprintf>
80104547:	83 c4 10             	add    $0x10,%esp
8010454a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        if(p->son[i] != 0){
80104550:	8b 06                	mov    (%esi),%eax
80104552:	85 c0                	test   %eax,%eax
80104554:	74 1a                	je     80104570 <procdump+0x180>
          cprintf("%d:%s\t",p->son[i]->pid,p->son[i]->name);
80104556:	8d 90 f0 00 00 00    	lea    0xf0(%eax),%edx
8010455c:	83 ec 04             	sub    $0x4,%esp
8010455f:	52                   	push   %edx
80104560:	ff 70 10             	pushl  0x10(%eax)
80104563:	68 94 81 10 80       	push   $0x80108194
80104568:	e8 d3 c0 ff ff       	call   80100640 <cprintf>
8010456d:	83 c4 10             	add    $0x10,%esp
80104570:	83 c6 04             	add    $0x4,%esi
      for(i = 0; i < MAXSON; ++i){
80104573:	39 fe                	cmp    %edi,%esi
80104575:	75 d9                	jne    80104550 <procdump+0x160>
      cprintf("\n");
80104577:	83 ec 0c             	sub    $0xc,%esp
8010457a:	68 df 81 10 80       	push   $0x801081df
8010457f:	e8 bc c0 ff ff       	call   80100640 <cprintf>
80104584:	83 c4 10             	add    $0x10,%esp
80104587:	e9 cf fe ff ff       	jmp    8010445b <procdump+0x6b>
8010458c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104590:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104593:	83 ec 08             	sub    $0x8,%esp
80104596:	8d 75 c0             	lea    -0x40(%ebp),%esi
80104599:	50                   	push   %eax
8010459a:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
801045a0:	8b 40 0c             	mov    0xc(%eax),%eax
801045a3:	83 c0 08             	add    $0x8,%eax
801045a6:	50                   	push   %eax
801045a7:	e8 14 07 00 00       	call   80104cc0 <getcallerpcs>
801045ac:	83 c4 10             	add    $0x10,%esp
801045af:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
801045b0:	8b 06                	mov    (%esi),%eax
801045b2:	85 c0                	test   %eax,%eax
801045b4:	0f 84 ec fe ff ff    	je     801044a6 <procdump+0xb6>
        cprintf(" %p", pc[i]);
801045ba:	83 ec 08             	sub    $0x8,%esp
801045bd:	83 c6 04             	add    $0x4,%esi
801045c0:	50                   	push   %eax
801045c1:	68 62 7b 10 80       	push   $0x80107b62
801045c6:	e8 75 c0 ff ff       	call   80100640 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801045cb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801045ce:	83 c4 10             	add    $0x10,%esp
801045d1:	39 f0                	cmp    %esi,%eax
801045d3:	75 db                	jne    801045b0 <procdump+0x1c0>
801045d5:	e9 cc fe ff ff       	jmp    801044a6 <procdump+0xb6>
801045da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801045e0 <mygrowproc>:


int mygrowproc(int n){
801045e0:	55                   	push   %ebp
801045e1:	89 e5                	mov    %esp,%ebp
801045e3:	57                   	push   %edi
801045e4:	56                   	push   %esi
801045e5:	53                   	push   %ebx
801045e6:	83 ec 1c             	sub    $0x1c,%esp
  struct vma *vm = proc->vm;
801045e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  int start = proc->sz;
  int pre=0;
  int i,k;
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801045ef:	8b b8 08 01 00 00    	mov    0x108(%eax),%edi
  struct vma *vm = proc->vm;
801045f5:	8d 88 00 01 00 00    	lea    0x100(%eax),%ecx
801045fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  int start = proc->sz;
801045fe:	8b 18                	mov    (%eax),%ebx
  struct vma *vm = proc->vm;
80104600:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104603:	85 ff                	test   %edi,%edi
80104605:	0f 84 d5 00 00 00    	je     801046e0 <mygrowproc+0x100>
  {
    if (start + n < vm[i].start)
8010460b:	8d 04 7f             	lea    (%edi,%edi,2),%eax
8010460e:	8d 14 81             	lea    (%ecx,%eax,4),%edx
80104611:	8b 45 08             	mov    0x8(%ebp),%eax
80104614:	8b 0a                	mov    (%edx),%ecx
80104616:	01 d8                	add    %ebx,%eax
80104618:	39 c8                	cmp    %ecx,%eax
8010461a:	7d 22                	jge    8010463e <mygrowproc+0x5e>
8010461c:	e9 cf 00 00 00       	jmp    801046f0 <mygrowproc+0x110>
80104621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104628:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010462b:	8d 14 40             	lea    (%eax,%eax,2),%edx
8010462e:	8d 14 96             	lea    (%esi,%edx,4),%edx
80104631:	8b 75 08             	mov    0x8(%ebp),%esi
80104634:	8b 0a                	mov    (%edx),%ecx
80104636:	01 de                	add    %ebx,%esi
80104638:	39 ce                	cmp    %ecx,%esi
8010463a:	7c 0e                	jl     8010464a <mygrowproc+0x6a>
8010463c:	89 c7                	mov    %eax,%edi
    {
      break;
    }
    start = vm[i].start + vm[i].length;
8010463e:	8b 5a 04             	mov    0x4(%edx),%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104641:	8b 42 08             	mov    0x8(%edx),%eax
    start = vm[i].start + vm[i].length;
80104644:	01 cb                	add    %ecx,%ebx
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
80104646:	85 c0                	test   %eax,%eax
80104648:	75 de                	jne    80104628 <mygrowproc+0x48>
8010464a:	8b 75 e0             	mov    -0x20(%ebp),%esi
8010464d:	b9 01 00 00 00       	mov    $0x1,%ecx
80104652:	8d 96 0c 01 00 00    	lea    0x10c(%esi),%edx
80104658:	90                   	nop
80104659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pre = i;
  }
  for(k = 1; k < 10; ++k){
    if(vm[k].next == -1){
80104660:	83 7a 08 ff          	cmpl   $0xffffffff,0x8(%edx)
80104664:	74 2a                	je     80104690 <mygrowproc+0xb0>
  for(k = 1; k < 10; ++k){
80104666:	83 c1 01             	add    $0x1,%ecx
80104669:	83 c2 0c             	add    $0xc,%edx
8010466c:	83 f9 0a             	cmp    $0xa,%ecx
8010466f:	75 ef                	jne    80104660 <mygrowproc+0x80>
      myallocuvm(proc->pgdir, start , start + n);
      switchuvm(proc);
      return start;
    }
  }
  switchuvm(proc);
80104671:	83 ec 0c             	sub    $0xc,%esp
80104674:	ff 75 e0             	pushl  -0x20(%ebp)
  return 0; 
80104677:	31 db                	xor    %ebx,%ebx
  switchuvm(proc);
80104679:	e8 d2 2d 00 00       	call   80107450 <switchuvm>
  return 0; 
8010467e:	83 c4 10             	add    $0x10,%esp
}
80104681:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104684:	89 d8                	mov    %ebx,%eax
80104686:	5b                   	pop    %ebx
80104687:	5e                   	pop    %esi
80104688:	5f                   	pop    %edi
80104689:	5d                   	pop    %ebp
8010468a:	c3                   	ret    
8010468b:	90                   	nop
8010468c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      vm[k].next = i;
80104690:	89 42 08             	mov    %eax,0x8(%edx)
      vm[k].length = n;
80104693:	8b 45 08             	mov    0x8(%ebp),%eax
      myallocuvm(proc->pgdir, start , start + n);
80104696:	83 ec 04             	sub    $0x4,%esp
      vm[k].start = start;
80104699:	89 1a                	mov    %ebx,(%edx)
      vm[k].length = n;
8010469b:	89 42 04             	mov    %eax,0x4(%edx)
      vm[pre].next = k;
8010469e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
801046a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801046a4:	89 4c 87 08          	mov    %ecx,0x8(%edi,%eax,4)
      myallocuvm(proc->pgdir, start , start + n);
801046a8:	8b 45 08             	mov    0x8(%ebp),%eax
801046ab:	01 d8                	add    %ebx,%eax
801046ad:	50                   	push   %eax
801046ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b4:	53                   	push   %ebx
801046b5:	ff 70 04             	pushl  0x4(%eax)
801046b8:	e8 a3 30 00 00       	call   80107760 <myallocuvm>
      switchuvm(proc);
801046bd:	58                   	pop    %eax
801046be:	65 ff 35 04 00 00 00 	pushl  %gs:0x4
801046c5:	e8 86 2d 00 00       	call   80107450 <switchuvm>
      return start;
801046ca:	83 c4 10             	add    $0x10,%esp
}
801046cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801046d0:	89 d8                	mov    %ebx,%eax
801046d2:	5b                   	pop    %ebx
801046d3:	5e                   	pop    %esi
801046d4:	5f                   	pop    %edi
801046d5:	5d                   	pop    %ebp
801046d6:	c3                   	ret    
801046d7:	89 f6                	mov    %esi,%esi
801046d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  for(i = vm[0].next; i != 0; i=vm[i].next)//find the fist suitable
801046e0:	31 c0                	xor    %eax,%eax
801046e2:	e9 63 ff ff ff       	jmp    8010464a <mygrowproc+0x6a>
801046e7:	89 f6                	mov    %esi,%esi
801046e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if (start + n < vm[i].start)
801046f0:	89 f8                	mov    %edi,%eax
  int pre=0;
801046f2:	31 ff                	xor    %edi,%edi
801046f4:	e9 51 ff ff ff       	jmp    8010464a <mygrowproc+0x6a>
801046f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104700 <myreduceproc>:

int myreduceproc(int start){
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	57                   	push   %edi
80104704:	56                   	push   %esi
80104705:	53                   	push   %ebx
80104706:	83 ec 0c             	sub    $0xc,%esp
  int prev=0;
  int i;
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
80104709:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
int myreduceproc(int start){
80104710:	8b 75 08             	mov    0x8(%ebp),%esi
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
80104713:	8b 9a 08 01 00 00    	mov    0x108(%edx),%ebx
80104719:	85 db                	test   %ebx,%ebx
8010471b:	74 2f                	je     8010474c <myreduceproc+0x4c>
      if(proc->vm[i].start == start){
8010471d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
80104720:	3b b4 82 00 01 00 00 	cmp    0x100(%edx,%eax,4),%esi
80104727:	75 15                	jne    8010473e <myreduceproc+0x3e>
80104729:	eb 45                	jmp    80104770 <myreduceproc+0x70>
8010472b:	90                   	nop
8010472c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104730:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
80104733:	39 b4 8a 00 01 00 00 	cmp    %esi,0x100(%edx,%ecx,4)
8010473a:	74 38                	je     80104774 <myreduceproc+0x74>
8010473c:	89 c3                	mov    %eax,%ebx
  for(i=proc->vm[0].next; i!=0; i=proc->vm[i].next){
8010473e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
80104741:	8b 84 82 08 01 00 00 	mov    0x108(%edx,%eax,4),%eax
80104748:	85 c0                	test   %eax,%eax
8010474a:	75 e4                	jne    80104730 <myreduceproc+0x30>
        switchuvm(proc);
        return 0;
      }
      prev=i;
  }
  cprintf("warning: free vma at %x! \n",start);
8010474c:	83 ec 08             	sub    $0x8,%esp
8010474f:	56                   	push   %esi
80104750:	68 c6 81 10 80       	push   $0x801081c6
80104755:	e8 e6 be ff ff       	call   80100640 <cprintf>
  return -1;
8010475a:	83 c4 10             	add    $0x10,%esp
}
8010475d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80104760:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104765:	5b                   	pop    %ebx
80104766:	5e                   	pop    %esi
80104767:	5f                   	pop    %edi
80104768:	5d                   	pop    %ebp
80104769:	c3                   	ret    
8010476a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      if(proc->vm[i].start == start){
80104770:	89 d8                	mov    %ebx,%eax
  int prev=0;
80104772:	31 db                	xor    %ebx,%ebx
        mydeallocuvm(proc->pgdir,start,start+proc->vm[i].length);
80104774:	8d 3c 40             	lea    (%eax,%eax,2),%edi
80104777:	83 ec 04             	sub    $0x4,%esp
8010477a:	c1 e7 02             	shl    $0x2,%edi
8010477d:	8b 84 3a 04 01 00 00 	mov    0x104(%edx,%edi,1),%eax
80104784:	01 f0                	add    %esi,%eax
80104786:	50                   	push   %eax
80104787:	56                   	push   %esi
80104788:	ff 72 04             	pushl  0x4(%edx)
8010478b:	e8 70 30 00 00       	call   80107800 <mydeallocuvm>
        proc->vm[prev].next = proc->vm[i].next;
80104790:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104796:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
80104799:	01 c7                	add    %eax,%edi
8010479b:	8b 8f 08 01 00 00    	mov    0x108(%edi),%ecx
801047a1:	89 8c 90 08 01 00 00 	mov    %ecx,0x108(%eax,%edx,4)
        proc->vm[i].next=-1;
801047a8:	c7 87 08 01 00 00 ff 	movl   $0xffffffff,0x108(%edi)
801047af:	ff ff ff 
        switchuvm(proc);
801047b2:	89 04 24             	mov    %eax,(%esp)
801047b5:	e8 96 2c 00 00       	call   80107450 <switchuvm>
        return 0;
801047ba:	83 c4 10             	add    $0x10,%esp
}
801047bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
801047c0:	31 c0                	xor    %eax,%eax
}
801047c2:	5b                   	pop    %ebx
801047c3:	5e                   	pop    %esi
801047c4:	5f                   	pop    %edi
801047c5:	5d                   	pop    %ebp
801047c6:	c3                   	ret    
801047c7:	89 f6                	mov    %esi,%esi
801047c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801047d0 <clone>:

// malloc space for new stack then pass to clone
int clone(void(*fcn)(void*), void* arg, void* stack)
{
801047d0:	55                   	push   %ebp
801047d1:	89 e5                	mov    %esp,%ebp
801047d3:	57                   	push   %edi
801047d4:	56                   	push   %esi
801047d5:	53                   	push   %ebx
801047d6:	83 ec 24             	sub    $0x24,%esp
   cprintf("in clone, stack start addr = %p\n", stack);
801047d9:	ff 75 10             	pushl  0x10(%ebp)
801047dc:	68 48 83 10 80       	push   $0x80108348
801047e1:	e8 5a be ff ff       	call   80100640 <cprintf>
  struct proc *curproc = proc;  // 调用 clone 的进程
801047e6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  struct proc *np;

  // allocate a PCB
  if((np = allocproc()) == 0)
801047f0:	e8 eb ef ff ff       	call   801037e0 <allocproc>
801047f5:	83 c4 10             	add    $0x10,%esp
801047f8:	85 c0                	test   %eax,%eax
801047fa:	0f 84 66 01 00 00    	je     80104966 <clone+0x196>
80104800:	89 c3                	mov    %eax,%ebx
   return -1; 

  if(proc->numofthreads >= MAXTHREADS){
80104802:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104808:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010480b:	83 b8 fc 01 00 00 1f 	cmpl   $0x1f,0x1fc(%eax)
80104812:	0f 8f 37 01 00 00    	jg     8010494f <clone+0x17f>
    cprintf("clone: the number of threads is too many!\n");
    return -1;
  }
  
  // For clone, don't need to copy entire address space like fork
  np->pgdir = curproc->pgdir;  // 线程间公用页表
80104818:	8b 42 04             	mov    0x4(%edx),%eax
8010481b:	89 43 04             	mov    %eax,0x4(%ebx)
  np->sz = curproc->sz;
8010481e:	8b 02                	mov    (%edx),%eax
  np->pthread = curproc;       // exit 时唤醒用
80104820:	89 93 78 01 00 00    	mov    %edx,0x178(%ebx)
  np->parent = 0;
80104826:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  np->sz = curproc->sz;
8010482d:	89 03                	mov    %eax,(%ebx)
  proc->numofthreads++;
8010482f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  for(int i=0;i<MAXTHREADS;++i){
80104836:	31 c0                	xor    %eax,%eax
  proc->numofthreads++;
80104838:	83 81 fc 01 00 00 01 	addl   $0x1,0x1fc(%ecx)
8010483f:	eb 0f                	jmp    80104850 <clone+0x80>
80104841:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(int i=0;i<MAXTHREADS;++i){
80104848:	83 c0 01             	add    $0x1,%eax
8010484b:	83 f8 20             	cmp    $0x20,%eax
8010484e:	74 12                	je     80104862 <clone+0x92>
    if(proc->cthread[i] == 0){
80104850:	8b b4 81 7c 01 00 00 	mov    0x17c(%ecx,%eax,4),%esi
80104857:	85 f6                	test   %esi,%esi
80104859:	75 ed                	jne    80104848 <clone+0x78>
      proc->cthread[i] = np;
8010485b:	89 9c 81 7c 01 00 00 	mov    %ebx,0x17c(%ecx,%eax,4)
      break;
    }
  }

  *np->tf = *curproc->tf;      // 继承 trapframe
80104862:	8b b2 9c 00 00 00    	mov    0x9c(%edx),%esi
80104868:	8b bb 9c 00 00 00    	mov    0x9c(%ebx),%edi
8010486e:	b9 13 00 00 00       	mov    $0x13,%ecx
80104873:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  int* sp = stack + 4096 - 8;

  // Clone may need to change other registers than ones seen in fork
  np->tf->eip = (int)fcn;
80104875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  np->tf->esp = (int)sp; 
  np->tf->ebp = (int)sp; 
  np->tf->eax = 0; 

  // setup new user stack and some pointers
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
80104878:	8b 7d 10             	mov    0x10(%ebp),%edi
  *sp = 0xffffffff; 

  for(int i = 0; i < NOFILE; i++)
8010487b:	31 f6                	xor    %esi,%esi
  np->tf->eip = (int)fcn;
8010487d:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
80104883:	89 48 38             	mov    %ecx,0x38(%eax)
  int* sp = stack + 4096 - 8;
80104886:	8b 45 10             	mov    0x10(%ebp),%eax
  np->tf->esp = (int)sp; 
80104889:	8b 8b 9c 00 00 00    	mov    0x9c(%ebx),%ecx
  int* sp = stack + 4096 - 8;
8010488f:	05 f8 0f 00 00       	add    $0xff8,%eax
  np->tf->esp = (int)sp; 
80104894:	89 41 44             	mov    %eax,0x44(%ecx)
  np->tf->ebp = (int)sp; 
80104897:	8b 8b 9c 00 00 00    	mov    0x9c(%ebx),%ecx
8010489d:	89 41 08             	mov    %eax,0x8(%ecx)
  np->tf->eax = 0; 
801048a0:	8b 83 9c 00 00 00    	mov    0x9c(%ebx),%eax
801048a6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
801048ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  *sp = 0xffffffff; 
801048b0:	c7 87 f8 0f 00 00 ff 	movl   $0xffffffff,0xff8(%edi)
801048b7:	ff ff ff 
  *(sp + 1) = (int)arg; // *(np->tf->esp+4) = (int)arg
801048ba:	89 87 fc 0f 00 00    	mov    %eax,0xffc(%edi)
  for(int i = 0; i < NOFILE; i++)
801048c0:	89 d7                	mov    %edx,%edi
801048c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[i])
801048c8:	8b 84 b7 ac 00 00 00 	mov    0xac(%edi,%esi,4),%eax
801048cf:	85 c0                	test   %eax,%eax
801048d1:	74 13                	je     801048e6 <clone+0x116>
      np->ofile[i] = filedup(curproc->ofile[i]);
801048d3:	83 ec 0c             	sub    $0xc,%esp
801048d6:	50                   	push   %eax
801048d7:	e8 f4 c4 ff ff       	call   80100dd0 <filedup>
801048dc:	83 c4 10             	add    $0x10,%esp
801048df:	89 84 b3 ac 00 00 00 	mov    %eax,0xac(%ebx,%esi,4)
  for(int i = 0; i < NOFILE; i++)
801048e6:	83 c6 01             	add    $0x1,%esi
801048e9:	83 fe 10             	cmp    $0x10,%esi
801048ec:	75 da                	jne    801048c8 <clone+0xf8>
  np->cwd = idup(curproc->cwd);
801048ee:	83 ec 0c             	sub    $0xc,%esp
801048f1:	ff b7 ec 00 00 00    	pushl  0xec(%edi)
801048f7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801048fa:	e8 f1 cc ff ff       	call   801015f0 <idup>

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801048ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  np->cwd = idup(curproc->cwd);
80104902:	89 83 ec 00 00 00    	mov    %eax,0xec(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104908:	8d 83 f0 00 00 00    	lea    0xf0(%ebx),%eax
8010490e:	83 c4 0c             	add    $0xc,%esp
80104911:	6a 10                	push   $0x10
80104913:	81 c2 f0 00 00 00    	add    $0xf0,%edx
80104919:	52                   	push   %edx
8010491a:	50                   	push   %eax
8010491b:	e8 d0 06 00 00       	call   80104ff0 <safestrcpy>
  
  int pid = np->pid;
80104920:	8b 73 10             	mov    0x10(%ebx),%esi
  
  acquire(&ptable.lock);
80104923:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
8010492a:	e8 d1 02 00 00       	call   80104c00 <acquire>
  np->state = RUNNABLE;
8010492f:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80104936:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
8010493d:	e8 7e 04 00 00       	call   80104dc0 <release>
 
  // return the ID of the new thread
  return pid;
80104942:	83 c4 10             	add    $0x10,%esp
}
80104945:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104948:	89 f0                	mov    %esi,%eax
8010494a:	5b                   	pop    %ebx
8010494b:	5e                   	pop    %esi
8010494c:	5f                   	pop    %edi
8010494d:	5d                   	pop    %ebp
8010494e:	c3                   	ret    
    cprintf("clone: the number of threads is too many!\n");
8010494f:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80104952:	be ff ff ff ff       	mov    $0xffffffff,%esi
    cprintf("clone: the number of threads is too many!\n");
80104957:	68 6c 83 10 80       	push   $0x8010836c
8010495c:	e8 df bc ff ff       	call   80100640 <cprintf>
    return -1;
80104961:	83 c4 10             	add    $0x10,%esp
80104964:	eb df                	jmp    80104945 <clone+0x175>
   return -1; 
80104966:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010496b:	eb d8                	jmp    80104945 <clone+0x175>
8010496d:	8d 76 00             	lea    0x0(%esi),%esi

80104970 <join>:

int
join(void **stack)
{
80104970:	55                   	push   %ebp
80104971:	89 e5                	mov    %esp,%ebp
80104973:	56                   	push   %esi
80104974:	53                   	push   %ebx
  cprintf("in join, stack pointer = %p\n",*stack);
80104975:	8b 45 08             	mov    0x8(%ebp),%eax
80104978:	83 ec 08             	sub    $0x8,%esp
8010497b:	ff 30                	pushl  (%eax)
8010497d:	68 e1 81 10 80       	push   $0x801081e1
80104982:	e8 b9 bc ff ff       	call   80100640 <cprintf>
  struct proc *curproc = proc;
  struct proc *p;
  int havekids;

  acquire(&ptable.lock);
80104987:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
  struct proc *curproc = proc;
8010498e:	65 8b 35 04 00 00 00 	mov    %gs:0x4,%esi
  acquire(&ptable.lock);
80104995:	e8 66 02 00 00       	call   80104c00 <acquire>
8010499a:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010499d:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010499f:	bb 14 29 11 80       	mov    $0x80112914,%ebx
801049a4:	eb 18                	jmp    801049be <join+0x4e>
801049a6:	8d 76 00             	lea    0x0(%esi),%esi
801049a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801049b0:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
801049b6:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
801049bc:	73 21                	jae    801049df <join+0x6f>
      if(p->pthread != curproc)
801049be:	39 b3 78 01 00 00    	cmp    %esi,0x178(%ebx)
801049c4:	75 ea                	jne    801049b0 <join+0x40>
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
801049c6:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801049ca:	74 34                	je     80104a00 <join+0x90>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049cc:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
      havekids = 1;
801049d2:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d7:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
801049dd:	72 df                	jb     801049be <join+0x4e>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049df:	85 c0                	test   %eax,%eax
801049e1:	74 7a                	je     80104a5d <join+0xed>
801049e3:	8b 86 a8 00 00 00    	mov    0xa8(%esi),%eax
801049e9:	85 c0                	test   %eax,%eax
801049eb:	75 70                	jne    80104a5d <join+0xed>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801049ed:	83 ec 08             	sub    $0x8,%esp
801049f0:	68 e0 28 11 80       	push   $0x801128e0
801049f5:	56                   	push   %esi
801049f6:	e8 25 f7 ff ff       	call   80104120 <sleep>
    havekids = 0;
801049fb:	83 c4 10             	add    $0x10,%esp
801049fe:	eb 9d                	jmp    8010499d <join+0x2d>
        kfree(p->kstack);
80104a00:	83 ec 0c             	sub    $0xc,%esp
80104a03:	ff 73 08             	pushl  0x8(%ebx)
        int pid = p->pid;
80104a06:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104a09:	e8 12 d9 ff ff       	call   80102320 <kfree>
        release(&ptable.lock);
80104a0e:	c7 04 24 e0 28 11 80 	movl   $0x801128e0,(%esp)
        p->kstack = 0;
80104a15:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        p->state = UNUSED;
80104a1c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
80104a23:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80104a2a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->pthread = 0;
80104a31:	c7 83 78 01 00 00 00 	movl   $0x0,0x178(%ebx)
80104a38:	00 00 00 
        p->name[0] = 0;
80104a3b:	c6 83 f0 00 00 00 00 	movb   $0x0,0xf0(%ebx)
        p->killed = 0;
80104a42:	c7 83 a8 00 00 00 00 	movl   $0x0,0xa8(%ebx)
80104a49:	00 00 00 
        release(&ptable.lock);
80104a4c:	e8 6f 03 00 00       	call   80104dc0 <release>
        return pid;
80104a51:	83 c4 10             	add    $0x10,%esp
  }

  return 0;
}
80104a54:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a57:	89 f0                	mov    %esi,%eax
80104a59:	5b                   	pop    %ebx
80104a5a:	5e                   	pop    %esi
80104a5b:	5d                   	pop    %ebp
80104a5c:	c3                   	ret    
      release(&ptable.lock);
80104a5d:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104a60:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104a65:	68 e0 28 11 80       	push   $0x801128e0
80104a6a:	e8 51 03 00 00       	call   80104dc0 <release>
      return -1;
80104a6f:	83 c4 10             	add    $0x10,%esp
80104a72:	eb e0                	jmp    80104a54 <join+0xe4>
80104a74:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104a7a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104a80 <cps>:

int cps(void)
{
80104a80:	55                   	push   %ebp
80104a81:	89 e5                	mov    %esp,%ebp
80104a83:	53                   	push   %ebx
80104a84:	83 ec 10             	sub    $0x10,%esp
  asm volatile("sti");
80104a87:	fb                   	sti    
  struct proc *p;
  sti(); // Enable interrupts
  acquire(&ptable.lock);
80104a88:	68 e0 28 11 80       	push   $0x801128e0
  cprintf("name\tpid\tstate\t\tpriority\n");
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a8d:	bb 14 29 11 80       	mov    $0x80112914,%ebx
  acquire(&ptable.lock);
80104a92:	e8 69 01 00 00       	call   80104c00 <acquire>
  cprintf("name\tpid\tstate\t\tpriority\n");
80104a97:	c7 04 24 fe 81 10 80 	movl   $0x801081fe,(%esp)
80104a9e:	e8 9d bb ff ff       	call   80100640 <cprintf>
80104aa3:	83 c4 10             	add    $0x10,%esp
80104aa6:	eb 2d                	jmp    80104ad5 <cps+0x55>
80104aa8:	90                   	nop
80104aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  {
    if (p->state == SLEEPING)
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
    else if (p->state == RUNNING)
80104ab0:	83 f8 04             	cmp    $0x4,%eax
80104ab3:	74 6b                	je     80104b20 <cps+0xa0>
      cprintf("%s\t%d\tRUNNING\t\t%d\n", p->name, p->pid, p->priority);
    else if (p->state == RUNNABLE)
80104ab5:	83 f8 03             	cmp    $0x3,%eax
80104ab8:	0f 84 82 00 00 00    	je     80104b40 <cps+0xc0>
      cprintf("%s\t%d\tRUNNABLE\t%d\n", p->name, p->pid, p->priority);
    else if (p->state == ZOMBIE)
80104abe:	83 f8 05             	cmp    $0x5,%eax
80104ac1:	0f 84 a1 00 00 00    	je     80104b68 <cps+0xe8>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ac7:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
80104acd:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
80104ad3:	73 33                	jae    80104b08 <cps+0x88>
    if (p->state == SLEEPING)
80104ad5:	8b 43 0c             	mov    0xc(%ebx),%eax
80104ad8:	83 f8 02             	cmp    $0x2,%eax
80104adb:	75 d3                	jne    80104ab0 <cps+0x30>
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
80104add:	8d 83 f0 00 00 00    	lea    0xf0(%ebx),%eax
80104ae3:	ff b3 04 02 00 00    	pushl  0x204(%ebx)
80104ae9:	ff 73 10             	pushl  0x10(%ebx)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104aec:	81 c3 0c 02 00 00    	add    $0x20c,%ebx
      cprintf("%s\t%d\tSLEEPING\t%d\n", p->name, p->pid, p->priority);
80104af2:	50                   	push   %eax
80104af3:	68 18 82 10 80       	push   $0x80108218
80104af8:	e8 43 bb ff ff       	call   80100640 <cprintf>
80104afd:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b00:	81 fb 14 ac 11 80    	cmp    $0x8011ac14,%ebx
80104b06:	72 cd                	jb     80104ad5 <cps+0x55>
      cprintf("%s\t%d\tZOMBIE\t%d\n", p->name, p->pid, p->priority);
  }
  release(&ptable.lock);
80104b08:	83 ec 0c             	sub    $0xc,%esp
80104b0b:	68 e0 28 11 80       	push   $0x801128e0
80104b10:	e8 ab 02 00 00       	call   80104dc0 <release>
  return 0;
}
80104b15:	31 c0                	xor    %eax,%eax
80104b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b1a:	c9                   	leave  
80104b1b:	c3                   	ret    
80104b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      cprintf("%s\t%d\tRUNNING\t\t%d\n", p->name, p->pid, p->priority);
80104b20:	8d 83 f0 00 00 00    	lea    0xf0(%ebx),%eax
80104b26:	ff b3 04 02 00 00    	pushl  0x204(%ebx)
80104b2c:	ff 73 10             	pushl  0x10(%ebx)
80104b2f:	50                   	push   %eax
80104b30:	68 2b 82 10 80       	push   $0x8010822b
80104b35:	e8 06 bb ff ff       	call   80100640 <cprintf>
80104b3a:	83 c4 10             	add    $0x10,%esp
80104b3d:	eb 88                	jmp    80104ac7 <cps+0x47>
80104b3f:	90                   	nop
      cprintf("%s\t%d\tRUNNABLE\t%d\n", p->name, p->pid, p->priority);
80104b40:	8d 83 f0 00 00 00    	lea    0xf0(%ebx),%eax
80104b46:	ff b3 04 02 00 00    	pushl  0x204(%ebx)
80104b4c:	ff 73 10             	pushl  0x10(%ebx)
80104b4f:	50                   	push   %eax
80104b50:	68 3e 82 10 80       	push   $0x8010823e
80104b55:	e8 e6 ba ff ff       	call   80100640 <cprintf>
80104b5a:	83 c4 10             	add    $0x10,%esp
80104b5d:	e9 65 ff ff ff       	jmp    80104ac7 <cps+0x47>
80104b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("%s\t%d\tZOMBIE\t%d\n", p->name, p->pid, p->priority);
80104b68:	8d 83 f0 00 00 00    	lea    0xf0(%ebx),%eax
80104b6e:	ff b3 04 02 00 00    	pushl  0x204(%ebx)
80104b74:	ff 73 10             	pushl  0x10(%ebx)
80104b77:	50                   	push   %eax
80104b78:	68 51 82 10 80       	push   $0x80108251
80104b7d:	e8 be ba ff ff       	call   80100640 <cprintf>
80104b82:	83 c4 10             	add    $0x10,%esp
80104b85:	e9 3d ff ff ff       	jmp    80104ac7 <cps+0x47>
80104b8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104b90 <chpri>:

int chpri(int pid, int priority)
{
80104b90:	55                   	push   %ebp
80104b91:	89 e5                	mov    %esp,%ebp
80104b93:	53                   	push   %ebx
80104b94:	83 ec 10             	sub    $0x10,%esp
80104b97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;
  acquire(&ptable.lock);
80104b9a:	68 e0 28 11 80       	push   $0x801128e0
80104b9f:	e8 5c 00 00 00       	call   80104c00 <acquire>
80104ba4:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ba7:	ba 14 29 11 80       	mov    $0x80112914,%edx
80104bac:	eb 10                	jmp    80104bbe <chpri+0x2e>
80104bae:	66 90                	xchg   %ax,%ax
80104bb0:	81 c2 0c 02 00 00    	add    $0x20c,%edx
80104bb6:	81 fa 14 ac 11 80    	cmp    $0x8011ac14,%edx
80104bbc:	73 0e                	jae    80104bcc <chpri+0x3c>
  {
    if (p->pid == pid)
80104bbe:	39 5a 10             	cmp    %ebx,0x10(%edx)
80104bc1:	75 ed                	jne    80104bb0 <chpri+0x20>
    {
      p->priority = priority;
80104bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bc6:	89 82 04 02 00 00    	mov    %eax,0x204(%edx)
      break;
    }
  }
  release(&ptable.lock);
80104bcc:	83 ec 0c             	sub    $0xc,%esp
80104bcf:	68 e0 28 11 80       	push   $0x801128e0
80104bd4:	e8 e7 01 00 00       	call   80104dc0 <release>
  return pid;
}
80104bd9:	89 d8                	mov    %ebx,%eax
80104bdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bde:	c9                   	leave  
80104bdf:	c3                   	ret    

80104be0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104be0:	55                   	push   %ebp
80104be1:	89 e5                	mov    %esp,%ebp
80104be3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104be6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104be9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
80104bef:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104bf2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104bf9:	5d                   	pop    %ebp
80104bfa:	c3                   	ret    
80104bfb:	90                   	nop
80104bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104c00 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104c00:	55                   	push   %ebp
80104c01:	89 e5                	mov    %esp,%ebp
80104c03:	53                   	push   %ebx
80104c04:	83 ec 04             	sub    $0x4,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c07:	9c                   	pushf  
80104c08:	5a                   	pop    %edx
  asm volatile("cli");
80104c09:	fa                   	cli    
{
  int eflags;

  eflags = readeflags();
  cli();
  if(cpu->ncli == 0)
80104c0a:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80104c11:	8b 81 ac 00 00 00    	mov    0xac(%ecx),%eax
80104c17:	85 c0                	test   %eax,%eax
80104c19:	75 0c                	jne    80104c27 <acquire+0x27>
    cpu->intena = eflags & FL_IF;
80104c1b:	81 e2 00 02 00 00    	and    $0x200,%edx
80104c21:	89 91 b0 00 00 00    	mov    %edx,0xb0(%ecx)
  if(holding(lk))
80104c27:	8b 55 08             	mov    0x8(%ebp),%edx
  cpu->ncli += 1;
80104c2a:	83 c0 01             	add    $0x1,%eax
80104c2d:	89 81 ac 00 00 00    	mov    %eax,0xac(%ecx)
  return lock->locked && lock->cpu == cpu;
80104c33:	8b 02                	mov    (%edx),%eax
80104c35:	85 c0                	test   %eax,%eax
80104c37:	74 05                	je     80104c3e <acquire+0x3e>
80104c39:	39 4a 08             	cmp    %ecx,0x8(%edx)
80104c3c:	74 74                	je     80104cb2 <acquire+0xb2>
  asm volatile("lock; xchgl %0, %1" :
80104c3e:	b9 01 00 00 00       	mov    $0x1,%ecx
80104c43:	90                   	nop
80104c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104c48:	89 c8                	mov    %ecx,%eax
80104c4a:	f0 87 02             	lock xchg %eax,(%edx)
  while(xchg(&lk->locked, 1) != 0)
80104c4d:	85 c0                	test   %eax,%eax
80104c4f:	75 f7                	jne    80104c48 <acquire+0x48>
  __sync_synchronize();
80104c51:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = cpu;
80104c56:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104c59:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  for(i = 0; i < 10; i++){
80104c5f:	31 d2                	xor    %edx,%edx
  lk->cpu = cpu;
80104c61:	89 41 08             	mov    %eax,0x8(%ecx)
  getcallerpcs(&lk, lk->pcs);
80104c64:	83 c1 0c             	add    $0xc,%ecx
  ebp = (uint*)v - 2;
80104c67:	89 e8                	mov    %ebp,%eax
80104c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c70:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104c76:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104c7c:	77 1a                	ja     80104c98 <acquire+0x98>
    pcs[i] = ebp[1];     // saved %eip
80104c7e:	8b 58 04             	mov    0x4(%eax),%ebx
80104c81:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104c84:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104c87:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104c89:	83 fa 0a             	cmp    $0xa,%edx
80104c8c:	75 e2                	jne    80104c70 <acquire+0x70>
}
80104c8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c91:	c9                   	leave  
80104c92:	c3                   	ret    
80104c93:	90                   	nop
80104c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104c98:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104c9b:	83 c1 28             	add    $0x28,%ecx
80104c9e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104ca0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104ca6:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104ca9:	39 c8                	cmp    %ecx,%eax
80104cab:	75 f3                	jne    80104ca0 <acquire+0xa0>
}
80104cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cb0:	c9                   	leave  
80104cb1:	c3                   	ret    
    panic("acquire");
80104cb2:	83 ec 0c             	sub    $0xc,%esp
80104cb5:	68 b0 83 10 80       	push   $0x801083b0
80104cba:	e8 b1 b6 ff ff       	call   80100370 <panic>
80104cbf:	90                   	nop

80104cc0 <getcallerpcs>:
{
80104cc0:	55                   	push   %ebp
  for(i = 0; i < 10; i++){
80104cc1:	31 d2                	xor    %edx,%edx
{
80104cc3:	89 e5                	mov    %esp,%ebp
80104cc5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104cc6:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
80104ccc:	83 e8 08             	sub    $0x8,%eax
80104ccf:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104cd0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104cd6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104cdc:	77 1a                	ja     80104cf8 <getcallerpcs+0x38>
    pcs[i] = ebp[1];     // saved %eip
80104cde:	8b 58 04             	mov    0x4(%eax),%ebx
80104ce1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104ce4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104ce7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104ce9:	83 fa 0a             	cmp    $0xa,%edx
80104cec:	75 e2                	jne    80104cd0 <getcallerpcs+0x10>
}
80104cee:	5b                   	pop    %ebx
80104cef:	5d                   	pop    %ebp
80104cf0:	c3                   	ret    
80104cf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104cf8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104cfb:	83 c1 28             	add    $0x28,%ecx
80104cfe:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104d00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104d06:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
80104d09:	39 c1                	cmp    %eax,%ecx
80104d0b:	75 f3                	jne    80104d00 <getcallerpcs+0x40>
}
80104d0d:	5b                   	pop    %ebx
80104d0e:	5d                   	pop    %ebp
80104d0f:	c3                   	ret    

80104d10 <holding>:
{
80104d10:	55                   	push   %ebp
80104d11:	89 e5                	mov    %esp,%ebp
80104d13:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
80104d16:	8b 02                	mov    (%edx),%eax
80104d18:	85 c0                	test   %eax,%eax
80104d1a:	74 14                	je     80104d30 <holding+0x20>
80104d1c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d22:	39 42 08             	cmp    %eax,0x8(%edx)
}
80104d25:	5d                   	pop    %ebp
  return lock->locked && lock->cpu == cpu;
80104d26:	0f 94 c0             	sete   %al
80104d29:	0f b6 c0             	movzbl %al,%eax
}
80104d2c:	c3                   	ret    
80104d2d:	8d 76 00             	lea    0x0(%esi),%esi
80104d30:	31 c0                	xor    %eax,%eax
80104d32:	5d                   	pop    %ebp
80104d33:	c3                   	ret    
80104d34:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104d3a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104d40 <pushcli>:
{
80104d40:	55                   	push   %ebp
80104d41:	89 e5                	mov    %esp,%ebp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d43:	9c                   	pushf  
80104d44:	59                   	pop    %ecx
  asm volatile("cli");
80104d45:	fa                   	cli    
  if(cpu->ncli == 0)
80104d46:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d4d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104d53:	85 c0                	test   %eax,%eax
80104d55:	75 0c                	jne    80104d63 <pushcli+0x23>
    cpu->intena = eflags & FL_IF;
80104d57:	81 e1 00 02 00 00    	and    $0x200,%ecx
80104d5d:	89 8a b0 00 00 00    	mov    %ecx,0xb0(%edx)
  cpu->ncli += 1;
80104d63:	83 c0 01             	add    $0x1,%eax
80104d66:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
}
80104d6c:	5d                   	pop    %ebp
80104d6d:	c3                   	ret    
80104d6e:	66 90                	xchg   %ax,%ax

80104d70 <popcli>:

void
popcli(void)
{
80104d70:	55                   	push   %ebp
80104d71:	89 e5                	mov    %esp,%ebp
80104d73:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d76:	9c                   	pushf  
80104d77:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104d78:	f6 c4 02             	test   $0x2,%ah
80104d7b:	75 2c                	jne    80104da9 <popcli+0x39>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
80104d7d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d84:	83 aa ac 00 00 00 01 	subl   $0x1,0xac(%edx)
80104d8b:	78 0f                	js     80104d9c <popcli+0x2c>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
80104d8d:	75 0b                	jne    80104d9a <popcli+0x2a>
80104d8f:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
80104d95:	85 c0                	test   %eax,%eax
80104d97:	74 01                	je     80104d9a <popcli+0x2a>
  asm volatile("sti");
80104d99:	fb                   	sti    
    sti();
}
80104d9a:	c9                   	leave  
80104d9b:	c3                   	ret    
    panic("popcli");
80104d9c:	83 ec 0c             	sub    $0xc,%esp
80104d9f:	68 cf 83 10 80       	push   $0x801083cf
80104da4:	e8 c7 b5 ff ff       	call   80100370 <panic>
    panic("popcli - interruptible");
80104da9:	83 ec 0c             	sub    $0xc,%esp
80104dac:	68 b8 83 10 80       	push   $0x801083b8
80104db1:	e8 ba b5 ff ff       	call   80100370 <panic>
80104db6:	8d 76 00             	lea    0x0(%esi),%esi
80104db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104dc0 <release>:
{
80104dc0:	55                   	push   %ebp
80104dc1:	89 e5                	mov    %esp,%ebp
80104dc3:	83 ec 08             	sub    $0x8,%esp
80104dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked && lock->cpu == cpu;
80104dc9:	8b 10                	mov    (%eax),%edx
80104dcb:	85 d2                	test   %edx,%edx
80104dcd:	74 2b                	je     80104dfa <release+0x3a>
80104dcf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104dd6:	39 50 08             	cmp    %edx,0x8(%eax)
80104dd9:	75 1f                	jne    80104dfa <release+0x3a>
  lk->pcs[0] = 0;
80104ddb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104de2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  __sync_synchronize();
80104de9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->locked = 0;
80104dee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80104df4:	c9                   	leave  
  popcli();
80104df5:	e9 76 ff ff ff       	jmp    80104d70 <popcli>
    panic("release");
80104dfa:	83 ec 0c             	sub    $0xc,%esp
80104dfd:	68 d6 83 10 80       	push   $0x801083d6
80104e02:	e8 69 b5 ff ff       	call   80100370 <panic>
80104e07:	66 90                	xchg   %ax,%ax
80104e09:	66 90                	xchg   %ax,%ax
80104e0b:	66 90                	xchg   %ax,%ax
80104e0d:	66 90                	xchg   %ax,%ax
80104e0f:	90                   	nop

80104e10 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	57                   	push   %edi
80104e14:	53                   	push   %ebx
80104e15:	8b 55 08             	mov    0x8(%ebp),%edx
80104e18:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104e1b:	f6 c2 03             	test   $0x3,%dl
80104e1e:	75 05                	jne    80104e25 <memset+0x15>
80104e20:	f6 c1 03             	test   $0x3,%cl
80104e23:	74 13                	je     80104e38 <memset+0x28>
  asm volatile("cld; rep stosb" :
80104e25:	89 d7                	mov    %edx,%edi
80104e27:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e2a:	fc                   	cld    
80104e2b:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104e2d:	5b                   	pop    %ebx
80104e2e:	89 d0                	mov    %edx,%eax
80104e30:	5f                   	pop    %edi
80104e31:	5d                   	pop    %ebp
80104e32:	c3                   	ret    
80104e33:	90                   	nop
80104e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c &= 0xFF;
80104e38:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e3c:	c1 e9 02             	shr    $0x2,%ecx
80104e3f:	89 f8                	mov    %edi,%eax
80104e41:	89 fb                	mov    %edi,%ebx
80104e43:	c1 e0 18             	shl    $0x18,%eax
80104e46:	c1 e3 10             	shl    $0x10,%ebx
80104e49:	09 d8                	or     %ebx,%eax
80104e4b:	09 f8                	or     %edi,%eax
80104e4d:	c1 e7 08             	shl    $0x8,%edi
80104e50:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104e52:	89 d7                	mov    %edx,%edi
80104e54:	fc                   	cld    
80104e55:	f3 ab                	rep stos %eax,%es:(%edi)
}
80104e57:	5b                   	pop    %ebx
80104e58:	89 d0                	mov    %edx,%eax
80104e5a:	5f                   	pop    %edi
80104e5b:	5d                   	pop    %ebp
80104e5c:	c3                   	ret    
80104e5d:	8d 76 00             	lea    0x0(%esi),%esi

80104e60 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e60:	55                   	push   %ebp
80104e61:	89 e5                	mov    %esp,%ebp
80104e63:	57                   	push   %edi
80104e64:	56                   	push   %esi
80104e65:	53                   	push   %ebx
80104e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104e69:	8b 75 08             	mov    0x8(%ebp),%esi
80104e6c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104e6f:	85 db                	test   %ebx,%ebx
80104e71:	74 29                	je     80104e9c <memcmp+0x3c>
    if(*s1 != *s2)
80104e73:	0f b6 16             	movzbl (%esi),%edx
80104e76:	0f b6 0f             	movzbl (%edi),%ecx
80104e79:	38 d1                	cmp    %dl,%cl
80104e7b:	75 2b                	jne    80104ea8 <memcmp+0x48>
80104e7d:	b8 01 00 00 00       	mov    $0x1,%eax
80104e82:	eb 14                	jmp    80104e98 <memcmp+0x38>
80104e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104e88:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
80104e8c:	83 c0 01             	add    $0x1,%eax
80104e8f:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
80104e94:	38 ca                	cmp    %cl,%dl
80104e96:	75 10                	jne    80104ea8 <memcmp+0x48>
  while(n-- > 0){
80104e98:	39 d8                	cmp    %ebx,%eax
80104e9a:	75 ec                	jne    80104e88 <memcmp+0x28>
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
80104e9c:	5b                   	pop    %ebx
  return 0;
80104e9d:	31 c0                	xor    %eax,%eax
}
80104e9f:	5e                   	pop    %esi
80104ea0:	5f                   	pop    %edi
80104ea1:	5d                   	pop    %ebp
80104ea2:	c3                   	ret    
80104ea3:	90                   	nop
80104ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return *s1 - *s2;
80104ea8:	0f b6 c2             	movzbl %dl,%eax
}
80104eab:	5b                   	pop    %ebx
      return *s1 - *s2;
80104eac:	29 c8                	sub    %ecx,%eax
}
80104eae:	5e                   	pop    %esi
80104eaf:	5f                   	pop    %edi
80104eb0:	5d                   	pop    %ebp
80104eb1:	c3                   	ret    
80104eb2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ec0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ec0:	55                   	push   %ebp
80104ec1:	89 e5                	mov    %esp,%ebp
80104ec3:	56                   	push   %esi
80104ec4:	53                   	push   %ebx
80104ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104ecb:	8b 75 10             	mov    0x10(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104ece:	39 c3                	cmp    %eax,%ebx
80104ed0:	73 26                	jae    80104ef8 <memmove+0x38>
80104ed2:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
80104ed5:	39 c8                	cmp    %ecx,%eax
80104ed7:	73 1f                	jae    80104ef8 <memmove+0x38>
    s += n;
    d += n;
    while(n-- > 0)
80104ed9:	85 f6                	test   %esi,%esi
80104edb:	8d 56 ff             	lea    -0x1(%esi),%edx
80104ede:	74 0f                	je     80104eef <memmove+0x2f>
      *--d = *--s;
80104ee0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104ee4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    while(n-- > 0)
80104ee7:	83 ea 01             	sub    $0x1,%edx
80104eea:	83 fa ff             	cmp    $0xffffffff,%edx
80104eed:	75 f1                	jne    80104ee0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104eef:	5b                   	pop    %ebx
80104ef0:	5e                   	pop    %esi
80104ef1:	5d                   	pop    %ebp
80104ef2:	c3                   	ret    
80104ef3:	90                   	nop
80104ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
80104ef8:	31 d2                	xor    %edx,%edx
80104efa:	85 f6                	test   %esi,%esi
80104efc:	74 f1                	je     80104eef <memmove+0x2f>
80104efe:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80104f00:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104f04:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80104f07:	83 c2 01             	add    $0x1,%edx
    while(n-- > 0)
80104f0a:	39 d6                	cmp    %edx,%esi
80104f0c:	75 f2                	jne    80104f00 <memmove+0x40>
}
80104f0e:	5b                   	pop    %ebx
80104f0f:	5e                   	pop    %esi
80104f10:	5d                   	pop    %ebp
80104f11:	c3                   	ret    
80104f12:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104f20 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f20:	55                   	push   %ebp
80104f21:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80104f23:	5d                   	pop    %ebp
  return memmove(dst, src, n);
80104f24:	eb 9a                	jmp    80104ec0 <memmove>
80104f26:	8d 76 00             	lea    0x0(%esi),%esi
80104f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104f30 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f30:	55                   	push   %ebp
80104f31:	89 e5                	mov    %esp,%ebp
80104f33:	57                   	push   %edi
80104f34:	56                   	push   %esi
80104f35:	8b 7d 10             	mov    0x10(%ebp),%edi
80104f38:	53                   	push   %ebx
80104f39:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  while(n > 0 && *p && *p == *q)
80104f3f:	85 ff                	test   %edi,%edi
80104f41:	74 2f                	je     80104f72 <strncmp+0x42>
80104f43:	0f b6 01             	movzbl (%ecx),%eax
80104f46:	0f b6 1e             	movzbl (%esi),%ebx
80104f49:	84 c0                	test   %al,%al
80104f4b:	74 37                	je     80104f84 <strncmp+0x54>
80104f4d:	38 c3                	cmp    %al,%bl
80104f4f:	75 33                	jne    80104f84 <strncmp+0x54>
80104f51:	01 f7                	add    %esi,%edi
80104f53:	eb 13                	jmp    80104f68 <strncmp+0x38>
80104f55:	8d 76 00             	lea    0x0(%esi),%esi
80104f58:	0f b6 01             	movzbl (%ecx),%eax
80104f5b:	84 c0                	test   %al,%al
80104f5d:	74 21                	je     80104f80 <strncmp+0x50>
80104f5f:	0f b6 1a             	movzbl (%edx),%ebx
80104f62:	89 d6                	mov    %edx,%esi
80104f64:	38 d8                	cmp    %bl,%al
80104f66:	75 1c                	jne    80104f84 <strncmp+0x54>
    n--, p++, q++;
80104f68:	8d 56 01             	lea    0x1(%esi),%edx
80104f6b:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104f6e:	39 fa                	cmp    %edi,%edx
80104f70:	75 e6                	jne    80104f58 <strncmp+0x28>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
80104f72:	5b                   	pop    %ebx
    return 0;
80104f73:	31 c0                	xor    %eax,%eax
}
80104f75:	5e                   	pop    %esi
80104f76:	5f                   	pop    %edi
80104f77:	5d                   	pop    %ebp
80104f78:	c3                   	ret    
80104f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f80:	0f b6 5e 01          	movzbl 0x1(%esi),%ebx
  return (uchar)*p - (uchar)*q;
80104f84:	29 d8                	sub    %ebx,%eax
}
80104f86:	5b                   	pop    %ebx
80104f87:	5e                   	pop    %esi
80104f88:	5f                   	pop    %edi
80104f89:	5d                   	pop    %ebp
80104f8a:	c3                   	ret    
80104f8b:	90                   	nop
80104f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104f90 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f90:	55                   	push   %ebp
80104f91:	89 e5                	mov    %esp,%ebp
80104f93:	56                   	push   %esi
80104f94:	53                   	push   %ebx
80104f95:	8b 45 08             	mov    0x8(%ebp),%eax
80104f98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104f9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f9e:	89 c2                	mov    %eax,%edx
80104fa0:	eb 19                	jmp    80104fbb <strncpy+0x2b>
80104fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104fa8:	83 c3 01             	add    $0x1,%ebx
80104fab:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
80104faf:	83 c2 01             	add    $0x1,%edx
80104fb2:	84 c9                	test   %cl,%cl
80104fb4:	88 4a ff             	mov    %cl,-0x1(%edx)
80104fb7:	74 09                	je     80104fc2 <strncpy+0x32>
80104fb9:	89 f1                	mov    %esi,%ecx
80104fbb:	85 c9                	test   %ecx,%ecx
80104fbd:	8d 71 ff             	lea    -0x1(%ecx),%esi
80104fc0:	7f e6                	jg     80104fa8 <strncpy+0x18>
    ;
  while(n-- > 0)
80104fc2:	31 c9                	xor    %ecx,%ecx
80104fc4:	85 f6                	test   %esi,%esi
80104fc6:	7e 17                	jle    80104fdf <strncpy+0x4f>
80104fc8:	90                   	nop
80104fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104fd0:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
80104fd4:	89 f3                	mov    %esi,%ebx
80104fd6:	83 c1 01             	add    $0x1,%ecx
80104fd9:	29 cb                	sub    %ecx,%ebx
  while(n-- > 0)
80104fdb:	85 db                	test   %ebx,%ebx
80104fdd:	7f f1                	jg     80104fd0 <strncpy+0x40>
  return os;
}
80104fdf:	5b                   	pop    %ebx
80104fe0:	5e                   	pop    %esi
80104fe1:	5d                   	pop    %ebp
80104fe2:	c3                   	ret    
80104fe3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104fe9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ff0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ff0:	55                   	push   %ebp
80104ff1:	89 e5                	mov    %esp,%ebp
80104ff3:	56                   	push   %esi
80104ff4:	53                   	push   %ebx
80104ff5:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104ffe:	85 c9                	test   %ecx,%ecx
80105000:	7e 26                	jle    80105028 <safestrcpy+0x38>
80105002:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
80105006:	89 c1                	mov    %eax,%ecx
80105008:	eb 17                	jmp    80105021 <safestrcpy+0x31>
8010500a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80105010:	83 c2 01             	add    $0x1,%edx
80105013:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
80105017:	83 c1 01             	add    $0x1,%ecx
8010501a:	84 db                	test   %bl,%bl
8010501c:	88 59 ff             	mov    %bl,-0x1(%ecx)
8010501f:	74 04                	je     80105025 <safestrcpy+0x35>
80105021:	39 f2                	cmp    %esi,%edx
80105023:	75 eb                	jne    80105010 <safestrcpy+0x20>
    ;
  *s = 0;
80105025:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80105028:	5b                   	pop    %ebx
80105029:	5e                   	pop    %esi
8010502a:	5d                   	pop    %ebp
8010502b:	c3                   	ret    
8010502c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105030 <strlen>:

int
strlen(const char *s)
{
80105030:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80105031:	31 c0                	xor    %eax,%eax
{
80105033:	89 e5                	mov    %esp,%ebp
80105035:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80105038:	80 3a 00             	cmpb   $0x0,(%edx)
8010503b:	74 0c                	je     80105049 <strlen+0x19>
8010503d:	8d 76 00             	lea    0x0(%esi),%esi
80105040:	83 c0 01             	add    $0x1,%eax
80105043:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80105047:	75 f7                	jne    80105040 <strlen+0x10>
    ;
  return n;
}
80105049:	5d                   	pop    %ebp
8010504a:	c3                   	ret    

8010504b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010504b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010504f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105053:	55                   	push   %ebp
  pushl %ebx
80105054:	53                   	push   %ebx
  pushl %esi
80105055:	56                   	push   %esi
  pushl %edi
80105056:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105057:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105059:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010505b:	5f                   	pop    %edi
  popl %esi
8010505c:	5e                   	pop    %esi
  popl %ebx
8010505d:	5b                   	pop    %ebx
  popl %ebp
8010505e:	5d                   	pop    %ebp
  ret
8010505f:	c3                   	ret    

80105060 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105060:	55                   	push   %ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105061:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
80105068:	89 e5                	mov    %esp,%ebp
8010506a:	8b 45 08             	mov    0x8(%ebp),%eax
  if(addr >= proc->sz || addr+4 > proc->sz)
8010506d:	8b 12                	mov    (%edx),%edx
8010506f:	39 c2                	cmp    %eax,%edx
80105071:	76 15                	jbe    80105088 <fetchint+0x28>
80105073:	8d 48 04             	lea    0x4(%eax),%ecx
80105076:	39 ca                	cmp    %ecx,%edx
80105078:	72 0e                	jb     80105088 <fetchint+0x28>
    return -1;
  *ip = *(int*)(addr);
8010507a:	8b 10                	mov    (%eax),%edx
8010507c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010507f:	89 10                	mov    %edx,(%eax)
  return 0;
80105081:	31 c0                	xor    %eax,%eax
}
80105083:	5d                   	pop    %ebp
80105084:	c3                   	ret    
80105085:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105088:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010508d:	5d                   	pop    %ebp
8010508e:	c3                   	ret    
8010508f:	90                   	nop

80105090 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105090:	55                   	push   %ebp
  char *s, *ep;

  if(addr >= proc->sz)
80105091:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80105097:	89 e5                	mov    %esp,%ebp
80105099:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz)
8010509c:	39 08                	cmp    %ecx,(%eax)
8010509e:	76 2c                	jbe    801050cc <fetchstr+0x3c>
    return -1;
  *pp = (char*)addr;
801050a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801050a3:	89 c8                	mov    %ecx,%eax
801050a5:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
801050a7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050ae:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
801050b0:	39 d1                	cmp    %edx,%ecx
801050b2:	73 18                	jae    801050cc <fetchstr+0x3c>
    if(*s == 0)
801050b4:	80 39 00             	cmpb   $0x0,(%ecx)
801050b7:	75 0c                	jne    801050c5 <fetchstr+0x35>
801050b9:	eb 25                	jmp    801050e0 <fetchstr+0x50>
801050bb:	90                   	nop
801050bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801050c0:	80 38 00             	cmpb   $0x0,(%eax)
801050c3:	74 13                	je     801050d8 <fetchstr+0x48>
  for(s = *pp; s < ep; s++)
801050c5:	83 c0 01             	add    $0x1,%eax
801050c8:	39 c2                	cmp    %eax,%edx
801050ca:	77 f4                	ja     801050c0 <fetchstr+0x30>
    return -1;
801050cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return s - *pp;
  return -1;
}
801050d1:	5d                   	pop    %ebp
801050d2:	c3                   	ret    
801050d3:	90                   	nop
801050d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801050d8:	29 c8                	sub    %ecx,%eax
801050da:	5d                   	pop    %ebp
801050db:	c3                   	ret    
801050dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
801050e0:	31 c0                	xor    %eax,%eax
}
801050e2:	5d                   	pop    %ebp
801050e3:	c3                   	ret    
801050e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801050ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801050f0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801050f0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
{
801050f7:	55                   	push   %ebp
801050f8:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801050fa:	8b 82 9c 00 00 00    	mov    0x9c(%edx),%eax
80105100:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80105103:	8b 12                	mov    (%edx),%edx
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105105:	8b 40 44             	mov    0x44(%eax),%eax
80105108:	8d 04 88             	lea    (%eax,%ecx,4),%eax
8010510b:	8d 48 04             	lea    0x4(%eax),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
8010510e:	39 d1                	cmp    %edx,%ecx
80105110:	73 16                	jae    80105128 <argint+0x38>
80105112:	8d 48 08             	lea    0x8(%eax),%ecx
80105115:	39 ca                	cmp    %ecx,%edx
80105117:	72 0f                	jb     80105128 <argint+0x38>
  *ip = *(int*)(addr);
80105119:	8b 50 04             	mov    0x4(%eax),%edx
8010511c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511f:	89 10                	mov    %edx,(%eax)
  return 0;
80105121:	31 c0                	xor    %eax,%eax
}
80105123:	5d                   	pop    %ebp
80105124:	c3                   	ret    
80105125:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105128:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010512d:	5d                   	pop    %ebp
8010512e:	c3                   	ret    
8010512f:	90                   	nop

80105130 <argptr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105130:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105136:	55                   	push   %ebp
80105137:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105139:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
8010513f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80105142:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105144:	8b 52 44             	mov    0x44(%edx),%edx
80105147:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
8010514a:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
8010514d:	39 c1                	cmp    %eax,%ecx
8010514f:	73 27                	jae    80105178 <argptr+0x48>
80105151:	8d 4a 08             	lea    0x8(%edx),%ecx
80105154:	39 c8                	cmp    %ecx,%eax
80105156:	72 20                	jb     80105178 <argptr+0x48>
  *ip = *(int*)(addr);
80105158:	8b 52 04             	mov    0x4(%edx),%edx
  int i;

  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010515b:	39 c2                	cmp    %eax,%edx
8010515d:	73 19                	jae    80105178 <argptr+0x48>
8010515f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80105162:	01 d1                	add    %edx,%ecx
80105164:	39 c1                	cmp    %eax,%ecx
80105166:	77 10                	ja     80105178 <argptr+0x48>
    return -1;
  *pp = (char*)i;
80105168:	8b 45 0c             	mov    0xc(%ebp),%eax
8010516b:	89 10                	mov    %edx,(%eax)
  return 0;
8010516d:	31 c0                	xor    %eax,%eax
}
8010516f:	5d                   	pop    %ebp
80105170:	c3                   	ret    
80105171:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010517d:	5d                   	pop    %ebp
8010517e:	c3                   	ret    
8010517f:	90                   	nop

80105180 <argstr>:
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105180:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105186:	55                   	push   %ebp
80105187:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105189:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
8010518f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
80105192:	8b 00                	mov    (%eax),%eax
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105194:	8b 52 44             	mov    0x44(%edx),%edx
80105197:	8d 14 8a             	lea    (%edx,%ecx,4),%edx
8010519a:	8d 4a 04             	lea    0x4(%edx),%ecx
  if(addr >= proc->sz || addr+4 > proc->sz)
8010519d:	39 c1                	cmp    %eax,%ecx
8010519f:	73 3b                	jae    801051dc <argstr+0x5c>
801051a1:	8d 4a 08             	lea    0x8(%edx),%ecx
801051a4:	39 c8                	cmp    %ecx,%eax
801051a6:	72 34                	jb     801051dc <argstr+0x5c>
  *ip = *(int*)(addr);
801051a8:	8b 4a 04             	mov    0x4(%edx),%ecx
  if(addr >= proc->sz)
801051ab:	39 c1                	cmp    %eax,%ecx
801051ad:	73 2d                	jae    801051dc <argstr+0x5c>
  *pp = (char*)addr;
801051af:	8b 55 0c             	mov    0xc(%ebp),%edx
801051b2:	89 c8                	mov    %ecx,%eax
801051b4:	89 0a                	mov    %ecx,(%edx)
  ep = (char*)proc->sz;
801051b6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801051bd:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
801051bf:	39 d1                	cmp    %edx,%ecx
801051c1:	73 19                	jae    801051dc <argstr+0x5c>
    if(*s == 0)
801051c3:	80 39 00             	cmpb   $0x0,(%ecx)
801051c6:	75 0d                	jne    801051d5 <argstr+0x55>
801051c8:	eb 26                	jmp    801051f0 <argstr+0x70>
801051ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801051d0:	80 38 00             	cmpb   $0x0,(%eax)
801051d3:	74 13                	je     801051e8 <argstr+0x68>
  for(s = *pp; s < ep; s++)
801051d5:	83 c0 01             	add    $0x1,%eax
801051d8:	39 c2                	cmp    %eax,%edx
801051da:	77 f4                	ja     801051d0 <argstr+0x50>
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
801051dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchstr(addr, pp);
}
801051e1:	5d                   	pop    %ebp
801051e2:	c3                   	ret    
801051e3:	90                   	nop
801051e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801051e8:	29 c8                	sub    %ecx,%eax
801051ea:	5d                   	pop    %ebp
801051eb:	c3                   	ret    
801051ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
801051f0:	31 c0                	xor    %eax,%eax
}
801051f2:	5d                   	pop    %ebp
801051f3:	c3                   	ret    
801051f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801051fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80105200 <syscall>:
[SYS_chpri]     sys_chpri,
};

void
syscall(void)
{
80105200:	55                   	push   %ebp
80105201:	89 e5                	mov    %esp,%ebp
80105203:	83 ec 08             	sub    $0x8,%esp
  int num;

  num = proc->tf->eax;
80105206:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010520d:	8b 82 9c 00 00 00    	mov    0x9c(%edx),%eax
80105213:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105216:	8d 48 ff             	lea    -0x1(%eax),%ecx
80105219:	83 f9 1b             	cmp    $0x1b,%ecx
8010521c:	77 22                	ja     80105240 <syscall+0x40>
8010521e:	8b 0c 85 00 84 10 80 	mov    -0x7fef7c00(,%eax,4),%ecx
80105225:	85 c9                	test   %ecx,%ecx
80105227:	74 17                	je     80105240 <syscall+0x40>
    proc->tf->eax = syscalls[num]();
80105229:	ff d1                	call   *%ecx
8010522b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105232:	8b 92 9c 00 00 00    	mov    0x9c(%edx),%edx
80105238:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
8010523b:	c9                   	leave  
8010523c:	c3                   	ret    
8010523d:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80105240:	50                   	push   %eax
            proc->pid, proc->name, num);
80105241:	8d 82 f0 00 00 00    	lea    0xf0(%edx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80105247:	50                   	push   %eax
80105248:	ff 72 10             	pushl  0x10(%edx)
8010524b:	68 de 83 10 80       	push   $0x801083de
80105250:	e8 eb b3 ff ff       	call   80100640 <cprintf>
    proc->tf->eax = -1;
80105255:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010525b:	83 c4 10             	add    $0x10,%esp
8010525e:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80105264:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
8010526b:	c9                   	leave  
8010526c:	c3                   	ret    
8010526d:	66 90                	xchg   %ax,%ax
8010526f:	90                   	nop

80105270 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80105270:	55                   	push   %ebp
80105271:	89 e5                	mov    %esp,%ebp
80105273:	57                   	push   %edi
80105274:	56                   	push   %esi
80105275:	53                   	push   %ebx
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105276:	8d 75 da             	lea    -0x26(%ebp),%esi
{
80105279:	83 ec 44             	sub    $0x44,%esp
8010527c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
8010527f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80105282:	56                   	push   %esi
80105283:	50                   	push   %eax
{
80105284:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80105287:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  if((dp = nameiparent(path, name)) == 0)
8010528a:	e8 61 cc ff ff       	call   80101ef0 <nameiparent>
8010528f:	83 c4 10             	add    $0x10,%esp
80105292:	85 c0                	test   %eax,%eax
80105294:	0f 84 46 01 00 00    	je     801053e0 <create+0x170>
    return 0;
  ilock(dp);
8010529a:	83 ec 0c             	sub    $0xc,%esp
8010529d:	89 c3                	mov    %eax,%ebx
8010529f:	50                   	push   %eax
801052a0:	e8 7b c3 ff ff       	call   80101620 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801052a5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
801052a8:	83 c4 0c             	add    $0xc,%esp
801052ab:	50                   	push   %eax
801052ac:	56                   	push   %esi
801052ad:	53                   	push   %ebx
801052ae:	e8 dd c8 ff ff       	call   80101b90 <dirlookup>
801052b3:	83 c4 10             	add    $0x10,%esp
801052b6:	85 c0                	test   %eax,%eax
801052b8:	89 c7                	mov    %eax,%edi
801052ba:	74 34                	je     801052f0 <create+0x80>
    iunlockput(dp);
801052bc:	83 ec 0c             	sub    $0xc,%esp
801052bf:	53                   	push   %ebx
801052c0:	e8 2b c6 ff ff       	call   801018f0 <iunlockput>
    ilock(ip);
801052c5:	89 3c 24             	mov    %edi,(%esp)
801052c8:	e8 53 c3 ff ff       	call   80101620 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801052cd:	83 c4 10             	add    $0x10,%esp
801052d0:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801052d5:	0f 85 95 00 00 00    	jne    80105370 <create+0x100>
801052db:	66 83 7f 10 02       	cmpw   $0x2,0x10(%edi)
801052e0:	0f 85 8a 00 00 00    	jne    80105370 <create+0x100>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801052e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801052e9:	89 f8                	mov    %edi,%eax
801052eb:	5b                   	pop    %ebx
801052ec:	5e                   	pop    %esi
801052ed:	5f                   	pop    %edi
801052ee:	5d                   	pop    %ebp
801052ef:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
801052f0:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801052f4:	83 ec 08             	sub    $0x8,%esp
801052f7:	50                   	push   %eax
801052f8:	ff 33                	pushl  (%ebx)
801052fa:	e8 b1 c1 ff ff       	call   801014b0 <ialloc>
801052ff:	83 c4 10             	add    $0x10,%esp
80105302:	85 c0                	test   %eax,%eax
80105304:	89 c7                	mov    %eax,%edi
80105306:	0f 84 e8 00 00 00    	je     801053f4 <create+0x184>
  ilock(ip);
8010530c:	83 ec 0c             	sub    $0xc,%esp
8010530f:	50                   	push   %eax
80105310:	e8 0b c3 ff ff       	call   80101620 <ilock>
  ip->major = major;
80105315:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80105319:	66 89 47 12          	mov    %ax,0x12(%edi)
  ip->minor = minor;
8010531d:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
80105321:	66 89 47 14          	mov    %ax,0x14(%edi)
  ip->nlink = 1;
80105325:	b8 01 00 00 00       	mov    $0x1,%eax
8010532a:	66 89 47 16          	mov    %ax,0x16(%edi)
  iupdate(ip);
8010532e:	89 3c 24             	mov    %edi,(%esp)
80105331:	e8 3a c2 ff ff       	call   80101570 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80105336:	83 c4 10             	add    $0x10,%esp
80105339:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010533e:	74 50                	je     80105390 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80105340:	83 ec 04             	sub    $0x4,%esp
80105343:	ff 77 04             	pushl  0x4(%edi)
80105346:	56                   	push   %esi
80105347:	53                   	push   %ebx
80105348:	e8 c3 ca ff ff       	call   80101e10 <dirlink>
8010534d:	83 c4 10             	add    $0x10,%esp
80105350:	85 c0                	test   %eax,%eax
80105352:	0f 88 8f 00 00 00    	js     801053e7 <create+0x177>
  iunlockput(dp);
80105358:	83 ec 0c             	sub    $0xc,%esp
8010535b:	53                   	push   %ebx
8010535c:	e8 8f c5 ff ff       	call   801018f0 <iunlockput>
  return ip;
80105361:	83 c4 10             	add    $0x10,%esp
}
80105364:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105367:	89 f8                	mov    %edi,%eax
80105369:	5b                   	pop    %ebx
8010536a:	5e                   	pop    %esi
8010536b:	5f                   	pop    %edi
8010536c:	5d                   	pop    %ebp
8010536d:	c3                   	ret    
8010536e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80105370:	83 ec 0c             	sub    $0xc,%esp
80105373:	57                   	push   %edi
    return 0;
80105374:	31 ff                	xor    %edi,%edi
    iunlockput(ip);
80105376:	e8 75 c5 ff ff       	call   801018f0 <iunlockput>
    return 0;
8010537b:	83 c4 10             	add    $0x10,%esp
}
8010537e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105381:	89 f8                	mov    %edi,%eax
80105383:	5b                   	pop    %ebx
80105384:	5e                   	pop    %esi
80105385:	5f                   	pop    %edi
80105386:	5d                   	pop    %ebp
80105387:	c3                   	ret    
80105388:	90                   	nop
80105389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink++;  // for ".."
80105390:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
    iupdate(dp);
80105395:	83 ec 0c             	sub    $0xc,%esp
80105398:	53                   	push   %ebx
80105399:	e8 d2 c1 ff ff       	call   80101570 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010539e:	83 c4 0c             	add    $0xc,%esp
801053a1:	ff 77 04             	pushl  0x4(%edi)
801053a4:	68 90 84 10 80       	push   $0x80108490
801053a9:	57                   	push   %edi
801053aa:	e8 61 ca ff ff       	call   80101e10 <dirlink>
801053af:	83 c4 10             	add    $0x10,%esp
801053b2:	85 c0                	test   %eax,%eax
801053b4:	78 1c                	js     801053d2 <create+0x162>
801053b6:	83 ec 04             	sub    $0x4,%esp
801053b9:	ff 73 04             	pushl  0x4(%ebx)
801053bc:	68 8f 84 10 80       	push   $0x8010848f
801053c1:	57                   	push   %edi
801053c2:	e8 49 ca ff ff       	call   80101e10 <dirlink>
801053c7:	83 c4 10             	add    $0x10,%esp
801053ca:	85 c0                	test   %eax,%eax
801053cc:	0f 89 6e ff ff ff    	jns    80105340 <create+0xd0>
      panic("create dots");
801053d2:	83 ec 0c             	sub    $0xc,%esp
801053d5:	68 83 84 10 80       	push   $0x80108483
801053da:	e8 91 af ff ff       	call   80100370 <panic>
801053df:	90                   	nop
    return 0;
801053e0:	31 ff                	xor    %edi,%edi
801053e2:	e9 ff fe ff ff       	jmp    801052e6 <create+0x76>
    panic("create: dirlink");
801053e7:	83 ec 0c             	sub    $0xc,%esp
801053ea:	68 92 84 10 80       	push   $0x80108492
801053ef:	e8 7c af ff ff       	call   80100370 <panic>
    panic("create: ialloc");
801053f4:	83 ec 0c             	sub    $0xc,%esp
801053f7:	68 74 84 10 80       	push   $0x80108474
801053fc:	e8 6f af ff ff       	call   80100370 <panic>
80105401:	eb 0d                	jmp    80105410 <argfd.constprop.0>
80105403:	90                   	nop
80105404:	90                   	nop
80105405:	90                   	nop
80105406:	90                   	nop
80105407:	90                   	nop
80105408:	90                   	nop
80105409:	90                   	nop
8010540a:	90                   	nop
8010540b:	90                   	nop
8010540c:	90                   	nop
8010540d:	90                   	nop
8010540e:	90                   	nop
8010540f:	90                   	nop

80105410 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	56                   	push   %esi
80105414:	53                   	push   %ebx
80105415:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
80105417:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
8010541a:	89 d6                	mov    %edx,%esi
8010541c:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010541f:	50                   	push   %eax
80105420:	6a 00                	push   $0x0
80105422:	e8 c9 fc ff ff       	call   801050f0 <argint>
80105427:	83 c4 10             	add    $0x10,%esp
8010542a:	85 c0                	test   %eax,%eax
8010542c:	78 32                	js     80105460 <argfd.constprop.0+0x50>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010542e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105431:	83 f8 0f             	cmp    $0xf,%eax
80105434:	77 2a                	ja     80105460 <argfd.constprop.0+0x50>
80105436:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010543d:	8b 8c 82 ac 00 00 00 	mov    0xac(%edx,%eax,4),%ecx
80105444:	85 c9                	test   %ecx,%ecx
80105446:	74 18                	je     80105460 <argfd.constprop.0+0x50>
  if(pfd)
80105448:	85 db                	test   %ebx,%ebx
8010544a:	74 02                	je     8010544e <argfd.constprop.0+0x3e>
    *pfd = fd;
8010544c:	89 03                	mov    %eax,(%ebx)
    *pf = f;
8010544e:	89 0e                	mov    %ecx,(%esi)
  return 0;
80105450:	31 c0                	xor    %eax,%eax
}
80105452:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105455:	5b                   	pop    %ebx
80105456:	5e                   	pop    %esi
80105457:	5d                   	pop    %ebp
80105458:	c3                   	ret    
80105459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105460:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105465:	eb eb                	jmp    80105452 <argfd.constprop.0+0x42>
80105467:	89 f6                	mov    %esi,%esi
80105469:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105470 <sys_dup>:
{
80105470:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
80105471:	31 c0                	xor    %eax,%eax
{
80105473:	89 e5                	mov    %esp,%ebp
80105475:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
80105476:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
80105479:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010547c:	e8 8f ff ff ff       	call   80105410 <argfd.constprop.0>
80105481:	85 c0                	test   %eax,%eax
80105483:	78 43                	js     801054c8 <sys_dup+0x58>
  if((fd=fdalloc(f)) < 0)
80105485:	8b 55 f4             	mov    -0xc(%ebp),%edx
    if(proc->ofile[fd] == 0){
80105488:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  for(fd = 0; fd < NOFILE; fd++){
8010548e:	31 db                	xor    %ebx,%ebx
80105490:	eb 0e                	jmp    801054a0 <sys_dup+0x30>
80105492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105498:	83 c3 01             	add    $0x1,%ebx
8010549b:	83 fb 10             	cmp    $0x10,%ebx
8010549e:	74 28                	je     801054c8 <sys_dup+0x58>
    if(proc->ofile[fd] == 0){
801054a0:	8b 8c 98 ac 00 00 00 	mov    0xac(%eax,%ebx,4),%ecx
801054a7:	85 c9                	test   %ecx,%ecx
801054a9:	75 ed                	jne    80105498 <sys_dup+0x28>
  filedup(f);
801054ab:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
801054ae:	89 94 98 ac 00 00 00 	mov    %edx,0xac(%eax,%ebx,4)
  filedup(f);
801054b5:	52                   	push   %edx
801054b6:	e8 15 b9 ff ff       	call   80100dd0 <filedup>
}
801054bb:	89 d8                	mov    %ebx,%eax
  return fd;
801054bd:	83 c4 10             	add    $0x10,%esp
}
801054c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801054c3:	c9                   	leave  
801054c4:	c3                   	ret    
801054c5:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
801054c8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
801054cd:	89 d8                	mov    %ebx,%eax
801054cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801054d2:	c9                   	leave  
801054d3:	c3                   	ret    
801054d4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801054da:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801054e0 <sys_read>:
{
801054e0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801054e1:	31 c0                	xor    %eax,%eax
{
801054e3:	89 e5                	mov    %esp,%ebp
801054e5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801054e8:	8d 55 ec             	lea    -0x14(%ebp),%edx
801054eb:	e8 20 ff ff ff       	call   80105410 <argfd.constprop.0>
801054f0:	85 c0                	test   %eax,%eax
801054f2:	78 4c                	js     80105540 <sys_read+0x60>
801054f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054f7:	83 ec 08             	sub    $0x8,%esp
801054fa:	50                   	push   %eax
801054fb:	6a 02                	push   $0x2
801054fd:	e8 ee fb ff ff       	call   801050f0 <argint>
80105502:	83 c4 10             	add    $0x10,%esp
80105505:	85 c0                	test   %eax,%eax
80105507:	78 37                	js     80105540 <sys_read+0x60>
80105509:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010550c:	83 ec 04             	sub    $0x4,%esp
8010550f:	ff 75 f0             	pushl  -0x10(%ebp)
80105512:	50                   	push   %eax
80105513:	6a 01                	push   $0x1
80105515:	e8 16 fc ff ff       	call   80105130 <argptr>
8010551a:	83 c4 10             	add    $0x10,%esp
8010551d:	85 c0                	test   %eax,%eax
8010551f:	78 1f                	js     80105540 <sys_read+0x60>
  return fileread(f, p, n);
80105521:	83 ec 04             	sub    $0x4,%esp
80105524:	ff 75 f0             	pushl  -0x10(%ebp)
80105527:	ff 75 f4             	pushl  -0xc(%ebp)
8010552a:	ff 75 ec             	pushl  -0x14(%ebp)
8010552d:	e8 0e ba ff ff       	call   80100f40 <fileread>
80105532:	83 c4 10             	add    $0x10,%esp
}
80105535:	c9                   	leave  
80105536:	c3                   	ret    
80105537:	89 f6                	mov    %esi,%esi
80105539:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105540:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105545:	c9                   	leave  
80105546:	c3                   	ret    
80105547:	89 f6                	mov    %esi,%esi
80105549:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105550 <sys_write>:
{
80105550:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105551:	31 c0                	xor    %eax,%eax
{
80105553:	89 e5                	mov    %esp,%ebp
80105555:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105558:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010555b:	e8 b0 fe ff ff       	call   80105410 <argfd.constprop.0>
80105560:	85 c0                	test   %eax,%eax
80105562:	78 4c                	js     801055b0 <sys_write+0x60>
80105564:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105567:	83 ec 08             	sub    $0x8,%esp
8010556a:	50                   	push   %eax
8010556b:	6a 02                	push   $0x2
8010556d:	e8 7e fb ff ff       	call   801050f0 <argint>
80105572:	83 c4 10             	add    $0x10,%esp
80105575:	85 c0                	test   %eax,%eax
80105577:	78 37                	js     801055b0 <sys_write+0x60>
80105579:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010557c:	83 ec 04             	sub    $0x4,%esp
8010557f:	ff 75 f0             	pushl  -0x10(%ebp)
80105582:	50                   	push   %eax
80105583:	6a 01                	push   $0x1
80105585:	e8 a6 fb ff ff       	call   80105130 <argptr>
8010558a:	83 c4 10             	add    $0x10,%esp
8010558d:	85 c0                	test   %eax,%eax
8010558f:	78 1f                	js     801055b0 <sys_write+0x60>
  return filewrite(f, p, n);
80105591:	83 ec 04             	sub    $0x4,%esp
80105594:	ff 75 f0             	pushl  -0x10(%ebp)
80105597:	ff 75 f4             	pushl  -0xc(%ebp)
8010559a:	ff 75 ec             	pushl  -0x14(%ebp)
8010559d:	e8 2e ba ff ff       	call   80100fd0 <filewrite>
801055a2:	83 c4 10             	add    $0x10,%esp
}
801055a5:	c9                   	leave  
801055a6:	c3                   	ret    
801055a7:	89 f6                	mov    %esi,%esi
801055a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
801055b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055b5:	c9                   	leave  
801055b6:	c3                   	ret    
801055b7:	89 f6                	mov    %esi,%esi
801055b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801055c0 <sys_close>:
{
801055c0:	55                   	push   %ebp
801055c1:	89 e5                	mov    %esp,%ebp
801055c3:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801055c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
801055c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055cc:	e8 3f fe ff ff       	call   80105410 <argfd.constprop.0>
801055d1:	85 c0                	test   %eax,%eax
801055d3:	78 2b                	js     80105600 <sys_close+0x40>
  proc->ofile[fd] = 0;
801055d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
801055de:	83 ec 0c             	sub    $0xc,%esp
  proc->ofile[fd] = 0;
801055e1:	c7 84 90 ac 00 00 00 	movl   $0x0,0xac(%eax,%edx,4)
801055e8:	00 00 00 00 
  fileclose(f);
801055ec:	ff 75 f4             	pushl  -0xc(%ebp)
801055ef:	e8 2c b8 ff ff       	call   80100e20 <fileclose>
  return 0;
801055f4:	83 c4 10             	add    $0x10,%esp
801055f7:	31 c0                	xor    %eax,%eax
}
801055f9:	c9                   	leave  
801055fa:	c3                   	ret    
801055fb:	90                   	nop
801055fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105605:	c9                   	leave  
80105606:	c3                   	ret    
80105607:	89 f6                	mov    %esi,%esi
80105609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105610 <sys_fstat>:
{
80105610:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105611:	31 c0                	xor    %eax,%eax
{
80105613:	89 e5                	mov    %esp,%ebp
80105615:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105618:	8d 55 f0             	lea    -0x10(%ebp),%edx
8010561b:	e8 f0 fd ff ff       	call   80105410 <argfd.constprop.0>
80105620:	85 c0                	test   %eax,%eax
80105622:	78 2c                	js     80105650 <sys_fstat+0x40>
80105624:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105627:	83 ec 04             	sub    $0x4,%esp
8010562a:	6a 14                	push   $0x14
8010562c:	50                   	push   %eax
8010562d:	6a 01                	push   $0x1
8010562f:	e8 fc fa ff ff       	call   80105130 <argptr>
80105634:	83 c4 10             	add    $0x10,%esp
80105637:	85 c0                	test   %eax,%eax
80105639:	78 15                	js     80105650 <sys_fstat+0x40>
  return filestat(f, st);
8010563b:	83 ec 08             	sub    $0x8,%esp
8010563e:	ff 75 f4             	pushl  -0xc(%ebp)
80105641:	ff 75 f0             	pushl  -0x10(%ebp)
80105644:	e8 a7 b8 ff ff       	call   80100ef0 <filestat>
80105649:	83 c4 10             	add    $0x10,%esp
}
8010564c:	c9                   	leave  
8010564d:	c3                   	ret    
8010564e:	66 90                	xchg   %ax,%ax
    return -1;
80105650:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105655:	c9                   	leave  
80105656:	c3                   	ret    
80105657:	89 f6                	mov    %esi,%esi
80105659:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105660 <sys_link>:
{
80105660:	55                   	push   %ebp
80105661:	89 e5                	mov    %esp,%ebp
80105663:	57                   	push   %edi
80105664:	56                   	push   %esi
80105665:	53                   	push   %ebx
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105666:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105669:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010566c:	50                   	push   %eax
8010566d:	6a 00                	push   $0x0
8010566f:	e8 0c fb ff ff       	call   80105180 <argstr>
80105674:	83 c4 10             	add    $0x10,%esp
80105677:	85 c0                	test   %eax,%eax
80105679:	0f 88 fb 00 00 00    	js     8010577a <sys_link+0x11a>
8010567f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105682:	83 ec 08             	sub    $0x8,%esp
80105685:	50                   	push   %eax
80105686:	6a 01                	push   $0x1
80105688:	e8 f3 fa ff ff       	call   80105180 <argstr>
8010568d:	83 c4 10             	add    $0x10,%esp
80105690:	85 c0                	test   %eax,%eax
80105692:	0f 88 e2 00 00 00    	js     8010577a <sys_link+0x11a>
  begin_op();
80105698:	e8 a3 d5 ff ff       	call   80102c40 <begin_op>
  if((ip = namei(old)) == 0){
8010569d:	83 ec 0c             	sub    $0xc,%esp
801056a0:	ff 75 d4             	pushl  -0x2c(%ebp)
801056a3:	e8 28 c8 ff ff       	call   80101ed0 <namei>
801056a8:	83 c4 10             	add    $0x10,%esp
801056ab:	85 c0                	test   %eax,%eax
801056ad:	89 c3                	mov    %eax,%ebx
801056af:	0f 84 ea 00 00 00    	je     8010579f <sys_link+0x13f>
  ilock(ip);
801056b5:	83 ec 0c             	sub    $0xc,%esp
801056b8:	50                   	push   %eax
801056b9:	e8 62 bf ff ff       	call   80101620 <ilock>
  if(ip->type == T_DIR){
801056be:	83 c4 10             	add    $0x10,%esp
801056c1:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
801056c6:	0f 84 bb 00 00 00    	je     80105787 <sys_link+0x127>
  ip->nlink++;
801056cc:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
801056d1:	83 ec 0c             	sub    $0xc,%esp
  if((dp = nameiparent(new, name)) == 0)
801056d4:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801056d7:	53                   	push   %ebx
801056d8:	e8 93 be ff ff       	call   80101570 <iupdate>
  iunlock(ip);
801056dd:	89 1c 24             	mov    %ebx,(%esp)
801056e0:	e8 4b c0 ff ff       	call   80101730 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801056e5:	58                   	pop    %eax
801056e6:	5a                   	pop    %edx
801056e7:	57                   	push   %edi
801056e8:	ff 75 d0             	pushl  -0x30(%ebp)
801056eb:	e8 00 c8 ff ff       	call   80101ef0 <nameiparent>
801056f0:	83 c4 10             	add    $0x10,%esp
801056f3:	85 c0                	test   %eax,%eax
801056f5:	89 c6                	mov    %eax,%esi
801056f7:	74 5b                	je     80105754 <sys_link+0xf4>
  ilock(dp);
801056f9:	83 ec 0c             	sub    $0xc,%esp
801056fc:	50                   	push   %eax
801056fd:	e8 1e bf ff ff       	call   80101620 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105702:	83 c4 10             	add    $0x10,%esp
80105705:	8b 03                	mov    (%ebx),%eax
80105707:	39 06                	cmp    %eax,(%esi)
80105709:	75 3d                	jne    80105748 <sys_link+0xe8>
8010570b:	83 ec 04             	sub    $0x4,%esp
8010570e:	ff 73 04             	pushl  0x4(%ebx)
80105711:	57                   	push   %edi
80105712:	56                   	push   %esi
80105713:	e8 f8 c6 ff ff       	call   80101e10 <dirlink>
80105718:	83 c4 10             	add    $0x10,%esp
8010571b:	85 c0                	test   %eax,%eax
8010571d:	78 29                	js     80105748 <sys_link+0xe8>
  iunlockput(dp);
8010571f:	83 ec 0c             	sub    $0xc,%esp
80105722:	56                   	push   %esi
80105723:	e8 c8 c1 ff ff       	call   801018f0 <iunlockput>
  iput(ip);
80105728:	89 1c 24             	mov    %ebx,(%esp)
8010572b:	e8 60 c0 ff ff       	call   80101790 <iput>
  end_op();
80105730:	e8 7b d5 ff ff       	call   80102cb0 <end_op>
  return 0;
80105735:	83 c4 10             	add    $0x10,%esp
80105738:	31 c0                	xor    %eax,%eax
}
8010573a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010573d:	5b                   	pop    %ebx
8010573e:	5e                   	pop    %esi
8010573f:	5f                   	pop    %edi
80105740:	5d                   	pop    %ebp
80105741:	c3                   	ret    
80105742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105748:	83 ec 0c             	sub    $0xc,%esp
8010574b:	56                   	push   %esi
8010574c:	e8 9f c1 ff ff       	call   801018f0 <iunlockput>
    goto bad;
80105751:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105754:	83 ec 0c             	sub    $0xc,%esp
80105757:	53                   	push   %ebx
80105758:	e8 c3 be ff ff       	call   80101620 <ilock>
  ip->nlink--;
8010575d:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
80105762:	89 1c 24             	mov    %ebx,(%esp)
80105765:	e8 06 be ff ff       	call   80101570 <iupdate>
  iunlockput(ip);
8010576a:	89 1c 24             	mov    %ebx,(%esp)
8010576d:	e8 7e c1 ff ff       	call   801018f0 <iunlockput>
  end_op();
80105772:	e8 39 d5 ff ff       	call   80102cb0 <end_op>
  return -1;
80105777:	83 c4 10             	add    $0x10,%esp
}
8010577a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010577d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105782:	5b                   	pop    %ebx
80105783:	5e                   	pop    %esi
80105784:	5f                   	pop    %edi
80105785:	5d                   	pop    %ebp
80105786:	c3                   	ret    
    iunlockput(ip);
80105787:	83 ec 0c             	sub    $0xc,%esp
8010578a:	53                   	push   %ebx
8010578b:	e8 60 c1 ff ff       	call   801018f0 <iunlockput>
    end_op();
80105790:	e8 1b d5 ff ff       	call   80102cb0 <end_op>
    return -1;
80105795:	83 c4 10             	add    $0x10,%esp
80105798:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579d:	eb 9b                	jmp    8010573a <sys_link+0xda>
    end_op();
8010579f:	e8 0c d5 ff ff       	call   80102cb0 <end_op>
    return -1;
801057a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a9:	eb 8f                	jmp    8010573a <sys_link+0xda>
801057ab:	90                   	nop
801057ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801057b0 <sys_unlink>:
{
801057b0:	55                   	push   %ebp
801057b1:	89 e5                	mov    %esp,%ebp
801057b3:	57                   	push   %edi
801057b4:	56                   	push   %esi
801057b5:	53                   	push   %ebx
  if(argstr(0, &path) < 0)
801057b6:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
801057b9:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801057bc:	50                   	push   %eax
801057bd:	6a 00                	push   $0x0
801057bf:	e8 bc f9 ff ff       	call   80105180 <argstr>
801057c4:	83 c4 10             	add    $0x10,%esp
801057c7:	85 c0                	test   %eax,%eax
801057c9:	0f 88 77 01 00 00    	js     80105946 <sys_unlink+0x196>
  if((dp = nameiparent(path, name)) == 0){
801057cf:	8d 5d ca             	lea    -0x36(%ebp),%ebx
  begin_op();
801057d2:	e8 69 d4 ff ff       	call   80102c40 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801057d7:	83 ec 08             	sub    $0x8,%esp
801057da:	53                   	push   %ebx
801057db:	ff 75 c0             	pushl  -0x40(%ebp)
801057de:	e8 0d c7 ff ff       	call   80101ef0 <nameiparent>
801057e3:	83 c4 10             	add    $0x10,%esp
801057e6:	85 c0                	test   %eax,%eax
801057e8:	89 c6                	mov    %eax,%esi
801057ea:	0f 84 60 01 00 00    	je     80105950 <sys_unlink+0x1a0>
  ilock(dp);
801057f0:	83 ec 0c             	sub    $0xc,%esp
801057f3:	50                   	push   %eax
801057f4:	e8 27 be ff ff       	call   80101620 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057f9:	58                   	pop    %eax
801057fa:	5a                   	pop    %edx
801057fb:	68 90 84 10 80       	push   $0x80108490
80105800:	53                   	push   %ebx
80105801:	e8 6a c3 ff ff       	call   80101b70 <namecmp>
80105806:	83 c4 10             	add    $0x10,%esp
80105809:	85 c0                	test   %eax,%eax
8010580b:	0f 84 03 01 00 00    	je     80105914 <sys_unlink+0x164>
80105811:	83 ec 08             	sub    $0x8,%esp
80105814:	68 8f 84 10 80       	push   $0x8010848f
80105819:	53                   	push   %ebx
8010581a:	e8 51 c3 ff ff       	call   80101b70 <namecmp>
8010581f:	83 c4 10             	add    $0x10,%esp
80105822:	85 c0                	test   %eax,%eax
80105824:	0f 84 ea 00 00 00    	je     80105914 <sys_unlink+0x164>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010582a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010582d:	83 ec 04             	sub    $0x4,%esp
80105830:	50                   	push   %eax
80105831:	53                   	push   %ebx
80105832:	56                   	push   %esi
80105833:	e8 58 c3 ff ff       	call   80101b90 <dirlookup>
80105838:	83 c4 10             	add    $0x10,%esp
8010583b:	85 c0                	test   %eax,%eax
8010583d:	89 c3                	mov    %eax,%ebx
8010583f:	0f 84 cf 00 00 00    	je     80105914 <sys_unlink+0x164>
  ilock(ip);
80105845:	83 ec 0c             	sub    $0xc,%esp
80105848:	50                   	push   %eax
80105849:	e8 d2 bd ff ff       	call   80101620 <ilock>
  if(ip->nlink < 1)
8010584e:	83 c4 10             	add    $0x10,%esp
80105851:	66 83 7b 16 00       	cmpw   $0x0,0x16(%ebx)
80105856:	0f 8e 10 01 00 00    	jle    8010596c <sys_unlink+0x1bc>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010585c:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105861:	74 6d                	je     801058d0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
80105863:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105866:	83 ec 04             	sub    $0x4,%esp
80105869:	6a 10                	push   $0x10
8010586b:	6a 00                	push   $0x0
8010586d:	50                   	push   %eax
8010586e:	e8 9d f5 ff ff       	call   80104e10 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105873:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105876:	6a 10                	push   $0x10
80105878:	ff 75 c4             	pushl  -0x3c(%ebp)
8010587b:	50                   	push   %eax
8010587c:	56                   	push   %esi
8010587d:	e8 be c1 ff ff       	call   80101a40 <writei>
80105882:	83 c4 20             	add    $0x20,%esp
80105885:	83 f8 10             	cmp    $0x10,%eax
80105888:	0f 85 eb 00 00 00    	jne    80105979 <sys_unlink+0x1c9>
  if(ip->type == T_DIR){
8010588e:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105893:	0f 84 97 00 00 00    	je     80105930 <sys_unlink+0x180>
  iunlockput(dp);
80105899:	83 ec 0c             	sub    $0xc,%esp
8010589c:	56                   	push   %esi
8010589d:	e8 4e c0 ff ff       	call   801018f0 <iunlockput>
  ip->nlink--;
801058a2:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
801058a7:	89 1c 24             	mov    %ebx,(%esp)
801058aa:	e8 c1 bc ff ff       	call   80101570 <iupdate>
  iunlockput(ip);
801058af:	89 1c 24             	mov    %ebx,(%esp)
801058b2:	e8 39 c0 ff ff       	call   801018f0 <iunlockput>
  end_op();
801058b7:	e8 f4 d3 ff ff       	call   80102cb0 <end_op>
  return 0;
801058bc:	83 c4 10             	add    $0x10,%esp
801058bf:	31 c0                	xor    %eax,%eax
}
801058c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801058c4:	5b                   	pop    %ebx
801058c5:	5e                   	pop    %esi
801058c6:	5f                   	pop    %edi
801058c7:	5d                   	pop    %ebp
801058c8:	c3                   	ret    
801058c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058d0:	83 7b 18 20          	cmpl   $0x20,0x18(%ebx)
801058d4:	76 8d                	jbe    80105863 <sys_unlink+0xb3>
801058d6:	bf 20 00 00 00       	mov    $0x20,%edi
801058db:	eb 0f                	jmp    801058ec <sys_unlink+0x13c>
801058dd:	8d 76 00             	lea    0x0(%esi),%esi
801058e0:	83 c7 10             	add    $0x10,%edi
801058e3:	3b 7b 18             	cmp    0x18(%ebx),%edi
801058e6:	0f 83 77 ff ff ff    	jae    80105863 <sys_unlink+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
801058ef:	6a 10                	push   $0x10
801058f1:	57                   	push   %edi
801058f2:	50                   	push   %eax
801058f3:	53                   	push   %ebx
801058f4:	e8 47 c0 ff ff       	call   80101940 <readi>
801058f9:	83 c4 10             	add    $0x10,%esp
801058fc:	83 f8 10             	cmp    $0x10,%eax
801058ff:	75 5e                	jne    8010595f <sys_unlink+0x1af>
    if(de.inum != 0)
80105901:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80105906:	74 d8                	je     801058e0 <sys_unlink+0x130>
    iunlockput(ip);
80105908:	83 ec 0c             	sub    $0xc,%esp
8010590b:	53                   	push   %ebx
8010590c:	e8 df bf ff ff       	call   801018f0 <iunlockput>
    goto bad;
80105911:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80105914:	83 ec 0c             	sub    $0xc,%esp
80105917:	56                   	push   %esi
80105918:	e8 d3 bf ff ff       	call   801018f0 <iunlockput>
  end_op();
8010591d:	e8 8e d3 ff ff       	call   80102cb0 <end_op>
  return -1;
80105922:	83 c4 10             	add    $0x10,%esp
80105925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592a:	eb 95                	jmp    801058c1 <sys_unlink+0x111>
8010592c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink--;
80105930:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
    iupdate(dp);
80105935:	83 ec 0c             	sub    $0xc,%esp
80105938:	56                   	push   %esi
80105939:	e8 32 bc ff ff       	call   80101570 <iupdate>
8010593e:	83 c4 10             	add    $0x10,%esp
80105941:	e9 53 ff ff ff       	jmp    80105899 <sys_unlink+0xe9>
    return -1;
80105946:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594b:	e9 71 ff ff ff       	jmp    801058c1 <sys_unlink+0x111>
    end_op();
80105950:	e8 5b d3 ff ff       	call   80102cb0 <end_op>
    return -1;
80105955:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595a:	e9 62 ff ff ff       	jmp    801058c1 <sys_unlink+0x111>
      panic("isdirempty: readi");
8010595f:	83 ec 0c             	sub    $0xc,%esp
80105962:	68 b4 84 10 80       	push   $0x801084b4
80105967:	e8 04 aa ff ff       	call   80100370 <panic>
    panic("unlink: nlink < 1");
8010596c:	83 ec 0c             	sub    $0xc,%esp
8010596f:	68 a2 84 10 80       	push   $0x801084a2
80105974:	e8 f7 a9 ff ff       	call   80100370 <panic>
    panic("unlink: writei");
80105979:	83 ec 0c             	sub    $0xc,%esp
8010597c:	68 c6 84 10 80       	push   $0x801084c6
80105981:	e8 ea a9 ff ff       	call   80100370 <panic>
80105986:	8d 76 00             	lea    0x0(%esi),%esi
80105989:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105990 <sys_open>:

int
sys_open(void)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	57                   	push   %edi
80105994:	56                   	push   %esi
80105995:	53                   	push   %ebx
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105996:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105999:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010599c:	50                   	push   %eax
8010599d:	6a 00                	push   $0x0
8010599f:	e8 dc f7 ff ff       	call   80105180 <argstr>
801059a4:	83 c4 10             	add    $0x10,%esp
801059a7:	85 c0                	test   %eax,%eax
801059a9:	0f 88 1d 01 00 00    	js     80105acc <sys_open+0x13c>
801059af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801059b2:	83 ec 08             	sub    $0x8,%esp
801059b5:	50                   	push   %eax
801059b6:	6a 01                	push   $0x1
801059b8:	e8 33 f7 ff ff       	call   801050f0 <argint>
801059bd:	83 c4 10             	add    $0x10,%esp
801059c0:	85 c0                	test   %eax,%eax
801059c2:	0f 88 04 01 00 00    	js     80105acc <sys_open+0x13c>
    return -1;

  begin_op();
801059c8:	e8 73 d2 ff ff       	call   80102c40 <begin_op>

  if(omode & O_CREATE){
801059cd:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801059d1:	0f 85 a9 00 00 00    	jne    80105a80 <sys_open+0xf0>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801059d7:	83 ec 0c             	sub    $0xc,%esp
801059da:	ff 75 e0             	pushl  -0x20(%ebp)
801059dd:	e8 ee c4 ff ff       	call   80101ed0 <namei>
801059e2:	83 c4 10             	add    $0x10,%esp
801059e5:	85 c0                	test   %eax,%eax
801059e7:	89 c6                	mov    %eax,%esi
801059e9:	0f 84 b2 00 00 00    	je     80105aa1 <sys_open+0x111>
      end_op();
      return -1;
    }
    ilock(ip);
801059ef:	83 ec 0c             	sub    $0xc,%esp
801059f2:	50                   	push   %eax
801059f3:	e8 28 bc ff ff       	call   80101620 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801059f8:	83 c4 10             	add    $0x10,%esp
801059fb:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
80105a00:	0f 84 aa 00 00 00    	je     80105ab0 <sys_open+0x120>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105a06:	e8 55 b3 ff ff       	call   80100d60 <filealloc>
80105a0b:	85 c0                	test   %eax,%eax
80105a0d:	89 c7                	mov    %eax,%edi
80105a0f:	0f 84 a6 00 00 00    	je     80105abb <sys_open+0x12b>
    if(proc->ofile[fd] == 0){
80105a15:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  for(fd = 0; fd < NOFILE; fd++){
80105a1c:	31 db                	xor    %ebx,%ebx
80105a1e:	eb 0c                	jmp    80105a2c <sys_open+0x9c>
80105a20:	83 c3 01             	add    $0x1,%ebx
80105a23:	83 fb 10             	cmp    $0x10,%ebx
80105a26:	0f 84 ac 00 00 00    	je     80105ad8 <sys_open+0x148>
    if(proc->ofile[fd] == 0){
80105a2c:	8b 84 9a ac 00 00 00 	mov    0xac(%edx,%ebx,4),%eax
80105a33:	85 c0                	test   %eax,%eax
80105a35:	75 e9                	jne    80105a20 <sys_open+0x90>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105a37:	83 ec 0c             	sub    $0xc,%esp
      proc->ofile[fd] = f;
80105a3a:	89 bc 9a ac 00 00 00 	mov    %edi,0xac(%edx,%ebx,4)
  iunlock(ip);
80105a41:	56                   	push   %esi
80105a42:	e8 e9 bc ff ff       	call   80101730 <iunlock>
  end_op();
80105a47:	e8 64 d2 ff ff       	call   80102cb0 <end_op>

  f->type = FD_INODE;
80105a4c:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105a52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105a55:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105a58:	89 77 10             	mov    %esi,0x10(%edi)
  f->off = 0;
80105a5b:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
80105a62:	89 d0                	mov    %edx,%eax
80105a64:	f7 d0                	not    %eax
80105a66:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105a69:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
80105a6c:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105a6f:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
80105a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105a76:	89 d8                	mov    %ebx,%eax
80105a78:	5b                   	pop    %ebx
80105a79:	5e                   	pop    %esi
80105a7a:	5f                   	pop    %edi
80105a7b:	5d                   	pop    %ebp
80105a7c:	c3                   	ret    
80105a7d:	8d 76 00             	lea    0x0(%esi),%esi
    ip = create(path, T_FILE, 0, 0);
80105a80:	83 ec 0c             	sub    $0xc,%esp
80105a83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105a86:	31 c9                	xor    %ecx,%ecx
80105a88:	6a 00                	push   $0x0
80105a8a:	ba 02 00 00 00       	mov    $0x2,%edx
80105a8f:	e8 dc f7 ff ff       	call   80105270 <create>
    if(ip == 0){
80105a94:	83 c4 10             	add    $0x10,%esp
80105a97:	85 c0                	test   %eax,%eax
    ip = create(path, T_FILE, 0, 0);
80105a99:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105a9b:	0f 85 65 ff ff ff    	jne    80105a06 <sys_open+0x76>
      end_op();
80105aa1:	e8 0a d2 ff ff       	call   80102cb0 <end_op>
      return -1;
80105aa6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105aab:	eb c6                	jmp    80105a73 <sys_open+0xe3>
80105aad:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ab0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105ab3:	85 d2                	test   %edx,%edx
80105ab5:	0f 84 4b ff ff ff    	je     80105a06 <sys_open+0x76>
    iunlockput(ip);
80105abb:	83 ec 0c             	sub    $0xc,%esp
80105abe:	56                   	push   %esi
80105abf:	e8 2c be ff ff       	call   801018f0 <iunlockput>
    end_op();
80105ac4:	e8 e7 d1 ff ff       	call   80102cb0 <end_op>
    return -1;
80105ac9:	83 c4 10             	add    $0x10,%esp
80105acc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105ad1:	eb a0                	jmp    80105a73 <sys_open+0xe3>
80105ad3:	90                   	nop
80105ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      fileclose(f);
80105ad8:	83 ec 0c             	sub    $0xc,%esp
80105adb:	57                   	push   %edi
80105adc:	e8 3f b3 ff ff       	call   80100e20 <fileclose>
80105ae1:	83 c4 10             	add    $0x10,%esp
80105ae4:	eb d5                	jmp    80105abb <sys_open+0x12b>
80105ae6:	8d 76 00             	lea    0x0(%esi),%esi
80105ae9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105af0 <sys_mkdir>:

int
sys_mkdir(void)
{
80105af0:	55                   	push   %ebp
80105af1:	89 e5                	mov    %esp,%ebp
80105af3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105af6:	e8 45 d1 ff ff       	call   80102c40 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105afb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105afe:	83 ec 08             	sub    $0x8,%esp
80105b01:	50                   	push   %eax
80105b02:	6a 00                	push   $0x0
80105b04:	e8 77 f6 ff ff       	call   80105180 <argstr>
80105b09:	83 c4 10             	add    $0x10,%esp
80105b0c:	85 c0                	test   %eax,%eax
80105b0e:	78 30                	js     80105b40 <sys_mkdir+0x50>
80105b10:	83 ec 0c             	sub    $0xc,%esp
80105b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b16:	31 c9                	xor    %ecx,%ecx
80105b18:	6a 00                	push   $0x0
80105b1a:	ba 01 00 00 00       	mov    $0x1,%edx
80105b1f:	e8 4c f7 ff ff       	call   80105270 <create>
80105b24:	83 c4 10             	add    $0x10,%esp
80105b27:	85 c0                	test   %eax,%eax
80105b29:	74 15                	je     80105b40 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
80105b2b:	83 ec 0c             	sub    $0xc,%esp
80105b2e:	50                   	push   %eax
80105b2f:	e8 bc bd ff ff       	call   801018f0 <iunlockput>
  end_op();
80105b34:	e8 77 d1 ff ff       	call   80102cb0 <end_op>
  return 0;
80105b39:	83 c4 10             	add    $0x10,%esp
80105b3c:	31 c0                	xor    %eax,%eax
}
80105b3e:	c9                   	leave  
80105b3f:	c3                   	ret    
    end_op();
80105b40:	e8 6b d1 ff ff       	call   80102cb0 <end_op>
    return -1;
80105b45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b4a:	c9                   	leave  
80105b4b:	c3                   	ret    
80105b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105b50 <sys_mknod>:

int
sys_mknod(void)
{
80105b50:	55                   	push   %ebp
80105b51:	89 e5                	mov    %esp,%ebp
80105b53:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105b56:	e8 e5 d0 ff ff       	call   80102c40 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105b5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b5e:	83 ec 08             	sub    $0x8,%esp
80105b61:	50                   	push   %eax
80105b62:	6a 00                	push   $0x0
80105b64:	e8 17 f6 ff ff       	call   80105180 <argstr>
80105b69:	83 c4 10             	add    $0x10,%esp
80105b6c:	85 c0                	test   %eax,%eax
80105b6e:	78 60                	js     80105bd0 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105b70:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b73:	83 ec 08             	sub    $0x8,%esp
80105b76:	50                   	push   %eax
80105b77:	6a 01                	push   $0x1
80105b79:	e8 72 f5 ff ff       	call   801050f0 <argint>
  if((argstr(0, &path)) < 0 ||
80105b7e:	83 c4 10             	add    $0x10,%esp
80105b81:	85 c0                	test   %eax,%eax
80105b83:	78 4b                	js     80105bd0 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105b85:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b88:	83 ec 08             	sub    $0x8,%esp
80105b8b:	50                   	push   %eax
80105b8c:	6a 02                	push   $0x2
80105b8e:	e8 5d f5 ff ff       	call   801050f0 <argint>
     argint(1, &major) < 0 ||
80105b93:	83 c4 10             	add    $0x10,%esp
80105b96:	85 c0                	test   %eax,%eax
80105b98:	78 36                	js     80105bd0 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105b9a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
     argint(2, &minor) < 0 ||
80105b9e:	83 ec 0c             	sub    $0xc,%esp
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ba1:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80105ba5:	ba 03 00 00 00       	mov    $0x3,%edx
80105baa:	50                   	push   %eax
80105bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105bae:	e8 bd f6 ff ff       	call   80105270 <create>
80105bb3:	83 c4 10             	add    $0x10,%esp
80105bb6:	85 c0                	test   %eax,%eax
80105bb8:	74 16                	je     80105bd0 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
80105bba:	83 ec 0c             	sub    $0xc,%esp
80105bbd:	50                   	push   %eax
80105bbe:	e8 2d bd ff ff       	call   801018f0 <iunlockput>
  end_op();
80105bc3:	e8 e8 d0 ff ff       	call   80102cb0 <end_op>
  return 0;
80105bc8:	83 c4 10             	add    $0x10,%esp
80105bcb:	31 c0                	xor    %eax,%eax
}
80105bcd:	c9                   	leave  
80105bce:	c3                   	ret    
80105bcf:	90                   	nop
    end_op();
80105bd0:	e8 db d0 ff ff       	call   80102cb0 <end_op>
    return -1;
80105bd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bda:	c9                   	leave  
80105bdb:	c3                   	ret    
80105bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105be0 <sys_chdir>:

int
sys_chdir(void)
{
80105be0:	55                   	push   %ebp
80105be1:	89 e5                	mov    %esp,%ebp
80105be3:	53                   	push   %ebx
80105be4:	83 ec 14             	sub    $0x14,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105be7:	e8 54 d0 ff ff       	call   80102c40 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105bec:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bef:	83 ec 08             	sub    $0x8,%esp
80105bf2:	50                   	push   %eax
80105bf3:	6a 00                	push   $0x0
80105bf5:	e8 86 f5 ff ff       	call   80105180 <argstr>
80105bfa:	83 c4 10             	add    $0x10,%esp
80105bfd:	85 c0                	test   %eax,%eax
80105bff:	78 7f                	js     80105c80 <sys_chdir+0xa0>
80105c01:	83 ec 0c             	sub    $0xc,%esp
80105c04:	ff 75 f4             	pushl  -0xc(%ebp)
80105c07:	e8 c4 c2 ff ff       	call   80101ed0 <namei>
80105c0c:	83 c4 10             	add    $0x10,%esp
80105c0f:	85 c0                	test   %eax,%eax
80105c11:	89 c3                	mov    %eax,%ebx
80105c13:	74 6b                	je     80105c80 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105c15:	83 ec 0c             	sub    $0xc,%esp
80105c18:	50                   	push   %eax
80105c19:	e8 02 ba ff ff       	call   80101620 <ilock>
  if(ip->type != T_DIR){
80105c1e:	83 c4 10             	add    $0x10,%esp
80105c21:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
80105c26:	75 38                	jne    80105c60 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105c28:	83 ec 0c             	sub    $0xc,%esp
80105c2b:	53                   	push   %ebx
80105c2c:	e8 ff ba ff ff       	call   80101730 <iunlock>
  iput(proc->cwd);
80105c31:	58                   	pop    %eax
80105c32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c38:	ff b0 ec 00 00 00    	pushl  0xec(%eax)
80105c3e:	e8 4d bb ff ff       	call   80101790 <iput>
  end_op();
80105c43:	e8 68 d0 ff ff       	call   80102cb0 <end_op>
  proc->cwd = ip;
80105c48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return 0;
80105c4e:	83 c4 10             	add    $0x10,%esp
  proc->cwd = ip;
80105c51:	89 98 ec 00 00 00    	mov    %ebx,0xec(%eax)
  return 0;
80105c57:	31 c0                	xor    %eax,%eax
}
80105c59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105c5c:	c9                   	leave  
80105c5d:	c3                   	ret    
80105c5e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80105c60:	83 ec 0c             	sub    $0xc,%esp
80105c63:	53                   	push   %ebx
80105c64:	e8 87 bc ff ff       	call   801018f0 <iunlockput>
    end_op();
80105c69:	e8 42 d0 ff ff       	call   80102cb0 <end_op>
    return -1;
80105c6e:	83 c4 10             	add    $0x10,%esp
80105c71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c76:	eb e1                	jmp    80105c59 <sys_chdir+0x79>
80105c78:	90                   	nop
80105c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    end_op();
80105c80:	e8 2b d0 ff ff       	call   80102cb0 <end_op>
    return -1;
80105c85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8a:	eb cd                	jmp    80105c59 <sys_chdir+0x79>
80105c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105c90 <sys_exec>:

int
sys_exec(void)
{
80105c90:	55                   	push   %ebp
80105c91:	89 e5                	mov    %esp,%ebp
80105c93:	57                   	push   %edi
80105c94:	56                   	push   %esi
80105c95:	53                   	push   %ebx
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105c96:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
80105c9c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ca2:	50                   	push   %eax
80105ca3:	6a 00                	push   $0x0
80105ca5:	e8 d6 f4 ff ff       	call   80105180 <argstr>
80105caa:	83 c4 10             	add    $0x10,%esp
80105cad:	85 c0                	test   %eax,%eax
80105caf:	0f 88 87 00 00 00    	js     80105d3c <sys_exec+0xac>
80105cb5:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105cbb:	83 ec 08             	sub    $0x8,%esp
80105cbe:	50                   	push   %eax
80105cbf:	6a 01                	push   $0x1
80105cc1:	e8 2a f4 ff ff       	call   801050f0 <argint>
80105cc6:	83 c4 10             	add    $0x10,%esp
80105cc9:	85 c0                	test   %eax,%eax
80105ccb:	78 6f                	js     80105d3c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105ccd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105cd3:	83 ec 04             	sub    $0x4,%esp
  for(i=0;; i++){
80105cd6:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105cd8:	68 80 00 00 00       	push   $0x80
80105cdd:	6a 00                	push   $0x0
80105cdf:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
80105ce5:	50                   	push   %eax
80105ce6:	e8 25 f1 ff ff       	call   80104e10 <memset>
80105ceb:	83 c4 10             	add    $0x10,%esp
80105cee:	eb 2c                	jmp    80105d1c <sys_exec+0x8c>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
80105cf0:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105cf6:	85 c0                	test   %eax,%eax
80105cf8:	74 56                	je     80105d50 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105cfa:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
80105d00:	83 ec 08             	sub    $0x8,%esp
80105d03:	8d 14 31             	lea    (%ecx,%esi,1),%edx
80105d06:	52                   	push   %edx
80105d07:	50                   	push   %eax
80105d08:	e8 83 f3 ff ff       	call   80105090 <fetchstr>
80105d0d:	83 c4 10             	add    $0x10,%esp
80105d10:	85 c0                	test   %eax,%eax
80105d12:	78 28                	js     80105d3c <sys_exec+0xac>
  for(i=0;; i++){
80105d14:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105d17:	83 fb 20             	cmp    $0x20,%ebx
80105d1a:	74 20                	je     80105d3c <sys_exec+0xac>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105d1c:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105d22:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
80105d29:	83 ec 08             	sub    $0x8,%esp
80105d2c:	57                   	push   %edi
80105d2d:	01 f0                	add    %esi,%eax
80105d2f:	50                   	push   %eax
80105d30:	e8 2b f3 ff ff       	call   80105060 <fetchint>
80105d35:	83 c4 10             	add    $0x10,%esp
80105d38:	85 c0                	test   %eax,%eax
80105d3a:	79 b4                	jns    80105cf0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
80105d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105d3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d44:	5b                   	pop    %ebx
80105d45:	5e                   	pop    %esi
80105d46:	5f                   	pop    %edi
80105d47:	5d                   	pop    %ebp
80105d48:	c3                   	ret    
80105d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105d50:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105d56:	83 ec 08             	sub    $0x8,%esp
      argv[i] = 0;
80105d59:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105d60:	00 00 00 00 
  return exec(path, argv);
80105d64:	50                   	push   %eax
80105d65:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
80105d6b:	e8 80 ac ff ff       	call   801009f0 <exec>
80105d70:	83 c4 10             	add    $0x10,%esp
}
80105d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d76:	5b                   	pop    %ebx
80105d77:	5e                   	pop    %esi
80105d78:	5f                   	pop    %edi
80105d79:	5d                   	pop    %ebp
80105d7a:	c3                   	ret    
80105d7b:	90                   	nop
80105d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105d80 <sys_pipe>:

int
sys_pipe(void)
{
80105d80:	55                   	push   %ebp
80105d81:	89 e5                	mov    %esp,%ebp
80105d83:	57                   	push   %edi
80105d84:	56                   	push   %esi
80105d85:	53                   	push   %ebx
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105d86:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105d89:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105d8c:	6a 08                	push   $0x8
80105d8e:	50                   	push   %eax
80105d8f:	6a 00                	push   $0x0
80105d91:	e8 9a f3 ff ff       	call   80105130 <argptr>
80105d96:	83 c4 10             	add    $0x10,%esp
80105d99:	85 c0                	test   %eax,%eax
80105d9b:	0f 88 b4 00 00 00    	js     80105e55 <sys_pipe+0xd5>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105da1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105da4:	83 ec 08             	sub    $0x8,%esp
80105da7:	50                   	push   %eax
80105da8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105dab:	50                   	push   %eax
80105dac:	e8 2f d6 ff ff       	call   801033e0 <pipealloc>
80105db1:	83 c4 10             	add    $0x10,%esp
80105db4:	85 c0                	test   %eax,%eax
80105db6:	0f 88 99 00 00 00    	js     80105e55 <sys_pipe+0xd5>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105dbc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
    if(proc->ofile[fd] == 0){
80105dbf:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  for(fd = 0; fd < NOFILE; fd++){
80105dc6:	31 c0                	xor    %eax,%eax
80105dc8:	eb 0e                	jmp    80105dd8 <sys_pipe+0x58>
80105dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105dd0:	83 c0 01             	add    $0x1,%eax
80105dd3:	83 f8 10             	cmp    $0x10,%eax
80105dd6:	74 68                	je     80105e40 <sys_pipe+0xc0>
    if(proc->ofile[fd] == 0){
80105dd8:	8b 94 81 ac 00 00 00 	mov    0xac(%ecx,%eax,4),%edx
80105ddf:	85 d2                	test   %edx,%edx
80105de1:	75 ed                	jne    80105dd0 <sys_pipe+0x50>
80105de3:	8d 34 81             	lea    (%ecx,%eax,4),%esi
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105de6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105de9:	31 d2                	xor    %edx,%edx
      proc->ofile[fd] = f;
80105deb:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
80105df1:	eb 0d                	jmp    80105e00 <sys_pipe+0x80>
80105df3:	90                   	nop
80105df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(fd = 0; fd < NOFILE; fd++){
80105df8:	83 c2 01             	add    $0x1,%edx
80105dfb:	83 fa 10             	cmp    $0x10,%edx
80105dfe:	74 30                	je     80105e30 <sys_pipe+0xb0>
    if(proc->ofile[fd] == 0){
80105e00:	83 bc 91 ac 00 00 00 	cmpl   $0x0,0xac(%ecx,%edx,4)
80105e07:	00 
80105e08:	75 ee                	jne    80105df8 <sys_pipe+0x78>
      proc->ofile[fd] = f;
80105e0a:	89 bc 91 ac 00 00 00 	mov    %edi,0xac(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105e11:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80105e14:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
80105e16:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e19:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105e1c:	31 c0                	xor    %eax,%eax
}
80105e1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e21:	5b                   	pop    %ebx
80105e22:	5e                   	pop    %esi
80105e23:	5f                   	pop    %edi
80105e24:	5d                   	pop    %ebp
80105e25:	c3                   	ret    
80105e26:	8d 76 00             	lea    0x0(%esi),%esi
80105e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      proc->ofile[fd0] = 0;
80105e30:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80105e37:	00 00 00 
80105e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    fileclose(rf);
80105e40:	83 ec 0c             	sub    $0xc,%esp
80105e43:	53                   	push   %ebx
80105e44:	e8 d7 af ff ff       	call   80100e20 <fileclose>
    fileclose(wf);
80105e49:	58                   	pop    %eax
80105e4a:	ff 75 e4             	pushl  -0x1c(%ebp)
80105e4d:	e8 ce af ff ff       	call   80100e20 <fileclose>
    return -1;
80105e52:	83 c4 10             	add    $0x10,%esp
80105e55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e5a:	eb c2                	jmp    80105e1e <sys_pipe+0x9e>
80105e5c:	66 90                	xchg   %ax,%ax
80105e5e:	66 90                	xchg   %ax,%ax

80105e60 <sys_clone>:
#include "mmu.h"
#include "proc.h"

int 
sys_clone(void)
{
80105e60:	55                   	push   %ebp
80105e61:	89 e5                	mov    %esp,%ebp
80105e63:	83 ec 20             	sub    $0x20,%esp
  int func_add;
  int arg;
  int stack_add;

  if (argint(0, &func_add) < 0)
80105e66:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e69:	50                   	push   %eax
80105e6a:	6a 00                	push   $0x0
80105e6c:	e8 7f f2 ff ff       	call   801050f0 <argint>
80105e71:	83 c4 10             	add    $0x10,%esp
80105e74:	85 c0                	test   %eax,%eax
80105e76:	78 48                	js     80105ec0 <sys_clone+0x60>
     return -1;
  if (argint(1, &arg) < 0)
80105e78:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e7b:	83 ec 08             	sub    $0x8,%esp
80105e7e:	50                   	push   %eax
80105e7f:	6a 01                	push   $0x1
80105e81:	e8 6a f2 ff ff       	call   801050f0 <argint>
80105e86:	83 c4 10             	add    $0x10,%esp
80105e89:	85 c0                	test   %eax,%eax
80105e8b:	78 33                	js     80105ec0 <sys_clone+0x60>
     return -1;
  if (argint(2, &stack_add) < 0)
80105e8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e90:	83 ec 08             	sub    $0x8,%esp
80105e93:	50                   	push   %eax
80105e94:	6a 02                	push   $0x2
80105e96:	e8 55 f2 ff ff       	call   801050f0 <argint>
80105e9b:	83 c4 10             	add    $0x10,%esp
80105e9e:	85 c0                	test   %eax,%eax
80105ea0:	78 1e                	js     80105ec0 <sys_clone+0x60>
     return -1;
 
  return clone((void *)func_add, (void *)arg, (void *)stack_add);
80105ea2:	83 ec 04             	sub    $0x4,%esp
80105ea5:	ff 75 f4             	pushl  -0xc(%ebp)
80105ea8:	ff 75 f0             	pushl  -0x10(%ebp)
80105eab:	ff 75 ec             	pushl  -0x14(%ebp)
80105eae:	e8 1d e9 ff ff       	call   801047d0 <clone>
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

80105ed0 <sys_join>:

int 
sys_join(void)
{
80105ed0:	55                   	push   %ebp
80105ed1:	89 e5                	mov    %esp,%ebp
80105ed3:	83 ec 20             	sub    $0x20,%esp
  int stack_add;

  if (argint(0, &stack_add) < 0)
80105ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ed9:	50                   	push   %eax
80105eda:	6a 00                	push   $0x0
80105edc:	e8 0f f2 ff ff       	call   801050f0 <argint>
80105ee1:	83 c4 10             	add    $0x10,%esp
80105ee4:	85 c0                	test   %eax,%eax
80105ee6:	78 18                	js     80105f00 <sys_join+0x30>
     return -1;

  return join((void **)stack_add);
80105ee8:	83 ec 0c             	sub    $0xc,%esp
80105eeb:	ff 75 f4             	pushl  -0xc(%ebp)
80105eee:	e8 7d ea ff ff       	call   80104970 <join>
80105ef3:	83 c4 10             	add    $0x10,%esp
}
80105ef6:	c9                   	leave  
80105ef7:	c3                   	ret    
80105ef8:	90                   	nop
80105ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
     return -1;
80105f00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f05:	c9                   	leave  
80105f06:	c3                   	ret    
80105f07:	89 f6                	mov    %esi,%esi
80105f09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105f10 <sys_myalloc>:

int 
sys_myalloc(void)
{
80105f10:	55                   	push   %ebp
80105f11:	89 e5                	mov    %esp,%ebp
80105f13:	83 ec 20             	sub    $0x20,%esp
  int n;   // 分配 n 个字节
  if(argint(0, &n) < 0)
80105f16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f19:	50                   	push   %eax
80105f1a:	6a 00                	push   $0x0
80105f1c:	e8 cf f1 ff ff       	call   801050f0 <argint>
80105f21:	83 c4 10             	add    $0x10,%esp
    return 0;
80105f24:	31 d2                	xor    %edx,%edx
  if(argint(0, &n) < 0)
80105f26:	85 c0                	test   %eax,%eax
80105f28:	78 15                	js     80105f3f <sys_myalloc+0x2f>
  if(n <= 0)
80105f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2d:	85 c0                	test   %eax,%eax
80105f2f:	7e 0e                	jle    80105f3f <sys_myalloc+0x2f>
    return 0;
  return mygrowproc(n);
80105f31:	83 ec 0c             	sub    $0xc,%esp
80105f34:	50                   	push   %eax
80105f35:	e8 a6 e6 ff ff       	call   801045e0 <mygrowproc>
80105f3a:	83 c4 10             	add    $0x10,%esp
80105f3d:	89 c2                	mov    %eax,%edx
}
80105f3f:	89 d0                	mov    %edx,%eax
80105f41:	c9                   	leave  
80105f42:	c3                   	ret    
80105f43:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105f49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105f50 <sys_myfree>:

int 
sys_myfree(void) {
80105f50:	55                   	push   %ebp
80105f51:	89 e5                	mov    %esp,%ebp
80105f53:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(0, &addr) < 0)
80105f56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f59:	50                   	push   %eax
80105f5a:	6a 00                	push   $0x0
80105f5c:	e8 8f f1 ff ff       	call   801050f0 <argint>
80105f61:	83 c4 10             	add    $0x10,%esp
80105f64:	85 c0                	test   %eax,%eax
80105f66:	78 18                	js     80105f80 <sys_myfree+0x30>
    return -1;
  return myreduceproc(addr);
80105f68:	83 ec 0c             	sub    $0xc,%esp
80105f6b:	ff 75 f4             	pushl  -0xc(%ebp)
80105f6e:	e8 8d e7 ff ff       	call   80104700 <myreduceproc>
80105f73:	83 c4 10             	add    $0x10,%esp
}
80105f76:	c9                   	leave  
80105f77:	c3                   	ret    
80105f78:	90                   	nop
80105f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f85:	c9                   	leave  
80105f86:	c3                   	ret    
80105f87:	89 f6                	mov    %esi,%esi
80105f89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105f90 <sys_getcpuid>:

//achieve sys_getcpuid, just my homework
int
sys_getcpuid()
{
80105f90:	55                   	push   %ebp
80105f91:	89 e5                	mov    %esp,%ebp
  return getcpuid();
}
80105f93:	5d                   	pop    %ebp
  return getcpuid();
80105f94:	e9 c7 d9 ff ff       	jmp    80103960 <getcpuid>
80105f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105fa0 <sys_fork>:

int
sys_fork(void)
{
80105fa0:	55                   	push   %ebp
80105fa1:	89 e5                	mov    %esp,%ebp
  return fork();
}
80105fa3:	5d                   	pop    %ebp
  return fork();
80105fa4:	e9 87 db ff ff       	jmp    80103b30 <fork>
80105fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105fb0 <sys_exit>:

int
sys_exit(void)
{
80105fb0:	55                   	push   %ebp
80105fb1:	89 e5                	mov    %esp,%ebp
80105fb3:	83 ec 08             	sub    $0x8,%esp
  exit();
80105fb6:	e8 a5 de ff ff       	call   80103e60 <exit>
  return 0;  // not reached
}
80105fbb:	31 c0                	xor    %eax,%eax
80105fbd:	c9                   	leave  
80105fbe:	c3                   	ret    
80105fbf:	90                   	nop

80105fc0 <sys_wait>:

int
sys_wait(void)
{
80105fc0:	55                   	push   %ebp
80105fc1:	89 e5                	mov    %esp,%ebp
  return wait();
}
80105fc3:	5d                   	pop    %ebp
  return wait();
80105fc4:	e9 27 e2 ff ff       	jmp    801041f0 <wait>
80105fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105fd0 <sys_kill>:

int
sys_kill(void)
{
80105fd0:	55                   	push   %ebp
80105fd1:	89 e5                	mov    %esp,%ebp
80105fd3:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fd9:	50                   	push   %eax
80105fda:	6a 00                	push   $0x0
80105fdc:	e8 0f f1 ff ff       	call   801050f0 <argint>
80105fe1:	83 c4 10             	add    $0x10,%esp
80105fe4:	85 c0                	test   %eax,%eax
80105fe6:	78 18                	js     80106000 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105fe8:	83 ec 0c             	sub    $0xc,%esp
80105feb:	ff 75 f4             	pushl  -0xc(%ebp)
80105fee:	e8 7d e3 ff ff       	call   80104370 <kill>
80105ff3:	83 c4 10             	add    $0x10,%esp
}
80105ff6:	c9                   	leave  
80105ff7:	c3                   	ret    
80105ff8:	90                   	nop
80105ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80106000:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106005:	c9                   	leave  
80106006:	c3                   	ret    
80106007:	89 f6                	mov    %esi,%esi
80106009:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106010 <sys_getpid>:

int
sys_getpid(void)
{
  return proc->pid;
80106010:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
{
80106016:	55                   	push   %ebp
80106017:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106019:	8b 40 10             	mov    0x10(%eax),%eax
}
8010601c:	5d                   	pop    %ebp
8010601d:	c3                   	ret    
8010601e:	66 90                	xchg   %ax,%ax

80106020 <sys_sbrk>:

int
sys_sbrk(void)
{
80106020:	55                   	push   %ebp
80106021:	89 e5                	mov    %esp,%ebp
80106023:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106024:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80106027:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010602a:	50                   	push   %eax
8010602b:	6a 00                	push   $0x0
8010602d:	e8 be f0 ff ff       	call   801050f0 <argint>
80106032:	83 c4 10             	add    $0x10,%esp
80106035:	85 c0                	test   %eax,%eax
80106037:	78 27                	js     80106060 <sys_sbrk+0x40>
    return -1;
  addr = proc->sz;
80106039:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(growproc(n) < 0)
8010603f:	83 ec 0c             	sub    $0xc,%esp
  addr = proc->sz;
80106042:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80106044:	ff 75 f4             	pushl  -0xc(%ebp)
80106047:	e8 64 da ff ff       	call   80103ab0 <growproc>
8010604c:	83 c4 10             	add    $0x10,%esp
8010604f:	85 c0                	test   %eax,%eax
80106051:	78 0d                	js     80106060 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80106053:	89 d8                	mov    %ebx,%eax
80106055:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106058:	c9                   	leave  
80106059:	c3                   	ret    
8010605a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80106060:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80106065:	eb ec                	jmp    80106053 <sys_sbrk+0x33>
80106067:	89 f6                	mov    %esi,%esi
80106069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106070 <sys_sleep>:

int
sys_sleep(void)
{
80106070:	55                   	push   %ebp
80106071:	89 e5                	mov    %esp,%ebp
80106073:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106074:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80106077:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010607a:	50                   	push   %eax
8010607b:	6a 00                	push   $0x0
8010607d:	e8 6e f0 ff ff       	call   801050f0 <argint>
80106082:	83 c4 10             	add    $0x10,%esp
80106085:	85 c0                	test   %eax,%eax
80106087:	0f 88 8a 00 00 00    	js     80106117 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
8010608d:	83 ec 0c             	sub    $0xc,%esp
80106090:	68 20 ac 11 80       	push   $0x8011ac20
80106095:	e8 66 eb ff ff       	call   80104c00 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010609a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010609d:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801060a0:	8b 1d 60 b4 11 80    	mov    0x8011b460,%ebx
  while(ticks - ticks0 < n){
801060a6:	85 d2                	test   %edx,%edx
801060a8:	75 27                	jne    801060d1 <sys_sleep+0x61>
801060aa:	eb 54                	jmp    80106100 <sys_sleep+0x90>
801060ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
801060b0:	83 ec 08             	sub    $0x8,%esp
801060b3:	68 20 ac 11 80       	push   $0x8011ac20
801060b8:	68 60 b4 11 80       	push   $0x8011b460
801060bd:	e8 5e e0 ff ff       	call   80104120 <sleep>
  while(ticks - ticks0 < n){
801060c2:	a1 60 b4 11 80       	mov    0x8011b460,%eax
801060c7:	83 c4 10             	add    $0x10,%esp
801060ca:	29 d8                	sub    %ebx,%eax
801060cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801060cf:	73 2f                	jae    80106100 <sys_sleep+0x90>
    if(proc->killed){
801060d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060d7:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801060dd:	85 c0                	test   %eax,%eax
801060df:	74 cf                	je     801060b0 <sys_sleep+0x40>
      release(&tickslock);
801060e1:	83 ec 0c             	sub    $0xc,%esp
801060e4:	68 20 ac 11 80       	push   $0x8011ac20
801060e9:	e8 d2 ec ff ff       	call   80104dc0 <release>
      return -1;
801060ee:	83 c4 10             	add    $0x10,%esp
801060f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&tickslock);
  return 0;
}
801060f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801060f9:	c9                   	leave  
801060fa:	c3                   	ret    
801060fb:	90                   	nop
801060fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&tickslock);
80106100:	83 ec 0c             	sub    $0xc,%esp
80106103:	68 20 ac 11 80       	push   $0x8011ac20
80106108:	e8 b3 ec ff ff       	call   80104dc0 <release>
  return 0;
8010610d:	83 c4 10             	add    $0x10,%esp
80106110:	31 c0                	xor    %eax,%eax
}
80106112:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106115:	c9                   	leave  
80106116:	c3                   	ret    
    return -1;
80106117:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611c:	eb f4                	jmp    80106112 <sys_sleep+0xa2>
8010611e:	66 90                	xchg   %ax,%ax

80106120 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106120:	55                   	push   %ebp
80106121:	89 e5                	mov    %esp,%ebp
80106123:	53                   	push   %ebx
80106124:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80106127:	68 20 ac 11 80       	push   $0x8011ac20
8010612c:	e8 cf ea ff ff       	call   80104c00 <acquire>
  xticks = ticks;
80106131:	8b 1d 60 b4 11 80    	mov    0x8011b460,%ebx
  release(&tickslock);
80106137:	c7 04 24 20 ac 11 80 	movl   $0x8011ac20,(%esp)
8010613e:	e8 7d ec ff ff       	call   80104dc0 <release>
  return xticks;
}
80106143:	89 d8                	mov    %ebx,%eax
80106145:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106148:	c9                   	leave  
80106149:	c3                   	ret    
8010614a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106150 <sys_cps>:

int sys_cps(void){
80106150:	55                   	push   %ebp
80106151:	89 e5                	mov    %esp,%ebp
  return cps();
}
80106153:	5d                   	pop    %ebp
  return cps();
80106154:	e9 27 e9 ff ff       	jmp    80104a80 <cps>
80106159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106160 <sys_chpri>:

int sys_chpri(void)
{
80106160:	55                   	push   %ebp
80106161:	89 e5                	mov    %esp,%ebp
80106163:	83 ec 20             	sub    $0x20,%esp
  int pid, pr;
  if (argint(0, &pid) < 0)
80106166:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106169:	50                   	push   %eax
8010616a:	6a 00                	push   $0x0
8010616c:	e8 7f ef ff ff       	call   801050f0 <argint>
80106171:	83 c4 10             	add    $0x10,%esp
80106174:	85 c0                	test   %eax,%eax
80106176:	78 28                	js     801061a0 <sys_chpri+0x40>
    return -1;
  if (argint(1, &pr) < 0)
80106178:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010617b:	83 ec 08             	sub    $0x8,%esp
8010617e:	50                   	push   %eax
8010617f:	6a 01                	push   $0x1
80106181:	e8 6a ef ff ff       	call   801050f0 <argint>
80106186:	83 c4 10             	add    $0x10,%esp
80106189:	85 c0                	test   %eax,%eax
8010618b:	78 13                	js     801061a0 <sys_chpri+0x40>
    return -1;
  return chpri(pid, pr);
8010618d:	83 ec 08             	sub    $0x8,%esp
80106190:	ff 75 f4             	pushl  -0xc(%ebp)
80106193:	ff 75 f0             	pushl  -0x10(%ebp)
80106196:	e8 f5 e9 ff ff       	call   80104b90 <chpri>
8010619b:	83 c4 10             	add    $0x10,%esp
}
8010619e:	c9                   	leave  
8010619f:	c3                   	ret    
    return -1;
801061a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061a5:	c9                   	leave  
801061a6:	c3                   	ret    
801061a7:	66 90                	xchg   %ax,%ax
801061a9:	66 90                	xchg   %ax,%ax
801061ab:	66 90                	xchg   %ax,%ax
801061ad:	66 90                	xchg   %ax,%ax
801061af:	90                   	nop

801061b0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801061b0:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801061b1:	b8 34 00 00 00       	mov    $0x34,%eax
801061b6:	ba 43 00 00 00       	mov    $0x43,%edx
801061bb:	89 e5                	mov    %esp,%ebp
801061bd:	83 ec 14             	sub    $0x14,%esp
801061c0:	ee                   	out    %al,(%dx)
801061c1:	ba 40 00 00 00       	mov    $0x40,%edx
801061c6:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
801061cb:	ee                   	out    %al,(%dx)
801061cc:	b8 2e 00 00 00       	mov    $0x2e,%eax
801061d1:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
801061d2:	6a 00                	push   $0x0
801061d4:	e8 37 d1 ff ff       	call   80103310 <picenable>
}
801061d9:	83 c4 10             	add    $0x10,%esp
801061dc:	c9                   	leave  
801061dd:	c3                   	ret    

801061de <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801061de:	1e                   	push   %ds
  pushl %es
801061df:	06                   	push   %es
  pushl %fs
801061e0:	0f a0                	push   %fs
  pushl %gs
801061e2:	0f a8                	push   %gs
  pushal
801061e4:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801061e5:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801061e9:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801061eb:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801061ed:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801061f1:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801061f3:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801061f5:	54                   	push   %esp
  call trap
801061f6:	e8 c5 00 00 00       	call   801062c0 <trap>
  addl $4, %esp
801061fb:	83 c4 04             	add    $0x4,%esp

801061fe <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801061fe:	61                   	popa   
  popl %gs
801061ff:	0f a9                	pop    %gs
  popl %fs
80106201:	0f a1                	pop    %fs
  popl %es
80106203:	07                   	pop    %es
  popl %ds
80106204:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106205:	83 c4 08             	add    $0x8,%esp
  iret
80106208:	cf                   	iret   
80106209:	66 90                	xchg   %ax,%ax
8010620b:	66 90                	xchg   %ax,%ax
8010620d:	66 90                	xchg   %ax,%ax
8010620f:	90                   	nop

80106210 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106210:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80106211:	31 c0                	xor    %eax,%eax
{
80106213:	89 e5                	mov    %esp,%ebp
80106215:	83 ec 08             	sub    $0x8,%esp
80106218:	90                   	nop
80106219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106220:	8b 14 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%edx
80106227:	c7 04 c5 62 ac 11 80 	movl   $0x8e000008,-0x7fee539e(,%eax,8)
8010622e:	08 00 00 8e 
80106232:	66 89 14 c5 60 ac 11 	mov    %dx,-0x7fee53a0(,%eax,8)
80106239:	80 
8010623a:	c1 ea 10             	shr    $0x10,%edx
8010623d:	66 89 14 c5 66 ac 11 	mov    %dx,-0x7fee539a(,%eax,8)
80106244:	80 
  for(i = 0; i < 256; i++)
80106245:	83 c0 01             	add    $0x1,%eax
80106248:	3d 00 01 00 00       	cmp    $0x100,%eax
8010624d:	75 d1                	jne    80106220 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010624f:	a1 0c b1 10 80       	mov    0x8010b10c,%eax

  initlock(&tickslock, "time");
80106254:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106257:	c7 05 62 ae 11 80 08 	movl   $0xef000008,0x8011ae62
8010625e:	00 00 ef 
  initlock(&tickslock, "time");
80106261:	68 d5 84 10 80       	push   $0x801084d5
80106266:	68 20 ac 11 80       	push   $0x8011ac20
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010626b:	66 a3 60 ae 11 80    	mov    %ax,0x8011ae60
80106271:	c1 e8 10             	shr    $0x10,%eax
80106274:	66 a3 66 ae 11 80    	mov    %ax,0x8011ae66
  initlock(&tickslock, "time");
8010627a:	e8 61 e9 ff ff       	call   80104be0 <initlock>
}
8010627f:	83 c4 10             	add    $0x10,%esp
80106282:	c9                   	leave  
80106283:	c3                   	ret    
80106284:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010628a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80106290 <idtinit>:

void
idtinit(void)
{
80106290:	55                   	push   %ebp
  pd[0] = size-1;
80106291:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80106296:	89 e5                	mov    %esp,%ebp
80106298:	83 ec 10             	sub    $0x10,%esp
8010629b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010629f:	b8 60 ac 11 80       	mov    $0x8011ac60,%eax
801062a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801062a8:	c1 e8 10             	shr    $0x10,%eax
801062ab:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801062af:	8d 45 fa             	lea    -0x6(%ebp),%eax
801062b2:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801062b5:	c9                   	leave  
801062b6:	c3                   	ret    
801062b7:	89 f6                	mov    %esi,%esi
801062b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801062c0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801062c0:	55                   	push   %ebp
801062c1:	89 e5                	mov    %esp,%ebp
801062c3:	57                   	push   %edi
801062c4:	56                   	push   %esi
801062c5:	53                   	push   %ebx
801062c6:	83 ec 0c             	sub    $0xc,%esp
801062c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
801062cc:	8b 43 30             	mov    0x30(%ebx),%eax
801062cf:	83 f8 40             	cmp    $0x40,%eax
801062d2:	74 74                	je     80106348 <trap+0x88>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
801062d4:	83 e8 20             	sub    $0x20,%eax
801062d7:	83 f8 1f             	cmp    $0x1f,%eax
801062da:	0f 87 a8 00 00 00    	ja     80106388 <trap+0xc8>
801062e0:	ff 24 85 7c 85 10 80 	jmp    *-0x7fef7a84(,%eax,4)
801062e7:	89 f6                	mov    %esi,%esi
801062e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  case T_IRQ0 + IRQ_TIMER:
    if(cpunum() == 0){
801062f0:	e8 4b c4 ff ff       	call   80102740 <cpunum>
801062f5:	85 c0                	test   %eax,%eax
801062f7:	0f 84 b3 01 00 00    	je     801064b0 <trap+0x1f0>
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
801062fd:	e8 ee c4 ff ff       	call   801027f0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106302:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106308:	85 c0                	test   %eax,%eax
8010630a:	74 2f                	je     8010633b <trap+0x7b>
8010630c:	8b 90 a8 00 00 00    	mov    0xa8(%eax),%edx
80106312:	85 d2                	test   %edx,%edx
80106314:	0f 85 c9 00 00 00    	jne    801063e3 <trap+0x123>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010631a:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010631e:	0f 84 4c 01 00 00    	je     80106470 <trap+0x1b0>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106324:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010632a:	85 c0                	test   %eax,%eax
8010632c:	74 0d                	je     8010633b <trap+0x7b>
8010632e:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80106332:	83 e0 03             	and    $0x3,%eax
80106335:	66 83 f8 03          	cmp    $0x3,%ax
80106339:	74 3c                	je     80106377 <trap+0xb7>
    exit();
}
8010633b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010633e:	5b                   	pop    %ebx
8010633f:	5e                   	pop    %esi
80106340:	5f                   	pop    %edi
80106341:	5d                   	pop    %ebp
80106342:	c3                   	ret    
80106343:	90                   	nop
80106344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc->killed)
80106348:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010634e:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
80106354:	85 f6                	test   %esi,%esi
80106356:	0f 85 3c 01 00 00    	jne    80106498 <trap+0x1d8>
    proc->tf = tf;
8010635c:	89 98 9c 00 00 00    	mov    %ebx,0x9c(%eax)
    syscall();
80106362:	e8 99 ee ff ff       	call   80105200 <syscall>
    if(proc->killed)
80106367:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010636d:	8b 98 a8 00 00 00    	mov    0xa8(%eax),%ebx
80106373:	85 db                	test   %ebx,%ebx
80106375:	74 c4                	je     8010633b <trap+0x7b>
}
80106377:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010637a:	5b                   	pop    %ebx
8010637b:	5e                   	pop    %esi
8010637c:	5f                   	pop    %edi
8010637d:	5d                   	pop    %ebp
      exit();
8010637e:	e9 dd da ff ff       	jmp    80103e60 <exit>
80106383:	90                   	nop
80106384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(proc == 0 || (tf->cs&3) == 0){
80106388:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010638f:	8b 73 38             	mov    0x38(%ebx),%esi
80106392:	85 c9                	test   %ecx,%ecx
80106394:	0f 84 4a 01 00 00    	je     801064e4 <trap+0x224>
8010639a:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010639e:	0f 84 40 01 00 00    	je     801064e4 <trap+0x224>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801063a4:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801063a7:	e8 94 c3 ff ff       	call   80102740 <cpunum>
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
801063ac:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801063b3:	57                   	push   %edi
801063b4:	56                   	push   %esi
801063b5:	50                   	push   %eax
801063b6:	ff 73 34             	pushl  0x34(%ebx)
801063b9:	ff 73 30             	pushl  0x30(%ebx)
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
801063bc:	8d 82 f0 00 00 00    	lea    0xf0(%edx),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801063c2:	50                   	push   %eax
801063c3:	ff 72 10             	pushl  0x10(%edx)
801063c6:	68 38 85 10 80       	push   $0x80108538
801063cb:	e8 70 a2 ff ff       	call   80100640 <cprintf>
    proc->killed = 1;
801063d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063d6:	83 c4 20             	add    $0x20,%esp
801063d9:	c7 80 a8 00 00 00 01 	movl   $0x1,0xa8(%eax)
801063e0:	00 00 00 
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801063e3:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
801063e7:	83 e2 03             	and    $0x3,%edx
801063ea:	66 83 fa 03          	cmp    $0x3,%dx
801063ee:	0f 85 26 ff ff ff    	jne    8010631a <trap+0x5a>
    exit();
801063f4:	e8 67 da ff ff       	call   80103e60 <exit>
801063f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801063ff:	85 c0                	test   %eax,%eax
80106401:	0f 85 13 ff ff ff    	jne    8010631a <trap+0x5a>
80106407:	e9 2f ff ff ff       	jmp    8010633b <trap+0x7b>
8010640c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    kbdintr();
80106410:	e8 0b c2 ff ff       	call   80102620 <kbdintr>
    lapiceoi();
80106415:	e8 d6 c3 ff ff       	call   801027f0 <lapiceoi>
    break;
8010641a:	e9 e3 fe ff ff       	jmp    80106302 <trap+0x42>
8010641f:	90                   	nop
    uartintr();
80106420:	e8 5b 02 00 00       	call   80106680 <uartintr>
80106425:	e9 d3 fe ff ff       	jmp    801062fd <trap+0x3d>
8010642a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106430:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80106434:	8b 7b 38             	mov    0x38(%ebx),%edi
80106437:	e8 04 c3 ff ff       	call   80102740 <cpunum>
8010643c:	57                   	push   %edi
8010643d:	56                   	push   %esi
8010643e:	50                   	push   %eax
8010643f:	68 e0 84 10 80       	push   $0x801084e0
80106444:	e8 f7 a1 ff ff       	call   80100640 <cprintf>
    lapiceoi();
80106449:	e8 a2 c3 ff ff       	call   801027f0 <lapiceoi>
    break;
8010644e:	83 c4 10             	add    $0x10,%esp
80106451:	e9 ac fe ff ff       	jmp    80106302 <trap+0x42>
80106456:	8d 76 00             	lea    0x0(%esi),%esi
80106459:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ideintr();
80106460:	e8 1b bc ff ff       	call   80102080 <ideintr>
    lapiceoi();
80106465:	e8 86 c3 ff ff       	call   801027f0 <lapiceoi>
    break;
8010646a:	e9 93 fe ff ff       	jmp    80106302 <trap+0x42>
8010646f:	90                   	nop
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106470:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80106474:	0f 85 aa fe ff ff    	jne    80106324 <trap+0x64>
    yield();
8010647a:	e8 61 dc ff ff       	call   801040e0 <yield>
8010647f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106485:	85 c0                	test   %eax,%eax
80106487:	0f 85 97 fe ff ff    	jne    80106324 <trap+0x64>
8010648d:	e9 a9 fe ff ff       	jmp    8010633b <trap+0x7b>
80106492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80106498:	e8 c3 d9 ff ff       	call   80103e60 <exit>
8010649d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064a3:	e9 b4 fe ff ff       	jmp    8010635c <trap+0x9c>
801064a8:	90                   	nop
801064a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      acquire(&tickslock);
801064b0:	83 ec 0c             	sub    $0xc,%esp
801064b3:	68 20 ac 11 80       	push   $0x8011ac20
801064b8:	e8 43 e7 ff ff       	call   80104c00 <acquire>
      wakeup(&ticks);
801064bd:	c7 04 24 60 b4 11 80 	movl   $0x8011b460,(%esp)
      ticks++;
801064c4:	83 05 60 b4 11 80 01 	addl   $0x1,0x8011b460
      wakeup(&ticks);
801064cb:	e8 40 de ff ff       	call   80104310 <wakeup>
      release(&tickslock);
801064d0:	c7 04 24 20 ac 11 80 	movl   $0x8011ac20,(%esp)
801064d7:	e8 e4 e8 ff ff       	call   80104dc0 <release>
801064dc:	83 c4 10             	add    $0x10,%esp
801064df:	e9 19 fe ff ff       	jmp    801062fd <trap+0x3d>
801064e4:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801064e7:	e8 54 c2 ff ff       	call   80102740 <cpunum>
801064ec:	83 ec 0c             	sub    $0xc,%esp
801064ef:	57                   	push   %edi
801064f0:	56                   	push   %esi
801064f1:	50                   	push   %eax
801064f2:	ff 73 30             	pushl  0x30(%ebx)
801064f5:	68 04 85 10 80       	push   $0x80108504
801064fa:	e8 41 a1 ff ff       	call   80100640 <cprintf>
      panic("trap");
801064ff:	83 c4 14             	add    $0x14,%esp
80106502:	68 da 84 10 80       	push   $0x801084da
80106507:	e8 64 9e ff ff       	call   80100370 <panic>
8010650c:	66 90                	xchg   %ax,%ax
8010650e:	66 90                	xchg   %ax,%ax

80106510 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80106510:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
{
80106515:	55                   	push   %ebp
80106516:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106518:	85 c0                	test   %eax,%eax
8010651a:	74 1c                	je     80106538 <uartgetc+0x28>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010651c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106521:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80106522:	a8 01                	test   $0x1,%al
80106524:	74 12                	je     80106538 <uartgetc+0x28>
80106526:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010652b:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010652c:	0f b6 c0             	movzbl %al,%eax
}
8010652f:	5d                   	pop    %ebp
80106530:	c3                   	ret    
80106531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80106538:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010653d:	5d                   	pop    %ebp
8010653e:	c3                   	ret    
8010653f:	90                   	nop

80106540 <uartputc.part.0>:
uartputc(int c)
80106540:	55                   	push   %ebp
80106541:	89 e5                	mov    %esp,%ebp
80106543:	57                   	push   %edi
80106544:	56                   	push   %esi
80106545:	53                   	push   %ebx
80106546:	89 c7                	mov    %eax,%edi
80106548:	bb 80 00 00 00       	mov    $0x80,%ebx
8010654d:	be fd 03 00 00       	mov    $0x3fd,%esi
80106552:	83 ec 0c             	sub    $0xc,%esp
80106555:	eb 1b                	jmp    80106572 <uartputc.part.0+0x32>
80106557:	89 f6                	mov    %esi,%esi
80106559:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    microdelay(10);
80106560:	83 ec 0c             	sub    $0xc,%esp
80106563:	6a 0a                	push   $0xa
80106565:	e8 a6 c2 ff ff       	call   80102810 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010656a:	83 c4 10             	add    $0x10,%esp
8010656d:	83 eb 01             	sub    $0x1,%ebx
80106570:	74 07                	je     80106579 <uartputc.part.0+0x39>
80106572:	89 f2                	mov    %esi,%edx
80106574:	ec                   	in     (%dx),%al
80106575:	a8 20                	test   $0x20,%al
80106577:	74 e7                	je     80106560 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106579:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010657e:	89 f8                	mov    %edi,%eax
80106580:	ee                   	out    %al,(%dx)
}
80106581:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106584:	5b                   	pop    %ebx
80106585:	5e                   	pop    %esi
80106586:	5f                   	pop    %edi
80106587:	5d                   	pop    %ebp
80106588:	c3                   	ret    
80106589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106590 <uartinit>:
{
80106590:	55                   	push   %ebp
80106591:	31 c9                	xor    %ecx,%ecx
80106593:	89 c8                	mov    %ecx,%eax
80106595:	89 e5                	mov    %esp,%ebp
80106597:	57                   	push   %edi
80106598:	56                   	push   %esi
80106599:	53                   	push   %ebx
8010659a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
8010659f:	89 da                	mov    %ebx,%edx
801065a1:	83 ec 0c             	sub    $0xc,%esp
801065a4:	ee                   	out    %al,(%dx)
801065a5:	bf fb 03 00 00       	mov    $0x3fb,%edi
801065aa:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801065af:	89 fa                	mov    %edi,%edx
801065b1:	ee                   	out    %al,(%dx)
801065b2:	b8 0c 00 00 00       	mov    $0xc,%eax
801065b7:	ba f8 03 00 00       	mov    $0x3f8,%edx
801065bc:	ee                   	out    %al,(%dx)
801065bd:	be f9 03 00 00       	mov    $0x3f9,%esi
801065c2:	89 c8                	mov    %ecx,%eax
801065c4:	89 f2                	mov    %esi,%edx
801065c6:	ee                   	out    %al,(%dx)
801065c7:	b8 03 00 00 00       	mov    $0x3,%eax
801065cc:	89 fa                	mov    %edi,%edx
801065ce:	ee                   	out    %al,(%dx)
801065cf:	ba fc 03 00 00       	mov    $0x3fc,%edx
801065d4:	89 c8                	mov    %ecx,%eax
801065d6:	ee                   	out    %al,(%dx)
801065d7:	b8 01 00 00 00       	mov    $0x1,%eax
801065dc:	89 f2                	mov    %esi,%edx
801065de:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801065df:	ba fd 03 00 00       	mov    $0x3fd,%edx
801065e4:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801065e5:	3c ff                	cmp    $0xff,%al
801065e7:	74 5a                	je     80106643 <uartinit+0xb3>
  uart = 1;
801065e9:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801065f0:	00 00 00 
801065f3:	89 da                	mov    %ebx,%edx
801065f5:	ec                   	in     (%dx),%al
801065f6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801065fb:	ec                   	in     (%dx),%al
  picenable(IRQ_COM1);
801065fc:	83 ec 0c             	sub    $0xc,%esp
801065ff:	6a 04                	push   $0x4
80106601:	e8 0a cd ff ff       	call   80103310 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106606:	59                   	pop    %ecx
80106607:	5b                   	pop    %ebx
80106608:	6a 00                	push   $0x0
8010660a:	6a 04                	push   $0x4
  for(p="xv6...\n"; *p; p++)
8010660c:	bb fc 85 10 80       	mov    $0x801085fc,%ebx
  ioapicenable(IRQ_COM1, 0);
80106611:	e8 ca bc ff ff       	call   801022e0 <ioapicenable>
80106616:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106619:	b8 78 00 00 00       	mov    $0x78,%eax
8010661e:	eb 0a                	jmp    8010662a <uartinit+0x9a>
80106620:	83 c3 01             	add    $0x1,%ebx
80106623:	0f be 03             	movsbl (%ebx),%eax
80106626:	84 c0                	test   %al,%al
80106628:	74 19                	je     80106643 <uartinit+0xb3>
  if(!uart)
8010662a:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
80106630:	85 d2                	test   %edx,%edx
80106632:	74 ec                	je     80106620 <uartinit+0x90>
  for(p="xv6...\n"; *p; p++)
80106634:	83 c3 01             	add    $0x1,%ebx
80106637:	e8 04 ff ff ff       	call   80106540 <uartputc.part.0>
8010663c:	0f be 03             	movsbl (%ebx),%eax
8010663f:	84 c0                	test   %al,%al
80106641:	75 e7                	jne    8010662a <uartinit+0x9a>
}
80106643:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106646:	5b                   	pop    %ebx
80106647:	5e                   	pop    %esi
80106648:	5f                   	pop    %edi
80106649:	5d                   	pop    %ebp
8010664a:	c3                   	ret    
8010664b:	90                   	nop
8010664c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106650 <uartputc>:
  if(!uart)
80106650:	8b 15 c0 b5 10 80    	mov    0x8010b5c0,%edx
{
80106656:	55                   	push   %ebp
80106657:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106659:	85 d2                	test   %edx,%edx
{
8010665b:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
8010665e:	74 10                	je     80106670 <uartputc+0x20>
}
80106660:	5d                   	pop    %ebp
80106661:	e9 da fe ff ff       	jmp    80106540 <uartputc.part.0>
80106666:	8d 76 00             	lea    0x0(%esi),%esi
80106669:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80106670:	5d                   	pop    %ebp
80106671:	c3                   	ret    
80106672:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106679:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106680 <uartintr>:

void
uartintr(void)
{
80106680:	55                   	push   %ebp
80106681:	89 e5                	mov    %esp,%ebp
80106683:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106686:	68 10 65 10 80       	push   $0x80106510
8010668b:	e8 60 a1 ff ff       	call   801007f0 <consoleintr>
}
80106690:	83 c4 10             	add    $0x10,%esp
80106693:	c9                   	leave  
80106694:	c3                   	ret    

80106695 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106695:	6a 00                	push   $0x0
  pushl $0
80106697:	6a 00                	push   $0x0
  jmp alltraps
80106699:	e9 40 fb ff ff       	jmp    801061de <alltraps>

8010669e <vector1>:
.globl vector1
vector1:
  pushl $0
8010669e:	6a 00                	push   $0x0
  pushl $1
801066a0:	6a 01                	push   $0x1
  jmp alltraps
801066a2:	e9 37 fb ff ff       	jmp    801061de <alltraps>

801066a7 <vector2>:
.globl vector2
vector2:
  pushl $0
801066a7:	6a 00                	push   $0x0
  pushl $2
801066a9:	6a 02                	push   $0x2
  jmp alltraps
801066ab:	e9 2e fb ff ff       	jmp    801061de <alltraps>

801066b0 <vector3>:
.globl vector3
vector3:
  pushl $0
801066b0:	6a 00                	push   $0x0
  pushl $3
801066b2:	6a 03                	push   $0x3
  jmp alltraps
801066b4:	e9 25 fb ff ff       	jmp    801061de <alltraps>

801066b9 <vector4>:
.globl vector4
vector4:
  pushl $0
801066b9:	6a 00                	push   $0x0
  pushl $4
801066bb:	6a 04                	push   $0x4
  jmp alltraps
801066bd:	e9 1c fb ff ff       	jmp    801061de <alltraps>

801066c2 <vector5>:
.globl vector5
vector5:
  pushl $0
801066c2:	6a 00                	push   $0x0
  pushl $5
801066c4:	6a 05                	push   $0x5
  jmp alltraps
801066c6:	e9 13 fb ff ff       	jmp    801061de <alltraps>

801066cb <vector6>:
.globl vector6
vector6:
  pushl $0
801066cb:	6a 00                	push   $0x0
  pushl $6
801066cd:	6a 06                	push   $0x6
  jmp alltraps
801066cf:	e9 0a fb ff ff       	jmp    801061de <alltraps>

801066d4 <vector7>:
.globl vector7
vector7:
  pushl $0
801066d4:	6a 00                	push   $0x0
  pushl $7
801066d6:	6a 07                	push   $0x7
  jmp alltraps
801066d8:	e9 01 fb ff ff       	jmp    801061de <alltraps>

801066dd <vector8>:
.globl vector8
vector8:
  pushl $8
801066dd:	6a 08                	push   $0x8
  jmp alltraps
801066df:	e9 fa fa ff ff       	jmp    801061de <alltraps>

801066e4 <vector9>:
.globl vector9
vector9:
  pushl $0
801066e4:	6a 00                	push   $0x0
  pushl $9
801066e6:	6a 09                	push   $0x9
  jmp alltraps
801066e8:	e9 f1 fa ff ff       	jmp    801061de <alltraps>

801066ed <vector10>:
.globl vector10
vector10:
  pushl $10
801066ed:	6a 0a                	push   $0xa
  jmp alltraps
801066ef:	e9 ea fa ff ff       	jmp    801061de <alltraps>

801066f4 <vector11>:
.globl vector11
vector11:
  pushl $11
801066f4:	6a 0b                	push   $0xb
  jmp alltraps
801066f6:	e9 e3 fa ff ff       	jmp    801061de <alltraps>

801066fb <vector12>:
.globl vector12
vector12:
  pushl $12
801066fb:	6a 0c                	push   $0xc
  jmp alltraps
801066fd:	e9 dc fa ff ff       	jmp    801061de <alltraps>

80106702 <vector13>:
.globl vector13
vector13:
  pushl $13
80106702:	6a 0d                	push   $0xd
  jmp alltraps
80106704:	e9 d5 fa ff ff       	jmp    801061de <alltraps>

80106709 <vector14>:
.globl vector14
vector14:
  pushl $14
80106709:	6a 0e                	push   $0xe
  jmp alltraps
8010670b:	e9 ce fa ff ff       	jmp    801061de <alltraps>

80106710 <vector15>:
.globl vector15
vector15:
  pushl $0
80106710:	6a 00                	push   $0x0
  pushl $15
80106712:	6a 0f                	push   $0xf
  jmp alltraps
80106714:	e9 c5 fa ff ff       	jmp    801061de <alltraps>

80106719 <vector16>:
.globl vector16
vector16:
  pushl $0
80106719:	6a 00                	push   $0x0
  pushl $16
8010671b:	6a 10                	push   $0x10
  jmp alltraps
8010671d:	e9 bc fa ff ff       	jmp    801061de <alltraps>

80106722 <vector17>:
.globl vector17
vector17:
  pushl $17
80106722:	6a 11                	push   $0x11
  jmp alltraps
80106724:	e9 b5 fa ff ff       	jmp    801061de <alltraps>

80106729 <vector18>:
.globl vector18
vector18:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $18
8010672b:	6a 12                	push   $0x12
  jmp alltraps
8010672d:	e9 ac fa ff ff       	jmp    801061de <alltraps>

80106732 <vector19>:
.globl vector19
vector19:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $19
80106734:	6a 13                	push   $0x13
  jmp alltraps
80106736:	e9 a3 fa ff ff       	jmp    801061de <alltraps>

8010673b <vector20>:
.globl vector20
vector20:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $20
8010673d:	6a 14                	push   $0x14
  jmp alltraps
8010673f:	e9 9a fa ff ff       	jmp    801061de <alltraps>

80106744 <vector21>:
.globl vector21
vector21:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $21
80106746:	6a 15                	push   $0x15
  jmp alltraps
80106748:	e9 91 fa ff ff       	jmp    801061de <alltraps>

8010674d <vector22>:
.globl vector22
vector22:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $22
8010674f:	6a 16                	push   $0x16
  jmp alltraps
80106751:	e9 88 fa ff ff       	jmp    801061de <alltraps>

80106756 <vector23>:
.globl vector23
vector23:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $23
80106758:	6a 17                	push   $0x17
  jmp alltraps
8010675a:	e9 7f fa ff ff       	jmp    801061de <alltraps>

8010675f <vector24>:
.globl vector24
vector24:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $24
80106761:	6a 18                	push   $0x18
  jmp alltraps
80106763:	e9 76 fa ff ff       	jmp    801061de <alltraps>

80106768 <vector25>:
.globl vector25
vector25:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $25
8010676a:	6a 19                	push   $0x19
  jmp alltraps
8010676c:	e9 6d fa ff ff       	jmp    801061de <alltraps>

80106771 <vector26>:
.globl vector26
vector26:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $26
80106773:	6a 1a                	push   $0x1a
  jmp alltraps
80106775:	e9 64 fa ff ff       	jmp    801061de <alltraps>

8010677a <vector27>:
.globl vector27
vector27:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $27
8010677c:	6a 1b                	push   $0x1b
  jmp alltraps
8010677e:	e9 5b fa ff ff       	jmp    801061de <alltraps>

80106783 <vector28>:
.globl vector28
vector28:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $28
80106785:	6a 1c                	push   $0x1c
  jmp alltraps
80106787:	e9 52 fa ff ff       	jmp    801061de <alltraps>

8010678c <vector29>:
.globl vector29
vector29:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $29
8010678e:	6a 1d                	push   $0x1d
  jmp alltraps
80106790:	e9 49 fa ff ff       	jmp    801061de <alltraps>

80106795 <vector30>:
.globl vector30
vector30:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $30
80106797:	6a 1e                	push   $0x1e
  jmp alltraps
80106799:	e9 40 fa ff ff       	jmp    801061de <alltraps>

8010679e <vector31>:
.globl vector31
vector31:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $31
801067a0:	6a 1f                	push   $0x1f
  jmp alltraps
801067a2:	e9 37 fa ff ff       	jmp    801061de <alltraps>

801067a7 <vector32>:
.globl vector32
vector32:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $32
801067a9:	6a 20                	push   $0x20
  jmp alltraps
801067ab:	e9 2e fa ff ff       	jmp    801061de <alltraps>

801067b0 <vector33>:
.globl vector33
vector33:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $33
801067b2:	6a 21                	push   $0x21
  jmp alltraps
801067b4:	e9 25 fa ff ff       	jmp    801061de <alltraps>

801067b9 <vector34>:
.globl vector34
vector34:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $34
801067bb:	6a 22                	push   $0x22
  jmp alltraps
801067bd:	e9 1c fa ff ff       	jmp    801061de <alltraps>

801067c2 <vector35>:
.globl vector35
vector35:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $35
801067c4:	6a 23                	push   $0x23
  jmp alltraps
801067c6:	e9 13 fa ff ff       	jmp    801061de <alltraps>

801067cb <vector36>:
.globl vector36
vector36:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $36
801067cd:	6a 24                	push   $0x24
  jmp alltraps
801067cf:	e9 0a fa ff ff       	jmp    801061de <alltraps>

801067d4 <vector37>:
.globl vector37
vector37:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $37
801067d6:	6a 25                	push   $0x25
  jmp alltraps
801067d8:	e9 01 fa ff ff       	jmp    801061de <alltraps>

801067dd <vector38>:
.globl vector38
vector38:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $38
801067df:	6a 26                	push   $0x26
  jmp alltraps
801067e1:	e9 f8 f9 ff ff       	jmp    801061de <alltraps>

801067e6 <vector39>:
.globl vector39
vector39:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $39
801067e8:	6a 27                	push   $0x27
  jmp alltraps
801067ea:	e9 ef f9 ff ff       	jmp    801061de <alltraps>

801067ef <vector40>:
.globl vector40
vector40:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $40
801067f1:	6a 28                	push   $0x28
  jmp alltraps
801067f3:	e9 e6 f9 ff ff       	jmp    801061de <alltraps>

801067f8 <vector41>:
.globl vector41
vector41:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $41
801067fa:	6a 29                	push   $0x29
  jmp alltraps
801067fc:	e9 dd f9 ff ff       	jmp    801061de <alltraps>

80106801 <vector42>:
.globl vector42
vector42:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $42
80106803:	6a 2a                	push   $0x2a
  jmp alltraps
80106805:	e9 d4 f9 ff ff       	jmp    801061de <alltraps>

8010680a <vector43>:
.globl vector43
vector43:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $43
8010680c:	6a 2b                	push   $0x2b
  jmp alltraps
8010680e:	e9 cb f9 ff ff       	jmp    801061de <alltraps>

80106813 <vector44>:
.globl vector44
vector44:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $44
80106815:	6a 2c                	push   $0x2c
  jmp alltraps
80106817:	e9 c2 f9 ff ff       	jmp    801061de <alltraps>

8010681c <vector45>:
.globl vector45
vector45:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $45
8010681e:	6a 2d                	push   $0x2d
  jmp alltraps
80106820:	e9 b9 f9 ff ff       	jmp    801061de <alltraps>

80106825 <vector46>:
.globl vector46
vector46:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $46
80106827:	6a 2e                	push   $0x2e
  jmp alltraps
80106829:	e9 b0 f9 ff ff       	jmp    801061de <alltraps>

8010682e <vector47>:
.globl vector47
vector47:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $47
80106830:	6a 2f                	push   $0x2f
  jmp alltraps
80106832:	e9 a7 f9 ff ff       	jmp    801061de <alltraps>

80106837 <vector48>:
.globl vector48
vector48:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $48
80106839:	6a 30                	push   $0x30
  jmp alltraps
8010683b:	e9 9e f9 ff ff       	jmp    801061de <alltraps>

80106840 <vector49>:
.globl vector49
vector49:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $49
80106842:	6a 31                	push   $0x31
  jmp alltraps
80106844:	e9 95 f9 ff ff       	jmp    801061de <alltraps>

80106849 <vector50>:
.globl vector50
vector50:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $50
8010684b:	6a 32                	push   $0x32
  jmp alltraps
8010684d:	e9 8c f9 ff ff       	jmp    801061de <alltraps>

80106852 <vector51>:
.globl vector51
vector51:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $51
80106854:	6a 33                	push   $0x33
  jmp alltraps
80106856:	e9 83 f9 ff ff       	jmp    801061de <alltraps>

8010685b <vector52>:
.globl vector52
vector52:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $52
8010685d:	6a 34                	push   $0x34
  jmp alltraps
8010685f:	e9 7a f9 ff ff       	jmp    801061de <alltraps>

80106864 <vector53>:
.globl vector53
vector53:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $53
80106866:	6a 35                	push   $0x35
  jmp alltraps
80106868:	e9 71 f9 ff ff       	jmp    801061de <alltraps>

8010686d <vector54>:
.globl vector54
vector54:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $54
8010686f:	6a 36                	push   $0x36
  jmp alltraps
80106871:	e9 68 f9 ff ff       	jmp    801061de <alltraps>

80106876 <vector55>:
.globl vector55
vector55:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $55
80106878:	6a 37                	push   $0x37
  jmp alltraps
8010687a:	e9 5f f9 ff ff       	jmp    801061de <alltraps>

8010687f <vector56>:
.globl vector56
vector56:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $56
80106881:	6a 38                	push   $0x38
  jmp alltraps
80106883:	e9 56 f9 ff ff       	jmp    801061de <alltraps>

80106888 <vector57>:
.globl vector57
vector57:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $57
8010688a:	6a 39                	push   $0x39
  jmp alltraps
8010688c:	e9 4d f9 ff ff       	jmp    801061de <alltraps>

80106891 <vector58>:
.globl vector58
vector58:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $58
80106893:	6a 3a                	push   $0x3a
  jmp alltraps
80106895:	e9 44 f9 ff ff       	jmp    801061de <alltraps>

8010689a <vector59>:
.globl vector59
vector59:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $59
8010689c:	6a 3b                	push   $0x3b
  jmp alltraps
8010689e:	e9 3b f9 ff ff       	jmp    801061de <alltraps>

801068a3 <vector60>:
.globl vector60
vector60:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $60
801068a5:	6a 3c                	push   $0x3c
  jmp alltraps
801068a7:	e9 32 f9 ff ff       	jmp    801061de <alltraps>

801068ac <vector61>:
.globl vector61
vector61:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $61
801068ae:	6a 3d                	push   $0x3d
  jmp alltraps
801068b0:	e9 29 f9 ff ff       	jmp    801061de <alltraps>

801068b5 <vector62>:
.globl vector62
vector62:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $62
801068b7:	6a 3e                	push   $0x3e
  jmp alltraps
801068b9:	e9 20 f9 ff ff       	jmp    801061de <alltraps>

801068be <vector63>:
.globl vector63
vector63:
  pushl $0
801068be:	6a 00                	push   $0x0
  pushl $63
801068c0:	6a 3f                	push   $0x3f
  jmp alltraps
801068c2:	e9 17 f9 ff ff       	jmp    801061de <alltraps>

801068c7 <vector64>:
.globl vector64
vector64:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $64
801068c9:	6a 40                	push   $0x40
  jmp alltraps
801068cb:	e9 0e f9 ff ff       	jmp    801061de <alltraps>

801068d0 <vector65>:
.globl vector65
vector65:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $65
801068d2:	6a 41                	push   $0x41
  jmp alltraps
801068d4:	e9 05 f9 ff ff       	jmp    801061de <alltraps>

801068d9 <vector66>:
.globl vector66
vector66:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $66
801068db:	6a 42                	push   $0x42
  jmp alltraps
801068dd:	e9 fc f8 ff ff       	jmp    801061de <alltraps>

801068e2 <vector67>:
.globl vector67
vector67:
  pushl $0
801068e2:	6a 00                	push   $0x0
  pushl $67
801068e4:	6a 43                	push   $0x43
  jmp alltraps
801068e6:	e9 f3 f8 ff ff       	jmp    801061de <alltraps>

801068eb <vector68>:
.globl vector68
vector68:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $68
801068ed:	6a 44                	push   $0x44
  jmp alltraps
801068ef:	e9 ea f8 ff ff       	jmp    801061de <alltraps>

801068f4 <vector69>:
.globl vector69
vector69:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $69
801068f6:	6a 45                	push   $0x45
  jmp alltraps
801068f8:	e9 e1 f8 ff ff       	jmp    801061de <alltraps>

801068fd <vector70>:
.globl vector70
vector70:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $70
801068ff:	6a 46                	push   $0x46
  jmp alltraps
80106901:	e9 d8 f8 ff ff       	jmp    801061de <alltraps>

80106906 <vector71>:
.globl vector71
vector71:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $71
80106908:	6a 47                	push   $0x47
  jmp alltraps
8010690a:	e9 cf f8 ff ff       	jmp    801061de <alltraps>

8010690f <vector72>:
.globl vector72
vector72:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $72
80106911:	6a 48                	push   $0x48
  jmp alltraps
80106913:	e9 c6 f8 ff ff       	jmp    801061de <alltraps>

80106918 <vector73>:
.globl vector73
vector73:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $73
8010691a:	6a 49                	push   $0x49
  jmp alltraps
8010691c:	e9 bd f8 ff ff       	jmp    801061de <alltraps>

80106921 <vector74>:
.globl vector74
vector74:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $74
80106923:	6a 4a                	push   $0x4a
  jmp alltraps
80106925:	e9 b4 f8 ff ff       	jmp    801061de <alltraps>

8010692a <vector75>:
.globl vector75
vector75:
  pushl $0
8010692a:	6a 00                	push   $0x0
  pushl $75
8010692c:	6a 4b                	push   $0x4b
  jmp alltraps
8010692e:	e9 ab f8 ff ff       	jmp    801061de <alltraps>

80106933 <vector76>:
.globl vector76
vector76:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $76
80106935:	6a 4c                	push   $0x4c
  jmp alltraps
80106937:	e9 a2 f8 ff ff       	jmp    801061de <alltraps>

8010693c <vector77>:
.globl vector77
vector77:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $77
8010693e:	6a 4d                	push   $0x4d
  jmp alltraps
80106940:	e9 99 f8 ff ff       	jmp    801061de <alltraps>

80106945 <vector78>:
.globl vector78
vector78:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $78
80106947:	6a 4e                	push   $0x4e
  jmp alltraps
80106949:	e9 90 f8 ff ff       	jmp    801061de <alltraps>

8010694e <vector79>:
.globl vector79
vector79:
  pushl $0
8010694e:	6a 00                	push   $0x0
  pushl $79
80106950:	6a 4f                	push   $0x4f
  jmp alltraps
80106952:	e9 87 f8 ff ff       	jmp    801061de <alltraps>

80106957 <vector80>:
.globl vector80
vector80:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $80
80106959:	6a 50                	push   $0x50
  jmp alltraps
8010695b:	e9 7e f8 ff ff       	jmp    801061de <alltraps>

80106960 <vector81>:
.globl vector81
vector81:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $81
80106962:	6a 51                	push   $0x51
  jmp alltraps
80106964:	e9 75 f8 ff ff       	jmp    801061de <alltraps>

80106969 <vector82>:
.globl vector82
vector82:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $82
8010696b:	6a 52                	push   $0x52
  jmp alltraps
8010696d:	e9 6c f8 ff ff       	jmp    801061de <alltraps>

80106972 <vector83>:
.globl vector83
vector83:
  pushl $0
80106972:	6a 00                	push   $0x0
  pushl $83
80106974:	6a 53                	push   $0x53
  jmp alltraps
80106976:	e9 63 f8 ff ff       	jmp    801061de <alltraps>

8010697b <vector84>:
.globl vector84
vector84:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $84
8010697d:	6a 54                	push   $0x54
  jmp alltraps
8010697f:	e9 5a f8 ff ff       	jmp    801061de <alltraps>

80106984 <vector85>:
.globl vector85
vector85:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $85
80106986:	6a 55                	push   $0x55
  jmp alltraps
80106988:	e9 51 f8 ff ff       	jmp    801061de <alltraps>

8010698d <vector86>:
.globl vector86
vector86:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $86
8010698f:	6a 56                	push   $0x56
  jmp alltraps
80106991:	e9 48 f8 ff ff       	jmp    801061de <alltraps>

80106996 <vector87>:
.globl vector87
vector87:
  pushl $0
80106996:	6a 00                	push   $0x0
  pushl $87
80106998:	6a 57                	push   $0x57
  jmp alltraps
8010699a:	e9 3f f8 ff ff       	jmp    801061de <alltraps>

8010699f <vector88>:
.globl vector88
vector88:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $88
801069a1:	6a 58                	push   $0x58
  jmp alltraps
801069a3:	e9 36 f8 ff ff       	jmp    801061de <alltraps>

801069a8 <vector89>:
.globl vector89
vector89:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $89
801069aa:	6a 59                	push   $0x59
  jmp alltraps
801069ac:	e9 2d f8 ff ff       	jmp    801061de <alltraps>

801069b1 <vector90>:
.globl vector90
vector90:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $90
801069b3:	6a 5a                	push   $0x5a
  jmp alltraps
801069b5:	e9 24 f8 ff ff       	jmp    801061de <alltraps>

801069ba <vector91>:
.globl vector91
vector91:
  pushl $0
801069ba:	6a 00                	push   $0x0
  pushl $91
801069bc:	6a 5b                	push   $0x5b
  jmp alltraps
801069be:	e9 1b f8 ff ff       	jmp    801061de <alltraps>

801069c3 <vector92>:
.globl vector92
vector92:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $92
801069c5:	6a 5c                	push   $0x5c
  jmp alltraps
801069c7:	e9 12 f8 ff ff       	jmp    801061de <alltraps>

801069cc <vector93>:
.globl vector93
vector93:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $93
801069ce:	6a 5d                	push   $0x5d
  jmp alltraps
801069d0:	e9 09 f8 ff ff       	jmp    801061de <alltraps>

801069d5 <vector94>:
.globl vector94
vector94:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $94
801069d7:	6a 5e                	push   $0x5e
  jmp alltraps
801069d9:	e9 00 f8 ff ff       	jmp    801061de <alltraps>

801069de <vector95>:
.globl vector95
vector95:
  pushl $0
801069de:	6a 00                	push   $0x0
  pushl $95
801069e0:	6a 5f                	push   $0x5f
  jmp alltraps
801069e2:	e9 f7 f7 ff ff       	jmp    801061de <alltraps>

801069e7 <vector96>:
.globl vector96
vector96:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $96
801069e9:	6a 60                	push   $0x60
  jmp alltraps
801069eb:	e9 ee f7 ff ff       	jmp    801061de <alltraps>

801069f0 <vector97>:
.globl vector97
vector97:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $97
801069f2:	6a 61                	push   $0x61
  jmp alltraps
801069f4:	e9 e5 f7 ff ff       	jmp    801061de <alltraps>

801069f9 <vector98>:
.globl vector98
vector98:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $98
801069fb:	6a 62                	push   $0x62
  jmp alltraps
801069fd:	e9 dc f7 ff ff       	jmp    801061de <alltraps>

80106a02 <vector99>:
.globl vector99
vector99:
  pushl $0
80106a02:	6a 00                	push   $0x0
  pushl $99
80106a04:	6a 63                	push   $0x63
  jmp alltraps
80106a06:	e9 d3 f7 ff ff       	jmp    801061de <alltraps>

80106a0b <vector100>:
.globl vector100
vector100:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $100
80106a0d:	6a 64                	push   $0x64
  jmp alltraps
80106a0f:	e9 ca f7 ff ff       	jmp    801061de <alltraps>

80106a14 <vector101>:
.globl vector101
vector101:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $101
80106a16:	6a 65                	push   $0x65
  jmp alltraps
80106a18:	e9 c1 f7 ff ff       	jmp    801061de <alltraps>

80106a1d <vector102>:
.globl vector102
vector102:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $102
80106a1f:	6a 66                	push   $0x66
  jmp alltraps
80106a21:	e9 b8 f7 ff ff       	jmp    801061de <alltraps>

80106a26 <vector103>:
.globl vector103
vector103:
  pushl $0
80106a26:	6a 00                	push   $0x0
  pushl $103
80106a28:	6a 67                	push   $0x67
  jmp alltraps
80106a2a:	e9 af f7 ff ff       	jmp    801061de <alltraps>

80106a2f <vector104>:
.globl vector104
vector104:
  pushl $0
80106a2f:	6a 00                	push   $0x0
  pushl $104
80106a31:	6a 68                	push   $0x68
  jmp alltraps
80106a33:	e9 a6 f7 ff ff       	jmp    801061de <alltraps>

80106a38 <vector105>:
.globl vector105
vector105:
  pushl $0
80106a38:	6a 00                	push   $0x0
  pushl $105
80106a3a:	6a 69                	push   $0x69
  jmp alltraps
80106a3c:	e9 9d f7 ff ff       	jmp    801061de <alltraps>

80106a41 <vector106>:
.globl vector106
vector106:
  pushl $0
80106a41:	6a 00                	push   $0x0
  pushl $106
80106a43:	6a 6a                	push   $0x6a
  jmp alltraps
80106a45:	e9 94 f7 ff ff       	jmp    801061de <alltraps>

80106a4a <vector107>:
.globl vector107
vector107:
  pushl $0
80106a4a:	6a 00                	push   $0x0
  pushl $107
80106a4c:	6a 6b                	push   $0x6b
  jmp alltraps
80106a4e:	e9 8b f7 ff ff       	jmp    801061de <alltraps>

80106a53 <vector108>:
.globl vector108
vector108:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $108
80106a55:	6a 6c                	push   $0x6c
  jmp alltraps
80106a57:	e9 82 f7 ff ff       	jmp    801061de <alltraps>

80106a5c <vector109>:
.globl vector109
vector109:
  pushl $0
80106a5c:	6a 00                	push   $0x0
  pushl $109
80106a5e:	6a 6d                	push   $0x6d
  jmp alltraps
80106a60:	e9 79 f7 ff ff       	jmp    801061de <alltraps>

80106a65 <vector110>:
.globl vector110
vector110:
  pushl $0
80106a65:	6a 00                	push   $0x0
  pushl $110
80106a67:	6a 6e                	push   $0x6e
  jmp alltraps
80106a69:	e9 70 f7 ff ff       	jmp    801061de <alltraps>

80106a6e <vector111>:
.globl vector111
vector111:
  pushl $0
80106a6e:	6a 00                	push   $0x0
  pushl $111
80106a70:	6a 6f                	push   $0x6f
  jmp alltraps
80106a72:	e9 67 f7 ff ff       	jmp    801061de <alltraps>

80106a77 <vector112>:
.globl vector112
vector112:
  pushl $0
80106a77:	6a 00                	push   $0x0
  pushl $112
80106a79:	6a 70                	push   $0x70
  jmp alltraps
80106a7b:	e9 5e f7 ff ff       	jmp    801061de <alltraps>

80106a80 <vector113>:
.globl vector113
vector113:
  pushl $0
80106a80:	6a 00                	push   $0x0
  pushl $113
80106a82:	6a 71                	push   $0x71
  jmp alltraps
80106a84:	e9 55 f7 ff ff       	jmp    801061de <alltraps>

80106a89 <vector114>:
.globl vector114
vector114:
  pushl $0
80106a89:	6a 00                	push   $0x0
  pushl $114
80106a8b:	6a 72                	push   $0x72
  jmp alltraps
80106a8d:	e9 4c f7 ff ff       	jmp    801061de <alltraps>

80106a92 <vector115>:
.globl vector115
vector115:
  pushl $0
80106a92:	6a 00                	push   $0x0
  pushl $115
80106a94:	6a 73                	push   $0x73
  jmp alltraps
80106a96:	e9 43 f7 ff ff       	jmp    801061de <alltraps>

80106a9b <vector116>:
.globl vector116
vector116:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $116
80106a9d:	6a 74                	push   $0x74
  jmp alltraps
80106a9f:	e9 3a f7 ff ff       	jmp    801061de <alltraps>

80106aa4 <vector117>:
.globl vector117
vector117:
  pushl $0
80106aa4:	6a 00                	push   $0x0
  pushl $117
80106aa6:	6a 75                	push   $0x75
  jmp alltraps
80106aa8:	e9 31 f7 ff ff       	jmp    801061de <alltraps>

80106aad <vector118>:
.globl vector118
vector118:
  pushl $0
80106aad:	6a 00                	push   $0x0
  pushl $118
80106aaf:	6a 76                	push   $0x76
  jmp alltraps
80106ab1:	e9 28 f7 ff ff       	jmp    801061de <alltraps>

80106ab6 <vector119>:
.globl vector119
vector119:
  pushl $0
80106ab6:	6a 00                	push   $0x0
  pushl $119
80106ab8:	6a 77                	push   $0x77
  jmp alltraps
80106aba:	e9 1f f7 ff ff       	jmp    801061de <alltraps>

80106abf <vector120>:
.globl vector120
vector120:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $120
80106ac1:	6a 78                	push   $0x78
  jmp alltraps
80106ac3:	e9 16 f7 ff ff       	jmp    801061de <alltraps>

80106ac8 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ac8:	6a 00                	push   $0x0
  pushl $121
80106aca:	6a 79                	push   $0x79
  jmp alltraps
80106acc:	e9 0d f7 ff ff       	jmp    801061de <alltraps>

80106ad1 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ad1:	6a 00                	push   $0x0
  pushl $122
80106ad3:	6a 7a                	push   $0x7a
  jmp alltraps
80106ad5:	e9 04 f7 ff ff       	jmp    801061de <alltraps>

80106ada <vector123>:
.globl vector123
vector123:
  pushl $0
80106ada:	6a 00                	push   $0x0
  pushl $123
80106adc:	6a 7b                	push   $0x7b
  jmp alltraps
80106ade:	e9 fb f6 ff ff       	jmp    801061de <alltraps>

80106ae3 <vector124>:
.globl vector124
vector124:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $124
80106ae5:	6a 7c                	push   $0x7c
  jmp alltraps
80106ae7:	e9 f2 f6 ff ff       	jmp    801061de <alltraps>

80106aec <vector125>:
.globl vector125
vector125:
  pushl $0
80106aec:	6a 00                	push   $0x0
  pushl $125
80106aee:	6a 7d                	push   $0x7d
  jmp alltraps
80106af0:	e9 e9 f6 ff ff       	jmp    801061de <alltraps>

80106af5 <vector126>:
.globl vector126
vector126:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $126
80106af7:	6a 7e                	push   $0x7e
  jmp alltraps
80106af9:	e9 e0 f6 ff ff       	jmp    801061de <alltraps>

80106afe <vector127>:
.globl vector127
vector127:
  pushl $0
80106afe:	6a 00                	push   $0x0
  pushl $127
80106b00:	6a 7f                	push   $0x7f
  jmp alltraps
80106b02:	e9 d7 f6 ff ff       	jmp    801061de <alltraps>

80106b07 <vector128>:
.globl vector128
vector128:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $128
80106b09:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106b0e:	e9 cb f6 ff ff       	jmp    801061de <alltraps>

80106b13 <vector129>:
.globl vector129
vector129:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $129
80106b15:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106b1a:	e9 bf f6 ff ff       	jmp    801061de <alltraps>

80106b1f <vector130>:
.globl vector130
vector130:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $130
80106b21:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106b26:	e9 b3 f6 ff ff       	jmp    801061de <alltraps>

80106b2b <vector131>:
.globl vector131
vector131:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $131
80106b2d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106b32:	e9 a7 f6 ff ff       	jmp    801061de <alltraps>

80106b37 <vector132>:
.globl vector132
vector132:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $132
80106b39:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106b3e:	e9 9b f6 ff ff       	jmp    801061de <alltraps>

80106b43 <vector133>:
.globl vector133
vector133:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $133
80106b45:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106b4a:	e9 8f f6 ff ff       	jmp    801061de <alltraps>

80106b4f <vector134>:
.globl vector134
vector134:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $134
80106b51:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106b56:	e9 83 f6 ff ff       	jmp    801061de <alltraps>

80106b5b <vector135>:
.globl vector135
vector135:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $135
80106b5d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106b62:	e9 77 f6 ff ff       	jmp    801061de <alltraps>

80106b67 <vector136>:
.globl vector136
vector136:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $136
80106b69:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106b6e:	e9 6b f6 ff ff       	jmp    801061de <alltraps>

80106b73 <vector137>:
.globl vector137
vector137:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $137
80106b75:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106b7a:	e9 5f f6 ff ff       	jmp    801061de <alltraps>

80106b7f <vector138>:
.globl vector138
vector138:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $138
80106b81:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106b86:	e9 53 f6 ff ff       	jmp    801061de <alltraps>

80106b8b <vector139>:
.globl vector139
vector139:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $139
80106b8d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106b92:	e9 47 f6 ff ff       	jmp    801061de <alltraps>

80106b97 <vector140>:
.globl vector140
vector140:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $140
80106b99:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106b9e:	e9 3b f6 ff ff       	jmp    801061de <alltraps>

80106ba3 <vector141>:
.globl vector141
vector141:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $141
80106ba5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106baa:	e9 2f f6 ff ff       	jmp    801061de <alltraps>

80106baf <vector142>:
.globl vector142
vector142:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $142
80106bb1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106bb6:	e9 23 f6 ff ff       	jmp    801061de <alltraps>

80106bbb <vector143>:
.globl vector143
vector143:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $143
80106bbd:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106bc2:	e9 17 f6 ff ff       	jmp    801061de <alltraps>

80106bc7 <vector144>:
.globl vector144
vector144:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $144
80106bc9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106bce:	e9 0b f6 ff ff       	jmp    801061de <alltraps>

80106bd3 <vector145>:
.globl vector145
vector145:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $145
80106bd5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106bda:	e9 ff f5 ff ff       	jmp    801061de <alltraps>

80106bdf <vector146>:
.globl vector146
vector146:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $146
80106be1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106be6:	e9 f3 f5 ff ff       	jmp    801061de <alltraps>

80106beb <vector147>:
.globl vector147
vector147:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $147
80106bed:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106bf2:	e9 e7 f5 ff ff       	jmp    801061de <alltraps>

80106bf7 <vector148>:
.globl vector148
vector148:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $148
80106bf9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106bfe:	e9 db f5 ff ff       	jmp    801061de <alltraps>

80106c03 <vector149>:
.globl vector149
vector149:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $149
80106c05:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106c0a:	e9 cf f5 ff ff       	jmp    801061de <alltraps>

80106c0f <vector150>:
.globl vector150
vector150:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $150
80106c11:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106c16:	e9 c3 f5 ff ff       	jmp    801061de <alltraps>

80106c1b <vector151>:
.globl vector151
vector151:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $151
80106c1d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106c22:	e9 b7 f5 ff ff       	jmp    801061de <alltraps>

80106c27 <vector152>:
.globl vector152
vector152:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $152
80106c29:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106c2e:	e9 ab f5 ff ff       	jmp    801061de <alltraps>

80106c33 <vector153>:
.globl vector153
vector153:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $153
80106c35:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106c3a:	e9 9f f5 ff ff       	jmp    801061de <alltraps>

80106c3f <vector154>:
.globl vector154
vector154:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $154
80106c41:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106c46:	e9 93 f5 ff ff       	jmp    801061de <alltraps>

80106c4b <vector155>:
.globl vector155
vector155:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $155
80106c4d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106c52:	e9 87 f5 ff ff       	jmp    801061de <alltraps>

80106c57 <vector156>:
.globl vector156
vector156:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $156
80106c59:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106c5e:	e9 7b f5 ff ff       	jmp    801061de <alltraps>

80106c63 <vector157>:
.globl vector157
vector157:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $157
80106c65:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106c6a:	e9 6f f5 ff ff       	jmp    801061de <alltraps>

80106c6f <vector158>:
.globl vector158
vector158:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $158
80106c71:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106c76:	e9 63 f5 ff ff       	jmp    801061de <alltraps>

80106c7b <vector159>:
.globl vector159
vector159:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $159
80106c7d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106c82:	e9 57 f5 ff ff       	jmp    801061de <alltraps>

80106c87 <vector160>:
.globl vector160
vector160:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $160
80106c89:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106c8e:	e9 4b f5 ff ff       	jmp    801061de <alltraps>

80106c93 <vector161>:
.globl vector161
vector161:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $161
80106c95:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106c9a:	e9 3f f5 ff ff       	jmp    801061de <alltraps>

80106c9f <vector162>:
.globl vector162
vector162:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $162
80106ca1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ca6:	e9 33 f5 ff ff       	jmp    801061de <alltraps>

80106cab <vector163>:
.globl vector163
vector163:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $163
80106cad:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106cb2:	e9 27 f5 ff ff       	jmp    801061de <alltraps>

80106cb7 <vector164>:
.globl vector164
vector164:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $164
80106cb9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106cbe:	e9 1b f5 ff ff       	jmp    801061de <alltraps>

80106cc3 <vector165>:
.globl vector165
vector165:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $165
80106cc5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106cca:	e9 0f f5 ff ff       	jmp    801061de <alltraps>

80106ccf <vector166>:
.globl vector166
vector166:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $166
80106cd1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106cd6:	e9 03 f5 ff ff       	jmp    801061de <alltraps>

80106cdb <vector167>:
.globl vector167
vector167:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $167
80106cdd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106ce2:	e9 f7 f4 ff ff       	jmp    801061de <alltraps>

80106ce7 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $168
80106ce9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106cee:	e9 eb f4 ff ff       	jmp    801061de <alltraps>

80106cf3 <vector169>:
.globl vector169
vector169:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $169
80106cf5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106cfa:	e9 df f4 ff ff       	jmp    801061de <alltraps>

80106cff <vector170>:
.globl vector170
vector170:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $170
80106d01:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106d06:	e9 d3 f4 ff ff       	jmp    801061de <alltraps>

80106d0b <vector171>:
.globl vector171
vector171:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $171
80106d0d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106d12:	e9 c7 f4 ff ff       	jmp    801061de <alltraps>

80106d17 <vector172>:
.globl vector172
vector172:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $172
80106d19:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106d1e:	e9 bb f4 ff ff       	jmp    801061de <alltraps>

80106d23 <vector173>:
.globl vector173
vector173:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $173
80106d25:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106d2a:	e9 af f4 ff ff       	jmp    801061de <alltraps>

80106d2f <vector174>:
.globl vector174
vector174:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $174
80106d31:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106d36:	e9 a3 f4 ff ff       	jmp    801061de <alltraps>

80106d3b <vector175>:
.globl vector175
vector175:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $175
80106d3d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106d42:	e9 97 f4 ff ff       	jmp    801061de <alltraps>

80106d47 <vector176>:
.globl vector176
vector176:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $176
80106d49:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106d4e:	e9 8b f4 ff ff       	jmp    801061de <alltraps>

80106d53 <vector177>:
.globl vector177
vector177:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $177
80106d55:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106d5a:	e9 7f f4 ff ff       	jmp    801061de <alltraps>

80106d5f <vector178>:
.globl vector178
vector178:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $178
80106d61:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106d66:	e9 73 f4 ff ff       	jmp    801061de <alltraps>

80106d6b <vector179>:
.globl vector179
vector179:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $179
80106d6d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106d72:	e9 67 f4 ff ff       	jmp    801061de <alltraps>

80106d77 <vector180>:
.globl vector180
vector180:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $180
80106d79:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106d7e:	e9 5b f4 ff ff       	jmp    801061de <alltraps>

80106d83 <vector181>:
.globl vector181
vector181:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $181
80106d85:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106d8a:	e9 4f f4 ff ff       	jmp    801061de <alltraps>

80106d8f <vector182>:
.globl vector182
vector182:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $182
80106d91:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106d96:	e9 43 f4 ff ff       	jmp    801061de <alltraps>

80106d9b <vector183>:
.globl vector183
vector183:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $183
80106d9d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106da2:	e9 37 f4 ff ff       	jmp    801061de <alltraps>

80106da7 <vector184>:
.globl vector184
vector184:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $184
80106da9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106dae:	e9 2b f4 ff ff       	jmp    801061de <alltraps>

80106db3 <vector185>:
.globl vector185
vector185:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $185
80106db5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106dba:	e9 1f f4 ff ff       	jmp    801061de <alltraps>

80106dbf <vector186>:
.globl vector186
vector186:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $186
80106dc1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106dc6:	e9 13 f4 ff ff       	jmp    801061de <alltraps>

80106dcb <vector187>:
.globl vector187
vector187:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $187
80106dcd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106dd2:	e9 07 f4 ff ff       	jmp    801061de <alltraps>

80106dd7 <vector188>:
.globl vector188
vector188:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $188
80106dd9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106dde:	e9 fb f3 ff ff       	jmp    801061de <alltraps>

80106de3 <vector189>:
.globl vector189
vector189:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $189
80106de5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106dea:	e9 ef f3 ff ff       	jmp    801061de <alltraps>

80106def <vector190>:
.globl vector190
vector190:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $190
80106df1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106df6:	e9 e3 f3 ff ff       	jmp    801061de <alltraps>

80106dfb <vector191>:
.globl vector191
vector191:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $191
80106dfd:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106e02:	e9 d7 f3 ff ff       	jmp    801061de <alltraps>

80106e07 <vector192>:
.globl vector192
vector192:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $192
80106e09:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106e0e:	e9 cb f3 ff ff       	jmp    801061de <alltraps>

80106e13 <vector193>:
.globl vector193
vector193:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $193
80106e15:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106e1a:	e9 bf f3 ff ff       	jmp    801061de <alltraps>

80106e1f <vector194>:
.globl vector194
vector194:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $194
80106e21:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106e26:	e9 b3 f3 ff ff       	jmp    801061de <alltraps>

80106e2b <vector195>:
.globl vector195
vector195:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $195
80106e2d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106e32:	e9 a7 f3 ff ff       	jmp    801061de <alltraps>

80106e37 <vector196>:
.globl vector196
vector196:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $196
80106e39:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106e3e:	e9 9b f3 ff ff       	jmp    801061de <alltraps>

80106e43 <vector197>:
.globl vector197
vector197:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $197
80106e45:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106e4a:	e9 8f f3 ff ff       	jmp    801061de <alltraps>

80106e4f <vector198>:
.globl vector198
vector198:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $198
80106e51:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106e56:	e9 83 f3 ff ff       	jmp    801061de <alltraps>

80106e5b <vector199>:
.globl vector199
vector199:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $199
80106e5d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106e62:	e9 77 f3 ff ff       	jmp    801061de <alltraps>

80106e67 <vector200>:
.globl vector200
vector200:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $200
80106e69:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106e6e:	e9 6b f3 ff ff       	jmp    801061de <alltraps>

80106e73 <vector201>:
.globl vector201
vector201:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $201
80106e75:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106e7a:	e9 5f f3 ff ff       	jmp    801061de <alltraps>

80106e7f <vector202>:
.globl vector202
vector202:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $202
80106e81:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106e86:	e9 53 f3 ff ff       	jmp    801061de <alltraps>

80106e8b <vector203>:
.globl vector203
vector203:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $203
80106e8d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106e92:	e9 47 f3 ff ff       	jmp    801061de <alltraps>

80106e97 <vector204>:
.globl vector204
vector204:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $204
80106e99:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106e9e:	e9 3b f3 ff ff       	jmp    801061de <alltraps>

80106ea3 <vector205>:
.globl vector205
vector205:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $205
80106ea5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106eaa:	e9 2f f3 ff ff       	jmp    801061de <alltraps>

80106eaf <vector206>:
.globl vector206
vector206:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $206
80106eb1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106eb6:	e9 23 f3 ff ff       	jmp    801061de <alltraps>

80106ebb <vector207>:
.globl vector207
vector207:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $207
80106ebd:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106ec2:	e9 17 f3 ff ff       	jmp    801061de <alltraps>

80106ec7 <vector208>:
.globl vector208
vector208:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $208
80106ec9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106ece:	e9 0b f3 ff ff       	jmp    801061de <alltraps>

80106ed3 <vector209>:
.globl vector209
vector209:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $209
80106ed5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106eda:	e9 ff f2 ff ff       	jmp    801061de <alltraps>

80106edf <vector210>:
.globl vector210
vector210:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $210
80106ee1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106ee6:	e9 f3 f2 ff ff       	jmp    801061de <alltraps>

80106eeb <vector211>:
.globl vector211
vector211:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $211
80106eed:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106ef2:	e9 e7 f2 ff ff       	jmp    801061de <alltraps>

80106ef7 <vector212>:
.globl vector212
vector212:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $212
80106ef9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106efe:	e9 db f2 ff ff       	jmp    801061de <alltraps>

80106f03 <vector213>:
.globl vector213
vector213:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $213
80106f05:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106f0a:	e9 cf f2 ff ff       	jmp    801061de <alltraps>

80106f0f <vector214>:
.globl vector214
vector214:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $214
80106f11:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106f16:	e9 c3 f2 ff ff       	jmp    801061de <alltraps>

80106f1b <vector215>:
.globl vector215
vector215:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $215
80106f1d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106f22:	e9 b7 f2 ff ff       	jmp    801061de <alltraps>

80106f27 <vector216>:
.globl vector216
vector216:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $216
80106f29:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106f2e:	e9 ab f2 ff ff       	jmp    801061de <alltraps>

80106f33 <vector217>:
.globl vector217
vector217:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $217
80106f35:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106f3a:	e9 9f f2 ff ff       	jmp    801061de <alltraps>

80106f3f <vector218>:
.globl vector218
vector218:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $218
80106f41:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106f46:	e9 93 f2 ff ff       	jmp    801061de <alltraps>

80106f4b <vector219>:
.globl vector219
vector219:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $219
80106f4d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106f52:	e9 87 f2 ff ff       	jmp    801061de <alltraps>

80106f57 <vector220>:
.globl vector220
vector220:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $220
80106f59:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106f5e:	e9 7b f2 ff ff       	jmp    801061de <alltraps>

80106f63 <vector221>:
.globl vector221
vector221:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $221
80106f65:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106f6a:	e9 6f f2 ff ff       	jmp    801061de <alltraps>

80106f6f <vector222>:
.globl vector222
vector222:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $222
80106f71:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106f76:	e9 63 f2 ff ff       	jmp    801061de <alltraps>

80106f7b <vector223>:
.globl vector223
vector223:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $223
80106f7d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106f82:	e9 57 f2 ff ff       	jmp    801061de <alltraps>

80106f87 <vector224>:
.globl vector224
vector224:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $224
80106f89:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106f8e:	e9 4b f2 ff ff       	jmp    801061de <alltraps>

80106f93 <vector225>:
.globl vector225
vector225:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $225
80106f95:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106f9a:	e9 3f f2 ff ff       	jmp    801061de <alltraps>

80106f9f <vector226>:
.globl vector226
vector226:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $226
80106fa1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106fa6:	e9 33 f2 ff ff       	jmp    801061de <alltraps>

80106fab <vector227>:
.globl vector227
vector227:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $227
80106fad:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106fb2:	e9 27 f2 ff ff       	jmp    801061de <alltraps>

80106fb7 <vector228>:
.globl vector228
vector228:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $228
80106fb9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106fbe:	e9 1b f2 ff ff       	jmp    801061de <alltraps>

80106fc3 <vector229>:
.globl vector229
vector229:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $229
80106fc5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106fca:	e9 0f f2 ff ff       	jmp    801061de <alltraps>

80106fcf <vector230>:
.globl vector230
vector230:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $230
80106fd1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106fd6:	e9 03 f2 ff ff       	jmp    801061de <alltraps>

80106fdb <vector231>:
.globl vector231
vector231:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $231
80106fdd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106fe2:	e9 f7 f1 ff ff       	jmp    801061de <alltraps>

80106fe7 <vector232>:
.globl vector232
vector232:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $232
80106fe9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106fee:	e9 eb f1 ff ff       	jmp    801061de <alltraps>

80106ff3 <vector233>:
.globl vector233
vector233:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $233
80106ff5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106ffa:	e9 df f1 ff ff       	jmp    801061de <alltraps>

80106fff <vector234>:
.globl vector234
vector234:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $234
80107001:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107006:	e9 d3 f1 ff ff       	jmp    801061de <alltraps>

8010700b <vector235>:
.globl vector235
vector235:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $235
8010700d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107012:	e9 c7 f1 ff ff       	jmp    801061de <alltraps>

80107017 <vector236>:
.globl vector236
vector236:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $236
80107019:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010701e:	e9 bb f1 ff ff       	jmp    801061de <alltraps>

80107023 <vector237>:
.globl vector237
vector237:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $237
80107025:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010702a:	e9 af f1 ff ff       	jmp    801061de <alltraps>

8010702f <vector238>:
.globl vector238
vector238:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $238
80107031:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107036:	e9 a3 f1 ff ff       	jmp    801061de <alltraps>

8010703b <vector239>:
.globl vector239
vector239:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $239
8010703d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107042:	e9 97 f1 ff ff       	jmp    801061de <alltraps>

80107047 <vector240>:
.globl vector240
vector240:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $240
80107049:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010704e:	e9 8b f1 ff ff       	jmp    801061de <alltraps>

80107053 <vector241>:
.globl vector241
vector241:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $241
80107055:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010705a:	e9 7f f1 ff ff       	jmp    801061de <alltraps>

8010705f <vector242>:
.globl vector242
vector242:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $242
80107061:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107066:	e9 73 f1 ff ff       	jmp    801061de <alltraps>

8010706b <vector243>:
.globl vector243
vector243:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $243
8010706d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107072:	e9 67 f1 ff ff       	jmp    801061de <alltraps>

80107077 <vector244>:
.globl vector244
vector244:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $244
80107079:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010707e:	e9 5b f1 ff ff       	jmp    801061de <alltraps>

80107083 <vector245>:
.globl vector245
vector245:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $245
80107085:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010708a:	e9 4f f1 ff ff       	jmp    801061de <alltraps>

8010708f <vector246>:
.globl vector246
vector246:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $246
80107091:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107096:	e9 43 f1 ff ff       	jmp    801061de <alltraps>

8010709b <vector247>:
.globl vector247
vector247:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $247
8010709d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801070a2:	e9 37 f1 ff ff       	jmp    801061de <alltraps>

801070a7 <vector248>:
.globl vector248
vector248:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $248
801070a9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801070ae:	e9 2b f1 ff ff       	jmp    801061de <alltraps>

801070b3 <vector249>:
.globl vector249
vector249:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $249
801070b5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801070ba:	e9 1f f1 ff ff       	jmp    801061de <alltraps>

801070bf <vector250>:
.globl vector250
vector250:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $250
801070c1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801070c6:	e9 13 f1 ff ff       	jmp    801061de <alltraps>

801070cb <vector251>:
.globl vector251
vector251:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $251
801070cd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801070d2:	e9 07 f1 ff ff       	jmp    801061de <alltraps>

801070d7 <vector252>:
.globl vector252
vector252:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $252
801070d9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801070de:	e9 fb f0 ff ff       	jmp    801061de <alltraps>

801070e3 <vector253>:
.globl vector253
vector253:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $253
801070e5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801070ea:	e9 ef f0 ff ff       	jmp    801061de <alltraps>

801070ef <vector254>:
.globl vector254
vector254:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $254
801070f1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801070f6:	e9 e3 f0 ff ff       	jmp    801061de <alltraps>

801070fb <vector255>:
.globl vector255
vector255:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $255
801070fd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107102:	e9 d7 f0 ff ff       	jmp    801061de <alltraps>
80107107:	66 90                	xchg   %ax,%ax
80107109:	66 90                	xchg   %ax,%ax
8010710b:	66 90                	xchg   %ax,%ax
8010710d:	66 90                	xchg   %ax,%ax
8010710f:	90                   	nop

80107110 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107110:	55                   	push   %ebp
80107111:	89 e5                	mov    %esp,%ebp
80107113:	57                   	push   %edi
80107114:	56                   	push   %esi
80107115:	53                   	push   %ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107116:	89 d3                	mov    %edx,%ebx
{
80107118:	89 d7                	mov    %edx,%edi
  pde = &pgdir[PDX(va)];
8010711a:	c1 eb 16             	shr    $0x16,%ebx
8010711d:	8d 34 98             	lea    (%eax,%ebx,4),%esi
{
80107120:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80107123:	8b 06                	mov    (%esi),%eax
80107125:	a8 01                	test   $0x1,%al
80107127:	74 27                	je     80107150 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107129:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010712e:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80107134:	c1 ef 0a             	shr    $0xa,%edi
}
80107137:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
8010713a:	89 fa                	mov    %edi,%edx
8010713c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107142:	8d 04 13             	lea    (%ebx,%edx,1),%eax
}
80107145:	5b                   	pop    %ebx
80107146:	5e                   	pop    %esi
80107147:	5f                   	pop    %edi
80107148:	5d                   	pop    %ebp
80107149:	c3                   	ret    
8010714a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107150:	85 c9                	test   %ecx,%ecx
80107152:	74 2c                	je     80107180 <walkpgdir+0x70>
80107154:	e8 77 b3 ff ff       	call   801024d0 <kalloc>
80107159:	85 c0                	test   %eax,%eax
8010715b:	89 c3                	mov    %eax,%ebx
8010715d:	74 21                	je     80107180 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
8010715f:	83 ec 04             	sub    $0x4,%esp
80107162:	68 00 10 00 00       	push   $0x1000
80107167:	6a 00                	push   $0x0
80107169:	50                   	push   %eax
8010716a:	e8 a1 dc ff ff       	call   80104e10 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010716f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107175:	83 c4 10             	add    $0x10,%esp
80107178:	83 c8 07             	or     $0x7,%eax
8010717b:	89 06                	mov    %eax,(%esi)
8010717d:	eb b5                	jmp    80107134 <walkpgdir+0x24>
8010717f:	90                   	nop
}
80107180:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80107183:	31 c0                	xor    %eax,%eax
}
80107185:	5b                   	pop    %ebx
80107186:	5e                   	pop    %esi
80107187:	5f                   	pop    %edi
80107188:	5d                   	pop    %ebp
80107189:	c3                   	ret    
8010718a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107190 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107190:	55                   	push   %ebp
80107191:	89 e5                	mov    %esp,%ebp
80107193:	57                   	push   %edi
80107194:	56                   	push   %esi
80107195:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107196:	89 d3                	mov    %edx,%ebx
80107198:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
8010719e:	83 ec 1c             	sub    $0x1c,%esp
801071a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801071a4:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
801071a8:	8b 7d 08             	mov    0x8(%ebp),%edi
801071ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801071b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
801071b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801071b6:	29 df                	sub    %ebx,%edi
801071b8:	83 c8 01             	or     $0x1,%eax
801071bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
801071be:	eb 15                	jmp    801071d5 <mappages+0x45>
    if(*pte & PTE_P)
801071c0:	f6 00 01             	testb  $0x1,(%eax)
801071c3:	75 45                	jne    8010720a <mappages+0x7a>
    *pte = pa | perm | PTE_P;
801071c5:	0b 75 dc             	or     -0x24(%ebp),%esi
    if(a == last)
801071c8:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
    *pte = pa | perm | PTE_P;
801071cb:	89 30                	mov    %esi,(%eax)
    if(a == last)
801071cd:	74 31                	je     80107200 <mappages+0x70>
      break;
    a += PGSIZE;
801071cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801071d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071d8:	b9 01 00 00 00       	mov    $0x1,%ecx
801071dd:	89 da                	mov    %ebx,%edx
801071df:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
801071e2:	e8 29 ff ff ff       	call   80107110 <walkpgdir>
801071e7:	85 c0                	test   %eax,%eax
801071e9:	75 d5                	jne    801071c0 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
801071eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801071ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801071f3:	5b                   	pop    %ebx
801071f4:	5e                   	pop    %esi
801071f5:	5f                   	pop    %edi
801071f6:	5d                   	pop    %ebp
801071f7:	c3                   	ret    
801071f8:	90                   	nop
801071f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107203:	31 c0                	xor    %eax,%eax
}
80107205:	5b                   	pop    %ebx
80107206:	5e                   	pop    %esi
80107207:	5f                   	pop    %edi
80107208:	5d                   	pop    %ebp
80107209:	c3                   	ret    
      panic("remap");
8010720a:	83 ec 0c             	sub    $0xc,%esp
8010720d:	68 04 86 10 80       	push   $0x80108604
80107212:	e8 59 91 ff ff       	call   80100370 <panic>
80107217:	89 f6                	mov    %esi,%esi
80107219:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107220 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107220:	55                   	push   %ebp
80107221:	89 e5                	mov    %esp,%ebp
80107223:	57                   	push   %edi
80107224:	56                   	push   %esi
80107225:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80107226:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
8010722c:	89 c7                	mov    %eax,%edi
  a = PGROUNDUP(newsz);
8010722e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107234:	83 ec 1c             	sub    $0x1c,%esp
80107237:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010723a:	39 d3                	cmp    %edx,%ebx
8010723c:	73 60                	jae    8010729e <deallocuvm.part.0+0x7e>
8010723e:	89 d6                	mov    %edx,%esi
80107240:	eb 3d                	jmp    8010727f <deallocuvm.part.0+0x5f>
80107242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a += (NPTENTRIES - 1) * PGSIZE;
    else if((*pte & PTE_P) != 0){
80107248:	8b 10                	mov    (%eax),%edx
8010724a:	f6 c2 01             	test   $0x1,%dl
8010724d:	74 26                	je     80107275 <deallocuvm.part.0+0x55>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010724f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80107255:	74 52                	je     801072a9 <deallocuvm.part.0+0x89>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80107257:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010725a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107260:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80107263:	52                   	push   %edx
80107264:	e8 b7 b0 ff ff       	call   80102320 <kfree>
      *pte = 0;
80107269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010726c:	83 c4 10             	add    $0x10,%esp
8010726f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107275:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010727b:	39 f3                	cmp    %esi,%ebx
8010727d:	73 1f                	jae    8010729e <deallocuvm.part.0+0x7e>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010727f:	31 c9                	xor    %ecx,%ecx
80107281:	89 da                	mov    %ebx,%edx
80107283:	89 f8                	mov    %edi,%eax
80107285:	e8 86 fe ff ff       	call   80107110 <walkpgdir>
    if(!pte)
8010728a:	85 c0                	test   %eax,%eax
8010728c:	75 ba                	jne    80107248 <deallocuvm.part.0+0x28>
      a += (NPTENTRIES - 1) * PGSIZE;
8010728e:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80107294:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010729a:	39 f3                	cmp    %esi,%ebx
8010729c:	72 e1                	jb     8010727f <deallocuvm.part.0+0x5f>
    }
  }
  return newsz;
}
8010729e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801072a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801072a4:	5b                   	pop    %ebx
801072a5:	5e                   	pop    %esi
801072a6:	5f                   	pop    %edi
801072a7:	5d                   	pop    %ebp
801072a8:	c3                   	ret    
        panic("kfree");
801072a9:	83 ec 0c             	sub    $0xc,%esp
801072ac:	68 7a 7d 10 80       	push   $0x80107d7a
801072b1:	e8 ba 90 ff ff       	call   80100370 <panic>
801072b6:	8d 76 00             	lea    0x0(%esi),%esi
801072b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801072c0 <seginit>:
{
801072c0:	55                   	push   %ebp
801072c1:	89 e5                	mov    %esp,%ebp
801072c3:	53                   	push   %ebx
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801072c4:	31 db                	xor    %ebx,%ebx
{
801072c6:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpunum()];
801072c9:	e8 72 b4 ff ff       	call   80102740 <cpunum>
801072ce:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801072d4:	8d 90 e0 22 11 80    	lea    -0x7feedd20(%eax),%edx
801072da:	8d 88 94 23 11 80    	lea    -0x7feedc6c(%eax),%ecx
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801072e0:	c7 80 58 23 11 80 ff 	movl   $0xffff,-0x7feedca8(%eax)
801072e7:	ff 00 00 
801072ea:	c7 80 5c 23 11 80 00 	movl   $0xcf9a00,-0x7feedca4(%eax)
801072f1:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801072f4:	c7 80 60 23 11 80 ff 	movl   $0xffff,-0x7feedca0(%eax)
801072fb:	ff 00 00 
801072fe:	c7 80 64 23 11 80 00 	movl   $0xcf9200,-0x7feedc9c(%eax)
80107305:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107308:	c7 80 70 23 11 80 ff 	movl   $0xffff,-0x7feedc90(%eax)
8010730f:	ff 00 00 
80107312:	c7 80 74 23 11 80 00 	movl   $0xcffa00,-0x7feedc8c(%eax)
80107319:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010731c:	c7 80 78 23 11 80 ff 	movl   $0xffff,-0x7feedc88(%eax)
80107323:	ff 00 00 
80107326:	c7 80 7c 23 11 80 00 	movl   $0xcff200,-0x7feedc84(%eax)
8010732d:	f2 cf 00 
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107330:	66 89 9a 88 00 00 00 	mov    %bx,0x88(%edx)
80107337:	89 cb                	mov    %ecx,%ebx
80107339:	c1 eb 10             	shr    $0x10,%ebx
8010733c:	66 89 8a 8a 00 00 00 	mov    %cx,0x8a(%edx)
80107343:	c1 e9 18             	shr    $0x18,%ecx
80107346:	88 9a 8c 00 00 00    	mov    %bl,0x8c(%edx)
8010734c:	bb 92 c0 ff ff       	mov    $0xffffc092,%ebx
80107351:	66 89 98 6d 23 11 80 	mov    %bx,-0x7feedc93(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107358:	05 50 23 11 80       	add    $0x80112350,%eax
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010735d:	88 8a 8f 00 00 00    	mov    %cl,0x8f(%edx)
  pd[0] = size-1;
80107363:	b9 37 00 00 00       	mov    $0x37,%ecx
80107368:	66 89 4d f2          	mov    %cx,-0xe(%ebp)
  pd[1] = (uint)p;
8010736c:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107370:	c1 e8 10             	shr    $0x10,%eax
80107373:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107377:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010737a:	0f 01 10             	lgdtl  (%eax)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010737d:	b8 18 00 00 00       	mov    $0x18,%eax
80107382:	8e e8                	mov    %eax,%gs
  proc = 0;
80107384:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010738b:	00 00 00 00 
  c = &cpus[cpunum()];
8010738f:	65 89 15 00 00 00 00 	mov    %edx,%gs:0x0
}
80107396:	83 c4 14             	add    $0x14,%esp
80107399:	5b                   	pop    %ebx
8010739a:	5d                   	pop    %ebp
8010739b:	c3                   	ret    
8010739c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801073a0 <setupkvm>:
{
801073a0:	55                   	push   %ebp
801073a1:	89 e5                	mov    %esp,%ebp
801073a3:	56                   	push   %esi
801073a4:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801073a5:	e8 26 b1 ff ff       	call   801024d0 <kalloc>
801073aa:	85 c0                	test   %eax,%eax
801073ac:	74 52                	je     80107400 <setupkvm+0x60>
  memset(pgdir, 0, PGSIZE);
801073ae:	83 ec 04             	sub    $0x4,%esp
801073b1:	89 c6                	mov    %eax,%esi
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801073b3:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
801073b8:	68 00 10 00 00       	push   $0x1000
801073bd:	6a 00                	push   $0x0
801073bf:	50                   	push   %eax
801073c0:	e8 4b da ff ff       	call   80104e10 <memset>
801073c5:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0)
801073c8:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801073cb:	8b 4b 08             	mov    0x8(%ebx),%ecx
801073ce:	83 ec 08             	sub    $0x8,%esp
801073d1:	8b 13                	mov    (%ebx),%edx
801073d3:	ff 73 0c             	pushl  0xc(%ebx)
801073d6:	50                   	push   %eax
801073d7:	29 c1                	sub    %eax,%ecx
801073d9:	89 f0                	mov    %esi,%eax
801073db:	e8 b0 fd ff ff       	call   80107190 <mappages>
801073e0:	83 c4 10             	add    $0x10,%esp
801073e3:	85 c0                	test   %eax,%eax
801073e5:	78 19                	js     80107400 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801073e7:	83 c3 10             	add    $0x10,%ebx
801073ea:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
801073f0:	75 d6                	jne    801073c8 <setupkvm+0x28>
}
801073f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801073f5:	89 f0                	mov    %esi,%eax
801073f7:	5b                   	pop    %ebx
801073f8:	5e                   	pop    %esi
801073f9:	5d                   	pop    %ebp
801073fa:	c3                   	ret    
801073fb:	90                   	nop
801073fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107400:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return 0;
80107403:	31 f6                	xor    %esi,%esi
}
80107405:	89 f0                	mov    %esi,%eax
80107407:	5b                   	pop    %ebx
80107408:	5e                   	pop    %esi
80107409:	5d                   	pop    %ebp
8010740a:	c3                   	ret    
8010740b:	90                   	nop
8010740c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107410 <kvmalloc>:
{
80107410:	55                   	push   %ebp
80107411:	89 e5                	mov    %esp,%ebp
80107413:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107416:	e8 85 ff ff ff       	call   801073a0 <setupkvm>
8010741b:	a3 64 b4 11 80       	mov    %eax,0x8011b464
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107420:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107425:	0f 22 d8             	mov    %eax,%cr3
}
80107428:	c9                   	leave  
80107429:	c3                   	ret    
8010742a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107430 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107430:	a1 64 b4 11 80       	mov    0x8011b464,%eax
{
80107435:	55                   	push   %ebp
80107436:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107438:	05 00 00 00 80       	add    $0x80000000,%eax
8010743d:	0f 22 d8             	mov    %eax,%cr3
}
80107440:	5d                   	pop    %ebp
80107441:	c3                   	ret    
80107442:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107449:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107450 <switchuvm>:
{
80107450:	55                   	push   %ebp
80107451:	89 e5                	mov    %esp,%ebp
80107453:	53                   	push   %ebx
80107454:	83 ec 04             	sub    $0x4,%esp
80107457:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010745a:	e8 e1 d8 ff ff       	call   80104d40 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010745f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107465:	b9 67 00 00 00       	mov    $0x67,%ecx
8010746a:	8d 50 08             	lea    0x8(%eax),%edx
8010746d:	66 89 88 a0 00 00 00 	mov    %cx,0xa0(%eax)
80107474:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
8010747b:	89 d1                	mov    %edx,%ecx
8010747d:	c1 ea 18             	shr    $0x18,%edx
80107480:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
80107486:	ba 89 40 00 00       	mov    $0x4089,%edx
8010748b:	c1 e9 10             	shr    $0x10,%ecx
8010748e:	66 89 90 a5 00 00 00 	mov    %dx,0xa5(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107495:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010749c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801074a2:	b9 10 00 00 00       	mov    $0x10,%ecx
801074a7:	66 89 48 10          	mov    %cx,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801074ab:	8b 52 08             	mov    0x8(%edx),%edx
801074ae:	81 c2 00 10 00 00    	add    $0x1000,%edx
801074b4:	89 50 0c             	mov    %edx,0xc(%eax)
  cpu->ts.iomb = (ushort) 0xFFFF;
801074b7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801074bc:	66 89 50 6e          	mov    %dx,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801074c0:	b8 30 00 00 00       	mov    $0x30,%eax
801074c5:	0f 00 d8             	ltr    %ax
  if(p->pgdir == 0)
801074c8:	8b 43 04             	mov    0x4(%ebx),%eax
801074cb:	85 c0                	test   %eax,%eax
801074cd:	74 11                	je     801074e0 <switchuvm+0x90>
  lcr3(V2P(p->pgdir));  // switch to process's address space
801074cf:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801074d4:	0f 22 d8             	mov    %eax,%cr3
}
801074d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801074da:	c9                   	leave  
  popcli();
801074db:	e9 90 d8 ff ff       	jmp    80104d70 <popcli>
    panic("switchuvm: no pgdir");
801074e0:	83 ec 0c             	sub    $0xc,%esp
801074e3:	68 0a 86 10 80       	push   $0x8010860a
801074e8:	e8 83 8e ff ff       	call   80100370 <panic>
801074ed:	8d 76 00             	lea    0x0(%esi),%esi

801074f0 <inituvm>:
{
801074f0:	55                   	push   %ebp
801074f1:	89 e5                	mov    %esp,%ebp
801074f3:	57                   	push   %edi
801074f4:	56                   	push   %esi
801074f5:	53                   	push   %ebx
801074f6:	83 ec 1c             	sub    $0x1c,%esp
801074f9:	8b 75 10             	mov    0x10(%ebp),%esi
801074fc:	8b 45 08             	mov    0x8(%ebp),%eax
801074ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(sz >= PGSIZE)
80107502:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
{
80107508:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
8010750b:	77 49                	ja     80107556 <inituvm+0x66>
  mem = kalloc();
8010750d:	e8 be af ff ff       	call   801024d0 <kalloc>
  memset(mem, 0, PGSIZE);
80107512:	83 ec 04             	sub    $0x4,%esp
  mem = kalloc();
80107515:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80107517:	68 00 10 00 00       	push   $0x1000
8010751c:	6a 00                	push   $0x0
8010751e:	50                   	push   %eax
8010751f:	e8 ec d8 ff ff       	call   80104e10 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107524:	58                   	pop    %eax
80107525:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010752b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107530:	5a                   	pop    %edx
80107531:	6a 06                	push   $0x6
80107533:	50                   	push   %eax
80107534:	31 d2                	xor    %edx,%edx
80107536:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107539:	e8 52 fc ff ff       	call   80107190 <mappages>
  memmove(mem, init, sz);
8010753e:	89 75 10             	mov    %esi,0x10(%ebp)
80107541:	89 7d 0c             	mov    %edi,0xc(%ebp)
80107544:	83 c4 10             	add    $0x10,%esp
80107547:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010754a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010754d:	5b                   	pop    %ebx
8010754e:	5e                   	pop    %esi
8010754f:	5f                   	pop    %edi
80107550:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80107551:	e9 6a d9 ff ff       	jmp    80104ec0 <memmove>
    panic("inituvm: more than a page");
80107556:	83 ec 0c             	sub    $0xc,%esp
80107559:	68 1e 86 10 80       	push   $0x8010861e
8010755e:	e8 0d 8e ff ff       	call   80100370 <panic>
80107563:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107569:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107570 <loaduvm>:
{
80107570:	55                   	push   %ebp
80107571:	89 e5                	mov    %esp,%ebp
80107573:	57                   	push   %edi
80107574:	56                   	push   %esi
80107575:	53                   	push   %ebx
80107576:	83 ec 0c             	sub    $0xc,%esp
  if((uint) addr % PGSIZE != 0)
80107579:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80107580:	0f 85 91 00 00 00    	jne    80107617 <loaduvm+0xa7>
  for(i = 0; i < sz; i += PGSIZE){
80107586:	8b 75 18             	mov    0x18(%ebp),%esi
80107589:	31 db                	xor    %ebx,%ebx
8010758b:	85 f6                	test   %esi,%esi
8010758d:	75 1a                	jne    801075a9 <loaduvm+0x39>
8010758f:	eb 6f                	jmp    80107600 <loaduvm+0x90>
80107591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107598:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010759e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
801075a4:	39 5d 18             	cmp    %ebx,0x18(%ebp)
801075a7:	76 57                	jbe    80107600 <loaduvm+0x90>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801075a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801075ac:	8b 45 08             	mov    0x8(%ebp),%eax
801075af:	31 c9                	xor    %ecx,%ecx
801075b1:	01 da                	add    %ebx,%edx
801075b3:	e8 58 fb ff ff       	call   80107110 <walkpgdir>
801075b8:	85 c0                	test   %eax,%eax
801075ba:	74 4e                	je     8010760a <loaduvm+0x9a>
    pa = PTE_ADDR(*pte);
801075bc:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
801075be:	8b 4d 14             	mov    0x14(%ebp),%ecx
    if(sz - i < PGSIZE)
801075c1:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
801075c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801075cb:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801075d1:	0f 46 fe             	cmovbe %esi,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
801075d4:	01 d9                	add    %ebx,%ecx
801075d6:	05 00 00 00 80       	add    $0x80000000,%eax
801075db:	57                   	push   %edi
801075dc:	51                   	push   %ecx
801075dd:	50                   	push   %eax
801075de:	ff 75 10             	pushl  0x10(%ebp)
801075e1:	e8 5a a3 ff ff       	call   80101940 <readi>
801075e6:	83 c4 10             	add    $0x10,%esp
801075e9:	39 f8                	cmp    %edi,%eax
801075eb:	74 ab                	je     80107598 <loaduvm+0x28>
}
801075ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801075f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801075f5:	5b                   	pop    %ebx
801075f6:	5e                   	pop    %esi
801075f7:	5f                   	pop    %edi
801075f8:	5d                   	pop    %ebp
801075f9:	c3                   	ret    
801075fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107600:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107603:	31 c0                	xor    %eax,%eax
}
80107605:	5b                   	pop    %ebx
80107606:	5e                   	pop    %esi
80107607:	5f                   	pop    %edi
80107608:	5d                   	pop    %ebp
80107609:	c3                   	ret    
      panic("loaduvm: address should exist");
8010760a:	83 ec 0c             	sub    $0xc,%esp
8010760d:	68 38 86 10 80       	push   $0x80108638
80107612:	e8 59 8d ff ff       	call   80100370 <panic>
    panic("loaduvm: addr must be page aligned");
80107617:	83 ec 0c             	sub    $0xc,%esp
8010761a:	68 dc 86 10 80       	push   $0x801086dc
8010761f:	e8 4c 8d ff ff       	call   80100370 <panic>
80107624:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010762a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107630 <allocuvm>:
{
80107630:	55                   	push   %ebp
80107631:	89 e5                	mov    %esp,%ebp
80107633:	57                   	push   %edi
80107634:	56                   	push   %esi
80107635:	53                   	push   %ebx
80107636:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80107639:	8b 7d 10             	mov    0x10(%ebp),%edi
8010763c:	85 ff                	test   %edi,%edi
8010763e:	0f 88 8e 00 00 00    	js     801076d2 <allocuvm+0xa2>
  if(newsz < oldsz)
80107644:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80107647:	0f 82 93 00 00 00    	jb     801076e0 <allocuvm+0xb0>
  a = PGROUNDUP(oldsz);
8010764d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107650:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107656:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
8010765c:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010765f:	0f 86 7e 00 00 00    	jbe    801076e3 <allocuvm+0xb3>
80107665:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80107668:	8b 7d 08             	mov    0x8(%ebp),%edi
8010766b:	eb 42                	jmp    801076af <allocuvm+0x7f>
8010766d:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
80107670:	83 ec 04             	sub    $0x4,%esp
80107673:	68 00 10 00 00       	push   $0x1000
80107678:	6a 00                	push   $0x0
8010767a:	50                   	push   %eax
8010767b:	e8 90 d7 ff ff       	call   80104e10 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107680:	58                   	pop    %eax
80107681:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80107687:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010768c:	5a                   	pop    %edx
8010768d:	6a 06                	push   $0x6
8010768f:	50                   	push   %eax
80107690:	89 da                	mov    %ebx,%edx
80107692:	89 f8                	mov    %edi,%eax
80107694:	e8 f7 fa ff ff       	call   80107190 <mappages>
80107699:	83 c4 10             	add    $0x10,%esp
8010769c:	85 c0                	test   %eax,%eax
8010769e:	78 50                	js     801076f0 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
801076a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801076a6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801076a9:	0f 86 81 00 00 00    	jbe    80107730 <allocuvm+0x100>
    mem = kalloc();
801076af:	e8 1c ae ff ff       	call   801024d0 <kalloc>
    if(mem == 0){
801076b4:	85 c0                	test   %eax,%eax
    mem = kalloc();
801076b6:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801076b8:	75 b6                	jne    80107670 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
801076ba:	83 ec 0c             	sub    $0xc,%esp
801076bd:	68 56 86 10 80       	push   $0x80108656
801076c2:	e8 79 8f ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
801076c7:	83 c4 10             	add    $0x10,%esp
801076ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801076cd:	39 45 10             	cmp    %eax,0x10(%ebp)
801076d0:	77 6e                	ja     80107740 <allocuvm+0x110>
}
801076d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
801076d5:	31 ff                	xor    %edi,%edi
}
801076d7:	89 f8                	mov    %edi,%eax
801076d9:	5b                   	pop    %ebx
801076da:	5e                   	pop    %esi
801076db:	5f                   	pop    %edi
801076dc:	5d                   	pop    %ebp
801076dd:	c3                   	ret    
801076de:	66 90                	xchg   %ax,%ax
    return oldsz;
801076e0:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
801076e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801076e6:	89 f8                	mov    %edi,%eax
801076e8:	5b                   	pop    %ebx
801076e9:	5e                   	pop    %esi
801076ea:	5f                   	pop    %edi
801076eb:	5d                   	pop    %ebp
801076ec:	c3                   	ret    
801076ed:	8d 76 00             	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
801076f0:	83 ec 0c             	sub    $0xc,%esp
801076f3:	68 6e 86 10 80       	push   $0x8010866e
801076f8:	e8 43 8f ff ff       	call   80100640 <cprintf>
  if(newsz >= oldsz)
801076fd:	83 c4 10             	add    $0x10,%esp
80107700:	8b 45 0c             	mov    0xc(%ebp),%eax
80107703:	39 45 10             	cmp    %eax,0x10(%ebp)
80107706:	76 0d                	jbe    80107715 <allocuvm+0xe5>
80107708:	89 c1                	mov    %eax,%ecx
8010770a:	8b 55 10             	mov    0x10(%ebp),%edx
8010770d:	8b 45 08             	mov    0x8(%ebp),%eax
80107710:	e8 0b fb ff ff       	call   80107220 <deallocuvm.part.0>
      kfree(mem);
80107715:	83 ec 0c             	sub    $0xc,%esp
      return 0;
80107718:	31 ff                	xor    %edi,%edi
      kfree(mem);
8010771a:	56                   	push   %esi
8010771b:	e8 00 ac ff ff       	call   80102320 <kfree>
      return 0;
80107720:	83 c4 10             	add    $0x10,%esp
}
80107723:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107726:	89 f8                	mov    %edi,%eax
80107728:	5b                   	pop    %ebx
80107729:	5e                   	pop    %esi
8010772a:	5f                   	pop    %edi
8010772b:	5d                   	pop    %ebp
8010772c:	c3                   	ret    
8010772d:	8d 76 00             	lea    0x0(%esi),%esi
80107730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80107733:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107736:	5b                   	pop    %ebx
80107737:	89 f8                	mov    %edi,%eax
80107739:	5e                   	pop    %esi
8010773a:	5f                   	pop    %edi
8010773b:	5d                   	pop    %ebp
8010773c:	c3                   	ret    
8010773d:	8d 76 00             	lea    0x0(%esi),%esi
80107740:	89 c1                	mov    %eax,%ecx
80107742:	8b 55 10             	mov    0x10(%ebp),%edx
80107745:	8b 45 08             	mov    0x8(%ebp),%eax
      return 0;
80107748:	31 ff                	xor    %edi,%edi
8010774a:	e8 d1 fa ff ff       	call   80107220 <deallocuvm.part.0>
8010774f:	eb 92                	jmp    801076e3 <allocuvm+0xb3>
80107751:	eb 0d                	jmp    80107760 <myallocuvm>
80107753:	90                   	nop
80107754:	90                   	nop
80107755:	90                   	nop
80107756:	90                   	nop
80107757:	90                   	nop
80107758:	90                   	nop
80107759:	90                   	nop
8010775a:	90                   	nop
8010775b:	90                   	nop
8010775c:	90                   	nop
8010775d:	90                   	nop
8010775e:	90                   	nop
8010775f:	90                   	nop

80107760 <myallocuvm>:
int myallocuvm(pde_t *pgdir,uint start, uint end){
80107760:	55                   	push   %ebp
80107761:	89 e5                	mov    %esp,%ebp
80107763:	57                   	push   %edi
80107764:	56                   	push   %esi
80107765:	53                   	push   %ebx
80107766:	83 ec 0c             	sub    $0xc,%esp
  a = PGROUNDUP(start);
80107769:	8b 45 0c             	mov    0xc(%ebp),%eax
int myallocuvm(pde_t *pgdir,uint start, uint end){
8010776c:	8b 75 10             	mov    0x10(%ebp),%esi
  a = PGROUNDUP(start);
8010776f:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107775:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end; a += PGSIZE){
8010777b:	39 f3                	cmp    %esi,%ebx
8010777d:	73 3f                	jae    801077be <myallocuvm+0x5e>
8010777f:	90                   	nop
    mem = kalloc();
80107780:	e8 4b ad ff ff       	call   801024d0 <kalloc>
    memset(mem, 0 , PGSIZE);
80107785:	83 ec 04             	sub    $0x4,%esp
    mem = kalloc();
80107788:	89 c7                	mov    %eax,%edi
    memset(mem, 0 , PGSIZE);
8010778a:	68 00 10 00 00       	push   $0x1000
8010778f:	6a 00                	push   $0x0
80107791:	50                   	push   %eax
80107792:	e8 79 d6 ff ff       	call   80104e10 <memset>
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
80107797:	58                   	pop    %eax
80107798:	5a                   	pop    %edx
80107799:	8d 97 00 00 00 80    	lea    -0x80000000(%edi),%edx
8010779f:	8b 45 08             	mov    0x8(%ebp),%eax
801077a2:	6a 06                	push   $0x6
801077a4:	b9 00 10 00 00       	mov    $0x1000,%ecx
801077a9:	52                   	push   %edx
801077aa:	89 da                	mov    %ebx,%edx
  for(;a<end; a += PGSIZE){
801077ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(mappages(pgdir, (char*)a,PGSIZE,V2P(mem),PTE_W|PTE_U)<0){
801077b2:	e8 d9 f9 ff ff       	call   80107190 <mappages>
  for(;a<end; a += PGSIZE){
801077b7:	83 c4 10             	add    $0x10,%esp
801077ba:	39 de                	cmp    %ebx,%esi
801077bc:	77 c2                	ja     80107780 <myallocuvm+0x20>
  return (end - start);
801077be:	89 f0                	mov    %esi,%eax
801077c0:	2b 45 0c             	sub    0xc(%ebp),%eax
}
801077c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801077c6:	5b                   	pop    %ebx
801077c7:	5e                   	pop    %esi
801077c8:	5f                   	pop    %edi
801077c9:	5d                   	pop    %ebp
801077ca:	c3                   	ret    
801077cb:	90                   	nop
801077cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801077d0 <deallocuvm>:
{
801077d0:	55                   	push   %ebp
801077d1:	89 e5                	mov    %esp,%ebp
801077d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801077d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
801077d9:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
801077dc:	39 d1                	cmp    %edx,%ecx
801077de:	73 10                	jae    801077f0 <deallocuvm+0x20>
}
801077e0:	5d                   	pop    %ebp
801077e1:	e9 3a fa ff ff       	jmp    80107220 <deallocuvm.part.0>
801077e6:	8d 76 00             	lea    0x0(%esi),%esi
801077e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801077f0:	89 d0                	mov    %edx,%eax
801077f2:	5d                   	pop    %ebp
801077f3:	c3                   	ret    
801077f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801077fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107800 <mydeallocuvm>:

int mydeallocuvm(pde_t *pgdir,uint start,uint end){
80107800:	55                   	push   %ebp
80107801:	89 e5                	mov    %esp,%ebp
80107803:	57                   	push   %edi
80107804:	56                   	push   %esi
80107805:	53                   	push   %ebx
80107806:	83 ec 1c             	sub    $0x1c,%esp
  pte_t *pte;
  uint a,pa;
  a=PGROUNDUP(start);
80107809:	8b 45 0c             	mov    0xc(%ebp),%eax
int mydeallocuvm(pde_t *pgdir,uint start,uint end){
8010780c:	8b 75 10             	mov    0x10(%ebp),%esi
8010780f:	8b 7d 08             	mov    0x8(%ebp),%edi
  a=PGROUNDUP(start);
80107812:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80107818:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(;a<end;a += PGSIZE){
8010781e:	39 f3                	cmp    %esi,%ebx
80107820:	72 3d                	jb     8010785f <mydeallocuvm+0x5f>
80107822:	eb 5a                	jmp    8010787e <mydeallocuvm+0x7e>
80107824:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir,(char*)a,0);
    if(!pte){
      a += (NPDENTRIES-1)*PGSIZE;
    }else if((*pte & PTE_P)!=0){
80107828:	8b 10                	mov    (%eax),%edx
8010782a:	f6 c2 01             	test   $0x1,%dl
8010782d:	74 26                	je     80107855 <mydeallocuvm+0x55>
      pa=PTE_ADDR(*pte);
      if(pa == 0){
8010782f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80107835:	74 54                	je     8010788b <mydeallocuvm+0x8b>
        panic("kfree");
      }
      char *v = P2V(pa);
      kfree(v);
80107837:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010783a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107840:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80107843:	52                   	push   %edx
80107844:	e8 d7 aa ff ff       	call   80102320 <kfree>
      *pte=0;
80107849:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010784c:	83 c4 10             	add    $0x10,%esp
8010784f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(;a<end;a += PGSIZE){
80107855:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010785b:	39 de                	cmp    %ebx,%esi
8010785d:	76 1f                	jbe    8010787e <mydeallocuvm+0x7e>
    pte = walkpgdir(pgdir,(char*)a,0);
8010785f:	31 c9                	xor    %ecx,%ecx
80107861:	89 da                	mov    %ebx,%edx
80107863:	89 f8                	mov    %edi,%eax
80107865:	e8 a6 f8 ff ff       	call   80107110 <walkpgdir>
    if(!pte){
8010786a:	85 c0                	test   %eax,%eax
8010786c:	75 ba                	jne    80107828 <mydeallocuvm+0x28>
      a += (NPDENTRIES-1)*PGSIZE;
8010786e:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(;a<end;a += PGSIZE){
80107874:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010787a:	39 de                	cmp    %ebx,%esi
8010787c:	77 e1                	ja     8010785f <mydeallocuvm+0x5f>
    }
  }
  return 1;
}
8010787e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107881:	b8 01 00 00 00       	mov    $0x1,%eax
80107886:	5b                   	pop    %ebx
80107887:	5e                   	pop    %esi
80107888:	5f                   	pop    %edi
80107889:	5d                   	pop    %ebp
8010788a:	c3                   	ret    
        panic("kfree");
8010788b:	83 ec 0c             	sub    $0xc,%esp
8010788e:	68 7a 7d 10 80       	push   $0x80107d7a
80107893:	e8 d8 8a ff ff       	call   80100370 <panic>
80107898:	90                   	nop
80107899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801078a0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801078a0:	55                   	push   %ebp
801078a1:	89 e5                	mov    %esp,%ebp
801078a3:	57                   	push   %edi
801078a4:	56                   	push   %esi
801078a5:	53                   	push   %ebx
801078a6:	83 ec 0c             	sub    $0xc,%esp
801078a9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801078ac:	85 f6                	test   %esi,%esi
801078ae:	74 59                	je     80107909 <freevm+0x69>
801078b0:	31 c9                	xor    %ecx,%ecx
801078b2:	ba 00 00 00 80       	mov    $0x80000000,%edx
801078b7:	89 f0                	mov    %esi,%eax
801078b9:	e8 62 f9 ff ff       	call   80107220 <deallocuvm.part.0>
801078be:	89 f3                	mov    %esi,%ebx
801078c0:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
801078c6:	eb 0f                	jmp    801078d7 <freevm+0x37>
801078c8:	90                   	nop
801078c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801078d0:	83 c3 04             	add    $0x4,%ebx
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801078d3:	39 fb                	cmp    %edi,%ebx
801078d5:	74 23                	je     801078fa <freevm+0x5a>
    if(pgdir[i] & PTE_P){
801078d7:	8b 03                	mov    (%ebx),%eax
801078d9:	a8 01                	test   $0x1,%al
801078db:	74 f3                	je     801078d0 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801078dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
801078e2:	83 ec 0c             	sub    $0xc,%esp
801078e5:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
801078e8:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801078ed:	50                   	push   %eax
801078ee:	e8 2d aa ff ff       	call   80102320 <kfree>
801078f3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801078f6:	39 fb                	cmp    %edi,%ebx
801078f8:	75 dd                	jne    801078d7 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801078fa:	89 75 08             	mov    %esi,0x8(%ebp)
}
801078fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107900:	5b                   	pop    %ebx
80107901:	5e                   	pop    %esi
80107902:	5f                   	pop    %edi
80107903:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107904:	e9 17 aa ff ff       	jmp    80102320 <kfree>
    panic("freevm: no pgdir");
80107909:	83 ec 0c             	sub    $0xc,%esp
8010790c:	68 8a 86 10 80       	push   $0x8010868a
80107911:	e8 5a 8a ff ff       	call   80100370 <panic>
80107916:	8d 76 00             	lea    0x0(%esi),%esi
80107919:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107920 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107920:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107921:	31 c9                	xor    %ecx,%ecx
{
80107923:	89 e5                	mov    %esp,%ebp
80107925:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80107928:	8b 55 0c             	mov    0xc(%ebp),%edx
8010792b:	8b 45 08             	mov    0x8(%ebp),%eax
8010792e:	e8 dd f7 ff ff       	call   80107110 <walkpgdir>
  if(pte == 0)
80107933:	85 c0                	test   %eax,%eax
80107935:	74 05                	je     8010793c <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
80107937:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010793a:	c9                   	leave  
8010793b:	c3                   	ret    
    panic("clearpteu");
8010793c:	83 ec 0c             	sub    $0xc,%esp
8010793f:	68 9b 86 10 80       	push   $0x8010869b
80107944:	e8 27 8a ff ff       	call   80100370 <panic>
80107949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107950 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107950:	55                   	push   %ebp
80107951:	89 e5                	mov    %esp,%ebp
80107953:	57                   	push   %edi
80107954:	56                   	push   %esi
80107955:	53                   	push   %ebx
80107956:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107959:	e8 42 fa ff ff       	call   801073a0 <setupkvm>
8010795e:	85 c0                	test   %eax,%eax
80107960:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107963:	0f 84 a0 00 00 00    	je     80107a09 <copyuvm+0xb9>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80107969:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010796c:	85 c9                	test   %ecx,%ecx
8010796e:	0f 84 95 00 00 00    	je     80107a09 <copyuvm+0xb9>
80107974:	31 f6                	xor    %esi,%esi
80107976:	eb 4e                	jmp    801079c6 <copyuvm+0x76>
80107978:	90                   	nop
80107979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107980:	83 ec 04             	sub    $0x4,%esp
80107983:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80107989:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010798c:	68 00 10 00 00       	push   $0x1000
80107991:	57                   	push   %edi
80107992:	50                   	push   %eax
80107993:	e8 28 d5 ff ff       	call   80104ec0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107998:	58                   	pop    %eax
80107999:	5a                   	pop    %edx
8010799a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010799d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801079a0:	b9 00 10 00 00       	mov    $0x1000,%ecx
801079a5:	53                   	push   %ebx
801079a6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801079ac:	52                   	push   %edx
801079ad:	89 f2                	mov    %esi,%edx
801079af:	e8 dc f7 ff ff       	call   80107190 <mappages>
801079b4:	83 c4 10             	add    $0x10,%esp
801079b7:	85 c0                	test   %eax,%eax
801079b9:	78 39                	js     801079f4 <copyuvm+0xa4>
  for(i = 0; i < sz; i += PGSIZE){
801079bb:	81 c6 00 10 00 00    	add    $0x1000,%esi
801079c1:	39 75 0c             	cmp    %esi,0xc(%ebp)
801079c4:	76 43                	jbe    80107a09 <copyuvm+0xb9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801079c6:	8b 45 08             	mov    0x8(%ebp),%eax
801079c9:	31 c9                	xor    %ecx,%ecx
801079cb:	89 f2                	mov    %esi,%edx
801079cd:	e8 3e f7 ff ff       	call   80107110 <walkpgdir>
801079d2:	85 c0                	test   %eax,%eax
801079d4:	74 3e                	je     80107a14 <copyuvm+0xc4>
    if(!(*pte & PTE_P))
801079d6:	8b 18                	mov    (%eax),%ebx
801079d8:	f6 c3 01             	test   $0x1,%bl
801079db:	74 44                	je     80107a21 <copyuvm+0xd1>
    pa = PTE_ADDR(*pte);
801079dd:	89 df                	mov    %ebx,%edi
    flags = PTE_FLAGS(*pte);
801079df:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    pa = PTE_ADDR(*pte);
801079e5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
801079eb:	e8 e0 aa ff ff       	call   801024d0 <kalloc>
801079f0:	85 c0                	test   %eax,%eax
801079f2:	75 8c                	jne    80107980 <copyuvm+0x30>
      goto bad;
  }
  return d;

bad:
  freevm(d);
801079f4:	83 ec 0c             	sub    $0xc,%esp
801079f7:	ff 75 e0             	pushl  -0x20(%ebp)
801079fa:	e8 a1 fe ff ff       	call   801078a0 <freevm>
  return 0;
801079ff:	83 c4 10             	add    $0x10,%esp
80107a02:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
}
80107a09:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107a0f:	5b                   	pop    %ebx
80107a10:	5e                   	pop    %esi
80107a11:	5f                   	pop    %edi
80107a12:	5d                   	pop    %ebp
80107a13:	c3                   	ret    
      panic("copyuvm: pte should exist");
80107a14:	83 ec 0c             	sub    $0xc,%esp
80107a17:	68 a5 86 10 80       	push   $0x801086a5
80107a1c:	e8 4f 89 ff ff       	call   80100370 <panic>
      panic("copyuvm: page not present");
80107a21:	83 ec 0c             	sub    $0xc,%esp
80107a24:	68 bf 86 10 80       	push   $0x801086bf
80107a29:	e8 42 89 ff ff       	call   80100370 <panic>
80107a2e:	66 90                	xchg   %ax,%ax

80107a30 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107a30:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a31:	31 c9                	xor    %ecx,%ecx
{
80107a33:	89 e5                	mov    %esp,%ebp
80107a35:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80107a38:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a3e:	e8 cd f6 ff ff       	call   80107110 <walkpgdir>
  if((*pte & PTE_P) == 0)
80107a43:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107a45:	c9                   	leave  
  if((*pte & PTE_U) == 0)
80107a46:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107a48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107a4d:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107a50:	05 00 00 00 80       	add    $0x80000000,%eax
80107a55:	83 fa 05             	cmp    $0x5,%edx
80107a58:	ba 00 00 00 00       	mov    $0x0,%edx
80107a5d:	0f 45 c2             	cmovne %edx,%eax
}
80107a60:	c3                   	ret    
80107a61:	eb 0d                	jmp    80107a70 <copyout>
80107a63:	90                   	nop
80107a64:	90                   	nop
80107a65:	90                   	nop
80107a66:	90                   	nop
80107a67:	90                   	nop
80107a68:	90                   	nop
80107a69:	90                   	nop
80107a6a:	90                   	nop
80107a6b:	90                   	nop
80107a6c:	90                   	nop
80107a6d:	90                   	nop
80107a6e:	90                   	nop
80107a6f:	90                   	nop

80107a70 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107a70:	55                   	push   %ebp
80107a71:	89 e5                	mov    %esp,%ebp
80107a73:	57                   	push   %edi
80107a74:	56                   	push   %esi
80107a75:	53                   	push   %ebx
80107a76:	83 ec 1c             	sub    $0x1c,%esp
80107a79:	8b 5d 14             	mov    0x14(%ebp),%ebx
80107a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a7f:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107a82:	85 db                	test   %ebx,%ebx
80107a84:	75 40                	jne    80107ac6 <copyout+0x56>
80107a86:	eb 70                	jmp    80107af8 <copyout+0x88>
80107a88:	90                   	nop
80107a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80107a90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a93:	89 f1                	mov    %esi,%ecx
80107a95:	29 d1                	sub    %edx,%ecx
80107a97:	81 c1 00 10 00 00    	add    $0x1000,%ecx
80107a9d:	39 d9                	cmp    %ebx,%ecx
80107a9f:	0f 47 cb             	cmova  %ebx,%ecx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107aa2:	29 f2                	sub    %esi,%edx
80107aa4:	83 ec 04             	sub    $0x4,%esp
80107aa7:	01 d0                	add    %edx,%eax
80107aa9:	51                   	push   %ecx
80107aaa:	57                   	push   %edi
80107aab:	50                   	push   %eax
80107aac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80107aaf:	e8 0c d4 ff ff       	call   80104ec0 <memmove>
    len -= n;
    buf += n;
80107ab4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  while(len > 0){
80107ab7:	83 c4 10             	add    $0x10,%esp
    va = va0 + PGSIZE;
80107aba:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
    buf += n;
80107ac0:	01 cf                	add    %ecx,%edi
  while(len > 0){
80107ac2:	29 cb                	sub    %ecx,%ebx
80107ac4:	74 32                	je     80107af8 <copyout+0x88>
    va0 = (uint)PGROUNDDOWN(va);
80107ac6:	89 d6                	mov    %edx,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107ac8:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
80107acb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80107ace:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107ad4:	56                   	push   %esi
80107ad5:	ff 75 08             	pushl  0x8(%ebp)
80107ad8:	e8 53 ff ff ff       	call   80107a30 <uva2ka>
    if(pa0 == 0)
80107add:	83 c4 10             	add    $0x10,%esp
80107ae0:	85 c0                	test   %eax,%eax
80107ae2:	75 ac                	jne    80107a90 <copyout+0x20>
  }
  return 0;
}
80107ae4:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107aec:	5b                   	pop    %ebx
80107aed:	5e                   	pop    %esi
80107aee:	5f                   	pop    %edi
80107aef:	5d                   	pop    %ebp
80107af0:	c3                   	ret    
80107af1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107afb:	31 c0                	xor    %eax,%eax
}
80107afd:	5b                   	pop    %ebx
80107afe:	5e                   	pop    %esi
80107aff:	5f                   	pop    %edi
80107b00:	5d                   	pop    %ebp
80107b01:	c3                   	ret    
