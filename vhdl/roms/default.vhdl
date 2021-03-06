-- Generated by tools/generate-rom.pl
-- Template: https://www.xilinx.com/support/answers/8183.html
-- But changed manually afterwards

library ieee;
use ieee.std_logic_1164.all;
use work.txt_utils.all;
use work.arch_defs.all;
use work.utils.all;

entity rom_default is
    port ( a: in std_logic_vector(31 downto 0);
           z: out std_logic_vector(31 downto 0);
           en: in std_logic
         );
    attribute syn_romstyle : string;
    attribute syn_romstyle of z : signal is "select_rom";
end rom_default;

architecture rtl of rom_default is
    signal my_z : word_t;
begin
    z <= my_z when en = '1' else HI_Z;
    process(a)
    begin
        if en = '1' then
            printf("Address = %s\n", a);
            case a is
                -- _start:
                -- FIXME the first instruction won't be executed.
                -- No idea why, so keep that in mind and place a nop there or something
                when X"0000_0000" => my_z <= X"0000_0000";
                when X"0000_0004" => my_z <= X"3421_f000";    -- ori     $1,$1,0xf000
                when X"0000_0008" => my_z <= X"0000_0000";
                when X"0000_000C" => my_z <= X"3422_0bad";    -- ori     $1,$2,0xbad
                when X"0000_0010" => my_z <= X"0000_0000";
                when X"0000_0014" => my_z <= X"3c03_A000";    -- lui     $3,0xA000
                when X"0000_0018" => my_z <= X"0000_0000";
                when X"0000_001C" => my_z <= X"a062_0000";    -- sb      $2,0($3)
                when X"0000_0020" => my_z <= X"0000_0000";
                when X"0000_0024" => my_z <= X"0000_0000";
                when X"0000_0028" => my_z <= X"8064_0000";    -- lb      $4,0($3)
                when X"0000_002C" => my_z <= X"0800_0000";  -- j       0 <_start>
                when X"0000_0030" => my_z <= X"0000_0000";  -- j       0 <_start>

                when others => null;
            end case;
        end if;
    end process;
end rtl;
