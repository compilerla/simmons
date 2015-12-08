require 'geocoder'
require 'UniversalDetector'
require 'fastercsv'
require 'iconv'

file_name = "Master Property List (Simple) 03-7-2013- Update (1) (2).csv"

output = []
errors = []

file_to_import = File.open("../data/compiled/#{file_name}")
# determine the encoding based on the first 100 characters
chardet = UniversalDetector::chardet(file_to_import.read[0..100])
if chardet['confidence'] > 0.7
  charset = chardet['encoding']
else 
  raise 'You better check this file manually.'
end

file_to_import.each_line do |l| 
  begin
    next if file_to_import.lineno == 1
    
    converted_line = Iconv.conv('utf-8', charset, l)
    row = FasterCSV.parse(converted_line)[0]

    addy = row[3]
    puts "Geocoding #{addy}"
    geo_response = Geocoder.search(addy).first
    compiled_addy = geo_response.address
    lat = geo_response.coordinates[0]
    lng = geo_response.coordinates[1]
    row[19] = compiled_addy
    row[20] = lat
    row[21] = lng
  rescue
    errors << { row: row, addy: addy }
  end
end

puts "Errors: #{errors}"

CSV.open("../data/compiled/#{file_name}", "wb") do |csv|
  output.each do |row|
    csv << row
  end
end