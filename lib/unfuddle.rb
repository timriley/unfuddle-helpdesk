class Unfuddle
  include HTTParty
  
  basic_auth Sinatra.options.unfuddle_username, Sinatra.options.unfuddle_password

  format :xml

  def self.get_ticket_report(id)
    get("https://#{Sinatra.options.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra.options.unfuddle_project_id}/ticket_reports/#{id}/generate")['ticket_report']
  end
  
  def self.get_ticket(id)
    get("https://#{Sinatra.options.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra.options.unfuddle_project_id}/tickets/by_number/#{id}")['ticket']
  end
end