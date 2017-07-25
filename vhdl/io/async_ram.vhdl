library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.utils.all;
use work.memory_map.all;
use work.txt_utils.all;

entity async_ram is
    generic (
        MEMSIZE :integer := 8
    );
    port (
        address : in addr_t;
        din     : in word_t;
        dout    : out word_t;
        size    : in ctrl_memwidth_t;
        wr      : in std_logic;
        en      : in    std_logic
    );
end entity;
architecture behav of async_ram is
    signal data_out : word_t;

    type ram_t is array (integer range <>)of byte_t;
    signal mem : ram_t (0 to MEMSIZE-1);
    signal mem_word0 : word_t;
    constant NOCARE : byte_t := (others => '-');
begin

    dout <= data_out when en = '1' and wr = '0' else HI_Z;

    -- FIXME use size of ram for masking
    memwrite: process (address, din, en, wr)
        variable index : natural;
    begin
        index := vtou(address and not mmap(mmap_ram).base);
       if en = '1' and wr = '1' then
           case size is
               when WIDTH_BYTE => mem(index  ) <= din( 7 downto 0);

               when WIDTH_HALF => mem(index+0) <= din(15 downto 8);
                                  mem(index+1) <= din(7 downto 0);

               when WIDTH_WORD => mem(index+0) <= din(31 downto 24);
                                  mem(index+1) <= din(23 downto 16);
                                  mem(index+2) <= din(15 downto 8);
                                  mem(index+3) <= din( 7 downto 0);
               when others => null;
           end case;
       end if;
    end process;

    memread: process (address, en, wr, size, mem)
        variable index : natural;
    begin
        index := vtou(address and not mmap(mmap_ram).base);
        -- printf(ANSI_GREEN & " iNDEX is %d\n", index);
        if en = '1' and wr = '0' then
           case size is
               when WIDTH_BYTE => data_out <= NOCARE & NOCARE & NOCARE & mem(0);
               when WIDTH_HALF => data_out <= NOCARE & NOCARE & mem(0) & mem(1);
               when WIDTH_WORD => data_out <= mem(0) & mem(1) & mem(2) & mem(3);
               when others => null;
           end case;
        end if;
    end process;

    mem_word0 <= mem(0) & mem(1) & mem(2) & mem(3); -- this is crappy
end behav;

