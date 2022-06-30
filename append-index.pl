#!/usr/bin/env perl
# Copyright (C) 2022  Alex Schroeder <alex@gnu.org>
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
use XML::LibXML;

undef $/;
my $doc = XML::LibXML->load_html(string => <STDIN>);

# avoid bronze golem!
my @nodes = $doc->findnodes('/html/body/p/*[position()=1][name()="strong"]');
my $id = 'spell001';
my %spells;
for my $node (@nodes) {
  my $content = $node->textContent;
  next unless length($content) > 1;
  die "$content\n" if $content =~ /^bron/;
  $spells{$content} = $id;
  $node->setAttribute('id', $id++);
  $node->setAttribute('class', 'indexed');
}
my @body = $doc->findnodes('//body');
$body[0]->appendTextNode("\n");
my $div = XML::LibXML::Element->new('div');
$div->setAttribute('id', 'index');
$body[0]->appendChild($div);
$div->appendTextNode("\n");
my $h2 = XML::LibXML::Element->new('h2');
$h2->appendTextNode('Index');
$div->appendChild($h2);
$div->appendTextNode("\n");
for my $spell (sort keys %spells) {
  my $p = XML::LibXML::Element->new('p');
  $div->appendChild($p);
  my $an = XML::LibXML::Element->new('a');
  $an->appendTextNode($spell);
  $an->setAttribute('href', '#' . $spells{$spell});
  $p->appendChild($an);
  $p->appendTextNode("\n");
}

print $doc;
