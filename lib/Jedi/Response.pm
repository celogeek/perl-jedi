package Jedi::Response;

# ABSTRACT: response object

=head1 DESCRIPTION

This is the response you will have to fill from route to route.

=cut

use Moo;

# VERSION

use Jedi::Helpers::Hash;

=attr status

Status code, by default is 404 (not found).

You can consult the L<HTTP status|http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html> but here some common :

 500: internal server error
 404: route not found
 405: access forbidden
 204: no content
 200: status ok, with content
 302: redirect
 301: permanent redirect

=cut

has 'status' => (is => 'rw', default => sub{404});

=attr headers

This contain the headers you will send with your response.

You should use the method L</set_header> and L</push_header> instead of filling this attribute directly.

The attribute has this form :

 key => [val1, val2 ...],
 key2 => [val4],

=cut
has 'headers' => (is => 'ro', default => sub{{}});

=method set_header

Set an header to a specific value.

 $response->set_header('X-AUTH', $token);
 $response->set_header('Location', 'http://blog.celogeek.com');

=cut
sub set_header {
  my ($self, $header_name, $header_value) = @_;
  $self->headers->{$header_name} = [$header_value];
  return;
}

=method push_header

Push an header to a specific value

 $response->push_header('Set-Cookie', 'myCookie=a');
 $response->push_header('Set-Cookie', 'myCookie2=b');

You will see :

 Set-Cookie: myCookie=a
 Set-Cookie: myCookie=b

=cut
sub push_header {
  my ($self, $header_name, $header_value) = @_;
  if (exists $self->headers->{$header_name}) {
    push @{$self->headers->{$header_name}}, $header_value;
  } else {
    $self->set_header($header_name, $header_value);
  }
  return;
}

=attr body

The body is the string return to the browser.

 $response->body("Hello World !");

=cut
has 'body' => (is => 'rw', default => sub{''});


=method to_psgi

This return the content in a psgi form.

It is use by Jedi to transform the response into a valid psgi response.

=cut
sub to_psgi {
  my ($self) = @_;

  $self->body('No route found !') if $self->status == 404 && ! length($self->body);

  return [$self->status, $self->headers->to_arrayref, [$self->body]];
}

1;