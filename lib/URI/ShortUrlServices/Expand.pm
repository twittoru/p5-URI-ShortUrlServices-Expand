package URI::ShortUrlServices::Expand;

use strict;
use warnings;
use HTTP::Lite;
use Regexp::Assemble;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $source = shift;
    my $self = bless {
        _re => Regexp::Assemble->new,
        _http => HTTP::Lite->new,
    }, $class;

    $self->{_http}->http11_mode(1);
    $self->{_http}->method('HEAD');
    $self->{_http}->add_req_header('User-Agent', "HTTP::Lite/$HTTP::Lite::VERSION URI::ReURL ver:$VERSION");

    defined($source) ? $self->_get_shortservies_from_url($source) : $self->_get_shortservies_from_wedata;

    $self;
}

sub _get_shortservies_from_url{
    use JSON;
    my $self = shift;
    my $url = shift;

    $self->{_http}->method('GET');
    my $res = $self->{_http}->request($url)
        or die "Unabel to get ShortUrlServices: $!";

    if (my $content = $self->{_http}->body())
    {
        for my $row ( @{ from_json( $content ) } )
        {
            $self->{_re}->add($row->{data}->{domain});
        }
    }

    $self->{_http}->reset();
}

sub _get_shortservies_from_wedata {
    use WebService::Wedata;
    my $self = shift;

    my $wedata = WebService::Wedata->new;
    my $db = $wedata->get_database('ShortUrlServices');
    foreach my $item (@{$db->get_items}){
        $self->{_re}->add($item->{data}->{domain});
    }
}

sub expand {
    my ($self,$url) = @_;

    $self->{_http}->method('HEAD');

    while (defined ($self->{_re}->match($url)))
    {
        my $req = $self->{_http}->request($url) or return;
        last unless defined $self->{_http}->get_header('Location');
        $url = @{$self->{_http}->get_header('Location')}[0];
    }

    $self->{_http}->reset();

    $url;
}

1;
