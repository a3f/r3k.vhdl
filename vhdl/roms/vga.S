#include "../barebones.inc"

_start:
nop;

li $gp, 0x10000000 # VRAM

li $v0, 0b00011111
sb $v0, 0($gp)

li $v0, 0b00000011
sb $v0, 19($gp)

li $v0, 0b11111111
sb $v0, 150($gp)

li $v0, 0b00011100
sb $v0, 280($gp)

li $v0, 0b11100000
sb $v0, 299($gp)

nop;
j start;

