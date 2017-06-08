# MIPS R3000

We will design a processor implementing a big subset of the MIPS R3000. The different entities, which architectures will comprise the CPU will be modelled after the original MIPS pipeline.

A total of 51 Instructions will need to be implemented. Many of them are variations of each other. e.g. there are 4 ADD instructions differeing in addressing mode and 8 branch instructions, differing only in branch condition.

## I/O

Two memory mapped devices will be implemented in VHDL:

* A 8250-class UART
* A VGA frame buffer, similar in operation to the IBM VGA BIOS Mode 13h

## Operation

The C-Code will be compiled by a cross GCC toolchain to MIPS R3000 assembler. The raw machine code will be extracted and written to FPGA ROM. The ROM is mapped on the address of the reset vector. MIPS instructions starting with that address are mapped. The bootloader initializes the .data, .bss and stack segments and starts executing the C main code. The C code starts polling the UART and presents a command prompt where a number of demos (e.g. Mandeblrot on VGA generator) can be selected.

More information is available in the attached slide set.

## Github repositoriy

https://github.com/a3f/r3k.vhdl

## Work division

Part                  | Responsible 
--------------------- | --------------
Instruction Decoder   | Ahmad
UART                  | Niklas
ALU                   | Aicha
RAM                   | Ahmad
Address decoder       | Niklas
ROM                   | Aicha
VGA frame buffer      | Ahmad
Register File         | Niklas
Pipeline (Data path)  | Aicha and us

## Listing 1
Instructions to be implemented:

    add   
    addi  
    addiu 
    addu
    and   
    andi  
    lui   
    nor   
    or    
    ori   
    slt   
    slti  
    sltiu 
    sltu  
    sub   
    subu  
    xor   
    xori  
    sll   
    sllv  
    sra   
    srav  
    srl   
    srlv  
    div   
    divu  
    mfhi  
    mflo  
    mthi  
    mtlo  
    mult  
    multu 
    beq   
    bgez  
    bgezal
    bgtz  
    blez  
    bltz  
    bltzal
    bne   
    j     
    jal   
    jr    
    lb   
    lbu  
    lh   
    lhu  
    lw   
    sb   
    sh   
    sw   

All other instructions, including the following, will lead to a system reset.

    break 
    mfc0  
    mtc0  
    syscall
