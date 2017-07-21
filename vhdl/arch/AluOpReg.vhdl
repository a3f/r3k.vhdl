library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;


entity AluOpReg is
port(
    data   : in alu_op_t;
    enable  : in std_logic; -- load/enable.
    clr : in std_logic; -- async. clear.
    clk : in std_logic; -- clock.
    output   : out alu_op_t
);
end AluOpReg;

architecture behav of AluOpReg is

begin
    process(clk, clr)
    begin
        if clr = '1' then
            output <= ALU_AND;
        elsif rising_edge(clk) then
            if enable = '1' then
                output <= data;
            end if;
        end if;
    end process;
end behav;



