-- Counts clock cycles elapsed since system startup
-- FIXME Maybe use a separate clock? VGA for example?
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;

entity mmio_tsc is
    port (
        -- static
             addr : in addr_t;
             din: in word_t;
             dout: out word_t;
             size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
             wr      : in std_logic;
             en      : in    std_logic;
             clk : in std_logic;
             trap : out traps_t := TRAP_NONE
         );
end mmio_tsc;

architecture mmio of mmio_tsc is
    constant reading : std_logic := '0';

    signal tstamp : word_t := ZERO;
    signal data_out : word_t;
begin
    dout <= data_out when en = '1' and wr = '0' else HI_Z;
    process(clk) begin
        if rising_edge(clk) then
            if size /= "00" and en = '1' then
                case wr is
                    when reading => data_out <= tstamp;
                    when others => null;
                end case;
            end if;

            tstamp <= vec_increment(tstamp);

        end if;
    end process;
end;

