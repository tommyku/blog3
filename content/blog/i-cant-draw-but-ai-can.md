---
title: I can't draw but AI can
kind: article
created_at: '2023-05-17 00:00:00 +0800'
slug: i-cant-draw-but-ai-can
preview: false
abstract: I had never been a good drawer, except maybe I don't have to draw anymore
---

*Note: Unlike most other posts, this one is not instructional. There're many tutorials online that are way better than any tutorial I could've ever produced.*

When I was little my parents sent me to a drawing class which taught nothing but gave us empty papers and paints to draw on. Then was an age where creativity was appreciated over accuracy, thus my results were passable at the time.

Fast forward to secondary school years, my art score hadn't been any better, especially when accuracy and design were concerned. Self-learning wasn't a thing until I after form 4, when I realized the school teaches the mere basics while putting an unreasonably high bar on students.

Fine, had I came to that realization earlier in life, I wouldn't have had an easier time re-learning everything in my adulthood.

Then came 2022, amongst the COVID-19 pandemic came the exciting boom of image diffusion model: DALL-E2, Midjourney, Stable Diffusion&hellip;

## My love for impressionism

For a period I was hooked by the impressionism works by Claude Monet.

In an attempt to re-create the impressionistic look, I dug fairly deep into the GIMPressionist filter of GIMP.

<figure>
<img style='max-width: 300px;' src='./imp.jpg' alt='Impressionistic painting converted from photo via GIMPressionism' />
<figcaption>Impressionistic painting converted from photo via GIMPressionism</figcaption>
</figure>

Not good. There's a hint of impressionism yet by simply placing fake strokes on top of a digital image, the details are appearing too clearly and the brushstrokes too regular for the impressionistic touch.

## First time trying out AI

Therefore I turned to AI, to Stable Diffusion, when it first came out as an open source project. At that point people were still using the 1.5 checkpoint and it's quite lacking compared to what we the community were able to produce now in May 2023.

On my underpowered machine Razer Blade 14 with a meager 3GB of VRAM, I was able to produce a few 512x512 at 15 steps over a run time of 5-10 minutes, *on command line*. Nowadays there's an easy to use UI that makes both learning and using way easier.

I was very disappointed. The img2img output failed to retain the original look of my photo and went fairly creative. Yet, the biggest issue was the resolution. At 512x512 these are not good enough to excite me.

<figure>
<img style='max-width: 100%;' src='./919183_00001.png' alt='Impressionistic painting imagined by Stable Diffusion via img2img' />
<figcaption>Impressionistic painting imagined by Stable Diffusion via img2img</figcaption>
</figure>

## My other artistic interests

Before continuing, I wish to talk about my other artistic interests. Aside from impressionism I am also passionate block printing works, in particular the many Ex Libris (bookplate) almost completely faded into history.

So I created my own that's not exactly fancy.

<figure>
<img style='max-width: 100%;' src='./192713.jpg' alt='Left: draft. Middle: print. Right: stamp.' />
<figcaption>Left: draft. Middle: print. Right: stamp.</figcaption>
</figure>

I told you I am not good at art. Maybe AI could help me fix this.

## Second time trying out AI

Months later, I paid for Midjourney hoping to give AI generative art another try. On its own, Midjourney is capable of producing sufficiently good image given a well-crafted text to image prompt. Except it can't do hands properly and I lack critical control over placement, style and size of elements.

Still, one leap forward beyond GIMP and early Stable Diffusion.

<figure>
<img style='max-width: 300px;' src='./tti.png' alt='Text to image Rabbit' />
<figcaption>Text to image via Midjourney</figcaption>
</figure>

<figure>
<img style='max-width: 500px;' src='./photo2img.png' alt='Photo to image via Midjourney' />
<figcaption>Photo to image via Midjourney</figcaption>
</figure>

By blending images Midjourney, it's possible to use reference images to specify the style to convert the image into. This time, block printing.

<figure>
<img style='max-width: 300px;' src='./rabbit.png' alt='Rabbit' />
<figcaption>Sketch to image via Midjourney</figcaption>
</figure>

One thing I like Midjourney over other generative art AIs is the way they run the community. Except for work generated in private mode, which is only available in the most expensive plan, all work and their promptes are made visible publicly in the community feeds. Beginners can easily learn from the good works produced by others and build on top of them.

However, there's still the problem of a private company profiting off weights trained from publicly available sources and keeping a tight grip over the content generated.

