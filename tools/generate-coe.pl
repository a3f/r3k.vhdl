#!/usr/bin/perl -0777

# https://www.xilinx.com/support/documentation/sw_manuals/xilinx11/cgn_r_coe_file_syntax.htm

use open IN => ':raw';
%escape_of = ("\n"=>'\n', "\r"=>'\r', "\t"=>'\t', "\e"=>'\e');
%format_of = (2 => '%08b', 8 => '%03o', 10 => '%d', 16 =>'%02x');

use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION = 1;
getopts 'r:';

$radix = $opt_r // 16;
die "Radix must be either 2, 8, 10 or 16\n" unless grep /^$radix$/, (2,8,10,16);
print "memory_initialization_radix=$radix;\n"
    . "memory_initialization_vector=\n";

# This a bit of a roundabout way to do it, but it looks funny
$addr = -1;
print "; FUN FACT: This Perl's MAX_INT is  ";
while (<>) {
    for (split //) {
        print ', '; annotate($addr, $c);
        printf $format_of{$radix}, ord;
        $c = $_;
        $addr++;
    }
}
print '; ';
annotate($addr, $c);

sub annotate {
    my ($addr, $c) = @_;
    printf "; @%04x_%04x", $addr >> 16, $addr & 0xFFFF;
    print $escape_of{$c}     ? " '$escape_of{$c}'\n"
        : $c=~/[[:print:]]/  ? " '$c'\n"
        :                      "\n";
}
