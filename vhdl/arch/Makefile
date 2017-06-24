.NOTPARALLEL: # has problems otherwise

GHDL_FLAGS = --std=93

all: arch_defs.o maindec.o

%.o: %.vhdl
	ghdl -a $(GHDL_FLAGS) $^


.PHONY: clean
clean:
	$(RM) *.vcd
	ghdl --remove
	$(RM) *.o *.cf *.lst

