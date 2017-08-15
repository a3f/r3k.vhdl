#!/bin/sh

which dpkg 2>&1 >/dev/null
if [ $? -ne 0 ]; then
   echo "This script is only for Debian-based systems. Install GHDL manually or use a VM"
   exit 1
fi

set -e
echo "Downloading and installing GNAT 4.8"
    sudo apt-get install gnat-4.8-base ||
         ( wget 'http://de.archive.ubuntu.com/ubuntu/pool/universe/g/gnat-4.8/gnat-4.8-base_4.8.2-8ubuntu3_amd64.deb' -O/tmp/gnat-4.8-base.deb && sudo dpkg -i /tmp/gnat-4.8-base.deb)
    sudo apt-get install libgnat-4.8 || 
         ( wget 'http://de.archive.ubuntu.com/ubuntu/pool/universe/g/gnat-4.8/libgnat-4.8_4.8.2-8ubuntu3_amd64.deb' -O/tmp/libgnat.deb && sudo dpkg -i /tmp/libgnat.deb)

echo "Downloading and installing libmpc2 0.9-4"
    wget 'http://ftp.de.debian.org/debian/pool/main/m/mpclib/libmpc2_0.9-4_amd64.deb' -O/tmp/libmpc2.deb && sudo dpkg -i /tmp/libmpc2.deb

echo "Downloading and installing GHDL 0.34dev"
    wget 'https://github.com/tgingold/ghdl/releases/download/v0.34/ghdl-v0.34-mcode-ubuntu.tgz' -O/tmp/ghdl.tar.gz
    mkdir -p ghdl && tar xzf /tmp/ghdl.tar.gz -C ghdl

sudo ldconfig
