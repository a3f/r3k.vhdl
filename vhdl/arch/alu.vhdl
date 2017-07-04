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

         trap       : out traps_t
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
                when ALU_DIV =>
                    if Src2 = X"0000_0000" then
                        trap <= TRAP_DIVBYZERO;
                    else
                        trap <= TRAP_UNIMPLEMENTED;
                    end if;
                when others => trap <= TRAP_UNIMPLEMENTED; -- FIXME!
            end case;

            Zero <= high_if(result = X"0000_0000");

            AluResult <= result;
        end process;
end behav;

