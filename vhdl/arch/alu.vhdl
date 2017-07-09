library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.utils.all;

entity alu is
    port(Src1       : in word_t;
         Src2       : in word_t;
         AluOp      : in alu_op_t;
         AluResult  : out word_t;
         Zero       : out ctrl_t;

         trap       : out traps_t -- only TRAP_OVERFLOW is relevant
     );
end alu;


architecture behav of alu is
    signal HI, LO : word_t;
    signal result : word_t;
begin
        process (AluOp)
        begin
            case AluOp is
                when ALU_ADD | ALU_ADDU =>
                                result <= Src1  +  Src2;
                when ALU_AND => result <= Src1 and Src2;
                when ALU_OR  => result <= Src1 or  Src2;
                when ALU_NOR => result <= Src1 nor Src2;
                when ALU_XOR => result <= Src1 xor Src2;
                when ALU_DIV =>
                    -- Interesting read: http://yarchive.net/comp/mips_exceptions.html
                    -- TL;DR: No arithmetic division errors on a MIPS R3000
                    trap <= TRAP_UNIMPLEMENTED; -- FIXME!
                when others => trap <= TRAP_UNIMPLEMENTED; -- FIXME!
            end case;

        end process;

        Zero <= '1' when result = X"0000_0000" else '0';
        AluResult <= result;
end behav;

