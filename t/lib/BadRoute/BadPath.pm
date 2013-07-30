package t::lib::BadRoute::BadPath;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->_jedi_routes_push('GET');

	return;
}

1;