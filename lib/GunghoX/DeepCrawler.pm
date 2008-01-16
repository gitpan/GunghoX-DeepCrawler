# $Id: /mirror/perl/GunghoX-DeepCrawler/trunk/lib/GunghoX/DeepCrawler.pm 39023 2008-01-16T16:38:51.640916Z daisuke  $
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package GunghoX::DeepCrawler;
use strict;
use warnings;
use Swarmage;
use Gungho::Request;
use GunghoX::DeepCrawler::Worker;
use GunghoX::DeepCrawler::Provider;
our $VERSION = '0.00001';

sub run
{
    my $class = shift;
    my %args  = @_;

    my $drone = Swarmage::Drone->new(
        queue => {
            module => "BerkeleyDB",
        },
        workers => {
            crawler => [
                ({
                    backend => "+GunghoX::DeepCrawler::Worker",
                    url => $args{url},
                }) x 1
            ]
        }
    );
    $drone->queue->enqueue(
        Swarmage::Task->new(
            type => "crawler",
            data => Gungho::Request->new( GET => $args{url} )
        )
    );

    POE::Kernel->run;
}


1;

__END__

=head1 NAME

GunghoX::DeepCrawler - Crawls Within The Same Host

=head1 SYNOPSIS

  gunghox-deepcrawler.pl http://example.com/

=head1 DESCRIPTION

I wanted to use Gungho, GunghoX::FollowLinks, and Swarmage together. That's
all. This is a toy. You can't tweak the knobs without looking into the
source code. 

=head1 AUTHOR

Copyright (c) 2008 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut