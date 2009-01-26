class Comment < OpenStruct
  def initialize(hsh)
    super(hsh)
  end
  
  def commenter_name
    Person.find(self.author_id).first_name
  end
  
  [:created_at, :updated_at].each do |time|
    define_method :"comment_#{time}" do
      if self.send(time).kind_of?(String)
        Time.parse(self.send(time))
      else
        self.send(time)
      end
    end
  end
end