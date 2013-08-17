#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Jedi;

my $jedi_empty = Jedi->new();

test_psgi $jedi_empty->start, sub {
	my $cb = shift;
	{
		my $res = $cb->(GET '/');
		is $res->code, 500, 'Status of empty jedi is correct';
		is $res->content, 'No road found !', '... and also the content';
	}
};

my $jedi = Jedi->new();
$jedi->road('/', 't::lib::base');

test_psgi $jedi->start, sub {
	my $cb = shift;
	{
		my $res = $cb->(HEAD '/');
		is $res->code, 200, 'Base status is correct';
		is $res->content, 'Hello World !', '... and also the content';
	}
	{
		my $res = $cb->(GET '/');
		is $res->code, 200, 'Base status is correct';
		is $res->content, 'Hello World !', '... and also the content';
	}
	{
		my $res = $cb->(GET '/');
		is $res->code, 200, 'Base status is correct';
		is $res->content, 'Hello World !', '... and also the content';
	}
	{
		my $res = $cb->(GET '/404');
		is $res->code, 404, 'Base status is correct';
		is $res->content, 'No route found !', '... and also the content';
	}
};

my $jedi_admin = Jedi->new();
$jedi_admin->road('/admin', 't::lib::base');

test_psgi $jedi_admin->start, sub {
	my $cb = shift;
	{
		my $res = $cb->(GET '/');
		is $res->code, 500, 'Status of empty jedi is correct';
		is $res->content, 'No road found !', '... and also the content';
	}
};

my $jedi_bad_app = Jedi->new;
eval {
	$jedi_bad_app->road('/', 't::lib::badapp');
};
like $@, qr{t::lib::badapp is not a jedi app}, 'badapp is not a jedi app';

done_testing;