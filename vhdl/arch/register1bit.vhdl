library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;


entity register1bit is
port(
    data   : in std_logic;
    enable  : in std_logic; -- load/enable.
    clr : in std_logic; -- async. clear.
    clk : in std_logic; -- clock.
    output   : out std_logic -- output.
);
end register1bit;

architecture behav of register1bit is

begin
    process(clk, clr)
    begin
        if clr = '1' then
            output <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                output <= data;
            end if;
        end if;
    end process;
end behav;
