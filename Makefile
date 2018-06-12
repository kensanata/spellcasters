CSS=spellcasters.css

%.pdf: %.html
	weasyprint $< $@

%.html: %.md
	md2html $<
