---
title: Setting up Laravel 5.0 for Openshift
kind: article
created_at: '2015-02-16 00:00:00 +0800'
slug: setting-up-laravel-5-0-for-openshift
---

Earlier on Laravel 5.0 has been released, with an overhaul on directory structure, easier form validation, out of the box authentication support, introduction of middleware and more. While you can find out more from the [release note](http://laravel.com/docs/5.0/releases), this post explains how a new version of Laravel can be pushed onto Openshift and get running. 

To begin with, let's grab the Laravel 5.0 release and put it on to Openshift. This is done as usual via Composer.

#### Installation

~~~  bash
composer create-project laravel/laravel --prefer-dist
~~~ 

#### Configuration

I think the `.gitignore` that came with this installation is not as good as before for the lack of ignoring files like `.DS_Store`, `Thumbs.db`, `composer.lock` and so on. You can modify `.gitignore` the way you wish, or simply copy this.

~~~ 
/vendor
/node_modules
composer.phar
composer.lock
.env
.DS_Store
Thumbs.db
~~~ 

You pretty much understand what most of the ignored files are except for `.env`, which is newly introduced in Laravel 5.0 as an attempt to simplify the configuration of the confusing development environment back in Laravel 4.2. 

In your local environment, you can simply put your database setting into `.env`. I specifically added the `DB_PORT` setting because we need it to get it on Openshift.

~~~ 
APP_ENV=local
APP_DEBUG=true
APP_KEY=use_artisan_key:generate_to_gen_this

DB_HOST=MYSQL_DB_HOST
DB_DATABASE=MYSQL_DB_NAME
DB_USERNAME=MYSQL_DB_USERNAME
DB_PASSWORD=MYSQL_DB_PASSWORD
DB_PORT=MYSQL_DB_PORT

CACHE_DRIVER=file
SESSION_DRIVER=file
~~~ 

Look at my `config/database.php` you will see how the setting in `.env` are used. Like [before](http://blog.tommyku.com/blog/database-config-trick-hosting-laravel-on-openshift) we try to get environmental variables from Openshift. The function `env('DB_HOST', 'default')` will take either `DB_HOST` from `.env` or use the default value in the second parameter. Since `.env` is excluded from version control, Laravel will take the Openshift-specific settings instead. 

~~~  php
'mysql' => [
    'driver'    => 'mysql',
    'host'      => env('DB_HOST', getenv('OPENSHIFT_MYSQL_DB_HOST')),
    'database'  => env('DB_DATABASE', getenv('OPENSHIFT_APP_NAME')),
    'username'  => env('DB_USERNAME', getenv('OPENSHIFT_MYSQL_DB_USERNAME')),
    'password'  => env('DB_PASSWORD', getenv('OPENSHIFT_MYSQL_DB_PASSWORD')),
    'port'      => env('DB_PORT', getenv('OPENSHIFT_MYSQL_DB_PORT')),
    'charset'   => 'utf8',
    'collation' => 'utf8_unicode_ci',
    'prefix'    => '',
    'strict'    => false,
],
~~~ 

To test this, run (given that you have created the database locally)

~~~  bash
php artisan migrate
~~~ 

`database/migrate` comes with two migrations by default which you can gracefully remove. The above command will do the migration for you as a simple test to database connectivity. For other database drivers it just work similary.

#### Pushing to Openshift

One thing that Laravel cannot use without is an action hook that loads Laravel dependencies on the remote end. See `.openshift/action_hooks/build`. 

~~~ bash
#!/bin/bash

export COMPOSER_HOME="$OPENSHIFT_DATA_DIR/.composer"

if [ ! -f "$OPENSHIFT_DATA_DIR/composer.phar" ]; then
        echo 'Installing Composer'
        curl -s https://getcomposer.org/installer | php -- --quiet --install-dir=$OPENSHIFT_DATA_DIR
else
        echo 'Updating Composer'
        php $OPENSHIFT_DATA_DIR/composer.phar -q --no-ansi self-update
fi

if [ -d "$OPENSHIFT_REPO_DIR/vendor" ]; then
        echo 'Dependencies already installed, Moving on...'
else
        echo 'Hang in there, we are getting ready to Install/Update dependencies'
        echo 'Installing/Updating dependencies'; 
        unset GIT_DIR ; 
        cd $OPENSHIFT_REPO_DIR ; 
        php $OPENSHIFT_DATA_DIR/composer.phar -q --no-ansi install ;
fi
~~~ 

If this file does not exist in `.openshift/action_hooks/`, feel free to copy above bash script and create `build` file yourself. After doing so, remember to grant it the execution right by

~~~ bash
chmod +x build
~~~ 

You are taking one last step to push the application to Openshift, that is to add the remote to the version control. 

~~~ bash
git init
git add --all
git commit -m 'Initial commit'
git remote add origin {link to the repo given by Openshift}
git push -uf origin master
~~~ 

Lastly, go checking out the site you have just pushed and see Laravel 5 running.
