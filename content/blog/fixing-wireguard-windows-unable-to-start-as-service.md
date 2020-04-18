---
title: "Fixing Wireguard Windows unable to start as service"
kind: article
created_at: '2019-08-06 00:00:00 +0800'
slug: fixing-wireguard-windows-unable-to-start-as-service
preview: false
abstract: 'How to workaround the issue with Wireguard service not starting
on Windows when logging in as standard user'
--- 

<!-- 
This line is 80 characters long
01234567890123456789012345678901234567890123456789012345678901234567890123456789
-->

Wireguard is cool. I happen to be hosting some private web services on a VPS
instance,some without authentication. To secure them I installed Wireguard and
restricted access from public Internet. Only traffic coming from Wireguard's
interface can go into my hosted service. It's secure (I hope...), and
hassle-free.

Now it's finally the time to have Wireguard set up on my Windows 10 machine
because I have gotten to use it more often lately. There is an official
Wireguard client on [their website](https://www.wireguard.com/install/) so I
went on to install it.

Everything went well on my admin user. I was able to add and activate the
interface.

<figure>
<img style='max-width: 440px' src='./interface.jpg' alt='Interface properties screen
of Wireguard' />
<figcaption>And my ethernet connection goes up to 1Gbps, connecting to a crappy
100Mbps router</figcaption>
</figure>

I set it up such that only traffic going from/to the `10.0.0.0/24` subnet is
using Wireguard's interface. The rest goes through `eth0` as before. The
purpose of using Wireguard is to gain access to services on the VPS, not using
the VPS as a VPN host.

This setup seemed working until I rebooted the machine and logged into a
non-admin user as I usually do. This time, there's a problem. Wireguard isn't
connected. When opening the Wireguard client GUI, I was greeted by this message
box.

<figure>
<img style='max-width: 100%' src='./wireguard-message.jpg' alt='Error message:
Manager already installed and running' />
<figcaption>Yeah I know, not helpful</figcaption>
</figure>

I cannot control the Wireguard as non-admin user. Worse, it doesn't start
automatically. I know that Wireguard manager and the Wireguard tunnel I set up
are running as services and start automatically on boot. Somehow, the tunnel
cannot be started properly when I boot into non-admin user.

From the `services` tool of Windows I found this line of log:

~~~ plaintext
WireGuardTunnel$Wireguard 服務因下列服務特定錯誤而終止: 
系統找不到指定的路徑。
~~~

In English it means Wireguard couldn't read a particular file. Either it doesn't
exist, or Wireguard wasn't able to read it.

When manually start the `WireGuardTunnel$Wireguard` service, it works. The
interface comes back. However, this isn't good enough for my lazy soul. So I
went to look at the config file Wireguard was trying to access.

`WireGuardTunnel$Wireguard` starts by reading configurations from this file
inside the system directory `C:\WINDOWS`. Apparently, whichever user Windows
was trying to start this service with, had not the permission to this file.

~~~ plaintext
"C:\Program Files\WireGuard\wireguard.exe" /tunnelservice C:\WINDOWS\system32\config\systemprofile\AppData\Local\WireGuard\Configurations\Wireguard.conf.dpapi
~~~

Well, at this point the fix has became obvious. I granted my non-admin user
the read permission to this configuration file and rebooted.

It works!!!!!

## Discussion

At this point I have gotten Wireguard to automatically start when loggin
in as non-admin user. However there's a caveat: I granted a non-admin user
access to the DPAPI-encrypted config file which contains the private key of
my Wireguard client. Any application can read (but not write to) that file.

Granted, it's encrypted and the non-admin user has no write permission to
the folder containing this config file, yet is it possible for malicious
actors to obtain this file via an exploit in Windows and pretend to be me?

According to Microsoft, DPAPI uses a "pseudo-random 512-bit number named
a master key" that is "protected using a value that is derived from the
user's password". Who's the user in this case? The admin group user setting
up Wireguard? The LocalSystem? Or the non-admin user who requires this
file to be readable in order make Wireguard service start successfully?

Inexperienced in software development in Windows, I have no answer to this
question. I am however aware that on the other side of the Wireguard network,
I can set a static endpoint for my particular machine.

~~~ plaintext
[Peer]
PublicKey = dmVyeSByYW5kb20K...
AllowedIPs = 20.0.0.4/32
Endpoint = 1.2.3.4:1234 # host:port of my Windows PC
~~~

This may be one way to secure my setup because the VPS will verify that
the traffic came from this particular IP. Malicious have to ues my IP
address to access the network even though they may have my private key.

This is an ugly workaround, especially if my PC's public IP changes
frequently. What would you do? Any better way to deal with this issue?
