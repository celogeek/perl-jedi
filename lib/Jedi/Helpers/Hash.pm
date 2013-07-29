package Jedi::Helpers::Hash;
use strict;
use warnings;
use Import::Into;
use Module::Runtime qw/use_module/;

sub import {
	my ($class) = @_;
	my $target = caller;
	use_module('autobox')->import::into($target, HASH => __PACKAGE__);
	return;
}

sub to_arrayref {
	my ($headers) = @_;
	my @res;
	for my $k(keys %$headers) {
		for my $v(@{$headers->{$k}}) {
			push @res, $k, $v;
		}
	}
	return \@res;
}

1;