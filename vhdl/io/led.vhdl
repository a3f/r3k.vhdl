library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity leds is
		port (
		-- static
		addr : in addr_t;
		din: in word_t;
		dout: out word_t;
		size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
		wr : in std_logic;
		clk : in std_logic;
		-- leds
		leds : out std_logic_vector(7 downto 0)
		);
		end leds ;
		
architecture leds of leds is
	constant reading : std_logic := '0';
	constant writing : std_logic := '1';

begin
    dout <= HI_Z;
process(clk) begin
		if rising_edge(clk) and size /= "00" then
			case wr is
				when reading => dout <= (others => '1');
				when writing => leds <= din(7 downto 0);
				when others => null;
			end case;
		end if;
	end process;
 end leds;
