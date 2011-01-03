#---------------------------------------------------------------------
package DateTime::Format::XMLTV;
#
# Copyright 2011 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created: 28 Dec 2010
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# ABSTRACT: Parse and format XMLTV dates and times
#---------------------------------------------------------------------

use 5.008;
use strict;
use warnings;

our $VERSION = '0.01';
# This file is part of {{$dist}} {{$dist_version}} ({{$date}})

#=====================================================================
use DateTime::Format::Builder 0.80 (
  parsers => {
    parse_datetime => [
      [ preprocess => \&_parse_tz ],
      {
        length => 14,
        params => [ qw( year month day hour minute second ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/,
      },
      {
        length => 12,
        params => [ qw( year month day hour minute ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/,
      },
      {
        length => 10,
        params => [ qw( year month day hour ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)$/,
      },
      {
        length => 8,
        params => [ qw( year month day ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)$/,
      },
      {
        length => 6,
        params => [ qw( year month ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)$/,
      },
      {
        length => 4,
        params => [ qw( year ) ],
        regex  => qr/^(\d\d\d\d)$/,
      },
    ],
  },
);

*parse_date = \&parse_datetime;
*parse_time = \&parse_datetime; # XMLTV has no time-only format

#---------------------------------------------------------------------
sub _parse_tz
{
  my %args = @_;
  my ($date, $p) = @args{qw( input parsed )};

  $date =~ s/\s+\z//;           # Strip any trailing whitespace

  if ($date =~ s/\s+(\S+)\z//) {
    $p->{time_zone} = $1;
  } else {
    $p->{time_zone} = 'UTC';
  }

  return $date;
} # end _parse_tz

#---------------------------------------------------------------------
sub format_date
{
  my ($self, $dt) = @_;

  return $dt->ymd('');
}

sub format_datetime
{
  my ($self, $dt) = @_;

  return($dt->ymd('') . $dt->hms('') . ' ' .
         DateTime::TimeZone->offset_as_string($dt->offset));
}

*format_time = \&format_datetime; # XMLTV has no time-only format

#=====================================================================
# Package Return Value:

1;

__END__

=head1 SYNOPSIS

  use DateTime::Format::XMLTV;
  my $dt = DateTime::Format::XMLTV->parse_datetime('20101230150000 +0000');

  # 20101230150000 +0000
  DateTime::Format::XMLTV->format_datetime($dt);

=head1 DESCRIPTION

DateTime::Format::XMLTV understands the datetime format used by
L<XMLTV> files.

To quote the XMLTV DTD:

=over

All dates and times in this DTD follow the same format, loosely based
on ISO 8601.  They can be C<YYYYMMDDhhmmss> or some initial
substring, for example if you only know the year and month you can
have C<YYYYMM>.  You can also append a timezone to the end; if no
explicit timezone is given, UTC is assumed.  Examples:
S<C<200007281733 BST>>, C<200209>, S<C<19880523083000 +0300>>.
S<(BST == +0100.)>

=back

=head1 METHODS

This class offers the following methods.

=over 4

=item * C<< parse_datetime($string) >>

=item * C<< parse_date($string) >>

=item * C<< parse_time($string) >>

These are 3 names for the same method.  Given a string containing an
XMLTV date, this method will return a new C<DateTime> object.  If no
time zone is specified in the string, UTC is assumed.

If given an improperly formatted string, this method may die.

=item * C<< format_date($datetime) >>

Given a C<DateTime> object, this returns a string in C<YYYYMMDD> format.

=item * C<< format_time($datetime) >>

=item * C<< format_datetime($datetime) >>

Given a C<DateTime> object, this returns a string in
S<C<YYYYMMDDhhmmss +HHMM>> format (where C<+HHMM> is the time zone
offset).  C<format_time> is an alias for C<format_datetime>, because
XMLTV has no time-only format.

=back

=head1 SEE ALSO

The XMLTV File format: L<http://wiki.xmltv.org/index.php/XMLTVFormat>

The XMLTV DTD:
L<http://xmltv.cvs.sourceforge.net/*checkout*/xmltv/xmltv/xmltv.dtd>
