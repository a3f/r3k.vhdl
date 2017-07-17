#!/usr/bin/env perl

use strict;
use warnings;

# Shows all MIPS opcodes in an ELF

my %ops;
my ($num_ops, $num_instrs) = (0, 0);

while (defined($_ = <>)) {
    next unless /^[[:xdigit:]]+:\s*[[:xdigit:]]+\s*/;
    s/[[:xdigit:]]+:\s*[[:xdigit:]]+\s*//g;
    next unless /^[a-z]/i;

    my @word = split ' ';

    $ops{$word[0]}++;
    $num_instrs++;
}

my $num = 0;

for (sort keys %ops)
{
    printf "%.10s: %d\n", $_, $ops{$_};
    $num_ops++;
}

printf "Number of Instructions: %04u. Number of Opcodes: %04u\n", $num_instrs, $num_ops;
