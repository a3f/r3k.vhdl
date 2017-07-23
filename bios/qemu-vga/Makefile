CPPFLAGS = -isystem .. -Iinclude
CFLAGS += -Wno-implicit-fallthrough
PATH := ../../toolchain:$(PATH)


vga.a: mips/gt64120.o mips/pci.o sys/stdvga.o qsort.o sys/physmem.o mips/malta.o sys/pci_ids.o
	$(AR) rcs $@ $^

.PHONY: clean
clean:
	rm -f mips/*.o sys/*.o *.o *.a

# vi: set shiftwidth=4 tabstop=4 noexpandtab:
# :indentSize=4:tabSize=4:noTabs=false:
