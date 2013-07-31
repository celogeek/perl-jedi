#!perl
use Test::Most 'die';
use HTTP::Request::Common;
use Plack::Test;
use Module::Runtime qw/use_module/;

my $noconf = use_module('t::lib::Config::App')->new;
is $noconf->jedi_env, 'development', 'env by default is development';
is_deeply $noconf->jedi_config, {}, 'no conf has no config';

done_testing;