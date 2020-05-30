package Basket;

use strict;
use warnings;
use Readonly;
use DateTime;
use Class::Std;
use Carp qw(croak);
use List::MoreUtils qw(any);
use Item 0.001;
use Category 0.001;

our $VERSION = 0.001;

{
    sub SAVED     :PRIVATE { 1 };
    sub NOT_SAVED :PRIVATE { 0 };
    sub EMPTY     :PRIVATE { 0 };

    my %dir    :ATTR( :get<dir> );
    my %basket :ATTR;
    my %saved  :ATTR;

    sub BUILD {
        my ($self, $ident, $args_ref) = @_;

        if (not defined $args_ref->{dir}) {
            croak __PACKAGE__ . "::new(): no dir";
        }

        $dir{$ident}    = $args_ref->{dir};
        $basket{$ident} = {};    
  
        $self->_parse_files();

        $saved{$ident} = SAVED;

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
                    = $self->_get_lines($dir{ident $self} . q{/} . $cat_file);            
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
            $parts[0] =~ s{["]}{}gxms;
            $parts[1] =~ s{\s+}{}gxms;

            next LINE if $parts[0] eq q{};
            next LINE if $parts[1] eq q{};

            my $item = Item->new({
                text => $parts[0],
                added => $parts[1]
            });

            $items->{$item->get_text()} = $item;            
        }

        close $basket_file;      

        return $items;
    }   

    sub get_categories {
        my $self = shift;

        my @categories = ();
        foreach my $cat (values %{ $basket{ident $self} }) {
            push @categories, $cat->{obj};
        }

        return \@categories;
    }

    sub get_category_names {
        my $self = shift;

        my @category_names = ();
        foreach my $cat (keys %{ $basket{ident $self} }) {
            push @category_names, $cat;
        }

        return \@category_names;        
    } 

    sub get_items {
        my $self = shift; 

        my @items = ();
        foreach my $item (values %{ $basket{ident $self} }) {            
            push @items, values %{ $item->{items} };
        }       

        return \@items;
    }
    
    sub get_item_texts {
        my $self = shift;

        my @items = ();
        foreach my $item (values %{ $basket{ident $self} }) {            
            push @items, keys %{ $item->{items} };
        }       

        return \@items;
    }

    sub add_item {
        my $self     = shift;
        my $args_ref = shift;

        if (not defined $args_ref->{category}) {
            croak __PACKAGE__ . "::add_item(): no category";
        }

        if (not defined $args_ref->{text}) {
            croak __PACKAGE__ . "::add_item(): no item text";
        }

        my $now = DateTime->now();

        my $new_item = Item->new({ 
            text  => $args_ref->{text},
            added => $now->ymd()
        });

        if (not defined $basket{ident $self}->{$args_ref->{category}}) {
            my $new_cat = Category->new({ name => $args_ref->{category} });
            $basket{ident $self}->{$args_ref->{category}}->{obj} = $new_cat;
        }

        $basket{ident $self}->{
            $args_ref->{category}}->{items}->{$new_item->get_text()}
                = $new_item
        ;

        $saved{ident $self} = NOT_SAVED;
        return;
    }

    sub delete_item {
        my $self     = shift;
        my $args_ref = shift;

        if (not defined $args_ref->{text}) {
            croak __PACKAGE__ . "::delete_item(): no item text";
        }

        if (defined $args_ref->{category}) {
            delete $basket{ident $self}->{
                $args_ref->{category}}->{items}->{$args_ref->{text}};

            # delete the whole category if it's empty
            if (scalar keys %{ $basket{ident $self}->{
                $args_ref->{category}}->{items} } == EMPTY) {
                $self->delete_category({ category => $args_ref->{category} });
            }
        }
        else {
            foreach my $cat (keys %{ $basket{ident $self} }) {
                delete $basket{ident $self}->{$cat}->{items}->{
                    $args_ref->{text}};

                # delete the whole category if it's empty
                if (scalar keys %{ $basket{ident $self}->{$cat}->{items} } == EMPTY) {
                    $self->delete_category({ category => $cat });
                }
            }
        }       

        $saved{ident $self} = NOT_SAVED;
        return;
    }

    sub delete_category {
        my $self     = shift;
        my $args_ref = shift;

        if (not defined $args_ref->{category}) {
            croak __PACKAGE__ . "::delete_category(): no category";
        }

        delete $basket{ident $self}->{$args_ref->{category}};

        $saved{ident $self} = NOT_SAVED;
        return;
    }

    sub list {
        my $self     = shift;
        my $args_ref = shift;

        use Storable qw(dclone);

        my $set = $basket{ident $self};        
        
        # filter based on:
        ## category names
        if (defined $args_ref->{categories}) {
            foreach my $cat (keys %$set ) {
                if (not any{ $_ eq $cat } @{ $args_ref->{categories} }) {
                    delete $set->{$cat};
                }
            }
        }
        ## dates after
        if (defined $args_ref->{after}) {            
            # go over all categories
            foreach my $cat (keys %$set) {
                # go over all items
                foreach my $item (keys %{ $set->{$cat}->{items} }) {                    
                    # delete those not older than
                    if (not $set->{$cat}->{items}->{$item}
                        ->is_newer_than($args_ref->{after})) {
                        delete $set->{$cat}->{items}->{$item};
                    }
                }

                # delete whole category is empty (== no items in it)
                if (scalar keys %{ $set->{$cat}->{items} } == EMPTY) {
                    delete $set->{$cat};
                }
            }
        }
        ## dates before
        if (defined $args_ref->{before}) {
            # go over all categories
            foreach my $cat (keys %$set) {
                # go over all items
                foreach my $item (keys %{ $set->{$cat}->{items} }) {
                    # delete those not older than
                    if (not $set->{$cat}->{items}->{$item}
                        ->is_older_than($args_ref->{before})) {
                        delete $set->{$cat}->{items}->{$item};
                    }
                }

                # delete whole category is empty (== no items in it)
                if (scalar keys %{ $set->{$cat}->{items} } == EMPTY) {
                    delete $set->{$cat};
                }
            }
        }

        return $set;
    }

    sub _raname_files :PRIVATE {
        my $self = shift;

        opendir my $basket_dir, $dir{ident $self};

        BASKET_FILE:
        while (my $cat_file = readdir $basket_dir) {
            next BASKET_FILE if -d $cat_file;                   
            
            rename $dir{ident $self} . q{/} . $cat_file,
                   $dir{ident $self} . q{/} . $cat_file . q{.bak};   
        }        

        closedir $basket_dir;
        return;
    }

    sub _dump :PRIVATE {
        my $self = shift;

        CATEGORY:
        foreach my $cat (keys %{ $basket{ident $self} }) {
            open my $cat_file, q{>}, $dir{ident $self} . q{/} . $cat
                or next CATEGORY; 

            # save all items
            foreach my $item (keys %{ $basket{ident $self}->{$cat}->{items} }) {
                printf $cat_file "\"%s\";%s\n", $item
                    , $basket{ident $self}->{$cat}->{items}
                        ->{$item}->get_added_on();
            }

            close $cat_file;
        }

        return;
    }

    sub _delete_backup_files :PRIVATE {
        my $self = shift;

        unlink glob $dir{ident $self} . q{/} . q{*.bak};

        return;
    }

    sub save {
        my $self = shift;

        # create backup files == rename current ones
        $self->_raname_files();

        # create new files
        $self->_dump();

        # delete backup files
        $self->_delete_backup_files();

        $saved{ident $self} = SAVED;
        return;
    }
}

1;

__END__