package t::lib::missing;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('hello_world'));
	$jedi->missing($jedi->can('handle_missing'));
}

sub hello_world {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body('hello world !');
	return 1;
}

sub handle_missing {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body('missing : ' . $request->path);
	return 1;
}

1;