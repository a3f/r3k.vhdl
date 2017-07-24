library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

entity MUX1bit is
    -- With VHDL2008 we could MAX type generic and make this obsolete
    port (
             sel: in ctrl_t;
             input0 : in std_logic;
             input1 : in std_logic;
             output : out std_logic
         );
end entity;

architecture behav of MUX1bit is
begin
    output <= input0 when sel = '0' else input1;
end architecture behav;


