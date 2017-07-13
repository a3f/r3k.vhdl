-- See tools/assemble.pl


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.txt_utils.all;

--  A testbench has no ports.
entity control_vec_tb is
    end control_vec_tb;

architecture behav of control_vec_tb is

component maindec is
    port (  instr     : in std_logic_vector(31 downto 0); -- instruction_t
            regwrite, regdst, link, jumpreg, jumpdirect, branch : out ctrl_t;
            memread : out ctrl_memwidth_t;
            memtoreg, memsex : out ctrl_t;
            memwrite : out ctrl_memwidth_t;
            shift, alusrc : out ctrl_t;
            aluop     : out alu_op_t);
    end component;
    signal instr     : std_logic_vector(31 downto 0); -- instruction_t

    signal regwrite, regdst, link, jumpreg, jumpdirect, branch : ctrl_t;
    signal memread : ctrl_memwidth_t;
    signal memtoreg, memsex : ctrl_t;
    signal memwrite : ctrl_memwidth_t;
    signal shift, alusrc : ctrl_t;
    signal aluop     : alu_op_t;
    alias op is instr(31 downto 26);
    alias rs is instr(25 downto 21);
    alias rt is instr(20 downto 16);
    alias rd is instr(15 downto 11);
    alias shamt is instr(10 downto 6);
    alias func is instr(5 downto 0);
    alias address is instr(25 downto 0);
    alias imm is instr(15 downto 0);

    alias b is TO_BSTRING [STD_LOGIC_VECTOR return STRING];
    alias b is TO_STRING [STD_ULOGIC return STRING];
    constant d : string := "|";
    begin
        control : maindec port map(
                instr,
                regwrite, regdst, link, jumpreg, jumpdirect, branch,
                memread,
                memtoreg,
                memsex,
                memwrite,
                shift, alusrc,
                aluop);

        printer: process
        begin
            instr <= X"0000_0000"; -- nop
            wait for 1 ns;

            assert RegWrite   = '1'
               and RegDst     = '1'
               and Link       = '0'
               and JumpReg    = '0'
               and JumpDirect = '0'
               and Branch     = '0'
               and MemRead    = "00"
               and MemtoReg   = '0'
               and MemSex     = '0'
               and MemWrite   = "00"
               and Shift      = '1'
               and AluSrc     = '0'
               and AluOp      = alu_sll
            report
                "Fail"
            severity note;

            wait;
    end process;
end behav;

