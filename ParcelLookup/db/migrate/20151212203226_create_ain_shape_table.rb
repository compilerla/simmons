class CreateAinShapeTable < ActiveRecord::Migration
  def change
    create_table :ain_shapes do |t|
      t.st_polygon :shape
      t.string :ain
    end
  end
end
