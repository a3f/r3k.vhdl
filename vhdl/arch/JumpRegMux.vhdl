library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity JumpRegMux is 
	port (
	JumpReg: in ctrl_t;
	reg1data : in addr_t;
	JumpDirMux : in addr_t;
	output : out addr_t
	);
end entity;

architecture behav of JumpRegMux is
	begin
		output <= reg1data when JumpReg = '1' else JumpDirMux;
end architecture behav;
