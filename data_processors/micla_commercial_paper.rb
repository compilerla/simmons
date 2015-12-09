require 'geocoder'

file_name = "MICLA Commercial Paper Note Program.csv"

output = []
errors = []
CSV.foreach("../data/raw/#{file_name}", { :headers=>:first_row }) do |row|
  begin
    addy = row[1]
    puts "Geocoding #{addy}"
    geo_response = Geocoder.search(addy).first
    compiled_addy = geo_response.address
    lat = geo_response.coordinates[0]
    lng = geo_response.coordinates[1]
    row[2] = compiled_addy
    row[3] = lat
    row[4] = lng

    output << row
  rescue
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