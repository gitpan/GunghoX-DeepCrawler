# $Id: /mirror/perl/GunghoX-DeepCrawler/trunk/lib/GunghoX/DeepCrawler/Provider.pm 39021 2008-01-16T16:36:40.809573Z daisuke  $

package GunghoX::DeepCrawler::Provider;
use strict;
use warnings;
use base qw(Gungho::Provider);

sub dispatch
{
#    my $self = shift;
#    POE::Kernel->post( $self->config->{worker}->session_id, 'pump_queue' )
#        or die;
    1;
}

sub pushback_request
{
    my ($self, $c, $request) = @_;

    $self->config->{queue}->enqueue(
        Swarmage::Task->new(
            type => "crawler",
            data => $request,
        )
    );
    POE::Kernel->post( $self->config->{worker}->session_id, 'pump_queue' );
}

1;
