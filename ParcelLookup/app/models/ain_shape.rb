class AinShape < ActiveRecord::Base
  scope :containing_point, -> (point) { where("ain_shapes.shape && ?", point) }

  def self.find_by_lat_lon(lat, lon)
    factory = RGeo::Geographic.simple_mercator_factory()
    point = factory.point(lon, lat)
    self.containing_point(point)
  end
end
