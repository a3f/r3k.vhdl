library ieee;
use ieee.std_logic_1164.all;

entitiy JumpDirMux is 
	port (
	JumpDir: in ctrl_t;
	jumpAddr : in std_logic_vector(31 downto 0)
	BranchMux : in std_logic_vector(31 downto 0) 
	output : out std_logic_vector(31 downto 0)
	);

architecture behav of JumpDirMux is
	begin
		output <= jumpAddr when JumpDir => '1' else BranchMux;
end architecture behav;
