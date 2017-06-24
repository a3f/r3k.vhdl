library ieee;
use ieee.std_logic_1164.all;

entity ALUSrcMux is 
	port (
	ALUSrc: in ctrl_t;
	reg2data : in word_t;
	-- Instruction 15-0 Address/Immediate
	addr : in addr_t;
	output : out word_t
	);
end entity;

architecture behav of ALUSrcMux is
	begin
		output <= addr when ALUSrc = '1' else reg2Data;
end architecture behav;
	
		
