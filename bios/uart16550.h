/*
 * Copyright (C) 2001 MontaVista Software Inc.
 * Author: Jun Sun, jsun@mvista.com or jsun@junsun.net
 *
 * This program is free software; you can redistribute  it and/or modify it
 * under  the terms of  the GNU General  Public License as published by the
 * Free Software Foundation;  either version 2 of the  License, or (at your
 * option) any later version.
 *
 */

#ifndef _uart16550_h_
#define _uart16550_h_

#include <stdint.h>

#define         UART16550_BAUD_2400             (115200 / 2400)
#define         UART16550_BAUD_4800             (115200 / 4800)
#define         UART16550_BAUD_9600             (115200 / 9600)
#define         UART16550_BAUD_19200            (115200 / 19200)
#define         UART16550_BAUD_38400            (115200 / 38400)
#define         UART16550_BAUD_57600            (115200 / 57600)
#define         UART16550_BAUD_115200           (115200 / 115200)

#define         UART16550_PARITY_NONE           0
#define         UART16550_PARITY_ODD            0x08
#define         UART16550_PARITY_EVEN           0x18
#define         UART16550_PARITY_MARK           0x28
#define         UART16550_PARITY_SPACE          0x38

#define         UART16550_DATA_5BIT             0x0
#define         UART16550_DATA_6BIT             0x1
#define         UART16550_DATA_7BIT             0x2
#define         UART16550_DATA_8BIT             0x3

#define         UART16550_STOP_1BIT             0x0
#define         UART16550_STOP_2BIT             0x4

#define         UART16550_8N1 UART16550_DATA_8BIT | UART16550_PARITY_NONE | UART16550_STOP_1BIT

void uart16550_init(uint16_t baud_div, uint8_t config);
unsigned char uart16550_getc(void);
void uart16550_putc(unsigned char ch);

#endif
