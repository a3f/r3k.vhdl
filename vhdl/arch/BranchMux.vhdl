library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity BranchMux is 
	port (
	BranchANDZero: in ctrl_t;
	AddrALUresult: in addr_t;
	addr : in addr_t;
	output : out addr_t
	);
end entity;

architecture behav of BranchMux is
	begin
		output <= AddrALUresult when BranchANDZero = '1' else addr;
end architecture behav;
	
		
