# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
require 'json'

factory = RGeo::Geographic.simple_mercator_factory()

file = File.read('../data/geo.geojson');0
data_hash = JSON.parse(file);0

data_hash['features'].each do |parcel|
  next unless parcel['geometry']['type'] == "Polygon"
  p parcel["geometry"]["coordinates"].first
  parcel_points = parcel["geometry"]["coordinates"].first.map do |coords|
    factory.point(coords[0], coords[1])
  end
  parcel_string = factory.line_string(parcel_points)
  parcel_polygon = factory.polygon(parcel_string)
  next if AinShape.where(ain: parcel['properties']['APN']).count > 0
  AinShape.where(ain: parcel['properties']['APN'], shape: parcel_polygon).first_or_create
end
data_hash = {}

# Load master_with_dupes into the master_record table

CSV.open('../data/master_with_dups.csv', headers: true) do |in_csv|
  in_csv.each do |row|
    lat = JSON.parse(row['Latlng from address given'] || '[]')[0]
    lon = JSON.parse(row['Latlng from address given'] || '[]')[1]
    MasterRecord.create(file_name: row['File name'],
                         apn_given: row['APN given'],
                         address_given: row['Address given'],
                         address_from_apn: row['Address from APN'],
                         address_latitude: lat,
                         address_longitude: lon)
  end
end
