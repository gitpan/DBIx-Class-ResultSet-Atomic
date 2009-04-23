package TestDB;
use base qw/ DBIx::Class::Schema /;

__PACKAGE__->load_namespaces
  (
   default_resultset_class => '+DBIx::Class::ResultSet::Atomic::Default',
  );

1;

