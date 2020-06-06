use Test::More qw(no_plan);

use Category;

###############################################################################

subtest 'Create New Category' => sub {
    my $cat_name = q{electronics};

    my $cat = Category->new({ name => $cat_name });

    isa_ok($cat, q{Category});
    is($cat->get_name(), $cat_name);
};

subtest 'Rename Category' => sub {
    my $cat_name = q{electronics};
    my $cat = Category->new({ name => $cat_name });

    my $result = $cat->set_name(q{IT});

    is($result, undef);
    is($cat->get_name, q{IT});
};
