---
title: 'Create simple contact list application with Laravel and Openshift integration: Part 1'
kind: article
created_at: '2014-08-01 00:00:00 +0800'
slug: create-simple-contact-list-application-with-laravel-and-openshift-integration-part-2
preview: false
abstract: 'Part 1 of a 2-part tutorial about jump-starting a Laravel
project on OpenShift, this part is about making a "Hello World" page'
---

**This is the part 1 of a 2-part tutorial about jump-starting a Laravel project on Openshift. [go to part2](/blog/create-simple-contact-list-application-with-laravel-and-openshift-integration-part-2)**

Laravel is a PHP web development framework providing nice and easy routing, convenient Blade templating, Artisan CLI for better project management and easy build powered by Composer.

In part 1, I will go through the steps of setting up a running Laravel on Openshift, which takes some effort to figure it out if you have never used Laravel and Composer before. In part 2, we will go deeper into creating a contact list application running on Openshift.

#### Show me the steps

1. Deploying Laravel 4.1 with PHP 5.4 and MySQL 5.5

   <small>If you use RHC cli</small>

   ~~~ php
   rhc create app laravel php-5.4
   rhc cartridge add mysql-5.5 -a laravel
   ~~~

   <small>If you use web console</small>

   Choose <code>Laravel 4.1 Quickstart</code> when creating new application.

2. Pull the repository into local environment by running <code>git clone {address to the repo}</code>

3. Get [Composer](https://getcomposer.org/) (if you have not had one), you can simply download the <code>composer.phar</code> if you do not want to install it.

4. In console locate the repo folder, if you had done the global install run <code>composer install</code>, otherwise <code>php composer.phar install</code>. You will see <code>/vendor</code> folder being created with the autoload script inside.

5. If you encounter an error like <code>Script php artisan clear-compiled handling the post-install-cmd event return an error</code>, try to ensure your PHP build has mcrypt installed.

After having done the 4 steps above, Composer would have downloaded the necessary dependencies and you should already have had Laravel setup and able to run locally. Go to <code>http://localhost/{path-to-Laravel-app}/public/index.php</code>

<figure>
<img src='./screenshot.jpg'/>
<figcaption>Finally!</figcaption>
</figure>

However to run a production build we could do something more. These actions are perfectly optional but in part 2 you are assumpted to have done them.

Switch off debug mode. In <code>app/config/app.php</code> set the <code>debug</code> attribute to false. You can view the error log in <code>app/storage/logs/laravel.log</code>.

Set the URL to your app in <code>app/config/app.php</code>.

Relocate the public path out of <code>/public</code>. Copy every inside <code>/public</code> to repo root, then move everything else inside a new folder <code>/Laravel</code>.

You will have to modify <code>/Laravel/bootstrap/paths.php</code>

~~~ php
'public' => __DIR__.'/../..',
~~~

Also <code>/index.php</code>

~~~ php
require __DIR__.'/Laravel/bootstrap/autoload.php';
$app = require_once __DIR__.'/Laravel/bootstrap/start.php';
~~~

Modify the build hook to run Composer while publishing the source to Openshift.

In <code>/.openshift/action_hooks/build</code> remove the hash to uncomment the line

~~~ bash
#( echo 'Installing/Updating Laravel'; unset GIT_DIR ; cd $OPENSHIFT_REPO_DIR/Laravel ; php $OPENSHIFT_DATA_DIR/composer.phar -q --no-ansi install )
~~~

Generate optimized class loader with <code>php artisan optimize</code>

#### What's next?

For the basics of Laravel you should consult [the documentation](http://laravel.com/docs). Chinese version is also avaliable [here](http://kejyun.github.io/Laravel-4-Documentation-Traditional-Chinese/docs/introduction/).

Briefly speaking, to show the "hello world" page you saw above, you need to set a route, and implement the controller handling the request.

In <code>/Laravel/app/routes.php</code>

~~~ php
Route::get('/', function()
{
  return View::make('hello');
});
~~~

The controller is the function passed into <code>Route::get</code>, which define a path and its request handler. It simply render the template located at <code>/Laravel/app/views/hello.php</code>

You may define more routes like:

~~~ php
Route::get('/hello', "HomeController@hello");
~~~

Here HomeController@hello means the request handler is the <code>hello()</code> method defined in <code>/Laravel/app/controllers/HomeController.php</code> which is implemented as 

~~~ php
public function hello()
{
  return "hello";
}
~~~

Go to `http://localhost/{path-to-Laravel-app}/hello` to see the effect.

#### Part 2

In part 1 we have a proper Laravel framework set up to start building the awesome contact list. In the forthcoming part 2 we will actually get into the details of building a frontend with HTML/CSS/AngularJS and the backend interacting with MySQL.

[go to part 2](/blog/create-simple-contact-list-application-with-laravel-and-openshift-integration-part-2)

<br />

#### Reference

1. [Laravel 4.1 Quickstart \| OpenShift by Red Hat](https://www.openshift.com/quickstarts/laravel-41-quickstart)
2. [Laravel - The PHP Framework For Web Artisans.](http://laravel.com/docs)
3. [Laravel 4 PHP Framework Documentation 繁體中文教學文件](http://kejyun.github.io/Laravel-4-Documentation-Traditional-Chinese/docs/introduction/)
