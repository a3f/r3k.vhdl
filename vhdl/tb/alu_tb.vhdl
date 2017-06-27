library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

--  A testbench has no ports.
entity alu_tb is
    end alu_tb;

architecture test of alu_tb is
   --  Declaration of the component that will be instantiated.
    component alu
    port(Src1       : in word_t;
         Src2       : in word_t;
         AluOp      : in alu_op_t;
         AluResult  : out word_t;
         Zero       : out std_logic);
    end component;

   --  Specifies which entity is bound with the component.
    for instance: alu use entity work.alu;
        signal Src1, Src2 : word_t;
        signal AluOp : alu_op_t;
        signal AluResult : word_t;
        signal ZeroInd : std_logic;

begin
   --  Component instantiation.
        instance: alu port map (Src1 => Src1, Src2 => Src2, AluOp => AluOp, AluResult => AluResult, Zero => ZeroInd);

   --  This process does the real job.
        process

        variable error       : boolean := false;
        variable error_count : integer := 0;

        type testcase_t is record
            Src1 : word_t;
            AluOp : alu_op_t;
            Src2 : word_t;

            AluResult : word_t;
        end record;

        type testcase_table_t is array (natural range <>) of testcase_t;
        constant testcases : testcase_table_t := (
            (ZERO, ALU_AND, ZERO, ZERO),
            (ZERO, ALU_OR, NEG_ONE, NEG_ONE),
            (NEG_ONE, ALU_NOR, ZERO, ZERO),
            (X"f0f0_f0f0", ALU_XOR, X"0f0f_0f0f", X"ffff_ffff")
        );
        begin
            for i in testcases'range loop
         --  Set the inputs.
                Src1 <= testcases(i).Src1;
                Src2 <= testcases(i).Src2;
                AluOp <= testcases(i).AluOp;
         --  Wait for the results.
                wait for 1 ns;
         --  Check the outputs.
                error := AluResult /= testcases(i).AluResult or ((AluResult = ZERO and ZeroInd = '0') or (AluResult /= Zero and ZeroInd /= '0'));
                if error then
                    error_count := error_count + 1;
                end if;
                assert not error report
                Character'Val(27) & "[31mFailure in testcase " & integer'image(i)
                & Character'Val(27) & "[m" severity note;
            end loop;
            assert error_count /= 0 report
            -- ANSI escape characters for green text
            Character'Val(27) & "[32mTest's over." & Character'Val(27) & "[m"
            severity note;
            assert error_count = 0 report
            -- ANSI escape characters for green text
            Character'Val(27) & "[31m" & integer'image(error_count) & " testcase(s) failed." & Character'Val(27) & "[m"
            severity failure;
            --  Wait forever; this will finish the simulation.
            wait;
        end process;
end test;



