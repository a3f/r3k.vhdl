library ieee;
use ieee.std_logic_1164.all;

entity returnAddrMux is 
	port (
	returnAddrControl: in ctrl_t;
	returnAddrReg : in addr_t;
	regDstMux : in addr_t;
	output : out word_t
	);
end entity;

architecture behav of returnAddrMux is
	begin
		output <= returnAddrReg when returnAddrControl = '1' else regDstMux;
end architecture behav;
	
		
