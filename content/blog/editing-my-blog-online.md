---
title: 'Editing my blog online'
kind: article
created_at: '2019-03-08 00:00:00 +0800'
slug: editing-my-blog-online
preview: false
abstract: 'My blog used to be only editable on my a PC, which made me unable to edit on the go, until I have
made this infrastructure change that is surprisingly simple'
---

<!-- 
This line is 80 characters long
01234567890123456789012345678901234567890123456789012345678901234567890123456789
-->

Since my blog was first created and even after multiple revamps, there is no
online-editing capability, until today as I am writing this post on the web.
The solution is surprisingly simple that I couldn't believe why I haven't done
this earlier.

I use a static site generator called [Nanoc](https://nanoc.ws/) to convert
posts written in markdown into HTML. One property of a static site generator
is that I cannot edit my blog online unlike CMS such as WordPress, I couldn't
edit my blog online.

After an infrastructure change, I am now able to logon to a file editor on
PC or mobile and see immediately the change I made on a clone of my blog in
DEV environment.

## Before

<figure>
<img style='max-width: 100%;' src='./before.png' alt='Date flow before this change' />
<figcaption>Originally, local machine is required to perform any change</figcaption>
</figure>

Before this infrastructure change has been made, I needed to 

In order to make any change blog content, I have to open
the posts, written markdown, using text editor, save it, and push it to GitHub
such that the CI can compile and deploy the updated pages.

There is no need to change any of the existing flow. The issue that troubles
me so far has only been the part where I cannot edit online. Being a lazy, I
don't want to migrate my blog to a headless CMS either &mdash; that'll be an
overkill and I don't like my data being tied to one specific platform.

Therefore, I cloned the existing setup and added online content editing,
hopefully together they work as planned.

## After

<figure>
<img style='max-width: 100%;' src='./after.png' alt='Date flow after this change' />
<figcaption>Cloned the whole setup with online file editing, less CI and deployment target</figcaption>
</figure>

The Dev server I have been using came with Nanoc. Nanoc itself doesn't listen
to file change unless you couple it with Guard, which has been bundled into
the release of Nanoc I am running on.

Basically, I run `nanoc live` and it recompiles the diff every time I save a
file. The site sits behind a Nginx reverse proxy with basic auth
[just like how I did for many things else](/blog/hide-docker-containers-behind-nginx-proxy/).

I spent a hour searching online for something I can just easily hook onto a
folder so that I can edit the folder content on a web page, ideally with Docker.
So far, only [File Browser](https://filebrowser.xyz/) fits the bill, and man it
looks and works great.

Isn't this super obvious? I was surprised when I wrote this setup down on paper,
wondering why haven't I figured it out earlier, and even wasting an afternoon
looking at some headless CMS offerings.

The purpose of running my own server and a few web services is so that I can learn
to be lazy. And with this zero-migration setup, lazy I am.

<figure>
<img style='max-width: 100%;' src='./editing-online.png' alt='How editing online looks like on my laptop' />
<figcaption>How it looks like when I write on my laptop</figcaption>
</figure>
