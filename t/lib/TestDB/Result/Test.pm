package TestDB::Result::Test;
use base qw/ DBIx::Class /;

__PACKAGE__->load_components(qw/ Core /);
__PACKAGE__->table('test');
__PACKAGE__->add_columns(
                         id =>
                         foo =>
                        );
__PACKAGE__->set_primary_key(qw/ id /);
__PACKAGE__->add_unique_constraint([qw/ foo /]);

1;

