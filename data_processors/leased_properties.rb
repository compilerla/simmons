require 'geocoder'

file_name = "Leased properties to NPOs - GSD - 110 - FY 2014.csv"

output = []
errors = []
CSV.foreach("../data/raw/#{file_name}", { :headers=>:first_row }) do |row|
  begin
    if $. == 1
      output << row
      next
    end

    addy = row[2]
    puts "Geocoding #{addy}"
    geo_response = Geocoder.search(addy).first
    compiled_addy = geo_response.address
    lat = geo_response.coordinates[0]
    lng = geo_response.coordinates[1]
    row[14] = compiled_addy
    row[15] = lat
    row[16] = lng

    output << row
  rescue
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