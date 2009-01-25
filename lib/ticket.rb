class Ticket < OpenStruct
  include UnfuddleClient
  
  def self.find(id)
    new(get("https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/tickets/by_number/#{id}")['ticket'])
  end
  
  # HTTParty doesn't like that this request returns a nil body. Let's do it manually for now.
  def self.post_ticket(params)
    http                = Net::HTTP.new("#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com", 443)
    http.use_ssl        = true
    http.verify_mode    = OpenSSL::SSL::VERIFY_NONE

    request             = Net::HTTP::Post.new("/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/tickets", {'Content-type' => 'application/xml'})
    request.basic_auth  Sinatra::Application.unfuddle_username, Sinatra::Application.unfuddle_password
    request.body        = "<ticket><priority>3</priority><summary>#{params[:name]}#{Ticket.delimiter}#{params[:summary]}</summary><description>#{params[:description]}</description></ticket>"
    
    response            = http.request(request)
    
    response.class == Net::HTTPCreated ? true : false
  end
  
  def self.delimiter
    ' --reported--> '
  end
  
  def initialize(hsh)
    super(hsh)
  end
    
  def assigned?
    !!self.assignee_id
  end
  
  def assignee_name
    Person.name_by_id(self.assignee_id)
  end
  
  def reporter_name
    self.summary.match(Ticket.delimiter) ? self.summary.split(Ticket.delimiter).first : 'Unknown'
  end
  
  def ticket_summary
    self.summary.match(Ticket.delimiter) ? self.summary.split(Ticket.delimiter).last : self.summary
  end
  
  # When loading a generated ticket report: <created-at type="datetime">2008-05-23T07:48:38+00:00</created-at>
  # When loading a ticket on its own:       <created-at>2008-05-23T17:48:38+10:00</created-at>
  # Ugh.
  [:created_at, :updated_at].each do |time|
    define_method :"ticket_#{time}" do
      if self.send(time).kind_of?(String)
        Time.parse(self.send(time))
      else
        self.send(time)
      end
    end
  end
end