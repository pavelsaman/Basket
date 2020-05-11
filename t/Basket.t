use Test::More qw(no_plan);
use List::MoreUtils qw(any);

use Basket;

###############################################################################

my $basket = Basket->new({ dir => q{./t/dummy_files} });

isa_ok($basket, q{Basket});

my @all_cat_names = $basket->get_all_category_names();
is(scalar @all_cat_names, 2);

my @electronics = any{ $_ eq q{electronics} } @all_cat_names;
is(scalar @electronics, 1);

my @kitchen = any{ $_ eq q{kitchen} } @all_cat_names;
is(scalar @kitchen, 1);

###############################################################################
# no dir

my $basket = eval{ Basket->new({ }) };
my $error = $@;

is($basket, undef);
like($error, qr/no dir/);
