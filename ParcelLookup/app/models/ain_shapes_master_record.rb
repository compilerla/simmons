class AinShapesMasterRecord < ActiveRecord::Base
  belongs_to :master_record
  belongs_to :ain_shape

  validates_uniqueness_of :ain_shape_id, scope: :master_record_id
end
