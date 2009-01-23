require 'ostruct'




# This method is needed for HTTParty to work properly
# Extracted from http://github.com/wycats/merb-extlib/tree/master/lib/merb-extlib/string.rb
class String
  def snake_case
    return self.downcase if self =~ /^[A-Z]+$/
    self.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
      return $+.downcase
  end
end

class Unfuddle
  include HTTParty
  
  basic_auth  Sinatra::Application.unfuddle_username, Sinatra::Application.unfuddle_password

  format :xml

  def self.get_ticket_report(id)
    TicketReport.new(
      get("https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/ticket_reports/#{id}/generate")['ticket_report']
    )
  end
  
  def self.get_ticket(id)
    Ticket.new(
      get("https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/tickets/by_number/#{id}")['ticket']
    )
  end
  
  def self.get_person(id)
    get("https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/people/#{id}")['person']
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
end

class Person
  @people = {}
  
  def self.name_by_id(id)
    if id
      @people[id] ||= begin
        Unfuddle.get_person(id)['first_name']
      rescue Net::HTTPServerException
        'Unknown'
      end
    else
      'No one yet'
    end
  end
end

class TicketReport
  attr_accessor :ticket_groups
  
  def initialize(hsh)
    @ticket_groups = hsh['groups']['group'].map { |g| TicketGroup.new(g) }
  end
end

class TicketGroup
  attr_accessor :tickets
  
  def initialize(hsh)
    @title    = hsh['title']
    @tickets  = hsh['tickets']['ticket'].map { |t| Ticket.new(t) }
  end
  
  def title
    @title == '<none>' ? 'Ungrouped' : @title
  end
  
  def unassigned_tickets
    @unassigned_tickets ||= @tickets.select { |t| t.assignee_id.nil? }
  end
  
  def assigned_tickets
    @assigned_tickets ||= @tickets.select { |t| !t.assignee_id.nil? }
  end
end

class Ticket < OpenStruct
  def initialize(hsh)
    super(hsh)
  end
  
  def self.delimiter
    ' --reported--> '
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
  def ticket_created_at
    if self.created_at.kind_of?(String)
      Time.parse(self.created_at)
    else
      self.created_at
    end
  end
end