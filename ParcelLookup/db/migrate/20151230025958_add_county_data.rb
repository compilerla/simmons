class AddCountyData < ActiveRecord::Migration
  def change
    add_column :master_records, :county_data, :json, null: false, default: {}
  end
end
