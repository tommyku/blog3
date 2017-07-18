---
title: Adding HTML5 application cache to speed up your web app in 5 minutes
kind: article
created_at: '2015-03-16 00:00:00 +0800'
slug: adding-html5-application-cache-to-speed-up-your-web-app-in-5-minutes
---

<mark style='display: block; background-color: lightcoral; padding: .5em; font-style: italic;'>
(2017-07-17) AppCache has been deprecated, see how to cache web pages using
ServiceWorker in <a href='/blog/appcache-revisited'>this post</a>.
</mark>

OK, let's do this in 5 minutes to get you started with HTML5 app cache.

### 10 seconds

<div style="text-align: center;">
<img src="./caniuse.png" title="application cache browser support chart" />
<br />
<small><em>source:</em> <a href="http://caniuse.com/">http://caniuse.com/</a></small>
</div>

Save yourself the trouble if you have to support IE6.

### 30 seconds

Make a branch so we can do whatever we want.

~~~ bash
git checkout -b 'html5-app-cache'
~~~ 

### 1 minute

Your server has to serve the manifest file in `text/cache-manifest` MIME type. Look it up how to setup this if you are not using Apache.

~~~ bash
nano .htaccess
~~~ 

~~~ apache
# add the following line for serving offline cache manifest
AddType text/cache-manifest .manifest
~~~ 

### 2 minutes

Specific the path to manifest file in your web app.

~~~ html
<!DOCTYPE html>
<html manifest="/cache.manifest">
  <head>
<!-- everything else -->
~~~ 

### 3 minutes

~~~ bash
touch cache.manifest
~~~ 

Write up the manifest itself, inside `cache.manifest`:

~~~ 
CACHE MANIFEST
~~~ 

Now fire up your app and it *will not* work. Be patient, we still have 2 minutes.

Tab `F12` to enter Chrome DevTools

<div style="text-align: center;">
<img src="./copyandpaste.png" title="A quick way to know what we wanna cache" />
<br />
<small><em>Img:</em> A quick way to know what we wanna cache</small>
</div>

### 4 minutes

Copy and paste the paths to whatever files we are supposed to cache from DevTools console warnings.

~~~ 
CACHE MANIFEST

CACHE:
/js/app.js
/js/angular/angular.min.js
/js/angular-resource/angular-resource.min.js
/js/angular-sanitize/angular-sanitize.min.js
/css/base.css
/css/animate.css

NETWORK:
*
~~~ 

Everything listed under `CACHE` will be cached, other stuff like Google fonts are loaded as usual.

### 5 minutes

Now we are done. It is always a good idea to cache your web app to optimize page load time. In particular, when your web app is an utility app intended to be usable offline. There are more to do with `cache.manifest` such as version-based caches, hooks to manifest loading... The references below explain better how those features work. So far, I only need to cache my Javascript and CSS files.

Why 5 minutes? That's because I had to wait for this.

<div style="text-align: center;">
<img src="./992692498_85526273c4_z.jpg" title="cup noodle time!" />
<br />
<small><em>source:</em> <a href="https://www.flickr.com/photos/oddharmonic/992692498/in/photostream/">Flickr</a></small>
</div>

### References

1. [Using the application cache - HTML (HyperText Markup Language) \| MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache)
2. [A Beginner's Guide to Using the Application Cache - HTML5 Rocks](http://www.html5rocks.com/en/tutorials/appcache/beginner/)
