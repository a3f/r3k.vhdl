-- Instruction Fetch
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity InstructionFetch is
    port (
        next_pc : in addr_t;
        pc : out addr_t;
        instr : in instruction_t
    );
end;

architecture struct of InstructionFetch is
begin
end struct;


