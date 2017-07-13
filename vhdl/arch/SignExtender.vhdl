library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity SignExtender is
    port (immediate : in half_t;
          sexed : out word_t);
    end;

Architecture behav of SignExtender is
    constant zeroes : half_t := (others => '0');
    constant ones   : half_t := (others => '1');
begin
    sexed <= zeroes & immediate when immediate(15) = '0' else ones & immediate;
end;
