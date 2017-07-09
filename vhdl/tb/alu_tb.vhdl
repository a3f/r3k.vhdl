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
         AluResult  : out word_t;
         Zero       : out ctrl_t;

         trap       : out traps_t -- only TRAP_OVERFLOW is relevant
     );
    end component;

    signal Src1, Src2 : word_t;
    signal Op : alu_op_t;
    signal AluResult : word_t;
    signal ZeroInd : ctrl_t;
    signal trap : traps_t;

begin
   --  Component instantiation.
        instance: alu port map (Src1 => Src1, Src2 => Src2, AluOp => Op, AluResult => AluResult, Zero => ZeroInd, trap => trap); -- FIXME check traps

   --  This process does the real job.
        process

        variable error_count : integer := 0;
        variable error : boolean := false;

        constant BTRUE  : word_t := X"0000_0000";
        constant BFALSE : word_t := X"0000_0001";

        type testcase_t is record
            Src1 : word_t;
            AluOp : alu_op_t;
            Src2 : word_t;

            AluResult : word_t;
        end record;

        type testcase_table_t is array (natural range <>) of testcase_t;
        constant testcases : testcase_table_t := (
            -- Easy arithmetic
            (X"0000_0000", ALU_ADD, X"0000_0000", X"0000_0000"),
            (X"0000_0000", ALU_ADD, X"0000_0000", X"0000_0000"),
            (X"00f0_f0f0", ALU_ADD, X"0f0f_0f0f", X"0fff_ffff"),
            (X"f0f0_f0f0", ALU_ADDU, X"0f0f_0f0f", X"ffff_ffff"),
            (X"0000_0000", ALU_ADDU, X"0000_0000", X"0000_0000"),
            (X"00f0_f0f1", ALU_ADDU, X"0f0f_0f0f", X"1000_0000"),
            (X"0000_0002", ALU_ADDU, X"0000_0002", X"0000_0004"),
            (X"7000_1102", ALU_ADD,  X"8000_1009", X"f000_210B"),
            (X"8000_1102", ALU_ADD,  X"8000_1009", X"0000_210B"),
            (X"ffff_ffff", ALU_ADD,  X"0000_0001", X"0000_0000"),
            (X"ffff_ffff", ALU_SUB,  X"0000_0001", X"ffff_fffe"),
            (X"0000_0004", ALU_SUB,  X"0000_0001", X"0000_0003"),
            (X"0000_0004", ALU_SUB,  X"0000_0009", X"ffff_fffb"),

            -- Logic
            (ZERO, ALU_AND, ZERO, ZERO),
            (ZERO, ALU_OR, NEG_ONE, NEG_ONE),
            (NEG_ONE, ALU_NOR, ZERO, ZERO),
            (NEG_ONE, ALU_OR, ZERO, NEG_ONE),
            (X"8000_0000", ALU_OR,  X"0000_0001", X"8000_0001"),
            (X"f0f0_f0f0", ALU_XOR, X"0f0f_0f0f", X"ffff_ffff"),
            (X"f0f0_f0f0", ALU_OR,  X"0f0f_0f0f", X"ffff_ffff"),

            -- Shifts
            (X"0000_0001", ALU_SLL, X"0000_0001", X"0000_0002"),
            (X"0000_0001", ALU_SLL, X"0000_0002", X"0000_0004"),
            (X"ffff_0fff", ALU_SLL, X"0000_0000", X"ffff_0fff"),
            (X"0000_0000", ALU_SLL, X"0000_0000", X"0000_0000"), -- That's a nop
            (X"ffff_0fff", ALU_SLL, X"0000_0010", X"0fff_0000"),
            (X"ffff_0fff", ALU_SRL, X"0000_0010", X"0000_ffff"),
            (X"1fff_0fff", ALU_SRL, X"0000_0010", X"0000_1fff"),
            (X"8fff_0fff", ALU_SRA, X"0000_0010", X"ffff_8fff"),
            (X"8000_0000", ALU_SRA, X"0000_0001", X"C000_0000"),
            (X"7fff_ffff", ALU_SRA, X"0000_0003", X"0FFF_FFFF"),

            -- No multiplication/division tests cuz not implemented yet

            -- SLT(U)
            (X"0000_0000", ALU_SLT, X"0000_0001", X"0000_0001"),
            (X"0000_0001", ALU_SLT, X"0000_0000", X"0000_0000"),
            (NEG_ONE,      ALU_SLT, ZERO, X"0000_0001"),
            (NEG_ONE,      ALU_SLTU, ZERO, X"0000_0000"),
            (NEG_ONE,      ALU_SLTU, NEG_ONE, X"0000_0000"),
            (NEG_ONE,      ALU_SLT, NEG_ONE, X"0000_0000"),

            -- A bit hacky, we assume the ALU to output 0 and 1 same as SLT for branches
            (X"0000_0001", ALU_EQ, X"0000_0001", BTRUE),
            (X"1000_0001", ALU_EQ, X"0000_0001", BFALSE),
            (X"0000_0001", ALU_NE, X"0000_0001", BFALSE),
            (X"1000_0001", ALU_NE, X"0000_0001", BTRUE),

            (X"0000_0001", ALU_LEZ, DONT_CARE, BFALSE),
            (NEG_ONE,      ALU_LEZ, DONT_CARE, BTRUE),
            (ZERO,         ALU_LEZ, ZERO,      BTRUE),

            (X"0000_0001", ALU_LTZ, DONT_CARE, BFALSE),
            (NEG_ONE,      ALU_LTZ, DONT_CARE, BTRUE),
            (ZERO,         ALU_LTZ, ZERO,      BFALSE),

            (X"0000_0001", ALU_GTZ, DONT_CARE, BTRUE),
            (NEG_ONE,      ALU_GTZ, DONT_CARE, BFALSE),
            (ZERO,         ALU_GTZ, ZERO,      BFALSE),

            (X"0000_0001", ALU_GEZ, DONT_CARE, BTRUE),
            (NEG_ONE,      ALU_GEZ, DONT_CARE, BFALSE),
            (ZERO,         ALU_GEZ, ZERO,      BTRUE),
            
            (ZERO, ALU_AND, ZERO, ZERO)
        );
        begin
            wait for 10 ns;
            for i in testcases'range loop
         --  Set the inputs.
                Src1 <= testcases(i).Src1;
                Src2 <= testcases(i).Src2;
                Op <= testcases(i).AluOp;
         --  Wait for the results.
                wait for 10 ns;
         --  Check the outputs.
                error := (testcases(i).AluResult /= DONT_CARE and AluResult /= testcases(i).AluResult) or ((AluResult = ZERO and ZeroInd = '0') or (AluResult /= Zero and ZeroInd /= '0')) or trap /= TRAP_NONE;
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



