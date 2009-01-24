class Person < OpenStruct
  include UnfuddleClient
  
  @people = {}
  
  # TODO fix this to memoize the whole object and use this instead of name_by_id below
  def self.find(id)
    new(get("https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/people/#{id}")['person'])
  end
  
  def self.name_by_id(id)
    if id
      @people[id] ||= begin
        find(id).first_name
      rescue Net::HTTPServerException
        'Unknown'
      end
    else
      'No one yet'
    end
  end
  
  def initialize(hsh)
    super(hsh)
  end
end