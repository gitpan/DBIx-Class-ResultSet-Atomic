#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'DBIx::Class::ResultSet::Atomic' );
}

diag( "Testing DBIx::Class::ResultSet::Atomic $DBIx::Class::ResultSet::Atomic::VERSION, Perl $], $^X" );
