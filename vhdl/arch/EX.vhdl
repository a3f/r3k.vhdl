-- Execute
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity Execute is
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
end;

architecture struct of Execute is

    -- multi used componets 
    component Adder is
    port(
        src1: in addr_t;
        src2: in addrdiff_t;
        result: out addr_t);
    end component;
    component ShiftLeftImm is
    port(
        imm: in std_logic_vector (31 downto 0);
        output: out std_logic_vector (31 downto 0));
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
        immediate : in word_t;
        output : out word_t);
    end component;
    component alu is
    port(
        Src1       : in word_t;
        Src2       : in word_t;
        ALUOp      : in alu_op_t;
        Immediate  : in ctrl_t;
        AluResult  : out word_t;
        isZero     : out ctrl_t;
        trap       : out traps_t
    );
    end component;

    -- pc
    signal branch_offset : addrdiff_t;

    -- ALU signals
    signal Src1, Src2 : word_t;

    signal isZero : ctrl_t;

begin
    shiftLeftImm1: shiftLeftImm
    port map(imm => sexed, output => branch_offset);

    branchAdd: Adder
    port map(
        src1 => pc_plus_4,
        src2 => branch_offset,
        result => branch_addr
    );

    shiftMux1: shiftMux
    port map (Shift => Shift_in, reg1data => regReadData1, shamt => zeroxed, output => Src1);

    --alu
    aluSrc2Mux1: aluSrcMux
    port map (ALUSrc => AluSrc_in, reg2data => regReadData2, immediate => sexed, output => Src2);
    alu1: alu
    port map (Src1 => Src1, Src2 => Src2, AluOp => ALUOp_in, Immediate => AluSrc_in, AluResult => AluResult, isZero => isZero);

    takebranch <= Branch_in and isZero;

end struct;
