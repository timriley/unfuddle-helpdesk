class BlankSlate
  # instance_methods.each { |m| undef_method m unless m =~ /^__/ }
end

module HTTParty
  class Response
    def created?
      code == '201'
    end
  end
end

class String
  def underscore
    gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

class Date
  def to_time(form = :local)
    Time.mktime(year, month, day)
  end
end