---
title: 'Communication between C++ and PHP program using socket'
kind: article
created_at: '2018-01-13 00:00:00 +0800'
slug: communication-between-cpp-and-php-program-using-socket
abstract: 'How a C++ application can talk to a PHP application directly
using socket without shard database or interprocess memory sharing'
preview: false
---

## Background

In a recent job, I had to integrate a piece of hardware with my
PHP server. The only library available was written in C and Java, yet
it's unreasonable to port the whole PHP application just because it
lacks the library to communicate with the hardware.

Then I came up with an idea of writting a C++ application to bridge the
hardware and the PHP application. The C++ application can use the
library, no problem, but how could I let my C++ and my PHP applications
communicate?

I chose to use socket because it's straightforward to implement and
reliable enough (for TCP) for my little application that exchanges only
short texts per transaction.

In this short post, I will go over writing a C++ server and a PHP
client that communicate using socket. Demo code can be found on
[tommyku/cpp-php-socket-demo](https://github.com/tommyku/cpp-php-socket-demo).

## C++ Server

Our C++ server is a simple echo server &mdash; it echos back to the
client whatever it receives.

First, we need to include some libraries.

~~~ cpp
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <signal.h>

using namespace std;
~~~

Next I create a signal handler to handle `SIGTERM`, `SIGKILL` and `SIGINT`.
This handler becomes useful when I ran my server as a daemon in the background
because I can clean things up such as removing wthe socket file and flushing the log buffer
here when the application closes. Note I made the socket file descriptor `server`
global so that the signal handler can access it outside of the `main` function.

~~~ cpp
#define SOCKET_FILENAME "/tmp/server.sock"

int server;

void signal_callback_handler(int signum)
{
  // close server
  close(server);
  // remove the socket file
  unlink(SOCKET_FILENAME);
  // signal handled
  exit(0);
}
~~~

Here goes the rest of the application.

~~~ cpp
int main(int argc, char **argv)
{
  struct sockaddr_un server_addr, client_addr;
  socklen_t clientlen = sizeof(client_addr);
  int client, buflen, nread;
  char *buf;

  puts("Hell World");

  // listen to SIGINT, SIGTERM, and SIGKILL
  signal(SIGINT, signal_callback_handler);
  signal(SIGTERM, signal_callback_handler);
  signal(SIGKILL, signal_callback_handler);

  // setup socket address structure
  memset(&server_addr, 0, sizeof(server_addr));
  server_addr.sun_family = AF_UNIX;
  strcpy(server_addr.sun_path, SOCKET_FILENAME);

  // create socket
  server = socket(PF_UNIX, SOCK_STREAM, 0);
  if (!server) {
    perror("socket");
    exit(-1);
  }

  // call bind to associate the socket with our local address and
  // port
  if (bind(server, (const struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
    perror("bind");
    exit(-1);
  }

  // convert the socket to listen for incoming connections
  if (listen(server, 0) < 0) {
    perror("listen");
    exit(-1);
  }

  puts("Listening to connection...");

  // allocate buffer
  buflen = 1024;
  buf = new char[buflen+1];

  // loop to handle all requests
  while (1) {
    unsigned int client = accept(server, (struct sockaddr *)&client_addr, &clientlen);

    // read a request
    memset(buf, 0, buflen);
    nread = recv(client, buf, buflen, 0);

    printf("\nClient says: %s\n\n", buf);

    // echo back to the client
    send(client, buf, nread, 0);

    close(client);
  }

  close(server);

  unlink(SOCKET_FILENAME);

return 0;
}
~~~

At first you create a socket file descriptor with socket domain and type,
which hasn't been bind to anything yet. Then you bind it to a specific address described in
`server_addr`. After that, you put the socket in passive mode which
waits for clients to approach and make connection.

When creating a socket, I had to made a design decision whether to use
UNIX domain or Internet domain when creating my socket.

UNIX domain (using PF_UNIX when creating socket) is a component of
POSIX, so it's internal of the host and does not require (de)encapsulation
of the internet and network layer of TCP/IP. Therefore, it's more
efficient for IPC and more secure as other devices in the LAN cannot tap
into this socket.

On the other hand, Internet domain is just like UNIX domain but the
socket is binded to an address and a port instead of a socket file as in
UNIX domain. It works like UNIX domain socket but other devices in the LAN
can connect to this socket (depending on your firewall setting).

Since the purpose of this socket is purely for interprocess
communication, there is no need to expose the port to outside devices,
so I chose to create my socket in UNIX domain.

In the infinite while loop, the program accepts connection from a
client, and use `recv` to read the content sent by the client. After
doing something with the content received (in this program it does
nothing), `sent` is used to send a reply to the client.

~~~ cpp
  while (1) {
    unsigned int client = accept(server, (struct sockaddr *)&client_addr, &clientlen);
    // rest of the code...
~~~

## PHP Client

The PHP code does pretty much the similar thing. Except that instead of
binding to a socket, it connects to a socket that's already opened by
the C++ program. It will send a message, wait for the first reply while the
C++ program does it's thing, and then terminate.

~~~ php
<?php
error_reporting(E_ALL);

if(!($sock = socket_create(AF_UNIX, SOCK_STREAM, 0)))
{
    $errorcode = socket_last_error();
    $errormsg = socket_strerror($errorcode);

    die("Couldn't create socket: [$errorcode] $errormsg \n");
}

echo "Socket created";

if(!socket_connect($sock , '/tmp/server.sock'))
{
    $errorcode = socket_last_error();
    $errormsg = socket_strerror($errorcode);
    die("Could not connect: [$errorcode] $errormsg \n");
}

echo "Connection established \n";

$message = $argv[1];

if(!socket_send( $sock , $message , strlen($message) , 0))
{
    $errorcode = socket_last_error();
    $errormsg = socket_strerror($errorcode);

    die("Could not send data: [$errorcode] $errormsg \n");
}

echo "Message send successfully \n";

// Now receive reply from server
if(socket_recv( $sock , $buf , 1024, MSG_WAITALL ) === FALSE)
{
    $errorcode = socket_last_error();
    $errormsg = socket_strerror($errorcode);
    die("Could not receive data: [$errorcode] $errormsg \n");
}

echo "Message received \n";

// print the received message
var_dump($buf);

socket_close($sock);
~~~

One thing to note if you're like me who develops the PHP application in
a docker container which has a separate file system from the host is
that you need to mount the directory where your socket file resides in
the host into the docker container. Otherwise, you may scratch your head
like I did when `socket_connect` reports: `socket_connect(): unable to connect [2]: No such file or directory`

## Accepting one connection at a time

As the hardware I was working with prohibits parallelism, only one
request should be handled by it at a time. It was tempting for me to
leave the socket open and push the requests into a queue, but how'd the
C++ program know if one request is still valid without the PHP program
first look at the respond of the last request?

As a result, I simply closed the socket once a connection is established
and something is being sent in. The program handles the requets, send a
response back and then binds to the socket again.

To do so, we define a function `bind_listen_socket` that wraps all the
code needed to create, bind and listen to a socket. This function will
be called when the program starts and after a request has been
processed. This piece of code was originally in `main` but now it's
being moved to a function.

~~~cpp
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <signal.h>

using namespace std;

#define SOCKET_FILENAME "/tmp/server.sock"

int server;

void bind_listen_socket(int &server, sockaddr_un &server_addr)
{
  // create socket
  server = socket(PF_UNIX, SOCK_STREAM, 0);
  if (!server) {
    perror("socket");
    exit(-1);
  }

  // call bind to associate the socket with our local address and
  // port
  if (bind(server, (const struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
    perror("bind");
    exit(-1);
  }

  // convert the socket to listen for incoming connections
  if (listen(server, 0) < 0) {
    perror("listen");
    exit(-1);
  }

  puts("Listening to connection...");

}
~~~

The rest of the program remains similar to the orginal version, however
it calls `bind_listen_socket` whenever it wants to create, bind and
listen to a socket. Moreover, the socket file descriptor is closed and
the socket file removed once there is a request coming in from a client.

~~~cpp
void signal_callback_handler(int signum)
{
  // close server
  close(server);
  // remove the socket file
  unlink(SOCKET_FILENAME);
  // signal handled
  exit(0);
}

int main(int argc, char **argv)
{
  struct sockaddr_un server_addr, client_addr;
  socklen_t clientlen = sizeof(client_addr);
  int client, buflen, nread;
  char *buf;

  puts("Hell World");

  // listen to SIGINT, SIGTERM, and SIGKILL
  signal(SIGINT, signal_callback_handler);
  signal(SIGTERM, signal_callback_handler);
  signal(SIGKILL, signal_callback_handler);

  // setup socket address structure
  memset(&server_addr, 0, sizeof(server_addr));
  server_addr.sun_family = AF_UNIX;
  strcpy(server_addr.sun_path, SOCKET_FILENAME);

  // bind and listen on the socket file
  bind_listen_socket(server, server_addr);

  // allocate buffer
  buflen = 1024;
  buf = new char[buflen+1];

  // loop to handle all requests
  while (1) {
    unsigned int client = accept(server, (struct sockaddr *)&client_addr, &clientlen);

    // got a request, close the socket
    close(server);
    unlink(SOCKET_FILENAME);

    // read a request
    memset(buf, 0, buflen);
    nread = recv(client, buf, buflen, 0);

    printf("\nClient says: %s\n\n", buf);

    // echo back to the client
    send(client, buf, nread, 0);

    close(client);

    sleep(2);

    // re-bind and listen on the socket
    bind_listen_socket(server, server_addr);
  }

  close(server);

  unlink(SOCKET_FILENAME);

  return 0;
}
~~~

During the execution of the `while` loop body and that 2 seconds delay I
added to demonstrate that the socket really does not take any new
connection during the execution. This is illustrated below. When trying
to connect to the socket, the client couldn't open the socket file
during the 2-second period.

~~~bash
/run/app # php client.php Hi
Socket createdConnection established 
Message send successfully 
Message received 
string(2) "Hi"

/run/app # php client.php Hi
Socket created
Warning: socket_connect(): unable to connect [2]: No such file or directory in /run/app/client.php on line 14
Could not connect: [2] No such file or directory 

/run/app # php client.php Hi
Socket createdConnection established 
Message send successfully 
Message received 
string(2) "Hi"
~~~

## Remarks

During the handling of my job and creation of this post,
I learned that socket in UNIX domain is a very fast and effective way to achieve
interprocess communication using different programming languages

The code used as examples here are available at [tommyku/cpp-php-socket-demo](https://github.com/tommyku/cpp-php-socket-demo).
As I was searching for socket programming with PHP and C++, a tutorial from [BinaryTides](http://www.binarytides.com/php-socket-programming-tutorial/)
and [zappala/socket-programming-examples-c](https://github.com/zappala/socket-programming-examples-c) have been very useful.
