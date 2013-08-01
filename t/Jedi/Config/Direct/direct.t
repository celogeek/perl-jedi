#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Module::Runtime qw/use_module/;
use Path::Class;
use FindBin qw/$Bin/;

{
	my $direct = use_module('t::lib::Config::App')->new;
	is $direct->jedi_env, 'development', 'env by default is development';
	is_deeply $direct->jedi_config, {
		direct => 2,
		conf => 'dev',
	}, 'dev conf loaded';
	is $direct->jedi_app_root, $Bin, '... and the root app is at the same place';
	is_deeply $direct->jedi_config_files, [
		file($Bin, 'config.yml'),
		file($Bin, 'environments', 'development.yml')
	], '... the conf found is correct';
}

for my $env_name(qw/JEDI_ENV PLACK_ENV/) {

	{
		local $ENV{$env_name} = 'prod';
		my $direct = use_module('t::lib::Config::App')->new;
		is $direct->jedi_env, 'prod', 'env is now prod';
		is_deeply $direct->jedi_config, {
			direct => 1,
		}, 'prod conf loaded';
		is $direct->jedi_app_root, $Bin, '... and the root app is at the same place';
		is_deeply $direct->jedi_config_files, [
			file($Bin, 'config.yml'),
		], '... the conf found is correct';
	}
	
	{
		local $ENV{$env_name} = 'test';
		my $direct = use_module('t::lib::Config::App')->new;
		is $direct->jedi_env, 'test', 'env is now prod';
		is_deeply $direct->jedi_config, {
			direct => 1,
			conf => 'test',
		}, 'test conf loaded';
		is $direct->jedi_app_root, $Bin, '... and the root app is at the same place';
		is_deeply $direct->jedi_config_files, [
			file($Bin, 'config.yml'),
			file($Bin, 'environments', 'test.yml')
		], '... the conf found is correct';
	}

}

done_testing;