.NOTPARALLEL: # has problems otherwise

include ../*.mk

SRCS  = $(wildcard *.vhdl)
NAMES = $(SRCS:.vhdl=)

.PHONY: all ../work/work-obj93.cf
all: ../work/work-obj93.cf test

.PHONY: test
test: $(SRCS)
	perl test.pl $(GHDL_FLAGS) $(NAMES)

.DEFAULT:
../work/work-obj93.cf: *.vhdl
	$(ghdl_build)

.PHONY: arch_defs
arch_defs: ;

.PHONY: clean
clean:
	$(ghdl_clean)

