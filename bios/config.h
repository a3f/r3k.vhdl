#ifndef __CONFIG_H_
#define __CONFIG_H_

#define ELF_BASE  0x00000000

#define ROM_BASE  0xbfc00000
#define RAM_BASE  0xa0000000

#if SYS_MALTA
    #define MMIO_BASE 0x1f000000
    #define UART_BASE (MMIO_BASE+0x900)
    #define UART_PAD  uint64_t :64;
#if KERNEL
    #undef ROM_BASE
    #define ROM_BASE  0x80100000
    #undef ELF_BASE
    #define ELF_BASE  0x00100000
    #undef MMIO_BASE
    #define MMIO_BASE 0xbf000000
#endif

#elif SYS_MIPSSIM
    #define MMIO_BASE 0x1fd00000

#elif SYS_MIPS
    #define MMIO_BASE 0x14000000

#else
    #error "Unknown System"

#endif

#define LED_BASE        (MMIO_BASE+0x000)
#define DIP_SWITCH_BASE (MMIO_BASE+0x001)
#define PUSHBUTTON_BASE (MMIO_BASE+0x002)
#ifndef UART_BASE
    #define UART_BASE  (MMIO_BASE+0x3f8)
#endif

#ifndef UART_PAD
#define UART_PAD
#endif

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define MIPSEL 1
#endif

#endif
