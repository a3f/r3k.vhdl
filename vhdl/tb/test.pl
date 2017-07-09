#!/usr/bin/env perl

use strict;
use warnings;

my @only = split ' ', $ENV{TEST} if defined $ENV{TEST};
my @skip = split ' ', $ENV{SKIP} if defined $ENV{SKIP};

my (@opts, @tests);

for (@ARGV) {
    /^-/ and push @opts, $_ or push @tests, $_
}

for (@tests) {
    open my $file, '<', "$_.vhdl"; my $line = <$file>; close $file;
    push @skip, $_ if $line =~ /^\s*--\s*SKIP/i;
}

my $total = @tests;
@tests = @only if @only;

my %disabled = map {($_, 1)} @skip;
@tests = grep {!$disabled{$_}} @tests;


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
    print "\n \33[31m=> $errors/${\scalar @tests} test(s) failed.\33[m";
} else {
    print "\n \33[32m=> All ${\scalar @tests} tests were successful\33[m";
}
print " => ". ($total - @tests) . " skipped.\n";
exit $errors;

