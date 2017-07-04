library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity DataMem is
    port (
    Address : in addr_t;
    WriteData : in word_t;
    ReadData : out word_t;
    MemRead, MemWrite : in ctrl_memwidth_t;
    MemSex : in std_logic;
    clk : in std_logic
);
end DataMem;

architecture behav of DataMem is
    type code_t is array (natural range <>) of instruction_t;
    constant code : code_t := (
    -- start:
    X"00_00_00_00", -- no-op
    X"08_00_00_00"  -- j start
);
begin process(Address, clk)
begin
    if rising_edge(clk) then
        ReadData <= code(to_integer(unsigned(Address)));
    end if;
end process;
end behav;
