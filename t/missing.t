#!/usr/bin/env perl
# Copyright (C) 2001-2019  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use Modern::Perl '2018';
use File::Slurp qw(read_file);
use List::Util qw(none);
use Encode qw(decode);
use Test::More;

my $verbose = grep { $_ eq '-v' } @ARGV;

my @others = qw(README.md Foreword.md Spellcasters.md);
my @files = grep {
  my $file = $_;
  none { $_ eq $file } @others;
} <"*.md">;

ok(@files > 0, "At least one file found");

my %required = (1 => 3, 2 => 3, 3 => 3, 4 => 3, 5=> 2);
my @warnings;
for my $file (@files) {
  my %spells;
  my $octets = read_file($file);
  my $string = decode("UTF-8", $octets);
  while ($string =~ /^\*\*([^.*\n]+)\*\* \((\d)\)/gm) {
    my $spell = $1;
    my $circle = $2;
    $spells{$circle}++;
    print "$file: $spell ($circle)\n" if $verbose;
  }
  my @missing;
  if (not keys %spells) {
    push(@missing, "no spells");
  } else {
    for my $circle (sort keys %required) {
      if (not $spells{$circle}) {
	push(@missing, "($circle) no spells");
      } elsif ($spells{$circle} != $required{$circle}) {
	push(@missing, "($circle) $spells{$circle} instead of $required{$circle}");
      }
    }
  }
  ok(@missing == 0, "$file: spells OK");
  diag("$file: @missing") if @missing;
}

done_testing;
