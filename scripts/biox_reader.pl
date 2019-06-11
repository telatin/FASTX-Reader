use BioX::Seq::Stream;

my $filename = shift @ARGV; 
my $parser = BioX::Seq::Stream->new( $filename );
 
while (my $seq = $parser->next_seq) {
    print $seq->{id}, "\n";
    print $seq->{seq}, "\n";
    print $seq->{qual}, "\n";

    # $seq is a BioX::Seq object
 
}
