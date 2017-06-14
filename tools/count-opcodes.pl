#!/usr/bin/env perl

use strict;
use warnings;

# Shows all MIPS opcodes in an ELF

my %ops;
my ($num_ops, $num_instrs) = (0, 0);

while (defined($_ = <>)) {
    next unless /^[[:xdigit:]]+:\s*[[:xdigit:]]+\s*/;
    s/[[:xdigit:]]+:\s*[[:xdigit:]]+\s*//g;
    next unless /^[a-z]/i;

    my @word = split ' ';

    $ops{$word[0]}++;
    $num_instrs++;
}

my $num = 0;

for (sort keys %ops)
{
    printf "%.10s: %d\n", $_, $ops{$_};
    $num_ops++;
}

printf "Number of Instructions: %04u. Number of Opcodes: %04u\n", $num_instrs, $num_ops;



__END__

../bios/bios.elf:     file format elf32-littlemips


Disassembly of section .text:

bfc00000 <_reset>:
bfc00000:	0bf00081 	j	bfc00204 <clear_bss>
bfc00004:	00000000 	nop
	...

bfc00200 <unhandled_exception>:
bfc00200:	0bf0009f 	j	bfc0027c <_exit>

bfc00204 <clear_bss>:
bfc00204:	00000000 	nop
bfc00208:	3c02a000 	lui	v0,0xa000
bfc0020c:	24420000 	addiu	v0,v0,0
bfc00210:	3c03a000 	lui	v1,0xa000
bfc00214:	24630010 	addiu	v1,v1,16

bfc00218 <clear_loop>:
bfc00218:	ac400000 	sw	zero,0(v0)
bfc0021c:	ac400004 	sw	zero,4(v0)
bfc00220:	ac400008 	sw	zero,8(v0)
bfc00224:	ac40000c 	sw	zero,12(v0)
bfc00228:	24420010 	addiu	v0,v0,16
bfc0022c:	0043082a 	slt	at,v0,v1
bfc00230:	1420fff9 	bnez	at,bfc00218 <clear_loop>

bfc00234 <copy_data>:
bfc00234:	00000000 	nop
bfc00238:	3c08bfc0 	lui	t0,0xbfc0
bfc0023c:	25081160 	addiu	t0,t0,4448
bfc00240:	3c09a000 	lui	t1,0xa000
bfc00244:	25290000 	addiu	t1,t1,0
bfc00248:	3c0aa000 	lui	t2,0xa000
bfc0024c:	254a0000 	addiu	t2,t2,0

bfc00250 <copy_loop>:
bfc00250:	8d0b0000 	lw	t3,0(t0)
bfc00254:	ad2b0000 	sw	t3,0(t1)
bfc00258:	25080004 	addiu	t0,t0,4
bfc0025c:	25290004 	addiu	t1,t1,4
bfc00260:	012a082a 	slt	at,t1,t2
bfc00264:	1420fffa 	bnez	at,bfc00250 <copy_loop>

bfc00268 <init_stack>:
bfc00268:	00000000 	nop
bfc0026c:	3c1da000 	lui	sp,0xa000
bfc00270:	27bd1020 	addiu	sp,sp,4128

bfc00274 <load>:
bfc00274:	0ff000c0 	jal	bfc00300 <main>
bfc00278:	00000000 	nop

bfc0027c <_exit>:
bfc0027c:	0bf0009f 	j	bfc0027c <_exit>
bfc00280:	00000000 	nop
	...

bfc00300 <main>:
#include "tty.h"
#include "string.h"

