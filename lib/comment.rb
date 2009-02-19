class Comment < UnfuddleRecord
  def commenter_name
    Person.find(self.author_id).first_name
  end
end