library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity MIPSFPGA is
	port(
		clk: in std_logic;
		--tmp
		ALUZero: in ctrl_t);
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
			addr : out addr_t);
	end component;
	-- jumps
	component BranchANDZero
		port (
			Branch: in ctrl_t;
			ALUZero: in ctrl_t;
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
			jumpAddr, BranchMuxOut: in addr_t; 
			JumpDirMuxOut: out addr_t);
	end component;
	component JumpRegMux
		port (
			JumpReg: in ctrl_t;
			reg1data, JumpDirMuxOut: in addr_t;
			next_addr: out addr_t);
	end component;
	--pc
	signal Link, JumpReg, JumpDir, Branch, MemRead, MemToReg, SignExtend, MemWrite, Shift, ALUSrc, ALUOp, RegWrite, RegDst: ctrl_t; 
	signal addr: addr_t;
	signal pcPLUS4: addr_t;
	signal next_addr: addr_t;
	--jump MUXs
	signal BranchANDZeroOut: ctrl_t;
	signal BranchMuxOut: addr_t;
	signal jump_addr: addr_t;
	signal JumpDirMuxOut: addr_t;
	signal JumpRegMuxOUt: addr_t;
	begin
	control1: control
		port map (Link, JumpReg, JumpDir, Branch, MemRead, MemToReg, SignExtend, MemWrite, Shift, ALUSrc, ALUOp, RegWrite, RegDst);
	pc1: PC
		port map (next_addr, clk, addr);
	-- jumps
	branchANDZero1: BranchANDZero
		port map (Branch, ALUZero, BranchANDZeroOut);
	branchMux1: BranchMux
		port map (BranchANDZeroOut, AddrALUResult, pcPLUS4, BranchMuxOut);	
	jumpDirMux1: JumpDirMux
		port map (JumpDir, jump_addr, BranchMuxOut, JumpDirMuxOut);
	jumpRegMux1:JumpRegMux
		port map (JumpReg, reg1data, JumpDirMuxOut, next_addr);
end struct;

