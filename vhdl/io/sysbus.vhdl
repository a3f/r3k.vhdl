library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity sysbus is
    port (
             addr : in addr_t;
             din: in word_t;
             dout: out word_t;
             size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
             wr : in std_logic;
             clk : in std_logic;
             trap : out traps_t := TRAP_NONE
         );
end sysbus;

architecture behav of sysbus is
    signal cs : std_logic_vector(1 downto 0);

begin

end behav;

