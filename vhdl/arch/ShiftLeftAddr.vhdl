library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity shiftLeftAddr is
    port (
             addr: in std_logic_vector (25 downto 0);
             output: out std_logic_vector (28 downto 0)
         );
end entity;

architecture behav of shiftLeftAddr is
begin
    output <= std_logic_vector(shift_left(unsigned(addr), 2));
end architecture behav;
