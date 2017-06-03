#!/bin/sh
gdb-multiarch -q -n -x .gdbinit -- bios/bios.elf
