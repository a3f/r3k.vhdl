library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity WriteBack is
   port(
	Link, JumpReg, JumpDir, MemToReg, TakeBranch : in ctrl_t;
	pc_out, branch_addr, jump_addr: in addr_t;
	aluResult, memReadData : in word_t;
	memWriteData : out word_t;
	pc_in : out addr_t);
end;

arichtecture struct of WriteBack is

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
signal LinkMuxOut : word_t;

begin

branchMux1: BranchMux
    port map (BranchANDZero => BranchANDZeroOut, AddrALUresult => BranchAddOut, addr => pcAddOut, output => BranchMuxOut);
    jumpDirMux1: JumpDirMux
    port map (JumpDir => JumpDir, jumpAddr => jump_addr, BranchMux => BranchMuxOut, output => JumpDirMuxOut);
    jumpRegMux1:JumpRegMux
    port map (JumpReg => JumpReg, reg1Data => regReadData1, JumpDirMux => JumpDirMuxOut, output => next_addr);
 linkMux1: linkMux
    port map(Link => Link, pc => pcAddOut, memToRegMux => memToRegMuxOut, output => linkMuxOut);
    memToRegMux1: memToRegMux
    port map(MemtoReg => memToReg, aluresult => ALUResult, memReadData => memReadData, output => memToRegMuxOut);

end;
end struct;
