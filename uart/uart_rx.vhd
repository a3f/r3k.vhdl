
library ieee;
use ieee.std_logic_1164.all;
package vl2vh_common_pack is 
    type vl2vh_memory_type is      array  ( natural range <> , natural range <>  )  of std_logic ;
    function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : std_logic;  constant falseval : std_logic)  return std_logic; 
    function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : std_logic_vector;  constant falseval : std_logic_vector)  return std_logic_vector; 
end package; 




package body vl2vh_common_pack is 
    function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : std_logic;  constant falseval : std_logic)  return std_logic is 
    begin
        if ( cond ) then 
             return trueval;
        else 
             return falseval;
        end if;
    end;
    function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : std_logic_vector;  constant falseval : std_logic_vector)  return std_logic_vector is 
    begin
        if ( cond ) then 
             return trueval;
        else 
             return falseval;
        end if;
    end;
end; 


library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.vl2vh_common_pack.all;
entity uart_rx is 
generic (
        idle : INTEGER( 1  downto 0  ) := 0 ;
        start : INTEGER( 1  downto 0  ) := 1 ;
        data : INTEGER( 1  downto 0  ) := 2 ;
        stop : INTEGER( 1  downto 0  ) := 3 
    );
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
    signal state_reg : std_logic_vector( 1  downto 0  );
    signal state_next : std_logic_vector( 1  downto 0  );
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
            if ( reset ) then 
                state_reg <= idle;
                baud_reg <= 0 ;
                n_reg <= 0 ;
                d_reg <= 0 ;
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
                    idle => 
                    if ( (  not rx )  ) then 
                        state_next <= start;
                        baud_next <= 0 ;
                    end if;
                when 
                    start => 
                    if ( baud_tick ) then 
                        baud_next <= ( baud_reg + 1  ) ;
                    else 
                        if ( ( baud_reg = 8  )  ) then 
                            state_next <= data;
                            baud_next <= 0 ;
                            n_next <= 0 ;
                        end if;
                    end if;
                when 
                    data => 
                    if ( baud_tick ) then 
                        baud_next <= ( baud_reg + 1  ) ;
                    else 
                        if ( ( baud_reg = 16  )  ) then 
                            d_next <= ( rx & d_reg(7  downto 1 ) );
                            n_next <= ( n_reg + 1  ) ;
                            baud_next <= 0 ;
                        else 
                            if ( ( n_reg = 8  )  ) then 
                                state_next <= stop;
                            end if;
                        end if;
                    end if;
                when 
                    stop => 
                    if ( baud_tick ) then 
                        baud_next <= ( baud_reg + 1  ) ;
                    else 
                        if ( ( baud_reg = 16  )  ) then 
                            state_next <= idle;
                            rx_done_tick <= '1';
                        end if;
                    end if;
            end case;
        end process;
        rx_data <= d_reg;
    end; 


