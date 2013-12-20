package Jedi;

# ABSTRACT: Web App Framework

use Moo;

# VERSION

use Jedi::Helpers::Scalar;
use Jedi::Request;
use Jedi::Response;
use CHI;

use Module::Runtime qw/use_module/;
use Carp qw/croak/;

# PUBLIC METHOD

has 'config' => (is => 'ro', default => sub {{}});

sub road {
	my ($self, $base_route, $module) = @_;
	$base_route = $base_route->full_path();

	my $jedi = use_module($module)->new(jedi_config => $self->config);
	croak "$module is not a jedi app" unless $jedi->does('Jedi::Role::App');
	
	$jedi->jedi_app;

	push(@{$self->_jedi_roads},[$base_route => $jedi]);
	$self->_jedi_roads_is_sorted(0);
	$self->_clear_jedi_roads_cache;
	return;
}

sub start {
	my ($self) = @_;
	return sub { $self->_response(@_)->to_psgi };
}

# PRIVATE METHODS AND ATTRIBUTES

# The roads is store when you register an app into a specific path
has '_jedi_roads' => (is => 'ro', default => sub {[]});
has '_jedi_roads_is_sorted' => (is => 'rw', default => sub { 0 });
has '_jedi_roads_cache' => (is => 'lazy', clearer => 1);
sub _build__jedi_roads_cache {
  return CHI->new(driver => 'RawMemory', datastore => {}, max_size => 10_000);
}

# The response loop on all path, using the cache and return a response format
# This response can be convert into a compatible psgi response
# The method 'start' use that method directly.
sub _response {
  my ($self, $env) = @_;
  
  my $sorted_roads = $self->_jedi_roads;
  if (!$self->_jedi_roads_is_sorted) {
    $self->_jedi_roads_is_sorted(1);
    @$sorted_roads = sort { length($b->[0]) <=> length($a->[0]) } @$sorted_roads;
  }

  my $path_info = $env->{PATH_INFO}->full_path();
  my $response = Jedi::Response->new();

  if (my $road_def = $self->_jedi_roads_cache->get($path_info)) {
    my ($road, $jedi) = @$road_def;
    return $jedi->response(Jedi::Request->new(env => $env, path => $path_info->without_base($road)), $response);
  }

  for my $road_def(@$sorted_roads) {
    my ($road, $jedi) = @$road_def;
    if ($path_info->start_with($road)) {
      $self->_jedi_roads_cache->set($path_info => $road_def);
      return $jedi->response(Jedi::Request->new(env => $env, path => $path_info->without_base($road)), $response);
    }
  }

  return Jedi::Response->new(status => 500, body => 'No road found !');
}

1;
__END__

=head1 DESCRIPTION

Jedi is a web framework, easy to understand, without DSL !

In a galaxy, far far away, a misterious force is operating. Come on young Padawan, let me show you how to use that power wisely !

=head1 SYNOPSIS

An Jedi App is simple as a package in perl. You can initialize the app with the jedi launcher and a config file.

When you include L<Jedi::App>, it will automatically import L<Moo> and the L<Jedi::Role::App> in your package.

In MyApps.pm :

 package MyApps;
 use Jedi::App;
 
 sub jedi_app {
  my ($app) = @_;
  $app->get('/', $app->can('index'));
  $app->get('/config', $app->can('show_config'));
  $app->get(qr{/env/.*}, $app->can('env'));
 }
 
 sub index {
  my ($app, $request, $response) = @_;
  $response->status(200);
  $response->body('Hello World !');
  return 1;
 }

 sub env {
  my ($app, $request, $response) = @_;
  my $env = substr($request->path, length("/env/"));
  $response->status(200);
  $response->body(
      "The env : <$env>, has the value <" .
      ($request->env->{$env} // "") . 
    ">");
  return 1;
 }

 sub show_config {
  my ($app, $request, $response) = @_;
  $response->status(200);
  $response->body($app->jedi_config->{MyApps}{foo});
  return 1;
 }

 1;

In MyApps::Admin :

 package MyApps;
 use Jedi::App;
 
 sub jedi_app {
   my ($jedi) = @_;
   $jedi->get('/', $jedi->can('index_admin'));
 }
 
 sub index_admin {
   #...
 }
 1

The you can create a lauching config app.yml :

 Jedi:
   Roads:
     MyApps: "/"
     MyApps::Admin: "/admin"
 Plack:
   env: production
   server: Starman
 Starman:
   workers: 2
 MyApps:
   foo: bar

To start your app :

 jedi -c app.yml

And if you want to test your app with your package inside the 'lib' directory :

 jedi -Ilib -c app.yml

