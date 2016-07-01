---
title: Prototyping with gulp-web-starter
kind: article
created_at: '2015-08-08 00:00:00 +0800'
slug: prototyping-with-gulp-web-starter
---

Let's pretend that in one random evening when you leave office early and formed a brilliant idea on your way home. Your blood is boiling and you want it dive into a coding sprint as soon as possible. Roll out a barely functional or even completely hard-coded version, then send it to friends and coworkers to make sure the idea holds up to the expectations.

This is called prototyping &mdash; a way to creating an incomplete version of a software because most complete software project takes more than a few hours.


#### Prototying for the web

No one wants to learn that an idea doesn't work only after days or even weeks of developement.

Luckily, the web is very flexible. Pulling in this framework, that library, hold them together with duct tape, here comes a prototype, quick and dirty.

I mean, you can use `bower` to grab a release of some frameworks/libraries then group them together into a single `index.html` to form a minimally viable prototype.

Backend? No you don't need to write one yourself, try [Firebase](https://www.firebase.com/) or [Parse](https://www.parse.com/) for data and [Cloudinary](http://cloudinary.com/).

#### Introducing gulp-web-starter

<div class="github-card" data-github="tommyku/gulp-web-starter" data-width="400" data-height="155" data-theme="default"></div>
<script src="//cdn.jsdelivr.net/github-cards/latest/widget.js"></script>

GitHub should make some official embeded cards.

##### Installation takes a couple lines and just that.

~~~ bash
$ git clone https://github.com/tommyku/gulp-web-starter.git new-project
$ cd new-project
$ npm install
$ gulp --live #--live flag enables liverelaod
~~~

*gulp-web-starter* is not really any big deal. It focuses on saving your time setting up the environment because it you can pull in whatever framework/library. Any preset or preconfigured framework that not everyone needs would void the point. You can pull in whatever you want quickly with `bower`.

~~~ bash
$ bower install --save 'library-name'
~~~

##### Functions

The point of this starter is to pack in the barely minimum setup that usually you would need so you don't have to do it each time kickstarting a prototype.

It can
- compile Jade into HTML
- compile Sass into CSS
- compile CoffeeScript into JavaScript
- publish compiled content (no, a prototype doesn't need to be uglified)
- livereload on browser tabs when `--live` flag is applied

You might say if any preset not fitting the reality of prototyping should not exist in the starter, why put in the *Jade*, *Sass* and *CoffeeScript* compilers in? No, they speed things up. These language proprocessors as mostly as syntactic sugers reducing the amount of code you need to type so you spend less time adding mundane paraentheses and braces.

That's pretty much I have to talk about gulp-web-start, or maybe too much already. Feel free to customize it or start your own such that you can spend more time with your family and friends instead of punching the keyboard to set things up.

#### On a side note

When your app need to work with a separate local backend, remember to allow for [CORS](http://www.html5rocks.com/en/tu
torials/cors/) on the backend.

[localtunnel](http://localtunnel.me/) is a nice tool to expose a port to external clients should you want to share an adhoc gulp server serving your prototype locally. Or try `ssh -L`.
