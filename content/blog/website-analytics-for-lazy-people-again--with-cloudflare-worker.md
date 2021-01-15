---
title: Website analytics for lazy people again, with Cloudflare Worker
kind: article
created_at: 2021-01-15 23:15:28 +0800
slug: website-analytics-for-lazy-people-again--with-cloudflare-worker
preview: false
abstract: With the serverless hammer everything looks like a nail, this time with page-wise view counts
---

In [Website analytics for lazy people](/blog/website-analytics-for-lazy-people) I have shown that you can use bit.ly to load a tracking pixel from your page, and thus capture the view count of the page that works even when JavaScript is disabled, and can fly under your ad blocker's radar.

For those who finds the previous post on this topic TL;DR, basically I have added a tracking pixel to my site, which loads with the page like any image, and by using a middleman such as URL shortener to capture that request I am able to aggregate the view counts of my page.

After some time I began using Cloudflare worker, which is a serverless service that has a free tier and key-value storage without extra cost. Using a serverless worker I am able to do tiny tasks and write the results back to the storage entirely for free and without the need of additional infrastructure.

Then I thought, hey what if I ditch bit.ly and instead use Cloudflare worker to track my page view counts? Given a serverless function what I have more control over how the request sent to it is converted into page view record. I can even add hard-coded parameters to the worker URL in different page to get page-wise view counts.

I have implemented a quick and dirty page view counter as a Cloudflare worker like below and replaced the bit.ly tracking pixel with this worker tracking pixel. They work exactly the same in high-level, but I am able to track per-page view counts by adding different page parameter (e.g. `?http://blog.tommyku.com`) to the URL and have the worker save the counts by page.

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
<small><center><i>Terribly written code that works ok</i></center></small>
