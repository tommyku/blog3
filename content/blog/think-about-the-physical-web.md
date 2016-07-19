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
<img src='http://elseheartbreak.com/Hack2.jpg' width='50%' />
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

### A real world case study

Earlier on a technical demo was presented to the product manager and the management where I worked.

Imagine a conference where self-serviced check-in is empowered by the Physical Web -- connecting to a printer that prints
you a name badge right after you clicked '**One-click Check in**' from your phone -- 1 tap, 3 seconds, done.

(talk about the beacon)

(talk about the invitation email)

(talk about simple attendee app)

(talk about printer)

### Why is it *not yet* there

(need to at least install Chrome)

(not quite stable, esp. on Android)
