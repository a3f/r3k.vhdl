OUTPUT_ARCH(mips)
ENTRY(_reset)

MEMORY
{
    MMIO (rw)  : ORIGIN = 0x1bd00000, LENGTH = 16K
    ROM  (rx)  : ORIGIN = 0xbfc00000, LENGTH = 16K
    RAM  (rw)  : ORIGIN = 0xa0000000, LENGTH = 16K
}
 
SECTIONS
{
    . = ORIGIN(ROM);
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
	/* FIXME make it work
	. = ALIGN(64);
	__heap_start = .;
	. = . + 0x1000;
	__heap_end = .;
	*/
}


