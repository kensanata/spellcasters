CSS=spellcasters.css

# Create a PDF for every Markdown file
NO_CASTERS=README.md Foreword.md Spellcasters.md
CASTERS=$(sort $(filter-out $(NO_CASTERS),$(wildcard *.md)))
ALL=$(patsubst %.md,%.pdf,$(CASTERS))

all: $(ALL) Spellcasters.pdf

%.pdf: %.html spellcasters.css
	weasyprint --stylesheet spellcasters.css $< $@

Spellcasters.html.tmp: Spellcasters.md

Spellcasters.md: Foreword.md $(CASTERS)
	cat $^ > $@

%.html.tmp: %.md
	python3 -m markdown \
		--extension=markdown.extensions.tables \
		--extension markdown.extensions.smarty \
		--file=$@ $<

%.html: %.html.tmp spellcasters-prefix spellcasters-suffix
	cat spellcasters-prefix $< spellcasters-suffix > $@

upload: $(ALL) Spellcasters.pdf
	scp -P 882 $^ alexschroeder.ch:alexschroeder.ch/pdfs/spellcasters/
