---
title: Feature ownership and motivation
kind: article
created_at: '2016-10-05 00:00:00 +0800'
slug: feature-ownership-and-motivation
preview: false
---

With 3 of my friends I used to join the department-held hackathon at
HKUST. One of which named Ivan, a talented programmer who were also
somewhat experienced in image editing and video processing.

We brainstormed a lot before the hackathon and ended up with 1 idea the
majority of us agreed on.
Of course, we needed a design before we start validation or
development, that
responsibility fell on Ivan's shoulder despite he were the minority who
opposed the idea.

Ivan did a fine work, we got a design the next day. We came to
discover that the idea we suppored yesterday could hardly impress us
anymore. Back to the drawing board, we brainstormed again.

Of course the one who spent the night creating a design was
dissatisfied. Ivan, losing trust on the other teammates, disagreed to
create any design until the rest of the team make a final decision, the
one killer idea we would never diverge from.

The team were demotivated, and it was nobody's fault. Product feature
idea and direction changes according to the circumtance. Everybody
who builds product knows it, but not all can deal with it calmly.

### Impromptu change and vague requirement demotivate people

Recalling the experience with the product manager and another engineer in
Taiwan, we have spent a big chunk of our time working on something and
had it thrown away because 1) we didn't validate it beforehand or 2) the
project manager has a better idea/something more valuable to do.

We never gave him a good face whenever the PM wanted to change. Over
time there developed a sentiment that if a feature is not well-designed
and validated with the users, we shouldn't work on it. We played with
cat instead.

The situation were made worse because our 'PM' were less of detail-focused
person but more of big-picture driven and gave nothing more than a sentence
rather. As an CEO that is fine, but as an PM, that is unacceptable.

> Don't ask me to do it until you're absolutely sure.

<figure>
<img src='./just-do-it.jpg' style='max-width: 600px'/>
<figcaption>Really, no</figcaption>
</figure>


We were demotivated. Task assignment became long discussion and took lots
of persuasion. The unhealthy tension between the devs and the PM
required much negotiations and trust building before the devs agreed to
work and the PM promised to not change the schedule until the end of the
sprint.

It was that moment that I realized what Ivan felt when I piped his
night-worth of work into `/dev/null`*. And the prospect of the project
were gloomy.

<small>* nerdy way to say 'void', 'nothingness'</small>

Vroom's Expectancy theory states that individuals motivation comes from
the belief that efforts are positively correlated to performance, and
that performance results in an outcome that brings reward that satisfies
an individual's need.

Now think about it, effort were paid yet there comes no performance nor
outcome because the work were trashed. While rewards (paycheck) were
given every month, developers seek more than monetary rewards. They
value the sense of achievement when they deploy a feature with nice code
and novel approaches.

Therefore impromptu change in plan negates developers' paid efforts and
brough nothing but demotivation.

### Feature ownership motivates people

> Tommy, I have something to ask you.

Sometime my colleague John would call me to his seat and showed me the
code I wrote. He could be modifying the code or didn't understand it.
Then he would made me feel shameful or feel proud of the piece of code I
wrote.

In EventXtra where I worked, every one of us is usually responsible for
a chunk of feature. One would architech it, write up algorithms to *do
something*. Later somebody else may manage that piece of code, by then
the piece or code is either `git praise`-ed or `git blame`-ed.

~~~
# ~/.gitconfig
[alias]
    praise = blame
~~~

> This's my feature, and that is your feature. For that part of code,
you'd better ask *Kenneth*.

> Who the h\*ll wrote this? Let me git blame it.

<figure>
<img src='./git-blame.jpg'/>
<figcaption>Go, <a href='https://github.com/jayphelps/git-blame-someone-else'>blame someone else</a></figcaption>
</figure>

When we evaluate a piece of work, we refer it by *somebody's* feature
not because that person is the sole person responsible for developing
it, but that it's consolidated a significant amount of effort from that
person and thus that person feels a *psychological ownership* over it.

The sense of psychological ownership also spawns from the fact that
someone being a opinion leader over a feature, in which he possesses
control over a major part of the design or implementation of the
feature.

[Research by Dyne and Pierce](http://cqtesting.com/papers/JOB%202004%20Van%20Dyne%20Pierce%20Psychological%20Ownership.pdf) demonstrates
positively links between psychological ownership for the organization and employee
attitudes, and work behavior.

Of course, when a piece of code is `git praise`-ed the developer feels good
about it due to a sense of ownership. Ownership positively influences
the attitude and performance of a developer as a feature is being
developed.

### Feedback and discussion are the keys

We have talked about what demotivates and what motivates. To those who
are attempting to improve their own working motivation, these are what
to fix and what to reinforce. For those who attempts to motivate, they
should take note on and avoid the behaviors demotivating their colleagues.

Open communication aiming at trust-building instead of blaming can help
the managements to better understand the need of their colleagues.

As a friend of mine always says: 'When your trust bank has bankrupted,
you\'ve to work hard to build the trust back up.' Should you see your
colleagues demotivated on their jobs, trust-building is the first step.

Have you encountered motivation issues in workplace, either on yourself
or your colleagues? How did you deal with it? Tell us in the comment
section!
