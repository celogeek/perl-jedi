package Jedi::Request;

# ABSTRACT: Request object

=head1 DESCRIPTION

This object is pass through the route, as a second params. (self, request, response).

You can get data from it, to generate your response

=cut

use strict;
use warnings;
# VERSION

# USE
use HTTP::Body;
use CGI::Deurl::XS 'parse_query_string';
use CGI::Cookie::XS;
use Net::IP::XS;

# MOO PACKAGE
use Moo;

=attr env

The environment variable, as it received from PSGI. This is a HASH.

=cut
has 'env' => (is => 'ro', required => 1);

=attr path

The end of the path_info, without the road.

Ex:
	road("/test"), route("/me") # so /test/me/ will give the path /me/

The $ENV{PATH_INFO} is untouch, you can use that method to get the relative PATH.

The path always end with '/'.

=cut
has 'path' => (is => 'ro', required => 1);

=attr params

If method is POST or PUT, it will parse the body, and extract the params.

Otherwise it parse the QUERY_STRING.

It always return an HASH, with:

	key => Scalar // [ARRAY of Values]

Ex:

	a=1&a=2&a=3&b=4&b=5&b=6&c=1

You receive:

  {	
   a => [1,2,3],
   b => [4,5,6],
   c => 1
  }

=cut
has 'params' => (is => 'lazy');
sub _build_params {
	my ($self) = @_;
	my $method = $self->env->{REQUEST_METHOD};
	if ($method eq 'POST' || $method eq 'PUT') {
		return $self->_body->param;
	} else {
		return parse_query_string($self->env->{QUERY_STRING}) // {};
	}
}

=attr uploads

Return the file uploads.

For a request like test@test.txt, the form is : 

   	test => {
	    filename   "test.txt",
        headers    {
            Content-Disposition   "form-data; name="test"; filename="test.txt"",
            Content-Type          "text/plain"
        },
        name       "test",
        size       13,
        tempname   "/var/folders/_1/097rrrdd2s5dwqgd7hp6nlx00000gn/T/X4me5HO7L_.txt"
   	}

Ex with curl :
	
	curl -F 'test@test.txt' http://localhost:5000/post

You can read the tempname file to get the content. When the request is sent back, the file is automatically removed.

See <HTTP::Body> for more details.

=cut
has 'uploads' => (is => 'lazy');
sub _build_uploads {
	my ($self) = @_;
	my $method = $self->env->{REQUEST_METHOD};
	if ($method eq 'POST' || $method eq 'PUT') {
		return $self->_body->upload;
	} else {
		return {};
	}
}

=attr cookies

Parse the HTTP_COOKIE, and return an HASH of ARRAY

Ex:

	a=1&b&c; b=4&5&6; c=1

You receive:
	
 {
  a => [1,2,3],
	b => [4,5,6],
	c => [1]
 }

=cut
has 'cookies' => (is => 'lazy');
sub _build_cookies {
	my ($self) = @_;
	return CGI::Cookie::XS->parse($self->env->{HTTP_COOKIE} // '');
}

=method scheme

Return the scheme from proxied proto or main proto

=cut
sub scheme {
	my ($self) = @_;
	my $env = $self->env;

	return 
	       $env->{'X_FORWARDED_PROTOCOL'}
        || $env->{'HTTP_X_FORWARDED_PROTOCOL'}
        || $env->{'HTTP_X_FORWARDED_PROTO'}
        || $env->{'HTTP_FORWARDED_PROTO'}
      	|| $env->{'psgi.url_scheme'}
      	|| $env->{'PSGI.URL_SCHEME'}
      	|| '';
}

=method port

Return server port

=cut
sub port {
	my ($self) = @_;
	my $env = $self->env;

	return $env->{'SERVER_PORT'};	
}

=method host

Return the proxied host or the main host

=cut
sub host {
	my ($self) = @_;
	my $env = $self->env;

	return
	   $env->{'HTTP_X_FORWARDED_HOST'}
	|| $env->{'X_FORWARDED_HOST'}
	|| $env->{'HTTP_HOST'}
	|| '';
}

# get Net::IP::XS of the most probable real ip
has '_real_ip' => (is => 'lazy');
sub _build__real_ip {
	my ($self) = @_;

    my $env = $self->env;
    my @possible_forwarded_ips = 
	grep { $_->iptype !~ /^(?:LOOPBACK|LINK\-LOCAL|PRIVATE|UNIQUE\-LOCAL\-UNICAST|LINK\-LOCAL\-UNICAST)$/xo }
	grep { defined }
	map { Net::IP::XS->new($_) } 
	grep { defined }
	(
                $env->{'HTTP_CLIENT_IP'},
                split(/,\s*/xo, $env->{'HTTP_X_FORWARDED_FOR'} // ''),
                $env->{'HTTP_X_FORWARDED'},
                $env->{'HTTP_X_CLUSTER_CLIENT_IP'},
                $env->{'HTTP_FORWARDED_FOR'},
                $env->{'HTTP_FORWARDED'},
    );

	return $possible_forwarded_ips[0] // Net::IP::XS->new($env->{'REMOTE_ADDR'} // '');
}

=attr remote_address

Return the int version of the remote_address_str

=cut

has 'remote_address' => (is => 'lazy');
sub _build_remote_address {
	my ($self) = @_;
	my $real_ip = $self->_real_ip
		or return 0;
	return $real_ip->intip()->bstr();
}

=attr remote_address_str

Try to find the real ip of the user

=cut

has 'remote_address_str' => (is => 'lazy');
sub _build_remote_address_str {
    my ($self) = @_;
	my $real_ip = $self->_real_ip
		or return '';
	return $real_ip->ip();
}

# PRIVATE

has '_body' => (is => 'lazy');
sub _build__body {
  my ($self) = @_;
  
  my $type = $self->env->{'CONTENT_TYPE'} || '';
  my $length = $self->env->{'CONTENT_LENGTH'} || 0;
  my $io = $self->env->{'psgi.input'};
  my $body = HTTP::Body->new($type, $length);
  $body->cleanup(1);

  while($length) {
        $io->read( my $buffer, ( $length < 8192 ) ? $length : 8192 );
        $length -= length($buffer);
        $body->add($buffer);
  }

  return $body;
}

1;
