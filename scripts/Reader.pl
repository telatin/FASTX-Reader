use 5.012;
use autodie;
use Term::ANSIColor;
use Data::Dumper;

use FindBin qw($Bin);
use lib "$Bin/../lib/";
use FASTQ::Reader;

my $file1 = "$Bin/test.fastq";
my $file2 = "$Bin/test2.fastq";
my $o1 = FASTQ::Reader->new(filename => "$file1");
my $o2 = FASTQ::Reader->new(filename => "$file2");


print "READ FILE 1: $file1\n";
print "READ FILE 2: $file1\n";

my $counter = 0;
while (my $seq = $o1->getRead()) {
  $counter++;
  my $pair = $o2->getRead();
  say color('red'), $counter, color('reset'), "\t",$seq->{name}, ' - ', $pair->{name};
}
# Test general settings for the module
#my $file = FASTQ::Reader->new(
#	filepath => $input,
#);
#my $input = file("$Bin/test.fastq");

#while (my $line = $file->process_file) {
#	say $line;
#}
