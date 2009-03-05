class Comment < UnfuddleRecord
  # attrs needs to include a ticket_id
  def self.create(attrs)
    # raise argument error of no attrs[:ticket_id]
    
    attrs = prepare_attributes(attrs)
    
    post( "https://#{Sinatra::Application.unfuddle_subdomain}.unfuddle.com/api/v1/projects/#{Sinatra::Application.unfuddle_project_id}/tickets/#{attrs['ticket_id']}/comments",
          :body => "
            <comment>
              <body>#{attrs['name']}#{delimiter}#{attrs['body']}</body>
            </comment>",
          :headers => {'Content-type' => 'application/xml'})
  end
  
  def self.delimiter
    ' --commented--> '
  end
  
  def commenter_name
    if @attributes.body.match(self.class.delimiter)
      @attributes.body.split(self.class.delimiter).first
    else
      Person.find(@attributes.author_id).first_name
    end
  end
  
  def body
    @attributes.body.match(self.class.delimiter) ? @attributes.body.split(self.class.delimiter).last : @attributes.body
  end
  
  private
  
  def self.prepare_attributes(attrs)
    # Strip tags
    ['name', 'body'].each do |attr|
      attrs[attr].gsub!(/<\/?[^>]*>/, "")
    end

    attrs
  end
end