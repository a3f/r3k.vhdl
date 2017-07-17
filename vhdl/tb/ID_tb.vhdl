-- InstructionDecode Testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.txt_utils.all;

--  A testbench has no ports.
entity ID_tb is
    end ID_tb;

architecture behav of ID_tb is

component InstructionDecode is
    port (instr : in instruction_t;
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
          rst : in std_logic);
    end component;

    signal instr     : std_logic_vector(31 downto 0); -- instruction_t

    signal regwrite, regdst, link, jumpreg, jumpdirect, branch : ctrl_t;
    signal memread : ctrl_memwidth_t;
    signal memtoreg, memsex : ctrl_t;
    signal memwrite : ctrl_memwidth_t;
    signal shift, alusrc : ctrl_t;
    signal aluop     : alu_op_t;

    signal pc_plus_4, jump_addr : addr_t;

    signal clk, rst : std_logic;
    signal readreg1, readreg2 : reg_t;
    signal writereg : reg_t;
    signal zeroxed, sexed : word_t;

    signal done : boolean := false;
    constant RIGN : reg_t := "-----";
    constant IMMIGN : word_t := "--------------------------------";
begin
        ID : InstructionDecode port map(
            instr => instr,
            pc_plus_4 => pc_plus_4,
            jump_addr => jump_addr,

            regwrite => regwrite, link => link, jumpreg => jumpreg,
            jumpdirect => jumpdirect, branch => branch,
            memread => memread,
            memtoreg => memtoreg, memsex => memsex,
            memwrite => memwrite,
            shift => shift, alusrc => alusrc,
            aluop => aluop,

            readreg1 => readreg1, readreg2 => readreg2,
            writereg => writereg,
            zeroxed => zeroxed, sexed => sexed,

            clk => clk,
            rst => rst
        );


        test: process
            variable error : boolean := false;
            variable error_count : natural := 0;
            type testcase_t is record
                instr : instruction_t;
                AluOp : alu_op_t;
                readreg1, readreg2, writereg : reg_t;
                zeroxed, sexed : word_t;
            end record;

            type testcase_table_t is array (natural range <>) of testcase_t;
            constant testcases : testcase_table_t := (
                -- Easy arithmetic
                (X"3421_ffff", ALU_OR, R1,R1, RIGN, IMMIGN, NEG_ONE), -- ori r1, r1, 0xffff
                (X"3428_ffff", ALU_OR, R1,R8, RIGN, IMMIGN, NEG_ONE), -- ori r1, r8, 0xffff
                (X"3421_0fff", ALU_OR, R1,R1, RIGN, IMMIGN, X"0000_0fff")
            );
        begin
            for i in testcases'range loop
                instr <= testcases(i).instr;
                wait for 2 ns;

                error := not (AluOp = testcases(i).AluOp
                    and std_match(readreg1, testcases(i).readreg1)
                    and std_match(readreg2, testcases(i).readreg2)
                    and std_match(writereg, testcases(i).writereg)
                    and std_match(zeroxed, testcases(i).zeroxed)
                    and std_match(sexed, testcases(i).sexed)
                );

                if error then
                    error_count := error_count + 1;
                end if;

                assert not error report
                ANSI_GREEN & "Failure in testcase " & integer'image(i) & ": " &
                to_hstring(testcases(i).instr)
                & ANSI_NONE severity note;

            end loop;
            assert error_count /= 0 report
            ANSI_GREEN & "Test's over." & ANSI_NONE
            severity note;
            assert error_count = 0 report
            ANSI_RED & integer'image(error_count) & " testcase(s) failed." & ANSI_NONE
            severity failure;
            --  Wait forever; this will finish the simulation.
            done <= true;
            wait;
        end process;
    clkproc: process
    begin
        clk <= not clk;
        wait for 1 ns;
        if done then wait; end if;
    end process;
end behav;
