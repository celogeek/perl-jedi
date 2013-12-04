package Jedi::Launcher;

# ABSTRACT: Launcher for Jedi App

use Moo;
# VERSION
use MooX::Options authors => ['Celogeek <me@celogeek.com>'];
use feature 'say';
use Config::Any;
use Carp;

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

sub run {
  my ($self) = @_;
  for my $config(@{$self->config}) {
    say "Loading config $config ...";
  }
  exit(0);
}

1;

__END__

=head1 DESCRIPTION

This app load config files and start your jedi app.

=head SYNOPSIS

myBlog.yml:

  Jedi:
    Roads:
      Jedi::App::MiniCPAN::Doc : /
      Jedi::App::MiniCPAN::Doc::Admin : /admin
  Plack:
    environment: production
    server: Starman
    server_options:
      workers: 2
      port: 9999

=cut