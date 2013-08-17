package Jedi::Role::App;

# ABSTRACT: Jedi App Role

=head1 DESCRIPTION

This role is to apply to your Moo module.

   use Moo;
   with 'Jedi::Role::App';

You should use the L<Jedi::App> module.

You module need to defined the sub "jedi_app", the road will call it directly.

=cut

use Moo::Role;
# VERSION
use Jedi::Helpers::Scalar;
use CHI;
use Carp qw/carp croak/;

requires 'jedi_app';

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

=head1 ROUTES

=head2 GET/POST/PUT/DELETE

All the methods, take a route, and a sub.

The route can be a scalar (exact match) or a regexp.

The sub take L<Jedi::App>, a L<Jedi::Request> and a L<Jedi::Response>.

Each sub should fill the Response based on the Request.

The return code should be "1" if everything goes fine, to let other matching route to apply their changes.

If the return is "0" or undef (false), the route stop and return the response.

You should only use the bad return if something goes wrong.

You can have multiple time the same route catch (thought regexp, and exact match). Each one receive a response, and pass this
response to the next sub.

=method get

Define a GET method.

	$jedi->get("/", sub{...});

=cut
sub get  { 
	my ($self, $path, $sub) = @_;
	return $self->_jedi_routes_push('GET', $path, $sub);
}

=method post

Define a POST method.

	$jedi->post("/", sub{...});

=cut
sub post { 	
	my ($self, $path, $sub) = @_;
	return $self->_jedi_routes_push('POST', $path, $sub);
}

=method put

Define a PUT method.

	$jedi->put("/", sub{...});

=cut
sub put  {
	my ($self, $path, $sub) = @_;
	return $self->_jedi_routes_push('PUT', $path, $sub);
}

=method del

Define a DEL method.

	$jedi->del("/", sub{...});

=cut
sub del {
	my ($self, $path, $sub) = @_;
	return $self->_jedi_routes_push('DELETE', $path, $sub);
}


=method missing

If no route matches, all the missing method is executed.

	$jedi->missing(sub{...});

=cut
sub missing {
	my ($self, $sub) = @_;
	croak "sub invalid !" if ref $sub ne 'CODE';

	push(@{$self->_jedi_missing}, $sub);
	$self->_clear_jedi_routes_cache;
	return;
}

=method response

This will solve the route, and run all the method found.

If none is found, we run all the missing methods.

The route continue until a "false" response it sent. That should always mean an error.

	$jedi->response($request, $response);

=cut
sub response {
	my ($self, $request, $response) = @_;

	my $path = $request->path;
	
	my $request_method = $request->env->{REQUEST_METHOD};
	$request_method = 'GET' if $request_method eq 'HEAD';

	my $routes = $self->_jedi_routes->{$request_method};
	my $methods;
	
	if (my $cache_routes = $self->_jedi_routes_cache->get($path)) {
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
	
		$self->_jedi_routes_cache->set($path => $methods);
	}

	for my $meth(@$methods) {
		last if ! $self->$meth($request, $response);
	}

	return $response;
}

1;
