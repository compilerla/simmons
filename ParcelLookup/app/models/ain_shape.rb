class AinShape < ActiveRecord::Base
  scope :containing_point, -> (point) { where("ain_shapes.shape && ?", point) }
  validates_uniqueness_of :ain
  has_many :ain_shapes_master_record, dependent: :destroy, foreign_key: :ain_shape_id
  has_many :master_records, through: :ain_shapes_master_record

  def self.find_by_lat_lon(lat, lon)
    factory = RGeo::Geographic.simple_mercator_factory()
    point = factory.point(lon, lat)
    self.containing_point(point)
  end
end
