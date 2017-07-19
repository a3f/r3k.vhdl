library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;


entity register16bit is
port(
    data   : in std_logic_vector(15 downto 0);
    enable  : in std_logic; -- load/enable.
    clr : in std_logic; -- async. clear.
    clk : in std_logic; -- clock.
    output   : out std_logic_vector(15 downto 0) -- output.
);
end register16bit;

architecture behav of register16bit is

begin
    process(clk, clr)
    begin
        if clr = '1' then
            output <= x"0000";
        elsif rising_edge(clk) then
            if enable = '1' then
                output <= data;
            end if;
        end if;
    end process;
end behav;