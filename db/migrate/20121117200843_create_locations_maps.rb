class CreateLocationsMaps < ActiveRecord::Migration
  def change
    create_table :locations_maps do |t|
      t.references :map
      t.references :location
    end
  end
end
