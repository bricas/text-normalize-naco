use Test::More qw( no_plan );

use strict;
use warnings;

BEGIN {
	use_ok( 'Text::Normalize::NACO' );
}

my $naco = Text::Normalize::NACO->new( case => 'lower' );
isa_ok( $naco, 'Text::Normalize::NACO' );

for my $file ( <t/*.dat> ) {
	open( FILE, $file );

	while( <FILE> ) {
		s/[\r\n]//g;
		my( $original, $normalized ) = split( /\t/, $_ );
		is( $naco->normalize( $original ), $normalized, "\$naco->normalize( '$original' )" );
	}

	close( FILE );
}


