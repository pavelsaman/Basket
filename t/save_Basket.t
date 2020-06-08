use Test::More qw(no_plan);

use Basket::Basket;

###############################################################################

subtest 'Save New Item' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 4);
    is(scalar @$categories, 2);

    # save new item
    $basket->add_item({
        text     => q{raspberry},
        category => q{electronics}
    });    
    # save changes
    $basket->save();

    # check it's been saved
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 5);
    is(scalar @$categories, 2);

    # clean
    $basket->delete_item({
        text     => q{raspberry},
        category => q{electronics}
    });
    $basket->save();
};

subtest 'Save New Item With New Category' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 4);
    is(scalar @$categories, 2);
    
    # add new category
    $basket->add_item({
        text     => q{bike},
        category => q{garage}
    });
    # save changes
    $basket->save();

    # check it's been saved
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 5);
    is(scalar @$categories, 3);

    # clean
    $basket->delete_item({
        text     => q{bike},
        category => q{garage}
    });
    $basket->save();
};

subtest 'Delete Item' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 4);
    is(scalar @$categories, 2);    
    # add new category
    $basket->add_item({
        text     => q{bike},
        category => q{kitchen}
    });
    # save changes
    $basket->save();
    # check it's been saved
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 5);
    is(scalar @$categories, 2);

    # delete the item
    $basket->delete_item({
        text     => q{bike},
        category => q{kitchen}
    });
    $basket->save();

    # check it's been deleted
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 4);
    is(scalar @$categories, 2);
};

subtest 'Delete Last Item - Category Gets Deletes As Well' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 4);
    is(scalar @$categories, 2);    
    # add new category
    $basket->add_item({
        text     => q{bike},
        category => q{garage}
    });
    # save changes
    $basket->save();
    # check it's been saved
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 5);
    is(scalar @$categories, 3);

    # delete the item
    $basket->delete_item({
        text     => q{bike},
        category => q{garage}
    });
    $basket->save();

    # check it's been deleted
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });
    my $items = $basket->get_items();
    my $categories = $basket->get_categories();
    is(scalar @$items, 4);
    is(scalar @$categories, 2);
};
