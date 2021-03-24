use strict;
use warnings;
use FindBin qw($RealBin);
use Test::More;
use FASTX::Reader;
my $file1    = "$RealBin/../data/comments.fastq"; #SEQ
my $file2    = "$RealBin/../data/../data/illumina_nocomm.fq"; #A00709
# TEST: Retrieves sequence COMMENTS from a FASTA file

# Check required input file
if (! -e $file1) {
  print STDERR "ERROR TESTING: $file1 not found\n";
  exit 0;
}
if (! -e $file2) {
  print STDERR "ERROR TESTING: $file2 not found\n";
  exit 0;
}


my $f1 = FASTX::Reader->new({ filename => "$file1" });
my $f2 = FASTX::Reader->new({ filename => "$file2" });

while (my $seq1 = $f1->getRead() ) {
	my $seq2 = $f2->getRead();


	ok( $seq1->{name} =~/SEQ/, "[FILE1] name has SEQ: $seq1->{name}");
	ok( $seq2->{name} =~/A00709/, "[FILE2] name has A00709: $seq2->{name}");
}

done_testing();
