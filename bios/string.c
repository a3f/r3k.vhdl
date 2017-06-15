#include "string.h"
#include <stddef.h>
char* itopow2(uint32_t num, int pow2, char *s, size_t size)
{
	long len = (long) size - 1;
	int counter = 0;

	do {
		// if (len <= 0) return NULL;

		if (counter++ == 4)
			s[--len] = '_';

		// if (len <= 0) return NULL;

		s[--len] = "0123456789abcdef"[num & ((1 << pow2) - 1)];
	} while ((num >>= pow2) != 0);

	s[size - 1] = '\0';
	return s + len;
}

char* itodec(uint32_t num, char *s, size_t size)
{
	int i = 0;

	if (num == 0) {
		s[i++] = '0';
		s[i] = '\0';
		return s;
	}

	s += size - 1;
	s[i--] = '\0';

	while (num != 0) {
		s[i--] = num % 10 + '0';
		num /= 10;
	}

	return &s[i+1];
}

void *memchr(const void *_ptr, int ch, size_t len)
{
	const unsigned char *ptr = _ptr;
    for (size_t i = 0; i < len; i++)
        if(ptr[i] == ch)
            return (void*)&ptr[i];

    return NULL;
}

void *memset(void *_dst, int ch, size_t len)
{
    unsigned char *dst = _dst;

    while (len--)
        *dst++ = (unsigned char)ch;

    return _dst;
}

int memcmp(const void *_s1, const void *_s2, size_t len)
{
	const unsigned char *s1 = _s1, *s2 = _s2;
	
    while (len--) {
        unsigned char ch1 = *s1++,
                      ch2 = *s2++;
        if (ch1 != ch2)
            return ch1 - ch2;
    }

    return 0;
}

void *memcpy(void * restrict _dst, const void * restrict _src, size_t len)
{
	      unsigned char *dst = _dst;
	const unsigned char *src = _src;

	if (!len) return _dst;

    size_t n = (len + 7) >> 3;
    switch (len & 7) {
    case 0: do { *dst++ = *src++;
    case 7:      *dst++ = *src++;
    case 6:      *dst++ = *src++;
    case 5:      *dst++ = *src++;
    case 4:      *dst++ = *src++;
    case 3:      *dst++ = *src++;
    case 2:      *dst++ = *src++;
    case 1:      *dst++ = *src++;
            } while (--n);
    }

	return _dst;
}

void *memmove(void *_dst, const void *_src, size_t len)
{
	      unsigned char *dst = _dst;
	const unsigned char *src = _src;

	if (!len) return _dst;

	if (dst <= src)
		return memcpy(dst, src, len);

	src += len;
	dst += len;

	while (len--)
		*--dst = *--src;

	return _dst;
}

