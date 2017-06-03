# Barebones MIPS cross-compiler & toolchain

There are two platform flavors, 32- and 64-bit depending on your host Linux x86 environment.
The correct one is automatically chosen when the `setenv.sh` script is run.

## Setup details

Run the `setenv.sh` script to configure your PATH:

    $ . setenv.sh

Check that it worked:

    $ mips-gcc --version
    mips-gcc (GCC) 6.2.0
    Copyright (C) 2016 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

## Provided versions

| Package  | Version |
|----------|---------|
| binutils | 2.27    |
| gcc      | 6.2.0   |
| gmp      | 6.1.1   |
| isl      | 0.17    |
| libiconv | 1.14    |
| mpc      | 1.0.3   |
| mpfr     | 3.1.4   |


## Origin

Got it from https://github.com/rm-hull/barebones-toolchain
