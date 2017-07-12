library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity MIPSFPGA is
port(
        clk: in std_logic;
        --tmp
        ALUZero: in ctrl_t;
AddrALUresult: in addr_t);
end ;

architecture struct of MIPSFPGA is
-- multi used componets
component Adder is
port(
	src1: in addr_t;
	src2: in addrdiff_t;
	result: addr_t);
end component;
-- TODO: check order with entity
component Control is
port(
        Link, JumpReg, JumpDir, Branch, MemToReg, SignExtend, Shift, ALUSrc, RegWrite, RegDst: out ctrl_t;
        memRead, memWrite: out ctrl_memwidth_t;
	ALUOp: out alu_op_t);
end component;
component PC is
port (
        next_addr : in addr_t;
	clk : in std_logic;
	read_addr : out addr_t);
end component;
-- jumps
component BranchANDZero
port (
        Branch: in ctrl_t;
	Zero: in ctrl_t;
	BranchANDZeroOut: out ctrl_t);
end component;
component ShiftLeftAddr
port(
        Inst25to0: in std_logic_vector(25 downto 0);
	Inst27to0: out std_logic_vector(27 downto 0));
end component;
component ShiftLeftImm is
port(
	immExt: in std_logic_vector (31 downto 0);
	immExtShift: out std_logic_vector (31 downto 0));
end component;
component BranchMux
port (
        BranchANDZeroOut: in ctrl_t;
        AddrALUResult, pcAddOut: in addr_t;
	BranchMuxOut: out addr_t);
end component;
component JumpDirMux
port (
        JumpDir: in ctrl_t;
        jump_addr, BranchMuxOut: in addr_t;
	JumpDirMuxOut: out addr_t);
end component;
component JumpRegMux
port (
        JumpReg: in ctrl_t;
        reg1data, JumpDirMuxOut: in addr_t;
	next_addr: out addr_t);
end component;
component InstructionMem is
port (
        read_addr : in addr_t;
	clk : in std_logic;
	instr : out instruction_t);
end component;
-- ALU
component ZeroExtender is
port (
        shamt: reg_t;
	shamtExt: out word_t);
end component;
component SignExtender is
port (
        imm: in halfword_t;
	immExt: out std_logic_vector (31 downto 0)
);
end component;
component shiftMux is
port (
        Shift: in ctrl_t;
	readData1 : in word_t;
	shamtExt : in word_t;
	shiftMuxOut : out word_t);
end component;
component ALUSrcMux is
port (
        ALUSrc: in ctrl_t;
	readData2 : in word_t;
	immExt : in std_logic_vector (31 downto 0);
	ALUSrcMuxOut : out word_t);
end component;
component alu is
port(
	Src1       : in word_t;
	Src2       : in word_t;
	ALUOp      : in alu_op_t;
	AluResult  : out word_t;
	Zero       : out std_logic);
end component;
component regFile is
port (
        -- static
        readreg1, readreg2 : in reg_t;
	writereg: in reg_t;
	writedata: in word_t;
	readData1, readData2 : out word_t;
	clk : in std_logic;
	regWrite : in std_logic);
end component;
component returnAddrMux is
port (
        returnAddrControl: in ctrl_t;
	returnAddrReg : in reg_t;
	regDstMuxOut : in reg_t;
	returnAddrMuxOut : out reg_t);
end component;
component regDstMux is
port (
        RegDst: in ctrl_t;
	rt : in reg_t; --Instruction 20-16
	rd : in reg_t; --Instruction 15-11
	regDstMuxOut : out reg_t);
end component;
component linkMux is
port (
        Link : in ctrl_t;
	pcAddOut : in word_t;
	memToRegMuxOut: in word_t;
	linkMuxOut: out word_t);
end component;
component memToRegMux is
port (
        MemtoReg: in ctrl_t;
	aluResult : in word_t;
	memReadData : in word_t;
	memToRegMuxOut : out word_t);
end component;
component DataMem is
port (
        Address : in addr_t;
	WriteData : in word_t;
	memReadData : out word_t;
	MemRead, MemWrite : in ctrl_memwidth_t;
	MemSex : in std_logic;
clk : in std_logic
);
end component;
component BranchORJumpDir is
port (
        Branch: in ctrl_t;
	JumpDir : in ctrl_t;
	BranchOrJumpDirOut : out ctrl_t);
end component;
component LinkANDBranchORJumpDir is
port (
        BranchORJumpDirOut: in ctrl_t;
	Link : in ctrl_t;
	returnAddrControl : out ctrl_t);
