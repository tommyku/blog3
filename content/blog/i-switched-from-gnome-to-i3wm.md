---
title: 'I switched from GNOME to i3wm'
kind: article
created_at: '2018-05-19 00:00:00 +0800'
slug: i-switched-from-gnome-to-i3wm
abstract: 'Ubuntu 18.04 ditched Unity in favor of GNOME as the default
window manager, so I switched to i3wm to desperately save some pixels on
my small laptop screen'
preview: false
---

My ThinkPad X230 (yes it's still kicking since [the upgrade](/blog/do-i-need-a-new-laptop/))
has a 12.5-inch screen supporting resolution up to 1366x768. It's
far behind the common resolution of 1920x1080 that has became widely
available today. Vendors even went up to QHD+ with 3200x1800 like my
Razer Blade 2015 to please the eyes of the customers. Due to battery
life issue and that there is no viable battery replacement solution
except paying expensively to ship it back to Razer and replace it.
Therefore, I had to stick to my ThinkPad X230 which only holds 60%
of its battery's original design capacity now.

Recently I upgraded to Ubuntu 18.04 LTS hoping Linux 4.15 could give me
some better battery life and prettier layouts. Naive was I. Desktop
and laptop support on Linux has been good thanks to people in the open
source scene, but it is simply falling behind in battery life
optimization compared to Windows 7 on the same machine. Layout-wise,
GNOME of Ubuntu 18.04 looks good except that the top bar and application
bar don't merge like they did in Unity. This further reduce the
available workspace I have for the applications. This is detrimental to
me such a small screen, and I had to switch to something else.

## What is i3wm?

i3 is a tiling window manager alternative to GNOME and Unity. Tiling
means that windows are non-overlapping frames instead of the traditional
stacking windows that we are familiar with. The first window you open
occupies the whole screen, then the next occupies half it the screen,
the third window occupies one-forth of the screen, and so on.

<figure>
<img src='./i3wm_tiling.png' width='100%' style='max-width: 48em;'/>
<figcaption>i3wm with non-overlapping tiling windows</figcaption>
</figure>

On Reddit [/r/unixporn](https://www.reddit.com/r/unixporn/), there is a strong following for tiling
windows manager as new "rices" are posted onto the subreddit daily, with
a lot of them using a fork of i3wm, i3-gaps, which add gaps between the
tiles and some other features.

For the poor folks deprived of pixels like me, we'd have more
pixels for our applications if we stick to the original i3wm.

i3 also manages it's windows in workspaces, as you can see in the
screenshot above, I am using the workspace named "Terminal". I also have
workspace named "Chrome", "Firefox", "Files" and so on. I type `Super +
3` to switch to the Chrome workspace, or `Super + 4` to switch to Firefox.
It didn't take much effort for me to get used to this, and each application
gets max screen pixels.

I appreciate i3 for it's simplicity and flexibility in configuration.
The window manager is primarily keyboard shortcut-driven, and there's no
weird transparency/blurring, just simple pixels for all your basic needs.
It is not pretty at first unless you customize it to your liking. I kept
a barebone setup for it and it rewards me with improved battery life and
more pixels on screen compared to GNOME and Unity.

## I have installed i3wm, now what?

The big question I asked after installing i3wm was like, what do I do?
Unlike GNOME or Unity where application launcher is triggered by
tapping the Super key (the one with Windows logo), in i3 you type `Super
+ D` to fire up `dmenu`, or `rofi`, or whatever launcher of your choice.
Sorry that I couldn't capture a screenshot while having rofi menu on,
but you may find some screenshots of rofi [here](https://github.com/DaveDavenport/rofi-themes/tree/master/Official%20Themes).

More often than not in the first couple weeks you'll find i3 doesn't
have many things working out-of-the-box for you. Your configuration file
located at `~/.config/i3/config` is likely to expand to twice or even
three times its original size as you add in configurations. For example,
I had to map media keys (+vol, -vol, mute, etc) and PrintScreen to their
respective commands for them to work. There was no lock screen or desktop
background, so you will have to use `i3lock` to add a lock screen, and `nitrogen`
to set a desktop background.

>  The usual elitism amongst minimal window managers: Don’t be bloated, don’t be fancy (simple borders are the most decoration we want to have)
>
> &mdash; Goals for i3 ([www.i3wm.org](https://i3wm.org/))

i3 is minimal by design. Not all computer have a PrintScreen key, or
media keys. If you have them, you will have to work out ways for them to
work on your machine. The official documentation for i3wm is very
well-written, well-organized and easy to understand that I finished
reading it over a bus ride. Surprisingly, there's a big and active community
on [/r/i3wm](https://www.reddit.com/r/i3wm/), various online forums and
tutorials with people willing to address your issue or who encountered
issues similar to yours before.

I have also developed an interest in reading others' i3wm config they
made public on GitHub or Gists. These config files contain some
convenient binding I haven't thought of, or better ways to do something.
Currently my i3 config is also hosted on GitHub via [tommyku/my-i3-config](https://github.com/tommyku/my-i3-config).

<figure>
<img src='./i3wm_polybar.jpg' width='100%' style='max-width: 48em;'/>
<figcaption>June 2018: How my current setup with polybar looks like</figcaption>
</figure>

<figure>
<img src='./i3wm_current.jpg' width='100%' style='max-width: 48em;'/>
<figcaption><s>How my current setup looks like</s></figcaption>
</figure>

The window manager has been working very well for me, I still have some minor
things I couldn't quite figure out myself, like key bindings for multiple
monitors, but there are ample of resources and examples out there that I
could look at. I expect to continue tinker with my i3 config, and that's
probably the fun of having a highly customizable environment on my
laptop.
