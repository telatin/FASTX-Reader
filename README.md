# FASTQ-Parser
OOP Perl module to parse FASTQ files, without depending on BioPerl

## Origin

Based on Heng Li's FAST* parser subroutine (https://github.com/lh3/readfq) and its minor updates
reported here (https://github.com/telatin/readfq/blob/master/readfq.pl)

 ### Original script
 
In the scripts directory there are two test _input files_ (test.fasta and test.fastq), and a demo script showing the usage of the subroutine readfq. The script will print the number of sequences and the lenght of the longest sequence.

```
# Demo script usage (by default will read test.fasta in its directory):
perl scripts/test.pl

# Specify a file to parse
perl scripts/test.pl --input scripts/test.fastq

# Print every sequence name, in addition to the total at the end
perl scripts/test.pl --input scripts/test.fastq --long
perl scripts/test.pl --i scripts/test.fastq -l
```
