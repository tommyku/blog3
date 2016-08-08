---
title: My friend got hacked (by me)
kind: article
created_at: '2014-01-27 00:00:00 +0800'
slug: my-friend-got-hacked-by-me-
---

## Background

Paying one month-worth of deligence, my friend got his first online service [Evaplus](http://keansh.com/evaplus/) onlne (looks like it's offline as of Aug 2016). He initially started with Mongodb and node.js but end up using PHP and MySQL. Fair, as PHP is easier for a newbie. 

Despite, eventually, it went terribly wrong.

## The hacking bit

Evaplus collects the course evaluation results submitted by students in past years and present them in a fancier way. The client side webpage send a POST request to server by AJAX, then the server throws back any data needed.

AJAX, getting resource from server without refreshing the page. The evil lies not on AJAX but what were passed with AJAX. When user makes a query via his interface, the following data were sent to a PHP script via HTTP POST.

~~~ sql
yr[]: 2013
sem[]: s
school[]: engineering
order: DESC
type: course
limit: 10
catalog: `course` REGEXP ' ([1-4]|[A-Z])'
~~~

Doesn’t it look familiar? Remember he used MySQL database and PHP, I will show you the relationship very soon.

Server returns some good stuff such as the desired data and a line of SQL query string.

~~~ javascript
{
  sql: “SELECT * FROM `engineering` WHERE (`yr`=2013) AND (`sem`='f') AND (`instructor`=’’) AND (`lecture`=’’ AND `ecourse` REGEXP ' ([1-4]|[A-Z])' ORDER BY `mean` DESC, `sd` ASC, `respRate` DESC LIMIT 0,20; ”,
  data: “...”
}
~~~

The developer was out of his mind. Who would include the SQL string in the reply for no reason? The client should be decoupled from the server structure. Best case scenario the client side don’t even know what server side script / database was being used.

I reached the developer, and told him about that. Before he tried to understand what I was talking about, one of the tables got deleted. Totally shocked, he asked "how was it even possible?"

**SQL injection**

Look at the POST request again, it is not difficult to guess how the SQL query string was constructed. To put it simply, the developer only concatenate whatever was passed. Thus exploiting this property, additional SQL can be injected into the query string. The attacker will then have *almost* full control to the database.

Only that was not enough. Without knowledge concerning the internal structure of the table, it is hard to guess what the structure of the database is. In particular, the name of the table I want to modify and the structure of the record.

Luckily, the developer had everything printed in the SQL statement, making the database under the mercy of attackers.

I won’t reveal the details of the attacks because the above materials are enough for you to plan an attack. Eventually, I inserted records, deleted records, updated records, truncated table and deleted table under the developer’s consent.

## Suggestions

Evaplus is a well thought service to integrate the course evaluation results across over 10 years into a single place. Interface looks practical and responsive with bootstrap framework. 

However, the aforementioned flaw should be fixed to prevent further attack which may used to forge records and even take down the service.

Here are some suggestions to improve security and performance of Evaplus.

####Use flat file database####

Considering the data stored are totally static, SQL database is unnecessary and insecure. The developer can put the records into files and filter the records with little complication. This avoids any sort of SQL injection attack.

####Go restful####

In addition, static data are even better fit with restful structure in which resources are available given the URIs. This would simplify the system and allow for decoupling the front end and back end. [more about RESTful](http://www.restapitutorial.com/)

####Return only data####

Currenly the server returns rendered data, which means data are wrapped inside HTML representations when returned. By returning data in say, XML or JSON format, then package them into HTML in client side instead, it saves bandwidth and server load.
