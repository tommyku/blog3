---
title: "Putting Claude Code on mobile"
kind: article
created_at: '2026-01-14 00:00:00 +0800'
slug: putting-claude-code-on-mobile
preview: false
unprofessional: true
abstract: "Needless complication or personalized solution"
---

Oh wow I am still around. Was busy with [photos](https://photo.tommyku.com/) and [watches](https://timepiece.tommyku.com/).

The most exciting thing in the past 2 years has to be AI. At my line of work as software engineer AI has became a irreplaceable tool for productivity.

Claude AI isn't available in my country without an VPN because of politics and I don't want to use an VPN. Instead, there are some LLM models that are available at my country namely Deepseek and GLM (through Z.ai). They support the Anthropic API so Claude Code can work with these LLMs. I had lots of fun using Claude Code to uplift my some personal tools I have built over the years.

Now I want to use Claude Code on mobile. There are existing solutions such as

1. using Claude Code on the web (banned in my city)
2. directly SSH'ing into my home server
3. use [Happy](http://happy.engineering/) (I don't like the naming)

Claude Code on the web is of course out of the question due to them banning access from my city. While I can access my home server via home VPN, I didn't want to set up SSH and handle firewall or keys. I tried using Happy, its documentation for self-hosting with Docker doesn't work and was said to be outdated.

What I did at the end was using [ttyd](https://github.com/tsl0922/ttyd) to expose the terminal session to my LAN protected by basic authentication.

It wasn't easy at first when I attempted to `docker attach` my `ttyd` container to the `claude` container, and it would have to allow the `ttyd` access to `docker.sock` which I don't like.

At the end, I rebuilt my `claude` container to have `ttyd` installed. Of course, with the help from Claude Code.

~~~dockerfile
FROM node:latest

# Install build dependencies for ttyd and tmux
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libssl-dev \
    libwebsockets-dev \
    libjson-c-dev \
    git \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Build and install ttyd from source
RUN git clone https://github.com/tsl0922/ttyd.git /tmp/ttyd \
    && cd /tmp/ttyd \
    && mkdir build && cd build \
    && cmake .. \
    && make && make install \
    && rm -rf /tmp/ttyd

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Verify installations
RUN node --version && npm --version && ttyd --version && tmux -V

WORKDIR /app

# Use entrypoint script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
~~~

I would then mount my git folder, and the `node_modules` of claude onto this new container. `docker-entrypoint.sh` would run `ttyd` with a simple `bash` command to start.

This setup appears to work and I was able to start and interact with Claude Code from my mobile. However whenever I kill the browser tab or put my phone on standby while waiting for the LLM to finish crunching numbers, the Claude Code instance would have been killed.

This is because `ttyd` will kill the process it started on socket disconnect. When killed, Claude Code also generates a large dump file at the working direction, which is another nuisance.

~~~bash
#!/bin/bash
# Start or attach to the default tmux session
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
tmux -u new-session -d -s default 2>/dev/null || true

# Build ttyd command with optional credentials
TTYD_CMD="ttyd --writable -t fontSize=25"

if [ -n "$TTYD_USERNAME" ] && [ -n "$TTYD_PASSWORD" ]; then
    TTYD_CMD="$TTYD_CMD -c $TTYD_USERNAME:$TTYD_PASSWORD"
fi

# Start ttyd and attach to the tmux session
exec $TTYD_CMD tmux attach-session -t default
~~~

This is the updated `docker-entrypoint.sh`, it uses `tmux` to maintain a session. Whenever `ttyd` reconnects, it restores the default `tmux` session.

It worked like a charm!