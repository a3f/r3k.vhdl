-- Address decoder

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.memory_map.all;

entity addrdec is
   port(A  : in  addr_t;
        cs : out memchipsel_t);
end addrdec;

architecture behav of addrdec is
begin
   -- FIXME use a loop over the mmap array instead
   cs <= mmap(0).chip_select when inside(A, mmap(0).base, mmap(0).size) else -- RAM
         mmap(1).chip_select when inside(A, mmap(1).base, mmap(1).size) else -- ROM
         mmap(2).chip_select when inside(A, mmap(2).base, mmap(2).size) else -- LEDs
         mmap(3).chip_select when inside(A, mmap(3).base, mmap(3).size) else -- DIP-Switch
         mmap(4).chip_select when inside(A, mmap(4).base, mmap(4).size) else -- Pushbuttons
         mmap(5).chip_select when inside(A, mmap(5).base, mmap(5).size) else -- UART
         mmap(6).chip_select when inside(A, mmap(6).base, mmap(6).size) else -- VRAM
         mmap(7).chip_select when inside(A, mmap(7).base, mmap(7).size) else -- Video configuration
         (others => '0');

         -- We need dual-ported RAM for the framebuffer,
         -- lest we've to deal with bus arbitration.
         -- That's why the VRAM is separate from the RAM
end behav;
