class Person < OpenStruct
  include UnfuddleClient
  
  def self.find(id)
    people[id] ||= new(get("https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/people/#{id}")['person'])
  end
  
  def initialize(hsh)
    super(hsh)
  end
  
  private
  
  def self.people
    @people ||= {}
  end
end