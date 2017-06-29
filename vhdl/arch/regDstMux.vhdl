library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity regDstMux is 
	port (
	RegDst: in ctrl_t;
	rt : in reg_t; --Instruction 20-16
	rd : in reg_t; --Instruction 15-11
	output : out reg_t 
	);
end regDstMux;

architecture behav of regDstMux is
	begin
		output <= rd when RegDst = '1' else rt;
end architecture behav;
	
		
