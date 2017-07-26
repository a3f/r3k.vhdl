#
# Adds the compilers' bin directory to the path, use as:
#
#    . ./setenv.sh

CDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PATH=$CDIR/ghdl/bin:$CDIR/toolchain/cross/$(uname -m)/bin:$PATH
