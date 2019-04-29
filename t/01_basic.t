use strict;
use warnings;

use FASTQ::Parser tests => 2;

use_ok 'Proch::Cmd';

my $data = Proch::Cmd->new();

isa_ok($data, 'FASTQ::Parser');
