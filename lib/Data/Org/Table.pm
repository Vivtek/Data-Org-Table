package Data::Org::Table;

use 5.006;
use strict;
use warnings;

use base qw(Data::Table);
use Scalar::Util 'blessed';
use Carp;

=head1 NAME

Data::Org::Table - Data::Table with some added features

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The L<Data::Table> module is a stable, actively updated module that provides services related to tabular data - essentially
the data structure underlying a spreadsheet. I like it a lot, but I also do a lot of work with L<Iterator::Records>, and so
I wanted a table module that worked with record iterators. This is that module. It simply subclasses L<Data::Table> and
adds some features that make iterator work easier.

See L<Data::Table> for extensive documentation in how to work with tables. I will only document my extensions here.

=head1 LOADING AND EMITTING RECORD STREAMS

The most important additional functionality I need is simply to read a record stream into a Data::Table buffer, and
extract an Iterator::Records object from an existing table.

=head2 fromItrecs (Iterator::Records object, [limit])

This works analogously to the rest of the from... methods, creating a new table from a record stream.

 $i = Iterator::Records->new (..., [...]);
 $t = Data::Table::fromItrecs ($i);
 
The resulting table has the same column headings as the iterator.

If you don't want the entire iterator, you can limit the number of rows read with the optional "limit" parameter.

=cut

sub fromItrecs {
   my ($class, $iterator, $limit) = @_;
   my $t = new Data::Org::Table ($iterator->load($limit), $iterator->fields(), 0);
   #bless ($t, $class);
}

=head2 iterator()

This overrides the native Data::Tab function, which returns an iterator of hashrefs for each row of the table, and instead
returns an Iterator::Records object on the rows instead. The column names are, of course, the same as the table's.

=cut

sub iterator {
   my ($self) = @_;
   Iterator::Records->new (
      sub {
         my $index = 0;
         sub {
            return if $index >= $self->nofRow;
            $self->rowRef($index);
         }
      },
      $self->header
   );
}

=head1 TEXT OUTPUT

Data::Table provides CSV and TSV output (as well as Wiki and HTML), but I tend to do a lot with flatter text, primarily tables like this:
 
 +------+------+
 | fld1 | fld2 |
 +------+------+
 | 1    | 2    |
 +------+------+

And like this:

 fld1 fld2
 1    2

=head2 show, show_decl, show_generic (separator, show_header, show_rule)

The C<show> method shows the table contents in the first format above, while C<show_decl> uses the second.

The C<show_generic> takes a field separator and two flags; the first is either a scalar (if true, shows the table's headers) or an arrayref of the headers to show instead of
the table's headers. The second flag is either a scalar (if true, show the +---+ lines) or an arrayref of two characters to use instead of '-' and '+'.

=cut

sub show { shift->show_generic ('|', 1, 1); }
sub show_decl { shift->show_generic ('', 1, 0); }
sub show_generic {
   eval { require Text::Table; };
   croak "Text::Table not installed" if $@;

   my $self = shift;
   my $sep = shift;
   my $headers = shift;
   my $rule = shift;
   
   my @headers = ();
   if ($headers) {
      if (ref $headers eq 'ARRAY') {
         @headers = @$headers;
      } else {
         @headers = $self->header;
      }
   }
   my @c = ();
   if (defined $sep and @headers) {
      push @c, \$sep if defined $sep;
      foreach my $h (@headers) {
         push @c, $h, \$sep;
      }
   }
   my $t = Text::Table->new($sep ? @c : @headers);
   $t->load (@{$self->rowRefs});
   
   my @rule_p = ('-', '+');
   @rule_p = @$rule if $rule and ref $rule eq 'ARRAY';
   my $rule_text = '';
   $rule_text = $t->rule(@rule_p) if @headers and $rule;

   my $text = '';
   $text .= $rule_text;
   $text .= $t->title() if @headers;
   $text .= $rule_text;
   $text .= $t->body();
   $text .= $rule_text;
   
   $text =~ s/ +$//mg;
   return $text;
}


# Data::Table is not really written for subclassing; all its creator methods except new simply create Data::Table objects instead of Data::Org::Table.
# So here are wrappers for all the creator methods. joy!

sub match_pattern {
   my $self = shift;
   my $ret = $self->SUPER::match_pattern(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub match_pattern_hash {
   my $self = shift;
   my $ret = $self->SUPER::match_pattern_hash(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub match_string {
   my $self = shift;
   my $ret = $self->SUPER::match_string(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub rowMask {
   my $self = shift;
   my $ret = $self->SUPER::rowMask(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub subTable {
   my $self = shift;
   my $ret = $self->SUPER::subTable(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub clone {
   my $self = shift;
   my $ret = $self->SUPER::clone(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub fromCSV {
   my $self = shift;
   my $ret = $self->SUPER::fromCSV(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub fromTSV {
   my $self = shift;
   my $ret = $self->SUPER::fromTSV(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub fromSQL {
   my $self = shift;
   my $ret = $self->SUPER::fromSQL(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub join {
   my $self = shift;
   my $ret = $self->SUPER::join(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub melt {
   my $self = shift;
   my $ret = $self->SUPER::melt(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub group {
   my $self = shift;
   my $ret = $self->SUPER::group(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub pivot {
   my $self = shift;
   my $ret = $self->SUPER::pivot(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}
sub fromFile {
   my $self = shift;
   my $ret = $self->SUPER::fromFile(@_);
   bless ($ret, ref($self)) if ref $ret;
   $ret;
}


=head1 AUTHOR

Michael Roberts, C<< <michael at vivtek.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-data-org-table at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Org-Table>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::Org::Table


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Org-Table>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-Org-Table>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-Org-Table>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-Org-Table/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2019 Michael Roberts.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Data::Org::Table
