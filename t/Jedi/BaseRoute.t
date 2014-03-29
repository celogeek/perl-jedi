#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Jedi;

{
	my $jedi = Jedi->new();
	$jedi->road('/', 't::lib::baseroute');
	$jedi->road('/admin', 't::lib::baseroute');
	
	test_psgi $jedi->start, sub {
		my $cb = shift;
		{
			my $res = $cb->(GET '/');
			is $res->code, 200, 'status root is correct';
			is $res->content, '/', '... and content is correct';
		}
		{
			my $res = $cb->(GET '/admin');
			is $res->code, 200, 'status root is correct';
			is $res->content, '/admin/', '... and content is correct';
		}
    }
}
done_testing;
