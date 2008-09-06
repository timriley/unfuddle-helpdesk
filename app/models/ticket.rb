class Ticket < ActiveResource::Base
  
  self.site = "https://#{APP_CONFIG['unfuddle_username']}:#{APP_CONFIG['unfuddle_password']}@#{APP_CONFIG['unfuddle_subdomain']}.unfuddle.com/api/v1/projects/#{APP_CONFIG['unfuddle_project_id']}/"
  
  def self.find_by_number(number)
    find(:one, :from => "/projects/#{APP_CONFIG['unfuddle_project_id']}/tickets/by_number/#{number}.xml")
  end
  
  # We use the ticket number (not the ID) in the URL, since the number is more meaningful.
  def to_param
    number
  end
  
  def comments
    @comments ||= Comment.find(:all, :params => { :ticket_id => id })
  end
  
end
