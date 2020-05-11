package Basket;

use strict;
use warnings;
use Readonly;
use Class::Std;
use Carp qw(croak);
use Item 0.001;
use Category 0.001;

our $VERSION = 0.001;

{
    sub not_saved :PRIVATE { not $_[0] };

    my %dir    :ATTR( :get<dir> );
    my %basket :ATTR;

    sub BUILD {
        my ($self, $ident, $args_ref) = @_;

        if (not defined $args_ref->{dir}) {
            croak __PACKAGE__ . "::new(): no dir";
        }

        $dir{$ident}    = $args_ref->{dir};
        $basket{$ident} = {};    
  
        $self->_parse_files();

        return;
    }  

    sub _parse_files :PRIVATE {
        my $self = shift;

        opendir my $basket_dir, $dir{ident $self};

        BASKET_FILE:
        while (my $cat_file = readdir $basket_dir) {
            next BASKET_FILE if -d $cat_file;                       

            my $new_category = Category->new({ name => $cat_file });               
            $basket{ident $self}->{
                $new_category->get_name()}->{obj} = $new_category;
            $basket{ident $self}->{$new_category->get_name()}->{items}
                    = $self->_get_lines($cat_file);            
        }

        closedir $basket_dir;
    }

    sub _get_lines :PRIVATE {
        my $self     = shift;
        my $cat_file = shift;        

        open my $basket_file, q{<}, $cat_file or return;

        my $items = {};
        LINE:
        while (my $line = <$basket_file>) {
            chomp $line;            
            my @parts = split /;/, $line;
            $parts[0] =~ s{"}{}g;

            next LINE if $parts[0] eq q{};
            next LINE if $parts[1] eq q{};

            my $item = Item->new({
                text => $parts[0],
                added => $parts[1]
            });

            $items->{$item->get_hash()} = $item;            
        }

        close $basket_file;

        return $items;
    }   

    sub get_all_categories {
        my $self = shift;
    }

    sub get_all_items {
        my $self = shift;        
    }

    sub get_all_category_names {
        my $self = shift;
        
    } 

    sub get_all_item_texts {
        my $self = shift;
    }
}

1;

__END__