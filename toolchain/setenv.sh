#
# Adds the bin directory to the path, use as:
#
#    . ./setenv.sh

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/cross/$(uname -m)/bin
# I know, I know...
[[ -z "${CI}" ]] && true || chmod +x $DIR/* $DIR/../libexec/gcc/mips/6.2.0/*

echo Adding $DIR to path

export PATH=$DIR:$PATH
