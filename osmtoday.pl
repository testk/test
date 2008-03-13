#!/usr/bin/perl

use Data::Dumper;
use XML::Parser;
use XML::SimpleObject;

my $file = '/home/kara/dev/osmtoday/sample-data/hexagone-diff-latest.osc';

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $xso = XML::SimpleObject->new( $parser->parsefile($file) );

foreach my $creations ($xso->child('osmChange')->children('create')) {
	foreach my $nodes ($creations->children('node')) {
		# Do stuff for newly created node
		print "User ".$nodes->attribute('user')." created node at ".$nodes->attribute('lat').", ".$nodes->attribute('lon')."\n";
	}
}
