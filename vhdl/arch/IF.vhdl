-- Instruction Fetch
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity InstructionFetch is
    generic(PC_ADD : addrdiff_t := X"0000_0004");
    port (
        clk : in std_logic;
	rst : in std_logic;
        pc_in : in addr_t;
	pc_out : out addr_t;
        instr_out : out instruction_t
    );
end;

architecture struct of InstructionFetch is

component PC is
    port (
        pc_in : in addr_t;
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
    port (
        read_addr: in addr_t;
        clk : in std_logic;
        instr : out instruction_t);
    end component;

signal read_addr: addr_t;

begin

pc1: PC
    port map (
        pc_in=> pc_in,
        clk => clk,
        rst => rst,
        addr => read_addr);

pcAdd: Adder
    port map(
        src1 => read_addr,
        src2 => PC_ADD,
        result => pc_out);

instructionMem1: InstructionMem
    port map (
	read_addr => read_addr,
	clk => clk,
	instr => instr_out);

end struct;


