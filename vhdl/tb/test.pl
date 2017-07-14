#!/usr/bin/env perl

use strict;
no strict 'vars';
use warnings;

@only = split ' ', $ENV{TEST} if defined $ENV{TEST};
@skip = split ' ', $ENV{SKIP} if defined $ENV{SKIP};

for (@ARGV) {
    /^-/ and push @opts, $_ or push @tests, $_
}

for (@tests) {
    open $file, '<', "$_.vhdl"; $line = <$file>; close $file;
    push @skip, $_ if $line =~ /^\s*--\s*SKIP/i;
}

@tests = @only if @only;
$total = @tests;

%disabled = map {($_, 1)} @skip;
@tests = grep {!$disabled{$_}} @tests;

@aopts = @eopts = @ropts = @opts;
# push @ropts, '--assert-level=note' if $ENV{FATAL};

sub run { print "@_ \n"; 0 == system @_ }

for (@tests) {
    $errors++; # Pessimistic by default
    run 'ghdl', '-a', @aopts, "$_.vhdl" or next;
    run 'ghdl', '-e', '-g', @eopts, $_, or next;
    run 'ghdl', '-r', @ropts, $_, "--vcd=$_.vcd" or next;
    $errors--;
    # GHDL doesn't fail on testbench error!
}

if ($errors) {
    print "\n \33[31m=> $errors/${\scalar @tests} test(s) failed.\33[m";
} else {
    print "\n \33[32m=> All ${\scalar @tests} tests were successful\33[m";
}
print " => ". ($total - @tests) . " skipped.\n";
exit $errors;

