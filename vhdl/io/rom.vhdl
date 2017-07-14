-- Generated by tools/generate-rom.pl
-- Template: https://www.xilinx.com/support/answers/8183.html

library ieee;
use ieee.std_logic_1164.all;
entity rom is
    port ( a: in std_logic_vector(31 downto 0);
           z: out std_logic_vector(31 downto 0)
         );
    attribute syn_romstyle : string;
    attribute syn_romstyle of z : signal is "select_rom";
end rom;

architecture rtl of rom is
    begin
    process(a)
        begin
        case a is

        when X"0000_0000" => z <= X"3421ffff"; -- 4!..

        when others => z <= X"ffffffff";
        end case;
    end process;
end rtl;