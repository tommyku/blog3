---
title: Multiple .env configurations in Laravel 5 using symbolic link
kind: article
created_at: '2015-04-04 00:00:00 +0800'
slug: multiple-env-configurations-in-laravel-5-using-symbolic-link
abstract: 'Use symbolic link to switch between multiple Laravel 5
environmental configurations without additional console command'
---

In this post I am going to introduce an ingenius approach for having multiple environmental configurations in Laravel 5 without the need for [another artisan command](/blog/an-artisan-command-for-using-multiple-environment-configurations-in-laravel-5). Credit goes to [@Tiquortoo](http://www.reddit.com/r/programming/comments/30h39l/managing_multiple_env_with_artisan_in_laravel_5/) on reddit who nicely pointed that out.

#### Tl;dr;

~~~ bash
$ ln -s ./.local.env .env
~~~

Bear with me if you don't know what the hack that command does.

#### What is a symbolic link

`ln` creates hard links or symbolic link (if you add the `-s` option) in Unix-like systems.

A symbolic links like a pointer to a file itself. When you access a symbolic link you will be redirected to the file. Deleting the file which the symbolic link is pointing will cause the link to be broken.

A hard link, however,  points directly to the inode of a file, so you can see it as a file existings in both folders. If you modify a file from it's hard link the original file content get changed. If you delete one hard link, the file itself will not be removed until all the hard links are removed. 

#### Managing .env, the symbolic link way

Very likely that you have a couple of `.env` lying around (`.local.env`, `.testing.env`, `.staging1.env` etc), one for each environment. One of the easiest way to change the environement is to simply overwrite the `.env` with the config file of your target environment like:

~~~ bash
$ cat .testing.env > .env
~~~

That doesn't look nice because you will then have 2 separate `.testing.env` to manage. What if you want to make a change? (1) change one and run the `cat` again, or (2) change both. Both ways sound dumb. 

Now what if we use symbolic link:

~~~ bash
$ ln -s ./.testing.env .env
~~~

Changing either of `.env` or `.testing.env` will affect both files. For whatever change you want to do, you will only need to do it once. Having multiple environmental configuration is particularily useful for teams having multiple deploys, so I hope this article helps.
