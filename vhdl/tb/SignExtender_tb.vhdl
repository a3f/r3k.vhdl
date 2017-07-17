library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

--  A testbench has no ports.
entity SignExtender_tb is
    end SignExtender_tb;

architecture test of SignExtender_tb is
   --  Declaration of the component that will be instantiated.
    component signextender
        port (immediate : in half_t; sexed : out word_t);
    end component;

   --  Specifies which entity is bound with the component.
    for instance: SignExtender use entity work.SignExtender;
        signal immediate : half_t;
        signal sexed : word_t;

begin
   --  Component instantiation.
        instance: SignExtender port map (immediate => immediate, sexed => sexed);

   --  This process does the real job.
        process
        variable error       : boolean := false;
        variable error_count : integer := 0;

        constant sixteen_zeroes : half_t := (others => '0');
        constant sixteen_ones   : half_t := (others => '1');
        type testcase_t is record
            input : half_t;
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
                ANSI_RED & "Failure in testcase " & integer'image(i) & ANSI_NONE severity note;
            end loop;
            assert error_count /= 0 report ANSI_GREEN & "Test's over." & ANSI_NONE severity note;
            assert error_count = 0 report
            ANSI_RED & integer'image(error_count) & " testcase(s) failed." & ANSI_NONE
            severity failure;
            --  Wait forever; this will finish the simulation.
            wait;
        end process;
end test;

