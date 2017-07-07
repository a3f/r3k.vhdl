library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;

entity uart_tx is
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


architecture behav of uart_tx is
    type STATE is (IDLE, START, DATA, STOP);
    signal state_reg : STATE;
    signal state_next : STATE;

    signal baud_reg : std_logic_vector( 4  downto 0  );
    signal baud_next : std_logic_vector( 4  downto 0  );
    signal n_reg : std_logic_vector( 4  downto 0  );
    signal n_next : std_logic_vector( 4  downto 0  );
    signal d_reg : std_logic_vector( 7  downto 0  );
    signal d_next : std_logic_vector( 7  downto 0  );
    signal tx_reg : std_logic;
    signal tx_next : std_logic;
    begin
	a: process (clk, reset) is
	begin
    	    if (reset = '1' ) then
      		state_reg <= IDLE;
        	baud_reg <= (others => '0');
		n_reg <= (others => '0');
                d_reg <= (others => '0');
                tx_reg <= '1';
	    elsif (clk'EVENT and (clk = '1')) then
                state_reg <= STATE_NEXT;
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
                    IDLE =>
                    tx_next <= '1';
                    if ( tx_start = '1' ) then
                        state_next <= START;
                        baud_next <= "00000";
                        d_next <= tx_data;
                    end if;
                when
                    START =>
                    tx_next <= '0';
                    if ( baud_tick = '1' ) then
                        baud_next <= vec_increment(baud_reg) ;
                    else
                        if ( ( baud_reg = X"10"  )  ) then
                            state_next <= DATA;
                            baud_next <= "00000";
                            n_next <= "00000";
                        end if;
                    end if;
                when
                    DATA =>
                    tx_next <= d_reg(0 );
                    if ( baud_tick = '1' ) then
                        baud_next <= vec_increment(baud_reg) ;
                    else
                        if ( ( baud_reg = X"10"  )  ) then
                            d_next <= std_logic_vector(unsigned(d_reg) srl 1);
                            baud_next <= "00000";
                            n_next <= vec_increment(n_reg) ;
                        else
                            if ( ( n_reg = X"8"  )  ) then
                                state_next <= STOP;
                            end if;
                        end if;
                    end if;
                when
                    STOP =>
                    tx_next <= '1';
                    if ( baud_tick = '1' ) then
                        baud_next <= vec_increment(baud_reg) ;
                    else
                        if ( ( baud_reg = X"10"  )  ) then
                            state_next <= IDLE;
                            tx_done_tick <= '1';
                        end if;
                    end if;
            end case;
        end process;
        tx <= tx_reg;
    end;


