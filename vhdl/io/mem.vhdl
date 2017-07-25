library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.memory_map.all;
use work.txt_utils.all;
use work.utils.all;

entity mem is
    generic (ROM : string := ""; RAMSIZE : positive := 32);
    port(
            addr : in addr_t;
            din : in word_t;
            dout : out word_t;
            size : in ctrl_memwidth_t;
            wr : in std_logic;
            clk : in std_logic;

            -- VGA I/O
            vgaclk, rst : in std_logic;
            r, g, b : out std_logic_vector (3 downto 0);

            hsync, vsync : out std_logic;

            -- LEDs
            leds : out std_logic_vector(7 downto 0);
            -- Push buttons
            buttons : in std_logic_vector(3 downto 0);
            -- DIP Switch IO
            switch : in std_logic_vector(7 downto 0)
    );
end mem;

architecture struct of mem is
    component addrdec is
   port( A  : in  addr_t;
         cs : out memchipsel_t);
    end component;

    component rom_default is port (a: in addr_t; z: out word_t; en: in ctrl_t); end component;
    component rom_vga is port (a: in addr_t; z: out word_t; en: in ctrl_t); end component;

    signal cs : memchipsel_t;
    signal instr : instruction_t;

   component async_ram is
       generic (
       MEMSIZE :integer := RAMSIZE
   );
   port (
            address : in addr_t;
            din     : in word_t;
            dout    : out word_t;
            size    : in ctrl_memwidth_t;
            wr      : in std_logic;
            en      : in    std_logic
        );
   end component;

   component mmio_vga is
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

            -- VGA I/O
               vgaclk, rst : in std_logic;
               r, g, b : out std_logic_vector (3 downto 0);

               hsync, vsync : out std_logic
   );
   end component;

   component mmio_leds is
    port (
        -- static
             addr : in addr_t;
             din: in word_t;
             dout: out word_t;
             size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
             wr      : in std_logic;
             en      : in    std_logic;
             clk : in std_logic;
             trap : out traps_t := TRAP_NONE;
        -- leds
             leds : out std_logic_vector(7 downto 0)
         );
   end component;

   component mmio_buttons is
    port (
        -- static
             addr : in addr_t;
             din: in word_t;
             dout: out word_t;
             size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
             wr      : in std_logic;
             en      : in    std_logic;
             clk : in std_logic;
             trap : out traps_t := TRAP_NONE;

        -- push buttons
             buttons : in std_logic_vector(3 downto 0)
         );
   end component;

   component mmio_tsc is
    port (
        -- static
             addr : in addr_t;
             din: in word_t;
             dout: out word_t;
             size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
             wr      : in std_logic;
             en      : in    std_logic;
             clk : in std_logic;
             trap : out traps_t := TRAP_NONE
         );
   end component;

   component mmio_dipswitch is
    port (
        -- static
             addr : in addr_t;
             din: in word_t;
             dout: out word_t;
             size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
             wr      : in std_logic;
             en      : in    std_logic;
             clk : in std_logic;
             trap : out traps_t := TRAP_NONE;

        -- dip switch
             switch : in std_logic_vector(7 downto 0)
         );
   end component;

   signal vga_en : ctrl_t := '0';
begin
    addrdec_instance : addrdec port map(addr, cs);

    vga_rom_selector: if ROM = "VGA" or ROM = "vga" generate
    begin
        instruction_mem : rom_vga
            port map(addr, dout, cs(mmap_rom));
    end generate;
     default_rom_selector: if ROM = "" generate
    begin
        instruction_mem : rom_default
            port map(addr, dout, cs(mmap_rom));
    end generate;

    -- It's possible that this isn't interferrable. If so, maybe use synchronous RAM instead?
    working_ram : async_ram
        port map(address => addr,
                 din => din,
                 dout => dout,
                 size => size,
                 wr => wr,
                 en => cs(mmap_ram)
         );

    vga_en <= cs(mmap_vram) or cs(mmap_videocfg);

    vga : mmio_vga
        port map(addr => addr,
                 din  => din,
                 dout => dout,
                 size => size,
                 wr   => wr,
                 en   => vga_en,
                 memclk => clk,
                 trap => open,
                 
                 vgaclk => vgaclk,
                 rst => rst,
                 r => r, g => g, b => b,
                 hsync => hsync, vsync => vsync
        );

   ledbank: mmio_leds
        port map(addr => addr,
                 din  => din,
                 dout => dout,
                 size => size,
                 wr   => wr,
                 en   => cs(mmap_led),
                 clk => clk,
                 trap => open,

                 leds => leds
        );

   pushbuttons : mmio_buttons
        port map(addr => addr,
                 din  => din,
                 dout => dout,
                 size => size,
                 wr   => wr,
                 en   => cs(mmap_push),
                 clk => clk,
                 trap => open,

                 buttons => buttons
        );

   timestamp_counter : mmio_tsc
    port map(addr => addr,
             din  => din,
             dout => dout,
             size => size,
             wr   => wr,
             en   => cs(mmap_tsc),
             clk => clk,
             trap => open
        );

   dipswitch: mmio_dipswitch
    port map(addr => addr,
             din  => din,
             dout => dout,
             size => size,
             wr   => wr,
             en   => cs(mmap_dipswitch),
             clk => clk,
             trap => open,
             switch => switch
         );
end struct;

