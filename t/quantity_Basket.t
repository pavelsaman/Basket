use Test::More qw(no_plan);
use List::MoreUtils qw(any);
use DateTime;

use Basket;

###############################################################################

my $basket = Basket->new({ dir => q{./t/dummy_files} });

isa_ok($basket, q{Basket});

###############################################################################
# quantity 1

my $result = $basket->list({ categories => ["electronics"] });

ok(grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });

###############################################################################
# quantity 1

# add more of "a"
$basket->add_item({
    text     => q{a},
    category => q{electronics}
});
my $now = DateTime->now();

my $result = $basket->list({ categories => ["electronics"] });
ok(grep { $_ eq q{2x a;} . $now->ymd() } @{ $result->{electronics} });
ok(grep { $_ eq q{b;2020-02-01}        } @{ $result->{electronics} });

###############################################################################
# quantity 3

# add more of "a"
$basket->add_item({
    text     => q{a},
    category => q{electronics}
});
my $now = DateTime->now();

my $result = $basket->list({ categories => ["electronics"] });
ok(grep { $_ eq q{3x a;} . $now->ymd() } @{ $result->{electronics} });
ok(grep { $_ eq q{b;2020-02-01}        } @{ $result->{electronics} });

###############################################################################
# quantity 0

# delete "a"
$basket->delete_item({
    text     => q{a},
    category => q{electronics}
});

my $result = $basket->list({ categories => ["electronics"] });
ok(not grep { $_ eq q{3x a;} . $now->ymd() } @{ $result->{electronics} });
ok(not grep { $_ eq q{a;2020-01-01}        } @{ $result->{electronics} });
ok(grep { $_ eq q{b;2020-02-01}            } @{ $result->{electronics} });