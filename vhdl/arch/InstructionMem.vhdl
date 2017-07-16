library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;

entity InstructionMem is
    port (
             read_addr : in addr_t;
             clk : in std_logic;
             instr : out instruction_t
         );
end InstructionMem;

architecture behav of InstructionMem is
    type code_t is array (natural range <>) of instruction_t;
    constant code : code_t := (
    -- start:
    B"001101_00001_00001" & X"f000", -- ori r1, r1, 0xf000
    B"001101_00001_00001" & X"0b00", -- ori r1, r2, 0x0b00
    X"08_000000"  -- j start
    );
begin process(read_addr, clk)
        variable instrnum : addr_t;
    begin
        instrnum := "00" & read_addr(31 downto 2);
    if rising_edge(clk) then
        instr <= code(vtou(instrnum));
    end if;
end process;
end behav;
