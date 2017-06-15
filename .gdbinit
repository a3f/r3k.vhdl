define xxd
	dump binary memory /tmp/dump.bin $arg0 $arg0+$arg1
	eval "shell xxd-o %p /tmp/dump.bin", $arg0
end

#b main
set mipsfpu none
shell touch /tmp/endianness
shell if test -f ./LITTLE; then echo "set endian little" > /tmp/endianness; fi
shell if test -f ./BIG; then echo "set endian big" > /tmp/endianness; fi
source /tmp/endianness
#layout asm
set $mmio = (uint8_t*)0x14000000
set $uart = $mmio+0x3f8
set $isamem = (uint8_t*)0x10000000
set $rom = (uint8_t*)0xbfc00000
set $ram = (uint8_t*)0xa0000000
set $vga_linux = (uint8_t*)0xb0000000
set $vga_e = (uint8_t*)0xe0000000
set $vga_a_abs = (uint8_t*)0xa0000
set $vga_a = $mmio + (size_t)$vga_a_abs

define try_addr
    set *(uint8_t*)($arg0+0xA0000) = 4
    set *(uint8_t*)($arg0+0xA0001) = 0xFF
    set *(uint32_t*)($arg0+0xA0004) = 0x07690748
    set *(uint8_t*)($arg0+0xA8000) = 4
    set *(uint8_t*)($arg0+0xA8001) = 0xFF
    set *(uint32_t*)($arg0+0xA8004) = 0x07690748
    set *(uint8_t*)($arg0+0xB0000) = 4
    set *(uint8_t*)($arg0+0xB0001) = 0xFF
    set *(uint32_t*)($arg0+0xB0004) = 0x07690748
    set *(uint8_t*)($arg0+0xB8000) = 4
    set *(uint8_t*)($arg0+0xB8001) = 0xFF
    set *(uint32_t*)($arg0+0xB8004) = 0x07690748
end

set $vga = 0xB8000
set $greeting = 0x07690748

dir bios

define reconnect 
	dont-repeat
	target remote localhost:51234
end
reconnect
