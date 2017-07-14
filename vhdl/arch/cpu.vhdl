-- The CPU, only the stateless parts
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

-- We keep keep all state (registers, memory) out of the CPU
-- This allows for testbenches that can instantiate them theirselves
-- and check whether everything works as expected
entity cpu is
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

    -- multi used componets 
    component Adder is
    port(
        src1: in addr_t;
        src2: in addrdiff_t;
        result: out addr_t);
    end component;
    component maindec is
    port(
        instr : in std_logic_vector(31 downto 0);
        Link, JumpReg, JumpDirect, Branch, MemToReg, MemSex, Shift, ALUSrc, RegWrite, RegDst: out ctrl_t;
        memRead, memWrite: out ctrl_memwidth_t;
        ALUOp: out alu_op_t);
    end component;
    component PC is
    port (
        next_addr : in addr_t;
        clk : in std_logic;
        addr : out addr_t);
    end component;

    -- jumps
    component BranchANDZero
    port (
        Branch: in ctrl_t;
        ALUZero: in ctrl_t;
        output: out ctrl_t);
    end component;
    component ShiftLeftAddr
    port(
        addr: in std_logic_vector(25 downto 0);
        output: out std_logic_vector(27 downto 0));
    end component;
    component ShiftLeftImm is
    port(
        imm: in std_logic_vector (31 downto 0);
        output: out std_logic_vector (31 downto 0));
    end component;
    component BranchMux
    port (
        BranchANDZero: in ctrl_t;
        AddrALUresult, addr: in addr_t;
        output: out addr_t);
    end component;
    component JumpDirMux
    port (
        JumpDir: in ctrl_t;
        jumpAddr, BranchMux: in addr_t;
        output: out addr_t);
    end component;
    component JumpRegMux
    port (
        JumpReg: in ctrl_t;
        reg1data, JumpDirMux: in addr_t;
        output: out addr_t);
    end component;
    component InstructionMem is
    port (
        read_addr: in addr_t;
        clk : in std_logic;
        instr : out instruction_t);
    end component;
    -- ALU
    component ZeroExtender is
    port (
        shamt: reg_t;
        zeroxed: out word_t);
    end component;
    component SignExtender is
    port (
        immediate: in half_t;
        sexed: out std_logic_vector (31 downto 0)
    );
    end component;
    component shiftMux is
    port (
        Shift: in ctrl_t;
        reg1data : in word_t;
        shamt : in word_t;
        output : out word_t);
    end component;
    component ALUSrcMux is
    port (
        ALUSrc: in ctrl_t;
        reg2data : in word_t;
        immediate : in std_logic_vector (31 downto 0);
        output : out word_t);
    end component;
    component alu is
    port(
        Src1       : in word_t;
        Src2       : in word_t;
        ALUOp      : in alu_op_t;
        AluResult  : out word_t;
        Zero       : out std_logic;
        trap       : out traps_t
    );
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
        regDstMux : in reg_t;
        output : out reg_t);
    end component;
    component regDstMux is
    port (
        RegDst: in ctrl_t;
        rt : in reg_t; --Instruction 20-16
        rd : in reg_t; --Instruction 15-11
        output : out reg_t);
    end component;
    component linkMux is
    port (
        Link : in ctrl_t;
        pc: in word_t;
        memToRegMux: in word_t;
        output: out word_t);
    end component;
    component memToRegMux is
    port (
        MemtoReg: in ctrl_t;
        aluResult : in word_t;
        memReadData : in word_t;
        output : out word_t);
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

    -- pc
    signal addr, pcAddOut, next_addr, read_addr: addr_t;

    --control signals
    signal Link, JumpReg, JumpDir, Branch, MemToReg, Shift, ALUSrc, RegDst, returnAddrControl, BranchORJumpDirOut: ctrl_t;
    signal ALUOp: alu_op_t;

    --jump MUXs signals
    signal inst25to0: std_logic_vector (25 downto 0);
    signal inst27to0: std_logic_vector (27 downto 0);
    signal BranchANDZeroOut: ctrl_t;
    signal BranchMuxOut, BranchAddOut: addr_t;
    alias pcLast4 is pcAddOut (31 downto 28);	
    signal jump_addr: addr_t; --concat pcAddOut 31-28 to inst27to0
    signal JumpDirMuxOut, JumpRegMuxOUt: addr_t;

    -- instructions
    signal instr: instruction_t;
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
    signal Zero: ctrl_t;

    -- regFile Signals
    signal regDstMuxOut, returnAddrMuxOut, returnAddrReg: reg_t;
    signal linkMuxOut, memToRegMuxOut : word_t;

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
    pc1: PC
    port map (
        next_addr => next_addr,
        clk => clk,
        addr => addr
    );

    maindec1: maindec
    port map (instr => instr, Link => Link, JumpReg => JumpReg, JumpDirect => JumpDir, Branch =>Branch, MemToReg => MemToReg, MemSex => MemSex, Shift => Shift, ALUSrc => ALUSrc, RegWrite => RegWrite, RegDst => RegDst, memRead => memRead, memWrite => memWrite, ALUOp => ALUOp);

    -- jumps
    shiftLeftAddr1: shiftLeftAddr
    port map(addr => inst25to0, output => inst27to0);
    shiftLeftImm1: shiftLeftImm
    port map(imm => immExt, output => immExtShift);
    branchANDZero1: BranchANDZero
    port map (Branch => Branch, ALUZero => Zero, output => BranchANDZeroOut);
    branchMux1: BranchMux
    port map (BranchANDZero => BranchANDZeroOut, AddrALUresult => BranchAddOut, addr => pcAddOut, output => BranchMuxOut);
    jumpDirMux1: JumpDirMux
    port map (JumpDir => JumpDir, jumpAddr => jump_addr, BranchMux => BranchMuxOut, output => JumpDirMuxOut);
    jumpRegMux1:JumpRegMux
    port map (JumpReg, reg1Data => regReadData1, JumpDirMux => JumpDirMuxOut, output => next_addr);
    instructionMem1: InstructionMem
    port map (read_addr, clk, instr);
    zeroExtender1: ZeroExtender
    port map (shamt => shamt, zeroxed => shamtExt);
    signExtender1: SignExtender
    port map (immediate => imm, sexed => immExt);
    shiftMux1: shiftMux
    port map (Shift => Shift, reg1data => regReadData1, shamt => shamtExt, output => Src1);

    --alu
    aluSrcMux1: aluSrcMux
    port map (ALUSrc => ALUSrc, reg2data => regReadData2, immediate => immExt, output => Src2);
    alu1: alu
    port map (Src1, Src2, ALUOp, AluResult, Zero);

    --regFile
    regDstMux1: regDstMux
    port map (RegDst => RegDst, rt => rt, rd => rd, output => RegDstMuxOut);
    returnAddrMux1: returnAddrMux
    port map (returnAddrControl => returnAddrControl, returnAddrReg => returnAddrReg, regDstMux => regDstMuxOut, output => returnAddrMuxOut);

    linkMux1: linkMux
    port map(Link => Link, pc => pcAddOut, memToRegMux => memToRegMuxOut, output => linkMuxOut);
    memToRegMux1: memToRegMux
    port map(MemtoReg => memToReg, aluresult => ALUResult, memReadData => memReadData, output => memToRegMuxOut);

end struct;

