require 'geocoder'

file_name = "Master Property List (Simple) 03-7-2013- Update (1) (2).csv"

output = []
errors = []
CSV.foreach("../data/raw/#{file_name}", { :headers=>:first_row }) do |row|
  begin
    addy = row[3]
    puts "Geocoding #{addy}"
    geo_response = Geocoder.search(addy).first
    compiled_addy = geo_response.address
    lat = geo_response.coordinates[0]
    lng = geo_response.coordinates[1]
    row[19] = compiled_addy
    row[20] = lat
    row[21] = lng

    output << row
  rescue
    row[19] = nil
    row[20] = nil
    row[21] = nil
    output << row
    errors << { row: row, addy: addy }
  end
end

CSV.open("../data/compiled/#{file_name}", "wb") do |csv|
  output.each do |row|
    csv << row
  end
end

CSV.open("../data/errors.csv", "ab") do |csv|
  errors.each do |error|
    csv << [error[:addy], '', '']
  end
end
