library ieee;
use ieee.std_logic_1164.all;

entity JumpDirMux is 
	port (
	JumpDir: in ctrl_t;
	jumpAddr : in addr_t;
	BranchMux : in word_t;
	output : out word_t
	);
end entity;

architecture behav of JumpDirMux is
	begin
		output <= jumpAddr when JumpDir = '1' else BranchMux;
end architecture behav;
