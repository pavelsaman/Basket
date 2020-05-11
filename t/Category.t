use Test::More qw(no_plan);

use Category;

###############################################################################

my $cat_name = q{electronics};
my $cat = Category->new({ name => $cat_name });

isa_ok($cat, q{Category});
is($cat->get_name(), $cat_name);
