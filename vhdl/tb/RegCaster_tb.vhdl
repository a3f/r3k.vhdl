library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use ieee.numeric_std.all;
use work.utils.all;

--  A testbench has no ports.
entity RegCaster_tb is
    end RegCaster_tb;

architecture test of RegCaster_tb is
   --  Declaration of the component that will be instantiated.
    component RegCaster
        port (input : in word_t;
              SignExtend : in ctrl_t;
              size : in ctrl_memwidth_t;
              extended : out word_t
             );
    end component;

   --  Specifies which entity is bound with the component.
    for instance: RegCaster use entity work.RegCaster;
        signal input : word_t;
        signal SignExtend : ctrl_t;
        signal size : ctrl_memwidth_t;
        signal extended : word_t;

begin
   --  Component instantiation.
        instance: RegCaster port map (
            input => input,
            SignExtend => SignExtend,
            size => size,
            extended => extended
            );

   --  This process does the real job.
        process
        variable error       : boolean := false;
        variable error_count : integer := 0;

        type load_t is record
            SignExtend : ctrl_t;
            size       : ctrl_memwidth_t;
        end record;
        type load_table_t is array (natural range <>) of load_t;
        constant loads : load_table_t := (
            ('0', WIDTH_BYTE),
            ('1', WIDTH_BYTE),
            ('0', WIDTH_HALF),
            ('1', WIDTH_HALF),
            ('0', WIDTH_WORD),
            ('1', WIDTH_WORD)
        );
        constant lbu : natural := 0;
        constant lb  : natural := 1;
        constant lhu : natural := 2;
        constant lh  : natural := 3;
        constant lwu : natural := 4;
        constant lw  : natural := 5; -- Won't happend

        type testcase_t is record
            input    : word_t;
            op       : natural;
            extended : word_t;
        end record;

        type testcase_table_t is array (natural range <>) of testcase_t;
        constant testcases : testcase_table_t := (
            (X"0000_0000", lb,  X"0000_0000"), 
            (X"0000_0000", lw,  X"0000_0000"), 
            (X"0000_ffff", lwu, X"0000_ffff"), 
            (X"0000_ffff", lw,  X"0000_ffff"), 
            (X"0000_00ff", lb,  X"ffff_ffff"),
            (X"ffff_f00d", lh,  X"ffff_f00d"),
            (X"0000_f00d", lh,  X"ffff_f00d"),
            (X"0000_0bad", lhu, X"0000_0bad")
        );
        begin
            for i in testcases'range loop
         --  Set the inputs.
                input <= testcases(i).input;
                SignExtend <= loads(testcases(i).op).SignExtend;
                size <= loads(testcases(i).op).size;
         --  Wait for the results.
                wait for 1 ns;
         --  Check the outputs.
                error := extended /= testcases(i).extended;
                if error then
                    error_count := error_count + 1;
                end if;
                assert not error report
                Character'Val(27) & "[31mFailure in testcase " & integer'image(i)
                & Character'Val(27) & "[m" severity note;
                assert not error report Character'Val(27) &
                "[31mGot: "    & integer'image(vtou(extended)) &
                ", Expected: " & integer'image(vtou(testcases(i).extended))
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

