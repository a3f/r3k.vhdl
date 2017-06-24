library ieee;
use ieee.std_logic_1164.all;

entitiy JumpRegMux is 
	port (
	JumpReg: in ctrl_t;
	reg1data : in std_logic_vector(31 downto 0)
	JumpDirMux : in std_logic_vector(31 downto 0) 
	output : out std_logic_vector(31 downto 0)
	);

architecture behav of JumpRegMux is
	begin
		output <= reg1data when JumpReg => '1' else JumpDirMux;
end architecture behav;
