ENV['TZ'] = 'Australia/Canberra'

require 'rubygems'

gem 'sinatra', '~> 0.9'
require 'sinatra'

set :run      => false,
    :environment => :production,
    :root     => File.dirname(__FILE__),
    :views    => File.dirname(__FILE__) + "/views",
    :public   => File.dirname(__FILE__) + "/public",
    :app_file => "app.rb"

require File.join(File.dirname(__FILE__), "app.rb")

run Sinatra::Application
