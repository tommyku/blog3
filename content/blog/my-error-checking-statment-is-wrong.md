---
title: My error checking statment is wrong
kind: article
created_at: '2014-07-23 00:00:00 +0800'
slug: my-error-checking-statment-is-wrong
---

Spent an hour tracking down a bug in updating MySQL row, turned out it has nothing to do with my database library (yes looked into the Medoo library) but my error checking statement.

My code looks like this.

~~~ php
$row_affected = $database->update(//...bleh bleh bleh)
if ($row_affected != 1) {
  // http_internal_server_error
}
~~~

What it should look like.

~~~ php
$row_affected = $database->update(//...bleh bleh bleh)
if ($row_affected != 0 && $row_affected != 1) {
  // http_internal_server_error
}
~~~

What is wrong with my error checking statement? MySQL is so clever that when an UPDATE is trying to update absolutely the same things to the columns, it will not write anything to the database. Then <code>$row_affected</code> will be zero and it throws an error.

> If you set a column to the value it currently has, MySQL notices this and does not update it. 
> Source: [MySQL :: MySQL 5.1 Reference Manual :: 13.2.10 UPDATE Syntax](http://dev.mysql.com/doc/refman/5.1/en/update.html)

However, the best fix should be:

~~~ php
$row_affected = $database->update(//...bleh bleh bleh)
if ($database->error()[1] != 0) {
  // http_internal_server_error
}
~~~

This error checking statement detects errors in general, with error message available for programmer to debug. I would not have spent an hour fixing that if I had done this in the first time.
