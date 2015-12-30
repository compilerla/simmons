namespace :data do
  desc "get assessor info"
  task get_assessor_info: :environment do
    MasterRecord.where("apn_given IS NOT NULL AND NOT(info ? 'assesorinfo')").find_each do |record|
      begin
        next unless record.apn_given.present?

        request = RestClient.get("http://maps.assessor.lacounty.gov/Geocortex/Essentials/REST/sites/PAIS/SQLAINSearch?f=json&AIN=#{record.apn_given}&dojo.preventCache=1449797179914")
        details = JSON.parse(request)['results']['ParcelDetails']
        if details.present?
          p 'saving'
          record.county_data = details
          record.save!
        else
          p "skipping"
        end
      rescue
        p "Failed on record #{record.id}"
      end
    end
  end
end