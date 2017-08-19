---
title: 'The hidden cost of self-hosting'
kind: article
created_at: '2017-05-17 00:00:00 +0800'
slug: the-hidden-cost-of-self-hosting
preview: false
---

One day I stumbled upon a list on GitHub
[Kickball/awesome-selfhosted](https://github.com/Kickball/awesome-selfhosted)
listing open-source services and applications that can be hosted locally
or on my own servers. The list covers much more than you'd expect, you
can find alternatives to most close-sourced services you use daily on
the list. For example, Nextcloud does mostly what G Suite does; use GitLab to
replace GitHub; use Mastodon, the free (as in freedom) clone of Twitter...

Nowadays high-quality (and some not-so-high-quality) online services are
available for free to the public in every steps of life. All it takes is
usually just an email address and a password, maybe phone verification
too, then one can enjoy limitless photo backup on Google Photo,
reach millions of people on Twitter, etc. Sounds awesome? No, there
comes the hidden cost as you hand over your data and willingly subject
yourself to their [experiments](https://www.theguardian.com/technology/2014/oct/02/facebook-sorry-secret-psychological-experiment-users) and [selection of ads](https://privacy.google.com/intl/en/how-ads-work.html).

Of course, I don't mean stop using all those awesome free services and
start self-hosting everything yourself. That'll be impractical and
prohibitively expensive in both storage and actually running the
services. The good thing is, there are always self-hosted alternatives
to opt for.

As it turned out, it wasn't a easy task to self-host anything, not at
all.

## Hosting my own note-taking service

The time was the beginning of the semester, when I had to decide which
note-taking application to use for the semester. I used to take note
with pen and paper. They are ineffective and too heavy to carry around
near the end of the semester.

I needed something that syncs and backups automatically, works on both
laptop and mobile, and should look nice enough. Originally it wasn't about
self-hosting. I took notes on Vim and sync them to GitLab. Shortly
after, I trashed this practice because my notes are always out of sync
and I couldn't read them on the phone.

Then I found Standard Notes.

<figure>
<img src='./hero-banner.png'/>
<figcaption>Standard Notes, a self-hosted note app (image: <a href='https://standardnotes.org/'>Standard Notes</a>)</figcaption>
</figure>

Standard Notes is just one app thats connects to a [Standard File](https://standardfile.org/)
server. Think of it as a personal database that can be used across all
apps in an encrypted, standardized format. With Standard File server, you
own your own data. Nobody can tamper with your data. Nobody can look into
the data and tell what kind of ads or site you should visit. Standard File server
should remain private and encrypted, end-to-end. As such, I was sold.

The time is 2017, it is easy to gather the necessities to self-host
something. Domain name? GoDaddy. SSL? Let's Encrypt or Cloudflare.
Hosting? Digital Ocean/Linode. With the proper knowledge and choice of
service provider it shouldn't break your bank trying to self-host
something.

However there were a few issues. Setting up a Standard File server could
be a [lengthy process](https://github.com/standardfile/ruby-server/wiki/Deploying-a-private-Standard-File-server-with-Amazon-EC2-and-Nginx) involving a bunch of command crunchings. To facilitate the process
one could use Docker, if there was a Dockerfile with documentation.

Turned out there was no proper `Dockerfile` merged to the repo
[standardfile/ruby-server](https://github.com/standardfile/ruby-server)
and no documentation regardling deployment using Docker whatsoever. It
took me two nights to modify a `Dockerfile` from a fork, and a few more nights to finish a
[*proper* one](https://github.com/standardfile/ruby-server/pull/44) and get it merged.

<figure>
<img src='./standard.png'/>
<figcaption>The exact screen you see when you navigate to your Standard File server domain</figcaption>
</figure>

Cool, now can I finally deploy it and don't have to worry about it for the
decades to come? Not really.

When you own a server out there you'd have to worry about what any
sysadmin would worry about. You should [backup regularily](https://about.gitlab.com/2017/02/01/gitlab-dot-com-database-incident/), prevent [attacks](https://www.fail2ban.org/wiki/index.php/Main_Page), keep the software
up to date, [monitor the uptime](https://uptimerobot.com/) and remember to pay for the domain and hosting. This may seem to be a no-brainer for seasoned admins but as someone new to the field,
it felt frustrating to configure multiple additional software just to get one
self-hosted online service running. A couple hours should be enough to configure everything and
you can eventually begin to enjoy your own self-hosted service that probably
won't work better then its commercial counterpart, but it's free, and
you own the data.

Very soon you may think it's too crappy and want to modify the
source code yourself. That might take a couple more days away from your life
albeit in the open-source community perspective it's the preferable way
to do things.

## So, should I start self-hosting?

Nobody has to self-host something if free commercial
services should suffice. But one big feature of those services is the safety
of your data, even [if the company hosting it is sold](https://mobile.nytimes.com/2015/06/29/technology/when-a-company-goes-up-for-sale-in-many-cases-so-does-your-personal-data.html). Government, good or evil,
could forcefully access your data. If you believe your data worths more
protection then their own business interest, [think again](https://govtrequests.facebook.com/), [think thrice](https://www.google.com/transparencyreport/userdatarequests/legalprocess/)
if you have to. You may not have something to hide, most people don't.
That doesn't mean in essence someone can legitimately look at your
data without asking.

Self-hosting gives you the option to lock something up and throw away
the key when necessary. While it is possible to reset password on most
online services, you can keep the password that also serves as the
encryption key of your data only in your head. If you decide to hit
yourself in the head to forget the password, nothing better than brute-force
guessing can recover the data.

You pay your hosting company to keep the server running every month. For
anything that you'd rather take to your grave, just leave it. Take
Digital Ocean as an example, your data [will be purged](https://www.digitalocean.com/help/pricing-and-billing/general/) if you don't pay the bill for a long enough time.

<figure>
<img src='./after-i-died.jpg'/>
<figcaption>Self-host things that you want to keep secret forever</figcaption>
</figure>

Self-hosting is difficult to set up and troublesome to maintain. Most of the
the open-source self-hosting solutions are less user-friendly and less
functional then their commercial counterparts. Domain name renewal and
hosting may cost a lot in long run. In exchange, you can own your data
and peace in mind knowing nobody can sell your data for profit or
access it without your authorization (unless they hack, but who cares
about your data).
