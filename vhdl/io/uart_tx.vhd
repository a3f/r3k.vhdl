library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity uart_tx is
generic (
        idle : INTEGER( 1  downto 0  ) := 0 ;
        start : INTEGER( 1  downto 0  ) := 1 ;
        data : INTEGER( 1  downto 0  ) := 2 ;
        stop : INTEGER( 1  downto 0  ) := 3
    );
     port (
        clk :  in std_logic;
        reset :  in std_logic;
        tx_start :  in std_logic;
        baud_tick :  in std_logic;
        tx_data :  in std_logic_vector( 7  downto 0  );
        tx_done_tick :  out std_logic;
        tx :  out std_logic
    );
end entity;


architecture rtl of uart_tx is
    signal state_reg : std_logic_vector( 1  downto 0  );
    signal state_next : std_logic_vector( 1  downto 0  );
    signal baud_reg : std_logic_vector( 4  downto 0  );
    signal baud_next : std_logic_vector( 4  downto 0  );
    signal n_reg : std_logic_vector( 4  downto 0  );
    signal n_next : std_logic_vector( 4  downto 0  );
    signal d_reg : std_logic_vector( 7  downto 0  );
    signal d_next : std_logic_vector( 7  downto 0  );
    signal tx_reg : std_logic;
    signal tx_next : std_logic;
    begin
        process
        begin
            wait until ( ( reset'EVENT and ( reset = '1' )  )  or ( clk'EVENT and ( clk = '1' )  )  ) ;
            if ( reset ) then
                state_reg <= idle;
                baud_reg <= 0 ;
                n_reg <= 0 ;
                d_reg <= 0 ;
                tx_reg <= '1';
            else
                state_reg <= state_next;
                baud_reg <= baud_next;
                n_reg <= n_next;
                d_reg <= d_next;
                tx_reg <= tx_next;
            end if;
        end process;
        process
        begin
            wait ;
            state_next <= state_reg;
            tx_done_tick <= '0';
            baud_next <= baud_reg;
            n_next <= n_reg;
            d_next <= d_reg;
            tx_next <= tx_reg;
            case  ( state_reg ) is
                when
                    idle =>
                    tx_next <= '1';
                    if ( tx_start ) then
                        state_next <= start;
                        baud_next <= 0 ;
                        d_next <= tx_data;
                    end if;
                when
                    start =>
                    tx_next <= '0';
                    if ( baud_tick ) then
                        baud_next <= ( baud_reg + 1  ) ;
                    else
                        if ( ( baud_reg = 16  )  ) then
                            state_next <= data;
                            baud_next <= 0 ;
                            n_next <= 0 ;
                        end if;
                    end if;
                when
                    data =>
                    tx_next <= d_reg(0 );
                    if ( baud_tick ) then
                        baud_next <= ( baud_reg + 1  ) ;
                    else
                        if ( ( baud_reg = 16  )  ) then
                            d_next <= ( d_reg srl 1  ) ;
                            baud_next <= 0 ;
                            n_next <= ( n_reg + 1  ) ;
                        else
                            if ( ( n_reg = 8  )  ) then
                                state_next <= stop;
                            end if;
                        end if;
                    end if;
                when
                    stop =>
                    tx_next <= '1';
                    if ( baud_tick ) then
                        baud_next <= ( baud_reg + 1  ) ;
                    else
                        if ( ( baud_reg = 16  )  ) then
                            state_next <= idle;
                            tx_done_tick <= '1';
                        end if;
                    end if;
            end case;
        end process;
        tx <= tx_reg;
    end;


