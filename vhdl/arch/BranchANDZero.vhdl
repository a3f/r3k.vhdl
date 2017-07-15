library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity BranchANDZero is
    port (
             Branch: in ctrl_t;
             isZero : in ctrl_t;
             output : out ctrl_t
         );
end BranchANDZero;

architecture behav of BranchANDZero is
begin

    process(Branch, isZero)
    begin
        if ((Branch='1') and (isZero='1')) then
            output <= '1';
        else
            output <= '0';
        end if;
    end process;

end behav;
