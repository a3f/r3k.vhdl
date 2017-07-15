-- The CPU, only the stateless parts
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

-- We keep keep all state (registers, memory) out of the CPU
-- This allows for testbenches that can instantiate them theirselves
-- and check whether everything works as expected
entity cpu is
generic(PC_ADD : addrdiff_t := X"0000_0004");
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Register File
        readreg1, readreg2 : out reg_t;
        writereg: out reg_t;
        regWriteData: out word_t;
        regReadData1, regReadData2 : in word_t;
        regWrite : out std_logic;

        -- Memory
        Address : out addr_t;
        memWriteData : out word_t;
        memReadData : in word_t;
        MemRead, MemWrite : out ctrl_memwidth_t;
        MemSex : out std_logic
    );
end;

architecture struct of cpu is

component InstructionFetch is
    port(
	clk : in std_logic;
	rst : in std_logic;
        pc_in : in addr_t;
	pc_out : out addr_t;
        instr_out : out instruction_t);
end component;
	 
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
end component;

component memoryAccess is
end component;

component writeBack is
    port(
	Link, JumpReg, JumpDir, MemToReg, TakeBranch : in ctrl_t;
	pc_out, branch_addr, jump_addr: in addr_t;
	aluResult, memReadData, regReadData1 : in word_t;
	regWriteData : out word_t;
	next_addr : out addr_t);
end component;

begin
end struct;
