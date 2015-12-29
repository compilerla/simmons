class AddInfoToMasterRecords < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION hstore'
    add_column :master_records, :info, :hstore, default: {}
  end
end
