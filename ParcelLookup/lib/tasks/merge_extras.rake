namespace :data do
  desc "merge in extra attrs"
  task merge_extras: :environment do
    CSV.open('../data/raw/HCIDLA Owned Properties for Filming.csv', headers: true) do |in_csv|
      in_csv.each do |row|
        apn = row['APN']
        size = row['Parcel Size']
        district = row['Council District']
        records = MasterRecord.where(apn_given: apn)
        if records.any?
          records.each do |record|
            record.info['parcel_size'] = size
            record.info['council_district'] = district
            record.save!
          end
        end
      end
    end

    CSV.open('../data/raw/City Owned Within CDs.csv', headers: true) do |in_csv|
      in_csv.each do |row|
        apn = row['AIN']
        assessed_value = row['ASSESSED VALUE']
        district = row['DISTRICT']
        records = MasterRecord.where(apn_given: apn)
        if records.any?
          records.each do |record|
            record.info['assessed_value'] = assessed_value
            record.info['council_district'] = district
            record.save!
          end
        end
      end
    end

    MasterRecord.find_each do |record|
      next unless record.apn_given.present?

      request = RestClient.get("http://maps.assessor.lacounty.gov/Geocortex/Essentials/REST/sites/PAIS/SQLAINSearch?f=json&AIN=#{record.apn_given}&dojo.preventCache=1449797179914")
      details = JSON.parse(request)['results']['ParcelDetails']
      if details.present?
        p 'saving'
        record.info['assesorinfo'] = details
        record.save!
      else
        p "skipping"
      end
    end
  end
end
