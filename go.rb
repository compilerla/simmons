require 'roo'
require './property.rb'

easy = []
annoying = []

Dir.foreach('./files') do |item|
  next if item == '.' or item == '..'
  
  begin
    sheet = Roo::Spreadsheet.open("./files/#{item}")
    if (sheet.row(1).map(&:downcase) & ['apn', 'ain', 'address']).any?
      easy << item
    end
  rescue
    annoying << item
  end

end

puts "#{easy.count} easy files. #{annoying.count} annoying ones."