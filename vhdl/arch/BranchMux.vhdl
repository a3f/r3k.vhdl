library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity BranchMux is 
	port (
	BranchANDZero: in ctrl_t;
	ALUresult : in word_t;
	pc : in addr_t;
	output : out word_t
	);
end entity;

architecture behav of BranchMux is
	begin
		output <= ALUresult when BranchANDZero = '1' else pc;
end architecture behav;
	
		
