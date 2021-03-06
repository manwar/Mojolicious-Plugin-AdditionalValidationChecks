use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Mojo::Util qw(url_escape);

plugin 'AdditionalValidationChecks';

get '/' => sub {
  my $c = shift;

  my $validation = $c->validation;
  my $params     = $c->req->params->to_hash;

  $validation->input( $params );
  $validation->required( 'check' )->between( $params->{min}, $params->{max} );

  my $result = $validation->has_error() ? 0 : 1;
  $c->render(text => $result );
};

my %words = (
    '2'  => [ 0, 5, 1 ],
    'a'  => [ 'a', 'b', 1 ],
    '3'  => [ 5, 8, 0 ],
    'a'  => [ 'b', 'z', 0 ],
);

my $t = Test::Mojo->new;
for my $word ( keys %words ) {
    my $esc = url_escape( $word );
    my ($min, $max, $res)  = @{ $words{$word} };
    $t->get_ok('/?check=' . $esc . '&min=' . $min . '&max=' . $max)
      ->status_is(200)->content_is( $res, "Check: $word // $min // $max" );
}

done_testing();
