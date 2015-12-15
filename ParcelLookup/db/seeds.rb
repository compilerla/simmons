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

  AinShape.create(ain: parcel['properties']['id'], shape: parcel_polygon)
end
