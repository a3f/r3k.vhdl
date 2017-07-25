-- A DCM block would be more accurate, right?
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity clkdivider is
    port (
        ticks : in natural;
        bigclk : in std_logic;
        rst : in std_logic;

        smallclk : out std_logic
    );
end;

architecture behav of clkdivider is
begin
    clkdivider: process(bigclk, rst, ticks)
        variable i : natural := 0;
        variable pulse : std_logic := '0';
    begin

        if rst = '1' then
            i := 0;
            pulse := '0';
        elsif rising_edge(bigclk) then
            i := i + 1;
            if i >= ticks then
                pulse := not pulse;
                i := 0;
            end if;
        end if;

        smallclk <= pulse;
    end process;
end behav;

