---
title: Setup Gmail SMTP on Openshift hosted Laravel app
kind: article
created_at: '2015-01-03 00:00:00 +0800'
slug: setup-gmail-smtp-on-openshift-hosted-laravel-app
---

**edit**: This guide was written for Laravel 4.2. If you are using Laravel 5.0, similar settings are done separately in your environment configuration file `.env`, or in `config/mail.php` directly

This guide simply talk about the setup to send email in Laravel on Openshift similar as [a previous post](http://blog.tommyku.com/blog/setup-gmail-smtp-on-openshift-hosted-app).

It has been a while after my previous post because I have been struggling to get 2 projects online before the end of 2014. As a student I feel freelance projects overwhelming but extremely rewarding forcing myself to learn and create product valued by my clients. 

Talk less and do more, see the settings!

#### Show me the code

Laravel have the process streamlined, all you need to do to configure it, then you can send email using the `Mail` class. Below is the only configuration file you need to mess with.

~~~  php
<?php
/* app/config/mail.php */
return array(
	'driver' => 'smtp',
	'host' => 'smtp.gmail.com',
	'port' => 587,
	'from' => array('address' => "{your email address}", 'name' => "{your name}"),
	'encryption' => 'tls',
	'username' => "{your email address}",
	'password' => "{your gmail password}",
	'sendmail' => '/usr/sbin/sendmail -bs',
	'pretend' => false,
);
~~~ 

`Mail` class provides an extensive interface for sending emails. To send an email you can do something like:

~~~  php
/* freshly copied from laravel.com */
Mail::send('emails.welcome', $data, function($message)
{
  $message->from('us@example.com', 'Laravel');

  $message->to('foo@example.com')->cc('bar@example.com');

  $message->attach($pathToFile);
});
~~~ 

The same could be done for other SMTP services you currently use. You are done here if you are not using Gmail, and please continue to read the next section if you do use Gmail.

#### Working with Gmail (Important)

You may have noticed that even with the settings right, it is still not working. On this STMP matter Google has introduced a security policy "[Less Secure Apps](https://support.google.com/accounts/answer/6010255)". 

If the first email sent via Laravel is not reaching its destination, logon to [Gmail](gmail.com) and you are probably seeing a email like this:

<div style="text-align: center;">
<img src="./gmail.png" title="Email [Google Account: sign-in attempt blocked]" />
<br />
<small><em>Img.</em> <strong>Good job, Google</strong></small>
</div>

and inside it says

<div style="text-align: center;">
<img src="./lesssecureapp.png" title="Email [Google Account: sign-in attempt blocked]" />
<br />
<small><em>Img.</em> <strong>Google doesn't trust your app</strong></small>
</div>

Google is not confident in your Laravel app but clearly you are. What you need to do is to [follow that link](https://www.google.com/settings/security/lesssecureapps) and allow for Google sign in with "less secure apps".

#### References

<small>
1. [Laravel - The PHP Framework For Web Artisans. (Mail)](http://laravel.com/docs/4.2/mail)
2. [Accessing Gmail in Your Email Program or Mobile Device - About Email](http://email.about.com/od/accessinggmail/f/Gmail_SMTP_Settings.html)
</small>
