package FASTQ::Reader;
use 5.014;
use warnings;
$FASTQ::Reader::VERSION = 0.01;
# ABSTRACT: Execute shell commands with caching capability to store output of executed programs (useful for multi step pipelines where some steps can take long)

=pod

=encoding UTF-8

=head1 NAME

FASTQ::Reader - File reader OOP

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  use FASTQ::Reader;

=head1 NAME

FASTQ::Reader - a simple library

=head1 VERSION

version 0.01

=head1 METHODS

=head2 new()

The method creates a new shell command object, with the followin properties:

=over 4

=item I<filename> [required]

Filename to read

=back

=head1 AUTHORS

Fabrizio Levorin and Andrea Telatin

=head1 COPYRIGHT AND LICENSE

This software is free software under MIT Licence.

=cut

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


has filename => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has filepath => (
    is => 'ro',
    isa => "Path::Class::File",
    required => 0,
);

has fh => (
  is => 'ro',
  isa => 'FileHandle',
  builder => '_build_file_handler',
  required => 1,
);

sub _build_file_handler {
   my ($self) = @_;
   say "=BUILDER";
   say Dumper $self;
   open(my $fh, "<", $self->filename)
      or die ("ERROR:Can't open file "
         . $self->filename
         . " for writing");
   return $fh;
}


sub get_something {
    my $this = shift;
    say Dumper $this;

    while (my $line = readline($this->fh)) {
      say ".> " , $line;
    }
    say "DONE";
}

sub process_file {
    my $this = shift;
    say Dumper $this;

    if (-e $this->filepath) {
        my $fh = $this->filepath->openr;
        while (my $line = <$fh>)
        {
             # process file, line by line...
	     print ':', $line;
        }
    } else {
	say "<FATAL ERROR> File not found: ", $this->filepath;
        return 0;
    }
}

1;
