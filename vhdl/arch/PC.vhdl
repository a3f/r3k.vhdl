library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity PC is
    port (
             next_addr : in addr_t;
             clk : in std_logic;
             addr : out addr_t
         );
end PC;

architecture behav of PC is
    signal counter : addr_t := X"0000_0000"; -- X"bfc0_0000";

begin process(next_addr, clk)
begin
    if rising_edge(clk) then
        counter <= next_addr;
    end if;
end process;
addr <= counter;
end behav;
