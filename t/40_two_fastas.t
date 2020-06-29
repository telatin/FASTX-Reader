use strict;
use warnings;
use FindBin qw($RealBin);
use Test::More;
use FASTX::Reader;
my $file1    = "$RealBin/../data/more_comments.fa"; #S000
my $file2    = "$RealBin/../data/../data/comments.fasta"; #
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


	ok( $seq1->{name} =~/S000/, "[~S00] name is: $seq1->{name}");
	ok( $seq2->{name} =~/seq/i, "[~Seq] name is: $seq2->{name}");
}

done_testing();
