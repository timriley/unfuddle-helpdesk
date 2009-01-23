require 'rubygems'

gem 'sinatra', '~> 0.9'
require 'sinatra'

gem 'haml', '~> 2.1'
require 'haml'

require 'yaml'
require 'httparty'
require 'net/http'
require 'compass'

configure do
  require File.join(File.dirname(__FILE__), 'app_config')
  enable :sessions
end

require File.join(File.dirname(__FILE__), 'lib', 'unfuddle')

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def versioned_stylesheet(stylesheet)
    "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra::Application.views, "stylesheets", "#{stylesheet}.sass")).to_i.to_s
  end
  def versioned_js(js)
    "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
  end
  def partial(name, options = {})
    haml(:"_#{name}", options.merge!(:layout => false))
  end
  
  def cycle
    @_cycle ||= reset_cycle
    @_cycle = [@_cycle.pop] + @_cycle
    @_cycle.first
  end
  def reset_cycle
    @_cycle = %w(even odd)
  end
  
  def convert_breaks(str)
    str.gsub("\n", "<br/>")
  end
end

get '/' do
  @ticket_report = Unfuddle.get_ticket_report(Sinatra::Application.unfuddle_ticket_report_id)
  haml :ticket_report
end

%w( screen ie print ).each do |stylesheet|
  get "/stylesheets/#{stylesheet}.css" do
    content_type 'text/css'
    headers 'Expires' => (Time.now + 60*60*24*356*3).httpdate # Cache for 3 years
    sass :"stylesheets/#{stylesheet}", { :sass => { :load_paths => ([ File.join(File.dirname(__FILE__), 'views', 'stylesheets') ] + Compass::Frameworks::ALL.map { |f| f.stylesheets_directory }) } }
  end
end

get '/tickets/new' do
  haml :new_ticket
end

post '/tickets' do
  success = Unfuddle.post_ticket(params)
  
  set_cookie('notice', success ? 'ticket_successful' : 'ticket_failed')
  redirect '/'
end

get '/tickets/:id' do
  @ticket = Unfuddle.get_ticket(params[:id]) || raise(Sinatra::NotFound)
  haml :ticket
end