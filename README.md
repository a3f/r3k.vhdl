# r3k.vhdl - MIPS R3000 FPGA implementation in VHDL [![Build Status](https://travis-ci.org/a3f/r3k.vhdl.svg?branch=master)](https://travis-ci.org/a3f/r3k.vhdl)

## VHDL MIPS Implementation

Eventually, a VHDL implementation of a MIPS R3000 with memory mapped 16550-class UART and VGA.
Supplied Toolchain and BIOS can be used to cross-compile C application to run on it.

(More to follow)

## VHDL MIPS Simulation

![MIPS R3000 single-cycle datapath][datapath]

The VHDL code is located in `vhdl/`. Build and run tests with `make test`.

## BIOS

`bios/` contains a simple MIPS BIOS that runs a command interpreter on the UART. By default `make` is invoked with `SYS=malta`, which additionally spawns a window for VGA output.

## MIPS Emulator

Application can be tested locally in QEMU by running `make` in the root directory.
This will build the BIOS, applications and start a serial session with the command
interpreter running inside the emulator.

`make gdb` sets a breakpoint at `0xbfc0_0000` (reset vector) and `make monitor`
launches QEMU monitor mode. All three modes start a gdb server at port 51234.

`apt-get install gdb-multiarch` for debugging.

Three virtual boards are supported: MIPS Pseudoboard, MIPSSim and Malta. Pass e.g. 'SYS=mips" as environment variable to select one. '. You can also pass 'BIG=1' in order to build for big-endian. 

## C Toolchain

`toolchain/` contains Linux i686 and x86-64 cross MIPS toolchain binaries.
Add them to your PATH with `source toolchain/setenv.sh`


## Copyright and License

Copyright (C) 2017 Ahmad Fatoum and Niklas Fuhrberg.

This project is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License v3.0. See the file LICENSE for full copying conditions.

This project was written during the Basispraktikum Technische Informatik at the Karlsruhe Institute of Technology.

[datapath]: https://raw.githubusercontent.com/a3f/r3k.vhdl/master/datapath.png
