#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Module::Runtime qw/use_module/;
use FindBin qw/$Bin/;
use Path::Class;

my $noconf = use_module('t::lib::Config::App')->new;
is $noconf->jedi_env, 'development', 'env by default is development';
is_deeply $noconf->jedi_config, {}, 'no conf has no config';
is $noconf->jedi_app_root, dir($Bin), 'no conf, root app is the path of the script';
is_deeply $noconf->jedi_config_files, [], 'no conf files';

done_testing;