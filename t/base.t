#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Jedi;

my $jedi = Jedi->new();
$jedi->road('/', 't::lib::base');

test_psgi $jedi->start, sub {
	my $cb = shift;
	my $res = $cb->(GET '/');
	is $res->code, 200, 'Base status is correct';
	is $res->content, 'Hello World !', 'Base content is correct';
};

done_testing;