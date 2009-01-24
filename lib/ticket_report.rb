class TicketReport
  include UnfuddleClient
  
  def self.find(id)
    new(get("https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/ticket_reports/#{id}/generate")['ticket_report'])
  end
  
  attr_accessor :ticket_groups
  
  def initialize(hsh)
    @ticket_groups = hsh['groups']['group'].map { |g| TicketGroup.new(g) }
  end
end