package Jedi::Helpers::Scalar;

# ABSTRACT: Jedi Helpers for Scalar

use strict;
use warnings;

# VERSION

use Import::Into;
use Module::Runtime qw/use_module/;

=method import

Equivalent in your module to :

  use autobox SCALAR => Jedi::Helpers::Scalar

=cut
sub import {
	my $target = caller;
	use_module('autobox')->import::into($target, SCALAR => __PACKAGE__);
	return;
}

=method full_path

Add a trailing "/" to your path :

	"/env"->full_path # /env/

=cut	
sub full_path {
	my ($path) = @_;
	$path .= '/' if substr($path, -1) ne '/';
	return $path;
}

=method start_with

Check if a path start with the value in param :

	"/env/test"->start_with("/env") # true

=cut	
sub start_with {
	my ($path, $start) = @_;
	return substr($path, 0, length($start)) eq $start;
}

=method without_base

Remove from the path, the base pass in params :

	"/env/test"->without_base("/env") # /test/
	"/env/test"->without_base("/env") # /test/

=cut
sub without_base {
	my ($path, $base) = @_;

	return substr(full_path($path), length(full_path($base)) - 1);
}

1;