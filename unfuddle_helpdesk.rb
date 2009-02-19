require 'rubygems'

gem 'sinatra', '~> 0.9'
require 'sinatra'

gem 'haml', '~> 2.1'
require 'haml'

gem 'chriseppstein-compass', '~> 0.4'
require 'compass'

# Require my fork of httparty until my fix for empty XML bodies is pulled upstream
gem 'timriley-httparty'
require 'httparty'

require 'yaml'
require 'ostruct'
require 'net/http'

configure do
  require File.join(File.dirname(__FILE__), 'app_config')
  enable :sessions
  
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir     = File.join('views', 'stylesheets')
  end
end

%w( core_extensions unfuddle_client person ticket_report ticket_group ticket comment ).each do |lib|
  require File.join(File.dirname(__FILE__), 'lib', lib)
end

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
  def clear_cookie(name)
    response.set_cookie(name, nil)
  end
  def cycle
    %w{odd even}[@_cycle = ((@_cycle || -1) + 1) % 2]
  end
  def reset_cycle
    @_cycle = 1
  end
  def convert_breaks(str)
    str.gsub("\n", "<br/>")
  end
  def relative_date(date)
    date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
    days = (date - Date.today).to_i

    return 'Today'     if days >= 0 and days < 1
    return 'Tomorrow'  if days >= 1 and days < 2
    return 'Yesterday' if days >= -1 and days < 0

    return "In #{days} days"      if days.abs < 60 and days > 0
    return "#{days.abs} days ago" if days.abs < 60 and days < 0

    return date.strftime('%B %e') if days.abs < 182
    return date.strftime('%B %e, %Y')
  end
end

before do
  clear_cookie('notice')
end

get '/' do
  @ticket_report = TicketReport.find(Sinatra::Application.unfuddle_ticket_report_id)
  haml :ticket_report
end

%w( screen ie print ).each do |stylesheet|
  get "/stylesheets/#{stylesheet}.css" do
    content_type 'text/css'
    response['Expires'] = (Time.now + 60*60*24*356*3).httpdate # Cache for 3 years
    sass :"stylesheets/#{stylesheet}", :sass => Compass.sass_engine_options
  end
end

get '/tickets/new' do
  haml :new_ticket
end

post '/tickets' do
  response.set_cookie('name', params[:name])
  response.set_cookie('component_id', params[:component_id])

  response.set_cookie('notice', Ticket.create(params).created? ? 'ticket_success' : 'ticket_error')
  redirect '/'
end

get '/tickets/:id' do
  @ticket = Ticket.find(params[:id]) || raise(Sinatra::NotFound)
  haml :ticket
end