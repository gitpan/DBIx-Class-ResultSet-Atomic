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

plan tests => 2;

my $schema = TestDB->connect($dsn, $user, $pass)
  or die "TestDB->connect failed";

my $rs = $schema->resultset('Test')
  or die "Can't find resultset Test";

# What we're mainly testing here is that we don't just randomly-corrupt the
# database if the database schema disagrees with the dbic schema. An
# update_or_create with a null condition is one of those annoying broken
# results.

# FIXME: we should really try somewhat harder to break this.

eval {
  # in this case, the find() within atomic_update_or_create() doesn't get a
  # single row back. Something sensible should occur in that case.
  my $result = $rs->atomic_update_or_create
    ({
     });
}

like($@, qr/^Atomic update_or_create failed: query returned more than one row/,
     "Throws sensible exception if given oddball query");

