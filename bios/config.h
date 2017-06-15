#ifndef __CONFIG_H_
#define __CONFIG_H_

#define ROM_BASE  0xbfc00000
#define RAM_BASE  0xa0000000

#ifdef HAVE_MIPSSIM /* we don't */
#define MMIO_BASE 0x1bd00000
#else
#define MMIO_BASE 0x14000000
#endif

#define LED_BASE        (MMIO_BASE+0x000)
#define DIP_SWITCH_BASE (MMIO_BASE+0x001)
#define PUSHBUTTON_BASE (MMIO_BASE+0x002)
#define UART_BASE       (MMIO_BASE+0x3f8)

#endif
