library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

entity MUX is
    generic (BITS : natural := 32);
    port (
             sel: in ctrl_t;
             input0 : in std_logic_vector(BITS-1 downto 0);
             input1 : in std_logic_vector(BITS-1 downto 0);
             output : out std_logic_vector(BITS-1 downto 0)
         );
end entity;

architecture behav of MUX is
begin
    output <= input0 when sel = '0' else input1;
end architecture behav;

