package Basket;

use strict;
use warnings;
use Readonly;
use DateTime;
use Class::Std;
use Carp qw(croak);
use List::MoreUtils qw(duplicates any);
use Item 0.002;
use Category 0.002;

our $VERSION = 0.005;

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

        opendir my $basket_dir, $dir{ident $self}
            or croak "It is not possible to read from dir in BASKET_DIR.\n"
                . "Please check it is set up correctly.\n"
        ;

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
            $parts[0] =~ s{\s+}{}gxms;
            $parts[1] =~ s{["]}{}gxms;
            $parts[2] =~ s{\s+}{}gxms;

            next LINE if $parts[0] eq q{};
            next LINE if $parts[1] eq q{};
            next LINE if $parts[2] eq q{};

            my $item = Item->new({
                text     => $parts[1],
                added    => $parts[2],
                quantity => $parts[0]
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

        # create new category
        if (not defined $basket{ident $self}->{$args_ref->{category}}) {
            my $new_cat = Category->new({ name => $args_ref->{category} });
            $basket{ident $self}->{$args_ref->{category}}->{obj} = $new_cat;
        }        

        my $existing_item
            = $basket{ident $self}->{
                $args_ref->{category}}->{items}->{$args_ref->{text}}
        ;              

        my $now = DateTime->now();

        # increase quantity of an existing item
        if ($existing_item) {
            $existing_item->increase_quantity();
            $existing_item->set_added_on($now->ymd());            
        }
        # new item
        else {
            my $new_item = Item->new({ 
                text     => $args_ref->{text},
                added    => $now->ymd(),
                quantity => 1
            });

            $basket{ident $self}->{
                $args_ref->{category}}->{items}->{$new_item->get_text()}
                    = $new_item
            ;
        }        

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
                if (scalar keys %{ $basket{
                    ident $self}->{$cat}->{items} } == EMPTY) {
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

    sub _build_item_text {
        my $item_ref         = shift;
        my $pretty_item_text = q{};

        if ($item_ref->get_quantity() > 1) {
            $pretty_item_text = $item_ref->get_quantity() . "x ";
        }
        
        $pretty_item_text .= join q{;}, $item_ref->get_text(),
            $item_ref->get_added_on()
        ;

        return $pretty_item_text;
    }

    sub list {
        my $self     = shift;
        my $args_ref = shift; 
        my $result   = {};                

        # go over all categories        
        CATEGORY:  
        foreach my $cat (@{ $self->get_category_names() }) {  
            next CATEGORY if defined $args_ref->{categories}
                and scalar @{ $args_ref->{categories} } > 0
                and not any { $_ eq $cat } @{ $args_ref->{categories} }
            ;         
            # go over all items
            foreach my $item (keys %{ $basket{
                ident $self}->{$cat}->{items} }) {              
                my $it = $basket{ident $self}->{$cat}->{items}->{$item};
                
                if (defined $args_ref->{after}) {
                    if ($it->is_newer_than($args_ref->{after})) {                        
                        push @{ $result->{$cat} }, _build_item_text($it);                        
                    }                                 
                }                
                if (defined $args_ref->{before}) {
                    if ($it->is_older_than($args_ref->{before})) {                        
                        push @{ $result->{$cat} }, _build_item_text($it);                        
                    }                                  
                }
                if (not defined $args_ref->{before}
                    and not defined $args_ref->{after}) {
                    push @{ $result->{$cat} }, _build_item_text($it);                    
                }
            }            

            # if both before and after are specified, chose only values
            # that comply to both conditions
            if (defined $args_ref->{before}
                and defined $args_ref->{after}) {
                $result->{$cat} = [ duplicates @{ $result->{$cat} }];
            }

            _prune_empty_categories($result);
        }              

        return $result;
    }

    sub rename_category {
        my $self     = shift;
        my $args_ref = shift;

        $basket{ident $self}->{
            $args_ref->{old}}->{obj}->set_name($args_ref->{new})
        ;
        $basket{ident $self}->{
            $args_ref->{new}} = delete $basket{ident $self}->{
                $args_ref->{old}}
        ;

        return;
    }

    sub _prune_empty_categories {
        my $data_ref = shift;

        foreach my $key (keys %$data_ref) {
            if (scalar @{ $data_ref->{$key} } == EMPTY) {
                delete $data_ref->{$key};
            }
        }

        return;
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
                printf $cat_file "%s;\"%s\";%s\n",
                    $basket{ident $self}->{$cat}->{items}->{$item}
                        ->get_quantity(),
                    $item
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