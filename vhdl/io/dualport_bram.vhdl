-- A parameterized, inferable, true dual-port, dual-clock block RAM in VHDL.
-- https://danstrother.com/2010/09/11/inferring-rams-in-fpgas/
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library work;
entity dualport_bram is
generic (
    WORD_WIDTH    : integer := 72;
    ADDR_WIDTH    : integer := 10
);
port (
    -- Port A
    a_clk   : in  std_logic;
    a_wr    : in  std_logic;
    a_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    a_din   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    a_dout  : out std_logic_vector(WORD_WIDTH-1 downto 0);
     
    -- Port B
    b_clk   : in  std_logic;
    b_wr    : in  std_logic;
    b_addr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    b_din   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    b_dout  : out std_logic_vector(WORD_WIDTH-1 downto 0)
);
end dualport_bram;
 
architecture rtl of dualport_bram is
    -- Shared memory
    type mem_type is array ( (2**ADDR_WIDTH)-1 downto 0 ) of std_logic_vector(WORD_WIDTH-1 downto 0);
    shared variable mem : mem_type;
begin
 
-- Port A
process(a_clk)
begin
    if(a_clk'event and a_clk='1') then
        if(a_wr='1') then
            mem(to_integer(unsigned(a_addr))) := a_din;
        end if;
        a_dout <= mem(to_integer(unsigned(a_addr)));
    end if;
end process;
 
-- Port B
process(b_clk)
begin
    if(b_clk'event and b_clk='1') then
        if(b_wr='1') then
            mem(to_integer(unsigned(b_addr))) := b_din;
        end if;
        b_dout <= mem(to_integer(unsigned(b_addr)));
    end if;
end process;
 
end rtl;
