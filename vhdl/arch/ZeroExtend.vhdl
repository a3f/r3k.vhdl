library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity ZeroExtend is
    port (shamt : in std_logic_vector(4 downto 0); -- Instruction 10-6
          zeroxed : out word_t);
    end;

Architecture behav of ZeroExtend is
    constant zeroes : std_logic_vector(31 downto 5) := (others => '0');
begin
    zeroxed <= zeroes & shamt;
end;

