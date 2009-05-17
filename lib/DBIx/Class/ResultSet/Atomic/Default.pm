package DBIx::Class::ResultSet::Atomic::Default;
use DBIx::Class::ResultSet;
use base qw/ DBIx::Class::ResultSet /;

__PACKAGE__->load_components(qw/ ResultSet::Atomic /);

1;

=head1 NAME

DBIx::Class::ResultSet::Atomic::Default - Helper class for DBIx::Class::ResultSet::Atomic

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

 # in your Schema class
 __PACKAGE__->load_namespaces(
     default_resultset_class => '+DBIx::Class::ResultSet::Atomic::Default',
 );


DESCRIPTION

This helper class may be used as a default resultset class for your
application in cases where you don't care about writing resultsets for (all
of) your table classes, but still want to be able to use the atomic_*
methods on resultsets.

Obviously, if you then decide to add your own ResultSet classes, you will
need to load the ResultSet::Atomic component in those.

=head1 AUTHOR

Peter Corlett, C<< <abuse at cabal.org.uk> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Peter Corlett, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of DBIx::Class::ResultSet::Atomic
