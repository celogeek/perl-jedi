package Jedi;
use Moo;
use Jedi::Helpers::Scalar;
use Jedi::Request;
use Jedi::Response;

use Module::Runtime qw/use_module/;
use Carp qw/croak/;

has '_jedi_roads' => (is => 'ro', default => sub {[]});
has '_jedi_roads_is_sorted' => (is => 'rw', default => sub { 0 });

sub road {
	my ($self, $base_route, $module) = @_;
	$base_route = $base_route->full_path();

	my $jedi = use_module($module)->new();
	croak "$module is not a jedi app" unless $jedi->does('Jedi::Role::App');
	
	$jedi->jedi_app;

	push(@{$self->_jedi_roads},[$base_route => $jedi]);
	$self->_jedi_roads_is_sorted(0);
	return;
}

sub response {
	my ($self, $env) = @_;
	
	my $sorted_roads = $self->_jedi_roads;
	if (!$self->_jedi_roads_is_sorted) {
		$self->_jedi_roads_is_sorted(1);
		@$sorted_roads = sort { length($b->[0]) <=> length($a->[0]) } @$sorted_roads;
	}
	return Jedi::Response->new(code => 500, body => 'No road found !') if !scalar(@$sorted_roads);

	my $path_info = $env->{PATH_INFO}->full_path();

	my $response = Jedi::Response->new();

	for my $road_def(@$sorted_roads) {
		my ($road, $jedi) = @$road_def;
		if ($path_info->start_with($road)) {
			return $jedi->response(Jedi::Request->new(env => $env, path => $path_info->without_base($road)), $response);
		}
	}

	return $response;
}

sub start {
	my ($self) = @_;
	return sub { $self->response(@_)->to_psgi };
}

1;
