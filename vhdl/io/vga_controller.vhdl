library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;
--use work.shader.all;

entity mmio_vga is
port(
        -- static
        addr : in addr_t;
        din: in word_t;
        dout: out word_t;
        size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
        wr : in std_logic;
        en : in std_logic;
        memclk : in std_logic;
        trap : out traps_t := TRAP_NONE;

        -- I/O
        vgaclk, rst : in std_logic;
        r, g, b : out std_logic_vector (3 downto 0);

        hsync, vsync : out std_logic
    );
end mmio_vga;
architecture mmio of mmio_vga is

    component sync
    port (
         clk : in std_logic;
         en : in std_logic;
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
            a_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            a_din   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
            a_dout  : out std_logic_vector(WORD_WIDTH-1 downto 0);
            a_wr    : in  std_logic;
            a_clk   : in  std_logic;

            -- Port B
            b_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            b_din   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
            b_dout  : out std_logic_vector(WORD_WIDTH-1 downto 0);
            b_wr    : in  std_logic;
            b_clk   : in  std_logic
        );
    end component;


constant reading : std_logic := '0';
constant writing : std_logic := '1';

signal retracing : std_logic;
signal row : std_logic_vector (8 downto 0);
signal col : std_logic_vector (9 downto 0);

subtype vga_sync_t   is std_logic_vector(1 downto 0);
subtype vga_shader_t is std_logic_vector(1 downto 0);


constant VGA_SYNC_NONE      : vga_sync_t   := (others => '0');
constant VGA_SHADER_NONE    : vga_shader_t := (others => '0');
constant VGA_SYNC_640_480   : vga_sync_t   := "01";
constant VGA_SHADER_640_480 : vga_shader_t := "01";
type vga_mode_t is record sync : vga_sync_t; shader : vga_shader_t; end record;
type vga_mode_table_t is array (natural range <>) of vga_mode_t;
constant modes : vga_mode_table_t := (
    (VGA_SYNC_NONE,    VGA_SHADER_NONE),
    (VGA_SYNC_640_480, VGA_SHADER_640_480),
    (VGA_SYNC_NONE,    VGA_SHADER_NONE)
);


signal mode_idx : std_logic_vector(1 downto 0) := "01";

signal access_vram : std_logic := '0';

signal vram_din, vram_dout, data_out : word_t;
signal vram_addr : word_t;
signal writing_vram : ctrl_t := '0';

begin
    --  FIXME: make shader selectable
    --inst_sync_640_480:     sync     port map (clk => vgaclk, en => '1', hsync => hsync, vsync => vsync, retracing => retracing, col => col, row => row);
    inst_vram:     dualport_bram
generic map(WORD_WIDTH => 8, ADDR_WIDTH => 8)
-- TODO ISE has a Block RAM generator, that generates VHDL. Generate the VHDL for the RAM with it and plug it in here
--port map (clk => memclk, wr => wr, wraddr => addr, rdaddr => rdaddr, din => din, dout => video);
port map(
            a_addr => vram_addr(7 downto 0),
            a_din => vram_din(7 downto 0),
            a_dout => vram_dout(7 downto 0),
            a_wr => writing_vram,
            a_clk => memclk,

            b_addr => X"00",
            b_din => X"00",
            b_dout => open,
            b_wr => '0',
            b_clk => vgaclk
    );

    writing_vram <= wr and access_vram and en;
    vram_din <= din when access_vram = '1';
    vram_addr <= addr when access_vram = '1';

--inst_shader: shader
    --port map (col => col, row => row, retracing => retracing, r => r, g => g, b => b); --, memclk => memclk, addr => rdaddr, din, dout, size, wr);
    dout <= data_out  when en = '1' and wr = '0' and access_vram = '0' else
            vram_dout when en = '1' and wr = '0' and access_vram = '1' else HI_Z;

    process(memclk)
    begin
        if rising_edge(memclk) and en = '1' and size /= "00" then
            case addr(31 downto 24) is
                -- 0x14xx_xxxx is IO configuration space
                -- TODO use work.memory_map.mmap instead of hardcoded address base
                when X"14"=>
                    access_vram <= '0';
                    case addr(3 downto 0) is
                    when X"0" => -- vga_mode
                        if wr = writing then
                            mode_idx <= din(mode_idx'High downto mode_idx'Low);
                        else
                            zeroextend(data_out, mode_idx);

                        end if;
                    when others => null;
                end case;
                -- 0x10xx_xxxx is IO memory space
                when X"10" =>
                    access_vram <= '1';
                -- forward to BRAM
                    null;
                when others => trap <= TRAP_SEGFAULT;
            end case;
        end if;
    end process;
end mmio;
