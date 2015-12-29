# namespace :data do
#   desc "geocode using city's geocoder"
#   task geocode: :environment do
#     MasterRecord.where("apn_given IS NULL AND NOT(info ? 'cityprovidedlatlng')").find_each do |record|
#       begin
#         request_url = "http://myserver/arcgis/rest/services/SFOStreets/GeocodeServer/geocodeAddresses?addresses={'records':[{'attributes':{'STREET':'440 Arguello Blvd'}}]}&outSR=&f=pjson"
#       rescue
#         p "Failed on record #{record.id}"
#       end
#     end
#   end
# end