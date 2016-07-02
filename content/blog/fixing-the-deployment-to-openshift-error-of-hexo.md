---
title: Fixing the deployment to Openshift error of Hexo
kind: article
created_at: '2015-01-08 00:00:00 +0800'
slug: fixing-the-deployment-to-openshift-error-of-hexo
---

I have always wanted to bail out of php or at least get to learn something new. When I first looked into Node.js, I want to know what it is capable of, and how it was done. 

The first thing I found was Hexo, a static site generator written in Node.js. It's setup and configuration are smooth and easy until I deploy it to Openshift's DIY cartridge.

~~~ bash
[info] Start deploying: openshift
[error] Error: ENOENT, open '/var/www/html/hexo/diy/testrubyserver.rb'
Error: ENOENT, open '/var/www/html/hexo/diy/testrubyserver.rb'
~~~ 

So this is the first "What the..." moment I have with Hexo. The site isn't going to be deployed because (I assume) the DIY cartridge needs that `testrubyserver.rb` in order to function. 

A skim through the `hexo/lib/plugins/deployer/openshift.js` shows something like:

~~~ javascript
async.series([
  function(next){
    /* this is where it went wrong */
    file.copyFile(blogDir+'/testrubyserver.rb', publicDir); 
    file.rmdir(blogDir, next);
  },
  function(next){
    file.copyDir(publicDir, blogDir, next);
  },
  function(next){
    /* this is where it reports error */
    fs.chmod(blogDir+'/testrubyserver.rb',0777,next);
  },
  function(next){
    var commands = [
      ['add', '-A', baseDir],
      ['add', '-A', blogDir],
      ['commit', '-m', commitMessage(args)],
      ['push', remote, branch, '--force']
    ];

    async.eachSeries(commands, function(item, next){
      run('git', item, function(){
        next();
      });
    }, next);
  }
], callback);
~~~ 

Changing the line 

~~~ javascript
file.copyFile(blogDir+'/testrubyserver.rb', publicDir); 

to

file.copyFile(blogDir+'/testrubyserver.rb', publicDir+'/testrubyserver.rb');
~~~ 

will solve the problem. 

Interestingly when the [issue is still open on Github](https://github.com/hexojs/hexo/issues/870), the author has already went on to rewrite the whole thing. For anyone like me who pulled the older version `Hexo 2.8.3` from npm, you are looking into this page for a fix.
