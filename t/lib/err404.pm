package t::lib::err404;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('err404'));
}

sub err404 {
	my ($jedi, $request, $response) = @_;
	$response->body('err404');
}

1;