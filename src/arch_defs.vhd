library IEEE;
use IEEE.STD_LOGIC_1164.all;

package arch_defs is



    function is_type_r(vec: std_logic_vector) return boolean;
    function is_type_j(vec: std_logic_vector) return boolean;
    function J(op : std_logic_vector) return std_logic_vector;
    function I(op : std_logic_vector; rs : std_logic_vector := "-----"; rt :std_logic_vector := "-----") return std_logic_vector;
    function R(op : std_logic_vector := "000000"; rs : std_logic_vector := "-----"; rt : std_logic_vector := "-----"; rd : std_logic_vector := "-----";shift : std_logic_vector := "00000"; func : std_logic_vector(5 downto 0)) return std_logic_vector;

    -- ALU function
    -- enum ALU {
      --  AND, OR, XOR, SLL, SRL, SLA, SRA, ADD, SUB, MULT, DIV
    --}

    subtype WORD      is std_logic_vector(31 downto 0);
    subtype HALFWORD  is std_logic_vector(31 downto 0);

    subtype INSTRUCTION  is WORD;
    subtype MASK         is WORD;

    type alu_op_t is (ALU_ADD, ALU_AND, ALU_LU, ALU_NOR, ALU_OR, ALU_SLT, ALU_SUB, ALU_XOR);

    -- Taken from https://opencores.org/project,plasma,opcodes

    -- ALU
    constant OP_ADD   : MASK := R(func => "100000");
    constant OP_ADDI  : MASK := I(op => "001000");
    constant OP_ADDIU : MASK := I(op => "001001");
    constant OP_ADDU  : MASK := R(func => "100001");
    constant OP_AND   : MASK := R(func => "100100");
    constant OP_ANDI  : MASK := I(op => "001100");
    constant OP_LUI   : MASK := I(op => "001111");
    constant OP_NOR   : MASK := R(func => "100111");
    constant OP_OR    : MASK := R(func => "100101");
    constant OP_ORI   : MASK := I(op => "001101");
    constant OP_SLT   : MASK := R(func => "100101");
    constant OP_SLTI  : MASK := I(op => "001010");
    constant OP_SLTIU : MASK := I(op => "001011");
    constant OP_SLTU  : MASK := R(func => "101011");
    constant OP_SUB   : MASK := R(func => "100010");
    constant OP_SUBU  : MASK := R(func => "100011");
    constant OP_XOR   : MASK := R(func => "100110");
    constant OP_XORI  : MASK := I(op => "001110");

    -- Shifter
    constant OP_SLL   : MASK := R(shift => "-----", func => "000000");
    constant OP_SLLV  : MASK := R(shift => "00000", func => "000100");
    constant OP_SRA   : MASK := R(shift => "-----", func => "000011");
    constant OP_SRAV  : MASK := R(shift => "00000", func => "000111");
    constant OP_SRL   : MASK := R(shift => "-----", func => "000010");
    constant OP_SRLV  : MASK := R(shift => "00000", func => "000110");

    -- Multiply and Divide
    constant OP_DIV   : MASK := R(rd => "00000", func => "011010");
    constant OP_DIVU  : MASK := R(rd => "00000", func => "011011");
    constant OP_MFHI  : MASK := R(rs => "00000", rt => "00000", func => "010000");
    constant OP_MFLO  : MASK := R(rs => "00000", rt => "00000", func => "010010");
    constant OP_MTHI  : MASK := R(rt => "00000", rd => "00000", func => "010001");
    constant OP_MTLO  : MASK := R(rt => "00000", rd => "00000", func => "010011");
    constant OP_MULT  : MASK := R(rd => "00000", func => "011000");
    constant OP_MULTU : MASK := R(rd => "00000", func => "011001");

    -- Branch
    constant OP_BEQ   : MASK := I(op => "000100");
    constant OP_BGEZ  : MASK := I(op => "000001", rt => "00001");
    constant OP_BGEZAL: MASK := I(op => "000001", rt => "10001");
    constant OP_BGTZ  : MASK := I(op => "000111", rt => "00000");
    constant OP_BLEZ  : MASK := I(op => "000110", rt => "00000");
    constant OP_BLTZ  : MASK := I(op => "000001", rt => "00000");
    constant OP_BLTZAL: MASK := I(op => "000001", rt => "10000");
    constant OP_BNE   : MASK := I(op => "000101");
    constant OP_J     : MASK := J(op => "000010");
    constant OP_JAL   : MASK := J(op => "000011");
    constant OP_JR    : MASK := "000000"&"-----"&(14 downto 0 => '0')&"001000";

    constant OP_BREAK   : MASK := "000000"&(19 downto 0 => '-')&"001101";
    constant OP_MFC0    : MASK := "010000"&"00000"&(9 downto 0 => '-')&(10 downto 0 => '0');
    constant OP_MTC0    : MASK := "010000"&"00100"&(9 downto 0 => '-')&(10 downto 0 => '0');
    constant OP_SYSCALL : MASK := "000000"&(19 downto 0 => '-')&"001100";

    -- Memory Access
    constant OP_LB  : MASK := I(op => "100000");
    constant OP_LBU : MASK := I(op => "100100");
    constant OP_LH  : MASK := I(op => "100001");
    constant OP_LHU : MASK := I(op => "100101");
    constant OP_LW  : MASK := I(op => "100011");
    constant OP_SB  : MASK := I(op => "101000");
    constant OP_SH  : MASK := I(op => "101001");
    constant OP_SW  : MASK := I(op => "101011");



    --constant OP_ADDU   : MASK := "------"&"---------------"&"00000"&"100101";


    --constant OP_SPECIAL : I_op := "0000_00";
    --constant OP_ADDI    : I_op := "0010_00";
    --constant OP_ADDIU   : I_op := "0010_01";
    --constant OP_ANDI    : I_op := "0011_01";

    --constant ALU_AND         : STD_LOGIC_VECTOR(5 downto 0) := "100100";
    --constant ALU_OR          : STD_LOGIC_VECTOR(5 downto 0) := "100101";
    --constant ALU_SLT         : STD_LOGIC_VECTOR(5 downto 0) := "101010";

    -- BUS CONSTANTS
    --constant OP_LOAD          : STD_LOGIC_VECTOR(5 downto 0) := "100011"; -- 23 (LOAD WORD) / 35
    --constant OP_STORE         : STD_LOGIC_VECTOR(5 downto 0) := "101011"; -- 2B (STORE WORD) / 43
    --constant OP_LI            : STD_LOGIC_VECTOR(5 downto 0) := "001111"; -- (UNKNOWN) F / 15
    --constant OP_BEQ           : STD_LOGIC_VECTOR(5 downto 0) := "000100"; -- I-branch
    --constant OP_NOP           : STD_LOGIC_VECTOR(5 downto 0) := "111111"; -- No Operation
    
    -- ALU OP Codes
    --constant ALU_OP_LS          : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- Load & Store
    --constant ALU_OP_BEQ         : STD_LOGIC_VECTOR(1 downto 0) := "01"; -- Branch on equal
    --constant ALU_OP_R           : STD_LOGIC_VECTOR(1 downto 0) := "10"; -- R funct
    
    
end arch_defs;

package body arch_defs is

    function is_type_r(vec: std_logic_vector) return boolean is
    begin
        return vec(vec'high downto vec'high - 5) = "000000";
    end is_type_r;

    function is_type_j(vec: std_logic_vector) return boolean is
    begin
        return vec(vec'high downto vec'high - 5) = "000000";
    end is_type_j;

    function J(op : std_logic_vector) return std_logic_vector is
    begin return op & (31-6 downto 0 => '-');
    end J;

    function I(op : std_logic_vector; rs : std_logic_vector := "-----"; rt :std_logic_vector := "-----") return std_logic_vector is
    begin return op & rs & rt & (15 downto 0 => '-');
    end I;

    function R(op : std_logic_vector := "000000"; rs : std_logic_vector := "-----"; rt : std_logic_vector := "-----"; rd : std_logic_vector := "-----";shift : std_logic_vector := "00000"; func : std_logic_vector(5 downto 0)) return std_logic_vector is
    begin return op & (14 downto 0 => '-') & shift & func;
    end R;


end arch_defs;
