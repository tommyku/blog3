---
title: 'One project, one domain: Apache2 Virtual Host on Ubuntu 14.04'
kind: article
created_at: '2015-01-20 00:00:00 +0800'
slug: one-project-one-domain-apache2-virtual-host-on-ubuntu-14-04
---

Sometimes I just want one domain + one server for each project in my local environment. 

Be you a workaholic or not, you may be like me who have dozen of folders in your Apache server's DocumentRoot. As time goes by, more and more projects get created and store in that particular folder and it starts to look messy. Oh, more than that, it tortues you whenever you run your app: `http://localhost/this-project`, `http://localhost/that-project`, or `http://localhost/stupidly-long-project-name`.

> _"With great power comes great responsibility."_
> __Uncle Ben__

The more the projects you have, the more you should organize them well with nice-looking URL free of `http://localhost`. `php artisan serve` (i.e. start another server from the app) solves half of the problem, as you may want to access any of your projects through port 80.

With virtual host on Apache2 web server it is possible to access your app from `http://this-project.lo` or `http://that-project.lo`, or `http://slpn.lo` (stupidly long project name) without changing any of the directory structure. This is called [Name-based Virtual Hosts](http://httpd.apache.org/docs/2.2/vhosts/name-based.html). As its name suggests, the server determines what you are requesting according to the hostname the client includes in HTTP header. Another way is IP-based Virtual Hosts, which you probably find it less favorable because you want to identify different sites by names, not IP.

> For your information, virtual hosts is a way to get multiple websites running on the same server in web hosting company. But we are more excited about running multiple sites *locally* in this article.

#### The settings

Let there be a project located at DocumentRoot `/var/www/html/the-project`, and we want to access this project from `tp.lo`, meaning "the-project from localhost". 

> .lo is to date not a valid Internet TLD. Don't worry about using virtual host this way will fence off yourself from a proper website from the Internet

We are forking the default settings of `localhost`.

~~~  bash
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/tp.lo.conf
~~~ 

Fire up a text editor and open `tp.lo.conf`. If you screw this step up, you can always copy `000-default.conf` again.

~~~  apache
<VirtualHost *:80>
	ServerName tp.lo
	DocumentRoot /var/www/html/the-project

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
~~~ 

There are 2 things you want to modifty: `ServerName` and `DocumentRoot`. Modification to the port number `*:80` is very much optional. `ServerName` indicates the domain name you want to use, `tp.lo` in this example. `DocumentRoot` tells the web server where your website is, we already know the project is located at `/var/www/html/the-project` so fill that as is.

#### Bring the site up

The setup is almost done but we need to notify the web server we have a new virtual host and tell the operating system where to look at with the domain name `tp.lo`, which is probably not listed in any DNS.

~~~  bash
sudo a2ensite /etc/apache2/sites-available/tp.lo.conf
sudo service apache2 restart
~~~ 

Now Apache2 knows about this virtual host thing. Next, append the following line to `/etc/hosts`.

~~~ 
127.0.0.1    tp.lo
~~~ 

If you open a browser and go to `tp.lo`, you may be redirected to a search engine because the browser has not known about your virtural host yet. Go to `http://tp.lo` if that happens. 

#### Bring it down

Next time when you are done with the site and want to remove it, run

~~~  bash
sudo a2dissite /etc/apache2/sites-available/tp.lo.conf
sudo service apache2 restart
~~~ 
