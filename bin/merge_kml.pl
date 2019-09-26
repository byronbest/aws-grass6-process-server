#!/usr/bin/perl -w

use strict;
use warnings;

my ($saw_xml,$saw_kml,$saw_Document,$finally);

END { print $finally; }

while (<>) {
  if (m/^<[?]xml /) {
    next if $saw_xml;
    $saw_xml = 1;
  }
  elsif (m/^<kml /) {
    next if $saw_kml;
    $saw_kml = 1;
  }
  elsif (m/^<Document>/) {
    s/^<Document>// if $saw_Document;
    $saw_Document = 1;
  }
  elsif (m-</Document></kml>-) {
    $finally = "</Document></kml>\n";
    s-</Document></kml>--;
  }
  print;
}
exit 0;
