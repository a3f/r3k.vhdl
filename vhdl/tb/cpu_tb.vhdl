-- SKIP because I still have to get it working
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;
use work.memory_map.all;

entity cpu_tb is
end;

architecture struct of cpu_tb is
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
    signal regWrite : ctrl_t := '0';

    component mem is
    port (
        addr : in addr_t;
        din : in word_t;
        dout : out word_t;
        size : in ctrl_memwidth_t;
        wr : in std_logic;
        clk : in std_logic
    );
    end component;

    component InstructionFetch is
        generic(PC_ADD, CPI : natural; SINGLE_ADDRESS_SPACE : boolean);
        port (
            clk : in std_logic;
            rst : in std_logic;
            new_pc : in addr_t;
            pc_plus_4 : out addr_t;
            instr : out instruction_t;

            -- outbound to top level module
            top_addr : out addr_t;
            top_dout : in word_t;
            top_din : out word_t;
            top_size : out ctrl_memwidth_t;
            top_wr : out ctrl_t
        );
    end component;


    component InstructionDecode is
        port(
            instr : in instruction_t;
            pc_plus_4 : in addr_t;
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
    end component;

    component MemoryAccess is
        port(
        -- inbound
        Address_in : in addr_t;
        WriteData_in : in word_t;
        ReadData_in : out word_t;
        MemRead_in, MemWrite_in : in ctrl_memwidth_t;
        MemSex_in : in std_logic;
        clk : in std_logic;

        -- outbound to top level module
        top_addr : out addr_t;
        top_dout : in word_t;
        top_din : out word_t;
        top_size : out ctrl_memwidth_t;
        top_wr : out ctrl_t);
    end component;


    component WriteBack is
        port(
        Link, JumpReg, JumpDir, MemToReg, TakeBranch : in ctrl_t;
        pc_plus_4, branch_addr, jump_addr: in addr_t;
        aluResult, memReadData, regReadData1 : in word_t;
        regWriteData : out word_t;
        new_pc : out addr_t);
    end component;


    -- control signals
    signal Link, Branch, JumpReg, JumpDir, memToreg, TakeBranch, Shift, ALUSrc, MemSex : ctrl_t;
    signal MemRead, MemWrite : ctrl_memwidth_t;
    signal memReadData : word_t;
    signal new_pc : addr_t;
    signal pc_plus_4, jump_addr, branch_addr : addr_t;
    signal instr : instruction_t;
    signal zeroxed, sexed, aluResult: word_t;
    signal aluop : alu_op_t;

    signal cpuclk : std_logic := '0';
    signal regclk : std_logic := '0';
    signal halt_cpu : boolean := false;

    signal cpurst : std_logic := '0';
    signal regrst : std_logic := '0';

    signal done : boolean := false;

    constant ESC : Character := Character'val(27);

    signal addr : addr_t;
    signal din : word_t;
    signal dout : word_t;
    signal size : ctrl_memwidth_t;
    signal wr : std_logic;
begin

    regFile1: regFile
        port map(
            readreg1 => readreg1, readreg2 => readreg2,
            writereg => writereg, writedata => regWriteData,
            readData1 => regReadData1, readData2 => regReadData2,
            clk => regclk, rst => regrst,
            regWrite => regWrite
        );

    if1: InstructionFetch
    generic map (PC_ADD => 4, CPI => 4, SINGLE_ADDRESS_SPACE => false)
    port map(
                clk => cpuclk,
                rst => cpurst,
                new_pc => new_pc,
                pc_plus_4 => pc_plus_4,
                instr => instr,

                top_addr => addr,
                top_dout => dout,
                top_din => din,
                top_size => size,
                top_wr => wr
            );

    mem_bus: mem port map (
        addr => addr,
        din => din,
        dout => dout,
        size => size,
        wr => wr,
        clk => cpuclk
    );

    id1: InstructionDecode
    port map(instr => instr,
             pc_plus_4 => pc_plus_4,
             jump_addr => jump_addr,

             regwrite => regwrite, link => link, jumpreg => jumpreg, jumpdirect => jumpdir, branch => Branch,
             memread => memread, memwrite => memwrite,
             memtoreg => memtoreg, memsex => memsex,
             shift => shift, alusrc => aluSrc,
             aluop => aluOp,        

             readreg1 => readReg1, readreg2 => readReg2, writeReg => writeReg,

             zeroxed => zeroxed, sexed => sexed,

             clk => cpuclk,
             rst => cpurst
         );
    ex1: Execute
    port map(
                pc_plus_4 => pc_plus_4,
                regReadData1 => regReadData1, regReadData2 => regReadData2,
                branch_addr => branch_addr,
                branch_in => Branch,
                shift_in => shift, alusrc_in => ALUSrc,
                aluop_in => ALUOp,

                zeroxed => zeroxed, sexed => sexed,

                takeBranch => takeBranch,
                ALUResult => ALUResult,

                clk => cpuclk,
                rst => cpurst
    );
    ma1: memoryAccess
    port map( 
        -- inbound
        Address_in => AluResult,
        WriteData_in => regReadData2,
        ReadData_in => memReadData,
        MemRead_in => memRead, MemWrite_in => memWrite,
        MemSex_in => memSex,
        clk => cpuclk,

        -- outbound to top level module
        top_addr => addr,
        top_dout => dout,
        top_din => din,
        top_size => size,
        top_wr => wr);

    wb1: WriteBack
    port map(
                Link => Link,
                JumpReg => JumpReg,
                JumpDir => JumpDir,
                MemToReg => MemToReg,
                TakeBranch => TakeBranch,
                pc_plus_4 => pc_plus_4,
                branch_addr => branch_addr,
                jump_addr => jump_addr,
                aluResult => aluResult,
                memReadData => memReadData,
                regReadData1 => regReadData1,
                regWriteData => regWriteData,
                new_pc => new_pc);
    
    test : process
    begin
        -- This halt_cpu thing doesn't work yet
        --halt_cpu <= true;
        --regrst <= '0';
        --wait for 2 ns;
        --regrst <= '1';
        --wait for 2 ns;
        --regrst <= '0';
        --wait for 20 ns;

        --readreg1 <= R1;
        --wait for 2 ns;

        --assert regReadData1 = ZERO report
        --    ANSI_RED "Failed to reset. 0 /= " & to_hstring(regReadData1) & ANSI_NONE
        --severity error;
        --halt_cpu <= false;

        cpurst <= '0';
        wait for 2 ns;
        cpurst <= '1';
        wait for 2 ns;
        cpurst <= '0';

        wait for 200 ns;

        readreg1 <= R1;
        wait for 2 ns;

        assert regReadData1 = X"0000_F000" report
                ANSI_RED & "Failed to ori. 0xF000 /= " & to_hstring(regReadData1) & ANSI_NONE
        severity error;

        readreg1 <= R1;
        readreg2 <= R2;
        wait for 2 ns;

        assert regReadData2 = X"0000_0BAD" report
                ANSI_RED & "Failed to ori. 0x0BAD /= " & to_hstring(regReadData2) & ANSI_NONE
        severity error;

        assert regReadData1 = X"0000_F000" report
                ANSI_RED & "Failed to ori. 0xF000 /= " & to_hstring(regReadData2) & ANSI_NONE
        severity error;

        done <= true;
        wait;
    end process;

    clkproc: process
    begin
        regclk <= not regclk;
        if not halt_cpu then
            cpuclk <= not cpuclk;
        end if;
        wait for 1 ns;
        if done then wait; end if;
    end process;
end struct;




