---
title: "Controlling my home server with Syncthing"
kind: article
created_at: '2019-07-27 00:00:00 +0800'
slug: controlling-my-home-server-with-syncthing
preview: false
abstract: "How I threw together a few files to come up with a solution
controlling my laptop's sleep/shutdown state"
--- 

<!-- 
This line is 80 characters long
01234567890123456789012345678901234567890123456789012345678901234567890123456789
-->

At home I run a Windows 10 Home on Thinkpad E540 as a home server. It sites
nicely inside the TV closet drawer quietly doing its thing. With Emby, SMB and
some web services I am able to make use of the home server as much as I want to.

However there is one thing that Windows 10 Home cannot do: remote desktop.
Microsoft locked up the feature for Home edition and even though people got it
working with RDP wrapper in the past, it no longer works on my machine in 2019.

The reason I need to remotely connect to my laptop is such that I can put it to 
sleep, wake up and shutdown using only my phone. This is obvious - just throw in
a web server that can run shell commands. Say IIS + PHP.

Going down this path will inevitably lead us to stuff like handling
authentication, opening an extra port in the firewall and setting up PHP on
IIS. That’s too much work for my lazy self.

So I turned to the unobvious - I’ve already had an SMB and a Syncthing server
running. SMB is for sharing storage to other machines and Syncthing is similar
but running on my phone. What if the server polls for commands updatable by
these services? SMB and Syncthing each has their own authentication layer, and
I only need to work out the logic. A logic like this:

<figure>
<img style='max-width: 100%;' src='./Controlling my home server with Syncthing.png' alt='Finite state machine showing states of the laptop' />
<figcaption>State diagram of the laptop, with transition triggered by file change</figcaption>
</figure>

Because the state itself can easily be represented by what file is in the `is`
and `should` folder, I only need to use SMB/Syncthing to move around files in
order to update the states. The state is maintained by folders and files
inside a control folder accessible via SMB and Syncthing.

~~~ plaintext
Control
├── is/
├── should/
├── running.txt
├── shutdown.txt
├── sleep.txt
├── will_shutdown.txt
├── will_sleep.txt
└── Control.cmd
~~~

A scheduled task will run every 1 minute to scan for any change in state and
perform some actions while moving to the next state. Best part? Most of it
comes for free.

<figure>
<img style='max-width: 100%;' src='./Control power state using Syncthing.png' alt='Data flow' />
<figcaption>Components and data flow</figcaption>
</figure>

Everything here is already in place except for the scheduled task that reads
the latest state and perform actions (sleep/shutdown) accordingly. I created
a `.cmd` file is pretty simple. For each of the states above that has a
transition marked by `1 min`, I define an if statement to check the state,
then perform the action and state change. With such a simple finite state
machine it didn’t take long to debug.

~~~
IF EXIST ".\should\sleep.txt" (
  DEL ".\is\*.txt"
  DEL ".\should\*.txt"
  COPY ".\will_sleep.txt" ".\is"
  curl -s -X POST https://api.telegram.org/bot<BOT TOKEN>/sendMessage -d chat_id=<CHAT ID> -d text="HOMESERVER will sleep soon"
  EXIT 1
)

IF EXIST ".\is\will_sleep.txt" (
  DEL ".\is\*.txt"
  DEL ".\should\*.txt"
  COPY ".\sleep.txt" ".\is"
  curl -s -X POST https://api.telegram.org/bot<BOT TOKEN>/sendMessage -d chat_id=<CHAT ID> -d text="HOMESERVER sleeps now"
  %windir%\System32\rundll32.exe powrprof.dll,SetSuspendState 0,1,0
  EXIT 2
)

IF EXIST ".\should\shutdown.txt" (
  DEL ".\is\*.txt"
  DEL ".\should\*.txt"
  curl -s -X POST https://api.telegram.org/bot<BOT TOKEN>/sendMessage -d chat_id=<CHAT ID> -d text="HOMESERVER will shutdown soon"
  COPY ".\will_shutdown.txt" ".\is"
  EXIT 3
)

