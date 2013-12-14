package Jedi;

# ABSTRACT: Jedi Web App Framework

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
