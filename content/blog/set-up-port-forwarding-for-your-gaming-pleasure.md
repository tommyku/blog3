---
title: Set up port forwarding for your gaming pleasure
kind: article
created_at: '2014-04-20 00:00:00 +0800'
slug: set-up-port-forwarding-for-your-gaming-pleasure
abstract: 'Setting up port forwarding on router for others to connect to your local game server'
---

Last week is the Easter holiday. Finally, a time for me and friends to play some old school shooters.

I opened a dedicated server on my laptop for but my friends could not connect. It turned out that my wireless router did not have the correct port forwarding setting.

A router has only one external IP address but inside the local network (LAN) there could be multiple IP addresses for your laptop, desktop, tablets and phones. The router does not know when incoming transmission to this external IP at, say, port 14567 (actual port number depends on your game), which machine it should forward the payload to. The postman finds the apartment building, but not sure which room this letter belongs to.

So, setting port forwarding ensures any communication going into that port routes to your game server.

1. Enter the router setting page, usually via 192.168.0.1 on web browser.

2. Select the option named “Port forwarding” or “Forwarding”.

3. Add a record.<br />Port number, there goes your server’s listening port number.<br />IP, your IP address in the LAN, check this via ipconfig (Windows) or ifconfig (Linux).<br />Protocol, you could just choose “All” unless you know what you are doing.

And now, back to the gaming.
