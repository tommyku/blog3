---
title: Building reusable things, FTW
kind: article
created_at: '2015-03-23 00:00:00 +0800'
slug: building-reusable-things-ftw
abstract: 'Exploring the concept of encapsulation that I learned and
building a reusable package for a pet project'
---

I was working on an API wrapper for HKUST library room reservation system for my COMP4971F Independent Work. The nasty way I usually did was to hack the application out of a fresh Laravel build by putting all the parsing, booking and strange work-arounds inside the controllers. This time, I decided to build a composer package `tommyku/liba_lib` ([github](https://github.com/tommyku/liba_lib)) instead.

We have spent way too much time re-inventing the wheel for the web, only that they look slightly different from another. Popular front-end frameworks, toolkits and CMS/templates such as AngularJS, normalize.css and Wordpress did make people re-invent lesser of the wheel. Still, some reusable parts are mingled with the logics which may encourage reuse by copying instead of nice encapsulation.

> Whenever something is reusable, separate them from the constants of your program.

By constants I mean tailored codes that probably cannot be used elsewhere; while by reusable I mean methods or structures that may be plugged into another controller/app and still work fine by itself.

My object-oriented class instructor Dekai once deducted me some 30% of my assignment score just because I put an inline function into one .cpp, while that function was called by two supposingly independent classes. Encapsulation and date hiding was strictly enforced for the remainder of the course.

Looking back, I see the reason behind. Components with good encapsulation communicates with other parts of the program solely by an interface that has been designed and communicated to the other team members. This makes it reusable by default because it doesn't depend on other components unless specified. You can grab the class/library and use it almost anywhere. Unit tests are simple by default because you will be just dealing with a set of function calls as defined by the class interface.

> Encapsulated classes are reusable by default, and performing on a single class unit test much is less painful than a single class within a pool of other logics.

Encapsulation is good, things are reusable. Are we done yet?

Let's dig deeper. Why is it better making some sets of functions a composer package instead ofusing a simple separate .php? The same 2 reasons: testing with convenience and code reusability.

#### Being smart on unit testing

If you navigate to [liba_lib](https://github.com/tommyku/liba_lib) you will see there is a `tests/` folder containing test cases which I use for phpunit tests. Unit test is made convenient this way because I can test directly the core library functionalities without having to call Laravel route and invoke many other logics that I don't intend to test. Feel free to clone the repo and run `make test-all` to test it, given that you have a ITSC account to access the library system.

> You can test the core functionalities of your library without invoking other logics you don't intent to test.

#### Automatically reusable

In case you want to use my library to build your app, it is super easy. My code have been detailedly documented for better maintainability. To include it in your application, you will need to have these in your `composer.json`


~~~ json
{
    "repositories": [
        {
            "type": "vcs",
            "url": "https://github.com/tommyku/liba_lib"
        }
    ],
    "require": {
        "tommyku/liba_lib": "dev-master"
    }
}
~~~

Then, `composer install` as usual.

> You should really let your fellow devs use your awesome library.

My project title is *Multi-device web applications suite for API-less online services* where I try to wrap around nasty web services which are not enthusiastic in opening up API for other developers to use their web services. It doesn't make sense if I do the same thing as the evil I am fighting does, do it? Good code (not that mine are good, but ya know in general...) and services should be opened up for others to use. When others use your library, you won't know how if -

> The whole is greater than the sum of its parts. - Aristotle
