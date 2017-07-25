#include "../barebones.inc"

_start:
nop;

li $gp, 0x10000000 # VRAM
or $v0, $0, $0
ori $v0, $v0, 0b00011100
sb $v0, 0($gp)
lb $v0, 0($gp)

nop;
j start;

