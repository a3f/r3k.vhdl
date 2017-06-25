# GHDL flags and canned recipes

SELF_DIR = $(dir $(lastword $(MAKEFILE_LIST)))
GHDL_FLAGS = --std=93 --workdir=$(SELF_DIR)/work


define ghdl_clean
ghdl --remove
$(RM) *.o *.cf *.lst *.vcd
endef

define ghdl_build
ghdl -a $(GHDL_FLAGS) $^
endef

