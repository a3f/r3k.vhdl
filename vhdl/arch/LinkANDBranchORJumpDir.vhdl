library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity LinkANDBranchORJumpDir is
    port (
             BranchORJumpDir: in ctrl_t;
             Link : in ctrl_t;
             output : out ctrl_t
         );
end LinkANDBranchORJumpDir;

architecture behav of LinkANDBranchORJumpDir is
begin

    process(BranchORJumpDir, Link)
    begin
        if ((BranchORJumpDir='1') and (Link='1')) then
            output <= '1';
        else
            output <= '0';
        end if;
    end process;

end behav;


