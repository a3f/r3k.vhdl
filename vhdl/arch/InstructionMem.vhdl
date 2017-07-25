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
    -- <_start>:
       X"00000000", -- nop
       X"3c1c1000", -- lui     gp,0x1000
       X"2402001f", -- li      v0,31
       X"a3820000", -- sb      v0,0(gp)
       X"24020003", -- li      v0,3
       X"a3820013", -- sb      v0,19(gp)
       X"240200ff", -- li      v0,255
       X"a3820096", -- sb      v0,150(gp)
       X"2402001c", -- li      v0,28
       X"a3820118", -- sb      v0,280(gp)
       X"240200e0", -- li      v0,224
       X"a382012b", -- sb      v0,299(gp)
       X"00000000", -- nop
       X"08000000", -- j       0 <_start>
       X"00000000" -- nop
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
