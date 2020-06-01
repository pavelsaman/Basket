use Test::More qw(no_plan);
use List::MoreUtils qw(any);
use DateTime;

use Basket;

###############################################################################
# get_category_names

my $basket = Basket->new({ dir => q{./t/dummy_files} });

isa_ok($basket, q{Basket});

my $all_cat_names = $basket->get_category_names();
is(scalar @$all_cat_names, 2);

my @electronics = any{ $_ eq q{electronics} } @$all_cat_names;
is(scalar @electronics, 1);

my @kitchen = any{ $_ eq q{kitchen} } @$all_cat_names;
is(scalar @kitchen, 1);

###############################################################################
# no dir

my $basket = eval{ Basket->new({ }) };
my $error = $@;

is($basket, undef);
like($error, qr/no dir/);

###############################################################################
# wrong dir

my $basket = eval{ Basket->new({ dir => q{./t/dummy_file} }) };
my $error = $@;

is($basket, undef);
like($error, qr/It is not possible to read from dir in BASKET_DIR/);

###############################################################################
# get_categories

my $basket = Basket->new({ dir => q{./t/dummy_files} });
my $categories = $basket->get_categories();

is(scalar @$categories, 2);

###############################################################################
# get_items

my $basket = Basket->new({ dir => q{./t/dummy_files} });
my $items = $basket->get_items();

is(scalar @$items, 4);

###############################################################################
# get_item_texts

my $basket = Basket->new({ dir => q{./t/dummy_files} });
my $items = $basket->get_item_texts();

is(scalar @$items, 4);

###############################################################################
# add_item

my $basket = Basket->new({ dir => q{./t/dummy_files} });
$basket->add_item({
    text     => q{e},
    category => q{garage}
});

my $items = $basket->get_items();
my $categories = $basket->get_categories();

is(scalar @$items, 5);
is(scalar @$categories, 3);

# add existing item
$basket->add_item({
    text     => q{a},
    category => q{electronics}
});

my $items = $basket->get_items();
my $categories = $basket->get_categories();

is(scalar @$items, 5);
is(scalar @$categories, 3);
my $result = $basket->list({ categories => ["electronics"] });
my $now = DateTime->now();

# increase quantity and change date to the date of addition
ok(grep { $_ eq q{2x a;} . $now->ymd() } @{ $result->{electronics} });

# missing text

eval{ $basket->add_item({
        category => q{garage}
    });
};
my $error = $@;

like($error, qr/no item text/);

# missing category

eval{ $basket->add_item({
        text => q{e}
    });
};
my $error = $@;

like($error, qr/no category/);

###############################################################################
# delete_item - from one category

$basket->delete_item({
    text     => q{e},
    category => q{garage}
});

my $items = $basket->get_items();
my $categories = $basket->get_categories();

is(scalar @$items, 4);
is(scalar @$categories, 2);

# missing text

eval{ $basket->delete_item({ }) };
my $error = $@;

like($error, qr/no item text/);

###############################################################################
# delete_item - from all category

$basket->delete_item({
    text => q{a}
});

my $items = $basket->get_items();
my $categories = $basket->get_categories();

is(scalar @$items, 3);
is(scalar @$categories, 2);

###############################################################################
# delete_category

$basket->delete_category({
    category => q{electronics}
});

my $items = $basket->get_items();
my $categories = $basket->get_categories();

is(scalar @$items, 2);
is(scalar @$categories, 1);

# missing category

eval{ $basket->delete_category({ }) };
my $error = $@;

like($error, qr/no category/);