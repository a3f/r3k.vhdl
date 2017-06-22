library ieee;
use ieee.std_logic_1164.all;

entitiy regDstMux is 
	port (
	RegDst: in ctrl_t;
	rt : in std_logic_vector(4 downto 0) --Instruction 20-16
	rd : in std_logic_vector(4 downto 0) --Instruction 15-11
	output : out std_logic_vector(4 downto 0)
	);

architecture behav of regDstMux is
	begin
		output <= rd when RegDst => '1' else rt;
end architecture behav;
	
		
