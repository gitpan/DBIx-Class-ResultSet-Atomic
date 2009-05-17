#!perl

use Test::More;

use FindBin;
use lib "${FindBin::Bin}/lib";

use TestDB;

my ($dsn, $user, $pass) = @ENV{map { "DBICTEST_PG_${_}" } qw/DSN USER PASS/};

plan skip_all => <<'EOT' unless $dsn;
Set $ENV{DBICTEST_PG_DSN}, _USER and _PASS to run this test.
(note: This test drops and creates a table 'test' and corresponding sequence
and indices!)
EOT

plan tests => 1;

sub do_test {
  my $schema = TestDB->connect($dsn, $user, $pass)
    or die "TestDB->connect failed";

  # this changes the debug object so that we use our new Statistics. The net
  # effect of this is that if tests are run with DBIC_TRACE set, the PID
  # will precede the statement so it's possible to tell which process is
  # doing what.
  use Statistics;
  $schema->storage->debugobj(new Statistics());

  my $rs = $schema->resultset('Test')
    or die "Can't find resultset Test";

  for(1..10) {
    for my $value ('a'..'z') {
      my $result = $rs->atomic_update_or_create
        ({
          foo => "Value '$value'",
         });
    }
  }
}

my $pid;
unless($pid = fork) { # child
  eval {
    do_test();
  };
  if($@) {
    print STDERR $@;
    exit 1;
  }
  exit 0;
}

# parent

do_test();
my $waitpid = waitpid $pid, 0;
die unless $waitpid == $pid;
die "child exited nonzero status" if $?;

ok('apparently works in parallel');

