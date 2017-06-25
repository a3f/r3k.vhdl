library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

--  A testbench has no ports.
entity SignExtend_tb is
    end SignExtend_tb;

architecture test of SignExtend_tb is
   --  Declaration of the component that will be instantiated.
    component signextend
        port (immediate : in halfword_t; sexed : out word_t);
    end component;

   --  Specifies which entity is bound with the component.
    for instance: SignExtend use entity work.SignExtend;
        signal immediate : halfword_t;
        signal sexed : word_t;

begin
   --  Component instantiation.
        instance: SignExtend port map (immediate => immediate, sexed => sexed);

   --  This process does the real job.
        process
        variable error       : boolean := false;
        variable error_count : integer := 0;

        constant sixteen_zeroes : halfword_t := (others => '0');
        constant sixteen_ones   : halfword_t := (others => '1');
        type testcase_t is record
            input : halfword_t;
            output : word_t;
        end record;

        type testcase_table_t is array (natural range <>) of testcase_t;
        constant testcases : testcase_table_t := (
            ("0000000000000000",  ZERO),
            ("0111100000000000",  sixteen_zeroes & "0111100000000000"),
            ("1111111111111111",  sixteen_ones   & "1111111111111111"),
            ("1000000000000001",  sixteen_ones   & "1000000000000001")
        );
        begin
            for i in testcases'range loop
         --  Set the inputs.
                immediate <= testcases(i).input;
         --  Wait for the results.
                wait for 1 ns;
         --  Check the outputs.
                error := sexed /= testcases(i).output;
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

