-- Don't use this.
-- GHDL doesn't put signals of enumerated type into the .vcd signal trace
-- So we'd have to settle for constants when we want to display them.
-- If you find yourself in that position, comment out alu_op_t in arch_defs.vhdl
-- and use this one here instead.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package alu_defs is

    subtype alu_op_t is std_logic_vector(4 downto 0);
    constant ALU_ADD : alu_op_t   := B"0_0000";
    constant ALU_ADDU : alu_op_t  := B"0_0001";
    constant ALU_SUB : alu_op_t   := B"0_0010";
    constant ALU_SUBU : alu_op_t  := B"0_0011";

    constant ALU_AND : alu_op_t   := B"0_0100";
    constant ALU_OR : alu_op_t    := B"0_0101";
    constant ALU_NOR : alu_op_t   := B"0_0110";
    constant ALU_XOR : alu_op_t   := B"0_0111";
    constant ALU_LU : alu_op_t    := B"0_1000";

    constant ALU_SLL : alu_op_t   := B"0_1001";
    constant ALU_SRL : alu_op_t   := B"0_1010";
    constant ALU_SRA : alu_op_t   := B"0_1011";

    constant ALU_MULT : alu_op_t  := B"0_1100";
    constant ALU_MULTU : alu_op_t := B"0_1101";
    constant ALU_DIV : alu_op_t   := B"0_1110";
    constant ALU_DIVU : alu_op_t  := B"0_1111";

    constant ALU_MFHI : alu_op_t  := B"1_0000";
    constant ALU_MFLO : alu_op_t  := B"1_0001";
    constant ALU_MTHI : alu_op_t  := B"1_0010";
    constant ALU_MTLO : alu_op_t  := B"1_0011";

    constant ALU_SLT : alu_op_t   := B"1_0100";
    constant ALU_SLTU : alu_op_t  := B"1_0101";

    constant ALU_EQ : alu_op_t    := B"1_0110";
    constant ALU_NE : alu_op_t    := B"1_0111";
    constant ALU_LEZ : alu_op_t   := B"1_1000";
    constant ALU_LTZ : alu_op_t   := B"1_1001";
    constant ALU_GTZ : alu_op_t   := B"1_1010";
    constant ALU_GEZ : alu_op_t   := B"1_1011";
end package;
