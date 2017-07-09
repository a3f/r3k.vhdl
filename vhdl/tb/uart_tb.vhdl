-- SKIP FIXME: Niklas remove this line, when the test succeeds
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;

entity uart_tb is
    end uart_tb;

architecture behav of uart_tb is

    component uart_tx
    port(
            clk :  in std_logic;
            reset :  in std_logic;
            tx_start :  in std_logic;
            baud_tick :  in std_logic;
            tx_data :  in std_logic_vector( 7  downto 0  );
            tx_done_tick :  out std_logic;
            tx :  out std_logic
    );
    end component;
    component uart_rx
    port (
            clk :  in std_logic;
            reset :  in std_logic;
            rx :  in std_logic;
            baud_tick :  in std_logic;
            rx_done_tick :  out std_logic;
            rx_data :  out std_logic_vector( 7  downto 0  )
    );
    end component;

    type state_t is (idle, received, transmit);
    signal rx_data: std_logic_vector(7 downto 0);
    signal rx_done_tick, tx_done_tick: std_logic;
    signal tx_data_next, tx_data: std_logic_vector(7 downto 0);
    signal tx_start: std_logic;
    signal reset, rx, tx: std_logic;
    signal state_next, state: state_t;

    signal clk : std_logic; -- system clock
    signal baud_tick : std_logic; -- 19200

begin

tx_instance: uart_tx port map (clk, reset, tx_start, baud_tick, tx_data, tx_done_tick, tx);

rx_instance: uart_rx port map (clk, reset, rx, baud_tick, rx_done_tick, rx_data);

clk_process :process
begin
    clk <= '0';
    wait for 1 ns;  --for 0.5 ns signal is '0'.
    clk <= '1';
    wait for 1 ns;  --for next 0.5 ns signal is '1'.
end process;

baud_tick_process :process
begin
    baud_tick <= '0';
    wait for 1 ns;  --for 0.5 ns signal is '0'.
    baud_tick <= '1';
    wait for 1 ns;  --for next 0.5 ns signal is '1'.
end process;


reset_ctrl: process (clk, reset) is
begin
	if reset = '1' then
		tx_data <= "00000000";
	elsif (clk'EVENT and (clk = '1')) then
		tx_data <= tx_data_next;
	end if;
end process;
test: process (state, rx_done_tick, tx_done_tick) is
begin
	state_next <= state;
	case(state) is
	when idle =>
		if(rx_done_tick = '1') then
			tx_data_next <= rx_data;
			tx_start <= '0';
			state_next <= received;
		end if;
	when received => 
		tx_start <= '1';
		state_next <= transmit;
	when transmit => 
		if(tx_done_tick = '1') then
			tx_start <= '0';
			state_next <= idle;
		end if;
	end case;
end process;
end behav;


