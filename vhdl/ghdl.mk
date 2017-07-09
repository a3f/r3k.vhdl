# GHDL flags and canned recipes

SELF_DIR = $(dir $(lastword $(MAKEFILE_LIST)))
GHDL_FLAGS = --std=93c -fexplicit --ieee=synopsys --workdir=$(SELF_DIR)/work

# See http://ghdl.readthedocs.io/en/latest/Invoking_GHDL.html
# for why -fexplicit is needed

define ghdl_clean
ghdl --remove
$(RM) *.o *.cf *.lst *.vcd
endef

define ghdl_build
ghdl -a $(GHDL_FLAGS) $^
endef

