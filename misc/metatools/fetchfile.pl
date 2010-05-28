#!/usr/bin/perl
# download a file from the web
# status = fetchfile source dest
use LWP::Simple;
my $status = getstore($ARGV[0], $ARGV[1]);
print is_success($status)






