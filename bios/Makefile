include ../toolchain/*.mk

MMAP = mmap.x
ENDIANNESS = -EL
PIC ?=
CFLAGS = -O0 -march=r3k $(PIC) -g3 -Wall -Wextra -Wno-main $(ENDIANNESS) \
	     -ffreestanding -nostdlib -nostartfiles
ASFLAGS = -march=r3k $(PIC) $(ENDIANNESS)
LDFLAGS = -ffreestanding $(PIC) -nostdlib -nostartfiles -T$(MMAP) -march=r3k $(ENDIANNESS)
ifeq ($(V), 1)
	LDFLAGS += -Wl,-verbose
endif

.DEFAULT: bios.bin
bios.bin: mmap.x bios.elf
	$(OBJCOPY) -O binary bios.elf $@

bios.elf: head.o shell.o uart16550.o tty.o string.o
	$(CC) $(LDFLAGS) -o$@ $^

mmap.x: mmap.x.inc
	cpp -nostdinc -P -o$@ -C $<

.PHONY: clean
clean:
	rm -rf *.o *.elf *.bin mmap.x

# vi: set shiftwidth=4 tabstop=4 noexpandtab:
# :indentSize=4:tabSize=4:noTabs=false:
