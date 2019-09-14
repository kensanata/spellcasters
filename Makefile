CSS=spellcasters.css

# Create a PDF for every Markdown file
NO_CASTERS=README.md Foreword.md Spellcasters.md
CASTERS=$(sort $(filter-out $(NO_CASTERS),$(wildcard *.md)))
ALL=$(patsubst %.md,%.pdf,$(CASTERS))

all: $(ALL) Spellcasters.pdf

%.pdf: %.html spellcasters.css
	weasyprint $< $@

Spellcasters.html.tmp: Spellcasters.md

Spellcasters.md: Foreword.md $(CASTERS)
	cat $^ > $@

%.html.tmp: %.md
	python3 -m markdown \
		--extension=markdown.extensions.tables \
		--extension markdown.extensions.smarty \
		--file=$@ $<

spells.html: $(CASTERS) spells.pl
	perl spells.pl $(CASTERS) > $@

%.html: %.html.tmp spellcasters-prefix spellcasters-suffix
	cat spellcasters-prefix $< spellcasters-suffix > $@

upload: $(ALL) Spellcasters.pdf spells.html spellcasters.css
	rsync --rsh="ssh -p 882" \
		$^ alexschroeder.ch:alexschroeder.ch/pdfs/spellcasters/

test:
	prove t
