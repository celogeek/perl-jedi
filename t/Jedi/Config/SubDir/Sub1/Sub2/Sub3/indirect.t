#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Module::Runtime qw/use_module/;
use Path::Class;
use FindBin qw/$Bin/;

{
	my $indirect = use_module('t::lib::Config::App')->new;
	is $indirect->jedi_env, 'development', 'env by default is development';
	is_deeply $indirect->jedi_config, {
		direct => 2,
		conf => 'dev',
	}, 'dev conf loaded';
	is $indirect->jedi_app_root, dir($Bin)->parent->parent->parent, '... and the root app is at the same place';
	is_deeply $indirect->jedi_config_files, [
		file(dir($Bin)->parent->parent->parent, 'config.yml'),
		file(dir($Bin)->parent->parent->parent, 'environments', 'development.yml')
	], '... the conf found is correct';
}

for my $env_name(qw/JEDI_ENV PLACK_ENV/) {
	{
		local $ENV{$env_name} = 'prod';
		my $indirect = use_module('t::lib::Config::App')->new;
		is $indirect->jedi_env, 'prod', 'env is now prod';
		is_deeply $indirect->jedi_config, {
			direct => 1,
		}, 'prod conf loaded';
		is $indirect->jedi_app_root, dir($Bin)->parent->parent->parent, '... and the root app is at the same place';
		is_deeply $indirect->jedi_config_files, [
			file(dir($Bin)->parent->parent->parent, 'config.yml'),
		], '... the conf found is correct';
	}
	
	{
		local $ENV{$env_name} = 'test';
		my $indirect = use_module('t::lib::Config::App')->new;
		is $indirect->jedi_env, 'test', 'env is now prod';
		is_deeply $indirect->jedi_config, {
			direct => 1,
			conf => 'test',
		}, 'test conf loaded';
		is $indirect->jedi_app_root, dir($Bin)->parent->parent->parent, '... and the root app is at the same place';
		is_deeply $indirect->jedi_config_files, [
			file(dir($Bin)->parent->parent->parent, 'config.yml'),
			file(dir($Bin)->parent->parent->parent, 'environments', 'test.yml')
		], '... the conf found is correct';
	}
}

done_testing;