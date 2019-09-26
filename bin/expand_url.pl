#!/usr/bin/perl -wp

use strict;
use warnings;

sub get {
  my ($f) = @_;
  local $\ = undef;
  my $fh;
  open $fh,"<",$f;
  my $c = <$fh>;
  close $fh;
  chomp $c;
  $c =~ s/(?<=[^.])0+,/,/go;
  $c =~ s/(?<=[^.])0+$//o;
  return $c;
}
s%\[aws_get_object:([^=]*)=([^\]]*)\]%&get($2)%ge;
