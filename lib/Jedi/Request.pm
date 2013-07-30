package Jedi::Request;

# ABSTRACT: Jedi Request

=head1 DESCRIPTION

This object is pass through the route, as a second params. (self, request, response).

You can get data from it, to generate your response

=cut

use Moo;
use CGI::Deurl::XS 'parse_query_string';
use CGI::Cookie::XS;

=attr env

The environment variable, as it received from PSGI

=cut
has 'env' => (is => 'ro', required => 1);

=attr path

The end of the path_info, without the road.

Ex:
	road("/test"), route("/me") # so /test/me/ will give the path /me/

=cut
has 'path' => (is => 'ro', required => 1);

=attr params

Parsing of the QUERY_STRING. It always return an HASH, with:

	key => Scalar // [ARRAY of Values]

Ex:

	a=1&a=2&a=3&b=4&b=5&b=6&c=1

You receive:
	
	a => [1,2,3]
	b => [4,5,6]
	c => 1

=cut
has 'params' => (is => 'lazy');
sub _build_params {
	my ($self) = @_;
	return parse_query_string($self->env->{QUERY_STRING}) // {};
}

=attr cookies

Parse the HTTP_COOKIE, and return an Hash of array

Ex:

	a=1&b&c; b=4&5&6; c=1

You receive:
	
	a => [1,2,3]
	b => [4,5,6]
	c => [1]

=cut
has 'cookies' => (is => 'lazy');
sub _build_cookies {
	my ($self) = @_;
	return CGI::Cookie::XS->parse($self->env->{HTTP_COOKIE}) // {};
}
1;