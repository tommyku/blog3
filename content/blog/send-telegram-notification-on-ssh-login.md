---
title: "Send Telegram notification on SSH login via PAM"
kind: article
created_at: '2019-07-07 00:00:00 +0800'
slug: send-telegram-notification-on-ssh-login
preview: false
abstract: 'Every login to my VPS via SSH should now send out a Telegram message
to notify me of a successful login. Not really bullet-proof, but good enough.'
--- 

<!-- 
This line is 80 characters long
01234567890123456789012345678901234567890123456789012345678901234567890123456789
-->

Every time I logon to my bank's website, there's a helpful and annoying
notification sent to my email and phone via SMS. I want my VPS to behave the
same when I logon via SSH because I have never had an idea if somebody else is
using my key to logon (it shouldn't be...) when I wasn't looking. Having my
phone with me most of the time, I can receive push notification via a Telegram
bot.

The following steps have been experimented on an Ubuntu 18.04 VPS hosted on
Digital Ocean.

## Step 1: Create a bot

You need to talk to @BotFather of Telegram about it.

For a detailed walkthrough, refer to the documentation of my [Telegram starter
bot repo](https://github.com/tommyku/telegram-bot-starter#step-1-register-your-bot).

At the end of it, you should receive a bot token like the following:

~~~
987654321:ABCDEFGHIJKLMNopqrstUVWXYZ123456789
~~~

## Step 2: Add a script to /etc/ssh

Create a script to be ran by PAM when user logs in. While it's fine to place
it anywhere, I chose to put it inside /etc/ssh.

~~~ bash
sudo touch /etc/ssh/login_notify.sh
sudo chmod +x /etc/ssh/login_notify.sh
sudo editor /etc/ssh/login_notify.sh
~~~

Content of the script looks like:

~~~ bash
#!/usr/bin/env bash
# Content of /etc/ssh/login_notify.sh
TELEGRAM_TOKEN="987654321:ABCDEFGHIJKLMNopqrstUVWXYZ123456789"
CHAT_ID=""

if [ ${PAM_TYPE} = "open_session" ]; then
  MESSAGE="$PAM_USER@$PAM_RHOST: knock knock via $PAM_SERVICE"
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$MESSAGE" > /dev/null 2>&1
fi
~~~

If you run `login_notify.sh` now, you are likely to not receive anything
because inside the script `$CHAT_ID` hasn't been set, and Telegram does not
know who to send this message to.

To obtain your chat ID, first text your bot with a `/start` message.
Then from terminal:

~~~ bash
curl https://api.telegram.org/bot<BOT TOKEN>/getUpdates
# { ..."chat": { "id": 12345, ... }... }
~~~

Let's fill in the chat ID we found into `login_notify.sh`.

~~~ diff
--- a/etc/ssh/login_notify.sh
+++ b/etc/ssh/login_notify.sh
- CHAT_ID=""
+ CHAT_ID="12345"
~~~

Let's try this our by running the script with the least amount of
environmental variables set.

~~~ bash
PAM_TYPE="open_session" /etc/ssh/login_notify.sh
# Telegram > "@: knock knock via"
~~~

The script works. Now we need it to be triggered.

## Step 3: Modify PAM configuration to trigger the script

PAM configurations for each service are located in `/etc/pam.d`. In
particular, we are interested in `/etc/pam.d/sshd`.

~~~ bash
sudo editor /etc/pam.d/sshd
~~~

Add to the end:

~~~ bash
# Login Telegram Notification
session optional pam_exec.so /etc/ssh/login_notify.sh
~~~

## Step 4: Test it

~~~ bash
ssh -l username hostname -P port
~~~

<figure>
<img src='./it-works.png'/>
<figcaption>Good. It works.</figcaption>
</figure>
