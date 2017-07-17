library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.txt_utils.all;
use work.utils.all;

--  A testbench has no ports.
entity regFile_tb is
    end regFile_tb;

architecture behav of regFile_tb is

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

    signal readreg1, readreg2 : reg_t := R0;
    signal writereg: reg_t := R0;
    signal writedata: word_t := ZERO;
    signal readData1, readData2 : word_t := ZERO;
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal regWrite : std_logic := '0';

    constant errormsg : string := ANSI_RED & "Testcase failed" & ANSI_NONE;
    signal done : boolean := false;

    begin
    regFile1: regFile
        port map(
            readreg1 => readreg1, readreg2 => readreg2,
            writereg => writereg, writedata => writedata,
            readData1 => readData1, readData2 => readData2,
            clk => clk, rst => rst,
            regWrite => regWrite
        );
    
    test: process
    begin
        wait for 2 ns;
        rst <= '1';
        wait for 2 ns;
        rst <= '0';
        wait for 2 ns;

        for i in 0 to 30 loop
            readreg1 <= toreg(i);
            readreg2 <= toreg(i+1);
            wait for 2 ns;

            assert readdata1 = ZERO and readdata2 = ZERO report
                errormsg & ": 0 /= " & to_string(readdata1)
            severity error;
        end loop;

        writereg  <= R7;
        writedata <= X"01234567";
        regWrite  <= '1';
        wait for 2 ns;
        regWrite  <= '0';
        wait for 2 ns;

        readreg1 <= R7;
        wait for 2 ns;

        assert readdata1 = X"01234567" report
            errormsg & to_string(readdata1)
        severity error;

        readreg1 <= R7;
        wait for 2 ns;

        assert readdata1 = X"01234567" report
            errormsg & to_string(readdata1)
        severity error;

        writereg  <= R0;
        writedata <= X"01234567";
        regWrite  <= '1';
        wait for 2 ns;
        regWrite  <= '0';
        wait for 2 ns;

        readreg1 <= R7;
        wait for 2 ns;

        assert readdata1 = X"01234567" report
            errormsg & to_string(readdata1)
        severity error;

        readreg1 <= R0;
        wait for 2 ns;

        assert readdata1 = X"00000000" report
            errormsg & to_string(readdata1)
        severity error;

        wait for 2 ns;
        readreg1 <= R2;
        wait for 2 ns;

        assert readdata1 = ZERO report
            errormsg &": "& to_hstring(readdata1)
        severity error;

        for i in 0 to 31 loop
            writereg  <= toreg(i);
            writedata <= (31 downto 5 => '0') & toreg(i);
            regWrite  <= '1';
            wait for 2 ns;
        end loop;

        for i in 0 to 31 loop
            readreg1 <= toreg(i);
            wait for 2 ns;

            assert readData1 = (31 downto 5 => '0') & toreg(i) report
                errormsg & ": " & to_string(readData1)
            severity error;
        end loop;

        done <= true;
        wait;
    end process;

    clkproc: process begin
        clk <= not clk;
        wait for 1 ns;

        if done then wait; end if;
    end process;
end behav;


