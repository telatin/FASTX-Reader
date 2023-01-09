use 5.012;
use warnings;
use FindBin qw($RealBin);
use Test::More;
use FASTX::Reader;
use FASTX::ReaderPaired;
use FASTX::Seq;
use Data::Dumper;
# TEST: Parse a regular file as interleaved (error)

my $seq_file = "$RealBin/../data/illumina_1.fq.gz";

# Check required input file
if (! -e $seq_file) {
  print STDERR "Skip test: $seq_file not found\n";
  exit 0;
}

my $data1 = FASTX::Reader->new({
    filename => "$seq_file"
});


my $data2 = FASTX::Reader->new({
    filename => "$seq_file"
});

my $count1 = 0;
my $len1 = 0;
my $count2 = 0;
my $len2 = 0;

while (my $seq1 = $data1->getRead()) {
  $count1 += 1;
  $len1 += length($seq1->{seq});
}


while (my $seq2 = $data2->next()) {
  $count2 += 1;
  $len2 += length($seq2->seq);

}

ok($count1 > 0, "File read with getRead() has > 0 reads ($count1)");
ok($count1 == $count2, "Same number of reads from getReads() and next() [$count1==$count2]");
ok($len1 == $len2, "Same total length ($len1==$len2) from getReads() and next()");
done_testing();
