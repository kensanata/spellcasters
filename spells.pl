use Modern::Perl;
use File::Slurp;
my %spells;
my %source;
for my $f (@ARGV) {
  my $text = read_file($f);
  while ($text =~ /^\*\*([^*]+)\*\*( .*?)\n\n/gms) {
    my $name = $1;
    next if $name eq '...';
    my $description = $2;
    $description =~ s/\*([^*]+)\*/<em>$1<\/em>/g;
    if (exists $source{$name}) {
      if ($description ne $spells{$name}) {
	warn "Duplicate $name for $f, first seen in $source{$name} (but with different description)\n";
	warn "→ $description\n";
	warn "→ $spells{$name}\n";
      } else {
	warn "Duplicate $name for $f, first seen in $source{$name}\n";
      }
      next;
    }
    $spells{$name} = $description;
    $source{$name} = $f;
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
