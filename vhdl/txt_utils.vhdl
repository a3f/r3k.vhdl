library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package txt_utils is
    function to_string (value : STD_ULOGIC) return STRING;
    function to_string (value : STD_ULOGIC_VECTOR) return STRING;
    function to_string (value : STD_LOGIC_VECTOR) return STRING;

    alias TO_BSTRING is TO_STRING [STD_LOGIC_VECTOR return STRING];
    alias TO_BINARY_STRING is TO_STRING [STD_LOGIC_VECTOR return STRING];
    function TO_OSTRING (VALUE : STD_LOGIC_VECTOR) return STRING;
    alias TO_OCTAL_STRING is TO_OSTRING [STD_LOGIC_VECTOR return STRING];
    function TO_HSTRING (VALUE : STD_LOGIC_VECTOR) return STRING;
    alias TO_HEX_STRING is TO_HSTRING [STD_LOGIC_VECTOR return STRING];

    -- can't resolve overload for function call, slice or indexed name, otherwise

    --alias TO_BSTRING is TO_STRING [STD_ULOGIC_VECTOR return STRING];
    --alias TO_BINARY_STRING is TO_STRING [STD_ULOGIC_VECTOR return STRING];
    --function TO_OSTRING (VALUE : STD_ULOGIC_VECTOR) return STRING;
    --alias TO_OCTAL_STRING is TO_OSTRING [STD_ULOGIC_VECTOR return STRING];
    --function TO_HSTRING (VALUE : STD_ULOGIC_VECTOR) return STRING;
    --alias TO_HEX_STRING is TO_HSTRING [STD_ULOGIC_VECTOR return STRING];

    --function TO_HSTRING (VALUE : UNSIGNED) return STRING;
    --alias TO_HEX_STRING is TO_HSTRING [UNSIGNED return STRING];
  

  -----------------------------------------------------------------------------
  -- This section copied from "std_logic_textio"
  -----------------------------------------------------------------------------
  -- Type and constant definitions used to map STD_ULOGIC values
  -- into/from character values.
  type MVL9plus is ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-', error);
  type char_indexed_by_MVL9 is array (STD_ULOGIC) of CHARACTER;
  type MVL9_indexed_by_char is array (CHARACTER) of STD_ULOGIC;
  type MVL9plus_indexed_by_char is array (CHARACTER) of MVL9plus;
  constant MVL9_to_char : char_indexed_by_MVL9 := "UX01ZWLH-";
  constant char_to_MVL9 : MVL9_indexed_by_char :=
    ('U' => 'U', 'X' => 'X', '0' => '0', '1' => '1', 'Z' => 'Z',
     'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-', others => 'U');
  constant char_to_MVL9plus : MVL9plus_indexed_by_char :=
    ('U' => 'U', 'X' => 'X', '0' => '0', '1' => '1', 'Z' => 'Z',
     'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-', others => error);

  constant NBSP : CHARACTER      := CHARACTER'val(160);  -- space character
  constant NUS  : STRING(2 to 1) := (others => ' ');     -- null STRING

  end txt_utils;

