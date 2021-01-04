---
title: Website analytics for lazy people
kind: article
created_at: 2020-12-30 09:35:58 +0800
slug: website-analytics-for-lazy-people
preview: false
abstract: Being lazy and against self-hosting public-facing services, I made others do it for me
---

Imagine shouting into the void where there's absolutely no echo. This is what it's like writing this blog after I have [removed Google Analytics](/blog/no-more-google-analytics/). I got organic traffic from time to time back when Google Analytics was enabled, and now I have zero idea.

Pretty sure I am not going back to over-tracking my visitors&mdash;but I do want to have an idea at least view counts to my site. Knowing th view count motivates me to continue writing things that someone might find useful.

Being lazy and prefer doing things [as simply as possible](/blog/doing-things-the-layman-way/), I know that most of the web traffic analytics services out there won't fit. I want something I can drop in, and get out of at any time.

> Building a program to automate and perform a computationally expensive task is one thing that all software engineers are more than prepared for. But doing things the layman way and achieve virtually the same result in lower cost is much much better.

## Solution: bit.ly + tracking pixel

<figure>
  <a href="./5feacee4935d9tracking.png" target="_blank">
    <img src="./5feacee4935d9tracking.png" style="max-width: 100%;" alt="bit.ly link click dashboard">
  </a>
<figcaption>bit.ly link click dashboard tracking a bit.ly link to a...pixel.png?</figcaption>
</figure>

The solution I opted for is easy to set up (took me 10 minutes to get first tracking in) without any configuration. I first created a transparent, 1x1 pixel PNG file. Then, I created a bit.ly link to the pixel.png's supposed URL.

Then, I inserted the bit.ly link as an `<img>`{: .language-} to my homepage's `index.html`{: .language-}.

~~~html
<!-- Tracking pixel -->
<img src="https://bit.ly/3aP0xkp"
     style="width: 0px; height: 0px; margin: 0; padding: 0; visibility: hidden;" />
~~~

If you have used bit.ly before, you'd have noticed that the URL translation from bit.ly URL to the original URL happens transparently to the user. This is done my a `HTTP 301 Moved Permanently`{: .language-} redirection returned by bit.ly, which most browser would automatically follow to the redirected URL.

Therefore, from the users perspective loading this 1x1 pixel, 564 bytes, invisible image won't make any difference in terms of experience and load speed. To the browser, it's equally transparent because it's a `HTTP 301`{: .language-} redirection. Ad blockers usually don't block frequently used link shortener such as bit.ly (my uBlock Origin didn't block it), so I am more or less sure I am not missing any visitor counts.

The benefit I get from this extra tracking pixel is that every time the bit.ly link is hit, bit.ly would increase its counter and I am able to see the visitor counts to these pages from bit.ly. One caveat to this approach is that I am not able to distinguish repeating visitors, which is fine by me.

When the browser is making a request to the bit.ly URL, it includes a header entry `referrer: https://tommyku.com`{: .language-} <s>, which means for the same site you can reuse the same bit.ly URL across pages. On the bit.ly dashboard you are able to see the breakdown of requests by referrer page.</s> <i>Edit: You cannot. Only the website's domain, not full page URL, is included in referrer field (2020-12-30)</i>

bit.ly doesn't forget to sneak in a cookie, but it can be blocked if user disables third-party cookie.

<figure>
  <a href="./5ff306fe95e963rd_party_cookie.jpg" target="_blank">
    <img src="./5ff306fe95e963rd_party_cookie.jpg" style="max-width: 100%;" alt="Cookie from bit.ly getting blocked">
  </a>
<figcaption>bit.ly, don't</figcaption>
</figure>

If you want strict segregation between tracking URLs, you can create one bit.ly per page, and link to the same image file. However bit.ly would give you the same bit.ly URL if you're linking to the same URL, so you need to add an extra query parameter (`?now`{: .language-}) to make them look different (bit still resolve to the same image file).

~~~text
https://bit.ly/urlTokenA => https://tommyku.com/assets/pixel.png
https://bit.ly/urlTokenB => https://tommyku.com/assets/pixel.png?now
~~~

bit.ly please don't block me <s>even though I misused you</s>.

## User-friendliness

Just to sweeten it a bit for the users to <s>swallow</s> accept this visitor counting approach, I have added an event listener to the tracking pixel `<img>`{: .language-} tag which changes from a &#128584; (see no evil monkey) to &#128064; (eyes) emoji after the tracking pixel has finished loading.

<figure>
  <a href="./5feb2b0f3aaaetracking-eye-eye.png" target="_blank">
    <img src="./5feb2b0f3aaaetracking-eye-eye.png" style="max-width: 100%;" alt="Eyes emoji after tracking pixel is loaded">
  </a>
<figcaption>"I see you" (on bit.ly)</figcaption>
</figure>

Clicking on the icon leads users to this article. Visitors will then realize that their visit is being counted.

~~~html
<style>
  a#tracking-status {
    display: block;
    width: 0;
    line-height: 0;
    margin: 0 auto;
    padding: 0;
    text-decoration: none;
  }

  a#tracking-status.unloaded::before {
    content: "\1F648";
  }

  a#tracking-status.loaded::before {
    content: "\1F440";
  }
</style>
<!-- Tracking pixel -->
<a href="https://blog.tommyku.com/blog/website-analytics-for-lazy-people" id="tracking-status" class="unloaded" title="Tracking Indicator"></a>
<img src="https://bit.ly/3aP0xkp"
     style="width: 0px; height: 0px; margin: 0; padding: 0; visibility: hidden;"
     onload="javascript: document.querySelector('#tracking-status').classList.replace('unloaded', 'loaded')" />
~~~

## Why not self-host/use other analytics services

The market is saturated with web analytics services, most of them have free tier, many available for self-hosting. I could have used any of them instead of going through this approach.

Aside from ordinary web analytics solutions, I could have also analyzed the web server's `access.log`{: .language-} for page view counts.

The reason I didn't take the `access.log`{: .language-} analysis approach is because the site is hosted on GitHub Pages. Despite the middle layer Cloudflare provides analytics service, it comes with a cost. Visit count needs to happen on client side somehow.

As for self-hosted analytics service, I simply don't want to pay/setup a service on cloud simply for analytics which I need to maintain over the years. At such a small scale I like to do things [the layman way](/blog/doing-things-the-layman-way/).

Lastly, the reason I am not using other hosted analytics service is because this approach is so simple I can easily swap out bit.ly to something else later if I want to. 

## Bonus: reactions

Loading an image means adding a count to the tracking. If image loading can be controlled by JavaScript, users can selectively load images to record their reactions to the page, such as leaving "Like" on the page.
