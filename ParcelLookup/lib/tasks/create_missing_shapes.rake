require Rails.root.join('lib', 'data_filler.rb')

namespace :data do
  desc "get assessor info"
  task create_missing_shapes: :environment do
    MasterRecord.find_each do |record|
      next unless record.apn_given.length == 10
      shape = AinShape.find_by_ain(record.apn_given)
      if !shape
        p "Missing shape found"
        shape_data = DataFiller.shape_from_apn(record.apn_given)
        if shape_data.present?
          p "Found shape data. Creating new record"
          AinShape.create!(ain: record.apn_given, shape: shape_data)
        else
          p "No shape found. Skipping"
        end
      end
    end
  end
end