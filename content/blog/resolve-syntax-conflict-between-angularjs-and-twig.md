---
title: Resolve syntax conflict between AngularJS and Twig
kind: article
created_at: '2014-07-18 00:00:00 +0800'
slug: resolve-syntax-conflict-between-angularjs-and-twig
abstract: 'Both AngularJS and Twig use {{curly braces}} to wrap the
variables in HTML templates, here is a few ways to work around the
syntax conflict'
---

AngularJS uses double curly braces (e.g. {{var}}) to wrap the variables in its HTML view while Twig use precisely the same syntax to wrap the variables. Should you use Twig to render a AngularJS app, the HTML view template will simply be messed up.

There are two solutions suggested by the online community:

1. Convert all double curly braces into literal strings

   As suggested by the official documentation of Twig, when rendering literal {{ }} one can 'escape' it like the following.

   `{{ -> {{ '{{' }}` or `{{var}} -> {{ '{{var}}' }}`

   No doubt the AngularJS template will look terrible, but this solution resolves the conflict without tweaking the options of both AngularJS and Twig. 

2. Configure AngularJS to use other braces such as <code>{[{var}]}</code> (or whatever you like) instead.

   In your AngularJS app script, add the following config.

   ~~~ javascript
angular.module('app', []).config(function($interpolateProvider){
  $interpolateProvider.startSymbol('{[{').endSymbol('}]}');
});
   ~~~

   This method breaks less of the syntax in both Twig and AngularJS, so it is strongly suggested.

3. Twig also provide a tag for displaying raw content. Everything inside <code>vertatim</code> block is not parsed by Twig engine.

   ~~~
{% verbatim %}
// everything of your angularJS template
{% endverbatim %}
   ~~~

   This one should be the least obstructive and the easiest to implement.

*edited 2014-07-26*
