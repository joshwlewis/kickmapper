class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :project_url
      t.string :name
      t.string :description
      t.string :image_url

      t.timestamps
    end
  end
end
