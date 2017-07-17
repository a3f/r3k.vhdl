library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

--  A testbench has no ports.
entity ZeroExtender_tb is
    end ZeroExtender_tb;

architecture test of ZeroExtender_tb is
   --  Declaration of the component that will be instantiated.
    component zeroextender
        port (shamt : in std_logic_vector(4 downto 0); zeroxed : out word_t);
    end component;

   --  Specifies which entity is bound with the component.
    for instance: ZeroExtender use entity work.ZeroExtender;
        signal shamt : std_logic_vector(4 downto 0);
        signal zeroxed : word_t;

begin
   --  Component instantiation.
        instance: ZeroExtender port map (shamt => shamt, zeroxed => zeroxed);

   --  This process does the real job.
        process
        variable error       : boolean := false;
        variable error_count : integer := 0;

        constant twentyseven_zeroes : std_logic_vector(26 downto 0) := (others => '0');
        type testcase_t is record
            input : std_logic_vector(4 downto 0);
            output : word_t;
        end record;

        type testcase_table_t is array (natural range <>) of testcase_t;
        constant testcases : testcase_table_t := (
            ("00000",  ZERO),
            ("11111",  twentyseven_zeroes & "11111"),
            ("10001",  twentyseven_zeroes & "10001")
        );
        begin
            for i in testcases'range loop
         --  Set the inputs.
                shamt <= testcases(i).input;
         --  Wait for the results.
                wait for 1 ns;
         --  Check the outputs.
                error := zeroxed /= testcases(i).output;
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
