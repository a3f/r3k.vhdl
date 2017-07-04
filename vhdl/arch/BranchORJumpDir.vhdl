library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity BranchORJumpDir is
    port (
             Branch: in ctrl_t;
             JumpDir : in ctrl_t;
             output : out ctrl_t
         );
end BranchORJumpDir;

architecture behav of BranchORJumpDir is
begin

    process(Branch, JumpDir)
    begin
        if ((Branch='1') and (JumpDir='1')) then
            output <= '0';
        else
            output <= '1';
        end if;
    end process;
end behav;
