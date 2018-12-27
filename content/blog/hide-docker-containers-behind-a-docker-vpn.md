---
title: 'Hide Docker containers behind a Docker VPN'
kind: article
created_at: '2018-12-27 00:00:00 +0800'
slug: hide-docker-containers-behind-a-docker-vpn
preview: false
abstract: 'How I safe-guarded my personal web services (many of which
have no auth layer at all) without having to integrate authentication to
every single of my services'
---

People are lazy &mdash; I am lazy. Yet laziness doesn't justify not
safe-guarding my personal web services with authentication layer, even
though my experimental abominations have the shittiest quality possible.
Lazy as I am, I wouldn't lift a finger to implement event the simplest
humblest web server-based basic auth, not to mention the all troublesome
OpenID Connect.

For people like me, we have VPN that comes to rescue. VPN stands for
virtual private network. Once your device is connected to a VPN, it is
as if you magically have an additional LAN port on your devices (even if
it doesn't have one) plugged in and connected to a *virtual* (get it?)
network over any network. Also, the network is *private* in a sense that
no external hosts can access hosts within the network without first
connecting to the network. As such, one can host totally insecure and
authentication-less web services entirely inside an VPN, and have
devices connect to the network when needed. All the web services will be
hidden behind the wall of the VPN itself, only allow the selected few
with the relevant credentials to access.

When I researched for the topic, I was surprised not many have covered the
topic, except like one [question on
StackExchange](https://security.stackexchange.com/questions/97542/hide-docker-containers-behind-vpn)
that pretty much explained it all. The answer covers pretty much all I have
to show you in this post, and it's fairly obvious. Probably that's why
nobody goes one step further to actually show how it's done.

I am going to show you how to use Docker to set up such an environment.

## Server setup

- A Linode instance with 1GB RAM
- Ubuntu 18.04
- Docker 18.06.1-ce
- Docker image
  - VPN: [hwdsl2/ipsec-vpn-server](https://hub.docker.com/r/hwdsl2/ipsec-vpn-server/)
  - Web service: [nginx:1.13.8-alpine](https://hub.docker.com/_/nginx)

## How it works?

In Docker, you can create internal subnets (bridge network) where your
containers sit on. By default, no port is open to public unless you
specify which port to make open with `--publish` or it's shortened form
`-p` when spinning up a container.

In addition, you can create a bridge network that's only open to the
outside world with ports your VPN service uses (e.g. 450 and 5000 UDP),
while keeping everything else in isolation from the external network. As
such, only hosts connected to the VPN network is able to access services
within it's own isolated bridge network. Once connected to your VPN, you
can access all containers within the same network as your VPN with their
internal IP addresses.

This setup isn't without disadvantages. One of which being services
within the network are shielded such that services that requires
incoming transmissions, for example webhooks, are unusable. For most of
my use cases, this doesn't pose an issue to me, but it may affect some
people who listens to transmissions from external services and require
a public facing interface. Also, forget about HTTPS and navigating to
services using domain names. While you can specify an IP for a service,
it is a bit tricky to get Let's encrypt to issue you a free certificate.
Not impossible, but tricky, troublesome, and fall out of scope of this
post. I may write another post to follow up with these issues.

## Creating a user-defined bridge network

We are going to create a user-defined bridge network with a specific
network segment such that we can assign a static IP to each service.

~~~ bash
docker network create vpn --subnet 172.20.0.0/16
# 848f85b7a08f31ae26b57d9a1efa70099e6048461ca0d50a5b7c941647e34184
docker inspect vpn
~~~

By inspecting the network we see that we have created a network with
name `vpn` for the subnet `172.20.0.0/16`. The subnet mask has 16 bits,
meaning the first 16 bits represents the network address, and we have 16
bits of addressable space for network host, which translates to `2^16 -
2 = 65534` available host addresses. With `172.20.0.0` reserved for
network address and `172.20.255.255` for broadcast address. Discounting
the one address we reserve for our VPN server, that's a lot of hosts
you can stuck behind an VPN.

~~~ json
[
    {
        "Name": "vpn",
        "Id": "848f85b7a08f31ae26b57d9a1efa70099e6048461ca0d50a5b7c941647e34184",
        "Created": "2018-12-28T21:15:59.205797293+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.20.0.0/16"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
~~~

## Setting up VPN

For a detailed walkthrough and explanation, you should check out the
excellently written documentation of [hwdsl2/ipsec-vpn-server](https://hub.docker.com/r/hwdsl2/ipsec-vpn-server/), I will not go into details for each step.

On a Linode 1GB instance running Ubuntu 18.04, first I load the IPsec
`af_key` kernel module. Documentation states that this is optional for
Ubuntu but I found my Android client unable to connect unless I do this.

~~~ bash
sudo modprobe af_key
sudo reboot
~~~

After reboot, download the sample `vpn.env` file and edit accordingly.

~~~ bash
wget https://raw.githubusercontent.com/hwdsl2/docker-ipsec-vpn-server/master/vpn.env.example -O vpn.env
vim vpn.env
~~~

You should change the three lines regarding login credentials.

~~~ bash
VPN_IPSEC_PSK=your_ipsec_pre_shared_key
VPN_USER=your_vpn_username
VPN_PASSWORD=your_vpn_password
~~~

On `vim`, press `i` to enter Insert mode, edit your config. `Esc` to return
to Normal mode, then `:wq` to save and exit.

Now spin up the VPN server.

~~~ bash
docker run \
    --name ipsec-vpn-server \
    --env-file ./vpn.env \
    --restart=always \
    --network vpn \
    --ip 172.20.0.2 \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -v /lib/modules:/lib/modules:ro \
    -d --privileged \
    hwdsl2/ipsec-vpn-server
~~~

To connect to the VPN, follow the guide
[here](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md).
Note that even though in the `docker run` command the container's IP is
set to `172.20.0.2`, that's is just it's IP inside the subnet `vpn`. You
need to use the host machine's (your VPS's) IP to connect to VPN from
outside.

## Setting up an insecure web service

For the sake of demonstration, let's create a web service that contains
super secret content yet doesn't come with any authentication.

~~~ bash
mkdir test-web && cd test-web
echo 'be aware of the lizard people!' > index.html
~~~

The content is served by a nginx server. Although it's possible to
configurate basic auth on nginx, we are not going to do that so keep
this service insecure.

~~~ bash
docker run \
    --name test-web \
    -v `pwd`:/usr/share/nginx/html:ro \
    --network vpn \
    --ip 172.20.0.3 \
    --restart=always \
    -d \
    nginx:1.13.8-alpine
~~~

Notice that there is no `-p` or `--publish` argument because we don't
want to publish the container's port to the external-facing interface of
the host machine. Instead, we keep it inside the VPN's network by
specifying `--network vpn` and giving it a static IP `--ip 172.20.0.3`.

At this stage, we haven't had a way to resolve that IP by name. While it
is possible to point a (sub)domain to `172.20.0.3` on a public-facing
DNS, but then this IP actually points to two different hosts when you
disconnect from the VPN. This introduces an obvious security loophole as
you may send traffic to an totally unrelated service if you are unware
that you're not on the VPN at that moment.

For now, let's connect to the services using strictly IP address.

## Accessing the web service within VPN

Assuming you have connected to the VPN, it is trivial to simply open a
web browser and navigate to the IP `172.20.0.3`. After disconnecting
from the network, you'll find that the same IP is no longer accessible.

## Closing notes

With that, we have created an VPN and hide an insecure web service
within the same isolated subnet of that VPN. Only if you connect to the
VPN can you access the insecure web service. VPN serves as an
authentication layer without any sort of integration on our insecure web
services.

However, one issue remains. On this set up we have to navigate to our
web services using IP address. In a next post we'll explore how to
conveniently use customized hostname to access web services within the
VPN network, and potentially even enable HTTPS.
