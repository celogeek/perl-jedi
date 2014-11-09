package t::lib::hostip;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->get('/', $jedi->can('get_hostip'));

	return;
}

sub get_hostip {
	my ($jedi, $request, $response) = @_;
	$response->status(200);
	$response->body($jedi->jedi_host_ip);

	return 1;
}

1;
