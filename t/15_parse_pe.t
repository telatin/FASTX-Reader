use strict;
use warnings;
use FindBin qw($RealBin);
use Test::More;
use FASTX::Reader;
use FASTX::PE;

# TEST: Retrieves sequences from a test FASTA file

my $seq = "$RealBin/../data/illumina_1.fq.gz";

# Check required input file
if (! -e $seq) {
  print STDERR "Skip test: $seq not found\n";
  exit 0;
}

my $data = FASTX::PE->new({ filename => "$seq" });
my $pe = $data->getReads();
 
ok(defined $pe->{seq1},  "[PE] sequence1 is defined");
ok(defined $pe->{seq2},  "[PE] sequence2 is defined");
ok(defined $pe->{qual1}, "[PE] quality1 is defined");
ok(defined $pe->{qual2}, "[PE] quality2 is defined");

done_testing();
