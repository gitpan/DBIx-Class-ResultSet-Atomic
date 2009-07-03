package DBIx::Class::ResultSet::Atomic;

use warnings;
use strict;

use base qw/ DBIx::Class /;     # we're a dbic component...
use DBIx::Class 0.08100;        # savepoints are new to 0.01800

use Carp;

=head1 NAME

DBIx::Class::ResultSet::Atomic - Atomic alternative to update_or_create()

=cut

our $VERSION = '0.005';

=head1 SYNOPSIS

 # in your ResultSet class
 __PACKAGE__->load_components(qw/ ResultSet::Atomic /);

 # in your application code
 my $result = $rs->atomic_update_or_create({
     column1 => 'value',
     ...
 });

 # or if you're using DBIx::Class::Schema::Loader...:

 __PACKAGE__->loader_options(
   # ...
   # have separate Result and ResultSet schemas
   use_namespaces => 1,
   # use this plugin
   resultset_components => [ '+DBIx::Class::ResultSet::Atomic' ],

=head1 DESCRIPTION

DBIx::Class::ResultSet::update_or_create() currently (up to at least version
0.08100) contains a race condition which can cause it to fail with an
unnecessary exception or cause database corruption if two processes attempt
to create a new record within the critical window.

DBIx::Class::ResultSet::Atomic fixes this race condition. It is a component
that you add to your ResultSet classes to add the new atomic methods.

=head1 METHODS

=head2 atomic_update_or_create

 # exactly the same arguments as update_or_create
 my $result = $rs->atomic_update_or_create({
     column1 => 'value',
     ...
 });

This is an atomic version of update_or_create(). It requires your database
engine to support transactions, savepoints and SELECT ... FOR UPDATE.
PostgreSQL does. Your table must also have UNIQUE constraints that match
your DBIC schema.

Benchmarking shows that this is also about 50% faster than
update_or_create() when inserting a new row, and 30% slower to do an update.
This is intuitive since update_or_create performs two queries (or just one
if nothing is changed) whereas this will always do one query on insert, and
three to do an update (two if nothing is changed). You are however
encouraged to do your own performance measurements if this is important to
you.

=cut

sub atomic_update_or_create {
  my $self = shift;
  my $attrs = (@_ > 1 && ref $_[$#_] eq 'HASH' ? pop(@_) : {});
  my $cond = ref $_[0] eq 'HASH' ? shift : {@_};

  my $schema = $self->result_source->schema;

  # We want a savepoint, but those only work within transactions, so we
  # start a transaction as well. One or both of these will fail if the
  # underlying storage doesn't support savepoints. This is still safe even
  # if a transaction is already in progress - the savepoint ensures that the
  # outer transaction isn't aborted unless there is a real failure.
  return $schema->txn_do
    (sub {
       $schema->svp_begin;

       # now try an INSERT
       my $row = eval { $self->create($cond); };
       if($@) {
         # If the INSERT failed, this suggests a failed constraint check due to
         # duplicate keys. So we rollback the savepoint and do a
         # SELECT-modify-UPDATE instead. We add the SELECT ... FOR UPDATE
         # option to block any parallel queries on the same row.
         $schema->svp_rollback;
         # The insert failed, so we search for the row that caused the
         # failure. If there are zero or more than two matches, there's
         # clearly something not quite right going on
         $row = $self->find($cond, { %$attrs, for => 'update'} );
#          $row = $rs->next
#            or croak "Atomic update_or_create failed: query didn't return a row";
#          $rs->next
#            and croak "Atomic update_or_create failed: query returned more than one row";
         $row->update($cond);
       }
       $schema->svp_release;
       return $row;
     }); # txn_do
}

=head1 RATIONALE

Some people have questioned the need for this component, apparently not
understanding what the race condition in the existing update_or_create() is,
or why it is a problem. This section tries to clarify that.

update_or_create() works by first doing a SELECT query to find any rows
matching the unique constraints, and then does an INSERT if no row was
found, or an UPDATE if one was. There is thus a critical section between the
SELECT and the INSERT/UPDATE. This is not a theoretical issue either: it
turned out to be a show-stopper in a Catalyst application I was writing,
hence why I was prompted to write a fix.

Here's how the race might happen if two processes try to insert the same row
and hit the critical section:

 Process 1        Process 2

 SELECT * FROM row WHERE uniq_col = 'data';
                  SELECT * FROM row WHERE uniq_col = 'data';

(both processes see that there is no row and decide to do an INSERT.)

 INSERT INTO row (uniq_col, ...) VALUES ('data', ...);
                  INSERT INTO row (uniq_col, ...) VALUES ('data', ...);

Assuming the database also has a UNIQUE constraint on the uniq_col column,
the second INSERT will fail with a constraint check. If the datbase omitted
the constraint, we now have two rows with the same data in a supposedly
unique column. Either way is not acceptable behaviour.

Wrapping this in a transaction does not help either. If anything, it
potentially widens the critical section because the result of the INSERT is
not visible until the transaction is committed.

A race-safe version requires the use of savepoints, at least on PostgreSQL.
Within a savepoint, one attempts the INSERT. If the INSERT succeeds, we are
done. If it fails with a constraint check, we know the row already exists,
so perform a SELECT ... FOR UPDATE followed by an UPDATE. This code is now
race-safe.

=head1 AUTHOR

Peter Corlett, C<< <abuse at cabal.org.uk> >>

=head1 CAVEATS

The atomic operations rely upon the database having sensible UNIQUE
constraints set so that the INSERT of the conflicting row will fail. If this
is not the case, your database may gain duplicate "unique" rows. You will
usually discover this when you try to C<< $rs->find >> the row later and get
a DBIC warning about multiple rows being found. Consider using
DBIx::Class::Schema::Loader to keep things in sync.

atomic_update_or_create() will still bump the table's sequence even if it
updates a row. Thus, your rows may not have sequential IDs.

=head1 BUGS

This has only been tested on PostgreSQL, and will probably keel over (but
fail safe) on MySQL.

=head1 ACKNOWLEDGEMENTS

This relies on the new SAVEPOINT support in DBIC 0.08100, without which this
module would not be possible.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Peter Corlett, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of DBIx::Class::ResultSet::Atomic
