package Jedi::Role::Config;

# ABSTRACT: Easy load of config file by env

=head1 DESCRIPTION

We will try to load the config into the current directory and try all parents.

The sub env is loaded using the jedi_env.

Ex: 

  PLACK_ENV = test

Load
  config.*
  environments/test.*

The config is merged together, so the "test" file replace keys from the main config.

Ex:

  config.yml

     test: 1
     hello: 2

  environments/test.yml

     test: 2
     world: 1

The jedi_config is set to :

   {
	 test => 2,
	 hello => 2,
	 world => 1,
   }

=cut

use Moo::Role;
use Path::Class;
use FindBin qw/$Bin/;
use Config::Any;

has 'jedi_env' => (is => 'lazy', clearer => 1);
sub _build_jedi_env {
    return $ENV{'JEDI_ENV'} // $ENV{'PLACK_ENV'} // 'development';
}

has 'jedi_config' => (is => 'lazy', clearer => 1);

sub _build_jedi_config {
	my ($self) = @_;

	my $env = $self->jedi_env;
	FindBin::again();

	my $curdir = dir($Bin);
	my $main_file = "config";
	my $env_file = "" . file('environments', $env);

	my @files;
	while($curdir ne '/') {
		for my $ext (Config::Any->extensions) {
			my $full_main_file = file($curdir, $main_file . '.' .$ext);
			my $full_env_file = file($curdir, $env_file . '.' . $ext);
			push @files, $full_main_file if -f $full_main_file;
			push @files, $full_env_file if -f $full_env_file;
			last if @files;
		}
		last if @files;
		$curdir = $curdir->parent;
	}
	return {} if !@files;

    my $config = Config::Any->load_files( { files => \@files, use_ext => 1 } );
    my $config_merged = {};
    for my $c(map { values %$_ } @$config) {
        %$config_merged = (%$config_merged, %$c);
    }
    return $config_merged;

}

1;