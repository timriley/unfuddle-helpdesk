class TicketGroup
  attr_accessor :tickets
  
  def initialize(hsh)
    @title    = hsh['title']
    @tickets  = (hsh['tickets'].kind_of?(Array) ? hsh['tickets'] : [hsh['tickets']]).map { |t| Ticket.new(t) }
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