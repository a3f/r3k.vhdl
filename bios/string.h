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

void *memchr(const void *ptr, int ch, size_t len);
void *memset(void *_dst, int ch, size_t len);
void *memchr(const void *ptr, int ch, size_t len);
int memcmp(const void *s1, const void *s2, size_t len);
void *memcpy(void *restrict dst, const void *restrict src, size_t len);
static inline void *mempcpy(void * restrict dst, const void * restrict src, size_t len)
{
    return (char*)memcpy(dst, src, len) + len;
}
void *memmove(void *dst, const void * src, size_t len);
static inline void *mempmove(void *dst, const void *src, size_t len)
{
    return (char*)memmove(dst, src, len) + len;
}


#endif

