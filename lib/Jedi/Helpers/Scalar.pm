package Jedi::Helpers::Scalar;
use strict;
use warnings;
use Import::Into;
use Module::Runtime qw/use_module/;

sub import {
	my ($class) = @_;
	my $target = caller;
	use_module('autobox')->import::into($target, SCALAR => __PACKAGE__);
	return;
}

sub full_path {
	my ($path) = @_;
	$path .= '/' if substr($path, -1) ne '/';
	return $path;
}

sub start_with {
	my ($path, $start) = @_;
	return substr($path, 0, length($start)) eq $start;
}

sub without_base {
	my ($path, $base) = @_;

	return substr(full_path($path), length(full_path($base)) - 1);
}

1;