class MasterRecord < ActiveRecord::Base
  has_one :ain_shapes_master_record, dependent: :destroy
  has_one :ain_shape, ->{ uniq }, through: :ain_shapes_master_record

  def self.not_yet_matched
    already_matched = AinShapesMasterRecord.pluck(:master_record_id);0
    where.not(id: already_matched)
  end

  def council_district
    info['council_district']
  end

  def use_type
    county_data['UseType']
  end

  def use_type_label
    county_data['UseType_Label']
  end

  def info
    read_attribute(:info) || {}
  end
end
