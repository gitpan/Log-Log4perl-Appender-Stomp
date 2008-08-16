package Log::Log4perl::Appender::Stomp;

use warnings;
use strict;

use Net::Stomp;

our $VERSION = '0.0.1';

our @ISA = qw(Log::Log4perl::Appender);

sub new {
    my ($class, %options) = @_;

    my $self = {
        'name'       => "unknown name" || $options{'name'},
        'hostname'   => "localhost"    || $options{'hostname'},
        'port'       => 61613          || $options{'port'},
        'topic_name' => "log"          || $options{'topic_name'},
        'connection' => undef,
        %options
    };

    bless($self, $class);

    return $self;
}

sub log {
    my ($self, %params) = @_;

    my $stomp = $self->{'connection'};

    unless ($stomp) {

        $stomp = Net::Stomp->new(
            {
                'hostname' => $self->{'hostname'},
                'port'     => $self->{'port'}
            }
        );

        unless ($stomp->connect({ 'login' => "noauth", 'passcode' => "supportyet" })) {
            die("Connection to ", $self->{'hostname'}, ":", $self->{'port'}, " failed: $!");
        }

        $self->{'connection'} = $stomp;
    }

    return $stomp->send(
        {
            'destination' => sprintf("/topic/%s", $self->{'topic_name'}),
            'body'        => $params{'message'}
        }
    );
}

sub DESTROY {
    my ($self) = @_;

    if ($self->{'connection'}) {
        $self->{'connection'}->disconnect();
    }
}

1;

__END__

=head1 NAME

Log::Log4perl::Appender::Stomp - Log messages via STOMP

=head1 VERSION

Version 0.0.1

=head1 SYNOPSIS

    use Log::Log4perl;

    # Default options are in $conf
    my $conf = qq(
        log4perl.category = WARN, STOMP

        log4perl.appender.STOMP                          = Log::Log4perl::Appender::Stomp
        log4perl.appender.STOMP.hostname                 = localhost
        log4perl.appender.STOMP.port                     = 61613
        log4perl.appender.STOMP.topic_name               = log
        log4perl.appender.STOMP.layout                   = PatternLayout
        log4perl.appender.STOMP.layout.ConversionPattern = %d %-5p %m%n
    );

    Log::Log4perl::init(\$conf);

    Log::Log4perl->get_logger("blah")->debug("...");

=head1 DESCRIPTION

This allows you to send log messages via the Streaming Text Orientated Messaging
Protocol to a message broker that supports STOMP, such as Apache's ActiveMQ.

This makes use of topics in ActiveMQ so that multiple consumers can receive the
log messages from multiple producers. It takes a similar approach as syslog
does but uses ActiveMQ to do the message handling.

=head1 CONFIGURATION AND ENVIRONMENT

You can change:

=over

=item hostname

=item port

=item topic_name

=back

In the Log::Log4perl configuration.

=head1 DEPENDENCIES

=over

=item Log::Log4perl

=item Net::Stomp

=item ActiveMQ

=back

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-log-log4perl-appender-stomp@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Adam Flott  C<< <adam@npjh.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Adam Flott C<< <adam@npjh.com> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
