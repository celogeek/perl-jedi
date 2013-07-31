#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Module::Runtime qw/use_module/;

{
	my $indirect = use_module('t::lib::Config::App')->new;
	is $indirect->jedi_env, 'development', 'env by default is development';
	is_deeply $indirect->jedi_config, {
		direct => 2,
		conf => 'dev',
	}, 'dev conf loaded';
}

{
	local $ENV{JEDI_ENV} = 'prod';
	my $indirect = use_module('t::lib::Config::App')->new;
	is $indirect->jedi_env, 'prod', 'env is now prod';
	is_deeply $indirect->jedi_config, {
		direct => 1,
	}, 'prod conf loaded';
}

{
	local $ENV{JEDI_ENV} = 'test';
	my $indirect = use_module('t::lib::Config::App')->new;
	is $indirect->jedi_env, 'test', 'env is now prod';
	is_deeply $indirect->jedi_config, {
		direct => 1,
		conf => 'test',
	}, 'test conf loaded';
}

done_testing;