library ieee;
use ieee.std_logic_1164.all;

entitiy BranchMux is 
	port (
	BranchANDZero: in ctrl_t;
	ALUresult : in std_logic_vector(31 downto 0)
	pc : in std_logic_vector(31 downto 0) 
	output : out std_logic_vector(31 downto 0)
	);

architecture behav of BranchMux is
	begin
		output <= ALUresult when BranchANDZero => '1' else pc;
end architecture behav;
	
		
