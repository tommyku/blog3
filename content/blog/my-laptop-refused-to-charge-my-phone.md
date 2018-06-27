---
title: 'My laptop refused to charge my phone'
kind: article
created_at: '2018-06-27 00:00:00 +0800'
slug: my-laptop-refused-to-charge-my-phone
preview: false
---

To extends my 6 year-old Thinkpad X230's battery life per charge, I have
taken measures from installing power saving software tlp to [switching to
a lightweight window manager](/blog/i-switched-from-gnome-to-i3wm/).
It has since served me well with over 2 hours of battery life under normal
load of web development.

Last night I was trying to charge my phone over the laptop's USB port.
For a moment the phone showed that it's charging, then the charging
symbol of the phone quickly switched to non-charging symbol. I tried
rebooting both the phone and laptop to no avail. The phone simply
refused to be charged.

Or was it?

As I later realized, my laptop is willing to autosuspend power to USB ports
in order to save power. So I typed `sudo powertop` and found the one
toggleable that caused the issue.

<figure>
<img src='./powertop.png' width='100%'/>
<figcaption>By toggling this to "Bad", my phone could be charged from my laptop again</figcaption>
</figure>

Well that's weird. Nowadays we assume things to "just work", but there
are things behind the scene that we might not realize if all we did
was just installing software without understanding their working
principles (in this case, autosuspending USB port).