end component;
--control signals
signal Link, JumpReg, JumpDir, Branch, MemToReg, SignExtend, Shift, ALUSrc, RegWrite, RegDst, returnAddrControl, BranchORJumpDirOut: ctrl_t;
signal ALUOp: alu_op_t;
-- pc
signal addr, pcAddOut, next_addr, read_addr: addr_t;
--jump MUXs signals
signal inst25to0: std_logic_vector (25 downto 0);
signal inst27to0: std_logic_vector (27 downto 0);
signal BranchANDZeroOut: ctrl_t;
signal BranchMuxOut, BranchAddOut: addr_t;
alias pcLast4 is pcAddOut (31 downto 28);	
signal jump_addr: addr_t; --TODO: concat pcAddOut 31-28 to inst27to0
signal JumpDirMuxOut, JumpRegMuxOUt: addr_t;
-- instructions
signal instr: instruction_t; --TODO: type? Instruction output is instruction_t, but all inputs are reg_t, here actual std_logic_vectors would be much cleaner.
-- instruction signals
alias op is instr(31 downto 26);
alias rs is instr(25 downto 21);
alias rt is instr(20 downto 16);
alias rd is instr(15 downto 11);
alias shamt is instr(10 downto 6);
alias func is instr(5 downto 0);
alias imm is instr(15 downto 0);
-- ALU signals
signal immExt, immExtShift: std_logic_vector (31 downto 0);
signal shamtExt : word_t;
signal Src1, Src2, ALUResult: word_t;
signal reg1data, reg2data: word_t;
signal Zero: ctrl_t;
-- regFile Signals
signal regDstMuxOut, returnAddrMuxOut, returnAddrReg: reg_t;
signal writedata, readdata1, readdata2: word_t;
signal linkMuxOut, memToRegMuxOut, memReadData: word_t;
signal memRead, memWrite: ctrl_memwidth_t;
signal memSex: std_logic;
begin
jump_addr <= pcLast4 & inst27to0;
pcAdd: Adder
port map(
	src1 => read_addr,
	src2 => X"0000_0004",
	result => pcAddOut);
branchAdd: Adder
port map(
	src1 => pcAddOut,
	src2 => immExtShift,
	result => BranchAddOut
);
control1: control
port map (Link, JumpReg, JumpDir, Branch, MemToReg, SignExtend, Shift, ALUSrc, RegWrite, RegDst, memRead, memWrite, ALUOp);
pc1: PC
port map (next_addr, clk, addr);
-- jumps
shiftLeftAddr1: shiftLeftAddr
port map(inst25to0, inst27to0);
shiftLeftImm1: shiftLeftImm
port map(immExt, immExtShift);
branchANDZero1: BranchANDZero
port map (Branch, Zero, BranchANDZeroOut);
branchMux1: BranchMux
port map (BranchANDZeroOut, AddrALUResult, pcAddOut, BranchMuxOut);
jumpDirMux1: JumpDirMux
port map (JumpDir, jump_addr, BranchMuxOut, JumpDirMuxOut);
jumpRegMux1:JumpRegMux
port map (JumpReg, reg1data, JumpDirMuxOut, next_addr);
instructionMem1: InstructionMem
port map (read_addr, clk, instr);
zeroExtender1: ZeroExtender
port map (shamt, shamtExt);
signExtender1: SignExtender
port map (imm, immExt);
shiftMux1: shiftMux
port map (Shift, readData1, shamtExt, Src1);
--alu
aluSrcMux1: aluSrcMux
port map (ALUSrc, readData2, immExt, Src2);
alu1: alu
port map (Src1, Src2, ALUOp, AluResult, Zero);
--regFile
regDstMux1: regDstMux
port map (RegDst, rt, rd, RegDstMuxOut);
returnAddrMux1: returnAddrMux
port map (returnAddrControl, returnAddrReg, regDstMuxOut, returnAddrMuxOut);
regfile1: regFile
port map(
        rs, rt, returnAddrMuxOut, writedata, readData1, readData2, clk, regWrite);
linkMux1: linkMux
port map(Link, pcAddOut, memToRegMuxOut, linkMuxOut);
memToRegMux1: memToRegMux
port map(memToReg, ALUResult, memReadData, memToRegMuxOut);
dataMem1: DataMem
port map(ALUResult, ReadData2, memReadData, memRead, memWrite, memSex, clk);
end struct;

