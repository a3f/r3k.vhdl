library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync is
    port (
         clk : in std_logic;
         hsync : out std_logic := '1';
         vsync : out std_logic := '1';
         retracing : out std_logic := '1'; -- maybe we don't need this?
-- Dunno why, but if I zero-initialize these, the very first pixel is black in the bitmap_tb
         col : out std_logic_vector (9 downto 0) := (others => '1'); -- 640 = 10_1000_0000b
         row : out std_logic_vector (8 downto 0) := (others => '1') -- 480 = 1_1110_0000b
    );
end entity sync;


architecture behavioral of sync is
    constant h_display  : natural := 640;
    constant h_front    : natural := 20;
    constant h_sync     : natural := 96;
    constant h_back     : natural := 44;
    constant h_retrace  : natural := h_front + h_sync + h_back;
    constant h_max      : natural := h_retrace + h_display - 1;

    constant v_display  : natural := 480;
    constant v_front    : natural := 14;
    constant v_sync     : natural := 1;
    constant v_back     : natural := 30;
    constant v_retrace  : natural := v_front + v_sync + v_back;
    constant v_max      : natural := v_retrace + v_display - 1;

    function high_if(cond : boolean) return std_logic is
    begin
        if cond then return '1'; else return '0'; end if;
    end function;

    function low_if(cond : boolean) return std_logic is
    begin
        if cond then return '0'; else return '1'; end if;
    end function;

begin
    process(clk)
        variable h_idx: integer range 0 to h_max := 0;
        variable v_idx: integer range 0 to v_max := 0;
        variable in_retrace : boolean := true;
    begin
        if rising_edge(clk) then
            if h_idx >= h_max - h_sync then hsync <= '0'; end if;
            if v_idx >= v_max - v_sync then vsync <= '0'; end if;

            in_retrace := h_idx < h_back - 1 or h_idx > h_display + h_back - 2
            or v_idx < v_back or v_idx > v_display + v_back - 1;

            retracing <= high_if (in_retrace);

            if not in_retrace then
                row <= std_logic_vector(to_unsigned(v_idx - v_back,     row'length));
                col <= std_logic_vector(to_unsigned(h_idx - h_back + 1, col'length));
            end if;

            if h_idx = h_max then
                h_idx := 0;
                hsync <= '1';
                if v_idx = v_max then
                    v_idx := 0;
                    vsync <= '1';
                else
                    v_idx := v_idx + 1;
                end if;
            else
                h_idx := h_idx + 1;
            end if;



        end if;
    end process;
end architecture;

