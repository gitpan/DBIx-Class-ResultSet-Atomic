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

my $result = $rs->atomic_update_or_create
  ({
    foo => 'a random value too',
   });
isa_ok($result, 'TestDB::Result::Test', "INSERT returns row");

$result = $rs->atomic_update_or_create
  ({
    foo => 'a random value too',
   });
isa_ok($result, 'TestDB::Result::Test', "UPDATE returns row");

