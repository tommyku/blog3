---
title: 'Using Google Form to track my life: a lifelogging primer'
kind: article
created_at: '2018-11-13 00:00:00 +0800'
slug: using-google-form-to-track-my-life-a-lifelogging-primer
preview: false
abstract: 'Not only Google can track your every move, now you can track
your own life using what Google is offering for free, and for your own
good'
---

Lifelogging is the activity of collecting records of one's life over an
extended period. Most of them are quantified data such as weight, sleep
time and expenses. Although technology isn't a precondition for
lifelogging, many opted for gadgets and smartphone apps that made
tracking less intrusive and more convenient. There has never been a
short of lifelogging apps and devices in the market that represents a
barrier to beginners of lifelogging - isn't it annoying to use an ads
infested app, or buy an expensive gadget? In this post I am going to
show you lifelogging for free [in the layman's way](/blog/doing-things-the-layman-way/).

I have been lifelogging since the beginning of 2018. My dataset expanded
from just daily measure of body weights to my sleep duration, expenses,
steps walked, moods, drinks drank and more. Lifelogging may seem
troublesome in a glance, with expensive gadgets and intrusive/shady
mobile apps as prerequisites, but it doesn't have to be like that.
Lifelogging can be done cheap and easy. I am going to show you how to
lifelog with just Google Form.

## Google Form + Google Sheet = lifelogging
First you'll need a Google account. The thing is you have you store your
data on Google, otherwise, there's no point to continue reading. Go to
Google Drive, click “Create” and select “Form”.

You are creating a form. Like a web survey page, you can define
questions of different kinds, some useful fields are text, date, time,
number and multiple choices. I am sparing you the details of how to
create a Google Form because there are much better tutorials already on
the Internet, and that the point of this post is to show you how I use
Google Form as a mean of lifelogging.

For example, the picture below shows a form tracking what I drink. This
form uses standard single-line text, radio buttons for multiple choice,
datepicker and timepicker for recording time on top of the automatically
appended response time (more on that later).

<figure>
<img style='width: 100%; max-width: 640px;' src='./drink-form.jpg' alt='A google form, tracking the kind of drink I consume with date and time' />
<figcaption>I actually use a Chinese version of this form to track my daily coffee/tea intake</figcaption>
</figure>

You can then create a sheet to store all form responses. A good thing
about this is, you can add many worksheets in the same workbook to
generate reports based off form responses. One note: you may want to
hide the rows on top regularly to avoid scrolling 1,000+ rows to the
latest records every time you visit the sheet.

<figure>
<img style='max-width: 100%' src='./report.jpg' alt='A line chart
showing variations of body weight over time' />
<figcaption>Graduation from university happened, then my weight rebounced</figcaption>
</figure>

## Google Form + Progressive Web App

Everything thus far has been obvious and simple. You can get one of
those set up and run just fine for most use cases, unless you are
interested in alternative form management. To those who are interested
in dig deeper into how Google Form works, I am presenting&mdash;

<figure>
<img style='width: 100%; max-width: 320px;' src='./startpage.png' alt='Mobile webapp, with links to each of the forms' />
<figcaption>Make a progressive web app to collect all forms</figcaption>
</figure>

Bleh.

You may say, this isn't anything surprising because browser bookmark can
well serve the same end. True. Clicking any of the rectangle basically
opens the form page on a webview. However, one interesting thing you may
discover if you check the HTTP request the page makes when submitting a
Google Form, there is one surprising thing.

<figure>
<img style='max-width: 100%;' src='./post-request.png' alt='Form data of POST request when submitting a Google Form response' />
<figcaption>Surprisingly simple internal working of Google Form</figcaption>
</figure>

In the age of single-page app, service worker and AJAX calls, Google
Form still do things the old-school way. It's how things worked 10
years ago, when I first learned HTML. As long as your page submits a
POST request with form body that resembles what Google Form is
submitting.

In fact, in one of my work back in 2013, a graduation photo registration
website for my University was made to recreate the form Google Form is
using under the hood, yet it looks entirely diffent than Google Form.

<figure>
<img style='max-width: 100%;' src='./grad.png' alt='HKUST graduation
photo taking form, made using Google Form under the hood' />
<figcaption>Everything were exactly the same as they were except I modified the form URL</figcaption>
</figure>

This presents an interesting opportunity for us because now we can make
a form however we like that can look arbitrarily different from the
original Google Form, leading us to the last section of this
post&mdash;, your very own lifelogging app with the backend taken care
of.

## Progressive Web App

<figure>
<img style='width: 100%; max-width: 320px;' src='./expense.png' alt='Mobile webapp, with a form looking different from Google Form' />
<figcaption>Yes, it is Google Form under the hood, but better</figcaption>
</figure>

As everything down the pipeline is handled by Google Form, and there's
nothing stopping you from doing whatever you want to the user interface
before form submission. In my progressive web app shown above, I added a
list of historic responses. Tapping them will automatically populate the
form and then submit the form. Of course, it still requires Internet
connection in order to submit the form, so it isn't exactly optimal.
Also, submitting the form inevitably redirects you to Google Form's
default response page, breaking the illusion that you host your own form
instead of using Google's.

However, this behavior can be worked around by simply proxying form
responses. This way, you delegates the form submission to an application
serving as a proxy on a web server, instead of submitting the form by
yourself on a web page. With that, you can even cache your requests
using service worker, or do all sorts of preprocessing before eventually
submitting it to Google. I do have a Telegram bot doing that job for me,
as a sort of personal bookmark. Sharing links to Telegram on the mobile
is faster than opening up a form and pasting it. Plus Telegram does a
good job caching the request when my phone is offline.

<figure>
<img style='width: 100%; max-width: 640px;' src='./telegram.png' alt='A Telegram bot
receiving links, and submitting it to Google Form' />
<figcaption>I use a Telegram bot to receive links and submit them to
Google Form. It works offline.</figcaption>
</figure>

You may say, at this point things have evolved so much it has reached
escape velocity from the layman planet to the domain of web developers.
In fact, you are probably right. Stopping at any point of this post can
still well serve you in a lifelogging perspective. At the end, we just
want to log stuff, and perform post-processing.

One caveat is that, it only works if Google Form continues to work this
way. There is nothing we can do about it when Google decided to kill
Google Form, as they did for many old Google products. Even so, it is
not difficult to roll out a Google Form replacement. A alternative to
downstream integration with Google Sheet could be difficult though.

I wish this post gives you some useful insights into how to use Google
Form for your lifelogging purpose. Note that I don't mean Google Form is
the only way of lifelogging. Bullet journal, mobile apps, fitness
trackers all serve their own niches, yet if you don't feel like
investing heavily into lifeloggin, Google Form can be an easily accesible
alternative.
