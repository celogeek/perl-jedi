package t::lib::configs::myConfigRoot;
use Jedi::App;

sub jedi_app {
	my ($app) = @_;
	$app->get('/', sub {
		my ($self, $request, $response) = @_;
		$response->status(200);
    $response->body($self->jedi_config->{ref $self}{text});
	});
}

1;
