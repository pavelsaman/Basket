use Test::More qw(no_plan);

use Basket::Basket;

###############################################################################

subtest 'Rename Category' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    $basket->rename_category({
        old => "electronics",
        new => "abc"
    });

    my $category_names_ref = $basket->get_category_names();
    ok(    grep { $_ eq q{abc}         } @$category_names_ref);
    ok(    grep { $_ eq q{kitchen}     } @$category_names_ref);
    ok(not grep { $_ eq q{electronics} } @$category_names_ref);
};
