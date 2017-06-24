library ieee;
use ieee.std_logic_1164.all;

entity BranchShift2 is
    port (immediate  : in addr_t;
          addr   : out addr_t);
    end;

architecture behav of BranchShift2 is
begin
    addr <= immediate(29 downto 0) & "00";
end;

