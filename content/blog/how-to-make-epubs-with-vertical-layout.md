---
title: How to make EPUB ebooks with vertical layout?
kind: article
created_at: '2017-08-29 00:00:00 +0800'
slug: how-to-make-epub-ebooks-with-vertical-layout
abstract: 'Make CJK epub ebooks print texts vertically, just like how
they are printed physically'
preview: false
---

For years I have been reading Chinese/Japanese novels on Kindle and
Google Play Book. While most Japanese books were formatted to
scroll from right to left and display texts vertically like real
books, literally none of the Chinese books I have read do the same
thing. The more I am used to reading physical books, the more this bugs
me.

In this post, I demonstrating how to convert Chinese EPUB ebook from
horizontal left-to-right to vertical right-to-left layout.

<figure>
<img src='./rl-demo.png' style='max-width: 15em;'/>
<figcaption>Above: horizontal left-to-right layout. Below: vertical
right-to-left layout.</figcaption>
</figure>

If want to follow this step-by-step guide, you can download a sample
EPUB [here](https://github.com/tommyku/vertical-epub/raw/master/static/horizontal.epub).
Althought using advanced EPUB editors like Sigil or Calibre will make your life easier,
the ZIP archiver and text editors that came with your system
will work just as well.

## Structure of an EPUB file

A EPUB file is essentially a ZIP archive containing HTML files, CSS
stylesheets, images and some files with metadata for the ebook.

Because EPUB is based on the widely adopted ZIP format, its content can
be easily extracted with ZIP archiver that bundles with most operating
systems. You may try to extract the content from my sample EPUB file by:

~~~ bash
$ unzip horizontal.epub
Archive:  horizontal.epub
 extracting: mimetype
  inflating: OEBPS/toc.ncx
  inflating: OEBPS/Text/Section001.xhtml
  inflating: OEBPS/Style/style.css
  inflating: OEBPS/content.opf
  inflating: META-INF/container.xml
~~~

The file `mimetype`, as the name suggests, specifies the MIME type of
the ebook. `toc.ncx` serves as a table of content.
`META-INF/container.xml` indicates the path to the root file
`content.opf`. `content.opf` contains a list of all resources (like
HTML/CSS files) in the ebook and a `<spine>` tag helps specifying page
direction.

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

If the EPUB you are editing does not have a `style.css` file, you
must add it inside `<head>` of each `.html` and `.xhtml` file, and add the file path to
`<manifest>` tag in `content.opf` yourself.

~~~ xml
<!-- OEBPS/content.opf -->
<?xml version="1.0" encoding="UTF-8" ?>
<package version="2.0" xmlns="http://www.idpf.org/2007/opf" unique-identifier="PrimaryID">
  ...
  <manifest>
    ...
    <item id="stylesheet" href="./Style/style.css"  media-type="text/css" />
    ...
  </manifest>
  ...
</package>
~~~

~~~ html
<!-- OEBPS/Text/Section001.xhtml -->
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    ...
    <link rel="stylesheet" href="../Style/style.css" type="text/css" />
  </head>
  <body>
    ...
  </body>
</html>
~~~

Note that `writing-mode` in EPUB 3 standard adopted the `-epub-` prefix, which
borrows properties from CSS Writing Modes 2011-04-28 because when EPUB 3
was out, CSS Writing Modes was still a W3C working draft. The rule might
have changed, or will change in the future, yet `-epub-` prefix guarantees
behavior consistent to when EPUB 3 standard was defined.

## Scrolling from right to left

Most reading systems render the pages from left to right, but there's an optional
attribute that can reverse the page direction.

In `OEBPS/content.opf` there is a tag `<spine>`. You can set its
`page-progression-direction` attribute to `rtl` to make the pages scroll
from right to left.

~~~ xml
<!-- OEBPS/content.opf -->
<?xml version="1.0" encoding="UTF-8" ?>
<package version="2.0" xmlns="http://www.idpf.org/2007/opf" unique-identifier="PrimaryID">
  ...
  <spine toc="..." page-progression-direction="rtl">
    ...
  </spine>
  ...
</package>
~~~

To test this, you will have to load the EPUB file into your ebook reader
or use an ebook reader because this is a EPUB behavior, not HTML/CSS
which we saw in last section.

## Packing up a EPUB file

EPUB files are ZIP archives. You can use a ZIP archiver to pack up the
files into a EPUB file. In Linux you can do this.

~~~ bash
$ zip -0 vertical.epub mimetype
$ zip -r vertical.epub META-INF OEBPS
~~~

First `mimetype` is added to a ZIP archive with file extension `.epub`,
then `META-INF` and `OEBPS` are added because `mimetype` should appear
at the beginning of the EPUB file.

Now you can add the EPUB file into your favorite ebook reader and enjoy
your document in a vertical, right-to-left layout.

You can find the outcome of the example file [here](https://github.com/tommyku/vertical-epub/raw/master/static/vertical.epub).

## References

This post is inspired by or has referenced to these pages:

- [EPUB Open Container Format (OCF) 3.0](http://www.idpf.org/epub/30/spec/epub30-ocf.html)
- [EPUB 3 and Global Language Support \| EPUBZone](http://epubzone.org/news/epub-3-and-global-language-support)
- [Learning About EPUB: Structure and Content - Altova Blog](https://blog.altova.com/learning-about-epub-structure-and-content/)
- [如何制作竖排文字的 Mobi 格式电子书? - 知乎](https://www.zhihu.com/question/21234737)
