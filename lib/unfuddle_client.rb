module UnfuddleClient
  def self.included(base)
    base.class_eval {
      include HTTParty
      basic_auth  Sinatra::Application.unfuddle_username, Sinatra::Application.unfuddle_password
      format :xml
    }
  end
end