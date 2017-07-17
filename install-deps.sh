#!/bin/sh
which dpkg 2>&1 >/dev/null

if [ $? -eq 0 ]; then
    set -e
    sudo apt-get install libgnat-4.6 || 
         ( wget http://ftp.de.debian.org/debian/pool/main/g/gnat-4.6/libgnat-4.6_4.6.3-8_amd64.deb -O/tmp/libgnat.deb && sudo dpkg -i /tmp/libgnat.deb)
    wget http://ftp.de.debian.org/debian/pool/main/m/mpclib/libmpc2_0.9-4_amd64.deb -O/tmp/libmpc2.deb
    sudo dpkg -i /tmp/libmpc2.deb
    wget https://sourceforge.net/projects/ghdl-updates/files/Builds/ghdl-0.33/debian/ghdl_0.33-1jessie1_amd64.deb/download -O/tmp/ghdl.deb
    sudo dpkg -i /tmp/ghdl.deb
    sudo ldconfig
    ghdl --version
else
   echo "This script is only for Debian-based systems. Install GHDL, QEMU and cross compiler manually or use a VM"
   exit 1
fi

