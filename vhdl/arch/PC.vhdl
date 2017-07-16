library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.memory_map.all;
-- Remove for synthesize?
use work.debugio_h.all;
use work.txt_utils.all;

entity PC is
    generic (CPI : natural := 1);
    port (
             next_addr : in addr_t;
             clk : in std_logic;
             rst : in std_logic;
             addr : out addr_t
         );
end PC;

architecture behav of PC is
    constant bootaddr : addr_t := BOOT_ADDR; -- X"bfc0_0000";

begin process(next_addr, clk, rst)
    variable cycles : natural := 0;
begin
    if rst = '1' then
        addr <= bootaddr;
        printf("Next PC: %s\n", to_hstring(bootaddr));
    elsif rising_edge(clk) then
        cycles := cycles + 1;
        if cycles = CPI then
            addr <= next_addr;
            printf("Next PC: %s\n", to_hstring(next_addr));
            cycles := 0;
        end if;
    end if;
end process;
end behav;
