package FASTX::PE;
use 5.014;
use warnings;
use Carp qw(confess cluck);
use Data::Dumper;
use FASTX::Reader;
$FASTX::PE::VERSION = $FASTX::Reader::VERSION;
#ABSTRACT: A Paired-End FASTQ files reader, based on FASTX::Reader.


=head1 SYNOPSIS

  use FASTX::PE;
  my $filepath = '/path/to/assembly_R1.fastq';
  # Will automatically open "assembly_R2.fastq"
  my $fq_reader = FASTX::Reader->new({
    filename => "$filepath",
  });

  while (my $seq = $fasta_reader->getRead() ) {
    print $seq->{name}, "\t", $seq->{seq1}, "\t", $seq->{qual1}, "\n";
    print $seq->{name}, "\t", $seq->{seq2}, "\t", $seq->{qual2}, "\n";
  }

=head1 BUILD TEST

=for html <a href="https://travis-ci.org/telatin/FASTQ-Parser"><img src="https://travis-ci.org/telatin/FASTQ-Parser.svg?branch=master"></a>

Each GitHub release of the module is tested by L<Travis-CI|https://travis-ci.org/telatin/FASTQ-Parser/builds> using multiple Perl versions (5.14 to 5.28).

In addition to this, every CPAN release is tested by the L<CPAN testers grid|http://matrix.cpantesters.org/?dist=FASTX-Reader>.

=head1 METHODS


=head2 new()

Initialize a new FASTX::Reader object passing 'filename' argument. Will open a filehandle
stored as $object->{fh}.

  my $seq_from_file = FASTX::Reader->({ filename => "$file" });

To read from STDIN either pass C<{{STDIN}}> as filename, or don't pass a filename at all:

  my $seq_from_stdin = FASTX::Reader->();

The parameter C<loadseqs> will preload all sequences in a hash having the sequence
name as key and its sequence as value.

  my $seq_from_file = FASTX::Reader->({
    filename => "$file",
    loadseqs => 1,
  });

=cut

sub new {

    # Instantiate object
    my ($class, $args) = @_;

    my %accepted_parameters = (
      'filename' => 1,
      'tag1' => 1,
      'tag2' => 1,
      'reverse' => 1,
      'interleaved' => 1,
      'nocheck' => 1,
    );
    my $valid_attributes = join(', ', keys %accepted_parameters);

    if ($args) {
      for my $parameter (keys %{ $args} ) {
        confess("Attribute <$parameter> is not expected. Valid attributes are: $valid_attributes\n")
          if (! $accepted_parameters{$parameter} );
      }
    } else {
      $args->{filename} = '{{STDIN}}';
    }

    my $self = {
        filename    => $args->{filename},
        reverse     => $args->{reverse},
        interleaved => $args->{interleaved},
        tag1        => $args->{tag1},
        tag2        => $args->{tag2},
        nocheck     => $args->{nocheck},
    };


    my $object = bless $self, $class;

    # Required to read STDIN?
    if ($self->{filename} eq '{{STDIN}}' or not $self->{filename}) {
      $self->{interleaved} = 1;
      $self->{stdin} = 1;
    }

    if ($self->{interleaved}) {
      # Decode interleaved
      if ($self->{stdin}) {
        $self->{R1} = FASTX::Reader->new({ filename => '{{STDIN}}' });
      } else {
        $self->{R1} = FASTX::Reader->new({ filename => "$self->{filename}"});
      }
    } else {
      # Decode PE
      if ( ! defined $self->{reverse} ) {

        # Auto calculate reverse filename
        my $reverse = $self->{filename};
        if (defined $self->{tag1} and defined $self->{tag2}) {
          $reverse =~s/$self->{tag1}/$self->{tag2}/;
        } else {

          $reverse =~s/_R1/_R2/;
          $reverse =~s/_1/_2/ if ($reverse eq $self->{filename});
        }

        if ( ($self->{filename} eq $reverse) or (not -e $reverse) ) {
          confess("ERROR: The reverse file for '$self->{filename}' was not found in '$reverse'\n");
        } else {
          $self->{reverse} = $reverse;
        }
      }

      $self->{R1}  = FASTX::Reader->new({ filename => "$self->{filename}"});
      $self->{R2}  = FASTX::Reader->new({ filename => "$self->{reverse}"});

    }


    return $object;
}

=head2 getRead()

Will return the next sequence in the FASTA / FASTQ file using Heng Li's implementation of the readfq() algorithm.
The returned object has these attributes:

=over 4

=item I<name>

header of the sequence (identifier)

=item I<comment>

any string after the first whitespace in the header

=item I<seq>

actual sequence

=item I<qual>

quality if the file is FASTQ

=back

=cut


sub getReads {
  my $self   = shift;
  #my ($fh, $aux) = @_;
  #@<instrument>:<run number>:<flowcell ID>:<lane>:<tile>:<x-pos>:<y-pos>:<UMI> <read>:<is filtered>:<control number>:<index>
  my $pe;
  my $r1;
  my $r2;

  if ($self->{interleaved}) {
    $r1 = $self->{R1}->getRead();
    $r2 = $self->{R1}->getRead();
  } else {
    $r1 = $self->{R1}->getRead();
    $r2 = $self->{R2}->getRead();
  }

  if (! defined $r1->{name} or !defined $r2->{name}) {
    return undef;
  }

  if (not defined $self->{nocheck}) {
    if ($r1->{name} ne  $r2->{name}) {
      confess("Read name different in PE:\n[$r1->{name}] !=\n[$r2->{name}]\n");
    }
  }

  $pe->{name} = $r1->{name};
  $pe->{qual1} = $r1->{qual};
  $pe->{qual2} = $r2->{qual};
  $pe->{seq1} = $r1->{seq};
  $pe->{seq2} = $r2->{seq};
  $pe->{comment1} = $r1->{comment};
  $pe->{comment2} = $r2->{comment};

  return $pe;

}




=head1 SEE ALSO

=over 4

=item L<FASTX::Reader>

The FASTA/FASTQ parser this module is based on.
=back

=cut
1;