## Third time trying out AI

I didn't want to continue paying for Midjourney and to be honest it could only take me that far. So the next thing to do was to setup my own instance of Stable Diffusion at home.

Luckily, my main PC sports a 7-year old GTX 1060 GPU with 6GB of VRAM. After several months of effort by the community, Stable Diffusion had became heaps more approachable, with one-click installer and various high quality checkpoints/loras.

Simply swapping the checkpoint from the default one I was able to generate pretty good output. Hands are still bad though.


<figure>
<img style='max-width: 100%;' src='./2959607628.png' alt='Rabbit with unicorn horn holding a spear' />
<figcaption>Rabbit with unicorn horn holding a spear but slightly too cute</figcaption>
</figure>

Then ControlNet came around changing everything. For generative AI, by default there is little control, because once the text had been converted into latent space vectors it's at the mercy of what the model already knows and lots of randomness.

<figure>
<img style='max-width: 100%;' src='./3404297023.png' alt='Rabbit with unicorn horn holding a spear' />
<figcaption>Rabbit with unicorn horn holding a spear, closer to original sketch, bit scary</figcaption>
</figure>

<figure>
<img style='max-width: 100%;' src='./3095961692.png' alt='Rabbit with unicorn horn holding a spear' />
<figcaption>Rabbit with unicorn horn holding a spear(?), too much creative freedom, quite scary</figcaption>
</figure>

With careful control over the parameters and trial and erros, I am now able to create the impressionistic work that pleases me.

<figure>
<img style='max-width: 100%;' src='./2747851235.jpg' alt='Impressionistic painting convered from IMAX film shot on medium format camera' />
<figcaption>IMAX film shot on medium format camera, converted into impressionistic work via Stable Diffusion</figcaption>
</figure>

<figure>
<img style='max-width: 100%;' src='./2157833255.png' alt='Impressionistic painting convered from GIMPressionist output' />
<figcaption>Impressionistic painting convered from GIMPressionist output via Stable Diffusion</figcaption>
</figure>

By importing Loras trained on works of a particular artist, the AI is able to replicate the artist's style to a believable degree. And I can also blend my photo and with their drawing style. This one is based on the style of an artist I like on Pixiv.

<figure>
<img style='max-width: 100%;' src='./1626995868.jpg' alt='Girl standing under flowers' />
<figcaption>Photo blended with AI-generated drawing via Stable Diffusion</figcaption>
</figure>

With ControlNet, there's more control over how an image can be. I don't get the block printing outcome I wanted because the checkpoint I used were better at creating cartoons. Sometimes (most of the time), I create monsters unintentionally.

<figure>
<img style='max-width: 300px;' src='./3529768930.png' alt='Rabbit with unicorn horn holding a spear or some random creature' />
<figcaption>??????</figcaption>
</figure>

Use Inpainting + ControlNet img2img to preserve text while converting my friend into something that my friend isn't.

<figure>
<img style='max-width: 100%;' src='./4028222514.png' alt='Vibe' />
<figcaption>Vibe</figcaption>
</figure>

Oh and, it's easy to upscale output I got from Midjourney with Stable Diffusion.

<figure>
<img style='max-width: 300px;' src='./3091167260.jpg' alt='Girl holding camera' />
<figcaption>For the lack of a life-sized model</figcaption>
</figure>

## AI is a tool

With the advent of diffusion model and GPT boom in late 2022, they have shown a lot of promises. Although they may be able to project an image of apparent intelligence, they still require a lot of guidance, say in the form of ControlNet, Inpainting, or preprocessing. Like a hammer, it only works when hitting on the nail head correctly.

Just like tools, a lot of experimentation and study are needed to understand how it works, and how to make these AI tools do what I want in the way I want.

So these AIs are probably not the silver bullet many came to believe or many are trying to advertise as.

## Thoughts on future of AI

Imagine the amount of energy wasted on crypto could have been better used to train more sophisticated models, provided that the entity behind each and every model and algorithm make the relevant tools and model weights public for the community to build on top of, like Stable Diffusion.

Oh, the same amount of wasted energy (plus all the externalized side effect in hardware procurement) will be diverted to training AI models, then the companies will paywall them and begin charging a monthly subscription fee&mdash;just so that someone can have an agreeable AI conversation&hellip;

Pretty grim, but what in life isn't.

By the way, is you job still secure?