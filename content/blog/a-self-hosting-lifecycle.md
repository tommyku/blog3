---
title: 'A self-hosting lifecycle'
kind: article
created_at: '2018-07-13 00:00:00 +0800'
slug: a-self-hosting-lifecycle
abstract: 'How is it like to self-host something? This post describes the process
of self-hosting from the initial thought process, to patching and housekeeping, all
the way to the end-of-life of a self-hosted service'
preview: false
---

Nowadays, I self-host my own [todo list](https://github.com/tommyku/progressive-work-la-7-head)
, [pastebin](https://github.com/tommyku/tip3), [bookmarking chatbot](https://github.com/tommyku/googledoc_link_bot),
and YouTube downloader chatbot.
At some point I had also hosted a [note taking service](https://github.com/tommyku/ruby-server)
and an [expense tracker](https://github.com/tommyku/expense-tracker-lite).

The takeaway I got from self-hosting web service is:

> Self-hosting is like owning a pet,
>
> you don't have to unless you want to, but be prepared to pay and take care of it...
>
> ...except that you can abandon it anytime you want (kind of).

This post go through the process I used to decide whether to self-host something,
how to keep the service up-to-date and how to tell when I don't need it anymore.
I will mention a couple pitfalls I encountered when self-hosting that made switching
or shutting down a self-hosted service difficult.

## Before you decide to self-host...

First ask youself why. Same as buying a pet, you have to explain to the virtual parents
inside you head why you need to self-host a service. Alternatives to the service you
want to host is usually wildly available for free on the Internet, with perhaps more
modern user interface, more fluent user experience and better customer support.

The downside of using 3rd party web services is that they are generally proprietary
software, and you don't always have an idea what they are doing with your data. So if
privacy is your primary concern, you *might* really need to self-hosting it.

Yet let's not omit the [hidden cost of self-hosting](https://blog.tommyku.com/blog/the-hidden-cost-of-self-hosting/).
Think of the self-hosted service like a pet, it needs feeding (an VPS instance/server at home),
grooming (software update/housekeeping), bigger bed as it grows (CPU/RAM upgrade), risk of being
stolen (hacked) or used to serve other masters (hacked for botnet/cryptomining).

That's why I said you *might* need to self-host if privacy is your primary concern.
It may be better letting a reputable web service provider, especially those who have
no interest in selling your data (who?), to safeguard your data than to self-host
your service with insufficient security and leaving your data and server compromised.

There are more to think about in self-hosting something for the long term.

Instead of buying a pet, you may co-own your pet with somebody else too. I used to host
my own expense tracking and online bookmarking service until I figured out that I could
have [done it the layman way](/blog/doing-things-the-layman-way/) using Google form. I
use Google spreadsheet to process and analyse the data collected, without the need of writing
and maintaining an app.

> Perhaps there exists a simplier solution for the problem you intend
> to solve by self-hosting.

All that being said, there may just be a new service you found online that you really
want to try in which it's alternatives may be inferior or paid, then by all mean, go
ahead to the next step to get a taste of self-hosting without committing to it.

## Local-'host' the service

In the long list of [awesome self-hosted free software](https://github.com/Kickball/awesome-selfhosted),
there are many with demos or screenshots. You could get a taste of self-hosting conveniently
and for free.

Even if there is a demo server already running, you could spin up one of your own. To
keep unwanted packages and residue packages/config files lying around after testing it,
I recommend trying out self-hosted services using [Docker](https://www.docker.com/), especially
for those with a `Dockerfile` in their repositories already. Or, you could look up
[Docker Hub](https://hub.docker.com/) for preconfigured `Dockerfile`-s.

Setting up the service locally feels pretty similar to running it on an actual server,
minus the security and housekeeping side of it. You will encounter hiccups that hinders
the deployment, and at that point you'd have a pretty good idea if the software
package lives up to it's promise.

To me, many self-hosted services didn't make it past this point. For some that did please
you and delivered what they promised, you're left with one simple question to answer (for now).

## After all, A really simple formula

~~~ javascript
const goAhead = (() => (
  selfHostedService.hostingCost <= thirdPartyAlternatives.bestOf.cost
  || you.reallyLike(selfHostedService)
))();

console.log(goAhead);
~~~

Yes, forgot about all the hidden costs of self-hosting because you're super excited about
the prospect of self-hosting. Why stop here? Go ahead and spin up a server! Let's deal
with the potential issues one by one later.

## Self-hosting in 5 easy steps

Here I summarize 5 steps that's essential for self-hosting a web service. It is better that
you have had knowledge or experience in deploying a web service, yet it isn't necessary. A
bit of Googling around or reading the repository's documentation should get you started just
fine.

### Step 1: Domain name & DNS

A domain name pointing to your web service isn't absolutely necessary if you don't mind typing
in the IP address into the browser's address bar, or that it runs without any user interactions
(say, a web analytics service), then it's fine without a domain name. However with a domain name,
you can safely redirect users to server at a new IP should you decide to scale up or migrate to
another host later &mdash; just change the A record on your DNS setting.

A domain name helps you remember where your pet self-hosted service resides. You can get them for
a fairly cheap price nowadays on any domain registrar. My personal favorite is [https://domains.google]
because it provides free [WHOIS information protection](https://support.google.com/domains/answer/3251242?hl=en)
in which your personal information won't be shown when people look up the WHOIS record of your domain.
Yet with the advent of European Union's GDPR, there [may no longer be a need to get a WHOIS record
shielding](https://www.zdnet.com/article/icann-makes-last-minute-whois-changes-to-address-gdpr-requirements/)
in a foreseeable future no matter which domain registrar you use.

You don't need one domain name for each of your self-hosted services. With a reverse proxy you can
host multiple services on the same server and point multiple sub-domains A record to the same
server's IP. More on that in a later section.

Usually, a domain registrar also provides DNS service so visitors to your self-hosted service can
resolve the domain name into IP address of your service. For most of the time it's good enough to
stick to what your domain registrar provides unless it's exceptionally old and crappy (like some .hk
registrars unfortunately had to deal with before). Personally I use [CloudFlare](https://www.cloudflare.com/)
that just works almost all the time. It also provides DDoS protection by hiding the true IP of your
service. You may have concerns over the security/privacy of a DNS service tinkering with your traffic.
In such case, feel free to choose whatever DNS service you want.

### Step 2: Hosting

The big cloud computing companies has been building more and more server farms in many locations in
the world, and cloud hosting has never been cheaper and easier. You could spin up an VPS instance with
free credits and a few clicks on the web dashboard of cloud hosting providers.

Personally I used the $5/month virtual machines by Linode and Digital Ocean, depending on which
provides free credit at the time. If you're a student, you may find GitHub's
[Student Developer Pack](https://education.github.com/pack) useful as it provides hosting credit
(at the time of writing) and lots of other goodies. Non-students can easily look up for free credits
as hosting platforms seem to be on promotion all the time.

When choosing your cloud host, it is important to note the difference between PaaS (Platform as a
service) and IaaS (Infrastructure as a service). An PaaS provides the runtime for which your
application runs on. You have little control over the operating system and software preloaded
, say you may be given a MySQL database with a database, username and password, but not the root
access to that database. Heroku, Google App Engine and OpenShift are some examples of PaaS. An IaaS
provides a lower level infrastructure, say you can choose which operating system to run your
application on and use the software packages of your choice.

### Step 3: Server setup

Your server setup largely depends on the service you intend to host it on. Usually I use Ubuntu server
coupled with Docker because there is an abundance of documentations and Q&A online. Digital Ocean has
a [guide](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04)
that covers the basics of getting your server up and running. After following the guide you should
be able to SSH into the server and as a sudo-er. In addition, I would disable root logon via SSH and
disallow logging in via password for better security.

Running server software like Apache2, Nginx or whatever server that comes with your self-hosted
server seems trivial, yet running them as Docker container has the advantage of less garbage files
left behind after uninstallation. On my server, I am running multiple services in separate, isolated
Docker containers behind a [reverse proxy](https://github.com/jwilder/nginx-proxy). Using this setup,
I am able to run several self-hosted services on a single $5/month Digital Ocean droplet. In fact,
most self-hosted services I host use less than 50MB of RAM, so given 1GB of RAM I can run a lot of
them for cheap.

### Step 4: Backup strategies

Even in a managed cloud hosting environment, nobody can guarantee your data is always safe. Natural
disaster may occur, cloud hosting may get hacked, or [erase your data accidentally](https://about.gitlab.com/2017/02/01/gitlab-dot-com-database-incident/)
. To prepare for that, you should backup your storage.

What to backup for your self-hosted service differs from service to service. Most of them would run
one or multiple databases, and perhaps static files generated if you're running something like
a flat-file wiki. One reliable and free service to storing backup is Dropbox. Dropbox provides free
2GB storage and there is a command line tool [Dropbox-Uploader](https://github.com/andreafabrizi/Dropbox-Uploader)
useful for automatic backup to Dropbox.

You could first create a development app on Dropbox developer
[app console](https://www.dropbox.com/developers/apps) and obtain an access token for your app. Use
this access token when setting up `dropbox_uploader.sh` for the first time. Using an app folder
helps isolating the backup files of different self-hosted services to guarantee they won't overwrite
each other.

Here is a cron job I set up for backing up my database on a [hoodie server](https://github.com/tommyku/progressive-work-la-7-head-server).

~~~ bash
to access some data I missed or I changed my mind.
# crontab -l
# Run this every 6 hours
0 */6 * * * /home/tommyku/backup_hoodie_dropbox
~~~

And this is the content of `/home/tommyku/backup_hoodie_dropbox`.

~~~ bash
#!/bin/bash

rm -f /home/tommyku/backups/hoodie_couchdb/backup.tgz
docker run --rm --volumes-from progressiveworkla7headserver_couchdb_1 -v /home/tommyku/backups/hoodie_couchdb:/backup ubuntu tar zcvf /backup/backup.tgz /usr/local/var/lib/couchdb
bash /home/tommyku/dropbox_uploader.sh -f /home/tommyku/dropbox_uploader.conf -s delete /hoodie_couchdb/backup.tgz
bash /home/tommyku/dropbox_uploader.sh -f /home/tommyku/dropbox_uploader.conf -s upload /home/tommyku/backups/hoodie_couchdb /
~~~

This backup scheme has been running for well over a year, and I have never encountered any problem
with it. Two things you could also consider are logging each backup attempt and figuring out how to
restore the backups when shit *does* hit the fan.

### Step 5: Up and running

Now that you have the service set up, you can hit up your browser or your device to start testing out
your self-hosted service. Good, it works, for now.

You may consider adding a service monitor that notifies you if your service goes down for some reason.
I am using the free tier of [UptimeRobot](https://uptimerobot.com/) to monitor my server. It sends out
ping/HTTP requests in an interval to see if your server is alive and responding. You can even set up
a status page like [this](https://status.tommyku.com/) where your users can refer to when the server
goes down for an extensive period of time.

## Not just my own service

Good, you have a working self-hosted service. It may not be the best use of resource when it's just
you using it. The service is cool and you want everybody you know, even your dog to use it. Then you
should consider non-anonymous access or authentication on your self-hosted service.

Most self-hosted service come with user management. You might want to disable new user sign up
by toggling config flags, or even removing the route to user sign up page from source code directly.
There is no guarantee that a self-hosted service written by someone else would fit your use case
perfectly, so tinker around, don't be afraid to change their source code.

## Service just for myself

I have been adding restricted access through whitelist of Telegram user ID in my Telegram bots
, or stupidly long username:password pair for my Nginx file server. Mind that security through
obscurity is never a good idea though. Once a mischievous friend gets literate enough to figure out
your secret URL, then you're doomed.

I have seen bots trying to get into `wp-admin` of my site even though it is not running WordPress.
So be careful if you're running someone eles's software. You need to apply security patches and
upgrade regularly to mitigate security risks.

## Housekeeping/migration

Like habit forming, keeping a habit is harder than getting started. Once you have a self-hosted
service up and running, you will face hacking attempts by bots and unending amount of security
patches and upgrades to apply. You should follow the release page of your self-hosted service
for any new version, especially critical security patches unless your service comes with automatic
update check like WordPress.

With each upgrade there comes a risk of breaking what was originally working. Data may get lost or
become gibberish. Even if this upgrade go well, how about the next one? Backing up your data is thus
essential to the integrity of your service (We have covered that part).

In addition to keeping your service up to date, you should also keep the OS up to date as well.
Ubuntu applies security patches automatically so I am fairly content with that, but I still need to
logon to my server once in a while to upgrade the docker images for my reverse proxy and other
infrastructures.

## Deprecation

Deprecating a service is a tough choice, especially once you have tons of data in proprietary format
that only the code of your self-hosted service understands. Therefore it's important that your
service provides an 'exit option', say exporting to JSON/XML, or that it stores data in flat-file
format in the first place. A web scraper may come in handy should your service refuse to provide any
exporting option.

Powering down and destroying an instance is the easiest way to terminate a service. Generally, I would
take a snapshot of the instance and keep it for at least a month so I can spin it back up should I need
to access some data I missed or I changed my mind.

If your service is used by multiple people and it isn't your choice to shut it down, you should consider
who to delegate the tasks of maintenance and paying bills. Or if they need to migrate to another host,
how to ensure the migration is smooth and safe from data loss.

---

In this post I have gone through the lifecycle of self-hosting a service using my personal experience
and some of the thoughts I had when I was running my services. Self-hosting isn't an easy task given
so much to consider and to maintain in the long term. Perhaps we should expand the simple formula to

~~~ javascript
const goAhead = (() => (
  selfHostedService.hostingCost + selfHostedService.effort < thirdPartyAlternatives.bestOf.cost
  && selfHostedService.lifeTimeValue > thirdPartyAlternatives.bestOf.lifeTimeValue
  && you.canMaintain(selfHostedService)
  || you.reallyLike(selfHostedService)
))();

console.log(goAhead);
~~~