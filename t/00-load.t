#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Data::Org::Table' ) || print "Bail out!\n";
}

diag( "Testing Data::Org::Table $Data::Org::Table::VERSION, Perl $], $^X" );
