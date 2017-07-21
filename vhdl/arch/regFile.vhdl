library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;
use work.txt_utils.all;

entity regFile is
    port (
        readreg1, readreg2 : in reg_t;
        writereg: in reg_t;
        writedata: in word_t;
        readData1, readData2 : out word_t;
        clk : in std_logic;
        rst : in std_logic;
        regWrite : in std_logic
    );
    end regFile;

architecture behav of regFile is
    type regfile_t is array (31 downto 0) of word_t;
    signal reg : regfile_t := (0 => ZERO, others => ZERO);
    signal reg1, reg2 : word_t; -- for debug purposes only


    begin process(clk, rst, readreg1, readreg2)
    begin
        readdata1 <= reg(vtou(readreg1));
        readdata2 <= reg(vtou(readreg2));
        if rst = '1' then
            for i in 0 to 31 loop reg(i) <= ZERO; end loop;
        elsif rising_edge(clk) then
            if regWrite = '1' and writereg /= R0 then
                printf(ANSI_GREEN & "R%s=%s\n", writereg, writedata);
                reg(vtou(writereg)) <= writedata;
            end if;
        end if;
    end process;
    reg1 <= reg(1);
    reg2 <= reg(2);
end behav;
