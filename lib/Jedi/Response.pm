package Jedi::Response;
use Moo;
use Jedi::Helpers::Hash;

has 'status' => (is => 'rw', default => sub{404});

has 'headers' => (is => 'ro', default => sub{{}});

sub set_header {
	my ($self, $header_name, $header_value) = @_;
	$self->headers->{$header_name} = [$header_value];
	return;
}

sub push_header {
	my ($self, $header_name, $header_value) = @_;
	if (exists $self->headers->{$header_name}) {
		push @{$self->headers->{$header_name}}, $header_value;
	} else {
		$self->set_header($header_name, $header_value);
	}
	return;
}

has 'body' => (is => 'rw', default => sub{''});

sub to_psgi {
	my ($self) = @_;

	$self->body('No route found !') if $self->status == 404 && ! length($self->body);

	return [$self->status, $self->headers->to_arrayref, [$self->body]];
}

1;