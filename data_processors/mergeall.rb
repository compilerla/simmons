require 'csv'
require 'rest-client'
require 'merc_convert'
require 'geocoder'
require 'securerandom'
require '../property_deduper.rb'

Geocoder.configure( :lookup => :google,
                    :use_https => true,
                    :api_key => 'AIzaSyDzL_IIGdqVTs0_E6Oln6uYoJMXEffHfyk',
                    :region => 'us'
                  )

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

class Deduper
  def self.dedup_all
    in_csv = CSV.open("../data/master_with_dups.csv", { headers: true })
    out_csv = CSV.open("../data/master_without_dups.csv", "wb")

    out_csv << ['APN', 'Address given', 'Address from apn', 'Times encountered', 'Lists', 'Shape', 'Latlng from address given']

    deduper = PropertyDeduper.new

    in_csv.each do |row|
      list = row['File name']
      apn = row['APN given']
      address_from_apn = row['Address from APN']
      address_given = row['Address given']
      shape = row['Shape coords from APN']
      latlng = row['Latlng from address given']

      deduper.add(apn, address_from_apn, address_given, list, shape, latlng)
    end

    deduper.each_property do |property|
      out_csv << [property[:apn], property[:address_given], property[:address_from_apn], property[:times_encountered], property[:source_lists].join(', '), property[:shape_from_apn], property[:latlng_from_address]]
    end

    puts "Finished! #{deduper.dups} duplicates."

    in_csv.close
    out_csv.close
  end
end

