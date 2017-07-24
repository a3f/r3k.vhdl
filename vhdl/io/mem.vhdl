library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.memory_map.all;
use work.txt_utils.all;
use work.utils.all;

entity mem is
    generic (RAMSIZE : positive := 32);
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

    component rom is
    port ( a: in std_logic_vector(31 downto 0);
           z: out std_logic_vector(31 downto 0);
           en : in std_logic
         );
    end component;

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

begin
    addrdec_instance : addrdec port map(addr, cs);

    instruction_mem : rom
        port map(addr, dout, cs(mmap_rom));

    -- It's possible that this isn't interferrable. If so, maybe use synchronous RAM instead?
    working_ram : async_ram
        port map(address => addr,
                 din => din,
                 dout => dout,
                 size => size,
                 wr => wr,
                 en => cs(mmap_ram)
         );

    vga : mmio_vga
        port map(addr => addr,
                 din  => din,
                 dout => dout,
                 size => size,
                 wr   => wr,
                 en   => '0',
                 memclk => '0',
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
                 en   => '0',
                 clk => '0',
                 trap => open,

                 leds => leds
        );

   pushbuttons : mmio_buttons
        port map(addr => addr,
                 din  => din,
                 dout => dout,
                 size => size,
                 wr   => wr,
                 en   => '0',
                 clk => '0',
                 trap => open,

                 buttons => buttons
        );

   timestamp_counter : mmio_tsc
    port map(addr => addr,
             din  => din,
             dout => dout,
             size => size,
             wr   => wr,
             en   => '0',
             clk => '0',
             trap => open
        );

   dipswitch: mmio_dipswitch
    port map(addr => addr,
             din  => din,
             dout => dout,
             size => size,
             wr   => wr,
             en   => '0',
             clk => '0',
             trap => open,
             switch => switch
         );
end struct;

