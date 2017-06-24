library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

entity maindec is
    port (  instr     : in std_logic_vector(31 downto 0); -- instruction_t
            regwrite, regdst, link, jumpreg, jumpdirect, branch : out ctrl_t;
            memread : out ctrl_memwidth_t;
            memtoreg, memsex : out ctrl_t;
            memwrite : out ctrl_memwidth_t;
            shift, alusrc : out ctrl_t;
            aluop     : out alu_op_t);
    end;

architecture behave of maindec is
    signal op : opcode_t := instr(31 downto 26);
    signal rs : reg_t := instr(25 downto 21);
    signal rt : reg_t := instr(20 downto 16);
    signal rd : reg_t := instr(15 downto 11);
 -- signal shamt : std_logic_vector(4 downto 0) := instr(10 downto 6);
    signal func : func_t := instr(5 downto 0);

    constant i_regwrite : natural := 0;
    constant i_regdst : natural := 1;
    constant i_link : natural := 2;
    constant i_jumpreg : natural := 3;
    constant i_jumpdirect : natural := 4;
    constant i_branch : natural := 5;
    constant i_memread : natural := 6;
    constant i_memtoreg : natural := 7;
    constant i_memsex : natural := 8;
    constant i_memwrite : natural := 9;
    constant i_shift : natural := 10;
    constant i_alusrc : natural := 11;
    signal ctrl: std_logic_vector(i_alusrc downto i_regwrite);
    subtype memwidth_t is std_logic_vector(1 downto 0);
    constant WIDTH_NONE : memwidth_t := "00";
    constant WIDTH_BYTE : memwidth_t := "01";
    constant WIDTH_HALF : memwidth_t := "10";
    constant WIDTH_WORD : memwidth_t := "11";

    signal memwidth : memwidth_t := WIDTH_NONE;
    begin

    --   :   6  :   5  :   5  :   5  :   5   :   6  :
    --   .------------------------------------------.
    -- R |opcode|  rs  |  rt  |  rd  | shamt | func |
    --   '------------------------------------------'
    --   :31  26:25  21:20  16:15  11:10    6:5    0:
    --   .------------------------------------------.
    -- I |opcode|  rs  |  rt  |      immediate      |
    --   '------------------------------------------'
    --   :31  26:25  21:20  16:15                  0:
    --   .------------------------------------------.
    -- J |opcode|              address              |
    --   '------------------------------------------'
    --   :31  26:25                                0:
    
    process (op)
    begin
        aluop <= ALU_ADD;
        case op is
            when B"000_000" => ctrl <= "110000000000"; -- R-Type
                case func is
                    when B"10_0000" => aluop <= ALU_ADD;
                    when B"10_0001" => aluop <= ALU_ADDU;
                    when B"10_0100" => aluop <= ALU_AND;
                    when B"10_0111" => aluop <= ALU_NOR;
                    when B"10_0101" => aluop <= ALU_OR;
                    when B"10_1010" => aluop <= ALU_SLT;
                    when B"10_1011" => aluop <= ALU_SLTU;
                    when B"10_0010" => aluop <= ALU_SUB;
                    when B"10_0011" => aluop <= ALU_SUBU;
                    when B"10_0110" => aluop <= ALU_XOR;

                    when B"00_0000" => aluop <= ALU_SLL; ctrl(i_shift) <= '1';
                    when B"00_0100" => aluop <= ALU_SLL; -- sllv
                    when B"00_0011" => aluop <= ALU_SRA; ctrl(i_shift) <= '1';
                    when B"00_0111" => aluop <= ALU_SRA; -- srav
                    when B"00_0010" => aluop <= ALU_SRL; ctrl(i_shift) <= '1';
                    when B"00_0110" => aluop <= ALU_SRL; -- srav

                    when B"01_1010" => aluop <= ALU_DIV;
                    when B"01_1011" => aluop <= ALU_DIVU;
                    when B"01_0000" => aluop <= ALU_MFHI;
                    when B"01_0010" => aluop <= ALU_MFLO;
                    when B"01_0001" => ctrl <= "0X000000000X"; aluop <= ALU_MTHI;
                    when B"01_0011" => ctrl <= "0X000000000X"; aluop <= ALU_MTLO;
                    when B"01_1000" => aluop <= ALU_MULT;
                    when B"01_1001" => aluop <= ALU_MULTU;

                    when B"00_1000" => ctrl <= "0XX1XX0XX00X"; -- jr
                    when B"00_1001" => ctrl <= "1111000XX00X"; -- jalr
                    when others     => null; -- should be Illegal instruction instead
                end case;
            -- when OP_SHIFT  => ctrl <= "1100000X0010"; aluop <= ALU_SHIFT; -- shift
            when B"000_010" => ctrl <= "0XX01X00X00X"; -- j
            when B"000_011" => ctrl <= "1X101X00X00X"; -- jal

            when B"100_000" => ctrl <= "100000111001"; memwidth <= WIDTH_BYTE; -- lb
            when B"100_100" => ctrl <= "100000110001"; memwidth <= WIDTH_BYTE; -- lbu
            when B"100_001" => ctrl <= "100000111001"; memwidth <= WIDTH_HALF; -- lh
            when B"100_101" => ctrl <= "100000110001"; memwidth <= WIDTH_HALF; -- lhu
            when B"100_011" => ctrl <= "00000011X001"; memwidth <= WIDTH_WORD; -- lw
            when B"101_000" => ctrl <= "00000000X101"; memwidth <= WIDTH_BYTE; -- sb
            when B"101_001" => ctrl <= "00000000X101"; memwidth <= WIDTH_HALF; -- sh
            when B"101_011" => ctrl <= "00000000X101"; memwidth <= WIDTH_WORD; -- sw

            when B"000_100" => ctrl <= "0X0001000000"; aluop <= ALU_EQ; -- beq
            when B"000_101" => ctrl <= "0X0001000000"; aluop <= ALU_NE; -- bne

            -- Zero-relative branches
            when B"000_001" => case rt is
                when B"0_0000" => ctrl <= "000001000000"; aluop <= ALU_LTZ; -- bltz
                when B"1_0000" => ctrl <= "011001000000"; aluop <= ALU_LTZ; -- bltzal
                when B"0_0001" => ctrl <= "000001000000"; aluop <= ALU_GEZ;  -- bgez
                when B"1_0001" => ctrl <= "011001000000"; aluop <= ALU_GEZ;  -- bgezal
                when others    => null;
            end case;
            when B"000_111" => ctrl <= "000001000000"; aluop <= ALU_GTZ;  -- bgtz
            when B"000_110" => ctrl <= "000001000000"; aluop <= ALU_LEZ;  -- blez

            when others    => ctrl <= "100000000001"; -- I-Type
            case op is
                when B"0010_00" => aluop <= ALU_ADD;
                when B"0010_01" => aluop <= ALU_ADDU;
                when B"0011_00" => aluop <= ALU_AND;
                when B"0011_11" => aluop <= ALU_LU;
                when B"0011_01" => aluop <= ALU_OR;
                when B"0010_10" => aluop <= ALU_SLT;
                when B"0010_11" => aluop <= ALU_SLTU;
                when B"0011_10" => aluop <= ALU_XOR;
                when others    => ctrl <= "------------";
            end case;

        end case;
    end process;

    memread    <= memwidth when ctrl(i_memread)  = '1' else WIDTH_NONE;
    memwrite   <= memwidth when ctrl(i_memwrite) = '1' else WIDTH_NONE;

    regwrite   <= ctrl(i_regwrite);
    regdst     <= ctrl(i_regdst);
    link       <= ctrl(i_link);
    jumpreg    <= ctrl(i_jumpreg);
    jumpdirect <= ctrl(i_jumpdirect);
    branch     <= ctrl(i_branch);
    memtoreg   <= ctrl(i_memtoreg);
    memsex     <= ctrl(i_memsex);
    shift      <= ctrl(i_shift);
    alusrc     <= ctrl(i_alusrc);
end;
