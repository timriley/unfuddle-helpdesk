# This method is needed for HTTParty to work properly
# Extracted from http://github.com/wycats/merb-extlib/tree/master/lib/merb-extlib/string.rb
class String
  def snake_case
    return self.downcase if self =~ /^[A-Z]+$/
    self.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
      return $+.downcase
  end
end

module UnfuddleClient
  def self.included(base)
    base.class_eval {
      include HTTParty
      basic_auth  Sinatra::Application.unfuddle_username, Sinatra::Application.unfuddle_password
      format :xml
    }
  end
end