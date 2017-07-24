library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

package memory_map is
    constant BOOT_ADDR : addr_t := X"0000_0000";

    constant B : natural := 1; constant K : natural := 1024*B; constant M : natural := K*K;
    subtype memchipsel_t is std_logic_vector(7 downto 0);

    type mblock_t is record
        base : addr_t; size : natural; chip_select : memchipsel_t;
    end record;
    type mmap_t is array (natural range <>) of mblock_t;

    constant mmap : mmap_t := (
        (X"A0000000", 128*M, X"01"), -- RAM
        (BOOT_ADDR,   128*K, X"02"), -- ROM
        (X"14000000", 1*B,   X"04"), -- LEDs
        (X"14000001", 1*B,   X"08"), -- DIP-Switch
        (X"14000002", 1*B,   X"10"), -- Pushbuttons
        (X"140003f8", 7*B,   X"20"), -- UART
        (X"10000000", 16*M,  X"40"), -- VRAM
        (X"14000010", 16*B,  X"80")  -- Video configuration
    );

    constant mmap_ram : natural := 0;
    constant mmap_rom : natural := 1;
    constant mmap_led : natural := 2;
    constant mmap_dipswitch : natural := 3;
    constant mmap_push : natural := 4;
    constant mmap_uart : natural := 5;
    constant mmap_vram : natural := 6;
    constant mmap_videocfg : natural := 7;

    function inside(addr_vec, base_vec: addr_t; len : natural) return boolean;

end memory_map;

package body memory_map is
    function inside(addr_vec, base_vec: addr_t; len : natural) return boolean is
        variable addr: unsigned(31 downto 0) := unsigned(addr_vec);
        variable base: unsigned(31 downto 0) := unsigned(base_vec);
    begin
        return base <= addr and addr < base + len;
    end inside;
end memory_map;



