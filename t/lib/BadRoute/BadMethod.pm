package t::lib::BadRoute::BadMethod;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->_jedi_routes_push('PLOP', '/', sub{});

	return;
}

1;