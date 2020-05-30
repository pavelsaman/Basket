package Category;

use strict;
use warnings;
use Class::Std;
use Hash::Util qw(hash_value);

our $VERSION = 0.001;

{
    my %name :ATTR( :get<name> );

    sub BUILD {
        my ($self, $ident, $args_ref) = @_;

        $name{$ident} = $args_ref->{name};                  

        return;
    }        
}

1;

__END__