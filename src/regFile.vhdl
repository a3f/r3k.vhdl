brary ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regFile is
		port (
		-- static
		readreg1 : in  std_logic_vector(4 downto 0);		
		readreg2 : in  std_logic_vector(4 downto 0);
		writereg: in std_logic_vector (4 downto 0);
		writedata: in std_logic_vector (31 downto 0);
		readData1 : out std_logic_vector (31 downto 0);
		readData2 : out std_logic_vector (31 downto 0);
		clk : in std_logic;
		regWrite : in std_logic;
		);
	end regFile ;
		
architecture leds of leds is


begin process(clk) begin

end regFile;
