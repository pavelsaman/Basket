use Test::More qw(no_plan);
use List::MoreUtils qw(any);
use DateTime;

use Basket::Basket;

###############################################################################

subtest 'Get Category Names' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });   

    my $all_cat_names = $basket->get_category_names();
    is(scalar @$all_cat_names, 2);

    my @electronics = any{ $_ eq q{electronics} } @$all_cat_names;
    is(scalar @electronics, 1);

    my @kitchen = any{ $_ eq q{kitchen} } @$all_cat_names;
    is(scalar @kitchen, 1);
};

subtest 'Create Basket When No Dir Is Passed' => sub {
    my $basket = eval{ Basket::Basket->new({ }) };
    my $error = $@;

    is($basket, undef);
    like($error, qr/no dir/);
};

subtest 'Create Basket When Wrong Directory Is Passed' => sub {
    my $basket = eval{ Basket::Basket->new({ dir => q{./t/dummy_file} }) };
    my $error = $@;

    is($basket, undef);
    like($error, qr/It is not possible to read from dir in BASKET_DIR/);
};

subtest 'Get Correct Number Of Categories' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $categories = $basket->get_categories();

    is(scalar @$categories, 2);
};

subtest 'Get Correct Number Of Items' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $items = $basket->get_items();

    is(scalar @$items, 4);
};

subtest 'Get Correct Number Of Item Texts' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $items = $basket->get_item_texts();

    is(scalar @$items, 4);
};

subtest 'Add New Item To Basket' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    $basket->add_item({
        text     => q{e},
        category => q{garage}
    });

    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 5);
    is(scalar @$categories, 3);
};

subtest 'Add Existing Item - Quantity Increases, Date Changes' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    
    $basket->add_item({
        text     => q{a},
        category => q{electronics}
    });

    my $items = $basket->get_items();
    my $categories = $basket->get_categories();

    is(scalar @$items, 4);
    is(scalar @$categories, 2);

    my $result = $basket->list({ categories => ["electronics"] });
    my $now = DateTime->now();    
    ok(grep { $_ eq q{2x a;} . $now->ymd() } @{ $result->{electronics} });
};

subtest 'Add Item With No Text' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    eval{ $basket->add_item({ category => q{garage} }) };
    my $error = $@;

    like($error, qr/no item text/);
};

subtest 'Add Item With No Category' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    eval{ $basket->add_item({ text => q{e} }) };    
    my $error = $@;

    like($error, qr/no category/);
};

subtest 'Delete Item From One Category' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    $basket->delete_item({
        text     => q{a},
        category => q{electronics}
    });

    my $items = $basket->get_items();
    my $categories = $basket->get_categories();

    is(scalar @$items, 3);
    is(scalar @$categories, 2);
};

subtest 'Delete Last Item From Category - Delete Category As Well' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    $basket->delete_item({
        text     => q{a},
        category => q{electronics}
    });
    $basket->delete_item({
        text     => q{b},
        category => q{electronics}
    });

    my $items = $basket->get_items();
    my $categories = $basket->get_categories();

    is(scalar @$items, 2);
    is(scalar @$categories, 1);
};

subtest 'Delete Item - No Text Is Passed' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    eval{ $basket->delete_item({ }) };
    my $error = $@;

    like($error, qr/no item text/);
};

subtest 'Delete Item From All Categories' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    $basket->add_item({
        text     => q{a},
        category => q{kitchen}
    });

    $basket->delete_item({ text => q{a} });

    my $items = $basket->get_items();
    my $categories = $basket->get_categories();

    is(scalar @$items, 3);
    is(scalar @$categories, 2);
};

subtest 'Delete Category And All Its Items' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    $basket->delete_category({ category => q{electronics} });

    my $items = $basket->get_items();
    my $categories = $basket->get_categories();

    is(scalar @$items, 2);
    is(scalar @$categories, 1);
};

subtest 'Delete Category - No Category Is Passed' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    eval{ $basket->delete_category({ }) };
    my $error = $@;

    like($error, qr/no category/);
};
