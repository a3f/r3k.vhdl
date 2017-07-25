.set mips1
.set noreorder
.set noat

.org 0

li $at, 0x14000000 # LEDs
li $k0, 0x14000002 # Push buttons

lb $v0, 0($k0)
sb $v0, 0($at)

