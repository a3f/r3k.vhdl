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
	-- TODO: check order with entity
	component Control is
		port(
			Link, JumpReg, JumpDir, Branch, MemRead, MemToReg, SignExtend, MemWrite, Shift, ALUSrc, ALUOp, RegWrite, RegDst: out ctrl_t
			);
	end component;
	component PC is
		port (
			next_addr 	: in addr_t;
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
	--TODO: pcAdd etc.
	component ShiftLeftAddr
		port(
			Inst25to0: in std_logic_vector(25 downto 0);
			Inst28to0: out std_logic_vector(28 downto 0));
	end component;
	component BranchMux
		port (
			BranchANDZeroOut: in ctrl_t;
			AddrALUResult, addr2: in addr_t;
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
	component ZeroExtender is
		port (
			shamt: reg_t;
			shamtExt: out word_t);
	end component;
	component SignExtender is
		port (
			imm: in halfword_t;
			immExt: out word_t
			);
	end component;
	component shiftMux is 
		port (
			Shift: in ctrl_t;
			reg1data : in word_t;
			shamtExt : in word_t;
			output : out word_t);
	end component;
	component ALUSrcMux is 
		port (
			ALUSrc: in ctrl_t;
			reg2data : in word_t;
			immExt : in word_t;
			output : out word_t);
	end component;
	component AluControl
		port(
			AluOp: in ctrl_t;
			func: in func_t; --instruction 5-0
			AluControlOut: out alu_op_t
			);
	end component;
	component alu is
  		port(	
			Src1       : in word_t;
			Src2       : in word_t;
			AluControlOut      : in alu_op_t;
       			AluResult  : out word_t;
       			Zero       : out std_logic);
	end component;
	--control signals
	signal Link, JumpReg, JumpDir, Branch, MemRead, MemToReg, SignExtend, MemWrite, Shift, ALUSrc, ALUOp, RegWrite, RegDst: ctrl_t; 
	-- pc 
	signal read_addr: addr_t;
	signal addr: addr_t; --TODO: pcAdd
	signal next_addr: addr_t;
	--jump MUXs signals
	signal BranchANDZeroOut: ctrl_t;
	signal BranchMuxOut: addr_t;
	signal jump_addr: addr_t; --TODO: pcAdd
	signal JumpDirMuxOut, JumpRegMuxOUt: addr_t;
	-- instructions
	signal instr: instruction_t; --TODO: type? Instruction output is instruction_t, but all inputs are reg_t, here actual std_logic_vectors would be much cleaner.
	alias op is instr(31 downto 26);
	alias rs is instr(25 downto 21);
	alias rt is instr(20 downto 16);
	alias rd is instr(15 downto 11);
	alias shamt is instr(10 downto 6);
	alias func is instr(5 downto 0);
	alias imm 	 is instr(15 downto 0);
	signal immExt, shamtExt: word_t;
	signal Src1, Src2, ALUResult: word_t;
	signal AluControlOut: alu_op_t;
	signal reg1data, reg2data: word_t;
	signal Zero: ctrl_t;
	begin
	control1: control
		port map (Link, JumpReg, JumpDir, Branch, MemRead, MemToReg, SignExtend, MemWrite, Shift, ALUSrc, ALUOp, RegWrite, RegDst);
	pc1: PC
		port map (next_addr, clk, addr);
	-- jumps
	branchANDZero1: BranchANDZero
		port map (Branch, Zero, BranchANDZeroOut);
	branchMux1: BranchMux
		port map (BranchANDZeroOut, AddrALUResult, addr, BranchMuxOut);	
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
		port map (Shift, reg1data, shamtExt, Src1);
	aluSrcMux1: aluSrcMux
		port map (ALUSrc, reg2data, immExt, Src2);
	aluControl1: aluControl
		port map (AluOP, func, AluControlOut);
	alu1: alu
		port map (Src1, Src2, AluControlOut, AluResult, Zero);
end struct;

