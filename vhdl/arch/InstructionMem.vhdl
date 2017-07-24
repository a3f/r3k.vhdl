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
        -- start:
        --B"001101" &R1&R1& X"f000", -- ori r1, r1, 0xf000
        --B"001101" &R1&R2& X"0bad", -- ori r1, r2, 0x0bad
        --X"08_000000"  -- j start
        X"3421_f000",     -- ori     at,at,0xf000
        --X"3c02_1337",     -- lui     v0,0x1337
        X"3422_0bad",     -- ori     at,v0,0xbad
        X"3c03_7000",     -- lui     v1,0x7000
        X"a062_0000",     -- sb      v0,0(v1)
        X"8064_0000",     -- lb      a0,0(v1)
        X"0800_0000"      -- j       0 <_start>
    );

begin
    use_bus_rom: if SINGLE_ADDRESS_SPACE generate
                    instr <= (others => 'Z');
        process(read_addr, top_dout, clk)
            variable clks : natural := 0;
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
