CSS=spellcasters.css

# Create a PDF for every Markdown file
NO_CASTERS=README.md Cover.md Foreword.md Spellcasters.md Spellcasters-no-cover.md
CASTERS=$(sort $(filter-out $(NO_CASTERS),$(wildcard *.md)))
ALL=$(patsubst %.md,%.pdf,$(CASTERS))

all: $(ALL) Spellcasters.pdf

%.pdf: %.html spellcasters.css
	weasyprint $< $@

Spellcasters.html.tmp: Spellcasters.md

Spellcasters.md: Cover.md Foreword.md $(CASTERS)
	cat $^ > $@

Spellcasters-no-cover.md: Foreword.md $(CASTERS)
	cat $^ > $@

%.html.tmp: %.md
	python3 -m markdown \
		--extension=markdown.extensions.tables \
		--extension markdown.extensions.smarty \
		--file=$@ $<

%.html: %.html.tmp spellcasters-prefix spellcasters-suffix
	cat spellcasters-prefix $< spellcasters-suffix > $@

Spellcasters-no-cover.html: Spellcasters-no-cover.html.tmp spellcasters-prefix spellcasters-suffix
	cat spellcasters-prefix $< spellcasters-suffix > $@

Cover-epub.jpg: Spellcasters.pdf
	convert -density 150 "$<[0]" -gravity center -crop 90%x+0+0 $@

Spellcasters.epub: Spellcasters-no-cover.html Cover-epub.jpg
	ebook-convert $< $@ --embed-all-fonts --authors "Alex Schroeder" \
		--title "Halberds & Helmets Spellcasters" \
		--chapter "//h:h2" \
		--preserve-cover-aspect-ratio --cover Cover-epub.jpg

upload: $(ALL) Spellcasters.pdf Spellcasters.epub
	rsync --rsh="ssh -p 882" \
		$^ alexschroeder.ch:alexschroeder.ch/pdfs/spellcasters/

wiki: $(CASTERS)
	perl spells.pl $^

test:
	prove t
