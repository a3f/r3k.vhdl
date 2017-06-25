library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;

--  A testbench has no ports.
entity ZeroExtend_tb is
    end ZeroExtend_tb;

architecture test of ZeroExtend_tb is
   --  Declaration of the component that will be instantiated.
    component zeroextend
        port (shamt : in std_logic_vector(4 downto 0); zeroxed : out word_t);
    end component;

   --  Specifies which entity is bound with the component.
    for instance: ZeroExtend use entity work.ZeroExtend;
        signal shamt : std_logic_vector(4 downto 0);
        signal zeroxed : word_t;

begin
   --  Component instantiation.
        instance: ZeroExtend port map (shamt => shamt, zeroxed => zeroxed);

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
