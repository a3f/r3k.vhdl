include ../toolchain/*.mk

PATH := ../toolchain:$(PATH) # Put symlinks there if your cross compiler calls system as(1)
MMAP = mmap.x
ifeq ($(BIG), 1)
	ENDIANNESS = -EB
else
	ENDIANNESS = -EL
endif
PIC ?=
CFLAGS = -O0 -march=r3k $(PIC) -g3 -Wall -Wextra -Wno-main $(ENDIANNESS) \
         -ffreestanding -nostdlib -nostartfiles -msoft-float -std=gnu99
ifeq ($(SYS), mips)
	CPPFLAGS += -DSYS_MIPS=1
else
ifeq ($(SYS), mipssim)
	CPPFLAGS += -DSYS_MIPSSIM=1
else
ifeq ($(SYS), malta)
	CPPFLAGS += -DSYS_MALTA=1
	VGA_OBJS ?= qemu-vga/vga.a vga-demo.o
endif
endif
endif

ifeq ($(KERNEL), 1)
	CPPFLAGS += -DKERNEL=1
else
	CPPFLAGS += -DBIOS=1
endif

VGA_OBJS ?= vga.o

ASFLAGS = -march=r3k $(PIC) $(ENDIANNESS) -msoft-float
LDFLAGS = -ffreestanding $(PIC) -nostdlib -nostartfiles -march=r3k $(ENDIANNESS) \
          -Werror=implicit-function-declaration -T$(MMAP) -B$(AS)
LDLIBS  = -static-libgcc -lgcc

export

ifeq ($(V), 1)
	LDFLAGS += -Wl,-verbose
endif

export

.DEFAULT: bios.bin
bios.bin: mmap.x bios.elf
	$(OBJCOPY) -O binary bios.elf bios.bin

bios.elf: head.o init.o string.o tty.a $(VGA_OBJS)
	$(CC) $(LDFLAGS) -o$@ $^ $(LDLIBS)

tty.a: uart16550.o tty.o
	$(AR) rcs $@ $^

qemu-vga/vga.a:
	$(MAKE) -C qemu-vga

mmap.x: mmap.x.inc
	$(CC) -E -xc $(CPPFLAGS) -nostdinc -P -o$@ -C $<

# For the perl scripts to get access to CC, AS and co
printenv:
	@printenv

.PHONY: clean
clean:
	$(MAKE) -C qemu-vga clean
	rm -rf *.o *.elf *.bin mmap.x

# vi: set shiftwidth=4 tabstop=4 noexpandtab:
# :indentSize=4:tabSize=4:noTabs=false:
