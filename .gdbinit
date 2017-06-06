define xxd
	dump binary memory /tmp/dump.bin $arg0 $arg0+$arg1
	eval "shell xxd-o %p /tmp/dump.bin", $arg0
end

#b main
set endian little
set mipsfpu none
layout asm

define reconnect 
	dont-repeat
	target remote localhost:51234
end
reconnect
