-- A parameterized, inferable, true dual-port, dual-clock block RAM in VHDL.
-- https://danstrother.com/2010/09/11/inferring-rams-in-fpgas/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;
use work.txt_utils.all;

entity dualport_bram is
generic (
    WORD_WIDTH    : integer := 8;
    ADDR_WIDTH    : integer := 8
);
port (
    -- Port A
    a_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    a_din   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    a_dout  : out std_logic_vector(WORD_WIDTH-1 downto 0);
    a_wr    : in  std_logic;
    a_clk   : in  std_logic;

    -- Port B
    b_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    b_din   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    b_dout  : out std_logic_vector(WORD_WIDTH-1 downto 0);
    b_wr    : in  std_logic;
    b_clk   : in  std_logic
);
end dualport_bram;

architecture rtl of dualport_bram is
    -- Shared memory
    type mem_type is array ( (2**ADDR_WIDTH)-1 downto 0 ) of std_logic_vector(WORD_WIDTH-1 downto 0);
    signal mem : mem_type := (others => (others => '0'));

    signal first_byte : std_logic_vector(WORD_WIDTH-1 downto 0);
begin

    first_byte <= mem(0);
-- Port A
process(a_clk)
begin
    if(rising_edge(a_clk)) then
        if(a_wr='1') then
            printf(ANSI_GREEN & "writing %s to %s\n", a_din, a_addr);
            mem(vtou(a_addr)) <= a_din;
        end if;
        a_dout <= mem(vtou(a_addr));
    end if;
end process;

-- Port B
process(b_clk)
begin
    if(rising_edge(b_clk)) then
        if(b_wr='1') then
            mem(vtou(b_addr)) <= b_din;
        end if;
        b_dout <= mem(vtou(b_addr));
    end if;
end process;
end rtl;
