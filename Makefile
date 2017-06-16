.NOTPARALLEL:
CPU  ?= 24Kf
SYS  ?= malta
BIOS ?= bios/bios

include boards.mk

ifeq ($(BIG), 1)
	QEMU ?= qemu-system-mips
	ENDIAN = BIG
else
	QEMU ?= qemu-system-mipsel
	ENDIAN = LITTLE
endif
ifeq ($(KERNEL), 1)
	IMAGE ?= -kernel $(BIOS).elf
else
	IMAGE ?= -bios $(BIOS).bin
endif

export

.PHONY: gdb emu monitor bios
emu: $(ENDIAN) bios
	$(QEMU) $(IMAGE) -cpu $(CPU) -monitor null -m 16M $(DEV) \
	-gdb tcp::51234 -M $(SYS)
	stty sane

gdb: $(ENDIAN) bios
	$(QEMU) $(IMAGE) -cpu $(CPU) -monitor null -m 16M $(DEV) \
	-gdb tcp::51234 -M $(SYS) -S
	stty sane

monitor: $(ENDIAN) bios
	$(QEMU) $(IMAGE) -cpu $(CPU) -monitor stdio -m 16M $(DEV) \
	-gdb tcp::51234 -M $(SYS)
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
