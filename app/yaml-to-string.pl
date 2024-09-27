use strict;
use warnings;
use YAML qw'LoadFile';

my $packages = $ARGV[0];

my $items = LoadFile "/packages/$packages.yml";

my $first = 1;

for ( @{$items} ) {
    if ( $first ) {
        print "$_";
        $first = 0;
    } else {
        print " $_";
    }
}
