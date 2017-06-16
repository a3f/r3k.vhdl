# Entry Point
# We need to setup the call stack and zero-initialize static variables
# before we can call main()

#include "asmmacros.h"
#include "m32c0.h"
#include "config.h"

.set mips1
.set noreorder
    
.section .text.boot, "x"
LEAF(_reset)
    LA     $gp, _gp

#if 0 && SYS_MALTA
	mfc0    $t0, C0_STATUS
	li      $t1, ~(SR_KSU_MASK|SR_ERL|SR_EXL|SR_IE)

	and     $t0, $t1
	mtc0    $t0, C0_STATUS

	mfc0    $t0, C0_CAUSE
	li      $t1, ~CR_IP_MASK
	and     $t0, $t1
	mtc0    $t0, C0_CAUSE
#endif

    j    init
    nop
    .align 8
    nop
    .align 8

nhandled_exception:
    j    _exit
    

init:
clear_bss: nop
    la    $v0, __bss_start
    la    $v1, __bss_end
clear_loop:
 1: sw    $0, 0x0($v0)
    sw    $0, 0x4($v0)
    sw    $0, 0x8($v0)
    sw    $0, 0xC($v0)
    addu  $v0, 16
    blt   $v0, $v1, clear_loop

copy_data: nop
    la    $t0, __text_end
    la    $t1, __data_start
    la    $t2, __data_end
copy_loop:
    lw    $t3, ($t0)
    sw    $t3, ($t1)
    addu  $t0, 4
    addu  $t1, 4
    blt   $t1, $t2, copy_loop

init_stack: nop
    la    $sp, __ss_top
    nop

load:
#if 0
    la    $t0, main
    jalr  $t0
#endif
    jal   main    
    nop
_exit:
	# show some Exiting... message? and then jump to reset?
_loop:
	j    _loop
    nop
END(_reset)
