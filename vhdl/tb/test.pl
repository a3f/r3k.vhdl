#!/usr/bin/env perl

use strict;
no strict 'vars';
use warnings;
no warnings 'uninitialized';

@only = split ' ', $ENV{TEST} if defined $ENV{TEST};
@skip = split ' ', $ENV{SKIP} if defined $ENV{SKIP};

for (@ARGV) {
    /^-/ and push @opts, $_ or $tests{$_} = 0;
}

if (@only) {
    undef %tests;
    $tests{$_} = 0 for @only; # hash slice?
} else {
    for (keys %tests) {
        open $file, '<', "$_.vhdl"; $line = <$file>; close $file;
        undef $tests{$_} if $line =~ /^\s*--\s*SKIP/i;
    }
    undef $tests{$_} for @skip;
}

@aopts = @eopts = @ropts = @opts;
# push @ropts, '--assert-level=note' if $ENV{FATAL};

sub run { print "@_ \n"; 0 == system @_ }

for (keys %tests) {
    do { $skipped++; next } unless defined $tests{$_};
    run 'ghdl', '-a', @aopts, "$_.vhdl" or next;
    run 'ghdl', '-e', '-g', @eopts, $_, or next;
    @out = qx(ghdl -r @ropts $_ --vcd=$_.vcd 3>&1 1>&2 2>&3 3>&-);
    $? == 0 or next;
    for $line (@out) {
        $tests{$_} = -1 if $line =~ /:\(assertion error\):/;
        print $line if !$ENV{NO_WARN_NUMERIC_STD} || $line !~ /:\(assertion warning\): NUMERIC_STD/ 
    }

    $ok++ if ++$tests{$_};
}

$tests = keys(%tests) - $skipped;
$errors = $tests - $ok;
#print "tests=$tests ok=$ok skipped=$skipped errors=$errors\n";

if ($errors) {
    print "\n \33[31m=> $errors/$tests test(s) failed:\n";
    print "\t$_\n" for grep { defined $tests{$_} && $tests{$_} == 0 } keys %tests;
    print" \33[m";
} else {
    print "\n \33[32m=> All $tests tests were successful\33[m";
}
print " => $skipped skipped.\n";
exit $errors;

