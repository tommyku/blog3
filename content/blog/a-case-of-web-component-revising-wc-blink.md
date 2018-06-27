---
title: 'A case of Web Component: Revising wc-blink'
kind: article
created_at: '2018-06-23 00:00:00 +0800'
slug: a-case-of-web-component-revising-wc-blink
preview: false
---

On 2015, I wrote `<wc-blink>` (check it out on [GitHub](https://github.com/tommyku/wc-blink)), a custom element that mimics the notorious
and obsolete native element `<blink>` (except that it has a `display: block`
instead of `display: inline` now that I think about it).

<link rel="import"
href="https://tommyku.github.io/wc-blink/wc-blink-element.html" async />

<wc-blink>If your browser supports custom component and HTML import,
you'll see this blinking! (and appreciate the fact that it's now
obsolete)</wc-blink>

~~~ html
<link rel="import" href="https://tommyku.github.io/wc-blink/wc-blink-element.html" async />

<wc-blink>If your browser supports custom component and HTML import, you'll see this blinking! (and appreciate the fact that it's now obsolete)</wc-blink>
~~~

It was absoluely unnecessary to make it a web component because there
exists a [CSS-only polyfill](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/blink)
that receives wide browser support (it's just CSS) and requires no
JavaScript or custom element support.

This element was written to explore the then-v0 customer element
standard. Even today, it still sound like the future to come, where you can plug
and play any HTML element without having to convert them from front-end
frameworks such as React, Vue.js or AngularJS.

When I was reading Mikeal's [post on web component](https://medium.com/@mikeal/ive-seen-the-future-it-s-full-of-html-2577246f2210), I was still full of
hope even though I jumped into developing in React a few months before
and never turned back. Web component is still at it's infancy in terms
of adoption and browser supports while component-based front-end
frameworks are quickly fulfilling its promise - except the
interoperatbility part.

<script type="text/javascript" src="https://ssl.gstatic.com/trends_nrtr/1457_RC04/embed_loader.js"></script>
<script type="text/javascript">
  trends.embed.renderExploreWidget("TIMESERIES", {"comparisonItem":[{"keyword":"React","geo":"","time":"2015-01-01 2017-06-23"},{"keyword":"Vue","geo":"","time":"2015-01-01 2017-06-23"},{"keyword":"Web component","geo":"","time":"2015-01-01 2017-06-23"},{"keyword":"Custom element","geo":"","time":"2015-01-01 2017-06-23"}],"category":31,"property":""}, {"exploreQuery":"cat=31&date=2015-01-01%202017-06-23&q=React,Vue,Web%20component,Custom%20element","guestPath":"https://trends.google.com:443/trends/embed/"});
</script>
<p style='text-align: center;font-size: 0.8125em;'>
  <i></i>
</p>

## In case of \<wc-blink\> in 2015

`<wc-blink>` was originally written in custom element v0, without the
ES2015 vibe of JavaScript class. Yet the general idea was the same: first you
attach a shadowDOM to the element housing your content, then fill it up
with lifecycle callbacks such as attachedCallback() or
attributeChangedCallback() which reassembles React's componentDidMount() and a high level shouldComponentUpdate() + render() + componentDidUpdate().

~~~ html
<!-- Commit: df3fcb41c880cb6762c609d7657cc0fd833d9134 -->
<!-- wc-blink.html -->
<template>
  <style>
    /* Credit goes to google for this part
       Search "html blink" on google and see */
    @-webkit-keyframes blink {80%{opacity:0.0}}
    @keyframes blink {80%{opacity:0.0}}
    :host, * {
      -webkit-animation:blink 1s steps(1,end) 0s infinite;
      animation:blink 1s steps(1,end) 0s infinite;
    }
  </style>
  <content></content>
</template>

<script>
  (function() {
    // Refers to the "importer", which is index.html
    var thatDoc = document;

    // Refers to the "importee", which is src/hello-world.html
    var thisDoc =  (thatDoc._currentScript || thatDoc.currentScript).ownerDocument;

    // Gets content from <template>
    var template = thisDoc.querySelector('template').content;

    // Creates an object based in the HTML Element prototype
    var element = Object.create(HTMLElement.prototype);

    // Fires when an instance of the element is created
    element.createdCallback = function() {
      var shadowRoot = this.createShadowRoot();
      shadowRoot.appendChild(document.importNode(template, true));
    };

    // Fires when an instance was inserted into the document
    element.attachedCallback = function() {};

    // Fires when an instance was removed from the document
    element.detachedCallback = function() {};

    // Fires when an attribute was added, removed, or updated
    element.attributeChangedCallback = function(attr, oldVal, newVal) {};

    // Registers <hello-world> in the main document
    window.WcBlink = thatDoc.registerElement('wc-blink', {
        prototype: element
    });
  }());
</script>
~~~

Of course, this is not pretty. Despite `<template>` reassembles the
convenient JSX where we define the HTML structure of the "shadowDOM"
(it isn't exactly shadowDOM in React's case despite some degree of
encapusulation).

Nevertheless, custom component v0 `<wc-blink>` has a much lighter
footprint compared to even the simpliest React app. All you need is a
`wc-blink.html`, and a line of `<link rel='import' href='wc-blink.html'>`.
No `npm install` (I used `git submodule add`). Bundling isn't necessary
until you have multiple HTML elements to import depending on how much extra
lines of `<link>` you can tolerate in your HTML file.

`<wc-blink>` was built as an exercise to see how the custom element
standard works. Judging from the amount of code I need to write by
myself to create an element as simple as `<blink>`, it wasn't really
attractive back then. I did love the part that I could import an element
and expect it'll work like a charm, it was just that betting on a web
standard that was in drafting stage was rather reckless.

With such a simple component, I haven't even got to partial shadowDOM
update (where I really hoped there was something like React's VirtualDOM)
or inter-component communication. As the web component standard is less
opinionated than frameworks like React, <em>it gives you lots of ropes to hang
yourself</em>, ending up writing overly coupled components, unnecessary
DOM updates and weirdly behaving components due to lifecycle issue (like
things not initializing/firing properly).

## In case of \<wc-blink\> in 2018

My worry came true. Custom element v0 was removed and v1 was introduced
relying on ES2015. `document.registerElement` was no longer in the web
standard and we should expect one day no browser would support it
(Firefox never supported v0 in the first place 😐, nor v1 at the time of
writing)

In general, my v0 and v1 implementations of `<wc-blink>` are quite similar. This revision
only makes use of ES2015 class, and replaced `<content>` with `<slot>` to
give users a better idea where the dynamic content go.

~~~ html
<!-- Commit: 3f8fa76675c15177baf9ccb81dcbb9b6831effcd -->
<!-- wc-blink-element.html -->
<template id='wc-blink'>
  <style>
    /* Credit goes to google for this part
       Search "html blink" on google and see */
    @keyframes blink {80%{opacity:0.0}}
    :host, * {
      animation:blink 1s steps(1,end) 0s infinite;
    }
  </style>
  <slot name='content'></slot>
</template>

<script type='text/javascript'>
  // hack to get reference to this document even if calling constructors somewhere else
  const thisDoc = document.currentScript.ownerDocument;

  class WcBlink extends HTMLElement {
    constructor() {
      super();

      const template = thisDoc.getElementById('wc-blink')
        .content;

      const shadowRoot = this.attachShadow({ mode: 'open' })
        .appendChild(template.cloneNode(true));

      this.blinkStep = 0;
      this.blinkInterval = setInterval(function() {
        this.updateDisplay();
      }.bind(this), 200);
    }

    connectedCallback() {
      const content = document.createElement('div');
      content.setAttribute('slot', 'content');

      content.setAttribute('slot', 'content');
      this.childNodes.forEach((child) => content.appendChild(child));
      this.appendChild(content);
    }

    updateDisplay() {
      const content = this.querySelector('div[slot=content]');
      content.style.opacity = (this.blinkStep == 3) ? 0 : content.style.opacity;
      content.style.opacity = (this.blinkStep == 4) ? 1 : content.style.opacity;

      this.blinkStep++;
      this.blinkStep = this.blinkStep % 5;
    }
  }

  customElements.define('wc-blink', WcBlink);
</script>
~~~

Even in 2018, tutorials on the topic are hard to find. Web component
is much less opinionated than frameworks and therefore each tutorial author has their
own way of doing things. For example, to get content `<template>` from
template some decided to use `await fetch('template.html')` while some
referenced the `link[rel="import"]` to get the template document when
importing the component into other documents. At the end, I figured out
a way to get a hold of the reference to `ownerDocument` even after
importing the component from other documents.

You may have also noticed `blickStep` and `updateDisplay`, which are
unnnecessary given that there's a blinking animation applied to the
shadowDOM. Although the selector can select the element within the
shadowDOM (verified using `color: red !important;`), animation simply
doesn't fire, perhaps owing to browser bug as it works on my mobile
browser but not on desktop.

Although adoption of web component is still low to date and there seems to
be a larger community for Polymer, I still think that going through
all the hassles to write a web component-powered app less attractive
than writing a React app in a production setting.

With that being said, I may still have some fun writing web components
when I am offline.
