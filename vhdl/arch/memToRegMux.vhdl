library ieee;
use ieee.std_logic_1164.all;

entity memToRegMux is 
	port (
	MemtoReg: in ctrl_t;
	aluResult : in word_t;
	memReadData : in word_t;
	output : out word_t
	);
end entity;

architecture behav of memToRegMux is
	begin
		output <= medReadData when MemtoReg = '1' else alu;
end architecture behav;
	
		
