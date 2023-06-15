#!/usr/bin/perl
#im using this repo to learn git sorry
use Data::dumper;
use XML::Parser;
use XML::SimpleObject;
use GD::Image;
use Geo::Proj4;

my $proj = Geo::Proj4->new(proj => "merc", datum => "WGS84");

#my $file = '/home/kara/dev/osmtoday/sample-data/hexagone-diff-latest.osc';
my $file = shift;
my $background_file = '/home/kara/dev/osmtoday/img/bg.png';

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $xso = XML::SimpleObject->new( $parser->parsefile($file) );

my $im = GD::Image->newFromPng($background_file);
my $creation_color = $im->colorAllocate(0, 255, 0);
my $modification_color = $im->colorAllocate(0, 0, 255);
my $deletion_color = $im->colorAllocate(255, 0, 0);
my $background = $im->colorAllocate(0, 0, 0);
$im->fill(50,50,$background);

my ($left, $top) = $proj->forward( 51.5, -5.5 );
my ($right, $bottom) = $proj->forward( 40.5, 10.5 );


my $xfactor = $im->width / ($right - $left);
my $yfactor = $im->height / ($top - $bottom);
my $xoffset = $left;
my $yoffset = $top;


foreach my $deletions ($xso->child('osmChange')->children('delete')) {
	foreach my $node ($deletions->children('node')) {
		if ($node) {;
			($x, $y) = $proj->forward( $node->attribute('lat'), $node->attribute('lon') );
			$x = int(($x - $xoffset) * $xfactor);
			$y = int(($yoffset - $y) * $yfactor);
			$im->setPixel($x, $y, $deletion_color);
		}
	}
}

foreach my $modifications ($xso->child('osmChange')->children('modify')) {
	foreach my $node ($modifications->children('node')) {
		if ($node) {
			($x, $y) = $proj->forward( $node->attribute('lat'), $node->attribute('lon') );
			$x = int(($x - $xoffset) * $xfactor);
			$y = int(($yoffset - $y) * $yfactor);
			$im->setPixel($x, $y, $modification_color);
		}
	}
}

foreach my $creations ($xso->child('osmChange')->children('create')) {
	foreach my $node ($creations->children('node')) {
		if ($node) {
			($x, $y) = $proj->forward( $node->attribute('lat'), $node->attribute('lon') );
			$x = int(($x - $xoffset) * $xfactor);
			$y = int(($yoffset - $y) * $yfactor);
			$im->setPixel($x, $y, $creation_color);
		}
	}
}

binmode STDOUT;

print $im->png;
