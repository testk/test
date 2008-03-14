#!/usr/bin/perl

use Data::Dumper;
use XML::Parser;
use XML::SimpleObject;
use GD::Image;

my $file = '/home/kara/dev/osmtoday/sample-data/hexagone-diff-latest2.osc';

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $xso = XML::SimpleObject->new( $parser->parsefile($file) );

my $im = new GD::Image(600, 600);
my $creation_color = $im->colorAllocate(0, 255, 0);
my $modification_color = $im->colorAllocate(0, 0, 255);
my $deletion_color = $im->colorAllocate(255, 0, 0);
my $background = $im->colorAllocate(0, 0, 0);
$im->fill(50,50,$background);

foreach my $deletions ($xso->child('osmChange')->children('delete')) {
	foreach my $node ($deletions->children('node')) {
		if ($node) {
			$x = int(($node->attribute('lon') + 5.5) * (600 / 14.5));
			$y = int((52 - $node->attribute('lat')) * (600 / 14.5));
			$im->setPixel($x, $y, $deletion_color);
		}
	}
}

foreach my $modifications ($xso->child('osmChange')->children('modify')) {
	foreach my $node ($modifications->children('node')) {
		if ($node) {
			$x = int(($node->attribute('lon') + 5.5) * (600 / 14.5));
			$y = int((52 - $node->attribute('lat')) * (600 / 14.5));
			$im->setPixel($x, $y, $modification_color);
		}
	}
}

foreach my $creations ($xso->child('osmChange')->children('create')) {
	foreach my $node ($creations->children('node')) {
		if ($node) {
			$x = int(($node->attribute('lon') + 5.5) * (600 / 14.5));
			$y = int((52 - $node->attribute('lat')) * (600 / 14.5));
			$im->setPixel($x, $y, $creation_color);
		}
	}
}

binmode STDOUT;

print $im->png;