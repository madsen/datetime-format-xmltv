#! /usr/bin/perl
#---------------------------------------------------------------------
# Test parsing XMLTV dates:
#---------------------------------------------------------------------

use strict;
use warnings;
use Test::More 0.88;            # done_testing

use DateTime::Format::XMLTV;

my $utc = DateTime::TimeZone->new(name => 'UTC');

#---------------------------------------------------------------------
sub fmt
{
  my $dt = shift;

  $dt->format_cldr('yyyy-MM-dd HH:mm:ss Z  (') .
  $dt->clone->set_time_zone($utc)->format_cldr('yyyy-MM-dd HH:mm:ss Z)');
} # end fmt

#---------------------------------------------------------------------
my @tests = (
  ['20110102060000 -0600', 2011,  1,  2, 12],
  ['20110102060000 +0930', 2011,  1,  1,  20, 30],
  ['20110102060000 +0000', 2011,  1,  2,  6],
  ['20110102060000 -0000', 2011,  1,  2,  6],
  ['20110102060000 UTC',   2011,  1,  2,  6],
  ['20110102060000',       2011,  1,  2,  6],
  ['201101020600',         2011,  1,  2,  6],
  ['2011010206',           2011,  1,  2,  6],
  ['20110102',             2011,  1,  2],
  ['201101020600 +0000',   2011,  1,  2,  6],
  ['2011010206 +0000',     2011,  1,  2,  6],
  ['20110102 +0000',       2011,  1,  2],
  ['199012',               1990, 12],
  ['1999',                 1999],
  ['20010203040506 UTC',   2001,  2,  3,  4,  5,  6],
  ['200102030405',         2001,  2,  3,  4,  5],
  ['2001020304',           2001,  2,  3,  4],
  ['20010203',             2001,  2,  3],
  ['200102',               2001,  2],
  ['2001',                 2001],
);

plan tests => scalar @tests;

for my $test (@tests) {
  my ($string, $year, $month, $day, $hour, $min, $sec) = @$test;

  my $got = DateTime::Format::XMLTV->parse_datetime($string);

  my $expected = DateTime->new(
    year => $year, month => $month||1, day => $day||1,
    hour => $hour||0, minute => $min||0, second => $sec||0,
    time_zone => $utc
  );

  ok(DateTime->compare_ignore_floating($got, $expected) == 0, "parse $string")
      or diag("     Got: ", fmt($got), "\nExpected: ", fmt($expected));
} # end for each $test in @tests

done_testing;
