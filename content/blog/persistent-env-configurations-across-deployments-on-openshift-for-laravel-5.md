---
title: Persistent .env configurations across deployments on OpenShift for Laravel 5
---

#Persistent .env configurations across deployments on OpenShift for Laravel 5

People get hacked easily [when they include the environmental files or passwords](http://blog.nortal.com/mining-passwords-github-repositories/) in version control. Yet keeping it all local makes each and every deployment to OpenShift troublesome as you will need to `scp` the environmental file `.env` onto server every time you deploy.

You can set up an action hook to create a symbolic link inside the deployment directory to `$OPENSHIFT_DATE_DIR` which keeps the `.env` persistently. I know this has been covered in [a previous tutorial](http://blog.tommyku.com/blog/using-laravel-5-0-with-angularjs-part-2-of-5-migrations-controllers-validations-in-laravel-5-0#deploying-the-back-end) but it doesn't hurt repeating myself as a reminder of this security trick.

<div style="text-align: center;">
<img src="https://drive.google.com/uc?export=download&id=0B_6N7pbdkx-lZnc4ZDZ5MWdXekk" title="Screenshot of .env file with passwords" />
<br />
<small><em>Img.</em> <strong>Tried my luck with some keywords, obviously people still do that nowadays</strong></small>
</div>

Moreover, a team of students from a class I am mentoring got themselves a $10,000 AWS bill because they published the `.pem` files on GitHub and somehow got hacked.

<div style="text-align: center;">
<img src="https://drive.google.com/uc?export=download&id=0B_6N7pbdkx-leXoyU0k3WUtxM2M" title="Screenshot of $10,503.75 AWS bill" />
<br />
<small><em>Img.</em> <strong>I told them to use OpenShift instead of AWS for educational purpose</strong></small>
</div>

Now you see how important and trouble-free it is if your server and your local environments keep their configurations to themselves. Let's see how you can do it.

#### Preparation

First you should prepare an OpenShift instanace and a Laravel build on your local machine. [My previous tutorial](http://blog.tommyku.com/blog/using-laravel-5-0-with-angularjs-part-1-of-5-setting-up-laravel-5-0) should get this part well covered.

#### Managing multiple .env locally

To cover the basics, you should first try to have multiple `.env` locally. You may use [an artisan command I made before](http://blog.tommyku.com/blog/an-artisan-command-for-using-multiple-environment-configurations-in-laravel-5) or archieve the same effect [with symbolic link](http://blog.tommyku.com/blog/multiple-env-configurations-in-laravel-5-using-symbolic-link).

In command line, create a couple of environmental configuration files from your Laravel directory by copying the default `.env.example`.

~~~ bash
$ cp .env.example .local.env
$ cp .env.example .testing.env
~~~

Then make sure this line is inside your `.gitignore` file.

~~~ bash
.env
~~~

By default Laravel does not come with `.env` file, so there is nothing to ignore yet. Then create a symbolic link to `.local.env` named `.env`.

~~~ bash
$ ln -s .local.env .env
$ ls -lah
lrwxrwxrwx  1 user user   10 Sep 28 18:21 .env -> .local.env
-rw-rw-r--  1 user user  306 Jul  2 02:30 .local.env
~~~

So `.env` is now a symbolic link to `.local.env`, modifying either of them changes both. How do you switch to testing environment locally?

~~~ bash
$ rm .env
$ ln -s .testing.env .env
~~~

That's it. Don't worry, removing symbolic link doesn't remove the actual file.

#### Uploading `.env` to server

Provided that yout have SSH access to the server (you do so by submitting your public key to OpenShift web panel), first SSH into the server to locate `$OPENSHIFT_DATA_DIR`.

~~~ bash
# figure out the user name and hostname of your OpenShift instance
$ git remote -v
origin  ssh://xxxxxxxxxxxxxxxxxxxxxxxx@test-test.rhcloud.com/~/git/blog.git/ (fetch)
origin  ssh://xxxxxxxxxxxxxxxxxxxxxxxx@test-test.rhcloud.com/~/git/blog.git/ (push)
# ssh into the instance to find where the data dir is
$ ssh xxxxxxxxxxxxxxxxxxxxxxxx@test-test.rhcloud.com
# on remote server
[test-test.rhcloud.com xxxxxxxxxxxxxxxxxxxxxxxx]\> echo $OPENSHIFT_DATA_DIR
# this is the path to data dir where you should store the .env
/var/lib/openshift/xxxxxxxxxxxxxxxxxxxxxxxx/app-root/data/
~~~

Now `scp` the current `.env` you use locally to server. Note that `.local.env` is renamed to `.production.env` when it is uploaded. You could make `.production.env` locally, edit the configuration then upload instead.

~~~ bash
$ scp .local.env xxxxxxxxxxxxxxxxxxxxxxxx@test-test.rhcloud.com:/var/lib/openshift/xxxxxxxxxxxxxxxxxxxxxxxx/app-root/data/.production.env
~~~

Now `.production.env` is on the server, next you should create a symbolic link to it whenever you deploy a new version of your software.

#### Creating a build hook

Git runs a post-receive hook if you write it in `.git/hooks/`. OpenShift plays a different rule, it runs the scripts located in `.openshift/action_hooks/` as well. From your project root folder, create folders `.openshift/action_hooks/` if they weren't there already, then make a `build` file and flip the execute bit.

~~~ bash
$ mkdir -p .openshift/action_hooks
$ touch .openshift/action_hooks
$ chmod +x .openshift/action_hooks
~~~

Then, make sure your `build` file has these content.

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
    echo 'Laravel dependencies already installed, Moving on...'
else
    echo 'Hang in there, we are getting ready to Install/Update Laravel dependencies'
    # Activate composer install for Laravel on Git Push
    ( echo 'Installing/Updating Laravel'; unset GIT_DIR ; cd $OPENSHIFT_REPO_DIR ; php $OPENSHIFT_DATA_DIR/composer.phar -q --no-ansi install ; )   
fi

( echo 'Loading environmental configurations'; ln -s "$OPENSHIFT_DATA_DIR/.production.env" "$OPENSHIFT_REPO_DIR/.env"; cd $OPENSHIFT_REPO_DIR; )
~~~

The first couple lines will fetch the dependencies automatically, and the last line with words *Loading environmental configurations* makes sure a symbolic link `.env` pointing to `.production.env` is created each time you push to server.

#### Why it has to be so cryptic?

Albeit a little bit off-topic, this question keeps popping up in my mind as I wrote this article. From my experience with Ruby on Rails, you can deploy and do the symbolic link thing all inside the confines of your project; i.e. no need for a sneaky hook in `.openshift` or `.git`.

Then when I looked it up, [someone did use a Ruby gem `Capistrano` to deploy his Laravel application](https://www.airpair.com/laravel/posts/automating-laravel-deployments-using-capistrano).

Deploying a PHP project, using a Ruby gem. That's ingenius.

And it goes no further than that, no automatic push-from-local ways of deploying a Laravel application except for bunch of hacks and cryptic scripts.

Yeah, next time, let's talk about a simplier Laravel deployment.
