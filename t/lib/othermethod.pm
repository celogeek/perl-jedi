package t::lib::othermethod;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('display_method'));
	$jedi->put('/', $jedi->can('display_method'));
	$jedi->post('/', $jedi->can('display_method'));
	$jedi->del('/', $jedi->can('display_method'));

	return;
}

sub display_method {
	my ($jedi, $request, $response) = @_;

	$response->status(200);
	$response->body($request->env->{REQUEST_METHOD});

	return 1;
}

1;