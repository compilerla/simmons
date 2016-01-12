require 'csv'
require 'pry'
require 'colorizer'


namespace :data do
  desc "output csv of all data matched to an AIN"
  task ain_output: :environment do
    colorizer = Colorizer.new
    used_ids = []
    geojson_features = []
    headers = %w(ain supplied_address address_from_apn latitude longitude source_files parcel_size council_district use_type use_type_label region tax_rate_area recording_date assessed_value land_value improvement_value property_boundary_description first_owner_name agency_name general_use_type specific_use_type)
    CSV.open('../data/deduped_by_ain.csv', 'wb') do |out_csv|
      out_csv << headers
      AinShape.all.each do |shape|
        out_row = []
        out_row << shape.ain
        out_row << shape.master_records.first.address_given
        out_row << shape.master_records.first.address_from_apn
        out_row << shape.master_records.first.address_latitude
        out_row << shape.master_records.first.address_longitude
        out_row << shape.master_records.pluck(:file_name).join(', ')
        out_row << shape.master_records.map(&:parcel_size).uniq.join(', ')
        out_row << shape.master_records.map(&:council_district).uniq.join(', ')
        out_row << shape.master_records.map(&:use_type).uniq.join(', ')
        out_row << shape.master_records.map(&:use_type_label).uniq.join(', ')
        out_row << shape.master_records.map(&:region).uniq.join(', ')
        out_row << shape.master_records.map(&:tax_rate_area).uniq.join(', ')
        out_row << shape.master_records.map(&:recording_date).uniq.join(', ')
        out_row << shape.master_records.map(&:assessed_value).uniq.join(', ')
        out_row << shape.master_records.map(&:land_value).uniq.join(', ')
        out_row << shape.master_records.map(&:improvement_value).uniq.join(', ')
        out_row << shape.master_records.map(&:property_boundary_description).uniq.join(', ')
        out_row << shape.master_records.map(&:first_owner_name).uniq.join(', ')
        out_row << shape.master_records.map(&:agency_name).uniq.join(', ')
        out_row << shape.master_records.map(&:general_use_type).uniq.join(', ')
        out_row << shape.master_records.map(&:specific_use_type).uniq.join(', ')

        used_ids << shape.master_records.pluck(:id)
        used_ids = used_ids.flatten
        # p out_row if shape.master_records.first.apn_given.empty?
        out_csv << out_row
        geojson_features << {
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": shape.shape.coordinates
          },
          "properties": {
            "title": shape.master_records.pluck(:file_name).join(', '),
            "APN": shape.master_records.first.apn_given,
            "fill": colorizer.colorize(shape.master_records.pluck(:file_name)),
            "stroke": colorizer.colorize(shape.master_records.pluck(:file_name))
          }
        }
        p colorizer.colorize(shape.master_records.pluck(:file_name))
      end

      # APN groups
      not_matched = MasterRecord.not_yet_matched.where.not(id: used_ids).group(:apn_given).count
      not_matched.each do |apn, count|
        next if apn.blank?
        out_row = []
        records = MasterRecord.where("apn_given = ?", apn)
        next if records.empty?
        out_row << records.first.apn_given
        out_row << records.first.address_given
        out_row << records.first.address_from_apn
        out_row << records.first.address_latitude
        out_row << records.first.address_longitude
        out_row << records.pluck(:file_name).join(', ')
        out_row << records.map(&:parcel_size).uniq.join(', ')
        out_row << records.map(&:council_district).uniq.join(', ')
        out_row << records.map(&:use_type).uniq.join(', ')
        out_row << records.map(&:use_type_label).uniq.join(', ')
        out_row << records.map(&:region).uniq.join(', ')
        out_row << records.map(&:tax_rate_area).uniq.join(', ')
        out_row << records.map(&:recording_date).uniq.join(', ')
        out_row << records.map(&:assessed_value).uniq.join(', ')
        out_row << records.map(&:land_value).uniq.join(', ')
        out_row << records.map(&:improvement_value).uniq.join(', ')
        out_row << records.map(&:property_boundary_description).uniq.join(', ')
        out_row << records.map(&:first_owner_name).uniq.join(', ')
        out_row << records.map(&:agency_name).uniq.join(', ')
        out_row << records.map(&:general_use_type).uniq.join(', ')
        out_row << records.map(&:specific_use_type).uniq.join(', ')

        used_ids << records.pluck(:id)
        used_ids = used_ids.flatten
        # p out_row if records.first.apn_given.empty?
        out_csv << out_row

        if records.first.address_longitude.present?
          geojson_features << {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [records.first.address_longitude, records.first.address_latitude]
            },
            "properties": {
              "title": records.pluck(:file_name).join(', '),
              "address": records.first.address_given,
              "marker-color": colorizer.colorize(records.pluck(:file_name))
            }
          }
        end
      end
      # p "group by location"
      not_matched = MasterRecord.not_yet_matched.where.not(id: used_ids).group([:address_latitude, :address_longitude]).count
      not_matched.each do |(lat, lon), count|
        next if lat.blank?
        out_row = []
        records = MasterRecord.where("address_latitude::numeric = ? AND address_longitude::numeric = ?", lat, lon)
        next if records.empty?
        out_row << records.first.apn_given
        out_row << records.first.address_given
        out_row << records.first.address_from_apn
        out_row << records.first.address_latitude
        out_row << records.first.address_longitude
        out_row << records.pluck(:file_name).join(', ')
        out_row << records.map(&:parcel_size).uniq.join(', ')
        out_row << records.map(&:council_district).uniq.join(', ')
        out_row << records.map(&:use_type).uniq.join(', ')
        out_row << records.map(&:use_type_label).uniq.join(', ')
        out_row << records.map(&:region).uniq.join(', ')
        out_row << records.map(&:tax_rate_area).uniq.join(', ')
        out_row << records.map(&:recording_date).uniq.join(', ')
        out_row << records.map(&:assessed_value).uniq.join(', ')
        out_row << records.map(&:land_value).uniq.join(', ')
        out_row << records.map(&:improvement_value).uniq.join(', ')
        out_row << records.map(&:property_boundary_description).uniq.join(', ')
        out_row << records.map(&:first_owner_name).uniq.join(', ')
        out_row << records.map(&:agency_name).uniq.join(', ')
        out_row << records.map(&:general_use_type).uniq.join(', ')
        out_row << records.map(&:specific_use_type).uniq.join(', ')

        used_ids << records.pluck(:id)
        used_ids = used_ids.flatten
        # p out_row if records.first.apn_given.empty?
        out_csv << out_row

        if records.first.address_longitude.present?
          geojson_features << {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [records.first.address_longitude, records.first.address_latitude]
            },
            "properties": {
              "title": records.pluck(:file_name).join(', '),
              "address": records.first.address_given,
              "marker-color": colorizer.colorize(records.pluck(:file_name))
            }
          }
        end
      end

      # p "going into everything else"
      no_lat_lon = MasterRecord.not_yet_matched.where.not(id: used_ids)
      no_lat_lon.each do |record|
        out_row = []
        out_row << record.apn_given
        out_row << record.address_given
        out_row << record.address_from_apn
        out_row << record.address_latitude
        out_row << record.address_longitude
        out_row << record.file_name
        out_row << record.parcel_size
        out_row << record.council_district
        out_row << record.use_type
        out_row << record.use_type_label
        out_row << record.region
        out_row << record.tax_rate_area
        out_row << record.recording_date
        out_row << record.assessed_value
        out_row << record.land_value
        out_row << record.improvement_value
        out_row << record.property_boundary_description
        out_row << record.first_owner_name
        out_row << record.agency_name
        out_row << record.general_use_type
        out_row << record.specific_use_type

        # p out_row if record.apn_given.empty?
        out_csv << out_row

        if record.address_longitude.present?
          geojson_features << {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [record.address_longitude, record.address_latitude]
            },
            "properties": {
              "title": record,
              "address": record.address_given,
              "marker-color": colorizer.colorize(record.file_name)
            }
          }
        end
      end
    end

    feature_collection = {
      "type": "FeatureCollection",
      "features": geojson_features
    }

    File.open('../data/deduped.geojson', 'w') { |file| file.write(feature_collection.to_json) }
  end
end
