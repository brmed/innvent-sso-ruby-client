# SsoClient

A rubygem that wraps a client for the InnventSSOServer gem

## Installation

Add this line to your application's Gemfile:

    gem 'sso_client', git: "git@github.com:innvent/InnventSSOServer.git"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sso_client

## Usage

- Run ```$ rake sso_client:install```
- Add ```include SsoClient::ControllerHelpers``` on your ```ApplicationController```.
- Add ```before_action :authenticate_user!``` on the controllers you wish to require authentication through the Sso Server.
- Create the login and logout routes to point to SsoClient routes
```ruby
  #You'll need a GET route to sso/logins#create and sso/logins#destroy
  get :destroy, controller: 'sso/logins', as: :logout, path: 'sso/logout'
  get :create, controller: 'sso/logins', as: :login, path: 'sso/login'
```
- Implement the following methods:
```ruby
  class ApplicationController
    protected
    def after_logged_in(user)
      # Custom actions with user
      # Redirects after login
    end

    def on_logged_out_path
      # Return a valid fullpath to where user will be redirected when
      # logged out of the system
      # ex: root_path(only_path: false)
    end
  end
```
- Run the SSO Server
- Change the file ```sso_client.yaml``` in ```APPROOT/config/``` to point to the sso server instance

If you want to add before_filter/before_action methods on your ApplicationController, add the following line on your application.rb file:
```ruby
  class Application < Rails::Application
    config.to_prepare do
      Sso::LoginsController.skip_before_filter :my_filter_name
    end
  end
```
