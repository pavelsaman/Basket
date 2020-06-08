use Test::More qw(no_plan);
use List::MoreUtils qw(any);

use Basket::Basket;

###############################################################################

subtest 'List Everything' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({ categories => [] });

    ok(grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};

subtest 'Use --after Option' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({ categories => [], after => "2020-01-01" });

    ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(    grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};

subtest 'Use --before Option' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({ categories => [], before => "2020-02-02" });

    ok(    grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(not grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};

subtest 'Use --before and --after Option' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({
        categories => [],
        after      => "2020-01-01",
        before     => "2020-04-01"
    });

    ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};

subtest 'Use --after and --category Option' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({
        categories => ["kitchen"],
        after => "2020-01-01"
    });

    ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(not grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(    grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};

subtest 'Use --before and --category Option' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({
        categories => ["kitchen"],
        before => "2020-03-02"
    });

    ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(not grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};

subtest 'Use --before, --after, and --category Option' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({
        categories => ["electronics"],
        after      => "2020-01-01",
        before     => "2020-04-01"
    });

    ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(not grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};

subtest 'Use --before, --after, and --category Option - Two Categories' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({
        categories => ["electronics", "kitchen"],
        after      => "2020-01-01",
        before     => "2020-04-01"
    });

    ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(    grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};

subtest 'Use --before, --after, and --category Option - No Results' => sub {
    my $basket = Basket::Basket->new({ dir => q{./t/dummy_files} });

    my $result = $basket->list({
        categories => ["electronics", "kitchen"],
        after      => "2020-02-01",
        before     => "2020-03-01"
    });

    ok(not grep { $_ eq q{a;2020-01-01} } @{ $result->{electronics} });
    ok(not grep { $_ eq q{b;2020-02-01} } @{ $result->{electronics} });
    ok(not grep { $_ eq q{c;2020-03-01} } @{ $result->{kitchen}     });
    ok(not grep { $_ eq q{d;2020-04-01} } @{ $result->{kitchen}     });
};
