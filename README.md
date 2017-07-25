# r3k.vhdl - MIPS R3000 FPGA implementation in VHDL [![Build Status](https://travis-ci.org/a3f/r3k.vhdl.svg?branch=master)](https://travis-ci.org/a3f/r3k.vhdl)

## VHDL MIPS Implementation

A MIPS R3000 softcore written in VHDL with memory mapped 16550-class UART and VGA.
(Eventually), Supplied Toolchain and BIOS can be used to cross-compile C application to run on it.

(More to follow)

## VHDL MIPS Simulation

![MIPS R3000 single-cycle datapath][datapath]

The VHDL93 code is located in `vhdl/`. Build and run tests by executing `make test` in that directory. The test system was written for use with GHDL. The subdirectory `ise/` contains the project files for use with ISE. We used version 14.7.

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

Prebuilt Out-of-tree binutils and cross GCC are available [here](https://github.com/a3f/Cross-mips-elf-gcc-for-macOS).

If you rather build your own, unpack binutils and GCC source tarballs to e.g. `/opt/cross`
and run:

```
export PREFIX=/opt/cross/gcc-mips
export PATH=${PREFIX}/bin:${PATH}
../binutils-2.*/configure --target=mipsel-elf --prefix=$PREFIX
../gcc-7.*/configure --target=mipsel-elf --prefix=$PREFIX --without-headers --with-gnu-as --with-gnu-ld --disable-shared --enable-languages=c --disable-libssp
```

## Copyright and License

Copyright (C) 2017 Ahmad Fatoum and Niklas Fuhrberg.

This project is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License v3.0. See the file LICENSE for full copying conditions.

This project was written during the Basispraktikum Technische Informatik at the Karlsruhe Institute of Technology.

[datapath]: https://raw.githubusercontent.com/a3f/r3k.vhdl/master/datapath.png
