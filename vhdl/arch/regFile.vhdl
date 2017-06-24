library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity regFile is
		port (
		-- static
		readreg1, readreg2 : in reg_t;
		writereg: in reg_t;
		writedata: in word_t;
		readData1, readData2 : out word_t;
		clk : in std_logic;
		regWrite : in std_logic
		);
	end regFile;
		
architecture behav of regFile is
    type regfile_t is array (31 downto 0) of word_t;
    signal reg : regfile_t := (R0 => ZERO);


begin process(readreg1, readreg2, writereg, clk)
        variable readreg1_int, readreg2_int, writereg_int : integer;
    begin
    -- Do these need to be inside a process? I think not.
    if readreg1'event then
        readdata1 <= reg(readreg1_int);
    end if;
    if readreg1'event then
        readdata2 <= reg(readreg2_int);
    end if;
    if rising_edge(clk) then
        if regWrite = '1' then
                regs(writereg_int) <= writedata;
        end if;
    end if;

end process;

end behav;
