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
    component Pipeliner is
    port(
        clk, rst : in std_logic;
        ID_en, IF_en, EX_en, MEM_en, WB_en : out std_logic
    );
    end component;

    component PipeReg is
    generic (BITS : natural := 32);
	port(
 	   data   : in std_logic_vector(BITS-1 downto 0);
 	   enable  : in std_logic; -- load/enable.
	   clr : in std_logic; -- async. clear.
 	   clk : in std_logic; -- clock.
  	   output   : out std_logic_vector(BITS-1 downto 0) -- output.
	);
    end component;

    component CtrlReg is port(
 	   data   : in std_logic;
 	   enable  : in std_logic; -- load/enable.
	   clr : in std_logic; -- async. clear.
 	   clk : in std_logic; -- clock.
  	   output   : out std_logic
	);
    end component;

    component AluOpReg is port(
 	   data   : in alu_op_t;
 	   enable  : in std_logic; -- load/enable.
	   clr : in std_logic; -- async. clear.
 	   clk : in std_logic; -- clock.
  	   output   : out alu_op_t
	);
    end component;

    component InstructionFetch is
        generic(PC_ADD : natural := PC_ADD;
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

    signal IF_en  : std_logic := '0';
    signal ID_en  : std_logic := '0';
    signal EX_en  : std_logic := '0';
    signal MEM_en : std_logic := '0';
    signal WB_en  : std_logic := '0';

    signal regwrite_pre_reg : ctrl_t;
    signal Link, JumpReg, JumpDir, Branch,  MemToReg, Shift, ALUSrc, MemSex : ctrl_t;
    signal Link_pre_reg, JumpReg_pre_reg, JumpDir_pre_reg, Branch_pre_reg,  MemToReg_pre_reg, Shift_pre_reg, ALUSrc_pre_reg, MemSex_pre_reg : ctrl_t;
    signal TakeBranch, TakeBranch_pre_reg : ctrl_t;
    signal MemRead, MemWrite : ctrl_memwidth_t;
    signal MemRead_pre_reg, MemWrite_pre_reg : ctrl_memwidth_t;
    signal memReadData, memReadData_pre_reg : word_t;
    signal new_pc, new_pc_pre_reg : addr_t := BOOT_ADDR;
    signal pc_plus_4, pc_plus_4_pre_reg, jump_addr, jump_addr_pre_reg, branch_addr : addr_t;
    signal instr, instr_pre_reg : instruction_t;
    signal zeroxed, sexed, zeroxed_pre_reg, sexed_pre_reg, aluResult, aluResult_pre_reg: word_t;

    signal readreg1_pre_reg, readreg2_pre_reg, writereg_pre_reg : reg_t;

    signal regwritedata_pre_reg : word_t;
    signal aluop : alu_op_t;
    signal aluop_slv : natural; -- debug only;
    signal aluop_pre_reg : alu_op_t;

begin
    aluop_slv <= alu_op_t'pos(aluop);

    if1: InstructionFetch
    generic map (PC_ADD => PC_ADD)
    port map(
                clk => clk,
                rst => rst,
                new_pc => new_pc,
                pc_plus_4 => pc_plus_4_pre_reg,
                instr => instr_pre_reg,

                top_addr => top_addr,
                top_dout => top_dout,
                top_din => top_din,
                top_size => top_size,
                top_wr => top_wr
            );

    new_pc_reg: PipeReg
    generic map(32)
    port map (
		data => new_pc_pre_reg,
        enable => WB_en,
		clr => rst,
		clk => clk,
		output => new_pc
		);

    pc_plus_4_reg: PipeReg
    generic map(32)
    port map (
		data => pc_plus_4_pre_reg,
        enable => IF_en,
		clr => rst,
		clk => clk,
		output => pc_plus_4
		);

    instr_reg: PipeReg
    generic map(32)
    port map (
		data => instr_pre_reg,
		enable => IF_en,
		clr => rst,
		clk => clk,
		output => instr
		);

    id1: InstructionDecode
    port map(
	     instr => instr,
             pc_plus_4 => pc_plus_4,
             jump_addr => jump_addr_pre_reg,
             regwrite => regwrite_pre_reg, link => link_pre_reg, jumpreg => jumpreg_pre_reg, jumpdirect => jumpDir_pre_reg, branch => Branch_pre_reg,
             memread => memRead, memwrite => memWrite,
             memtoreg => memToReg_pre_reg, memsex => memSex_pre_reg,
             shift => shift_pre_reg, alusrc => aluSrc_pre_reg,
             aluop => aluOp_pre_reg,

             readreg1 => readReg1_pre_reg, readreg2 => readReg2_pre_reg, writeReg => writeReg_pre_reg,

             zeroxed => zeroxed_pre_reg, sexed => sexed_pre_reg,

             clk => clk,
             rst => rst
         );
    readreg1_reg: PipeReg
    generic map(5)
    port map (
		data => readreg1_pre_reg,
		enable => ID_en,
		clr => rst,
		clk => clk,
		output => readreg1
    );
    readreg2_reg: PipeReg
    generic map(5)
    port map (
		data => readreg2_pre_reg,
		enable => ID_en,
		clr => rst,
		clk => clk,
		output => readreg2
    );
    writereg_reg: PipeReg
    generic map(5)
    port map (
		data => writereg_pre_reg,
		enable => ID_en,
		clr => rst,
		clk => clk,
		output => writereg
    );

    pipeliner1: pipeliner port map (
        clk => clk,
        rst => rst,
        IF_en => IF_en,
        ID_en => ID_en,
        EX_en => EX_en,
        MEM_en => MEM_en,
        WB_en => WB_en
    );

    ctrlvec_regwrite_reg : CtrlReg port map (data => regwrite_pre_reg, enable => ID_en, clr => rst, clk => clk, output => regwrite);
    --ctrlvec_regdst_reg : CtrlReg port map (data => regdst_pre_reg, enable => ID_en, clr => rst, clk => clk, output => regdst);
    ctrlvec_link_reg : CtrlReg port map (data => link_pre_reg, enable => ID_en, clr => rst, clk => clk, output => link);
    ctrlvec_jumpreg_reg : CtrlReg port map (data => jumpreg_pre_reg, enable => ID_en, clr => rst, clk => clk, output => jumpreg);
    ctrlvec_jumpdirect_reg : CtrlReg port map (data => jumpdir_pre_reg, enable => ID_en, clr => rst, clk => clk, output => jumpdir);
    ctrlvec_branch_reg : CtrlReg port map (data => branch_pre_reg, enable => ID_en, clr => rst, clk => clk, output => branch);
    ctrlvec_memread_reg : PipeReg generic map(2) port map (data => memread_pre_reg, enable => ID_en, clr => rst, clk => clk, output => memread);
    ctrlvec_memtoreg_reg : CtrlReg port map (data => memtoreg_pre_reg, enable => ID_en, clr => rst, clk => clk, output => memtoreg);
    ctrlvec_memsex_reg : CtrlReg port map (data => memsex_pre_reg, enable => ID_en, clr => rst, clk => clk, output => memsex);
    ctrlvec_memwrite_reg : PipeReg generic map (2) port map (data => memwrite_pre_reg, enable => ID_en, clr => rst, clk => clk, output => memwrite);
    ctrlvec_shift_reg : CtrlReg port map (data => shift_pre_reg, enable => ID_en, clr => rst, clk => clk, output => shift);
    ctrlvec_alusrc_reg : CtrlReg port map (data => alusrc_pre_reg, enable => ID_en, clr => rst, clk => clk, output => alusrc);
    ctrlvec_aluop_reg : AluOpReg port map (data => aluop_pre_reg, enable => ID_en, clr => rst, clk => clk, output => aluop);


    jump_addr_reg: PipeReg
    generic map(32)
    port map (
		data => jump_addr_pre_reg,
        enable => ID_en,
		clr => rst,
		clk => clk,
		output => jump_addr
		);

    zeroxed_reg: PipeReg
    generic map(32)
    port map (
		data => zeroxed_pre_reg,
		enable => ID_en,
		clr => rst,
		clk => clk,
		output => zeroxed
		);
    sexed_reg: PipeReg
    generic map(32)
    port map (
		data => sexed_pre_reg,
		enable => ID_en,
		clr => rst,
		clk => clk,
		output => sexed
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

                takeBranch => takeBranch_pre_reg,
                ALUResult => ALUResult_pre_reg,

                clk => clk,
                rst => rst
    );

    takeBranch_reg: CtrlReg
    port map (
		data =>takeBranch_pre_reg,
		enable => EX_en,
		clr => rst,
		clk => clk,
		output => takeBranch
		);
    aluResult_reg: PipeReg
    generic map(32)
    port map (
		data => aluResult_pre_reg,
		enable => EX_en,
		clr => rst,
		clk => clk,
		output => aluResult
		);
    ma1: memoryAccess
    port map(
        -- inbound
        Address_in => AluResult,
        WriteData_in => regReadData2,
        ReadData_in => memReadData,
        MemRead_in => memRead,
	MemWrite_in => memWrite,
        MemSex_in => MemSex,
        clk => clk,

        -- outbound to top level module
        top_addr => top_addr,
        top_dout => top_dout,
        top_din => top_din,
        top_size => top_size,
        top_wr => top_wr);

    memReadData_reg: PipeReg
    generic map (32)
    port map (
		data => memReadData_pre_reg,
		enable => MEM_en,
		clr => rst,
		clk => clk,
		output => memReadData
		);
    regWrite_data_reg: PipeReg
    generic map(32)
    port map (
		data => regwritedata_pre_reg,
		enable => WB_en,
		clr => rst,
		clk => clk,
		output => regwritedata
		);
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
                regWriteData => regWriteData_pre_reg,
                new_pc => new_pc_pre_reg);

end struct;
