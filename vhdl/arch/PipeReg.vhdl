library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;


entity PipeReg is
generic ( BITS : natural := 32);
port(
    data   : in std_logic_vector(BITS-1 downto 0);
    enable  : in std_logic; -- load/enable.
    clr : in std_logic; -- async. clear.
    clk : in std_logic; -- clock.
    output   : out std_logic_vector(BITS-1 downto 0) -- output.
);
end PipeReg;

architecture behav of PipeReg is

begin
    process(clk, clr)
    begin
        if clr = '1' then
            output <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                output <= data;
            end if;
        end if;
    end process;
end behav;

