package Jedi::Request;
use Moo;
use CGI::Deurl::XS 'parse_query_string';
use CGI::Cookie::XS;

has 'env' => (is => 'ro', required => 1);

has 'path' => (is => 'ro', required => 1);

has 'params' => (is => 'lazy');
sub _build_params {
	my ($self) = @_;
	return parse_query_string($self->env->{QUERY_STRING}) // {};
}

has 'cookies' => (is => 'lazy');
sub _build_cookies {
	my ($self) = @_;
	return CGI::Cookie::XS->parse($self->env->{HTTP_COOKIE}) // {};
}
1;