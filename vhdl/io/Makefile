.NOTPARALLEL: # has problems otherwise

include ../*.mk

SRCS = $(wildcard *.vhdl)

.PHONY: all uart vga ../work/work-obj93.cf
all: uart vga ../work/work-obj93.cf

.DEFAULT:
../work/work-obj93.cf: *.vhdl
	$(ghdl_build)

uart: uart/*.vhdl
	$(ghdl_build)

vga: vga/color_util.vhdl vga/*.vhdl
	$(ghdl_build)

.PHONY: globals
globals: ;

.PHONY: clean
clean:
	$(ghdl_clean)

