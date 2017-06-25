library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity JumpRegMux is 
	port (
	JumpReg: in ctrl_t;
	reg1data : in word_t;
	JumpDirMux : in word_t;
	output : out word_t
	);
end entity;

architecture behav of JumpRegMux is
	begin
		output <= reg1data when JumpReg = '1' else JumpDirMux;
end architecture behav;
