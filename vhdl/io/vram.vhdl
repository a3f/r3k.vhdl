library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.color_util.all;

entity dualport_ram is
    generic ( SIZE  : natural := 8 );
    port ( clk   : in  std_logic;
           wr : in  std_logic;
           wraddr   : in  std_logic_vector (31 downto 0); -- MIPS-facing
           rdaddr   : in  std_logic_vector (31 downto 0); -- VGA-facing
           din   : in  std_logic_vector (7 downto 0);
           dout  : out std_logic_vector (7 downto 0)
       );
end dualport_ram;

architecture blockram of dualport_ram is
    type memory_t is array(0 to SIZE-1) of std_logic_vector(7 downto 0);
    signal memory : memory_t;   
begin
process begin
    wait until rising_edge(clk);
    if wr = '1' then
        memory(to_integer(unsigned(wraddr)+0)) <= din;
    end if;
    dout <= memory(to_integer(unsigned(rdaddr)));
end process;
end blockram;