char buf[16] = "";
void main(void)
{
bfc00300:	27bdffe0 	addiu	sp,sp,-32
bfc00304:	afbf001c 	sw	ra,28(sp)
bfc00308:	afbe0018 	sw	s8,24(sp)
bfc0030c:	03a0f025 	move	s8,sp
    uart16550_init(UART16550_BAUD_115200, UART16550_8N1);
bfc00310:	24050003 	li	a1,3
bfc00314:	24040001 	li	a0,1
bfc00318:	0ff000e0 	jal	bfc00380 <uart16550_init>
bfc0031c:	00000000 	nop

    __attribute__((unused)) volatile unsigned v0 = 0xffff;
bfc00320:	3402ffff 	li	v0,0xffff
bfc00324:	afc20010 	sw	v0,16(s8)
    __attribute__((unused)) volatile unsigned v1 = 0xff00;
bfc00328:	3402ff00 	li	v0,0xff00
bfc0032c:	afc20014 	sw	v0,20(s8)

    while (1) {
        puts("\e[31mr3k.vhdl$\e[0m ");
bfc00330:	3c02bfc0 	lui	v0,0xbfc0
bfc00334:	2444110c 	addiu	a0,v0,4364
bfc00338:	0ff0015c 	jal	bfc00570 <puts>
bfc0033c:	00000000 	nop
        gets(buf, sizeof buf);
bfc00340:	24050010 	li	a1,16
bfc00344:	3c02a000 	lui	v0,0xa000
bfc00348:	24440000 	addiu	a0,v0,0
bfc0034c:	0ff001f9 	jal	bfc007e4 <gets>
bfc00350:	00000000 	nop
        puts("You wrote: \n");
bfc00354:	3c02bfc0 	lui	v0,0xbfc0
bfc00358:	24441120 	addiu	a0,v0,4384
bfc0035c:	0ff0015c 	jal	bfc00570 <puts>
bfc00360:	00000000 	nop
        hexdump(buf, sizeof buf);
bfc00364:	24050010 	li	a1,16
bfc00368:	3c02a000 	lui	v0,0xa000
bfc0036c:	24440000 	addiu	a0,v0,0
bfc00370:	0ff002f1 	jal	bfc00bc4 <hexdump>
bfc00374:	00000000 	nop
        puts("\e[31mr3k.vhdl$\e[0m ");
bfc00378:	1000ffed 	b	bfc00330 <main+0x30>
bfc0037c:	00000000 	nop

bfc00380 <uart16550_init>:
};
_Static_assert(sizeof __uart == 7, "Struct not padded correctly!");

volatile int x;
void uart16550_init(uint16_t baud_div, uint8_t config)
{
bfc00380:	27bdfff8 	addiu	sp,sp,-8
bfc00384:	afbe0004 	sw	s8,4(sp)
bfc00388:	03a0f025 	move	s8,sp
bfc0038c:	00801825 	move	v1,a0
bfc00390:	00a01025 	move	v0,a1
bfc00394:	a7c30008 	sh	v1,8(s8)
bfc00398:	a3c2000c 	sb	v0,12(s8)
    x = 2;
bfc0039c:	24020002 	li	v0,2
bfc003a0:	af820010 	sw	v0,16(gp)
    __uart.int_enable = false;
bfc003a4:	3c021fd0 	lui	v0,0x1fd0
bfc003a8:	344203f8 	ori	v0,v0,0x3f8
bfc003ac:	a0400001 	sb	zero,1(v0)

    __uart.line_ctrl.set_baud = true;
bfc003b0:	3c021fd0 	lui	v0,0x1fd0
bfc003b4:	344203f8 	ori	v0,v0,0x3f8
bfc003b8:	90440003 	lbu	a0,3(v0)
bfc003bc:	2403ff80 	li	v1,-128
bfc003c0:	00831825 	or	v1,a0,v1
bfc003c4:	a0430003 	sb	v1,3(v0)

    __uart.baud_div_lo = (uint8_t)baud_div;
bfc003c8:	3c021fd0 	lui	v0,0x1fd0
bfc003cc:	344203f8 	ori	v0,v0,0x3f8
bfc003d0:	97c30008 	lhu	v1,8(s8)
bfc003d4:	00000000 	nop
bfc003d8:	306300ff 	andi	v1,v1,0xff
bfc003dc:	a0430000 	sb	v1,0(v0)
    __uart.baud_div_hi = (uint8_t)(baud_div >> 8);
bfc003e0:	3c021fd0 	lui	v0,0x1fd0
bfc003e4:	344203f8 	ori	v0,v0,0x3f8
bfc003e8:	97c30008 	lhu	v1,8(s8)
bfc003ec:	00000000 	nop
bfc003f0:	00031a02 	srl	v1,v1,0x8
bfc003f4:	3063ffff 	andi	v1,v1,0xffff
bfc003f8:	306300ff 	andi	v1,v1,0xff
bfc003fc:	a0430001 	sb	v1,1(v0)

    __uart.line_ctrl.set_baud = false;
bfc00400:	3c021fd0 	lui	v0,0x1fd0
bfc00404:	344203f8 	ori	v0,v0,0x3f8
bfc00408:	90430003 	lbu	v1,3(v0)
bfc0040c:	00000000 	nop
bfc00410:	3063007f 	andi	v1,v1,0x7f
bfc00414:	a0430003 	sb	v1,3(v0)

    __uart.line_ctrl.config = config;
bfc00418:	3c021fd0 	lui	v0,0x1fd0
bfc0041c:	344203f8 	ori	v0,v0,0x3f8
bfc00420:	93c3000c 	lbu	v1,12(s8)
bfc00424:	00000000 	nop
bfc00428:	3063001f 	andi	v1,v1,0x1f
bfc0042c:	306300ff 	andi	v1,v1,0xff
bfc00430:	3065001f 	andi	a1,v1,0x1f
bfc00434:	90440003 	lbu	a0,3(v0)
bfc00438:	2403ffe0 	li	v1,-32
bfc0043c:	00831824 	and	v1,a0,v1
bfc00440:	00602025 	move	a0,v1
bfc00444:	00a01825 	move	v1,a1
bfc00448:	00831825 	or	v1,a0,v1
bfc0044c:	a0430003 	sb	v1,3(v0)
}
bfc00450:	00000000 	nop
bfc00454:	03c0e825 	move	sp,s8
bfc00458:	8fbe0004 	lw	s8,4(sp)
bfc0045c:	27bd0008 	addiu	sp,sp,8
bfc00460:	03e00008 	jr	ra
bfc00464:	00000000 	nop

bfc00468 <uart16550_getc>:

unsigned char uart16550_getc(void)
{
bfc00468:	27bdfff0 	addiu	sp,sp,-16
bfc0046c:	afbe000c 	sw	s8,12(sp)
bfc00470:	03a0f025 	move	s8,sp
    while(!__uart.line_status.data_available)
bfc00474:	00000000 	nop
bfc00478:	3c021fd0 	lui	v0,0x1fd0
bfc0047c:	344203f8 	ori	v0,v0,0x3f8
bfc00480:	90420005 	lbu	v0,5(v0)
bfc00484:	00000000 	nop
bfc00488:	30420001 	andi	v0,v0,0x1
bfc0048c:	304200ff 	andi	v0,v0,0xff
bfc00490:	1040fff9 	beqz	v0,bfc00478 <uart16550_getc+0x10>
bfc00494:	00000000 	nop
        ;

    char ch = __uart.rx;
bfc00498:	3c021fd0 	lui	v0,0x1fd0
bfc0049c:	344203f8 	ori	v0,v0,0x3f8
bfc004a0:	90420000 	lbu	v0,0(v0)
bfc004a4:	00000000 	nop
bfc004a8:	304200ff 	andi	v0,v0,0xff
bfc004ac:	a3c20000 	sb	v0,0(s8)
    if (ch == '\r') ch = '\n';
bfc004b0:	83c30000 	lb	v1,0(s8)
bfc004b4:	2402000d 	li	v0,13
bfc004b8:	14620003 	bne	v1,v0,bfc004c8 <uart16550_getc+0x60>
bfc004bc:	00000000 	nop
bfc004c0:	2402000a 	li	v0,10
bfc004c4:	a3c20000 	sb	v0,0(s8)
    return ch;
bfc004c8:	93c20000 	lbu	v0,0(s8)
}
bfc004cc:	03c0e825 	move	sp,s8
bfc004d0:	8fbe000c 	lw	s8,12(sp)
bfc004d4:	27bd0010 	addiu	sp,sp,16
bfc004d8:	03e00008 	jr	ra
bfc004dc:	00000000 	nop

bfc004e0 <uart16550_putc>:


void uart16550_putc(unsigned char ch)
{
bfc004e0:	27bdffe8 	addiu	sp,sp,-24
bfc004e4:	afbf0014 	sw	ra,20(sp)
bfc004e8:	afbe0010 	sw	s8,16(sp)
bfc004ec:	03a0f025 	move	s8,sp
bfc004f0:	00801025 	move	v0,a0
bfc004f4:	a3c20018 	sb	v0,24(s8)
    while (!__uart.line_status.tx_empty)
bfc004f8:	00000000 	nop
bfc004fc:	3c021fd0 	lui	v0,0x1fd0
bfc00500:	344203f8 	ori	v0,v0,0x3f8
bfc00504:	90420005 	lbu	v0,5(v0)
bfc00508:	00000000 	nop
bfc0050c:	304200ff 	andi	v0,v0,0xff
bfc00510:	00021142 	srl	v0,v0,0x5
bfc00514:	30420001 	andi	v0,v0,0x1
bfc00518:	304200ff 	andi	v0,v0,0xff
bfc0051c:	1040fff7 	beqz	v0,bfc004fc <uart16550_putc+0x1c>
bfc00520:	00000000 	nop
        ;

    __uart.tx = ch;
bfc00524:	3c021fd0 	lui	v0,0x1fd0
bfc00528:	344203f8 	ori	v0,v0,0x3f8
bfc0052c:	93c30018 	lbu	v1,24(s8)
bfc00530:	00000000 	nop
bfc00534:	a0430000 	sb	v1,0(v0)

    if (ch == '\n')
bfc00538:	93c30018 	lbu	v1,24(s8)
bfc0053c:	2402000a 	li	v0,10
bfc00540:	14620004 	bne	v1,v0,bfc00554 <uart16550_putc+0x74>
bfc00544:	00000000 	nop
        uart16550_putc('\r');
bfc00548:	2404000d 	li	a0,13
bfc0054c:	0ff00138 	jal	bfc004e0 <uart16550_putc>
bfc00550:	00000000 	nop
}
bfc00554:	00000000 	nop
bfc00558:	03c0e825 	move	sp,s8
bfc0055c:	8fbf0014 	lw	ra,20(sp)
bfc00560:	8fbe0010 	lw	s8,16(sp)
bfc00564:	27bd0018 	addiu	sp,sp,24
bfc00568:	03e00008 	jr	ra
bfc0056c:	00000000 	nop

bfc00570 <puts>:

#define putc uart16550_putc
#define getc uart16550_getc

void puts(const char *s)
{
bfc00570:	27bdffe8 	addiu	sp,sp,-24
bfc00574:	afbf0014 	sw	ra,20(sp)
bfc00578:	afbe0010 	sw	s8,16(sp)
bfc0057c:	03a0f025 	move	s8,sp
bfc00580:	afc40018 	sw	a0,24(s8)
	while (*s) putc(*s++);
bfc00584:	1000000b 	b	bfc005b4 <puts+0x44>
bfc00588:	00000000 	nop
bfc0058c:	8fc20018 	lw	v0,24(s8)
bfc00590:	00000000 	nop
bfc00594:	24430001 	addiu	v1,v0,1
bfc00598:	afc30018 	sw	v1,24(s8)
bfc0059c:	80420000 	lb	v0,0(v0)
bfc005a0:	00000000 	nop
bfc005a4:	304200ff 	andi	v0,v0,0xff
bfc005a8:	00402025 	move	a0,v0
bfc005ac:	0ff00138 	jal	bfc004e0 <uart16550_putc>
bfc005b0:	00000000 	nop
bfc005b4:	8fc20018 	lw	v0,24(s8)
bfc005b8:	00000000 	nop
bfc005bc:	80420000 	lb	v0,0(v0)
bfc005c0:	00000000 	nop
bfc005c4:	1440fff1 	bnez	v0,bfc0058c <puts+0x1c>
bfc005c8:	00000000 	nop
}
bfc005cc:	00000000 	nop
bfc005d0:	03c0e825 	move	sp,s8
bfc005d4:	8fbf0014 	lw	ra,20(sp)
bfc005d8:	8fbe0010 	lw	s8,16(sp)
bfc005dc:	27bd0018 	addiu	sp,sp,24
bfc005e0:	03e00008 	jr	ra
bfc005e4:	00000000 	nop

bfc005e8 <putmem>:
void putmem(const void *_s, size_t n)
{
bfc005e8:	27bdffe0 	addiu	sp,sp,-32
bfc005ec:	afbf001c 	sw	ra,28(sp)
bfc005f0:	afbe0018 	sw	s8,24(sp)
bfc005f4:	03a0f025 	move	s8,sp
bfc005f8:	afc40020 	sw	a0,32(s8)
bfc005fc:	afc50024 	sw	a1,36(s8)
    const unsigned char *s = _s;
bfc00600:	8fc20020 	lw	v0,32(s8)
bfc00604:	00000000 	nop
bfc00608:	afc20010 	sw	v0,16(s8)
	while (n--) putc(*s++);
bfc0060c:	1000000a 	b	bfc00638 <putmem+0x50>
bfc00610:	00000000 	nop
bfc00614:	8fc20010 	lw	v0,16(s8)
bfc00618:	00000000 	nop
bfc0061c:	24430001 	addiu	v1,v0,1
bfc00620:	afc30010 	sw	v1,16(s8)
bfc00624:	90420000 	lbu	v0,0(v0)
bfc00628:	00000000 	nop
bfc0062c:	00402025 	move	a0,v0
bfc00630:	0ff00138 	jal	bfc004e0 <uart16550_putc>
bfc00634:	00000000 	nop
bfc00638:	8fc20024 	lw	v0,36(s8)
bfc0063c:	00000000 	nop
bfc00640:	2443ffff 	addiu	v1,v0,-1
bfc00644:	afc30024 	sw	v1,36(s8)
bfc00648:	1440fff2 	bnez	v0,bfc00614 <putmem+0x2c>
bfc0064c:	00000000 	nop
}
bfc00650:	00000000 	nop
bfc00654:	03c0e825 	move	sp,s8
bfc00658:	8fbf001c 	lw	ra,28(sp)
bfc0065c:	8fbe0018 	lw	s8,24(sp)
bfc00660:	27bd0020 	addiu	sp,sp,32
bfc00664:	03e00008 	jr	ra
bfc00668:	00000000 	nop

bfc0066c <gets_till>:

char *gets_till(char *buf, size_t size, char delim)
{
bfc0066c:	27bdffe0 	addiu	sp,sp,-32
bfc00670:	afbf001c 	sw	ra,28(sp)
bfc00674:	afbe0018 	sw	s8,24(sp)
bfc00678:	03a0f025 	move	s8,sp
bfc0067c:	afc40020 	sw	a0,32(s8)
bfc00680:	afc50024 	sw	a1,36(s8)
bfc00684:	00c01025 	move	v0,a2
bfc00688:	a3c20028 	sb	v0,40(s8)
	if (!size)
bfc0068c:	8fc20024 	lw	v0,36(s8)
bfc00690:	00000000 	nop
bfc00694:	14400004 	bnez	v0,bfc006a8 <gets_till+0x3c>
bfc00698:	00000000 	nop
		return buf;
bfc0069c:	8fc20020 	lw	v0,32(s8)
bfc006a0:	1000004a 	b	bfc007cc <gets_till+0x160>
bfc006a4:	00000000 	nop

    size_t i = 0;
bfc006a8:	afc00010 	sw	zero,16(s8)
    
	char *s = buf;
bfc006ac:	8fc20020 	lw	v0,32(s8)
bfc006b0:	00000000 	nop
bfc006b4:	afc20014 	sw	v0,20(s8)
	if (size > 1) redo: do {
bfc006b8:	8fc20024 	lw	v0,36(s8)
bfc006bc:	00000000 	nop
bfc006c0:	2c420002 	sltiu	v0,v0,2
bfc006c4:	1440003d 	bnez	v0,bfc007bc <gets_till+0x150>
bfc006c8:	00000000 	nop
		*s = getc();
bfc006cc:	0ff0011a 	jal	bfc00468 <uart16550_getc>
bfc006d0:	00000000 	nop
bfc006d4:	00021e00 	sll	v1,v0,0x18
bfc006d8:	00031e03 	sra	v1,v1,0x18
bfc006dc:	8fc20014 	lw	v0,20(s8)
bfc006e0:	00000000 	nop
bfc006e4:	a0430000 	sb	v1,0(v0)
        switch (*s) {
bfc006e8:	8fc20014 	lw	v0,20(s8)
bfc006ec:	00000000 	nop
bfc006f0:	80420000 	lb	v0,0(v0)
bfc006f4:	24030004 	li	v1,4
bfc006f8:	1043002f 	beq	v0,v1,bfc007b8 <gets_till+0x14c>
bfc006fc:	00000000 	nop
bfc00700:	2403007f 	li	v1,127
bfc00704:	1443000f 	bne	v0,v1,bfc00744 <gets_till+0xd8>
bfc00708:	00000000 	nop
            case '\x7f':
                if (i) {
bfc0070c:	8fc20010 	lw	v0,16(s8)
bfc00710:	00000000 	nop
bfc00714:	1040ffed 	beqz	v0,bfc006cc <gets_till+0x60>
bfc00718:	00000000 	nop
                    puts("\b \b");
bfc0071c:	3c02bfc0 	lui	v0,0xbfc0
bfc00720:	24441130 	addiu	a0,v0,4400
bfc00724:	0ff0015c 	jal	bfc00570 <puts>
bfc00728:	00000000 	nop
                    i--;
bfc0072c:	8fc20010 	lw	v0,16(s8)
bfc00730:	00000000 	nop
bfc00734:	2442ffff 	addiu	v0,v0,-1
bfc00738:	afc20010 	sw	v0,16(s8)
                }
                goto redo;
bfc0073c:	1000ffe3 	b	bfc006cc <gets_till+0x60>
bfc00740:	00000000 	nop
            case 'D' - 'A' + 1:
                goto out;
        }
        putc(*s);
bfc00744:	8fc20014 	lw	v0,20(s8)
bfc00748:	00000000 	nop
bfc0074c:	80420000 	lb	v0,0(v0)
bfc00750:	00000000 	nop
bfc00754:	304200ff 	andi	v0,v0,0xff
bfc00758:	00402025 	move	a0,v0
bfc0075c:	0ff00138 	jal	bfc004e0 <uart16550_putc>
bfc00760:	00000000 	nop
	} while (*s++ != delim &&  ++i < size);
bfc00764:	8fc20014 	lw	v0,20(s8)
bfc00768:	00000000 	nop
bfc0076c:	24430001 	addiu	v1,v0,1
bfc00770:	afc30014 	sw	v1,20(s8)
bfc00774:	80420000 	lb	v0,0(v0)
bfc00778:	83c30028 	lb	v1,40(s8)
bfc0077c:	00000000 	nop
bfc00780:	1062000e 	beq	v1,v0,bfc007bc <gets_till+0x150>
bfc00784:	00000000 	nop
bfc00788:	8fc20010 	lw	v0,16(s8)
bfc0078c:	00000000 	nop
bfc00790:	24420001 	addiu	v0,v0,1
bfc00794:	afc20010 	sw	v0,16(s8)
bfc00798:	8fc30010 	lw	v1,16(s8)
bfc0079c:	8fc20024 	lw	v0,36(s8)
bfc007a0:	00000000 	nop
bfc007a4:	0062102b 	sltu	v0,v1,v0
bfc007a8:	1440ffc8 	bnez	v0,bfc006cc <gets_till+0x60>
bfc007ac:	00000000 	nop
bfc007b0:	10000002 	b	bfc007bc <gets_till+0x150>
bfc007b4:	00000000 	nop
                goto out;
bfc007b8:	00000000 	nop
    out:

	*s = '\0';
bfc007bc:	8fc20014 	lw	v0,20(s8)
bfc007c0:	00000000 	nop
bfc007c4:	a0400000 	sb	zero,0(v0)

	return buf;
bfc007c8:	8fc20020 	lw	v0,32(s8)
}
bfc007cc:	03c0e825 	move	sp,s8
bfc007d0:	8fbf001c 	lw	ra,28(sp)
bfc007d4:	8fbe0018 	lw	s8,24(sp)
bfc007d8:	27bd0020 	addiu	sp,sp,32
bfc007dc:	03e00008 	jr	ra
bfc007e0:	00000000 	nop

bfc007e4 <gets>:

char *gets(char *s, size_t size)
{
bfc007e4:	27bdffe8 	addiu	sp,sp,-24
bfc007e8:	afbf0014 	sw	ra,20(sp)
bfc007ec:	afbe0010 	sw	s8,16(sp)
bfc007f0:	03a0f025 	move	s8,sp
bfc007f4:	afc40018 	sw	a0,24(s8)
bfc007f8:	afc5001c 	sw	a1,28(s8)
	return gets_till(s, size, '\n');
bfc007fc:	2406000a 	li	a2,10
bfc00800:	8fc5001c 	lw	a1,28(s8)
bfc00804:	8fc40018 	lw	a0,24(s8)
bfc00808:	0ff0019b 	jal	bfc0066c <gets_till>
bfc0080c:	00000000 	nop
}
bfc00810:	03c0e825 	move	sp,s8
bfc00814:	8fbf0014 	lw	ra,20(sp)
bfc00818:	8fbe0010 	lw	s8,16(sp)
bfc0081c:	27bd0018 	addiu	sp,sp,24
bfc00820:	03e00008 	jr	ra
bfc00824:	00000000 	nop

bfc00828 <vprintf>:

void vprintf(const char * restrict fmt, va_list args)
{
bfc00828:	27bdffa0 	addiu	sp,sp,-96
bfc0082c:	afbf005c 	sw	ra,92(sp)
bfc00830:	afbe0058 	sw	s8,88(sp)
bfc00834:	03a0f025 	move	s8,sp
bfc00838:	afc40060 	sw	a0,96(s8)
bfc0083c:	afc50064 	sw	a1,100(s8)
	for (;;) {
		const char *start = fmt;
bfc00840:	8fc20060 	lw	v0,96(s8)
bfc00844:	00000000 	nop
bfc00848:	afc20014 	sw	v0,20(s8)
		while (*fmt && *fmt != '%')
bfc0084c:	10000005 	b	bfc00864 <vprintf+0x3c>
bfc00850:	00000000 	nop
			fmt++;
bfc00854:	8fc20060 	lw	v0,96(s8)
bfc00858:	00000000 	nop
bfc0085c:	24420001 	addiu	v0,v0,1
bfc00860:	afc20060 	sw	v0,96(s8)
		while (*fmt && *fmt != '%')
bfc00864:	8fc20060 	lw	v0,96(s8)
bfc00868:	00000000 	nop
bfc0086c:	80420000 	lb	v0,0(v0)
bfc00870:	00000000 	nop
bfc00874:	10400007 	beqz	v0,bfc00894 <vprintf+0x6c>
bfc00878:	00000000 	nop
bfc0087c:	8fc20060 	lw	v0,96(s8)
bfc00880:	00000000 	nop
bfc00884:	80430000 	lb	v1,0(v0)
bfc00888:	24020025 	li	v0,37
bfc0088c:	1462fff1 	bne	v1,v0,bfc00854 <vprintf+0x2c>
bfc00890:	00000000 	nop

		putmem(start, fmt - start);
bfc00894:	8fc30060 	lw	v1,96(s8)
bfc00898:	8fc20014 	lw	v0,20(s8)
bfc0089c:	00000000 	nop
bfc008a0:	00621023 	subu	v0,v1,v0
bfc008a4:	00402825 	move	a1,v0
bfc008a8:	8fc40014 	lw	a0,20(s8)
bfc008ac:	0ff0017a 	jal	bfc005e8 <putmem>
bfc008b0:	00000000 	nop
		if (*fmt == '\0') break;
bfc008b4:	8fc20060 	lw	v0,96(s8)
bfc008b8:	00000000 	nop
bfc008bc:	80420000 	lb	v0,0(v0)
bfc008c0:	00000000 	nop
bfc008c4:	104000a1 	beqz	v0,bfc00b4c <vprintf+0x324>
bfc008c8:	00000000 	nop

		char buf[64];
		unsigned val = va_arg(args, unsigned);
bfc008cc:	8fc20064 	lw	v0,100(s8)
bfc008d0:	00000000 	nop
bfc008d4:	24430004 	addiu	v1,v0,4
bfc008d8:	afc30064 	sw	v1,100(s8)
bfc008dc:	8c420000 	lw	v0,0(v0)
bfc008e0:	00000000 	nop
bfc008e4:	afc20010 	sw	v0,16(s8)
		switch (*++fmt) {
bfc008e8:	8fc20060 	lw	v0,96(s8)
bfc008ec:	00000000 	nop
bfc008f0:	24420001 	addiu	v0,v0,1
bfc008f4:	afc20060 	sw	v0,96(s8)
bfc008f8:	8fc20060 	lw	v0,96(s8)
bfc008fc:	00000000 	nop
bfc00900:	80420000 	lb	v0,0(v0)
bfc00904:	24030069 	li	v1,105
bfc00908:	1043002f 	beq	v0,v1,bfc009c8 <vprintf+0x1a0>
bfc0090c:	00000000 	nop
bfc00910:	2843006a 	slti	v1,v0,106
bfc00914:	10600016 	beqz	v1,bfc00970 <vprintf+0x148>
bfc00918:	00000000 	nop
bfc0091c:	24030062 	li	v1,98
bfc00920:	1043003f 	beq	v0,v1,bfc00a20 <vprintf+0x1f8>
bfc00924:	00000000 	nop
bfc00928:	28430063 	slti	v1,v0,99
bfc0092c:	10600008 	beqz	v1,bfc00950 <vprintf+0x128>
bfc00930:	00000000 	nop
bfc00934:	10400071 	beqz	v0,bfc00afc <vprintf+0x2d4>
bfc00938:	00000000 	nop
bfc0093c:	24030058 	li	v1,88
bfc00940:	10430053 	beq	v0,v1,bfc00a90 <vprintf+0x268>
bfc00944:	00000000 	nop
bfc00948:	10000072 	b	bfc00b14 <vprintf+0x2ec>
bfc0094c:	00000000 	nop
bfc00950:	24030063 	li	v1,99
bfc00954:	1043005a 	beq	v0,v1,bfc00ac0 <vprintf+0x298>
bfc00958:	00000000 	nop
bfc0095c:	24030064 	li	v1,100
bfc00960:	10430019 	beq	v0,v1,bfc009c8 <vprintf+0x1a0>
bfc00964:	00000000 	nop
bfc00968:	1000006a 	b	bfc00b14 <vprintf+0x2ec>
bfc0096c:	00000000 	nop
bfc00970:	24030073 	li	v1,115
bfc00974:	1043005a 	beq	v0,v1,bfc00ae0 <vprintf+0x2b8>
bfc00978:	00000000 	nop
bfc0097c:	28430074 	slti	v1,v0,116
bfc00980:	10600009 	beqz	v1,bfc009a8 <vprintf+0x180>
bfc00984:	00000000 	nop
bfc00988:	2403006f 	li	v1,111
bfc0098c:	10430030 	beq	v0,v1,bfc00a50 <vprintf+0x228>
bfc00990:	00000000 	nop
bfc00994:	24030070 	li	v1,112
bfc00998:	10430039 	beq	v0,v1,bfc00a80 <vprintf+0x258>
bfc0099c:	00000000 	nop
bfc009a0:	1000005c 	b	bfc00b14 <vprintf+0x2ec>
bfc009a4:	00000000 	nop
bfc009a8:	24030075 	li	v1,117
bfc009ac:	10430011 	beq	v0,v1,bfc009f4 <vprintf+0x1cc>
bfc009b0:	00000000 	nop
bfc009b4:	24030078 	li	v1,120
bfc009b8:	10430035 	beq	v0,v1,bfc00a90 <vprintf+0x268>
bfc009bc:	00000000 	nop
bfc009c0:	10000054 	b	bfc00b14 <vprintf+0x2ec>
bfc009c4:	00000000 	nop
			case 'i':
			case 'd':
				if (val & 0x80000000) {
bfc009c8:	8fc20010 	lw	v0,16(s8)
bfc009cc:	00000000 	nop
bfc009d0:	04410008 	bgez	v0,bfc009f4 <vprintf+0x1cc>
bfc009d4:	00000000 	nop
					putc('-');
bfc009d8:	2404002d 	li	a0,45
bfc009dc:	0ff00138 	jal	bfc004e0 <uart16550_putc>
bfc009e0:	00000000 	nop
					val = -val;
bfc009e4:	8fc20010 	lw	v0,16(s8)
bfc009e8:	00000000 	nop
bfc009ec:	00021023 	negu	v0,v0
bfc009f0:	afc20010 	sw	v0,16(s8)
				}
			case 'u':
				puts(itodec(val, buf, sizeof buf));
bfc009f4:	27c20018 	addiu	v0,s8,24
bfc009f8:	24060040 	li	a2,64
bfc009fc:	00402825 	move	a1,v0
bfc00a00:	8fc40010 	lw	a0,16(s8)
bfc00a04:	0ff003e7 	jal	bfc00f9c <itodec>
bfc00a08:	00000000 	nop
bfc00a0c:	00402025 	move	a0,v0
bfc00a10:	0ff0015c 	jal	bfc00570 <puts>
bfc00a14:	00000000 	nop
				break;
bfc00a18:	10000046 	b	bfc00b34 <vprintf+0x30c>
bfc00a1c:	00000000 	nop
			case 'b':
				puts(itopow2(val, 1, buf, sizeof buf));
bfc00a20:	27c20018 	addiu	v0,s8,24
bfc00a24:	24070040 	li	a3,64
bfc00a28:	00403025 	move	a2,v0
bfc00a2c:	24050001 	li	a1,1
bfc00a30:	8fc40010 	lw	a0,16(s8)
bfc00a34:	0ff0039a 	jal	bfc00e68 <itopow2>
bfc00a38:	00000000 	nop
bfc00a3c:	00402025 	move	a0,v0
bfc00a40:	0ff0015c 	jal	bfc00570 <puts>
bfc00a44:	00000000 	nop
				break;
bfc00a48:	1000003a 	b	bfc00b34 <vprintf+0x30c>
bfc00a4c:	00000000 	nop
			case 'o':
				puts(itopow2(val, 3, buf, sizeof buf));
bfc00a50:	27c20018 	addiu	v0,s8,24
bfc00a54:	24070040 	li	a3,64
bfc00a58:	00403025 	move	a2,v0
bfc00a5c:	24050003 	li	a1,3
bfc00a60:	8fc40010 	lw	a0,16(s8)
bfc00a64:	0ff0039a 	jal	bfc00e68 <itopow2>
bfc00a68:	00000000 	nop
bfc00a6c:	00402025 	move	a0,v0
bfc00a70:	0ff0015c 	jal	bfc00570 <puts>
bfc00a74:	00000000 	nop
				break;
bfc00a78:	1000002e 	b	bfc00b34 <vprintf+0x30c>
bfc00a7c:	00000000 	nop
			case 'p':
				puts("0x");
bfc00a80:	3c02bfc0 	lui	v0,0xbfc0
bfc00a84:	24441134 	addiu	a0,v0,4404
bfc00a88:	0ff0015c 	jal	bfc00570 <puts>
bfc00a8c:	00000000 	nop
			case 'x':
			case 'X':
				puts(itopow2(val, 4, buf, sizeof buf));
bfc00a90:	27c20018 	addiu	v0,s8,24
bfc00a94:	24070040 	li	a3,64
bfc00a98:	00403025 	move	a2,v0
bfc00a9c:	24050004 	li	a1,4
bfc00aa0:	8fc40010 	lw	a0,16(s8)
bfc00aa4:	0ff0039a 	jal	bfc00e68 <itopow2>
bfc00aa8:	00000000 	nop
bfc00aac:	00402025 	move	a0,v0
bfc00ab0:	0ff0015c 	jal	bfc00570 <puts>
bfc00ab4:	00000000 	nop
				break;
bfc00ab8:	1000001e 	b	bfc00b34 <vprintf+0x30c>
bfc00abc:	00000000 	nop
			case 'c':
				putc(val);
bfc00ac0:	8fc20010 	lw	v0,16(s8)
bfc00ac4:	00000000 	nop
bfc00ac8:	304200ff 	andi	v0,v0,0xff
bfc00acc:	00402025 	move	a0,v0
bfc00ad0:	0ff00138 	jal	bfc004e0 <uart16550_putc>
bfc00ad4:	00000000 	nop
				break;
bfc00ad8:	10000016 	b	bfc00b34 <vprintf+0x30c>
bfc00adc:	00000000 	nop
			case 's':
				puts((char*)val);
bfc00ae0:	8fc20010 	lw	v0,16(s8)
bfc00ae4:	00000000 	nop
bfc00ae8:	00402025 	move	a0,v0
bfc00aec:	0ff0015c 	jal	bfc00570 <puts>
bfc00af0:	00000000 	nop
				break;
bfc00af4:	1000000f 	b	bfc00b34 <vprintf+0x30c>
bfc00af8:	00000000 	nop
			case '\0':
				fmt--;
bfc00afc:	8fc20060 	lw	v0,96(s8)
bfc00b00:	00000000 	nop
bfc00b04:	2442ffff 	addiu	v0,v0,-1
bfc00b08:	afc20060 	sw	v0,96(s8)
				break;
bfc00b0c:	10000009 	b	bfc00b34 <vprintf+0x30c>
bfc00b10:	00000000 	nop
			case '%':
			default:
				putc(*fmt);
bfc00b14:	8fc20060 	lw	v0,96(s8)
bfc00b18:	00000000 	nop
bfc00b1c:	80420000 	lb	v0,0(v0)
bfc00b20:	00000000 	nop
bfc00b24:	304200ff 	andi	v0,v0,0xff
bfc00b28:	00402025 	move	a0,v0
bfc00b2c:	0ff00138 	jal	bfc004e0 <uart16550_putc>
bfc00b30:	00000000 	nop

		}
		fmt++;
bfc00b34:	8fc20060 	lw	v0,96(s8)
bfc00b38:	00000000 	nop
bfc00b3c:	24420001 	addiu	v0,v0,1
bfc00b40:	afc20060 	sw	v0,96(s8)
	for (;;) {
bfc00b44:	1000ff3e 	b	bfc00840 <vprintf+0x18>
bfc00b48:	00000000 	nop
	}
}
bfc00b4c:	00000000 	nop
bfc00b50:	03c0e825 	move	sp,s8
bfc00b54:	8fbf005c 	lw	ra,92(sp)
bfc00b58:	8fbe0058 	lw	s8,88(sp)
bfc00b5c:	27bd0060 	addiu	sp,sp,96
bfc00b60:	03e00008 	jr	ra
bfc00b64:	00000000 	nop

bfc00b68 <printf>:

void printf(const char * restrict fmt, ...)
{
bfc00b68:	27bdffe0 	addiu	sp,sp,-32
bfc00b6c:	afbf001c 	sw	ra,28(sp)
bfc00b70:	afbe0018 	sw	s8,24(sp)
bfc00b74:	03a0f025 	move	s8,sp
bfc00b78:	afc40020 	sw	a0,32(s8)
bfc00b7c:	afc50024 	sw	a1,36(s8)
bfc00b80:	afc60028 	sw	a2,40(s8)
bfc00b84:	afc7002c 	sw	a3,44(s8)
	va_list args;
	va_start(args, fmt);
bfc00b88:	27c20024 	addiu	v0,s8,36
bfc00b8c:	afc20010 	sw	v0,16(s8)
	vprintf(fmt, args);
bfc00b90:	8fc20010 	lw	v0,16(s8)
bfc00b94:	00000000 	nop
bfc00b98:	00402825 	move	a1,v0
bfc00b9c:	8fc40020 	lw	a0,32(s8)
bfc00ba0:	0ff0020a 	jal	bfc00828 <vprintf>
bfc00ba4:	00000000 	nop
	va_end(args);
}
bfc00ba8:	00000000 	nop
bfc00bac:	03c0e825 	move	sp,s8
bfc00bb0:	8fbf001c 	lw	ra,28(sp)
bfc00bb4:	8fbe0018 	lw	s8,24(sp)
bfc00bb8:	27bd0020 	addiu	sp,sp,32
bfc00bbc:	03e00008 	jr	ra
bfc00bc0:	00000000 	nop

bfc00bc4 <hexdump>:

void hexdump(const void *addr, size_t len)
{
bfc00bc4:	27bdffc0 	addiu	sp,sp,-64
bfc00bc8:	afbf003c 	sw	ra,60(sp)
bfc00bcc:	afbe0038 	sw	s8,56(sp)
bfc00bd0:	03a0f025 	move	s8,sp
bfc00bd4:	afc40040 	sw	a0,64(s8)
bfc00bd8:	afc50044 	sw	a1,68(s8)
	unsigned i;
	unsigned char buf[17];
	unsigned char *pc = (unsigned char*)addr;
bfc00bdc:	8fc20040 	lw	v0,64(s8)
bfc00be0:	00000000 	nop
bfc00be4:	afc20014 	sw	v0,20(s8)

	if (!addr || !len)
bfc00be8:	8fc20040 	lw	v0,64(s8)
bfc00bec:	00000000 	nop
bfc00bf0:	10400096 	beqz	v0,bfc00e4c <hexdump+0x288>
bfc00bf4:	00000000 	nop
bfc00bf8:	8fc20044 	lw	v0,68(s8)
bfc00bfc:	00000000 	nop
bfc00c00:	10400092 	beqz	v0,bfc00e4c <hexdump+0x288>
bfc00c04:	00000000 	nop
		return;

    // Process every byte in the data.
    for (i = 0; i < len; i++) {
bfc00c08:	afc00010 	sw	zero,16(s8)
bfc00c0c:	10000072 	b	bfc00dd8 <hexdump+0x214>
bfc00c10:	00000000 	nop
        // Multiple of 16 means new line (with line offset).

        if ((i % 16) == 0) {
bfc00c14:	8fc20010 	lw	v0,16(s8)
bfc00c18:	00000000 	nop
bfc00c1c:	3042000f 	andi	v0,v0,0xf
bfc00c20:	14400023 	bnez	v0,bfc00cb0 <hexdump+0xec>
bfc00c24:	00000000 	nop
            char hexbuf[] = "0000";
bfc00c28:	3c023030 	lui	v0,0x3030
bfc00c2c:	34423030 	ori	v0,v0,0x3030
bfc00c30:	afc20030 	sw	v0,48(s8)
bfc00c34:	a3c00034 	sb	zero,52(s8)
            // Just don't print ASCII for the zeroth line.
            if (i != 0)
bfc00c38:	8fc20010 	lw	v0,16(s8)
bfc00c3c:	00000000 	nop
bfc00c40:	10400007 	beqz	v0,bfc00c60 <hexdump+0x9c>
bfc00c44:	00000000 	nop
                printf ("  %s\n", buf);
bfc00c48:	27c20018 	addiu	v0,s8,24
bfc00c4c:	00402825 	move	a1,v0
bfc00c50:	3c02bfc0 	lui	v0,0xbfc0
bfc00c54:	24441138 	addiu	a0,v0,4408
bfc00c58:	0ff002da 	jal	bfc00b68 <printf>
bfc00c5c:	00000000 	nop

            // Output the offset.
            puts("  ");
bfc00c60:	3c02bfc0 	lui	v0,0xbfc0
bfc00c64:	24441140 	addiu	a0,v0,4416
bfc00c68:	0ff0015c 	jal	bfc00570 <puts>
bfc00c6c:	00000000 	nop
            itopow2(i, 4, hexbuf, sizeof hexbuf);
bfc00c70:	27c20030 	addiu	v0,s8,48
bfc00c74:	24070005 	li	a3,5
bfc00c78:	00403025 	move	a2,v0
bfc00c7c:	24050004 	li	a1,4
bfc00c80:	8fc40010 	lw	a0,16(s8)
bfc00c84:	0ff0039a 	jal	bfc00e68 <itopow2>
bfc00c88:	00000000 	nop
            putmem(hexbuf, sizeof hexbuf);
bfc00c8c:	27c20030 	addiu	v0,s8,48
bfc00c90:	24050005 	li	a1,5
bfc00c94:	00402025 	move	a0,v0
bfc00c98:	0ff0017a 	jal	bfc005e8 <putmem>
bfc00c9c:	00000000 	nop
            puts(" ");
bfc00ca0:	3c02bfc0 	lui	v0,0xbfc0
bfc00ca4:	24441144 	addiu	a0,v0,4420
bfc00ca8:	0ff0015c 	jal	bfc00570 <puts>
bfc00cac:	00000000 	nop
        }

        char hexbuf[] = "00";
bfc00cb0:	24023030 	li	v0,12336
bfc00cb4:	a7c2002c 	sh	v0,44(s8)
bfc00cb8:	a3c0002e 	sb	zero,46(s8)
        // Now the hex code for the specific character.
        putc(' ');
bfc00cbc:	24040020 	li	a0,32
bfc00cc0:	0ff00138 	jal	bfc004e0 <uart16550_putc>
bfc00cc4:	00000000 	nop
        itopow2(pc[i], 4, hexbuf, sizeof hexbuf);
bfc00cc8:	8fc30014 	lw	v1,20(s8)
bfc00ccc:	8fc20010 	lw	v0,16(s8)
bfc00cd0:	00000000 	nop
bfc00cd4:	00621021 	addu	v0,v1,v0
bfc00cd8:	90420000 	lbu	v0,0(v0)
bfc00cdc:	00000000 	nop
bfc00ce0:	00401825 	move	v1,v0
bfc00ce4:	27c2002c 	addiu	v0,s8,44
bfc00ce8:	24070003 	li	a3,3
bfc00cec:	00403025 	move	a2,v0
bfc00cf0:	24050004 	li	a1,4
bfc00cf4:	00602025 	move	a0,v1
bfc00cf8:	0ff0039a 	jal	bfc00e68 <itopow2>
bfc00cfc:	00000000 	nop
        putmem(hexbuf, sizeof hexbuf);
bfc00d00:	27c2002c 	addiu	v0,s8,44
bfc00d04:	24050003 	li	a1,3
bfc00d08:	00402025 	move	a0,v0
bfc00d0c:	0ff0017a 	jal	bfc005e8 <putmem>
bfc00d10:	00000000 	nop


        // And store a printable ASCII character for later.
        if ((pc[i] < 0x20) || (pc[i] > 0x7e))
bfc00d14:	8fc30014 	lw	v1,20(s8)
bfc00d18:	8fc20010 	lw	v0,16(s8)
bfc00d1c:	00000000 	nop
bfc00d20:	00621021 	addu	v0,v1,v0
bfc00d24:	90420000 	lbu	v0,0(v0)
bfc00d28:	00000000 	nop
bfc00d2c:	2c420020 	sltiu	v0,v0,32
bfc00d30:	1440000a 	bnez	v0,bfc00d5c <hexdump+0x198>
bfc00d34:	00000000 	nop
bfc00d38:	8fc30014 	lw	v1,20(s8)
bfc00d3c:	8fc20010 	lw	v0,16(s8)
bfc00d40:	00000000 	nop
bfc00d44:	00621021 	addu	v0,v1,v0
bfc00d48:	90420000 	lbu	v0,0(v0)
bfc00d4c:	00000000 	nop
bfc00d50:	2c42007f 	sltiu	v0,v0,127
bfc00d54:	1440000a 	bnez	v0,bfc00d80 <hexdump+0x1bc>
bfc00d58:	00000000 	nop
            buf[i % 16] = '.';
bfc00d5c:	8fc20010 	lw	v0,16(s8)
bfc00d60:	00000000 	nop
bfc00d64:	3042000f 	andi	v0,v0,0xf
bfc00d68:	27c30010 	addiu	v1,s8,16
bfc00d6c:	00621021 	addu	v0,v1,v0
bfc00d70:	2403002e 	li	v1,46
bfc00d74:	a0430008 	sb	v1,8(v0)
bfc00d78:	1000000c 	b	bfc00dac <hexdump+0x1e8>
bfc00d7c:	00000000 	nop
        else
            buf[i % 16] = pc[i];
bfc00d80:	8fc20010 	lw	v0,16(s8)
bfc00d84:	00000000 	nop
bfc00d88:	3042000f 	andi	v0,v0,0xf
bfc00d8c:	8fc40014 	lw	a0,20(s8)
bfc00d90:	8fc30010 	lw	v1,16(s8)
bfc00d94:	00000000 	nop
bfc00d98:	00831821 	addu	v1,a0,v1
bfc00d9c:	90630000 	lbu	v1,0(v1)
bfc00da0:	27c40010 	addiu	a0,s8,16
bfc00da4:	00821021 	addu	v0,a0,v0
bfc00da8:	a0430008 	sb	v1,8(v0)
        buf[(i % 16) + 1] = '\0';
bfc00dac:	8fc20010 	lw	v0,16(s8)
bfc00db0:	00000000 	nop
bfc00db4:	3042000f 	andi	v0,v0,0xf
bfc00db8:	24420001 	addiu	v0,v0,1
bfc00dbc:	27c30010 	addiu	v1,s8,16
bfc00dc0:	00621021 	addu	v0,v1,v0
bfc00dc4:	a0400008 	sb	zero,8(v0)
    for (i = 0; i < len; i++) {
bfc00dc8:	8fc20010 	lw	v0,16(s8)
bfc00dcc:	00000000 	nop
bfc00dd0:	24420001 	addiu	v0,v0,1
bfc00dd4:	afc20010 	sw	v0,16(s8)
bfc00dd8:	8fc30010 	lw	v1,16(s8)
bfc00ddc:	8fc20044 	lw	v0,68(s8)
bfc00de0:	00000000 	nop
bfc00de4:	0062102b 	sltu	v0,v1,v0
bfc00de8:	1440ff8a 	bnez	v0,bfc00c14 <hexdump+0x50>
bfc00dec:	00000000 	nop
    }

    // Pad out last line if not exactly 16 characters.
    while ((i % 16) != 0) {
bfc00df0:	10000009 	b	bfc00e18 <hexdump+0x254>
bfc00df4:	00000000 	nop
        printf("   ");
bfc00df8:	3c02bfc0 	lui	v0,0xbfc0
bfc00dfc:	24441148 	addiu	a0,v0,4424
bfc00e00:	0ff002da 	jal	bfc00b68 <printf>
bfc00e04:	00000000 	nop
        i++;
bfc00e08:	8fc20010 	lw	v0,16(s8)
bfc00e0c:	00000000 	nop
bfc00e10:	24420001 	addiu	v0,v0,1
bfc00e14:	afc20010 	sw	v0,16(s8)
    while ((i % 16) != 0) {
bfc00e18:	8fc20010 	lw	v0,16(s8)
bfc00e1c:	00000000 	nop
bfc00e20:	3042000f 	andi	v0,v0,0xf
bfc00e24:	1440fff4 	bnez	v0,bfc00df8 <hexdump+0x234>
bfc00e28:	00000000 	nop
    }

    // And print the final ASCII bit.
    printf("  %s\n", buf);
bfc00e2c:	27c20018 	addiu	v0,s8,24
bfc00e30:	00402825 	move	a1,v0
bfc00e34:	3c02bfc0 	lui	v0,0xbfc0
bfc00e38:	24441138 	addiu	a0,v0,4408
bfc00e3c:	0ff002da 	jal	bfc00b68 <printf>
bfc00e40:	00000000 	nop
bfc00e44:	10000002 	b	bfc00e50 <hexdump+0x28c>
bfc00e48:	00000000 	nop
		return;
bfc00e4c:	00000000 	nop
}
bfc00e50:	03c0e825 	move	sp,s8
bfc00e54:	8fbf003c 	lw	ra,60(sp)
bfc00e58:	8fbe0038 	lw	s8,56(sp)
bfc00e5c:	27bd0040 	addiu	sp,sp,64
bfc00e60:	03e00008 	jr	ra
bfc00e64:	00000000 	nop

bfc00e68 <itopow2>:
#include "string.h"
char* itopow2(uint32_t num, int pow2, char *s, size_t size)
{
bfc00e68:	27bdfff0 	addiu	sp,sp,-16
bfc00e6c:	afbe000c 	sw	s8,12(sp)
bfc00e70:	03a0f025 	move	s8,sp
bfc00e74:	afc40010 	sw	a0,16(s8)
bfc00e78:	afc50014 	sw	a1,20(s8)
bfc00e7c:	afc60018 	sw	a2,24(s8)
bfc00e80:	afc7001c 	sw	a3,28(s8)
	long len = (long) size - 1;
bfc00e84:	8fc2001c 	lw	v0,28(s8)
bfc00e88:	00000000 	nop
bfc00e8c:	2442ffff 	addiu	v0,v0,-1
bfc00e90:	afc20000 	sw	v0,0(s8)
	int counter = 0;
bfc00e94:	afc00004 	sw	zero,4(s8)

	do {
		// if (len <= 0) return NULL;

		if (counter++ == 4)
bfc00e98:	8fc20004 	lw	v0,4(s8)
bfc00e9c:	00000000 	nop
bfc00ea0:	24430001 	addiu	v1,v0,1
bfc00ea4:	afc30004 	sw	v1,4(s8)
bfc00ea8:	24030004 	li	v1,4
bfc00eac:	1443000b 	bne	v0,v1,bfc00edc <itopow2+0x74>
bfc00eb0:	00000000 	nop
			s[--len] = '_';
bfc00eb4:	8fc20000 	lw	v0,0(s8)
bfc00eb8:	00000000 	nop
bfc00ebc:	2442ffff 	addiu	v0,v0,-1
bfc00ec0:	afc20000 	sw	v0,0(s8)
bfc00ec4:	8fc20000 	lw	v0,0(s8)
bfc00ec8:	8fc30018 	lw	v1,24(s8)
bfc00ecc:	00000000 	nop
bfc00ed0:	00621021 	addu	v0,v1,v0
bfc00ed4:	2403005f 	li	v1,95
bfc00ed8:	a0430000 	sb	v1,0(v0)

		// if (len <= 0) return NULL;

		s[--len] = "0123456789abcdef"[num & ((1 << pow2) - 1)];
bfc00edc:	8fc20000 	lw	v0,0(s8)
bfc00ee0:	00000000 	nop
bfc00ee4:	2442ffff 	addiu	v0,v0,-1
bfc00ee8:	afc20000 	sw	v0,0(s8)
bfc00eec:	8fc20000 	lw	v0,0(s8)
bfc00ef0:	8fc30018 	lw	v1,24(s8)
bfc00ef4:	00000000 	nop
bfc00ef8:	00621021 	addu	v0,v1,v0
bfc00efc:	24040001 	li	a0,1
bfc00f00:	8fc30014 	lw	v1,20(s8)
bfc00f04:	00000000 	nop
bfc00f08:	00641804 	sllv	v1,a0,v1
bfc00f0c:	2463ffff 	addiu	v1,v1,-1
bfc00f10:	00602025 	move	a0,v1
bfc00f14:	8fc30010 	lw	v1,16(s8)
bfc00f18:	00000000 	nop
bfc00f1c:	00832024 	and	a0,a0,v1
bfc00f20:	3c03bfc0 	lui	v1,0xbfc0
bfc00f24:	2463114c 	addiu	v1,v1,4428
bfc00f28:	00831821 	addu	v1,a0,v1
bfc00f2c:	80630000 	lb	v1,0(v1)
bfc00f30:	00000000 	nop
bfc00f34:	a0430000 	sb	v1,0(v0)
	} while ((num >>= pow2) != 0);
bfc00f38:	8fc30010 	lw	v1,16(s8)
bfc00f3c:	8fc20014 	lw	v0,20(s8)
bfc00f40:	00000000 	nop
bfc00f44:	00431006 	srlv	v0,v1,v0
bfc00f48:	afc20010 	sw	v0,16(s8)
bfc00f4c:	8fc20010 	lw	v0,16(s8)
bfc00f50:	00000000 	nop
bfc00f54:	1440ffd0 	bnez	v0,bfc00e98 <itopow2+0x30>
bfc00f58:	00000000 	nop

	s[size - 1] = '\0';
bfc00f5c:	8fc2001c 	lw	v0,28(s8)
bfc00f60:	00000000 	nop
bfc00f64:	2442ffff 	addiu	v0,v0,-1
bfc00f68:	8fc30018 	lw	v1,24(s8)
bfc00f6c:	00000000 	nop
bfc00f70:	00621021 	addu	v0,v1,v0
bfc00f74:	a0400000 	sb	zero,0(v0)
	return s + len;
bfc00f78:	8fc20000 	lw	v0,0(s8)
bfc00f7c:	8fc30018 	lw	v1,24(s8)
bfc00f80:	00000000 	nop
bfc00f84:	00621021 	addu	v0,v1,v0
}
bfc00f88:	03c0e825 	move	sp,s8
bfc00f8c:	8fbe000c 	lw	s8,12(sp)
bfc00f90:	27bd0010 	addiu	sp,sp,16
bfc00f94:	03e00008 	jr	ra
bfc00f98:	00000000 	nop

bfc00f9c <itodec>:

char* itodec(uint32_t num, char *s, size_t size)
{
bfc00f9c:	27bdfff0 	addiu	sp,sp,-16
bfc00fa0:	afbe000c 	sw	s8,12(sp)
bfc00fa4:	03a0f025 	move	s8,sp
bfc00fa8:	afc40010 	sw	a0,16(s8)
bfc00fac:	afc50014 	sw	a1,20(s8)
bfc00fb0:	afc60018 	sw	a2,24(s8)
	int i = 0;
bfc00fb4:	afc00000 	sw	zero,0(s8)

	if (num == 0) {
bfc00fb8:	8fc20010 	lw	v0,16(s8)
bfc00fbc:	00000000 	nop
bfc00fc0:	14400013 	bnez	v0,bfc01010 <itodec+0x74>
bfc00fc4:	00000000 	nop
		s[i++] = '0';
bfc00fc8:	8fc20000 	lw	v0,0(s8)
bfc00fcc:	00000000 	nop
bfc00fd0:	24430001 	addiu	v1,v0,1
bfc00fd4:	afc30000 	sw	v1,0(s8)
bfc00fd8:	00401825 	move	v1,v0
bfc00fdc:	8fc20014 	lw	v0,20(s8)
bfc00fe0:	00000000 	nop
bfc00fe4:	00431021 	addu	v0,v0,v1
bfc00fe8:	24030030 	li	v1,48
bfc00fec:	a0430000 	sb	v1,0(v0)
		s[i] = '\0';
bfc00ff0:	8fc20000 	lw	v0,0(s8)
bfc00ff4:	8fc30014 	lw	v1,20(s8)
bfc00ff8:	00000000 	nop
bfc00ffc:	00621021 	addu	v0,v1,v0
bfc01000:	a0400000 	sb	zero,0(v0)
		return s;
bfc01004:	8fc20014 	lw	v0,20(s8)
bfc01008:	1000003b 	b	bfc010f8 <itodec+0x15c>
bfc0100c:	00000000 	nop
	}

	s += size - 1;
bfc01010:	8fc20018 	lw	v0,24(s8)
bfc01014:	00000000 	nop
bfc01018:	2442ffff 	addiu	v0,v0,-1
bfc0101c:	8fc30014 	lw	v1,20(s8)
bfc01020:	00000000 	nop
bfc01024:	00621021 	addu	v0,v1,v0
bfc01028:	afc20014 	sw	v0,20(s8)
	s[i--] = '\0';
bfc0102c:	8fc20000 	lw	v0,0(s8)
bfc01030:	00000000 	nop
bfc01034:	2443ffff 	addiu	v1,v0,-1
bfc01038:	afc30000 	sw	v1,0(s8)
bfc0103c:	00401825 	move	v1,v0
bfc01040:	8fc20014 	lw	v0,20(s8)
bfc01044:	00000000 	nop
bfc01048:	00431021 	addu	v0,v0,v1
bfc0104c:	a0400000 	sb	zero,0(v0)

	while (num != 0) {
bfc01050:	1000001f 	b	bfc010d0 <itodec+0x134>
bfc01054:	00000000 	nop
		s[i--] = num % 10 + '0';
bfc01058:	8fc20000 	lw	v0,0(s8)
bfc0105c:	00000000 	nop
bfc01060:	2443ffff 	addiu	v1,v0,-1
bfc01064:	afc30000 	sw	v1,0(s8)
bfc01068:	00401825 	move	v1,v0
bfc0106c:	8fc20014 	lw	v0,20(s8)
bfc01070:	00000000 	nop
bfc01074:	00431021 	addu	v0,v0,v1
bfc01078:	8fc40010 	lw	a0,16(s8)
bfc0107c:	2403000a 	li	v1,10
bfc01080:	0083001b 	divu	zero,a0,v1
bfc01084:	14600002 	bnez	v1,bfc01090 <itodec+0xf4>
bfc01088:	00000000 	nop
bfc0108c:	0007000d 	break	0x7
bfc01090:	00001810 	mfhi	v1
bfc01094:	306300ff 	andi	v1,v1,0xff
bfc01098:	24630030 	addiu	v1,v1,48
bfc0109c:	306300ff 	andi	v1,v1,0xff
bfc010a0:	00031e00 	sll	v1,v1,0x18
bfc010a4:	00031e03 	sra	v1,v1,0x18
bfc010a8:	a0430000 	sb	v1,0(v0)
		num /= 10;
bfc010ac:	8fc30010 	lw	v1,16(s8)
bfc010b0:	2402000a 	li	v0,10
bfc010b4:	0062001b 	divu	zero,v1,v0
bfc010b8:	14400002 	bnez	v0,bfc010c4 <itodec+0x128>
bfc010bc:	00000000 	nop
bfc010c0:	0007000d 	break	0x7
bfc010c4:	00001010 	mfhi	v0
bfc010c8:	00001012 	mflo	v0
bfc010cc:	afc20010 	sw	v0,16(s8)
	while (num != 0) {
bfc010d0:	8fc20010 	lw	v0,16(s8)
bfc010d4:	00000000 	nop
bfc010d8:	1440ffdf 	bnez	v0,bfc01058 <itodec+0xbc>
bfc010dc:	00000000 	nop
	}

	return &s[i+1];
bfc010e0:	8fc20000 	lw	v0,0(s8)
bfc010e4:	00000000 	nop
bfc010e8:	24420001 	addiu	v0,v0,1
bfc010ec:	8fc30014 	lw	v1,20(s8)
bfc010f0:	00000000 	nop
bfc010f4:	00621021 	addu	v0,v1,v0
}
bfc010f8:	03c0e825 	move	sp,s8
bfc010fc:	8fbe000c 	lw	s8,12(sp)
bfc01100:	27bd0010 	addiu	sp,sp,16
bfc01104:	03e00008 	jr	ra
bfc01108:	00000000 	nop
bfc0110c:	31335b1b 	andi	s3,t1,0x5b1b
bfc01110:	6b33726d 	0x6b33726d
bfc01114:	6468762e 	0x6468762e
bfc01118:	5b1b246c 	0x5b1b246c
bfc0111c:	00206d30 	0x206d30
bfc01120:	20756f59 	addi	s5,v1,28505
bfc01124:	746f7277 	jalx	b1bdc9dc <__ss_top+0x11bdb9bc>
bfc01128:	0a203a65 	j	b880e994 <__ss_top+0x1880d974>
bfc0112c:	00000000 	nop
bfc01130:	00082008 	0x82008
bfc01134:	00007830 	0x7830
bfc01138:	73252020 	0x73252020
bfc0113c:	0000000a 	0xa
bfc01140:	00002020 	add	a0,zero,zero
bfc01144:	00000020 	add	zero,zero,zero
bfc01148:	00202020 	add	a0,at,zero
bfc0114c:	33323130 	andi	s2,t9,0x3130
bfc01150:	37363534 	ori	s6,t9,0x3534
bfc01154:	62613938 	0x62613938
bfc01158:	66656463 	0x66656463
	...
