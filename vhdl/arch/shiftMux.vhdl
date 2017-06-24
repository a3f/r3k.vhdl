library ieee;
use ieee.std_logic_1164.all;

entitiy shiftMux is 
	port (
	Shift: in ctrl_t;
	reg1data : in std_logic_vector(31 downto 0)
	shamt : in std_logic_vector(31 downto 0) --Instruction 0-6
	output : out std_logic_vector(31 downto 0)
	);

architecture behav of shiftMux is
	begin
		output <= shamt when Shift => '1' else reg1Data;
end architecture behav;
	
		
