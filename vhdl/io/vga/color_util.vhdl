library ieee;
use ieee.std_logic_1164.all;

package color_util is
    type rgb_t is record r, g, b : std_logic_vector(3 downto 0); end record;
    function rgb (color: std_logic_vector(11 downto 0)) return rgb_t;
    function rgb_negate(color : rgb_t) return rgb_t;

    procedure nibbles_from_rgb(signal r,g,b : out std_logic_vector (3 downto 0); rgb : in rgb_t);

    -- Raylib's color palette
    constant BEIGE     : rgb_t := ( "1101", "1011", "1000" );
    constant BLACK     : rgb_t := ( "0000", "0000", "0000" );
    constant BLANK     : rgb_t := ( "0000", "0000", "0000" );
    constant BLUE      : rgb_t := ( "0000", "1111", "1111" );
    constant BROWN     : rgb_t := ( "1111", "1101", "1001" );
    constant DARKBLUE  : rgb_t := ( "0000", "1010", "1010" );
    constant DARKBROWN : rgb_t := ( "1001", "1111", "1011" );
    constant DARKGRAY  : rgb_t := ( "1010", "1010", "1010" );
    constant DARKGREEN : rgb_t := ( "0000", "1110", "1011" );
    constant DARKGREY  : rgb_t := ( "1010", "1010", "1010" );
    constant DARKPURPL : rgb_t := ( "1110", "1111", "1111" );
    constant GOLD      : rgb_t := ( "1111", "1100", "0000" );
    constant GRAY      : rgb_t := ( "1000", "1000", "1000" );
    constant GREEN     : rgb_t := ( "0000", "1110", "1100" );
    constant GREY      : rgb_t := ( "1000", "1000", "1000" );
    constant LIGHTGRAY : rgb_t := ( "1100", "1100", "1100" );
    constant LIGHTGREY : rgb_t := ( "1100", "1100", "1100" );
    constant LIME      : rgb_t := ( "0000", "1001", "1011" );
    constant MAGENTA   : rgb_t := ( "1111", "0000", "1111" );
    constant MAROON    : rgb_t := ( "1011", "1000", "1101" );
    constant ORANGE    : rgb_t := ( "1111", "1010", "0000" );
    constant PINK      : rgb_t := ( "1111", "1101", "1100" );
    constant PURPLE    : rgb_t := ( "1100", "1111", "1111" );
    constant RED       : rgb_t := ( "1110", "1010", "1101" );
    constant SKYBLUE   : rgb_t := ( "1100", "1011", "1111" );
    constant VIOLET    : rgb_t := ( "1000", "1111", "1011" );
    constant WHITE     : rgb_t := ( "1111", "1111", "1111" );
    constant YELLOW    : rgb_t := ( "1111", "1111", "0000" );
end color_util;

package body color_util is

    function rgb (color: std_logic_vector(11 downto 0)) return rgb_t is
        subtype r is std_logic_vector (11 downto 8);
        subtype g is std_logic_vector ( 7 downto 4);
        subtype b is std_logic_vector ( 3 downto 0);
    begin
        return rgb_t'(color(r'range), color(g'range), color(b'range));
    end function;

    function rgb_negate(color : rgb_t) return rgb_t is
    begin
        return rgb_t'(not color.r, not color.g, not color.b);
    end function;

    procedure nibbles_from_rgb(signal r,g,b : out std_logic_vector (3 downto 0); rgb : in rgb_t) is
    begin
        r <= rgb.r;
        g <= rgb.g;
        b <= rgb.b;
    end;

end color_util;
