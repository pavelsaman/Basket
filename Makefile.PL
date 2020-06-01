use 5.030002;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Basket',
    ABSTRACT     => 'Basket - keep track of your shopping lists',
    VERSION_FROM => 'lib/basket',
    PREREQ_PM    => {                      
                      'Class::Std'     => 0.013,
                      'Readonly'       => 2.05
                    },
    AUTHOR       => 'Pavel Saman <pavelsamn@centrum.cz>',
    LICENSE      => 'perl',
    EXE_FILES    => ['bin/basket'],
    test         => { TESTS => 't/*.t'}
    #INST_SCRIPT  => '~/.local/bin'
);
