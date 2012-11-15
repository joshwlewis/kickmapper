class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :project_url
      t.text :locations_cache

      t.timestamps
    end
  end
end
