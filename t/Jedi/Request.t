#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Jedi;
use JSON;

my $jedi = Jedi->new();
$jedi->road('/', 't::lib::request');

test_psgi $jedi->start, sub {
	my ($cb) = @_;
	{
		my $res = $cb->(GET '/');
		is $res->code, 200, 'status is correct';
		is $res->content, '{}', 'status is empty, no params';
	}

	{
		my $res = $cb->(GET '/?a=1&a=2&b=1');
		is $res->code, 200, 'status is correct';
		is_deeply from_json($res->content), {a => [1,2], b => 1}, '... and params is correct';
	}

	{
		my $res = $cb->(POST '/?a=1&a=2&b=1');
		is $res->code, 200, 'status is correct';
		is_deeply from_json($res->content), {}, '... and params is empty (not a post)';
	}

	{
		my $res = $cb->(POST '/', [a => 1, a => 2, b => 1]);
		is $res->code, 200, 'status is correct';
		is_deeply from_json($res->content), {a => [1,2], b => 1}, '... and params is correct';
	}
};

done_testing;