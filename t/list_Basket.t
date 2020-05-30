use Test::More qw(no_plan);
use List::MoreUtils qw(any);

use Basket;

###############################################################################

my $method = 'list';

###############################################################################

my $basket = Basket->new({ dir => q{./t/dummy_files} });
isa_ok($basket, q{Basket});

###############################################################################
# --list

my $result = $basket->list({ categories => [] });

ok(grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });

###############################################################################
# --list --after

my $result = $basket->list({ categories => [], after => "2020-01-01" });

ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(    grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });

###############################################################################
# --list --before

my $result = $basket->list({ categories => [], before => "2020-02-02" });

ok(    grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(not grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });

###############################################################################
# --list --after --category

my $result = $basket->list({
    categories => ["kitchen"],
    after => "2020-01-01"
});

ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(not grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(    grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });

###############################################################################
# --list --before --category

my $result = $basket->list({
    categories => ["kitchen"],
    before => "2020-03-02"
});

ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(not grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });

###############################################################################
# --list --after --before

my $result = $basket->list({
    categories => [],
    after      => "2020-01-01",
    before     => "2020-04-01"
});

ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });

###############################################################################
# --list --after --before --category

my $result = $basket->list({
    categories => ["electronics"],
    after      => "2020-01-01",
    before     => "2020-04-01"
});

ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(not grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });

###############################################################################
# --list --after --before --category

my $result = $basket->list({
    categories => ["electronics", "kitchen"],
    after      => "2020-01-01",
    before     => "2020-04-01"
});

ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });

###############################################################################
# --list --after --before --category

my $result = $basket->list({
    categories => ["electronics", "kitchen"],
    after      => "2020-02-01",
    before     => "2020-03-01"
});

ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
ok(not grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
ok(not grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });