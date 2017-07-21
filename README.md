# Molecule
This gem adds a frontend layer to Rails which you can write all your html and javascript with ruby.
Also molecule can render (react like) components and when doing this it uses  virtual-dom (thanks to inesita gem).
It can communicate with backend by websockets automatically. It can use inesita routers for routing purposes.

## Usage

#### Routing
```ruby
# app/components/layout.rb
class Layout
  include Molecule::Component

  def render
    div do
      component props[:child]
    end
  end
end
```
```ruby
# app/components/home.rb
class Home
  include Molecule::Component

  def render
    div do
      h1 'Hello From Molecule'
    end
  end
end
```
```ruby
# app/components/router.rb
class Router
  include Molecule::Router

  def routes
    route '/', to: Layout, props: { child: Home }
    # route '/another-route', to: Layouts, props: { child: AnotherComponent }
  end
end
```
```ruby
# app/config/routes.rb
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # root 'site#index'

  # Mount for websocket support
  mount Molecule::Engine, at: '/molecule'
  # This is for single page application and server side rendering support
  # make sure that this line must be end of the file
  get '/(*others)', to: 'molecule#spa'
end
```

Molecule use its own action for spa renders, this action ('molecule#spa') can handle search engines and
return them server side rendered data and disable javascripts. But when the normal user comes in javascript 
rendered site will be seen. See: `app/controllers/molecule_controller.rb` in gem.

#### Rendering



Molecule can render components inside other components. See: https://inesita.fazibear.me/ for details
```ruby
# app/components/home.rb
class Home
  include Molecule::Component

  def render
    div do
      component Header, props: { title: 'My Page' }
      div 'This is home body'
    end
  end
end
````
```ruby
# app/components/header.rb
class Header
  include Molecule::Component

  def render
    div do
      div.title { 'The title is: ' + props[:title] }
    end
  end
end
````
also we can capsulate components into methods like this
```ruby
# app/components/home.rb
class Home
  include Molecule::Component
  
  component :my_header_method, Long::Namespaced::Header

  def render
    div do
      # convert this
      # component Long::Namespaced::Header, props: { title: 'My Page' }
      # into this
      my_header_method(title: 'My Page')
      div 'This is home body'
    end
  end
end
````
this gives you freedom for making reusable packed components
```ruby
# app/components/form_package.rb
module FormPackage
  include Molecule::Component

  component :text_field, Form::Textfield
  component :password_field, Form::Passwordfield
  component :checkbox, Form::Checkbox
  # ...
end
``` 
```ruby
# app/components/home.rb
class Home
  include Molecule::Component
  include FormPackage

  def render
    div do
      text_field(label: 'Label', name:'name')
      checkbox(label: 'Label', name:'name', checked: true)
      # ...
    end
  end
end
```

#### Communication with backend
Molecule components can communicate with backend through a web socket pipe which will be initialized when 
molecule loads the page. These pipe sends data to a backend interaction which is provided by ActiveInteraction gem
executes it and capture its result from client.
For using websocket and session handler, you must need to install **redis** to server.
```ruby
# app/components/home.rb
class Home
  include Molecule::Component
  
  # this defines the backend EchoUser interaction
  # also defines user_data method to bind results
  # for namespaced classes use '/' etc; 'UserInteractions/EchoUser'
  interaction :user_data, 'EchoUser'

  # init runs before the render only one time!
  init do
    # run the interaction with given parameters, bind result to user_data and rerender component
    user_data!(username: 'user')
  end

  def render
    div do
      component Header, props: { title: 'My Page' }
      if user_data
        div 'Hello' + user_data[:username]
      else
        div 'data placeholder'  
      end
      
    end
  end
end
````
```ruby
# app/interactions/echo_user.rb
class EchoUser < ActiveInteraction::Base
  string :username
  # Molecule has an internal session handler
  object :session, class: Molecule::Session
  
  def execute
    # session set and get method usage
    # session.set(:user, username)
    # session.get(:user)
    
    # returns data to component
    { username: username }
  end
end
```
you can access interaction result and error with `user_data?[:success]` and `user_data?[:errors]` inside component.

see; http://devblog.orgsync.com/active_interaction/ for details

### Extra
Molecule has support for serializing forms. It can give you form data as hash, so you can send it to interaction easily.
```ruby
module Users
  # User creation form
  class Create
    include Molecule::Component
    include FormPackage

    interaction :user_data, 'Users/CreateUser'

    def submit
      data = Element['#create_user'].serialize_hash
      user_data! data
    end

    def render
      div.users_create!.container do
        if user_data
          h2 { "Hello #{user_data[:username]}" }
        end
        hr
        h3 'Create New User'
        br
        br
        form.create_user! do
          text_field(label: 'Username', name: 'username')
          text_field(label: 'Password', name: 'password')
          input.btn.btn_default(type: 'Button', value: 'Gönder',
                                onclick: method(:submit))
        end
      end
    end
  end
end
``` 

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'molecule', :git => 'http://github.com:codem4ster/molecule.git'
```

And then execute:
```bash
$ bundle install
```
note that this gem is under heavy development yet 


Or install it yourself as:
Not added to rubygems yet

## Contributing
fork, change, request pull

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
