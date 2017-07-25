library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;

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

    component vram
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
    end component;

constant reading : std_logic := '0';
constant writing : std_logic := '1';

signal retracing : std_logic;
signal row : std_logic_vector (8 downto 0);
signal col : std_logic_vector (9 downto 0);

-- XXX The original idea was having multiple VGA modes
-- Each VGA mode consists of a tuple of a Sync mode
-- which defines the control signals and thereby the resolution
-- and a shader, which accesses the VRAM in a specific way
-- e.g. you can pair a 1024x768 sync with a shader that use a color palette
-- While this would be cleaner, I think there's no way around having the
-- shader work at double the VGA frequency, so it may access the VRAM.
-- As I got no time for that, the mode code is commented out.

--subtype vga_sync_t   is std_logic_vector(1 downto 0);
--subtype vga_shader_t is std_logic_vector(1 downto 0);


--constant VGA_SYNC_NONE      : vga_sync_t   := (others => '0');
--constant VGA_VRAM_NONE    : vga_shader_t := (others => '0');
--constant VGA_SYNC_640_480   : vga_sync_t   := "01";
--constant VGA_SHADER_640_480 : vga_shader_t := "01";
--type vga_mode_t is record sync : vga_sync_t; shader : vga_shader_t; end record;
--type vga_mode_table_t is array (natural range <>) of vga_mode_t;
--constant modes : vga_mode_table_t := (
    --(VGA_SYNC_NONE,    VGA_SHADER_NONE),
    --(VGA_SYNC_640_480, VGA_SHADER_640_480),
    --(VGA_SYNC_NONE,    VGA_SHADER_NONE)
--);


signal mode_idx : std_logic_vector(1 downto 0) := "01";

signal bus_access_vram : std_logic := '0';

signal bus_vram_din, bus_vram_dout, data_out : word_t;
signal bus_vram_addr : word_t;
signal bus_writing_vram : ctrl_t := '0';

begin
    --  FIXME: make shader selectable
    inst_sync_640_480:     sync     port map (clk => vgaclk, en => '1', hsync => hsync, vsync => vsync, retracing => retracing, col => col, row => row);

    --inst_vram:     dualport_bram generic map(WORD_WIDTH => 8, ADDR_WIDTH => 8)

    bus_writing_vram <= wr and bus_access_vram and en;
    bus_vram_din <= din when bus_access_vram = '1';
    bus_vram_addr <= addr when bus_access_vram = '1';

    inst_vram: vram
    port map (x => col, y => row, retracing => retracing,
              r => r, g => g, b => b,

              bus_addr => bus_vram_addr,
              bus_din =>  bus_vram_din,
              bus_dout => bus_vram_dout,
              bus_wr =>   bus_writing_vram,
              bus_clk =>  memclk
      );
    dout <= data_out  when en = '1' and wr = '0' and bus_access_vram = '0' else
            bus_vram_dout when en = '1' and wr = '0' and bus_access_vram = '1' else HI_Z;

    process(memclk)
    begin
        if rising_edge(memclk) and en = '1' and size /= "00" then
            case addr(31 downto 24) is
                -- 0x14xx_xxxx is IO configuration space
                -- TODO use work.memory_map.mmap instead of hardcoded address base
                when X"14"=>
                    bus_access_vram <= '0';
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
                when X"10" => -- forward to BRAM
                    bus_access_vram <= '1';
                when others => trap <= TRAP_SEGFAULT;
            end case;
        end if;
    end process;
end mmio;
