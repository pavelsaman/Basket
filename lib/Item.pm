package Item;

use strict;
use warnings;
use Readonly;
use DateTime;
use Class::Std;
use Hash::Util qw(hash_value);

our $VERSION = 0.002;

{
    Readonly my $year_part  => 0;
    Readonly my $month_part => 1;
    Readonly my $day_part   => 2;
    Readonly my $delimeter  => q{-};

    sub TRUE  :PRIVATE { 1 };   
    sub FALSE :PRIVATE { 0 };   

    my %text         :ATTR( :get<text>     );
    my %added        :ATTR( :get<added_on> );
    my %hash_value   :ATTR( :get<hash>     );
    my %quantity     :ATTR( :get<quantity> );

    sub BUILD {
        my ($self, $ident, $args_ref) = @_;

        $text{$ident}       = $args_ref->{text};
        $added{$ident}      = $args_ref->{added};
        $quantity{$ident}   = $args_ref->{quantity};

        $hash_value{$ident} = hash_value(
            join q{}, $text{$ident}, $added{$ident}, $quantity{$ident}
        );

        return;
    }

    sub _split_date :PRIVATE {
        my $self = shift;
        my $part = shift;

        return (split /$delimeter/, $added{ident $self})[$part];
    }

    sub increase_quantity {
        my $self = shift;

        $quantity{ident $self} += 1;
        return;
    }

    sub set_added_on {
        my $self         = shift;
        my $new_added_on = shift;

        $added{ident $self} = $new_added_on;
        return;
    }

    sub get_year {
        my $self = shift;

        return $self->_split_date($year_part);
    }

    sub get_month {
        my $self = shift;

        return $self->_split_date($month_part);
    }

    sub get_day {
        my $self = shift;

        return $self->_split_date($day_part);
    }

    sub _get_datetime_obj {        
        my @date = split /$delimeter/, shift;        

        return DateTime->new(
            year  => $date[0],
            month => $date[1],
            day   => $date[2]
        );
    }

    sub _compare_date :PRIVATE {
        my $self = shift;
        my $date = shift;            

        my $datetime = _get_datetime_obj($date);
        return DateTime->compare(                
            _get_datetime_obj($added{ident $self}),
            $datetime
        );
    }

    sub is_newer_than {
        my $self = shift;
        my $date = shift;     

        if ($self->_compare_date($date) == 1) {
            return TRUE;
        }   

        return;
    }

    sub is_older_than {
        my $self = shift;
        my $date = shift;               

        if ($self->_compare_date($date) == -1) {
            return TRUE;
        }   

        return;
    }

    sub is_created_at {
        my $self = shift;
        my $date = shift;               

        if (not defined $self->is_newer_than($date)
            and not defined $self->is_older_than($date)) {
            return TRUE;
        }   

        return;
    }
}

1;

__END__