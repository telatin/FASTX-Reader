package FASTX::Reader;
use 5.012;
use warnings;
use Carp qw(confess);
use Data::Dumper;
<<<<<<< HEAD
$Data::Dumper::Sortkeys = 1;
use File::Basename;
=======
>>>>>>> 166d528077938aaaf4ea2e186f5935aa991e8568
$FASTX::Reader::VERSION = '0.94';
require Exporter;
our @ISA = qw(Exporter);
#ABSTRACT: A lightweight module to parse FASTA and FASTQ files, supporting compressed files and paired-ends.

use constant GZIP_SIGNATURE => pack('C3', 0x1f, 0x8b, 0x08);

=head1 SYNOPSIS

  use FASTX::Reader;
  my $filepath = '/path/to/assembly.fastq';
  die "Input file not found: $filepath\n" unless (-e "$filepath");
  my $fasta_reader = FASTX::Reader->new({ filename => "$filepath" });

  while (my $seq = $fasta_reader->getRead() ) {
    f $seq->{name}, "\t", $seq->{seq}, "\t", $seq->{qual}, "\n";
  }

=head1 BUILD TEST

=for html <p><a href="https://travis-ci.org/telatin/FASTQ-Parser"><img src="https://travis-ci.org/telatin/FASTQ-Parser.svg?branch=master"></a></p>

Each GitHub release of the module is tested by L<Travis-CI|https://travis-ci.org/telatin/FASTQ-Parser/builds> using multiple Perl versions (5.14 to 5.28).

In addition to this, every CPAN release is tested by the L<CPAN testers grid|http://matrix.cpantesters.org/?dist=FASTX-Reader>.

=head1 METHODS


=head2 new()

Initialize a new FASTX::Reader object passing 'filename' argument. Will open a filehandle
stored as $object->{fh}.

  my $seq_from_file = FASTX::Reader->new({ filename => "$file" });

To read from STDIN either pass C<{{STDIN}}> as filename, or don't pass a filename at all:

  my $seq_from_stdin = FASTX::Reader->new();

The parameter C<loadseqs> will preload all sequences in a hash having the sequence
name as key and its sequence as value.

  my $seq_from_file = FASTX::Reader->new({
    filename => "$file",
    loadseqs => 1,
  });

=cut

