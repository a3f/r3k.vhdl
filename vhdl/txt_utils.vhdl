library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all; --defines line, output

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

  -- File: debugio_h.vhd
-- Version: 3.0	 (June 6, 2004)
-- Source: http://bear.ces.cwru.edu/vhdl
-- Date:   June 6, 2004 (Copyright)
-- Author: Francis G. Wolff   Email: fxw12@po.cwru.edu
-- Author: Michael J. Knieser Email: mjknieser@knieser.com
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 1, or (at your option)
-- any later version: http://www.gnu.org/licenses/gpl.html
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--


  function sprintf(fmt: string; s0, s1, s2, s3: string; i0: integer) return string;
  procedure printf(fmt: string; s0, s1, s2, s3: string; i0: integer);
  procedure printf(fmt: string);
  procedure printf(fmt: string; s1: string);
  procedure printf(fmt: string; s1, s2: string);
  procedure printf(fmt: string; i1: integer);
  procedure printf(fmt: string; i1: integer; s2: string);
  procedure printf(fmt: string; i1: integer; s2, s3: string);
  procedure printf(fmt: string; v0: std_logic_vector);
  procedure printf(fmt: string; v0, v1: std_logic_vector);
  procedure printf(fmt: string; v0, v1, v2: std_logic_vector);
  procedure printf(fmt: string; v0, v1, v2, v3: std_logic_vector);
  procedure printf(fmt: string; s0 : string; v0: std_logic_vector);
  procedure printf(fmt: string; v0 : std_logic_vector; s0: string);

  function  pf(arg1: in boolean) return string;

  constant ANSI_NONE  : string := ESC & "[m";
  constant ANSI_RED   : string := ESC & "[31m";
  constant ANSI_GREEN : string := ESC & "[32m";
  constant ANSI_BLUE  : string := ESC & "[34m";

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

    function sprintf(fmt: string; s0, s1, s2, s3: string; i0: integer) return string is
    variable W: line; variable i, fi, di: integer:=0;
  begin loop
      --write(W, string'("n=")); write(W, s0'length);
      --write(W, string'(" L=")); write(W, s0'left);
      --write(W, string'(" R=")); write(W, s0'right);
      --writeline(output, W);

      fi:=fi+1; if fi>fmt'length then exit; end if;
      if fmt(fi)='%' then
        fi:=fi+1; if fi>fmt'length then exit; end if;
        if fmt(fi)='s' then
          case di is
          when 0 => i:=s0'left;
                    while i<=s0'right loop
                      if s0(i)=NUL then exit; end if;
                      write(W, s0(i)); i:=i+1;
                    end loop;
          when 1 => i:=s1'left;
                    while i<=s1'right loop
                      if s1(i)=NUL then exit; end if;
                      write(W, s1(i)); i:=i+1;
                    end loop;
          when 2 => i:=s2'left;
                    while i<=s2'length loop
                      if s2(i)=NUL then exit; end if;
                      write(W, s2(i)); i:=i+1;
                    end loop;
          when 3 => i:=s3'left;
                    while i<=s3'length loop
                      if s3(i)=NUL then exit; end if;
                      write(W, s3(i)); i:=i+1;
                    end loop;
          when others =>
          end case;
          di:=di+1;
        elsif fmt(fi)='d' or fmt(fi)='i' then
	  case di is
          when 0 => write(W, i0); when others => end case;
          di:=di+1;
        end if;
      elsif fmt(fi)='\' then
        fi:=fi+1; if fi>fmt'length then exit; end if;
        case fmt(fi) is
          when 'n'    => write(W, LF);
          when others => write(W, fmt(fi));
        end case;
      else write(W, fmt(fi));
      end if;
  end loop;
  return W.all;
  end sprintf;

  procedure printf(fmt: string; s0, s1, s2, s3: string; i0: integer) is
    variable W: line;
    variable lastch : string(1 to 2) := fmt(fmt'high-1 to fmt'high);
  begin
      Write(W, ANSI_BLUE);
      Write(W, sprintf(fmt(fmt'low to fmt'high-1), s0, s1, s2, s3, i0));
      if not (fmt(fmt'high) = 'n' and fmt(fmt'high -1) = '\') then
        Write(W, fmt(fmt'high-1 to fmt'high-2));
      end if;
      Write(W, ANSI_NONE);
      writeline(output, W);
  end printf;

  procedure printf(fmt: string) is
    begin printf(fmt, "", "", "", "", 0); end printf;
  procedure printf(fmt: string; s1: string) is
    begin printf(fmt, s1, "", "", "", 0); end printf;
  procedure printf(fmt: string; s1, s2: string) is
    begin printf(fmt, s1, s2, "", "", 0); end printf;
  procedure printf(fmt: string; i1: integer) is
    begin printf(fmt, "", "", "", "", i1); end printf; 
  procedure printf(fmt: string; i1: integer; s2: string) is
    begin printf(fmt, "", s2, "", "", i1); end printf; 
  procedure printf(fmt: string; i1: integer; s2, s3: string) is
    begin printf(fmt, "", s2, s3, "", i1); end printf; 
  procedure printf(fmt: string; v0, v1, v2, v3: std_logic_vector) is
    begin printf(fmt, to_hstring(v0), to_hstring(v1), to_hstring(v2), to_hstring(v3), 0); end printf;
  procedure printf(fmt: string; v0, v1, v2: std_logic_vector) is
    begin printf(fmt, v0, v1, v2, ""); end printf;
  procedure printf(fmt: string; v0: std_logic_vector) is
      begin printf(fmt, to_hstring(v0), "", "", "", 0); end printf;
  procedure printf(fmt: string; v0, v1: std_logic_vector) is
      begin printf(fmt, to_hstring(v0), to_hstring(v1), "", "", 0); end printf;
  procedure printf(fmt: string; s0 : string; v0: std_logic_vector) is
      begin printf(fmt, s0, to_hstring(v0), "", "", 0); end printf;
  procedure printf(fmt: string; v0 : std_logic_vector; s0: string) is
      begin printf(fmt, to_hstring(v0), s0, "", "", 0); end printf;

  function pf(arg1: in boolean) return string is
  begin
    if arg1 then return "true"; else return "false"; end if;
  end pf;


end txt_utils;
