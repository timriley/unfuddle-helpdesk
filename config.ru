ENV['TZ'] = 'Australia/Sydney'

require 'rubygems'
gem 'sinatra', '~> 0.3'
require 'sinatra'

set :run      => false,
    :env      => :production,
    :root     => File.dirname(__FILE__),
    :views    => File.dirname(__FILE__) + "/views",
    :public   => File.dirname(__FILE__) + "/public",
    :app_file => "unfuddle-mirror.rb"

require File.join(File.dirname(__FILE__), "unfuddle-mirror.rb")

run Sinatra.application