package t::lib::stop;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('do_redirect'));
	$jedi->get('/', $jedi->can('hello_world'));
}

sub do_redirect {
	my ($jedi, $request, $response) = @_;
	$response->status(302);
	$response->set_header('Location', 'http://blog.celogeek.com');
	return;
}

sub hello_world {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body('KO');
	return 1;
}

1;