library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity shiftLeftImm is 
	port (
	imm: in std_logic_vector (31 downto 0);
	output: out std_logic_vector (31 downto 0)
	);
end entity;

architecture behav of shiftLeftImm is
	begin
		output <= std_logic_vector(shift_left(unsigned(imm), 2));
end architecture behav;
