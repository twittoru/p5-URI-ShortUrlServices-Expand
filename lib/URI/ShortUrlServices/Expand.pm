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
        tinyurl => Regexp::Assemble->new,
        http => HTTP::Lite->new,
    }, $class;

    $self->{http}->http11_mode(1);
    $self->{http}->method('HEAD');
    $self->{http}->add_req_header('User-Agent', "HTTP::Lite/$HTTP::Lite::VERSION URI::ReURL ver:$VERSION");

    defined($source) ? $self->_get_shortservies_from_url($source) : $self->_get_shortservies_from_wedata;

    $self;
}

sub _get_shortservies_from_url{
    use JSON;
    my $self = shift;
    my $url = shift;

    $self->{http}->method('GET');
    my $res = $self->{http}->request($url)
        or die "Unabel to get ShortUrlServices: $!";
    $self->{http}->method('HEAD');

    if (my $content = $self->{http}->body())
    {
        for my $row ( @{ from_json( $content ) } )
        {
            $self->{tinyurl}->add($row->{data}->{domain});
        }
    }
}

sub _get_shortservies_from_wedata {
    use WebService::Wedata;
    my $self = shift;

    my $wedata = WebService::Wedata->new;
    my $db = $wedata->get_database('ShortUrlServices');
    foreach my $item (@{$db->get_items}){
        $self->{tinyurl}->add($item->{data}->{domain});
    }
}

sub expand {
    my ($self,$url) = @_;
    while (defined ($self->{tinyurl}->match($url)))
    {
        my $req = $self->{http}->request($url) or return;
        last unless defined $self->{http}->get_header('Location');
        $url = @{$self->{http}->get_header('Location')}[0];
    }
    $url;
}

1;
