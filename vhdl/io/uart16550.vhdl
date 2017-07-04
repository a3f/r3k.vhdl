-- Memory mapped 16550 UART
-- Acutally, it's won't even be a proper 8250, it should at least support
-- 9600 baud 8N1 with Tx, Rx, data_available, tx_ready memory-mapped

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity uart16550 is
		port (
		-- static
		addr : in addr_t;
		din: in word_t;
		dout: out word_t;
		size : in std_logic_vector(1 downto 0); -- is also enable when = "00"
		wr : in std_logic;
		clk : in std_logic;
        trap : out traps_t := TRAP_NONE;
		-- pins
		tx : out std_logic;
		rx : in std_logic
		);
end uart16550;
		
architecture behav of uart16550 is
	constant reading : std_logic := '0';
	constant writing : std_logic := '1';

begin
    dout <= HI_Z;
process(clk)
begin
		if rising_edge(clk) and size /= "00" then
            -- A 16550 UART spans 7 registers
            dout <= NEG_ONE;
            case addr(2 downto 0) is
                when "000" => -- union { Tx, Rx, baud_lo }
                    null;
                when "001" => -- union { baud_hi, int_enable }
                    null;
                when "010" => -- union { int_status, fifo_ctrl }
                    null;
                when "011" => -- struct LINE_CTRL { set baud, config }
                    null;
                when "100" => -- struct MODEM_CTRL
                    null;
                when "101" => -- struct LINE_STATUS { tx_empty, data_available }
                    null;
                when "110" => -- struct MODEM_STATUS
                    null;
				when others => trap <= TRAP_SEGFAULT;
			end case;
		end if;
	end process;
end;

--
--struct uart16550 {
--    union {
--        writeonly uint8_t tx;
--        readonly  uint8_t rx;
--                  uint8_t baud_div_lo;
--                  UART_PAD
--    };
--    union {
--            uint8_t int_enable;
--            uint8_t  baud_div_hi;
--            UART_PAD
--    };
--
--    union {
--        uint8_t int_status; 
--        uint8_t fifo_ctrl;
--        UART_PAD
--    };
--
--    writeonly struct {
--        union {
--        uint8_t set_baud : 1;
--        uint8_t          : 2;
--        uint8_t config   : 5;
--        UART_PAD
--        };
--    } line_ctrl;
--
--    writeonly union {uint8_t modem_ctrl; UART_PAD};
--
--    readonly union {struct {
--        uint8_t                : 2;
--        uint8_t tx_empty       : 1;
--        uint8_t                : 4;
--        uint8_t data_available : 1;
--    }; UART_PAD } line_status;
--
--    readonly union{uint8_t modem_status; UART_PAD};
--};
