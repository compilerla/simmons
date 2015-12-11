require 'csv'

class Housekeeping
  def self.clean_apn(apn)
    if apn.nil?
      ''
    elsif apn.include?('#')
      ''
    elsif apn.length == 1
      ''
    elsif apn =~ /^.{4}-.{3}-.{3}$/
      [apn.gsub(/^(.{4})-(.{3})-(.{3})$/, '\1\2\3')]
    elsif apn =~ /^.{7}\*{3}$/
      ''
    elsif apn.include?(';')
      apn.split(';').map(&:strip)
    elsif apn.include?(',')
      apn.split(',').map do |no_commas_apn|
        clean_apn(no_commas_apn)
      end
    else
      apn
    end
  end
end

class Merger
  def self.merge_file(file_name, apn_col, address_col, new_file = false)
    open_mode = new_file ? 'wb' : 'ab'
    in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
    out_csv = CSV.open("../data/master_with_dups.csv", open_mode)
    in_csv.each do |row|
      apn_raw = apn_col.nil? ? '' : row[apn_col]
      
      apns_cleaned = Housekeeping.clean_apn(apn_raw)
      address = address_col.nil? ? '' : build_column_value(row, address_col)

      if apns_cleaned.kind_of?(Array)      
        apns_cleaned.each do |clean_apn|
          out_csv << [file_name, clean_apn, address, '']
        end
      else
        out_csv << [file_name, apns_cleaned, address, '']
      end
    end

    in_csv.close
    out_csv.close
  end

  def self.build_column_value(input_row, keys)
    return '' if keys.nil? || keys == ''
    return input_row[keys] unless keys.kind_of?(Array)
    keys.map do |key|
      input_row[key]
    end.join(' ')
  end
end

Merger.merge_file("2015 Registered Foreclosed Properties.csv", 'APN', 'Property Address', true)
Merger.merge_file("Assumed outside LA City Limits.csv", 'AIN', 'PropertyLocation')
Merger.merge_file("Brownfields Program - Sanitation Department.csv", 'APN', 'Address')
Merger.merge_file("Building Book - GSD - 4468 FY 2014_by_building_book_number.csv", 'APN', ['Street #', 'Street Dir', 'Street Name', 'Street Type', 'Zip Code'])
Merger.merge_file("Building Book - GSD - 4468 FY 2014_listed_by_address.csv", 'APN', ['Street #', 'Street Dir', 'Street Name', 'Street Type', 'Zip Code'])
Merger.merge_file("City Owned Within CDs.csv", 'AIN', nil)
Merger.merge_file("CRA Option Properties .csv", nil, 'Address')
Merger.merge_file("CRA Property List Oct 2012.csv", 'Parcel Number', 'Address')
Merger.merge_file("Decommissioned Fire Stations.csv", 'APN', nil)
Merger.merge_file("GSD Facilities  For Filming.csv", nil, 'Address')
Merger.merge_file("Insured Buildings & Uninsured Buildings -CAO - 359.csv", nil, ['Address','City', 'State', 'Zip'])
Merger.merge_file("Leased properties to NPOs - GSD - 110 - FY 2014.csv", nil, 'Address')
# Merger.merge_file("Master Property List (Simple) 03-7-2013- Update (1) (2).csv", 'APN', 'Address')
Merger.merge_file("MICLA Commercial Paper Note Program.csv", nil, 'ADDRESS')
Merger.merge_file("Neighborhood Land Trust Empty Lots .csv", 'AIN', nil)
Merger.merge_file("Own a Piece of LA - OPLA (3).csv", 'APN', 'ADDRESS')
Merger.merge_file("Parking Lots & Structures - LADOT.csv", nil, ['Address', 'Zip Code'])
Merger.merge_file("Projected Surplus Properties Sales FY15-16 (Per GSD).csv", 'APN', ['PROPERTY ADDRESS', 'ZIP'])
Merger.merge_file("Properties in BIDS - Compiled.csv", 'APN', 'Site Addr')
Merger.merge_file("Properties Recommended for Disposition byb HCIDLA.csv", nil, ['City', 'Zip Code'])

# Merger.merge_file("Recreation and Parks - Provided by Department.csv", 'APN', 'Address') Use manually cleaned one!

Merger.merge_file("Reported Nuisance Properties FYs 14-16__14-15_sheet.csv", nil, ['Street #', 'Street Name', 'City & ZIP'])
Merger.merge_file("Reported Nuisance Properties FYs 14-16__15-16_sheet.csv", nil, ['Street #', 'Street Name', 'City & ZIP'])
Merger.merge_file("Residential Leases - GSD - 11 total - FY 2013.csv", nil, ['ADDRESS', 'ADDRESS_2'])
Merger.merge_file("undeclared surplus property by id.csv", 'APN', 'ADDRESS')