IF EXIST ".\is\will_shutdown.txt" (
  DEL ".\is\*.txt"
  DEL ".\should\*.txt"
  COPY ".\shutdown.txt" ".\is"
  curl -s -X POST https://api.telegram.org/bot<BOT TOKEN>/sendMessage -d chat_id=<CHAT ID> -d text="HOMESERVER shutdowns now"
  shutdown.exe -s
  EXIT 4
)

DEL ".\is\*.txt"
DEL ".\should\*.txt"
EXIT 5
~~~
<!-- 
This line is 80 characters long
01234567890123456789012345678901234567890123456789012345678901234567890123456789
-->

I’ve included a `curl` command to send out Telegram notification notifying
a state change. For more information regarding using Telegram as a notification
service, look at my [previous post](/blog/send-telegram-notification-on-ssh-login/).

What is left is a trigger that runs this `cmd` file every 1 minute. It took me
awhile to figure it all out because of how strange Windows’s task scheduler
works while the *nix master race who’ve been using the awesome CRON wouldn’t
understand.

In a nutshell, we want to run this script:

- every minute after start up
- even if waking from sleep
- regardless of power source (AC/battery)
- regardless of whether the user has logged in or not

I have exported the task into an .xml file such that you can just import it,
change some necessary parameters and off you go.

~~~ xml
﻿<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2019-06-15T16:20:14.7976916</Date>
    <Author>HOMESERVER\user</Author>
    <Description>HOMESERVER Control</Description>
    <URI>\HOMESERVER Auto Control</URI>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <Repetition>
        <Interval>PT1M</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <StartBoundary>2019-07-10T00:00:00</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>UserId</UserId>
      <LogonType>Password</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>StopExisting</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Data\Control\control.cmd</Command>
      <WorkingDirectory>C:\Data\Control</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
~~~

From task scheduler, click “Import Task...” and select the downloaded file.
Change the user and location to the script to wherever the control script is
located. Now we have got the logic covered. What’s left is some simple wiring
to allow syncing files between the control folder and the phone’s internal
storage using Syncthing.

For download/setup of Syncthing, refer to Syncthing’s
[website](https://syncthing.net/) which pretty much explained it all. Just
make sure you can sync files between your phone and the PC. 

To move the PC into a sleep state, first copy and paste `sleep.txt` into
`./should` folder, then instruct Syncthing on the phone to perform a folder
rescan.

<figure>
<img style='max-width: 350px;' src='./Screenshot_20190720-121043.png' alt='Syncthing UI on mobile' />
<figcaption>Syncthing UI on mobile</figcaption>
</figure>

The default rescan interval is 1 hour. Reducing it to say 1 minute could
avoid manually triggering a rescan at the cost of battery life. As we’ll
always trigger a rescan when we need it, it’s probably ok making the
rescan interval 1 day or even longer.

In a minute or so, the home server should have picked up the file change
and sent out a Telegram message notifying that it’s going to sleep and
then in another minute’s time, the server goes to sleep.

Next time when I want to wake the server, I can either go pressing its
power button directly, or use Emby for Android’s “Wake server” feature.
Thus at this point, we’ve connected all the dots and established a
control mechanism for the home server without adding additional web
service.

<figure>
<img style='max-width: 100%;' src='./Controlling my home server with Syncthing.png' alt='Finite state machine showing states of the laptop' />
<figcaption>Nothing but a scheduled job and Syncthing</figcaption>
</figure>

Some may say I am just asking for trouble by adding artificial
constraints to myself. That is true. I could have set up a simple PHP
script or build a bot to long-poll Telegram’s API and act accordingly.
I was too lazy to set those up, or play around with cmd’s syntax trying
to parse Telegram’s API response. Being limited helped me come up with
creative solutions like this, and it worked!