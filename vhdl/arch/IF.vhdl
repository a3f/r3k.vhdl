-- Instruction Fetch
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity InstructionFetch is
    -- NOTE I think, too high a CPI may lead to the same instruction
    --      executed multiple times. Problematic with real world
    --      access (e.g. writing UART)
    generic(PC_ADD : natural := 4;
            CPI : natural := 5;
            SINGLE_ADDRESS_SPACE : boolean := true);
    port (
        clk : in std_logic;
        rst : in std_logic;
        new_pc : in addr_t;
        pc_plus_4 : out addr_t;
        instr : out instruction_t;

        -- outbound to top level module
        top_addr : out addr_t;
        top_dout : in word_t;
        top_din : out word_t;
        top_size : out ctrl_memwidth_t;
        top_wr : out ctrl_t
    );
end;

architecture struct of InstructionFetch is

component PC is
    generic (CPI : natural := CPI);
    port (
        next_addr : in addr_t;
        clk : in std_logic;
        rst : in std_logic;
        addr : out addr_t);
    end component;

component Adder is
    port(
        src1: in addr_t;
        src2: in addrdiff_t;
        result: out addr_t);
    end component;

component InstructionMem is
    generic ( SINGLE_ADDRESS_SPACE : boolean := SINGLE_ADDRESS_SPACE );
    port (
        read_addr: in addr_t;
        clk : in std_logic;
        instr : out instruction_t;

        -- outbound to top level module
        top_addr : out addr_t;
        top_dout : in word_t;
        top_din : out word_t;
        top_size : out ctrl_memwidth_t;
        top_wr : out ctrl_t);
    end component;

signal read_addr: addr_t;

begin

pc1: PC
    generic map(CPI => CPI)
    port map (
        next_addr => new_pc,
        clk => clk,
        rst => rst,
        addr => read_addr);

pcAdd: Adder
    port map(
        src1 => read_addr,
        src2 => std_logic_vector(to_unsigned(PC_ADD, 32)),
        result => pc_plus_4);

instructionMem1: InstructionMem
    generic map ( SINGLE_ADDRESS_SPACE => SINGLE_ADDRESS_SPACE )
    port map (
         read_addr => read_addr,
         clk => clk,
         instr => instr,

         -- outbound to top level module
         top_addr => top_addr,
         top_dout => top_dout,
         top_din => top_din,
         top_size => top_size,
         top_wr => top_wr);
end struct;
