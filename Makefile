CPU  ?= 74Kf
SYS  ?= mipssim
BIOS ?= bios/bios.bin
QEMU ?= qemu-system-mipsel

.PHONY: gdb emu monitor bios
emu: bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) -nographic -monitor null -m 16M  -serial stdio \
	-gdb tcp::51234 -M $(SYS)
	stty sane

gdb: bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) -nographic -monitor null -m 16M  -serial stdio \
	-gdb tcp::51234 -M $(SYS) -S
	stty sane

monitor: bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) -nographic -monitor stdio -m 16M  -serial null \
	-gdb tcp::51234 -M $(SYS) -S
	stty sane

bios:
	$(MAKE) -C bios



.PHONY: clean
clean:
	$(MAKE) -C bios clean


# vi: set shiftwidth=4 tabstop=4 noexpandtab:
# :indentSize=4:tabSize=4:noTabs=false:
