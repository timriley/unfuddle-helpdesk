class Ticket < OpenStruct
  include UnfuddleClient
  
  def self.find(id)
    new(get("https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/tickets/by_number/#{id}")['ticket'])
  end
  
  def self.create(attrs)
    attrs = prepare_attributes(attrs)
    
    post( "https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/tickets",
          :body => "
            <ticket>
              <priority>3</priority>
              <component-id>#{attrs[:component_id]}</component-id>
              <summary>#{attrs[:name]}#{delimiter}#{attrs[:summary]}</summary>
              <description>#{attrs[:description]}</description>
            </ticket>",
          :headers => {'Content-type' => 'application/xml'})
  end
  
  def self.delimiter
    ' --reported--> '
  end
  
  def initialize(hsh)
    super(hsh.merge(:ticket_id => hsh['id']))
  end
  
  def comments
    @comments ||= self.class.get(
      "https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/tickets/#{self.ticket_id}/comments"
    )['comments'].map { |c| Comment.new(c) }
  end
  
  def assigned?
    !!self.assignee_id
  end
  
  # Older than 24 hours and still unassigned
  def out_of_bounds?
    !assigned? && self.created_at < (Time.now - (1*24*60*60))
  end
  
  def assignee_name
    Person.find(self.assignee_id).first_name || 'No one yet'
  end
  
  def reporter_name
    if self.summary.match(Ticket.delimiter)
      self.summary.split(Ticket.delimiter).first
    else
      Person.find(self.reporter_id).first_name
    end
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
  
  private
  
  def self.prepare_attributes(attrs)
    attrs[:summary].capitalize!

    # Strip tags
    [:name, :summary, :description].each do |attr|
      attrs[attr].gsub!(/<\/?[^>]*>/, "")
    end
    
    attrs
  end
end