---
title: Integrating two-step two-factor authentication into Rails 4 project with devise
kind: article
created_at: '2016-07-02 00:00:00 +0800'
slug: integrating-two-step-two-factor-authentication-into-rails-4-project-with-devise
preview: false
---

About a month back at where I worked I was asked to implement a two-step two-factor authentication into our existing Rails 4 project.

### Table of Content

1. [Why is this hard?](#why-is-this-hard)
2. [Compromise](#compromise)
3. [Implementation](#implementation)

### <a name='why-is-this-hard'></a> Why is this hard?

Being _two-factor_ isn't a problem because there are many libraries (aka `gems`) implementing that and are handy enought to be working with [Devise](https://github.com/plataformatec/devise) --- the authentication solution we
were then using.

For example:

- [tinfoil/devise-two-factor](https://github.com/tinfoil/devise-two-factor)
- [AsteriskLabs/devise_google_authenticator](https://github.com/AsteriskLabs/devise_google_authenticator)
- [authy/authy-devise](https://github.com/authy/authy-devise)
- [Houdini/two_factor_authentication](https://github.com/Houdini/two_factor_authentication)

But the _two-step_ part made the two-week sprint rather painful. Fact: none of the aforementioned gems implement two-step two-factor auth; they only handle the two-factor part.

[Issue](https://github.com/tinfoil/devise-two-factor/issues/61) from `tinfoil/devise-two-factor` shows that many others had the same problem.

Devise isn't being helpful either --- it's session controller was designed to login in one step only.

And before you ask, no there isn't an easy way to hack Devise's `SessionsController` into neatly adding another action to make it two-step while keeping all the security goodies and still look legible to my coworkers.

`Lockable` fails to work if you modify `SessionController` just so you can first: verify login username and password; second: verify the two-step auth token because you are supposed to login with username, password and two-factor auth token all at once with the gems above.

You could end up first verifying the username and password but it then fails to lock the account with multiple attempts to get pass the first step, because the second step is the _real_ Devise login. See my point?

For those trying to brute force you with a dictionary, they know they're done when they see the two-step auth token prompt. I did check `Lockable` module, you can't invoke it from controller.

Of course nobody wants to hack Devise, either. (because that means one has to maintain it)

### <a name='compromise'></a> Compromise

We ended up with a compromise after long frustration. Let's not verify the password at the first step. We shall send users their two-factor auth token whenever they've keyed in the right username.

SMS will then be sent and users be prompted to input their password and two-step auth token. Pretty _lockable_ that way, and it's still two-step from the look of it.

Code samples down below if you're interested in our implementation, else you're good to go.

### <a name='implementation'></a> Implementation

The following implementation is available on [tommyku/blog3_lab-two_step](https://github.com/tommyku/blog3_lab-two_step). Major steps are committed and you can find the
commit id conveniently labelled.

My confession: the code is in Rails 5. I only noticed it after the majority of it has been done. It should work fine on Rails 4.2 as I did it the exact same way as the original
implementation.

You may want to [skip to the best part](#making-it-two-step) because most of these are just simple Rails + Devise setup.

#### Setup

~~~ bash
$ rails -v
Rails 5.0.0
$ rails new two-step
$ cd two-step
$ rails db:migrate
$ rake db:setup
~~~

By default this rails project use sqlite database. Pretty care-free for a simple tutorial like this.

> You've reached commit `81f2cc7` at this point.

#### Installing Devise and configure a simple login system

Add this line to to `Gemfile`.

~~~ ruby
gem 'devise'
~~~

Then we will simply set it up.

~~~ bash
$ bundle install
$ rails generate devise:install
~~~

Follow the Devise installation instructions.

~~~
===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

===============================================================================
~~~

You're told to add a controller action `home#index` yet there isn't a `HomeController` yet.

~~~ ruby
# app/controllers/home_controller.rb

class HomeController < ApplicationController
  protect_from_forgery with: :exception

  def index
  end
end
~~~

~~~ erb
<%# app/views/home/index.html.erb %>

Yeah you're at home.
~~~

Start the server and navigate to [http://localhost:3000/](http://localhost:3000/).

~~~ bash
$ rails server
~~~

You should see "yeah you're at home"

> You've reached commit `c35f801` at this point.

Now let's make a simple login feature.

~~~ bash
$ rails generate devise User
$ rake db:migrate
~~~

Add this line to home controller because we wanna authenticate the user.

~~~ ruby
# app/controllers/home_controller.rb

class HomeController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def index
  end
end
~~~

Add two seeds for use to test later.

~~~ ruby
# db/seeds.rb

User.create! email: 'test@example.com', password: '1'*8
User.create! email: 'text@example.com', password: '1'*8
~~~

Then seed it.

~~~ bash
$ rake db:seed
~~~

You should now restart the server and try to login. Both user accounts should work fine.

> You've reached commit `f4214fc` at this point.

Let's just add the logout button.

~~~ erb
<%# app/views/home/index.html.erb %>

Yeah you're at home.
<% if user_signed_in? %>
  <%= link_to('Logout', destroy_user_session_path, method: :delete) %>
<% else %>
  <%= link_to('Login', new_user_session_path)  %>
<% end %>
~~~

Now refresh and you should see a working logout button.

> You've reached commit `95dff89` at this point.

#### Integrating two-factor authentication

We chose [tinfoil/devise-two-factor](https://github.com/tinfoil/devise-two-factor) as I work out-of-the-box but any other devise two-factor auth gem should work similarily in the
next part. You may need to tweak the function calls a bit but the flow should be the same.

Now just add the gem.

~~~ ruby
gem 'devise-two-factor'
~~~

~~~ bash
$ bundle install
$ rails generate devise_two_factor User ENCRPYTION_KEY
~~~

In your `User` model:

Extend from `ActiveRecord::Base` instead of `ApplicationRecord` on Rails 4.

~~~ ruby
# app/models/user.rb

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :two_factor_authenticatable,
         otp_secret_encryption_key: 'any_random_string_or_rails_secret'
  devise :registerable, :recoverable, 
         :rememberable, :trackable, :validatable
end
~~~

The random string that goes into `otp_secret_encryption_key` should be stored in your `ENV` (as advised by the gem README) and generating `rails secret` may come in handy when you
want something secure.

And in `application_controller.rb`, as perscribed.

~~~ ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end
end
~~~

~~~ bash
$ rake db:migrate
~~~

There are 2 users in database but two-factor authentication should be activated individually per account. In this case we will only do it to `test@example.com` and leave
`text@example.com` as is.

Of course in production environment you might want to do it through an user setting page or something.

~~~ bash
$ rails console
> u = User.find_by(email: 'test@example.com')
> u.otp_required_for_login = true
> u.otp_secret = User.generate_otp_secret
> u.save!
~~~

When you try to login. You will see that you can't because of 2 reasons: 1) you haven't added a field for one-time password and 2) you don't know the one-time password to fill in.

~~~ erb
<%# app/views/devise/sessions/new.html.erb %>

<h2>Log in</h2>

<%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
  <div class="field">
    <%= f.label :email %><br />
    <%= f.email_field :email, autofocus: true %>
  </div>

  <div class="field">
    <%= f.label :password %><br />
    <%= f.password_field :password, autocomplete: "off" %>
  </div>

  <div class="field">
    <%= f.label :otp_attempt %><br />
    <%= f.text_field :otp_attempt, autocomplete: "off" %>
  </div>

  <% if devise_mapping.rememberable? -%>
    <div class="field">
      <%= f.check_box :remember_me %>
      <%= f.label :remember_me %>
    </div>
  <% end -%>

  <div class="actions">
    <%= f.submit "Log in" %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
~~~

The OTP of `test@example.com` can be obtained from the rails console the next time you login. You're good to go if can get pass the login page.

~~~ ruby
> u.current_otp
~~~

> You've reached commit `3ebfcfe` at this point.

#### <a id='making-it-two-step'></a>  Making it two-step

Finally we are at the meat of this article. All work done so far just try to emulate an existing Rails application you're running on. Check out to `3ebfcfe` of the code sample if
you have skipped all those.

General idea:

1. use SJR to see if username is correct
2. display one-time password input box if the user has two-factor auth enabled, else just display a simple password box

~~~ bash
$ rails generate devise:controllers users
~~~

To do this, we need to add an additional action `pre_otp` to Devise's session controller.

~~~ ruby
# config/routes.rb

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  devise_scope :user do
    scope :users, as: :users do
      post 'pre_otp', to: 'users/sessions#pre_otp'
    end
  end
end
~~~

In this configuration when user sign in `Users::SessionsController` will be invoked instead of the default `Devise::SessionsController`.

~~~ ruby
# app/controllers/user/sessions_controller.rb

class Users::SessionsController < Devise::SessionsController
  def pre_otp
    user = User.find_by pre_otp_params
    @otp_ok = user && user.otp_required_for_login
    respond_to do |format|
      format.js {
        @otp = user.current_otp if @otp_ok
      }
    end
  end

  private

  def pre_otp_params
    params.require(:user).permit(:email)
  end
end
~~~

A new action `pre_otp` is defined in addition to the defaul `Devise::SessionsController` actions. It is responsible for checking whether an user email has two-factor auth enabled.
Result of the test is indicated by an instance variable `@otp_ok`.

We use `respond_to` which only respond with Javascript because we want to do AJAX but was too lazy. [Server-generated Javascript response (SJR)](https://signalvnoise.com/posts/3697-server-generated-javascript-responses) can be used to implement AJAX conveniently.

We are going to split the login form into 2 steps. In the view of `sessions#new` there are two forms `step-1` and `step-2` respectively.

Note that `step-1` has an option `remote: true`. With this flag we tell the Rails application to send an AJAX request instead of form post when we click submit.

`step-2` is hidden for the moment.

~~~ erb
<%# app/views/users/sessions/new.html.erb %>

<h2>Log in</h2>

<%= form_for(resource, as: resource_name, url: users_pre_otp_path, method: :post, remote: true, html: {id: 'step-1'}) do |f| %>
  <div class="field">
    <%= f.label :email %><br />
    <%= f.email_field :email, autofocus: true %>
  </div>

  <div class="actions">
    <%= f.submit "next" %>
  </div>
<% end %>

<%= form_for(resource, as: resource_name, url: session_path(resource_name), html: {class: 'hidden', id: 'step-2'}) do |f| %>
  <div class="field">
    <%= f.label :email %><br />
    <%= f.email_field :email, autofocus: true %>
  </div>

  <div class="field">
    <%= f.label :password %><br />
    <%= f.password_field :password, autocomplete: "off" %>
  </div>

  <div id="step-2-otp" class="field hidden">
    <%= f.label :otp_attempt %><br />
    <%= f.text_field :otp_attempt, autocomplete: "off" %>
  </div>

  <% if devise_mapping.rememberable? -%>
    <div class="field">
      <%= f.check_box :remember_me %>
      <%= f.label :remember_me %>
    </div>
  <% end -%>

  <div class="actions">
    <%= f.submit "Log in" %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
~~~

~~~ scss
/* app/assets/stylesheets/application.css */
/*
 *= require_tree .
 *= require_self
 */

.hidden {
  display: none;
}
~~~

Now we have the form all set, we need a Javascript file to run the logic after step 1. We do this by adding the view of `sessions#pre_otp`.

~~~ erb
<%# app/views/users/sessions/pre_otp.js.erb %>

var stepOne = $('#step-1');
stepOne.addClass('hidden');
var email = stepOne.find('#user_email').val();
var stepTwo = $('#step-2');
stepTwo.removeClass('hidden');
stepTwo.find('#user_email').val(email);
stepTwo.find('#user_password').focus();
if (<%= @otp_ok === true %>) {
  console.debug(<%= @otp %>);
  $('#step-2-otp').removeClass('hidden');
}
~~~

For our convenience we print out the current otp of the logging in user so we don't have to use the console. In production application of course this should be removed and users
should be able to receive their one-time password via SMS sent inside `sessions#pre_otp`.

We're done here. Try restarting the server (so new files are loaded) then try to login as `test@example.com` and `text@example.com` respectively. You should see `Otp attmpt` input
box when logging in `test@example.com` but not for `text@example.com`.

> You've reached commit `3a2ebbf` at this point.
