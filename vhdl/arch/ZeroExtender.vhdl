library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.utils.all;

entity ZeroExtender is
    port (shamt : in std_logic_vector(4 downto 0); -- Instruction 10-6
          zeroxed : out word_t);
    end;

Architecture behav of ZeroExtender is
    constant zeroes : std_logic_vector(31 downto 5) := (others => '0');
begin
    zeroextend(zeroxed, shamt);
end;

