class UnfuddleRecord
  include HTTParty
  basic_auth Sinatra::Application.unfuddle_username, Sinatra::Application.unfuddle_password
  format :xml

  def initialize(hsh)
    @attributes = OpenStruct.new(hsh.merge({"#{self.class.name.underscore}_id" => hsh['id']}))
  
    # Fix up unfuddle's crappy dates
    # When loading a generated ticket report: <created-at type="datetime">2008-05-23T07:48:38+00:00</created-at>
    # When loading a ticket on its own:       <created-at>2008-05-23T17:48:38+10:00</created-at>
    # Ugh.
    [:created_at, :updated_at].each do |time|
      if @attributes.respond_to?(time)
        self.class.class_eval do
          define_method :"#{time}" do
            if @attributes.send(time).kind_of?(String)
              Time.parse(@attributes.send(time))
            else
              @attributes.send(time)
            end
          end
        end
      end
    end
  end

  def method_missing(name, *args, &block)
    @attributes.send(name, *args, &block)
  end

  def id
    @attributes.send(:"#{self.class.name.underscore}_id")
  end
end