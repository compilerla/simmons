class AinShape < ActiveRecord::Base
  scope :containing_point, -> (point) { where("ain_shapes.shape && ?", point) }
end
