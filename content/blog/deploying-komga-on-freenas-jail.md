---
title: "Deploying Komga on FreeNAS jail"
kind: article
created_at: '2020-03-15 00:00:00 +0800'
slug: deploying-komga-on-freenas-jail
preview: false
abstract: 'How FreeNAS is capable of hosting lots of services in addition to
file storage'
--- 

<!-- 
This line is 80 characters long
01234567890123456789012345678901234567890123456789012345678901234567890123456789
-->

I've built myself a NAS using old parts and FreeNAS. Then I realized I can host
a variety of services on my NAS such as Emby, Syncthing and duplicati with
FreeNAS plugins out-of-the-box.

Compared to the wealth of containers available on Docker Hub, plugins on FreeNAS
are somewhat lacking. However that doesn't mean docker is the to-go option for
running isolated services. Instead, jail came out of the box in FreeNAS while
docker didn't. Plus I couldn’t get RancherOS (a host-OS for docker) to run on
a FreeNAS VM, so I gave up.

In this post I am going to walk you through how I deployed a manga-reading
application Komga to my FreeNAS jail.

## Creating a Jail

First locate the Jails section on the side menu of FreeNAS dashboard, then
click ADD on the top right corner. Here fill in the Name, and choose a Release
from the dropdown menu, then click NEXT.

<figure>
<img style='max-width: 100%' src='./image2.png' alt='Creating a Jail' />
<figcaption></figcaption>
</figure>

There are 3 ways to set the IP addresses of the jail - VNET/NAT, DHCP or
static IP.

With VNET/NAT you access your service via the same IP as your FreeNAS and some
unused port.

With DHCP, you still access your services from unused ports but via an IP
distributed by the DHCP server.

With static IP like below, I specify an IP address, subnet mask and default
router to my home network router. If you find the default router field
disabled, clicking some of the checkboxes will re-enable it. You can then
edit the default router before unchecking the checkboxes.

Oh, feel free to check the Auto-start checkbox at the bottom as well.

<figure>
<img style='max-width: 100%' src='./image4.png' alt='Editing Jail properties' />
<figcaption></figcaption>
</figure>

After saving and starting the jail, you will have a working jail with
its own IP address and isolation. At this point it is not running service
for you, so in the next part we will mount a ZFS folder to it and install
Komga for you to read comics.

## Deploying Komga to a jail

From the Jails page click on the arrow on the right of our Komga jail, then
click Mount Points in the expanded panel. Here you can configure where in your
pools do you want to make visible to the jail by mounting. Otherwise, the jail
will see only files inside its own iocage dataset.

<figure>
<img style='max-width: 100%' src='./image3.png' alt='Komga jail in Jails page' />
<figcaption></figcaption>
</figure>

<figure>
<img style='max-width: 100%' src='./image6.png' alt='Mounting folder to the jail' />
<figcaption></figcaption>
</figure>

Komga requires Java to run which is not available. To install Java 11, start
the jail and click Shell from the Jails page. In the resultant shell screen
you have logged in to the jail’s shell, not to your FreeNAS host shell.
Installing Java in the shell doesn’t make it available to the host OS.

~~~ bash
# Jail Shell
# Developer of Komga recommends using openjdk11 over openjdk8 for better performance
pkg install openjdk11
~~~

<figure>
<img style='max-width: 100%' src='./image1.png' alt='Screen shown after installing java' />
<figcaption></figcaption>
</figure>

As shown in the screenshot there are some post-installation steps required for
Java. However we need to do them on the host-OS’s shell instead of inside the
jail. Open the host OS shell from the left menu, then run the following
commands.

~~~ bash
# Host Shell
mount -t fdescfs null /mnt/{POOL NAME}/iocage/jails/Komga/root/dev/fd
mount -t procfs null /mnt/{POOL NAME}/iocage/jails/Komga/root/proc
~~~

Next return to the jail’s shell, and from `/root` download the latest
version of Komga using fetch. Alternatively, you may download the file
elsewhere and drop it into jail’s own dataset.

~~~ bash
# Jail Shell
fetch https://github.com/gotson/komga/releases/download/v0.27.7/komga-0.27.7.jar
~~~

To quickly test whether Komga is working, start the Komga server from
`/root`.

~~~ bash
# Jail Shell
/usr/local/bin/java -jar ./komga-0.27.7.jar
~~~

Navigating to the webpage at port 8080 of your jail’s IP, you will see
Komga’s login screen.

<figure>
<img style='max-width: 250px' src='./image5.png' alt='Komga login screen' />
<figcaption></figcaption>
</figure>

You won’t be able to login at the moment because no account is created
yet. Follow [Komga’s installation instruction](https://komga.org/installation/user-accounts.html#automatic-mode-default)
to get it up and running.


If you want to change some of the default config options, Komga’s
configuration is stored in a file `application.yml` alongside the jar.
A sample configuration file can be found in [Komga’s documentation](https://komga.org/configuration/#sample-configuration-file).

The last bit of this deployment is to make Komga start every time the jail
is started. Navigate to `/etc` and create a file `rc.local`.

~~~ bash
#!/bin/sh

exec 2> /tmp/rc.local.log
exec 1>&2
set -x

cd /root
nohup /usr/local/bin/java -jar /root/komga-0.27.7.jar

exit 0
~~~

Lastly, make `rc.local` executable.

~~~ bash
# Jail Shell
chmod +x /etc/rc.local
~~~

This way next time when you start the jail, Komga will automatically be started too.

## More Information

This post was created with the help of the following pages:

- [Linux LXC vs FreeBSD jail - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/127001/linux-lxc-vs-freebsd-jail)
- [Ubooquity \| iXsystems Community](https://www.ixsystems.com/community/threads/ubooquity.59244/#post-422437)
- [A guide on how to install Ubooquity in a FreeNAS jail and how to get it to run on jail start : freenas](https://www.reddit.com/r/freenas/comments/9r1bky/a_guide_on_how_to_install_ubooquity_in_a_freenas/)
