library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dipswitch is
		port (
		-- static
		addr : in addr_t;
		din: in word_t;
		dout: out word_t;
		size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
		wr : in std_logic;
		clk : in std_logic;
		-- leds
		switch : out std_logic_vector(7 downto 0)
		);
end dipswitch;
		
architecture behav of dipswitch is
	constant reading : std_logic := '0';

begin process(clk) begin
		if rising_edge(clk) and size /= "00" then
			case wr is
				when reading => dout <= switch;
				when others => null;
			end case;
		end if;
	end process;
end;
