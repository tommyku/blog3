---
title: Explaining Base64 encoding
kind: article
created_at: '2013-12-28 00:00:00 +0800'
slug: explaining-base64-encoding
abstract: 'Base64 encoding is a widely-used yet pretty simple encoding
scheme to encode any binary/textual data into ASCII printable characters'
---

Base64 is a common encoding scheme for representing binary data with a set of 64 ASCII printable characters. Web designer and developers might come across base64 when trying to send machine generated email or embed image into a page. I am going to go through some of its usages and working mechanism.

## What is base64 for?

Usually base64 hides within the interaction between machines instead of that with human, but when generating emails with attachment, or trying to embed an image into a webpage/CSS file, base64 will come handy.

The MIME standard supports for using base64 as a transfer encoding in which an arbitrary file can be encoded into a base64 string and sent out as email attachment. When generating email with attachment, base64 is particularily useful. See below for an example.

~~~
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=randomSeparator

--randomSeparator
Content-Type: text/plain

This is the body of the email

--randomSeparator
Content-Type: application/zip; name="attachment.zip"
Content-Transfer-Encoding: base64
Content-Disposition: attachment

YXNrZGphc2tka2phc2p3cXJocWtqd3JhaHNka2pzYWRrYXNoanNhZ2Noa2FzY3dxaw==
~~~

Near the end of this email there is an attachment with its content encoded in base64 so you will not see strange characters in the generated email. Just letters, digites, plus a few symbols.

Another usage for base64 in web development is to embed an image into a webpage. <br />
Embed? Yes.

Most of the time when browser loads a webpage, first the HTML document containing the skeleton of the site is loaded. Then browser then looks for any image/script/css/etc in the page that need to be downloaded. In other words, when we first see a webpage the images are not loaded, leaving a awkward white blank in the display before the images are done loading.


<figure>
<img src='./screenshot1.png'/>
<figcaption>Load sequence in a webpage</figcaption>
</figure>

The gap between finishing loading html and image makes a bad impression to new visitors. In slow network such as mobile network, we want to avoid this. Using base64, external resources can now be in-line included in a html document. As mentioned, base64 can be used to covert binary data in a file into printable characters. By the same token web developer can embed images into a page. I draw a snail’s picture to illustrate this, following the actual html code you would see in the source code of this web page.

<figure>
<img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAIAAACRXR/mAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAB3RJTUUH3QwdCiQA+YijYgAAAT1JREFUWMPtmEkOwzAIRY3F/a+cLiylkTGzMyzwrqoDD/gFGjiOo33v9PbJU1iFVViFVViF9fjB6TMAtNbO+Q0A6iwfj9CTWQKQ2uLcCEBLgsmOixI4i1c+wavRmeuypC3ZkNfNuGmvQ1dtxb5NkmEgDfagw8LFWBqEO7LSB5nqArekgfthAoAFQtHW8vkp80v04X5cvhrh9KTG32MSWcqRiyogku4tULJTRIo4dVEa3ySUJdNZUC4qi9q6Pb3LhFnkmJW8QEClI8s2WdbushhLQ6Dv3LJv0YbiTR4muwOX0aS2MJwSYYzIoynVt5KD6JZd/hwaKpyL3rH3WnqVZV/Y1fNMWMl/GeokZb+1CFDwumUa0ppAxq5LWGqVt2ElA6Bl/e8EL75pFljxxeZEd6Sni1hvbAqrsAqrsF45P7k6+UiRTNsxAAAAAElFTkSuQmCC' />
<figcaption>A snail image embedded in to the page with base64</figcaption>
</figure>

~~~ html
<img src=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAIAAACRXR/mAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAB3RJTUUH3QwdCiQA+YijYgAAAT1JREFUWMPtmEkOwzAIRY3F/a+cLiylkTGzMyzwrqoDD/gFGjiOo33v9PbJU1iFVViFVViF9fjB6TMAtNbO+Q0A6iwfj9CTWQKQ2uLcCEBLgsmOixI4i1c+wavRmeuypC3ZkNfNuGmvQ1dtxb5NkmEgDfagw8LFWBqEO7LSB5nqArekgfthAoAFQtHW8vkp80v04X5cvhrh9KTG32MSWcqRiyogku4tULJTRIo4dVEa3ySUJdNZUC4qi9q6Pb3LhFnkmJW8QEClI8s2WdbushhLQ6Dv3LJv0YbiTR4muwOX0aS2MJwSYYzIoynVt5KD6JZd/hwaKpyL3rH3WnqVZV/Y1fNMWMl/GeokZb+1CFDwumUa0ppAxq5LWGqVt2ElA6Bl/e8EL75pFljxxeZEd6Sni1hvbAqrsAqrsF45P7k6+UiRTNsxAAAAAElFTkSuQmCC />
~~~

Previously I have introduced two of many usages of base64. For the next part, I will explain how to turn data into a base64 string you have seen above.

## How base64 works?

A sequence of bits is coverted into base64 by taking 24 bits (or 3*8 bits), and write them as 4 base64 characters. I will use this base64 dictionary with a padding character <code>=</code>.

~~~
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
~~~

Example 1 and 2 illustrates the base cases of turning strings of 3 or less characters into a base64 string. For any bit stream longer than 24 bits, iterate the steps of example 1 and 2 for every 24 bits will do.

~~~
Example 1

#1 Gathering 24 bits.
input:   A        B        C
ASCII:   01000001 01000010 01000011
         -------- |||||||| --------

#2 Dividing them into 6-bits chunks.
6-bits:  010000 010100 001001 000011
         ------ --|||| ||||-- ------
Index :  16     20     9      3
base64:  Q      U      J      D
~~~

~~~
Example 2

#1 Do not have 24-bits
input:   A        B
ASCII:   01000001 01000010
         -------- ||||||||

#2 Dividing them into 6-bits chunks, fill in the missing bits with 0
6-bits:  010000 010100 001000
         ------ --|||| ||||XX
Index :  16     20     8
base64:  Q      U      I

#3 Pad the base64 string until it gets a length of 4
QUH ---> QUI=
~~~

To test its correctness, run btoa(string) in any modern browser JavaScript console. The function encodes any string into its base64 encoded form.

Obviously, the input is not limited to ASCII string. The essence is to take 24 bits from the data source and represent it with 4 base64 characters. A drawback of base64 is that the data ends up 33.3% (4/3 in fraction) longer than the original.
