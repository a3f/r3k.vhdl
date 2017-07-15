-- The CPU, only the stateless parts
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

-- We keep keep all state (registers, memory) out of the CPU
-- This allows for testbenches that can instantiate them theirselves
-- and check whether everything works as expected
entity cpu is

end;
