---
title: 'Hide Docker containers behind Nginx proxy'
kind: article
created_at: '2019-02-06 00:00:00 +0800'
slug: hide-docker-containers-behind-nginx-proxy
preview: false
abstract: 'How I ditched VPN and embrace basica HTTP authentication when
I am too lazy to implement user authentication into individual app'
---

In the [last
post](/blog/hide-docker-containers-behind-a-docker-vpn/)
I have shown how to put docker containers inside a semi-isolated network
such that only those connected to the VPN can access the containers
within the network. The promise comes with two caveats: 1) it's troublesome
(not impossible) to get HTTPS on the network and 2) we were access the
containers via their IP addresses instead of some easy-to-remember
hostnames.

While those issues can be solved by obtaining the cert via DNS-01
challenge and roll your own DNS inside the VPN to help resolving
domain names, it's way too troublesome.

In the one month that I attempted to host a beanscount web client
[Fava](https://github.com/beancount/fava), I had to frequently connect
to the VPN, which isn't fast or reliable in the first place. I feel that
this isn't a convenient and scalable way to incorporate authentication
to a bunch of containers.

Therefore, I am going to do it the old-school way &mdash; HTTP basic
auth via Nginx reverse proxy.

## A few words of caution

Before anyone complains, I am fully aware that basic auth sends
(more or less) plaintext over HTTP and provides no session
management/CSRF protection and may be stored on browser for however long
the browser wants to.

## Why Nginx reverse proxy?

From a practical standpoint, using HTTP basic is no more scalable than an
VPN because individual user still need to be onboarded manually. One
good thing though, is that with Nginx reverse proxy gives you per-domain
control on user profiles.

Another good thing about Nginx revese proxy is that since the containers
are not hidden inside an VPN, they can respond to HTTP-01 challenge,
making obtaining a HTTPS cert easier and of course, these containers can
be accessed via traditional domain names similar to any public website.


## What is a reverse proxy?

Think about HTTP proxy. For example those that highschool libraries used
to block YouTube/Twitter/Facebook. What a proxy does, in that sense, is
to shield an user from a number of different web services. In the view
of the web services, they are only aware of the proxy but not the users.

A reverse proxy is literally, a proxy that's reversed. Instead of
shielding user from web services, it shields web services from users. In
the view of users, it knows only the reverse proxy itself but not anything
behind it, which are our docker containers.

As such, one can host multiple containers on the same servers, each exposing
a port different form 80 and 443. Different domains, for example
`a.example.com` and `b.example.com` would each resolve to the same IP
address &mdash; the IP address of the reverse proxy server. Despite
under the hood reverse proxy redirects the traffics to the respective
web services, user never has the knowledge about the individual
containers because reverse proxy shields the user from the underlying
docker containers.

You can read more about the internal working of Nginx reverse proxy [here](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/).

## Hiding containers behind nginx proxy

Like last time, we would create a web service that's a server serving
some static content without any authentication. We will then add the
security layer by hiding it behind a reverse proxy and enable HTTPS
transmission.

### Another word of caution

In writing this piece I am sharing my personal experience of being lazy
about the security of some non-critical web services that nobody really
cares about. I understand HTTP basic authentication is flawed and you
should too. Note that the approach I documented here comes with no
warranty. If anything breaks or you unluckily get hacked, it's solely
your own responsibility.

### Server setup

- A Linode instance with 1GB RAM
- Ubuntu 18.04
- Docker 18.06.1-ce
- Docker image
  - Nginx reverse proxy: [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)
  - LetsEncrypt companion for nginx-proxy: [JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
  - Web service: [nginx:1.13.8-alpine](https://hub.docker.com/_/nginx)

### Creating a file storing the passphrases

First, we need to create a file that contains the credentials for
HTTP basic authentication. To do that, we use a tool called `htpasswd`
that comes with `apache2-utils` in Ubuntu.

`apache2-utils` can be installed by running:

~~~ bash
# Install apache2-utils
$ sudo apt install apache2-utils
# Verify that htpasswd has been installed
$ htpasswd
# ...help info of htpasswd is shown
~~~

With `htpasswd` ready, we can create a password file.

~~~ bash
# replace `test.domain.name` with a virtual host name of your choice
$ mkdir ~/htpasswd
$ htpasswd -c ~/htpasswd/test.domain.name username
# ...fill in the password according to the promots
~~~

The file containing our credentials is named `test.domain.name` because
nginx-proxy reads htpasswd files accroding to the virtual host's name.
So use whatever domain name you're going to use for your docker
container as the filename.

<small>\* You may also consider adding `-B` for encryption using bcrypt,
however your Nginx/OS may not be supporting that yet, for details see this [SO post](https://stackoverflow.com/questions/31833583/nginx-gives-an-internal-server-error-500-after-i-have-configured-basic-auth).</small>

### Spinning up a Nginx reverse proxy

Now it's time to start a nginx reverse proxy. Don't worry about
nginx's configurations &mdash; they are done automatically when we plug
in the right environmental variables when we later start our web service
using Docker.

~~~ bash
$ docker run --detach \
    --name nginx-proxy \
    --publish 80:80 \
    --publish 443:443 \
    --volume /etc/nginx/certs \
    --volume `pwd`/htpasswd:/etc/nginx/htpasswd \
    --volume /etc/nginx/vhost.d \
    --volume /usr/share/nginx/html \
    --volume /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy
~~~

Basically, this is all that we need for the reverse proxy. After
starting the container it will listen to Docker events on `docker.sock`,
pick up newly started containers and reconfigure itself automatically.
You can head over to the image's [GitHub page](https://github.com/jwilder/nginx-proxy)
for more info.

### Point a domain name to the server

The reverse proxy needs a domain name to resolve which Docker container
to pass incoming traffic to. For example, it forwards the traffic to
container A when it reads that users are requesting `a.example.com` and
container B when it's `b.example.com`. This coordination requires a
proper domain name to be set up per container.

To do this, you need to add an A record to your domain name's DNS
server and point it to the public IP of the reverse proxy. You can point
multiple A records with different subdomains to the same IP address.

### Setting up the web service

Similar to [last time](/blog/hide-docker-containers-behind-a-docker-vpn/),
we are going to set up a web server serving one static file. And it
comes with no security. Anyone accessing the page is able to see what it
serves.

~~~ bash
$ mkdir test-web && cd test-web
$ echo 'be aware of the lizard people!' > index.html

$ docker run --name test-web \
    -v `pwd`:/usr/share/nginx/html:ro \
    --expose 80 \
    -e 'VIRTUAL_HOST=test.domain.name' # change this \
    --restart=always \
    -d \
    nginx:1.13.8-alpine
~~~

Assuming your machine is able to resolve the domain name you've set up
on your DNS, you can already see the outcome:

~~~ bash
$ curl http://test.domain.name
# <html>
# <head><title>401 Authorization Required</title></head>
# <body bgcolor="white">
# <center><h1>401 Authorization Required</h1></center>
# <hr><center>nginx/1.14.1</center>
# </body>
# </html>
$ curl -u username:password http://test.domain.name
# be aware of the lizard people!
~~~

But this is not enough! As we all know HTTP basic authentication sends
(base64 encoded) plain text password, which is susceptible to
eavesdropping. To protect this important payload, we have to add HTTPS.

### Add HTTPS

To add HTTPS, we need to first enable the Let's Encrypt companion for
Nginx proxy.

~~~ bash
$ docker run --detach \
    --name nginx-proxy-letsencrypt \
    --volumes-from nginx-proxy \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion
~~~

This container would automatically create and renew Let's Encrypt
certificates for your docker containers. This alone isn't enough though,
we need to configure some environmental variables of our web service to
let the Let's Encrypt companion pick them up.

~~~ bash
$ docker stop test-web
$ docker rm test-web
$ docker run --name test-web \
    -v `pwd`:/usr/share/nginx/html:ro \
    --expose 80 \
    -e 'VIRTUAL_HOST=test.domain.name' # change this \
    -e 'LETSENCRYPT_HOST=test.domain.name' # add this \
    -e 'LETSENCRYPT_EMAIL=user@test.domain.name' # add this \
    --restart=always \
    -d \
    nginx:1.13.8-alpine
~~~

Now the Let's Encrypt companion should be able to pick up this container
event and create/renew a certificate for the site. Give it a couple
minutes and you should be able to access the site using HTTPS without
invalid server certificate issue.

To debug, you can check the logs by:

~~~ bash
$ docker logs nginx-proxy
# or
$ docker logs nginx-proxy-letsencrypt
~~~

### Enforce HTTPS

If you use DNS service provider like Cloudflare that provides page
rules, you can enforce HTTP by redirecting HTTP traffic to HTTPS.
Clients will receive HTTP 301 Moved Permanently when requesting through
HTTP, and be redirected to the HTTPS version of the page.

Also, blocking port 80 may sound like a good idea until one finds that
Let's Encrypt companion isn't able to complete an HTTP-01 challenge
because by that point it becomes a problem of chicken first or egg first &mdash;
without cert it can't get a valid response using HTTPS, yet not passing
HTTP-01 challenge prohibits it from getting a certificate to enable
HTTPS.

## Closing thoughts

Let's revisit an important thing: HTTP basic authentication isn't
an one-size-fit-all security solution, it's far from being one. Not only
does it sends credentials as plain text, it is also susceptible to CSRF
attack. `htpasswd` file using MD5 to encrypt passwords isn't exactly
secure in today's standard either.

However it gest the job done. You get HTTPS, some degree of security
without modifying the source of whatever service you're hosting, and no
need of an VPN/DNS. As lazy as I am, this is enough for low-critical
non-confidential applications.

For apps that requires higher level of security, I still recommand the
VPN approach because VPN provides encrypted transmission
out-of-the-box and actually isolates your web services from the world
wide web.
