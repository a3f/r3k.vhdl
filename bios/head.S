# Entry Point
# We need to setup the call stack and zero-initialize static variables
# before we can call main()

#include "asm.h"

.set mips1
.set noreorder
    
.section .text.boot, "x"
LEAF(_reset)
#if 0
disable_interruptss:
    mtc0   $0, CP0_STATUS

disable_watch_exceptions:
    mtc0   $0, CP0_WATCHLO
    mtc0   $0, CP0_WATCHHI

disable_kernel_mode_chache:
    mfc0   $t0, CP0_CONFIG
    and    $t0, ~0x7
    ori    $t0, 0x2
    mtc0   $t0, CP0_CONFIG
#endif


    j    init
    .align 8
    nop
    .align 8

unhandled_exception:
    j    _exit
    
#if 0
    li    $t0, SR_BEV
    mtc0  $r0, CO_SR
#endif

init:
clear_bss: nop
    la    $v0, __bss_start
    la    $v1, __bss_end
 1: sw    $0, 0x0($v0)
    sw    $0, 0x4($v0)
    sw    $0, 0x8($v0)
    sw    $0, 0xC($v0)
    addu  $v0, 16
    blt   $v0, $v1, 1b

copy_data: nop
    la    $t0, __text_end
    la    $t1, __data_start
    la    $t2, __data_end
 2: lw    $t3, ($t0)
    sw    $t3, ($t1)
    addu  $t0, 4
    addu  $t1, 4
    blt   $t1, $t2, 2b

init_stack: nop
    la    $sp, __ss_top

load:
//  la    $t0, main
//  jalr  $t0
    jal   main    
    nop
_exit:
	# show some Exiting... message? and then jump to reset?
_loop:
	j    _loop
    nop
END(_reset)
	
