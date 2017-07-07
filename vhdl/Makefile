.NOTPARALLEL: # has problems otherwise

include *.mk

G_SRCS = $(wildcard *.vhdl)
G_OBJS = $(G_SRCS:.vhdl=.o)

.PHONY: all
all: arch io

.PHONY: test
test: tb

.PHONY: globals
globals: $(G_OBJS)

.PHONY: arch
arch: globals
	$(MAKE) -C $@

.PHONY: io
io: globals
	$(MAKE) -C $@

.PHONY: tb
tb: arch io
	$(MAKE) -C $@ test

%.o: %.vhdl
	$(ghdl_build)

.PHONY: clean
clean:
	$(MAKE) -C arch clean
	$(MAKE) -C tb clean
	cd work && $(RM) *.o *.cf *.lst *.vcd

