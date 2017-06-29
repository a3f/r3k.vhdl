library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utils is
    function vec_increment(vec: std_logic_vector) return std_logic_vector;
end utils;

package body utils is
    function vec_increment(vec: std_logic_vector) return std_logic_vector is
    begin
        return std_logic_vector(unsigned(vec) + 1);
    end vec_increment;
end utils;

