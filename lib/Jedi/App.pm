package Jedi::App;

# ABSTRACT: Jedi App

=head1 DESCRIPTION

This module allow you to define apps. Apps is plug above roads, and with receive the end of the path (without the road).

You can reused easily apps, like admin panel, or anything, and plug it into any based road you want.

	package MyApps;

	use Jedi::App;
	use JSON;

	sub jedi_apps {
		my ($jedi) = @_;

		$jedi->get('/', $jedi->can('index'));
		$jedi->get('/env', $jedi->can('display_env'));
		$jedi->get(qr{/aaa/}, $jedi->can('aaa'));

		return;
	}

	sub index {
		my ($jedi, $request, $response) = @_;
		$response->status("200");
		$response->body("Hello World !");
		return 1;
	}

	sub display_env {
		my ($jedi, $request, $response) = @_;
		$response->status('200');
		$response->body(to_json($request->env));
		return 1;
	}

	sub aaa {
		my ($jedi, $request, $response) = @_;
		$response->status(200);
		$response->body("AAA !");
	}

	1;

If this is plug with :

	$jedi->road('/test');

This will return :

	/test      # Hello World !
	/test/     # Hello World !
	/test/env  # JSON of env variables
	/test/env/ # JSON of env variables

And also the regexp works

	/test/helloaaaworld # AAA !

=cut

use strict;
use warnings;

# VERSION

use Import::Into;
use Module::Runtime qw/use_module/;


=method import

This module is equivalent into your package to :

	package MyApps;
	use Moo;
	with "Jedi::Role::App";

=cut
sub import {
	my ($class) = @_;
	my $target = caller;
	use_module('Moo')->import::into($target);
	$target->can('with')->('Jedi::Role::App');

	return;
}

1;
