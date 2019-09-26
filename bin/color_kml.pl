#!/usr/bin/perl -w
use strict;
use warnings;
use Text::CSV;

my $arg = $ARGV[0];
my $mod = '';
if ($arg) {
  $mod = "_$arg";
} else {
  $arg = "EDWG";
}

sub get_p {
  my ($f) = @_;
  open my $fh,$f or die "cannot open $f: $!";
  my %p = ();
  while (my $line=<$fh>) {
    chop $line;
    if ($line =~ m/\s*(\d+)\s*:\s*"?([^"]*)"?\s*$/) {
      $p{$1} = $2;
    }
  }
  return %p;
}

sub get_h {
  my ($f) = @_;
  open my $fh,$f or die "cannot open $f: $!";
  my %h = ();
  while (my $line=<$fh>) {
    chop $line;
    my ($key,$rgb) = split ' ',$line;
    my ($r,$g,$b) = split ':',$rgb;
    $h{$key} = sprintf("ff%02x%02x%02x",$b,$g,$r);
  }
  return %h;
}

sub get_c {
  my ($f) = @_;
  open my $fh,$f or die "cannot open $f: $!";
  my %c = ();
  while (my $line=<$fh>) {
    chop $line;
    my ($key,$rgb) = split ' ',$line;
    my ($r,$g,$b) = split ':',$rgb;
    $c{$key} = sprintf("#%02x%02x%02x",$r,$g,$b);
  }
  return %c;
}

my %cats = ();
my $cat;
my %h=get_h($ENV{UNIT_PARAMETERS}."/".$ENV{"${arg}_COLORS"});
my %c=get_c($ENV{UNIT_PARAMETERS}."/".$ENV{"${arg}_COLORS"});
my %l=get_p($ENV{UNIT_PARAMETERS}."/".$ENV{"${arg}_LABELS"});
my %w=get_p($ENV{UNIT_PARAMETERS}."/".$ENV{"${arg}_WEIGHTS"});
my %m=();
my $fin;
my $fout;
my $in;
my $out;

sub r(\%$) {
  my ($s,$cat) = @_;
  return $$s{$cat};
}

if ($mod) {
  my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();

  $fin = $ENV{TARGETDIR}."/line_stats/linear/".$ENV{NAME}."${mod}_miles.csv";
  open $in,"<",$fin or die "cannot open $fin: $!";
  $csv->column_names($csv->getline($in));
  while (my $row = $csv->getline($in)) {
    $w{$row->[1]} = $row->[2]; # override with actual weights used
    $m{$row->[1]} = $row->[3]; # miles in cat
  }
  close $in or die "cannot close $fin: $!";
}

$fin = $ENV{TARGETDIR}."/ideal_path/".$ENV{NAME}."${mod}_path.kml";
$fout = $ENV{TARGETDIR}."/ideal_path/".$ENV{NAME}."${mod}.kml";
open $in,"<",$fin or die "cannot open $fin: $!";
open $out,">",$fout or die "cannot open $fout: $!";
while (<$in>) {
  if (m/>cat:</) {
    print $out "      <b>$ENV{NAME}</b><br />\n";
    s/cat/$arg/;
    if (m/>(\d+)</) {
      $cat = $1;
      $cats{$cat} = 1;
      s/$cat/&r(\%l,$cat)/e;
    }
  }
  elsif (m/>label:</) {
    s/label/weight/;
  }
  elsif (m-<LineStyle><color>.*?</color></LineStyle>-) {
    s-(?<=<color>).*?(?=</color>)-&r(\%h,$cat)-e;
  }
  print $out $_;
}

close $in or die "cannot close $fin: $!";
close $out or die "cannot close $fout: $!";

$fout = $ENV{TARGETDIR}."/legend${mod}.json";
open $out,">",$fout or die "cannot open $fout: $!";
$. = 0;
foreach $cat (sort keys %cats) {
  $.++;
  print $out "," if $.>1;
  print $out '"',&r(\%c,$cat),'",';
  print $out '"',&r(\%l,$cat),' (',&r(\%w,$cat),')';
  printf $out ' %.3f miles',&r(\%m,$cat) if $mod;
  print $out '"'
}
close $out or die "cannot close $fout: $!";

exit 0;
