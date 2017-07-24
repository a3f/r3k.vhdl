library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
use work.utils.all;
use work.txt_utils.all;

entity InstructionMem is
    generic (SINGLE_ADDRESS_SPACE : boolean := true);
    port (
            read_addr : in addr_t;
            clk : in std_logic;
            instr : out instruction_t;

            -- outbound to top level module
            top_addr : out addr_t;
            top_dout : in word_t;
            top_din : out word_t;
            top_size : out ctrl_memwidth_t;
            top_wr : out ctrl_t
    );
end InstructionMem;

architecture behav of InstructionMem is
    type code_t is array (natural range <>) of instruction_t;
    constant example_code : code_t := (
    -- _start:
        X"3421_f000",     -- ori     $1,$1,0xf000
        X"0000_0000",
        X"0000_0000",
        X"3422_0bad",     -- ori     $1,$2,0xbad
        X"0000_0000",
        X"3c03_A000",     -- lui     $3,0xA000
        X"0000_0000",
        X"a062_0000",     -- sb      $2,0($3)
        X"0000_0000",
        X"0000_0000",
        X"8064_0000",     -- lb      $4,0($3)
        X"0800_0000"    -- j       0 <_start>
    );

begin
    use_bus_rom: if SINGLE_ADDRESS_SPACE generate
        process(read_addr, top_dout, clk)
        begin
            if rising_edge(clk) then
                instr <= top_dout;
                printf("[IMEM] *%s: %s\n", read_addr, top_dout);
                top_addr <= read_addr;
                top_size <= WIDTH_WORD;
                top_wr <= '0';
            end if;
        end process;
    end generate;

    use_hardwired_rom: if not SINGLE_ADDRESS_SPACE generate
        process(read_addr, clk)
            variable instrnum : addr_t;
        begin
            instrnum := "00" & read_addr(31 downto 2);
            if rising_edge(clk) then
                instr <= example_code(vtou(instrnum));
                printf("[IMEM] %s: %s\n", read_addr, example_code(vtou(instrnum)));
                top_wr <= '0';
            end if;
        end process;
    end generate;
end behav;
