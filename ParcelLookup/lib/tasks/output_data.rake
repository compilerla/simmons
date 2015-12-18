require 'csv'


namespace :data do
  desc "output csv of all data matched to an AIN"
  task ain_output: :environment do
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
        out_csv << out_row
      end

      no_ains = MasterRecord.not_yet_matched.group([:address_latitude, :address_longitude]).count
      not_matched.each do |(lat, lon), count|
        next if lat.nil?
        out_row = []
        out_row << nil
        records = MasterRecord.where(address_latitude: lat, address_longitude: lon)
        out_row << records.first.address_given
        out_row << records.first.address_from_apn
        out_row << records.first.address_latitude
        out_row << records.first.address_longitude
        out_row << records.pluck(:file_name)
        out_csv << out_row
      end

      no_lat_lon = MasterRecord.not_yet_matched.where(address_longitude: nil, address_latitude: nil).count
      no_lat_lon.each do |record|
        out_row << nil
        out_row << record.address_given
        out_row << record.address_from_apn
        out_row << record.address_latitude
        out_row << record.address_longitude
        out_row << record.file_name
        out_csv << out_row
      end
    end
  end
end