class Merger
  def self.merge_file(file_name, apn_col, address_col, new_file = false)
    open_mode = new_file ? 'wb' : 'ab'
    in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
    out_csv = CSV.open("../data/master_with_dups.csv", open_mode)
    if new_file
      out_csv << headers
    end
    in_csv.each do |row|
      cleaned_rows = generate_cleaned_rows(row, file_name, apn_col, address_col)
      cleaned_rows.each do |cleaned_row|
        out_csv << cleaned_row
      end
    end

    in_csv.close
    out_csv.close
  end

  def self.update_headers
    in_csv = CSV.open("../data/master_with_dups.csv", { headers: true })
    out_csv = CSV.open("../data/master_with_dups_updated_headers.csv", "wb")

    out_csv << headers
    in_csv.each do |row|
      headers.each do |header|
        if !row[header]
          row[header] = ''
        end
      end
      out_csv << row
    end

    in_csv.close
    out_csv.close
  end

  def self.headers
    ['File name', 'APN given', 'Address given', 'Address from APN', 'Shape coords from APN', 'Latlng from address given', 'Latlng from city API', 'Assessed value', 'council district', 'Property Type', 'Region/Cluster', 'Tax Rate Area', 'Recording Date', 'Land', 'Improvements', 'Property Boundary Description', 'Building Square Footage', 'Year Built/Effective Year Built', 'Units']
  end

  def self.patch_missing_geos
    in_csv = CSV.open("../data/master_with_dups.csv", { headers: true })
    out_csv = CSV.open("../data/master_with_dups_patched.csv", "wb")

    processed = 0
    skipped = 0

    out_csv << headers
    in_csv.each do |row|
      processed += 1
      if (row['APN given'].nil? || row['APN given'] == '') && (!row['Address given'].nil? && row['Address given'] != '')
        puts "#{processed}: Geocoding #{row['Address given']}..."
        row['Latlng from address given'] = latlng_for_address(row['Address given'])
        puts "Done: #{row['Latlng from address given']}"
      else
        skipped += 1
        puts "APN present or no address, skipping... (#{skipped})"
      end

      out_csv << row
    end

    in_csv.close
    out_csv.close
  end

  def self.patch_missing_shapes
    in_csv = CSV.open("../data/master_with_dups.csv", { headers: true })
    out_csv = CSV.open("../data/master_with_dups_patched.csv", "wb")

    out_csv << headers
    in_csv.each do |row|
      if row['Shape coords from APN'].nil? || row['Shape coords from APN'] == '' && (!row['APN given'].nil? && row['APN given'] != '')
        puts "Querying #{row['APN given']}..."
        row['Shape coords from APN'] = shape_from_apn(row['APN given'].strip)
        puts "Done: #{row['Shape coords from APN']}"
      else
        puts "Skipping..."
      end

      out_csv << row
    end

    in_csv.close
    out_csv.close
  end

  def self.generate_cleaned_rows(row, file_name, apn_col, address_col)
    apn_raw = apn_col.nil? ? '' : row[apn_col]
      
    apns_cleaned = Housekeeping.clean_apn(apn_raw)
    address = address_col.nil? ? '' : build_column_value(row, address_col)

    apns_cleaned = [apns_cleaned] if !apns_cleaned.kind_of?(Array)      
    apns_cleaned.map do |clean_apn|
      [file_name, clean_apn, address, self.address_from_apn(clean_apn), self.shape_from_apn(clean_apn), self.latlng_for_address(address), nil, nil, row['Council District'], nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    end
  end

  def self.latlng_for_address(address)
    return nil unless address && address.length > 0
    puts "Geocoding #{address}"
    geo_response = Geocoder.search(address).first
    if geo_response.nil?
      log_error("Couldn't geocode address: #{address}")
      return
    end

    geo_response.coordinates
  end

  def self.log_error(error)
    # TODO
  end

  def self.address_from_apn(apn)
    return '' unless apn && apn.length > 0

    address_from_apn = ''
    puts "Checking address for apn: #{apn}"

    begin
      request = RestClient.get("http://maps.assessor.lacounty.gov/Geocortex/Essentials/REST/sites/PAIS/SQLAINSearch?f=json&AIN=#{apn}&dojo.preventCache=1449797179914")
      details = JSON.parse(request)['results']['ParcelDetails']

      address_from_apn = ''
      if details['Address1'].length > 0 && details['Address2'].length > 0
        address_from_apn = "#{details['Address1']}, #{details['Address2']}"
      end
    rescue
      puts "API error"
    end

    puts "Response: #{address_from_apn}"

    address_from_apn
  end

  def self.shape_from_apn(apn)
    return '' unless apn && apn.length > 0

    shape_from_apn = nil
    puts "Checking shape for apn: #{apn}"
    begin
      puts "Trying city"
      url = "http://maps.lacity.org/lahub/rest/services/Landbase_Information/MapServer/5/query?where=BPP%3D%27#{apn}%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=json"
      request = RestClient.get(url)
      parsed = JSON.parse(request)

      if parsed['features'].any?
        p "Found city shape"
        shape_from_apn = parsed['features'].first['geometry']['rings']
      else
        puts "City failed. Using county."
        url = "http://assessor.gis.lacounty.gov/assessor/rest/services/PAIS/pais_parcels/MapServer/0/query?f=json&where=AIN%20%3D%20%27#{apn}%27&returnGeometry=true&spatialRel=esriSpatialRelIntersects&outFields=AIN&outSR=102100"
        request = RestClient.get(url)
        parsed = JSON.parse(request)
        shape_from_apn = parsed['features'].first['geometry']['rings']
      end  

      puts "Response: #{shape_from_apn}"
      shape_from_apn
    rescue
      log_error("Couldn't get shape for APN: #{apn}")
      puts "Failed to fetch shape"
      nil
    end
  end

  def self.build_column_value(input_row, keys)
    return '' if keys.nil? || keys == ''
    return input_row[keys] unless keys.kind_of?(Array)
    keys.map do |key|
      input_row[key]
    end.join(' ')
  end
end

class Geobuilder
  def self.build
    in_csv = CSV.open("../data/master_with_dups.csv", { headers: true })

    features = []
    in_csv.each do |row|
      feature = build_feature_from_row(row)
      features << feature if feature
    end

    in_csv.close

    feature_collection = {
      "type": "FeatureCollection",
      "features": features
    }

    File.open('../data/geo.geojson', 'w') { |file| file.write(feature_collection.to_json) }
  end  

  def self.build_feature_from_row(row)
    if !row['Shape coords from APN'].nil? && row['Shape coords from APN'] != ''
      return {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": JSON.parse(row['Shape coords from APN']).map{ |polygon| polygon.map{ |coords| MercConvert.inverse(coords[0], coords[1]) } }
        },
        "properties": {
          "title": row['File name'],
          "APN": row['APN given']
        },
        "id": row['APN given']
      }
    elsif !row['Latlng from address given'].nil? && row['Latlng from address given'] != ''
      return {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": JSON.parse(row['Latlng from address given']).reverse
        },
        "properties": {
          "title": row['File name'],
          "address": row['Address given']
        },
        "id": SecureRandom.uuid
      }
    end
  end
