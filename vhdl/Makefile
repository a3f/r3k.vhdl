.NOTPARALLEL: # has problems otherwise

include *.mk

.PHONY: all
all: arch io

.PHONY: test
test: tb

.PHONY: globals
globals: arch_defs.o utils.o

.PHONY: arch
arch: globals
	$(MAKE) -C $@

.PHONY: io
io: globals
	$(MAKE) -C $@

.PHONY: tb
tb: arch
	$(MAKE) -C $@ test

%.o: %.vhdl
	$(ghdl_build)

.PHONY: clean
clean:
	$(MAKE) -C arch clean
	$(MAKE) -C tb clean
	$(RM) work/{*.o,*.cf,*.lst,*.vcd}

