library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity shiftMux is 
	port (
	Shift: in ctrl_t;
	reg1data : in word_t;
	shamt : in word_t; -- Instruction 0-6 Zero-extended
	output : out word_t
	);
end entity;

architecture behav of shiftMux is
	begin
		output <= shamt when Shift = '1' else reg1Data;
end architecture behav;
	
		
