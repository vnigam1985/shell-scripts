#!/usr/bin/perl
use strict;

if(@ARGV != 1)
{
	die "Error: please provide directory path";
}

my ($dirname) = @ARGV;

if(-d $dirname)
{
	
	opendir(DIR, $dirname) or die "Error: $dirname Directory can not open";
	my @files = readdir DIR;
	close DIR;

	foreach(@files)
	{
		if($_ eq '.' or $_ eq '..')
		{
			next;
		}
		if(!-d $_)
		{
			#Open file for read
#print "$dirname\\.$_";
			open(FILE, "$dirname\/".$_) or die "Error: could not open file";
			my $filebuf = join "", <FILE>;

			close FILE;
			$filebuf =~ s/\s+//g; #delete spaces and new lines from file buffer			
			
			#Extract export if from xml file
			my ($export_id) = $filebuf =~ /<ExportId>(.+?)<\/ExportId>/i;
			#Extract consumerid from xml file
			#my ($ConsumerId) = $filebuf =~ /<Id\ *Type\=\"ConsumerId\">(.+?)<\/Id>/i;
			
			#Check whether market directory already exist
			#if(! -d "$dirname\/$market")
			#{
			#	#If not exist create one
			#	mkdir "$dirname\/$market";
			#}
			
			#Create a file with name market-consumerid in market folder. For example, CN-115290549.txt
			open(FILE, ">>$dirname\/list\.txt") or die "Can not create file list\.txt";
			print FILE "$export_id"."\n";
			close FILE;			
			#`mv "$dirname\/$_" "$dirname\/$market"`;
			#Append spaces, lines removed data to the file in comment
			#open(FILE, ">>$dirname\\".$_) or die "Error: could not open file";
			#print FILE "\n\n\n<!--$filebuf\n\n-->";						
			#close FILE;
		}
	}
}
else
{
	print "Error: $dirname is not a valid directory";

}
