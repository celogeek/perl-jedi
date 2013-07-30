#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Jedi;

{
	my $jedi = Jedi->new();
	$jedi->road('/', 't::lib::advanced');
	
	test_psgi $jedi->start, sub {
		my $cb = shift;
		{
			my $res = $cb->(GET '/');
			is $res->code, 200, 'status root is correct';
			is $res->content, 'Hello World !', '... and content is correct';
		}
		{
			my $res = $cb->(GET '/test/me/hello_aaa_world');
			is $res->code, 200, 'status regexp is correct';
			is $res->content, 'aaa', '... and content is correct';
		}
		{
			my $res = $cb->(GET '/test/me/hello_aaaa_world');
			is $res->code, 200, 'status regexp is correct';
			is $res->content, 'aaa,aaaa', '... and content is correct';
		}
	};
}

{
	my $bad_method = Jedi->new();
	eval { $bad_method->road('/', 't::lib::BadRoute::BadMethod') };
	like $@, qr{method invalid : only support GET/POST/PUT/DELETE !}, 'method invalid';
}
{
	my $bad_method = Jedi->new();
	eval { $bad_method->road('/', 't::lib::BadRoute::BadPath') };
	like $@, qr{path invalid !}, 'path invalid';
}
{
	my $bad_method = Jedi->new();
	eval { $bad_method->road('/', 't::lib::BadRoute::BadSub') };
	like $@, qr{sub invalid !}, 'sub invalid';
}

{
	my $bad_method = Jedi->new();
	eval { $bad_method->road('/', 't::lib::BadRoute::BadMissing') };
	like $@, qr{sub invalid !}, 'sub invalid';
}

{
	my $jedi = Jedi->new();
	$jedi->road('/', 't::lib::missing');
	
	test_psgi $jedi->start, sub {
		my $cb = shift;
		{
			my $res = $cb->(GET '/');
			is $res->code, 200, 'route is correct';
			is $res->content, 'hello world !', '... and content also';
		}
		for my $p(qw{
			/test
			/test/me
			/test/me?a=1
		}
		) {
			my $res = $cb->(GET $p);
			is $res->code, 200, 'missing status is correct';
			my $r = $p;
			$r =~ s/\?.*//;
			$r .= '/';
			is $res->content, 'missing : ' . $r, '... and also the content';
		}
	};
}

done_testing;