---
title: 'Hide Docker containers behind Nginx proxy'
kind: article
created_at: '2019-02-04 00:00:00 +0800'
slug: hide-docker-containers-behind-nginx-proxy
preview: true
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

### Setting up the web service

### Creating a file storing the passphrases

First, we need to create a file that contains the encrypted

### Spinning up a Nginx reverse proxy

### Point a domain name to the server

### Add HTTPS

### Enforce HTTPS
