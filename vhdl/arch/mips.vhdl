-- This is the top level MIPS architecture
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity mips is
    port (
        clk : in std_logic;
        rst : in std_logic
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
    port (
        addr : in addr_t;
        din : in word_t;
        dout : out word_t;
        size : in ctrl_memwidth_t;
        wr : in std_logic;
        clk : in std_logic
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
        top_wr : out ctrl_t
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

begin
    regfile_inst: regFile port map (
        readreg1 => readreg1, readreg2 => readreg2,
        writereg => writereg,
        writeData => regWriteData,
        readData1 => regReadData1, readData2 => regReadData2,
        clk => clk,
        rst => rst,
        regWrite => regWrite
    );

    mem_bus: mem port map (
        addr => addr,
        din => din,
        dout => dout,
        size => size,
        wr => wr,
        clk => clk
    );

    cpu_inst: cpu port map (
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
        top_wr => wr
    );
end struct;

