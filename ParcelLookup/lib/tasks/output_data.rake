require 'csv'
require 'pry'


namespace :data do
  desc "output csv of all data matched to an AIN"
  task ain_output: :environment do
    used_ids = []
    geojson_features = []
    headers = %w(ain supplied_address address_from_apn latitude longitude source_files council_district use_type, use_type_label)
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
        out_row << shape.master_records.map(&:council_district).uniq.join(', ')
        out_row << shape.master_records.map(&:use_type).uniq.join(', ')
        out_row << shape.master_records.map(&:use_type_label).uniq.join(', ')

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
            "APN": shape.master_records.first.apn_given
          }
        }
      end

      # p "going into not matched"
      not_matched = MasterRecord.not_yet_matched.group([:address_latitude, :address_longitude]).count
      not_matched.each do |(lat, lon), count|
        next if lat.nil?
        out_row = []
        records = MasterRecord.where(address_latitude: lat, address_longitude: lon)
        next if records.empty?
        out_row << records.first.apn_given
        out_row << records.first.address_given
        out_row << records.first.address_from_apn
        out_row << records.first.address_latitude
        out_row << records.first.address_longitude
        out_row << records.pluck(:file_name)
        out_row << records.map(&:council_district).uniq.join(', ')
        out_row << records.map(&:use_type).uniq.join(', ')
        out_row << records.map(&:use_type_label).uniq.join(', ')

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
              "address": records.first.address_given
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
        out_row << record.council_district
        out_row << record.use_type
        out_row << record.use_type_label

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
              "address": record.address_given
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
