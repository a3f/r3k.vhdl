-- Incomplete

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.memory_map.all;

entity mem is
    port(
            Address : in addr_t;
            WriteData : in word_t;
            memReadData : out word_t;
            MemRead, MemWrite : in ctrl_memwidth_t;
            MemSex : in std_logic;
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
           z: out std_logic_vector(31 downto 0)
         );
    end component;

    signal cs : memchipsel_t;
    signal instr : instruction_t;
begin
    addrdec_instance : addrdec
        port map(Address, cs);

    instruction_mem : rom
        port map(Address, instr);

    memReadData <= HI_Z;

    process(clk)
    begin
        if rising_edge(clk) and memRead = WIDTH_WORD then
            memReadData <= instr;
        end if;
    end process;
end struct;

