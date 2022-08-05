---
title: Why "Add to Home screen" links to the incorrect page
kind: article
created_at: 2022-08-05 00:00:00 +0800
slug: why-add-to-home-screen-links-to-incorrect-page
preview: false
timeless: false
abstract: '"Add to Home screen" may not do what you expect it does on websites with web manifest'
---

## Background (skippable)

[Monica](https://github.com/monicahq/monica) is a personal CRM for managing contact list and journey entries. Its interface is desktop-first and somewhat responsive on mobile. The two-column layout stacks on mobile screen.

<figure>
  <a href="monica.jpg" target="_blank">
    <img src="monica.jpg" alt="Add journey button">
  </a>
<figcaption>Add journey button appearing at bottom of the page</figcaption>
</figure>

Scrolling to the bottom is ok when there are limited numbers of entries. On day 3 it already began feeling troublesome having to scroll all the way down.

The add journal page `/journal/add`, so I thought if I use the "Add to Home screen" (A2HS) feature of my mobile browser I should be able to open the add journey page.

Except not really. When tapping the icon on home screen, the homepage of Monica is opened.

## What "Add to Home screen" (A2HS) actually does

When a website doesn't have a web app [manifest](https://developer.mozilla.org/en-US/docs/Web/Manifest) containing the `start_url` property, A2HS actually takes that URL instead of URL of the page you were viewing when you added the website to homescreen.

This is actually a feature for Progressive Web App (PWA) to have an app-like fullscreen shell and consistent start page when opened. The problem is mobile browsers do not offer an option to choose between the current page or the page pointed to by `start_url`.

Monica has this [manifest](https://github.com/monicahq/monica/blob/6a0af31efc66eb49222e6328fa454c2d7d038e43/resources/views/layouts/skeleton.blade.php#L15) defined, so I am not able to open the `/journal/add` page directly.

## How to add abritrary page to homescreen

Ok, A2HS doesn't work, and I don't want to write a separate app calling Monica's [API](https://www.monicahq.com/api) to create journal entries.

There are many ways to add to homescreen bypassing the forced `start_url` and link to whatever page you want. You can redirect with a meta tag on a static page. You can also write a serverless function that simply redirects when called.

Make sure your redirection isn't instant. You need some time to press that "Add to Homescreen" button before the page actually redirects into Monica.

At the end, I created a Cloudflare worker (because it's free) returning a HTML page that contains the redirection target.

That's it! Nothing complex about adding arbitrary page to the homescreen. I have been creating PWAs for years, and only today do I realize that A2HS has to give way to make PWA work. Perhaps not enough people have [complained](https://android.stackexchange.com/questions/225002/chrome-and-firefox-cannot-add-specific-url-to-home-screen) [about](https://apple.stackexchange.com/questions/385417/add-to-home-screen-saves-wrong-url) this for browser vendors to improve the experience.