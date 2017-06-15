#include "tty.h"
#include "string.h"

void main(void)
{
    uart16550_init(UART16550_BAUD_115200, UART16550_8N1);

    __attribute__((unused)) volatile unsigned v0 = 0xffff;
    __attribute__((unused)) volatile unsigned v1 = 0xff00;

    volatile char test[256];
    memset(test+1, 0xFF, 254);
    while (1) {
        char buf[16] = "";
        puts("\e[31mr3k.vhdl$\e[0m ");
        gets(buf, sizeof buf);
        puts("You wrote: \n");
        hexdump(buf, sizeof buf);
    }

    while (1);
}
