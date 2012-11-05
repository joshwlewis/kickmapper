class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :project_url
      t.text :location_data

      t.timestamps
    end
  end
end
