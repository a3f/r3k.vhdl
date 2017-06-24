library ieee;
use ieee.std_logic_1164.all;

entitiy memToRegMux is 
	port (
	MemtoReg: in ctrl_t;
	aluResult : in std_logic_vector(31 downto 0)
	memReadData : in std_logic_vector(31 downto 0)
	output : out std_logic_vector(31 downto 0)
	);

architecture behav of memToRegMux is
	begin
		output <= medReadData when MemtoReg => '1' else alu;
end architecture behav;
	
		
