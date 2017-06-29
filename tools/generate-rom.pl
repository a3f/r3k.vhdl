#!/usr/bin/perl -0777

use open IN => ':raw';
%escape_of = ("\n"=>'\n', "\r"=>'\r', "\t"=>'\t', "\e"=>'\e');

use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION = 1;
getopts 'b:';
$addr = hex($opt_b);

while (<>) {
    for (split //) {
        $whens .= ' ' x 8;
        $whens .= sprintf 'when X"%04x_%04x" => z <= X"%02x";',
                            $addr >> 16, $addr & 0xFFFF, ord;
        $whens .= $escape_of{$_} ? " -- $escape_of{$_}\n"
                : /[[:print:]]/  ? " -- $_\n"
                :                  "\n";

        $addr++;
    }
}

print <DATA> =~ s/\$whens/$whens/re;

__DATA__
-- Generated by tools/generate-rom.pl
-- Template: https://www.xilinx.com/support/answers/8183.html

library ieee;
use ieee.std_logic_1164.all;
entity rom is
    port ( a: in std_logic_vector(31 downto 0);
           z: out std_logic_vector(7 downto 0)
         );
    attribute syn_romstyle : string;
    attribute syn_romstyle of z : signal is "select_rom";
end rom;

architecture rtl of rom is
    begin
    process(a)
        begin
        case a is

$whens
        when others => z <= X"ff";
        end case;
    end process;
end rtl;