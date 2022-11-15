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
use File::Slurper qw(read_binary);
use List::Util qw(none);
use LWP::UserAgent ();

my %spells;
my %source;
my ($action) = grep /^--/, @ARGV;

if (not $action or $action eq "--help") {
  print <<EOT;
Usage: spells.pl [ACTION] [FILES...]
Action can be one of:
--help     show this message
--assemble assembles the spells into one document
--upload   upload assembled spells to the wiki page
--tables   turn into Hex Describe tables
EOT
}

for my $file (grep !/^--/, @ARGV) {
  my $text = read_binary($file); # octets!
  while ($text =~ /^(\*\*([^*]+)\*\* .*?)(\n\n|\n?\z)/gms) {
    my $name = $2;
    next if $name eq '...';
    next if exists $source{$name};
    my $spell = $1;
    $spells{$name} = $spell;
    $source{$name} = $file;
  }
}

# Add internal links
for my $nm (sort keys %spells) {
  my $spell = $spells{$nm};
  my $changed = 0;
  for my $name (sort keys %spells) {
    $name = lc($name);
    my $id = $name;
    $id =~ s/ /-/g;
    if ($spell =~ s/\*$name\*(?!\*)/[$name](#$id)/i) {
      $changed++;
    }
  }
  $spells{$nm} = $spell if $changed;
}

my $spells = "Each paragraph begins with the **spell name** "
    . "followed by the spell circle in parenthesis (1–5), "
    . "also known as the *spell level*.\n\n";
for my $name (sort keys %spells) {
  my $id = lc($name);
  $id =~ s/ /-/g;
  $spells .= "[:$id]\n";
  $spells .= "$spells{$name}\n\n";
}

if ($action eq "--upload") {
  my $url = 'https://campaignwiki.org/wiki/Spellcasters';
  my %form = (
    frodo => 1,
    username => 'Alex',
    title => 'Spells',
    summary => 'Update',
    text => $spells );

  my $ua = LWP::UserAgent->new;
  my $response = $ua->post( $url, \%form );

  if ($response->code == 302) {
    say "Posted";
  } else {
    die $response->status_line;
  }
} elsif ($action eq "--assemble") {
  $spells =~ s/^\[:.*\]\n//mg;
  print $spells;
} elsif ($action eq "--tables") {
  $spells =~ s/\n+\[:(.*)\]\n/<p id="$1">/g;
  $spells =~ s/\[(.*?)\]\((#.*?)\)/<a class="spell" href="$2">$1<\/a>/g;
  $spells =~ s/\n\s*/ /g;
  print $spells;
}
