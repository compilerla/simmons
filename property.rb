class Property
  def initialize(identifier)
    @identifier = identifier
  end

  def identifier_type
    # Returns one of :apn, :ain, :address
  end

  def as_json
    {
      apn: nil, #TODO
      ain: nil, #TODO
      address: nil, #TODO
      source_lists: []
    }
  end
end