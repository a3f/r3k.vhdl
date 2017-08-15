#!/bin/sh

which dpkg 2>&1 >/dev/null
if [ $? -ne 0 ]; then
   echo "This script is only for Debian-based systems. Install GHDL manually or use a VM"
   exit 1
fi

set -e
echo "Downloading and installing GNAT 4.9"
    sudo apt-get install gnat-4.9-base ||
         ( wget 'http://ftp.de.debian.org/debian/pool/main/g/gnat-4.9/gnat-4.9-base_4.9.2-1_amd64.deb' -O/tmp/gnat-4.9-base.deb && sudo dpkg -i /tmp/gnat-4.9-base.deb)
    sudo apt-get install libgnat-4.9 || 
         ( wget http://ftp.de.debian.org/debian/pool/main/g/gnat-4.9/libgnat-4.9_4.9.2-1_amd64.deb -O/tmp/libgnat.deb && sudo dpkg -i /tmp/libgnat.deb)


echo "Downloading and installing libmpc2 0.9-4"
    wget 'http://ftp.de.debian.org/debian/pool/main/m/mpclib/libmpc2_0.9-4_amd64.deb' -O/tmp/libmpc2.deb && sudo dpkg -i /tmp/libmpc2.deb

echo "Downloading and installing GHDL 0.34"
    wget 'https://github.com/tgingold/ghdl/releases/download/v0.34/ghdl-v0.34-mcode-ubuntu.tgz' -O/tmp/ghdl.tar.gz
    mkdir -p ghdl && tar xzf /tmp/ghdl.tar.gz -C ghdl

sudo ldconfig
