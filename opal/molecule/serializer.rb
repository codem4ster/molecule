class Element
  def serialize_hash
    Hash.new `self.serializeHash()`
  end
end