package Email;

use strict;
use warnings;
use Readonly;
use Class::Std;
use Carp qw(croak);
use List::MoreUtils qw(any);
use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP;

our $VERSION = 0.001;

{
    Readonly my $subject => "Basket - shopping list";

    my %server   :ATTR;
    my %port     :ATTR;
    my %security :ATTR;
    my %user     :ATTR;
    my %sender   :ATTR;
    my %pwd      :ATTR;

    sub BUILD {
        my ($self, $ident, $args_ref) = @_;

        $server{$ident}   = $ENV{BASKET_SERVER};
        $port{$ident}     = $ENV{BASKET_PORT};
        $security{$ident} = $ENV{BASKET_SECURITY};
        $user{$ident}     = $ENV{BASKET_USER};
        $sender{$ident}   = $ENV{BASKET_SENDER};
        $pwd{$ident}      = $ENV{BASKET_PWD};

        if (any { not defined $_ } ($server{$ident}, $port{$ident}, 
            $security{$ident}, $user{$ident}, $sender{$ident}, $pwd{$ident})) {
            croak __PACKAGE__ . "::new(): email information not configured.";
        }

        return;
    }

    sub send_email {
        my $self     = shift;
        my $args_ref = shift;

        if (not defined $args_ref->{recipient}) {
            croak __PACKAGE__ . "send_email(): no recipient.";
        }
        if (not defined $args_ref->{shopping_list}) {
            croak __PACKAGE__ . "send_email(): no shopping list.";
        }
        
        my $transport = Email::Sender::Transport::SMTP->new({
            host          => $server{ident $self},
            ssl           => $security{ident $self},
            port          => $port{ident $self},
            sasl_username => $user{ident $self},
            sasl_password => $pwd{ident $self}
        });

        my $email = Email::Simple->create(
            header => [
                To      => $args_ref->{recipient},
                From    => $sender{ident $self},
                Subject => $subject
            ],
            body => $args_ref->{shopping_list},
        );

        sendmail($email, { transport => $transport });
    }
}

1;