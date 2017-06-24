library ieee;
use ieee.std_logic_1164.all;

entitiy regDstMux is 
	port (
	RegDst: in ctrl_t;
	rt : in reg_t; --Instruction 20-16
	rd : in reg_t; --Instruction 15-11
	output : out reg_t 
	);

architecture behav of regDstMux is
	begin
		output <= rd when RegDst => '1' else rt;
end architecture behav;
	
		
