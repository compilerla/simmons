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
        first_owner = row['FIRST_OWNER_NAME']

        records = MasterRecord.where(apn_given: apn)
        if records.any?
          records.each do |record|
            record.info['assessed_value'] = assessed_value
            record.info['council_district'] = district
            record.info['first_owner_name'] = first_owner
            record.save!
          end
        end
      end
    end

    CSV.open('../data/raw/Assumed outside LA City Limits.csv', headers: true) do |in_csv|
      in_csv.each do |row|
        apn = row['AIN']
        agency_name = row['AgencyName']
        general_use_type = row['GeneralUseType']
        specific_use_type = row['SpecificUseType']

        records = MasterRecord.where(apn_given: apn)
        if records.any?
          records.each do |record|
            record.info['agency_name'] = agency_name
            record.info['general_use_type'] = general_use_type
            record.info['specific_use_type'] = specific_use_type
            record.save!
          end
        end
      end
    end
  end
end
