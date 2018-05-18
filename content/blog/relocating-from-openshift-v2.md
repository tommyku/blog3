---
title: Relocating from OpenShift v2
kind: article
created_at: '2018-05-18 00:00:00 +0800'
slug: relocating-from-openshift-v2
preview: false
---

This post summaries my efforts over September and October to migrate my
websites and apps away from OpenShift v2 to other hosting platforms as
Red Hat finally closed it down.

## What is OpenShift?

OpenShift is an PaaS service by Red Hat originated from 2011, it
provides infrastructure for users to deploy their apps with little to no
concern about the underlying infrastructure where the app runs on.
Deployment can be as simple as a `git push` command, given that the
git `post-receive` hooks have been properly configured.

I have been using OpenShift v2 since 2012 to deploy production
application for my freelance and personal projects. The free bronze tier of
OpenShift v2 allows for 3 'gears', which are instances of a virtual
machine on OpenShift platform. The resource constraint never bothered
me. If you run out of 3 gears, you can register for another OpenShift
account, then link the new account to the existing one such that
you can use the same SSH public key to deploy to the 3 additional gears
in the new account.

That means you can run virtually unlimited number of apps for free,
without credit card.

To Red Hat, this exploit might have costed them so much that they had
to close down OpenShift v2 in favor of the newer OpenShift v3. On
OpenShift v3 the cheapest tier 'Starter' allows for only 1 project, the
next tier 'Pro' allows for 10 projects at $50/month. Well, OpenShift v2
could have died of old age though.

That sucks. I had to move 14 websites/apps, including a client project from
OpenShift to other platforms:

- 1 client project
- 1 web API (require relocation)
- 4 website/web apps (require relocation)
- 8 website/web apps (trashed)

## Options aside from OpenShift v2

I love free things. Free things that remain free in long term are even
better. On September I had these options:

  - Digital Ocean (with GitHub's $50 student credit)
  - Free tier from AWS, Azure and GCP (free for 12 months)
  - GitHub Page

Digital Ocean offers virtual private server that I can install anything
on. AWS, Azure and GCP provide a wide variety of products and solutions
to suit various requirements and at different price ranges.

If you don't mind open-sourcing your static site or that your site uses
external APIs for dynamic features, GitHub Page would be your best
choice because it's completely free and ships with HTTPS by default.

## Post-OpenShift v2 life of hosting

Long story short, I moved all static assets from OpenShift to GitHub
Page. These include blog, static websites and web apps using self-hosted
database like Hoodie. For sites that are dynamic, I would re-think
whether it needs to be dynamic, or whether I really need the site
itself. I will go into more details about those sites. And for those
which I really must host on a VPS, I hosted them together on one single
instance on Linode or Digital Ocean, whichever I have free credits on.

### Static sites

[GitHub Pages](https://pages.github.com/) are great because it is free,
it hosts reasonably big static sites, it serves sites over HTTPS, it
allows for CNAME binding so I could use the domain names of my choosing
and I have never had any issue with it except the deployment time after
`git push` is rather random.

My sites and web apps locally using static site generator such as Nanoc
or bundler such as webpack, then I would commit the build to `gh-pages`
branch of my repo, then off it goes with `git push`.

I have deployed some of my [progressive](https://github.com/tommyku/expense-tracker-lite)
[web apps](https://github.com/tommyku/tip3) and deployed them using the
`gh-pages` package from the npm repository. It copies your build folder
and commit it to the `gh-pages` branch, and deploy (push) it to GitHub.
As my PWAs are using a self-hosted Hoodie backend of mine to store the
data, I did not have to worry about leaking my keys or tokens to the
public because my apps simply don't rely on them.

### Unnecessarily dynamic sites

After writing the [post about doing things the layman way](/blog/doing-things-the-layman-way/),
I have embraced the lazy approach to things &mdash; I don't have to do
everything by myself, and if I am to do them myself, I would take the
shortest path and the easiest approach.

Which means I discontinued my project of building my own bookmarking
service [link2](https://github.com/tommyku/link2-server) and embrace
the simplicity of Google Form and Spreadsheet instead. Simple, easy, and
free. I didn't have to pay for my own bookmarking now, and Google
probably won't care enought to look at my Spreadsheet to try to
"understand" me.

I used to host a website that tells you which room on campus is probably
empty, so instead of going to the library where everyone is coughing or
sneezing or both, people can use empty classroom to study free from
distractions. The website was written in Laravel, which requires PHP and
a MySQL database. Deeper look into the service made me realize that it
doesn't have to be dynamic. It could just be a bunch of JSON files, and
a progressive web app that loads up those files for once, then read from
cache forever. Yes, the service is no longer dynamic and it's now hosted
freely on GitHub Pages instead.

### Dynamic sites, databases and bots

Although offloading static content to GitHub Pages saved me a bunch of
money from VPS, some still require a server to run on. For example, a
Hoodie backend requires a Node.js environment and CouchDB. Plus I am
running a bunch of small Telegram utility bots and web services
such as a link shortener, a wrapper for youtube-dl and HTTP file server as
its companion, and some secret sites of mine.

I don't need 512MB RAM and 1 vCPU per service. In face, an VPS instance
of 1GB RAM and 1 vCPU is more than enough to run all of them. I used
docker to better maintain multiple servers and services in containers,
and fired up a [Nginx reverse proxy](https://github.com/jwilder/nginx-proxy)
to tunnel traffic for each service into their respective container. It's
automatic and I could disable/enable any of them with a few lines of
commands.

I paid $5/month to Linode for an VPS instance which I run multiple
services on. It is fairly cheap, but if I wish I could even set the same
thing up at home, using a Raspberry Pi 1 Model B which I had no purpose
for since I have bought it a few years back. I could set up
port-forwarding from my router, and use `ddclient` to update my Cloudflare
DNS record automatically. However, the marginal benefit of doing this
would be minimal compared to having an VPS on the cloud where they have
better spec and more bandwidth.

## Conclusion

OpenShift v2 has been the birth place of my career by allowing me to host
my random and mostly crappy creations over the years, but I had to move on.
Like dynasty, hosting services live and die. They might discontinue all
of a sudden for a lack of profit or prospect (obviously). And people
have to move on. Hosting has never been as cheap and accessible as
today, and I wish they continue to live on, free or paid alike so I
could continue to have a place on the Internet.
