require 'csv'

# file_name = "2015 Registered Foreclosed Properties.csv"

# in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
# out_csv = CSV.open("../data/master_with_dups.csv", "wb")

# out_csv << ['source', 'apn_given', 'address_given', 'address']
# in_csv.each do |row|
#   out_csv << [file_name, row['APN'], row['Property Address'], '']
# end

# in_csv.close
# out_csv.close



# file_name = "Assumed outside LA City Limits.csv"

# in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
# out_csv = CSV.open("../data/master_with_dups.csv", "ab")
# in_csv.each do |row|
#   out_csv << [file_name, row['AIN'], row['PropertyLocation'], '']
# end

# in_csv.close
# out_csv.close


# file_name = "Brownfields Program - Sanitation Department.csv"

# in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
# out_csv = CSV.open("../data/master_with_dups.csv", "ab")
# in_csv.each do |row|
#   out_csv << [file_name, row['APN'], row['Address'], '']
# end

# in_csv.close
# out_csv.close



file_name = "Building Book - GSD - 4468 FY 2014_by_building_book_number.csv"
in_csv = CSV.open("../data/raw/#{file_name}", { headers: true })
out_csv = CSV.open("../data/master_with_dups.csv", "ab")
in_csv.each do |row|
  out_csv << [file_name, row['APN'], "#{row['Street #']} #{row['Street Dir']} #{row['Street Name']} #{row['Street Type']} #{row['Zip Code']}", '']
end

in_csv.close
out_csv.close
