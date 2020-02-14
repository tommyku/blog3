---
title: 'Follow WordPress blogs using RSS reader'
kind: article
created_at: '2020-02-15 00:00:00 +0800'
slug: follow-wordpress-blogs-using-rss-reader
preview: false
abstract: 'What to do when a WordPress blog you like does not have a RSS feed button'
---

<!-- 
This line is 80 characters long
01234567890123456789012345678901234567890123456789012345678901234567890123456789
-->

I use a RSS feed reader to follow websites I care about. First it was Feedly for
6 years until ads began to annoy me. Then I moved to Feeder for around 2 years.

Being an open standard it means nobody but the content creator controls exactly
what content users can see and whether ads is included.

RSS has seen a gradual decline over the years in favor of social media such as
Facebook, Instagram and Twitter. Email newsletter, content curation sites and
apps also serve as other preferred avenues for feed-based content.

<figure>
<img src='./rss_trend.jpg' alt='RSS trend on Google Trend' />
<figcaption>RSS interest over time declining since 2004</figcaption>
</figure>

While RSS is designed to show the same content to all users alike, content
platforms generate feeds based on user preference shown from previous
interactions with the site. This is an power imbalance between content and
platform owners over what content and when to show them to consumers.

I prefer RSS over dynamically generated feeds because I want all the content
I am following. I don't mind scrolling through them to find what I am truly
interesting in because I can be sure that I am not missing anything or
manipulated by the algorithm generating the feed.

<figure>
<img src='./rss32x32.png' alt='RSS feed icon' />
<figcaption>RSS feed icon</figcaption>
</figure>

Whenever I see some content that I like from a site, I began looking for this
RSS feed icon. In fact, this site also has one on top called
[Atom Feed](/atom.xml), which works like RSS and is widely suppported by
feed readers.

35.8% of all websites are powered by WordPress according to
[W3Techs](https://w3techs.com/technologies/overview/content_management).
However not all of them show the RSS icon even though it comes [out of the
box with WordPress](https://wordpress.org/support/article/wordpress-feeds/#finding-your-feed-url).
Have no worries, though. Because while the link to RSS icon may be hidden,
the URL itself is usually still available. People don't bother disabling
that.

Try appending `/feed`, `/feed/rss` or `/?feed=rss` to the end of the
WordPress site's URL.

For example:

~~~bash
https://wylin.tw/feed
https://wylin.tw/feed/rss
https://wylin.tw/?feed=rss
~~~

If they work you'll see some XMLs being printed. That's the URL you want
to save into your RSS feed reader. Later when the site is updated, you
*will* see the update from the feed reader. Algorithm doesn't get to
determine what you see, the site owner does.