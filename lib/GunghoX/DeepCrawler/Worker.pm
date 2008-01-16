# $Id: /mirror/perl/GunghoX-DeepCrawler/trunk/lib/GunghoX/DeepCrawler/Worker.pm 39021 2008-01-16T16:36:40.809573Z daisuke  $

package GunghoX::DeepCrawler::Worker;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use POE;
use Gungho;
use Gungho::Request;
use Swarmage::Task;

__PACKAGE__->mk_accessors($_) for qw(worker url);

sub new
{
    my $class = shift;
    my $self  = $class->SUPER::new({ @_ });

    Gungho->run( $self->_gen_config() );
    $self;
}

sub _gen_config
{
    my $self = shift;

    # Setup the sessions here.
    {
        engine => {
            module => 'POE',
            config => {
                kernel_start => 0,
                loop_delay => 120
            }
        },
        follow_links => {
            parsers => [
                { 
                    module => 'HTML',
                    config => {
                        merge_rule => 'ALL',
                        filters => [
                            {
                                module => 'Strip',
                            }
                        ],
                        rules => [
                            {
                                module => 'HTML::SelectedTags',
                                config => {
                                    tags => [ 'a' ]
                                }
                            },
                            {
                                module => 'Fresh',
                                config => {
                                    storage => {
                                        module => "Cache",
                                        config => {
                                            cache => {
                                                module => "Cache::Memcached::LibMemcached",
                                                config => {
                                                    hashref => 1,
                                                    servers => [ qw(127.0.0.1:11211) ]
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            {
                                module => 'URI',
                                config => {
                                    match => [
                                        {
                                            action => 'FOLLOW_ALLOW',
                                            action_nomatch => 'FOLLOW_DENY',
                                            url => $self->url,
                                        }
                                    ]
                                }
                            }
                        ]
                    }
                }
            ]
        },
        provider => {
            module => '+GunghoX::DeepCrawler::Provider',
            config => {
                worker => $self->worker,
                queue => $self->worker->queue
            }
        },
        components => [ qw(
            +GunghoX::FollowLinks
            Throttle::Domain
        ) ],
        throttle => {
            domain => {
                max_items => 10,
                interval  => 5
            }
        },
        handler  => sub {
            my ($self, $c, $req, $res) = @_;

warn $req->uri;
            my $spec = $req->notes('spec');
            my $task = $req->notes('task');
            $spec->{task} = $task;

            $c->follow_links($res);
            $poe_kernel->post($spec->{session}, $spec->{event}, $spec);
        }
    };
}

sub work
{
    my ($self, $spec, $task) = @_;

    my $req = $task->data;
    $req->notes(task => $task);
    $req->notes(spec => $spec);
    Gungho->send_request( $req );
}

1;