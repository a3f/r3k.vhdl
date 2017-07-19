-- Incomplete

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.memory_map.all;
use work.txt_utils.all;
use work.utils.all;

entity mem is
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

    signal cs : memchipsel_t := (others => '1'); -- FIXME!
    signal instr : instruction_t;
begin
    --addrdec_instance : addrdec port map(addr, cs);

    instruction_mem : rom
        port map(addr, instr, cs(mmap_rom));

--    dout <= HI_Z;

    dout <= instr;
    process(instr, addr)
    begin
            printf("Reading *0x%s => %s\n", addr, instr);
    end process;
end struct;

