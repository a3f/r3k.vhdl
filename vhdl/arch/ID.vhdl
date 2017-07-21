-- Instruction Decode
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

entity InstructionDecode is
    port (
        instr : in instruction_t;
        pc_plus_4 : in addr_t;
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
        rst : in std_logic
    );
end;

architecture struct of InstructionDecode is

    -- multi used componets 
    component maindec is
    port(
        instr : in std_logic_vector(31 downto 0);
        Link, JumpReg, JumpDirect, Branch, MemToReg, MemSex, Shift, ALUSrc, RegWrite, RegDst: out ctrl_t;
        memRead, memWrite: out ctrl_memwidth_t;
        ALUOp: out alu_op_t);
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

    -- control signals consumed internally
    signal iRegWrite, iRegDst, iLink, iJumpReg, iJumpDirect, iBranch, iMemToReg, iMemSex, iShift, iALUSrc, ireturnAddrControl, iBranchORJumpDirOut: ctrl_t;
    signal iMemRead, iMemWrite : ctrl_memwidth_t;
    signal iAluOp : alu_op_t;
    signal iReadReg1, iReadReg2, iWriteReg : reg_t;
    signal returnAddrControl : ctrl_t;

    -- instruction signals
    alias op is instr(31 downto 26);
    alias rs is instr(25 downto 21);
    alias rt is instr(20 downto 16);
    alias rd is instr(15 downto 11);
    alias shamt is instr(10 downto 6);
    alias func is instr(5 downto 0);
    alias imm is instr(15 downto 0);
    alias jump_immediate is instr(25 downto 0);

    -- regFile Signals
    signal regDstMuxOut, returnAddrMuxOut : reg_t;

    constant zeroes : half_t := (others => '0');
    constant ones   : half_t := (others => '1');
begin

    -- immediates
    jump_addr <= pc_plus_4(31 downto 28) & jump_immediate & "00";
    returnAddrControl <= (iBranch or iJumpDirect) and iLink;
    zeroxed <= (31 downto 5 => '0') & shamt;
    sexed <= zeroes & imm when imm(15) = '0' else ones & imm;

    maindec1: maindec
    port map (instr      => instr,
              Link       => iLink,
              JumpReg    => iJumpReg,
              JumpDirect => iJumpDirect,
              Branch     => iBranch,
              MemToReg   => iMemToReg,
              MemSex     => iMemSex,
              Shift      => iShift,
              ALUSrc     => iALUSrc,
              RegWrite   => iRegWrite,
              RegDst     => iRegDst,
              memRead    => imemRead,
              memWrite   => imemWrite,
              ALUOp      => iALUOp);


    --regFile
    regDstMux1: regDstMux
    port map (RegDst => iRegDst, rt => rt, rd => rd, output => RegDstMuxOut);
    returnAddrMux1: returnAddrMux
    port map (returnAddrControl => returnAddrControl, returnAddrReg => R31, regDstMux => regDstMuxOut, output => iWritereg);

    RegWrite   <= iRegWrite;
    Link       <= iLink;
    JumpReg    <= iJumpReg;
    JumpDirect <= iJumpDirect;
    Branch     <= iBranch;
    MemRead    <= iMemRead;
    MemToReg   <= iMemToReg;
    MemSex     <= iMemSex;
    memWrite   <= iMemWrite;
    Shift      <= iShift;
    ALUSrc     <= iALUSrc;
    AluOp      <= iAluOp;

    process(instr) begin printf(ANSI_RED & "Decoding instruction %s\n", instr); end process;
    process(instr) begin printf(ANSI_RED & "readreg1=%s, readreg2=%s, writereg %s\n", iReadreg1, iReadreg2, iWritereg); end process;

    ReadReg1 <= rs;
    ReadReg2 <= rt;

    iReadReg1 <= rs;
    iReadReg2 <= rt;
    WriteReg <= iWriteReg;
end struct;
