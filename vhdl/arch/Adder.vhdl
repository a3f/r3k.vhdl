library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity Adder is
    port (src1 : in addr_t; src2 : in addrdiff_t;
          result : out addr_t);
end;

architecture behav of Adder is
begin
     result <= std_logic_vector(unsigned(src1) + unsigned(src2));
end;
