library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;

entity uart_rx is
     port (
        clk :  in std_logic;
        reset :  in std_logic;
        rx :  in std_logic;
        baud_tick :  in std_logic;
        rx_done_tick :  out std_logic;
        rx_data :  out std_logic_vector( 7  downto 0  )
    );
end entity;


architecture rtl of uart_rx is
    type STATE is (IDLE, START, DATA, STOP);
    signal state_reg : STATE;
    signal state_next : STATE;

    signal baud_reg : std_logic_vector( 4  downto 0  );
    signal baud_next : std_logic_vector( 4  downto 0  );
    signal n_reg : std_logic_vector( 3  downto 0  );
    signal n_next : std_logic_vector( 3  downto 0  );
    signal d_reg : std_logic_vector( 7  downto 0  );
    signal d_next : std_logic_vector( 7  downto 0  );
    begin
        process
        begin
            wait until ( ( reset'EVENT and ( reset = '1' )  )  or ( clk'EVENT and ( clk = '1' )  )  ) ;
            if ( reset = '1' ) then
                state_reg <= IDLE;
                baud_reg <= (others => '0');
                n_reg <= (others => '0');
                d_reg <= (others => '0');
            else
                state_reg <= state_next;
                baud_reg <= baud_next;
                n_reg <= n_next;
                d_reg <= d_next;
            end if;
        end process;
        process
        begin
            wait ;
            state_next <= state_reg;
            rx_done_tick <= '0';
            baud_next <= baud_reg;
            n_next <= n_reg;
            d_next <= d_reg;
            case  ( state_reg ) is
                when
                    IDLE =>
                    if ( rx = '0' ) then
                        state_next <= START;
                        baud_next <= "00000";
                    end if;
                when
                    START =>
                    if ( baud_tick = '1' ) then
                        baud_next <= vec_increment(baud_reg) ;
                    else
                        if ( ( baud_reg = X"8"  )  ) then
                            state_next <= DATA;
                            baud_next <= "00000";
                            n_next <= "0000";
                        end if;
                    end if;
                when
                    DATA =>
                    if ( baud_tick = '1' ) then
                        baud_next <= vec_increment(baud_reg) ;
                    else
                        if ( baud_reg = X"10"  ) then
                            d_next <= ( rx & d_reg(7  downto 1 ) );
                            n_next <= vec_increment(n_reg);
                            baud_next <= "00000";
                        else
                            if ( ( n_reg = X"8"  )  ) then
                                state_next <= STOP;
                            end if;
                        end if;
                    end if;
                when
                    STOP =>
                    if ( baud_tick = '1' ) then
                        baud_next <= vec_increment(baud_reg) ;
                    else
                        if ( ( baud_reg = X"10"  )  ) then
                            state_next <= IDLE;
                            rx_done_tick <= '1';
                        end if;
                    end if;
            end case;
        end process;
        rx_data <= d_reg;
    end;


