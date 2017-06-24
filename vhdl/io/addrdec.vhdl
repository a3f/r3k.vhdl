library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;
 
entity decoder is
   port(A  : in  addr_t;
        cs : out std_logic_vector(7 downto 0));
end decoder;
 
architecture behav of decoder is
    constant B : natural := 1;
    constant K : natural := 1024*B;
    constant M : natural := K*K;
    function inside(addr_vec, base_vec: addr_t; len : natural) return boolean is
        variable addr: unsigned(31 downto 0) := unsigned(addr_vec);
        variable base: unsigned(31 downto 0) := unsigned(base_vec);
    begin
        return base <= addr and addr <= base + len;
    end inside;
begin
   cs <= "00000001" when inside(A, X"a0000000", 128*M) else -- RAM
         "00000010" when inside(A, X"bfc00000", 128*K) else -- ROM
         "00000100" when inside(A, X"14000000", 1*B)   else -- LEDs
         "00001000" when inside(A, X"14000001", 1*B)   else -- DIP-Switch
         "00010000" when inside(A, X"14000002", 1*B)   else -- Pushbuttons
         "00100000" when inside(A, X"140003f8", 7*B)   else -- UART
         "00000000";
end behav;
