---
title: The "cat state" of boolean variable
kind: article
created_at: '2017-11-15 00:00:00 +0800'
slug: preview
abstract: 'A probably invalid case of using the boolean variable to determine application
state where enum could have worked better'
preview: false
---

One day when I was implementing a login UI of my app in React, I
thought about a `let login = true` flag.

For a boolean variable in an object-oriented language such as
JavaScript, how many states could it possibly have? Let's count, `true` and `false`,
there gives you two states.

> S &isin; { True, False }

Nope, there is an extra state, `null`, the variable can point to an empty
reference. Of course, in such case we aren't talking about the
variable itself, we are talking about a reference name.
In JavaScript, such reference could also evaluate to `undefined`!

> S &isin; { True, False, null, undefined }

## Why does it matter?

Consider the `login` flag we mentioned, the
following table summarizes all possible values and component it should
render as a result.

| login | Component |
|-------|-----------|
| true  | IndexPage |
| false | LoginPage |
| null  | SplashPage |
| undefined | SplashPage |

Rendering `IndexPage` and `LoginPage` when `login` is true or false
looks straightforward, but `null`? How about `undefined`? One trick I
took is to make use of the non-determinism of the variable, to wit:

> I don't know whether it's true or false, so it's in a "[cat state](https://en.wikipedia.org/wiki/Cat_state)"
> that's neither true nor false.

In other words,

> S &isin; { True, False, Cat }

## Should I use it?

Don't do that. There exists better alternative without additional
complexity, and by using the cat state you make your code harder to understand.

Alternatives such as enum, like a set of constants
encapsulate exactly what this non-deterministic boolean variable is trying
to do. For example:

~~~javascript
// LoginState.js
export DONNO = 1;
export NOT_LOGGEDIN = 1;
export LOGGEDIN = 2;

// app.js
import LoginState from 'LoginState'

let login = LoginState.DONNO;
let renderComponent;

switch (login) {
  case LoginState.NOT_LOGGEDIN:
    renderComponent = LoginPage;
    break;
  case LoginState.LOGGEDIN:
    renderComponent = IndexPage;
    break;
  default:
    renderComponent = SplashPage;
}
~~~

A quick-and-dirty implementation using non-determinism of boolean
variable wouldn't save you much more lines of code than that.

As my professor used to say:

> \[insert programming language\] gives you lots of ropes to hang
> yourself.

In this case, the rope is to make use of a boolean variable's cat state and
relying on it to decide the next action. You can do that of
course, but I have shown above there is a better way to do that.

When we evaluate a boolean variable, string like
`'123'`, or integer `3` could both be evaluated to true, while `null`,
and `undefined` both are evaluated to false. However, you shouldn't rely
on it because it's inconsistent.

Consider the following if-statement:

~~~javascript
if (login === true) {
  // ...logged in
} else {
  // ...cat state 🐱
}
~~~

Our understanding on boolean variable is that it's value could either be
true or false, there is no cat state before OOP, and now with cat state
we are just inviting troubles because to interpret the if-statement
above, we must also consider what that boolean could be &mdash; an
integer, a string, a `null`, or an `undefined`?

If the codebase has never relied on `null` or `undefined` in the first
place for it's logic, then we could even forgo the `=== true` part
(note `1 == true` evaluates to true).

## Verdict

Using the "cat state" of a boolean variable might be a neat
trick  on project where everyone working on the code is aware
of the possible values of that variable might contain. It could be
true, false, and anything else.

A safer bet, would be to use boolean strictly with its true/false
values by using `===` operator, or use TypeScript that comes with static
type-checking.
