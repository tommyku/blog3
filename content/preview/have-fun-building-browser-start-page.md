---
title: 'Have fun building browser start page'
kind: article
created_at: '2016-12-10 00:00:00 +0800'
slug: have-fun-building-browser-start-page
preview: true
---

<figure>
<img src='./multiple-tiles.png'/>
<figcaption>My current setup</figcaption>
</figure>

Before I thought of why I've fallen into building browser start page
building. Maybe it was my colleague, or maybe it was the web portal
nostalgia from the 90s. Feel the heat from [/r/startpages](https://www.reddit.com/r/startpages/).

I don't mean to say default start pages are nonfunctional or ugly, it is
just not mine. Like people want to customize their desktop wallpaper,
setting a background image for my browser page sounds like a no-brainer.
And why not add in some functions like web portals while I'm at it?

This time I am covering Google Chrome browser new-tab extension and local
web proxy with Docker.

Example code modified from my existing setup is availble on

<div style="text-align: center;">
  <div class="github-card" data-github="tommyku/gulp-web-starter" data-width="400" data-height="" data-theme="default"></div>
  <script src="//cdn.jsdelivr.net/github-cards/latest/widget.js"></script>
</div>

#### Setting things up

My first start page building attempt started off last year, which
prototypes scattering around, they all based on a [gulp-web-starter](https://github.com/tommyku/gulp-web-starter)
setup.

I believe everyone should have their own set of fine-tuned web starter
so they can jump into prototyping without worrying about the
development environment.

Either use your own starter or modify the demo code directly.

Start page is usually a small webpage. You might wanna keep it small
and fast because you are going to visit this page whenever you open a
new tab on browser.

Modify the source codes from `/src`, then run `gulp` to see the code in effect.

<figure>
<img src='./multiple-tiles.png'/>
<figcaption>my demo looks like this</figcaption>
</figure>

#### Brainstorm what to add

Browser start page is personal. There is no pattern or best practices
associated with the category of site.

Here is a list of stuff you may include:

- **search bar#**
- bookmarks
- **clock (w/without alarm)#**
- **weather report/forecast#**
- calendar
- kitten pics, lots of them
- notepad
- uptime of your current relationship
- **doomsday countdown#**

<small><attr>#</attr> included in demo</small>

Seek inspiration from online resources. After you have shortlisted what
to include in your start page, see if the following two sections are helpful before
you begin implementing them.

#### Exploring Chrome extension

#### Sinitra web proxy on Docker

Have you experienced [*Same-origin policy*](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy)
getting in the way when you attempt to make a [cross-origin HTTP request](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS),
which most likely to happen when making an API request to 3rd party
service.

While it enhances security, it's hindering legitimate API calls we want
to make, specifically [Dark Sky API](https://darksky.net/dev/) for weather
report.
