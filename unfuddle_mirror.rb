require 'rubygems'
require 'yaml'
require 'haml'
require 'sinatra'
require 'httparty'

configure do
  require File.join(File.dirname(__FILE__), '/app_config')
end

require File.join(File.dirname(__FILE__), '/lib/unfuddle')

# This method is needed for HTTParty to work properly
# Extracted from http://github.com/wycats/merb-extlib/tree/master/lib/merb-extlib/string.rb
class String
  def snake_case
    return self.downcase if self =~ /^[A-Z]+$/
    self.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
      return $+.downcase
  end
end

helpers do
  # Thanks to http://www.gittr.com/index.php/archive/using-rackutils-in-sinatra-escape_html-h-in-rails/
  include Rack::Utils
  alias_method :h, :escape_html
  
  # Thanks to Tim Lucas for these helpers, taken from http://github.com/toolmantim/toolmantim/tree/master/toolmantim.rb
  def versioned_stylesheet(stylesheet)
    "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra.application.options.views, "stylesheets", "#{stylesheet}.sass")).to_i.to_s
  end
  def versioned_js(js)
    "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra.application.options.public, "javascripts", "#{js}.js")).to_i.to_s
  end
  def partial(name)
    haml(:"_#{name}", :layout => false)
  end
end

get '/' do
  @ticket_report = Unfuddle.get_ticket_report(Sinatra.options.unfuddle_ticket_report_id)
  haml :ticket_report
end

get "/stylesheets/screen.css" do
  content_type 'text/css'
  headers "Expires" => (Time.now + 60*60*24*356*3).httpdate # Cache for 3 years
  sass :"stylesheets/screen"
end

get '/tickets/new' do
  haml :new_ticket
end

post '/tickets' do

end

get '/tickets/:id' do
  @ticket = Unfuddle.get_ticket(params[:id]) || raise(Sinatra::NotFound)
  haml :ticket
end