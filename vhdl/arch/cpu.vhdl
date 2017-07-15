-- The CPU, only the stateless parts
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

-- We keep keep all state (registers, memory) out of the CPU
-- This allows for testbenches that can instantiate them theirselves
-- and check whether everything works as expected
entity cpu is
    generic(PC_ADD : natural := 4;
               CPI : natural := 5);
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
        generic(PC_ADD : natural := PC_ADD;
                CPI : natural := CPI);
        port(
                clk : in std_logic;
                rst : in std_logic;
                next_addr : in addr_t;
                next_pc : out addr_t;
                instr   : out instruction_t);
    end component;

    component InstructionDecode is
        port(
                instr : in instruction_t;
                next_pc : in addr_t;
                jump_addr : out addr_t;

        regwrite, link, jumpreg, jumpdirect, branch : out ctrl_t;
        memread, memwrite : out ctrl_memwidth_t;
        memtoreg, memsex : out ctrl_t;
        shift, alusrc : out ctrl_t;
        aluop     : out alu_op_t;

        readreg1, readreg2, writereg : out reg_t;
        zeroxed, sexed : out word_t;

        clk : in std_logic;
        rst : in std_logic);
    end component;

    component Execute is
        port (
            next_pc : in addr_t;
            regReadData1, regReadData2 : in word_t;
            branch_addr : out addr_t;

            branch_in : in ctrl_t;
            shift_in, alusrc_in : in ctrl_t;
            aluop_in : in alu_op_t;

            zeroxed, sexed : in word_t;

            takeBranch : out ctrl_t;
            AluResult : out word_t;

            clk : in std_logic;
            rst : in std_logic
        );
    end component;

    component memoryAccess is
        port(
        ALUResult, regReadData2 : in word_t;
        signExtend : in ctrl_t);
    end component;

    component writeBack is
        port(
        Link, JumpReg, JumpDir, MemToReg, TakeBranch : in ctrl_t;
        next_pc, branch_addr, jump_addr: in addr_t;
        aluResult, memReadData, regReadData1 : in word_t;
        regWriteData : out word_t;
        next_addr : out addr_t);
    end component;

    signal Link, JumpReg, JumpDir, Branch, TakeBranch, MemToReg,  SignExtend, Shift, ALUSrc : ctrl_t;
    signal next_addr, next_pc, jump_addr, branch_addr : addr_t;
    signal instr : instruction_t;
    signal zeroxed, sexed, aluResult: word_t;
    signal aluop : alu_op_t;

begin

    if1: InstructionFetch
    generic map (PC_ADD => PC_ADD, CPI => CPI)
    port map(
                clk => clk,
                rst => rst,
                next_addr => next_addr,
                next_pc => next_pc,
                instr => instr);
    id1: InstructionDecode
    port map(instr => instr,
             next_pc => next_pc,
             jump_addr => jump_addr,

             regwrite => regwrite, link => link, jumpreg => jumpreg, jumpdirect => jumpDir, branch => Branch,
             memread => memRead, memwrite => memWrite,
             memtoreg => memToReg, memsex => memSex,
             shift => shift, alusrc => aluSrc,
             aluop => aluOp,        

             readreg1 => readReg1, readreg2 => readReg2, writeReg => writeReg,

             zeroxed => zeroxed, sexed => sexed,

             clk => clk,
             rst => rst
         );
    ex1: Execute
    port map(
                next_pc => next_pc,
                regReadData1 => regReadData1, regReadData2 => regReadData2,
                branch_addr => branch_addr,
                branch_in => Branch,
                shift_in => shift, alusrc_in => ALUSrc,
                aluop_in => ALUOp,

                zeroxed => zeroxed, sexed => sexed,

                takeBranch => takeBranch,
                ALUResult => ALUResult,

                clk => clk,
                rst => rst
    );
    ma1: memoryAccess
    port map( 
                ALUResult => ALUResult,
                regReadData2 => regReadData2,
                signExtend => signExtend);
    wb1: WriteBack
    port map(
                Link => Link,
                JumpReg => JumpReg,
                JumpDir => JumpDir,
                MemToReg => MemToReg,
                TakeBranch => TakeBranch,
                next_pc => next_pc,
                branch_addr => branch_addr,
                jump_addr => jump_addr,
                aluResult => aluResult,
                memReadData => memReadData,
                regReadData1 => regReadData1,
                regWriteData => regWriteData,
                next_addr => next_addr);

end struct;
