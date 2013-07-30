package t::lib::multipleheaders;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('multiple_headers'));

	return;
}

sub multiple_headers {
	my ($jedi, $request, $response) = @_;

	$response->status(200);
	$response->body('OK');
	$response->push_header('test', 1);
	$response->push_header('test', 2);

	return 1;
}

1;