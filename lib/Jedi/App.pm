package Jedi::App;
use strict;
use warnings;
use Import::Into;
use Module::Runtime qw/use_module/;

sub import {
	my ($class) = @_;
	my $target = caller;
	use_module('Moo')->import::into($target);
	$target->can('with')->('Jedi::Role::App');

	return;
}

1;
