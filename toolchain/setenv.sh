#!/usr/bin/bash
#
# Adds the bin directory to the path, use as:
#
#    . ./setenv.sh

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/cross/$(uname -m)/bin
echo Adding $DIR to path

export PATH=$DIR:$PATH
