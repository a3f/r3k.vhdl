library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
--use work.shader.all;

entity vga_controller is
port(
		-- static
		addr : out addr_t;
		din: out word_t;
		dout: in word_t;
		size : out std_logic_vector(1 downto 0); -- is also enable when = "00"
		wr : out std_logic;
		memclk : out std_logic;

        -- stuff
        vgaclk, rstclk : in std_logic;
        r, g, b : out std_logic_vector (3 downto 0);

        hsync, vsync : out std_logic
    );
end vga_controller;
architecture struct of vga_controller is

    component sync
    port (
         clk : in std_logic;
         hsync, vsync : out std_logic;
         retracing : out std_logic;
         col : out std_logic_vector (9 downto 0); -- 640 = 10_1000_0000b
         row : out std_logic_vector (8 downto 0) -- 480 = 1_1110_0000b
    );
    end component;

    component shader
    port (
          x : in std_logic_vector (9 downto 0); -- 640 = 10_1000_0000b
          y : in std_logic_vector (8 downto 0); -- 480 = 1_1110_0000b
          retracing : in std_logic;

          r, g, b : out std_logic_vector (3 downto 0)
    );
    end component;	

    component dualport_bram

        generic (
                    WORD_WIDTH    : integer := 72;
                    ADDR_WIDTH    : integer := 10
                );
        port (
    -- Port A
                 a_clk   : in  std_logic;
                 a_wr    : in  std_logic;
                 a_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
                 a_din   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
                 a_dout  : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- Port B
                 b_clk   : in  std_logic;
                 b_wr    : in  std_logic;
                 b_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
                 b_din   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
                 b_dout  : out std_logic_vector(WORD_WIDTH-1 downto 0)
             );
    end component;


signal retracing : std_logic;
signal row : std_logic_vector (8 downto 0);
signal col : std_logic_vector (9 downto 0);

begin
--  Component instantiation.
inst_sync:     sync     port map (clk => vgaclk, hsync => hsync, vsync => vsync, retracing => retracing, col => col, row => row);
--inst_vram:     dualport_bram
--generic map(WORD_WIDTH => 32, ADDR_WIDTH => 32)
--port map (clk => memclk, wr => wr, wraddr => addr, rdaddr => rdaddr, din => din, dout => video);

--inst_shader: shader
    --port map (col => col, row => row, retracing => retracing, r => r, g => g, b => b); --, memclk => memclk, addr => rdaddr, din, dout, size, wr);

end struct;


