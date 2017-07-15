library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.txt_utils.all;

--  A testbench has no ports.
entity alu_tb is
    end alu_tb;

architecture test of alu_tb is
   --  Declaration of the component that will be instantiated.
    component alu
    port(Src1       : in word_t;
         Src2       : in word_t;
         AluOp      : in alu_op_t;
         Immediate  : in ctrl_t;
         AluResult  : out word_t;
         isZero     : out ctrl_t;

         trap       : out traps_t -- only TRAP_OVERFLOW is relevant
     );
    end component;

    signal Src1, Src2 : word_t;
    signal Op : alu_op_t;
    signal immediate : ctrl_t;
    signal AluResult : word_t;
    signal isZero : ctrl_t;
    signal trap : traps_t;

begin
   --  Component instantiation.
    instance: alu port map (Src1 => Src1, Src2 => Src2, AluOp => Op, immediate => immediate, AluResult => AluResult, isZero => isZero, trap => trap); -- FIXME check traps

   --  This process does the real job.
        process

        variable error_count : integer := 0;
        variable error : boolean := false;

        constant BTRUE  : word_t := (31 downto 1 => '-', 0 => '1');
        constant BFALSE : word_t := (31 downto 1 => '-', 0 => '0');

        constant I : ctrl_t := '1';
        constant R : ctrl_t := '0';

        type testcase_t is record
            Src1 : word_t;
            AluOp : alu_op_t;
            Immediate : ctrl_t;
            Src2 : word_t;

            AluResult : word_t;
        end record;

        type testcase_table_t is array (natural range <>) of testcase_t;
        constant testcases : testcase_table_t := (
            -- Easy arithmetic
            (X"0000_0000", ALU_ADD,R, X"0000_0000", X"0000_0000"),
            (X"0000_0000", ALU_ADD,R, X"0000_0000", X"0000_0000"),
            (X"00f0_f0f0", ALU_ADD,R, X"0f0f_0f0f", X"0fff_ffff"),
            (X"f0f0_f0f0", ALU_ADDU,R,X"0f0f_0f0f", X"ffff_ffff"),
            (X"0000_0000", ALU_ADDU,R,X"0000_0000", X"0000_0000"),
            (X"00f0_f0f1", ALU_ADDU,R,X"0f0f_0f0f", X"1000_0000"),
            (X"0000_0002", ALU_ADDU,R,X"0000_0002", X"0000_0004"),
            (X"7000_1102", ALU_ADD,R, X"8000_1009", X"f000_210B"),
            (X"8000_1102", ALU_ADD,R, X"8000_1009", X"0000_210B"),
            (X"ffff_ffff", ALU_ADD,R, X"0000_0001", X"0000_0000"),
            (X"ffff_ffff", ALU_SUB,R, X"0000_0001", X"ffff_fffe"),
            (X"0000_0004", ALU_SUB,R, X"0000_0001", X"0000_0003"),
            (X"0000_0004", ALU_SUB,R, X"0000_0009", X"ffff_fffb"),

            -- Logic
            (ZERO, ALU_AND,R, ZERO, ZERO),
            (ZERO, ALU_OR,R, NEG_ONE, NEG_ONE),
            (NEG_ONE, ALU_NOR,R, ZERO, ZERO),
            (NEG_ONE, ALU_OR,R, ZERO, NEG_ONE),
            (X"8000_0000", ALU_OR,R,  X"0000_0001", X"8000_0001"),
            (X"8000_0000", ALU_OR,R,  X"ffff_ffff", X"ffff_ffff"),
            (X"8000_0000", ALU_OR,I,  X"ffff_ffff", X"8000_ffff"),
            (X"f0f0_f0f0", ALU_XOR,R, X"0f0f_0f0f", X"ffff_ffff"),
            (X"f0f0_f0f0", ALU_OR,R,  X"0f0f_0f0f", X"ffff_ffff"),

            -- Shifts
            (X"0000_0001", ALU_SLL,R, X"0000_0001", X"0000_0002"),
            (X"0000_0001", ALU_SLL,R, X"0000_0002", X"0000_0004"),
            (X"ffff_0fff", ALU_SLL,R, X"0000_0000", X"ffff_0fff"),
            (X"0000_0000", ALU_SLL,R, X"0000_0000", X"0000_0000"), -- That's a nop
            (X"ffff_0fff", ALU_SLL,R, X"0000_0010", X"0fff_0000"),
            (X"ffff_0fff", ALU_SRL,R, X"0000_0010", X"0000_ffff"),
            (X"1fff_0fff", ALU_SRL,R, X"0000_0010", X"0000_1fff"),
            (X"8fff_0fff", ALU_SRA,R, X"0000_0010", X"ffff_8fff"),
            (X"8000_0000", ALU_SRA,R, X"0000_0001", X"C000_0000"),
            (X"7fff_ffff", ALU_SRA,R, X"0000_0003", X"0FFF_FFFF"),

            -- No multiplication/division tests cuz not implemented yet

            -- SLT(U)
            (X"0000_0000", ALU_SLT,R, X"0000_0001", X"0000_0001"),
            (X"0000_0001", ALU_SLT,R, X"0000_0000", X"0000_0000"),
            (NEG_ONE,      ALU_SLT,R, ZERO, X"0000_0001"),
            (NEG_ONE,      ALU_SLTU,R, ZERO, X"0000_0000"),
            (NEG_ONE,      ALU_SLTU,R, NEG_ONE, X"0000_0000"),
            (NEG_ONE,      ALU_SLT,R, NEG_ONE, X"0000_0000"),

            -- BTRUE, BFALSE refer to whether the Zero signal of the ALU is asserted or not
            (X"0000_0001", ALU_EQ,R, X"0000_0001", BTRUE),
            (X"1000_0001", ALU_EQ,R, X"0000_0001", BFALSE),
            (X"0000_0001", ALU_NE,R, X"0000_0001", BFALSE),
            (X"1000_0001", ALU_NE,R, X"0000_0001", BTRUE),

            (X"0000_0001", ALU_LEZ,R, DONT_CARE, BFALSE),
            (NEG_ONE,      ALU_LEZ,R, DONT_CARE, BTRUE),
            (ZERO,         ALU_LEZ,R, DONT_CARE, BTRUE),

            (X"0000_0001", ALU_LTZ,R, DONT_CARE, BFALSE),
            (NEG_ONE,      ALU_LTZ,R, DONT_CARE, BTRUE),
            (ZERO,         ALU_LTZ,R, DONT_CARE, BFALSE),

            (X"0000_0001", ALU_GTZ,R, DONT_CARE, BTRUE),
            (NEG_ONE,      ALU_GTZ,R, DONT_CARE, BFALSE),
            (ZERO,         ALU_GTZ,R, DONT_CARE, BFALSE),

            (X"0000_0001", ALU_GEZ,R, DONT_CARE, BTRUE),
            (NEG_ONE,      ALU_GEZ,R, DONT_CARE, BFALSE),
            (ZERO,         ALU_GEZ,R, DONT_CARE, BTRUE),
            
            (ZERO, ALU_AND,R, ZERO, ZERO)
        );
        begin
            wait for 10 ns;
            for i in testcases'range loop
         --  Set the inputs.
                Src1 <= testcases(i).Src1;
                Src2 <= testcases(i).Src2;
                Op <= testcases(i).AluOp;
                Immediate <= testcases(i).immediate;
         --  Wait for the results.
                wait for 10 ns;
         --  Check the outputs.
                if testcases(i).AluResult(31) /= '-' then
                    error := AluResult /= testcases(i).AluResult
                    or (AluResult /= Zero and isZero /= '0');
                else
                    error := testcases(i).AluResult(0) /= isZero;
                end if;
                error := error or trap /= TRAP_NONE;

                if error then
                    error_count := error_count + 1;
                end if;
                assert not error report
                Character'Val(27) & "[31mFailure in testcase " & integer'image(i)
                & Character'Val(27) & "[m" severity note;
                assert trap = TRAP_NONE report
                Character'Val(27) & "[31mALU trapped.! " & integer'image(i)
                & Character'Val(27) & "[m" severity note;

                assert not error report Character'Val(27) &
                "[31m" & to_hstring(Src1) & " " &
                alu_op_t'image(Op) & " " &
                to_hstring(Src2)
                & " = "    & to_hstring(AluResult) &
                " (Expected: " & to_hstring(testcases(i).AluResult) & ")"
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



