library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;

entity mmio_dipswitch is
    port (
        -- static
             addr : in addr_t;
             din: in word_t;
             dout: out word_t;
             size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
             wr      : in std_logic;
             en      : in    std_logic;
             clk : in std_logic;
             trap : out traps_t := TRAP_NONE;

        -- dip switch
             switch : in std_logic_vector(7 downto 0)
         );
end mmio_dipswitch;

architecture mmio of mmio_dipswitch is
    constant reading : std_logic := '0';

    signal data_out : word_t;
begin
    dout <= data_out when en = '1' and wr = '0' else HI_Z;
    process(clk)
    begin
        if rising_edge(clk) and en = '1' and size /= "00" then
            case wr is
                when reading => zeroextend(data_out, switch);
                when others => trap <= TRAP_SEGFAULT;
            end case;
        end if;
    end process;
end;
