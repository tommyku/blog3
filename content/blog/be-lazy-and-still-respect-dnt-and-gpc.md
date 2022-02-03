---
title: 'Be lazy and still respect DNT and GPC'
kind: article
created_at: '2022-02-03 00:00:00 +0800'
slug: be-lazy-and-still-respect-dnt-and-gpc
preview: false
abstract: 'Adding back DNT and GPC to my previous half-hearted analytic solution'
---

This is a (rather late) follow-up to my previous posts to [self-dogfooding](https://indieweb.org/selfdogfood) the [use tracking pixel](http://u02.tommyku.com:3000/blog/website-analytics-for-lazy-people/) to [track the number of page views to my site](http://u02.tommyku.com:3000/blog/website-analytics-for-lazy-people-again--with-cloudflare-worker/) while being as lazy as I can.

My method is known to bypass (my own) adblocker and does a good job double-counting all repeated page visits from everyone, meaning I *really* isn't tracking anyone except for the page view. Even Nginx logs out more information than I do.

<figure>
  <a href="nginxlog.jpg" target="_blank">
    <img src="nginxlog.jpg" style="max-width: 100%;" alt="Log from Nginx">
  </a>
<figcaption>Hmm&hellip;legit traffic?</figcaption>
</figure>

Oh yeah that&hellip;I should subscribe to some more IP blocklists.

<figure>
  <a href="abuse.jpg" target="_blank">
    <img src="abuse.jpg" style="width: 100%; max-width: 500px;" alt="AbuseIPDB">
  </a>
<figcaption>Well, not legit traffic</figcaption>
</figure>

But I am lazy and poor so I didn't want to setup a Nginx reverse proxy somewhere on the cloud just to get some logs. And if you don't want to be tracked I don't want to track you. In fact, I simply don't want to track myself because it pollutes my statistics.

Being lazy, the simplest way is to add my own website to my adblocker's custom list. That'll cover the desktops that I use. However Google is [evil enough](https://en.wikipedia.org/wiki/Don%27t_be_evil) to disallow Chrome extension on Chrome for Android. Blocking traffic to the tracking pixel endpoint using adblocker isn't enough.

DNT stands for "Do Not Track", a long neglected *wanna-be* standard that failed to become mainstream [like other things that came before](http://u02.tommyku.com:3000/blog/appcache-revisited/) because websites decided that they don't care.

GPC stands for "Global Privacy Control" that seems to be backed by [a legal standpoint](https://globalprivacycontrol.org/) but I bet still nobody cares enough about ([except](https://blog.freeradical.zone/post/ccpa-scam-2021-12/)), especially the small web.

Since I am getting bored about this already, here is the code. The only interesting part is the `if` conditions about DNT and GPC headers.

~~~javascript
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

/**
 * Respond to the request
 * @param {Request} request
 */
async function handleRequest(request) {
  const page = decodeURIComponent(new URL(request.url).search.replace(/^\?/, ''));
  // Try to respect DNT and GPC---
  const dnt = request.headers.get('dnt');
  const secGpc = request.headers.get('Sec-GPC');
  if (dnt === '1' || secGpc === '1') {
    return Response.redirect('https://blog.tommyku.com/assets/images/pixel.png?ignored', 301);
  }
  // ---Try to respect DNT and GPC
  if (page && page.substr(0, 4) === 'http') {
    let views = parseInt(await BLOG_VIEW.get(page));
    if (Number.isNaN(views)) {
        views = 0;
    }
    views++;
    await BLOG_VIEW.put(page, views);
  }
  return Response.redirect('https://blog.tommyku.com/assets/images/pixel.png', 301);
}
~~~