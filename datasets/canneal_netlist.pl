#!/usr/bin/perl

# Copyright 2009, Princeton University
# All rights reserved.
#
# A simple script to generate inputs for the canneal workload of the PARSEC
# Benchmark Suite.

use strict;
my @names;

my $x = shift;
my $y = shift;
my $num_elements = shift;
($x > 1) or die "x is invalid: $y";
($y >1) or die "y is invalid: $y";
($num_elements < ($x * $y) )or die;
my $num_connections = 5;

print "$num_elements	$x	$y\n";


#create a set of names.  Use the ++ operator gives meaningless names, but thats 
#all I really need
my $name = "a";
foreach my $i (0..$num_elements-1){
	$names[$i] = $name;
	$name++;
}

foreach my $i (0..$num_elements-1){
	print "$names[$i]\t";
	#type is either reg or comb  For now my program makes no distinction
	my $type = 1+ int(rand(2));
	print "$type\t";
	foreach my $j (0..$num_connections-1){
		#get a random element
		my $random_connection = int(rand($num_elements));
		print $names[$random_connection];
		print "\t";
	}
	print "END\n";
}
