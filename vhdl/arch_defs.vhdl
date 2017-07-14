library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package arch_defs is


    subtype byte_t          is std_logic_vector( 7 downto 0);
    subtype half_t          is std_logic_vector(15 downto 0);
    subtype word_t          is std_logic_vector(31 downto 0);
    subtype addr_t          is std_logic_vector(31 downto 0);
    subtype intaddr_t       is unsigned(31 downto 0);
    subtype addrdiff_t      is std_logic_vector(31 downto 0);
    subtype ctrl_t          is std_logic;
    subtype ctrl_memwidth_t is std_logic_vector(1 downto 0);
    subtype instruction_t   is word_t;
    subtype mask_t          is word_t;
    subtype reg_t           is std_logic_vector(4 downto 0);
    subtype opcode_t        is std_logic_vector(5 downto 0);
    subtype func_t          is std_logic_vector(5 downto 0);

    function is_type_r(instr: instruction_t) return boolean;
    function is_type_j(instr: instruction_t) return boolean;
    function is_type_I(instr: instruction_t) return boolean;
    function J(op : std_logic_vector) return std_logic_vector;
    function I(op : std_logic_vector; rs : std_logic_vector := "-----"; rt :std_logic_vector := "-----") return std_logic_vector;
    function R(op : std_logic_vector := "000000"; rs : std_logic_vector := "-----"; rt : std_logic_vector := "-----"; rd : std_logic_vector := "-----";shift : std_logic_vector := "00000"; func : std_logic_vector(5 downto 0)) return std_logic_vector;

    function word(w : word_t) return word_t;
    function half(w : word_t) return half_t;
    function byte(w : word_t) return byte_t;

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
    constant TRAP_DIVERROR      : traps_t := X"01";
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
    constant ZERO      : word_t := X"00000000";
    constant HI_Z      : word_t := (others => 'Z');
    constant NEG_ONE   : word_t := not ZERO;
    constant INT_MIN   : word_t := X"8000_0000";
    constant INT_MAX   : word_t := X"7fff_ffff";
    constant DONT_CARE : word_t := (others => 'X');

    -- Register file
    constant R0  : reg_t := B"0_0000"; --  $zero
    constant R1  : reg_t := B"0_0001"; --  $at
    constant R2  : reg_t := B"0_0010"; --  $v0
    constant R3  : reg_t := B"0_0011"; --  $v1
    constant R4  : reg_t := B"0_0100"; --  $a0
    constant R5  : reg_t := B"0_0101"; --  $a1
    constant R6  : reg_t := B"0_0110"; --  $a2
    constant R7  : reg_t := B"0_0111"; --  $a3
    constant R8  : reg_t := B"0_1000"; --  $t0
    constant R9  : reg_t := B"0_1001"; --  $t1
    constant R10 : reg_t := B"0_1010"; --  $t2
    constant R11 : reg_t := B"0_1011"; --  $t3
    constant R12 : reg_t := B"0_1100"; --  $t4
    constant R13 : reg_t := B"0_1101"; --  $t5
    constant R14 : reg_t := B"0_1110"; --  $t6
    constant R15 : reg_t := B"0_1111"; --  $t7
    constant R16 : reg_t := B"1_0000"; --  $s0
    constant R17 : reg_t := B"1_0001"; --  $s1
    constant R18 : reg_t := B"1_0010"; --  $s2
    constant R19 : reg_t := B"1_0011"; --  $s3
    constant R20 : reg_t := B"1_0100"; --  $s4
    constant R21 : reg_t := B"1_0101"; --  $s5
    constant R22 : reg_t := B"1_0110"; --  $s6
    constant R23 : reg_t := B"1_0111"; --  $s7
    constant R24 : reg_t := B"1_1000"; --  $t8
    constant R25 : reg_t := B"1_1001"; --  $t9
    constant R26 : reg_t := B"1_1010"; --  $k0
    constant R27 : reg_t := B"1_1011"; --  $k1
    constant R28 : reg_t := B"1_1100"; --  $gp
    constant R29 : reg_t := B"1_1101"; --  $sp
    constant R30 : reg_t := B"1_1110"; --  $fp
    constant R31 : reg_t := B"1_1111"; --  $ra

    function toreg(i : integer) return reg_t;

end arch_defs;

package body arch_defs is

    function is_type_r(instr: instruction_t) return boolean is
    begin
        return instr(31 downto 26) = "000000";
    end is_type_r;

    function is_type_j(instr: instruction_t) return boolean is
    begin
		return instr(31 downto 26) = "000010"
			or instr(31 downto 26) = "000011";
    end is_type_j;

    function is_type_i(instr: instruction_t) return boolean is
    begin
		return not is_type_j(instr) and not is_type_r(instr);
    end is_type_i;

    function J(op : std_logic_vector) return std_logic_vector is
    begin return op & (31-6 downto 0 => '-');
    end J;

    function I(op : std_logic_vector; rs : std_logic_vector := "-----"; rt :std_logic_vector := "-----") return std_logic_vector is
    begin return op & rs & rt & (15 downto 0 => '-');
    end I;

    function R(op : std_logic_vector := "000000"; rs : std_logic_vector := "-----"; rt : std_logic_vector := "-----"; rd : std_logic_vector := "-----";shift : std_logic_vector := "00000"; func : std_logic_vector(5 downto 0)) return std_logic_vector is
    begin return op & (14 downto 0 => '-') & shift & func;
    end R;

    function word(w : word_t) return word_t is
    begin
        return w(31 downto 0);
    end function;
    function half(w : word_t) return half_t is
    begin
        return w(15 downto 0);
    end function;
    function byte(w : word_t) return byte_t is
    begin
        return w( 7 downto 0);
    end function;

    function toreg(i : integer) return reg_t is
    begin
        return std_logic_vector(to_unsigned(i, 5));
    end function;

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
