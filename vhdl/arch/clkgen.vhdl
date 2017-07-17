library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.utils.all;

entity clkgen is
    port(
        -- inbound
        Address_in : in addr_t;
        WriteData_in : in word_t;
        ReadData_in : out word_t;
        MemRead_in, MemWrite_in : in ctrl_memwidth_t;
        MemSex_in : in std_logic;
        clk : in std_logic;

        -- outbound to top level module
        top_addr : out addr_t;
        top_dout : in word_t;
        top_din : out word_t;
        top_size : out ctrl_memwidth_t;
        top_wr : out ctrl_t
    );
end;

architecture struct of clkgen is
    component RegCaster is
    port (input : in word_t;
          SignExtend : in ctrl_t;
          size : in ctrl_memwidth_t;
          extended : out word_t
    );
    end component;

    signal size : ctrl_memwidth_t;
begin
    top_size <= MemRead_in or MemWrite_in;
    size <= MemRead_in or MemWrite_in; -- because top_size is out port
    top_addr <= Address_in;
    top_wr   <= high_if(MemWrite_in /= WIDTH_NONE);

    top_din <= WriteData_in;

    RegCaster1: RegCaster
    port map(
        input => top_dout,
        SignExtend => MemSex_in,
        Size => size,
        extended => ReadData_in
    );
end struct;

