.NOTPARALLEL: # has problems otherwise

include ../*.mk

SRCS = $(wildcard *.vhdl)

.PHONY: all ../work/work-obj93.cf
all: ../work/work-obj93.cf

.DEFAULT:
../work/work-obj93.cf: *.vhdl
	$(ghdl_build)

.PHONY: globals
globals: ;

.PHONY: clean
clean:
	$(ghdl_clean)

