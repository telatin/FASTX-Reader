package FASTQ::Reader;
use 5.014;
use Term::ANSIColor qw(:constants);
use warnings;

use Moose;
use Data::Dumper;
use Path::Class;
use Carp qw(confess);

has debug        => (
    is => 'rw',
    isa => 'Bool'
);

has verbose      => (
    is => 'rw',
    isa => 'Bool'
);


has filename => (is => 'ro', isa => 'Str', required => 1);
    has fh => (is => 'rw', isa => 'FileHandle', lazy => 1, builder => '_build_fh');
    #                                           ~~~~~~~~~

    sub _build_fh {
        my ($self) = @_;
        open my $fh, '<', $self->filename or die $!;
        return $fh
    }


sub get_something {
    my $this = shift;
    my $line = '<undef>';

    if (defined $this->fh) {
      $line = readline($this->fh());
    }
    return $line;

}
 

1;
