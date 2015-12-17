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
    end
  end
end
