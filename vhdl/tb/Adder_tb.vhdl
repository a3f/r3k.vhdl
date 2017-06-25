library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

--  A testbench has no ports.
entity Adder_tb is
    end Adder_tb;

architecture test of Adder_tb is
   --  Declaration of the component that will be instantiated.
    component adder
        port (src1 : in addr_t; src2 : in addrdiff_t; result : out addrdiff_t);
    end component;

   --  Specifies which entity is bound with the component.
    for instance: Adder use entity work.Adder;
        signal src1 : addr_t;
        signal src2 : addrdiff_t;
        signal result : addr_t;

begin
   --  Component instantiation.
        instance: Adder port map (src1 => src1, src2 => src2, result => result);

   --  This process does the real job.
        process
        variable error       : boolean := false;
        variable error_count : integer := 0;

        type testcase_t is record
            input1 : addr_t;
            input2 : addrdiff_t;
            output : word_t;
        end record;

        type testcase_table_t is array (natural range <>) of testcase_t;
        constant testcases : testcase_table_t := (
            (ZERO, ZERO, ZERO),
            (ZERO, NEG_ONE, NEG_ONE),
            (NEG_ONE, ZERO, NEG_ONE),
            (ZERO, X"0000_0010", X"0000_0010"),
            (X"ff00_0000", ZERO,  X"ff00_0000"),
            (X"bfc0_0000",  X"0000_0004",  X"bfc0_0004"),
            (X"bfc0_000f",  X"0000_0004",  X"bfc0_0013")
        );
        begin
            for i in testcases'range loop
         --  Set the inputs.
                src1 <= testcases(i).input1;
                src2 <= testcases(i).input2;
         --  Wait for the results.
                wait for 1 ns;
         --  Check the outputs.
                error := result /= testcases(i).output;
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



