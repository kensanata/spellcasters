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

my %spells;
my %source;

for my $file (@ARGV) {
  my $text = read_file($file); # octets!
  while ($text =~ /^\*\*([^*]+)\*\*( .*?)\n\n/gms) {
    my $name = $1;
    next if $name eq '...';
    my $description = $2;
    $description =~ s/\*([^*]+)\*/<em>$1<\/em>/g;
    next if exists $source{$name};
    $spells{$name} = $description;
    $source{$name} = $file;
  }
}
print read_file('spellcasters-prefix');
say "<h1>All the Spells</h1>";
say "<p>The spell name in <strong>bold</strong>, followed by the spell circle in parenthesis (1–5).";
for my $name (sort keys %spells) {
  my $id = lc($name);
  $id =~ s/ /-/g;
  say("<p id=\"$id\"><strong>$name</strong>$spells{$name}</p>");
}
print read_file('spellcasters-suffix');
