library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.color_util.all;
use work.utils.all;
use work.txt_utils.all;

entity vram is
    port (
          x : in std_logic_vector (9 downto 0); -- 640 = 10_1000_0000b
          y : in std_logic_vector (8 downto 0); -- 480 = 1_1110_0000b
          retracing : in std_logic;

          -- I/O
          r, g, b : out std_logic_vector (3 downto 0);

          -- Bus access to VRAM
          bus_addr  : in  addr_t;
          bus_din   : in  word_t;
          bus_dout  : out word_t;
          bus_wr    : in  std_logic;
          bus_clk   : in  std_logic
    );
end entity vram;


architecture behavioral of vram is
    constant h_display  : integer := 640;
    constant v_display  : integer := 480;

    type vram_t is array (0 to 7) of byte_t;
    shared variable mem : vram_t;

    signal first_byte : byte_t;
begin
    process(x, y, retracing)
        variable color : rgb_t := BLACK;
    begin
   		if retracing = '1' then
            color := BLACK;
		else

            --color.r := x(9 downto 6);
            --color.g := y(8 downto 5);
            --color.b := "0000";
            color.r := mem(0)(7 downto 5) & B"00000";
            color.g := mem(0)(4 downto 2) & B"00000";
            color.b := mem(0)(1 downto 0) & B"000000";

            if x = "0000000000" or y = "000000000" or x = "1001111111" or y = "111011111" then
                color := WHITE;
            end if;
        end if;

        (r, g, b) <= color;
    end process;

    first_byte <= mem(0);

    process(bus_clk)
    begin
        if(rising_edge(bus_clk)) then
            if(bus_wr = '1') then
                printf(ANSI_GREEN & "writing %s to %s\n", bus_din, bus_addr);
                mem(vtou(bus_addr)) := bus_din(7 downto 0);
            end if;
            bus_dout(7 downto 0) <= mem(vtou(bus_addr));
        end if;
    end process;
end architecture;

