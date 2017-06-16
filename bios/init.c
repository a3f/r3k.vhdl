#include "tty.h"
#include "string.h"

extern const char vgastr[];

void demo(void);
void platform_init(unsigned, unsigned, unsigned);

#define MEMSIZE 16*1024*1024

void main(void)
{
    uart16550_init(UART16550_BAUD_115200, UART16550_8N1);
#if SYS_MALTA
    platform_init(640, 480, MEMSIZE);
    demo();
#endif

    while (1) {
        char buf[16] = "";
        puts("\e[31mr3k.vhdl%\e[0m ");
        gets(buf, sizeof buf);
        puts("You wrote: \n");
        hexdump(buf, sizeof buf);
    }

}
