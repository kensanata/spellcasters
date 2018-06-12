This repository contains spellcasters and their spellbooks for any old
school role-playing game. Personally, I use them for my
[Halberds & Helmets](https://alexschroeder.ch/wiki/Halberds_and_Helmets)
games.

## Toolchain

If you're interested in the toolchain I'm using: I use Pyhton's
[Markdown](https://pypi.org/project/Markdown/) processor and the
following little script to turn the text files into HTML files:

```
#!/usr/bin/env python3
import sys
import markdown

class md2html:
    def convert(files):
        for file in files:
            with open(file, encoding="utf-8") as input:
                text = input.read()
                html = markdown.markdown(
                    text,
                    extensions=['markdown.extensions.tables'])
                name = file.replace('.md', '.html')
                with open(name, mode="w", encoding="utf-8",
                          errors="xmlcharrefreplace") as output:
                    output.write(html)

if __name__ == "__main__":
    md2html.convert(sys.argv[1:])
```

And I turn the HTML into PDF using
[WeasyPrint](https://pypi.org/project/WeasyPrint/).

