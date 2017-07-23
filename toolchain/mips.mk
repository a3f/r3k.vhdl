ifneq (, $(shell command -v mips-gcc))
	PREFIX ?= mips-
else ifneq (, $(shell command -v mipsel-elf-gcc))
	PREFIX ?= mipsel-elf-
else ifneq (, $(shell command -v mips-elf-gcc))
	PREFIX ?= mips-elf-
else ifneq (, $(shell which mipsel-none-elf-gcc))
	PREFIX ?= mipsel-none-elf-
else ifneq (, $(shell which mips-none-elf-gcc))
	PREFIX ?= mipsel-none-elf-
else ifneq (, $(shell which mips-none-elf-gcc))
	PREFIX ?= mips-none-elf-
else
	PREFIX ?= mips-
endif

AS        = $(PREFIX)as
CC        = $(PREFIX)gcc
LD        = $(PREFIX)ld
OBJCOPY   = $(PREFIX)objcopy
SIZE      = $(PREFIX)size
STRIP     = $(PREFIX)strip
AR        = $(PREFIX)ar
ADDR2LINE = $(PREFIX)addr2line
RANLIB    = $(PREFIX)ranlib
CXX       = $(PREFIX)c++
OBJDUMP   = $(PREFIX)objdump
STRINGS   = $(PREFIX)strings
NM        = $(PREFIX)nm
READELF   = $(PREFIX)readelf

export
