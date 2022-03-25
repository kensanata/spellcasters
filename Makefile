CSS=spellcasters.css

# Create a PDF for every Markdown file
NO_CASTERS=README.md \
	Cover-Spellcasters.md Cover-Spells.md \
	Foreword-Spellcasters.md Foreword-Spells.md \
	Spells.md Spells-no-cover.md \
	Spellcasters.md Spellcasters-no-cover.md
CASTERS=$(sort $(filter-out $(NO_CASTERS),$(wildcard *.md)))
ALL=$(patsubst %.md,%.pdf,$(CASTERS))

all: Spellcasters.pdf Spellcasters.epub Spells.pdf Spells.epub

individuals: $(ALL)

upload: Spellcasters.pdf Spellcasters.epub Spells.pdf Spells.epub $(ALL)
	rsync --itemize-changes --archive --compress \
		$^ sibirocobombus:alexschroeder.ch/pdfs/spellcasters/

clean:
	rm -f *.pdf *.epub *.html *.html.tmp Spells.md Spellcasters.md

test:
	prove t

# --- PDF ---

%.pdf: %.html spellcasters.css
	weasyprint $< $@

%.html: %.html.tmp spellcasters-prefix spellcasters-suffix
	cat spellcasters-prefix $< spellcasters-suffix > $@

%.html.tmp: %.md
	python3 -m markdown \
		--extension=markdown.extensions.tables \
		--extension markdown.extensions.smarty \
		--file=$@ $<

%.md: Cover-%.md timestamp Foreword-%.md $(CASTERS)
	cat $^ > $@

# This rule different from Spells-no-cover.md so no pattern matching
Spellcasters-no-cover.md: Foreword-Spellcasters.md $(CASTERS)
	cat $^ > $@

# convert the first page of the PDF to a file
Cover-%.jpg: %.pdf
	convert -density 150 "$<[0]" -gravity center -crop 90%x+0+0 $@

timestamp: $(CASTERS)
	date '+<p class="timestamp">%B %d, %Y</p>' > $@

# --- EPUB ---

Spellcasters.epub: Spellcasters-no-cover.html Cover-Spellcasters.jpg
	ebook-convert $< $@ --embed-all-fonts --authors "Alex Schroeder" \
		--title "Halberds & Helmets Spellcasters" \
		--chapter "//h:h2" \
		--preserve-cover-aspect-ratio --cover Cover-Spellcasters.jpg

Spells.epub: Spells-no-cover.html Cover-Spells.jpg
	ebook-convert $< $@ --embed-all-fonts --authors "Alex Schroeder" \
		--title "Halberds & Helmets Spells" \
		--chapter "//h:h2" \
		--preserve-cover-aspect-ratio --cover Cover-Spells.jpg

Spells.md: Cover-Spells.md timestamp Foreword-Spells.md $(CASTERS)
	cat Cover-Spells.md timestamp Foreword-Spells.md > $@
	perl spells.pl --assemble $^ >> $@

Spells-no-cover.md: Foreword-Spells.md $(CASTERS)
	cat Foreword-Spells.md > $@
	perl spells.pl --assemble $^ >> $@

# --- Wiki ---

wiki: $(CASTERS)
	perl spells.pl --upload $^

# --- Tables for Hex Describe ---

hex-describe: $(CASTERS)
	perl spells.pl --tables $^ > hex-describe.txt

