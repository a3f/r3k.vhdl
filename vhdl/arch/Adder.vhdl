library ieee;
use ieee.std_logic_1164.all;

Entity Adder is
    Port (src1 : in addr_t; src2 : in addrdiff_t;
          result : out addr_t
    End;

Architecture behav of Adder is
begin
     result <= std_logic_vector(
                   to_unsigned(to_integer(unsigned(src1))
                 + to_unsigned(to_integer(unsigned(src2)),
               result'width));
end;
