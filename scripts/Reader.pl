use 5.012;
use autodie;
use Term::ANSIColor;
use Data::Dumper;

use FindBin qw($Bin);
use lib "$Bin/../lib/";
use FASTQ::Reader;
use Path::Class;

my $file = FASTQ::Reader->new(
	filename => "$Bin/test.fastq",
);
my $line = $file->get_something();
	say "<<$line>>";

# Test general settings for the module
#my $file = FASTQ::Reader->new(
#	filepath => $input,
#);
#my $input = file("$Bin/test.fastq");

#while (my $line = $file->process_file) {
#	say $line;
#}
