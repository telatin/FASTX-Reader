use strict;
use warnings;
use FindBin qw($RealBin);
use Test::More;
use FASTX::Reader;
use FASTX::PE;

# TEST: Parse a regular file as interleaved (error)

my $seq_file = "$RealBin/../data/illumina_1.fq.gz";

# Check required input file
if (! -e $seq_file) {
  print STDERR "Skip test: $seq_file not found\n";
  exit 0;
}

my $data = FASTX::PE->new({ 
    filename => "$seq_file", 
    interleaved => 1 });
    

 
eval {
    my $pe = $data->getReads();  
};
ok($@, "[ERR] Bad interleaved file didnt pass check [$@]");
done_testing();
