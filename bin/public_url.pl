#!/usr/bin/perl -wp

use strict;
use warnings;

s%\[aws_get_object_url:([^=]*)=([^=]*)=[^\]]*\]%https://$1.s3.amazonaws.com/$2%g;
