.NOTPARALLEL: # has problems otherwise

include *.mk

.PHONY: all
all: arch io

.PHONY: test
test: tb

.PHONY: arch_defs
arch_defs: arch_defs.o

.PHONY: arch
arch: arch_defs
	$(MAKE) -C $@

.PHONY: io
io: arch_defs
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

