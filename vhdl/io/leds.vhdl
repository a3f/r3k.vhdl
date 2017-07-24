library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity mmio_leds is
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
        -- leds
             leds : out std_logic_vector(7 downto 0)
         );
end mmio_leds ;

architecture mmio of mmio_leds is
    constant reading : std_logic := '0';
    constant writing : std_logic := '1';

    signal data_out : word_t;
begin
    dout <= data_out when en = '1' and wr = '0' else HI_Z;
    process(clk) begin
        if rising_edge(clk) and en = '1' and size /= "00" then
            case wr is
                when reading => data_out <= NEG_ONE;
                when writing => leds <= din(7 downto 0);
                when others => trap <= TRAP_SEGFAULT;
            end case;
        end if;
    end process;
 end mmio;
