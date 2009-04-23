package Statistics;
use base 'DBIx::Class::Storage::Statistics';

sub print {
  my($self, $string) = @_;
  print STDERR "[$$] $string";
}

1;

