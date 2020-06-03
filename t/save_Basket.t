use Test::More qw(no_plan);

use Basket;

###############################################################################

my $basket = Basket->new({ dir => q{./t/dummy_files} });

isa_ok($basket, q{Basket});

my $items = $basket->get_items();
my $categories = $basket->get_categories();

is(scalar @$items, 4);
is(scalar @$categories, 2);

# save new item
$basket->add_item({
    text     => q{raspberry},
    category => q{electronics}
});

# add new category
$basket->add_item({
    text     => q{bike},
    category => q{garage}
});

# save changes
$basket->save();

# check it's been saved
my $basket = Basket->new({ dir => q{./t/dummy_files} });

isa_ok($basket, q{Basket});

my $items = $basket->get_items();
my $categories = $basket->get_categories();

is(scalar @$items, 6);
is(scalar @$categories, 3);

# delete
$basket->delete_item({
    text     => q{bike},
    category => q{garage}
});

$basket->delete_item({
    text     => q{raspberry}
});

# save changes
$basket->save();

# check it's been saved
my $basket = Basket->new({ dir => q{./t/dummy_files} });

isa_ok($basket, q{Basket});

my $items = $basket->get_items();
my $categories = $basket->get_categories();

is(scalar @$items, 4);
is(scalar @$categories, 2);