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

As we know, computer systems nowadays are constructed as layers upon
layers of abstractions, so to troubleshoot we need to focus on each
layers as if we are peeling an onion.

Starting from runtime level, the key differences may be:

- versions of the runtime
- versions of the dependencies
- application state (e.g. uninitialized database, config files)

On layers below the application there are:

- external dependencies (e.g. database, library, network and external
APIs)
- system level restrictions/configuration (e.g. firewall, RAM/CPU
limitation, user permissions)

Then there are hardware, which is rather difficult to troubleshoot
unless we have replacement parts to see which is working/not working.

We should test our assumptions that every layers of the system works,
until we figured out which doesn't. To test the assumptions, we
perform test on separate layers to ensure that they work, and move on
to the next layer.

> We should test our assumptions that every layers of the system works,
> until we figured out which doesn't.

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
WTF land of troubleshooting.

It was supposed to be an one-hour deployment, now it has passed the
1.5 hour mark and I still hasn't figured out what happened. One
signature sign of you're looking into the wrong problem is that there
aren't many StackOverflow questions about the topic because that means
nobody was unfortunate enought to stumble upon the same problem.

Here is where we begin testing our assumptions. We have tested using
the PHP interpreter to see that `file_exists` works. Now we need to move
one layer up (or down depending on which way you look): Apache.

I will skip the dirty details and jump right to the conclusion. I did
something similar with that `php artisan tinker` step by creating a
separate PHP script inside my `/var/www/html` where my PHP pages reside.

Thing is, whenever I run `file_exists` by invoking a script from Apache,
it fails to recognize the file inside `/tmp`, so I can tell that
something is wrong with Apache. Further investigation by running
`scandir` tells me that from Apache's prespective, `/tmp` is an empty
folder.

But why? [systemd - why php can not see /tmp files - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/345122/why-php-can-not-see-tmp-files)

When you ask the right question, it's often easier to find the answer.
And that's why I believe troubleshooting requires testing the
assumptions. By testing assumptions you can drill down layer by layer
until you located where the culprit is. Once the defect has been
identified, it's much easier to figure out a solution.

Consider this approach a linear search &mdash; obviously there exists
the binary search variant called
[half-splitting](https://en.wikipedia.org/wiki/Troubleshooting#Half-splitting),
which I eventually had to employ on another issue that was closely
related to two pieces of hardware talking to each other.
