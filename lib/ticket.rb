class Ticket < UnfuddleRecord
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
  
  def comments
    @comments ||= self.class.get(
      "https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/tickets/#{@attributes.ticket_id}/comments"
    )['comments'].to_a.map { |c| Comment.new(c) }
  end
  
  def assigned?
    !!@attributes.assignee_id
  end
  
  def out_of_bounds?
    # neglected? || incomplete? || overdue?
    neglected? || overdue?
  end
  
  # Older than 24 hours and still unassigned
  def neglected?
    !assigned? && created_at < (Time.now - (1*24*60*60))
  end
  
  # neglected, or assigned but still without a due date
  def incomplete?
    neglected? || !due_on
  end
  
  def overdue?
    @attributes.due_on ? @attributes.due_on < Date.today : false
  end
  
  def helpdesk_url
    "/tickets/#{number}"
  end
  
  def admin_url
    "https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/projects/#{Sinatra::Application.unfuddle_project_id}/tickets/by_number/#{number}"
  end
  
  def assignee_name
    assigned? ? Person.find(@attributes.assignee_id).first_name : 'No one yet'
  end
  
  def reporter_name
    if @attributes.summary.match(self.class.delimiter)
      @attributes.summary.split(self.class.delimiter).first
    else
      Person.find(@attributes.reporter_id).first_name
    end
  end
  
  def summary
    @attributes.summary.match(self.class.delimiter) ? @attributes.summary.split(self.class.delimiter).last : @attributes.summary
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