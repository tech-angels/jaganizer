Jaganizer 
=========

Jaganizer is a gem to jaganize your Rails application.
Thanks to jaganizer, you'll be able to add a chat widget using one of your Jagan [http://jagan.io](http://jagan.io) applications.

Installation
------------

Add this line to your application's Gemfile:  

    gem 'jaganizer'

Execute:  

    $ bundle install

And then:  

    $ rake g jaganizer:install

Finally, create `config/jaganizer.yml` based on `config/jaganizer.yml.example`.

Usage
-----
### Chat widget

Require assets by adding `//= require jaganizer` to your application.js and application.css files

Add the chat widget to your layout with:  
    <%= jaganizer_widget("channel_name") %>

(`"channel_name"` is an optional parameters and can be any string including only alphanumeric characters and the following punctuation `_ - = @ , . ;`)

### Customizing user informations

By default, Jaganizer will provide user information thanks to this method:  

    def get_user_infos
      session[:userid] ||= Time.now.to_i
      @user_id = session[:userid]
      @user = {
        :username => "User #{@user_id}",
        :avatar => "http://placekitten.com/30/30",
        :details => "Your details"
      }
      end

As you can see, this is not the better way to know who is chatting.

If you want to customize your user informations, you'll need to extend this method via this controller:

    class ChatroomsController < Jaganizer::Controllers::Chatroom
      def get_user_infos
      end
    end

Your method `get_user_infos` should always set the two variables `@user_id` and `@user` following this simple recommandations:

* `@user_id` should be **unique** and compliant with [W3C specifications](http://www.w3.org/TR/html401/types.html#type-name) about HTML IDs:  
  > ID and NAME tokens must begin with a letter ([A-Za-z]) and may be followed by any number of letters, digits ([0-9]), hyphens ("-"), underscores ("_"), colons (":"), and periods (".").

* `@user` should be a **hash** with the optional keys `:username`, `:avatar`, `:details`.  
We recommend you specify at least the username of the user
  * `:avatar` is the URL of a squared image. Default dimensions are 30px &times; 30px.
