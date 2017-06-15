/* 8250/16550-type synchronous serial driver
 * 
 * Copyright (C) 2017 Ahmad Fatoum
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 3 of the License, or (at your
 * option) any later version.
 *
 */


#include "config.h"
#include "uart16550.h"
#include <stdbool.h>

#define readonly  const
#define writeonly

#define __uart (*(struct uart16550*)UART_BASE)
//extern volatile
struct uart16550 {
    union {
        writeonly uint8_t tx;
        readonly  uint8_t rx;
                  uint8_t baud_div_lo;
    };
    union {
            uint8_t int_enable;
            uint8_t  baud_div_hi;
    };

    union {
        uint8_t int_status; 
        uint8_t fifo_ctrl;
    };

    writeonly struct {
        uint8_t config   : 5;
        uint8_t          : 2;
        uint8_t set_baud : 1;
    } line_ctrl;

    writeonly uint8_t modem_ctrl;

    readonly struct {
        uint8_t data_available : 1;
        uint8_t                : 4;
        uint8_t tx_empty       : 1;
        uint8_t                : 2;
    } line_status;

    readonly uint8_t modem_status;
};//  __uart;

_Static_assert(sizeof __uart == 7, "Struct not padded correctly!");

void uart16550_init(uint16_t baud_div, uint8_t config)
{
    __uart.int_enable = false;

    __uart.line_ctrl.set_baud = true;

    __uart.baud_div_lo = (uint8_t)baud_div;
    __uart.baud_div_hi = (uint8_t)(baud_div >> 8);

    __uart.line_ctrl.set_baud = false;

    __uart.line_ctrl.config = config;
}

unsigned char uart16550_getc(void)
{
    while(!__uart.line_status.data_available)
        ;

    char ch = __uart.rx;
    if (ch == '\r') ch = '\n';
    return ch;
}


void uart16550_putc(unsigned char ch)
{
    while (!__uart.line_status.tx_empty)
        ;

    __uart.tx = ch;

    if (ch == '\n')
        uart16550_putc('\r');
}

