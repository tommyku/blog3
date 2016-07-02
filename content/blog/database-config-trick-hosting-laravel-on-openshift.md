---
title: Database config trick hosting Laravel on Openshift
kind: article
created_at: '2014-10-22 00:00:00 +0800'
slug: database-config-trick-hosting-laravel-on-openshift
---

Most of the case when I develop using Laravel, I would first host the app locally, then push the changes to Openshift when all tests are done. One thing that bugs me is every time I push I forgot to modify the database settings to Openshift's database setting. The app crashes until I notice it and I ended up pushing an additional commit that does nothing but "fix db setting".

So here are the fool-proof tricks that saved me from the pain of useless re-pushing.

#### The easy way

Use .gitignore

When you push the app onto Openshift for the first time, push with Openshift's database setting. 

~~~
app/config/database.php
~~~

~~~ php
/* the rest of the code */
'mysql' => array(
  'driver'    => 'mysql',
  'host'      => getenv('OPENSHIFT_MYSQL_DB_HOST'),
  'port'      => getenv('OPENSHIFT_MYSQL_DB_PORT'),
  'database'  => getenv('OPENSHIFT_APP_NAME'),
  'username'  => getenv('OPENSHIFT_MYSQL_DB_USERNAME'),
  'password'  => getenv('OPENSHIFT_MYSQL_DB_PASSWORD'),
  'charset'   => 'utf8',
  'collation' => 'utf8_unicode_ci',
  'prefix'    => '',
),
/* the rest of the code */
~~~

Then make yourself a .gitigore, or modify the existing one.

~~~
.gitignore
~~~

~~~ bash
/bootstrap/compiled.php
/vendor
composer.phar
composer.lock
.env.*.php
.env.php
.DS_Store
Thumbs.db
/app/config/database.php
~~~

.gitignore guraranttes the enlisted files be ignored in git commit and git push, thus you can modify `database.php` to your local setting as much as you like. Next time you push, what stays on Openshift will be the `database.php` you originally pushed.

#### Another way for your interest

In case your database setting cannot be separated from your code (uncommon, but possible), you can write down settings of both sides anyway. Openshift's database settings are stored in environmental variable, which are not set in local environment. Since [getenv()](http://php.net/manual/en/function.getenv.php) returns false when the requested variable does not exist, we can just fallback to local setting when the function returns false.

This is done using ternary if.

~~~
app/config/database.php
~~~

~~~ php
/* the rest of the code */
'mysql' => array(
  'driver'    => 'mysql',
  'host'      => (getenv('OPENSHIFT_MYSQL_DB_HOST')) ? getenv('OPENSHIFT_MYSQL_DB_HOST') : 'LOCAL_MYSQL_HOST',
  'port'      => (getenv('OPENSHIFT_MYSQL_DB_PORT')) ? getenv('OPENSHIFT_MYSQL_DB_PORT') : LOCAL_MYSQL_PORT,
  'database'  => (getenv('OPENSHIFT_APP_NAME')) ? getenv('OPENSHIFT_APP_NAME') : 'LOCAL_MYSQL_DATABASE',
  'username'  => (getenv('OPENSHIFT_MYSQL_DB_USERNAME')) ? getenv('OPENSHIFT_MYSQL_DB_USERNAME') : 'LOCAL_MYSQL_USERNAME',
  'password'  => (getenv('OPENSHIFT_MYSQL_DB_PASSWORD')) ? getenv('OPENSHIFT_MYSQL_DB_PASSWORD') : 'LOCAL_MYSQL_PASSWORD',
  'charset'   => 'utf8',
  'collation' => 'utf8_unicode_ci',
  'prefix'    => '',
),
/* the rest of the code */
~~~

There may be some better solutions to this, drop some lines into the comment box if you do!

