---
title: 'Oh my gosh SPACE!'
kind: article
created_at: '2018-08-05 00:00:00 +0800'
slug: oh-my-gosh-space
abstract: 'If you have written any amount of HTML and is conscious
enough to notice how whitespace (or the lack thereof) behave in a page,
welcome to the club'
preview: false
---

Over the years of developing for the web I would run into this problem
say, once every other year. Take a look at this piece of code.

~~~ html
<style>
* {
  font-size: xx-large;
}

ul {
  background-color: yellow;
}

ul li {
  display: inline-block;
  list-style: none;
  margin: 0;
}
</style>

<p>with whitespace</p>
<ul>
  <li>Hello</li>
  <li>World</li>
</ul>

<p>without whitespace</p>
<ul><li>Hello</li><li>World</li></ul>
~~~

The output looks like this. Alternatively, you may look at it on
[CodePen](https://codepen.io/anon/pen/VBBKpN). (makes me wanna self-host
a private CodePen but let's not go down that rabbit hole)

<figure>
<img src='./output.png' />
<figcaption>The list above has a space between two items, but not below</figcaption>
</figure>

Have you noticed that for the upper list, there is a space between list
items despite I have explicitly declared `margin: 0;` in their CSS properties?
Also observe that the same spacing doesn't exist in the list below.

What makes the matter worse, if you open up Chrome's DevTool and try to
inspect the two elements, DevTool's prettifies the HTML code in DevTool,
ending up not showing the difference between the original HTML code.

<figure>
<img src='./devtool.png' />
<figcaption>On DevTool, you'd never realize the two lists are written differently in source code</figcaption>
</figure>

To make the matter worse, static site generator likes to minify HTML
during build but not during development, so it could take you like an
hour or so diff-ing the pages on DevTool trying to spot the difference,
which you couldn't, until you shout...

> OH MY GOSH SPACEEEE!!!!!!
> <br />
> &mdash; Myself earlier today
