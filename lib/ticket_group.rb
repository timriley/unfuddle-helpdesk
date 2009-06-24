class TicketGroup < UnfuddleRecord
  attr_accessor :tickets
  
  def initialize(hsh)
    @tickets  = (hsh['tickets'].kind_of?(Array) ? hsh['tickets'] : [hsh['tickets']]).map { |t| Ticket.new(t) }
    super({:title => hsh['title']})
  end
  
  def title
    @attributes.title == '<none>' ? 'Ungrouped' : @attributes.title
  end
  
  def unassigned_tickets
    @unassigned_tickets ||= @tickets.select { |t| t.assignee_id.nil? }
  end
  
  def assigned_tickets
    @assigned_tickets ||= @tickets.select { |t| !t.assignee_id.nil? }
  end
  
  def tickets_by_status(status)
    @tickets.select { |t| t.get(:status) == status }
  end
  def tickets_not_by_status(status)
    @tickets.select { |t| t.get(:status) != status }
  end
end