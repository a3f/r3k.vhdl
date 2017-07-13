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
            regWrite : in std_logic
    );
    end component;

    component mem is
    port (
        Address : in addr_t;
        WriteData : in word_t;
        memReadData : out word_t;
        MemRead, MemWrite : in ctrl_memwidth_t;
        MemSex : in std_logic;
        clk : in std_logic
    );
    end component;

    component cpu is
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Register File
        readreg1, readreg2 : out reg_t;
        writereg: out reg_t;
        regWriteData: out word_t;
        readData1, readData2 : in word_t;
        regWrite : out std_logic;

        -- Memory
        Address : out addr_t;
        memWriteData : out word_t;
        memReadData : in word_t;
        MemRead, MemWrite : out ctrl_memwidth_t;
        MemSex : out std_logic
    );
    end component;

    signal readreg1, readreg2 : reg_t;
    signal writereg: reg_t;
    signal regWriteData: word_t;
    signal readData1, readData2 : word_t;
    signal regWrite : std_logic;

    signal Address : addr_t;
    signal memWriteData : word_t;
    signal memReadData : word_t;
    signal MemRead, MemWrite : ctrl_memwidth_t;
    signal MemSex : std_logic;

begin
    regfile_inst: regFile port map (
        readreg1 => readreg1, readreg2 => readreg2,
        writereg => writereg,
        writeData => regWriteData,
        readData1 => readData1, readData2 => readData2,
        clk => clk,
        regWrite => regWrite
    );

    mem_bus: mem port map (
        Address => Address,
        WriteData => memWriteData,
        memReadData => memReadData,
        MemRead => memRead, MemWrite => MemWrite,
        MemSex => MemSex,
        clk => clk
    );

    cpu_inst: cpu port map (
        clk => clk,
        rst => rst,

        -- Register File
        readreg1 => readreg1, readreg2 => readreg2,
        writereg => writereg,
        regWriteData => regWriteData,
        readData1 => readData1, readData2 => readData2,
        regWrite => regWrite,

        -- Memory
        Address => Address,
        memWriteData => memWriteData,
        memReadData => memReadData,
        MemRead => memRead, MemWrite => memWrite,
        MemSex => memSex
    );
end struct;

