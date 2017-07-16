library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity WriteBack is
   port(
	Link, JumpReg, JumpDir, MemToReg, TakeBranch : in ctrl_t;
	next_pc, branch_addr, jump_addr: in addr_t;
	aluResult, memReadData, regReadData1 : in word_t;
	regWriteData : out word_t;

	next_addr : out addr_t);
end;

architecture struct of WriteBack is

component BranchMux is
    port (
        BranchANDZero: in ctrl_t;
        AddrALUresult, addr: in addr_t;
        output: out addr_t);
end component;

component JumpDirMux is
    port (
        JumpDir: in ctrl_t;
        jumpAddr, BranchMux: in addr_t;
        output: out addr_t);
end component;

component JumpRegMux is
    port (
        JumpReg: in ctrl_t;
        reg1data, JumpDirMux: in addr_t;
        output: out addr_t);
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

signal BranchMuxOut, JumpDirMuxOut : addr_t;
signal MemToRegMuxOut : word_t; 

begin

branchMux1: BranchMux
    port map (BranchANDZero => TakeBranch, AddrALUresult => branch_addr, addr => next_pc, output => BranchMuxOut);
    jumpDirMux1: JumpDirMux
    port map (JumpDir => JumpDir, jumpAddr => jump_addr, BranchMux => BranchMuxOut, output => JumpDirMuxOut);
    jumpRegMux1:JumpRegMux
    port map (JumpReg => JumpReg, reg1Data => regReadData1, JumpDirMux => JumpDirMuxOut, output => next_addr); 	
 linkMux1: linkMux
    port map(Link => Link, pc => next_pc, memToRegMux => memToRegMuxOut, output => regWriteData);
    memToRegMux1: memToRegMux
    port map(MemtoReg => memToReg, aluresult => ALUResult, memReadData => memReadData, output => memToRegMuxOut);

end struct;
