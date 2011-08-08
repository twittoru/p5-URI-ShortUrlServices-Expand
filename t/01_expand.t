use strict;
use Test::More;

unless ( online() ) {
    plan skip_all => 'Network access required for tests';
}

plan tests => 4;

use URI::ShortUrlServices::Expand;

my($exp, $url);

## Test get shortservie data from JSON.
$exp = URI::ShortUrlServices::Expand->new(
    "http://wedata.net/databases/ShortUrlServices/items.json"
);
ok($exp);

## Test get shortservie data from Wedata API.
$exp = URI::ShortUrlServices::Expand->new();
ok($exp);

# Test expand of "bit.ly" resource.
$url = $exp->expand( 'http://bit.ly/n9wIfh' );
ok($url);
is($url,"https://github.com/twittoru/p5-URI-ShortUrlServices-Expand");

sub online {
    my $ua = LWP::UserAgent->new( env_proxy => 1, timeout => 30 );
    my $res = $ua->get( 'http://google.com/' );
    return $res->is_success ? 1 : 0;
}
