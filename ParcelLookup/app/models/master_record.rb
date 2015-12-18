class MasterRecord < ActiveRecord::Base
  has_one :ain_shapes_master_record, dependent: :destroy
  has_one :ain_shape, ->{ uniq }, through: :ain_shapes_master_record

  def self.not_yet_matched
    already_matched = AinShapesMasterRecord.pluck(:master_record_id);0
    where.not(id: already_matched)
  end
end
