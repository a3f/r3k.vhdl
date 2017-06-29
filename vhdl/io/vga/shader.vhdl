library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.color_util.all;

entity shader is
    port (
          x : in std_logic_vector (9 downto 0); -- 640 = 10_1000_0000b
          y : in std_logic_vector (8 downto 0); -- 480 = 1_1110_0000b

          r, g, b : out std_logic_vector (3 downto 0)


    );
end entity shader;


architecture behavioral of shader is
    constant h_display  : integer := 640;
    constant v_display  : integer := 480;

begin
    process(x, y)
    begin
        r <= x(9 downto 6);
        g <= y(8 downto 5);
        b <= "0000";
        if x = "0000000000" or y = "000000000" or x = "1001111111" or y = "111011111" then
            (r, g, b) <= WHITE;
        end if;
    end process;
end architecture;

