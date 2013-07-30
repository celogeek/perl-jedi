package t::lib::request;
use Jedi::App;
use JSON;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('handle_params'));
	$jedi->post('/', $jedi->can('handle_params'));
}

sub handle_params {
	my ($jedi, $request, $response) = @_;
	my $p = $request->params;
	$response->status(200);
	$response->body(to_json($p));
	return 1;
}

1;