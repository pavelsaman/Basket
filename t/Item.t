use Test::More qw(no_plan);

use Item;

###############################################################################

subtest 'Create New Item' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    isa_ok($item, q{Item});
    is($item->get_text(), q{RJ45 cable});
    is($item->get_added_on(), q{2020-05-10});
    is($item->get_year(), q{2020});
    is($item->get_month(), q{05});
    is($item->get_day(), q{10});
};

subtest 'Item Is Newer Than - Positive Case' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_newer_than(q{2020-05-05}), 1);
};

subtest 'Item Is Newer Than - Negative Case' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_newer_than(q{2020-05-15}), undef);
};

subtest 'Item Is Newer Than - Edge Case: Same Date' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_newer_than(q{2020-05-10}), undef);
};

subtest 'Item Is Older Than - Positive Case' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_older_than(q{2020-05-15}), 1);
};

subtest 'Item Is Older Than - Negative Case' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_older_than(q{2020-05-05}), undef);
};

subtest 'Item Is Older Than - Edge Case: Same Date' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_older_than(q{2020-05-10}), undef);
};

subtest 'Item Is Created At - Positive Case' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_created_at(q{2020-05-10}), 1);
};

subtest 'Item Is Created At - Negative Case Past' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_created_at(q{2020-05-05}), undef);
};

subtest 'Item Is Created At - Negative Case Future' => sub {
    my $item = Item->new({
        text     => q{RJ45 cable},
        added    => q{2020-05-10},
        quantity => q{1}
    });

    is($item->is_created_at(q{2020-05-15}), undef);
};
