class AddSourceFileAndAinMatch < ActiveRecord::Migration
  def change
    create_table :master_records do |t|
      t.string :file_name
      t.string :apn_given
      t.string :address_given
      t.string :address_from_apn
      t.float :address_latitude
      t.float :address_longitude
    end

    create_table :ain_shapes_master_records do |t|
      t.integer :master_record_id
      t.integer :ain_shape_id
      t.string :match_method
    end
  end
end
