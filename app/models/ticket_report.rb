class TicketReport < ActiveResource::Base
  
  self.site = "https://#{APP_CONFIG['unfuddle_username']}:#{APP_CONFIG['unfuddle_password']}@#{APP_CONFIG['unfuddle_subdomain']}.unfuddle.com/api/v1/projects/#{APP_CONFIG['unfuddle_project_id']}/"  
  
end