end

# Merger.merge_file("2015 Registered Foreclosed Properties.csv", 'APN', 'Property Address', true)
# Merger.merge_file("Assumed outside LA City Limits.csv", 'AIN', 'PropertyLocation')
# Merger.merge_file("Brownfields Program - Sanitation Department.csv", 'APN', 'Address')
# Merger.merge_file("Building Book - GSD - 4468 FY 2014_by_building_book_number.csv", 'APN', ['Street #', 'Street Dir', 'Street Name', 'Street Type', 'Community', 'Zip Code'])
# Merger.merge_file("Building Book - GSD - 4468 FY 2014_listed_by_address.csv", 'APN', ['Street #', 'Street Dir', 'Street Name', 'Street Type', 'Community', 'Zip Code'])
# Merger.merge_file("City Owned Within CDs.csv", 'AIN', nil)
# Merger.merge_file("CRA Option Properties .csv", nil, 'Address')
# Merger.merge_file("CRA Property List Oct 2012.csv", 'Parcel Number', 'Address')
# Merger.merge_file("Decommissioned Fire Stations.csv", 'APN', nil)
# Merger.merge_file("GSD Facilities  For Filming.csv", nil, 'Address')
# Merger.merge_file("Insured Buildings & Uninsured Buildings -CAO - 359.csv", nil, ['Address','City', 'State', 'Zip'])
# Merger.merge_file("Leased properties to NPOs - GSD - 110 - FY 2014.csv", nil, 'Address')

# Manually cleaned
# Merger.merge_file("Master Property List (Simple) 03-7-2013- Update (1) (2) manual cleaned.csv", 'APN', ['Address', 'City'])

# Merger.merge_file("MICLA Commercial Paper Note Program.csv", nil, 'ADDRESS')
# Merger.merge_file("Neighborhood Land Trust Empty Lots .csv", 'AIN', nil)
# Merger.merge_file("Own a Piece of LA - OPLA (3).csv", 'APN', 'ADDRESS')
# Merger.merge_file("Parking Lots & Structures - LADOT.csv", nil, ['Address', 'Zip Code'])
# Merger.merge_file("Projected Surplus Properties Sales FY15-16 (Per GSD).csv", 'APN', ['PROPERTY ADDRESS', 'ZIP'])
# Merger.merge_file("Properties in BIDS - Compiled.csv", 'APN', 'Site Addr')
# Merger.merge_file("Properties Recommended for Disposition byb HCIDLA.csv", nil, ['City', 'Zip Code'])
# # # This file was manually cleaned!
# Merger.merge_file("Recreation and Parks - Provided by Department manual cleaned.csv", 'APN', ['Address', 'City'])

# Merger.merge_file("Reported Nuisance Properties FYs 14-16__14-15_sheet.csv", nil, ['Street #', 'Street Name', 'City & ZIP'])
# Merger.merge_file("Reported Nuisance Properties FYs 14-16__15-16_sheet.csv", nil, ['Street #', 'Street Name', 'City & ZIP'])
# Merger.merge_file("Residential Leases - GSD - 11 total - FY 2013.csv", nil, ['ADDRESS', 'ADDRESS_2'])
# Merger.merge_file("undeclared surplus property by id.csv", 'APN', 'ADDRESS')
# Merger.merge_file("Department of Building & Safety Vacant Buildings.csv", nil, ['Address', 'City'])
# Merger.merge_file("HCIDLA Owned Properties for Filming.csv", 'APN', ['Property Address', 'City', 'Zip Code'])

# Merger.update_headers

Geobuilder.build

# Deduper.dedup_all

# out_csv = CSV.open("../data/master_with_dups_patched.csv", "wb")
# out_csv << Merger.headers
# wrong = []
# CSV.open "../data/master_with_dups.csv", { headers: true } do |in_csv|
#   in_csv.each do |row|
#     if row['Shape coords from APN'].nil? || row['Shape coords from APN'] == ''
#       row['Shape coords from APN'] = Merger.shape_from_apn(row['APN given'])
#     end
#     out_csv << row
#   end
# end

# out_csv.close
