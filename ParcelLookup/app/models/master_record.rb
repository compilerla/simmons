class MasterRecord < ActiveRecord::Base
  has_one :ain_shapes_master_record, dependent: :destroy
  has_one :ain_shape, through: :ain_shapes_master_record

  def self.not_yet_matched
    already_matched = AinShapesMasterRecord.pluck(:master_record_id);0
    where.not(id: already_matched)
  end

  def parcel_size
    info['parcel_size']
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

  def region
    county_data['REGION']
  end

  def tax_rate_area
    county_data['TRA']
  end

  def recording_date
    county_data['RECDATE']
  end

  def assessed_value
    info['assessed_value']
  end

  def land_value
    county_data['LANDVAL']
  end

  def improvement_value
    county_data['IMPROVAL']
  end

  def property_boundary_description
    return nil unless county_data['Legals'].is_a? Array
    county_data['Legals'].map(&:strip).join
  end

  def first_owner_name
    info['first_owner_name']
  end

  def agency_name
    info['agency_name']
  end

  def general_use_type
    info['general_use_type']
  end

  def specific_use_type
    info['specific_use_type']
  end

  def info
    read_attribute(:info) || {}
  end
end
