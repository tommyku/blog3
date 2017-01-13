---
title: 'Have fun building browser start page'
kind: article
created_at: '2017-01-10 00:00:00 +0800'
slug: have-fun-building-browser-start-page
preview: false
---

<figure>
<img src='./multiple-tiles.jpg'/>
<figcaption>My current setup</figcaption>
</figure>

Maybe it was my colleague, or maybe I feel the heat from [/r/startpages](https://www.reddit.com/r/startpages/)...
Whichever the reason is, I began building browser start page.

Default browser start pages are totally fine. Engineers' put in hard
work to make it convenient and visually pleasing, but it is not *my*
page. Just as people customize their desktop wallpaper, I want my browser
start page to do *this* and *that* while showing a refreshing background
image.

More than just simple background image replacement, or listing bookmarks in
various ways, it should show time and weather which are cool to look at
but essentially useless.

The finished code is available at:

<div style="text-align: center;">
  <div class="github-card" data-github="tommyku/start-page-demo" data-width="400" data-height="" data-theme="default"></div>
  <script src="//cdn.jsdelivr.net/github-cards/latest/widget.js"></script>
</div>

### Setting things up

#### Using webpack as module bundler

In this start-page project, `bower` is substituted by `webpack`, a
module bundler which compiles the source code along with modules used.
In `bower`'s way, components are first put inside `bower_components` folder and
then included in the HTML page one by one, while with `webpack` modules
are loaded as simple as calling `require('module-name')`.

~~~ coffeescript
# example.coffee
$ = require 'cash-dom'
$(document.body).text 'Hello World' # 'Hello World' is injected into <body>
~~~

Webpack uses `loaders` to pipe files through a set of processors when we
call `require` such that `gulp-sass` and `gulp-coffee` are no longer
needed.

~~~ coffeescript
# example.coffee
require '../css/app.scss'
# content of `app.scss` is passed through style-loader, css-loader, sass-loader and postcss-loader
# then injected into the page with JavaScript
# note: better keep a copy of the stylesheet inside <noscript> just in case
~~~

~~~ javascript
// webpack.config.js
module.exports = {
// ...
  module: {
    loaders: [
      { test: /\.scss$/, loader: "style-loader!css-loader?importLoaders=1!sass-loader!postcss-loader" },
    ]
  }
// ...
}
~~~

#### Using yarn along with npm

`npm` is fine but there exists `yarn` that runs faster and output better
information while running `npm|yarn install`.

`yarn` generates a `yarn.lock` file that records packages with version
numbers so the same packages are installed across machines.

For more of *yarn vs npm* see this [post](https://www.sitepoint.com/yarn-vs-npm/).

### Brainstorm what to add

Browser start page is personal. There is no pattern or best practices
associated with the genre.

Here is a list of stuff I might include:

- **search bar #**
- bookmarks
- **clock (w/without alarm) #**
- **weather report/forecast #**
- calendar
- kitten pics, lots of them
- notepad
- uptime of your current relationship
- doomsday countdown

<small><attr>#</attr> included in demo repo</small>

The [Startpage Emporium](https://startpages.github.io/) and [/r/startpages](https://www.reddit.com/r/startpages/)
are good places for seeking inspiration.

As often visited as a start page, it's better kept small
and fast. Consider importing external assets only when necessary
and minimize the `.js` files in production build.

### CSS grid

CSS grid is probably the reason for broken layout when you first build
and open build from the demo repo.

<figure>
<img src='./broken.jpg'/>
<figcaption>How broken it looks with CSS grid disabled</figcaption>
</figure>

The design shown of the demo is so simple it can be effortlessly
implemented with grids from `foundation`, `pure.css` or `bootstrap`.

Flexbox is too a viable option if I want to avoid UI framework entirely,
yet considering how troublesome flexbox is when implementing a 2D
nested layout (mainly for the bloated meaningless HTML structure), I opted for CSS grid instead.

<figure>
<img src='./caniuse-css-grid.jpg'/>
<figcaption>Fact: CSS grid isn't widely supported (as of Jan 2017)</figcaption>
</figure>

In Google Chrome 29 through 56, CSS grid is enabled through
'experimental Web Platform features' flags in
[chrome://flags](chrome://flags), so I did that.

A grid is exactly a grid, a 2D layout structure with grid cells and
lines defined using slightly abstract CSS syntax of
`grid-template-columns` and `grid-template-rows`.

~~~ scss
/* src/css/app.scss */
.grid-container {
  height: 100vh;
  display: grid;
  grid-template-columns: 12% 38% 38% 12%;
  grid-template-rows: 25% 25% 25% 25%
}
~~~

The above piece of CSS code defines a 4x4 grids with respective to cell
sizes (or separation between grid lines). Other than an extra grid
container that contains all grid elements, there is no need to change
the existing HTML DOM structure to accommodate for the CSS grid layout.

I look forward to CSS grid being a default feature in major browsers.
Meanwhile, a comprehensive guide is available on [CSS tricks](https://css-tricks.com/snippets/css/complete-guide-grid/).

### Chrome new-tab page override

Chrome pages namely Bookmark manager, History and New Tab pages can be
replaced by arbitrary Chrome extension with `chrome_url_overrides`
declared in `manifest.json`

Note other extensions might override your url overrides. In such case,
disable those extensions.

~~~ json
/* manifest.json */
{
  "name": "Start page demo",
  "description": "New tab replacer demo",
  "version": "0.1",
  "incognito": "split",
  "chrome_url_overrides": {
    "newtab": "index.html"
  },
  "content_security_policy": "script-src 'self' 'unsafe-eval'; object-src 'self'",
  "manifest_version": 2
}
~~~

Unfinished extensions are loaded into Chrome by clicking `Load
unpacked extension...` in [chrome://extensions](chrome://extensions/)
page.

### Sinitra web proxy on Docker

Have you experienced [*Same-origin policy*](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy)
getting in the way when you attempt to make a [cross-origin HTTP request](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS),
which most likely to happen when making an API request to 3rd party
service.

While it enhances security, it's hindering legitimate API calls we want
to make, specifically [Dark Sky API](https://darksky.net/dev/) for weather
report.

~~~ coffee
# src/js/weather.js.coffee
request = require 'superagent'

module.exports = {
  getWeather: ()->
    request.get('http://0.0.0.0:1080/weather')
  # ...
~~~

In the demo repo `weather.js` makes a call to a local server listening
at 1080 port which essentially wraps the Dark Sky API.

Make sure your've set the API key at the line `ForecastIO.api_key =
'YOUR_DARK_SKY_API_KEY'`.

The proxy server code is in `web-proxy` folder of the demo. With
Docker installed, starte the server by running:

~~~ bash
$ ./bin/build
$ ./bin/run
~~~

For those not running Docker, the server can still be started by:

~~~ bash
$ bundle install
$ ruby server.rb
~~~

While the server itself is straight-forward proxy that returns exactly
what Dark Sky API returns, Docker conveniently comes with `--restart=always` flag which
starts the container automatically on reboot, allowing us to run the
proxy with startpage with zero operational overhead.

### Masking/faking it til it's loaded

#### Masking the render

The page looks ugly for a split second before any CSS is injected and image loaded, then
everything looks normal again. There should be an element over
everything else masking all the ugly elements before the page is fully
loaded.

~~~ html
<!-- output/index.html -->
<html>
  <head>
    <!-- ... -->
    <style>
      .mask {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: white;
        z-index: 10000;
        opacity: 1;
        transition: opacity 0.2s linear;
        will-change: opacity;
      }
    </style>
    <!-- ... -->
  </head>
  <body>
    <div class="mask"></div>
    <!-- ... -->
  </body>
</html>
~~~

The mask does only one thing: mask the page in white before (hopefully) some JavaScript set
it's opacity to 0, revealing the fully loaded page under it.

<s>(exactly why you cannot click anything in the page...the mask element is still covering everything after unmasking)</s>

*edit: elements underneath the mask can be clicked by setting `pointer-events: none` on the mask*

~~~ coffeescript
# main.coffee
# ...
WeatherPanel = require './weather_panel.js.coffee'
DateTimePanel = require './date_time_panel.js.coffee'
Wallpaper = require './wallpaper.js.coffee'

unMask = ->
  $('.mask').css {
    opacity: 0,
    'pointer-events': 'none'
  }

  $ ->
    (new Wallpaper()).bootstrap()
    (new WeatherPanel()).bootstrap()
    (new DateTimePanel()).bootstrap()
    unMask()
~~~

The demo uses a bad approximation on the timing of unmasking. Bootstraping the panels do not mean
their respective assets (e.g. wallpaper, weather data) are fully loaded. This could be improved by a
`Promise`-based approach on each bootstrapped class, but we are simplifying here.

#### Faking API call

As it turns out, everything looks fine even on unmasking (disclaimer: works on my machine),
even the weather data is there despite our local proxy hasn't returned anything yet.

~~~ coffeescript
# src/js/weather_panel.js.coffee
# ...
class WeatherPanel
  # ...
  updatePage: ->
    return unless @report?
    $('.temperature').html "#{@lo @report.temperature}&deg;"
    $('.summary').html @report.current_summary
    $('.weather-icon').prop src: "static/weatherIcons/#{@report.icon}.png"

  getWeatherHandler: (err, res)->
    return unless res? && res.body.currently?
    current = res.body.currently
    @report =
      icon: weather.getWeatherIcon(current.icon)
      current_summary: current.summary
      temperature: current.temperature
      hour_summary: res.body.hourly.summary
    store.set 'weather.report', @report # store @report object into localStorage
    @updatePage()

  bootstrap: ->
    weather.getWeather().end (err, res)=>
      @getWeatherHandler(err, res)
    @report = store.get 'weather.report' # retrieve @report object from localStorage
    @updatePage()

module.exports = WeatherPanel
~~~

The trick is to cache API call result, either by simply storing it into localStorage or add a
service worker. In our case we are storing the data into localStorage, then update the page with
the latest data from API when it becomes available.

### Conclusion

This post illustrates the techniques I used when building my own [startpage demo](https://github.com/tommyku/start-page-demo).

Although many corners were cut to ensure timely delivery such as

1. only supports Google Chrome with flag enabling CSS Grid toggled
1. code not really organized by components
2. unmask on page loaded instead of on content loaded
4. wallpaper not optimized per screen size
3. used localStorage instead of service worker to cache API result

, many of the mentioned practices can be carried into general web developing and optimization.

And it's always pleasant to see *your own* startpage isn't?
