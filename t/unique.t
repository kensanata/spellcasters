#!/usr/bin/env perl
# Copyright (C) 2019–2020  Alex Schroeder <alex@gnu.org>
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

my $makefile = read_file('Makefile');
$makefile =~ s/\\\n/ /g; # undo continuation lines
my ($nocasters) = $makefile =~ /^NO_CASTERS=(.*)/m;
my @others = split ' ', $nocasters; # whitespace split
my @files = grep {
  my $file = $_;
  none { $_ eq $file } @others;
} <"*.md">;

my %description;
my %source;

for my $file (@files) {
  my $mu = substr $file, 0, -3;
  my $octets = read_file($file);
  my $string = decode("UTF-8", $octets);
  while ($string =~ /^\*\*([^*]+)\*\*( .*?)\n\n/gms) {
    my $name = $1;
    next if $name eq '...';
    my $description = $2;
    $description{$name}->{$description} = 1;
    push(@{$source{$name}}, $mu);
  }
}

for my $name (sort keys %source) {
  ok @{$source{$name}} == 1, "$name is a unique spell";
  if (@{$source{$name}} > 1) {
    diag "Multiple sources for $name exist: @{$source{$name}}";
  }
  if (keys %{$description{$name}} > 1) {
    diag "Multiple descriptions for $name exist:\n"
	. join("\n", keys %{$description{$name}}, "");
  }
}

done_testing;
