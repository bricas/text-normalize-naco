package Text::Normalize::NACO;

=head1 NAME

Text::Normalize::NACO - Normalize text based on the NACO rules

=head1 SYNOPSIS

	# exported method
	use Text::Normalize::NACO qw( naco_normalize );
	
	$normalized = naco_normalize( $original );
	
	# as an object
	$naco       = Text::Normalize::NACO->new;
	$normalized = $naco->normalize( $original );

	# normalize to lowercase
	$naco->case( 'lower' );
	$normalized = $naco->normalize( $original );

=head1 DESCRIPTION

In general, normalization is defined as:

	To make (a text or language) regular and consistent, especially with respect to spelling or style.

It is commonly used for comparative purposes. These particular normalization rules have been set out by the
Name Authority Cooperative. The rules are described in detail at: http://www.loc.gov/catdir/pcc/naco/normrule.html

=cut

use base qw( Exporter );

use strict;
use warnings;

our $VERSION = '0.05';

our @EXPORT_OK = qw( naco_normalize );

# LUT to convert diacritical and special characters
# Modified from Pod::Escapes
my ( %Latin1Code_to_fallback, %Latin1Char_to_fallback );

@Latin1Code_to_fallback{ 0xA0..0xFF } = (
	' ', ' ', 'C', ' ', ' ', 'Y', ' ', 'SS', ' ', ' ', 'a', ' ', ' ', '',  ' ', ' ',
	' ', ' ', '2', '3', '', 'u', 'P', ' ', ' ', '1', 'o', ' ', '1/4', '1/2', '3/4', ' ',
	'A', 'A', 'A', 'A', 'A', 'A', 'AE', 'C', 'E', 'E', 'E', 'E', 'I', 'I', 'I', 'I',
	'D', 'N', 'O', 'O', 'O', 'O', 'O', 'x', 'O', 'U', 'U', 'U', 'U', 'U', 'Th', 'ss',
	'a', 'a', 'a', 'a', 'a', 'a', 'ae', 'c', 'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i',
	'd', 'n', 'o', 'o', 'o', 'o', 'o', ' ', 'o', 'u', 'u', 'u', 'u', 'y', 'th', 'y',
);

{
	my( $k, $v );
	while( ( $k, $v ) = each %Latin1Code_to_fallback ) {
		$Latin1Char_to_fallback{ chr $k } = $v;
	}
}

=head1 METHODS

=head2 new( %options )

Creates a new Text::Normalize::NACO object. You explicitly request
strings to be normalized in upper or lower-case by setting
the "case" option (defaults to "upper").

	my $naco = Text::Normalize::NACO->new( case => 'lower' );

=cut

sub new {
	my $class   = shift;
	my %options = @_;
	my $self    = bless {}, $class;

	$self->case( $options{ case } || 'upper' );

	return $self;
}

=head2 case( $case )

Accessor/Mutator for the case in which the string should be returned.

	# lower-case
	$naco->case( 'lower' );

	# upper-case
	$naco->case( 'upper' );

=cut

sub case {
	my $self = shift;
	my( $case ) = @_;

	$self->{ _CASE } = $case if @_;

	return $self->{ _CASE };
}

=head2 naco_normalize( $text, { %options } )

Exported version of C<normalize>. You can specify any extra
options by passing a hashref after the string to be normalized.

	$normalized = naco_normalize( $original, { case => 'lower' } );

=cut

sub naco_normalize {
	my $text    = shift;
	my $options = shift;
	my $case    = $options->{ case } || 'upper';

	my $normalized = normalize( undef, $text );

	if( $case eq 'lower' ) {
		$normalized =~ tr/A-Z/a-z/;
	}
	else {
		$normalized =~ tr/a-z/A-Z/;
	}

	return $normalized;
}

=head2 normalize( $text )

Normalizes $text and returns the new string.

=cut

sub normalize {
	my $self  = shift;
	my $data  = shift;

	# Rules taken from NACO Normalization
	# http://lcweb.loc.gov/catdir/pcc/naco/normrule.html

	# Convert special chars to spaces
	$data =~ s/[\Q!(){}<>-;:.?,\/\\@*%=\$^_~\E]/ /g;

	# Delete special chars
	$data =~ s/[\Q'[]|\E]//g;

	# Remove diacritical marks and convert special chars
	my @chars = split(//, $data);
	for ( my $i = 0; $i < @chars; $i++ ) {
		next unless ord( $chars[ $i ] ) >= 160 and ord( $chars[ $i ] ) <= 255;
		$chars[ $i ] = $Latin1Char_to_fallback{ $chars[ $i ] };
	}
	$data = join( '', @chars );

	# Convert lowercase to uppercase or vice-versa.
	if( $self ) {
		if( $self->case eq 'lower' ) {
			$data =~ tr/A-Z/a-z/;
		}
		else {
			$data =~ tr/a-z/A-Z/;
		}
	}

	# Remove leading and trailing spaces
	$data =~ s/^\s+|\s+$//g;

	# Condense multiple spaces
	$data =~ s/\s+/ /g;

	return $data;
}

=head1 TODO

=over 4

=item * Add a test suite

=back

=head1 SEE ALSO

=over 4

=item * http://www.loc.gov/catdir/pcc/naco/normrule.html

=back

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;