library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity alu is
    port(Src1       : in word_t;
         Src2       : in word_t;
         AluOp      : in alu_op_t;
         AluResult  : out word_t;
         Zero       : out std_logic
      -- We need to route a trap line, so we can reset the CPU on signed overflow
      -- Probably a global trap register, where we connect
      --Overflow   : out std_logic;
     );
end alu;


architecture behav of alu is
    signal HI, LO : word_t;
begin
        process (AluOp)
            variable result : word_t;
        begin
            case AluOp is
                when ALU_AND => result := Src1 and Src2;
                when ALU_OR  => result := Src1 or  Src2;
                when ALU_NOR => result := Src1 nor Src2;
                when ALU_XOR => result := Src1 xor Src2;
                when others => null; -- implement me!
            end case;

            Zero <= result = '0';

            AluResult <= result;
        end process;
end behav;

