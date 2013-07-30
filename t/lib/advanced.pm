package t::lib::advanced;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('hello_world'));
	$jedi->get(qr{aaa}, $jedi->can('regexp'));
	$jedi->get(qr{aaaa}, $jedi->can('regexp2'));

	return;
}

sub hello_world {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body('Hello World !');

	return 1;
}

sub regexp {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body('aaa');
	return 1;
}

sub regexp2 {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body($response->body . ',aaaa');
}

1;