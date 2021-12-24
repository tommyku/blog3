---
title: Self-saving web app
kind: article
created_at: 2021-12-23 21:19:40 +0800
slug: self-saving-web-app
preview: false
timeless: false
abstract: An exploration with small web app and WebDAV
---

I don't remember when did I first learn about [TiddlyWiki](https://tiddlywiki.com/). 10 years ago perhaps, when [TiddlyWiki 2](https://classic.tiddlywiki.com/) was still the major version. 10 years ago I was still using free hosting and cPanel to run small self-developed PHP 4 note-taking programs.

When I first saw TiddlyWiki I was blown away by the idea that a website replicates itself in its entirety to the disk on save. That means no backend is required to host a full-blown Wiki software, whereas [most of rest of the world](https://en.wikipedia.org/wiki/List_of_wiki_software) relied on some sort of backend and database to work.

Now come to think about it, this is quite straight forward to implement:

~~~plaintext
html
|-- head
|-- body
|---- script (saved state)
|---- templates
|---- main
|---- script (application logic)
~~~

`html`, `head`, `templates`, `main` and `script` with application logic can simply be replicated on save. `script` with saved state is updated with application state at the time of saving. Of course, application state needs not be script only, it could also be HTML, or plaintext, or script, or script that loads external data, or any other format.

## Why self-saving web app

You may have seen lots of applications having front/backend architecture, yet there are few self-saving web apps like Tiddlywiki. Nowadays with free tier cloud hosting in abundance, it seems that "no backend required" argument is no longer justifyable.

Here let me try naming a few reasons why self-saving web app is still needed:

**Easy to backup/share** - I maintain documentation of a freelance project using Tiddlywiki, so I can easily version control and share the documentation, with attachments and images, in a portable format (HTML vs. Word document)

**Simple development** - simple, small app can be encapsulated into a single HTML document and edited on the spot with basic text editor without setting up a development environment

**Minimal backend** - self-saving web app can be saved to a very thin backend such as WebDAV that saves the entire copy of the app to a server location, or simply save a copy to local machine without the need of a backend even

**App is also app builder** - users can save a copy of the app locally after having configured it to their liking and host it themselves

## Example: Pastebin

Over the years I have tried out many different hosted pastebin solution. All of which require a heavy backend and most require some sort of database.

SQLite would have been fine, yet I can't understand why a full-blown separate DBMS is required. Scalability? No one but me is using it.

Below shows a self-saving pastebin application I quickly created using the aforementioned architecture. In this case, the template and data are contained within the `<textarea>`.

~~~ html
<html>
    <head>
        <title>Pastebin</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="mobile-web-app-capable" content="yes">
        <style>
            main {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1em;
                position: relative;
            }
            .bin-textarea {
                margin-bottom: 1em;
                height: 15vh;
                line-height: 1.4em;
                font-size: small;
            }
            .bin-textarea:focus {
                position: absolute;
                width: 100%;
                height: 100%;
            }
            .bin-save {
                display: block;
                margin-bottom: 1em;
                width: 100%;
            }
        </style>
    </head>
    <body>
        <h1>Pastebin</h1>
        <button class="bin-save">Save</button>
        <main>
            <textarea class="bin-textarea"></textarea>
            <textarea class="bin-textarea"></textarea>
            <textarea class="bin-textarea"></textarea>
            <textarea class="bin-textarea"></textarea>
            <textarea class="bin-textarea"></textarea>
            <textarea class="bin-textarea"></textarea>
            <textarea class="bin-textarea"></textarea>
            <textarea class="bin-textarea"></textarea>
        </main>
        <script>
            const save = data => {
                const html =
`<html>
    ${document.querySelector('head').outerHTML}
    <body>
        <h1>Pastebin</h1>
        <button class="bin-save">Save</button>
        <main>
            ${data.map(d => `
                <textarea class="bin-textarea">${
                d.replace("<", "&lt;").replace(">", "&gt;")
                }</textarea>
            `).join("")}
        </main>
        ${document.querySelector('script').outerHTML}
    </body>
</html>`;
                console.debug(html);
                saveToFile(html);
            };
            const saveToFile = html => {
                const $a = document.createElement('a');
                $a.href = URL.createObjectURL(new Blob([html], { type: 'text/html' }));
                $a.setAttribute('download', 'pastebin.html');
                document.body.appendChild($a);
                $a.click();
                document.body.removeChild($a);
            };
            /* Will cover this later
            const saveToWebDAV = html => {
                fetch(`/pastebin.html`, {
                    method: "PUT",
                    credentials: "include",
                    body: html
                })
                .then(() => window.location = '/pastebin.html?saved')
                .catch(console.error);
            };
            */
            const $save = document.querySelector('button');
            const $textarea = document.querySelectorAll('textarea');
            $save.addEventListener('click', e => {
                const data = Array.from($textarea).map(t => t.value);
                save(data);
            });
            /* Will cover this later
            if ((new URLSearchParams(window.location.search)).has('saved')) {
                $save.classList.add('animated', 'bounce');
            }
            */
        </script>
    </body>
</html>
~~~

When the page loads, the `<script>` tag at the bottom is ran and click event listener is added to the save button.

~~~ javascript
$save.addEventListener('click', e => {
    const data = Array.from($textarea).map(t => t.value);
    save(data);
});
~~~

User edits the textareas and eventually click on "Save" button. After which, `save` method is called and the app's full HTML content is recreated.

`<head>` and `<script>` are simply copied over. The app shell such as app title and save button are statically written. And internal value of `<textarea>` is dynamically written to inner HTML of tag, so that the state is retained.

~~~ javascript
const html =
`<html>
    ${document.querySelector('head').outerHTML}
    <body>
        <h1>Pastebin</h1>
        <button class="bin-save">Save</button>
        <main>
            ${data.map(d => `
                <textarea class="bin-textarea">${
                d.replace("<", "&lt;").replace(">", "&gt;")
                }</textarea>
            `).join("")}
        </main>
        ${document.querySelector('script').outerHTML}
    </body>
</html>`;
~~~

Then `save` method will call `saveToFile` to auto-download the file to local. It could also save to WebDAV, or some sort of backend.

~~~ javascript
const saveToFile = html => {
    const $a = document.createElement('a');
    $a.href = URL.createObjectURL(new Blob([html], { type: 'text/html' }));
    $a.setAttribute('download', 'pastebin.html');
    document.body.appendChild($a);
    $a.click();
    document.body.removeChild($a);
};
~~~

As you can see, a lot of conerns (component initialization/saving) are mixed into the same `<script>` tag. I wouldn't recommend this approval for app having multiple views.

Careful cleaning can help clear this up. Imagine view-model using React + action-reducer-store using Redux, yet the app would end up framework-heavy. Browser-native Web compoment might be a good middle ground.

## Saving with WebDAV

In the pastebin example above, there are some commented out code which are for saving the app to a thin backend such as WebDAV. I say WebDAV is thin because user need not write any custome to make this backend work.

In fact, the WebDAV server I run behind my personal pastebin instance is simply a docker container. My choice of WebDAV server is rclone, and there are many other images available.

~~~ bash
docker run --name pastebin \
        -u $(id -u):$(id -g) \
        -v /path/to/pastebin/dir:/data \
        --log-opt max-size=32k \
        -p 8080:8080 \
        rclone/rclone serve webdav --addr :8080 --dir-cache-time 0 /data
~~~

To update content on a WebDAV server, the WebDAV PUT method (like HTTP PUT) can be used to overwrite resource on the server.

~~~ javascript
const saveToWebDAV = html => {
    fetch(`/pastebin.html`, {
        method: "PUT",
        credentials: "include",
        body: html
    })
    .then(() => window.location = '/pastebin.html?saved')
    .catch(console.error);
};
~~~

We use `fetch` to make a PUT call to WebDAV server, with `credentials` set to "include" to include any authentication header in the call, and simply put the web app's html into request body. On the otherside the content of `pastebin.html` will be overwritten.

Once the call is finished, the page is refreshed with an additional `saved` query parameter. This has nothing to with WebDAV but simply a cherry-on-top that we want to present some visual feedbacks that the page is saved and reloaded.

~~~ javascript
// Add animate.css or something that implements these 2 CSS classes
if ((new URLSearchParams(window.location.search)).has('saved')) {
    $save.classList.add('animated', 'bounce');
}
~~~

Since the page is getting reloaded right after saving, `--dir-cache-time 0` is added to the docker run comment above to disable caching.

## Example: Startpage generator

The pastebin example covers the first 3 reasons: **Easy to backup/share**, **Simple development** and **Simple development**.

Now let me throw in another example to showcase the reason **App is also app builder**.

Below is a simple (lazily built) startpage + startpage generator that mutates itself when new link is added. That means the HTML structure is used to persist its state.

When save button is clicked, the entire page is simply re-created and saved locally. This may be used to distribute copies of the site to other people after they have customized it to their own likings. The copies can then make copies after further customization.

~~~ html
<html>
    <head>
        <title>Startpage</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="mobile-web-app-capable" content="yes">
        <style>
            body {
                max-width: 960px;
                margin: auto;
            }
            main {
                display: grid;
                grid-template-columns: repeat(4, minmax(200px, 1fr));
                gap: 1em;
                position: relative;
                margin-bottom: 1em;
            }
            .btn-save {
                display: block;
                margin-bottom: 1em;
                width: 100%;
            }
            main a {
              padding: 1em;
              border: dotted 1px grey;
            }
            main a:hover {
              border: solid 1px grey;
            }
        </style>
    </head>
    <body>
        <h1>Startpage</h1>
        <button class="btn-save">Save</button>
        <main></main>
        <button class="btn-add">Add</button>
        <script>
            const save = () => {
                const html =
`<html>
    ${document.querySelector('head').outerHTML}
    ${document.querySelector('body').outerHTML}
</html>`;
                console.debug(html);
                saveToFile(html);
            };
            const saveToFile = html => {
                const $a = document.createElement('a');
                $a.href = URL.createObjectURL(new Blob([html], { type: 'text/html' }));
                $a.setAttribute('download', 'startpage.html');
                document.body.appendChild($a);
                $a.click();
                document.body.removeChild($a);
            };
            const $save = document.querySelector('button.btn-save');
            const $add = document.querySelector('button.btn-add');
            $save.addEventListener('click', e => save());
            $add.addEventListener('click', e => {
                const url = prompt("URL?");
                const title = prompt("Title?");
                if (url && title) {
                    const $a = document.createElement('a');
                    const $main = document.querySelector('main');
                    $a.href = url;
                    $a.textContent = title;
                    $main.appendChild($a);
                }
            });
        </script>
    </body>
</html>
~~~

## Source pollution due to browser extensions

One thing to note, when using a self-saving web page, is that the simple ones like above are susceptible to pollution by browser extensions. If the extensions add/remove certain element on the page, the change in HTML will end up reflecting on the saved copy.

This may be worked around by using web components (with HTML template) and adding integrity checks to the static content to be saved. The only thing that should be changed on save is the state.

## Why write about self-saving web app

That's all about self-saving web app I have to write about. This post is my answer for a Hacker News post [Ask HN: Simplest stack to build web apps in 2021?](http://web.archive.org/web/20211125010339/https://news.ycombinator.com/item?Id=29311761)

While this approach is not realistic for full-blown apps on production, this is a fast and cheap way to build small apps with persisted state with a shared, thin WebDAV backend.