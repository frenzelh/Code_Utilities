#!/usr/bin/perl -w
#
# H. Frenzel, School of Oceanography, UW
#
# First version: August 16, 2019


# BEGIN of internal man page in POD format
=pod

=head1 NAME

B<FindDirectives.pl> - Script that finds CPP directives in one or more files

=head1 SYNOPSIS

B<FindDirectives.pl> FindDirectives.pl [-s] [-v] file(s)

=head1 DESCRIPTION

B<FindDirectives.pl> finds all CPP directives in the given file(s) and 
prints them alphabetically sorted (one per line) to stdout.

Some of the possible patterns are:

=over 8

#if defined DIRECTIVE1 || defined DIRECTIVE2

#ifdef DIRECTIVE

#ifndef DIRECTIVE

=back

Parentheses, "not" symbols (!), "and" symbols (&&) are possible as well.

=head1 OPTIONS

=over 8

=item B<-h>

Prints a very concise help text.

=item B<-s>

Shows a brief summary (number of files processed and number of
directives found)

=item B<-v>

Adds more verbosity. Implies the summary.

=back

=head1 NOTES

All directives must be in one line starting with a hash mark. 
Continuation lines are not yet considered.

=head1 CURRENT VERSION

Version 1.0 (August 16, 2019)

=head1 AUTHOR

Hartmut Frenzel (hfrenzel@uw.edu)

=cut

# END of internal man page
# use "pod2man FindDirectives.pl > FindDirectives.pl.1" to create the man page
# use "pod2html FindDirectives.pl > FindDirectives.pl.html" to create the man page in HTML format

use strict; # force variable declarations
use Getopt::Std; # handles command-line options


# parse and check command-line options
my %Options;
my $ok = getopts('hsv', \%Options);

if (!$ok || defined($Options{'h'}) ) {
    # wrong options or help requested: print brief help
    die "FindDirectives.pl [-s] [-v] file(s)\n";    
}

my $verbose = 0; # default: not verbose
my $file_count = 0;
if (defined($Options{'v'})) {
    $verbose = 1;
}
my $summary = 0; # default: no summary shown
if (defined($Options{'s'})) {
    $summary = 1;
} 

my %dirs; # directives found
while (@ARGV) {
    my $fname = shift(@ARGV);
    if ($verbose) {
	print "Examining $fname ...\n";
    }
    open(IN, $fname) || die "cannot open $fname for reading: $!";
    while(<IN>) {
	if (/^\s*\#\s*if\s+[!\(]*\s*defined\s+(\w+)\s+(.*)/ || 
	    /^\s*\#\s*if[n]?def\s+(\w+)\s+(.*)/) {
	    if (! exists($dirs{$1})) {
		$dirs{$1} = 1;
		if ($verbose) {
		    print "Found directive \"$1\"\n";
		}
	    }
	    my $rem = $2;
	    # look for additional directives in the current line
	    while ($rem) {
                # first match should be non-greedy (put as little as
		# possible into match before the first "defined"
		if ($rem =~ /^.*?defined\s+([\w]+)(.*)/) {
		    if (! exists($dirs{$1})) {
			$dirs{$1} = 1;
			if ($verbose) {
			    print "Found directive \"$1\"\n";
			}
		    }
		    $rem = $2;
		} else {
		    last;
		}
	    }
	}
    }
    close(IN) || die "can't close $fname: $!";
    $file_count++;
}

# print summary only if requested
if ($verbose || $summary) {
    my $num = keys %dirs;
    print "$file_count files processed, found $num directives:\n";
}
# always print found directives to stdout, alphabetically sorted
print "$_\n" for sort(keys %dirs);
