-- This is the top level MIPS architecture
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity mips is
    generic ( DEMO : boolean := false);
    port (
        sysclk : in std_logic;
        rst : in std_logic;

        -- VGA I/O
        vgaclk : in std_logic;
        r, g, b : out std_logic_vector (3 downto 0);

        hsync, vsync : out std_logic;

        -- LEDs
        leds : out std_logic_vector(7 downto 0);
        -- Push buttons
        buttons : in std_logic_vector(3 downto 0);
        -- DIP Switch IO
        switch : in std_logic_vector(7 downto 0)
    );
end;

architecture struct of mips is
    component regFile is
    port (
            readreg1, readreg2 : in reg_t;
            writereg: in reg_t;
            writedata: in word_t;
            readData1, readData2 : out word_t;
            clk : in std_logic;
            rst : in std_logic;
            regWrite : in std_logic
    );
    end component;

    component mem is
    generic (ROM : string := "");
    port (
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
    end component;

    component cpu is
    generic(PC_ADD : natural := 4;
            SINGLE_ADDRESS_SPACE : boolean := true);
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Register File
        readreg1, readreg2 : out reg_t;
        writereg: out reg_t;
        regWriteData: out word_t;
        regReadData1, regReadData2 : in word_t;
        regWrite : out std_logic;

        -- Memory
        top_addr : out addr_t;
        top_dout : in word_t;
        top_din : out word_t;
        top_size : out ctrl_memwidth_t;
        top_wr : out ctrl_t;

        -- Debug info
        instruction : out instruction_t
    );
    end component;

    component clkdivider is
        port (
            ticks : in natural;
            bigclk : in std_logic;
            rst : in std_logic;

            smallclk : out std_logic
        );
    end component;

    signal readreg1, readreg2 : reg_t;
    signal writereg: reg_t;
    signal regWriteData: word_t;
    signal regReadData1, regReadData2 : word_t;
    signal regWrite : std_logic;

    signal addr : addr_t;
    signal din : word_t;
    signal dout : word_t;
    signal size : ctrl_memwidth_t;
    signal wr : std_logic;

    signal clk : std_logic := '0';

    signal instruction : instruction_t;
begin
    normal_clk: if not DEMO generate
        clkdivider1: clkdivider port map (
            ticks => 10, bigclk => sysclk, rst => rst, smallclk => clk
        );
    end generate;
    clk_is_6hz: if DEMO generate
        clkdivider1: clkdivider port map (
            ticks => VGA_PIXELFREQ / 6, bigclk => sysclk, rst => rst, smallclk => clk
        );
    end generate;

    -- One instruction every two seconds

    regfile_inst: regFile port map (
        readreg1 => readreg1, readreg2 => readreg2,
        writereg => writereg,
        writeData => regWriteData,
        readData1 => regReadData1, readData2 => regReadData2,
        clk => clk,
        rst => rst,
        regWrite => regWrite
    );

    connect_leds_to_bus: if not DEMO generate
    mem_bus: mem
        generic map (ROM => "VGA")
        port map (
            addr => addr, din => din, dout => dout, size => size, wr => wr, clk => clk,
            vgaclk => vgaclk, rst => rst, r => r, g => g, b => b, hsync => hsync, vsync => vsync,
            leds => leds, buttons => buttons, switch => switch
        );
    end generate;

    connect_leds_to_instruction: if DEMO generate
        mem_bus: mem
        generic map (ROM => "VGA")
        port map (
            addr => addr, din => din, dout => dout, size => size, wr => wr, clk => clk,
            vgaclk => vgaclk, rst => rst, r => r, g => g, b => b, hsync => hsync, vsync => vsync,
            leds => open, buttons => buttons, switch => switch
        );

        leds(7) <= wr;
        leds(6) <= clk;
        leds(5 downto 0) <= instruction(31 downto 26);
    end generate;

    cpu_inst: cpu 
    generic map (SINGLE_ADDRESS_SPACE => false)
    port map (
        clk => clk,
        rst => rst,

        -- Register File
        readreg1 => readreg1, readreg2 => readreg2,
        writereg => writereg,
        regWriteData => regWriteData,
        regReadData1 => regReadData1, regReadData2 => regReadData2,
        regWrite => regWrite,

        -- Memory
        top_addr => addr,
        top_dout => dout,
        top_din => din,
        top_size => size,
        top_wr => wr,

        -- Debug info
        instruction => instruction
    );
end struct;

