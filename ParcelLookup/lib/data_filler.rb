require 'csv'
require 'rest-client'
require 'merc_convert'
require 'geocoder'
require 'securerandom'

class DataFiller
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