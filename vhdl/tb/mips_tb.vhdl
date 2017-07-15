-- SKIP because I can't get it to work yet :-(
-- Will try less involved instr_tb.vhdl first
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.utils.all;
use work.txt_utils.all;

-- A testbench has no ports
entity mips_tb is
end;

architecture struct of mips_tb is
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
        Address : in addr_t;
        WriteData : in word_t;
        memReadData : out word_t;
        MemRead, MemWrite : in ctrl_memwidth_t;
        MemSex : in std_logic;
        clk : in std_logic
    );
    end component;

    component cpu is
    generic(PC_ADD : addrdiff_t := X"0000_0004");
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
        Address : out addr_t;
        memWriteData : out word_t;
        memReadData : in word_t;
        MemRead, MemWrite : out ctrl_memwidth_t;
        MemSex : out std_logic
    );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal readreg1 : reg_t := R0;
    signal readreg2 : reg_t := R0;
    signal writereg: reg_t := R0;
    signal regWriteData: word_t := ZERO;
    signal readData1 : word_t := ZERO;
    signal readData2 : word_t := ZERO;
    signal regWrite : std_logic := '0';

    signal Address : addr_t := ZERO;
    signal memWriteData : word_t := ZERO;
    signal memReadData : word_t := ZERO;
    signal MemRead  : ctrl_memwidth_t := WIDTH_NONE;
    signal MemWrite : ctrl_memwidth_t := WIDTH_NONE;
    signal MemSex : std_logic := '0';

    signal done : boolean := false;
begin
    regfile_inst: regFile port map (
        readreg1 => readreg1, readreg2 => readreg2,
        writereg => writereg,
        writeData => regWriteData,
        readData1 => readData1, readData2 => readData2,
        clk => clk,
        rst => rst,
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

    cpu_inst: cpu
    generic map (PC_ADD => X"0000_0000")
    port map (
        clk => clk,
        rst => rst,

        -- Register File
        readreg1 => readreg1, readreg2 => readreg2,
        writereg => writereg,
        regWriteData => regWriteData,
        regReadData1 => readData1, regReadData2 => readData2,
        regWrite => regWrite,

        -- Memory
        Address => Address,
        memWriteData => memWriteData,
        memReadData => memReadData,
        MemRead => memRead, MemWrite => memWrite,
        MemSex => memSex
    );

    test: process begin
        wait for 20 ns;
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        readreg1 <= R1;
        wait for 20 ns;

        assert readdata1 = X"01234567" report
            "Failed writing regfile: " & to_string(readdata1)
        severity error;


        done <= true;
        wait;
    end process;

    clkproc: process begin clk <= not clk; wait for 1 ns; if done then wait; end if; end process;
end struct;


