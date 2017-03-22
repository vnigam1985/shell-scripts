#!/usr/bin/perl -w

while (<*.rfh>)
{
open(INFILE,"$_");
foreach $line (<INFILE>)
{
$line =~ s/\s+//g;
#print <> "$line";
}
close(INFILE);
}
