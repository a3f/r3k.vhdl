library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;

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
    signal reg : regfile_t := (0 => ZERO, others => DONT_CARE);


    begin process(readreg1, readreg2, writereg, writedata, regWrite, clk, rst)
    begin
        if rising_edge(clk) then
            readdata1 <= reg(vtoi(readreg1));
            readdata2 <= reg(vtoi(readreg2));

            if regWrite = '1' and writereg /= R0 then
                reg(vtoi(writereg)) <= writedata;
            end if;
            -- replace with loop
            if rst = '1' then
                for i in 0 to 31 loop reg(i) <= ZERO; end loop;
            end if;
        end if;
    end process;
end behav;
