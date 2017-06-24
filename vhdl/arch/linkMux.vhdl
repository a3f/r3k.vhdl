library ieee;
use ieee.std_logic_1164.all;

entity linkMux is 
	port (
	Link : in ctrl_t;
	pc : in addr_t;
	memToRegMux: in word_t;
	output: out word_t
	);
end entity;

architecture behav of linkMux is
	begin
		output <= pc when Link = '1' else memToRegMux;
end architecture behav;