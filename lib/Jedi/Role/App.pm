package Jedi::Role::App;

# ABSTRACT: imported role for Jedi::App

=head1 DESCRIPTION

Look the L<Jedi::App> for documentation.

=cut

use Moo::Role;
# VERSION
use Jedi::Helpers::Scalar;
use CHI;
use Carp qw/carp croak/;

# REQUIRED

requires 'jedi_app';

# INTERNAL ATTRIBUTES

has '_jedi_routes' => ( is => 'ro', default => sub {{}} );
has '_jedi_missing' => (is => 'ro', default => sub {[]});
has '_jedi_routes_cache' => (is => 'lazy', clearer => 1);
sub _build__jedi_routes_cache {
	return CHI->new(driver => 'RawMemory', datastore => {}, max_size => 10_000);
}

sub _jedi_routes_push {
	my ($self, $which, $path, $sub) = @_;
	croak "method invalid : only support GET/POST/PUT/DELETE !" if $which !~ /^(?:GET|POST|PUT|DELETE)/x;
	croak "path invalid !" if !defined $path;
	croak "sub invalid !" if ref $sub ne 'CODE';
	$path = $path->full_path if ref $path ne 'Regexp';
	push @{$self->_jedi_routes->{$which}}, [$path, $sub];
	$self->_clear_jedi_routes_cache;
	return;
}

# ATTRIBUTES

has 'jedi_config' => (is => 'ro', default => sub {{}});

# PUBLIC METHODS

sub get  { 
	my ($self, $path, $sub) = @_;
	return $self->_jedi_routes_push('GET', $path, $sub);
}

sub post { 	
	my ($self, $path, $sub) = @_;
	return $self->_jedi_routes_push('POST', $path, $sub);
}

sub put  {
	my ($self, $path, $sub) = @_;
	return $self->_jedi_routes_push('PUT', $path, $sub);
}

sub del {
	my ($self, $path, $sub) = @_;
	return $self->_jedi_routes_push('DELETE', $path, $sub);
}


sub missing {
	my ($self, $sub) = @_;
	croak "sub invalid !" if ref $sub ne 'CODE';

	push(@{$self->_jedi_missing}, $sub);
	$self->_clear_jedi_routes_cache;
	return;
}

sub response {
	my ($self, $request, $response) = @_;

	my $path = $request->path;
	
	my $request_method = $request->env->{REQUEST_METHOD};
	$request_method = 'GET' if $request_method eq 'HEAD';

	my $routes = $self->_jedi_routes->{$request_method};
	my $methods;
	
	my $cache_key = $request_method . ':' . $path;

	if (my $cache_routes = $self->_jedi_routes_cache->get($cache_key)) {
		$methods = $cache_routes;
	} else {
		$methods = [];
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
	
		$self->_jedi_routes_cache->set($cache_key => $methods);
	}

	for my $meth(@$methods) {
		last if ! $self->$meth($request, $response);
	}

	return $response;
}

1;
