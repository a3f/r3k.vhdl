library ieee;
use ieee.std_logic_1164.all;

entitiy ALUSrcMux is 
	port (
	ALUSrc: in ctrl_t;
	reg2data : in std_logic_vector(31 downto 0)
	-- Instruction 15-0 Address/Immediate
	addr : in std_logic_vector(31 downto 0) 
	output : out std_logic_vector(31 downto 0)
	);

architecture behav of ALUSrcMux is
	begin
		output <= addr when ALUSrc => '1' else reg2Data;
end architecture behav;
	
		
