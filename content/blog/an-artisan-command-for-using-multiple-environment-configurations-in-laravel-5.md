---
title: An artisan command for using multiple environment configurations in Laravel 5
kind: article
created_at: '2015-03-27 00:00:00 +0800'
slug: an-artisan-command-for-using-multiple-environment-configurations-in-laravel-5
---

The [Laravel framework 5](http://laravel.com/docs/5.0/) has switched to [DotEnv](https://github.com/vlucas/phpdotenv) which does not support multiple environmental configuration. You get only one `.env` file for your Laravel app, only one. As [@leonel](http://blog.tommyku.com/blog/setting-up-laravel-5-0-for-openshift#comment-1905666612) pointed out in [Setting up Laravel 5.0 for Openshift](http://blog.tommyku.com/blog/setting-up-laravel-5-0-for-openshif) it seems like a pain unable to have multiple environmental settings.

#### So I wrote an artisan command for that

I have written an artisan command `env:switch` available at [tommyku/laravel5_env](https://github.com/tommyku/laravel5_env), so you can switch between different `.env` files just by typing one line of command.

To save the current `.env` settings to `.$APP_ENV.env`, use `--save` option.

~~~ bash
$ php artisan env
Current application environment: local
$ php artisan env:switch --savee
Environmental config file .local.env saved
~~~

Edit `.env` for another set of environment configurations, `test` for example, save it again and feel free to switch to `local`.

~~~ bash
$ php artisan env
Current application environment: test
$ php artisan env:switch --save
Environmental config file .test.env saved
$ php artisan env:switch local
Successfully switched from test to local.
$ php artisan env
Current application environment: local
~~~

Now you can include multiple `*.env` in your version control or share them with your teammates.
