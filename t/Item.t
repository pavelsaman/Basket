use Test::More qw(no_plan);

use Item;

###############################################################################

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

###############################################################################
# is_newer_than()

is($item->is_newer_than(q{2020-05-05}), 1);
is($item->is_newer_than(q{2020-05-15}), undef);
is($item->is_older_than(q{2020-05-05}), undef);
is($item->is_older_than(q{2020-05-15}), 1);
is($item->is_created_at(q{2020-05-10}), 1);
is($item->is_created_at(q{2020-05-11}), undef);

