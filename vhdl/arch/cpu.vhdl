-- The CPU, only the stateless parts
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.memory_map.all;

-- We keep keep all state (registers, memory) out of the CPU
-- This allows for testbenches that can instantiate them theirselves
-- and check whether everything works as expected
entity cpu is
    generic(PC_ADD : natural := 4;
               CPI : natural := 5;
               SINGLE_ADDRESS_SPACE : boolean := true);
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
    top_addr : out addr_t;
    top_dout : in word_t;
    top_din : out word_t;
    top_size : out ctrl_memwidth_t;
    top_wr : out ctrl_t
);
end;

architecture struct of cpu is

    component InstructionFetch is
        generic(PC_ADD : natural := PC_ADD;
                CPI : natural := CPI;
                SINGLE_ADDRESS_SPACE : boolean := SINGLE_ADDRESS_SPACE);
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
    end component;

    component InstructionDecode is
        port(
            instr : in instruction_t;
            pc_plus_4 : in addr_t;
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
            pc_plus_4 : in addr_t;
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

    component MemoryAccess is
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
        top_wr : out ctrl_t);
    end component;

    component WriteBack is
        port(
        Link, JumpReg, JumpDir, MemToReg, TakeBranch : in ctrl_t;
        pc_plus_4, branch_addr, jump_addr: in addr_t;
        aluResult, memReadData, regReadData1 : in word_t;
        regWriteData : out word_t;
        new_pc : out addr_t);
    end component;

    signal Link, JumpReg, JumpDir, Branch, TakeBranch, MemToReg, SignExtend, Shift, ALUSrc, MemSex : ctrl_t;
    signal MemRead, MemWrite : ctrl_memwidth_t;
    signal memReadData : word_t;
    signal new_pc : addr_t := BOOT_ADDR;
    signal pc_plus_4, jump_addr, branch_addr : addr_t;
    signal instr : instruction_t;
    signal zeroxed, sexed, aluResult: word_t;
    signal aluop : alu_op_t;

begin

    if1: InstructionFetch
    generic map (PC_ADD => PC_ADD, CPI => CPI)
    port map(
                clk => clk,
                rst => rst,
                new_pc => new_pc,
                pc_plus_4 => pc_plus_4,
                instr => instr,

                top_addr => top_addr,
                top_dout => top_dout,
                top_din => top_din,
                top_size => top_size,
                top_wr => top_wr
            );
    id1: InstructionDecode
    port map(instr => instr,
             pc_plus_4 => pc_plus_4,
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
                pc_plus_4 => pc_plus_4,
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
        -- inbound
        Address_in => AluResult,
        WriteData_in => regReadData2,
        ReadData_in => memReadData,
        MemRead_in => memRead, MemWrite_in => memWrite,
        MemSex_in => MemSex,
        clk => clk,

        -- outbound to top level module
        top_addr => top_addr,
        top_dout => top_dout,
        top_din => top_din,
        top_size => top_size,
        top_wr => top_wr);

    wb1: WriteBack
    port map(
                Link => Link,
                JumpReg => JumpReg,
                JumpDir => JumpDir,
                MemToReg => MemToReg,
                TakeBranch => TakeBranch,
                pc_plus_4 => pc_plus_4,
                branch_addr => branch_addr,
                jump_addr => jump_addr,
                aluResult => aluResult,
                memReadData => memReadData,
                regReadData1 => regReadData1,
                regWriteData => regWriteData,
                new_pc => new_pc);

end struct;
