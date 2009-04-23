use strict;
use warnings;
use ExtUtils::MakeMaker;

use ExtUtils::MakeMaker;
eval "use ExtUtils::MakeMaker::Coverage";
warn "Note: ExtUtils::MakeMaker::Coverage not available, can't 'make testcover'\n"
  if $@;

eval "use Test::Pod::Coverage";
warn "Note: Test::Pod::Coverage not available, consider installing for POD testing\n"
  if $@;

WriteMakefile(
              NAME => 'DBIx::Class::ResultSet::Atomic',
              AUTHOR => 'Peter Corlett <abuse@cabal.org.uk>',
              VERSION_FROM => 'lib/DBIx/Class/ResultSet/Atomic.pm',
              ABSTRACT_FROM => 'lib/DBIx/Class/ResultSet/Atomic.pm',
              ($ExtUtils::MakeMaker::VERSION >= 6.3002
               ? ('LICENSE'=> 'perl')
               : ()),
              PL_FILES => {},
              PREREQ_PM => {
                            'Test::More' => 0,
                            'DBIx::Class' => 0.08100,
                           },
              dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
              clean => { FILES => 'DBIx-Class-Atomic-*' },
             );
