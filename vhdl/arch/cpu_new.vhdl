-- The CPU, only the stateless parts
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

-- We keep keep all state (registers, memory) out of the CPU
-- This allows for testbenches that can instantiate them theirselves
-- and check whether everything works as expected
entity cpu is
end;

architecture struct of cpu is

component InstructionFetch is
    port(
	clk : in std_logic;
	rst : in std_logic;
        pc_in : in addr_t;
	pc_out : out addr_t;
        instr_out : out instruction_t);
end component
	 
component InstructionDecode is
    port(
	instr : in instruction_t;
        next_pc : in addr_t;
        jump_addr : out addr_t;
        
        regwrite, link, jumpreg, jumpdirect, branch : out ctrl_t;
        memread : out ctrl_memwidth_t;
        memtoreg, memsex : out ctrl_t;
        memwrite : out ctrl_memwidth_t;
        shift, alusrc : out ctrl_t;
        aluop     : out alu_op_t;
        
        readreg1, readreg2, writereg : out reg_t;
        zeroxed, sexed : out word_t;

        clk : in std_logic;
        rst : in std_logic);
end component;

component execute is
    port(
	);
end component;

component memoryAccess is
    port(
	);
end component;

component writeBack is
    port(
	);
end component;

begin
end struct;
