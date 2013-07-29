package Jedi::Helpers::Hash;

# ABSTRACT: Jedi Helpers for Hash

use strict;
use warnings;

# VERSION

use Import::Into;
use Module::Runtime qw/use_module/;

=method import

Equivalent in your module to :

  use autobox HASH => Jedi::Helpers::Hash

=cut

sub import {
	my ($class) = @_;
	my $target = caller;
	use_module('autobox')->import::into($target, HASH => __PACKAGE__);
	return;
}

=method to_arrayref

Transform an headers form into an arrayref

Ex :

	{
		'X-Test' => [ "AAA" ],
		'Set-Cookie' => ["T1=1", "T2=2"],
	}

become

	[ 
		"X-Test", "AAA",
		"Set-Cookie", "T1=1",
		"Set-Cookie", "T2=2",
	]

=cut
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