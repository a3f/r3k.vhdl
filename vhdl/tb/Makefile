.NOTPARALLEL: # has problems otherwise

include ../*.mk

SRCS  = $(wildcard *_tb.vhdl)
NAMES = $(SRCS:.vhdl=)

.PHONY: all ../work/work-obj93.cf
all: ../work/work-obj93.cf test

.PHONY: test
test: $(SRCS)
	perl test.pl $(GHDL_FLAGS) $(NAMES)

.DEFAULT:
../work/work-obj93.cf: *.vhdl
	$(ghdl_build)

.PHONY: globals
globals: ;

.PHONY: clean
clean:
	$(ghdl_clean)

