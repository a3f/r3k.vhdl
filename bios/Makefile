include ../toolchain/*.mk

MMAP = mmap.x
ifneq ($(BIG), 1)
	ENDIANNESS = -EL
endif
PIC ?=
CFLAGS = -O0 -march=r3k $(PIC) -g3 -Wall -Wextra -Wno-main $(ENDIANNESS) \
	     -ffreestanding -nostdlib -nostartfiles
ifeq ($(SYS), mips)
	CPPFLAGS += -DSYS_MIPS=1
else
ifeq ($(SYS), mipssim)
	CPPFLAGS += -DSYS_MIPSSIM=1
else
ifeq ($(SYS), malta)
	CPPFLAGS += -DSYS_MALTA=1
endif
endif
endif


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
	cpp $(CPPFLAGS) -nostdinc -P -o$@ -C $<

.PHONY: clean
clean:
	rm -rf *.o *.elf *.bin mmap.x

# vi: set shiftwidth=4 tabstop=4 noexpandtab:
# :indentSize=4:tabSize=4:noTabs=false:
