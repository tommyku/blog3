---
title: 'AppCache revisited'
kind: article
created_at: '2017-06-10 00:00:00 +0800'
slug: appcache-revisited
abstract: 'AppCache has been deprecated in favor or Service Worker for
caching assets to be served when the device is offline'
preview: false
---

Two years ago, I wrote about the use of *Application Cache
(AppCache)* in the post "<a href="https://blog.tommyku.com/blog/adding-html5-application-cache-to-speed-up-your-web-app-in-5-minutes/">Adding HTML5 application cache to speed up your web app in 5 minutes</a>".

The AppCache feature <a href="https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache">is deprecated as a web standard</a>, so newer
version of browsers may not support it.

In comparison to its alternative *Service Worker*, AppCache is more
difficult to use because the web server has to serve the manifest files
in <code>text/cache-manifest</code> type while service worker is an ordinary JavaScript file.
No tinkering with the web server required except for
the HTTPS. Service worker has a shortcoming of unable to
run on browser with JavaScript disabled while AppCache doesn’t need
JavaScript to run.

The title of this post is “<strong>AppCache revisited</strong>”, but I am not going
to implement it again. Instead, I am migrating an old app that has
been sitting around since 2015 from AppCache to Service Worker.

<h2 id="removing-appcache-from-an-app">Removing AppCache from an app</h2>

<h3 id="removing-manifest-mime-type">Removing manifest MIME type</h3>

The web server was set up to serve <code>*.manifest</code> files with MIME type
<code>text/cache-manifest</code>. It is no longer needed as we are removing AppCache.

<pre><code class="language-apache"># .htaccess
# ...
# Remove this line from .htaccess file
AddType text/cache-manifest .manifest
# ...
</code></pre>

<h3 id="removing-references-to-manifest-files-from-source">Removing references to manifest files from source</h3>

Remove the <code>manifest</code> attribute from <code>&lt;html&gt;</code> tag.

<pre><code class="language-html">&lt;!DOCTYPE html&gt;
&lt;html manifest="/manifest/app.cache.manifest"&gt;
&lt;!-- ... --&gt;
</code></pre>

The <code>app.cache.manifest</code> file should also be removed from the project,
note that the file looks like this at the moment.

(yes, this is the same app from that old AppCache post)

<pre><code>CACHE MANIFEST

CACHE:
/js/app.js
/js/angular/angular.min.js
/js/angular-resource/angular-resource.min.js
/js/angular-sanitize/angular-sanitize.min.js
/css/base.css
/css/animate.css

NETWORK:
*
</code></pre>

Later when we migrate to service worker, the list of files to be cached
is useful because like AppCache, you can specifiy exactly what to cache
in service worker.

Now the app is free of the old deprecated AppCache. To achieve the same
caching effect, we will have to use add service worker to the app.

<h2 id="adding-service-worker-to-an-app">Adding service worker to an app</h2>

<h3 id="requirements-of-service-worker">Requirements of service worker</h3>

HTTPS is required to run service worker because service worker can serve
modified responses to network request, increasing the risk of man in the
middle attack. According to an <a href="https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API">MDN article</a>, Firefox disables service worker API while in private
browsing mode.

To enable HTTPS on your server, <a href="https://letsencrypt.org/">Let’s Encrypt</a>
is a good source of free certificate. If your app is
hosted on <a href="https://pages.github.com/">GitHub Pages</a>, it is already
being served over HTTPS (and it’s free!). <a href="https://www.cloudflare.com/">Cloudflare</a>
also provides HTTPS at free-tier if you are being lazy. (though the connection between
Cloudflare and your server may not be private, see <a href="https://support.cloudflare.com/hc/en-us/articles/200170416-What-do-the-SSL-options-Off-Flexible-SSL-Full-SSL-Full-SSL-Strict-mean-">this article</a> for
details).

<h3 id="the-service-workerjs">The service-worker.js</h3>

If you build your app with build tools such as <code>webpack</code> or <code>gulp</code>,
<a href="https://workboxjs.org/#get-started">Workbox</a> is a great tool for
integrating service worker into your app. The app I am maintaining
wasn’t built with any build tool but plain CSS and JavaScript. Workbox provides
options to manually select what kinds of file to cache.

To show you how to add service worker to a project, I decided to write
one up manually.

<pre><code class="language-javascript">// service-worker.js
var cacheName, filesToCache;

cacheName = 'link-201706101730';

filesToCache = [
  '/',
  'index.html'
  'js/app.js',
  'js/angular/angular.min.js',
  'js/angular-resource/angular-resource.min.js',
  'js/angular-sanitize/angular-sanitize.min.js',
  'css/base.css',
  'css/animate.css',
];
</code></pre>

At the top of <code>service-worker.js</code>, the <code>cacheName</code> and <code>filesToCache</code>
are specified. Caching each asset with individual cache name is
possible and preferred. To keep the example simple, we use a single
cache name for all files here.

<pre><code class="language-javascript">// service-worker.js
var cacheName, filesToCache;

cacheName = 'link-201706101730';

filesToCache = [
  '/',
  'index.html'
  'js/app.js',
  'js/angular/angular.min.js',
  'js/angular-resource/angular-resource.min.js',
  'js/angular-sanitize/angular-sanitize.min.js',
  'css/base.css',
  'css/animate.css',
];

self.addEventListener('install', function(e) {
  // [ServiceWorker] Install
  return e.waitUntil(caches.open(cacheName).then(function(cache) {
    console.log('[ServiceWorker] Caching app shell');
    return cache.addAll(filesToCache);
  }));
});

self.addEventListener('fetch', function(e) {
  console.log('[ServiceWorker] Fetch', e.request.url);
  return e.respondWith(
    fetch(e.request).catch(function() {
      return caches.match(e.request);
    })
  );
});

self.addEventListener('activate', function(e) {
  console.log('[ServiceWorker] Activate');
  return e.waitUntil(caches.keys().then(function(keyList) {
    return Promise.all(keyList.map(function(key) {
      if (key !== cacheName) {
        console.log('[ServiceWorker] Removing old cache', key);
        return caches["delete"](key);
      }
    }));
  }));
});
</code></pre>

This service worker set up will install and activate itself to cache new
assets. The <code>fetch</code> event uses network first instead of cache first
approach when dealing with asset request, meaning that it always try to
fetch through the network before falling back to using caches.

The code in this service worker example was heavily influenced by
<a href="https://developers.google.com/web/fundamentals/architecture/app-shell">this article</a>.

<h3 id="installing-and-updating-service-worker">Installing and updating service worker</h3>

Service worker doesn’t just work on its own, your app has to
explicitly register the service worker for it to work.

To achieve this, add the following code to the end of your app’s
JavaScript file.

<pre><code class="language-javascript">// app.js
// ...

if(typeof navigator['serviceWorker'] != 'undefined') {
  window.addEventListener('load', ()=&gt; {
    navigator.serviceWorker
      .register('/service-worker.js')
      .then(()=&gt; {
        console.log('Service Worker Registered')
      });
  });
};
</code></pre>

Lastly, deploy the app as usual. The app should load fast and work
offline like how it was with AppCache. Of course, background
sync and push notifications are also available thanks to service worker,
but they are out of the scope of this post.

<h2 id="closing-thoughts">Closing thoughts</h2>

One important thing to note is that despite deprecated, AppCache is
still supported by most of the major browsers (as of June 2017), while
service worker is either under development or under consideration on
Edge and Safari. The momentum of service worker is strong, with notable
sites such as Aliexpress, Flipboard, Financial Timesm and <a href="https://pwa.rocks/">more</a> already
using service worker to provide offline usability.

<figure>
<img src="./caniuse-appcache.png">
<figcaption>Browser support for AppCache (source: <a href="https://caniuse.com/#feat=offline-apps">caniuse.com</a>)</figcaption>
</figure>

<figure>
<img src="./caniuse-sw.png">
<figcaption>Browser support for service worker (source: <a href="https://caniuse.com/#feat=serviceworkers">caniuse.com</a>)</figcaption>
</figure>

Of course, service worker isn’s just about caching, it enables for
app-link features such as push notification, background sync and install
to homescreen that will continue to fill the gap between native apps and
web apps without the need for software like Cordova and
PhoneGap.

Looking back, not only AppCache, many browser APIs have been developed
to empower the web. I am excited to see as the web continues to evolve,
what will emerge to bridge the gap between native apps and web
apps (Firefox OS was a bummer), or even better, how web can surpass
native app in portability, availability and user experience.
