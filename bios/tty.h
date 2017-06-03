#ifndef STDIO_H_
#define STDIO_H_

#include <stddef.h>
#include <stdarg.h>
#include "uart16550.h"

#define putc uart16550_putc
#define getc uart16550_getc

void puts(const char *s);
void putmem(const void *s, size_t n);
char *gets_till(char *buf, size_t size, char delim);
char *gets(char *s, size_t size);

void printf(const char *restrict fmt, ...);
void vprintf(const char *restrict fmt, va_list va);
void hexdump(const void *addr, size_t len);

#endif
