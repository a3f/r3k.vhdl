#ifndef STRING_H_
#define STRING_H_

#include <stddef.h>
#include <stdint.h>

char* itopow2(unsigned long num, int pow2, char *s, size_t size);
char* itodec(uint32_t num, char *s, size_t size);

static inline size_t strlen(const char *s)
{
    size_t n = 0;
    while (*s++) n++;
    return n;
}

#endif
