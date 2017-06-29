#!/usr/bin/env perl

use strict;
use warnings;

my (@opts, @tests);

for (@ARGV) {
    /^-/ and push @opts, $_ or push @tests, $_
}

sub run { print "@_ \n"; 0 == system @_ }

my $errors = 0;
for (@tests) {
    $errors++; # Pessimistic by default
    run 'ghdl', '-a', @opts, "$_.vhdl" or next;
    run 'ghdl', '-e', @opts, $_, or next;
    run 'ghdl', '-r', @opts, $_, "--vcd=$_.vcd" or next;
    $errors--;
}

if ($errors) {
    print "\n \33[31m=> $errors/${\scalar @tests} test(s) failed.\33[m\n";
} else {
    print "\n \33[32m=> All ${\scalar @tests} tests were successful\33[m\n";
}

