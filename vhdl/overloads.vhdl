library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package overloads is
    function "+" (a : std_logic_vector; b : integer ) return std_logic_vector;
    function "+" (a : std_logic_vector; b : std_logic_vector) return std_logic_vector;
    function "-" (a : std_logic_vector; b : integer ) return std_logic_vector;
    function "-" (a : std_logic_vector; b : std_logic_vector) return std_logic_vector;

    function "sll" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR;
    function "sll" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR;

    function "srl" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR;
    function "srl" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR;

    function "sra" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR;
    function "sra" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR;

    function "rol" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR;
    function "rol" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR;

    function "ror" (l  : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR;
    function "ror" (l  : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR;
end overloads;

package body overloads is

    function "+" (a : std_logic_vector; b : integer) return std_logic_vector is
        variable result : unsigned(a'range);
    begin
        result := unsigned(a) + b;
        return std_logic_vector(result);
    end function;

    function "+" (a : std_logic_vector; b : std_logic_vector) return std_logic_vector is
        variable result : unsigned(a'range);
    begin
        result := unsigned(a) + unsigned(b);
        return std_logic_vector(result);
    end function;

    function "-" (a : std_logic_vector; b : integer) return std_logic_vector is
        variable result : unsigned(a'range);
    begin
        result := unsigned(a) - b;
        return std_logic_vector(result);
    end function;

    function "-" (a : std_logic_vector; b : std_logic_vector) return std_logic_vector is
        variable result : unsigned(a'range);
    begin
        result := unsigned(a) - unsigned(b);
        return std_logic_vector(result);
    end function;

  -------------------------------------------------------------------
  -- overloaded shift operators
  -------------------------------------------------------------------

  -------------------------------------------------------------------
  -- sll
  -------------------------------------------------------------------
  function "sll" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR is
    alias lv        : STD_LOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_LOGIC_VECTOR (1 to l'length) := (others => '0');
  begin
    if r >= 0 then
      result(1 to l'length - r) := lv(r + 1 to l'length);
    else
      result := l srl -r;
    end if;
    return result;
  end function "sll";
  -------------------------------------------------------------------
  function "sll" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR is
    alias lv        : STD_ULOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_ULOGIC_VECTOR (1 to l'length) := (others => '0');
  begin
    if r >= 0 then
      result(1 to l'length - r) := lv(r + 1 to l'length);
    else
      result := l srl -r;
    end if;
    return result;
  end function "sll";

  -------------------------------------------------------------------
  -- srl
  -------------------------------------------------------------------
  function "srl" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR is
    alias lv        : STD_LOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_LOGIC_VECTOR (1 to l'length) := (others => '0');
  begin
    if r >= 0 then
      result(r + 1 to l'length) := lv(1 to l'length - r);
    else
      result := l sll -r;
    end if;
    return result;
  end function "srl";
  -------------------------------------------------------------------
  function "srl" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR is
    alias lv        : STD_ULOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_ULOGIC_VECTOR (1 to l'length) := (others => '0');
  begin
    if r >= 0 then
      result(r + 1 to l'length) := lv(1 to l'length - r);
    else
      result := l sll -r;
    end if;
    return result;
  end function "srl";

  -------------------------------------------------------------------
  -- sra
  -------------------------------------------------------------------
  function "sra" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR is
    alias lv        : STD_LOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_LOGIC_VECTOR (1 to l'length) := (others => l(l'high));
  begin
    if r >= 0 then
      result(r + 1 to l'length) := lv(1 to l'length - r);
    else
      result := l sll -r;
    end if;
    return result;
  end function "sra";
  -------------------------------------------------------------------
  function "sra" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR is
    alias lv        : STD_ULOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_ULOGIC_VECTOR (1 to l'length) := (others => l(l'high));
  begin
    if r >= 0 then
      result(r + 1 to l'length) := lv(1 to l'length - r);
    else
      result := l sll -r;
    end if;
    return result;
  end function "sra";


  -------------------------------------------------------------------
  -- rol
  -------------------------------------------------------------------
  function "rol" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR is
    alias lv        : STD_LOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_LOGIC_VECTOR (1 to l'length);
    constant rm     : INTEGER := r mod l'length;
  begin
    if r >= 0 then
      result(1 to l'length - rm)            := lv(rm + 1 to l'length);
      result(l'length - rm + 1 to l'length) := lv(1 to rm);
    else
      result := l ror -r;
    end if;
    return result;
  end function "rol";
  -------------------------------------------------------------------
  function "rol" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR is
    alias lv        : STD_ULOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_ULOGIC_VECTOR (1 to l'length);
    constant rm     : INTEGER := r mod l'length;
  begin
    if r >= 0 then
      result(1 to l'length - rm)            := lv(rm + 1 to l'length);
      result(l'length - rm + 1 to l'length) := lv(1 to rm);
    else
      result := l ror -r;
    end if;
    return result;
  end function "rol";

  -------------------------------------------------------------------
  -- ror
  -------------------------------------------------------------------
  function "ror" (l : STD_LOGIC_VECTOR; r : INTEGER) return STD_LOGIC_VECTOR is
    alias lv        : STD_LOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_LOGIC_VECTOR (1 to l'length) := (others => '0');
    constant rm     : INTEGER := r mod l'length;
  begin
    if r >= 0 then
      result(rm + 1 to l'length) := lv(1 to l'length - rm);
      result(1 to rm)            := lv(l'length - rm + 1 to l'length);
    else
      result := l rol -r;
    end if;
    return result;
  end function "ror";
  -------------------------------------------------------------------
  function "ror" (l : STD_ULOGIC_VECTOR; r : INTEGER) return STD_ULOGIC_VECTOR is
    alias lv        : STD_ULOGIC_VECTOR (1 to l'length) is l;
    variable result : STD_ULOGIC_VECTOR (1 to l'length) := (others => '0');
    constant rm     : INTEGER := r mod l'length;
  begin
    if r >= 0 then
      result(rm + 1 to l'length) := lv(1 to l'length - rm);
      result(1 to rm)            := lv(l'length - rm + 1 to l'length);
    else
      result := l rol -r;
    end if;
    return result;
  end function "ror";


end overloads;
