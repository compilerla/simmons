require 'csv'

file_name = "2015 Registered Foreclosed Properties.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "wb")

out_csv << ['source', 'apn_given', 'address_given', 'address']
in_csv.each do |row|
  out_csv << [file_name, row['APN'], row['Property Address'], '']
end

in_csv.close
out_csv.close



file_name = "Assumed outside LA City Limits.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['AIN'], row['PropertyLocation'], '']
end

in_csv.close
out_csv.close


file_name = "Brownfields Program - Sanitation Department.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], row['Address'], '']
end

in_csv.close
out_csv.close



file_name = "Building Book - GSD - 4468 FY 2014_by_building_book_number.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], "#{row['Street #']} #{row['Street Dir']} #{row['Street Name']} #{row['Street Type']} #{row['Zip Code']}", '']
end

in_csv.close
out_csv.close



file_name = "Building Book - GSD - 4468 FY 2014_listed_by_address.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], "#{row['Street #']} #{row['Street Dir']} #{row['Street Name']} #{row['Street Type']} #{row['Zip Code']}", '']
end

in_csv.close
out_csv.close



file_name = "City Owned Within CDs.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['AIN'], '', '']
end

in_csv.close
out_csv.close


file_name = "CRA Option Properties .csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', row['Address'], '']
end

in_csv.close
out_csv.close


file_name = "CRA Property List Oct 2012.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['Parcel Number'], row['Address'], '']
end

in_csv.close
out_csv.close


file_name = "Decommissioned Fire Stations.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], '', '']
end

in_csv.close
out_csv.close


file_name = "GSD Facilities  For Filming.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', row['Address'], '']
end

in_csv.close
out_csv.close


file_name = "Insured Buildings & Uninsured Buildings -CAO - 359.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', "#{row['Address']}, #{row['City']}, #{row['State']}, #{row['Zip']} #{row['Zip Code']}", '']
end

in_csv.close
out_csv.close



file_name = "Leased properties to NPOs - GSD - 110 - FY 2014.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', row['Address'], '']
end

in_csv.close
out_csv.close


file_name = "Master Property List (Simple) 03-7-2013- Update (1) (2).csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], row['Address'], '']
end

in_csv.close
out_csv.close



file_name = "MICLA Commercial Paper Note Program.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', row['ADDRESS'], '']
end

in_csv.close
out_csv.close


file_name = "Neighborhood Land Trust Empty Lots .csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['AIN'], '', '']
end

in_csv.close
out_csv.close


file_name = "Own a Piece of LA - OPLA (3).csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], row['ADDRESS'], '']
end

in_csv.close
out_csv.close



file_name = "Parking Lots & Structures - LADOT.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', "#{row['Address']}, #{row['Zip Code']}", '']
end

in_csv.close
out_csv.close


file_name = "Projected Surplus Properties Sales FY15-16 (Per GSD).csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], "#{row['PROPERTY ADDRESS']}, #{row['ZIP']}", '']
end

in_csv.close
out_csv.close


file_name = "Properties in BIDS - Compiled.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], row['Site Addr'], '']
end

in_csv.close
out_csv.close


file_name = "Properties Recommended for Disposition byb HCIDLA.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', "#{row['Property Address']}, #{row['City']}, #{row['Zip Code']}", '']
end

in_csv.close
out_csv.close



# !!!!!!!!!! NEED TO FIX THIS ONE!!!!!!!!
file_name = "Recreation and Parks - Provided by Department.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', "#{row['Property Address']}, #{row['City']}, #{row['Zip Code']}", '']
end

in_csv.close
out_csv.close



file_name = "Reported Nuisance Properties FYs 14-16__14-15_sheet.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', "#{row['Street #']} #{row['Street Name']}, #{row['City & ZIP']}", '']
end

in_csv.close
out_csv.close



# !!!!!!!!!! NEED TO FIX THIS ONE!!!!!!!! (malformed csv)
file_name = "Reported Nuisance Properties FYs 14-16__15-16_sheet.csv"

in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, '', "#{row['Street #']} #{row['Street Name']}, #{row['City & ZIP']}", '']
end

in_csv.close
out_csv.close



# file_name = "Residential Leases - GSD - 11 total - FY 2013.csv"

# in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
# out_csv = CSV.open("../data/master_with_dups.csv", "ab")
# in_csv.each do |row|
#   out_csv << [file_name, '', "#{row['ADDRESS']}, #{row['ADDRESS_2']}", '']
# end

# in_csv.close
# out_csv.close



# file_name = "undeclared surplus property by id.csv"

# in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
# out_csv = CSV.open("../data/master_with_dups.csv", "ab")
# in_csv.each do |row|
#   out_csv << [file_name, row['APN'], row['ADDRESS'], '']
# end

# in_csv.close
# out_csv.close


