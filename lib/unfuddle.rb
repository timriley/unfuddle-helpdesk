class Unfuddle
  include HTTParty
  
  base_uri    "https://#{Sinatra.options.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra.options.unfuddle_project_id}"
  basic_auth  Sinatra.options.unfuddle_username, Sinatra.options.unfuddle_password

  format :xml

  def self.get_ticket_report(id)
    get("/ticket_reports/#{id}/generate")['ticket_report']
  end
  
  def self.get_ticket(id)
    get("/tickets/by_number/#{id}")['ticket']
  end
  
  # HTTParty doesn't like that this request returns a nil body. Let's do it manually for now.
  def self.post_ticket(params)
    http                = Net::HTTP.new("#{Sinatra.options.unfuddle_subdomain}.unfuddle.com", 443)
    http.use_ssl        = true
    http.verify_mode    = OpenSSL::SSL::VERIFY_NONE

    request             = Net::HTTP::Post.new("/api/v1/projects/#{Sinatra.options.unfuddle_project_id}/tickets", {'Content-type' => 'application/xml'})
    request.basic_auth  Sinatra.options.unfuddle_username, Sinatra.options.unfuddle_password
    request.body        = "<ticket><priority>3</priority><summary>#{params[:name]} || #{params[:summary]}</summary><description>#{params[:description]}</description></ticket>"
    
    response            = http.request(request)
    
    response.class == Net::HTTPCreated ? true : false
  end
end