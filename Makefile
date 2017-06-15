.NOTPARALLEL:
CPU  ?= 74Kf
SYS  ?= mips
export SYS
BIOS ?= bios/bios.bin
GRAPHIC ?= -nographic
ifneq ($(SYS), mipssim)
	VGA ?= -device isa-vga
endif
ifeq ($(BIG), 1)
	QEMU ?= qemu-system-mips
	ENDIAN = BIG
else
	QEMU ?= qemu-system-mipsel
	ENDIAN = LITTLE
endif

.PHONY: gdb emu monitor bios
emu: $(ENDIAN) bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) $(GRAPHIC) -monitor null -m 16M  -serial stdio \
	-gdb tcp::51234 $(VGA) -M $(SYS)
	stty sane

gdb: $(ENDIAN) bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) $(GRAPHIC) -monitor null -m 16M  -serial stdio \
	-gdb tcp::51234 $(VGA) -M $(SYS)
	stty sane

monitor: $(ENDIAN) bios
	$(QEMU) -bios $(BIOS) -cpu $(CPU) $(GRAPHIC) -monitor stdio -m 16M  -serial null \
	-gdb tcp::51234 $(VGA) -M $(SYS) -S
	stty sane

$(ENDIAN):
	make clean
	touch $(ENDIAN)

bios:
	$(MAKE) -C bios

vhdl sim:
	$(MAKE) -C vhdl


.PHONY: clean
clean:
	$(MAKE) -C bios clean
	rm -f BIG LITTLE


# vi: set shiftwidth=4 tabstop=4 noexpandtab:
# :indentSize=4:tabSize=4:noTabs=false:
