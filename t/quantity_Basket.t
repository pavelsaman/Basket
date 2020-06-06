use Test::More qw(no_plan);
use List::MoreUtils qw(any);
use DateTime;

use Basket;

###############################################################################

subtest 'List Quantity Of 1' => sub {
    my $basket = Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({ categories => ["electronics"] });

    ok(grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
};

subtest 'List Quantity Of 2' => sub {
    my $basket = Basket->new({ dir => q{./t/dummy_files} });
    $basket->add_item({
        text     => q{a},
        category => q{electronics}
    });

    my $result = $basket->list({ categories => ["electronics"] });

    my $now = DateTime->now();    
    ok(grep { $_ eq q{2x a;} . $now->ymd() } @{ $result->{electronics} });
    ok(grep { $_ eq q{b;2020-02-01}        } @{ $result->{electronics} });
};

subtest 'List Quantity Of 3' => sub {
    my $basket = Basket->new({ dir => q{./t/dummy_files} });
    $basket->add_item({
        text     => q{a},
        category => q{electronics}
    });
    $basket->add_item({
        text     => q{a},
        category => q{electronics}
    });

    my $result = $basket->list({ categories => ["electronics"] });

    my $now = DateTime->now();    
    ok(grep { $_ eq q{3x a;} . $now->ymd() } @{ $result->{electronics} });
    ok(grep { $_ eq q{b;2020-02-01}        } @{ $result->{electronics} });
};

subtest 'Add Item, Delete Item - No Quantity, No Item' => sub {
    my $basket = Basket->new({ dir => q{./t/dummy_files} });
    $basket->add_item({
        text     => q{a},
        category => q{electronics}
    });
    $basket->add_item({
        text     => q{a},
        category => q{electronics}
    });
    $basket->delete_item({
        text     => q{a},
        category => q{electronics}
    });

    my $result = $basket->list({ categories => ["electronics"] });

    my $now = DateTime->now(); 
    ok(not grep { $_ eq q{3x a;} . $now->ymd() } @{ $result->{electronics} });
    ok(not grep { $_ eq q{a;2020-01-01}        } @{ $result->{electronics} });
    ok(    grep { $_ eq q{b;2020-02-01}        } @{ $result->{electronics} });
};
