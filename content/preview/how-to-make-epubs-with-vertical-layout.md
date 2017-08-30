---
title: How to make EPUB ebooks with vertical layout?
kind: article
created_at: '2018-08-29 00:00:00 +0800'
slug: how-to-make-epub-ebooks-with-vertical-layout
preview: true
---

For years I have been reading Chinese/Japanese novels on Kindle or
Google Play Book. While most Japanese books were well-formatted to
scroll from right to left and texts were displayed vertically like real
books, literally none of the Chinese books I have read prints text vertically
or scrolls from right to left.

In this post, I demonstrating how to convert Chinese EPUB ebook from
horizontal left-to-right to vertical right-to-left layout.

<figure>
<img src='./rl-demo.png' style='max-width: 15em;'/>
<figcaption>Above: horizontal left-to-right layout. Below: vertical
right-to-left layout.</figcaption>
</figure>

If you are interested in following the step-by-step process, you can download the
EPUB I used here. Althought it'll make your life easier by using advanced EPUB editors
like Sigil or Calibre, the ZIP archiver and text editors that came with your system
will work as well.

## Structure of an EPUB file

An EPUB file is essentially a ZIP archive containing HTML files, CSS
stylesheets, images and some files containing metadata for the ebook.

Because EPUB is based on the widely adopted ZIP format, its content can
be easily extracted with ZIP archiver that bundles with most operating
systems. You may try to extract the content from my sample EPUB file by:

~~~ bash
$ unzip horizontal-sample.epub
Archive:  horizontal-sample.epub
 extracting: mimetype
  inflating: toc.ncx
  inflating: OEBPS/Text/Section001.xhtml
  inflating: OEBPS/Style/style.css
  inflating: OEBPS/content.opf
  inflating: META-INF/container.xml
~~~

The file `mimetype`, as the name suggests, specifies the MIME type of
the ebook. `toc.ncx` serves as a table of content.
`META-INF/container.xml` contains the path to the root file, which is
`content.opf`. `content.opf` contains a list of all resources (like
HTML/CSS files) in the ebook and a `<spine>` tag that helps specify in
which directions the pages are flipped.

Purposes of files in `OEBPS/Text` and `OEBPS/Style` are self-explanatory.

## CSS rules for vertical layout

One CSS rules that decides the printing behavior of a
document is `writing-mode`.

`writing-mode` can have these values: `horizontal-tb` (this is the initial value),
`vertical-rl` and `vertical-lr`. To print characters vertically from
right to left, `writing-mode` should be set to `vertical-rl`.

Now open `OEBPS/Style/styles.css` and modify rules in the `html`
selector to the following.

~~~ css
/* OEBPS/Style/styles.css */
@charset "utf-8";
html {
  -epub-writing-mode: vertical-rl;
        writing-mode: vertical-rl;
 }
/* ... */
~~~

Since we are simply dealing with HTML and CSS files, we can go ahead and
open `OEBPS/Text/Section001.xhtml` in a browser and see the change.

<figure>
<img src='./writing-mode-initial.png' style='max-width: 15em;'/>
<figcaption>Before: text printed horizontally from the left</figcaption>
</figure>

<figure>
<img src='./writing-mode-vertical-rl.png' style='max-width: 5em;'/>
<figcaption>After: text printed vertically from the right</figcaption>
</figure>

Note that `writing-mode` in EPUB 3 standard adopted the `-epub-` prefix, which
borrows properties from CSS Writing Modes 2011-04-28 because when EPUB 3
was out, CSS Writing Modes was still a W3C working draft. The rule might
have changed, or will change in the future, yet `-epub-` prefix guarantees
behavior consistent to when EPUB 3 standard was defined.

## Scrolling from right to left

By default EPUB documents are scrolled from left to right 

## Packing up an EPUB file

## References
http://epubzone.org/news/epub-3-and-global-language-support
