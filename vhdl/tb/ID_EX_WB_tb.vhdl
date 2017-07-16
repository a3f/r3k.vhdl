library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

entity id_ex_wb_tb is
end;

architecture struct of id_ex_wb_tb is
    component regFile is
    port (
        readreg1, readreg2 : in reg_t;
        writereg: in reg_t;
        writedata: in word_t;
        readData1, readData2 : out word_t;
        clk : in std_logic;
        rst : in std_logic;
        regWrite : in std_logic
    );
    end component;

    signal readreg1, readreg2 : reg_t := R0;
    signal writereg: reg_t := R0;
    signal regReadData1, regReadData2, regWriteData : word_t := ZERO;
    signal regWrite : std_logic := '0';

    component InstructionDecode is
        port(
            instr : in instruction_t;
            next_pc : in addr_t;
            jump_addr : out addr_t;

            regwrite, link, jumpreg, jumpdirect, branch : out ctrl_t;
            memread, memwrite : out ctrl_memwidth_t;
            memtoreg, memsex : out ctrl_t;
            shift, alusrc : out ctrl_t;
            aluop     : out alu_op_t;

            readreg1, readreg2, writereg : out reg_t;
            zeroxed, sexed : out word_t;

            clk : in std_logic;
            rst : in std_logic);
    end component;

    component Execute is
        port (
            next_pc : in addr_t;
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
    end component;

    component WriteBack is
        port(
        Link, JumpReg, JumpDir, MemToReg, TakeBranch : in ctrl_t;
        next_pc, branch_addr, jump_addr: in addr_t;
        aluResult, memReadData, regReadData1 : in word_t;
        regWriteData : out word_t;
        next_addr : out addr_t);
    end component;


    -- control signals
    signal Link, Branch, memToreg, TakeBranch, Shift, ALUSrc : ctrl_t;
    signal next_addr, next_pc, jump_addr, branch_addr : addr_t;
    signal instr : instruction_t;
    signal zeroxed, sexed, aluResult: word_t;
    signal aluop : alu_op_t;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal done : boolean := false;

    constant ESC : Character := Character'val(27);
begin

    regFile1: regFile
        port map(
            readreg1 => readreg1, readreg2 => readreg2,
            writereg => writereg, writedata => regWriteData,
            readData1 => regReadData1, readData2 => regReadData2,
            clk => clk, rst => rst,
            regWrite => regWrite
        );

    id1: InstructionDecode
    port map(instr => instr,
             next_pc => next_pc,
             jump_addr => jump_addr,

             regwrite => regwrite, link => open, jumpreg => open, jumpdirect => open, branch => Branch,
             memread => open, memwrite => open,
             memtoreg => memtoreg, memsex => open,
             shift => shift, alusrc => aluSrc,
             aluop => aluOp,        

             readreg1 => readReg1, readreg2 => readReg2, writeReg => writeReg,

             zeroxed => zeroxed, sexed => sexed,

             clk => clk,
             rst => rst
         );
    ex1: Execute
    port map(
                next_pc => next_pc,
                regReadData1 => regReadData1, regReadData2 => regReadData2,
                branch_addr => branch_addr,
                branch_in => Branch,
                shift_in => shift, alusrc_in => ALUSrc,
                aluop_in => ALUOp,

                zeroxed => zeroxed, sexed => sexed,

                takeBranch => open,
                ALUResult => AluResult,

                clk => clk,
                rst => rst
    );

    wb1: WriteBack
    port map(
                Link => Link,
                JumpReg => 'X',
                JumpDir => 'X',
                MemToReg => memtoreg,
                TakeBranch => 'X',
                next_pc => DONT_CARE,
                branch_addr => DONT_CARE,
                jump_addr => DONT_CARE,
                aluResult => aluResult,
                memReadData => DONT_CARE,
                regReadData1 => regReadData1,
                regWriteData => regWriteData,
                next_addr => open);
    
    test : process
    begin
        rst <= '0';
        wait for 2 ns;
        rst <= '1';
        wait for 2 ns;
        rst <= '0';
        wait for 20 ns;

        readreg1 <= R1;
        wait for 2 ns;

        assert regReadData1 = ZERO report
            ESC& "[31mFailed to reset. 0 /= " & to_hstring(regReadData1) &ESC& "[m"
        severity error;


        instr <= X"3421_ffff"; -- ori r1, r1, 0xffff
        wait for 20 ns;

        assert AluResult = X"0000FFFF" report
                ESC& "[31mNot expected AluResult: 0xFFFF /= " & to_hstring(AluResult) &ESC& "[m"
        severity error;

        readreg1 <= R1;
        wait for 2 ns;

        assert regReadData1 = X"0000FFFF" report
                ESC& "[31mFailed to ori. 0xFFFF /= " & to_hstring(regReadData1) &ESC& "[m"
        severity error;

        done <= true;
        wait;
    end process;

    clkproc: process
    begin
        clk <= not clk;
        wait for 1 ns;
        if done then wait; end if;
    end process;
end struct;

