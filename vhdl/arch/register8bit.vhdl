library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;


entity register8bit is
port(
    data   : in std_logic_vector(7 downto 0);
    enable  : in std_logic; -- load/enable.
    clr : in std_logic; -- async. clear.
    clk : in std_logic; -- clock.
    output   : out std_logic_vector(7 downto 0) -- output.
);
end register8bit;

architecture behav of register8bit is

begin
    process(clk, clr)
    begin
        if clr = '1' then
            output <= x"00";
        elsif rising_edge(clk) then
            if enable = '1' then
                output <= data;
            end if;
        end if;
    end process;
end behav;