sub new {
    # Instantiate object
    my ($class, $args) = @_;

    if (defined $args->{loadseqs}) {
      if ($args->{loadseqs} eq 'name' or $args->{loadseqs} eq 'names' ) {
        $args->{loadseqs} = 'name';
      } elsif ($args->{loadseqs} eq 'seq' or $args->{loadseqs} eq 'seqs' or $args->{loadseqs} == 1) {
        $args->{loadseqs} = 'seq';
      } else {
        confess("attribute <loadseqs> should be 'name' or 'seq' to specify the key of the hash.");
      }
    }
    my $self = {
        filename  => $args->{filename},
        loadseqs  => $args->{loadseqs},
    };

    $self->{aux} = [undef];


    # Initialize auxiliary array for getRead

    $self->{compressed} = 0;

    # Check if a filename was provided and not {{STDIN}}
    # uncoverable branch false
    my $fh;
    if (defined $self->{filename} and $self->{filename} ne '{{STDIN}}') {
      open my $initial_fh, '<', $self->{filename} or confess "Unable to read file ", $self->{filename}, "\n";
      read( $initial_fh, my $magic_byte, 4 );
      close $initial_fh;

      # See: __BioX::Seq::Stream__ for GZIP (and other) compressed file reader
      if (substr($magic_byte,0,3) eq GZIP_SIGNATURE) {

         $self->{compressed} = 1;
         our $GZIP_BIN = _which('pigz', 'gzip');
         #close $fh;
         if (! defined $GZIP_BIN) {
           require IO::Uncompress::Gunzip;
           $fh = IO::Uncompress::Gunzip->new($self->{filename}, MultiStream => 1);
         } else {
	         open  $fh, '-|', "$GZIP_BIN -dc $self->{filename}" or confess "Error opening gzip file ", $self->{filename}, ": $!\n";
         }
      } elsif (-B $self->{filename}) {

          # BINARY FILE NOT SUPPORTED?
          #close $fh;
          $self->{fh}      = undef;
          $self->{status}  = 1;
          $self->{message} = 'Binary file not supported';
      } else {

	       #close $fh;
      	 open $fh,  '<:encoding(utf8)', $self->{filename} or confess "Unable to read file ", $self->{filename}, ": ", $!, "\n";
      }
      $self->{fh} = $fh;

    } else {
      $self->{fh} = \*STDIN;
      if ($self->{loadseqs}) {
        confess("Load sequences not supported for STDIN");
      }
    }



    my $object = bless $self, $class;
    if ($self->{loadseqs}) {
      _load_seqs($self);
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

sub Flevorin_getRead {
  my $self   = shift;
  my $fh = $self->{fh};

  return undef if (defined $self->{status} and $self->{status} == 0);

  #  my $aux = $self->{aux};
  my $curpos = $self->{curpos};
  my $return;
  my $seq;
  my $dim = -s $fh;

  return if ( $curpos == $dim);

  seek($fh, $curpos, 0);

  # Nome sequenza e commento
  while (<$fh>) {
    chomp;
    if (substr($_, 0, 1) eq '>' || substr($_, 0, 1) eq '@') {
      my ($name, $comm) = /^.(\S+)(?:\s+)(.+)/ ? ($1, $2) : /^.(\S+)/ ? ($1, '') : ('', '');
      $return->{name} = $name;
      $return->{comment} = $comm;
      last;
    }
  }

  # Sequenza
  while (<$fh>) {
  chomp;
  my $c = substr($_, 0, 1);
  if ($c eq '>' || $c eq '@' || $c eq '+') {
  last;
  }
  $self->{curpos} = tell;
  $seq .= $_;
  }
  $return->{seq} = $seq;

  return $return;
}

sub getRead {
  my $self   = shift;
  state $line;

  $self->{counter_fake}++;
  if ($self->{counter_fake} < 4) {
    say Dumper $self;
  }
  #@<instrument>:<run number>:<flowcell ID>:<lane>:<tile>:<x-pos>:<y-pos>:<UMI> <read>:<is filtered>:<control number>:<index>


  return undef if (defined $self->{status} and $self->{status} == 0);

  #my $aux = $self->{aux};
  my $sequence_data;
  @{ $self->{aux} } = [undef, 0] if (!(@{ $self->{aux} }));


  if ($self->{aux}->[1]) {
    $self->{return_0}++;
  }

  if (!defined($self->{aux}->[0])) {
      while ($line = readline($self->{fh})) {

          chomp($line);
          if (substr($line, 0, 1) eq '>' || substr($line, 0, 1) eq '@') {
              $self->{aux}->[0] = $line;
              last;
          }
      }
      if (!defined($self->{aux}->[0])) {
          $self->{aux}->[1] = 1;
          $self->{return_1}++;
          return;
      }
  }


  # Comments can have more spaces:
  return unless defined $line;
  my ($name, $comm) = $line=~/^.(\S+)(?:\s+)(.+)/ ? ($1, $2) :
	                    $line=~/^.(\S+)/ ? ($1, '') : ('?', '');
  my $seq = '';
  my $c;
  $self->{aux}->[0] = undef;
  while ($line = readline($self->{fh})) {
     # PARSE SEQx
      chomp($line);
      $c = substr($line, 0, 1);
      last if ($c eq '>' || $c eq '@' || $c eq '+');
      $seq .= $line;
  }
  $self->{aux}->[0] = $line;
  $self->{aux}->[1] = 1 if (!defined($self->{aux}->[0]));
  $sequence_data->{name} = $name;
  $sequence_data->{comment} = $comm;
  $sequence_data->{seq} = $seq;
  $self->{counter}++;
  # Return FASTA
   if ($c ne '+') {
    $self->{return_fasta1}++;
    return $sequence_data;
  }
  my $qual = '';


  while ($line = readline($self->{fh})) {
      # PARSE QUALITY
      chomp($line);
      $qual .= $line;
      if (length($qual) >= length($seq)) {
          $self->{aux}->[0] = undef;
          $sequence_data->{name} = $name;
          $sequence_data->{seq} = $seq;
          $sequence_data->{comment} = $comm;
          $sequence_data->{qual} = $qual;
          # return FASTQ
          $self->{return_fastq}++;
          return $sequence_data;
      }
  }
  $self->{aux}->[1] = 1;
  $sequence_data->{name}    = $name;
  $sequence_data->{seq}     = $seq;
  $sequence_data->{comment} = $comm;
  $self->{counter}++;
  # return FASTA
  $self->{return_fasta2}++;
  return $sequence_data;

}

=head2 getFastqRead()

If the file is FASTQ, this method returns the same read object as I<getRead()> but with a simpler,
FASTQ-specific, parser.
Attributes of the returned object are I<name>, I<comment>, I<seq>, I<qual> (as for I<getRead()>).
It will alter the C<status> attribute of the reader object if the FASTQ format looks terribly wrong.

  use FASTX::Reader;
  my $filepath = '/path/to/assembly.fastq';
  my $fasta_reader = FASTX::Reader->new({ filename => "$filepath" });

  while (my $seq = $fasta_reader->getFastqRead() ) {
    die "Error parsing $filepath: " . $fasta_reader->{message} if ($fasta_reader->{status} != 1);
    print $seq->{name}, "\t", $seq->{seq}, "\t", $seq->{qual}, "\n";
  }

=cut

sub getFastqRead {
  my $self   = shift;
  my $seq_object = undef;

  return undef if (defined $self->{status} and $self->{status} == 0);

  $self->{status} = 1;
  my $header = readline($self->{fh});
  my $seq    = readline($self->{fh});
  my $check  = readline($self->{fh});
  my $qual   = readline($self->{fh});


  # Check 4 lines were found (FASTQ)

  unless (defined $qual) {
    if (defined $header) {
      $self->{message} = "Unknown format: FASTQ truncated at " . $header . "?";
      $self->{status} = 0;
    }
    return undef;
  }

  # Fast format control: header and separator
  if ( (substr($header, 0, 1) eq '@') and (substr($check, 0, 1) eq '+') ) {
    chomp($header);
    chomp($seq);
    chomp($qual);
    # Also control sequence integrity
    if ($seq=~/^[ACGTNacgtn]+$/ and length($seq) == length($qual) ) {
      my ($name, $comments) = split /\s+/, substr($header, 1);
      $seq_object->{name} = $name;
      $seq_object->{comments} = $comments;
      $seq_object->{seq} = $seq;
      $seq_object->{qual} = $qual;
      $self->{counter}++;

    } else {
      # Return error (corrupted FASTQ)
      $self->{message} = "Unknown format: expecting FASTQ (corrupted?)";
      $self->{status} = 0;

    }
  } else {
    # Return error (not a FASTQ)
    $self->{message} = "Unknown format: expecting FASTQ but @ header not found";

    if (substr($header, 0,1 ) eq '>' ) {
      # HINT: is FASTA?
      $self->{message} .= " (might be FASTA instead)";
    }
    $self->{status} = 0;
  }

  return $seq_object;
}

=head2 getIlluminaRead()

If the file is FASTQ, this method returns the same read object as I<getRead()> but with a simpler parser.
Attributes of the returned object are I<name>, I<comment>, I<seq>, I<qual> (as for I<getRead()>).
In addition to this it will parse the name and comment populating these properties fromt the read name:
C<instrument>, C<run>, C<flowcell>, C<lane>, C<tile>, C<x>, C<y>, C<umi>.

If the comment is also present the following will also populated: C<read> (1 for R1, and 2 for R2),
C<index> (barcode of the current read), C<paired_index> (barcode of the other read)
and C<filtered> (true if the read is to be discarded, false elsewhere).

It will alter the C<status> attribute of the reader object if the FASTQ format looks terribly wrong.

  while (my $seq = $fasta_reader->getIlluminaRead() ) {
    print $seq->{name}, "\t", $seq->{instrument}, ',', $seq->{index1}, "\n";
  }

=cut

sub getIlluminaRead {
  my $self   = shift;
  my $seq_object = undef;

  return undef if (defined $self->{status} and $self->{status} == 0);

  $self->{status} = 1;
  my $header = readline($self->{fh});
  my $seq    = readline($self->{fh});
  my $check  = readline($self->{fh});
  my $qual   = readline($self->{fh});


  # Check 4 lines were found (FASTQ)

  unless (defined $qual) {
    if (defined $header) {
      $self->{message} = "Unknown format: FASTQ truncated at " . $header . "?";
      $self->{status} = 0;
    }
    return undef;
  }

  # Fast format control: header and separator
  if ( (substr($header, 0, 1) eq '@') and (substr($check, 0, 1) eq '+') ) {
    chomp($header);
    chomp($seq);
    chomp($qual);
    # Also control sequence integrity
    if ($seq=~/^[ACGTNacgtn]+$/ and length($seq) == length($qual) ) {
      my ($name, $comments) = split /\s+/, substr($header, 1);
      #@<instrument>:<run number>:<flowcell ID>:<lane>:<tile>:<x-pos>:<y-pos>:<UMI> <read>:<is filtered>:<control number>:<index>
      my ($instrument, $run, $flowcell, $lane, $tile, $x, $y, $umi) = split /:/, $name;
      my ($read, $filtered, $ctrl, $index1, $index2);

      if (not defined $y) {
        $self->{message} = "Unknown format: not Illumina naming: <instrument>:<run number>:<flowcell ID>:<lane>:<tile>:<x-pos>:<y-pos>";
        $self->{status} = 0;
      }

      $seq_object->{name} = $name;
      $seq_object->{comments} = $comments;
      $seq_object->{seq} = $seq;
      $seq_object->{qual} = $qual;

      $seq_object->{instrument} = $instrument;
      $seq_object->{run} = $run;
      $seq_object->{flowcell} = $flowcell;
      $seq_object->{lane} = $lane;
      $seq_object->{tile} = $tile;
      $seq_object->{x} = $x;
      $seq_object->{y} = $y;
      $seq_object->{umi} = $umi;
      $seq_object->{instrument} = $instrument;
      $seq_object->{run} = $run;
      $seq_object->{flowcell} = $flowcell;

      if (defined $comments) {
          ($read, $filtered, $ctrl, $index1, $index2) = split /[:+]/, $comments;
          if ( defined $ctrl ) {
            $seq_object->{read} = $read;
            $filtered eq 'N' ? $seq_object->{filtered} = 0 : $seq_object->{filtered} = 1;
            $seq_object->{control} = $ctrl;
            if ($read eq '1') {
               $seq_object->{index} = $index1;
               $seq_object->{paired_index} =  $index2;
            } else {
              $seq_object->{paired_index} = $index1;
              $seq_object->{index} =  $index2;
            }
          }
      }
      $self->{counter}++;

    } else {
      # Return error (corrupted FASTQ)
      $self->{message} = "Unknown format: expecting FASTQ (corrupted?)";
      $self->{status} = 0;

    }
  } else {
    # Return error (not a FASTQ)
    $self->{message} = "Unknown format: expecting FASTQ but @ header not found";

    if (substr($header, 0,1 ) eq '>' ) {
      # HINT: is FASTA?
      $self->{message} .= " (might be FASTA instead)";
    }
    $self->{status} = 0;
  }

  return $seq_object;
}

=head2 getFileFormat(filename)

This subroutine returns 'fasta', 'fastq' or <undef> for a given filepath (this is not a method of the instantiated object)

=cut
sub getFileFormat {
  my $self   = shift;
  my ($filename) = shift;
  return 0 if (not defined $filename);

  open my $fh, '<', $filename or confess "Unable to read file ", $filename, "\n";
  read( $fh, my $magic_byte, 4 );
  close $fh;

  if (substr($magic_byte,0,3) eq GZIP_SIGNATURE) {

    if (! defined $self->{GZIP_BIN}) {
      require IO::Uncompress::Gunzip;
      $fh = IO::Uncompress::Gunzip->new($filename, MultiStream => 1);
    } else {
	    open  $fh, '-|', "$self->{GZIP_BIN} -dc $filename" or confess "Error opening gzip file ", $filename, ": $!\n";
    }
  } else {
    open  $fh, '<:encoding(utf8)', "$filename" || confess "Unable to read $filename\n$!\n";
  }
  my $first = readline($fh);
  if (substr($first, 0,1) eq '>') {
    #should be FASTA
    return 'fasta';
  } elsif (substr($first, 0, 1) eq '@') {
    #should be fastq
    readline($fh);
    my $sep = readline($fh);
    if ( substr($sep, 0, 1) eq '+' ) {
      #second check for fastq
      return 'fastq';
    }
  } else {
    #unknown format
    return undef;
  }
}
sub _load_seqs {
  my ($self) = @_;
  return 0 unless (defined $self->{loadseqs});

  my $seqs = undef;
  while (my $s = $self->getRead() ) {
      my ($name, $seq) = ($s->{name}, $s->{seq});
      if ($self->{loadseqs} eq 'name') {
        $seqs->{$name} = $seq;
      } else {
        $seqs->{$seq} = $name;
      }

  }
  $self->{seqs} = $seqs;
}


sub _which {
	return undef if ($^O eq 'MSWin32');
	my $has_which = eval { require File::Which; File::Which->import(); 1};
	if ($has_which) {
		foreach my $cmd (@_) {
			return which($cmd) if (which($cmd));
		}
	} else {
		foreach my $cmd (@_) {
			`which $cmd  2> /dev/null`;
			return $cmd if (not $?);
		}
	}
	return undef;
}
=head1 ACKNOWLEDGEMENTS

=over 4

=item B<Heng Li's readfq()>

This module is a has been inspired by the I<readfq()> subroutine originally written by Heng Li, that I updated
to retain I<sequence comments>. See: L<readfq repository|https://github.com/telatin/readfq>

=item B<Fabrizio Levorin>

has contributed to the prototyping of this module

=back

=head1 SEE ALSO

=over 4

=item L<BioX::Seq::Stream>

The module I would have used if it was available when I started working on this. The .gz reader implementation comes from this module.

=back

=cut
1;
