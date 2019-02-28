---
title: 'Debugging by testing assumptions'
kind: article
created_at: '2019-02-23 00:00:00 +0800'
slug: debugging-by-testing-assumptions
preview: true
abstract: 'Recently I have wasted half an hour of my life
troubleshooting an issue related to Apache2 and systemd when upgrading
from Ubuntu 16.04 to Ubuntu 18.04, here is what I learned'
---

When troubleshooting an issue introduced not by a simple and apparent
cause, it could take from from 10 minutes all the way to hours and days,
leaving ourselves scratching our heads and nearly suffering an emotional
breakdown. However, it needs not be the case had we had a healthy mindset when
troubleshooting the issue.

> It works on my machine
> &mdash; most common excuse used by programmers

At the beginning of troubleshooting, be an error message or something
not working the way we expect it does, we can take this assumption, and
start from here.

Ask yourself one question: What are the key differences between my
system and the system I am troubleshooting on?

The key differences may be:

- versions of the runtime
- versions of the dependencies
- application state (e.g. uninitialized database, config files)
- external dependencies (e.g. database, library, network and external
APIs)
- system level restrictions/configuration (e.g. firewall, RAM/CPU
limitation, user permissions)

Here comes a real-world example of me trying to trouble a mysterious issue
in my program &mdash; not a bug because the issue ended up to be non-code
related.

I upgraded my OS from Ubuntu 16.04 to Ubuntu 18.04. With it comes PHP
7.2 which is incompatible with the framework Laravel 5.5 that my
application depended on. Luckily, there is an PPA `ppa:ondrej/php` that
adds `php7.0` and related packages to Ubuntu 18.

Now here comes a problem. My application looks at some `.lock` files
stored in system `/tmp` folder to determine it's state. That worked on
my Ubuntu 16.04 setup and my development environment on Docker. However,
it stopped working after the OS upgrade.

What gives?

My original thought was that the view cache was not updated, so I
cleared the caches in Laravel by running `php artisan cache:clear`. Nope
that doesn't work. What about actually running the code? I fired up a
PHP command prompt with `php artisan tinker` and ran my line
`var_dump(file_exists('/tmp/something.lock'))` and sure enough I got
`bool(true)`. By that time I realized that I was stepping into the
WTF land of deployment.

It was supposed to be an one-hour deployment, now it has passed the
1.5 hour point and I still hasn't figured out what happened. One
signature sign of you're looking into the wrong problem is that there
aren't many StackOverflow questions about the topic because that means
nobody was unfortunate enought to stumble upon the same problem.

