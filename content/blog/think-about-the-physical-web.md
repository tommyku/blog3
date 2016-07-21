---
title: Think about the Physical Web
kind: article
created_at: '2016-07-21 00:00:00 +0800'
slug: think-about-the-physical-web
preview: true
---

On the Internet different resources are referenced by URL, or *Unversal Resource Locator*. A webpage, a picture, a
video, a file, or any other things you open on browser have such a URL so when you type that into your browser's address
bar it knows where to look that piece of resource up.

Think of the same thing but for real world objects -- a TV set, a phone, a light switch, even a table could have an URL
which you open on your browser, granting you the ability to control -- even hack that object as players'd do in a video
game.

Yes, hacking real world object right at your fingertips.

<figure>
<img src='http://elseheartbreak.com/Hack2.jpg'/>
<figcaption>Screenshot from video game `Else Heart.Break()` where player hacks an object (<a href='http://elseheartbreak.com/'>image credit</a>)</figcaption>
</figure>

The idea of [*The Physical Web*](https://google.github.io/physical-web/) was introduced by Google back in 2014. It
wasn't a thing until this year when it was featured in [Google I/O 2016](https://www.youtube.com/watch?v=-kjzVB8plZE).

Hey, you can hack real world things, without even plugging a cable into it or connecting it to the Internet (at least some
of them, I will mention it later).

### Physical Web is about the web

> Physical web is QR code without scanning, and you can control a trash can on a phone.

After a lengthy discussion with friend this is what we came up with if we had to describe the Physical Web in one
sentence.

The core technology behind Physical Web is becons working with [Eddystone beacon format](https://github.com/google/eddystone) based on Bluetooth.

A Beacon, a little device to place just anywhere, continuously broardcasts a URL via Bluetooth to the surrounding area.
Any device nearby can see an URL broadcasted by the beacon and those who open the URL from a browser can interact with
either an online service or the device connected to the beacon itself.

So yes, technically you can use the Physical Web to connect to your trash can and control it from *any* device that has
Bluetooth, browser, and can recognize the Eddystone format.

### A case study

Earlier on a technical demo was presented to the product manager and the management where I worked. I can't share too much details about it, at least I can tell you it was well received.

Have you ever thought that waiting in queue only to wait for a ticket is a stupid idea? We the university students stupidly
wait in queue just to order something, wasting precious time that we could otherwise use to deal with midterms and assignments.

Imagine when you go to the student canteen, swipe down the notification bar on your phone, click on a link to a web app, select your
the food and pay with Android pay or Apple pay.

Boom! On screen you see the estimated waiting time for your order. You go on to grab a seat with friends, and wait for
the push notification the restaurant shall send to your phone when your food is ready.

Show the staff your ticket number and get the food from one of the collection points.

Hey the best part of it? No app installed, just walk in and use.

Take a note that Android/Apple pay, push notification and web app are not part of the Physical Web, but without them
Physical Web might as well be another QR code alternative. They provide in-context native app-like support to many
things people do with apps on a web browser. It feels like having another native app on users' phone that shows up only when
users need it.

### Why is it *not yet* there

Sounds good? Then why nobody's using it? I don't see it in any of the local restaurants either.

First you need a scanner that scans for nearby beacons broadcasting URLs. You might not know that it's already built-in
on Google Chrome browser for iOS and Android.

[This guide](https://support.google.com/chrome/answer/6239299) teaches you how to enable it on your phone. Think about
it, who bothers turning the Physical Web scanner on unless it's extremly relevant to them. Not everybody knows how to scan a QR code even
these days!

The demo I showed to my colleagues was done using solely iPhone because it is pretty unstable on Android device.
On Android device the Physical Web notification is set to low priority. Android OS decides when to show you the Physical Web URLs it got and in many cases they don't show up at all. On iPhone they are better because it scans for Physical Web URLs whenever you pull down the notification
bar.
