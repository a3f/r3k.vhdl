library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity SignExtend is
    port (immediate : in halfword_t;
          sexed : out word_t);
    end;

Architecture behav of SignExtend is
begin
    sexed <= std_logic_vector(resize(signed(immediate),sexed'width));
end;
