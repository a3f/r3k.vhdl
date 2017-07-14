library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;
use work.overloads.all;

entity alu is
    port(Src1       : in word_t;
         Src2       : in word_t;
         AluOp      : in alu_op_t;
         AluResult  : out word_t;
         Zero       : out ctrl_t;

         trap       : out traps_t -- only TRAP_OVERFLOW is relevant
     );
end alu;


-- http://www-inst.eecs.berkeley.edu/~cs61c/resources/MIPS_Green_Sheet.pdf
architecture behav of alu is
    signal HI, LO : word_t;
begin
        trap <= TRAP_NONE; -- rethink
        process (Src1, Src2, AluOp)
            variable result : word_t := X"DEADBEEF";
        begin
            case AluOp is
                -- Trapping not implemented
                when ALU_ADD  => result := Src1  +  Src2;
                when ALU_ADDU => result := Src1  +  Src2;
                when ALU_SUB | ALU_SUBU =>
                                result := Src1  -  Src2;

                when ALU_AND => result := Src1 and Src2;
                when ALU_OR  => result := Src1 or  Src2;
                when ALU_NOR => result := Src1 nor Src2;
                when ALU_XOR => result := Src1 xor Src2;
                when ALU_LU  => result := half(Src2) & X"0000";

                when ALU_SLL => result := Src1 sll vtou(Src2);
                when ALU_SRL => result := Src1 srl vtou(Src2);
                when ALU_SRA => result := Src1 sra vtou(Src2);

                when ALU_MULT | ALU_MULTU | ALU_DIV | ALU_DIVU =>
                    -- Interesting read: http://yarchive.net/comp/mips_exceptions.html
                    -- TL;DR: No arithmetic division errors on a MIPS R3000
                    --trap <= TRAP_UNIMPLEMENTED; -- FIXME!
                    null;

                when ALU_MFHI => result := HI;
                when ALU_MFLO => result := LO;

                -- These weren't part of the MIPS R3000 AFAIK, implemented here anyway.
                when ALU_MTHI => HI <= Src1;
                when ALU_MTLO => LO <= Src2;
                
                when ALU_SLT  =>
                    result := (31 downto 1 => '0')
                            & high_if(vtoi(Src1) < vtoi(Src2));
                when ALU_SLTU => result := (31 downto 1 => '0') & high_if(Src1 < Src2);

                -- Some (all?) of these could be optimized away (e.g. EQ can be done with SUB)
                when ALU_EQ  => result := (31 downto 1 => '0') & low_if(Src1  = Src2);
                when ALU_NE  => result := (31 downto 1 => '0') & low_if(Src1 /= Src2);

                when ALU_LEZ => result := (31 downto 1 => '0')
                                        & low_if(vtoi(Src1) <= 0);
                when ALU_LTZ => result := (31 downto 1 => '0')
                                        & low_if(vtoi(Src1) <  0);
                when ALU_GTZ => result := (31 downto 1 => '0')
                                        & low_if(vtoi(Src1) >  0);
                when ALU_GEZ => result := (31 downto 1 => '0')
                                        & low_if(vtoi(Src1) >= 0);

                when others => null; -- trap <= TRAP_UNIMPLEMENTED; -- FIXME!
            end case;

            if result = X"0000_0000" then
                Zero <= '1';
            else
                Zero <= '0';
            end if;
            AluResult <= result;
        end process;

end behav;

