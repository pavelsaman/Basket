use 5.030002;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Basket',
    ABSTRACT     => 'Basket - keep track of your shopping lists',
    VERSION_FROM => 'bin/basket',
    PREREQ_PM    => {                      
                      'Class::Std'     => 0.013,
                      'Readonly'       => 2.05,
                      'Email::Sender'  => 1.300034,
                      'Email::Simple'  => 2.216
                    },
    AUTHOR       => 'Pavel Saman <pavelsamn@centrum.cz>',
    LICENSE      => 'perl',
    EXE_FILES    => ['bin/basket'],
    test         => { TESTS => 't/*.t'}
    #INST_SCRIPT  => '~/.local/bin'
);
