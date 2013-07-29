package Jedi::Role::App;
use Moo::Role;
use Jedi::Helpers::Scalar;

use Carp qw/carp croak/;

has '_jedi_routes' => ( is => 'ro', default => sub {{}} );
has '_jedi_missing' => (is => 'ro', default => sub {[]});

sub _jedi_routes_push {
	my ($self, $which, $path, $sub) = @_;
	croak "bad method : GET/POST/PUT/DELETE" if $which !~ /^(?:GET|POST|PUT|DELETE)/;
	croak "path incorrect !" if !defined $path;
	croak "sub incorrect !" if ref $sub ne 'CODE';
	$path = $path->full_path if ref $path ne 'Regexp';
	push @{$self->_jedi_routes->{$which}}, [$path, $sub];
}

sub get  { shift->_jedi_routes_push('GET', @_) }
sub post { shift->_jedi_routes_push('POST', @_) }
sub put  { shift->_jedi_routes_push('PUT', @_) }
sub del  { shift->_jedi_routes_push('DELETE', @_) }

sub missing {
	my ($self, $sub) = @_;
	croak "sub incorrect !" if ref $sub ne 'CODE';

	push(@{$self->_jedi_missing}, $sub);
}

sub response {
	my ($self, $request, $response) = @_;

	my $path = $request->path;
	my $routes = $self->_jedi_routes->{$request->env->{REQUEST_METHOD}};
	my $methods = [];
	if (ref $routes eq 'ARRAY') {
		for my $route_def(@$routes) {
			my ($route, $sub) = @$route_def;
			if (ref $route eq 'Regexp') {
				push @$methods, $sub if $path =~ $route;
			} else {
				push @$methods, $sub if $path eq $route->full_path;
			}
		}
	}

	@$methods = @{$self->_jedi_missing} if ! scalar @$methods;

	for my $meth(@$methods) {
		last if ! $self->$meth($request, $response);
	}

	return $response;
}

1;
