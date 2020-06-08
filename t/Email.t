use Test::More qw(no_plan);

use Basket::Email;

###############################################################################

subtest 'Env Variable Are Not Set' => sub {
    delete $ENV{BASKET_SERVER};
    delete $ENV{BASKET_PORT};
    delete $ENV{BASKET_SECURITY};
    delete $ENV{BASKET_USER};
    delete $ENV{BASKET_SENDER};
    delete $ENV{BASKET_PWD};

    my $email = eval{ Basket::Email->new() };
    my $error = $@;

    is($email, undef);
    like($error, qr/email information not configured/);
};

subtest 'Env Variable Server Is Not Set' => sub {
    delete $ENV{BASKET_SERVER};
    $ENV{BASKET_PORT}     = 465;
    $ENV{BASKET_SECURITY} = 'ssl';
    $ENV{BASKET_USER}     = "pavelsam";
    $ENV{BASKET_SENDER}   = 'pavelsam@centrum.cz';
    $ENV{BASKET_PWD}      = "secret";

    my $email = eval{ Basket::Email->new() };
    my $error = $@;

    is($email, undef);
    like($error, qr/email information not configured/);  
};

subtest 'Env Variable Port Is Not Set' => sub {
    $ENV{BASKET_SERVER}   = "gmail.com";
    delete $ENV{BASKET_PORT};
    $ENV{BASKET_SECURITY} = 'ssl';
    $ENV{BASKET_USER}     = "pavelsam";
    $ENV{BASKET_SENDER}   = 'pavelsam@centrum.cz';
    $ENV{BASKET_PWD}      = "secret";

    my $email = eval{ Basket::Email->new() };
    my $error = $@;

    is($email, undef);
    like($error, qr/email information not configured/);  
};

subtest 'Env Variable Security Is Not Set' => sub {
    $ENV{BASKET_SERVER}   = "gmail.com";
    $ENV{BASKET_PORT}     = 465;
    delete $ENV{BASKET_SECURITY};
    $ENV{BASKET_USER}     = "pavelsam";
    $ENV{BASKET_SENDER}   = 'pavelsam@centrum.cz';
    $ENV{BASKET_PWD}      = "secret";

    my $email = eval{ Basket::Email->new() };
    my $error = $@;

    is($email, undef);
    like($error, qr/email information not configured/);  
};

subtest 'Env Variable User Is Not Set' => sub {
    $ENV{BASKET_SERVER}   = "gmail.com";
    $ENV{BASKET_PORT}     = 465;
    $ENV{BASKET_SECURITY} = 'ssl';
    delete $ENV{BASKET_USER};
    $ENV{BASKET_SENDER}   = 'pavelsam@centrum.cz';
    $ENV{BASKET_PWD}      = "secret";

    my $email = eval{ Basket::Email->new() };
    my $error = $@;

    is($email, undef);
    like($error, qr/email information not configured/);  
};

subtest 'Env Variable Sender Is Not Set' => sub {
    $ENV{BASKET_SERVER}   = "gmail.com";
    $ENV{BASKET_PORT}     = 465;
    $ENV{BASKET_SECURITY} = 'ssl';
    $ENV{BASKET_USER}     = "pavelsam";
    delete $ENV{BASKET_SENDER};
    $ENV{BASKET_PWD}      = "secret";

    my $email = eval{ Basket::Email->new() };
    my $error = $@;

    is($email, undef);
    like($error, qr/email information not configured/);  
};

subtest 'Env Variable Pwd Is Not Set' => sub {
    $ENV{BASKET_SERVER}   = "gmail.com";
    $ENV{BASKET_PORT}     = 465;
    $ENV{BASKET_SECURITY} = 'ssl';
    $ENV{BASKET_USER}     = "pavelsam";
    $ENV{BASKET_SENDER}   = 'pavelsam@centrum.cz';
    delete $ENV{BASKET_PWD};

    my $email = eval{ Basket::Email->new() };
    my $error = $@;

    is($email, undef);
    like($error, qr/email information not configured/);  
};

subtest 'Env Variable Is Set' => sub {
    $ENV{BASKET_SERVER}   = "gmail.com";
    $ENV{BASKET_PORT}     = 465;
    $ENV{BASKET_SECURITY} = 'ssl';
    $ENV{BASKET_USER}     = "pavelsam";
    $ENV{BASKET_PWD}      = "secret";

    my $email = eval{ Basket::Email->new() };
    my $error = $@;

    isa_ok($email, q{Basket::Email});    
};
