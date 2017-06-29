library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity ALUSrcMux is 
	port (
	ALUSrc: in ctrl_t;
	reg2data : in word_t;
	-- Instruction 15-0 Address/Immediate
	immediate : in word_t;
	output : out word_t
	);
end entity;

architecture behav of ALUSrcMux is
	begin
		output <= immediate when ALUSrc = '1' else reg2Data;
end architecture behav;
	
		
