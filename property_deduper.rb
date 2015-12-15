class PropertyDeduper
  def initialize
    @properties = {}
    @dups = 0
  end

  def add(apn, address_from_apn, address_given, list, shape, latlng)
    property = find_by_apn(apn)
    if property
      puts "Dup!"
      @dups += 1
      @properties[property][:apn] ||= apn
      @properties[property][:address_from_apn] ||= address_from_apn
      @properties[property][:address_given] ||= address_given
      @properties[property][:shape_from_apn] ||= shape
      @properties[property][:latlng_from_address] ||= latlng
      @properties[property][:source_lists] << list
      @properties[property][:times_encountered] += 1
    else
      @properties[SecureRandom.uuid] = { apn: apn, address_from_apn: address_from_apn, address_given: address_given, source_lists: [list], times_encountered: 1, shape_from_apn: shape, latlng_from_address: latlng }
    end

    puts @properties.count
  end

  def each_property
    @properties.each do |k, property|
      yield(property)
    end
  end

  def find_by_apn(apn)
    return nil unless apn != ''

    property = @properties.find do |k, property|
      property[:apn] == apn
    end
    return property[0] if property
    nil
  end

  def dups
    @dups
  end
end