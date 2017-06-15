#include "config.h"
OUTPUT_ARCH(mips)
ENTRY(_reset)

MEMORY
{
    MMIO (rw)  : ORIGIN = MMIO_BASE, LENGTH = 16K
    ROM  (rx)  : ORIGIN = ROM_BASE, LENGTH = 16K
    RAM  (rw)  : ORIGIN = RAM_BASE, LENGTH = 16K
}
 
SECTIONS
{
    . = ORIGIN(ROM);
    __uart = UART_BASE;
    .text :
    {
        __text_start = .;
        /* KEEP(*(.ivt)) */
        KEEP(*(.text.boot))
        *(.text)
        *(.rodata)
    } > ROM
    . = ALIGN(16);
    __text_end = .;
 
	. = ORIGIN(RAM);
    .data :
    {
        __data_start = .;
        *(.data)
    } > RAM
    . = ALIGN(16);
	.got : {
		_gp = ALIGN(16);
		*(.got*)
	} > RAM
    . = ALIGN(16);
    __data_end = .;
 
    .bss :
    {
    	__bss_start = .;
        *(.bss)
    __bss_end = .;
    } > RAM
    . = ALIGN(16);
	. = ALIGN(8);
	. = . + 0x1000; /* 4k of stack memory */
	__ss_top = .;

	/DISCARD/ : { *(.reginfo) *(.MIPS.abiflags) }

	/* FIXME make it work
	. = ALIGN(64);
	__heap_start = .;
	. = . + 0x1000;
	__heap_end = .;
	*/
}


