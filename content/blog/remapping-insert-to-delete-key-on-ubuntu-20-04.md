---
title: Remapping Insert to Delete key on Ubuntu 20.04
kind: article
created_at: 2020-12-24 18:51:19 +0800
slug: remapping-insert-to-delete-key-on-ubuntu-20-04
preview: false
abstract: Delete key on my ThinkPad X230 fell off years ago, so I repurposed the rarely used Insert key into a Delete key
---

<figure>
  <a href="./5fe46042198abdelete_key_null.jpg" target="_blank">
    <img src="./5fe46042198abdelete_key_null.jpg" style="max-width: 100%; max-height: 500px;" alt="Delete key has lot a keycap, replaced by tape">
  </a>
<figcaption>Filmsy keycap of Lenovo ThinkPad's Delete key has broken</figcaption>
</figure>

I tried a few out-dated methods using `xmodmap` and getting `~/.xinitrc` to run on startup but even if `.xinitrc` is executed, the key is still not mapped.

At the end I stumbled upon [this answer](https://askubuntu.com/questions/325272/permanent-xmodmap-in-ubuntu-13-04/347382) when I was about to give up, and it worked.

I needed to change `/usr/share/X11/xkb/symbols/pc` with as root to modify the behavior of Insert key to Delete. Saved the file, reboot and it worked like a charm.

~~~diff
-    key  <INS> {	[  Insert		]	};
+    key  <INS> {	[  Delete		]	};
~~~
