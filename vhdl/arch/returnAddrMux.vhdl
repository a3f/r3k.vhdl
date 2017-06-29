library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity returnAddrMux is 
	port (
	returnAddrControl: in ctrl_t;
	returnAddrReg : in reg_t;
	regDstMux : in reg_t;
	output : out reg_t
	);
end entity;

architecture behav of returnAddrMux is
	begin
		output <= returnAddrReg when returnAddrControl = '1' else regDstMux;
end architecture behav;
	
		
