package t::lib::config;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('get_config'));

	return;
}

sub get_config {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body($jedi->jedi_config->{myconf} // 'noconf');

	return 1;
}

1;