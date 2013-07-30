package t::lib::BadRoute::BadMissing;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;

	$jedi->missing('bad');

	return;
}

1;