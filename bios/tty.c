#include "tty.h"
#include "string.h"
#include <stdarg.h>
#include <stdbool.h>

#define putc uart16550_putc
#define getc uart16550_getc

void puts(const char *s)
{
	while (*s) putc(*s++);
}
void putmem(const void *_s, size_t n)
{
    const unsigned char *s = _s;
	while (n--) putc(*s++);
}

char *gets_till(char *buf, size_t size, char delim)
{
	if (!size)
		return buf;

    size_t i = 0;
    
	char *s = buf;
	if (size > 1) redo: do {
		*s = getc();
        switch (*s) {
            case '\x7f':
                if (i) {
                    puts("\b \b");
                    i--;
                }
                goto redo;
            case 'D' - 'A' + 1:
                goto out;
        }
        putc(*s);
	} while (*s++ != delim &&  ++i < size);
    out:

	*s = '\0';

	return buf;
}

char *gets(char *s, size_t size)
{
	return gets_till(s, size, '\n');
}

void vprintf(const char * restrict fmt, va_list args)
{
	for (;;) {
		const char *start = fmt;
		while (*fmt && *fmt != '%')
			fmt++;

		putmem(start, fmt - start);
		if (*fmt == '\0') break;

		char buf[64];
		unsigned val = va_arg(args, unsigned);
		switch (*++fmt) {
			case 'i':
			case 'd':
				if (val & 0x80000000) {
					putc('-');
					val = -val;
				}
			case 'u':
				puts(itodec(val, buf, sizeof buf));
				break;
			case 'b':
				puts(itopow2(val, 1, buf, sizeof buf));
				break;
			case 'o':
				puts(itopow2(val, 3, buf, sizeof buf));
				break;
			case 'p':
				puts("0x");
			case 'x':
			case 'X':
				puts(itopow2(val, 4, buf, sizeof buf));
				break;
			case 'c':
				putc(val);
				break;
			case 's':
				puts((char*)val);
				break;
			case '\0':
				fmt--;
				break;
			case '%':
			default:
				putc(*fmt);

		}
		fmt++;
	}
}

void printf(const char * restrict fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	vprintf(fmt, args);
	va_end(args);
}

void hexdump(const void *addr, size_t len)
{
	unsigned i;
	unsigned char buf[17];
	unsigned char *pc = (unsigned char*)addr;

	if (!addr || !len)
		return;

    // Process every byte in the data.
    for (i = 0; i < len; i++) {
        // Multiple of 16 means new line (with line offset).

        if ((i % 16) == 0) {
            char hexbuf[] = "0000";
            // Just don't print ASCII for the zeroth line.
            if (i != 0)
                printf ("  %s\n", buf);

            // Output the offset.
            puts("  ");
            itopow2(i, 4, hexbuf, sizeof hexbuf);
            putmem(hexbuf, sizeof hexbuf);
            puts(" ");
        }

        char hexbuf[] = "00";
        // Now the hex code for the specific character.
        putc(' ');
        itopow2(pc[i], 4, hexbuf, sizeof hexbuf);
        putmem(hexbuf, sizeof hexbuf);


        // And store a printable ASCII character for later.
        if ((pc[i] < 0x20) || (pc[i] > 0x7e))
            buf[i % 16] = '.';
        else
            buf[i % 16] = pc[i];
        buf[(i % 16) + 1] = '\0';
    }

    // Pad out last line if not exactly 16 characters.
    while ((i % 16) != 0) {
        printf("   ");
        i++;
    }

    // And print the final ASCII bit.
    printf("  %s\n", buf);
}

