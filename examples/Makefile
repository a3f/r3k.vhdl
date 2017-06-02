AS = mips-as
CC = mips-gcc
LDFLAGS = -nostdlib

.DEFAULT: examples
examples: 00-simple.elf 01-simple.elf

00-simple.elf: 00-simple.o
	$(CC) $(LDFLAGS) -o$@ $^ $(LOADLIBS) $(LDLIBS)

01-simple.elf: 01-simple.o
	$(CC) $(LDFLAGS) -o$@ $^ $(LOADLIBS) $(LDLIBS)

.PHONY: clean
clean:
	rm -rf *.o *.elf
