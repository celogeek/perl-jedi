package t::lib::base;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('hello_world'));
}

sub hello_world {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body('Hello World !');

	return 1;
}

1;