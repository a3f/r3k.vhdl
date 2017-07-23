# don't execute me directly
use FindBin '$Bin';
use Data::Dumper;
open my $mips_mk, '<', "$Bin/../toolchain/mips.mk" or return;
my $toolchain = do { local $/; <$mips_mk> };
$toolchain =~ s/^(\w+)\s*=\s*([^#\n]+)\n/$mips{$1} = $2/egm;
%mips;
