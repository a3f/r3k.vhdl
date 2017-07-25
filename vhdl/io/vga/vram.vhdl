library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.color_util.all;
use work.utils.all;
use work.txt_utils.all;
use work.memory_map.all;

entity vram is
    generic ( MEM_SIZE : natural := 300;  PIXEL_SIZE : natural := 32 );
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
    constant x_pixels : natural := h_display / PIXEL_SIZE; -- 20
    constant y_pixels : natural := v_display / PIXEL_SIZE; -- 15

    type vram_t is array (0 to MEM_SIZE-1) of byte_t;
    signal mem : vram_t;

    signal byte00 : byte_t;
    signal byte01 : byte_t;
    signal byte02 : byte_t;
    signal byte03 : byte_t;
    signal byte04 : byte_t;
    signal byte05 : byte_t;
    signal byte06 : byte_t;
    signal byte07 : byte_t;
    signal byte08 : byte_t;
    signal byte09 : byte_t;
    signal byte10 : byte_t;
    signal byte11 : byte_t;
    signal byte12 : byte_t;
    signal byte13 : byte_t;
    signal byte14 : byte_t;
    signal byte15 : byte_t;
    signal byte16 : byte_t;
    signal byte17 : byte_t;
    signal byte18 : byte_t;
    signal byte19 : byte_t;
    signal byte150 : byte_t;
    signal byte280 : byte_t;
    signal byte299 : byte_t;
begin
    process(x, y, retracing)

        variable color : rgb_t := BLACK;
        variable x_int, y_int : natural;
        variable row, col : natural;
        variable offset : natural;

    begin
   		if retracing = '1' then
            color := BLACK;
		else
            x_int := to_integer(unsigned(x(9 downto 5)));
            y_int := to_integer(unsigned(y(8 downto 5)));

            --color.r := x(9 downto 6);
            --color.g := y(8 downto 5);
            --color.b := "0000";
            offset := x_int + y_int * x_pixels;

            color.r := mem(offset)(7 downto 5) & B"0";
            color.g := mem(offset)(4 downto 2) & B"0";
            color.b := mem(offset)(1 downto 0) & B"00";

            if x = "0000000000" or y = "000000000" or x = "1001111111" or y = "111011111" then
                color := WHITE;
            end if;
        end if;

        (r, g, b) <= color;
    end process;

    byte00 <= mem(0);
    byte01 <= mem(1);
    byte02 <= mem(2);
    byte03 <= mem(3);
    byte04 <= mem(4);
    byte05 <= mem(5);
    byte06 <= mem(6);
    byte07 <= mem(7);
    byte08 <= mem(8);
    byte09 <= mem(9);
    byte10 <= mem(10);
    byte11 <= mem(11);
    byte12 <= mem(12);
    byte13 <= mem(13);
    byte14 <= mem(14);
    byte15 <= mem(15);
    byte16 <= mem(16);
    byte17 <= mem(17);
    byte18 <= mem(18);
    byte19 <= mem(19);
    byte150 <= mem(150);
    byte280 <= mem(280);
    byte299 <= mem(299);

    process(bus_clk)
    begin
        if(rising_edge(bus_clk)) then
            if(bus_wr = '1') then
                printf(ANSI_GREEN & "writing %s to %s\n", bus_din, bus_addr);
                mem(to_integer(unsigned(bus_addr and not mmap(mmap_vram).base))) <= bus_din(7 downto 0);
            end if;
            bus_dout(7 downto 0) <= mem(to_integer(unsigned(bus_addr and not mmap(mmap_vram).base)));
        end if;
    end process;
end architecture;

