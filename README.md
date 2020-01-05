This repository contains spellcasters and their spellbooks for any old
school role-playing game. Personally, I use them for my
[Halberds & Helmets](https://alexschroeder.ch/wiki/Halberds_and_Helmets)
games.

The generated PDFs are hosted
[on my site](https://alexschroeder.ch/pdfs/spellcasters/).

## Toolchain

If you're interested in the toolchain I'm using: I use Python's
[Markdown](https://pypi.org/project/Markdown/) processor to turn
Markdown into HTML and I turn the HTML into PDF using
[WeasyPrint](https://pypi.org/project/WeasyPrint/).

## Fonts

The CSS specifies "fbb", "Palatino" for the text body. The font I've
used is fbb from Debian package `texlive-fonts-extra`. The problem is
that these fonts are not immediately available to `pango`, which means
that `fc-list` needs to find. The easiest solution was to symlink the
files from `/usr/share/texlive/texmf-dist/fonts/opentype/public/fbb/`
to `~/.local/share/fonts/`.

The CSS for the title page specifies "Gill Sans", "Gillus ADF",
"Helvetica". Somehow the actual font that gets picked is TeX Gyre
Heros (a replacement for Helvetica; it is based URW Nimbus Mono L).
You can get this font from Debian packages `fonts-texgyre`.