package body txt_utils is

  -----------------------------------------------------------------------------
  -- New string functions for vhdl-200x fast track
  -----------------------------------------------------------------------------
    function to_string (value     : STD_ULOGIC) return STRING is
        variable result : STRING (1 to 1);
    begin
        result (1) := MVL9_to_char (value);
        return result;
    end function to_string;
  -------------------------------------------------------------------
  -- TO_STRING (an alias called "to_bstring" is provide)
  -------------------------------------------------------------------
    function to_string (value     : STD_ULOGIC_VECTOR) return STRING is
        alias ivalue    : STD_ULOGIC_VECTOR(1 to value'length) is value;
        variable result : STRING(1 to value'length);
    begin
        if value'length < 1 then
            return NUS;
        else
            for i in ivalue'range loop
                result(i) := MVL9_to_char(iValue(i));
            end loop;
            return result;
        end if;
    end function to_string;

  -------------------------------------------------------------------
  -- TO_HSTRING
  -------------------------------------------------------------------
    function to_hstring (value     : STD_ULOGIC_VECTOR) return STRING is
    constant ne     : INTEGER := (value'length+3)/4;
    variable pad    : STD_ULOGIC_VECTOR(0 to (ne*4 - value'length) - 1);
    variable ivalue : STD_ULOGIC_VECTOR(0 to ne*4 - 1);
    variable result : STRING(1 to ne);
    variable quad   : STD_ULOGIC_VECTOR(0 to 3);
    begin
        if value'length < 1 then
            return NUS;
        else
            if value (value'left) = 'Z' then
                pad := (others => 'Z');
            else
                pad := (others => '0');
            end if;
            ivalue := pad & value;
            for i in 0 to ne-1 loop
                quad := To_X01Z(ivalue(4*i to 4*i+3));
                case quad is
                    when x"0"   => result(i+1) := '0';
                    when x"1"   => result(i+1) := '1';
                    when x"2"   => result(i+1) := '2';
                    when x"3"   => result(i+1) := '3';
                    when x"4"   => result(i+1) := '4';
                    when x"5"   => result(i+1) := '5';
                    when x"6"   => result(i+1) := '6';
                    when x"7"   => result(i+1) := '7';
                    when x"8"   => result(i+1) := '8';
                    when x"9"   => result(i+1) := '9';
                    when x"A"   => result(i+1) := 'A';
                    when x"B"   => result(i+1) := 'B';
                    when x"C"   => result(i+1) := 'C';
                    when x"D"   => result(i+1) := 'D';
                    when x"E"   => result(i+1) := 'E';
                    when x"F"   => result(i+1) := 'F';
                    when "ZZZZ" => result(i+1) := 'Z';
                    when others => result(i+1) := 'X';
                end case;
            end loop;
            return result;
        end if;
    end function to_hstring;

    function to_hstring (VALUE : UNSIGNED) return STRING is
    begin
        return TO_HSTRING(std_logic_vector(VALUE));
    end function to_hstring;

  -------------------------------------------------------------------
  -- TO_OSTRING
  -------------------------------------------------------------------
    function to_ostring (value     : STD_ULOGIC_VECTOR) return STRING is
    constant ne     : INTEGER := (value'length+2)/3;
    variable pad    : STD_ULOGIC_VECTOR(0 to (ne*3 - value'length) - 1);
    variable ivalue : STD_ULOGIC_VECTOR(0 to ne*3 - 1);
    variable result : STRING(1 to ne);
    variable tri    : STD_ULOGIC_VECTOR(0 to 2);
    begin
        if value'length < 1 then
            return NUS;
        else
            if value (value'left) = 'Z' then
                pad := (others => 'Z');
            else
                pad := (others => '0');
            end if;
            ivalue := pad & value;
            for i in 0 to ne-1 loop
                tri := To_X01Z(ivalue(3*i to 3*i+2));
                case tri is
                    when o"0"   => result(i+1) := '0';
                    when o"1"   => result(i+1) := '1';
                    when o"2"   => result(i+1) := '2';
                    when o"3"   => result(i+1) := '3';
                    when o"4"   => result(i+1) := '4';
                    when o"5"   => result(i+1) := '5';
                    when o"6"   => result(i+1) := '6';
                    when o"7"   => result(i+1) := '7';
                    when "ZZZ"  => result(i+1) := 'Z';
                    when others => result(i+1) := 'X';
                end case;
            end loop;
            return result;
        end if;
    end function to_ostring;

    function to_string (value     : STD_LOGIC_VECTOR) return STRING is
    begin
        return to_string (to_stdulogicvector (value));
    end function to_string;

    function to_hstring (value     : STD_LOGIC_VECTOR) return STRING is
    begin
        return to_hstring (to_stdulogicvector (value));
    end function to_hstring;

    function to_ostring (value     : STD_LOGIC_VECTOR) return STRING  is
    begin
        return to_ostring (to_stdulogicvector (value));
    end function to_ostring;

end txt_utils;
