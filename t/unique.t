#!/usr/bin/env perl
# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>
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

my @others = qw(README.md Foreword.md Spellcasters.md);
my @files = grep {
  my $file = $_;
  none { $_ eq $file } @others;
} <"*.md">;

my %spells;
my %source;

for my $file (@files) {
  my $octets = read_file($file);
  my $string = decode("UTF-8", $octets);
  while ($string =~ /^\*\*([^*]+)\*\*( .*?)\n\n/gms) {
    my $name = $1;
    next if $name eq '...';
    my $description = $2;
    ok(not(exists $source{$name}), "$name is a new spell");
    if (exists $source{$name}) {
      if ($description ne $spells{$name}) {
	diag "Duplicate $name for $file, first seen in $source{$name} (but with different description)\n";
	diag "→ $description\n";
	diag "→ $spells{$name}\n";
      } else {
	diag "Duplicate $name for $file, first seen in $source{$name}\n";
      }
      next;
    }
    $spells{$name} = $description;
    $source{$name} = $file;
  }
}

done_testing;
