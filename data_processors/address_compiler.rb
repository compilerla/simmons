require 'csv'
require 'geocoder'

Geocoder.configure({ lookup: :bing, api_key: 'AnoRWFu0Bv0UJChVOM5Lg02NB5xKgQTeRJjF0AzYny3hu5WkZw8WA303TDS5MCQj', timeout: 10})

class AddressCompiler
  def self.compile_addresses
    #AddressCompiler.new('../data/raw/2015 Registered Foreclosed Properties.csv',
    #                    ['Address', 'Zip Code']).compile!
    #AddressCompiler.new('../data/raw/Brownfields Program - Sanitation Department.csv',
    #                    ['Street Address']).compile!
    #AddressCompiler.new('../data/raw/Building Book - GSD - 4468 FY 2014_by_building_book_number.csv',
    #                    ['Street #','Street Dir','Street Name','Street Type','Bldg Name','Community', 'Zip Code']).compile!
    #AddressCompiler.new('../data/raw/Building Book - GSD - 4468 FY 2014_listed_by_address.csv',
    #                    ['Street #','Street Dir','Street Name','Street Type','Bldg Name','Community', 'Zip Code']).compile!
    #AddressCompiler.new('../data/raw/CRA Option Properties .csv',
    #                    ['Address']).compile!
    #AddressCompiler.new('../data/raw/CRA Property List Oct 2012.csv',
    #                    ['Address', 'Address2']).compile!
    #AddressCompiler.new('../data/raw/City Owned Within CDs.csv',
    #                    ['ADDRESS']).compile!
    #AddressCompiler.new('../data/raw/Decommissioned Fire Stations.csv',
    #                    ['LOCATION']).compile!
    AddressCompiler.new('../data/raw/GSD\ Facilities\ \ For\ Filming.csv',
                        ['Address']).compile!
    AddressCompiler.new('../data/raw/Insured Buildings & Uninsured Buildings -CAO - 359.csv',
                        ['Address','City','State','Zip']).compile!
    AddressCompiler.new('../data/raw/Leased properties to NPOs - GSD - 110 - FY 2014.csv',
                        ['Address']).compile!
    AddressCompiler.new('../data/raw/MICLA Assets.csv',
                        ['Asset Securing Lease']).compile!
    AddressCompiler.new('../data/raw/iMICLA Commercial Paper Note Program.csv',
                        ['ADDRESS']).compile!
  end

  def initialize(path_to_file, address_columns = [])
    @path_to_file = path_to_file
    @address_columns = address_columns
  end

  def compile!
    open_files
    headers = get_csv_headers(@in_csv)
    @out_csv << headers
    @in_csv.each do |row|
      @process_count += 1
      begin
        address = build_address_from_row(row)
        compiled_address = Geocoder.search(address).first
        add_compiled_address_to_row(compiled_address, row)
        out_row = headers.map { |column| row[column] }
        @out_csv << out_row.map(&:to_s).map(&:chomp) # remove new line chars
        puts "Processed #{@process_count} of #{@total_lines} with #{@error_count} errors" if @process_count % 50 == 0
        sleep(3) #geocoding rate limit
      rescue NoMethodError #nil geocoder
        @error_count += 1
        @errors_csv << headers.map { |column| row[column] }
      end
    end
    close_files
  end

  def open_files
    p @path_to_file
    @total_lines =  `wc -l < "#{@path_to_file}"`.to_i
    @error_count = 0
    @process_count = 0
    @in_csv = CSV.open(@path_to_file, headers: true)
    @out_csv = CSV.open("../data/compiled/#{@path_to_file.split('/').last}", 'wb')
    @errors_csv = CSV.open("../data/errors/#{@path_to_file.split('/').last}", 'wb')
  end

  def close_files
    @in_csv.close
    @out_csv.close
    @errors_csv.close
  end

  def get_csv_headers(csv)
    headers = csv.readline.headers
    csv.rewind
    headers << ['compiled_address', 'compiled_lat', 'compiled_lng']
    headers.flatten
  end

  def build_address_from_row(row)
    address_parts = @address_columns.map { |column| row[column] }
    address_parts.join(' ')
  end

  def add_compiled_address_to_row(compiled_address, row)
    row['compiled_address'] = compiled_address.address
    row['compiled_lat'] = compiled_address.coordinates[0]
    row['compiled_lng'] = compiled_address.coordinates[1]
  end
end
