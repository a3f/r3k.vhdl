-- Incomplete

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.memory_map.all;
use work.txt_utils.all;
use work.utils.all;

entity mem is
    generic (RAMSIZE : positive := 32);
    port(
            addr : in addr_t;
            din : in word_t;
            dout : out word_t;
            size : in ctrl_memwidth_t;
            wr : in std_logic;
            clk : in std_logic
    );
end mem;

architecture struct of mem is
    component addrdec is
   port( A  : in  addr_t;
         cs : out memchipsel_t);
    end component;

    component rom is
    port ( a: in std_logic_vector(31 downto 0);
           z: out std_logic_vector(31 downto 0);
           en : in std_logic
         );
    end component;

    signal cs : memchipsel_t;
    signal instr : instruction_t;

   component async_ram is
        generic (
            MEMSIZE :integer := RAMSIZE
        );
        port (
            address : in addr_t;
            din     : in word_t;
            dout    : out word_t;
            size    : in ctrl_memwidth_t;
            wr      : in std_logic;
            en      : in    std_logic
        );
   end component;
begin
    addrdec_instance : addrdec port map(addr, cs);

    instruction_mem : rom
        port map(addr, dout, cs(mmap_rom));

    -- It's possible that this isn't interferrable. If so, maybe use synchronous RAM instead?
    working_ram : async_ram
        port map(address => addr,
                 din => din,
                 dout => dout,
                 size => size,
                 wr => wr,
                 en => cs(mmap_ram)
         );

end struct;

