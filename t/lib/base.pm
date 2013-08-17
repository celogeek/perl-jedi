package t::lib::base;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('hello_world'));
	$jedi->post('/', $jedi->can('hello_world_post'));
}

sub hello_world {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body('Hello World !');

	return 1;
}

sub hello_world_post {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body('Hello World POST !');

	return 1;
}
1;