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

my $schema = TestDB->connect($dsn, $user, $pass)
  or die "TestDB->connect failed";

my $dbh = $schema->storage->dbh;

$dbh->do('DROP TABLE test');

ok('DROP TABLE');

