library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

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
    X"00_00_00_00", -- no-op
    X"08_00_00_00"  -- j start
    );
begin process(read_addr, clk)
    begin
    if rising_edge(clk) then
        instr <= code(to_integer(unsigned(read_addr)));
    end if;
end process;
end behav;
