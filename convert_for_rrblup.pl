#!/usr/bin/perl 
use strict;
use warnings;
use Getopt::Std;

#configure getopts
my $usage = "n$0 -i input_file -o output_file -start call_start -stop call_stop -h help\n";

our($opt_i, $opt_o, $opt_f, $opt_l, $opt_h);
getopts("i:o:f:l:h") or die $usage;

if((!(defined $opt_i))or(!(defined $opt_o))or(!(defined $opt_f))or(!(defined $opt_l))or(defined $opt_h)){
  print "$usage";
  exit;
}

#declare global variables
my @split_line;
my %code_ref = (
		'ACAA' => '1',
		'ACAC' => '0',
		'ACCC' => '-1',
		'ACNA' => 'NA',
		'AGAA' => '1',
		'AGAG' => '0',
		'AGGG' => '-1',
		'AGNA' => 'NA',
		'ATAA' => '1',
		'ATAT' => '0',
		'ATTT' => '-1',
		'ATNA' => 'NA',
		'CGCC' => '1',
		'CGCG' => '0',
		'CGGG' => '-1',
		'CGNA' => 'NA',
		'TCTT' => '1',
		'TCTC' => '0',
		'TCCC' => '-1',
		'TCNA' => 'NA',
		'TGTT' => '1',
		'TGTG' => '0',
		'TGGG' => '-1',
		'TGNA' => 'NA',
	       );

open(my $input_file, "<", $opt_i) or die "cannot open opt_i (╯°□°)╯︵ ┻━┻";
open(my $output_file, ">", $opt_o) or die "cannot open opt_o (╯°□°)╯︵ ┻━┻";

#skip line 1 of input_file and save as header
my $current_line = <$input_file>;

print $output_file $current_line;

#iterate through file lines, chomp, and change calls to code, print to output file

my $call_start = $opt_f-1;
my $call_stop = $opt_l-1;

while ($current_line=<$input_file>){
  
  chomp $current_line;
  @split_line = split(",",$current_line);
  
  for (my $i = 0; $i <= $call_stop; $i++) {
    if ($i < $call_start){
    } else {
      my $key = join("",$split_line[1],$split_line[$i]);
      $split_line[$i] = $code_ref{$key};
    }
  }
  
$current_line = join(",", @split_line);
print $output_file "$current_line\n";
  
}

#close files
close $input_file;
close $output_file;

print "complete\n";
