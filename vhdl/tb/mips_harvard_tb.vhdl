-- This is the top level MIPS architecture
-- With the instruction memory not mapped on the Data/IO memory bus
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

entity mips_harvard_tb is
end;

architecture struct of mips_harvard_tb is
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

    signal sysclk : std_logic := '0';
    signal regrst : std_logic := '0';
    signal rst : std_logic := '0';
    signal online : boolean := true;
    signal cpu_regWrite  : std_logic;
    signal cpu_readreg1  : reg_t;
    signal cpu_readreg2  : reg_t;
    signal test_readreg1  : reg_t;
    signal test_readreg2  : reg_t;

    alias clk is sysclk;

    -- VGA
    -- nothing yet
begin
    regfile_inst: regFile port map (
        readreg1 => readreg1, readreg2 => readreg2,
        writereg => writereg,
        writeData => regWriteData,
        readData1 => regReadData1, readData2 => regReadData2,
        clk => clk,
        rst => regrst,
        regWrite => regWrite
    );

    mem_bus: mem
    generic map (ROM => "")
    port map (
        addr => addr,
        din => din,
        dout => dout,
        size => size,
        wr => wr,
        clk => clk,

        vgaclk => '0', rst => '1',
        r => open, g => open, b => open,

        hsync => open, vsync => open,

        leds => open,
        -- Push buttons
        buttons => B"0000",
        -- DIP Switch IO
        switch => B"1010_1010"
    );

    cpu_inst: cpu
    generic map(SINGLE_ADDRESS_SPACE => false)
    port map (
        clk => clk,
        rst => rst,

        -- Register File
        readreg1 => cpu_readreg1, readreg2 => cpu_readreg2,
        writereg => writereg,
        regWriteData => regWriteData,
        regReadData1 => regReadData1, regReadData2 => regReadData2,
        regWrite => cpu_RegWrite,

        -- Memory
        top_addr => addr,
        top_dout => dout,
        top_din => din,
        top_size => size,
        top_wr => wr,

        -- Debug info
        instruction => open
    );

    regwrite <= cpu_RegWrite when online else '0';
    readreg1 <= cpu_readreg1 when online else test_readreg1;
    readreg2 <= cpu_readreg2 when online else test_readreg2;

    test: process begin
        wait for 4 ns;
        rst <= '1';
        wait for 4 ns;
        rst <= '0';
        wait for 4 ns;

        wait for 260 ns;

        rst <= '0';
        online <= false;
        wait for 20 ns;

        test_readreg1 <= R1;
        wait for 8 ns;

        assert regReadData1 = X"0000_F000" report
                ANSI_RED & "[r1] Failed to ori. 0xF000 /= " & to_hstring(regReadData1) & ANSI_NONE
        severity error;

        test_readreg1 <= R2;
        test_readreg2 <= R1;
        wait for 16 ns;

        assert regReadData2 = X"0000_F000" report
                ANSI_RED & "[r1] Failed to ori. 0xF000 /= " & to_hstring(regReadData2) & ANSI_NONE
        severity error;

        assert regReadData1 = X"0000_FBAD" report
                ANSI_RED & "[r2] Failed to ori. 0xFBAD /= " & to_hstring(regReadData1) & ANSI_NONE
        severity error;


        test_readreg1 <= R3;
        test_readreg2 <= R4;
        wait for 16 ns;

        assert regReadData1 = X"A000_0000" report
                ANSI_RED & "[r3] 0xA000_0000 /= " & to_hstring(regReadData1) & ANSI_NONE
        severity error;

        assert regReadData2 = X"FFFF_FFAD" report
                ANSI_RED & "[r4] 0xFFFF_FFAD /= " & to_hstring(regReadData2) & ANSI_NONE
        severity error;

        wait;
    end process;

    clkproc: process begin
        sysclk <= not sysclk; wait for 1 ns; if not online then sysclk <= '0'; wait; end if;
    end process;

end struct;


