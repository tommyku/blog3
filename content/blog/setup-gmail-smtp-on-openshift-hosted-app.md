---
title: Setup Gmail SMTP on Openshift hosted app
kind: article
created_at: '2014-07-26 00:00:00 +0800'
slug: setup-gmail-smtp-on-openshift-hosted-app
---

Sending email on the PasS Openshift may be a bit troublesome because you cannot install sendmail. By default, mail function of php is not installed as well. You will need to connect to external POP/IMAP/SMTP servers to send and receive email on Openshift. In this post I am showing you how I send verificaiton email from Openshift.

It happens that a project I am working on demands to send verification email upon user registration. [At first I tried SendGrid with no avail](https://www.openshift.com/blogs/enabling-transactional-email-on-paas-with-sendgrid) because their terms restrict email types to 

- Trigger based email notifications and alerts
- Purchase confirmations
- Password reminders
- Marketing email newsletters

where verification email is not in the list.

#### The silver lining

For someone like me who do want to send email but does not have a SMTP server, remember Google. For one Gmail account [you can send up to 99 email via Google's SMTP server every day](https://support.google.com/a/answer/166852?hl=en), and you can have as many Gmail account as you want.

Openshift opened [the ports we use to send/receive email](https://www.openshift.com/blogs/outbound-mail-ports-are-now-open-for-business-on-openshift), too!

- SMTP/submission (25, 465, 587)
- IMAP (143, 220, 993)
- POP (109, 110, 995)

Whatever library you use, the protocol is standard, in my project I chose Swift Mailer.

#### Show me the code

~~~ php
<?php

// ...

// make sure you get these SMTP settings right
$transport = Swift_SmtpTransport::newInstance('smtp.gmail.com', 465, "ssl") 
    ->setUsername('yourgmailusername@gmail.com')
    ->setPassword('yourgmailpassword');

$mailer = Swift_Mailer::newInstance($transport);
// the message itself
$message = Swift_Message::newInstance('email subject')
    ->setFrom(array('noreply@example.com' => 'no reply'))
    ->setTo(array('recipient@example.com'))
    ->setBody("email body");

$result = $mailer->send($message);

// ...
~~~

You are not restricted to using only Gmail's server, if you own or have rent a mail server supporting these protocols, it is not hard to set it up to use your own mail server.
