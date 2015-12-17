class AinShapesMasterRecord < ActiveRecord::Base
  belongs_to :master_record
  belongs_to :ain_shape
end
