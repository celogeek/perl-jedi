package t::lib::baseroute;
use Jedi::App;

sub jedi_app {
	my ($jedi) = @_;
    $jedi->get('/', sub {
            my ($app, $req, $resp) = @_;
            $resp->status(200);
            $resp->body($app->jedi_base_route);
    });
}
1;
