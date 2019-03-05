#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Org::Table;
use Iterator::Records;
use Data::Dumper;

my $i = Iterator::Records->new([[1, 2], [3, 4]], ['field1', 'field2']);
my $t = Data::Org::Table->fromItrecs ($i);
is ($t->tsv, <<"EOF", 'table contents');
field1\tfield2
1\t2
3\t4
EOF

is ($t->show, <<EOF, 'show output');
+------+------+
|field1|field2|
+------+------+
|1     |2     |
|3     |4     |
+------+------+
EOF

is ($t->show_decl, <<EOF, 'show_decl output');
field1 field2
1      2
3      4
EOF

# Test a subclassed creator method to be sure we still have a Data::Org::Table afterwards.
my $st = $t->subTable([0, 1], [1]);
is ($st->show_decl, <<EOF, 'subTable returns Data::Org::Table');
field2
2
4
EOF



done_testing ();
