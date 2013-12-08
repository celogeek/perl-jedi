package Jedi::Launcher;

# ABSTRACT: Launcher for Jedi App

use Moo;
# VERSION
use MooX::Options
  authors => ['Celogeek <me@celogeek.com>'],
  synopsis => <<'__EOF__'

  jedi -c myApp.yml -c myAppProd.yml

In myApp.yml:

  Jedi:
    Roads:
      t::lib::configs::myConfigRoot: /
      t::lib::configs::myConfigAdmin: /admin

In myAppProd.yml:

  Plack:
    server: Starman
    env: production
  Starman:
    workers: 2
    port: 9999

__EOF__
;
use feature 'say';
use Config::Any;
use Jedi;
use Carp;
use Plack::Runner;
use lib ();

=attr config

config files to load

=cut

option 'config' => (
  is => 'ro',
  format => 's@',
  required => 1,
  short => 'c',
  doc => 'config files to load',
  isa => sub {
    my $files = shift;
    for my $file (@{$files}) {
      next if -f $file;
      __PACKAGE__->options_usage(1, "'$file' doesn't exist !\n");
    }
    return;
  }
);

=attr lib

Include directory before starting include

=cut

option 'lib' => (
  is => 'ro',
  format => 's@',
  short => 'I',
  doc => 'library to include',
  default => sub {[]},
);

=method run

load config, init jedi and plack and start your apps

=cut

sub run {
  my ($self) = @_;

  for my $lib(@{$self->lib}) {
	  lib->import($lib);
  }

  my $config = $self->parse_config;  
  my $jedi = $self->jedi_initialize($config);
  my ($runner, $options) = $self->plack_initialize($config);

  say "Loading : plackup ", join(" ", @$options);

  return $runner->run($jedi->start);
}

=method parse_config

load and merge all configs

=cut

sub parse_config {
  my ($self) = @_;

  my $config = Config::Any->load_files( { files => $self->config, use_ext => 1 } );
  my $config_merged = {};
  for my $c(map { values %$_ } @$config) {
      %$config_merged = (%$config_merged, %$c);
  }

  croak "Jedi section is missing" if !defined $config_merged->{Jedi};
  croak "Jedi/Roads section is missing" if !defined $config_merged->{Jedi}{Roads};
  croak "Jedi/Roads shoud be 'module: path'" if ref $config_merged->{Jedi}{Roads} ne 'HASH';

  return $config_merged;
}

=method jedi_initialize

initialize the jedi apps from configs

=cut

sub jedi_initialize {
  my ($self, $config) = @_;

  my $jedi = Jedi->new(config => $config);
  my %roads = %{$config->{Jedi}{Roads}};
  for my $module(keys %roads) {
    $jedi->road($roads{$module}, $module);
  }

  return $jedi;
}

=method plack_initialize

initialize the plack runner from the option in the configs

=cut

sub plack_initialize {
  my ($self, $config) = @_;

  my $plack_config = $config->{Plack} // {};
  my $server_config = $plack_config->{server} ? $config->{$plack_config->{server}} // {} : {};
  my @options = (
    ( map { "--" . $_ => $plack_config->{$_} } sort keys %$plack_config ),
    ( map { "--" . $_ => $server_config->{$_} } sort keys %$server_config ),
  );

  my $runner = Plack::Runner->new;

  $runner->parse_options(
    @options
  );

  return $runner, \@options;
}

1;

__END__

=head1 DESCRIPTION

This app load config files and start your jedi app.

=head SYNOPSIS

myBlog.yml:

  Jedi:
    Roads:
      Jedi::App::MiniCPAN::Doc: /
      Jedi::App::MiniCPAN::Doc::Admin: /admin
  Plack:
    env: production
    server: Starman
  Starman
    workers: 2
    port: 9999
  Jedi::App::MiniCPAN::Doc:
    path : /var/lib/minicpan

The Jedi is init with the roads inside the config.

The server plack is started using the config option. In that case it is equivalent to :

  plackup --env=production --server=Starman --workers=2 --port=9999 myjedi.psgi

Take a look at the L<plackup> option to see all possible config.
