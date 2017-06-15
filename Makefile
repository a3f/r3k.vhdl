CPU  ?= 74Kf
SYS  ?= mips
BIOS ?= bios/bios.bin
QEMU ?= qemu-system-mipsel
GRAPHIC ?= -nographic
VGA ?= -device isa-vga

.PHONY: gdb emu monitor bios
emu: bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) $(GRAPHIC) -monitor null -m 16M  -serial stdio \
	-gdb tcp::51234 -M $(SYS) $(VGA)
	stty sane

gdb: bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) $(GRAPHIC) -monitor null -m 16M  -serial stdio \
	-gdb tcp::51234 -M $(SYS) $(VGA) -S
	stty sane

monitor: bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) $(GRAPHIC) -monitor stdio -m 16M  -serial null \
	-gdb tcp::51234 -M $(SYS) $(VGA) -S
	stty sane

bios:
	$(MAKE) -C bios

vhdl sim:
	$(MAKE) -C vhdl


.PHONY: clean
clean:
	$(MAKE) -C bios clean


# vi: set shiftwidth=4 tabstop=4 noexpandtab:
# :indentSize=4:tabSize=4:noTabs=false:
