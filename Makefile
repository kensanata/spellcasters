CSS=spellcasters.css

%.pdf: %.html
	weasyprint $< $@

%.html: %.md
	python3 -m markdown --extension=markdown.extensions.tables --file=$@ $<
