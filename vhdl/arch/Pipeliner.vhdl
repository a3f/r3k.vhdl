library ieee ;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

entity Pipeliner is
    port(
        clk, rst : in std_logic;
        IF_en, ID_en, EX_en, MEM_en, WB_en : out std_logic;
        Instruction_done : out std_logic
    );
end;

architecture behav of Pipeliner is
begin
    process (clk, rst)
        variable ticks : natural := 1;
        --constant CPI : natural := 8;
    begin
        if rst = '1' then
            ticks := 1;
        elsif rising_edge(clk) then
            IF_en  <= '0';
            ID_en  <= '0';
            EX_en  <= '0';
            MEM_en <= '0';
            WB_en  <= '0';
            Instruction_done <= '0';

            case ticks is
                when 2 => IF_en  <= '1';
                          printf("===== IF  ===== \n");
                when 3 => ID_en  <= '1';
                          printf("===== ID  ===== \n");
                when 4 => EX_en  <= '1';
                          printf("===== EX  ===== \n");
                when 5 => MEM_en <= '1';
                          printf("===== MEM ===== \n");
                when 8 => WB_en  <= '1';
                          printf("===== WB  ===== \n");
                when 9 => Instruction_done <= '1'; ticks := 0;
              when others => null;
            end case;
            --if ticks = CPI then
                --ticks := 0;
            --end if;
            ticks := ticks + 1;
        end if;
    end process;
end architecture;
