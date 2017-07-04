library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utils is
    function vec_increment(vec: std_logic_vector) return std_logic_vector;

    function high_if(cond : boolean) return std_logic;
    function low_if(cond : boolean) return std_logic;

    -- procedure signextend(signal data_out: out std_logic_vector; signal data_in : in std_logic_vector);
    procedure zeroextend(signal data_out: out std_logic_vector; signal data_in : in std_logic_vector);

    function isnonzero(vec: std_logic_vector) return boolean;

end utils;

package body utils is
    function vec_increment(vec: std_logic_vector) return std_logic_vector is
    begin
        return std_logic_vector(unsigned(vec) + 1);
    end vec_increment;

    function high_if(cond : boolean) return std_logic is
    begin
        if cond then return '1'; else return '0'; end if;
    end function;

    function low_if(cond : boolean) return std_logic is
    begin
        if cond then return '0'; else return '1'; end if;
    end function;


    procedure zeroextend(signal data_out: out std_logic_vector; signal data_in : in std_logic_vector) is
    begin
		data_out <= std_logic_vector(resize(unsigned(data_in), data_out'length));
    end zeroextend;

    function isnonzero(vec: std_logic_vector) return boolean is
    begin
        return vec = (vec'range => '0');
    end isnonzero;
end utils;


