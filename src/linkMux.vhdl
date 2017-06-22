library ieee;
use ieee.std_logic_1164.all;

entitiy linkMux is 
	port (
	Link : in ctrl_t;
	pc : in std_logic_vector(31 downto 0);
	memToRegMux: in std_logic_vector(31 downto 0);
	output: out std_logic_vector(31 downto 0)
	);

architecture behav of linkMux is
	begin
		output <= pc when Link => '1' else memToRegMux;
end architecture behav;
