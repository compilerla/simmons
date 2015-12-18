require 'csv'
require 'pry'


namespace :data do
  desc "output csv of all data matched to an AIN"
  task ain_output: :environment do
    used_ids = []
    headers = %w(ain supplied_address address_from_apn latitude longitude source_files)
    CSV.open('../data/deduped_by_ain.csv', 'wb') do |out_csv|
      out_csv << headers
      AinShape.all.each do |shape|
        out_row = []
        out_row << shape.ain
        out_row << shape.master_records.first.address_given
        out_row << shape.master_records.first.address_from_apn
        out_row << shape.master_records.first.address_latitude
        out_row << shape.master_records.first.address_longitude
        out_row << shape.master_records.pluck(:file_name)
        used_ids << shape.master_records.pluck(:id)
        used_ids = used_ids.flatten
        p out_row if shape.master_records.first.apn_given.empty?
        out_csv << out_row
      end

      p "going into not matched"
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
        used_ids << records.pluck(:id)
        used_ids = used_ids.flatten
        p out_row if records.first.apn_given.empty?
        out_csv << out_row
      end

      p "going into everything else"
      no_lat_lon = MasterRecord.not_yet_matched.where.not(id: used_ids)
      no_lat_lon.each do |record|
        out_row = []
        out_row << record.apn_given
        out_row << record.address_given
        out_row << record.address_from_apn
        out_row << record.address_latitude
        out_row << record.address_longitude
        out_row << record.file_name
        p out_row if record.apn_given.empty?
        out_csv << out_row
      end
    end
  end
end
