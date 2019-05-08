# FASTX::Reader
[![CPAN](https://img.shields.io/badge/CPAN-FASTX::Reader-1abc9c.svg)](https://metacpan.org/pod/FASTX::Reader)
[![Kwalitee](https://cpants.cpanauthors.org/release/PROCH/FASTX-Reader-0.01.svg)](https://cpants.cpanauthors.org/release/PROCH/FASTX-Reader-0.01)
[![Version](https://img.shields.io/cpan/v/Proch-N50.svg)](https://metacpan.org/pod/FASTX::Reader)
[![Tests](https://img.shields.io/badge/Tests-Grid-1abc9c.svg)](https://www.cpantesters.org/distro/F/FASTX-Reader.html)
### An OOP Perl module to parse FASTA and FASTQ files

For updated documentation, please visit *[Meta::CPAN](https://metacpan.org/pod/FASTX::Reader)*.

### Short synopsis

```perl
use FASTX::Reader;
my $filepath = '/path/to/assembly.fastq';
die "Input file not found: $filepath\n" unless (-e "$filepath");
my $fasta_reader = FASTX::Reader->new({ filename => "$filepath" });
 
while (my $seq = $fasta_reader->getRead() ) {
  print $seq->{name}, "\t", $seq->{seq}, "\t", $seq->{qual}, "\n";
}
```

### Contributors
- Andrea Telatin
- Fabrizio Levorin
