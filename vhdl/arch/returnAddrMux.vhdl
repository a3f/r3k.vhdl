library ieee;
use ieee.std_logic_1164.all;

entitiy returnAddrMux is 
	port (
	returnAddrControl: in ctrl_t;
	returnAddrReg : in std_logic_vector(31 downto 0)
	regDstMux : in std_logic_vector(31 downto 0)
	output : out std_logic_vector(31 downto 0)
	);

architecture behav of returnAddrMux is
	begin
		output <= returnAddrReg when returnAddrControl => '1' else regDstMux;
end architecture behav;
	
		
