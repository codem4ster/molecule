class Element
  def serialize_hash(obj)
    result = Hash.new `self.serializeHash()`
    result.each do |key, value|
      obj.instance_variable_set("@#{key}", value)
    end
    result
  end
end