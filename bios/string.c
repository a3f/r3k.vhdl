#include "string.h"
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

