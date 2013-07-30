package t::lib::BadRoute::BadSub;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->_jedi_routes_push('GET', '/');

	return;
}

1;