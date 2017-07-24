library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.utils.all;

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

    type ram_t is array (integer range <>)of word_t;
    signal mem : ram_t (0 to MEMSIZE-1);
    signal mem_word0 : word_t;
begin

    dout <= data_out when en = '1' and wr = '0' else HI_Z;

    -- FIXME use size of ram for masking
    memwrite: process (address, din, en, wr) begin
       if en = '1' and wr = '1' then
           mem(vtou(X"0000" & address(15 downto 0))) <= din;
       end if;
    end process;

    memread: process (address, en, wr, mem) begin
        if en = '1' and wr = '0'  then
             data_out <= mem(vtou(X"0000" & address(15 downto 0)));
        end if;
    end process;

    mem_word0 <= mem(0);
end behav;
