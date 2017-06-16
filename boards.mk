ifeq ($(SYS), malta)
	DEV ?= -nodefaults -device VGA -serial none -serial null -serial null
	KERNEL=1

ifeq ($(BIG), 1)
	$(error Malta PCI code is not big endian-safe. \
			Comment this conditional out if you want to build anyway.)
endif
endif

ifeq ($(SYS), mipssim)
    DEV ?= -nographic
endif


ifeq ($(SYS), mips)
	DEV ?= -device isa-vga -nographic # didn't manage to get that to work
endif

DEV += -serial stdio

export
