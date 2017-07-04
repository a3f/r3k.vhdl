library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

    subtype word_t          is std_logic_vector(31 downto 0);
    subtype addr_t          is std_logic_vector(31 downto 0);
    subtype intaddr_t       is unsigned(31 downto 0);
    subtype addrdiff_t      is std_logic_vector(31 downto 0);
    subtype halfword_t      is std_logic_vector(15 downto 0);
    subtype ctrl_t          is std_logic;
    subtype ctrl_memwidth_t is std_logic_vector(1 downto 0);
    subtype instruction_t   is word_t;
    subtype mask_t          is word_t;
    subtype reg_t           is std_logic_vector(4 downto 0);
    subtype opcode_t        is std_logic_vector(5 downto 0);
    subtype func_t          is std_logic_vector(5 downto 0);

    constant WIDTH_NONE : ctrl_memwidth_t := "00";
    constant WIDTH_BYTE : ctrl_memwidth_t := "01";
    constant WIDTH_HALF : ctrl_memwidth_t := "10";
    constant WIDTH_WORD : ctrl_memwidth_t := "11";

    type alu_op_t is (
        ALU_ADD, ALU_ADDU, ALU_SUB, ALU_SUBU,
        ALU_AND, ALU_OR, ALU_NOR, ALU_XOR, ALU_LU,
        ALU_SLL, ALU_SRL, ALU_SRA,
        ALU_MULT, ALU_MULTU, ALU_DIV, ALU_DIVU,
        ALU_MFHI, ALU_MFLO, ALU_MTHI, ALU_MTLO,
        ALU_SLT, ALU_SLTU,
        ALU_EQ, ALU_NE, ALU_LEZ, ALU_LTZ, ALU_GTZ, ALU_GEZ
    );

    subtype traps_t is std_logic_vector(7 downto 0);
    constant TRAP_NONE          : traps_t := X"00";
    constant TRAP_DIVBYZERO     : traps_t := X"01";
    constant TRAP_OVERFLOW      : traps_t := X"02";
    constant TRAP_SEGFAULT      : traps_t := X"04";
    constant TRAP_BREAKPOINT    : traps_t := X"08";
    constant TRAP_SYSCALL       : traps_t := X"10";
    constant TRAP_EPE           : traps_t := X"20";
    constant TRAP_UNIMPLEMENTED : traps_t := X"40";

    type exception_config_t is (
        EXCEPTIONS_IGNORE -- Bad idea!
        --EXCEPTIONS_HALT,-- e.g. light a red LED and stop fetching new instructions
        --EXCEPTIONS_RESET-- reboot
        --EXCEPTIONS_TRAP -- invoke user-programmable exception handlers
    );

    -- Taken from https://opencores.org/project,plasma,opcodes
    -- And http://web.cse.ohio-state.edu/~crawfis.3/cse675-02/Slides/MIPS%20Instruction%20Set.pdf

    -- 32 bit defines
    constant ZERO       : word_t := X"00000000";
    constant HI_Z       : word_t := (others => 'Z');
    constant NEG_ONE    : word_t := not ZERO;
    constant DONT_CARE  : word_t := (others => 'X');

    constant R0 : reg_t  := (others => '0'); --  Zero register  (5 bits)
    constant R31 : reg_t := (others => '1'); --  Return address (5 bits)

    -- ALU
    constant OP_ADD   : mask_t := R(func => "100000");
    constant OP_ADDU  : mask_t := R(func => "100001");
    constant OP_AND   : mask_t := R(func => "100100");
    constant OP_NOR   : mask_t := R(func => "100111");
    constant OP_OR    : mask_t := R(func => "100101");
    constant OP_SLT   : mask_t := R(func => "101010");
    constant OP_SLTU  : mask_t := R(func => "101011");
    constant OP_SUB   : mask_t := R(func => "100010");
    constant OP_SUBU  : mask_t := R(func => "100011");
    constant OP_XOR   : mask_t := R(func => "100110");

    constant OP_ADDI  : mask_t := I(op => "001000");
    constant OP_ADDIU : mask_t := I(op => "001001");
    constant OP_ANDI  : mask_t := I(op => "001100");
    constant OP_LUI   : mask_t := I(op => "001111");
    constant OP_ORI   : mask_t := I(op => "001101");
    constant OP_SLTI  : mask_t := I(op => "001010");
    constant OP_SLTIU : mask_t := I(op => "001011");
    constant OP_XORI  : mask_t := I(op => "001110");

    -- Shifter
    constant OP_SLL   : mask_t := R(shift => "-----", func => "000000");
    constant OP_SLLV  : mask_t := R(shift => "00000", func => "000100");
    constant OP_SRA   : mask_t := R(shift => "-----", func => "000011");
    constant OP_SRAV  : mask_t := R(shift => "00000", func => "000111");
    constant OP_SRL   : mask_t := R(shift => "-----", func => "000010");
    constant OP_SRLV  : mask_t := R(shift => "00000", func => "000110");

    -- Multiply and Divide
    constant OP_DIV   : mask_t := R(rd => "00000", func => "011010");
    constant OP_DIVU  : mask_t := R(rd => "00000", func => "011011");
    constant OP_MFHI  : mask_t := R(rs => "00000", rt => "00000", func => "010000");
    constant OP_MFLO  : mask_t := R(rs => "00000", rt => "00000", func => "010010");
    constant OP_MTHI  : mask_t := R(rt => "00000", rd => "00000", func => "010001");
    constant OP_MTLO  : mask_t := R(rt => "00000", rd => "00000", func => "010011");
    constant OP_MULT  : mask_t := R(rd => "00000", func => "011000");
    constant OP_MULTU : mask_t := R(rd => "00000", func => "011001");

    -- Branch
    constant OP_BEQ   : mask_t := I(op => "000100");
    constant OP_BGEZ  : mask_t := I(op => "000001", rt => "00001");
    constant OP_BGEZAL: mask_t := I(op => "000001", rt => "10001");
    constant OP_BGTZ  : mask_t := I(op => "000111", rt => "00000");
    constant OP_BLEZ  : mask_t := I(op => "000110", rt => "00000");
    constant OP_BLTZ  : mask_t := I(op => "000001", rt => "00000");
    constant OP_BLTZAL: mask_t := I(op => "000001", rt => "10000");
    constant OP_BNE   : mask_t := I(op => "000101");
    constant OP_J     : mask_t := J(op => "000010");
    constant OP_JAL   : mask_t := J(op => "000011");
    constant OP_JR    : mask_t := R(rt => R0, func => "001000", rd => R0);
    constant OP_JALR  : mask_t := R(rt => R0, func => "100010");

    constant OP_BREAK   : mask_t := "000000"&(19 downto 0 => '-')&"001101";
    constant OP_MFC0    : mask_t := "010000"&"00000"&(9 downto 0 => '-')&(10 downto 0 => '0');
    constant OP_MTC0    : mask_t := "010000"&"00100"&(9 downto 0 => '-')&(10 downto 0 => '0');
    constant OP_SYSCALL : mask_t := "000000"&(19 downto 0 => '-')&"001100";

    -- Memory Access
    constant OP_LB  : mask_t := I(op => "100000");
    constant OP_LBU : mask_t := I(op => "100100");
    constant OP_LH  : mask_t := I(op => "100001");
    constant OP_LHU : mask_t := I(op => "100101");
    constant OP_LW  : mask_t := I(op => "100011");
    constant OP_SB  : mask_t := I(op => "101000");
    constant OP_SH  : mask_t := I(op => "101001");
    constant OP_SW  : mask_t := I(op => "101011");



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
